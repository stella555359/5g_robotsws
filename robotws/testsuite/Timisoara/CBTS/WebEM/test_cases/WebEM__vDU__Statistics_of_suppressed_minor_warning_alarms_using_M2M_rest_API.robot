*** Settings ***
Documentation  This suite contains WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API TC

Resource  ../test_resources/WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API.robot


*** Test Cases ***
WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API
    [Setup]  TC Setup
    TC__WebEM__vDU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API
    [Teardown]  TC Teardown

