*** Settings ***
Documentation
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com
...    description: CRT test suite of feature CB009250

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/Alarms.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../resources/robot/IBW_modifications_to_other_OMs_in_both_directions.robot
Resource    ../resources/robot/Launch_Radio_Module_Troubleshooting_Script_Via_GUI.robot
Resource    ../resources/robot/Antenna_Online_Monitoring_using_WebEM_with_break.robot

Library     ../resources/python/RadioOperations.py   WITH NAME    radio_keywords
Library     ../resources/python/ScfObjectOperations.py   WITH NAME    scf_keywords
Library     ../resources/python/CellOperations.py  WITH NAME    cell_keywords

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   resources/deltas.py
Variables   resources/variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...                       increase_timeout_for_update_sw=${1800}
...                       list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...                       swconfig_from_path=${SWCONFIG_PATH}
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${SWCONFIG_PATH}

*** Test Cases ***
CB009250_ABIO_OM_One_Sector_1600MHz_IBW_modifications_to_other_OMs_in_both_directions
    [Setup]   Run Keywords
    ...       Common Preconditions With Watching Alarms
    ...       AND    Set Test Variable    ${logs_path}    ${LOG_PATH}
    ${RANDOM_NRCELLGRP_ID}=    cell_keywords.get_cell_group_ids    random_id=${True}
    ${SCF_SINGLE_NRCELLGRP}=    scf_keywords.get_scf_path_from_repository    prefix_tag=NRCELLGRP_${RANDOM_NRCELLGRP_ID}
    IBW_modifications_to_other_OMs_in_both_directions
    ...    ibw_reconfiguration_flow=${IBW_RECONFIGURATION_FLOW}
    ...    path_scf_one_sector=${SCF_SINGLE_NRCELLGRP}
    ...    path_scf_two_sectors=${scf_local_path}
    [Teardown]  Run Keywords
    ...         Common Postconditions With Watching Alarms
    ...         AND    Run Keyword If Test Failed    Restore gNB Configuration After Test
    ...         restore_only_if_not_onair=${False}

CB009250_CB008562_General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break
    Antenna_Online_Monitoring_using_WebEM_with_break
    ...    validation_data=${ANTENNA_MONITORING_VALIDATION_DATA}
    ...    dt_info=${SECTORS_DATA_TRANSFER_INFO_T01SK137}

CB009250_CB007042-5G-B_RF_IQ_data_capture_via_WebEM
    ${RU_SN}=    radio_keywords.get_radio_unit_serial_number    ru_id=${AWKUC_ID}
    Launch_Radio_Module_Troubleshooting_Script_Via_GUI
    ...    script_name=RU_Common_capture_IQ_data
    ...    rmods_name=${TBS_SCRIPT_RUS}
    ...    cells_name=all
    ...    dt_info=${SECTORS_DATA_TRANSFER_INFO_T01SK137}
    ...    regex_snapshot_name=SCRIPT_RESULT_RU_Common_capture_IQ_data_[\\d]{8}-[\\d]{4}.zip
    ...    regex_snapshot_content_name=${RU_SN}_RMOD_L_1_.*IQ_data
