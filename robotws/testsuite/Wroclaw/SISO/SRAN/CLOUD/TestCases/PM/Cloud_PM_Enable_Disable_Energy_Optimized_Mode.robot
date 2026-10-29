*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/Robot/L3_call.robot

*** Variables ***
# Maximum time to wait for complete lock RMOD operation
${RMOD_LOCK_MAX_WAIT_TIME}=    300s
# Maximum time to wait for complete unlock RMOD operation
${RMOD_UNLOCK_MAX_WAIT_TIME}=  300s
# Allowed test case historical alarms
@{VCU_ENERGY_OPTIMIZED_MODE_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_PM_Enable_Disable_Energy_Optimized_Mode
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_rmod_sn_list}=@{EMPTY}  ${cells_yaml_path_first}=${EMPTY}
    ...  ${cells_yaml_path_second}=${EMPTY}  ${cell_ids}=@{EMPTY}  ${make_call}=${False}
    ...  ${verify_power}=${False}  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-26185
    ...  Feature: CB014375 - Energy optimized mode for Pandion RRH
    ...  This feature will introduce energy efficiency mode for Airscale radios where radio EVM
    ...  is adjusted optimally considering Energy efficiency and high traffic cases.
    ...  Feature is limited to AHPMDG and AHEGHA radio modules for CPRI only.
    ...  - actParConfigurationMode:
    ...    This parameter controls the PAR (Peak to Average Ratio) configuration mode of the AirScale radio module.
    ...    - StandardMode: Default mode. Radio module in the normal mode, without any power saving.
    ...    - MaxEnergyEfficiency: Radio module supports PAR configuration mode,
    ...      radio module in the energy efficiency mode If it is configured.
    ...  The current state of PAR configuration mode mode in the radio module is informed via RMOD_R.parConfigurationModeState parameter.
    ...  - parConfigurationModeState:
    ...    This parameter shows the state of PAR (Peak to Average Ratio) configuration mode of the radio module (Disabled/Enabled).
    ...  During test execution the following precondition parameter will be updated:
    ...  - actPowerMeter=true
    ...
    ...  Step 1: Preconditions Enable Disable Energy Optimized Mode
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: Activate Initial Features Energy Optimized Mode
    ...  a) PAR configuration mode parameter checking
    ...  b) Energy efficiency monitoring feature checking (actPowerMeter=true)
    ...  Step 3: Make Call Before Enabling Energy Optimized Mode
    ...  Step 4: Check Radio Module Power Before Enabling Energy Optimized Mode
    ...  Step 5: Enable Energy Efficiency Mode
    ...  a) Lock radio module to deactivate carriers
    ...  b) Setting parameter to activate energy efficiency mode for radio module
    ...  c) Check state of PAR configuration mode of the radio module
    ...  d) Unlock radio module to activate carriers
    ...  e) Check if all cells are OnAir
    ...  Step 6: Make Call After Enabling Energy Optimized Mode
    ...  Step 7: Check Radio Module Power After Enabling Energy Optimized Mode
    ...  a) Verify power before and after feature activation
    ...  Step 8: Disable Energy Efficiency Mode
    ...  a) Lock radio module to deactivate carriers
    ...  b) Setting parameter to deactivate energy efficiency mode for radio module
    ...  c) Check state of PAR configuration mode of the radio module
    ...  d) Unlock radio module to activate carriers
    ...  Step 9: Deactivate Initial Features Energy Optimized Mode
    ...  a) Deactivate energy efficiency monitoring feature
    ...  Step 10: Postconditions Enable Disable Energy Optimized Mode
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  No unexpected alarms are visible

    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_list      |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_ids               | Yes  | List of cells ids for call NR->nr_cell_identity LTE->eutranCellId          |
    ...  |                        |      | If @{EMPTY} set, it means all cells will be called                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cells_yaml_path_first  | Yes  | Path to the yaml file with cells parameters before feature activation.     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cells_yaml_path_second | Yes  | Path to the yaml file with cells parameters after feature activation.      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | make_call              |  No  | Make call or not.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | verify_power           |  No  | Verify power before and after enabling energy optimized mode.              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${cbts_rmod_sn_list}
    Set Test Variable  ${cell_ids}
    Set Test Variable  ${cells_yaml_path_first}
    Set Test Variable  ${cells_yaml_path_second}
    Set Test Variable  ${make_call}
    Set Test Variable  ${verify_power}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Enable_Disable_Energy_Optimized_Mode  console=${log_to_console}
    Step 1: Preconditions Enable Disable Energy Optimized Mode
    FOR  ${cbts_tested_rmod_sn}  IN  @{cbts_rmod_sn_list}
      Set Test Variable  ${cbts_tested_rmod_sn}
      Step 2: Activate Initial Features Energy Optimized Mode
      Step 3: Make Call Before Enabling Energy Optimized Mode
      Step 4: Check Radio Module Power Before Enabling Energy Optimized Mode
      Step 5: Enable Energy Efficiency Mode
      Step 6: Make Call After Enabling Energy Optimized Mode
      Step 7: Check Radio Module Power After Enabling Energy Optimized Mode
      Step 8: Disable Energy Efficiency Mode
      Step 9: Deactivate Initial Features Energy Optimized Mode
    END
    Step 10: Postconditions Enable Disable Energy Optimized Mode
    Log  ${done_prefix_green}Test Case: Enable_Disable_Energy_Optimized_Mode  console=${log_to_console}
    [Teardown]  Enable Disable Energy Optimized Mode Teardown  tc_status=${KEYWORD_STATUS}

