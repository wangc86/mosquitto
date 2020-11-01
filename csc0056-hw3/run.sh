#!/bin/bash

topic=1
period=1
N=100

# Starting the Mosquitto broker
../src/mosquitto -c ./hw3.conf > arrival_time.out &
sleep 2

# Starting publishers
for i in $(seq 1 1 $N); do
    ./periodic_pub.sh $topic $period &
    sleep 0.1
    #sleep 0.$(( $RANDOM % 99 + 1 ))
done
echo "Finished starting all publishers"

# Keep collecting data
sleep 500

# Killing all publishers
./kill_pubs.sh

sleep 10

# Killing the broker
./kill_brokers.sh

sleep 2

# Parsing data
./parse.sh
