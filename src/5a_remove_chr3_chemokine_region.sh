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

sumstats_f=${data_d}/plink_format_UKB_cal/$(echo ${UKB_cal_f} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g")
in_f=${data_d}/UKB_PRS_clump/$(basename ${sumstats_f%.tsv.gz}).clump${clump_p1}.clumped.gz
out_f=${data_d}/UKB_PRS_clump/remove_chr3_chemokine/$(basename ${in_f%.clumped.gz}).remove_chr3_chemokine

# top hits from 'https://storage.googleapis.com/covid19-hg-public/20201215/results/20210107/COVID19_HGI_B1_ALL_eur_leave_23andme_20210107.b37_1.0E-5.txt'
chr3_chemokine_pos=45850783
remove_half_window=1500000 # 3MB window

if [ ! -d $(dirname ${out_f}) ] ; then mkdir -p $(dirname ${out_f}) ; fi

if [ ! -f "${out_f}.sscore.log" ] ; then
    if [ ! -f "${out_f}.sscore.zst" ] ; then
        zcat ${in_f} \
        | awk -v pos=${chr3_chemokine_pos} -v hw=${remove_half_window} '(( NR > 1 ) && ( length($3)>0 ) &&( ( $1 != 3 ) || ( $4 < pos - hw  ) || ( pos + hw < $4 ) )){print $3}' \
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
