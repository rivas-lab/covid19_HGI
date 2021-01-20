#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source 0_parameters.sh

ml load plink2

nCores=1
mem=8000
if [ $# -gt 0 ] ; then pheno_name=$1 ; else pheno_name="all" ; fi
if [ $# -gt 1 ] ; then nCores=$2 ; fi
if [ $# -gt 2 ] ; then mem=$3    ; fi

PRS_agg_hits_f=${data_scratch_d}/UKB_PRS_PheWAS/HGIrel5.PRS_PheWAS.1e-5.tsv.gz

plink_glm_wrapper () {
    plink2 \
        --memory ${mem} \
        --threads ${nCores} \
        --keep ${ukb_keep_wb} \
        --pheno ${data_d}/UKB_PRS_PheWAS_follow_up_GWAS/phe.tsv.gz \
        --pfile ${ukb_cal_pvar%.pvar.zst} vzs \
        --glm zs skip-invalid-pheno firth-fallback cc-residualize hide-covar omit-ref no-x-sex \
        --covar-variance-standardize \
        --pheno-quantile-normalize \
        --vif 100000000 \
        $@
}

show_pheno_name_all () {
    zcat ${PRS_agg_hits_f} | egrep -v '^#' | cut -f5 | sort -u \
    | tr '\n' ',' | rev | cut -c2- | rev
}

get_plink_suffix () {
    local GBE_ID=$1

    GBE_CAT=$(echo $GBE_ID | sed -e "s/[0-9]//g")

    if [ "${GBE_CAT}" == "QT_FC" ] || [ "${GBE_CAT}" == "INI" ] ; then
        echo glm.linear
    else
        echo glm.logistic.hybrid
    fi
}

#== one array ==#

plink_glm_wrapper \
    --pheno-name $([ ${pheno_name} != "all" ] && echo ${pheno_name} || show_pheno_name_all ) \
    --extract ${data_d}/UKB_PRS_PheWAS_follow_up_GWAS/var.one_array.lst \
    --covar-name age age_sq sex PC1-PC10 \
    --out ${data_scratch_d}/UKB_PRS_PheWAS_follow_up_GWAS/tmp/GWAS.assoc.one_array

if [ ${pheno_name} != "all" ] ; then
    mv \
    ${data_scratch_d}/UKB_PRS_PheWAS_follow_up_GWAS/tmp/GWAS.assoc.one_array.${pheno_name}.${pheno_name}.$(get_plink_suffix ${pheno_name}).zst \
    ${data_scratch_d}/UKB_PRS_PheWAS_follow_up_GWAS/tmp/GWAS.assoc.one_array.${pheno_name}.$(get_plink_suffix ${pheno_name}).zst
fi

#== both arrays ==#

plink_glm_wrapper \
    --pheno-name $([ ${pheno_name} != "all" ] && echo ${pheno_name} || show_pheno_name_all ) \
    --extract ${data_d}/UKB_PRS_PheWAS_follow_up_GWAS/var.both_arrays.lst \
    --covar-name age age_sq sex Array PC1-PC10 \
    --out ${data_scratch_d}/UKB_PRS_PheWAS_follow_up_GWAS/tmp/GWAS.assoc.both_arrays$([ ${pheno_name} != "all" ] && echo ".${pheno_name}" || echo "" )

if [ ${pheno_name} != "all" ] ; then
    mv \
    ${data_scratch_d}/UKB_PRS_PheWAS_follow_up_GWAS/tmp/GWAS.assoc.both_arrays.${pheno_name}.${pheno_name}.$(get_plink_suffix ${pheno_name}).zst \
    ${data_scratch_d}/UKB_PRS_PheWAS_follow_up_GWAS/tmp/GWAS.assoc.both_arrays.${pheno_name}.$(get_plink_suffix ${pheno_name}).zst
fi
