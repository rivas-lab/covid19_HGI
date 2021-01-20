#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source ${SRCDIR}/0_parameters.sh
helper_src="PRS_PheWAS.R"

ml load R/3.6 gcc

remove_topk=$1
HGI_case_control=$2
HGI_suffix=$3
clump_p1=$4

PRS_agg_hits_f=${data_scratch_d}/UKB_PRS_PheWAS/HGIrel5.PRS_PheWAS.1e-5.tsv.gz

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

tmp_phe_lst=${tmp_dir}/phe.lst
zcat ${PRS_agg_hits_f} | egrep -v '^#' | cut -f5 | sort -u > ${tmp_phe_lst}

PRS_f=${data_d}/UKB_PRS_clump/remove_topk/$(echo ${UKB_cal_f%.tsv.gz} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g").clump${clump_p1}.remove_top${remove_topk}.sscore.zst
out_f=${data_scratch_d}/UKB_PRS_PheWAS/remove_topk/$(basename ${PRS_f%.sscore.zst}).PRS_PheWAS_full.tsv.gz

if [ ! -d $(dirname ${out_f}) ] ; then mkdir -p $(dirname ${out_f}) ; fi

if [ ! -f ${out_f} ] ; then
    Rscript ${helper_src} \
    ${PRS_f} \
    'SCORE1_SUM' \
    ${ukb_master_phe} \
    ${tmp_phe_lst} \
    ${ukb_keep_wb} \
    ${out_f%.gz}
fi

bgzip -l9 -@6 ${out_f%.gz}
