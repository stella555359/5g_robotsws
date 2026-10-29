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
Resource        ../features/CB009482-CR/TestCases/CB009482-B-CR.robot
Resource        ../features/CB009482-CR/TestCases/CB009482-CR-ARP.robot


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
[1]CB012204-C_account_management_and_synchronization_to_RAN_NIC
    [Tags]    vDU_vCU
    CB012204-C_account_management_and_synchronization_to_RAN_NIC

[1]CB013483-CR-C_12_Termination_of_Idle_WebEM_Session_for_vDU-Interaction_between_JWT_Expiry_Timer_and_WebEM_Session_Logout_Timer
    [Tags]    vDU
    CB013483-CR-C_12_Termination_of_Idle_WebEM_Session_for_vDU-Interaction_between_JWT_Expiry_Timer_and_WebEM_Session_Logout_Timer

[1]CB013483-CR-C_03_ITSAR_Compliance_for_India_Deployment_vCU_via_NMS
    [Tags]    vCU
    CB013483-CR-C_03_ITSAR_Compliance_for_India_Deployment_vCU_via_NMS

[1]CB013483-CR-C_07_ITSAR_Compliance_for_non-India_Deployment_vCU_via_NMS
    [Tags]    vCU
    CB013483-CR-C_07_ITSAR_Compliance_for_non-India_Deployment_vCU_via_NMS

[1]CB011146-D_M2M_user_account_operations
    [Tags]    vDU_vCU
    CB011146-CR-D_M2m_user_account_operations

[1]CB009482-B_B1_CR_TC_04_pod_removing_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB
   [Tags]  vDU_vCU
   CB09482-B_B1_CR_TC_04_pod_removing_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB

[1]CB009482-B_B1_CR_TC_03_site_reset_power_break_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB_vCU
    [Tags]    vCU
    CB009482-B_B1_CR_TC_03_site_reset_power_break_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB    vCU

[1]CB009482-B_B1_CR_TC_03_site_reset_power_break_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB_vDU
    [Tags]    vDU
    CB009482-B_B1_CR_TC_03_site_reset_power_break_LDAP_CNUM_Syslog_servers_Report_TLS_failure_with_an_Additional_Text_field_in_the_gNB    vDU

[1]CB009482-E-CR_ARP_counters_harmonization_on_CRAN_M51328C17_M51328C0_vDU
    CB009482-X_Cloud_Rate_limit_for_ARP_packets-ipRmDropPcktsRtLimARP_vDU    vlan761

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
