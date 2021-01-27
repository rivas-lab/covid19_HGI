#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})


source $(dirname ${SRCDIR})/0_parameters.sh

out_d=${data_scratch_d}/UKB_MR/tmp_out

{
    cat ${out_d}/B1.leave_23andme.INI10030610.tsv | egrep '^#'

    find ${out_d} -type f -name "*.tsv" | sort -V | parallel -k 'cat' | egrep -v '#'
} > $(dirname ${out_d})/MR_IVW.tsv
