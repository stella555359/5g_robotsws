*** Settings ***
Documentation    Suite for 9203 testcases from Pack C for NESAS.

Resource        ../features/Stream_B2B/TestCases/Stream_B2B_TestCases-SR.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        ../common_resources/scout/scout_operations.robot
Resource        ../common_resources/alarms/alarm.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/swconfig/swconfig.robot
Resource        ../common_resources/admin/admin.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        ../common_resources/variables/variables.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

Test Setup        Test Setup
Test Teardown     Test Teardown

*** Test Cases ***
NESAS-SR_Private_Key_Storage_and_Certificate_Structure_Check
    NESAS-SR_Private_Key_Storage_and_Certificate_Structure_Check

NESAS-SR_Protecting_Data_and_Information_Storage
    NESAS-SR_Protecting_Data_and_Information_Storage

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown

