#!/bin/bash

while true;
do
    mosquitto_pub -t "topic1" -m "msg1" -p 2005 -q 0 
    sleep 0.$(( $RANDOM % 99 + 1 ))
done
