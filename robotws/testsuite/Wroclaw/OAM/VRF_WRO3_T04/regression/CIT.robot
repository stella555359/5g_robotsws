*** Settings ***
Documentation    This suite provides Test Cases for CIT testing

Resource        ../features/CB006114-A/TestCases/6114_TestCases.robot
Resource        ../features/TLS/TestCases/TLS_certificates.robot
Resource        ../features/CB012204-A-C/CB012204-A/TestCases/CB012204-A.robot
Resource        ../features/5GC001599-G/TestCases/Product_Security_Improvements.robot
Resource        ../features/CB009484/TestCases/CB009484-SR.robot
Resource        ../features/CB009233/TestCases/CB009233_TestCases.robot
Resource        ../features/CB011146/TestCases/CB011146-B_SR.robot

Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/variables/variables.robot
Resource        ../common_resources/swconfig/swconfig.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
[1]CB006114-A_IPSec_defect_handling_between_the_DU_and_RU
    [Tags]    6114
    CB006114-A_IPSec_defect_handling_between_the_DU_and_RU

[1]5GC001599-G_Check_Service_Binding_on_gBN_ABIP
    [Tags]    1599    T02    trunk
    [1]5GC001599-G_Check_Service_Binding_on_gBN_ASIL

[1]CB012204-A_Local_user_accounts_default_passwords_update_suppression_and_enforcement_with_alarm_check
    [Tags]    12204    T03    trunk    25R1_MP
    [1]CB012204-A_Local_user_accounts_default_passwords_update_suppression_and_enforcement_with_alarm_check

[1]CB009484-A_More_Restrictive_Permission_Settings_in_BTS_internal_file_system
    [Tags]    9484    T04    trunk    25R1_MP
    More_Restrictive_Permission_Settings_in_BTS_internal_file_system

[1]CB009233_Services_Supported_Over_WiFi_LMP
    [Tags]        9233
    [Setup]    Test Setup with debug flags
    CB009233_Services_Supported_Over_WiFi_LMP

[1]SECURITY_TLS_and_certificates_operations
    [Tags]   SECURITY
    TLS_operations

[1]CB011146-B_REST_API_commands
    [Tags]    11146    T04    trunk
    CB011146-SR-B_APIGW_Authenticaton

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup
    Set CMP Server Settings         key_pool_type=RSA

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
	Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown

Test Setup with debug flags
    ${fl}=    Create List    0x10040=1    0x1003F=0    0x10031=1    0x3f0044=1
    Add flags from list to swconfig    flags_list=${fl}    reboot_after_uploading=True
    Common Gathering Logs for Test Setup
