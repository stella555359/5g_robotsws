*** Settings ***
Documentation
...  Author: daniel.bartkowiak@nokia.com
...  Maintainer: daniel.bartkowiak@nokia.com

Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ./Cloud_ALD.resource

*** Variables ***
# Maximum time to wait for cells onair
${VDU_ALD_COMMISSIONING_CELLS_ONAIR_TIMEOUT}=  200s

@{VDU_RET_COMMISSIONING_VDU_ALLOWED_HIST_ALARMS}=  faultId=4592, severity=warning  faultId=10, severity=major
...  faultId=4141, severity=major  faultId=4142, severity=major
@{VCU_RET_COMMISSIONING_VDU_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_ALD_Ret_Detection_And_Commissioning
    [Arguments]  ${vdu_scfc_file_path}  ${remove_ret_scf_path}  ${ru_sn}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  TC Verifies correct detection of all RETs under selected RU. Next, commissioning is performed to confirm
    ...  successful operation of RET addition. Faults: 10, 4141 and 4142 are checked depending on following parameters:
    ...  Fault 10 depends on dcVoltageEnabled=false if RET LOGLINK has linkMOdeDC=false
    ...  Fault 4141 depends on dcVoltageEnabled=false if RET LOGLINK has linkMOdeDC=true
    ...  Fault 4142 depends on hdlcCommunicationAllowed=false for all RETs
    ...  NOTE1. User can execute TC per single RU, it means that all RETs belonging to selected RU are tested
    ...  NOTE2. Only RET type HW can be commissioned under selected RU
    ...  NOTE3. While preparing REMOVE_RET_SCF user need to remove all RETs under tested RU in xml and set:
    ...  hdlcCommunicationAllowed=false, dcVoltageEnabled=false under MO RSL for tested RU
    ...  NOTE4. All RETs under selected RU should be assigned to TX antennas otherwise fault 4142 won't be visible on RETs on RX
    ...
    ...  Step 1: CBTS Preconditions ALD Ret Detection And Commissioning
    ...  a) All radio modules should be on line
    ...  b) All ALD should be on line
    ...  c) All Ret should be on line
    ...  d) All cells should be OnAir
    ...  e) vDU operational state should be onAir
    ...  f) ALDs/RETs configuration is removed by commissioning
    ...  Step 2: CBTS Ret Detection
    ...  a) CBTS is onair
    ...  b) ALDs/RETs should not be visible under tested RU
    ...  c) Setting hdlcCommunicationAllowed and dcVoltageEnabled to true under RSL starts and RET detection
    ...  d) All RETs under tested RU are detected
    ...  e) ALDs/RETs are not commissioned under tested RU
    ...  f) ALDs/RETs states on RU are on line
    ...  Step 3: CBTS Ret Full Commissioning
    ...  a) Commissioning is performed
    ...  Step 4: CBTS Ret Fault Check
    ...  a) Setting dcVoltageEnabled=false
    ...  b) Faults 10, 4141 are visible on all RETs under tested RU depending on RET LOGLINK linkModeDC value
    ...  c) Rets cells are degraded while RETs are faulty
    ...  d) ALDs/RETs states on RU are not on air
    ...  e) Setting dcVoltageEnabled=true
    ...  f) Faults 10, 4141 are inactive on all RETs under tested RU
    ...  g) CBTS is onair
    ...  h) Setting hdlcCommunicationAllowed=false
    ...  i) Fault 4142 is visible on all RETs under tested RU
    ...  j) Rets cells are degraded while RETs are faulty
    ...  k) ALDs/RETs states on RU are not on air
    ...  l) Setting hdlcCommunicationAllowed=true
    ...  m) Fault 4142 is inactive on all RETs under tested RU
    ...  n) CBTS is onair
    ...  No unexpected active and historical alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     |  Yes | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | remove_ret_scf_path    |  Yes | Path to scf file with removed RETs under tested RU                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ru_sn                  |  Yes | RU serialNumber where all available RETs are going to be tested            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${remove_ret_scf_path}
    Set Test Variable  ${ru_sn}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Cloud_ALD_Ret_Detection_And_Commissioning  console=${log_to_console}
    Step 1: CBTS Preconditions ALD Ret Detection And Commissioning
    Step 2: CBTS Ret Detection
    Step 3: CBTS Ret Full Commissioning
    Step 4: CBTS Ret Fault Check
    Log  ${done_prefix_green}Test Case: Cloud_ALD_Ret_Detection_And_Commissioning  console=${log_to_console}
    [Teardown]  Teardown CBTS ALD Ret Detection And Commissioning  tc_status=${KEYWORD_STATUS}

