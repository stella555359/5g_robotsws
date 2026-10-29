*** Settings ***
Documentation    Suite for CB009233 Wireless LMP testcases for ASOF.

Resource        ../features/CB009233/TestCases/CB009233_TestCases.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/swconfig/swconfig.robot
Resource        ../common_resources/variables/variables.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
[1]CB009233_Handling_of_sensitive_data
    [Tags]    TC5
    ...       [1]CB009233_Handling_of_sensitive_data
    CB009233_Handling_of_sensitive_data

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup
    Add one flag to swconfig    flag=0x1A002E=1  reboot_after_uploading=True

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                             input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown
