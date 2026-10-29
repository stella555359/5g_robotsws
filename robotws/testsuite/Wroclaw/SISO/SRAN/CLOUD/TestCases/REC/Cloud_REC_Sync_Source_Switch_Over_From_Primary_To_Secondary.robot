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
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/operations.robot
Resource    ../../resources/Robot/L3_call.robot

*** Variables ***
@{VDU_SYNC_SWITCH_OVER_ALLOWED_HIST_ALARMS}=  faultId=4122, severity=minor
...                        faultId=1898, severity=minor

*** Keywords ***
TC__Cloud_REC_Sync_Source_Switch_Over_From_Primary_To_Secondary
    [Arguments]  ${scfc_file_path}  ${cells_yaml_path}=${EMPTY}  ${cell_list}=@{EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-11538
    ...  NOTE. Reference scf for TS need to contain runtime objects (_R) for successful execution.
    ...  Test is to verify synchronization switch over after a synchronization input error.
    ...  Test case interrupts primary sync signal (GNSS) and waits for expected sync switchover to secondary source.
    ...  Test case also handles L3 call before and after synchronization break.
    ...  Test is able to interrupt GNSS signal only when GPS reveiver supports manual location entry tested on AYGE
    ...
    ...  Step 1: Precheck States On VDU HW
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  c) All radio units are online
    ...     Radio module expected states:  administrative_state = Unlocked
    ...                                    operational_state = enabled
    ...                                    availability_status = on line
    ...  d) Check if active sync source is GNSSE
    ...  Step 2: Execute L3 Call
    ...  a) L3 call succesful on selected cells
    ...  Step 3: Perform Primary Sync Break (GNSS)
    ...  a) Perform primary (GNSS) sync break. Recommissioned parameters: locationMode = manual (update parameter)
    ...                                                                   gnssAntennaAltitudeConf = random_nidd_value
    ...                                                                   gnssAntennaLatitudeConf = random_nidd_value
    ...                                                                   gnssAntennaLongitudeConf = random_nidd_value
    ...  b) Waiting for fault 1898
    ...  c) Secondary synchronization should be active
    ...  d) All cells should be onair
    ...  Step 4: Execute L3 Call
    ...  a) L3 call succesful on selected cells
    ...  Step 5: Perform Primary Sync Reconnection (GNSS)
    ...  a) Perform primary (GNSS) sync reconnection. Recommissioned parameters: locationMode = automatic (update parameter)
    ...                                                                   gnssAntennaAltitudeConf (delete parameter)
    ...                                                                   gnssAntennaLatitudeConf (delete parameter)
    ...                                                                   gnssAntennaLongitudeConf (delete parameter)
    ...  b) Perform reset GNSSE.
    ...  c) All cells should be onair
    ...  Step 6: Execute L3 Call
    ...  a) L3 call succesful on selected cells
    ...  Step 7: Post check
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  c) All radio units are online
    ...     Radio module expected states:  administrative_state = Unlocked
    ...                                    operational_state = enabled
    ...                                    availability_status = on line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_list              |  No  | list of cells ids for call NR->nr_cell_identity LTE->eutranCellId          |
    ...  |                        |      | If @{EMPTY} set, it means all cells will be called                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cells_yaml_path        |  No  | If call is needed, please prepare path to yaml file with cells             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Set Test Variable  ${log_to_console}
    Set Test Variable  ${scfc_file_path}
    Set Test Variable  ${cell_list}
    Set Test Variable  ${cells_yaml_path}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_SYNC_SWITCH_OVER_ALLOWED_HIST_ALARMS}
    Log  ${start_prefix_green}Test Case: TC__Cloud_REC_Sync_Source_Switch_Over_From_Primary_To_Secondary  console=${log_to_console}
    Step 1: Precheck States On VDU HW
    Step 2: Execute L3 Call
    Step 3: Perform Primary Sync Break (GNSS)
    Step 4: Execute L3 Call
    Step 5: Perform Primary Sync Reconnection (GNSS)
    Step 6: Execute L3 Call
    Step 7: Post Check
    Log  ${done_prefix_green}Test Case: TC__Cloud_REC_Sync_Source_Switch_Over_From_Primary_To_Secondary  console=${log_to_console}
    [Teardown]  TC_PM_Sync_Switchover_Teardown  tc_status=${KEYWORD_STATUS}

