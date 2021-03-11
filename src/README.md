# COVID-19 HGI, PRS-PheWAS analysis analysis scripts

Here, we have the analysis scripts for the COVID-19 PRS-PheWAS analysis.

There are some rules regarding the organization of the script files.

- The prefix of the file name (`0_`, `1a_`, ...) reflects the order of the operation performed in the analysis.
- If there are R and bash script files that has the same basename (`***.R` and `***.sh`), we assume that the `bash` script will internally call the `R` script, unless otherwise specified.

Currently, we have the following analysis scripts.

- [`0_parameters.public.sh`](0_parameters.public.sh): the list of parameters used in the analysis script.
  - The actual file names in this file are masked using [`0_mask_parameters.sh`](0_mask_parameters.sh).
- [`0_parameters_chr3_chemokine_pos.sh`](0_parameters_chr3_chemokine_pos.sh): another parameter file that contains the coordinate of the chr3 region, which is associated with the COVID-19 phenotypes. This coordinate was defined as the 3MB window on hg19 surroinding the lead GWAS hits in HGI summary statistics.
- [`1a_download.sh`](1a_download.sh): sciprt that downloads the GWAS summary statistics from the covid-19 HGI release 5
- [`1b_conv_to_plink2.R`](1b_conv_to_plink2.R), [`1b_conv_to_plink2.sh`](1b_conv_to_plink2.sh): this simple script converts the file format of the GWAS summary statistics. The resulting file should look like the one used by `plink2` software.
- [`1c_filter_to_UKB_array.R`](1c_filter_to_UKB_array.R), [`1c_filter_to_UKB_array.sh`](1c_filter_to_UKB_array.sh): filter GWAS summary statistics so that the resulting file contains the variants that are present in the directly genotyped array in UK Biobank.
- [`2a_LD_clump.wrapper.sh`](2a_LD_clump.wrapper.sh): this script works as a wrapper for `plink` software and performs LD clumping to select the approximately independent set of GWAS associations.
- [`2b_PRS_sscore.wrapper.sh`](2b_PRS_sscore.wrapper.sh): this script works as a wrapper for `plink` software and computes polygenic risk score (PRS) for individuals in UK Biobank.
- [`3a_PRS_PheWAS.wrapper.sh`](3a_PRS_PheWAS.wrapper.sh): this script is a wrapper to perform PRS-PheWAS analysis, where we correlate the PRS value and the phenotypic data using the individual-level data in UK Biobank.
- [`3b_PRS_PheWAS.check.output.sh`](3b_PRS_PheWAS.check.output.sh): this script checks the output of the PRS-PheWAS analysis.
- [`3c_PRS_PheWAS.combine_full_results.sh`](3c_PRS_PheWAS.combine_full_results.sh): this script aggregates the results of PRS-PheWAS analysis across different phenotypes used in the PheWAS analysis. It is highly recommended to run [`3b_PRS_PheWAS.check.output.sh`](3b_PRS_PheWAS.check.output.sh) and check the existence of the files before using this script.
- [`3d_PRS_PheWAS.aggregate.sh`](3d_PRS_PheWAS.aggregate.sh): this script further aggregates the results from the previous step across different parameters (HGI case control status, set of individuals included in the analysis, and the clumping p-value threshold).
- [`3e_browse_top_hits.ipynb`](3e_browse_top_hits.ipynb): this Jupyter notebook shows how to browse the results. The similar, but more comprehensive functionality, should be implemented in [the data browser](/web).
- [`4_remove_topk_analysis.sh`](4_remove_topk_analysis.sh): this is a wrapper combining step 4a and 4b (see below).
- [`4a_remove_top_k_vars.sh`](4a_remove_top_k_vars.sh): For the "remove top-k" analysis, this script constructs PRS models after removing the top `k` GWAS hits in the clumpped GWAS results.
- [`4b_PRS_PheWAS.sh`](4b_PRS_PheWAS.sh): this script performs the PRS-PheWAS analysis for the "remove top-k" analysis
- [`4c_aggregate.sh`](4c_aggregate.sh): this script aggregates the PRS-PheWAS analysis for the "remove top-k" analysis across different traits.
- [`4d_remove_topk_examples.ipynb`](4d_remove_topk_examples.ipynb): this Jupyter notebook is helpful to browse the results of the remote-top-k analysis.
- [`5_remove_chr3_chemokine_region_analysis.sh`](5_remove_chr3_chemokine_region_analysis.sh): similarly, the `5*` script repeats the PRS-PheWAS analysis without the chr3 regions.
  - [`5a_remove_chr3_chemokine_region.sh`](5a_remove_chr3_chemokine_region.sh)
  - [`5b_PRS_PheWAS.sh`](5b_PRS_PheWAS.sh)
  - [`5c_aggregate.sh`](5c_aggregate.sh)
  - [`5d_remove_chr3_chemokine.ipynb`](5d_remove_chr3_chemokine.ipynb)
- [`6a_follow_up_GWAS_prep_phe.ipynb`](6a_follow_up_GWAS_prep_phe.ipynb): for the set of phenotypes implicated in the PRS-PheWAS analysis, we perform GWAS to prepare summary statistics (with `age^2` adjusted in the covariates).
- [`6b_var_list.sh`](6b_var_list.sh): extract the list of variants from the clumpped GWAS summary statistics and separate them into two, corresponding to "one array" and "both arrays" lists.
- [`6c_gwas.sh`](6c_gwas.sh): this is s `plink` wrapper to run GWAS.
- [`6d_gwas_combine.sh`](6d_gwas_combine.sh) and [`6e_combine_logs.sh`](6e_combine_logs.sh): combine the GWAS results
- [`6f_plot.R`](6f_plot.R), [`6f_plot.sh`](6f_plot.sh): a pair of visualization script for the `UKB_PRS_PheWAS_follow_up_GWAS` analysis. We have some Jupyter notebooks where we investigate the results of a selected phenotypes.
  - [`6f_plot_INI10030610.ipynb`](6f_plot_INI10030610.ipynb)
  - [`6f_plot_INI30610.ipynb`](6f_plot_INI30610.ipynb)
- [`MR`](MR): Mendelian Randomization analysis
- [`PRS_PheWAS.functions.R`](PRS_PheWAS.functions.R): this script contains helper functions for PRS-PheWAS analysis.
- [`PRS_PheWAS.R`](PRS_PheWAS.R): this script contains the PRS-PheWAS analysis
- [`colorblind_colors.R`](colorblind_colors.R): color-blindness-friendly colors are defined in this file.
- [`plot_functions.R`](plot_functions.R): a helper script for generating plots.
