#!/bin/bash

echo "Running scan..."
if [ -n "$6" ]
then
  sudo nmap $6 $1 -p- -vvv --reason --min-rate $2 --max-rate $3 $4 $5
else
  sudo nmap $1 -p- -vvv --reason --min-rate $2 --max-rate $3 $4 $5
fi
