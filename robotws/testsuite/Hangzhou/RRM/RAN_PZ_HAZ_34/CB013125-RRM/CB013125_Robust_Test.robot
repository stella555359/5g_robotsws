*** Settings ***
Documentation
...         author: Lixia.tang
...         contact: lixia.tang@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         Robust test

Resource    ./Resources/CB013125_Common_Keywords.robot


*** Test Cases ***
[1]CB013125_SCF_Commission_in_Loops
    [Setup]    Test Case setup
    [Timeout]    500min
    SCF Commission 30 times
    [Teardown]    Test Case teardown

[1]CB013125_BB_Reset_in_Loops
    [Setup]    Site Reset 1 Times
    [Timeout]    500min
    BBMOD Reset 30 Times
    [Teardown]    Test Case teardown

[1]CB013125_RAT_Reset_in_Loops
    [Setup]    Site Reset 1 Times
    [Timeout]    500min
    LTE RAT Reset 30 Times
    NR RAT Reset 30 Times
    [Teardown]    Test Case teardown
