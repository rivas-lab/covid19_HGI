#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

bash 5a_remove_chr3_chemokine_region.sh $@
bash 5b_PRS_PheWAS.sh $@
