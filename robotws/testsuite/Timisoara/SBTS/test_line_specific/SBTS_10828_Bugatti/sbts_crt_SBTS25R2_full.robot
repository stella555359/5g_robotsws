*** Settings ***
Documentation  Tests for ASOH
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NL_10828_1ASOH_1AHCA    SBTS25R2
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot

Resource          ../../LOGS/LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.robot
Resource          ../../LOGS/LOGS__Triggers_persistent_over_resets.robot
Resource          ../../LOGS/LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}  ${CURDIR}/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab1015}

*** Test Cases ***

CB010969_ASOH_CB006483_5G_C_Triggers_persistent_over_resets
    [Setup]    Run Keywords    LOGS__Triggers_persistent_over_resets.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Triggers_persistent_over_resets
    ...    AND    Set Library Search Order    LOGS__Triggers_persistent_over_resets
    [Timeout]    14400
    TC__LOGS__Triggers_persistent_over_resets
    [Teardown]    Run Keywords    LOGS__Triggers_persistent_over_resets.TC Teardown
    ...    AND    Restore Resource Search Order

CB010969_ASOH_CB006483_5G_E_The same trigger for 5 snapshots within 24 hours
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    2700
    ...    AND    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    [Timeout]    21600
    TC__LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S
    [Teardown]    Run Keywords    LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.TC Teardown
    ...    AND    Restore Resource Search Order

CB010239-A_04_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition
    [Setup]    Run Keywords  LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new.TC Setup
    ...  AND  Modify Resource Search Order
    ...    LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new
    ...  AND  Set Library Search Order
    ...    LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new
    [Timeout]  14400
    TC__LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new
    [Teardown]
    ...  Run Keywords  LOGS__CB010239-A_DC_from_WebEM_Remote_Tool_command_CP2_Configuration_file_presence_on_the_pasive_partition_new.TC Teardown
    ...    AND  Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
