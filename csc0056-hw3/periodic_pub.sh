#!/bin/bash

topic=$1
period=$2
while true;
do
    mosquitto_pub -t "$topic" -m "msg" -p 2005 -q 0 
    sleep $period
done
