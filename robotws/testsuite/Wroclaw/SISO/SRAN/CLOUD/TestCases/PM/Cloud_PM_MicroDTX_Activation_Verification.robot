*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    DateTime
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.transport.ssh    WITH NAME    tafssh

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/Robot/common_kw.robot

*** Variables ***
${VDU_MICRODTX_CELLS_ONAIR_TIMEOUT}=  60s
@{VDU_MICRODTX_VERIFICATION_ALLOWED_HIST_ALARMS}=  faultId=4592, severity=warning
...                                                faultId=4592, severity=minor
@{VCU_MICRODTX_VERIFICATION_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_PM_MicroDTX_Activation_Verification
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}=@{EMPTY}  ${rmod_sn_count}=0
    ...  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-19049
    ...  Feature CB013260 - Parity Cloud RAN new Radio introduction in 25R3
    ...
    ...  Test case validate activation of micro discontinuous transmission (µDTX) feature.
    ...  MicroDTX is enabled by default for AirScale Radios from Release 24R2 onwards.
    ...  According to CB013258 feature operator control for NR-MicroDTX on AirScale Radios
    ...  is disabled and activation parameter is hidden from operator.
    ...  Below parameters are not visible for operator to change.
    ...  - NRBTS.actMicroDTX
    ...  - NRBTS.actMicroDTXAdvanced
    ...  It can be switched off only using R&D mode.
    ...
    ...  Since R&D mode in CloudRAN will be available in 26R1 release, until then
    ...  in normal operation mode only activation can be checked.
    ...
    ...  The test case only supports radio modules that support microDTX.
    ...  Please verify radio modules support for microDTX in BPF tool.
    ...  Please provide a list of radio modules that support microDTX.
    ...
    ...  Step 1: Initial Check MicroDTX Activation And Verification
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  Step 2: vDU Reset
    ...  Step 3: MicroDTX Functionality Activation Verification
    ...  a) CPRI: MicroDTX functionality is enabled and "microDtxEnabled" messages are visible in logs.
    ...  b) ECPRI: MicroDTX functionality is enabled and "isEnableMicroDtx" messages are visible in logs.
    ...  Step 4: Postconditions MicroDTX Activation And Verification
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count          |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${scfc_file_path}
    Set Test Variable  ${rmod_sn_list}
    Set Test Variable  ${rmod_sn_count}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: MicroDTX Activation Verification  console=${log_to_console}
    Step 1: Initial Check MicroDTX Activation And Verification
    Step 2: vDU Reset
    Step 3: MicroDTX Functionality Activation Verification
    Step 4: Postconditions MicroDTX Activation And Verification
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: Initial Check MicroDTX Activation And Verification
    Log  ${dots_prefix_green}Step 1: Initial check MicroDTX activation and verification  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_MICRODTX_VERIFICATION_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_MICRODTX_VERIFICATION_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
