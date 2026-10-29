*** Settings ***
Documentation    Suite for TL280

Resource        ../features/CB011146/TestCases/CB011146-D_SR.robot
Resource        ../features/CB009482/TestCases/CB009482.robot
Resource        ../features/CB013360/TestCases/CB013360-SR_TestCases.robot
Resource        ../features/CB013310/TestCases/CB013310-SR_TestCases.robot
Resource        ../features/CB010214/TestCases/CB010214-C-SR.robot

Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/mantaray/mantaray.robot
Resource        ../common_resources/certificates/certificates.robot
Resource        ../common_resources/applications_running_with_root/common_keywords.robot
Resource        ../common_resources/variables/variables.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Variables ***
${NetAct_name}=     srnclab2010

*** Test Cases ***
[1]CB009482-B_B1_SR_TC_04_site_reset_power_break_LDAP_CNUM_Syslog_RTPM_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB
    [Tags]  9482    trunk
    CB009482-B_TC_04_CNUM_Syslog_RTPM_Servers_Report_TLS_failure_with_an_Additional_Text_Field

[1]CB013360_SR_A_sec_events_for_local_user_operations_complex_test
    [Setup]    Run Keywords    Test Setup NMS
    ...        AND             Setup Graylog     ${integrated_lab}
    Additional_sec_event_record_logging_users_and_session
    Additional_sec_event_record_local_accounts_operations
    Audit_logging_for_local_account_operations_by_MantaRay
    Collect and check ATL logs A
    [Teardown]    Test Teardown NMS

[1]CB013360_SR_B_certificate_operations_complex_test
    [Setup]    Run Keywords    Test Setup NMS
    ...        AND             Setup Graylog     ${integrated_lab}
    Audit_login_during_manual_CRL_download_failure_and_retry
    Audit_login_during_certificate_enrollment_or_renewal
    Collect and check ATL logs B
    [Teardown]    Test Teardown NMS

[1]CB013310-SR-A_Access_to_SCF_config_and_certs_info_as_BTS_Application_user
    [Tags]  13310    trunk
    CB013310-SR_Access_to_SCF_config_and_certs_info_as_BTS_Application_user

[2]CB011146-D_M2M_user_account_operations
     [Tags]    11146    T06    trunk
     CB011146-SR-D_M2m_user_account_operations

[1]CB011146-D_M2M_user_account_operations
     [Tags]    11146    T06    trunk
     CB011146-SR-D_M2m_user_account_operations

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup
    Change Ethernet Port Security Enabled To True CLASSICAL
    Run Keyword And Ignore Error                  add_headline_to_output_file
    Run Keyword And Continue On Failure           Wait Until BTS Reach Configured Or OnAir State

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
	Run Keyword And Ignore Error                  copy_files_of_nmap_results
	Run Keyword And Ignore Error                  Copy Report Txt File To Output Directory
	Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown

Test Setup NMS
    Common Gathering Logs for Test Setup
    ${integrated_lab}=    Integrate BTS to MantaRay without TLS    PREFERRED_LAB=${NetAct_name}
    Set Test Variable     ${integrated_lab}

Test Teardown NMS
    Deintegrate BTS from MantaRay    LAB_NAME=${integrated_lab}
    Clear Certificates
    Wait until BTS reach Configured or OnAir state
    Common Gathering Logs for Test Teardown
