#!/bin/bash
set -beEuo pipefail

SRCNAME=$(readlink -f $0)
SRCDIR=$(dirname ${SRCNAME})

cat 0_parameters.sh | awk -v FS='=' -v OFS='=' '(NF==2){$2="@@@@@@"; print $0}' > 0_parameters.public.sh
