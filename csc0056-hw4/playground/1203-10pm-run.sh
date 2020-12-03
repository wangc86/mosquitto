#!/bin/bash

# In this version we take samples at every arrival to estimate N
# To make this work, we need to modify ./src/database.c and recompile the code
SEC=30

#N_PUBS=100
N_PUBS=500

# The unit of delay is in seconds.
DELAY=0.99

# The following 2/$DELAY came from 1/($DELAY/2), since the delay follows an uniform distribution.
LAMBDA=$(echo "2 / $DELAY * $N_PUBS" | bc)
echo -n "Number of publishers = $N_PUBS; "
echo "Lambda = $LAMBDA packets/second"

echo -n "Initializing the system..."
# Starting the Mosquitto broker
stdbuf -oL ../src/mosquitto -c ./hw4.conf > N.log 2> tmp.log &
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
for i in $(seq 1 1 $N_PUBS); do
    ../client/mosquitto_pub -i "pub$i" -t "t1" -p 2006 -q 0 --embed-timestamp --repeat 50000 --repeat-delay $DELAY &
    if [ $(( i % 10 )) -eq 0 ]; then
        echo -n "."
    fi
    sleep 0.01
done

echo "Done!"
echo -n "Collecting samples of N for $SEC seconds..."

# Keep collecting data
sleep $SEC

echo "Done!"
echo -n "Parsing the result..."

# Killing all publishers, the subscriber, and the broker
# The following manipulation on the file descriptors
# are for the purpose to silence the output message of pkill.
exec 3>&2
exec 2> /dev/null
pkill mosquitto_sub 
pkill mosquitto_pub 
pkill -f src/mosquitto
exec 2>&3

# Now, parse the resulting data.
# Note that we need to throw away some latency measurements taken during the initialization,
# for they have relatively long delays due to interference by new client connections.
# In the following, we throw away the first N_PUBS*0.01*Lambda samples, discounting those
# sampled during execution of lines 24-27 above.
D_NUM=$(echo "$N_PUBS * 0.01 * $LAMBDA" | bc)
echo "$D_NUM"
awk -v ignore="$D_NUM" 'NR>ignore {print $0}' sub.log > s1
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' s1 > e2e_latency.out
awk -v ignore="$D_NUM" 'NR>ignore {print $0}' tmp.log > t1
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' t1 > T.log

echo "Done!"
echo "--------- Experimental Result ---------------"
T=$(./avg.sh T.log)
e2e=$(./avg.sh e2e_latency.out)
echo "  Lambda = $LAMBDA packets/second"
echo "  T = $T seconds"
echo "  N (estimated by Little's Theorem) = $(echo "$LAMBDA * $T" | bc) packets"
awk -v ignore="$D_NUM" 'NR>ignore {print $0}' N.log > n1
echo "  N (from our empirical measurement) = $(./avg.sh n1) packets"
echo "  End-to-end latency = $e2e seconds"
echo "---------------------------------------------"
