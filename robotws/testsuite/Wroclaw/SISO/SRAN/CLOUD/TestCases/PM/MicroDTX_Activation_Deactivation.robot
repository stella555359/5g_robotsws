*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    DateTime
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/operations.robot
Resource    ../../resources/variables.robot

*** Keywords ***
TC MicroDTX Activation Deactivation
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-43254
    ...  Test case for CB011178-CR-D2 SiSo parity feature (5GC000430 Adaption).
    ...
    ...  Test case activate and deactivate micro discontinuous transmission (µDTX) feature and checks
    ...  power of radio modules.
    ...
    ...  Step 1: Initial check
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  c) Check if radio module serial number is in configuration
    ...  d) Check if MicroDTX parameter (actMicroDTX) is disabled
    ...  e) Create lists with PIM counters
    ...  Step 2: Activate Micro Discontinuous Transmission (MicroDTX)
    ...  a) Set parameter "actMicroDTX" to "true".
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  Step 3: Check radio modules power after activating Micro Discontinuous Transmission (MicroDTX)
    ...  Step 4: Dectivate Micro Discontinuous Transmission (MicroDTX)
    ...  a) Set parameter "actMicroDTX" to "false".
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  Step 5: Check radio modules power after dectivating Micro Discontinuous Transmission (MicroDTX)
    ...  Step 6: Compare radio module power before and after activating MicroDTX
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           | Yes  | List of serial number of the tested radio modules.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  ${start_prefix_green}Test Case: MicroDTX Activation Deactivation  console=${log_to_console}
    vDU Rest Login
    ${teardown_updated_params_dict}=  Create Dictionary  actMicroDTX=false
#Step 1: Initial check
    Log  ${dots_prefix_green}Step 1: Initial check  console=${log_to_console}
    ${measurements_number}=  Set Variable  3
    ${vdu_k8s_connection_params}=  Get vDU K8s Master Node Connection Parameters From Init File
    ${ip_addr}=  Set Variable  ${vdu_k8s_connection_params['ip_addr']}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    ${scfc_rmod_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${scfc_file_path}
	${rmod_serial_number_list}=  Run Keyword If  'ALL' in ${rmod_sn_list}
    ...  Create List  @{scfc_rmod_sn_list}
    ...  ELSE IF  'RANDOM' in ${rmod_sn_list}
    ...  Get Random List Based On Input List  list=${scfc_rmod_sn_list}  length=${rmod_sn_list[1]}
    ...  ELSE IF  'SELECT' in ${rmod_sn_list}
    ...  Create List  @{rmod_sn_list[1:None]}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=False
    ${actmicrodtx_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}
    Log  ${info_prefix}Micro Discontinuous Transmission activation parameter (actMicroDTX) checking  console=${log_to_console}
    ${actmicrodtx_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${actmicrodtx_mo_dn}  para_name=actMicroDTX
    ${updated_params_dict}=  Create Dictionary  actMicroDTX=false
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=${actmicrodtx_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Run Keyword If  '${actmicrodtx_value}'=='true'  Run Keywords
    ...  Log  ${below_info_prefix}Recommissioning to deactivate micro discontinuous transmission (µDTX) (actMicroDTX=false) ...
    ...  console=${log_to_console}
    ...  AND
    ...  vdu.Perform Delta Recommissioning  delta_file=${json_parameters_update[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${actmicrodtx_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${actmicrodtx_mo_dn}  para_name=actMicroDTX
    Log  ${below_info_prefix}Parameter "actMicroDTX" is now set to "${actmicrodtx_value}"  console=${log_to_console}
    Log  ${done_prefix_green}Step 1: Initial check  console=${log_to_console}
#Step 2: Activate Micro Discontinuous Transmission (MicroDTX)
    Log  ${dots_prefix_green}Step 2: Activate Micro Discontinuous Transmission (MicroDTX)  console=${log_to_console}
    ${actmicrodtx_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}
    Log  ${info_prefix}Micro Discontinuous Transmission activation parameter (actMicroDTX) setting  console=${log_to_console}
    ${actmicrodtx_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${actmicrodtx_mo_dn}  para_name=actMicroDTX
    ${updated_params_dict}=  Create Dictionary  actMicroDTX=true
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=${actmicrodtx_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Run Keyword If  '${actmicrodtx_value}'=='false'  Run Keywords
    ...  Log  ${below_info_prefix}Recommissioning to deactivate micro discontinuous transmission (µDTX) (actMicroDTX=true) ...
    ...  console=${log_to_console}
    ...  AND
    ...  vdu.Perform Delta Recommissioning  delta_file=${json_parameters_update[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${actmicrodtx_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${actmicrodtx_mo_dn}  para_name=actMicroDTX
    Log  ${below_info_prefix}Parameter "actMicroDTX" is now set to "${actmicrodtx_value}"  console=${log_to_console}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${done_prefix_green}Step 2: Activate Micro Discontinuous Transmission (MicroDTX)  console=${log_to_console}
#Step 3: Check radio modules power after activating Micro Discontinuous Transmission (MicroDTX)
    Log  ${dots_prefix_green}Step 3: Check radio modules power after activating Micro Discontinuous Transmission (MicroDTX)
    ...  console=${log_to_console}
    ${rmod_power_activate_dict}=  Create Dictionary
    FOR  ${rmod_serial_number}  IN  @{rmod_serial_number_list}
      ${rmod_psu_values_list}=  radio.Get Radio Unit Psu Measurements  ru_serial_number=${rmod_serial_number}
      ...  number_of_measurements=${measurements_number}  interval=3  cloud_server_ip=${ip_addr}
      ${actual_power}=  Calculate Average Value   rmod_psu_values_list=${rmod_psu_values_list}
      Set To Dictionary  ${rmod_power_activate_dict}  ${rmod_serial_number}=${actual_power}
      Log  ${info_prefix}Radio module (sn: ${rmod_serial_number}) power - ${measurements_number} measurements: ${actual_power}
      ...  console=${log_to_console}
    END
    Log  ${done_prefix_green}Step 3: Check radio modules power after activating Micro Discontinuous Transmission (MicroDTX)
    ...  console=${log_to_console}
#Step 4: Dectivate Micro Discontinuous Transmission (MicroDTX)
    Log  ${dots_prefix_green}Step 4: Dectivate Micro Discontinuous Transmission (MicroDTX)  console=${log_to_console}
    ${actmicrodtx_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}
    Log  ${info_prefix}Micro Discontinuous Transmission deactivation parameter (actMicroDTX) setting  console=${log_to_console}
    ${updated_params_dict}=  Create Dictionary  actMicroDTX=false
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=${actmicrodtx_mo_dn}
    vdu.Perform Delta Recommissioning  delta_file=${json_parameters_update[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${actmicrodtx_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${actmicrodtx_mo_dn}  para_name=actMicroDTX
    Log  ${below_info_prefix}Parameter "actMicroDTX" is now set to "${actmicrodtx_value}"  console=${log_to_console}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${done_prefix_green}Step 4: Dectivate Micro Discontinuous Transmission (MicroDTX)  console=${log_to_console}
#Step 5: Check radio modules power after dectivating Micro Discontinuous Transmission (MicroDTX)
    Log  ${dots_prefix_green}Step 5: Check radio modules power after dectivating Micro Discontinuous Transmission (MicroDTX)
    ...  console=${log_to_console}
    ${rmod_power_deactivate_dict}=  Create Dictionary
    FOR  ${rmod_serial_number}  IN  @{rmod_serial_number_list}
      ${rmod_psu_values_list}=  radio.Get Radio Unit Psu Measurements  ru_serial_number=${rmod_serial_number}
      ...  number_of_measurements=${measurements_number}  interval=3  cloud_server_ip=${ip_addr}
      ${actual_power}=  Calculate Average Value   rmod_psu_values_list=${rmod_psu_values_list}
      Set To Dictionary  ${rmod_power_deactivate_dict}  ${rmod_serial_number}=${actual_power}
      Log  ${info_prefix}Radio module (sn: ${rmod_serial_number}) power - ${measurements_number} measurements: ${actual_power}
      ...  console=${log_to_console}
    END
    Log  ${done_prefix_green}Step 5: Check radio modules power after dectivating Micro Discontinuous Transmission (MicroDTX)
    ...  console=${log_to_console}
#Step 6: Compare radio modules power before and after activating MicroDTX
    Log  ${dots_prefix_green}Step 6: Compare radio modules power before and after activating MicroDTX  console=${log_to_console}
    ${rmod_sn_activate_list}=  Get Dictionary Keys  dictionary=${rmod_power_activate_dict}
    ${rmod_sn_deactivate_list}=  Get Dictionary Keys  dictionary=${rmod_power_deactivate_dict}
    Lists Should Be Equal  list1=${rmod_sn_activate_list}  list2=${rmod_sn_deactivate_list}
    ...  msg=Radio modules list before and after activation MicroDTX should be the same !
    FOR  ${rmod_sn_activate}  ${rmod_sn_deactivate}  IN ZIP  ${rmod_sn_activate_list}  ${rmod_sn_deactivate_list}
      Run Keyword If  ${rmod_power_activate_dict['${rmod_sn_activate}']}<${rmod_power_deactivate_dict['${rmod_sn_deactivate}']}
      ...  Log  ${info_prefix}Radio module power (sn: ${rmod_sn_activate}) after MicroDTX activation is lower than before activation
      ...  console=${log_to_console}
      ...  ELSE
      ...  Run Keyword And Continue On Failure
      ...  Fail  msg=Radio module power (sn: ${rmod_sn_activate}) after MicroDTX activation is higher than before activation !
    END
    Log  ${done_prefix_green}Step 6: Compare radio module power before and after activating MicroDTX  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: MicroDTX Activation Deactivation  console=${log_to_console}
    [Teardown]  Run Keywords  Run Keyword If  '${KEYWORD STATUS}'=='FAIL'
    ...  vDU Check And Update Parameter Of Delta Plan  mo_dn=${actmicrodtx_mo_dn}  updated_params_dict=${teardown_updated_params_dict}
    ...  AND  Run Keyword And Ignore Error  vDU Rest Logout

#INTERNAL TEST CASE KEYWORDS
Calculate Average Value
    [Arguments]  ${rmod_psu_values_list}
    ${rmod_power_count}=  Get Length  item=${rmod_psu_values_list}
    ${power}=  Set Variable  ${0}
    FOR  ${rmod_psu_dict}  IN  @{rmod_psu_values_list}
      ${power}=  Evaluate  expression=${power}+${rmod_psu_dict['power']}
    END
    ${rmod_power}=  Evaluate  expression=${power}/${rmod_power_count}
    ${rmod_power}=  Evaluate  expression=int(${rmod_power})
    [Return]  ${rmod_power}
