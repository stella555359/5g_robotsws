#!/bin/bash
dir=$1
archive=$2

cd "$dir" || exit 1
tar --zstd -cf "$archive" *.pcap
rm -f *.pcap