Step 1: Preconditions Enable Disable Energy Optimized Mode
    Log  ${dots_prefix_green}Step 1:Preconditions enable disable energy optimized mode  console=${log_to_console}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_ENERGY_OPTIMIZED_MODE_ALLOWED_HIST_ALARMS}
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
# Get and set variables
    ${cbts_rmod_sn_config_dn_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=dist_names
    ...  rmod_sub_param=config
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_config_dn_dict}
    ${cbts_rmod_sn_realtime_dn_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=dist_names
    ...  rmod_sub_param=runtime
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_realtime_dn_dict}
    ${cbts_rmod_sn_conf_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=configuration_id
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_conf_id_dict}
    ${cbts_rmod_sn_cells_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=cell_ids
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_cells_id_dict}
    ${vdu_cells_id_dist_name_dict}=  vDU Cells Get Ids And Given Parameters Value
    ...  cell_param=dist_names
    ...  cell_sub_param=config
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_cells_id_dist_name_dict}
    ${vdu_cells_id_identity_dict}=  vDU Cells Get Identity And Id
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_cells_id_identity_dict}
    ${mrbts_id}=  vDU Get MRBTS Id
    Set Test Variable  ${mrbts_id}
    ${vdu_scfc_nrcell_id_list}=  vDU SCFC Get NRCELL Id List  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_nrcell_id_list}
# Set cells states
    ${cbts_impacted_cell_state_dict}=  Create Dictionary  availabilityStatus=dependency
    ...  operationalState=disabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_impacted_cell_state_dict}
    ${cbts_unimpacted_cell_state_dict}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_unimpacted_cell_state_dict}
    Log  ${ok_prefix_green}Step 1:Preconditions enable disable energy optimized mode  console=${log_to_console}

Step 2: Activate Initial Features Energy Optimized Mode
    Log  ${dots_prefix_green}Step 2: Activate initial features energy optimized mode  console=${log_to_console}
    ${cbts_rmod_conf_id}=  Get From Dictionary  dictionary=${cbts_rmod_sn_conf_id_dict}  key=${cbts_tested_rmod_sn}
    ${cbts_rmod_conf_id}=  Convert To String  item=${cbts_rmod_conf_id}
    ${cbts_block_rmods_conf_id_list}=  Create List  ${cbts_rmod_conf_id}
    Set Test Variable  ${cbts_block_rmods_conf_id_list}
    ${cbts_tested_rmod_realtime_dn}=  Get From Dictionary
    ...  dictionary=${cbts_rmod_sn_realtime_dn_dict}
    ...  key=${cbts_tested_rmod_sn}
    Set Test Variable  ${cbts_tested_rmod_realtime_dn}
