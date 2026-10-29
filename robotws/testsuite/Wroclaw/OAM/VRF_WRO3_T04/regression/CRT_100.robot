*** Settings ***
Documentation    Suite for trunk for tl100

Resource        ../features/CNI-146617/TestCases/CNI-146617.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/swconfig/swconfig.robot
Resource        ../common_resources/variables/variables.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
[1]CNI-146617_SECU_Verify_Duration_of_Audit_Trail_Logs_Upload
    [Tags]    TC1
    ...       [1]CNI-146617_SECU_Verify_Duration_of_Audit_Trail_Logs_Upload
    CNI-146617_SECU_Verify_Duration_of_Audit_Trail_Logs_Upload

[1]CNI-146617_SECU_Verify_BTS_Capacity_for_Audit_Trail_Logs
    [Tags]    TC1
    ...       [1]CNI-146617_SECU_Verify_BTS_Capacity_for_Audit_Trail_Logs
    CNI-146617_SECU_Verify_BTS_Capacity_for_Audit_Trail_Logs

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
