*** Settings ***
Documentation  This suite contains PM__LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile TC

Resource  ../test_resources/PM__LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile.robot


*** Test Cases ***
PM__LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile
    [Setup]  TC Setup
    TC__PM__LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile
    [Teardown]  TC Teardown
