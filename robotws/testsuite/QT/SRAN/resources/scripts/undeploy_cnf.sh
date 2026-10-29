#!/bin/bash

release_name="$1"
namespace="$2"
timeout_sec="${3:-180}"

if [[ -z "$release_name" || -z "$namespace" ]]; then
  echo "Usage: $0 <release_name> <namespace> [timeout_sec]"
  exit 1
fi

# Uninstall helm release in the background
timeout "${timeout_sec}s" helm uninstall "$release_name" -n "$namespace" &

# Delete all jobs in the given namespace in the background with timeout
(
  start_time=$(date +%s)
  while true; do
    sleep 5
    jobs=$(kubectl get jobs -n "$namespace" --no-headers -o custom-columns=":metadata.name")
    if [[ -z "$jobs" ]]; then
      echo "All jobs deleted."
      break
    fi
    for job in $jobs; do
      kubectl delete job "$job" -n "$namespace" --grace-period=0 --force
    done
    now=$(date +%s)
    elapsed=$((now - start_time))
    if (( elapsed > timeout_sec )); then
      echo "Timeout reached while deleting jobs."
      break
    fi
  done
) &

# Wait for both background jobs to finish
wait
echo "Helm uninstall and job deletions completed."