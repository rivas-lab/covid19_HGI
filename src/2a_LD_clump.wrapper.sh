#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source ${SRCDIR}/0_parameters.sh

ml load plink htslib

nCores=2
mem=16000

HGI_case_control=$1
HGI_suffix=$2
clump_p1=$3
if [ $# -gt 3 ] ; then nCores=$4 ; fi
if [ $# -gt 4 ] ; then mem=$5    ; fi

if [ ! -d "${data_d}/UKB_PRS_clump" ] ; then mkdir -p ${data_d}/UKB_PRS_clump ; fi

in_f=${data_d}/plink_format_UKB_cal/$(echo ${UKB_cal_f} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g")
out_f=${data_d}/UKB_PRS_clump/$(basename ${in_f} .tsv.gz).clump${clump_p1}

if [ ! -f "${out_f}.clumped.log" ] ; then
    if [ ! -f "${out_f}.clumped.gz" ] ; then
        if [ ! -f "${out_f}.clumped" ] ; then
            plink \
            --threads ${nCores} --memory ${mem} \
            --bfile ${ukb_cal_pvar%.pvar.zst} \
            --keep ${ukb_keep_wb} \
            --clump-snp-field ID \
            --clump ${in_f} \
            --clump-p1 ${clump_p1} \
            --out ${out_f}
        fi
        bgzip -l9 -@${nCores} ${out_f}.clumped
    fi
    mv ${out_f}.log ${out_f}.clumped.log
fi
