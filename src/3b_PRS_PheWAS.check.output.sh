#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source 0_parameters.sh


HGI_case_controls=(A2 B1 B2 C2)
HGI_suffices=(leave_23andme leave_UKBB_23andme eur_leave_23andme eur_leave_ukbb_23andme)
clump_p1s=(1e-3 1e-4 1e-5)

for HGI_case_control in ${HGI_case_controls[@]} ; do
for HGI_suffix in ${HGI_suffices[@]} ; do
for clump_p1 in ${clump_p1s[@]} ; do

    out_d=${data_scratch_d}/UKB_PRS_PheWAS/tmp/$(echo ${UKB_cal_f%.tsv.gz} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g").clump${clump_p1}

    if [ ! -d ${out_d} ] ; then
        echo $(basename ${out_d})
    else
        for job_idx in $(seq 1 70) ; do
            f=${out_d}/$(basename ${out_d}).batch${job_idx}.tsv
            if [ ! -f ${f} ] ; then
                echo $f
            fi
        done
    fi
done
done
done
