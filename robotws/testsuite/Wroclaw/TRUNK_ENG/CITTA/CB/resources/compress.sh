#!/bin/bash
#
# Monitor <DIR> and compress files that were last modified more than <M> minutes ago.
# Uses zstd for compression. Original files are removed after compression completes.
# Runs indefinitely, scanning <DIR> each minute.

usage() {
    echo "Compress old files in a directory, periodically"
    echo ""
    echo "Usage: $0 <DIR> <M>"
    echo ""
    echo "Files in <DIR> that were modified more than <M> minute(s) ago are compressed in place."
}

if [ "$#" -ne 2 ]; then
    usage
    exit 1
fi

rootdir="$1"
if [ ! -d "$rootdir" ]; then
    echo "Error: '$rootdir' does not exist or is not a directory." >&2
    exit 2
fi

mtime="$2"
if ! [[ "$mtime" =~ ^[0-9]+$ ]] ; then
   echo "Error: '$mtime' is not a valid number of minutes." >&2
   exit 1
fi

while true; do
    while IFS= read -r -d '' file
    do
        timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "[${timestamp}] compressing ${file}"
        zstd --rm "${file}" 2>&1
    done <  <(find "${rootdir}" -type f -mmin +${mtime} ! -name '*.zst' -print0)
    sleep 60
done