Step 1: CBTS Preconditions ALD Ret Detection And Commissioning
    Log  ${dots_prefix_green}Step 1: CBTS Preconditions ALD Ret Detection And Commissioning  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_RET_COMMISSIONING_VDU_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_RET_COMMISSIONING_VDU_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
    General All States Check On VDU  vdu_scfc_file_path=${vdu_scfc_file_path}
    ${ru_config_distname}  ${ru_r_id}=  Get RMOD Details By SN  ru_sn=${ru_sn}
    ${ru_ald_to_ret_init_dict}=  Get ALD Dict From RU  ru_r_id=${ru_r_id}
    Set Test Variable  ${ru_ald_to_ret_init_dict}
    Should Not Be Empty  ${ru_ald_to_ret_init_dict}  msg=No RETs present under RU with SN: ${ru_sn}. Test cannot proceed
    Log  ${info_prefix}Removing RETs from configuration by using recommissioning vDU. Please wait ...  console=${log_to_console}
    Perform Commissioning And Wait For Api  scf=${remove_ret_scf_path}  vdu_connection=${vdu_connection}
# Create variables for further usage
    ${hdlc_dict}=  Create Dictionary  parameterName=hdlcCommunicationAllowed  operation=update  value=true
    ${dcvolt_dict}=  Create Dictionary  parameterName=dcVoltageEnabled  operation=update  value=true
    ${rsl_parameters_list}=  Create List  ${hdlc_dict}  ${dcvolt_dict}
    Set Test Variable  ${rsl_parameters_list}
    ${cbts_cell_degraded}=  Create Dictionary  availabilityStatus=degraded  operationalState=enabled
    ${cbts_cell_onair}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    ${commissioning_recovery_needed}=  Set Variable  ${TRUE}
    Set Test Variable  ${cbts_cell_degraded}
    Set Test Variable  ${cbts_cell_onair}
    Set Test Variable  ${commissioning_recovery_needed}
    Log  ${ok_prefix_green}Step 1: CBTS Preconditions ALD Ret Detection And Commissioning  console=${log_to_console}

Step 2: CBTS Ret Detection
    Log  ${dots_prefix_green}Step 2: CBTS Ret Detection  console=${log_to_console}
    General All States Check On VDU  vdu_scfc_file_path=${remove_ret_scf_path}  cells_timeout=${VDU_ALD_COMMISSIONING_CELLS_ONAIR_TIMEOUT}
# Set step variables
    ${ru_config_distname}  ${ru_r_id}=  Get RMOD Details By SN  ru_sn=${ru_sn}
    ${ru_ald_to_ret_remove_dict}=  Get ALD Dict From RU  ru_r_id=${ru_r_id}
    ${RSL_config_dist_name}=  Set Variable  ${ru_config_distname}/RSL-1
    Set Test Variable  ${RSL_config_dist_name}
    Should Be Empty  ${ru_ald_to_ret_remove_dict}  msg=No RETs should be present under RU with SN: ${ru_sn} after removing them from configuration
    Log  ${info_prefix}No RETs detected under RU with SN: ${ru_sn}. Test can proceed  console=${log_to_console}
    Log  ${info_prefix}Waiting for RET detection under RU with serial number: ${ru_sn} ...  console=${log_to_console}
