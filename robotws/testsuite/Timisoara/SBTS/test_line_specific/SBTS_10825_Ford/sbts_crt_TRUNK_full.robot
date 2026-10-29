*** Settings ***
Documentation  Tests on FORD
Force Tags   QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIN_1ABIO_1ASIA_3ABIA_1AHCA_1AHIB_1AHEH_2AHEB_1AHLOA_1FRHC   SBTS00
Library      XML  use_lxml=True
Resource     taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource     ../../LOGS/LOGS__Snapshot_BBOX5_File_Check.robot
Resource     ../../LOGS/LOGS__Technical_logs_are_failed_to_be_collected_from_the_secondary_cores_when_communication_between_two_cores_are_broken.robot
Resource     ../../LOGS/LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords.robot
Resource     ../../LOGS/LOGS__CB008626_Fault_Snapshot_Triggers_With_Unsupported_Coverage_Level_Validation.robot
Resource     ../../LOGS/LOGS__Trigger_FID_6929_Wearout_SSD.robot
Resource     ../../LOGS/LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core.robot
Resource     ../../LOGS/LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.robot
Resource     ../../LOGS/LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.robot
Resource     ../../LOGS/LOGS__CB010239-C_SW_integrity_on_active_partition_with_scheduled_DC_new.robot
Resource     ../../LOGS/LOGS__CB010239-A_DC_error_triggered_by_Diagnostic_Schedule_invalid_config_file_and_SWDLreport_missing_new.robot
Resource     ../../LOGS/LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new.robot
Resource     ../../LOGS/LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log.robot
Resource     ../../LOGS/LOGS__CB009077_FRM5_RU_check.robot
Resource     ../../LOGS/LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new.robot
Resource     ../../LOGS/LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.robot
Resource     ../../LOGS/LOGS__CB007615_Reporting_BTS_reset_cause_timestamp_unknown_during_BTS_startup_after_power_outage.robot
Resource     ../../LOGS/LOGS__CB010699_Collect_Local_SCREL.robot
Resource     ../../LOGS/LOGS__sn_pc_check_ASPx_on_MantaRay.robot
Resource     ../../LOGS/LOGS__Remote_Syslog.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10825_Ford/commissioning/SCF_01_TRUNK.xml
${NETACT_LAB}    &{srnclab1047}

*** Test Cases ***
[1]CB013694_check_ASPx_on_MantaRay
    [Setup]    Run Keywords    LOGS__sn_pc_check_ASPx_on_MantaRay.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__sn_pc_check_ASPx_on_MantaRay
    ...    AND    Set Library Search Order    LOGS__sn_pc_check_ASPx_on_MantaRay
    [Timeout]    14400
    TC__LOGS__sn_pc_check_ASPx_on_MantaRay
    [Teardown]    Run Keywords    LOGS__sn_pc_check_ASPx_on_MantaRay.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Setup]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    ...    AND    Set Library Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Timeout]    14400
    TC__LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Teardown]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB006622_Snapshot_BBOX5_File_Check
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    2400
    ...    AND    LOGS__Snapshot_BBOX5_File_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_BBOX5_File_Check
    ...    AND    Set Library Search Order    LOGS__Snapshot_BBOX5_File_Check
    [Timeout]    14400
    TC_LOGS__Snapshot_BBOX5_File_Check
    [Teardown]    Run Keywords    LOGS__Snapshot_BBOX5_File_Check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Technical_logs_are_failed_to_be_collected_from_the_secondary_cores_when_communication_between_two_cores_are_broken
    [Setup]    Run Keywords
    ...    LOGS__Technical_logs_are_failed_to_be_collected_from_the_secondary_cores_when_communication_between_two_cores_are_broken.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__Technical_logs_are_failed_to_be_collected_from_the_secondary_cores_when_communication_between_two_cores_are_broken
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    20
    ...    AND    Set Library Search Order
    ...    LOGS__Technical_logs_are_failed_to_be_collected_from_the_secondary_cores_when_communication_between_two_cores_are_broken
    [Timeout]    14400
    TC__LOGS__Technical_logs_are_failed_to_be_collected_from_the_secondary_cores_when_communication_between_two_cores_are_broken
    [Teardown]    Run Keywords
    ...    LOGS__Technical_logs_are_failed_to_be_collected_from_the_secondary_cores_when_communication_between_two_cores_are_broken.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    [Setup]    Run Keywords    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    ...    AND    Set Library Search Order    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    [Timeout]    14400
    TC__LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords
    [Teardown]    Run Keywords    LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB008626_Fault_Snapshot_Triggers_With_Unsupported_Coverage_Level_Validation
    [Setup]    Run Keywords    LOGS__CB008626_Fault_Snapshot_Triggers_With_Unsupported_Coverage_Level_Validation.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_Fault_Snapshot_Triggers_With_Unsupported_Coverage_Level_Validation
    ...    AND    Set Library Search Order    LOGS__CB008626_Fault_Snapshot_Triggers_With_Unsupported_Coverage_Level_Validation
    [Timeout]    14400
    TC__LOGS__CB008626_Fault_Snapshot_Triggers_With_Unsupported_Coverage_Level_Validation
    [Teardown]    Run Keywords    LOGS__CB008626_Fault_Snapshot_Triggers_With_Unsupported_Coverage_Level_Validation.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Trigger_FID_6929_Wearout_SSD
    [Setup]    Run Keywords    LOGS__Trigger_FID_6929_Wearout_SSD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Trigger_FID_6929_Wearout_SSD
    ...    AND    Set Library Search Order    LOGS__Trigger_FID_6929_Wearout_SSD
    [Timeout]    14400
    TC__LOGS__Trigger_FID_6929_Wearout_SSD
    [Teardown]    Run Keywords    LOGS__Trigger_FID_6929_Wearout_SSD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core
    [Setup]    Run Keywords    LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core
    ...    AND    Set Library Search Order    LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core
    [Timeout]    14400
    TC__LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core
    [Teardown]    Run Keywords    LOGS__CNI-94033_System_runtime_log_Error_prints_from_Dual_Core.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Setup]    Run Keywords
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    ...    AND    Set Library Search Order    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Timeout]    14400
    TC__LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Teardown]    Run Keywords
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010239-C_SW_integrity_on_active_partition_with_scheduled_DC
    [Setup]    Run Keywords    LOGS__CB010239-C_SW_integrity_on_active_partition_with_scheduled_DC_new.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010239-C_SW_integrity_on_active_partition_with_scheduled_DC_new
    ...    AND    Set Library Search Order    LOGS__CB010239-C_SW_integrity_on_active_partition_with_scheduled_DC_new
    [Timeout]    14400
    TC__LOGS__CB010239-C_SW_integrity_on_active_partition_with_scheduled_DC_new
    [Teardown]    Run Keywords    LOGS__CB010239-C_SW_integrity_on_active_partition_with_scheduled_DC_new.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010239-A_DC_error_triggered_by_Diagnostic_Schedule_invalid_config_file_and_SWDLreport_missing
    [Setup]    Run Keywords  LOGS__CB010239-A_DC_error_triggered_by_Diagnostic_Schedule_invalid_config_file_and_SWDLreport_missing_new.TC Setup
    ...  AND  Modify Resource Search Order  LOGS__CB010239-A_DC_error_triggered_by_Diagnostic_Schedule_invalid_config_file_and_SWDLreport_missing_new
    ...  AND  Set Library Search Order  LOGS__CB010239-A_DC_error_triggered_by_Diagnostic_Schedule_invalid_config_file_and_SWDLreport_missing_new
    [Timeout]  14400
    TC__LOGS__CB010239-A_DC_error_triggered_by_Diagnostic_Schedule_invalid_config_file_and_SWDLreport_missing_new
    [Teardown]   Run Keywords  LOGS__CB010239-A_DC_error_triggered_by_Diagnostic_Schedule_invalid_config_file_and_SWDLreport_missing_new.TC Teardown
    ...    AND  Restore Resource Search Order

