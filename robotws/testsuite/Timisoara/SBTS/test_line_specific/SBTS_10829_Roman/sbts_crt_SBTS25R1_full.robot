*** Settings ***
Documentation
...     tests branch 10415
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_10829_2ASIM_1ABIO_2ABIP_ABIA_FXDB_AHEGB_AZHL    SBTS25R1
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Snapshot.robot
Resource          ../../LOGS/LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API.robot
Resource          ../../LOGS/LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition_new.robot
Resource
...	   ../../LOGS/LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours.robot
Resource       ../../LOGS/LOGS__CNI-106835_01_Check_behavior_after_crashes_at_start-up_with_default_value.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10829_Roman/commissioning/SCF_01_SBTS25R1.xml

${Snap_by_fault_to_LSS_max5_in_24hPATH}=    SEPARATOR=
...  LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours


${NETACT_LAB}    &{srnclab1027}

*** Test Cases ***
[1]Automated__LOGS__Snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    Set Library Search Order    LOGS__Snapshot
    [Timeout]    14400
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API
    [Setup]    Run Keywords    LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API
    ...    AND    Modify Resource Search Order    LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API
    [Timeout]    14400
    TC__LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API
    [Teardown]    Run Keywords    LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition
    [Setup]    Run Keywords
    ...    LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition_new.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition_new
    ...    AND    Set Test Variable    ${TRUNK_VERSION}    SBTS23R4
    ...    AND    Set Library Search Order
    ...    LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition_new
    [Timeout]    14400
    TC__LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition_new
    [Teardown]    Run Keywords
    ...    LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition_new.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours
    [Setup]    Run Keywords    ${Snap_by_fault_to_LSS_max5_in_24hPATH}.TC Setup
    ...    AND    Modify Resource Search Order    ${Snap_by_fault_to_LSS_max5_in_24hPATH}
    ...    AND    Set Library Search Order    ${Snap_by_fault_to_LSS_max5_in_24hPATH}
    [Timeout]    14400
    TC__LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours
    [Teardown]    Run Keywords    ${Snap_by_fault_to_LSS_max5_in_24hPATH}.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-106835_01_Check_behavior_after_crashes_at_start-up_with_default_value
    [Setup]    Run Keywords    LOGS__CNI-106835_01_Check_behavior_after_crashes_at_start-up_with_default_value.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-106835_01_Check_behavior_after_crashes_at_start-up_with_default_value
    ...    AND    Set Library Search Order    LOGS__CNI-106835_01_Check_behavior_after_crashes_at_start-up_with_default_value
    [Timeout]    14400
    TC__LOGS__CNI-106835_01_Check_behavior_after_crashes_at_start-up_with_default_value
    [Teardown]    Run Keywords    LOGS__CNI-106835_01_Check_behavior_after_crashes_at_start-up_with_default_value.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
