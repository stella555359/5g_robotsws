*** Settings ***
Documentation  This suite contains WebEM__BER_Threshold_major_alarm_UL TC

Resource  ../test_resources/WebEM__BER_Threshold_major_alarm_UL.robot


*** Test Cases ***
WebEM__BER_Threshold_major_alarm_UL
    [Setup]  TC Setup
    TC__WebEM__BER_Threshold_major_alarm_UL
    [Teardown]  TC Teardown
