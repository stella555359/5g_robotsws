*** Settings ***
Documentation         Suite for trunk for TL169

Resource        ../features/CB008259/TestCases/CB008259.robot
Resource        ../features/CB008154/TestCases/CB008154.robot
Resource        ../features/CB005784-5G-A/TestCases/Keywords.robot
Resource        ../features/CB008267/TestCases/CB008267.robot
Resource        ../features/CB009131/TestCases/9131_TestCases_A.robot

Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/variables/variables.robot
Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
[1]CB010546_CB007426_CB008154_Manual_Temporary_Log_Event_Storage_ABIQ_ASIM
    [Tags]    8154    T02    trunk
    [1]CB008154 Manual Temporary Log Event Storage

[1]CB005784-5G-A_HTTPS_request_number_exceed_the_limitation_number
    [Tags]    5784    T03    trunk    25R2
    Number of HTTPS requests exceed the limitation number

[1]CB010777_CB008267-C_Nokia_Service_accounts_are_blocked_for_login_attempt_as_ftp_user_via_SSH_ABIQ
    [Tags]    8267    T05    trunk
    Nokia_Service_accounts_are_blocked_for_login_attempt_as_ftp_user_via_SSH

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
