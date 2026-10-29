*** Settings ***
Documentation  Trunk tests
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_10831_1ASIB_1ABIO_1ABIN_1ABIA_1FXDB_1AHBCB_1AHBOA   SBTS00
Library           XML  use_lxml=True
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        ../../LOGS/LOGS__BTS_enable_log_dedicated_storage_device_during_startup.robot
Resource        ../../LOGS/LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.robot
Resource        ../../LOGS/LOGS__Remote_Syslog.robot
Resource        ../../LOGS/LOGS__Snapnshot_Collection_Triggered_By_Fault.robot
Resource        ../../LOGS/LOGS__Event_Log_Creation_For_SSH_Operation.robot
Resource        ../../LOGS/LOGS__Log_Level_Read_Bts_Log_Level.robot
Resource        ../../LOGS/LOGS__Validate_Blackbox_after_reset_actions_LBT2522.robot
Resource        ../../LOGS/LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.robot
Resource        ../../LOGS/LOGS__CB010239-A_DC_triggered_by_WebEM_for_CP1_Configuration_file_presence_on_active_partition_new.robot
Resource        ../../LOGS/LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs.robot
Resource
...	  ../../LOGS/LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours.robot
Resource          ../../LOGS/LOGS__CB012784_TMO.robot
Resource          ../../LOGS/LOGS__CB012784_CRT.robot
Resource          ../../LOGS/LOGS__CB007042_MVP_B.robot
Resource          ../../LOGS/test_call_NSA.robot


Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01
#${MRBTS_ID}    10312

${COMMISSIONING_PATH}=    SEPARATOR=
...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10831_Tesla/commissioning/SCF_01_TRUNK.xml

${Snap_by_fault_to_LSS_max5_in_24hPATH}=    SEPARATOR=
...  LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours

${NETACT_LAB}    &{srnclab1047}

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

[1]Automated__LOGS_CB008390_fault_6504_about_utilization_of_log_dedicated_storage_device
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    ...    AND    Set Library Search Order    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    [Timeout]    14400
    TC__LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    [Teardown]    Run Keywords    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Remote_Syslog
    [Setup]    Run Keywords    LOGS__Remote_Syslog.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Remote_Syslog
    ...    AND    Set Library Search Order    LOGS__Remote_Syslog
    [Timeout]    14400
    TC__LOGS__Remote_Syslog
    [Teardown]    Run Keywords    LOGS__Remote_Syslog.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_Collection_Triggered_By_Fault
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    1200
    ...    AND    LOGS__Snapnshot_Collection_Triggered_By_Fault.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapnshot_Collection_Triggered_By_Fault
    ...    AND    Set Library Search Order    LOGS__Snapnshot_Collection_Triggered_By_Fault
    [Timeout]    14400
    TC__LOGS__Snapnshot_Collection_Triggered_By_Fault
    [Teardown]    Run Keywords    LOGS__Snapnshot_Collection_Triggered_By_Fault.TC Teardown
    ...    AND    Restore Resource Search Order

