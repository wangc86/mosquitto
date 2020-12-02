#!/bin/bash

N_PUBS=100
SAMPLES=1000

# Starting the Mosquitto broker
../src/mosquitto -c ./hw4.conf > broker.log &
sleep 2

# Starting our customized subscriber
../client/mosquitto_sub -v -i "sub1" -t "t1" -p 2006 > sub.out &

# Starting our customized publishers
for i in $(seq 1 1 $N_PUBS); do
    ../client/mosquitto_pub -i "pub$i" -t "t1" -p 2006 -q 0 --embed-timestamp --repeat 500000 --repeat-delay 0.013 &
    sleep 0.00$(( $RANDOM % 99 ))
    sleep 0.02
done
#TODO: Need to discard the latency measurements taken at the initialization phase,
#      for they have relatively longer delay due to interference by new client connections..
echo "Finished starting all publishers."
echo "Now, keep running to get $SAMPLES samples of N..."

# Keep collecting data
for i in $(seq 1 1 $SAMPLES); do
    pkill -12 -f src/mosquitto
    #sleep 1
    sleep 0.0$(( $RANDOM % 99 ))
    sleep 0.017
done

# Killing all publishers and the subscriber
killall mosquitto_pub
killall mosquitto_sub

sleep 2

# Killing the broker
./kill_brokers.sh

sleep 1

# Parsing data
./parse.sh
./inter.sh
echo "...Done"
