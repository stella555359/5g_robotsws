*** Settings ***
Documentation  Tests for ASOH
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NL_10828_1ASOH_1AHCA    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot

Resource          ../../LOGS/LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit.robot
Resource          ../../LOGS/LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.robot
Resource          ../../LOGS/LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_LSS_destination.robot
Resource          ../../LOGS/LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_with_delay.robot
Resource          ../../LOGS/LOGS__Reset_during_the_ongoing_snapshot_procedure.robot
Resource          ../../LOGS/LOGS__Triggers_persistent_over_resets.robot
Resource          ../../LOGS/LOGS__Default_fault_triggers.robot
Resource          ../../LOGS/LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.robot
Resource          ../../LOGS/LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new.robot
Resource          ../../LOGS/LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new.robot
Resource          ../../LOGS/LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}  ${CURDIR}/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab3008}

*** Test Cases ***
CNI-93026_03_Logs_present_in_new_SSD_location
    [Tags]  ReTest
    [Setup]    Run Keywords    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    ...    AND    Set Library Search Order    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    [Timeout]    14400
    TC__LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    [Teardown]    Run Keywords    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.TC Teardown
    ...    AND    Restore Resource Search Order

CB010969_ASOH_CB006483_5G_C_Reset_during_the_ongoing_snapshot_procedure
    [Setup]    Run Keywords    LOGS__Reset_during_the_ongoing_snapshot_procedure.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Reset_during_the_ongoing_snapshot_procedure
    ...    AND    Set Library Search Order    LOGS__Reset_during_the_ongoing_snapshot_procedure
    [Timeout]    14400
    TC__LOGS__Reset_during_the_ongoing_snapshot_procedure
    [Teardown]    Run Keywords    LOGS__Reset_during_the_ongoing_snapshot_procedure.TC Teardown
    ...    AND    Restore Resource Search Order

CB010969_ASOH_CB006483_5G_C_Triggers_persistent_over_resets
    [Setup]    Run Keywords    LOGS__Triggers_persistent_over_resets.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Triggers_persistent_over_resets
    ...    AND    Set Library Search Order    LOGS__Triggers_persistent_over_resets
    [Timeout]    14400
    TC__LOGS__Triggers_persistent_over_resets
    [Teardown]    Run Keywords    LOGS__Triggers_persistent_over_resets.TC Teardown
    ...    AND    Restore Resource Search Order

CB010969_ASOH_CB006483_5G_D_Max_number_of_snapshots_per_day_exceeded_the_max_limit
    [Setup]    Run Keywords    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit
    ...    AND    Set Library Search Order    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit
    [Timeout]    14400
    TC__LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit
    [Teardown]    Run Keywords    LOGS__Max_number_of_snapshots_per_day_exceeded_the_max_limit.TC Teardown
    ...    AND    Restore Resource Search Order

CB010969_ASOH_CB006483_5G_C_Parameter_snapshotUploadDelayForFault6450
    [Setup]    Run Keywords    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_with_delay.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_with_delay
    ...    AND    Set Library Search Order    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_with_delay
    [Timeout]    14400
    TC__LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_with_delay
    [Teardown]    Run Keywords    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_with_delay.TC Teardown
    ...    AND    Restore Resource Search Order

CB010969_ASOH_CB006483_5G_E_The same trigger for 5 snapshots within 24 hours
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    2700
    ...    AND    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    [Timeout]    21600
    TC__LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    [Teardown]    Run Keywords    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.TC Teardown
    ...    AND    Restore Resource Search Order

CB010969_ASOH_CB006483_5G_C_Default_fault_triggers
    [Setup]    Run Keywords    LOGS__Default_fault_triggers.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Default_fault_triggers
    ...    AND    Set Library Search Order    LOGS__Default_fault_triggers
    [Timeout]    14400
    TC__LOGS__Default_fault_triggers
    [Teardown]    Run Keywords    LOGS__Default_fault_triggers.TC Teardown
    ...    AND    Restore Resource Search Order

CB010969_ASOH_CB006483_5G_A_Configure_LSS_server_WebEM_GUI
    [Setup]    Run Keywords    LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_LSS_destination.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_LSS_destination
    ...    AND    Set Library Search Order    LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_LSS_destination
    [Timeout]    14400
    TC__LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_LSS_destination
    [Teardown]    Run Keywords    LOGS__Snapshot_triggered_by_BTS_fault_raised_collected_to_LSS_destination.TC Teardown
    ...    AND    Restore Resource Search Order

CB010239-C_08_Full_diagnostic_check_and_diagnostic_history_verification_via_WebEM_remote_tool
    [Setup]    Run Keywords    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    ...    AND    Set Library Search Order    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    [Timeout]    14400
    TC__LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification
    [Teardown]    Run Keywords    LOGS__CB010239-C_Full_DC_and_diagnostic_report_verification.TC Teardown
    ...    AND    Restore Resource Search Order

CB010239-A_04_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition
    [Setup]    Run Keywords  LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new.TC Setup
    ...  AND  Modify Resource Search Order
    ...    LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new
    ...  AND  Set Library Search Order
    ...    LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new
    [Timeout]  14400
    TC__LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new
    [Teardown]
    ...  Run Keywords  LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new.TC Teardown
    ...    AND  Restore Resource Search Order

[1]CB010970-C_CB012370-A_03_DC_from_WebEM_CLI_for_CP13_Available_disk_space_for_runtime_procedure
    [Setup]    Run Keywords    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new
    ...    AND    Set Library Search Order    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new
    [Timeout]    14400
    TC__LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new
    [Teardown]    Run Keywords    LOGS__CB012370-A_DC_from_WebEM_Remote_Tool_for_CP13_Available_disc_space_for_runtime_procedure_new.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
