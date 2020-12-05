#!/bin/bash

N=1

# Starting the Mosquitto broker
../src/mosquitto -c ./hw4-test-run.conf &
sleep 2

# Starting our customized subscriber
../client/mosquitto_sub -i "sub1" -t "topic1" -p 2006 > sub.out &

# Starting our customized publishers
for i in $(seq 1 1 $N); do
    ../client/mosquitto_pub -i "pub$i" -t "topic1" -p 2006 -q 0 --embed-timestamp &
    sleep 1
done

# Killing all publishers and the subscriber
#killall mosquitto_pub
#killall mosquitto_sub

#sleep 1

# Killing the broker and all publishers and subscribers.
./kill_all.sh
sleep 1
