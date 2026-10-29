*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NL_ASOE_AZQO_AEQN_AHCA    SBTS25R1
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
Resource          ../../LOGS/LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition.robot
Resource          ../../LOGS/LOGS__CNI-104334_2xpower-reset_snapshoot.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
#    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_8048_Sowa/commissioning/SCF_01_TRUNK.xml
     ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10837_Mercedes/commissioning/SCF_01_TRUNK.xml
${NETACT_LAB}    &{srnclab1015}

*** Test Cases ***
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
    [Timeout]    14400
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
    [Setup]    Run Keywords  LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition.TC Setup
    ...  AND  Modify Resource Search Order  LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition
    ...  AND  Set Library Search Order  LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition
    [Timeout]  14400
    TC__LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition
    [Teardown]   Run Keywords  LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition.TC Teardown
    ...    AND  Restore Resource Search Order

[1]1_CNI_104334_Improve_log_collection_during_Power_reset
    [Setup]    Run Keywords    LOGS__CNI-104334_2xpower-reset_snapshoot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-104334_2xpower-reset_snapshoot
    ...    AND    Set Library Search Order    LOGS__CNI-104334_2xpower-reset_snapshoot
    [Timeout]    14400
    TC__LOGS__CNI-104334_2xpower-reset_snapshoot
    [Teardown]    Run Keywords    LOGS__CNI-104334_2xpower-reset_snapshoot.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
