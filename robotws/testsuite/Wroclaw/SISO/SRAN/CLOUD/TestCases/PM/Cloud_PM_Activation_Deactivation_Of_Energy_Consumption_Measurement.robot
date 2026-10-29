*** Settings ***
Documentation
...  Author: daniel.bartkowiak@nokia.com
...  Maintainer: daniel.bartkowiak@nokia.com

Library    BuiltIn
Library    Collections
Library    DateTime
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/common_resources.robot
Resource    ../../resources/Robot/vdu_vcu_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/common_kw.robot

*** Keywords ***
TC__Cloud_PM_Activation_Deactivation_Of_Energy_Consumption_Measurement
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}  ${rmod_sn_count}=0  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) verifies counters related to RU Energy Consumption
    ...  NOTE. Before executing TC, VDU scf have to contain MO PMMNL-1
    ...  and parameters mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring should exist
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-8028
    ...  Test case for CB007065-CR-D Power Meter on RU side.
    ...  Test case is to verify the function of energy consumption measurement - enabling and disabling via WebEM-DU
    ...  Energy consumption measurements can be activated/deactivated using parameter 'actPowerMeter'.
	...  User is obligated to provide RU serial number which will be tested (only RUs supporting 'Embedded Power Meter').
	...  Tested counters need to be configured against sampling periods.
	...  For testing purposes sampling periods are going to be set for minimum value - 15min each.
	...  Two parameters are used: 'mtBtsEnergyMonitoring' and 'mtSBTSRfmEnergyMonitoring'
    ...  Specific Counters are going to be tested:
	...  M40002C1 ENERGY_CONSUMPTION_IN_RF - mtBtsEnergyMonitoring = 15min
	...  M40003C0 MIN_INPUT_VOLTAGE_IN_RF - mtSBTSRfmEnergyMonitoring = 15min
	...  M40003C1 MAX_INPUT_VOLTAGE_IN_RF - mtSBTSRfmEnergyMonitoring = 15min
	...  M40003C2 - RU_ENERGY_CONSUMPTION - mtSBTSRfmEnergyMonitoring = 15min
	...  M40003C3 - RU_MIN_PWR_USAGE - mtSBTSRfmEnergyMonitoring = 15min
	...  M40003C4 - RU_AVG_PWR_USAGE - mtSBTSRfmEnergyMonitoring = 15min
	...  M40003C5 - RU_MAX_PWR_USAGE - mtSBTSRfmEnergyMonitoring = 15min
    ...
    ...  Step 1: Check States On VDU HW
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
	...  c) All radio units are online
	...     Radio module expected states:  administrative_state = Unlocked
    ...                                    operational_state = enabled
    ...                                    availability_status = on line
    ...  d) Check if tested radio module serial number is in configuration
	...  Step 2: Verify Counters When Energy Consumption Measurement Deactivated
    ...  a) Get initial parameters values of 'actPowerMeter', 'mtSBTSRfmEnergyMonitoring', 'mtBtsEnergyMonitoring'
    ...  b) Deactivate Energy Consumption Measurement (actPowerMeter=false)
	...  c) Check if VDU reset was not performed
    ...  d) No unexpected alarm is visible
	...  e) Check if counters not exist
    ...  Step 3: Activate Energy Consumption Measurement
    ...  a) Activate Energy Consumption Measurement (actPowerMeter=true, mtSBTSRfmEnergyMonitoring=15min, mtBtsEnergyMonitoring=15min)
    ...  b) Check if VDU reset was not performed
    ...  c) No unexpected alarm is visible
    ...  Step 4: Verify Counters When Energy Consumption Measurement Activated
    ...  a) Check if counters exist after 15min time interval
    ...  Step 5: Deactivate Energy Consumption Measurement
    ...  a) Deactivate Energy Consumption Measurement (actPowerMeter=false)
    ...  b) Check if VDU reset was not performed
    ...  c) No unexpected alarm is visible
    ...  Step 6: Verify Counters When Energy Consumption Measurement Deactivated
    ...  a) Check if counters not exist
	...  b) Apply initial parameters values of 'actPowerMeter', 'mtSBTSRfmEnergyMonitoring', 'mtBtsEnergyMonitoring'
    ...  c) Check if VDU reset was not performed
    ...  d) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
	...  e) All radio units are online
	...     Radio module expected states:  administrative_state = Unlocked
    ...                                    operational_state = enabled
    ...                                    availability_status = on line
    ...  f) No unexpected alarm is visible
    ...  g) vDU operation state is OnAir (operational_state=OnAir)
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count          |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Set Test Variable  ${scfc_file_path}
    Set Test Variable  ${rmod_sn_list}
    Set Test Variable  ${rmod_sn_count}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: TC__Cloud_PM_Activation_Deactivation_Of_Energy_Consumption_Measurement  console=${log_to_console}
    Step 1: Check States On VDU HW
    Step 2: Verify Counters When Energy Consumption Measurement Deactivated
    Step 3: Activate Energy Consumption Measurement
    Step 4: Verify Counters When Energy Consumption Measurement Activated
    Step 5: Deactivate Energy Consumption Measurement
    Step 6: Verify Counters When Energy Consumption Measurement Deactivated
    Log  ${done_prefix_green}Test Case: TC__Cloud_PM_Activation_Deactivation_Of_Energy_Consumption_Measurement  console=${log_to_console}
    [Teardown]  TC_PM_Energy_Consumption_Measurement_Teardown  tc_status=${KEYWORD_STATUS}

