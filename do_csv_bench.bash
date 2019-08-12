#!/usr/bin/env bash
# Exit immediately if some command exits with a non-zero code
set -e

BUILD_DIR="./build"
REPORT_DIR="./reports"
BENCHMARK_SIZE=2000
THREADS=4

function echo_red {
    echo -e "\e[31m$@\e[0m"
}

function echo_header {
    echo
    echo -e "\e[1m$@\e[0m"
    echo
}

function check_dependencies {
    local all_ok=1
    local executables='python3 g++ make cmake perf cargo rustc'
    for dep in $executables; do
        local where=$(type -p $dep)
        if [ -z $where ]; then
            echo_red "$dep not found"
            all_ok=0
        else
            echo "$dep is $where"
        fi
    done
    if [ "$all_ok" != "1" ]; then
        echo_red "Some dependencies are missing"
        return 1
    fi
}

echo_header "Check all dependencies"
check_dependencies

# Single thread

rm --recursive --force $BUILD_DIR

echo_header "==== SINGLE THREAD BENCHMARK ===="

echo_header "Building all libraries"

./build.py --verbose \
           --no-multi-thread \
           --build_dir $BUILD_DIR

echo_header "Testing all libraries"

./test.py --iterations 10 \
          --build_dir $BUILD_DIR
          --threads 1

echo_header "Running all benchmarks"

./bench.py --reporter_out csv \
           --report_dir "$REPORT_DIR/single_core" \
           --build_dir $BUILD_DIR \
           --input_size $BENCHMARK_SIZE \
           --threads 1 \
           --iterations 10

echo_header "==== SINGLE THREAD BENCHMARK COMPLETE ===="

rm --recursive --force $BUILD_DIR

# Multi thread

echo_header "==== MULTI THREAD BENCHMARK ===="

echo_header "Building all libraries"

./build.py --verbose \
           --build_dir $BUILD_DIR

echo_header "Testing all libraries"

./test.py --iterations 10 \
          --build_dir $BUILD_DIR
          --threads $THREADS

echo_header "Running all benchmarks"

./bench.py --reporter_out csv \
           --report_dir "$REPORT_DIR/multi_core" \
           --build_dir $BUILD_DIR \
           --input_size $BENCHMARK_SIZE \
           --threads $THREADS \
           --iterations 10

echo_header "==== MULTI THREAD BENCHMARK COMPLETE ===="
