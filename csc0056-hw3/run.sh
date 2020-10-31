#!/bin/bash

topic=1
period=1
N=400

# Starting the Mosquitto broker
../src/mosquitto -c ./hw3.conf > arrival_time.out &
sleep 2

# Starting publishers
for i in $(seq 1 1 $N); do
    ./periodic_pub.sh $topic $period &
    sleep 0.$(( $RANDOM % 99 + 1 ))
done
echo "Finished starting all publishers"

# Collecting data
sleep 120

# Killing all publishers
echo "Killing all publishers"
killall periodic_pub.sh
killall mosquitto_pub

sleep 25

# Killing the broker
echo "Killing the broker"
killall mosquitto

sleep 2

# Parsing data
./parse.sh
