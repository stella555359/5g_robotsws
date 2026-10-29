*** Settings ***
Documentation  This suite contains KPI__CBTS__M2M_Remote_Syslog_Streaming_Reset_API TC

Resource  ../test_resources/KPI__CBTS__M2M_Remote_Syslog_Streaming_Reset_API.robot


*** Test Cases ***
KPI__CBTS__M2M_Remote_Syslog_Streaming_Reset_API
    [Setup]  TC Setup
    TC__KPI__CBTS__M2M_Remote_Syslog_Streaming_Reset_API
    [Teardown]  TC Teardown
