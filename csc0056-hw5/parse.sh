#!/bin/bash
awk '{if ($5-$3>0) printf "%ld.%ld\n", ($4-$2), ($5-$3); else printf "%ld.%ld\n", ($4-$2-1), (1000000000-$3+$5)}' out.txt > latency.out
awk 'BEGIN {sum=0} {sum+=$1} END {print sum/NR}' latency.out
