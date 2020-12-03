#!/bin/bash

pkill mosquitto_sub 
pkill mosquitto_pub 
pkill -f src/mosquitto
