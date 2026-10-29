*** Settings ***
Documentation   Logs collector is designed to help collect the five most common types of logs:
...                 5G SMOD tcpdump (master, slave)
...                 5G Snapshot
...                 5G Syslog
...                 L1L2 logs
...                 TTI traces
...
...             Usage:
...                 robot -V <path to TL init> -d <log_path> /home/ute/robotws5g/testsuite/Wroclaw/RRM/VRF_WRO2_T07/manual/logs_collector.robot

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/manual/logs_collector.py


*** Test Cases ***
Logs collector
    logs_collector   log_name=logs_collector   duration=${10}         collect_l1l2=${false}     smod_lte=${false}
    ...              smod_master=${false}   smod_slave=${false}       collect_tti=${false}   collect_btslog=${false}
    ...              collect_snapshot=${false}
