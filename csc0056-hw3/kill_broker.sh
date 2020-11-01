#!/bin/bash

# Killing the broker
# Note that this would also kill all other
# existing mosquitto brokers ran by the same user
echo "Killing brokers"
killall mosquitto

