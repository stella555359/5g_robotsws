*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    String
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/variables.robot

*** Variables ***
${TEST_MODELS_VDU_CELLS_ONAIR_TIMEOUT}=  60s
@{VDU_TDS_ALLOWED_HIST_ALARMS}=  faultId=4592, severity=warning
...                              faultId=4592, severity=minor
@{VCU_TDS_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__TEST_Cloud_TEST_Start_Stop_NR_TestModels
    [Arguments]  ${vdu_scfc_file_path}  ${test_model}  ${downlink_test_model}=NR-FR1-TM3.1
    ...  ${uplink_frc_index}=G-FR1-A1-5  ${pusch_frc_index}=G-FR1-A4-14  ${nrcell_id}=1
    ...  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case starts/stop selected test model on selected NR cell.
    ...  After test model is performed, the results are collected.
    ...  One of the test models can be performed:
    ...  - NR downlink
    ...  - NR uplink
    ...  - NR performance PUSCH
    ...  - NR performance PUCCH
    ...  - NR performance PRACH.
    ...  Test model parameters are defined in the test case.
    ...
    ...  Step 1: Preconditions Test Models
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: Enter To Test Dedicated State
    ...  a) vDU operation state is in test mode (operational_state=test)
    ...  Step 3: Start Test Model
    ...  a) Start selected Test Model
    ...  b) Get Test Model results
    ...  Step 4: Verify Test Model
    ...  a) Get running Test Models information
    ...  Step 5: Stop Test Model
    ...  a) Stop selected Test Model
    ...  b) Check BTS Reset Cause Alarm
    ...  Step 6: Exit From Test Dedicated State
    ...  a) Delete MRBTS-X/MNL-1/CMD-1/SWRESETREQ-1 object
    ...  b) vDU operation state is OnAir (operational_state=OnAir)
    ...  Step 7: Postconditions Test Models
    ...  a) The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | test_model             | Yes  | Test model that will be performed. One of 'nr_downlink', 'nr_uplink',      |
    ...  |                        |      | 'nr_performance_pusch', 'nr_performance_pucch', 'nr_performance_prach'     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | downlink_test_model    |  No  | Downlink test model if nr_downlink is selected, default NR-FR1-TM3.1.      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | uplink_frc_index       |  No  | Uplink FRC index if nr_uplink is selected, default G-FR1-A1-5.             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | pusch_frc_index        |  No  | FRC index if nr_performance_pusch is selected, default G-FR1-A4-14.        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrcell_id              | Yes  | NR cell id, e.g. 1.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${test_model}
    Set Test Variable  ${downlink_test_model}
    Set Test Variable  ${uplink_frc_index}
    Set Test Variable  ${pusch_frc_index}
    Set Test Variable  ${nrcell_id}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Start_Stop_NR_TestModels  console=${log_to_console}
    Step 1: Preconditions Test Models
    Step 2: Enter To Test Dedicated State
    Step 3: Start Test Model
    Step 4: Verify Test Model
    Step 5: Stop Test Model
    Step 6: Exit From Test Dedicated State
    Step 7: Postconditions Test Models
    Log  ${done_prefix_green}Test Case: Start_Stop_NR_TestModels  console=${log_to_console}
    [Teardown]  Start Stop NR TestModels Teardown

Step 1: Preconditions Test Models
    Log  ${dots_prefix_green}Step 1: Preconditions test models  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_TDS_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_TDS_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
