*** Settings ***
Documentation
...         author: Lixia.tang
...         contact: lixia.tang@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         Robust test

Resource    ./Resources/CB013125_Common_Keywords.robot


*** Test Cases ***
[1]CB013125_RU_Reset_Lock_Unlock_in_Loops
    [Setup]    Test Case setup
    [Timeout]    600min
    RU Reset 30 Times
    [Teardown]    Test Case teardown

[1]CB013125_Cell_Delete_Add_in_Loops
    [Setup]    Site Reset 1 Times
    [Timeout]    500min
    Cell Delete and Add for 30 Times
    [Teardown]    Test Case teardown

[1]CB013125_Site_Reset_without_HWF_in_Loops
    [Setup]    Site Reset 1 Times
    [Timeout]    500min
    Reset Site without HWF 30 Times
    [Teardown]    Test Case teardown