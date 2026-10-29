*** Settings ***
Documentation  This suite contains WebEM__Statistics_of_suppressed_alarms_after_BTS_reset TC

Resource  ../test_resources/WebEM__Statistics_of_suppressed_alarms_after_BTS_reset.robot


*** Test Cases ***
WebEM__Statistics_of_suppressed_alarms_after_BTS_reset
    [Setup]  TC Setup
    TC__WebEM__Statistics_of_suppressed_alarms_after_BTS_reset
    [Teardown]  TC Teardown
