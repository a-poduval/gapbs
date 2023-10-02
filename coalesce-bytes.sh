#!/bin/bash

if [ ! -f ./pin-byte-stats.csv ]; then
    echo "Name,Function,Read Bytes,Written Bytes" >> pin-byte-stats.csv
fi

kernels=("bc" "bfs" "cc" "cc_sv" "pr" "pr_spmv" "sssp" "tc")

BASE_DIR=$(pwd)

for i in $(seq 0 7); do
    cd $BASE_DIR
    cd ${kernels[$i]}
    FUNC_NAME=$(grep "Read Bytes" roitrace-mt.csv | grep -o ' \w* ' | grep -o '\w*' | head -n 1) #> delete
    READ_BYTES=$(grep "Read Bytes" roitrace-mt.csv | grep -o '\w*$' | paste -sd+ - | bc)
    WRITE_BYTES=$(grep "Write Bytes" roitrace-mt.csv | grep -o '\w*$' | paste -sd+ - | bc)
    echo ${kernels[$i]},$FUNC_NAME,$READ_BYTES,$WRITE_BYTES>> ../pin-byte-stats.csv
done
