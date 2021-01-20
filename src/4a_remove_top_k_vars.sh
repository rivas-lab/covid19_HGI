#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source ${SRCDIR}/0_parameters.sh

ml load plink2

nCores=2
mem=16000

remove_topk=$1
HGI_case_control=$2
HGI_suffix=$3
clump_p1=$4
if [ $# -gt 4 ] ; then nCores=$5 ; fi
if [ $# -gt 5 ] ; then mem=$6    ; fi

if [ ! -d "${data_d}/UKB_PRS_clump" ] ; then mkdir -p ${data_d}/UKB_PRS_clump ; fi

in_f=${data_d}/UKB_PRS_clump/$(echo ${UKB_cal_f%.tsv.gz} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g").clump${clump_p1}.clumped.gz
out_f=${data_d}/UKB_PRS_clump/remove_topk/$(basename ${in_f%.clumped.gz}).remove_top${remove_topk}
sumstats_f=${data_d}/plink_format_UKB_cal/$(echo ${UKB_cal_f} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g")

if [ ! -d $(dirname ${out_f}) ] ; then mkdir -p $(dirname ${out_f}) ; fi

if [ ! -f "${out_f}.sscore.log" ] ; then
    if [ ! -f "${out_f}.sscore.zst" ] ; then
        zcat ${in_f} \
        | awk -v remove_topk=${remove_topk} '(NR>(1 + remove_topk) && length($3)>0){print $3}' \
        | plink2 \
            --threads ${nCores} --memory ${mem} \
            --pfile ${ukb_cal_pvar%.pvar.zst} vzs \
            --extract /dev/stdin \
            --out ${out_f} \
            --score ${sumstats_f} 3 6 8 header zs list-variants-zs \
            cols=maybefid,maybesid,phenos,dosagesum,scoreavgs,denom,scoresums
    fi
    mv ${out_f}.log ${out_f}.sscore.log
fi
