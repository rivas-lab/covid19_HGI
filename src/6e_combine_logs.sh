#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

source 0_parameters.sh

log_f=${data_d}/UKB_PRS_PheWAS_follow_up_GWAS/ukb.glm.log.gz

find ${data_scratch_d}/UKB_PRS_PheWAS_follow_up_GWAS/tmp -name "GWAS.assoc*.log" | sort -V \
| while read f ; do
    echo "##$f"
    cat $f
    echo ""
done | bgzip -l9 -@6 > ${log_f}

echo ${log_f}

