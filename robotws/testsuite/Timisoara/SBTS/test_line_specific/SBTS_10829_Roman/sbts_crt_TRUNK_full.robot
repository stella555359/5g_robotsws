*** Settings ***
Documentation  Tests for ASOG

Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLG_10829_2ASIM_1ABIO_1ABIA_2ABIP_3AHLOB_3AHFIG_3AEHC    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.robot
Resource          ../../LOGS/LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.robot
Resource          ../../LOGS/LOGS__BTS_enable_log_dedicated_storage_device_during_startup.robot
Resource          ../../LOGS/LOGS__Snapshot.robot
Resource          ../../LOGS/LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.robot
Resource          ../../LOGS/LOGS__CB008390_Snapshot_startup_Log_ERROR_prints.robot
Resource          ../../LOGS/LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API.robot
Resource          ../../LOGS/LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition_new.robot
Resource          ../../LOGS/LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core.robot
Resource
...	   ../../LOGS/LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours.robot
Resource       ../../LOGS/LOGS__CNI-90327_AaTrblServer_configuration_formalization.robot
Resource       ../../LOGS/LOGS__CB009077_ERM6_RU_check.robot
Resource       ../../LOGS/LOGS__CNI-106835_01_Check_behavior_after_crashes_at_start-up_with_default_value.robot
Resource       ../../LOGS/LOGS__CB010699-A_Collect_Remote_SCREL.robot
Resource          ../../LOGS/LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.robot
Resource          ../../LOGS/LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files.robot
Resource          ../../LOGS/LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service.robot
Resource          ../../LOGS/LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs.robot


Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...  /home/ute/testline_configuration/10_18_UTESRANCLOUD1829/node1/SCF_01_TRUNK.xml

${Snap_by_fault_to_LSS_max5_in_24hPATH}=    SEPARATOR=
...  LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours

${NETACT_LAB}    &{srnclab1047}

*** Test Cases ***
LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs
    [Setup]    Run Keywords    LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs
    ...    AND    Set Library Search Order    LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs
    [Timeout]    14400
    TC__LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs
    [Teardown]    Run Keywords    LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs.TC Teardown
    ...    AND    Restore Resource Search Order

LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    [Setup]    Run Keywords    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    ...    AND    Set Library Search Order    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    [Timeout]    14400
    TC__LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    [Teardown]    Run Keywords    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files.TC Teardown
    ...    AND    Restore Resource Search Order

LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service
    [Setup]    Run Keywords    LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service
    ...    AND    Set Library Search Order    LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service
    [Timeout]    14400
    TC__LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service
    [Teardown]    Run Keywords    LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service.TC Teardown
    ...    AND    Restore Resource Search Order

LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    [Setup]    Run Keywords    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    ...    AND    Set Library Search Order    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    [Timeout]    14400
    TC__LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    [Teardown]    Run Keywords    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Setup]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    ...    AND    Set Library Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Timeout]    14400
    TC__LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Teardown]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Teardown
    ...    AND    Restore Resource Search Order

LOGS_CB008390_BTS_enable_log_dedicated_storage_device_during startup
    [Setup]    Run Keywords    LOGS__BTS_enable_log_dedicated_storage_device_during_startup.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__BTS_enable_log_dedicated_storage_device_during_startup
    ...    AND    Set Library Search Order    LOGS__BTS_enable_log_dedicated_storage_device_during_startup
    [Timeout]    14400
    TC__LOGS__BTS_enable_log_dedicated_storage_device_during_startup
    [Teardown]    Run Keywords    LOGS__BTS_enable_log_dedicated_storage_device_during_startup.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB007425_LOGS__Snapshot_on-hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Setup]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    ...    AND    Set Library Search Order    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Timeout]    14400
    TC__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Teardown]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    Set Library Search Order    LOGS__Snapshot
    [Timeout]    21600
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    2700
    ...    AND    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    [Timeout]    28400
    TC__LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    [Teardown]    Run Keywords    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.TC Teardown
    ...    AND    Restore Resource Search Order

[1]LOGS_CB008390_Snapshot_startup_Log_ERROR_prints
    [Setup]    Run Keywords    LOGS__CB008390_Snapshot_startup_Log_ERROR_prints.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008390_Snapshot_startup_Log_ERROR_prints
    ...    AND    Set Library Search Order    LOGS__CB008390_Snapshot_startup_Log_ERROR_prints
    [Timeout]    14400
    TC__LOGS__CB008390_Snapshot_startup_Log_ERROR_prints
    [Teardown]    Run Keywords    LOGS__CB008390_Snapshot_startup_Log_ERROR_prints.TC Teardown
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
    ...    AND    Set Test Variable    ${TRUNK_VERSION}    SBTS24R3
    ...    AND    Set Library Search Order
    ...    LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition_new
    [Timeout]    14400
    TC__LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition_new
    [Teardown]    Run Keywords
    ...    LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition_new.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core
    [Setup]    Run Keywords    LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core
    ...    AND    Set Library Search Order    LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core
    [Timeout]    14400
    TC__LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core
    [Teardown]    Run Keywords    LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours
    [Setup]    Run Keywords    ${Snap_by_fault_to_LSS_max5_in_24hPATH}.TC Setup
    ...    AND    Modify Resource Search Order    ${Snap_by_fault_to_LSS_max5_in_24hPATH}
    ...    AND    Set Library Search Order    ${Snap_by_fault_to_LSS_max5_in_24hPATH}
    [Timeout]    14400
    TC__LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours
    [Teardown]    Run Keywords    ${Snap_by_fault_to_LSS_max5_in_24hPATH}.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Setup]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    ...    AND    Set Library Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Timeout]    14400
    TC__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Teardown]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB009077_ERM6_RU_check
    [Setup]    Run Keywords    LOGS__CB009077_ERM6_RU_check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB009077_ERM6_RU_check
    ...    AND    Set Library Search Order    LOGS__CB009077_ERM6_RU_check
    [Timeout]    14400
    TC__LOGS__CB009077_ERM6_RU_check
    [Teardown]    Run Keywords    LOGS__CB009077_ERM6_RU_check.TC Teardown
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
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
