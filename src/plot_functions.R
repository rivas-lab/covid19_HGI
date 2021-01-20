source('colorblind_colors.R')

suppressWarnings(suppressPackageStartupMessages({
    library(tidyverse)
    library(data.table)
}))

p_PRS_phewas <- function(df){
    df %>% ggplot(aes(x = -log10(P), y = reorder(GBE_short_name, -log10(P)), color=plot_color, shape=plot_shape)) +
    geom_point(size=4) + xlim(0, NA) + theme_bw(base_size=12) +
    scale_shape_manual(values=setNames(c(17, 6), c('+', '-'))) +
    guides(
        color = guide_legend(title='Category', size=6),
        shape = FALSE
    ) +
    theme(
        legend.position=c(.7,.2),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10)
    ) +
    labs(
        x = latex2exp::TeX('PRS-PheWAS -log_{10}P'),
        y = 'UKB phenotype'
    )
}

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

p_HGIbeta_vs_UKBbeta <- function(df){
    df %>% mutate(
    plot_label =if_else(
        (rank(-abs(BETA_HGI)) <= 10) | (rank(-abs(BETA_UKB)) <= 10),
        if_else(is.na(SYMBOL), paste(CHROM,POS,REF,ALT, sep=':'), SYMBOL),
        ''
    )) %>%
    ggplot(aes(x=BETA_HGI, y=BETA_UKB, label = plot_label, color=is_in_chr3_chemokine_region)) +
    geom_vline(xintercept=0, color="gray") + 
    geom_hline(yintercept=0, color="gray") +
    geom_errorbarh(aes(xmin = BETA_HGI-SE_HGI,  xmax = BETA_HGI+SE_HGI), alpha=.3) +
    geom_errorbar( aes(ymin = BETA_UKB-SE_UKB,  ymax = BETA_UKB+SE_UKB), alpha=.3) +
    geom_point()+ theme_bw(base_size = 20) +
    ggrepel::geom_text_repel(force=10, size=5) +
    theme(legend.position='none') +
    scale_color_manual(values=setNames(c(cb.colors[['orange']], cb.colors[['sky.blue']]), c(TRUE, FALSE))) +
    labs(
        x = latex2exp::TeX('GWAS BETA [SE], COVID-19 HGI'),
        y = latex2exp::TeX('GWAS BETA [SE], UKB trait')
    )
}

p_HGIpval_vs_UKBpval <- function(df){
    df %>% mutate(
        plot_label =if_else(
            (rank(log10P_HGI) <= 5) | (rank(log10P_UKB) <= 2),
            if_else(is.na(SYMBOL), paste(CHROM,POS,REF,ALT, sep=':'), SYMBOL),
            ''
    )) %>%
    ggplot(aes(x=-log10P_HGI, y=-log10P_UKB, label = plot_label, color=is_in_chr3_chemokine_region)) +
    geom_point()+ theme_bw(base_size = 20) +
    ggrepel::geom_text_repel(force=10, size=5) +
    theme(legend.position='none') +
    scale_color_manual(values=setNames(c(cb.colors[['orange']], cb.colors[['sky.blue']]), c(TRUE, FALSE))) +
    labs(
        x = latex2exp::TeX('GWAS -log_{10}(P), COVID-19 HGI'),
        y = latex2exp::TeX('GWAS -log_{10}(P), UKB trait')
    )
}

