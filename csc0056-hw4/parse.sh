#!/bin/bash
awk 'NR==1 {s_prev=$1; us_prev=$2} NR > 1 {print ($1-s_prev), ($2-us_prev); s_prev=$1; us_prev=$2}' ./arrival_time.out > tmp
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' tmp > inter-arrival_time.out