# Start RET detection
    vdu.Perform Object Recommissioning  dist_name=${RSL_config_dist_name}  parameter=${rsl_parameters_list}
    ...  operation=update  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}  vdu_connection=${vdu_connection}
    Wait Until Keyword Succeeds  300  30  RETs Detect  ru_r_id=${ru_r_id}
    ${current_scfc_file_path}=  vdu.Get Current Plan File  local_dir_path=${OUTPUT_DIR}
    ...  filename=vDU_SCF_ret_remove.xml  vdu_connection=${vdu_connection}
# Check If RETs detected but not commissioned
    Check Rets Commissioning  ru_r_id=${ru_r_id}  commissioned=${False}
    Check ALDs/RETs States On RU  scf_path=${current_scfc_file_path}  ru_r_id=${ru_r_id}
    Log  ${ok_prefix_green}Step 2: CBTS Ret Detection  console=${log_to_console}

Step 3: CBTS Ret Full Commissioning
    Log  ${dots_prefix_green}Step 3: CBTS Ret Full Commissioning  console=${log_to_console}
    Log  ${info_prefix}Performing RETs commissioning under RU with SN: ${ru_sn}. Please wait ...  console=${log_to_console}
    Perform Commissioning And Wait For Api  scf=${vdu_scfc_file_path}  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}Step 3: CBTS Ret Full Commissioning  console=${log_to_console}

Step 4: CBTS Ret Fault Check
    Log  ${dots_prefix_green}Step4: CBTS Ret Fault Check  console=${log_to_console}
    General All States Check On VDU  vdu_scfc_file_path=${vdu_scfc_file_path}  cells_timeout=${VDU_ALD_COMMISSIONING_CELLS_ONAIR_TIMEOUT}
    ${ru_config_distname}  ${ru_r_id}=  Get RMOD Details By SN  ru_sn=${ru_sn}
    Check Rets Commissioning  ru_r_id=${ru_r_id}  commissioned=${True}
    ${current_scfc_file_path}=  vdu.Get Current Plan File  local_dir_path=${OUTPUT_DIR}
    ...  filename=vDU_SCF_with_RET.xml  vdu_connection=${vdu_connection}
# Set step variables
    ${commissioning_recovery_needed}=  Set Variable  ${FALSE}
    Set Test Variable  ${commissioning_recovery_needed}
    ${faults_dict}=  Create ALD Fault Dict  scf_path=${current_scfc_file_path}  ru_r_id=${ru_r_id}
    ${all_cells}  ${ret_cells}=  Get Cells For Testing  ru_r_id=${ru_r_id}
    Remove Values From List  ${all_cells}  @{ret_cells}
    ${not_impacted_cells}=  Set Variable  ${all_cells}
    ${alarm_severity_list}=  Create List  Major
# Set dcVoltageEnabled=false
    vdu.Perform Parameter Recommissioning  dist_name=${RSL_config_dist_name}  parameter=dcVoltageEnabled
    ...  operation=update  value=false  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Parameter dcVoltageEnabled set to false successsfully  console=${log_to_console}
# Check faults when dcVoltageEnabled=false
    FOR  ${ret}  IN  @{faults_dict}
      ${alarming_object_list}=  Create List  ${ret}
      vDU Assert Alarm Active
      ...  fault_id=${faults_dict['${ret}']}
      ...  alarming_object_list=${alarming_object_list}
      ...  alarm_severity_list=${alarm_severity_list}
      ...  timeout=600s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault ${faults_dict['${ret}']} for RET ${ret} successfully activated  console=${log_to_console}
    END
    Cloud ALD Check Cells According To Impact
    ...  impacted_cells=${ret_cells}
    ...  not_impacted_cells=${not_impacted_cells}
    ...  impacted_state_dict=${cbts_cell_degraded}
    ...  not_impacted_state_dict=${cbts_cell_onair}
    Check ALDs/RETs States On RU  scf_path=${current_scfc_file_path}  ru_r_id=${ru_r_id}  is_onair=False
