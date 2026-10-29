*** Settings ***
Documentation    Suite for Airphone

Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/variables/variables_airphone.robot
Resource        ../common_resources/airphone/airphone.robot
Resource        ../features/CB008254/TestCases/CB008254.robot
Resource        ../features/5GC001599-G/TestCases/Product_Security_Improvements.robot
Resource        ../features/CB006017/TestCases/6017_TestCases.robot
Resource        ../features/CB007672-G/TestCases/7672-G_TestCases.robot
Resource        ../features/CB007672-I/TestCases/7672-I_TestCases.robot
Resource        ../features/CB009484/TestCases/CB009484-SR.robot
Resource        ../features/CB012187/TestCases/CB012187-SR_TestCases.robot
Resource        ../features/TLS/TestCases/TLS_certificates.robot
Resource        ../features/CB012562-A/TestCases/CB012562-A.robot
Resource        ../features/CB011146/TestCases/CB011146-D_SR.robot
Resource        ../features/CB013310/TestCases/CB013310-SR_TestCases.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***
${airphone_config}=    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

*** Test Cases ***

[1]5GC001599-G_Check_Service_Binding_on_gBN_ABIP
    [Tags]
    [1]5GC001599-G_Check_Service_Binding_on_gBN_ASIL

[1]CB010970_CB010265_Differentiator_for_RSA_and_ECDSA_operations_error_code
    [Tags]
    CB008254_Differentiator_for_RSA_and_ECDSA_operations_error_code

[1]CB010971_CB007672-G-SyVe_Firewall_update_new_port_ASOH
    [Tags]
    CB007672-G-SyVe_Firewall_update_new_port

[1]CB010971_CB007672-5G-I-Verifying_DSCP_setting_for_CRL_IPv4_traffic_ASOH
    [Tags]
    CB007672-5G-I-Verifying_DSCP_setting_for_CRL_IPv4_traffic

[1]CB009484-F_Verify_All_Cross_Origin_Policies
    [Tags]
    Verify_All_Cross_Origin_Policies

[1]CB012187-B-SR_BTS_Update_Allowed_lifetime_or_Allowed_Idle_period_by_existing_value_for_usable_BTS_local_user_accounts
    [Tags]
    BTS_Update_Allowed_lifetime_or_Allowed_Idle_period_by_existing_value_for_usable_BTS_local_user_accounts

[1]CB012187-B-SR_BTS_Local_user_parameters_shall_be_synchronised_between_the_installed_SWs
    [Tags]
    BTS_Local_user_parameters_shall_be_synchronised_between_the_installed_SWs

[1]TLS_operations
    [Tags]
    TLS_operations

CB012562-A_08_Subject_Name_SN_and_Subject_Alternative_Names_SANs_autocompletion_on_Target_SW_After_Reset
    [Tags]
    CB012562-A_08_Subject_Name_(SN)_and_Subject_Alternative_Names_(SANs)_autocompletion_on_Target_SW_After_Reset

[1]CB010971-C_CB012562-A_06_Subject_Alternative_Names_(SANs)_depends_on_NumberOfSAN_parameter_expired_certificate_WebEM_and_NMS_ASOH
    [Tags]
    CB012562-A_06_Subject_Alternative_Names_(SANs)_depends_on_NumberOfSAN_parameter_expired_certificate_WebEM_and_NMS

[1]CB013310-SR-A_Access_to_SCF_config_and_certs_info_as_BTS_Application_user
    [Tags]
    CB013310-SR_Access_to_SCF_config_and_certs_info_as_BTS_Application_user

[1]CB012187-B-SR_Stressful_robustness_test_for_WebEM_CLI
    [Tags]
    Stressful_robustness_test_for_WebEM_CLI

*** Keywords ***
Suite Setup
    Add all required IP addresses for airphone
    Install Configuration File  ${airphone_config}
    Configure X2 Link
    Wait Until Keyword Succeeds    15min    30sec    Check If All Cells Are OnAir
    CB006017 Setup
    Set CMP Server Settings         key_pool_type=RSA
    Common Gathering Logs for Common Suite Setup

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
	Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}

Test Setup
    Add Multiple Alarms to Watchdog List   7107    7305
    Airphone Gathering Logs for Test Setup

Test Teardown
    Run Keyword and Ignore Error    Install Configuration File    ${airphone_config}
    Run Keyword and Ignore Error    Configure X2 Link
    Wait Until Keyword Succeeds     15min    30sec    Check If All Cells Are OnAir
    Airphone Gathering Logs for Test Teardown
