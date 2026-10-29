*** Settings ***
Documentation  This suite contains WebEM__vDU__Statistics_of_suppressed_alarms_after_DU_reset TC

Resource  ../test_resources/WebEM__vDU__Statistics_of_suppressed_alarms_after_DU_reset.robot


*** Test Cases ***
WebEM__vDU__Statistics_of_suppressed_alarms_after_DU_reset
    [Setup]  TC Setup
    TC__WebEM__vDU__Statistics_of_suppressed_alarms_after_DU_reset
    [Teardown]  TC Teardown
