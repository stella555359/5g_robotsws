#!/usr/bin/bash

latest_date=$(ls -1 | awk -F'[-_.]' '{print $3$4}' | sort -u | sort -t'+' -k1,1n -k2,2n | tail -1)
echo latest=$latest_date
ls > listPM.txt
echo latest=$latest_date >> listPM.txt
for file in A*; do
    file_date=$(echo "$file" | awk -F'[-_.]' '{print $3$4}')
    if [ "$file_date" != "$latest_date" ]; then
        rm "$file"
    fi
done
