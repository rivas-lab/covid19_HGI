fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))

####################################################################
source('../0_parameters.sh')
source('../PRS_PheWAS.functions.R')
source('MR_functions.R')

####################################################################
HGI_cc <- args[1]
HGI_sx <- args[2]
GBE_ID <- args[3]

# HGI_cc <- 'C2'
# HGI_sx <- 'eur_leave_ukbb_23andme'
# GBE_ID <- 'HC166'

p_thr <- 5e-8

out_prefix <- file.path(data_scratch_d, 'UKB_MR', 'tmp_out', sprintf('%s.%s.%s', HGI_cc, HGI_sx, GBE_ID))
####################################################################

ukb_phe_info %>% fread() -> ukb_phe_info_df
setNames(
    ukb_phe_info_df$GBE_short_name,
    ukb_phe_info_df$GBE_ID
) -> ukb_phe_info_dict

ukb_array_combined_annot_f %>%
fread(select=c('ID', 'ld_indep')) -> annot_df

file.path(data_d, 'plink_format_UKB_cal', UKB_cal_f) %>%
str_replace('@@HGI_case_control@@', HGI_cc) %>%
str_replace('@@HGI_suffix@@', HGI_sx) %>%
read_sumstats() -> hgi_df

file.path(data_scratch_d, 'UKB_MR', 'sumstats', sprintf('%s.p1e-5.tsv.gz', GBE_ID)) %>%
read_sumstats() %>% filter(log10P < log10(p_thr)) -> ukb_df

if(! 'BETA' %in% names(ukb_df)){
    ukb_df %>% mutate(BETA = log(OR)) %>%
    rename('SE'='LOG(OR)_SE') -> ukb_df
}

ukb_df %>% filter(ID %in% (annot_df %>% filter(ld_indep == T) %>% pull(ID))) %>%
join_ukb_hgi(hgi_df) -> df

lmfit <- lm(BETA_hgi ~ 0 + BETA_ukb, df, weights = (df$SE_hgi ** (-2)))

bind_rows(
    lmfit %>% fit_to_df() %>% mutate(method = 'IVW'),
    # can add other methods
) %>%
mutate(
    HGI_case_control = HGI_cc,
    HGI_suffix = HGI_sx,
    trait = GBE_ID,
    trait_name = ukb_phe_info_dict[[GBE_ID]]
) %>%
rename('#variable' = 'variable') %>%
fwrite(sprintf('%s.tsv', out_prefix), sep='\t', na = "NA", quote=F)

df %>% plot_beta_vs_beta(lmfit) +
labs(
    title = sprintf(
        'MR (%s)\nIVW estimate: %.2e, p = %.2e',
        HGI_sx,
        (lmfit)$coefficients[['BETA_ukb']],
        fit_to_df(lmfit) %>% pull(P)
    ),
    y = sprintf('BETA[SE] HGI (%s)', HGI_cc),
    x = sprintf('BETA[SE] UKB (%s)\n%s', GBE_ID, ukb_phe_info_dict[[GBE_ID]])
) -> p

ggsave(sprintf('%s.png', out_prefix), p, height=8, width=8)
ggsave(sprintf('%s.pdf', out_prefix), p, height=8, width=8)
