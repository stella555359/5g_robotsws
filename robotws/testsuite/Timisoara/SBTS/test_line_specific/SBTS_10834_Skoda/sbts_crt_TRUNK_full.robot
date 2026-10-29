*** Settings ***
Documentation  Tests on Skoda TMO
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_L_10644_2ASIA_4ABIA_3FRIG_3FHFB_3AHLOA_RFS_N_10643_1ASIL_1ABIO_3AHLOA    SBTS00
Library     XML  use_lxml=True
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource    ../../LOGS/LOGS__Blackbox_log_creation.robot
Resource    ../../LOGS/LOGS__Event_Log_Creation_For_SSH_Operation.robot
Resource    ../../LOGS/LOGS__Event_Log_Creation_For_WebEM_Operation.robot
Resource    ../../LOGS/LOGS__Event_Log_Preservation_After_Reset.robot
Resource    ../../LOGS/LOGS__Log_Level_Set_Minimum_Bts_Log_Level.robot
Resource    ../../LOGS/LOGS__Log_Level_Set_Normal_Bts_Log_Level.robot
Resource    ../../LOGS/LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.robot
Resource    ../../LOGS/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot
Resource    ../../LOGS/LOGS__Snapshot.robot
Resource    ../../LOGS/LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.robot
Resource    ../../LOGS/LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S.robot
Resource    ../../LOGS/LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core.robot
Resource    ../../LOGS/LOGS__Snapshot_collection_from_dual_core_with_re_establishing.robot
Resource    ../../LOGS/LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.robot
Resource    ../../LOGS/LOGS__CNI-90327_AaTrblServer_configuration_formalization.robot
Resource    ../../LOGS/LOGS__Snapshot_triggered_by_Fault_SignatureKeyword_Match.robot
Resource     ../../LOGS/LOGS__CB014065_Snapshot_triggered_by_AlarmKeyword_Match_upload_to_NMS.robot


Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}
    ...    /home/ute/testline_configuration/10_18_UTESRANCLOUD1644/node1/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab3007}

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
    [Timeout]    14400
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Event_Log_Creation_For_WebEM_Operation
    [Setup]    Run Keywords    coam.Connect To
    ...    AND    LOGS__Event_Log_Creation_For_WebEM_Operation.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Event_Log_Creation_For_WebEM_Operation
    ...    AND    Set Library Search Order    LOGS__Event_Log_Creation_For_WebEM_Operation
    ...    AND    coam.Teardown
    [Timeout]    14400
    TC__LOGS__Event_Log_Creation_For_WebEM_Operation.robot
    [Teardown]    Run Keywords    LOGS__Event_Log_Creation_For_WebEM_Operation.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_content__postmortem_files_creation_for_SMOD
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_FILE_PATH}    /tmp/uri/DIAGN_FILES/
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    Set Test Variable    ${SNAPSHOT_TIMEOUT}    600
    ...    AND    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    ...    AND    Set Library Search Order    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    [Timeout]    14400
    TC__LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    [Teardown]    Run Keywords    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Event_Log_Creation_For_SSH_Operation
    [Setup]    Run Keywords    LOGS__Event_Log_Creation_For_SSH_Operation.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Event_Log_Creation_For_SSH_Operation
    ...    AND    Set Library Search Order    LOGS__Event_Log_Creation_For_SSH_Operation
    [Timeout]    14400
    TC__LOGS__Event_Log_Creation_For_SSH_Operation.robot
    [Teardown]    Run Keywords    LOGS__Event_Log_Creation_For_SSH_Operation.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Event_Log_Preservation_After_Reset
    [Setup]    Run Keywords    LOGS__Event_Log_Preservation_After_Reset.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Event_Log_Preservation_After_Reset
    ...    AND    Set Library Search Order    LOGS__Event_Log_Preservation_After_Reset
    [Timeout]    14400
    TC__LOGS__Event_Log_Preservation_After_Reset.robot
    [Teardown]    Run Keywords    LOGS__Event_Log_Preservation_After_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Log_Level_Set_Normal_Bts_Log_Level
    [Setup]    Run Keywords    LOGS__Log_Level_Set_Normal_Bts_Log_Level.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Log_Level_Set_Normal_Bts_Log_Level
    ...    AND    Set Library Search Order    LOGS__Log_Level_Set_Normal_Bts_Log_Level
    [Timeout]    14400
    TC__LOGS__Log_Level_Set_Normal_Bts_Log_Level
    [Teardown]    Run Keywords    LOGS__Log_Level_Set_Normal_Bts_Log_Level.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Blackbox_log_creation
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_EXTRACTED}    ${FALSE}
    ...    AND    Set Test Variable    ${RESET_TYPE}    site_reset
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