[1]Automated__LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log
    [Setup]    Run Keywords    LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log
    ...    AND    Set Library Search Order    LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log
    [Timeout]    14400
    TC__LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log
    [Teardown]    Run Keywords    LOGS__LTE3266-A-d_Snapshot_Troubleshooting_RF_SOAP_log.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity
    [Setup]    Run Keywords
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new
    ...    AND    Set Library Search Order
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new
    [Timeout]    14400
    TC__LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new
    [Teardown]    Run Keywords
    ...    LOGS__CB012370-B_Full_DC_triggered_from_WebEM_and_auto_DC_for_CP33_Secondary_core_connectivity_new.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB009077_FRM5_RU_check
    [Setup]    Run Keywords    LOGS__CB009077_FRM5_RU_check.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB009077_FRM5_RU_check
    ...    AND    Modify Resource Search Order    LOGS__CB009077_FRM5_RU_check
    [Timeout]    14400
    TC_LOGS__CB009077_FRM5_RU_check
    [Teardown]    Run Keywords    LOGS__CB009077_FRM5_RU_check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010655_FRM5_RU_BBOX5_File_Enhancements_Check
    [Setup]    Run Keywords    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new
    ...    AND    Modify Resource Search Order    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new
    [Timeout]    14400
    TC__LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new
    [Teardown]    Run Keywords    LOGS__CB010655_FRM5_RU_BBOX5_File_enhancements_Check_new.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Setup]    Run Keywords    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    ...    AND    Modify Resource Search Order    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Timeout]    14400
    TC__LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Teardown]    Run Keywords    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB007615_Reporting_BTS_reset_cause_timestamp_unknown_during_BTS_startup_after_power_outage
    [Setup]    Run Keywords    LOGS__CB007615_Reporting_BTS_reset_cause_timestamp_unknown_during_BTS_startup_after_power_outage.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB007615_Reporting_BTS_reset_cause_timestamp_unknown_during_BTS_startup_after_power_outage
    ...    AND    Modify Resource Search Order    LOGS__CB007615_Reporting_BTS_reset_cause_timestamp_unknown_during_BTS_startup_after_power_outage
    [Timeout]    14400
    TC__LOGS__CB007615_Reporting_BTS_reset_cause_timestamp_unknown_during_BTS_startup_after_power_outage
    [Teardown]    Run Keywords    LOGS__CB007615_Reporting_BTS_reset_cause_timestamp_unknown_during_BTS_startup_after_power_outage.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010699_Collect_Local_SCREL
    [Setup]    Run Keywords    LOGS__CB010699_Collect_Local_SCREL.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010699_Collect_Local_SCREL
    ...    AND    Set Library Search Order    LOGS__CB010699_Collect_Local_SCREL
    [Timeout]    14400
    TC__LOGS__CB010699_Collect_Local_SCREL
    [Teardown]    Run Keywords    LOGS__CB010699_Collect_Local_SCREL.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Remote_Syslog
    [Setup]    Run Keywords    LOGS__Remote_Syslog.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Remote_Syslog
    ...    AND    Set Library Search Order    LOGS__Remote_Syslog
    [Timeout]    14400
    TC__LOGS__Remote_Syslog
    [Teardown]    Run Keywords    LOGS__Remote_Syslog.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
