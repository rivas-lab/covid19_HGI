fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))

####################################################################
in_f <- args[1]
out_f <- args[2]
####################################################################

fread(in_f, colClasses=c('#CHR'='character')) %>%
rename('CHR'='#CHR') %>% mutate(A1=ALT) %>%
select(
    CHR, POS, SNP, REF, ALT, A1, all_meta_sample_N,
    all_inv_var_meta_beta, all_inv_var_meta_sebeta, all_inv_var_meta_p
) %>% rename(
    'CHROM'='CHR',
    'ID'='SNP',
    'OBS_CT'='all_meta_sample_N',
    'BETA'='all_inv_var_meta_beta',
    'SE'='all_inv_var_meta_sebeta',
    'P'='all_inv_var_meta_p'
) %>% rename('#CHROM' = 'CHROM') %>%
fwrite(out_f, sep='\t', na = "NA", quote=F)
