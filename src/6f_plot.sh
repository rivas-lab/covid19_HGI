#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source ${SRCDIR}/0_parameters.sh

ml load R/3.6 gcc

helper_src="${SRCDIR}/$(basename ${SRCNAME} .sh).R"

HGI_case_controls=(A2 B1 B2 C2)
# HGI_suffices=(leave_23andme leave_UKBB_23andme eur_leave_23andme eur_leave_ukbb_23andme)
HGI_suffices=(eur_leave_ukbb_23andme)
clump_p1s=(1e-3 1e-4 1e-5)

phenos=(INI10030610 INI30130 INI30190 INI30610)

for HGI_case_control in ${HGI_case_controls[@]} ; do
for HGI_suffix in ${HGI_suffices[@]} ; do
for clump_p1 in ${clump_p1s[@]} ; do
for pheno in ${phenos[@]} ; do

    Rscript ${helper_src} ${HGI_case_control} ${HGI_suffix} ${clump_p1} ${pheno}

done
done
done
done
