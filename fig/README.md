# Figures

This directory contains the results from the analysis.

Currently, there are the following subdirectories, each corresponds to a specific analysis.

- [`UKB_PRS_PheWAS`](UKB_PRS_PheWAS): the main PRS-PheWAS analysis conducted within UK Biobank dataset.
  - [`HGIrel5.PRS_PheWAS.1e-5.tsv.gz`](HGIrel5.PRS_PheWAS.1e-5.tsv.gz): a compressed table file that contains the summary statistics of the UKB PRS-PheWAS analysis.
- [`UKB_PRS_PheWAS_follow_up_GWAS`](UKB_PRS_PheWAS_follow_up_GWAS): we perform the additional GWAS analysis for the list of traits implicated by the UKB PRS-PheWAS analysis.
- [`remove_topk`](remove_topk): As a follow-up analysis, we repeated the PRS-PheWAS analysis by removing the top `k` GWAS signals from the clumpped summary statistics.
- [`remove_chr3_chemokine`](remove_chr3_chemokine): As another follow-up analysis, we repeated the PRS-PheWAS analysis by removing the chr3 regions that are associated to the COVID-19 phenotypes.
