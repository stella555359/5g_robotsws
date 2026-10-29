*** Settings ***
Documentation    Test cases for Volkswagen 25R2
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_NLWG_10826_1ASIB_2ABIO_1ABIA_1ASIA_3ABIA_2FXDB_2AZQS_1FXED_1FRGU_1AHEH    SBTS25R2
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Snapshot_collection__triggered_by_multiple_fault_upload_to_NetAct_via_NE3S.robot
Resource          ../../LOGS/LOGS__Remote_snapshot_collection_via_cOAM_reject_as_remote_server_link_is_down.robot
Resource          ../../LOGS/LOGS__Snapshot_upload_to_external_server_long_link_break.robot
Resource          ../../LOGS/LOGS__CB010239-B_01_Full_DC_and_diagnostic_history_verification_via_WebEM_with_RMOD_removal.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10826_Volkswagen/commissioning/SCF_01_SBTS25R2.xml

${NETACT_LAB}    &{srnclab1028}

*** Test Cases ***
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

[1]Automated__LOGS__Snapshot_upload_to_external_server_long_link_break
    [Setup]    Run Keywords    LOGS__Snapshot_upload_to_external_server_long_link_break.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_upload_to_external_server_long_link_break
    ...    AND    Set Library Search Order    LOGS__Snapshot_upload_to_external_server_long_link_break
    [Timeout]    14400
    TC__LOGS__Snapshot_upload_to_external_server_long_link_break
    [Teardown]    Run Keywords    LOGS__Snapshot_upload_to_external_server_long_link_break.TC Teardown
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

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
