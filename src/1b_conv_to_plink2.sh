#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source ${SRCDIR}/0_parameters.sh

helper_src="${SRCDIR}/$(basename ${SRCNAME} .sh).R"
HGI_case_controls=(A2 B1 B2 C2)
HGI_suffices=(leave_23andme leave_UKBB_23andme eur_leave_23andme eur_leave_ukbb_23andme)

if [ ! -d "${data_d}/plink_format" ] ; then mkdir -p ${data_d}/plink_format ; fi

for HGI_case_control in ${HGI_case_controls[@]} ; do
for HGI_suffix in ${HGI_suffices[@]} ; do

in_f_basename=$(echo ${HGI_google_f} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g")
out_f_basename=$(echo ${plink_f} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g")

hg19_in_f=${data_d}/download/$(echo ${in_f_basename} | sed -e "s/@@ext@@/b37.txt.gz/g" )
hg38_in_f=${data_d}/download/$(echo ${in_f_basename} | sed -e "s/@@ext@@/txt.gz/g" )
hg19_out_f=${data_d}/plink_format/$(echo ${out_f_basename} | sed -e "s/@@assembly@@/hg19/g")
hg38_out_f=${data_d}/plink_format/$(echo ${out_f_basename} | sed -e "s/@@assembly@@/hg38/g")

if [ ! -f "${hg19_out_f}" ] ; then
    if [ ! -f "${hg19_out_f%.gz}" ] ; then
        Rscript ${helper_src} ${hg19_in_f} ${hg19_out_f%.gz}
    fi
    bgzip -l9 -@6 ${hg19_out_f%.gz}
fi

if [ ! -f "${hg38_out_f}" ] ; then
    if [ ! -f "${hg38_out_f%.gz}" ] ; then
        Rscript ${helper_src} ${hg38_in_f} ${hg38_out_f%.gz}
    fi
    bgzip -l9 -@6 ${hg38_out_f%.gz}
fi

done
done
