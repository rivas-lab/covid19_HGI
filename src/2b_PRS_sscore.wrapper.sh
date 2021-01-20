#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source ${SRCDIR}/0_parameters.sh

ml load plink2

nCores=2
mem=16000

HGI_case_control=$1
HGI_suffix=$2
clump_p1=$3
if [ $# -gt 3 ] ; then nCores=$4 ; fi
if [ $# -gt 4 ] ; then mem=$5    ; fi

if [ ! -d "${data_d}/UKB_PRS_clump" ] ; then mkdir -p ${data_d}/UKB_PRS_clump ; fi

out_f=${data_d}/UKB_PRS_clump/$(echo ${UKB_cal_f%.tsv.gz} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g").clump${clump_p1}
in_f=${out_f}.clumped.gz
sumstats_f=${data_d}/plink_format_UKB_cal/$(echo ${UKB_cal_f} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g")

if [ ! -f "${out_f}.sscore.log" ] ; then
    if [ ! -f "${out_f}.sscore.zst" ] ; then
        zcat ${in_f} \
        | awk '(NR>1 && length($3)>0){print $3}' \
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