# PAR configuration mode parameter checking (actParConfigurationMode=StandardMode)
    Log  ${info_prefix}PAR configuration mode parameter checking  console=${log_to_console}
    ${cbts_tested_rmod_conf_dn}=  Get From Dictionary
    ...  dictionary=${cbts_rmod_sn_config_dn_dict}
    ...  key=${cbts_tested_rmod_sn}
    Set Test Variable  ${cbts_tested_rmod_conf_dn}
    ${actparconfigurationmode_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${cbts_tested_rmod_conf_dn}
    ...  para_name=actParConfigurationMode
    Log  ${below_info_prefix}actParConfigurationMode: ${actparconfigurationmode_value}  console=${log_to_console}
    IF  '${actparconfigurationmode_value}'=='MaxEnergyEfficiency'
      Log  ${info_prefix}Initial deactivating energy efficiency mode  console=${log_to_console}
      Log  ${below_info_prefix}Lock radio module (sn: ${cbts_tested_rmod_sn}) to deactivate carriers
      ...  console=${log_to_console}
      Lock Radio Module Enable Disable Energy Optimized Mode
      Log  ${below_info_prefix}Recommissioning PAR configuration mode parameter is needed. Please wait ...  console=${log_to_console}
      vdu.Perform Parameter Recommissioning  dist_name=${cbts_tested_rmod_conf_dn}  parameter=actParConfigurationMode
      ...  operation=update  value=StandardMode  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
      ${actparconfigurationmode_value}=  vdu.Search Parameter Of Current Plan
      ...  mo_dn=${cbts_tested_rmod_conf_dn}
      ...  para_name=actParConfigurationMode
      Log  ${below_info_prefix}actParConfigurationMode: ${actparconfigurationmode_value}  console=${log_to_console}
      ${parconfigurationmodestate_value}=  vdu.Search Parameter Of Current Plan
      ...  mo_dn=${cbts_tested_rmod_realtime_dn}
      ...  para_name=parConfigurationModeState
      Log  ${below_info_prefix}parConfigurationModeState: ${parconfigurationmodestate_value}  console=${log_to_console}
      Log  ${below_info_prefix}Unlock radio module (sn: ${cbts_tested_rmod_sn}) to activate carriers
      ...  console=${log_to_console}
      Unlock Radio Module Enable Disable Energy Optimized Mode
      IF  '${parconfigurationmodestate_value}'=='Disabled'
        Log  ${info_prefix}Energy efficiency mode for radio module (sn: ${cbts_tested_rmod_sn}) has been deactivated
        ...  console=${log_to_console}
      ELSE
        Log  ${info_prefix}Energy efficiency mode for radio module (sn: ${cbts_tested_rmod_sn}) has not been deactivated !!! ${failed_result}
        ...  console=${log_to_console}
        Fail  msg=${failed_result}Energy efficiency mode for radio module (sn: ${cbts_tested_rmod_sn}) has not been deactivated !!!
      END
    END
# Energy efficiency monitoring feature checking (actPowerMeter=true)
    Log  ${info_prefix}Energy efficiency monitoring feature checking  console=${log_to_console}
    ${actpowermeter_dist_name}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${actpowermeter_initial_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${actpowermeter_dist_name}
    ...  para_name=actPowerMeter
    Log  ${below_info_prefix}actPowerMeter: ${actpowermeter_initial_value}  console=${log_to_console}
    Set Test Variable  ${actpowermeter_initial_value}
    IF  '${actpowermeter_initial_value}'=='false'
      Log  ${below_info_prefix}Recommissioning energy efficiency monitoring parameter is needed. Please wait ...
      ...  console=${log_to_console}
      vdu.Perform Parameter Recommissioning  dist_name=${actpowermeter_dist_name}  parameter=actPowerMeter
      ...  operation=update  value=true  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
      ${actpowermeter_value}=  vdu.Search Parameter Of Current Plan
      ...  mo_dn=${actpowermeter_dist_name}
      ...  para_name=actPowerMeter
      Log  ${below_info_prefix}actPowerMeter: ${actpowermeter_value}  console=${log_to_console}
      Log  ${info_prefix}Energy efficiency monitoring has been activated  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 2: Activate initial features energy optimized mode  console=${log_to_console}

Step 3: Make Call Before Enabling Energy Optimized Mode
    Log  ${dots_prefix_green}Step 3: Make call before enabling energy optimized mode  console=${log_to_console}
    IF  ${make_call}
      Cloud L3 Call  scfc_file_path=${vdu_scfc_file_path}  cells_yaml_path=${cells_yaml_path_first}  cells_input=${cell_ids}
    ELSE
      Log  ${info_prefix}Call disabled by user  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 3: Make call before enabling energy optimized mode  console=${log_to_console}

Step 4: Check Radio Module Power Before Enabling Energy Optimized Mode
    Log  ${dots_prefix_green}Step 4: Check radio module power before enabling energy optimized mode  console=${log_to_console}
    Log  ${info_prefix}Wait for power measurement (5 minutes) ...  console=${log_to_console}
    Sleep  300s
    ${cbts_tested_rmod_real_time_measurements_dict}=  vdu.Get Real Time Measurements
    ...  rmods_runtime_distnames=${cbts_tested_rmod_realtime_dn}
    ...  timeout=30
    ...  vdu_connection=${vdu_connection}
    ${cbts_tested_rmod_real_time_measurements_list}=  Get Dictionary Values  dictionary=${cbts_tested_rmod_real_time_measurements_dict}
    ${cbts_tested_rmod_power_first}=  Set Variable  ${cbts_tested_rmod_real_time_measurements_list[0][-1]['power']}
    Set Test Variable  ${cbts_tested_rmod_power_first}
    Log  ${info_prefix}Radio module power (sn: ${cbts_tested_rmod_sn}) before enable energy optimized mode: ${cbts_tested_rmod_power_first}
    ...  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Check radio module power before enabling energy optimized mode  console=${log_to_console}

Step 5: Enable Energy Efficiency Mode
    Log  ${dots_prefix_green}Step 5: Enable energy efficiency mode  console=${log_to_console}
# Lock radio module to deactivate carriers
    Log  ${info_prefix}Lock radio module (sn: ${cbts_tested_rmod_sn}) to deactivate carriers
    ...  console=${log_to_console}
    Lock Radio Module Enable Disable Energy Optimized Mode
# Setting parameter to activate energy efficiency mode for radio module (actParConfigurationMode=MaxEnergyEfficiency)
    Log  ${info_prefix}Setting parameter to activate energy efficiency mode for radio module (sn: ${cbts_tested_rmod_sn}). Please wait ...
    ...  console=${log_to_console}
    vdu.Perform Parameter Recommissioning  dist_name=${cbts_tested_rmod_conf_dn}  parameter=actParConfigurationMode
    ...  operation=update  value=MaxEnergyEfficiency  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${actparconfigurationmode_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${cbts_tested_rmod_conf_dn}
    ...  para_name=actParConfigurationMode
    Log  ${below_info_prefix}actParConfigurationMode: ${actparconfigurationmode_value}  console=${log_to_console}
# Check state of PAR configuration mode of the radio module  (parConfigurationModeState=Enabled)
    Log  ${info_prefix}Check state of PAR (Peak to Average Ratio) configuration mode of the radio module (sn: ${cbts_tested_rmod_sn})
    ...  console=${log_to_console}
    ${parconfigurationmodestate_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${cbts_tested_rmod_realtime_dn}
    ...  para_name=parConfigurationModeState
    Log  ${below_info_prefix}parConfigurationModeState: ${parconfigurationmodestate_value}  console=${log_to_console}
# Unlock radio module to activate carriers
    Log  ${info_prefix}Unlock radio module (sn: ${cbts_tested_rmod_sn}) to activate carriers
    ...  console=${log_to_console}
    Unlock Radio Module Enable Disable Energy Optimized Mode
# Check if all CBTS cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    IF  '${parconfigurationmodestate_value}'=='Enabled'
      Log  ${info_prefix}Energy efficiency mode for radio module (sn: ${cbts_tested_rmod_sn}) has been activated
      ...  console=${log_to_console}
    ELSE
      Log  ${info_prefix}Energy efficiency mode for radio module (sn: ${cbts_tested_rmod_sn}) has not been activated !!! ${failed_result}
      ...  console=${log_to_console}
      Fail  msg=${failed_result}Energy efficiency mode for radio module (sn: ${cbts_tested_rmod_sn}) has not been activated !!!
    END
    Log  ${ok_prefix_green}Step 5: Enable energy efficiency mode  console=${log_to_console}

Step 6: Make Call After Enabling Energy Optimized Mode
    Log  ${dots_prefix_green}Step 6: Make call after enabling energy optimized mode  console=${log_to_console}
    IF  ${make_call}
      Cloud L3 Call  scfc_file_path=${vdu_scfc_file_path}  cells_yaml_path=${cells_yaml_path_second}  cells_input=${cell_ids}
    ELSE
      Log  ${info_prefix}Call disabled by user  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 6: Make call after enabling energy optimized mode  console=${log_to_console}

Step 7: Check Radio Module Power After Enabling Energy Optimized Mode
    Log  ${dots_prefix_green}Step 7: Check radio module power after enabling energy optimized mode  console=${log_to_console}
    Log  ${info_prefix}Wait for power measurement (5 minutes) ...  console=${log_to_console}
    Sleep  300s
    ${cbts_tested_rmod_real_time_measurements_dict}=  vdu.Get Real Time Measurements
    ...  rmods_runtime_distnames=${cbts_tested_rmod_realtime_dn}
    ...  timeout=30
    ...  vdu_connection=${vdu_connection}
    ${cbts_tested_rmod_real_time_measurements_list}=  Get Dictionary Values  dictionary=${cbts_tested_rmod_real_time_measurements_dict}
    ${cbts_tested_rmod_power_second}=  Set Variable  ${cbts_tested_rmod_real_time_measurements_list[0][-1]['power']}
    Log  ${info_prefix}Radio module power (sn: ${cbts_tested_rmod_sn}) after enable energy optimized mode: ${cbts_tested_rmod_power_second}
    ...  console=${log_to_console}
# Verify power before and after feature activation
    IF  ${verify_power}
      Log  ${info_prefix}Radio module power (sn: ${cbts_tested_rmod_sn}) verification  console=${log_to_console}
      ${percentage_diff}=  Evaluate  expression=round((${cbts_tested_rmod_power_first}-(${cbts_tested_rmod_power_first}*0.1)), 4)
      IF  ${cbts_tested_rmod_power_first}>${cbts_tested_rmod_power_second} and ${cbts_tested_rmod_power_second}>${percentage_diff}
        Log  ${below_info_prefix}Radio module power (sn: ${cbts_tested_rmod_sn}) verification is OK  console=${log_to_console}
      ELSE IF  ${cbts_tested_rmod_power_first}<${cbts_tested_rmod_power_second}
        Log  ${below_info_prefix}Radio module power (sn: ${cbts_tested_rmod_sn}) verification is not OK. Power is higher ${failed_result}
        ...  console=${log_to_console}
        Run Keyword And Continue On Failure
        ...  Fail  msg=${failed_result}Radio module power (sn: ${cbts_tested_rmod_sn}) verification is not OK. Power is higher !!!
      ELSE IF  ${cbts_tested_rmod_power_second}<${percentage_diff}
        Log  ${below_info_prefix}Radio module power (sn: ${cbts_tested_rmod_sn}) verification is not OK. Power is too low ${failed_result}
        ...  console=${log_to_console}
        Run Keyword And Continue On Failure
        ...  Fail  msg=${failed_result}Radio module power (sn: ${cbts_tested_rmod_sn}) verification is not OK. Power is too low !!!
      END
    ELSE
        Log  ${info_prefix}Power verification disabled by user  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 7: Check radio module power after enabling energy optimized mode  console=${log_to_console}

Step 8: Disable Energy Efficiency Mode
    Log  ${dots_prefix_green}Step 8: Disable energy efficiency mode  console=${log_to_console}
# Lock radio module to deactivate carriers
    Log  ${info_prefix}Lock radio module (sn: ${cbts_tested_rmod_sn}) to deactivate carriers
    ...  console=${log_to_console}
    Lock Radio Module Enable Disable Energy Optimized Mode
# Setting parameter to deactivate energy efficiency mode for radio module (actParConfigurationMode=StandardMode)
    Log  ${info_prefix}Setting parameter to deactivate energy efficiency mode for radio module (sn: ${cbts_tested_rmod_sn}). Please wait ...
    ...  console=${log_to_console}
    vdu.Perform Parameter Recommissioning  dist_name=${cbts_tested_rmod_conf_dn}  parameter=actParConfigurationMode
    ...  operation=update  value=StandardMode  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${actparconfigurationmode_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${cbts_tested_rmod_conf_dn}
    ...  para_name=actParConfigurationMode
    Log  ${below_info_prefix}actParConfigurationMode: ${actparconfigurationmode_value}  console=${log_to_console}
# Check state of PAR configuration mode of the radio module  (parConfigurationModeState=Enabled)
    Log  ${info_prefix}Check state of PAR (Peak to Average Ratio) configuration mode of the radio module (sn: ${cbts_tested_rmod_sn})
    ...  console=${log_to_console}
    ${parconfigurationmodestate_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${cbts_tested_rmod_realtime_dn}
    ...  para_name=parConfigurationModeState
    Log  ${below_info_prefix}parConfigurationModeState: ${parconfigurationmodestate_value}  console=${log_to_console}
# Unlock radio module to activate carriers
    Log  ${info_prefix}Unlock radio module (sn: ${cbts_tested_rmod_sn}) to activate carriers
    ...  console=${log_to_console}
    Unlock Radio Module Enable Disable Energy Optimized Mode
    IF  '${parconfigurationmodestate_value}'=='Disabled'
      Log  ${info_prefix}Energy efficiency mode for radio module (sn: ${cbts_tested_rmod_sn}) has been deactivated
      ...  console=${log_to_console}
    ELSE
      Log  ${info_prefix}Energy efficiency mode for radio module (sn: ${cbts_tested_rmod_sn}) has not been deactivated !!! ${failed_result}
      ...  console=${log_to_console}
      Fail  msg=${failed_result}Energy efficiency mode for radio module (sn: ${cbts_tested_rmod_sn}) has not been deactivated !!!
    END
# Check if all CBTS cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 8: Disable energy efficiency mode  console=${log_to_console}

Step 9: Deactivate Initial Features Energy Optimized Mode
    Log  ${dots_prefix_green}Step 9: Deactivate initial features energy optimized mode  console=${log_to_console}
# Deactivate energy efficiency monitoring feature (actPowerMeter=false)
    ${actpowermeter_dist_name}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    IF  '${actpowermeter_initial_value}'=='false'
      Log  ${info_prefix}Deactivate energy efficiency monitoring feature. Please wait ...  console=${log_to_console}
      vdu.Perform Parameter Recommissioning  dist_name=${actpowermeter_dist_name}  parameter=actPowerMeter
      ...  operation=update  value=false  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
      Log  ${info_prefix}Energy efficiency monitoring has been deactivated  console=${log_to_console}
    ELSE
      Log  ${info_prefix}Deactivation not needed  console=${log_to_console}
    END
    ${actpowermeter_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${actpowermeter_dist_name}
    ...  para_name=actPowerMeter
    Log  ${below_info_prefix}actPowerMeter: ${actpowermeter_value}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 9: Deactivate initial features energy optimized mode  console=${log_to_console}

Step 10: Postconditions Enable Disable Energy Optimized Mode
    Log  ${dots_prefix_green}Step 10: Postconditions enable disable energy optimized mode  console=${log_to_console}
# Wait until all radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=10s
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
    Log  ${ok_prefix_green}Step 10: Postconditions enable disable energy optimized mode  console=${log_to_console}

#INTERNAL TEST CASE KEYWORDS
Lock Radio Module Enable Disable Energy Optimized Mode
    [Documentation]
    ...  Description:
    ...  Keyword lock radio module to deactivate carriers.
    ...  Reason (from CFAM):
    ...	 Feature CB014375 will not be activated until all the cells are disabled in radio or radio module locked.
    ...	 If enabling of feature CB014375 when no carrier is configured on radio,
    ...  then radio will enable energy efficiency mode immediately.
    ...  This will take effect when carriers are activated and this affects all carriers.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

# Lock radio module
    ${lock_result}=  vdu.Lock Rmods
    ...  rmod_id_list=${cbts_block_rmods_conf_id_list}
    ...  vdu_connection=${vdu_connection}
# Wait for radio module lock expected status
    RMOD Lock Wait For Expected Status
    ...  operation_id=${lock_result["id"]}
    ...  expected_status=success
    ...  timeout=${RMOD_LOCK_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}Lock radio module (sn: ${cbts_tested_rmod_sn}) succeeded  console=${log_to_console}
# Wait for radio module expected state
    RMOD Wait For Expected State
    ...  rmod_sn=${cbts_tested_rmod_sn}
    ...  rmod_state=administrative_state
    ...  rmod_state_value=Locked
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}Radio module (sn: ${cbts_tested_rmod_sn}) is Locked  console=${log_to_console}
# Check radio module impacted cells states
    ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${cbts_tested_rmod_sn}
    FOR  ${cbts_rmod_impacted_cell_id}  IN  @{cbts_rmod_impacted_cells_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${cbts_rmod_impacted_cell_id}
      ...  state_status_dict=${cbts_impacted_cell_state_dict}
      ...  timeout=30s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${below_info_prefix}Impacted radio module (sn: ${cbts_tested_rmod_sn}) cells status is OK  console=${log_to_console}

Unlock Radio Module Enable Disable Energy Optimized Mode
    [Documentation]
    ...  Description:
    ...  Keyword unlock radio module to deactivate carriers.
    ...  Reason (from CFAM):
    ...	 Feature CB014375 will not be activated until all the cells are disabled in radio or radio module locked.
    ...	 If enabling of feature CB014375 when no carrier is configured on radio,
    ...  then radio will enable energy efficiency mode immediately.
    ...  This will take effect when carriers are activated and this affects all carriers.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${unlock_result}=  vdu.Unlock Rmods
    ...  rmod_id_list=${cbts_block_rmods_conf_id_list}
    ...  vdu_connection=${vdu_connection}
# Wait for radio module lock expected status
    RMOD Unlock Wait For Expected Status
    ...  operation_id=${unlock_result["id"]}
    ...  expected_status=success
    ...  timeout=${RMOD_UNLOCK_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}Unlock radio module (sn: ${cbts_tested_rmod_sn}) succeeded  console=${log_to_console}
# Wait for radio module expected state (administrative_state=Unlocked)
    RMOD Wait For Expected State
    ...  rmod_sn=${cbts_tested_rmod_sn}
    ...  rmod_state=administrative_state
    ...  rmod_state_value=Unlocked
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}Radio module (sn: ${cbts_tested_rmod_sn}) is Unlocked  console=${log_to_console}

Enable Disable Energy Optimized Mode Teardown
    [Arguments]  ${tc_status}
    [Documentation]
    ...  Description:
    ...  Keyword performs tasks that clean up or restore initial values after the test is performed (PASS or FAIL).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | tc_status              | Yes  | The status of the current test case (keyword), either PASS or FAIL.        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    IF  '${tc_status}'=='FAIL'
      Log  ${failed_result}Test case FAILED. Teardown operations will be executed  console=${log_to_console}
# Deactivate PAR configuration mode
    ${actparconfigurationmode_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${cbts_tested_rmod_conf_dn}
    ...  para_name=actParConfigurationMode
      IF  '${actparconfigurationmode_value}'=='MaxEnergyEfficiency'
        Log  ${info_prefix}Deactivate PAR configuration mode. Please wait ...  console=${log_to_console}
        vdu.Perform Parameter Recommissioning  dist_name=${cbts_tested_rmod_conf_dn}  parameter=actParConfigurationMode
        ...  operation=update  value=StandardMode  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
        Log  ${info_prefix}PAR configuration mode has been deactivated  console=${log_to_console}
      END
# Deactivate energy efficiency monitoring feature
      IF  '${actpowermeter_initial_value}'=='false'
        Log  ${info_prefix}Deactivate energy efficiency monitoring feature. Please wait ...  console=${log_to_console}
        ${actpowermeter_dist_name}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
        vdu.Perform Parameter Recommissioning  dist_name=${actpowermeter_dist_name}  parameter=actPowerMeter
        ...  operation=update  value=false  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
        Log  ${info_prefix}Energy efficiency monitoring feature has been deactivated  console=${log_to_console}
      END
    END
    Run Keyword And Ignore Error  vDU Rest Logout
