#!/bin/bash

echo "Zipping total results..."
mkdir
zip $1/nmap_results/$2.zip $1/nmap_results/*.html $1/nmap_results/*.nmap $1/nmap_results/*.gnmap $1/nmap_results/*.xml $1/nmap_results/*.log
find $1/nmap_results -type f ! -name "*.zip" -delete
