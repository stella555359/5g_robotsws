*** Settings ***
Resource    ../test_resources/FM__Radio_memory_abnormal_and_critical_threshold_via_NA.robot

*** Test Cases ***
FM__Radio_memory_abnormal_and_critical_threshold_via_NA
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__Radio_memory_abnormal_and_critical_threshold_via_NA