# Wait until all radio modules are on line
    ${vdu_scfc_rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_rmods_count}
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    ${vdu_scfc_nrcells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${vdu_scfc_file_path}
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_scfc_nrcells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
# Get fault 4592 cancellation timer
    ${mrbts_id}=  vDU Get MRBTS Id
    ...  vdu_connection=${vdu_connection}
    ${timer_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ${cancellation_timer}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${timer_mo_dn}
    ...  para_name=fault4592CancellationTimer
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cancellation_timer}
# Get and set variables
    ${vdu_cells_id_dist_name_dict}=  vDU Cells Get Ids And Given Parameters Value
    ...  cell_param=dist_names
    ...  cell_sub_param=config
    ...  vdu_connection=${vdu_connection}
    ${cbts_tested_cell_config_dist_name}=  Get From Dictionary
    ...  dictionary=${vdu_cells_id_dist_name_dict}  key=${nrcell_id}
    ${phy_cell_id}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${cbts_tested_cell_config_dist_name}
    ...  para_name=physCellId
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${phy_cell_id}
    ${nrcell_fdd_mo_dn}=  Set Variable  ${cbts_tested_cell_config_dist_name}/NRCELL_FDD-1
    ${nrarfcndl}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${nrcell_fdd_mo_dn}
    ...  para_name=nrarfcnDl
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${nrarfcndl}
    ${nrarfcnul}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${nrcell_fdd_mo_dn}
    ...  para_name=nrarfcnUl
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${nrarfcnul}
    Log  ${ok_prefix_green}Step 1: Preconditions test models  console=${log_to_console}

Step 2: Enter To Test Dedicated State
    Log  ${dots_prefix_green}Step 2: Enter to Test Dedicated State  console=${log_to_console}
    Log  ${info_prefix}Waiting to enter into Test Dedicated State mode ...  console=${log_to_console}
# Enter Into TDS Mode
    vDU Enter Into TDS Mode
    ...  vdu_connection=${vdu_connection}
# Get Current vDU State
    ${vdu_operational_state}=  vDU Get Current State
    ...  vdu_state=operational_state
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_operational_state}
    Log  ${info_prefix}BTS is in Test Dedicated State mode (operational_state=${vdu_operational_state})  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: Enter to Test Dedicated State  console=${log_to_console}

Step 3: Start Test Model
    Log  ${dots_prefix_green}Step 3: Start Test Model  console=${log_to_console}
    ${test_model_string}=  Replace String   string=${test_model}  search_for=_  replace_with=${SPACE}
    ${test_model_string}=  Convert To Upper Case  string=${test_model_string}
    Set Test Variable  ${test_model_string}
    Log  ${info_prefix}Test model '${test_model_string}' has been started.  console=${log_to_console}
    Log  ${info_prefix}Test model '${test_model_string}' is running ...  console=${log_to_console}
# Start Test Model
    Run Keyword If  '${test_model}'=='nr_downlink'
    ...  Start NR Downlink Test Model
    ...  nrcell_id=${nrcell_id}
    ...  test_model=${downlink_test_model}
    ...  phys_cell_id=${phy_cell_id}
    ...  nrarfcn_dl=${nrarfcndl}
    ...  nrarfcn_ul=${nrarfcnul}
    ...  pmax=${FDD_PARAMS['downlink_p_max']}
    ...  vdu_connection=${vdu_connection}
    ...  ELSE IF  '${test_model}'=='nr_uplink'
    ...  Start NR Uplink Test Model
    ...  nrcell_id=${nrcell_id}
    ...  frc_index=${uplink_frc_index}
    ...  phys_cell_id=${phy_cell_id}
    ...  nrarfcn_dl=${nrarfcndl}
    ...  nrarfcn_ul=${nrarfcnul}
    ...  vdu_connection=${vdu_connection}
    ...  ELSE IF  '${test_model}'=='nr_performance_pusch'
    ...  Start NR Performance PUSCH Test Model
    ...  nrcell_id=${nrcell_id}
    ...  frc_index=${pusch_frc_index}
    ...  phys_cell_id=${phy_cell_id}
    ...  nrarfcn_dl=${nrarfcndl}
    ...  nrarfcn_ul=${nrarfcnul}
    ...  vdu_connection=${vdu_connection}
    ...  ELSE IF  '${test_model}'=='nr_performance_pucch'
    ...  Start NR Performance PUCCH Test Model
    ...  nrcell_id=${nrcell_id}
    ...  pucch_format=${FDD_PARAMS['pucch_format']}
    ...  phys_cell_id=${phy_cell_id}
    ...  nrarfcn_dl=${nrarfcndl}
    ...  nrarfcn_ul=${nrarfcnul}
    ...  num_pucch_symbol=${FDD_PARAMS['pucch_num_symbol']}
    ...  largest_prb_index=${FDD_PARAMS['pucch_largest_prb_index']}
    ...  vdu_connection=${vdu_connection}
    ...  ELSE IF  '${test_model}'=='nr_performance_prach'
    ...  Start NR Performance PRACH Test Model
    ...  nrcell_id=${nrcell_id}
    ...  prach_conf_index=${FDD_PARAMS['prach_configuration_index']}
    ...  phys_cell_id=${phy_cell_id}
    ...  nrarfcn_dl=${nrarfcndl}
    ...  nrarfcn_ul=${nrarfcnul}
    ...  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}Step 3: Start Test Model  console=${log_to_console}