[1]Automated__LOGS__Log_Level_Set_Minimum_Bts_Log_Level
    [Setup]    Run Keywords    LOGS__Log_Level_Set_Minimum_Bts_Log_Level.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Log_Level_Set_Minimum_Bts_Log_Level
    ...    AND    Set Library Search Order    LOGS__Log_Level_Set_Minimum_Bts_Log_Level
    [Timeout]    14400
    TC__LOGS__Log_Level_Set_Minimum_Bts_Log_Level
    [Teardown]    Run Keywords    LOGS__Log_Level_Set_Minimum_Bts_Log_Level.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Setup]    Run Keywords    Set Test Variable    ${DSP_ID}    ${Empty}
    ...    AND    Set Test Variable    ${SITE_RESET}    False
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    Set Test Variable    ${FAULT_TIMEOUT}    15
    ...    AND    Set Test Variable    ${VERIFICATION_TIMEOUT}    3
    ...    AND    Set Test Variable    ${MEMDUMP_PATTERN}    (\\d{4})\\w+MEMDUMP\\.bin\\.xz$
    ...    AND    Set Test Variable    ${DSP_MEMDUMPER_PATTERN}    memdumper_{}.+\\.log\\.xz$
    ...    AND    Set Test Variable    ${DSP_RUNTIME_PATTERN}    [1-2]011_crash_{}00_RT\\.log\\.zip$
    ...    AND    Set Test Variable    ${DSP_MEMDUMP_PATTERN}    {}00\\w+MEMDUMP\\.bin.*
    ...    AND    Set Test Variable    ${SRIO_DIO_INTERFACE_PATERN}    riomemfs-logdump
    ...    AND    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    ...    AND    Set Library Search Order    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Timeout]    14400
    TC__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Teardown]    Run Keywords    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Setup]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    ...    AND    Set Library Search Order    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Timeout]    14400
    TC__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Teardown]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S
    [Timeout]    14400
    TC__LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S
    [Teardown]    Run Keywords    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core
    [Setup]    Run Keywords    LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core
    ...    AND    Set Library Search Order    LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core
    [Timeout]    14400
    TC__LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core
    [Teardown]    Run Keywords    LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Setup]    Run Keywords    LOGS__Snapshot_collection_from_dual_core_with_re_establishing.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Timeout]    14400
    TC__LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Teardown]    Run Keywords    LOGS__Snapshot_collection_from_dual_core_with_re_establishing.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Setup]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    ...    AND    Set Library Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Timeout]    14400
    TC__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Teardown]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Teardown
    ...    AND    Restore Resource Search Order

CB014065_TC2_NMS_SignatureKeyword_Match
    [Setup]    Run Keywords    LOGS__Snapshot_triggered_by_Fault_SignatureKeyword_Match.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_triggered_by_Fault_SignatureKeyword_Match
    ...    AND    Set Library Search Order    LOGS__Snapshot_triggered_by_Fault_SignatureKeyword_Match
    [Timeout]    14400
    TC__LOGS__Snapshot_triggered_by_Fault_SignatureKeyword_Match
    [Teardown]    Run Keywords    LOGS__Snapshot_triggered_by_Fault_SignatureKeyword_Match.TC Teardown
    ...    AND    Restore Resource Search Order

CB014065_TC11_NMS_AlarmKeyword_Match
    [Setup]    Run Keywords    LOGS__CB014065_Snapshot_triggered_by_AlarmKeyword_Match_upload_to_NMS.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB014065_Snapshot_triggered_by_AlarmKeyword_Match_upload_to_NMS
    ...    AND    Set Library Search Order    LOGS__CB014065_Snapshot_triggered_by_AlarmKeyword_Match_upload_to_NMS
    [Timeout]    14400
    TC__LOGS__CB014065_TC11_NMS_AlarmKeyword_Match
    [Teardown]    Run Keywords    LOGS__CB014065_Snapshot_triggered_by_AlarmKeyword_Match_upload_to_NMS.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
