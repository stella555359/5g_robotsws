*** Settings ***
Documentation    Suite for CB013432 Wireless LMP testcases for ASOH.
...              author:    Piotr Pinderak
...              contact:   piotr.pinderak@nokia.com

Resource        ../features/CB013432/TestCases/CB013432_TestCases.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/variables/variables.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
[2]CB013432_CB009233_Services_Supported_Over_Wifi_LMP
    [Tags]    TC1
    ...       [1]CB013432_CB009233_Services_Supported_Over_Wifi_LMP
    CB013432_CB009233_Services_Supported_Over_Wifi_LMP

[2]CB013432_CB009233_Wifi_LMP_Layer_Hardening_And_Best_Practices
    [Tags]    TC2
    ...       [1]CB013432_CB009233_Wifi_LMP_Layer_Hardening_And_Best_Practices
    CB013432_CB009233_Wifi_LMP_Layer_Hardening_And_Best_Practices

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                             input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown
