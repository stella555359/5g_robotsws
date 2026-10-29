*** Settings ***
Documentation    Suite for testing 9857 on Cloud
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Resource        ../features/CB013483/TestCases/CB013483_cloud.robot
Resource        ../features/CB011146/TestCases/CB011146-D_CR.robot
Resource        ../features/CB009482-CR/TestCases/CB009482-CR-ARP.robot
Resource        ../features/CB009482-CR/TestCases/CB009482-B-CR.robot
Resource        ../features/CB013360/TestCases/CB013360-CR_TestCases.robot

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

Suite Teardown   Suite Teardown

Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***
[1]CB013483-CR-C_03_ITSAR_Compliance_for_India_Deployment_vCU_via_NMS
    [Tags]    vCU
    CB013483-CR-C_03_ITSAR_Compliance_for_India_Deployment_vCU_via_NMS

[1]CB011146-D_M2M_user_account_operations
    [Tags]    vDU_vCU
    CB011146-CR-D_M2m_user_account_operations

[1]CB009482-E-CR_ARP_counters_harmonization_on_CRAN_M51328C17_M51328C0_vDU
    CB009482-X_Cloud_Rate_limit_for_ARP_packets-ipRmDropPcktsRtLimARP_vDU    vlan761

[1]CB009482-B_B1_CR_TC_04_pod_removing_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB
    CB09482-B_B1_CR_TC_04_pod_removing_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB

[1]CB009482-B_B1_CR_TC_03_site_reset_power_break_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB_vDU
    CB009482-B_B1_CR_TC_03_site_reset_power_break_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB    vDU

CB013360_CR_B_Audit_login_during_certificate_related_operations_complex_test_vCU
    [Setup]    Run Keywords    Test Setup NMS    vCU
    ...        AND             Setup Graylog     ${NMS_LAB}
    Audit_login_during_manual_CRL_download_failure_and_retry_vCU
    Audit_login_during_certificate_enrollment_or_renewal_vCU
    Collect and check ATL logs B
    [Teardown]    Test Teardown NMS    vCU

*** Keywords ***
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

Test Setup NMS
    [Arguments]    ${hw}
    ${NMS_LAB}=    Integrate Cloud BTS with NMS Lab without TLS
    ...            preferred_lab=${lab_with_atl}    hw_type=${hw}
    Set Suite Variable    ${NMS_LAB}
    [Return]    ${NMS_LAB}

Test Teardown NMS
    [Arguments]    ${hw}
    Run Keyword if Test Failed    Perform Reset and Wait for Expected State    state=onAir    hw_type=${hw}
    Run Keyword if Test Failed    Restore Default Certificates on BTS    hw_type=${hw}
    Deintegrate Cloud BTS from NMS Lab
    ...    LAB_NAME=${NMS_LAB}
    ...    hw_type=${hw}
