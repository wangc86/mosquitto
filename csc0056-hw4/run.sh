#!/bin/bash

if [[ "$#" -ne 2 ]]; then
    echo "Error: need to give two parameters"
    echo "Usage: $0 #-of-publishers #-of-seconds-to-sample"
    exit 2
fi
# FYI, https://stackoverflow.com/questions/18568706/check-number-of-arguments-passed-to-a-bash-script

N_PUBS=$1
SEC=$2
echo "Number of publishers = $N_PUBS; sampling duration = $SEC seconds"


echo -n "Initializing the system..."
# Starting the Mosquitto broker
stdbuf -oL ../src/mosquitto -c ./hw4.conf > N.log 2> tmp.log &
for i in $(seq 1 4 1); do
    sleep 0.5
    echo -n "."
done

# Starting our customized subscriber
../client/mosquitto_sub -v -i "sub1" -t "t1" -p 2006 > e2e.log &
echo -n "."

# Starting our customized publishers
# Note that we've changed the --repeat-delay semantics, and
# now the delay follows an uniform distribution, with the specified value being the upper bound of the range.
# The unit of the delay parameter is second.
DELAY=0.99
for i in $(seq 1 1 $N_PUBS); do
    ../client/mosquitto_pub -i "pub$i" -t "t1" -p 2006 -q 0 --embed-timestamp --repeat 50000 --repeat-delay $DELAY &
    if [ $(( $i % 10 )) -eq 0 ]; then
        echo -n "."
    fi
    sleep 0.01
done
echo "Done!"

# The following pkill command sends signal SIGUSR2 to toggle the sampling mechanism
# Note that we take samples at every arrival to estimate N
pkill -12 -f src/mosquitto
for i in $(seq 1 1 $SEC); do
    if [ $(( $i % 2 )) -eq 0 ]; then
        echo -ne "\rSampling for N (should take $SEC seconds)....... $(echo "100*$i/$SEC"|bc)%"
        #echo -n "."
    fi
    sleep 1
done
pkill -12 -f src/mosquitto
echo -e "\rSampling for N (should take $SEC seconds)....... Done!"

# Allow some time for the final sample before killed
sleep 1

# Killing all publishers, the subscriber, and the broker
# The following manipulation on the file descriptors
# are for the purpose to silence the output message of pkill.
exec 3>&2
exec 2> /dev/null
pkill mosquitto_sub 
pkill mosquitto_pub 
pkill -f src/mosquitto
exec 2>&3

echo "  --------------- Experimental Result ------------------"
# The following 2/$DELAY came from 1/($DELAY/2), since the delay follows an uniform distribution.
LAMBDA1=$(echo "scale=6; 2 / $DELAY * $N_PUBS" | bc)
echo "    Lambda (in theory)   L1 = $LAMBDA1 pkts/sec"
L=$(wc -l N.log | awk '{print $1}')
LAMBDA2=$(echo "scale=6; $L / $SEC" | bc)
echo "    Lambda (in practice) L2 = $LAMBDA2 pkts/sec"
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' tmp.log > T.log
T=$(./avg.sh T.log)
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' e2e.log > e2e.delay
echo "    T (avg. time in structure 'inflight') = $T seconds"
echo "    N (from L1*T) = $(echo "scale=6; $LAMBDA1 * $T" | bc) packets"
echo "    N (from L2*T) = $(echo "scale=6; $LAMBDA2 * $T" | bc) packets"
echo "    N (from our empirical measurement) = $(./avg.sh N.log) packets"
echo "  ------------------------------------------------------"
