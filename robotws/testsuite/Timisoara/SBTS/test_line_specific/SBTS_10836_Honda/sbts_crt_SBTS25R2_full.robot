*** Settings ***
Documentation  Tests for ASOG
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NL_10836_1ASOG_1AHLOA    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot


Resource          ../../LOGS/LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_NMS_destination.robot
Resource          ../../LOGS/LOGS__Reset_during_the_ongoing_snapshot_procedure.robot
Resource          ../../LOGS/LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit.robot
Resource          ../../LOGS/LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new.robot
Resource          ../../LOGS/LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.robot
Resource          ../../LOGS/LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files.robot
Resource          ../../LOGS/LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service.robot
Resource          ../../LOGS/LOGS__CB010239-C_CP31_active_critical_alarms.robot


#Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}   ${CURDIR}/commissioning/SCF_01_TRUNK.xml
${NETACT_LAB}    &{srnclab1028}

${Snap_by_fault_to_LSS_max5_in_24hPATH}=    SEPARATOR=
...  LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours

*** Test Cases ***
LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    [Setup]    Run Keywords    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    ...    AND    Set Library Search Order    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    [Timeout]    14400
    TC__LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    [Teardown]    Run Keywords    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files.TC Teardown
    ...    AND    Restore Resource Search Order

CB010969_ASOG_CB006483_5G_C_Snapshot_automatically_transferred_to_NMS-default_alarm-when_alarm_is_cancelled
    [Setup]    Run Keywords     Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    2700
    ...    AND    LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_NMS_destination.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_NMS_destination
    ...    AND    Set Library Search Order    LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_NMS_destination
    [Timeout]    14400
    TC__LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_NMS_destination    triggerType=onFaultCancellation
    [Teardown]    Run Keywords    LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_NMS_destination.TC Teardown
    ...    AND    Restore Resource Search Order

CB010969_ASOG_CB006483_5G_C_Reset_during_the_ongoing_snapshot_procedure
    [Setup]    Run Keywords    LOGS__Reset_during_the_ongoing_snapshot_procedure.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Reset_during_the_ongoing_snapshot_procedure
    ...    AND    Set Library Search Order    LOGS__Reset_during_the_ongoing_snapshot_procedure
    [Timeout]    14400
    TC__LOGS__Reset_during_the_ongoing_snapshot_procedure
    [Teardown]    Run Keywords    LOGS__Reset_during_the_ongoing_snapshot_procedure.TC Teardown
    ...    AND    Restore Resource Search Order

CB010969_ASOG_CB006483_5G_D_Max_number_of_snapshots_per_day_exceeded_the_max_limit
    [Setup]    Run Keywords    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit
    ...    AND    Set Library Search Order    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit
    [Timeout]    14400
    TC__LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit
    [Teardown]    Run Keywords    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB010970-C_CB012370-A_03_DC_from_WebEM_CLI_for_CP13_Available_disk_space_for_runtime_procedure
    [Setup]    Run Keywords    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new
    ...    AND    Set Library Search Order    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new
    [Timeout]    14400
    TC__LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new
    [Teardown]    Run Keywords    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new.TC Teardown
    ...    AND    Restore Resource Search Order

CB010239-C_08_Full_diagnostic_check_and_diagnostic_history_verification_via_WebEM_remote_tool
    [Setup]    Run Keywords    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    ...    AND    Set Library Search Order    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    [Timeout]    14400
    TC__LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    [Teardown]    Run Keywords    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.TC Teardown
    ...    AND    Restore Resource Search Order

CB010239-C_01_CP31_active_critical_alarms
    [Setup]    Run Keywords    LOGS__CB010239-C_CP31_active_critical_alarms.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB010239-C_CP31_active_critical_alarms
    ...    AND    Modify Resource Search Order    LOGS__CB010239-C_CP31_active_critical_alarms
    [Timeout]    14400
    TC__LOGS__CB010239-C_CP31_active_critical_alarms
    [Teardown]    Run Keywords    LOGS__CB010239-C_CP31_active_critical_alarms.TC Teardown

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
