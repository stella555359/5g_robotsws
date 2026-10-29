*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_LW_10312_1ASIA_2ABIA_2FRGU    SBTS23R3
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Blackbox_log_creation.robot
Resource          ../../LOGS/LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.robot
Resource          ../../LOGS/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot
Resource          ../../LOGS/LOGS__Snapshot.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10312_Seat/commissioning/SCF_01_SBTS23R3.xml

*** Test Cases ***
[1]Automated__LOGS__Snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    600
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Set Library Search Order    LOGS__Snapshot
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    [Timeout]    14400
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
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

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
