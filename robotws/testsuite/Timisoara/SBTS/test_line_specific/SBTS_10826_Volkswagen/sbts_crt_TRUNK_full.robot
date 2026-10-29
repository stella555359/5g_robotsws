*** Settings ***
Documentation  Tests for Volkswagen
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_10826_1ASIB_2ABIO_1ABIA_1ASIA_3ABIA_2FXDB_2AZQS_1FXED_1FRGU_1AHEH    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Blackbox_log_creation.robot
Resource          ../../LOGS/LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.robot
Resource          ../../LOGS/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot
Resource          ../../LOGS/LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.robot
Resource          ../../LOGS/LOGS__Remote_snapshot_collection_via_cOAM_reject_as_remote_server_link_is_down.robot
Resource          ../../LOGS/LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination.robot
Resource          ../../LOGS/LOGS__Snapshot_upload_to_external_server_long_link_break.robot
Resource          ../../LOGS/LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal.robot
Resource          ../../LOGS/LOGS__Snapshot_collection_via_secondary_core.robot
Resource       ../../LOGS/LOGS__CNI-90327_AaTrblServer_configuration_formalization.robot
Resource       ../../LOGS/LOGS__CB009077_ERM6_RU_check.robot
Resource       ../../LOGS/LOGS__CB007042_B_114_AZQS_concurrent_operations_between_NE_Reset_and_RU_troubleshooting_script_execution.robot
Resource       ../../LOGS/LOGS__CB007042_B_112_AZQS_concurrent_operations_between_IQ_data_capture_and_L1low_dump_script_executions.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10826_Volkswagen/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab3008}

*** Test Cases ***
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

[1]Automated__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Setup]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Setup
    ...    AND    Set Test Variable    ${SNAPSHOT_TIMEOUT}    2700
    ...    AND    Modify Resource Search Order
    ...    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    ...    AND    Set Library Search Order    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Timeout]    14400
    TC__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Teardown]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_content__postmortem_files_creation_for_SMOD
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_FILE_PATH}    /tmp/uri/DIAGN_FILES/
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    Set Test Variable    ${SNAPSHOT_TIMEOUT}    2400
    ...    AND    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    ...    AND    Set Library Search Order    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    [Timeout]    14400
    TC__LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    [Teardown]    Run Keywords    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.TC Teardown
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

[1]Automated__LOGS__Remote_snapshot_collection_via_cOAM_reject_as_remote_server_link_is_down
    [Setup]    Run Keywords    LOGS__Remote_snapshot_collection_via_cOAM_reject_as_remote_server_link_is_down.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Remote_snapshot_collection_via_cOAM_reject_as_remote_server_link_is_down
    ...    AND    Set Library Search Order    LOGS__Remote_snapshot_collection_via_cOAM_reject_as_remote_server_link_is_down
    [Timeout]    14400
    TC__LOGS__Remote_snapshot_collection_via_cOAM_reject_as_remote_server_link_is_down
    [Teardown]    Run Keywords    LOGS__Remote_snapshot_collection_via_cOAM_reject_as_remote_server_link_is_down.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination
    [Setup]    Run Keywords    LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination
    ...    AND    Set Library Search Order    LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination
    [Timeout]    14400
    TC__LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination
    [Teardown]    Run Keywords    LOGS__Snapshot_triggered_by_BTS_fault_cancellation_collected_to_LSS_destination.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_upload_to_external_server_long_link_break
    [Setup]    Run Keywords    LOGS__Snapshot_upload_to_external_server_long_link_break.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_upload_to_external_server_long_link_break
    ...    AND    Set Library Search Order    LOGS__Snapshot_upload_to_external_server_long_link_break
    [Timeout]    14400
    TC__LOGS__Snapshot_upload_to_external_server_long_link_break
    [Teardown]    Run Keywords    LOGS__Snapshot_upload_to_external_server_long_link_break.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection_via_secondary_core
    [Setup]    Run Keywords    LOGS__Snapshot_collection_via_secondary_core.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection_via_secondary_core
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection_via_secondary_core
    [Timeout]    14400
    TC__LOGS__Snapshot_collection_via_secondary_core
    [Teardown]    Run Keywords    LOGS__Snapshot_collection_via_secondary_core.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal
    [Setup]    Run Keywords
    ...    LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal
    ...    AND    Set Library Search Order
    ...    LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal
    [Timeout]    14400
    TC__LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal
    [Teardown]    Run Keywords
    ...    LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal.TC Teardown
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

[1]Automated__LOGS__CB007042_B_114_AZQS_concurrent_operations_between_NE_Reset_and_RU_troubleshooting_script_execution
    [Setup]  Run Keywords
    ...    LOGS__CB007042_B_114_AZQS_concurrent_operations_between_NE_Reset_and_RU_troubleshooting_script_execution.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB007042_B_114_AZQS_concurrent_operations_between_NE_Reset_and_RU_troubleshooting_script_execution
    ...    AND    Set Library Search Order
    ...    LOGS__CB007042_B_114_AZQS_concurrent_operations_between_NE_Reset_and_RU_troubleshooting_script_execution
    [Timeout]    14400
    TC__LOGS__CB007042_B_114_AZQS_concurrent_operations_between_NE_Reset_and_RU_troubleshooting_script_execution
    [Teardown]    Run Keywords
    ...    LOGS__CB007042_B_114_AZQS_concurrent_operations_between_NE_Reset_and_RU_troubleshooting_script_execution.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB007042_B_112_AZQS_concurrent_operations_between_IQ_data_capture_and_L1low_dump_script_executions
    [Setup]  Run Keywords
    ...    LOGS__CB007042_B_112_AZQS_concurrent_operations_between_IQ_data_capture_and_L1low_dump_script_executions.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB007042_B_112_AZQS_concurrent_operations_between_IQ_data_capture_and_L1low_dump_script_executions
    ...    AND    Set Library Search Order
    ...    LOGS__CB007042_B_112_AZQS_concurrent_operations_between_IQ_data_capture_and_L1low_dump_script_executions
    [Timeout]    14400
    TC__LOGS__CB007042_B_112_AZQS_concurrent_operations_between_IQ_data_capture_and_L1low_dump_script_executions
    [Teardown]    Run Keywords
    ...    LOGS__CB007042_B_112_AZQS_concurrent_operations_between_IQ_data_capture_and_L1low_dump_script_executions.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
