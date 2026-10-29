*** Settings ***
Documentation  Tests for ASOG
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NL_10836_1ASOG_1AHLOA    SBTS25R2
Library           XML  use_lxml=True

Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../../LOGS/LOGS__CB008390_Robustness_both_faults_6506_and_6504_are_available.robot
Resource          ../../../LOGS/LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct.robot


Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}  ${CURDIR}/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab1028}

*** Test Cases ***

Automated__LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct
    [Setup]    Run Keywords    LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct
    ...    AND    Set Library Search Order    LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct
    [Timeout]    14400
    TC__LOGS_CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct
    [Teardown]    Run Keywords    LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order

LOGS_CB008390_Robustness_both_faults_6506_and_6504_are_available
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__CB008390_Robustness_both_faults_6506_and_6504_are_available.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008390_Robustness_both_faults_6506_and_6504_are_available
    ...    AND    Set Library Search Order    LOGS__CB008390_Robustness_both_faults_6506_and_6504_are_available
    [Timeout]    14400
    TC__LOGS_CB008390_Robustness_both_faults_6506_and_6504_are_available
    [Teardown]    Run Keywords    LOGS__CB008390_Robustness_both_faults_6506_and_6504_are_available.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
