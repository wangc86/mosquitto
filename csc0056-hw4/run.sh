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
stdbuf -oL ../src/mosquitto -c ./hw4.conf > n.log 2> t.log &
for i in $(seq 1 4 1); do
    sleep 0.5
    echo -n "."
done

# Starting our customized subscriber
../client/mosquitto_sub -v -i "sub1" -t "t1" -p 2006 > sub.log &
echo -n "."

# Starting our customized publishers
# Note that we've changed the --repeat-delay semantics, and
# now the delay follows an uniform distribution, with the specified value being the upper bound of the range.
# The time unit of the delay parameter is in seconds.
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
# Prune the subscriber log, because the log includes those
# data generated before we started taking samples in the broker.
L=$(wc -l n.log | awk '{print $1}')
P=$(wc -l sub.log | awk '{print $1}')
D=$(( $P - $L ))
awk -v delta=$D 'NR>=delta {print $0}' sub.log > sub.log.pruned
THROUGHPUT=$(echo "scale=6; $(wc -l sub.log.pruned | awk '{print $1}') / $SEC" | bc)
echo "    U (throughput) = $THROUGHPUT pkts/sec"
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' t.log > t1.log
T1=$(./avg.sh t1.log)
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' sub.log.pruned > t2.log
T2=$(./avg.sh t2.log)
echo "    T1 (delay in the broker) = $T1 seconds"
echo "    T2 (end-to-end delay)    = $T2 seconds"
echo "    N1 (from U*T1) = $(echo "scale=6; $THROUGHPUT * $T1" | bc) packets"
echo "    N2 (from U*T2) = $(echo "scale=6; $THROUGHPUT * $T2" | bc) packets"
echo "  ------------------------------------------------------"
FOLDER=$(date +%X)
mkdir -p result/$FOLDER-$N_PUBS-$SEC
cp *.log* result/$FOLDER-$N_PUBS-$SEC
