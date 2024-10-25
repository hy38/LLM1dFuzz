#!/bin/bash

# Set targets without DFG as special targets.
SPECIAL_TARGETS=("lua-2020-24370" "openssl-2017-3735" "php-2019-11041" "sndfile-convert-2018-19758")

# Use /benchmark/bin/DAFL directory for both DAFL and DAFL-selIns.
FUZZER_NAME='DAFL' 

if [[ " ${SPECIAL_TARGETS[@]} " =~ " $1 " ]]; then
  # If $1 is in the list, use DAFL-selIns
  . $(dirname $0)/common-setup.sh
  timeout $4 /fuzzer/DAFL/afl-fuzz \
    $DICT_OPT -m none -d -N -i seed/$5 -o output $6 -- ./$1 $2
else
  # Otherwise, use the standard DAFL fuzzer
  . $(dirname $0)/common-setup.sh
  timeout $4 /fuzzer/DAFL/afl-fuzz \
    $DICT_OPT -m none -d -i seed/$5 -o output $6 -- ./$1 $2
fi

. $(dirname $0)/common-postproc.sh
