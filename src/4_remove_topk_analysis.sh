#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

bash 4a_remove_top_k_vars.sh $@
bash 4b_PRS_PheWAS.sh $@

exit 0

nCores=2
mem=16000

remove_topk=$1
HGI_case_control=$2
HGI_suffix=$3
clump_p1=$4
if [ $# -gt 4 ] ; then nCores=$5 ; fi
if [ $# -gt 5 ] ; then mem=$6    ; fi
