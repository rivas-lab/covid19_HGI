#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source 0_parameters.sh

find ${data_d}/UKB_PRS_clump -name "*.clumped.gz" \
| while read f ; do zcat $f | awk '(NR>1){print $3}' ; done \
| sort -uV > ${data_d}/UKB_PRS_PheWAS_follow_up_GWAS/var.lst

comm -12 <(cat ${ukb_cal_both_arrays_lst} | sort) <(cat ${data_d}/UKB_PRS_PheWAS_follow_up_GWAS/var.lst | sort) \
| sort -V > ${data_d}/UKB_PRS_PheWAS_follow_up_GWAS/var.both_arrays.lst

comm -13 <(cat ${ukb_cal_both_arrays_lst} | sort) <(cat ${data_d}/UKB_PRS_PheWAS_follow_up_GWAS/var.lst | sort) \
| sort -V > ${data_d}/UKB_PRS_PheWAS_follow_up_GWAS/var.one_array.lst
