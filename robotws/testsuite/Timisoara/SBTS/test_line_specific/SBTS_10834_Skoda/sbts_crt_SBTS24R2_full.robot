*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_LWG_10834_1ASIA_3ABIA_1ASIA_2ABIA_1AREA_1FXED_2FXDB_1AWHHD    SBTS24R2
Library     XML  use_lxml=True
Resource    taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource    ../../LOGS/LOGS__Snapshot.robot
Resource    ../../LOGS/LOGS__Event_Log_Preservation_After_Reset.robot
Resource    ../../LOGS/LOGS__Event_Log_Creation_For_WebEM_Operation.robot
Resource    ../../LOGS/LOGS__Snapshot_collection_from_dual_core_with_re_establishing.robot
Resource    ../../LOGS/LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core.robot
Resource    ../../LOGS/LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10834_Skoda/commissioning/SCF_01_SBTS24R2.xml

${NETACT_LAB}    &{srnclab1028}

*** Test Cases ***
[1]Automated__LOGS__Snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    Set Library Search Order    LOGS__Snapshot
    [Timeout]    14400
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core
    [Setup]    Run Keywords    LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core
    ...    AND    Set Library Search Order    LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core
    [Timeout]    14400
    TC__LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core
    [Teardown]    Run Keywords    LOGS__LTE2866-A-n_Technical_log_collection_Snapshot_canceled_in_dual_core.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Event_Log_Preservation_After_Reset
    [Setup]    Run Keywords    LOGS__Event_Log_Preservation_After_Reset.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Event_Log_Preservation_After_Reset
    ...    AND    Set Library Search Order    LOGS__Event_Log_Preservation_After_Reset
    [Timeout]    14400
    TC__LOGS__Event_Log_Preservation_After_Reset.robot
    [Teardown]    Run Keywords    LOGS__Event_Log_Preservation_After_Reset.TC Teardown
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

[1]Automated__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Setup]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    ...    AND    Set Library Search Order    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Timeout]    14400
    TC__LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active
    [Teardown]    Run Keywords    LOGS__Snapshot_on_hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_started_after_link_with_NMS_active.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Setup]    Run Keywords    LOGS__Snapshot_collection_from_dual_core_with_re_establishing.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Timeout]    14400
    TC__LOGS__Snapshot_collection_from_dual_core_with_re_establishing
    [Teardown]    Run Keywords    LOGS__Snapshot_collection_from_dual_core_with_re_establishing.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