# Wait until all radio modules are on line
    ${vdu_scfc_rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${scfc_file_path}
    Set Test Variable  ${vdu_scfc_rmods_count}
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    ${vdu_scfc_nrcells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
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
    ${rmod_serial_number_list}=  Get Radio Modules Serial Numbers List
    ...  scfc_file_path=${scfc_file_path}
    ...  rmod_sn_list=${rmod_sn_list}
    ...  rmod_sn_count=${rmod_sn_count}
    ${cpri_rmod_serial_number_list}=  Create List
    ${ecpri_rmod_serial_number_list}=  Create List
    FOR  ${rmod_serial_number}  IN  @{rmod_serial_number_list}
      ${interface_type}=  vDU RMOD Get Parameter Value Based On Serial Number
      ...  rmod_sn=${rmod_serial_number}
      ...  rmod_param=interface_type
      Run Keyword If  '${interface_type}'=='CPRI'
      ...  Append To List  ${cpri_rmod_serial_number_list}  ${rmod_serial_number}
      ...  ELSE IF  '${interface_type}'=='eCPRI'
      ...  Append To List  ${ecpri_rmod_serial_number_list}  ${rmod_serial_number}
      ...  ELSE
      ...  Fail  msg=Unknown radio module interface type !
    END
    Set Test Variable  ${cpri_rmod_serial_number_list}
    Set Test Variable  ${ecpri_rmod_serial_number_list}
# Get fault 4592 cancellation timer
    ${mrbts_id}=  vDU Get MRBTS Id
    ...  vdu_connection=${vdu_connection}
    ${timer_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ${cancellation_timer}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${timer_mo_dn}
    ...  para_name=fault4592CancellationTimer
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cancellation_timer}
    Log  ${done_prefix_green}Step 1: Initial check MicroDTX activation and verification  console=${log_to_console}

Step 2: vDU Reset
    Log  ${dots_prefix_green}Step 2: vDU reset operation  console=${log_to_console}
    Log  ${info_prefix}vDU reset is being performed. Wait for vDU reset ...  console=${log_to_console}
    ${reset_result}=  vdu.Reset Vdu
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}vDU reset operation status: ${reset_result['status']}  console=${log_to_console}
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
# Check if vDU OAM IP address is unavailable
    Ip Address Is Unavailable  ip_addr=${ip_addr}
    Log  ${info_prefix}vDU is unavailable now. Wait for vDU availability ...  console=${log_to_console}
# Check if vDU OAM IP address is available
    Ip Address Is Available  ip_addr=${ip_addr}
    Log  ${below_info_prefix}vDU is available now  console=${log_to_console}
# Check if API connection is established
    Log  ${info_prefix}Waiting for API connection to be established ...  console=${log_to_console}
    Wait Until Keyword Succeeds  30  2
    ...  vDU Get Operational State
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}API connection established  console=${log_to_console}
    vDU Check BTS Reset Cause Alarm
    ...  activation_timeout=40s
    ...  cancellation_timeout=${cancellation_timer}
    ...  info_pattern=*due to user request*
    ...  vdu_connection=${vdu_connection}
    ...  log_prefix=${info_prefix}
# Check F1-C link status
    Log  ${info_prefix}Wait for F1-C link to activate...  console=${log_to_console}
    vDU Wait For Expected F1 Link Status
    ...  f1_link_status_value=available
    ...  timeout=600s
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}F1-C link is available  console=${log_to_console}
# Wait until all radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=60s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${VDU_MICRODTX_CELLS_ONAIR_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${done_prefix_green}Step 2: vDU reset operation  console=${log_to_console}

Step 3: MicroDTX Functionality Activation Verification
    Log  ${dots_prefix_green}Step 3: MicroDTX functionality activation verification  console=${log_to_console}
    Connect To vDU K8s Master Node With Tenant
    ${vdu_ns}=  Get vDU Namespace From Init File
    Set Test Variable  ${vdu_ns}
    ${pod_names_list}=  vDU Get Matches Pod Name  pod_name_pattern=regexp=.*oamfh-0  vdu_connection=${vdu_connection}
    ${pod_name}=  Set Variable  ${pod_names_list[0]}
    Set Test Variable  ${pod_name}
    Log  ${info_prefix}Active MicroDTX on radio modules is verified now ...  console=${log_to_console}
    ${cpri_is_not_empty}=  Run Keyword And Return Status  Should Not Be Empty  item=${cpri_rmod_serial_number_list}
    ${ecpri_is_not_empty}=  Run Keyword And Return Status  Should Not Be Empty  item=${ecpri_rmod_serial_number_list}
    Run Keyword If  ${cpri_is_not_empty}
    ...  Check Cpri Radio Modules And Get Result  rmod_sn_list=${cpri_rmod_serial_number_list}
    Run Keyword If  ${ecpri_is_not_empty}
    ...  Check Ecpri Radio Modules And Get Result  rmod_sn_list=${ecpri_rmod_serial_number_list}
    Log  ${info_prefix}Verification OK: MicroDtx is enabled on all radio modules  console=${log_to_console}
    Run Keyword And Ignore Error  Disconnect Interactive Connection
    Log  ${done_prefix_green}Step 3: MicroDTX functionality activation verification  console=${log_to_console}

Step 4: Postconditions MicroDTX Activation And Verification
    Log  ${dots_prefix_green}Step 4: Postconditions MicroDTX activation and verification  console=${log_to_console}
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
    Log  ${done_prefix_green}Step 4: Postconditions MicroDTX activation and verification  console=${log_to_console}

