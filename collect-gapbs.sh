#!/bin/bash

if [ ! -f ./zray-gapbs-stats.csv ]; then
	echo "Name,Total Loads,Total Stores,L1 Read Accesses,L1 Read Misses,Elapsed Real Time,Max RSS (kB)" >> zray-gapbs-stats.csv
	#echo "Name,Total Loads,Total Stores,Elapsed Real Time,Postprocessing Time,Max RSS (kB)" >> zray-gapbs-stats.csv
fi

kernels=("bc" "bfs" "cc" "cc_sv" "pr" "pr_spmv" "sssp" "tc")

BASE_DIR=$(pwd)
make clean
make -j8

for i in $(seq 0 7); do
    cd $BASE_DIR
    cd ${kernels[$i]}
    rm tool_log_file.txt
    if [ $i -eq 6 ]
    then
        /usr/bin/time -f "Time: %e\nMax RSS: %M\nAvg data+stack+text mem use: %K" -o time-${kernels[$i]}.txt ./${kernels[$i]} -f ../../graphs/raw/twitter.wsg
    else
        /usr/bin/time -f "Time: %e\nMax RSS: %M\nAvg data+stack+text mem use: %K" -o time-${kernels[$i]}.txt ./${kernels[$i]}
    fi
    #wait
    LD_CNT=$(grep "TOTAL HEAP LOAD" tool_log_file.txt | cut -c 1-19 --complement | paste -sd+ - | bc)
    ST_CNT=$(grep "TOTAL HEAP STORES" tool_log_file.txt | cut -c 1-19 --complement | paste -sd+ - | bc)
    L1_ACCS_CNT=$(grep "L1 READ ACCESSES" tool_log_file.txt | cut -c 1-20 --complement | paste -sd+ - | bc)
    L1_MISS_CNT=$(grep "L1 READ MISSES" tool_log_file.txt | cut -c 1-20 --complement | paste -sd+ - | bc)
    #PP_TIME=$(grep "TOTAL POSTPROCESS TIME" tool_log_file.txt | cut -c 1-24 --complement | paste -sd+ - | bc) # bc summation throwing an error because it doesn't handle scientific notation
    TIME=$(grep "Time" time-${kernels[$i]}.txt | cut -c 1-6 --complement)
    MAX_RSS=$(grep "Max RSS" time-${kernels[$i]}.txt | cut -c 1-9 --complement)
    echo ${kernels[$i]},$LD_CNT,$ST_CNT,$L1_ACCS_CNT,$L1_MISS_CNT,$TIME,$MAX_RSS >> ../zray-gapbs-stats.csv
    #echo ${kernels[$i]},$LD_CNT,$ST_CNT,$TIME,$PP_TIME,$MAX_RSS >> ../zray-gapbs-stats.csv
done
cd $BASE_DIR
