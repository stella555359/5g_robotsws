*** Settings ***
Documentation    Procedures to run test under CB007938-An configruation block feature.
...              author: Magda Chrostek, magda.chrostek@nokia.com
...              maintainer: Magda Chrostek, magda.chrostek@nokia.com

Library     testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.resources.configurations_features.procedures.Procedures
...          WITH NAME      proc
Resource    taf/rfrl/bts/robot/gnb.robot
Variables    ./deltas.py

*** Variables ***
${log_dir}         /tmp/snap/

*** Keywords ***
CB007938_A_n_1_full_commissioning_with_l3_call
    [Arguments]     ${scf_file}
    Perform Full Commissioning on gNB     ${scf_file}        skip_parameter_relation_errors=${True}     validate_scf=${False}
    Cell setup and onAir

CB007938_A_n_2_configuration_reset_and_commissioning
    [Arguments]     ${scf_file}
    Verify gNB is onAir
    Perform gNB configuration reset
    Verify gNB is Not Commissioned
    proc.bts_commissioning     ${scf_file}     skip_parameter_relation_errors=True      timeout=300
    ...           should_activate=True     validate_scf=False     du_id=0
    Cell setup and onAir

CB007938_A_n_5_state_management_rmod_lock_unlock_with_ongoing_l3_call
    [Arguments]     ${ue_radio_number}
    Verify gNB is onAir
    proc.lock_radios     ${ue_radio_number}
    proc.unlock_radios     ${ue_radio_number}
    Wait Until Keyword Succeeds  200 sec   50 sec    Verify Cells      ${cell_type}

CB007938_A_n_6_state_management_cell_lock_unlock_with_ongoing_l3_call
    [Arguments]     ${cell_type}        ${ue_cell_number}
    Verify gNB is onAir
    proc.block_cell        ${cell_type}           ${ue_cell_number}
    ${msg}      Run Keyword and Expect Error      *           Verify Cells     ${cell_type}
    proc.unblock_cell      ${cell_type}           ${ue_cell_number}
    Wait Until Keyword Succeeds  200 sec   50 sec    Verify Cells     ${cell_type}

CB007938_A_n_7_state_management_sbts_lock_unlock
    [Arguments]     ${rat}      ${cell_type}
    Verify gNB is onAir
    proc.block_sbts      ${rat}
    ${msg}      Run Keyword and Expect Error      *           Verify Cells     ${cell_type}
    Log         ${msg}
    proc.unblock_sbts       ${rat}
    Wait Until Keyword Succeeds  200 sec   50 sec    Verify Cells    ${cell_type}

CB007938_A_n_8_state_management_sbts_reset
    Verify gNB is onAir
    Reset gNB
    Cell setup and onAir

CB007938_A_n_9_state_management_rmod_reset_with_ongoing_l3_call
    [Arguments]     ${ue_radio_number}
    Verify gNB is onAir
    proc.reset_radios     ${ue_radio_number}
    Wait Until Keyword Succeeds  200 sec   50 sec    Verify Cells     ${cell_type}

CB007938_A_n_10_testability_log_collection_on_rmod
    [Arguments]    ${mandatory_logs}=${None}
    Run Keyword And Ignore Error       proc.remove_files       ${log_dir}
    Verify gNB is onAir
    Collect Snapshot From gNB      ${log_dir}
    ${path}    proc.determine_snapshot_path      ${log_dir}
    Find Mandatory RFSW Logs in gNB Snapshot      ${path}    ${mandatory_logs}

Cell setup and onAir
    Wait Until Keyword Succeeds  900 sec   100 sec    Verify If All Radio Modules Online
    Wait Until Keyword Succeeds  300 sec   50 sec    Verify Cells     ${cell_type}
    Wait Until Keyword Succeeds  200 sec   50 sec    Verify gNB is onAir

Verify Cells
    [Arguments]     ${cell_type}
    ${status}        proc.verify_there_is_no_disabled_cells      ${cell_type}
    Should Be True       ${status}

Manual_SiSo_CM_Recommissioning
    [Arguments]     ${cell_type}
    Verify gNB is onAir
    Perform Delta Commissioning On gNB  ${delta_lte4_prachConfig}
    Wait Until Keyword Succeeds  200 sec   50 sec    Verify Cells     ${cell_type}
    Perform Delta Commissioning On gNB  ${delta_lte4_prachConfig_backup}
    Wait Until Keyword Succeeds  200 sec   50 sec    Verify Cells     ${cell_type}
    Perform Delta Commissioning On gNB  ${delta_lte14_prachConfig}
    Wait Until Keyword Succeeds  200 sec   50 sec    Verify Cells     ${cell_type}
    Perform Delta Commissioning On gNB  ${delta_lte14_prachConfig_backup}
    Wait Until Keyword Succeeds  200 sec   50 sec    Verify Cells     ${cell_type}
