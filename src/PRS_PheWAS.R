fullargs <- commandArgs(trailingOnly=FALSE)
args <- commandArgs(trailingOnly=TRUE)

script.name <- normalizePath(sub("--file=", "", fullargs[grep("--file=", fullargs)]))

suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))

####################################################################
source('PRS_PheWAS.functions.R')
####################################################################

PRS_f     <- args[1]
PRS_col   <- args[2] # 'SCORE1_SUM'
phe_f     <- args[3]
phe_lst_f <- args[4]
keep_f    <- args[5]
out_f     <- args[6]

####################################################################
# constatns
covariates <- c('age', 'age_sq', 'sex', paste0('PC', 1:10))

# read data

phe_lst_f %>% fread(head=F) %>% pull() -> phe_lst

keep_f %>% fread(head=F, colClasses = 'character') %>% rename('FID'=1, 'IID'=2) -> keep_df

fread(
    cmd=paste(cat_or_zcat(PRS_f), PRS_f),
    colClasses = c('#FID'='character', 'IID'='character'),
    select = all_of(c('#FID', 'IID', PRS_col))
) %>% rename('FID'='#FID') -> PRS_df

fread(
    cmd=paste(cat_or_zcat(phe_f), phe_f),
    colClasses = c('#FID'='character', 'IID'='character'),
    select = all_of(c('#FID', 'IID', setdiff(covariates, c('age_sq')), phe_lst))
) %>% rename('FID'='#FID') %>% mutate(
    age_sq = age * age
    # we confirmed that the age field does not have missing value (-9)
) -> phe_df

# join
PRS_df %>%
inner_join(keep_df, by=c('FID', 'IID')) %>%
inner_join(phe_df, by=c('FID', 'IID')) -> df

intersect(phe_lst, colnames(phe_df)) %>%
lapply(function(p){
    message(p)
    tryCatch({
        PRS_PheWAS(df, p, PRS_col, covariates)
    }, error=function(e){ message(e) })
}) %>% bind_rows() %>%
rename('#phe' = 'phe') %>%
fwrite(out_f, sep='\t', na = "NA", quote=F)
