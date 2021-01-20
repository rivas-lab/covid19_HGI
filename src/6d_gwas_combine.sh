#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source 0_parameters.sh

pheno_name=$1

get_plink_suffix () {
    local GBE_ID=$1

    GBE_CAT=$(echo $GBE_ID | sed -e "s/[0-9]//g")

    if [ "${GBE_CAT}" == "QT_FC" ] || [ "${GBE_CAT}" == "INI" ] ; then
        echo glm.linear
    else
        echo glm.logistic.hybrid
    fi
}

f1=${data_scratch_d}/UKB_PRS_PheWAS_follow_up_GWAS/tmp/GWAS.assoc.one_array.${pheno_name}.$(get_plink_suffix ${pheno_name}).zst
f2=${data_scratch_d}/UKB_PRS_PheWAS_follow_up_GWAS/tmp/GWAS.assoc.both_arrays.${pheno_name}.$(get_plink_suffix ${pheno_name}).zst
f=${data_d}/UKB_PRS_PheWAS_follow_up_GWAS/ukb.${pheno_name}.glm.gz

if [ ! -d $(dirname ${f}) ] ; then mkdir -p $(dirname ${f}) ; fi

{
    zstdcat $f1 | egrep '^#'
    zstdcat $f1 $f2 | egrep -v '^#' | sort -k1,1V -k2,2n
} > ${f%.gz}

bgzip -l9 -@6 ${f%.gz}

echo ${f}
