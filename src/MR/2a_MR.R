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

out_f <- file.path(data_scratch_d, 'UKB_MR', 'tmp_out', sprintf('%s.%s.%s.tsv', HGI_cc, HGI_sx, GBE_ID))
####################################################################

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

bind_rows(
    lm(BETA_hgi ~ 0 + BETA_ukb, df, weights = (df$SE_hgi ** (-2))) %>% fit_to_df() %>%
    mutate(method = 'IVW'),
    # can add other methods
) %>%
mutate(
    HGI_case_control = HGI_cc,
    HGI_suffix = HGI_sx,
    trait = GBE_ID
) %>%
rename('#variable' = 'variable') %>%
fwrite(out_f, sep='\t', na = "NA", quote=F)
