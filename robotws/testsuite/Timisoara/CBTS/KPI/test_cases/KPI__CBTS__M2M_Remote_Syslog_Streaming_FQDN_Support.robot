*** Settings ***
Documentation  This suite contains KPI__CBTS__M2M_Remote_Syslog_Streaming_FQDN_Support TC

Resource  ../test_resources/KPI__CBTS__M2M_Remote_Syslog_Streaming_FQDN_Support.robot


*** Test Cases ***
KPI__CBTS__M2M_Remote_Syslog_Streaming_FQDN_Support
    [Setup]  TC Setup
    TC__KPI__CBTS__M2M_Remote_Syslog_Streaming_FQDN_Support
    [Teardown]  TC Teardown
