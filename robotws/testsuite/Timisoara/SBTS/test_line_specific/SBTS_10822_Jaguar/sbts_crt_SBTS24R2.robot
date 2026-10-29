*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_NLWG_10822_lASIL_1ABIP_1ABIO_1ABIA_2AHEH_2AHEGB    SBTS24R2
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Blackbox_log_creation.robot
Resource          ../../LOGS/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot
Resource          ../../LOGS/LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S.robot
Resource          ../../LOGS/LOGS__Snapshot_BBOX5_File_Check.robot
Resource          ../../LOGS/LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.robot
Resource          ../../LOGS/LOGS__Snapshot_collection_from_decommissioned_SBTS.robot
Resource          ../../LOGS/LOGS__CNI-96681-F_01_Full_DC_for_CP34_Uncorrectable_ECC_errors_on_SMOD.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10822_Jaguar/commissioning/SCF_01_SBTS24R2.xml

${NETACT_LAB}    &{srnclab1028}

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

[1]Automated__LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_ external_server_LSS_via_NE3S
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S
    [Timeout]    14400
    TC__LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S
    [Teardown]    Run Keywords    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_LSS_via_NE3S.TC Teardown
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

[1]Automated__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Setup]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    ...    AND    Set Library Search Order    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Timeout]    14400
    TC__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Teardown]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection_from_decommissioned_SBTS
    [Setup]    Run Keywords    LOGS__Snapshot_collection_from_decommissioned_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection_from_decommissioned_SBTS
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection_from_decommissioned_SBTS
    [Timeout]    14400
    TC__LOGS__Snapshot_collection_from_decommissioned_SBTS
    [Teardown]    Run Keywords    LOGS__Snapshot_collection_from_decommissioned_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-96681-F_01_Full_DC_for_CP34_Uncorrectable_ECC_errors_on_SMOD
    [Setup]    Run Keywords    LOGS__CNI-96681-F_01_Full_DC_for_CP34_Uncorrectable_ECC_errors_on_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-96681-F_01_Full_DC_for_CP34_Uncorrectable_ECC_errors_on_SMOD
    ...    AND    Set Library Search Order    LOGS__CNI-96681-F_01_Full_DC_for_CP34_Uncorrectable_ECC_errors_on_SMOD
    [Timeout]    14400
    TC__LOGS__CNI-96681-F_01_Full_DC_for_CP34_Uncorrectable_ECC_errors_on_SMOD
    [Teardown]    Run Keywords    LOGS__CNI-96681-F_01_Full_DC_for_CP34_Uncorrectable_ECC_errors_on_SMOD.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
