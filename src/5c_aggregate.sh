#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source 0_parameters.sh

ml load R/3.6 gcc

HGI_case_controls=(A2 B1 B2 C2)
HGI_suffices=(leave_23andme leave_UKBB_23andme eur_leave_23andme eur_leave_ukbb_23andme)
clump_p1s=(1e-3 1e-4 1e-5)

PRS_agg_f=${data_scratch_d}/UKB_PRS_PheWAS/HGIrel5.PRS_PheWAS.remove_chr3_chemokine.tsv.gz

############################################################
# tmp dir
############################################################
tmp_dir_root="$LOCAL_SCRATCH"
if [ ! -d ${tmp_dir_root} ] ; then mkdir -p $tmp_dir_root ; fi
tmp_dir="$(mktemp -p ${tmp_dir_root} -d tmp-$(basename $0)-$(date +%Y%m%d-%H%M%S)-XXXXXXXXXX)"
# echo "tmp_dir = $tmp_dir" >&2
handler_exit () { rm -rf $tmp_dir ; }
trap handler_exit EXIT
############################################################

tmp_PRS_agg_f=${tmp_dir}/$(basename ${PRS_agg_f})

{
    echo "#HGI_case_control HGI_suffix clump_p1 has_chr3_chemokine_region phe estimate SE z_or_t_value P" | tr ' ' '\t'
    for HGI_case_control in ${HGI_case_controls[@]} ; do
    for HGI_suffix in ${HGI_suffices[@]} ; do
    for clump_p1 in ${clump_p1s[@]} ; do

        path_str="$(echo ${UKB_cal_f%.tsv.gz} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g").clump${clump_p1}"

        zcat "${data_scratch_d}/UKB_PRS_PheWAS/${path_str}.PRS_PheWAS_full.tsv.gz" \
        | grep 'scale(PRS)' | cut -f1,4- \
        | awk -v cc=${HGI_case_control} -v sx=${HGI_suffix} -v p1=${clump_p1} -v has_chr3_flag="TRUE" -v OFS='\t' '{print cc, sx, p1, has_chr3_flag, $0}'

        zcat "${data_scratch_d}/UKB_PRS_PheWAS/remove_chr3_chemokine/${path_str}.remove_chr3_chemokine.PRS_PheWAS_full.tsv.gz" \
        | grep 'scale(PRS)' | cut -f1,4- \
        | awk -v cc=${HGI_case_control} -v sx=${HGI_suffix} -v p1=${clump_p1} -v has_chr3_flag="FALSE" -v OFS='\t' '{print cc, sx, p1, has_chr3_flag, $0}'

    done
    done
    done

} | bgzip -@6 > ${tmp_PRS_agg_f}

# add phenotype name and phenotype category
Rscript /dev/stdin ${tmp_PRS_agg_f} ${PRS_agg_f%.gz} ${ukb_phe_info} << EOF
suppressWarnings(suppressPackageStartupMessages({ library(tidyverse); library(data.table) }))
args <- commandArgs(trailingOnly=TRUE)

in_f <- args[1]
out_f <- args[2]
ukb_phe_info_f <- args[3]

ukb_phe_info_f %>%
fread(select=c('#GBE_category', 'GBE_ID', 'GBE_short_name')) %>%
rename('GBE_category'='#GBE_category') -> phe_info_df

in_f %>% fread(colClasses = 'character') %>%
rename('HGI_case_control' = '#HGI_case_control') -> df

df %>% filter(has_chr3_chemokine_region != 'TRUE') %>% pull(phe) %>% unique() -> phe_lst

df %>%
filter(phe %in% phe_lst) %>%
rename('GBE_ID' = 'phe') %>%
left_join(phe_info_df, by='GBE_ID') %>%
select(
    HGI_case_control, HGI_suffix, clump_p1, has_chr3_chemokine_region,
    GBE_category, GBE_ID, GBE_short_name,
    estimate, SE, z_or_t_value, P
) %>%
rename('#HGI_case_control' = 'HGI_case_control') %>%
fwrite(out_f, sep='\t', na = "NA", quote=F)
EOF

bgzip -l9 -@6 ${PRS_agg_f%.gz}

echo ${PRS_agg_f}
