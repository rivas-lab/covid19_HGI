#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source ${SRCDIR}/0_parameters.sh

ml load R/3.6 gcc

helper_src="${SRCDIR}/$(basename ${SRCNAME} .sh).R"
HGI_case_controls=(A2 B1 B2 C2)
HGI_suffices=(leave_23andme leave_UKBB_23andme eur_leave_23andme eur_leave_ukbb_23andme)

if [ ! -d "${data_d}/plink_format_UKB_cal" ] ; then mkdir -p ${data_d}/plink_format_UKB_cal ; fi

for HGI_case_control in ${HGI_case_controls[@]} ; do
for HGI_suffix in ${HGI_suffices[@]} ; do

in_f=${data_d}/plink_format/$(echo ${plink_f} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g" | sed -e "s/@@assembly@@/hg19/g")
out_f=${data_d}/plink_format_UKB_cal/$(echo ${UKB_cal_f} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g")

if [ ! -f "${out_f}" ] ; then
    if [ ! -f "${out_f%.gz}" ] ; then
        Rscript ${helper_src} ${in_f} ${out_f%.gz} ${ukb_cal_pvar}
    fi
    bgzip -l9 -@6 ${out_f%.gz}
fi

done
done
