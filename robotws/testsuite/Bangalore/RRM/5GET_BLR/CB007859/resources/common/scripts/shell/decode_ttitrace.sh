#!/bin/bash
mkdir /var/eventsTrace/tti_extracted

for i in /var/eventsTrace/L2TtiTrace_EventsSnapshot.bin.*.tar.gz; do
    tar zxvf $i -C /var/eventsTrace/tti_extracted/
done
sleep 5s

cd /var/eventsTrace/tti_extracted
mkdir /var/eventsTrace/tti_extracted/csv
for i in L2TtiTrace_EventsSnapshot.bin.*; do
    /opt/tools/ttiTrace/eventDecoder $i csv/$i
done

cd /var/eventsTrace/tti_extracted/csv
cat $(ls -v *dl.csv) > full_dl.csv
cat $(ls -v *ul.csv) > full_ul.csv
