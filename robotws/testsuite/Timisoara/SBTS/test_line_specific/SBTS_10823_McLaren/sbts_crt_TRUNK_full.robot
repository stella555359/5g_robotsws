*** Settings ***
Documentation     TCs McLaren
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_2ASIL_2ABIA_2ABIO_1ABIN_1FRGY_1AHFB_1AHIB_1FXDB_AHCA_AHEH_AHEC    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__CB007833_BlackBox_check_24h_save_period.robot
Resource          ../../LOGS/LOGS__Log_Level_Set_Full_Bts_Log_Level.robot
Resource          ../../LOGS/LOGS__Snapshot.robot
Resource          ../../LOGS/LOGS__Blackbox_log_creation.robot
Resource          ../../LOGS/LOGS__Event_Log_Preservation_After_Reset.robot
Resource          ../../LOGS/LOGS__CNI-29578_IP_connectivity_test.robot
Resource          ../../LOGS/LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD.robot
Resource          ../../LOGS/LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.robot
Resource          ../../LOGS/LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.robot
Resource          ../../LOGS/LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check.robot
Resource          ../../LOGS/LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new.robot
Resource          ../../LOGS/LOGS__CNI35012_Select_And_Load_IMS2_File.robot
Resource          ../../LOGS/LOGS__Snapshot_collection_from_dual_core_with_re_establishing.robot
Resource          ../../LOGS/LOGS__CNI-90327_AaTrblServer_configuration_formalization.robot
Resource          ../../LOGS/LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.robot
Resource          ../../LOGS/LOGS__CB012784_TMO.robot
Resource          ../../LOGS/LOGS__CB012784_CRT.robot
Resource          ../../LOGS/LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs.robot
Resource          ../../LOGS/LOGS__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS.robot
#Resource          ../../LOGS/LOGS__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1823/node1/SCF_01_TRUNK.xml

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

