*** Settings ***
Documentation
...    author: Chun Li
...    Contact: chun.li@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    import all resources from HAZ3 T05

Library     ./python/analysis_emil.py
Library     ./python/check_snapshot.py
Library     ./python/check_syslog.py
Library     ./python/check_tti.py
Library     ./python/data_process.py

Resource    ../../KISS/robot/common_resource.robot
Resource    ./robot/common.robot
Resource    ./robot/counter.robot
Resource    ./robot/m5_dcap.robot
