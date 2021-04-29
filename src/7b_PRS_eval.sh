#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})


source "${SRCDIR}/0_parameters.sh"

UKB_phes=(covid19_severe covid19_test_result)
HGI_case_controls=(A2 B1 B2 C2)
HGI_suffices=(leave_23andme leave_UKBB_23andme eur_leave_23andme eur_leave_ukbb_23andme)
HGI_suffices=(leave_23andme leave_UKBB_23andme eur_leave_23andme)
# HGI_suffices=(eur_leave_ukbb_23andme)
clump_p1s=(1e-3 1e-4 1e-5)

for HGI_case_control in ${HGI_case_controls[@]} ; do
for HGI_suffix in ${HGI_suffices[@]} ; do
for clump_p1 in ${clump_p1s[@]} ; do
for UKB_phe in ${UKB_phes[@]} ; do

eval_f="${data_d}/UKB_PRS_eval/eval_df/${UKB_phe}.PRS.${HGI_case_control}.${HGI_suffix}.${clump_p1}.tsv"

if [ ! -f ${eval_f} ] ; then
    Rscript ${SRCNAME%.sh}.R \
    ${UKB_phe} ${HGI_case_control} ${HGI_suffix} ${clump_p1}
fi

done
done
done
done
exit 0