#INTERNAL TEST CASE KEYWORDS
Check Ecpri Radio Modules And Get Result
    [Arguments]  ${rmod_sn_list}
    [Documentation]
    ...  Description:
    ...  Keyword checks if the eCPRI radio modules have an active microDTX and returns the result.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn_list           | Yes  | List of serial number of the tested radio modules.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_sn_failed_list}=  Create List
    ${microdtx_pattern}=  Set Variable  isEnableMicroDtx
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
      ${rmod_l_dn_pattern}=  Set Variable  RMOD_L_.*${rmod_sn}
      ${kubectl_command}=  Set Variable
      ...  kubectl logs -n ${vdu_ns} ${pod_name} --all-containers=true | grep -E ${rmod_l_dn_pattern} | head -1
      ${cmd_result}=  tafssh.Execute  command=${kubectl_command}
      ${rmod_l_dn_list}=  Get Regexp Matches  string=${cmd_result}  pattern=RMOD_L_\\d+
      ${kubectl_command}=  Set Variable
      ...  kubectl logs -n ${vdu_ns} ${pod_name} --all-containers=true | grep -i ${microdtx_pattern} | grep ${rmod_l_dn_list[0]}
      ${cmd_result}=  tafssh.Execute  command=${kubectl_command}
      ${microdtx_result}=  Run Keyword And Return Status
      ...  Should Match Regexp  string=${cmd_result}  pattern=isEnableMicroDtx
      Run Keyword If  not ${microdtx_result}
      ...  Append To List  ${rmod_sn_failed_list}  ${rmod_sn}
    END
    Should Be Empty  item=${rmod_sn_failed_list}
    ...  msg=There is no information in the logs about enable MicroDtx on radio modules: @{rmod_sn_failed_list} !

Check Cpri Radio Modules And Get Result
    [Arguments]  ${rmod_sn_list}
    [Documentation]
    ...  Description:
    ...  Keyword checks if the CPRI radio modules have an active microDTX and returns the result.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn_list           | Yes  | List of serial number of the tested radio modules.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmod_sn_failed_list}=  Create List
    ${microdtx_pattern}=  Set Variable  microDtxEnabled
    ${ant_port_direction}=  Create List  TXRX
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
      ${ants_runtime_dn_list}=  vDU RMOD Get Antennas Runtime Dist Name Based On Serial Number
      ...  rmod_sn=${rmod_sn}  ant_port_direction=${ant_port_direction}
      ${antenna_count}=  Get Length  ${ants_runtime_dn_list}
      ${rmod_l_dn_pattern}=  Set Variable  RMOD_L_.*${rmod_sn}
      ${kubectl_command}=  Set Variable
      ...  kubectl logs -n ${vdu_ns} ${pod_name} --all-containers=true | grep -E ${rmod_l_dn_pattern} | head -1
      ${cmd_result}=  tafssh.Execute  command=${kubectl_command}
      ${rmod_l_dn_list}=  Get Regexp Matches  string=${cmd_result}  pattern=RMOD_L_\\d+
      ${kubectl_command}=  Set Variable
      ...  kubectl logs -n ${vdu_ns} ${pod_name} --all-containers=true | grep -i microDtx | grep "Succeeded" | grep ${rmod_l_dn_list[0]} | head -1
      ${cmd_result}=  tafssh.Execute  command=${kubectl_command}
      ${rumag_number_list}=  Get Regexp Matches  string=${cmd_result}  pattern=.*-RUMAG
      ${rumag_number}=  Fetch From Right  string=${rumag_number_list[0]}  marker=${SPACE}
      ${kubectl_command}=  Set Variable
      ...  kubectl logs -n ${vdu_ns} ${pod_name} --all-containers | grep -i ${microdtx_pattern} | grep ${rumag_number}
      ${cmd_result}=  tafssh.Execute  command=${kubectl_command}
      ${pattern_result}=  Get Regexp Matches  string=${cmd_result}  pattern=${microdtx_pattern}
      ${pattern_result_count}=  Get Length  ${pattern_result}
      Run Keyword If  ${antenna_count}>${pattern_result_count}
      ...  Append To List  ${rmod_sn_failed_list}  ${rmod_sn}
    END
    Should Be Empty  item=${rmod_sn_failed_list}
    ...  msg=There is no information in the logs about enable MicroDtx on radio modules: @{rmod_sn_failed_list} !
