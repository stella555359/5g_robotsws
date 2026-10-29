*** Settings ***
Documentation    Suite for testing 9857 on Cloud
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Resource        ../features/CB010214/TestCases/CB010214-CR.robot
Resource        ../features/CB010214/TestCases/CB010214-D-CR.robot

Resource        ../../cloud_common_resources/connections/connections.robot
Resource        ../../cloud_common_resources/parameters/parameters.robot
Resource        ../../cloud_common_resources/alarms/alarms.robot
Resource        ../../cloud_common_resources/certificates/certificates.robot
Resource        ../../cloud_common_resources/resets/resets.robot
Resource        ../../cloud_common_resources/logs/logs.robot
Resource        ../../cloud_common_resources/commissioning/commissioning.robot
Resource        ../cloud_common_resources/emssim/emssim_setup.robot
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
[1]CB010214_D_BTS_System_Administrator_login_with_1RW_session_is_authorized_vCU
    [Tags]   vCU
    CB010214_D_BTS_System_Administrator_login_with_1RW_session_is_authorized_vCU

[1]CB010214_E_Change_btsEMRestrictAccSession_for_local_users_vDU
    [Tags]   vDU
    CB010214_E_Change_btsEMRestrictAccSession_for_local_users_vDU

[1]CB010214_D_B_Use_dcuser_for_DCAP_vCU
    [Tags]   vCU
    CB010214_D_B_Use_dcuser_for_DCAP_vCU

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
