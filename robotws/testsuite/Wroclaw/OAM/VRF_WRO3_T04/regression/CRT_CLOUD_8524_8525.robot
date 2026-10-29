*** Settings ***
Documentation    Suite for testing 10265 on Cloud
...              Authors:    Patryk Tatarek, Jagoda Kubacka
...              Contact:    patryk.tatarek@nokia.com, jagoda.kubacka@nokia.com

Resource        ../features/CB010265/TestCases/CB010265-AC.robot
Resource        ../features/CB010265/TestCases/CB010265-B.robot
Resource        ../features/CB009068/TestCases/CB009068-CR.robot
Resource        ../features/CB012187/TestCases/CB012187-CR_TestCases.robot
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

Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***
[1]CB009068-B01_vDU_vCU_adding_blocking_F1-C_peers
    [Tags]     vDU    8524/8525
    Adding_blocking_F1-C_peers
    [Teardown]    Test Teardown    hw_type=vDU

[1]CB009068-B02_ vCU_vDU_allowing_traffic_from_peer_GTP-U_path_endpoints_(F1-U)
    [Tags]     vDU    8524/8525
    Allowing_traffic_from_peer_GTP-U_path_endpoints_(F1-U)
    [Teardown]    Test Teardown    hw_type=vDU

[1]CB009068-A06_Adding_Blocking_access_of_O&M_controlled_peer_CPlane_vCU_via_Netact
    [Tags]     vCU
    Adding_Blocking_access_of_OM_controlled_peer_CPlane_vCU_via_Netact
    [Teardown]    Test Teardown    hw_type=vCU

[1]CB009068-A07_Change_of_CP_IP_address_of_O&M_controlled_peer_CPlane_vCU
    [Tags]     vCU
    Change_of_CP_IP_address_of_OM_controlled_peer_CPlane_vCU
    [Teardown]    Test Teardown    hw_type=vCU

*** Keywords ***
Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    [Arguments]                   ${hw_type}
    Run Keyword if Test Failed    logs.Common Gathering Logs for Test Teardown
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
