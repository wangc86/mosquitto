#!/bin/bash

# Starting the Mosquitto broker
../src/mosquitto -c ./hw4image.conf > arrival_time.out &
sleep 2

# Starting our subscriber
../client/mosquitto_sub -t "topic1" -p 2006 -N > ./output.jpg &
sleep 1

# Starting our publisher
../client/mosquitto_pub -t "topic1" -f ./arch.jpg -p 2006 -q 0 &
sleep 2

# Killing all related programs
killall mosquitto_pub
killall mosquitto_sub
killall mosquitto
