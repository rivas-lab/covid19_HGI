source('colorblind_colors.R')

suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))

p_beta_vs_beta <- function(df){
    df %>%
    mutate(
        min = pmin(estimate.w_chr3 - SE.w_chr3, estimate.wo_chr3 - SE.wo_chr3),
        max = pmax(estimate.w_chr3 + SE.w_chr3, estimate.wo_chr3 + SE.wo_chr3)
    ) -> min_max_df
    lim_min <- 1.05 * min(min_max_df$min, 0)
    lim_max <- 1.05 * max(min_max_df$max, 0)
       
    df %>%
    mutate(plot_label = if_else(
        rank( - pmax(abs(estimate.w_chr3), abs(estimate.wo_chr3)) ) <= 5,
        paste0(GBE_short_name, '(', GBE_ID, ')'), 
        ''
    )) %>%
    ggplot(aes(x = estimate.w_chr3, y = estimate.wo_chr3, label=plot_label)) +
    geom_abline(slope=1, intercept = 0, color='gray') +
    geom_errorbarh(aes(xmin = estimate.w_chr3  - SE.w_chr3,  xmax = estimate.w_chr3  + SE.w_chr3),  alpha=.2) +
    geom_errorbar( aes(ymin = estimate.wo_chr3 - SE.wo_chr3, ymax = estimate.wo_chr3 + SE.wo_chr3), alpha=.2) +
    geom_point() + theme_bw(base_size = 20) + 
    xlim(lim_min, lim_max) + ylim(lim_min, lim_max) + 
    labs(
        x = 'BETA [SE] estimate of scale(PRS), with chr3',
        y = 'BETA [SE] estimate of scale(PRS), without chr3'
    ) + ggrepel::geom_text_repel(size=4, color=cb.colors[['sky.blue']])
}

p_pval_vs_pval <- function(df){
    df %>% mutate(max = pmax(log10P.w_chr3, log10P.wo_chr3)) %>%
    pull(max) %>% max() -> lim_max
    
    df %>%
    mutate(plot_label = if_else(
#         log10P.w_chr3 > 10 | log10P.wo_chr3 > 10, 
        rank( - pmax(log10P.w_chr3, log10P.wo_chr3) ) <= 5,
        paste0(GBE_short_name, '(', GBE_ID, ')'), 
        ''
    )) %>%
    ggplot(aes(x = log10P.w_chr3, y = log10P.wo_chr3, label=plot_label)) +
    geom_abline(slope=1, intercept = 0, color='gray') +
    geom_point() + theme_bw(base_size = 20) + 
    xlim(0, lim_max) + ylim(0, lim_max) + 
    labs(
        x = latex2exp::TeX('-log_{10}(P) of scale(PRS), with chr3 region'),
        y = latex2exp::TeX('-log_{10}(P) of scale(PRS), without chr3 region')
    )  + ggrepel::geom_text_repel(force=10, size=5, color=cb.colors[['sky.blue']])

}