[1]Automated__LOGS__Snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    Set Library Search Order    LOGS__Snapshot
    [Timeout]    28800
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    2700
    ...    AND    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    [Timeout]    21600
    TC__LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    [Teardown]    Run Keywords    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Log_Level_Set_Full_Bts_Log_Level
    [Setup]    Run Keywords    LOGS__Log_Level_Set_Full_Bts_Log_Level.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Log_Level_Set_Full_Bts_Log_Level
    ...    AND    Set Library Search Order    LOGS__Log_Level_Set_Full_Bts_Log_Level
    [Timeout]    14400
    TC__LOGS__Log_Level_Set_Full_Bts_Log_Level
    [Teardown]    Run Keywords    LOGS__Log_Level_Set_Full_Bts_Log_Level.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Blackbox_log_creation
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_EXTRACTED}    ${FALSE}
    ...    AND    Set Test Variable    ${RESET_TYPE}    power_reset
    ...    AND    Set Test Variable    ${RESET_DATE}
    ...    AND    Set Test Variable    ${BLACKBOX_INFO}
    ...    AND    Set Test Variable    ${MATCHES}
    ...    AND    Set Test Variable    ${check_blackbox_date}
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    LOGS__Blackbox_log_creation.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Blackbox_log_creation
    ...    AND    Set Library Search Order    LOGS__Blackbox_log_creation
    [Timeout]    14400
    TC__LOGS__BlackBox
    [Teardown]    Run Keywords    LOGS__Blackbox_log_creation.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Event_Log_Preservation_After_Reset
    [Setup]    Run Keywords    LOGS__Event_Log_Preservation_After_Reset.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Event_Log_Preservation_After_Reset
    ...    AND    Set Library Search Order    LOGS__Event_Log_Preservation_After_Reset
    [Timeout]    14400
    TC__LOGS__Event_Log_Preservation_After_Reset.robot
    [Teardown]    Run Keywords    LOGS__Event_Log_Preservation_After_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__IP__connectivity_test_all_configured_hosts
    [Setup]    Run Keywords    Set Test Variable    ${CLOSE_BROWSER_AFTER_TEST}    True
    ...    AND    Set Test Variable    ${TESTED_IP_ADDRESS}    192.168.255.1
    ...    AND    LOGS__CNI-29578_IP_connectivity_test.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-29578_IP_connectivity_test
    ...    AND    Set Library Search Order    LOGS__CNI-29578_IP_connectivity_test
    [Timeout]    14400
    TC__LOGS__CNI-29578_IP_connectivity_test.robot
    [Teardown]    Run Keywords    LOGS__CNI-29578_IP_connectivity_test.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD
    [Setup]    Run Keywords    Set Test Variable    ${DSP_ID}    0x1231
    ...    AND    Set Test Variable    ${SITE_RESET}    False
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    Set Test Variable    ${FAULT_TIMEOUT}    15
    ...    AND    Set Test Variable    ${VERIFICATION_TIMEOUT}    3
    ...    AND    Set Test Variable    ${MEMDUMP_PATTERN}    (\\d{4})\\w+MEMDUMP\\.bin\\.xz$
    ...    AND    Set Test Variable    ${DSP_MEMDUMPER_PATTERN}    memdumper_{}.+\\.log\\.xz$
    ...    AND    Set Test Variable    ${DSP_RUNTIME_PATTERN}    [1-2]011_crash_{}00_RT\\.log\\.zip$
    ...    AND    Set Test Variable    ${DSP_MEMDUMP_PATTERN}    {}00\\w+MEMDUMP\\.bin.*
    ...    AND    Set Test Variable    ${SRIO_DIO_INTERFACE_PATERN}    riomemfs-logdump
    ...    AND    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD
    ...    AND    Set Library Search Order    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD
    [Timeout]    14400
    TC__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD
    [Teardown]    Run Keywords    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash_for_ASIL_SMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB007833_BlackBox_check_24h_save_period
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__CB007833_BlackBox_check_24h_save_period.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB007833_BlackBox_check_24h_save_period
    ...    AND    Set Library Search Order    LOGS__CB007833_BlackBox_check_24h_save_period
    [Timeout]    172800
    TC_LOGS__CB007833_BlackBox_check_24h_save_period
    [Teardown]    Run Keywords    LOGS__CB007833_BlackBox_check_24h_save_period.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI35012_Select_And_Load_IMS2_File
    [Setup]    Run Keywords    LOGS__CNI35012_Select_And_Load_IMS2_File.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI35012_Select_And_Load_IMS2_File
    ...    AND    Set Library Search Order    LOGS__CNI35012_Select_And_Load_IMS2_File
    [Timeout]    14400
    TC__LOGS__CNI35012_Select_And_Load_IMS2_File
    [Teardown]    Run Keywords    LOGS__CNI35012_Select_And_Load_IMS2_File.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Setup]    Run Keywords    LOGS__Snapshot_collection_from_dual_core_with_re_establishing.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Timeout]    14400
    TC__LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Teardown]    Run Keywords    LOGS__Snapshot_collection_from_dual_core_with_re_establishing.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check
    [Setup]    Run Keywords    LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check
    ...    AND    Set Library Search Order    LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check
    [Timeout]    14400
    TC__LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check
    [Teardown]    Run Keywords    LOGS__CB009077_Store_location_data_in_SMOD_BBMOD_and_preventParamModifList_check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Setup]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    ...    AND    Set Library Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Timeout]    14400
    TC__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Teardown]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed
    [Setup]    Run Keywords
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new
    ...    AND    Set Library Search Order
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new
    [Timeout]    14400
    TC__LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new
    [Teardown]    Run Keywords
    ...    LOGS__CB012370-C_Auto_and_scheduled_DC_triggered_from_WebEM_GUI_for_CP37_System_Module_FAN_Speed_new.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Setup]    Run Keywords
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    ...    AND    Set Library Search Order
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Timeout]    14400
    TC__LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset
    [Teardown]    Run Keywords
    ...    LOGS__CNI-93136_CNI-93789_Diagnostic_logs_from_secondary_common_unit_related_to_warm_reset.TC Teardown
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

CB012784_CB012784_Classical_disable_actKpiAlarms
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

[1]03_CB008626_A_Light_snapshot_with_L1_and_RU_logs_[4694_EFaultId_FifoBufferOverUnderFlowAI]
    [Setup]    Run Keywords    LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs
    ...    AND    Set Library Search Order    LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs
    [Timeout]    14400
    TC__LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs
    [Teardown]    Run Keywords    LOGS__CB008626_A_Light_snapshot_with_L1_and_RU_logs.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS
    [Tags]     ReTest
    [Setup]    Run Keywords    LOGS__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS
    ...    AND    Set Library Search Order    LOGS__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS
    [Timeout]    14400
    TC__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS
    [Teardown]    Run Keywords    LOGS__CNI-85020_03_Loki_Event_trigger_parallel_L1-L2_Mirroring_snapshot_to_LSS.TC Teardown
    ...    AND    Restore Resource Search Order
#
#[1]CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT
#    [Setup]    Run Keywords    LOGS__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT.TC Setup
#    ...    AND    Modify Resource Search Order    LOGS__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT
#    ...    AND    Set Library Search Order    LOGS__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT
#    [Timeout]    14400
#    TC__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT
#    [Teardown]    Run Keywords    LOGS__CNI-103148_05_collect_Syscom_trace_and_warm_and_hard_reset_RAT.TC Teardown
#    ...    AND    Restore Resource Search Order
*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
