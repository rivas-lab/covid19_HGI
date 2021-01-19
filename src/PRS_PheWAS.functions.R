suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))

cat_or_zcat <- function(f){
    ifelse(endsWith(f, '.zst'), 'zstdcat', ifelse(endsWith(f, '.gz'), 'zcat', 'cat'))
}

GBE_ID_to_family <- function(GBE_ID){
    ifelse(str_replace_all(GBE_ID, '[0-9]+', '') %in% c('INI', 'QT_FC'), 'gaussian', 'binomial')
}

fit_to_df <- function(fit){
    # convert the fit object to a data frame
    fit_df <- summary(fit)$coeff %>%
    as.data.frame() %>% rownames_to_column('variable')
    colnames(fit_df) <- c('variable', 'estimate', 'SE', 'z_or_t_value', 'P')
    fit_df
}

PRS_PheWAS <- function(df, phenotype, PRS_col, covariates){
    glmfam <- GBE_ID_to_family(phenotype)
    glmfit <- stats::glm(
        stats::as.formula(sprintf(
            'pheno ~ 1 + %s + scale(PRS)',
            paste(covariates, collapse =' + ')
        )),
        family=glmfam,
        data=df %>%
        select(all_of(c('FID', 'IID', covariates, PRS_col, phenotype))) %>%
        rename(!!'PRS':= all_of(PRS_col)) %>%
        rename(!!'pheno':= all_of(phenotype)) %>%
        drop_na(pheno, PRS) %>%
        filter(pheno != -9) %>%
        mutate(pheno = pheno - ifelse(glmfam == 'binomial', 1, 0))
    )
    glmfit %>% fit_to_df() %>%
    mutate(phe = phenotype, PRS = PRS_col) %>%
    select(phe, PRS, variable, estimate, SE, z_or_t_value, P)
}
