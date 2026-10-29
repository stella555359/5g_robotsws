*** Settings ***
Documentation
...    Author: Adrian Alpredi
...    Maintainer: Adrian Alpredi (adrian.alpredi@nokia.com)
...    Group in charge: MN RAN BOAM VERIF Team3
...    References: doors
...    Feature Description: 5GC001719-A


Resource   ./resources/5GC001719-A.robot
Resource   ./resources/xPATH_5GC001719-A.robot
#Suite Setup     Run Keyword  Login CU
Suite Teardown  Run Keyword And Ignore Error  Logout vCU

*** Test Cases ***
14. CNF activation in unforced switchover triggered by WebEM, sent to Standby CNF
    [Tags]   CRT_GEO   QC_157683  QCD_MN_RAN  QCP_RAN_ET
    Log    a
    Check Primary&Active vCU status
    Check Secondary&Standby vCU status
    Unforced Switchover on Standby vCU
    Check if Secondary became Active
    Check if Primary became Standby


15. CNF activation in forced switchover triggered by WebEM, sent to Standby CNF
    [Tags]   CRT_GEO   QC_157684  QCD_MN_RAN  QCP_RAN_ET
    [Setup]  Should Be Equal As Strings  ${PREV TEST STATUS}   PASS
    Log     t
    Forced Switchover on Standby vCU
    Check if Primary became Active
    Check if Secondary became Standby

17. CNF activation and deactivation triggered by WebEM , sent to Active CNF
    [Tags]   CRT_GEO   QC_157685  QCD_MN_RAN  QCP_RAN_ET
    [Setup]  Should Be Equal As Strings  ${PREV TEST STATUS}   PASS
    Deactivate CNF
    Check if Primary became Standby after Deactivate

