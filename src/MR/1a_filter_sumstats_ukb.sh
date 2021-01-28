#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source ../0_parameters.sh

ml load R/3.6 gcc

GBE_ID=$1
p_thr='1e-5'



suffix="logistic.hybrid"
suffix="linear"
full_f=$(echo ${ukb_array_combined_sumstats_f} | sed -e "s/@@GBE_ID@@/${GBE_ID}/g"  | sed -e "s/@@suffix@@/${suffix}/g") # linear
filtered_f=${data_scratch_d}/UKB_MR/sumstats/${GBE_ID}.p${p_thr}.tsv.gz

# helper script
if [ ! -d $(dirname ${filtered_f}) ] ; then mkdir -p $(dirname ${filtered_f}) ; fi

if [ ! -f ${filtered_f} ] ; then
    if [ ! -f ${filtered_f%.gz} ] ; then
        Rscript ${gwas_filter_by_p_R} ${full_f} ${filtered_f%.gz} ${p_thr}
    fi
    bgzip -l9 ${filtered_f%.gz}
fi
