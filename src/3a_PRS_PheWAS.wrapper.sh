#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source 0_parameters.sh
helper_src="PRS_PheWAS.R"

ml load R/3.6 gcc

job_idx=$1
HGI_case_control=$2
HGI_suffix=$3
clump_p1=$4

# job_idx=1
# HGI_case_control='B2'
# HGI_suffix='eur_leave_ukbb_23andme'
# clump_p1='1e-5'

job_size=50

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

PRS_f=${data_d}/UKB_PRS_clump/$(echo ${UKB_cal_f%.tsv.gz} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g").clump${clump_p1}.sscore.zst
out_f=${data_scratch_d}/UKB_PRS_PheWAS/tmp/$(basename ${PRS_f%.sscore.zst})/$(basename ${PRS_f%.sscore.zst}).batch${job_idx}.tsv

if [ ! -d $(dirname ${out_f}) ] ; then mkdir -p $(dirname ${out_f}) ; fi

if [ ! -f ${out_f} ] ; then
    # generate the list of phenotypes corresponding to this batch
    tmp_phe_lst=${tmp_dir}/phe.lst
    phe_idx_s=$( perl -e "print( ${ukb_master_phe_offset} + (${job_idx} - 1) * ${job_size} )" )
    phe_idx_e=$( perl -e "print( ${ukb_master_phe_offset} + (${job_idx}) * ${job_size} )" )

    ! zcat ${ukb_master_phe} | head -n1 | tr '\t' '\n' \
    | awk -v idx_s=${phe_idx_s} -v idx_e=${phe_idx_e} 'idx_s < NR && NR <= idx_e' > ${tmp_phe_lst}

    Rscript ${helper_src} \
    ${PRS_f} \
    'SCORE1_SUM' \
    ${ukb_master_phe} \
    ${tmp_phe_lst} \
    ${ukb_keep_wb} \
    ${out_f}
fi
