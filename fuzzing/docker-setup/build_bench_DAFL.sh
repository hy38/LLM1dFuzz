#!/bin/bash

. $(dirname $0)/build_bench_common.sh

# arg1 : Target project
# arg2~: Fuzzing targets
function build_with_DAFL() {
    CC="/fuzzer/DAFL/afl-clang-fast"
    CXX="/fuzzer/DAFL/afl-clang-fast++"

    for TARG in "${@:2}"; do
        cd /benchmark

        str_array=($TARG)
        BIN_NAME=${str_array[0]}
        if  [[ $BIN_NAME == "readelf" || $BIN_NAME == "objdump-2.31.1" ]]; then
            BIT_OPT="-m32"
        else
            BIT_OPT=""
        fi

        for BUG_NAME in "${str_array[@]:1}"; do
            export DAFL_SELECTIVE_COV="/benchmark/DAFL-input/inst-targ/$BIN_NAME/$BUG_NAME"
            export DAFL_DFG_SCORE="/benchmark/DAFL-input/dfg/$BIN_NAME/$BUG_NAME"
            build_target $1 $CC $CXX "-fsanitize=address $BIT_OPT" 2>&1 | tee /benchmark/build_log/$BIN_NAME-$BUG_NAME.txt

            ### copy results
            copy_build_result $1 $BIN_NAME $BUG_NAME "DAFL"
            rm -rf RUNDIR-$1
        done
    done

}

# Build with DAFL
mkdir -p /benchmark/build_log
mkdir -p /benchmark/bin/DAFL
build_with_DAFL "libming-4.7" "swftophp-4.7 2016-9827" &
build_with_DAFL "lrzip-ed51e14" "lrzip-ed51e14 2018-11496" &
build_with_DAFL "binutils-2.26" "cxxfilt 2016-4487" &
build_with_DAFL "binutils-2.28" "objcopy 2017-8393" &
build_with_DAFL "binutils-2.29" "readelf 2017-16828" &
build_with_DAFL "libxml2-2.9.4" "xmllint 2017-9047" &
build_with_DAFL "libjpeg-1.5.90" "cjpeg-1.5.90 2018-14498" &

build_with_DAFL "libsndfile-1.0.28" "sndfile-convert 2018-19758" &
build_with_DAFL "libtiff-4.0.7" "tiffcp 2016-10269" &
build_with_DAFL "libpng-1.6.35" "pngimage 2018-13785" &

wait

build_with_DAFL "sqlite-3.30.1" "sqlite3 2019-19923"
