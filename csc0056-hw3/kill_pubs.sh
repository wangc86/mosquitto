#!/bin/bash

# Killing all publishers
echo "Killing all publishers"
killall periodic_pub.sh
killall mosquitto_pub

