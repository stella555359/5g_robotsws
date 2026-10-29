*** Settings ***
Documentation       Suite for feature CB007822 on ASIM.
...
...                 author:    Jagoda Kubacka
...                 contact:   jagoda.kubacka@nokia.com

Resource            ../features/CB007822/TestCases/CB007822.robot
Resource            ../common_resources/gathering_logs/gathering_logs.robot
Resource            ../common_resources/variables/variables.robot

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown

Test Setup          Test Setup
Test Teardown       Test Teardown

*** Test Cases ***
[1]CNI_92066_CB007822_Robustness_full_TPM_or_unavailable
    [Tags]
    ...    [1]CB007822_Robustness_full_TPM_or_unavailable
    CB007822_Robustness_full_TPM_or_unavailable

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup
    Add Alarm To Allowed Alarms     61675     WiFi Configuration Issue

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                             input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown
