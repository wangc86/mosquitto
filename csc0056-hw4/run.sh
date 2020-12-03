#!/bin/bash

N_PUBS=100
SAMPLES=5000

# The unit of delay is in seconds.
DELAY=0.4

echo "Initializing the system..."
# Starting the Mosquitto broker
stdbuf -oL ../src/mosquitto -c ./hw4.conf > N.log 2> tmp.log &
sleep 2

# Starting our customized subscriber
../client/mosquitto_sub -v -i "sub1" -t "t1" -p 2006 > sub.log &

# Starting our customized publishers
# Note that we've changed the --repeat-delay semantics, and
# now the delay follows an uniform distribution, with the specified value being the upper bound of the range.
for i in $(seq 1 1 $N_PUBS); do
    ../client/mosquitto_pub -i "pub$i" -t "t1" -p 2006 -q 0 --embed-timestamp --repeat 50000 --repeat-delay $DELAY &
    sleep 0.01
done

echo "Finished initializing all components."
echo "Now, start to collect $SAMPLES samples of N..."

# Keep collecting data
for i in $(seq 1 1 $SAMPLES); do
    pkill -12 -f src/mosquitto
    sleep 0.00$(( $RANDOM % 999 + 1))
done
echo "...done. Start to parse the resulting data..."

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
# In the following, we throw away the first 300 lines, hoping to discount those interference
# incurred by commands in lines 24-27 above.
awk 'NR>300 {print $0}' sub.log > s1
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' s1 > e2e_latency.out
awk 'NR>300 {print $0}' tmp.log > t1
awk '{if ($2<0) printf "%.6f\n", (($1-1)+(1000000+$2)/1000000.0); else printf "%.6f\n", ($1+($2/1000000.0))}' t1 > T.log

echo "----------- result --------------------------"
# In the following we consider 1/($DELAY/2)=2/$DELAY since the delay follows an uniform distribution:
LAMBDA=$(echo "2 / $DELAY * $N_PUBS" | bc)
T=$(./avg.sh T.log)
e2e=$(./avg.sh e2e_latency.out)
echo "  Lambda = $LAMBDA packets/second"
echo "  T = $T seconds"
echo "  N (estimated by Little's Theorem) = $(echo "$LAMBDA * $T" | bc) packets"
echo "  N (from our empirical measurement) = $(./avg.sh N.log) packets"
echo "  End-to-end latency = $e2e seconds"
echo "---------------------------------------------"
