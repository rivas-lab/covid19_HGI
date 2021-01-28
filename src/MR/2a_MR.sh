#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source $(dirname ${SRCDIR})/0_parameters.sh

ml load R/3.6 gcc

helper_src="${SRCDIR}/$(basename ${SRCNAME} .sh).R"

HGI_case_controls=(B2 C2 A2 B1)
# HGI_suffices=(eur_leave_ukbb_23andme eur_leave_23andme leave_UKBB_23andme leave_23andme)
HGI_suffices=(eur_leave_23andme leave_UKBB_23andme leave_23andme)
# HGI_suffices=(eur_leave_ukbb_23andme)

GBE_IDs=(BIN_FC11006152 HC166 INI30130 INI30190 INI30610 INI10030610)
GBE_IDs=(INI30030860)

out_d=${data_scratch_d}/UKB_MR/tmp_out


for HGI_case_control in ${HGI_case_controls[@]} ; do
for HGI_suffix in ${HGI_suffices[@]} ; do
for GBE_ID in ${GBE_IDs[@]} ; do

out_f=${out_d}/${HGI_case_control}.${HGI_suffix}.${GBE_ID}.tsv

if [ ! -f ${out_f} ] ; then
    echo ${out_f}
    Rscript ${helper_src} ${HGI_case_control} ${HGI_suffix} ${GBE_ID}
fi

done
done
done