#[1]Automated__LOGS__Event_Log_Creation_For_SSH_Operation
#    [Setup]    Run Keywords    LOGS__Event_Log_Creation_For_SSH_Operation.TC Setup
#    ...    AND    Modify Resource Search Order    LOGS__Event_Log_Creation_For_SSH_Operation
#    ...    AND    Set Library Search Order    LOGS__Event_Log_Creation_For_SSH_Operation
#    [Timeout]    14400
#    TC__LOGS__Event_Log_Creation_For_SSH_Operation
#    [Teardown]    Run Keywords    LOGS__Event_Log_Creation_For_SSH_Operation.TC Teardown
#    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Log_Level_Read_Bts_Log_Level
    [Setup]    Run Keywords    LOGS__Log_Level_Read_Bts_Log_Level.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Log_Level_Read_Bts_Log_Level
    ...    AND    Set Library Search Order    LOGS__Log_Level_Read_Bts_Log_Level
    [Timeout]    14400
    TC__LOGS__Log_Level_Read_Bts_Log_Level
    [Teardown]    Run Keywords    LOGS__Log_Level_Read_Bts_Log_Level.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours
    [Setup]    Run Keywords    ${Snap_by_fault_to_LSS_max5_in_24hPATH}.TC Setup
    ...    AND    Modify Resource Search Order    ${Snap_by_fault_to_LSS_max5_in_24hPATH}
    ...    AND    Set Library Search Order    ${Snap_by_fault_to_LSS_max5_in_24hPATH}
    [Timeout]    14400
    TC__LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination_and_limit_of_maximum_5snapshots_within_24hours
    [Teardown]    Run Keywords    ${Snap_by_fault_to_LSS_max5_in_24hPATH}.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Validate_Blackbox_after_reset_actions_LBT2522
    [Setup]    Run Keywords    Set Test Variable    ${RESET_DATE}
    ...    AND    Set Test Variable    ${BLACKBOX_INFO}
    ...    AND    Set Test Variable    ${MATCHES}
    ...    AND    Set Test Variable    ${check_blackbox_date}
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    LOGS__Validate_Blackbox_after_reset_actions_LBT2522.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Validate_Blackbox_after_reset_actions_LBT2522
    ...    AND    Set Library Search Order    LOGS__Validate_Blackbox_after_reset_actions_LBT2522
    [Timeout]    14400
    TC__LOGS__Validate_Blackbox_after_reset_actions_LBT2522
    [Teardown]    Run Keywords    LOGS__Validate_Blackbox_after_reset_actions_LBT2522.TC Teardown
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

[1]03_CB008626_A_Light_snapshot_with_L1_and_RU_logs_[4694_EFaultId_FifoBufferOverUnderFlowAI]
    [Setup]    Run Keywords    LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs
    ...    AND    Set Library Search Order    LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs
    [Timeout]    14400
    TC__LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs
    [Teardown]    Run Keywords    LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs.TC Teardown
    ...    AND    Restore Resource Search Order


CB012784_Classical_KPI_triggering_faults_Formula_Evaluation_Error
    [Setup]    Run Keywords       LOGS__CB012784_CRT.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_CRT
    ...    AND    Set Library Search Order    LOGS__CB012784_CRT
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_Formula_Evaluation_Error
    [Teardown]    Run Keywords    LOGS__CB012784_CRT.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_KPI_triggering_faults_SMOD_SFP_LANE
    [Setup]    Run Keywords       LOGS__CB012784_CRT.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_CRT
    ...    AND    Set Library Search Order    LOGS__CB012784_CRT
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_SMOD_SFP_LANE
    [Teardown]    Run Keywords    LOGS__CB012784_CRT.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_KPI_triggering_faults_SMOD_SFP
    [Setup]    Run Keywords       LOGS__CB012784_CRT.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_CRT
    ...    AND    Set Library Search Order    LOGS__CB012784_CRT
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_SMOD_SFP
    [Teardown]    Run Keywords    LOGS__CB012784_CRT.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_KPI_triggering_faults_RMOD_SFP_LANE
    [Setup]    Run Keywords       LOGS__CB012784_CRT.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_CRT
    ...    AND    Set Library Search Order    LOGS__CB012784_CRT
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_RMOD_SFP_LANE
    [Teardown]    Run Keywords    LOGS__CB012784_CRT.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_disable_actKpiAlarms
    [Setup]    Run Keywords       LOGS__CB012784_CRT.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_CRT
    ...    AND    Set Library Search Order    LOGS__CB012784_CRT
    [Timeout]    14400
    TC__LOGS__CB012784_CB012784_Classical_disable_actKpiAlarms
    [Teardown]    Run Keywords    LOGS__CB012784_CRT.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_KPI_triggering_faults_SBTS_SMOD_TEMPERATURE
    [Setup]    Run Keywords       LOGS__CB012784_CRT.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_CRT
    ...    AND    Set Library Search Order    LOGS__CB012784_CRT
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_SBTS_SMOD_TEMPERATURE
    [Teardown]    Run Keywords    LOGS__CB012784_CRT.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_KPI_triggering_faults_RMOD
    [Setup]    Run Keywords       LOGS__CB012784_CRT.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_CRT
    ...    AND    Set Library Search Order    LOGS__CB012784_CRT
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_RMOD
    [Teardown]    Run Keywords    LOGS__CB012784_CRT.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_KPI_triggering_faults_RMOD_FAN
    [Setup]    Run Keywords       LOGS__CB012784_CRT.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_CRT
    ...    AND    Set Library Search Order    LOGS__CB012784_CRT
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_RMOD_FAN
    [Teardown]    Run Keywords    LOGS__CB012784_CRT.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_KPI_triggering_faults_RMOD_SFP
    [Setup]    Run Keywords       LOGS__CB012784_CRT.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_CRT
    ...    AND    Set Library Search Order    LOGS__CB012784_CRT
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_RMOD_SFP
    [Teardown]    Run Keywords    LOGS__CB012784_CRT.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_KPI_triggering_faults_SBTS_SM_Energy_Monitoring
    [Setup]    Run Keywords       LOGS__CB012784_CRT.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_CRT
    ...    AND    Set Library Search Order    LOGS__CB012784_CRT
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_SBTS_SM_Energy_Monitoring
    [Teardown]    Run Keywords    LOGS__CB012784_CRT.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_KPI_triggering_faults_TMOUS_Formula_Evaluation_Error
    [Setup]    Run Keywords       LOGS__CB012784_TMO.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_TMO
    ...    AND    Set Library Search Order    LOGS__CB012784_TMO
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_TMOUS_Formula_Evaluation_Error
    [Teardown]    Run Keywords    LOGS__CB012784_TMO.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_KPI_triggering_faults_TMOUS_RMOD
    [Setup]    Run Keywords       LOGS__CB012784_TMO.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_TMO
    ...    AND    Set Library Search Order    LOGS__CB012784_TMO
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_TMOUS_RMOD
    [Teardown]    Run Keywords    LOGS__CB012784_TMO.TC Teardown
    ...    AND    Restore Resource Search Order

