#!/bin/sh

#Show egate and edaemon processes
echo "egate process:"
ps -auxf | grep egate | grep -v grep
echo "edaemon process:"
ps -auxf | grep edaemon | grep -v grep
