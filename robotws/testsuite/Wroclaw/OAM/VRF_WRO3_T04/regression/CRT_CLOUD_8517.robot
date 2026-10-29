*** Settings ***
Documentation    Suite for testing 9857 on Cloud
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Resource        ../features/CB013483/TestCases/CB013483_cloud.robot
Resource        ../features/CB009857/TestCases/CB009857.robot
Resource        ../features/CB010214/TestCases/CB010214-CR.robot
Resource        ../features/CB012442/TestCases/CB012442-CR.robot
Resource        ../features/CB009484/TestCases/CB009484-CR.robot
Resource        ../features/CB012204-A-C/CB012204-C/TestCases/CB012204-C_TestCases.robot
Resource        ../features/CB010214/TestCases/CB010214-CR.robot
Resource        ../features/CB010214/TestCases/CB010214-D-CR.robot
Resource        ../features/CB012224/TestCases/CB012224_cloud.robot
Resource        ../features/CB010506/TestCases/CB010506.robot
Resource        ../features/CB011146/TestCases/CB011146-B_CR.robot
Resource        ../features/CB011146/TestCases/CB011146-D_CR.robot
Resource        ../features/CB013310/TestCases/CB013310-CR_TestCases.robot
Resource        ../features/CB012187/TestCases/CB012187-CR_TestCases.robot

Resource        ../../cloud_common_resources/connections/connections.robot
Resource        ../../cloud_common_resources/parameters/parameters.robot
Resource        ../../cloud_common_resources/alarms/alarms.robot
Resource        ../../cloud_common_resources/certificates/certificates.robot
Resource        ../../cloud_common_resources/resets/resets.robot
Resource        ../../cloud_common_resources/logs/logs.robot
Resource        ../../cloud_common_resources/commissioning/commissioning.robot
Resource        ../cloud_common_resources/emssim/emssim_setup.robot
Resource        ../cloud_common_resources/dcap/dcap.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot

Library         String
Library         SSHLibrary
Library         Collections
Library         OperatingSystem

Suite Setup      Suite Setup
Suite Teardown   Suite Teardown

Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***
[1]CB009857-D_Operator_4K_Certificate_initial_enrollment_CMP_init_and_KUR_failure-vCU
    [Tags]    vCU
    Operator_4K_Certificate_initial_enrollment_CMP_init_and_KUR_failure-vCU

[1]CB012442-B_FeVe_05_usage_of_Nokia_BTS_vendor_SW_certificate_for_WebEm_on_vCU
    [Tags]    vCU
    CB012442-B_FeVe_05_usage_of_Nokia_BTS_vendor_SW_certificate_for_WebEm_on_vCU

[1]CB012442-B_FeVe_05_usage_of_Nokia_BTS_vendor_SW_certificate_for_WebEm_on_vDU
    [Tags]    vDU
    CB012442-B_FeVe_05_usage_of_Nokia_BTS_vendor_SW_certificate_for_WebEm_on_vDU

[1]CB009484-G_Verify_All_Cross_Origin_Policies_Cloud_vCU
    [Tags]     vCU
    Verify_All_Cross_Origin_Policies_Cloud_vCU

[1]CB009484-G_Verify_All_Cross_Origin_Policies_Cloud_vDU
    [Tags]     vDU
    Verify_All_Cross_Origin_Policies_Cloud_vDU

[1]CB012204-C_Wsuser_user_account_default_password_alarm_reporting_vDU_vCU
    [Tags]    vDU_vCU
    CB012204-C_Wsuser_user_account_default_password_alarm_reporting
#
[1]CB012204-C_account_management_and_synchronization_to_RAN_NIC
    [Tags]    vDU_vCU
    CB012204-C_account_management_and_synchronization_to_RAN_NIC

[1]CB012224-B_#01_Role_activation_and_deactivation_time_update_vCU_vDU
    [Tags]   vCU_vDU
    CB012224-B_#01_Role_activation_and_deactivation_time_update_vDU

[1]CB012224-B_#03_Unsuccessful_local_user_accounts_status_report_vCU_vDU
    [Tags]   vCU_vDU
    CB012224-B_#03_Unsuccessful_local_user_accounts_status_report_vCU

[1]CB010214-D-REST_APIs_for_dcuser_vCU_vDU
    [Tags]   vCU_vDU
    CB010214-D-REST_APIs_for_dcuser_vCU_vDU

[1]CB010506_B_T03_Firewall_Mplane_Rate_Limit_Counter_TCP_Packets_Port_443_8443_8080_vDU
    [Tags]    vDU
    CB010506_B_T03_Firewall_Mplane_Rate_Limit_Counter_TCP_Packets_Port_443_8443_8080_vDU

[1]CB011146-D_Supported_ciphers_check_with_Logging_about_failed_TLS_connections
    [Tags]   vDU_vCU
    CB011146-CR-D_Supported_ciphers_check_with_Logging_about_failed_TLS_connections

[1]CB011146-B_REST_API_commands
    [Tags]   vDU_vCU
    CB011146-CR-B_APIGW_Authenticaton

[1]CB013310-CR-A_Access_to_SCF_config_and_certs_info_as_BTS_Application_user
    [Tags]    vDU_vCU
    CB013310-CR_Access_to_SCF_config_and_certs_info_as_BTS_Application_user_vCU_vDU

[1]CB012187-B-CR_Stressful_robustness_test_for_REST_API_vDU
    [Tags]    vDU
    Stressful_robustness_test_for_REST_API_vDU

*** Keywords ***
Suite Setup
    Run Keyword and Ignore Error    Create Object with Single Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP    param_value=${primary_param_value}     hw_type=vDU
    Run Keyword and Ignore Error    Create Object with Single Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_name=primaryCRLDP    param_value=${primary_param_value}     hw_type=vCU

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Run Keyword if Test Failed    logs.Common Gathering Logs for Test Teardown
    Run Keyword if Test Failed    Perform Reset and Wait for Expected State    state=onAir    hw_type=vCU
    Run Keyword if Test Failed    Restore Default Certificates on BTS    hw_type=vCU
    Run Keyword if Test Failed    Delete All Certificates    hw_type=vCU
    Run Keyword if Test Failed    Perform Reset and Wait for Expected State    state=onAir    hw_type=vDU
    Run Keyword if Test Failed    Restore Default Certificates on BTS    hw_type=vDU
    Run Keyword if Test Failed    Delete All Certificates    hw_type=vDU

Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...                             team_name=PZ3WRO4
    ...                             input_logs_dir=${None}
    ...                             remote_host_vDU=${LMP_VDU_IP}
    ...                             remote_host_vCU=${LMP_VCU_IP}
    ...                             mandatory_log_types=__snapshot_vDU__,__snapshot_vCU__
    ...                             collect_NOP=${True}
