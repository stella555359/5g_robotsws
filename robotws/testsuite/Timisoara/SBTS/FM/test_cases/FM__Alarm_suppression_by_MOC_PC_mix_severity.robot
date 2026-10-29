*** Settings ***
Documentation  This suite contains FM__Alarm_suppression_by_MOC_PC_mix_severity TC

Resource  ../test_resources/FM__Alarm_suppression_by_MOC_PC_mix_severity.robot


*** Test Cases ***
FM__Alarm_suppression_by_MOC_PC_mix_severity
    [Setup]  TC Setup
    TC_FM__Alarm_suppression_by_MOC_PC_mix_severity
    [Teardown]  TC Teardown
