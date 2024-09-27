#!/bin/bash

# This script will generate a list of source file names that we will use for code tracing.
# Some irrelevant directories are skipped, so that our search will not return irrelevant results.

# Before running this script, change the MOS to the-path-to-your-mosquitto-folder
# and create folder $HOME/cscope

# To learn more, see https://cscope.sourceforge.net/large_projects.html 

MOS=/home/cw/courses/csc0056/mosquitto
cd /
find $MOS/include $MOS/src $MOS/lib $MOS/deps $MOS/client -name '*.[ch]' -print > $HOME/cscope/cscope.files
