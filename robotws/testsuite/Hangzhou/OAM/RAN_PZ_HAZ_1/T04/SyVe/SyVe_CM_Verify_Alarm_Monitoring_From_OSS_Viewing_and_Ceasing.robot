*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables         ../test_line_specific/SBTS_SYVE_1910/My_Variables.py
Resource          ../test_resources/SyVe/SyVe_CM_Verify_Alarm_Monitoring_From_OSS_Viewing_and_Ceasing.robot

*** Test Cases ***
SyVe_CM_Verify_Alarm_Monitoring_From_OSS_Viewing_and_Ceasing
    [Setup]    TC Setup
    SyVe_CM_Verify_Alarm_Monitoring_From_OSS_Viewing_and_Ceasing
    [Teardown]    TC TearDown