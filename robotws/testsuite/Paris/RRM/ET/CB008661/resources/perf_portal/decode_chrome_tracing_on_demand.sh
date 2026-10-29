#!/usr/bin/bash

source /5g/usde/profiles/master/gnb/latest
python3 /5g_storage/PatchServer/perfport/ci-scripts/perf_portal/decode_chrome_tracing_on_demand.py "${1}"
