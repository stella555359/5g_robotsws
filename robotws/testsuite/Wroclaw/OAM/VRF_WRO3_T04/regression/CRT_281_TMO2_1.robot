*** Settings ***
Documentation         Suite for TL280

Resource        ../features/CB009484/TestCases/CB009484-SR.robot
Resource        ../features/CB012187/TestCases/CB012187-SR_TestCases.robot
Resource        ../features/5GC001049/TestCases/CB001049_TestCases.robot

Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/variables/variables.robot
Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
[1]CB009484-F_Verify_All_Cross_Origin_Policies
    [Tags]  9484  T01    trunk    25R2
    Verify_All_Cross_Origin_Policies

[1]CB012187-B-SR_BTS_Local_user_parameters_shall_be_synchronised_between_the_installed_SWs
    [Tags]  12187  T02    trunk    25R2    25R1_MP
    BTS_Local_user_parameters_shall_be_synchronised_between_the_installed_SWs

[1]CB012187-B-SR_Configuration_of_Allowed_lifetime_Allowed_Idle_period_from_WebEM_without_privileges
    [Tags]  12187  T03    trunk    25R2
    Configuration_of_Allowed_lifetime_&_Allowed_Idle_period_from_WebEM_without_privileges

[1]CB012187-B-SR_Configuration_of_Allowed_lifetime_Allowed_Idle_period_from_NMS_for_BTS_Local_User_Accounts
    [Tags]  12187  T04    trunk    25R2
    Configuration_of_Allowed_lifetime_&_Allowed_Idle_period_from_NMS_for_BTS_Local_User_Accounts

[1]CB012187-B-SR_BTS_Update_Allowed_lifetime_or_Allowed_Idle_period_by_existing_value_for_usable_BTS_local_user_accounts
    [Tags]  12187  T05    trunk    25R2
    BTS_Update_Allowed_lifetime_or_Allowed_Idle_period_by_existing_value_for_usable_BTS_local_user_accounts

[1]CB012187-B-SR_Stressful_robustness_test_for_WebEM_CLI
    [Tags]  12187  T06    trunk    25R2
    Stressful_robustness_test_for_WebEM_CLI

5GC001049_Dynamic_Firewall_Basic_TC
    [Tags]    1049    trunk
    Dynamic_Firewall_Basic_TC

5GC001049_Dynamic_Firewall_Advance_TC
    [Tags]    1049    trunk
    Dynamic_Firewall_Advance_TC

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
