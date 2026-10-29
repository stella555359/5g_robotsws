#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
export PERF_PORTAL_DEV_MODE="False"
source /5g/usde/profiles/master/gnb/latest \
    python-coverage=4.5.2.p362 \
    python-mysql-connector=8.0.16.p362 \
    python3-requests=2.18.4.p362 \
    || exit 1
python3 ./crontab_box_plot_increase.py > log/box_plot_increase.log 2>&1 || exit 1
