*** Settings ***
Documentation    Suite for testing 12224 and 13483 on Cloud
...              Authors:   Klaudyna Piechocka
...              Contact:    klaudyna.piechocka@nokia.com

Resource        ../features/5GC001719/TestCases/5GC001719-CR.robot
Resource        ../features/CB011107/TestCases/CB011107-CR.robot
Resource        ../../cloud_common_resources/connections/connections.robot
Resource        ../../cloud_common_resources/parameters/parameters.robot
Resource        ../../cloud_common_resources/alarms/alarms.robot
Resource        ../../cloud_common_resources/certificates/certificates.robot
Resource        ../../cloud_common_resources/resets/resets.robot
Resource        ../../cloud_common_resources/logs/logs.robot
Resource        ../cloud_common_resources/dcap/dcap.robot
Resource        ../cloud_common_resources/mantaray/mantaray.robot
Resource        ../features/CB009484/TestCases/CB009484-CR.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot

Library         String
Library         SSHLibrary
Library         Collections
Library         OperatingSystem

Suite Teardown   Suite Teardown

*** Variables ***
${NetAct_name}=    srnclab2010

*** Test Cases ***
5GC001719_A_Cloud_Unforced_Switchover_To_Standby_CNF_By_WebEM_SA_Without_Ipsec
    [Tags]    vCU
    Cloud_Unforced_Switchover_To_Standby_CNF_By_WebEM_SA_Without_Ipsec

5GC001719_D_CLoud_Modification_Common_And_Site_Specific_Parameters_SCF_Sync_Via_CNF_WebEM_SA_Ipsec
    [Tags]    vCU
    CLoud_Modification_Common_And_Site_Specific_Parameters_SCF_Sync_Via_CNF_WebEM_SA_Ipsec

CB011107_Change_parameter_in_secondary_active_vCU2_data_synchronization_via_WebEM_and_UnForced_switchover
    [Tags]    vCU
    Change_parameter_in_secondary_active_vCU2_data_synchronization_via_WebEM_and_UnForced_switchover

CB011107_Change_parameter_in_primary_active_vCU1_data_synchronization_via_MantaRay_and_UnForced_switchover
    [Tags]     vCU
    [Setup]    Wait Until Keyword Succeeds     5x    1min    Test Setup NMS    vCU
    Change_parameter_in_primary_active_vCU1_data_synchronization_via_MantaRay_and_UnForced_switchover
    [Teardown]    Test Teardown NMS    vCU

CB011107_Manual_IP_Destination_Reachability_Test_via_WebEM
    [Tags]    vCU
    Manual_IP_Destination_Reachability_Test_via_WebEM

[1]CB009484-E_#01_Mutual authentication support for geo-resiliency connection
    [Tags]    vCU
    Mutual_authentication_support_for_geo-resiliency_connection

[1]CB009484-E_#02_TLS authentication failure for georesiliency connection
    [Tags]    vCU
    TLS_authentication_failure_for_georesiliency_connection

[1]CB009484-E_#02_OAM-ext_reboot_Unforseen_Robustness
    [Tags]    vCU
    OAM-ext_reboot_Unforseen_Robustness

*** Keywords ***
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
    ${NMS_LAB}=           Integrate Cloud BTS with NMS Lab without TLS    hw_type=${hw}
    Set Suite Variable    ${NMS_LAB}

Test Teardown NMS
    [Arguments]    ${hw}
    Deintegrate Cloud BTS from NMS Lab    LAB_NAME=${NMS_LAB}    hw_type=${hw}
