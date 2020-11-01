#!/bin/bash
awk 'BEGIN {sum=0} {sum+=$1} END {printf "%.6f\n", sum/NR}'
