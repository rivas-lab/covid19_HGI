

compute_IVW_estimate <- function(df){
    sum(df$ratio * ((df$SE_hgi) ** -2)) / sum((df$SE_hgi) ** -2)
}

join_ukb_hgi <- function(ukb_df, hgi_df){
    inner_join(
        ukb_df, hgi_df, 
        by=c('CHROM','POS','ID','REF','ALT','A1'),
        suffix = c("_ukb", "_hgi")
    ) %>%
    mutate(
        ratio = BETA_hgi / BETA_ukb
    )
}

read_sumstats <- function(f){
    f %>% 
    fread(colClasses = c('#CHROM'='character', 'P'='character')) %>%
    rename('CHROM'='#CHROM') %>%
    separate(P, c('P_base', 'P_exp'), sep='e', remove=F, fill='right') %>%
    replace_na(list(P_exp='0')) %>%
    mutate(log10P = log10(as.numeric(P_base)) + as.numeric(P_exp))
}

plot_beta_vs_beta <- function(df){
    lmfit <- lm(BETA_hgi ~ 0 + BETA_ukb, df, weights = (df$SE_hgi ** (-2)))
    print(lmfit)
    df %>% ggplot(aes(x = BETA_ukb, y = BETA_hgi)) + 
    geom_abline(
        slope = (lmfit)$coefficients[['BETA_ukb']],
        color='red', alpha=.5
    ) + 
    geom_point(alpha=.1) +
    theme_bw()
}
