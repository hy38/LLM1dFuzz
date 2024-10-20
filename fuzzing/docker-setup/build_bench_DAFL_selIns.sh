#!/bin/bash

. $(dirname $0)/build_bench_common.sh

# arg1 : Target project
# arg2~: Fuzzing targets
function build_with_DAFL() {

    for TARG in "${@:2}"; do
        str_array=($TARG)
        BIN_NAME=${str_array[0]}
        if  [[ $BIN_NAME == "readelf" || $BIN_NAME == "objdump-2.31.1" ]]; then
            BIT_OPT="-m32"
        else
            BIT_OPT=""
        fi

        cd /benchmark
        CC="/fuzzer/DAFL/afl-clang-fast"
        CXX="/fuzzer/DAFL/afl-clang-fast++"

        for BUG_NAME in "${str_array[@]:1}"; do
            export DAFL_SELECTIVE_COV="/benchmark/DAFL-input/inst-targ/$BIN_NAME/$BUG_NAME"
            build_target $1 $CC $CXX "-fsanitize=address $BIT_OPT"

            ### copy results to "DAFL" not "DAFL-selIns" for convenience.
            copy_build_result $1 $BIN_NAME $BUG_NAME "DAFL"
            rm -rf RUNDIR-$1
        done
    done

}

# Build with DAFL
mkdir -p /benchmark/build_log
mkdir -p /benchmark/bin/DAFL
build_with_DAFL "libsndfile-1.0.28" "sndfile-convert 2018-19758" &
build_with_DAFL "php-7.3.6" "php 2019-11041" &
build_with_DAFL "openssl-1.1.0c" "openssl 2017-3735" &

wait

build_with_DAFL "lua-5.4.0" "lua 2020-24370"
