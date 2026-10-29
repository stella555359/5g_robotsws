#!/bin/bash

# Define the Telnet options and host details
TELNET_OPTIONS=" -e -"
HOST="10.255.1.200"
PORT="10001"

# Start the Telnet session and send commands
(
    sleep 1
    echo -e "\r"  # Send initial CR
    sleep 2
    echo "RMT 1"
    sleep 1
    echo -e "\r"
    sleep 2
    echo "PV 52"
    sleep 1
    echo -e "\r"
    sleep 2
    echo "PV?"
    sleep 1
    echo -e "\r"
    sleep 2
    echo "-"

) | telnet $TELNET_OPTIONS $HOST $PORT


