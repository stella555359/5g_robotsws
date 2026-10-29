*** Settings ***
Documentation    Common keywords for SFP faults testing
...    Author:        daniel.bartkowiak@nokia.com
...    Maintainer:    Daniel Bartkowiak

*** Keywords ***
Cloud FM SFP Get SFPs From Radio
    [Arguments]  ${ru_sn}  ${vdu_connection}=default
    [Documentation]
    ...  Creates dictionary of 'SFP ids' and 'runtime distname' from Radio based on RU serial number
    ...  and makes them available as test variable 'sfp_ids_dict'
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | ru_sn                     | Yes  | serial number of radio unit under test, default EMPTY              |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | vdu_connection            | No   | vDU connection name from robot.ini, default 'default'              |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    ${sfp_ids_dict}=  Create Dictionary
    ${ru_name}=  vDU RMOD Get Parameter Value Based On Serial Number  rmod_sn=${ru_sn}  rmod_param=product_name
    ${all_sfp_inf}=  vdu.Get Diagnostic Info From Sfp Connections  vdu_connection=${vdu_connection}
    FOR  ${sfp}  IN  @{all_sfp_inf}
        Continue For Loop If  '${ru_name}' not in '${sfp['sfp_port']}'
        ${sfp_id}=  Fetch From Right  string=${sfp['sfp_port']}  marker=IF
        Set To Dictionary  ${sfp_ids_dict}  ${sfp_id}=${sfp['dist_names']['runtime']}
    END
    Should Not Be Empty  ${sfp_ids_dict}  msg=No SFP ids found for RU SN: ${ru_sn}
    Set Test Variable  ${sfp_ids_dict}

Cloud FM SFP Get Initail Value For actTransceiverAlarmMonitoring
    [Arguments]  ${vdu_connection}=default
    [Documentation]
    ...  Gets initial value of parameter 'actTransceiverAlarmMonitoring' from FEATCADM object for teardown purposes.
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | vdu_connection            | No   | vDU connection name from robot.ini, default 'default'              |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    ${status}  ${targetTotalLoad_initial_value}=  Run Keyword And Ignore Error  vdu.Search Parameter Of Current Plan
    ...  mo_dn=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  para_name=actTransceiverAlarmMonitoring
    ...  vdu_connection=${vdu_connection}
    IF  '${status}'=='FAIL'
      Log  ${failed_result}Could not get initial targetTotalLoad value from   console=${log_to_console}
      Log  ${failed_result}Check if parameter exists on provided NRCELL-${nr_cell_id}  console=${log_to_console}
      Fail  Could not get initial targetTotalLoad value from NRCELL-${nr_cell_id}  console=${log_to_console}
    END
    [Return]  ${targetTotalLoad_initial_value}

Cloud FM SFP Perform actTransceiverAlarmMonitoring Recommissioning
    [Arguments]  ${value}  ${vdu_connection}=default
    [Documentation]
    ...  Keyword performs actTransceiverAlarmMonitoring recommissioning on FEATCADM object.
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | value                     | Yes  | recommissioning value of actTransceiverAlarmMonitoring             |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | vdu_connection            | No   | vDU connection object or string name alias if used                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    Log  ${info_prefix}Performing actTransceiverAlarmMonitoring recommissioning  console=${log_to_console}
    ${recommissioning_status}=  Run Keyword And Return Status  vdu.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actTransceiverAlarmMonitoring
    ...  operation=update  value=${value}  timeout=120  vdu_connection=${vdu_connection}
    IF  not ${recommissioning_status}
      Log  ${failed_result}actTransceiverAlarmMonitoring recommissioning failed  console=${log_to_console}
      Fail  actTransceiverAlarmMonitoring recommissioning failed  console=${log_to_console}
    END
    Log  ${info_prefix}actTransceiverAlarmMonitoring recommissioning successfully performed to value ${value}
    ...  console=${log_to_console}

Cloud FM SFP Check If Radio Has Degraded Cells
    [Arguments]  ${ru_sn}  ${vdu_connection}=default
    [Documentation]  Finds degraded cells on radio under test based on RU serial number.
    ...  Keyword fails if any degraded cells found.
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | ru_sn                     | Yes  | serial number of radio unit under test, default EMPTY              |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | vdu_connection            | No   | vDU connection object or string name alias if used                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    ${degraded_cells}=  Create List
    ${rmod_cell_ids_list}=  vDU RMOD Get Parameter Value Based On Serial Number
    ...  rmod_sn=${ru_sn}  rmod_param=cell_ids
    FOR  ${cell_id}  IN  @{rmod_cell_ids_list}
        ${cell_status}=  Run Keyword And Return Status  Cell Check Expected State
        ...  cell_id=${cell_id}
        ...  cell_state=availability_status
        ...  cell_state_value=degraded
        ...  vdu_connection=${vdu_connection}
        IF  ${cell_status}
            Append To List  ${degraded_cells}  ${cell_id}
        END
    END
    IF  not ${degraded_cells}
      Log  ${info_prefix}No degraded cells found on RU SN: ${ru_sn}  console=${log_to_console}
      Fail  No Degraded cells found on RU SN: ${ru_sn}: ${degraded_cells}
    END
    Log  ${info_prefix}Degraded cells found on RU SN: ${ru_sn}: ${degraded_cells}  console=${log_to_console}

Cloud Teardown FM SFP
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

    IF  '${tc_status}'=='FAIL'
      Log  ${info_prefix}Teardown: TC failed. Parameter actTransceiverAlarmMonitoring recovery  console=${log_to_console}
      Run Keyword And Ignore Error  Cloud FM SFP Perform actTransceiverAlarmMonitoring Recommissioning
      ...  value=${actTransceiverAlarmMonitoring_initial_value}
      ...  vdu_connection=${vdu_connection}
      Log  ${info_prefix}Teardown: TC failed. Ensuring vDU is onair after radio recovery  console=${log_to_console}
      Run Keyword And Ignore Error  Cloud FM Check Basic States Onair
      ...  timeout=240  vdu_connection=${vdu_connection}
    END
    Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Cloud FM SFP Get All VDU Cell Ids
    [Arguments]  ${vdu_connection}=default
    [Documentation]  Gets all VDU cell ids and returns them as a list.
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.      |
    ...  +------------------------+------+----------------------------------------------------------+

    ${all_cells}=  Create List
    ${vdu_cells_info}=  vdu.Get Vdu Cell Id  vdu_connection=${vdu_connection}
    FOR  ${cell}  IN  @{vdu_cells_info}
      ${keys_list}=  Get Dictionary Keys  ${cell}
      ${id}=  Fetch From Right  string=${keys_list[0]}  marker=-
      Append To List  ${all_cells}  ${id}
    END
    [Return]  ${all_cells}

Cloud FM SFP Get Cells From Other Radios Than Tested RU
    [Arguments]  ${ru_sn}  ${vdu_connection}=default
    [Documentation]  Gets all VDU cell ids except those belonging to tested RU based on RU serial number.
    ...  +========================+======+==========================================================+
    ...  | ru_sn                  |  Yes | tested radio serial number                               |
    ...  +------------------------+------+----------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.      |
    ...  +------------------------+------+----------------------------------------------------------+
    ${rmod_cell_ids_list}=  vDU RMOD Get Parameter Value Based On Serial Number
    ...  rmod_sn=${ru_sn}  rmod_param=cell_ids
    ${all_cells_ids}=  Cloud FM SFP Get All VDU Cell Ids  vdu_connection=${vdu_connection}
    Remove Values From List  ${all_cells_ids}  @{rmod_cell_ids_list}
    Set Test Variable  ${not_impacted_cells}  ${all_cells_ids}

Cloud FM SFP Verify R&D Fault In Snapshot
    [Arguments]  ${fault_id}  ${trigger_timestamp_epoch}  ${state}  ${vdu_connection}=default
    [Documentation]  Verifies if specified R&D fault is present in snapshot. Checks if fault has correct state and timestamp after triggering.
    ...  +===========================+======+============================================================+
    ...  | fault_id                  | Yes  | ID of the R&D fault to check                               |
    ...  +---------------------------+------+------------------------------------------------------------+
    ...  | trigger_timestamp_epoch   | Yes  | timestamp to check for R&D fault in epoch                  |
    ...  +---------------------------+------+------------------------------------------------------------+
    ...  | state                     | Yes  | expected state of the R&D fault, possible: Raise or Clear  |
    ...  +---------------------------+------+------------------------------------------------------------+
    ...  | vdu_connection            | No   | vDU connection object or string name alias if used.        |
    ...  +---------------------------+------+------------------------------------------------------------+

    ${snapshot_download_status}  ${snapshot_path}=  Run Keyword And Ignore Error
    ...  vdu.Get Local Snapshot  directory=${TC_LOGS_DIR_PATH}
    ...  compressed_or_not=True  vdu_connection=${vdu_connection}
    IF  '${snapshot_download_status}'=='FAIL'  Fail  msg=Snapshot was not collected from vdu
    ${arch_files_dict}=  Get Regex Match Nested Archives In Cloud Snapshot  zip_path=${snapshot_path}  regex_pattern=fm_fault_history
    ${parent_zip_name}=  Get Dictionary Keys  ${arch_files_dict}
    ${fault_zip_name}=  Get From Dictionary  ${arch_files_dict}  ${parent_zip_name}[0]
    ${fault_match_list}=  Search Regex In Nested Cloud Archives
    ...  main_arch_path=${snapshot_path}
    ...  nested_arch_path=${parent_zip_name}[0]/${fault_zip_name}[0]
    ...  r_pattern=${fault_id}
    IF  len(${fault_match_list})==0  Fail  msg=R&D fault ${fault_id} not found in fm_fault_history file in snapshot
    FOR  ${match}  IN  @{fault_match_list}
      ${match_values}=  Split String  ${match}  separator=|
      ${match_time}=  Evaluate  "${match_values[2]}".strip()
      ${match_time}=  Evaluate  "${match_time}".replace("Z", "+00:00")
      ${match_time_utc}=  Evaluate  datetime.datetime.fromisoformat("${match_time}").astimezone(datetime.timezone.utc)  modules=datetime
      ${match_time_in_epoch}=  Convert Date  date=${match_time_utc}
      ...  result_format=epoch
      ...  exclude_millis=False
      ${is_time_correct}=  Evaluate  ${match_time_in_epoch} > ${trigger_timestamp_epoch}
      ${match_state}=  Evaluate  "${match_values[7]}".strip()
      ${is_state_correct}=  Evaluate  '${match_state}'=='${state}'
      Return From Keyword If  ${is_time_correct} and ${is_state_correct}
    END
    Fail  msg=R&D fault ${fault_id} found with wrong timestamp or state. Expected state: ${state} and timestamp after: ${trigger_timestamp_epoch}