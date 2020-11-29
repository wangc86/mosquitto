#!/bin/bash

N=3

# Starting the Mosquitto broker
../src/mosquitto -c ./hw4.conf > arrival_time.out &
sleep 2

# Starting our customized publishers
for i in $(seq 1 1 $N); do
    ../client/mosquitto_pub -t "topic1" -m "from pub$i" -p 2006 -q 0 --repeat 100 --repeat-delay 1 &
    sleep 0.3
done
echo "Finished starting all publishers"

# Starting our customized subscriber
../client/mosquitto_sub -t "topic1" -p 2006 &

# Keep collecting data
sleep 5

# Killing all publishers and the subscriber
killall mosquitto_pub
killall mosquitto_sub

sleep 2

# Killing the broker
./kill_brokers.sh

sleep 1

# Parsing data
./parse.sh
