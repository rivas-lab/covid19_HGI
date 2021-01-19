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
ukb_cal_pvar <- args[3]
####################################################################
fread(
    cmd=paste('zstdcat', ukb_cal_pvar, '|', 'sed -e "s/^#//g"'),
    colClasses=c('CHROM'='character')
) -> ukb_pvar_df

fread(in_f, colClasses=c('#CHROM'='character')) %>%
rename('CHROM'='#CHROM') -> in_df

ukb_pvar_df %>%
inner_join(in_df %>% rename('HGI_ID'='ID') , by=c('CHROM', 'POS', 'REF', 'ALT')) %>%
select(CHROM, POS, ID, REF, ALT, A1, OBS_CT, BETA, SE, P) %>%
rename('#CHROM' = 'CHROM') %>%
fwrite(out_f, sep='\t', na = "NA", quote=F)
