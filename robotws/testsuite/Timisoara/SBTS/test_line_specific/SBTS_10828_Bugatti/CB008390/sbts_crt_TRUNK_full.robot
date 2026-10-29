*** Settings ***
Documentation  Tests for ASOH
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NL_10828_1ASOH_1AHCA    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot



Resource          ../../../LOGS/LOGS__BTS_enable_log_dedicated_storage_device_during_startup.robot
Resource          ../../../LOGS/LOGS__Trigger_RD_fault_6506_about_utilization_of_log_quota_value.robot
Resource          ../../../LOGS/LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.robot
Resource          ../../../LOGS/LOGS__CB008390_Snapshot_triggered_by_AASYSINFO_FS_OVERLOAD_IND_MSG_to_NetAct.robot
Resource          ../../../LOGS/LOGS__CB008390_Robustness_both_faults_6506_and_6504_are_available.robot


Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}  ${CURDIR}/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab3008}

*** Test Cases ***

LOGS_CB008390_BTS_enable_log_dedicated_storage_device_during startup
    [Setup]    Run Keywords    LOGS__BTS_enable_log_dedicated_storage_device_during_startup.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__BTS_enable_log_dedicated_storage_device_during_startup
    ...    AND    Set Library Search Order    LOGS__BTS_enable_log_dedicated_storage_device_during_startup
    [Timeout]    14400
    TC__LOGS__BTS_enable_log_dedicated_storage_device_during_startup
    [Teardown]    Run Keywords    LOGS__BTS_enable_log_dedicated_storage_device_during_startup.TC Teardown
    ...    AND    Restore Resource Search Order

LOGS_CB008390_Trigger_RD_fault_6506_about_utilization_of_log_quota_value
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Trigger_RD_fault_6506_about_utilization_of_log_quota_value.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Trigger_RD_fault_6506_about_utilization_of_log_quota_value
    ...    AND    Set Library Search Order    LOGS__Trigger_RD_fault_6506_about_utilization_of_log_quota_value
    [Timeout]    14400
    TC__LOGS__Trigger_RD_fault_6506_about_utilization_of_log_quota_value
    [Teardown]    Run Keywords    LOGS__Trigger_RD_fault_6506_about_utilization_of_log_quota_value.TC Teardown
    ...    AND    Restore Resource Search Order

Automated__LOGS_CB008390_fault_6504_about_utilization_of_log_dedicated_storage_device
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    ...    AND    Set Library Search Order    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    [Timeout]    14400
    TC__LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    [Teardown]    Run Keywords    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.TC Teardown
    ...    AND    Restore Resource Search Order

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
