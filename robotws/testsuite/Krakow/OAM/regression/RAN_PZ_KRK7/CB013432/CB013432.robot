*** Settings ***
Documentation
...    Test suite for regression testing for feature CB008927
...    authors: Jakub Bialon
...    maintainer: Jakub Bialon
...    group: RAN_PZ_KRK_SG_7
...    contact: jakub.bialon@nokia.com


Resource    resources/keywords.robot


Suite Setup    Common Suite Setup With OnAir Test Line Preparation
...            list_of_additional_allowed_alarms=@{ADDITIONAL_ALLOWED_ALARMS}
...            prefix_tag=CB013432
Suite Teardown    Common Suite Teardown
Test Setup    Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms


*** Variables ***
@{ADDITIONAL_ALLOWED_ALARMS}    WiFi Client Connected    WiFi Enabled Alarm


*** Test Cases ***
[1][1.0] CB013432_01_Feature_Enable_for_ASiR_WebEM
    [Tags]    TC01
    keywords.Enable WiFi Connection
    gnbasir.Disconnect
    keywords.Connect To Pc
    keywords.Run Test And Check Result    test_tag=TC01
    [Teardown]    Run Keywords    Disable WiFi Connection    AND
    ...                           keywords.Disconnect Pc    AND
    ...                           gnbasir.Disconnect


[1][1.0] CB013432_02_CM_Recommissioning_for_ASiR_WEM
    [Tags]    TC02
    keywords.Enable WiFi Connection
    gnbasir.Disconnect
    keywords.Connect To Pc
    keywords.Run Test And Check Result    test_tag=TC02
    [Teardown]    Run Keywords    Disable WiFi Connection    AND
    ...                           keywords.Disconnect Pc    AND
    ...                           gnbasir.Disconnect


[1][1.0] CB013432_04_Block_Unblock_pRRHs_via_ASiR_WebEM
    [Tags]  TC04
    keywords.Enable WiFi Connection
    gnbasir.Disconnect
    keywords.Connect To Pc
    keywords.Run Test And Check Result    test_tag=TC04
    [Teardown]    Run Keywords    Disable WiFi Connection    AND
    ...                           keywords.Disconnect Pc    AND
    ...                           gnbasir.Disconnect


[1][1.0] CB013432_05_Reset_ASiR_HUB_via_ASiR_WebEM
    [Tags]  TC05
    keywords.Enable WiFi Connection
    gnbasir.Disconnect
    keywords.Connect To Pc
    keywords.Run Test And Check Result    test_tag=TC05
    [Teardown]    Run Keywords    Disable WiFi Connection    AND
    ...                           keywords.Disconnect Pc    AND
    ...                           gnbasir.Disconnect


[1][1.0] CB013432_07_Reset_pRRH_via_ASiR_WebEM
    [Tags]  TC07
    keywords.Enable WiFi Connection
    gnbasir.Disconnect
    keywords.Connect To Pc
    keywords.Run Test And Check Result    test_tag=TC07
    [Teardown]    Run Keywords    Disable WiFi Connection    AND
    ...                           keywords.Disconnect Pc    AND
    ...                           gnbasir.Disconnect