Step 1: Check States On VDU HW
    vDU Rest Login
    Log  ${dots_prefix_green}Step 1: Check States On VDU HW  console=${log_to_console}
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=${FALSE}
    ${ee_monitoring_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${time_interval_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    Set Test Variable  @{EE_SM_MO_DN_LIST}  MRBTS-${mrbts_id}
    Set Test Variable  ${ee_monitoring_mo_dn}
    Set Test Variable  ${time_interval_mo_dn}
    ${init_actPowerMeter_value}=  Evaluate Xpath  ${scfc_file_path}
     ...  string(.//managedObject[contains(@distName, "${ee_monitoring_mo_dn}")]/p[@name='actPowerMeter'])
    ${init_vdu_params_dict_1}=  Create Dictionary
    ...  actPowerMeter=${init_actPowerMeter_value}
    Set Test Variable  ${init_vdu_params_dict_1}
    ${init_vdu_params_dict_2}=  Create Dictionary  mtSBTSRfmEnergyMonitoring=${EMPTY}  mtBtsEnergyMonitoring=${EMPTY}
    FOR  ${time_param}  IN  @{init_vdu_params_dict_2.keys()}
      ${init_value}=  Evaluate Xpath  ${scfc_file_path}
      ...  string(.//managedObject[contains(@distName, "${time_interval_mo_dn}")]/p[@name='${time_param}'])
      Set To dictionary  ${init_vdu_params_dict_2}  ${time_param}=${init_value}
    END
    Set Test Variable  ${init_vdu_params_dict_2}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${all_rmods_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${scfc_file_path}
    FOR  ${ru_sn}  IN  @{all_rmods_sn_list}
      RMOD Wait For Online  rmod_sn=${ru_sn}
    END
    Log  ${info_prefix}All radio units online  console=${log_to_console}
    ${rmod_serial_number_list}=  Get Radio Modules Serial Numbers List  scfc_file_path=${scfc_file_path}
    ...  rmod_sn_list=${rmod_sn_list}  rmod_sn_count=${rmod_sn_count}
    ${EE_RFM_MO_DN_LIST}=  Create List
    ${REAL_TIME_MO_DN_LIST}=  Create List
    ${all_rmods_params}=  vdu.Get Rmods Status
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_sn_value}=  Set Variable  ${rmod_params['serial_number']}
      ${rmod_id}=  Set Variable  ${rmod_params['id']}
      ${rmod_ant_ports}=  Set Variable  ${rmod_params['ant_ports']}
      Run Keyword If  '${rmod_sn_value}' in ${rmod_serial_number_list}  Run Keywords
      ...  Append To List  ${EE_RFM_MO_DN_LIST}  ${rmod_params['dist_names']['config']}
      ...  AND
      ...  Append To List  ${REAL_TIME_MO_DN_LIST}  ${rmod_params['dist_names']['runtime']}
    END
    Run Keyword If  len(${EE_RFM_MO_DN_LIST})!=len(${rmod_serial_number_list})
    ...  Fail  Not all declared RMOD serial numbers were found on VDU. Double check provided serials.
    Set Test Variable  @{EE_RFM_MO_DN_LIST}
    Set Test Variable  @{REAL_TIME_MO_DN_LIST}
    Log  ${ok_prefix_green}Step 1: Check States On VDU HW  console=${log_to_console}

Step 2: Verify Counters When Energy Consumption Measurement Deactivated
    Log  ${dots_prefix_green}Step 2: Verify Counters When Energy Consumption Measurement Deactivated  console=${log_to_console}
    ${updated_params_dict_1}=  Create Dictionary  actPowerMeter=false
    ${updated_params_dict_2}=  Create Dictionary
    ...  mtSBTSRfmEnergyMonitoring=15min
    ...  mtBtsEnergyMonitoring=15min
    ${update_dict_1}=  Create Dictionary  update=${updated_params_dict_1}
    ${json_update_1}=  Create Single Dist Name Json String
    ...  mo_dn=${ee_monitoring_mo_dn}
    ...  updated_params_dict=${update_dict_1}
    ...  distname_operation=update
    ${update_dict_2}=  Create Dictionary  update=${updated_params_dict_2}
    ${json_update_2}=  Create Single Dist Name Json String
    ...  mo_dn=${time_interval_mo_dn}
    ...  updated_params_dict=${update_dict_2}
    ...  distname_operation=update
    ${json_list}=  Create List  ${json_update_1[1]}  ${json_update_2[1]}
    ${full_json}=  Create Json String  distnames_json_elements=${json_list}
    vdu.Perform Delta recommissioning  delta_file=${full_json}
    Log  ${info_prefix}Energy consumption measurement deactivated - actPowerMeter=false  console=${log_to_console}
    ${step2_vdu_timestamp}  ${step2_real_time_bts_timestamp}=  Get VDU timestamp
    Log  ${info_prefix}Energy consumption measurement time interval set to 15min  console=${log_to_console}
    ${vcu_alarms}  ${vdu_alarms}=  Get All Active Alarms  vdu_login=False
    Check Active Alarms  allowed_alarms=@{EMPTY}  active_alarms=${vdu_alarms}
    ...  source=vDU  log_to_console=False
    Check Active Alarms  allowed_alarms=@{EMPTY}  active_alarms=${vcu_alarms}
    ...  source=vCU  log_to_console=False
    Log  ${info_prefix}Active allowed alarms checked (vDU, VCU)  console=${log_to_console}
    ${ee_rfm_counters_list}  Create List  M40003C0  M40003C1  M40003C2  M40003C3  M40003C4  M40003C5
    ${ee_sm_counters_list}  Create List  M40002C1
    Set Test Variable  ${ee_rfm_counters_list}
    Set Test Variable  ${ee_sm_counters_list}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=15  additional_offset=${15}
    Log  ${info_prefix}Waiting for ${time_to_sleep} minutes to get EE counters to check if feature was correctly deactivated
    ...  console=${log_to_console}
    Log  ${below_info_prefix}Verdict will be released at *${time_to_verdict}*  console=${log_to_console}
    vDU Rest Logout
    Sleep  ${time_to_sleep} minutes
    vDU Rest Login
    vDU EE Check Pm Counters
    ...  dist_name_list=${EE_RFM_MO_DN_LIST}
    ...  counters_list=${ee_rfm_counters_list}
    ...  ref_time_stamp=${step2_vdu_timestamp}
    ...  exist=${FALSE}
    vDU EE Check Pm Counters
    ...  dist_name_list=${EE_SM_MO_DN_LIST}
    ...  counters_list=${ee_sm_counters_list}
    ...  ref_time_stamp=${step2_vdu_timestamp}
    ...  exist=${FALSE}
    ${real_time_status}=  Run Keyword And Return Status  vdu.Get Real Time Measurements  rmods_runtime_distnames=${REAL_TIME_MO_DN_LIST}
    Run Keyword If  ${real_time_status}  Fail  Real Time Measurements are available. Fail
    Log  ${ok_prefix_green}Step 2: Verify Counters When Energy Consumption Measurement Deactivated  console=${log_to_console}

Step 3: Activate Energy Consumption Measurement
    Log  ${dots_prefix_green}Step 3: Activate Energy Consumption Measurement  console=${log_to_console}
    ${updated_params_dict}=  Create Dictionary  actPowerMeter=true
    ${update_dict_1}=  Create Dictionary  update=${updated_params_dict}
    ${json_update_1}=  Create Single Dist Name Json String
    ...  mo_dn=${ee_monitoring_mo_dn}
    ...  updated_params_dict=${update_dict_1}
    ...  distname_operation=update
    vdu.Perform Delta recommissioning  delta_file=${json_update_1[0]}
    ${step3_vdu_timestamp}  ${step3_real_time_bts_timestamp}=  Get VDU timestamp
    Set Test Variable  ${step3_vdu_timestamp}
    Set Test Variable  ${step3_real_time_bts_timestamp}
    ${vcu_alarms}  ${vdu_alarms}=  Get All Active Alarms  vdu_login=False
    Check Active Alarms  allowed_alarms=@{EMPTY}  active_alarms=${vdu_alarms}
    ...  source=vDU  log_to_console=False
    Check Active Alarms  allowed_alarms=@{EMPTY}  active_alarms=${vcu_alarms}
    ...  source=vCU  log_to_console=False
    Log  ${info_prefix}Active allowed alarms checked (vDU, VCU)  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Activate Energy Consumption Measurement  console=${log_to_console}

Step 4: Verify Counters When Energy Consumption Measurement Activated
    Log  ${dots_prefix_green}Step 4: Verify Counters When Energy Consumption Measurement Activated  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=15  additional_offset=${15}
    Log  ${info_prefix}Waiting for ${time_to_sleep} minutes to get EE counters to check if feature was correctly activated
    ...  console=${log_to_console}
    Log  ${below_info_prefix}Verdict will be released at *${time_to_verdict}*  console=${log_to_console}
    vDU Rest Logout
    Sleep  ${time_to_sleep} minutes
    vDU Rest Login
    vDU EE Check Pm Counters
    ...  dist_name_list=${EE_RFM_MO_DN_LIST}
    ...  counters_list=${ee_rfm_counters_list}
    ...  ref_time_stamp=${step3_vdu_timestamp}
    ...  exist=${TRUE}
    vDU EE Check Pm Counters
    ...  dist_name_list=${EE_SM_MO_DN_LIST}
    ...  counters_list=${ee_sm_counters_list}
    ...  ref_time_stamp=${step3_vdu_timestamp}
    ...  exist=${TRUE}
    ${real_time_status}  ${real_time_output}=  Run Keyword And Ignore Error  vdu.Get Real Time Measurements
    ...  rmods_runtime_distnames=${REAL_TIME_MO_DN_LIST}
    ...  start_time=${step3_real_time_bts_timestamp}
    Run Keyword If  "${real_time_status}"=="FAIL"  Fail  Real Time Measurements are not available. Fail
    FOR  ${rmod_dn}  IN  @{REAL_TIME_MO_DN_LIST}
      Should Not Be Empty
      ...  item=${real_time_output['${rmod_dn}']}
      ...  msg=Real Time measurements are not available for ${rmod_dn}. Fail
    END
    Log  ${ok_prefix_green}Step 4: Verify Counters When Energy Consumption Measurement Activated  console=${log_to_console}

Step 5: Deactivate Energy Consumption Measurement
    Log  ${dots_prefix_green}Step 5: Deactivate Energy Consumption Measurement  console=${log_to_console}
    ${updated_params_dict}=  Create Dictionary  actPowerMeter=false
    ${update_dict_1}=  Create Dictionary  update=${updated_params_dict}
    ${json_update_1}=  Create Single Dist Name Json String
    ...  mo_dn=${ee_monitoring_mo_dn}
    ...  updated_params_dict=${update_dict_1}
    ...  distname_operation=update
    vdu.Perform Delta recommissioning  delta_file=${json_update_1[0]}
    ${step5_vdu_timestamp}  ${step5_real_time_bts_timestamp}=  Get VDU timestamp
    Set Test Variable  ${step5_vdu_timestamp}
    Set Test Variable  ${step5_real_time_bts_timestamp}
    ${vcu_alarms}  ${vdu_alarms}=  Get All Active Alarms  vdu_login=False
    Check Active Alarms  allowed_alarms=@{EMPTY}  active_alarms=${vdu_alarms}
    ...  source=vDU  log_to_console=False
    Check Active Alarms  allowed_alarms=@{EMPTY}  active_alarms=${vcu_alarms}
    ...  source=vCU  log_to_console=False
    Log  ${info_prefix}Active allowed alarms checked (vDU, VCU)  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Deactivate Energy Consumption Measurement  console=${log_to_console}

Step 6: Verify Counters When Energy Consumption Measurement Deactivated
    Log  ${dots_prefix_green}Step 6: Verify Counters When Energy Consumption Measurement Deactivated  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=15  additional_offset=${15}
    Log  ${info_prefix}Waiting for ${time_to_sleep} minutes to get EE counters to check if feature was correctly activated
    ...  console=${log_to_console}
    Log  ${below_info_prefix}Verdict will be released at *${time_to_verdict}*  console=${log_to_console}
    vDU Rest Logout
    Sleep  ${time_to_sleep} minutes
    vDU Rest Login
    vDU EE Check Pm Counters
    ...  dist_name_list=${EE_RFM_MO_DN_LIST}
    ...  counters_list=${ee_rfm_counters_list}
    ...  ref_time_stamp=${step5_vdu_timestamp}
    ...  exist=${FALSE}
    vDU EE Check Pm Counters
    ...  dist_name_list=${EE_SM_MO_DN_LIST}
    ...  counters_list=${ee_sm_counters_list}
    ...  ref_time_stamp=${step5_vdu_timestamp}
    ...  exist=${FALSE}
    ${real_time_status}=  Run Keyword And Return Status  vdu.Get Real Time Measurements  rmods_runtime_distnames=${REAL_TIME_MO_DN_LIST}
    Run Keyword If  ${real_time_status}  Fail  Real Time Measurements are available. Fail
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${all_rmods_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${scfc_file_path}
    FOR  ${ru_sn}  IN  @{all_rmods_sn_list}
      RMOD Wait For Online  rmod_sn=${ru_sn}
    END
    Log  ${ok_prefix_green}Step 6: Verify Counters When Energy Consumption Measurement Deactivated  console=${log_to_console}

TC_PM_Energy_Consumption_Measurement_Teardown
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
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    ${init_dict_1}=  Create Dictionary  update=${init_vdu_params_dict_1}
    ${json_init_1}=  Create Single Dist Name Json String
    ...  mo_dn=${ee_monitoring_mo_dn}
    ...  updated_params_dict=${init_dict_1}
    ...  distname_operation=update
    ${init_dict_2}=  Create Dictionary  update=${init_vdu_params_dict_2}
    ${json_init_2}=  Create Single Dist Name Json String
    ...  mo_dn=${time_interval_mo_dn}
    ...  updated_params_dict=${init_dict_2}
    ...  distname_operation=update
    ${json_list}=  Create List  ${json_init_1[1]}  ${json_init_2[1]}
    ${full_json}=  Create Json String  distnames_json_elements=${json_list}
    Run Keyword If  "${tc_status}"=="FAIL"  Run Keyword And Ignore Error
    ...  vdu.Perform Delta recommissioning  delta_file=${full_json}
    Run Keyword And Ignore Error  vDU Rest Logout