# Set dcVoltageEnabled=true
    vdu.Perform Parameter Recommissioning  dist_name=${RSL_config_dist_name}  parameter=dcVoltageEnabled
    ...  operation=update  value=true  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Parameter dcVoltageEnabled set to true successfully  console=${log_to_console}
    General All States Check On VDU  vdu_scfc_file_path=${vdu_scfc_file_path}  cells_timeout=${VDU_ALD_COMMISSIONING_CELLS_ONAIR_TIMEOUT}
# Check inactive faults when dcVoltageEnabled=true
    FOR  ${ret}  IN  @{faults_dict}
      ${alarming_object_list}=  Create List  ${ret}
      vDU Assert Alarm Inactive
      ...  fault_id=${faults_dict['${ret}']}
      ...  alarming_object_list=${alarming_object_list}
      ...  alarm_severity_list=${alarm_severity_list}
      ...  timeout=200s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault ${faults_dict['${ret}']} for RET ${ret} successfully deactivated  console=${log_to_console}
    END
# Set hdlcCommunicationAllowed=false
    vdu.Perform Parameter Recommissioning  dist_name=${RSL_config_dist_name}  parameter=hdlcCommunicationAllowed
    ...  operation=update  value=false  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Parameter hdlcCommunicationAllowed set to false successfully  console=${log_to_console}
# Check faults when hdlcCommunicationAllowed=false
    FOR  ${ret}  IN  @{faults_dict}
      ${alarming_object_list}=  Create List  ${ret}
      vDU Assert Alarm Active
      ...  fault_id=4142
      ...  alarming_object_list=${alarming_object_list}
      ...  alarm_severity_list=${alarm_severity_list}
      ...  timeout=60s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault 4142 for RET ${ret} successfully activated  console=${log_to_console}
    END
    Cloud ALD Check Cells According To Impact
    ...  impacted_cells=${ret_cells}
    ...  not_impacted_cells=${not_impacted_cells}
    ...  impacted_state_dict=${cbts_cell_degraded}
    ...  not_impacted_state_dict=${cbts_cell_onair}
    Check ALDs/RETs States On RU  scf_path=${current_scfc_file_path}  ru_r_id=${ru_r_id}
    ...  tested_rsl_parameter=hdlcCommunicationAllowed  is_onair=False
# Set hdlcCommunicationAllowed=true
    vdu.Perform Parameter Recommissioning  dist_name=${RSL_config_dist_name}  parameter=hdlcCommunicationAllowed
    ...  operation=update  value=true  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Parameter hdlcCommunicationAllowed set to true successfully  console=${log_to_console}
    General All States Check On VDU  vdu_scfc_file_path=${vdu_scfc_file_path}  cells_timeout=${VDU_ALD_COMMISSIONING_CELLS_ONAIR_TIMEOUT}
# Check inactive faults when hdlcCommunicationAllowed=true
    FOR  ${ret}  IN  @{faults_dict}
      ${alarming_object_list}=  Create List  ${ret}
      vDU Assert Alarm Inactive
      ...  fault_id=4142
      ...  alarming_object_list=${alarming_object_list}
      ...  alarm_severity_list=${alarm_severity_list}
      ...  timeout=120s
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Fault 4142 for RET ${ret} successfully deactivated  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step4: CBTS Ret Fault Check  console=${log_to_console}