Step 1: Precheck States On VDU HW
    vDU Rest Login
    ${syncbreak_add_del_dict}=  Prepare GNSSE Parameters
    Set Test Variable  ${syncbreak_add_del_dict}
    ${syncbreak_update_dict}=  Create Dictionary  locationMode=manual
    ${syncrecon_update_dict}=  Create Dictionary  locationMode=automatic
    Set Test Variable  ${syncbreak_update_dict}
    Set Test Variable  ${syncrecon_update_dict}
    Log  ${dots_prefix_green}Step 1: Precheck States On VDU HW  console=${log_to_console}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${rmods_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${scfc_file_path}
    FOR  ${ru_sn}  IN  @{rmods_sn_list}
      RMOD Wait For Online  rmod_sn=${ru_sn}
    END
    Log  ${info_prefix}All radio units online  console=${log_to_console}
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=${FALSE}
    Set Test Variable   ${MRBTS_ID}  ${mrbts_id}
    ${precheck_scf_path}=  vdu.Get Current Plan File  local_dir_path=${OUTPUT_DIR}
    ...  filename=precheck_scf_${MRBTS_ID}.xml
    ${gnsse_obj_list}=  SCFC Get Regexp Matches Dist Name  scfc_file_path=${precheck_scf_path}  dist_name=.*?GNSSE-\\d+
    Set Test Variable  ${gnsse_obj_list}
    ${gnsse_num}=  Get Length  ${gnsse_obj_list}
    Run Keyword If  ${gnsse_num}!=1  Fail  There should be defined only one GNSSE object but found: ${/n} ${gnsse_obj_list}
    ${clock}  ${gnsse}=  Split String From Right  ${gnsse_obj_list[0]}  /  1
    Set Test Variable  ${clock}
    ${is_gnsse}=  Evaluate Xpath  ${precheck_scf_path}
    ...  boolean(.//managedObject[(contains(@distName, "${clock}/CLOCK_R") and p[@name='activeTimeSource']='ExternalGnss')])
    Run Keyword If  not ${is_gnsse}  Fail  Active sync source should be ExternalGnss
    ${gnsse_r_distname}=  Evaluate Xpath  ${precheck_scf_path}  .//managedObject[p[@name='configDN']='${gnsse_obj_list[0]}']/@distName
    Set Test Variable  ${gnsse_r_distname}
    Run Keyword If  not ${is_gnsse}  Fail  Active sync source should be ExternalGnss
    ${init_locationMode_value}=  Evaluate Xpath
    ...  ${precheck_scf_path}
    ...  string(.//managedObject[contains(@distName, '${gnsse_obj_list[0]}')]/p[@name='locationMode'])
    Run Keyword If  '${init_locationMode_value}'!='automatic'
    ...  Fail  Env issue. Initial parameter "locationMode" value should be "automatic"
    Log  ${info_prefix}Active sync source is ExternalGnss  console=${log_to_console}
    Log  ${ok_prefix_green}Step 1: Precheck States On VDU HW  console=${log_to_console}

Step 2: Execute L3 Call
    Log  ${dots_prefix_green}Step 2: Execute L3 Call  console=${log_to_console}
    Cloud L3 Call  scfc_file_path=${scfc_file_path}  cells_yaml_path=${cells_yaml_path}  cells_input=${cell_list}
    Log  ${ok_prefix_green}Step 2: Execute L3 Call  console=${log_to_console}

Step 3: Perform Primary Sync Break (GNSS)
    Log  ${dots_prefix_green}Step 3: Perform Primary Sync Break (GNSS)  console=${log_to_console}
    ${recomm_sync_break_dict}=  Create Dictionary  update=${syncbreak_update_dict}  create=${syncbreak_add_del_dict}
    ${json_sync_break}=  Create Single Dist Name Json String
    ...  mo_dn=${gnsse_obj_list[0]}
    ...  updated_params_dict=${recomm_sync_break_dict}
    ...  distname_operation=update
    vdu.Perform Delta recommissioning
    ...  delta_file=${json_sync_break[0]}
    Log  ${info_prefix}GPS sync break performed. Waiting 180s for sync source switch  console=${log_to_console}
    Sleep  180s  Waiting 180s for sync source switch
    ${gnss_sync_break_scf_path}=  vdu.Get Current Plan File  local_dir_path=${OUTPUT_DIR}
    ...  filename=gnss_sync_break_scf_${mrbts_id}.xml
    ${is_top}=  Evaluate Xpath  ${gnss_sync_break_scf_path}
    ...  boolean(.//managedObject[(contains(@distName, "${clock}/CLOCK_R") and p[@name='activeTimeSource']='Top')])
    Run Keyword If  not ${is_top}  Fail  Active sync source should be TOP but is GNSSE
    Log  ${info_prefix}Secondary sync source TOP is active  console=${log_to_console}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Perform Primary Sync Break (GNSS)  console=${log_to_console}

Step 4: Execute L3 Call
    Log  ${dots_prefix_green}Step 4: Execute L3 Call  console=${log_to_console}
    Cloud L3 Call  scfc_file_path=${scfc_file_path}  cells_yaml_path=${cells_yaml_path}  cells_input=${cell_list}
    Log  ${ok_prefix_green}Step 4: Execute L3 Call  console=${log_to_console}

Step 5: Perform Primary Sync Reconnection (GNSS)
    Log  ${dots_prefix_green}Step 5: Perform Primary Sync Reconnection (GNSS)  console=${log_to_console}
    ${recomm_resync_dict}=  Create Dictionary  update=${syncrecon_update_dict}  delete=${syncbreak_add_del_dict}
    ${json_resync}=  Create Single Dist Name Json String
    ...  mo_dn=${gnsse_obj_list[0]}
    ...  updated_params_dict=${recomm_resync_dict}
    ...  distname_operation=update
    vdu.Perform Delta recommissioning
    ...  delta_file=${json_resync[0]}
    Log  ${info_prefix}GPS sync reconnection performed. Waiting for sync source switch  console=${log_to_console}
    Log  ${info_prefix}GPS reset ongoing  console=${log_to_console}
    Sleep  5  Stabilize after delta commissioning
    vdu.Reset Gnss  gnsse_r_dn=${gnsse_r_distname[0]}
    vDU Assert Alarm Inactive  fault_id=1898  vdu_login=${FALSE}  timeout=300
    Sleep  10  Stabilize before resync
    ${gnss_resync_scf_path}=  vdu.Get Current Plan File  local_dir_path=${OUTPUT_DIR}
    ...  filename=gnss_resync_scf_${mrbts_id}.xml
    ${is_resync}=  Evaluate Xpath  ${gnss_resync_scf_path}
    ...  boolean(.//managedObject[(contains(@distName, "${clock}/CLOCK_R") and p[@name='activeTimeSource']='ExternalGnss')])
    Run Keyword If  not ${is_resync}  Fail  Active sync source should be ExternalGnss but is ToP
    Log  ${info_prefix}Active sync source is ExternalGnss  console=${log_to_console}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Perform Primary Sync Reconnection (GNSS)  console=${log_to_console}

Step 6: Execute L3 Call
    Log  ${dots_prefix_green}Step 6: Execute L3 Call  console=${log_to_console}
    Cloud L3 Call  scfc_file_path=${scfc_file_path}  cells_yaml_path=${cells_yaml_path}  cells_input=${cell_list}
    Log  ${ok_prefix_green}Step 6: Execute L3 Call  console=${log_to_console}

Step 7: Post Check
    Log  ${dots_prefix_green}Step 7: Post check  console=${log_to_console}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${rmods_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${scfc_file_path}
    FOR  ${ru_sn}  IN  @{rmods_sn_list}
      RMOD Wait For Online  rmod_sn=${ru_sn}
    END
    Log  ${info_prefix}All radio units online  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: Post check  console=${log_to_console}

Prepare GNSSE Parameters
    [Documentation]
    ...  Description:
    ...  Kw prepares random values for GNSSE recommissioning. Returns useful dictionary with parameters and values
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${altitude}=  Get Random List  begin_range=-500  end_range=1800  length=1
    ${altitude_tmp}=  Convert To String  ${altitude[0]}
    ${latitude}=  Get Random List  begin_range=-900000000  end_range=900000000  length=1
    ${latitude_tmp}=  Convert To String  ${latitude[0]}
    ${longitude}=  Get Random List  begin_range=-1800000000  end_range=1800000000  length=1
    ${longitude_tmp}=  Convert To String  ${longitude[0]}
    ${gnsse_parameters_dict}=  Create Dictionary
    ...  gnssAntennaAltitudeConf=${altitude_tmp}
    ...  gnssAntennaLatitudeConf=${latitude_tmp}
    ...  gnssAntennaLongitudeConf=${longitude_tmp}
    [Return]  ${gnsse_parameters_dict}

TC_PM_Sync_Switchover_Teardown
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

    ${recomm_resync_dict}=  Create Dictionary  update=${syncrecon_update_dict}  delete=${syncbreak_add_del_dict}
    ${json_resync}=  Create Single Dist Name Json String
    ...  mo_dn=${gnsse_obj_list[0]}
    ...  updated_params_dict=${recomm_resync_dict}
    ...  distname_operation=update
    Run Keyword If  "${tc_status}"=="FAIL"  Run Keywords  Run Keyword And Ignore Error
    ...  vdu.Perform Delta recommissioning
    ...  delta_file=${json_resync[0]}
    ...  AND  Sleep  5  Stabilize after delta sommissioning
    ...  AND  Run Keyword And Ignore Error  vdu.Reset Gnss  gnsse_r_dn=${gnsse_r_distname[0]}
    ...  AND  Run Keyword And Ignore Error  vDU Assert Alarm Inactive  fault_id=1898  vdu_login=${FALSE}  timeout=300
    Run Keyword And Ignore Error  vDU Rest Logout
