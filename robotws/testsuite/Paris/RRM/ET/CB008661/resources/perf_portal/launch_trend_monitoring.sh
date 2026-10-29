#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
export PERF_PORTAL_DEV_MODE="False"
source /5g/usde/profiles/master/gnb/latest \
    python-mysql-connector=8.0.16.p362 \
    python3-requests=2.18.4.p362 \
    || exit 1
python3 ./crontab_trend_monitoring.py >> log/trend_monitoring.log 2>&1 || exit 1
