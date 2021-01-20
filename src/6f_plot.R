fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))
####################################################################
# clumpp <- 1e-5
# HGI_cc <- 'B2'
# HGI_sx <- 'eur_leave_ukbb_23andme'

# pheno <- 'INI30130'
HGI_cc <- args[1]
HGI_sx <- args[2]
clumpp <- as.numeric(args[3])

pheno <- args[4]
####################################################################
source(file.path(dirname(script.name), '0_parameters.sh'))
source(file.path(dirname(script.name), '0_parameters_chr3_chemokine_pos.sh'))
source(file.path(dirname(script.name), 'plot_functions.R'))
####################################################################
clumpp_str <- str_replace(sprintf('%.0e', clumpp), '0', '')

ukb_phe_info %>% fread(select=c('GBE_ID', 'GBE_short_name')) -> ukb_phe_info_df
setNames(ukb_phe_info_df$GBE_short_name, ukb_phe_info_df$GBE_ID) -> ukb_phe_info_named_l

HGI_sumstats_f <- file.path(
    data_d, 'plink_format_UKB_cal',
    UKB_cal_f %>%
    str_replace('@@HGI_case_control@@', HGI_cc) %>%
    str_replace('@@HGI_suffix@@', HGI_sx)
)

clump_f <- file.path(
    data_d, 'UKB_PRS_clump',
    basename(HGI_sumstats_f) %>%
    str_replace('.tsv.gz$', str_replace(sprintf('.clump%.0e.clumped.gz', clumpp), '0', ''))
)

UKB_sumstats_f <- file.path(
    data_d, 'UKB_PRS_PheWAS_follow_up_GWAS',
    sprintf('ukb.%s.glm.gz', pheno)
)

clump_f %>% fread() %>% pull(SNP) -> clumped_vars

ukb_cal_annotation_f %>%
fread(colClasses = c('#CHROM'='character')) %>%
rename('CHROM'='#CHROM')  -> ukb_cal_annotation_df

UKB_sumstats_f %>% fread(colClasses = c('#CHROM'='character')) %>%
rename('CHROM'='#CHROM') %>% filter(ID %in% clumped_vars) -> UKB_sumstats_df

HGI_sumstats_f %>% fread(colClasses = c('#CHROM'='character')) %>%
rename('CHROM'='#CHROM') %>% filter(ID %in% clumped_vars) -> HGI_sumstats_df

inner_join(
    UKB_sumstats_df %>%
    separate(P, c('P_base', 'P_exp'), sep='e', remove=F, fill='right') %>%
    replace_na(list(P_exp='0')) %>% mutate(log10P = log10(as.numeric(P_base)) + as.numeric(P_exp)) %>%
    select(CHROM, POS, ID, BETA, SE, P, log10P),
    HGI_sumstats_df %>%
    separate(P, c('P_base', 'P_exp'), sep='e', remove=F, fill='right') %>%
    replace_na(list(P_exp='0')) %>% mutate(log10P = log10(as.numeric(P_base)) + as.numeric(P_exp)) %>%
    select(CHROM, POS, ID, BETA, SE, P, log10P),
    by=c('CHROM', 'POS', 'ID'),
    suffix=c('_UKB', '_HGI')
) %>%
left_join(
    ukb_cal_annotation_df %>% select(ID, REF, ALT, SYMBOL),
    by='ID'
) %>% mutate(
    is_in_chr3_chemokine_region = (
        CHROM == '3' &
        ((chr3_chemokine_pos - remove_half_window) <= POS) &
        (POS <= (chr3_chemokine_pos + remove_half_window))
    )
) -> df

df %>% p_HGIpval_vs_UKBpval() -> p_pval
df %>% p_HGIbeta_vs_UKBbeta() -> p_beta

out_f <- file.path(
    repo_fig_d, 'UKB_PRS_PheWAS_follow_up_GWAS', HGI_sx, HGI_cc, sprintf(
        'HGIrel5_%s_%s.clump%s.%s.png',
        HGI_cc, HGI_sx, clumpp_str, pheno
    )
)


if(!dir.exists(dirname(dirname(out_f)))) dir.create(dirname(dirname(out_f)))
if(!dir.exists(dirname(out_f))) dir.create(dirname(out_f))

gridExtra::arrangeGrob(
    p_pval, p_beta, ncol=2,
    top=grid::textGrob(sprintf(
        "Comparison of GWAS associations (%s, %s, clump p1: %s)\n%s (%s)",
        HGI_cc, HGI_sx, clumpp_str,
        ukb_phe_info_named_l[[pheno]], pheno
    ),gp=grid::gpar(fontsize=20))
) -> g

ggsave(file=out_f, g, width=16, height=8)
ggsave(file=str_replace(out_f, '.png$', '.pdf'), g, width=16, height=8)
