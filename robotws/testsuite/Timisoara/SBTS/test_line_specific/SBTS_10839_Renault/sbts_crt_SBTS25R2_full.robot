*** Settings ***
Documentation  Test Suite for TL10839_Renault
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_LG_10839_1ASIA_2ABIA_1FSMF_3AHFIB    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot
Resource          ../../LOGS/LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash.robot


Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}       /home/ute/testline_configuration/10_18_UTESRANCLOUD1839/node1_25R2/SCF_01_SBTS25R2.xml
${NETACT_LAB}    &{srnclab1015}

*** Test Cases ***
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


[1]Automated__LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash
    [Setup]    Run Keywords    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash
    ...    AND    Set Library Search Order    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash
    [Timeout]    14400
    TC__LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash
    [Teardown]    Run Keywords    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
