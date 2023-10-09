#!/bin/bash

if [ ! -f ./zray-byte-stats.csv ]; then
    echo "Name,Function,Time Elapsed (ns),Read Bytes,Written Bytes" >> zray-byte-stats.csv
fi

kernels=("bc" "bfs" "cc" "cc_sv" "pr" "pr_spmv" "sssp" "tc")

functions=("PBFS" "BUStep" "Link" "ShiloachVishkin" "PageRankPullGS" "PageRankPull" "RelaxEdges" "OrderedCount")

BASE_DIR=$(pwd)

for i in $(seq 0 7); do
    cd $BASE_DIR
    cd ${kernels[$i]}
    TIME_ELAPSED=$(grep "TIME ELAPSED (ns)" tool_log_file.txt | grep -o '\w*$' | paste -sd+ - | bc)
    READ_BYTES=$(grep "READ BYTES" tool_log_file.txt | grep -o '\w*$' | paste -sd+ - | bc)
    WRITE_BYTES=$(grep "WRITTEN BYTES" tool_log_file.txt | grep -o '\w*$' | paste -sd+ - | bc)
    echo ${kernels[$i]},${functions[$i]},$TIME_ELAPSED,$READ_BYTES,$WRITE_BYTES>> ../zray-byte-stats.csv
done
