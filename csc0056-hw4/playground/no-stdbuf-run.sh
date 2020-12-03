#!/bin/bash

N_PUBS=100
SAMPLES=100

# The unit of delay is in hundred milliseconds.
# For example, the following implies 400 milliseconds.
# We do this because we want to calculate and show
# the average arrival rate using BASH, and because
# BASH does not easily support floating-point arithmetics.
DELAY=4

echo "Initializing the system..."
# Starting the Mosquitto broker
#stdbuf -oL ../src/mosquitto -c ./hw4.conf > N.log 2> tmp.log &
../src/mosquitto -c ./hw4.conf > N.log 2> tmp.log &
sleep 2

# Starting our customized subscriber
../client/mosquitto_sub -v -i "sub1" -t "t1" -p 2006 > sub.out &

# Starting our customized publishers
for i in $(seq 1 1 $N_PUBS); do
    ../client/mosquitto_pub -i "pub$i" -t "t1" -p 2006 -q 0 --embed-timestamp --repeat 5000 --repeat-delay 0.$DELAY &
    sleep 0.01
done

#TODO: Need to discard the latency measurements taken at the initialization phase,
#      for they have relatively longer delay due to interference by new client connections..
echo "Finished starting all components."
echo "Now, keep running to get $SAMPLES samples of N..."

# Keep collecting data
for i in $(seq 1 1 $SAMPLES); do
    pkill -12 -f src/mosquitto
    sleep 0.00$(( $RANDOM % 999 + 1))
done

# Killing all publishers, the subscriber, and the broker
exec 3>&2
exec 2> /dev/null
pkill mosquitto_sub 
pkill mosquitto_pub 
pkill -f src/mosquitto
exec 2>&3

# Parsing data
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' sub.out > e2e_latency.out
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' tmp.log > T.log

echo "...Done"
echo "----------- result --------------------------"
LAMBDA=$(( 20 / $DELAY * $N_PUBS ))
#T=`./avg.sh T.log`
#N=`./avg.sh N.log`
awk "END{print NR};" N.log
echo "  Lambda = $LAMBDA"
echo "  T = $T"
#echo "  N (estimated by Little's Theorem) = $(awk -v var1='$LAMBDA',var2='$T' 'BEGIN{print var1*var2};')"
#echo "  N (from our empirical measurement) = $N"
echo "---------------------------------------------"