Step 4: Verify Test Model
    Log  ${dots_prefix_green}Step 4: Verify Test Model  console=${log_to_console}
# Verify Test Model
    ${actual_test_model}=  vdu.Get Running Test Models
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${actual_test_model}
    Log  ${info_prefix}Running test model information:  console=${log_to_console}
    Log  ${below_info_prefix}NR cell id: ${actual_test_model[0]['nr_cell_id']}  console=${log_to_console}
    Log  ${below_info_prefix}Test model type: ${actual_test_model[0]['test_type']}  console=${log_to_console}
    Run Keyword If  '${actual_test_model[0]['test_type']}'=='Downlink'
    ...  Log  ${below_info_prefix}Test model: ${actual_test_model[0]['test_model']}  console=${log_to_console}
    ...  ELSE IF  '${actual_test_model[0]['test_type']}'=='Uplink'
    ...  Log  ${below_info_prefix}FRC index: ${actual_test_model[0]['frc_index']}  console=${log_to_console}
    ...  ELSE IF  '${actual_test_model[0]['test_type']}'=='Performance'
    ...  Log  ${below_info_prefix}Performance test type: ${actual_test_model[0]['performance_test_type']}  console=${log_to_console}
    Sleep  5s  reason=Additional test model duration time
    Log  ${info_prefix}Test model '${test_model_string}' duration has ended  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Verify Test Model  console=${log_to_console}

Step 5: Stop Test Model
    Log  ${dots_prefix_green}Step 5: Stop Test Model  console=${log_to_console}
# Stop Test Model
    Stop NR Test Model
    ...  test_model_type=${actual_test_model[0]['test_type']}
    ...  nrcell_id=${nrcell_id}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Test model '${test_model_string}' has been stopped  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Stop Stop Test Model  console=${log_to_console}

Step 6: Exit From Test Dedicated State
    Log  ${dots_prefix_green}Step 6: Exit from Test Dedicated State  console=${log_to_console}
    Log  ${info_prefix}Waiting to exit from Test Dedicated State mode ...  console=${log_to_console}
# Exit From TDS Mode
    vDU Exit From TDS Mode
    ...  activation_timeout=60s
    ...  cancellation_timeout=${cancellation_timer}
    ...  vdu_connection=${vdu_connection}
    ...  log_prefix=${info_prefix}
# Wait until all radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=60s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${TEST_MODELS_VDU_CELLS_ONAIR_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Delete MRBTS-X/MNL-1/CMD-1/SWRESETREQ-1 object
    ${cmd_object}=  vdu.Get Current Plan Objects  class_name=CMD
    ${swreset_dist_name}=  Set Variable  ${cmd_object['objects'][0]['distName']}/SWRESETREQ-1
    ${parameters_list}=  Create List
    vdu.Perform Object Recommissioning
    ...  dist_name=${swreset_dist_name}
    ...  parameter=${parameters_list}
    ...  operation=delete
    ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
# Get Current vDU State
    ${vdu_operational_state}=  vDU Get Current State
    ...  vdu_state=operational_state
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_operational_state}
    Log  ${info_prefix}vDU operational state is ${vdu_operational_state}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 6: Exit from Test Dedicated State  console=${log_to_console}

Step 7: Postconditions Test Models
    Log  ${dots_prefix_green}Step 7: Postconditions test models  console=${log_to_console}
# Wait until all radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: Postconditions test models  console=${log_to_console}

# INTERNAL TEST CASE KEYWORDS
Start Stop NR TestModels Teardown
    [Documentation]
    ...  Description:
    ...  Keyword performs tasks that clean up or restore initial values after the test is performed.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

# Exit From TDS Mode
    Run Keyword If  '${vdu_operational_state}'=='test'
    ...  vDU Exit From TDS Mode
    ...  activation_timeout=60s
    ...  cancellation_timeout=${cancellation_timer}
    ...  vdu_connection=${vdu_connection}
    ...  log_to_console=${False}
    Run Keyword And Ignore Error
    ...  vDU Rest Logout
    ...  vdu_connection=${vdu_connection}
