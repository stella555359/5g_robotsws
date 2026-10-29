*** Settings ***
Documentation  Tests on VOLVO
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_NL_ASOE_AZQO_AEQN_AHCA    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Snapshot.robot
Resource          ../../LOGS/LOGS__Snapshot_collection_from_decommissioned_SBTS.robot
Resource          ../../LOGS/LOGS__Snapshot_filelist_check.robot
Resource          ../../LOGS/LOGS__Snapnshot_Collection_Triggered_By_Syslog_Substring.robot
Resource          ../../LOGS/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot
Resource          ../../LOGS/LOGS__Snapshot_Runtime_Log_Error_Prints.robot
Resource          ../../LOGS/LOGS__Blackbox_log_creation.robot
Resource          ../../LOGS/LOGS__Snapshot_files_freezing_time_check.robot
Resource       ../../LOGS/LOGS__CNI-132394_trigger_fault_214.robot
Resource     ../../LOGS/LOGS__CNI_132394_B_trigger_fault_6928_6915.robot


Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
     ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10821_Volvo/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab1047}

*** Test Cases ***
[1]Automated__LOGS__Snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    Set Library Search Order    LOGS__Snapshot
    [Timeout]    28800
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection_from_decommissioned_SBTS
    [Setup]    Run Keywords    LOGS__Snapshot_collection_from_decommissioned_SBTS.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection_from_decommissioned_SBTS
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection_from_decommissioned_SBTS
    [Timeout]    14400
    TC__LOGS__Snapshot_collection_from_decommissioned_SBTS
    [Teardown]    Run Keywords    LOGS__Snapshot_collection_from_decommissioned_SBTS.TC Teardown
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

[1]Automated__LOGS__Snapshot_Runtime_Log_ERROR_Prints
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot_Runtime_Log_Error_Prints.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_Runtime_Log_Error_Prints
    ...    AND    Set Library Search Order    LOGS__Snapshot_Runtime_Log_Error_Prints
    [Timeout]    14400
    LOGS__Snapshot_Runtime_Log_Error_Prints
    [Teardown]    Run Keywords    LOGS__Snapshot_Runtime_Log_Error_Prints.TC Teardown
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

[1]Automated__LOGS__Snapshot_files_freezing_time_check
    [Setup]    Run Keywords    LOGS__Snapshot_files_freezing_time_check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_files_freezing_time_check
    ...    AND    Set Library Search Order    LOGS__Snapshot_files_freezing_time_check
    [Timeout]    14400
    TC__LOGS__Snapshot_files_freezing_time_check
    [Teardown]    Run Keywords    LOGS__Snapshot_files_freezing_time_check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-132394_trigger_fault_214
    [Setup]    Run Keywords    LOGS__CNI-132394_trigger_fault_214.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-132394_trigger_fault_214
    ...    AND    Set Library Search Order    LOGS__CNI-132394_trigger_fault_214
    [Timeout]    14400
    TC__LOGS__CNI-132394_trigger_fault_214
    [Teardown]    Run Keywords    LOGS__CNI-132394_trigger_fault_214.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI_132394_B_trigger_fault_6928_6915
    [Setup]    Run Keywords    LOGS__CNI_132394_B_trigger_fault_6928_6915.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI_132394_B_trigger_fault_6928_6915
    ...    AND    Set Library Search Order    LOGS__CNI_132394_B_trigger_fault_6928_6915
    [Timeout]    14400
    TC__LOGS__CNI_132394_B_trigger_fault_6928_6915
    [Teardown]    Run Keywords    LOGS__CNI_132394_B_trigger_fault_6928_6915.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_filelist_check
    [Setup]    Run Keywords    LOGS__Snapshot_filelist_check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_filelist_check
    ...    AND    Set Library Search Order    LOGS__Snapshot_filelist_check
    [Timeout]    14400
    TC__LOGS__Snapshot_filelist_check
    [Teardown]    Run Keywords    LOGS__Snapshot_filelist_check.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