CB012784_Classical_KPI_triggering_faults_TMOUS_SMOD
    [Setup]    Run Keywords       LOGS__CB012784_TMO.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB012784_TMO
    ...    AND    Set Library Search Order    LOGS__CB012784_TMO
    [Timeout]    14400
    TC__LOGS__CB012784_Classical_KPI_triggering_faults_TMOUS_SMOD
    [Teardown]    Run Keywords    LOGS__CB012784_TMO.TC Teardown
    ...    AND    Restore Resource Search Order

CB007042_MVP_B_001_List_L1low_dump_and_register_dump_scripts_and_check_descriptions_from_WebEM
    [Setup]    Run Keywords       LOGS__CB007042_MVP_B.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB007042_MVP_B
    ...    AND    Set Library Search Order    LOGS__CB007042_MVP_B
    [Timeout]    14400
    TC__CB007042_MVP_B_001_List_L1low_dump_and_register_dump_scripts_and_check_descriptions_from_WebEM
    [Teardown]    Run Keywords    LOGS__CB007042_MVP_B.TC Teardown
    ...    AND    Restore Resource Search Order

CB007042_MVP_B_003_List_L1low_dump_and_register_dump_scripts_and_check_descriptions_from_Admin_CLI
    [Setup]    Run Keywords       LOGS__CB007042_MVP_B.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB007042_MVP_B
    ...    AND    Set Library Search Order    LOGS__CB007042_MVP_B
    [Timeout]    14400
    TC__CB007042_MVP_B_003_List_L1low_dump_and_register_dump_scripts_and_check_descriptions_from_Admin_CLI
    [Teardown]    Run Keywords    LOGS__CB007042_MVP_B.TC Teardown
    ...    AND    Restore Resource Search Order

CB007042_MVP_B_004_Execute_L1low_dump_script_from_Admin_CLI
    [Setup]    Run Keywords       LOGS__CB007042_MVP_B.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB007042_MVP_B
    ...    AND    Set Library Search Order    LOGS__CB007042_MVP_B
    [Timeout]    14400
    TC__CB007042_MVP_B_004_Execute_L1low_dump_script_from_Admin_CLI
    [Teardown]    Run Keywords    LOGS__CB007042_MVP_B.TC Teardown
    ...    AND    Restore Resource Search Order

Test_Call
    [Setup]    Run Keywords       sleep    1s    #test_call_NSA.TC Setup
    ...    AND    Modify Resource Search Order    test_call_NSA
    ...    AND    Set Library Search Order    test_call_NSA
    [Timeout]    14400
    TC__test_call_NSA
#    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
