#!/bin/bash

N=100

# Starting the Mosquitto broker
../src/mosquitto -c ./hw4.conf > broker.log &
sleep 2

# Starting our customized subscriber
../client/mosquitto_sub -i "sub1" -t "t1" -p 2006 > sub.out &

# Starting our customized publishers
for i in $(seq 1 1 $N); do
    ../client/mosquitto_pub -i "pub$1" -t "t1" -m "from pub$i" -p 2006 -q 0 --repeat 300 --repeat-delay 0.3 &
    sleep 0.13
done
echo "Finished starting all publishers"


# Keep collecting data
sleep 20

# Killing all publishers and the subscriber
killall mosquitto_pub
killall mosquitto_sub

sleep 2

# Killing the broker
./kill_brokers.sh

sleep 1

# Parsing data
./parse.sh
