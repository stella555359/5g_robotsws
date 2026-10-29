*** Settings ***


Documentation   EDA Action For 03805465
...             RCA:  https://rca-shark.ext.net.nokia.com/onlineui/onlinerca/MNRCA-75105
...             Jira: https://jiradc.ext.net.nokia.com/browse/MNRCA-75724
...    author: 'VRF Ulm Team #4'
...    Team: 'MN RAN RD VRF ULM 4'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource        5GC000707_Keywords.robot

Suite Setup     Prepare TL for 5GC000707
Suite Teardown  Sqd65 Common Teardown

Test Setup      Perform Preconditions of Test Scenario
Test Teardown   Perform Postconditions of Test Scenario

*** Test Cases ***

03805465_NG_FLOW_REL_GNB_UNSPECIFIED_not_pegged_during_InterRAT-HO_with_RLF
    [Documentation]  03805465
    [Tags]   03805465
    Set Reporting Interval
    Send Egate Command and verify output   cmd=script file=${CURDIR}/03805465.lua
    Verify PM Counters  03805465
