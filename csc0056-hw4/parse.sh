#!/bin/bash
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' sub.out > latency.out
