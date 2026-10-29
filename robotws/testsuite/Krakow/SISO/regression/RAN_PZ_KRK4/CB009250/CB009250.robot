*** Settings ***
Documentation
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com
...    description: CRT test suite of feature CB009250

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource    taf/rfrl/procedures/resources/robot/Alarms.robot
Resource    ../resources/robot/Cell_Block_And_Unblock.robot
Resource    ../resources/robot/Online_Sector_Addition_Deletion.robot
Resource    ../resources/robot/IBW_modifications_to_other_OMs_in_both_directions.robot
Resource    ../resources/robot/Launch_Radio_Module_Troubleshooting_Script_Via_GUI.robot
Resource    ../resources/robot/Antenna_Online_Monitoring_using_WebEM_with_break.robot
Resource    ../resources/robot/RF_Module_Trigger_Faults_4590_EFaultId_CrashOrFailureSignatureAl.robot
Resource    ../resources/robot/Switching_On_Cell_NR.robot

Library     ../resources/python/RadioOperations.py   WITH NAME    radio_keywords
Library     ../resources/python/ScfObjectOperations.py   WITH NAME    scf_keywords
Library     ../resources/python/antenna_monitoring_validator.py   WITH NAME    validator

Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   resources/deltas.py
Variables   resources/variables.py

Suite Setup     Run Keywords
...             gnbbbu.upload_swconfig  sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt
...             AND    Common Suite Setup With Commissioning
Suite Teardown  Common Suite Teardown
Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Test Cases ***
CB009250_General_SiSo_Cell_block_and_unblock
    Cell_Block_And_Unblock    dt_info=${SECTORS_DATA_TRANSFER_INFO_T01SK127}
    [Teardown]  Run Keywords
    ...         Common Postconditions With Watching Alarms
    ...         AND    Run Keyword If Test Failed    Restore gNB Configuration After Test
    ...         restore_only_if_not_onair=${False}

CB009250_General_SiSo_Online_Sector_Addition_Deletion
    [Setup]   Run Keywords
    ...       Common Preconditions With Watching Alarms
    ...       AND    Set Test Variable    ${logs_path}    ${LOG_PATH}
    ${SCF_1_SECTOR}=    scf_keywords.get_scf_path_from_repository    prefix_tag=1_SECTOR
    Online_Sector_Addition_Deletion
    ...    path_scf_base_sector=${SCF_1_SECTOR}
    ...    path_scf_added_sector=${scf_local_path}
    ...    base_sector_dt=${SECTORS_DATA_TRANSFER_INFO_T01SK127['SECTOR_0']}
    ...    added_sector_dt=${SECTORS_DATA_TRANSFER_INFO_T01SK127['SECTOR_1']}
    [Teardown]  Run Keywords
    ...         Common Postconditions With Watching Alarms
    ...         AND    Run Keyword If Test Failed    Restore gNB Configuration After Test
    ...         restore_only_if_not_onair=${False}

CB009250_ABIO_OM_One_Sector_1600MHz_IBW_modifications_to_other_OMs_in_both_directions
    [Setup]   Run Keywords
    ...       Common Preconditions With Watching Alarms
    ...       AND    Set Test Variable    ${logs_path}    ${LOG_PATH}
    ${SCF_1_SECTOR}=    scf_keywords.get_scf_path_from_repository    prefix_tag=1_SECTOR
    IBW_modifications_to_other_OMs_in_both_directions
    ...    ibw_reconfiguration_flow=${IBW_RECONFIGURATION_FLOW}
    ...    path_scf_one_sector=${SCF_1_SECTOR}
    ...    path_scf_two_sectors=${scf_local_path}
    [Teardown]  Run Keywords
    ...         Common Postconditions With Watching Alarms
    ...         AND    Run Keyword If Test Failed    Restore gNB Configuration After Test
    ...         restore_only_if_not_onair=${False}

CB009250_CB008745_Switching_On_Cell_NR
    Switching_On_Cell_NR
    ...    cell_id=8
    ...    dt_info=${SECTORS_DATA_TRANSFER_INFO_T01SK127['SECTOR_0']}
    ...    delta_enable_power_saving=${DELTA_ACTIVATE_POWER_SAVING['GNB0']}
    ...    delta_disable_power_saving=${DELTA_DEACTIVATE_POWER_SAVING['GNB0']}
    ...    path_delta_nrpgrp=${CURDIR}/resources/delta_custom_nrpgrp_switching_on_cell_nr.json

CB009250_CB008562_General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break
    Antenna_Online_Monitoring_using_WebEM_with_break
    ...    validation_data=${ANTENNA_MONITORING_VALIDATION_DATA}
    ...    dt_info=${SECTORS_DATA_TRANSFER_INFO_T01SK127}

CB009250_CB007273_Faults_4590_EFaultId_CrashOrFailureSignatureAl
    RF_Module_Trigger_Faults_4590_EFaultId_CrashOrFailureSignatureAl
    ...    delta_act_category_alarms_and_signatures=${DELTA_ACTIVATE_CATEGORY_ALARMS_AND_SIGNATURES['GNB0']}

CB009250_CB007042-5G-B_RF_IQ_data_capture_via_WebEM
    ${RU_SN}=    radio_keywords.get_radio_unit_serial_number    ru_id=${AWKUC_ID}
    Launch_Radio_Module_Troubleshooting_Script_Via_GUI
    ...    script_name=RU_Common_capture_IQ_data
    ...    rmods_name=${TBS_SCRIPT_RUS}
    ...    cells_name=all
    ...    dt_info=${SECTORS_DATA_TRANSFER_INFO_T01SK127}
    ...    regex_snapshot_name=SCRIPT_RESULT_RU_Common_capture_IQ_data_[\\d]{8}-[\\d]{4}.zip
    ...    regex_snapshot_content_name=${RU_SN}_RMOD_L_1_.*IQ_data

CB009250_CB007042-5G-B_Register_dump_capture_via_WebEM
    ${RU_SN}=    radio_keywords.get_radio_unit_serial_number    ru_id=${AWKUC_ID}
    Launch_Radio_Module_Troubleshooting_Script_Via_GUI
    ...    script_name=RU_Common_capture_register_dump
    ...    rmods_name=${TBS_SCRIPT_RUS}
    ...    cells_name=all
    ...    dt_info=${SECTORS_DATA_TRANSFER_INFO_T01SK127}
    ...    regex_snapshot_name=SCRIPT_RESULT_RU_Common_capture_register_dump_[\\d]{8}-[\\d]{4}.zip
    ...    regex_snapshot_content_name=${RU_SN}_RMOD_L_1.*register_dump
