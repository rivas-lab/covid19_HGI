fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))

####################################################################
source('0_parameters.sh')
source(snpnet_misc_R)

####################################################################

UKB_phe <- args[1]
HGI_case_control <- args[2]
HGI_suffix <- args[3]
clump_p1 <- args[4]

# UKB_phe <- 'covid19_severe'
# HGI_case_control <- 'B2'
# HGI_suffix <- 'eur_leave_ukbb_23andme'
# clump_p1 <- '1e-5'

####################################################################
covariates <- c('age', 'sex', paste0('PC', 1:10))

####################################################################

generate_eval_from_df_with_renamed_cols <- function(dff){
    dff %>% count(split, phe) %>%
    mutate(phe = if_else(phe==2, 'case_n', 'control_n')) %>%
    spread(phe, n) %>% filter(control_n>0, case_n>0) %>%
    arrange(-case_n) -> split_cnt_df

    dff %>%
    build_eval_df((split_cnt_df %>% pull(split)), 'auc') %>%
    left_join(split_cnt_df, by='split') %>%
    mutate(
        UKB_phe = UKB_phe,
        HGI_case_control = HGI_case_control,
        HGI_suffix = HGI_suffix,
        clump_p1 = clump_p1
    ) %>%
    select(UKB_phe, HGI_case_control, HGI_suffix, clump_p1, geno, covar, geno_covar, case_n, control_n)    
}

####################################################################

# run-time parameters
PRS_col <- paste('PRS', HGI_case_control, HGI_suffix, clump_p1, sep='.')
out_base_prefix <- paste(UKB_phe, PRS_col, sep='.')

# read phe file
file.path(data_d, 'UKB_PRS_eval', 'UKB.WB.phe.gz') %>%
fread(colClasses = c('#FID'='character', 'IID'='character')) %>%
rename('FID'='#FID') -> phe_df

# read PRS file
file.path(data_d, 'UKB_PRS_clump.phe.gz') %>%
fread(
    colClasses = c('#FID'='character', 'IID'='character'),
    select=c('#FID', 'IID', PRS_col)
) %>%
rename('FID'='#FID') %>%
rename(!!'geno_score' := all_of(PRS_col)) -> PRS_df

# join them and restrict to the WB
phe_df %>% left_join(PRS_df, by = c("FID", "IID")) %>%
mutate(split = 'UKB_WB') -> df

# rename columns 
df %>% 
rename(!!'phe' := all_of(UKB_phe)) %>%
rename(!!'covar_score' := all_of(paste(UKB_phe, 'covar_score', sep='.'))) -> dff


dff %>% generate_eval_from_df_with_renamed_cols() %>%
rename('#UKB_phe' = 'UKB_phe') %>%
fwrite(file.path(data_d, 'UKB_PRS_eval', 'eval_df', paste0(out_base_prefix, '.tsv')), sep='\t', na = "NA", quote=F)


# prepare data frames for the plots
dff %>% drop_na(geno_score, phe) %>%
mutate(geno_score_percentile = rank(-geno_score) / n()) -> plot_df

summary_plot_df <- plot_df %>%
compute_summary_df('geno_score_percentile', 'phe', family='binomial')


p1 <- plot_df %>% plot_PRS_binomial() +
labs(
    y = 'LD-clumping based PRS (Z-score)',
    title = sprintf('%s  %s', UKB_phe, PRS_col)
)

p2 <- summary_plot_df %>% plot_PRS_bin_vs_OR() +
labs(
    x = 'Percentitle of LD-clumping based PRS',
    title = sprintf('%s  %s', UKB_phe, PRS_col)
)

plot_f <- file.path(data_d, 'UKB_PRS_eval', 'plots', paste0(out_base_prefix, '.pdf'))

g <- gridExtra::arrangeGrob(p1, p2, ncol=2)
ggsave(plot_f, g, width=12, height=6)
ggsave(str_replace(plot_f, '.pdf$', '.png'), g, width=12, height=6)
