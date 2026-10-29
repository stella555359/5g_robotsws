*** Settings ***
Documentation  Tests for ASOE
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_N_10837_1ASOE_3AVQA_1AHPB_1AHPJ    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Snapshot_BBOX5_File_Check.robot
Resource          ../../LOGS/LOGS__BTS_enable_log_dedicated_storage_device_during_startup.robot
Resource          ../../LOGS/LOGS__Snapshot.robot
Resource          ../../LOGS/LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring.robot
Resource          ../../LOGS/LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.robot
Resource          ../../LOGS/LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct.robot
Resource          ../../LOGS/LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.robot
Resource          ../../LOGS/LOGS__CB010239-C_CP31_active_critical_alarms.robot
Resource          ../../LOGS/LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new.robot
Resource          ../../LOGS/LOGS__CNI-104334_2xpower-reset_snapshoot.robot
Resource          ../../LOGS/LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.robot
Resource         ../../LOGS/LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD.robot
Resource         ../../LOGS/LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD.robot
#Resource          ../../LOGS/LOGS__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT.robot
#Resource          ../../LOGS/LOGS__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS.robot
#Resource         ../../LOGS/LOGS__CB009514_A_5GC000794_ASOG_CRT.robot
Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
     ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10837_Mercedes/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab3008}

*** Test Cases ***
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

[1]LOGS_CB008390_BTS_enable_log_dedicated_storage_device_during startup
    [Setup]    Run Keywords    LOGS__BTS_enable_log_dedicated_storage_device_during_startup.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__BTS_enable_log_dedicated_storage_device_during_startup
    ...    AND    Set Library Search Order    LOGS__BTS_enable_log_dedicated_storage_device_during_startup
    [Timeout]    14400
    TC__LOGS__BTS_enable_log_dedicated_storage_device_during_startup
    [Teardown]    Run Keywords    LOGS__BTS_enable_log_dedicated_storage_device_during_startup.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    Set Library Search Order    LOGS__Snapshot
    [Timeout]    28800
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_Collection_Triggered_By_Syslog_Substring
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    2700
    ...    AND    LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring
    ...    AND    Set Library Search Order    LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring
    [Timeout]    14400
    TC__LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring
    [Teardown]    Run Keywords    LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS_CB008390_fault_6504_about_utilization_of_log_dedicated_storage_device
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    ...    AND    Set Library Search Order    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    [Timeout]    14400
    TC__LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    [Teardown]    Run Keywords    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB006622_Snapshot_BBOX5_File_Check
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot_BBOX5_File_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_BBOX5_File_Check
    ...    AND    Set Library Search Order    LOGS__Snapshot_BBOX5_File_Check
    [Timeout]    14400
    TC_LOGS__Snapshot_BBOX5_File_Check
    [Teardown]    Run Keywords    LOGS__Snapshot_BBOX5_File_Check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    2700
    ...    AND    LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct
    ...    AND    Set Library Search Order    LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct
    [Timeout]    14400
    TC__LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct
    [Teardown]    Run Keywords    LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010239-C_CP31_active_critical_alarms
    [Setup]    Run Keywords    LOGS__CB010239-C_CP31_active_critical_alarms.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB010239-C_CP31_active_critical_alarms
    ...    AND    Modify Resource Search Order    LOGS__CB010239-C_CP31_active_critical_alarms
    [Timeout]    14400
    TC__LOGS__CB010239-C_CP31_active_critical_alarms
    [Teardown]    Run Keywords    LOGS__CB010239-C_CP31_active_critical_alarms.TC Teardown

[1]Automated_LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_1
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

[1] 1_CNI_104334_Improve_log_collection_during_Power_reset
    [Setup]    Run Keywords    LOGS__CNI-104334_2xpower-reset_snapshoot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-104334_2xpower-reset_snapshoot
    ...    AND    Set Library Search Order    LOGS__CNI-104334_2xpower-reset_snapshoot
    [Timeout]    14400
    TC__LOGS__CNI-104334_2xpower-reset_snapshoot
    [Teardown]    Run Keywords    LOGS__CNI-104334_2xpower-reset_snapshoot.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated_CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD
    [Setup]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD
    ...    AND    Set Library Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD
    [Timeout]    14400
    TC__LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD    SMOD_side=1
    [Teardown]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_SMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated_CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD
    [Setup]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD
    ...    AND    Set Library Search Order    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD
    [Timeout]    14400
    TC__LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD    SMOD_side=1
    [Teardown]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_247_Correctable_ECC_memory_SMOD.TC Teardown
    ...    AND    Restore Resource Search Order

#[1]CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT
##    [Tags]     ReTest
#    [Setup]    Run Keywords    LOGS__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT.TC Setup
#    ...    AND    Modify Resource Search Order    LOGS__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT
#    ...    AND    Set Library Search Order    LOGS__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT
#    [Timeout]    14400
#    TC__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT
#    [Teardown]    Run Keywords    LOGS__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT.TC Teardown
#    ...    AND    Restore Resource Search Order
#
#[1]CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS
#    [Tags]     ReTest
#    [Setup]    Run Keywords    LOGS__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS.TC Setup
#    ...    AND    Modify Resource Search Order    LOGS__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS
#    ...    AND    Set Library Search Order    LOGS__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS
#    [Timeout]    14400
#    TC__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS
#    [Teardown]    Run Keywords    LOGS__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS.TC Teardown
#    ...    AND    Restore Resource Search Order

#[1]CB009514_A_5GC000794_ASOG_CRT
#    [Tags]     ReTest
#    [Setup]    Run Keywords    LOGS__CB009514_A_5GC000794_ASOG_CRT.TC Setup
#    ...    AND    Modify Resource Search Order    LOGS__CB009514_A_5GC000794_ASOG_CRT
#    ...    AND    Set Library Search Order    LOGS__CB009514_A_5GC000794_ASOG_CRT
#    [Timeout]    14400
#    TC__CB009514_A_5GC000794_ASOG_CRT
#    [Teardown]    Run Keywords    LOGS__CB009514_A_5GC000794_ASOG_CRT.TC Teardown
#    ...    AND    Restore Resource Search Order
*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
