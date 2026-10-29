*** Settings ***
Documentation    Suite for testing 10265 on Cloud
...              Authors:    Patryk Tatarek, Jagoda Kubacka
...              Contact:    patryk.tatarek@nokia.com, jagoda.kubacka@nokia.com

Resource        ../features/CB009068/TestCases/CB009068-CR.robot
Resource        ../features/CB013360/TestCases/CB013360-CR_TestCases.robot
Resource        ../features/CB009482-CR/TestCases/CB009482-B-CR.robot
Resource        ../../cloud_common_resources/connections/connections.robot
Resource        ../../cloud_common_resources/parameters/parameters.robot
Resource        ../../cloud_common_resources/alarms/alarms.robot
Resource        ../../cloud_common_resources/certificates/certificates.robot
Resource        ../../cloud_common_resources/accounts/accounts.robot
Resource        ../../cloud_common_resources/resets/resets.robot
Resource        ../../cloud_common_resources/logs/logs.robot
Resource        ../cloud_common_resources/dcap/dcap.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot

Library         String
Library         SSHLibrary
Library         Collections
Library         OperatingSystem

Suite Teardown   Suite Teardown

*** Test Cases ***
[1][1]CB009068-B-B3-High_Availability_support_for_firewall_operations
    [Tags]     vCU    8523
    High_Availability_support_for_firewall_operations
    [Teardown]    Test Teardown    hw_type=vCU

CB013360_CR_A_sec_events_for_local_user_operations_complex_test_vDU
    [Setup]    Run Keywords    Test Setup NMS    vDU
    ...        AND             Setup Graylog     ${NMS_LAB}
    Additional_sec_event_record_local_accounts_operations_vDU
    Collect and check ATL logs A
    [Teardown]    Test Teardown NMS    vDU

CB013360_CR_B_Audit_login_during_certificate_related_operations_complex_test_vCU
    [Setup]    Run Keywords    Test Setup NMS    vCU
    ...        AND             Setup Graylog     ${NMS_LAB}
    Audit_login_during_manual_CRL_download_failure_and_retry_vCU
    Audit_login_during_certificate_enrollment_or_renewal_vCU
    Collect and check ATL logs B
    [Teardown]    Test Teardown NMS    vCU

CB09482-B_B1_CR_TC_04_pod_removing_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB
    CB09482-B_B1_CR_TC_04_pod_removing_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB

CB009482-B_B1_CR_TC_03_site_reset_power_break_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB
    CB009482-B_B1_CR_TC_03_site_reset_power_break_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB

*** Keywords ***
Test Teardown
    [Arguments]                   ${hw_type}
    Run Keyword if Test Failed    Perform Reset and Wait for Expected State    state=onAir    hw_type=${hw_type}
    Run Keyword if Test Failed    Restore Default Certificates on BTS    hw_type=${hw_type}
    Run Keyword if Test Failed    Delete All Certificates    hw_type=${hw_type}

Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...                             team_name=PZ3WRO4
    ...                             input_logs_dir=${None}
    ...                             remote_host_vDU=${LMP_VDU_IP}
    ...                             remote_host_vCU=${LMP_VCU_IP}
    ...                             mandatory_log_types=__snapshot_vDU__,__snapshot_vCU__
    ...                             collect_NOP=${True}

Test Setup NMS
    [Arguments]    ${hw}
    ${NMS_LAB}=    Integrate Cloud BTS with NMS Lab without TLS
    ...            preferred_lab=${lab_with_atl}    hw_type=${hw}
    Set Suite Variable    ${NMS_LAB}
    [Return]    ${NMS_LAB}

Test Teardown NMS
    [Arguments]    ${hw}
    Deintegrate Cloud BTS from NMS Lab
    ...    LAB_NAME=${NMS_LAB}
    ...    hw_type=${hw}
