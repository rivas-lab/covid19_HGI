#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source ${SRCDIR}/0_parameters.sh

HGI_case_controls=(A2 B1 B2 C2)
HGI_suffices=(leave_23andme leave_UKBB_23andme eur_leave_23andme eur_leave_ukbb_23andme)
exts=(txt.gz txt.gz.tbi b37.txt.gz b37.txt.gz.tbi)

cd ${data_d}/download

for HGI_case_control in ${HGI_case_controls[@]} ; do
for HGI_suffix in ${HGI_suffices[@]} ; do
for ext in ${exts[@]} ; do

! wget --timestamp \
$(echo ${HGI_google_d}/${HGI_google_f} | sed -e "s/@@HGI_case_control@@/${HGI_case_control}/g" | sed -e "s/@@HGI_suffix@@/${HGI_suffix}/g" | sed -e "s/@@ext@@/${ext}/g")

done
done
done
