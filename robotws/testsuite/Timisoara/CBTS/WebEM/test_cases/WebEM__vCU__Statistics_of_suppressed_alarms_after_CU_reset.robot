*** Settings ***
Documentation  This suite contains WebEM__vCU__Statistics_of_suppressed_alarms_after_CU_reset TC

Resource  ../test_resources/WebEM__vCU__Statistics_of_suppressed_alarms_after_CU_reset.robot


*** Test Cases ***
WebEM__vCU__Statistics_of_suppressed_alarms_after_CU_reset
    [Setup]  TC Setup
    TC__WebEM__vCU__Statistics_of_suppressed_alarms_after_CU_reset
    [Teardown]  TC Teardown
