*** Settings ***
Documentation  This suite contains WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager TC

Resource  ../test_resources/WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager.robot


*** Test Cases ***
WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    [Setup]  TC Setup
    TC__WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_in_BTS_Element_Manager
    [Teardown]  TC Teardown
