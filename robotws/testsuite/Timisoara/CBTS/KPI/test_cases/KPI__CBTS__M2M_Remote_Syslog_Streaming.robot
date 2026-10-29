*** Settings ***
Documentation  This suite contains KPI__CBTS__M2M_Remote_Syslog_Streaming TC

Resource  ../test_resources/KPI__CBTS__M2M_Remote_Syslog_Streaming.robot


*** Test Cases ***
KPI__CBTS__M2M_Remote_Syslog_Streaming
    [Setup]  TC Setup
    TC__KPI__CBTS__M2M_Remote_Syslog_Streaming
    [Teardown]  TC Teardown
