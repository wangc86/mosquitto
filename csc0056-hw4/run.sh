#!/bin/bash

N=1

# Starting the Mosquitto broker
../src/mosquitto -c ./hw4.conf > broker.log &
sleep 2

# Starting our customized subscriber
../client/mosquitto_sub -i "sub1" -t "t1" -p 2006 > sub.out &

# Starting our customized publishers
for i in $(seq 1 1 $N); do
    ../client/mosquitto_pub -i "pub$i" -t "t1" -p 2006 -q 0 --embed-timestamp --repeat 10000 --repeat-delay 0.001 &
    sleep 0.03
done
#TODO: Need to discard the latency measurements taken at the initialization phase,
#      for they have relatively longer delay due to interference by new client connections..
echo "Finished starting all publishers."
echo "Now, keep running for 10 seconds..."

# Keep collecting data
sleep 10

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