General All States Check On VDU
    [Arguments]  ${vdu_scfc_file_path}  ${cells_timeout}=60  ${vdu_connection}=default
    [Documentation]
    ...  Kw Checks if HW on vDU is on air
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     |  Yes | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cells_timeout          |  No  | Timeout for cells onair                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
# Wait until all cells are OnAir
    ${vdu_scfc_nrcells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${vdu_scfc_file_path}
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${cells_timeout}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Wait until all RUs are on line
    ${vdu_scfc_rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${vdu_scfc_file_path}
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=50s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all ALD are on line
    ${vdu_scfc_all_ald_list}=  SCFC Get Regexp Matches Dist Name  scfc_file_path=${vdu_scfc_file_path}  dist_name=.*?/ALD_R-\\d+
    ${vdu_scfc_ald_count}=  Get Length  ${vdu_scfc_all_ald_list}
    Wait Until All ALDs Are OnAir
    ...  alds_count=${vdu_scfc_ald_count}
    ...  timeout=50s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All ALD are on line  console=${log_to_console}
# Wait until all RET are on line
    ${vdu_scfc_all_ret_list}=  SCFC Get Regexp Matches Dist Name  scfc_file_path=${vdu_scfc_file_path}  dist_name=.*?/RETU_R-\\d+
    ${vdu_scfc_ret_count}=  Get Length  ${vdu_scfc_all_ret_list}
    Wait Until All RETs Are OnAir
    ...  rets_count=${vdu_scfc_ret_count}
    ...  timeout=50s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All RET are on line  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=50s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}

Wait For Rest Api Reconnection
    [Arguments]  ${vdu_connection}=default
    [Documentation]  KW waits until vDU REST API becomes available
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
    Ip Address Is Unavailable  ip_addr=${ip_addr}
    Log  ${info_prefix}vDU is unavailable. Wait for vDU availability ...  console=${log_to_console}
    Wait Until Keyword Succeeds  180  5
    ...  vDU Rest Login  vdu_connection=${vdu_connection}

Get RMOD Details By SN
    [Arguments]  ${ru_sn}  ${vdu_connection}=default
    [Documentation]  KW returns config distname, runtime ID
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ru_sn                  |  Yes | RU serial number                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ${ru_inf}=  vdu.Get Rmods Status  vdu_connection=${vdu_connection}
    FOR  ${rmod}  IN  @{ru_inf}
        IF  '${rmod["serial_number"]}' == '${ru_sn}'
            RETURN  ${rmod['dist_names']['config']}  ${rmod['id']}
        END
    END
    Run Keywords  Log  ${info_prefix}RU ${ru_sn} provided by user doesn't exist  console=${log_to_console}
    ...  AND  Fail  RU ${RU_SN} provided by user doesn't exist

Get ALD Dict From RU
    [Arguments]  ${ru_r_id}  ${vdu_connection}=default
    [Documentation]  KW gathers ALDs from given RU runtime ID and returns dictionary with ALD s/n as key and params as value
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ru_r_id                |  Yes | RU runtime ID                                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ${ald_to_ret_dict}=  Create Dictionary
    ${alds_inf}=  vdu.Get Rets Information  vdu_connection=${vdu_connection}
    FOR  ${ald}  IN  @{alds_inf}
      IF  '${ald['ald']['control_ports'][0]['rmod_r_id']}' == '${ru_r_id}'
        Set To Dictionary  ${ald_to_ret_dict}  ${ald['ald']['serial_number']}=${ald}
      END
    END
    [Return]  ${ald_to_ret_dict}

RETs Detect
    [Arguments]  ${ru_r_id}  ${vdu_connection}=default
    [Documentation]  KW waits until all RETs under tested RU are detected
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ru_r_id                |  Yes | Runtime ru id                                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ${ru_ald_to_ret_detected_dict}=  Get ALD Dict From RU  ru_r_id=${ru_r_id}  vdu_connection=${vdu_connection}
    IF  len(${ru_ald_to_ret_detected_dict}) != len(${ru_ald_to_ret_init_dict})
      ${detected_count}=    Evaluate    len(${ru_ald_to_ret_detected_dict})
      ${expected_count}=    Evaluate    len(${ru_ald_to_ret_init_dict})
      Fail  Detected ALDs -> ${detected_count}, should be ${expected_count}
    END
    FOR  ${sn}  IN  @{ru_ald_to_ret_detected_dict}
        ${ret_list}=  Get From Dictionary  ${ru_ald_to_ret_detected_dict['${sn}']}  subunits
        ${expected_ret_list}=  Get From Dictionary  ${ru_ald_to_ret_init_dict['${sn}']}  subunits
        IF  len(${ret_list}) != len(${expected_ret_list})
            ${detected_ret_count}=    Evaluate    len(${ret_list})
            ${expected_ret_count}=    Evaluate    len(${expected_ret_list})
            Fail  Detected RETs under ALD ${sn} -> ${detected_ret_count}, should be ${expected_ret_count}
        END
    END
    Log  ${info_prefix}ALDs/RETs detected successfully  console=${log_to_console}

Check Rets Commissioning
    [Arguments]  ${ru_r_id}  ${commissioned}=${TRUE}  ${vdu_connection}=default
    [Documentation]  KW checks if all RETs under tested RU are commissioned
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ru_r_id                |  Yes | Runtime ru id                                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | commissioned           |  No  | starts commissioned or not commissioned check                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ${ru_ald_to_ret_commissioned_dict}=  Get ALD Dict From RU  ru_r_id=${ru_r_id}  vdu_connection=${vdu_connection}
    FOR  ${sn}  IN  @{ru_ald_to_ret_commissioned_dict}
      ${single_ald}=  Set Variable  ${ru_ald_to_ret_commissioned_dict['${sn}']['ald']}
      ${stat_ald_comm}=  Run Keyword And Return Status  Should Be Equal As Strings  ${single_ald['dist_names']['config']}  None
      IF  not ${commissioned} and not ${stat_ald_comm}
        Fail  ALD ${single_ald['serial_number']} is commissioned under RU with SN: ${ru_sn}. Should be NOT COMMISSIONED.
      ELSE IF  ${commissioned} and ${stat_ald_comm}
        Fail  ALD ${single_ald['serial_number']} is NOT commissioned under RU with SN: ${ru_sn}. Should be COMMISSIONED.
      END
      FOR  ${ret}  IN  @{ru_ald_to_ret_commissioned_dict['${sn}']['subunits']}
        ${stat_ret_comm}=  Run Keyword And Return Status  Should Be Equal As Strings  ${ret['dist_names']['config']}  None
        IF  not ${commissioned} and not ${stat_ret_comm}
          Fail  RET ${ret['dist_names']['runtime']} is commissioned under RU with SN: ${ru_sn}. Should be NOT COMMISSIONED.
        ELSE IF  ${commissioned} and ${stat_ret_comm}
          Fail  RET ${ret['dist_names']['runtime']} is NOT commissioned under RU with SN: ${ru_sn}. Should be COMMISSIONED.
        END
      END
    END
    IF  ${commissioned}
      Log  ${info_prefix}All ALDs/RETs under RU with SN: ${ru_sn} are commissioned successfully  console=${log_to_console}
    ELSE
      Log  ${info_prefix}All ALDs/RETs under RU with SN: ${ru_sn} are NOT commissioned successfully  console=${log_to_console}
    END

Check ALDs/RETs States On RU
    [Arguments]  ${scf_path}  ${ru_r_id}  ${tested_rsl_parameter}=dcVoltageEnabled  ${is_onair}=True
    ...  ${vdu_connection}=default
    [Documentation]  KW checks if all RETs under tested RU are in expected state
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scf_path               |  Yes | scf path                                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ru_r_id                |  Yes | Runtime ru id                                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | tested_rsl_parameter   |  No  | Tested RSL parameter when ALD/RET states check, possible values:           |
    ...  |                        |      | hdlcCommunicationAllowed or dcVoltageEnabled                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | is_onair               |  No  | Starts onair or not onair check                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ${ru_ald_to_ret_commissioned_dict}=  Get ALD Dict From RU  ru_r_id=${ru_r_id}  vdu_connection=${vdu_connection}
    FOR  ${sn}  IN  @{ru_ald_to_ret_commissioned_dict}
      ${single_ald}=  Set Variable  ${ru_ald_to_ret_commissioned_dict['${sn}']}
      ${loglink_distname}=  Get Loglink Distname From SCF
      ...  scf_path=${scf_path}  ald_dist_name=${single_ald['ald']['dist_names']['runtime']}
      ${loglink_info}=  vdu.Get Loglink  loglink_dn=${loglink_distname}  vdu_connection=${vdu_connection}
      IF  '${tested_rsl_parameter}' == 'hdlcCommunicationAllowed'
        ${failed_availability_status}=  Set Variable  (?i)off line
      ELSE IF  '${tested_rsl_parameter}' == 'dcVoltageEnabled'
        ${failed_availability_status}=  Set Variable  (?i)not installed
      END
      IF  ${is_onair}
        ${ald_availa}=  Run Keyword And Return Status
        ...  Should Match Regexp  ${single_ald['ald']['availability_status']}  (?i)on line
        ${ald_oper}=  Run Keyword And Return Status  Should Match Regexp  ${single_ald['ald']['operational_state']}  (?i)Enabled
      ELSE
        ${ald_availa}=  Run Keyword And Return Status
        ...  Should Match Regexp  ${single_ald['ald']['availability_status']}  ${failed_availability_status}
        ${ald_oper}=  Run Keyword And Return Status  Should Match Regexp  ${single_ald['ald']['operational_state']}  (?i)Disabled
      END
      IF  not (${ald_availa} and ${ald_oper})
          Log  ${failed_result}ALD ${sn} has wrong status ${single_ald['ald']['availability_status']}  console=${log_to_console}
          Fail  ${failed_result}ALD ${sn} has wrong status ${single_ald['ald']['availability_status']}
      END
      FOR  ${ret}  IN  @{ru_ald_to_ret_commissioned_dict['${sn}']['subunits']}
        IF  ${is_onair}
          ${ret_availa}=  Run Keyword And Return Status
          ...  Should Match Regexp  ${ret['availability_status']}  (?i)on line
          ${ret_oper}=  Run Keyword And Return Status  Should Match Regexp  ${ret['operational_state']}  (?i)Enabled
        ELSE
          ${ret_availa}=  Run Keyword And Return Status
          ...  Should Match Regexp  ${ret['availability_status']}  ${failed_availability_status}
          ${ret_oper}=  Run Keyword And Return Status  Should Match Regexp  ${ret['operational_state']}  (?i)Disabled
        END
        IF  not (${ret_availa} and ${ret_oper})
            Log  ${failed_result}${ret['dist_names']['runtime']} has wrong status ${ret['availability_status']}  console=${log_to_console}
            Fail  ${failed_result}${ret['dist_names']['runtime']} has wrong status ${ret['availability_status']}
        END
      END
    END
    Log  ${info_prefix}All ALDs/RETs under RU with SN: ${ru_sn} have expected states  console=${log_to_console}

Get Loglink Distname From SCF
    [Arguments]  ${scf_path}  ${ald_dist_name}
    [Documentation]   KW returns LOGLINK distname for given ALD distname in given SCF file
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scf_file_path          |  Yes | scf file path to search for                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ald_dist_name          |  Yes | ALD runtime distname                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ${loglink_distname}=  Evaluate Xpath  ${scf_path}
    ...  string(.//managedObject[contains(@class, "LOGLINK_R") and p[@name="secondEndpointDN"]="${ald_dist_name}"]/@distName)
    [Return]  ${loglink_distname}

Create ALD Fault Dict
    [Arguments]  ${scf_path}  ${ru_r_id}  ${vdu_connection}=default
    [Documentation]  KW creates and returns dictionary with faults to be checked on ALDs
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scf_path               |  Yes | scf path                                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ru_r_id                |  Yes | Runtime ru id                                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ${faults_dict}=  Create Dictionary
    ${ru_ald_to_ret_commissioned_dict}=  Get ALD Dict From RU  ru_r_id=${ru_r_id}  vdu_connection=${vdu_connection}
    FOR  ${sn}  IN  @{ru_ald_to_ret_commissioned_dict}
      ${single_ald}=  Set Variable  ${ru_ald_to_ret_commissioned_dict['${sn}']}
      ${loglink_distname}=  Get Loglink Distname From SCF
      ...  scf_path=${scf_path}  ald_dist_name=${single_ald['ald']['dist_names']['runtime']}
      ${loglink_info}=  vdu.Get Loglink  loglink_dn=${loglink_distname}  vdu_connection=${vdu_connection}
      IF  '${loglink_info['link_mode_dc']}' == 'True'
        FOR  ${ret}  IN  @{single_ald['subunits']}
          Set To Dictionary  ${faults_dict}  ${ret['dist_names']['runtime']}=4141
        END
      ELSE
        FOR  ${ret}  IN  @{single_ald['subunits']}
          Set To Dictionary  ${faults_dict}  ${ret['dist_names']['runtime']}=10
        END
      END
    END
    [Return]  ${faults_dict}

Get Cells For Testing
    [Arguments]  ${ru_r_id}  ${vdu_connection}=default
    [Documentation]  KW creates and returns two lists with cell IDs. First list contains IDs of all cells from VDU.
    ...  Second list contains IDs of cells impacted by RETs under tested RU
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | ru_r_id                |  Yes | Runtime ru id                                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ${impacted_cells}=  Create List
    ${all_cells}=  Create List
    ${vdu_cells_info}=  vdu.Get Vdu Cell Id  vdu_connection=${vdu_connection}
    FOR  ${cell}  IN  @{vdu_cells_info}
      ${keys_list}=  Get Dictionary Keys  ${cell}
      ${all_cells}=  Combine Lists  ${all_cells}  ${keys_list}
    END
    ${ru_ald_to_ret_commissioned_dict}=  Get ALD Dict From RU  ru_r_id=${ru_r_id}  vdu_connection=${vdu_connection}
    FOR  ${sn}  IN  @{ru_ald_to_ret_commissioned_dict}
      ${single_ald}=  Set Variable  ${ru_ald_to_ret_commissioned_dict['${sn}']}
      FOR  ${ret}  IN  @{single_ald['subunits']}
        FOR  ${ant}  IN  @{ret['antenna_list']}
          IF  '${ant['rmod_r_id']}' == '${ru_r_id}'
            ${impacted_cells}=  Combine Lists  ${impacted_cells}  ${ant['local_cells']}
          END
        END
      END
    END
    ${impacted_cells}=  Remove Duplicates  ${impacted_cells}
    [Return]  ${all_cells}  ${impacted_cells}

Perform Commissioning And Wait For Api
    [Arguments]  ${scf}  ${vdu_connection}=default
    [Documentation]  KW performs commissioning and waits for REST API reconnection and F1-C link availability
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scf                    |  Yes | path to scf file                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ${commissioning_result}=  vdu.Perform Commissioning
    ...  scf_file=${scf}
    ...  timeout=${ACTIVATE_PLAN_TIMEOUT}
    ...  wait_for_completion=${True}
    ...  should_activate=${True}
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}vDU commissioning activation has been completed successfully.  console=${log_to_console}
    Log  ${below_info_prefix}vDU commissioning operation status: ${commissioning_result['status']}  console=${log_to_console}
    vDU Rest Logout  vdu_connection=${vdu_connection}
    Wait For Rest Api Reconnection
    Log  ${info_prefix}Wait for F1-C link to activate...  console=${log_to_console}
    vDU Wait For Expected F1 Link Status
    ...  f1_link_status_value=available
    ...  timeout=600s
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}F1-C link is available  console=${log_to_console}

Teardown CBTS ALD Ret Detection And Commissioning
    [Arguments]  ${tc_status}  ${vdu_connection}=default
    [Documentation]  Teardown procedures
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | tc_status              | Yes  | TC status                                                |
    ...  +------------------------+------+----------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.      |
    ...  +------------------------+------+----------------------------------------------------------+
    IF  '${tc_status}'=='PASS'  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}
    Return From Keyword If  '${tc_status}'=='PASS'
    Log  ${info_prefix}Teardown: Reverting RETs commissioning changes by using commissioning vDU. Please wait ...
    ...  console=${log_to_console}
    Run Keyword And Ignore Error  Perform Commissioning And Wait For Api  scf=${vdu_scfc_file_path}  vdu_connection=${vdu_connection}
    Run Keyword And Ignore Error  General All States Check On VDU
    ...  vdu_scfc_file_path=${vdu_scfc_file_path}
    ...  cells_timeout=${VDU_ALD_COMMISSIONING_CELLS_ONAIR_TIMEOUT}
    Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}
