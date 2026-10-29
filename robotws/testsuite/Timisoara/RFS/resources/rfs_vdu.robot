*** Settings ***
Documentation    Keywords using taf vdu library
...              Resource used by RF Sharing Vrf tribe
...              Author: Dinu Olariu
...              Contact: dinu.olariu@nokia.com

Library    Collections
Library    OperatingSystem
Library    python_resources/alarms_analysis.py
Library    String
Library    taf.gnb.oam.coam.vdu  WITH NAME  vdu

*** Keywords ***

VDU Get SW Version
    [Documentation]
    ...  Get active software version on CBTS VDU.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                        |
    ...  | vdu_connection | No   | VDU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                 |
    ...  | VDU_software_version | VDU active software version |
    ...

    [Arguments]  ${vdu_connection}=None

    ${VDU_state_data}=  vdu.Get VDU State Data  vdu_connection=${vdu_connection}

    ${VDU_software_version}=  Get From Dictionary  ${VDU_state_data}  software_version

    [Return]  ${VDU_software_version}

VDU Get Name
    [Documentation]
    ...  Get CBTS VDU name.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter      | Man. | Description                                        |
    ...  | vdu_connection | No   | VDU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter | Description |
    ...  | VDU_name   | VDU name   |
    ...
    [Arguments]  ${vdu_connection}=None

    ${VDU_state_info}=  vdu.Get Vdu State Data  vdu_connection=${vdu_connection}
    ${VDU_name}=  Get From Dictionary  ${VDU_state_info}  name

    [Return]  ${VDU_name}

VDU Get Current Plan File
    [Documentation]
    ...  Get CBTS VDU SCF.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                             |
    ...  | local_dir_path       | No   | Path to directory to stored SCF                         |
    ...  | filename             | No   | Filename stored SCF                                     |
    ...  | timeout              | No   | Timeout for the operation in seconds. Default value: 30 |
    ...  | include_runtime_data | No   | Include runtime data or not. Default value: True        |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None      |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                                 |
    ...  | VDU_SCF_path_file_info | CBTS VDU SCF full path where file is stored |
    ...
    [Arguments]  ${local_dir_path}=${EMPTY}  ${filename}=${EMPTY}  ${timeout}=30  ${include_runtime_data}=True  ${vdu_connection}=None

    ${include_runtime_data}=  Convert To Boolean  ${include_runtime_data}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${local_dir_path}=  Set Variable If  '${local_dir_path}' == '${EMPTY}'  /tmp  ${local_dir_path}
    ${filename}=  Set Variable If  '${filename}' == '${EMPTY}'  VDU_SCF_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.xml  ${filename}

    ${VDU_SCF_path_file_info}=  vdu.Get Current Plan File  local_dir_path=${local_dir_path}  filename=${filename}  timeout=${timeout}
    ...  include_runtime_data=${include_runtime_data}  vdu_connection=${vdu_connection}

    ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${VDU_SCF_path_file_info}
    Run Keyword If  not ${status}  Run Keywords
    ...  Log  ${vdu_connection} SCF file not available at ${local_dir_path}/${filename}  level=ERROR
    ...  AND  Fail  ${vdu_connection} SCF file not available at ${local_dir_path}/${filename}

    [Return]  ${VDU_SCF_path_file_info}

VDU Check Cells Expected Status
    [Documentation]
    ...  Check all VDU cells current status to be aligned with expected status
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                        |
    ...  | operational_state    | Yes  | Expected VDU cell operational state.               |
    ...  | availability_status  | Yes  | Expected VDU cell availability status.             |
    ...  | administrative_state | Yes  | Expected VDU cell administrative state.            |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter             | Description                                                                                 |
    ...  | VDU_CELL_check_status | ${True} if VDU all cells current status is aligned with expected status, otherwise ${False} |
    ...
    [Arguments]  ${operational_state}  ${availability_status}  ${administrative_state}  ${vdu_connection}=None

    ${VDU_CELL_check_status}=  Set Variable  ${True}

    ${VDU_CELL_info}=  vdu.Get Vdu Cells Status  vdu_connection=${vdu_connection}

    FOR  ${cell_info}  IN  @{VDU_CELL_info}

        ${VDU_CELL_operational_state}=  Get From Dictionary  ${cell_info}  operational_state
        ${VDU_CELL_availability_status}=  Get From Dictionary  ${cell_info}  availability_status
        ${VDU_CELL_administrative_state}=  Get From Dictionary  ${cell_info}  administrative_state

        ${cond_operational_state}=  Set Variable  '${VDU_CELL_operational_state}' not in '${operational_state}'
        ${cond_availability_status}=  Set Variable  '${VDU_CELL_availability_status}' not in '${availability_status}'
        ${cond_administrative_state}=  Set Variable  '${VDU_CELL_administrative_state}' not in '${administrative_state}'

        ${VDU_CELL_check_status}=  Set Variable If  ${cond_operational_state} or ${cond_availability_status} or ${cond_administrative_state}
        ...  ${False}  ${VDU_CELL_check_status}

    END

    [Return]  ${VDU_CELL_check_status}

VDU Check Cell Expected Status
    [Documentation]
    ...  Check VDU cell current status to be aligned with expected status. KW is passed if VDU cell current status is aligned with expected status,
    ...  otherwise it fails
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                        |
    ...  | cell_id              | Yes  | VDU cell identifier.                               |
    ...  | operational_state    | Yes  | Expected VDU cell operational state.               |
    ...  | availability_status  | No   | Expected VDU cell availability status.             |
    ...  | administrative_state | No   | Expected VDU cell administrative state.            |
    ...  | blocking_state       | No   | Expected VDU cell blocking state.                  |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None |
    ...
    [Arguments]  ${cell_id}  ${operational_state}  ${availability_status}=None  ${administrative_state}=None  ${blocking_state}=None
    ...  ${vdu_connection}=None

    ${VDU_CELL_check_status}=  Set Variable  ${True}

    ${VDU_CELL_info}=  vdu.Get Vdu Cells Status  vdu_connection=${vdu_connection}

    FOR  ${cell_info}  IN  @{VDU_CELL_info}

        ${VDU_CELL_id}=  Get From Dictionary  ${cell_info}  id
        ${cell_info_dist_names}=  Get From Dictionary  ${cell_info}  dist_names
        ${VDU_CELL_config_dn}=  Get From Dictionary  ${cell_info_dist_names}  config

        Continue For Loop If  '${cell_id}' not in ['${VDU_CELL_id}', '${VDU_CELL_config_dn}']

        ${VDU_CELL_operational_state}=  Get From Dictionary  ${cell_info}  operational_state
        ${VDU_CELL_availability_status}=  Run Keyword If  '${availability_status}' != 'None'
        ...  Get From Dictionary  ${cell_info}  availability_status
        ...  ELSE
        ...  Set Variable  ${availability_status}
        ${VDU_CELL_administrative_state}=  Run Keyword If  '${administrative_state}' != 'None'
        ...  Get From Dictionary  ${cell_info}  administrative_state
        ...  ELSE
        ...  Set Variable  ${administrative_state}
        ${VDU_CELL_blocking_state}=  Run Keyword If  '${blocking_state}' != 'None'
        ...  Get From Dictionary  ${cell_info}  blocking_state
        ...  ELSE
        ...  Set Variable  ${blocking_state}

        ${cond_operational_state}=  Set Variable  '${VDU_CELL_operational_state}' not in '${operational_state}'
        ${cond_availability_status}=  Set Variable If  '${availability_status}' != 'None'
        ...  '${VDU_CELL_availability_status}' not in '${availability_status}'  ${False}
        ${cond_administrative_state}=  Set Variable If  '${administrative_state}' != 'None'
        ...  '${VDU_CELL_administrative_state}' not in '${administrative_state}'  ${False}
        ${cond_blocking_state}=  Set Variable If  '${blocking_state}' != 'None'
        ...  '${VDU_CELL_blocking_state}' not in '${blocking_state}'  ${False}

        ${VDU_CELL_check_status}=  Set Variable If
        ...  ${cond_operational_state} or ${cond_availability_status} or ${cond_administrative_state} or ${cond_blocking_state}
        ...  ${False}  ${VDU_CELL_check_status}

        Exit For Loop

    END

    Should Be True  ${VDU_CELL_check_status}

VDU Check RMODs Expected Status
    [Documentation]
    ...  Check all VDU radio modules current status to be aligned with expected status
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                        |
    ...  | operational_state    | Yes  | Expected VDU RMOD operational state.               |
    ...  | availability_status  | Yes  | Expected VDU RMOD availability status.             |
    ...  | administrative_state | Yes  | Expected VDU RMOD administrative state.            |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter             | Description                                                                                         |
    ...  | VDU_RMOD_check_status | ${True} if VDU all radio modules current status is aligned with expected status, otherwise ${False} |
    ...
    [Arguments]  ${operational_state}  ${availability_status}  ${administrative_state}  ${vdu_connection}=None

    ${VDU_RMOD_check_status}=  Set Variable  ${True}

    ${VDU_RMOD_info}=  vdu.Get Rmods Status  vdu_connection=${vdu_connection}

    FOR  ${rmod_info}  IN  @{VDU_RMOD_info}

        ${VDU_RMOD_operational_state}=  Get From Dictionary  ${rmod_info}  operational_state
        ${VDU_RMOD_availability_status}=  Get From Dictionary  ${rmod_info}  availability_status
        ${VDU_RMOD_administrative_state}=  Get From Dictionary  ${rmod_info}  administrative_state

        ${cond_operational_state}=  Set Variable  '${VDU_RMOD_operational_state}' not in '${operational_state}'
        ${cond_availability_status}=  Set Variable  '${VDU_RMOD_availability_status}' not in '${availability_status}'
        ${cond_administrative_state}=  Set Variable  '${VDU_RMOD_administrative_state}' not in '${administrative_state}'

        ${VDU_RMOD_check_status}=  Set Variable If  ${cond_operational_state} or ${cond_availability_status} or ${cond_administrative_state}
        ...  ${False}  ${VDU_RMOD_check_status}

    END

    [Return]  ${VDU_RMOD_check_status}

VDU Check RMOD Expected Status
    [Documentation]
    ...  Check VDU radio module current status to be aligned with expected status
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                        |
    ...  | operational_state    | Yes  | Expected VDU RMOD operational state.               |
    ...  | availability_status  | No   | Expected VDU RMOD availability status.             |
    ...  | administrative_state | No   | Expected VDU RMOD administrative state.            |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None |
    ...
    [Arguments]  ${rmod_id}  ${operational_state}  ${availability_status}=None  ${administrative_state}=None  ${vdu_connection}=None

    ${VDU_RMOD_check_status}=  Set Variable  ${True}

    ${VDU_RMOD_info}=  vdu.Get Rmods Status  vdu_connection=${vdu_connection}

    FOR  ${rmod_info}  IN  @{VDU_RMOD_info}

        ${VDU_RMOD_id}=  Get From Dictionary  ${rmod_info}  id
        ${rmod_info_dist_names}=  Get From Dictionary  ${rmod_info}  dist_names
        ${VDU_RMOD_config_dn}=  Get From Dictionary  ${rmod_info_dist_names}  config
        ${VDU_RMOD_runtime_dn}=  Get From Dictionary  ${rmod_info_dist_names}  runtime

        Continue For Loop If  '${rmod_id}' not in ['${VDU_RMOD_id}', '${VDU_RMOD_config_dn}', '${VDU_RMOD_runtime_dn}']

        ${VDU_RMOD_operational_state}=  Get From Dictionary  ${rmod_info}  operational_state
        ${VDU_RMOD_availability_status}=  Run Keyword If  '${availability_status}' != 'None'
        ...  Get From Dictionary  ${rmod_info}  availability_status
        ...  ELSE
        ...  Set Variable  ${availability_status}
        ${VDU_RMOD_administrative_state}=  Run Keyword If  '${administrative_state}' != 'None'
        ...  Get From Dictionary  ${rmod_info}  administrative_state
        ...  ELSE
        ...  Set Variable  ${administrative_state}

        ${cond_operational_state}=  Set Variable  '${VDU_RMOD_operational_state}' not in '${operational_state}'
        ${cond_availability_status}=  Set Variable If  '${availability_status}' != 'None'
        ...  '${VDU_RMOD_availability_status}' not in '${availability_status}'  ${False}
        ${cond_administrative_state}=  Set Variable If  '${administrative_state}' != 'None'
        ...  '${VDU_RMOD_administrative_state}' not in '${administrative_state}'  ${False}

        ${VDU_RMOD_check_status}=  Set Variable If  ${cond_operational_state} or ${cond_availability_status} or ${cond_administrative_state}
        ...  ${False}  ${VDU_RMOD_check_status}

        Exit For Loop

    END

    Should Be True  ${VDU_RMOD_check_status}

VDU Check Expected Operational State
    [Documentation]
    ...  Check VDU current operational state to be aligned with expected operational state
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter         | Man. | Description                                        |
    ...  | operational_state | Yes  | Expected VDU operational state.                    |
    ...  | vdu_connection    | No   | VDU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter                   | Description                                                                                             |
    ...  | VDU_check_operational_state | ${True} if VDU current operational state is aligned with expected operational state, otherwise ${False} |
    ...

    [Arguments]  ${operational_state}  ${vdu_connection}=None

    ${VDU_check_operational_state}=  Set Variable  ${True}

    ${VDU_state_data}=  vdu.Get VDU State Data  vdu_connection=${vdu_connection}

    ${VDU_operational_state}=  Get From Dictionary  ${VDU_state_data}  operational_state

    ${VDU_check_operational_state}=  Set Variable If  '${VDU_operational_state}' not in '${operational_state}'  ${False}
    ...  ${VDU_check_operational_state}

    [Return]  ${VDU_check_operational_state}

VDU Check VDU Expected Status
    [Documentation]
    ...  Check VDU current status to be aligned with expected status
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter         | Man. | Description                                        |
    ...  | operational_state | Yes  | Expected VDU operational state.                    |
    ...  | vdu_connection    | No   | VDU connection instance alias. Default value: None |
    ...

    [Arguments]  ${operational_state}  ${vdu_connection}=None

    ${VDU_state_data}=  vdu.Get VDU State Data  vdu_connection=${vdu_connection}

    ${VDU_operational_state}=  Get From Dictionary  ${VDU_state_data}  operational_state

    ${VDU_check_status}=  Set Variable If  '${VDU_operational_state}' in '${operational_state}'  ${True}  ${False}

    Should Be True  ${VDU_check_status}

VDU Get Cells id config info
    [Documentation]
    ...  Get VDU cells id config runtime info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                        |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter                  | Description                                              |
    ...  | VDU_CELL_id_config_dn_dict | Dict containing structure: {'CELL_id': 'CELL_config_dn'} |
    ...
    [Arguments]  ${vdu_connection}=None

    ${VDU_CELL_id_config_dn_dict}=  Create Dictionary

    ${VDU_CELL_info}=  vdu.Get Vdu Cells Status  vdu_connection=${vdu_connection}

    FOR  ${cell_info}  IN  @{VDU_CELL_info}

        ${VDU_CELL_id}=  Get From Dictionary  ${cell_info}  id
        ${cell_info_dist_names}=  Get From Dictionary  ${cell_info}  dist_names
        ${VDU_CELL_config_dn}=  Get From Dictionary  ${cell_info_dist_names}  config

        Set To Dictionary  ${VDU_CELL_id_config_dn_dict}  ${VDU_CELL_id}  ${VDU_CELL_config_dn}

    END

    [Return]  ${VDU_CELL_id_config_dn_dict}

VDU Block Cell
    [Documentation]
    ...  Perform VDU block cell and wait for expected status operation
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                             |
    ...  | cell_id         | Yes  | VDU cell id                                             |
    ...  | expected_status | No   | Expected status for block cell. Default value: success  |
    ...  | timeout         | No   | Timeout for the operation in seconds. Default value: 60 |
    ...  | vdu_connection  | No   | VDU connection instance alias. Default value: None      |
    ...
    [Arguments]  ${cell_id}  ${expected_status}=success  ${timeout}=60  ${vdu_connection}=None

    ${vdu_block_cell_info}=  vdu.Block Cell  cell_id=${cell_id}  timeout=${timeout}  vdu_connection=${vdu_connection}

    ${vdu_block_cell_id}=  Get From Dictionary  ${vdu_block_cell_info}  id

    Wait Until Keyword Succeeds  ${timeout}  1s  VDU Check Block Cell Status  operation_id=${vdu_block_cell_id}  expected_status=${expected_status}
    ...  timeout=${timeout}  vdu_connection=${vdu_connection}

VDU Check Block Cell Status
    [Arguments]  ${operation_id}  ${expected_status}=success  ${timeout}=60s  ${vdu_connection}=None
    ${operation_result}=  vdu.Get Block Cell Operation Status  operation_id=${operation_id}  timeout=${timeout}  vdu_connection=${vdu_connection}
    ${status_check}=  Get From Dictionary  ${operation_result}  status
    Should Be True  '${status_check}' == '${expected_status}'

VDU Unblock Cell
    [Documentation]
    ...  Perform VDU unblock cell and wait for expected status operation
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                              |
    ...  | cell_id         | Yes  | VDU cell id                                              |
    ...  | expected_status | No   | Expected status for unblock cell. Default value: success |
    ...  | timeout         | No   | Timeout for the operation in seconds. Default value: 60  |
    ...  | vdu_connection  | No   | VDU connection instance alias. Default value: None       |
    ...
    [Arguments]  ${cell_id}  ${expected_status}=success  ${timeout}=60  ${vdu_connection}=None

    ${vdu_unblock_cell_info}=  vdu.Unblock Cell  cell_id=${cell_id}  timeout=${timeout}  vdu_connection=${vdu_connection}

    ${vdu_unblock_cell_id}=  Get From Dictionary  ${vdu_unblock_cell_info}  id

    Wait Until Keyword Succeeds  ${timeout}  1s  VDU Check Unblock Cell Status  operation_id=${vdu_unblock_cell_id}
    ...  expected_status=${expected_status}  timeout=${timeout}  vdu_connection=${vdu_connection}

VDU Check Unblock Cell Status
    [Arguments]  ${operation_id}  ${expected_status}=success  ${timeout}=60s  ${vdu_connection}=None
    ${operation_result}=  vdu.Get Unblock Cell Operation Status  operation_id=${operation_id}  timeout=${timeout}  vdu_connection=${vdu_connection}
    ${status_check}=  Get From Dictionary  ${operation_result}  status
    Should Be True  '${status_check}' == '${expected_status}'

VDU Recover VDU blocked cells
    [Documentation]
    ...  Check VDU cells to be unblocked. If needed perform unblock VDU cells.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                             |
    ...  | VDU_cell_ids_list | Yes  | VDU cell ids list                                       |
    ...  | timeout           | No   | Timeout for the operation in seconds. Default value: 60 |
    ...  | vdu_connection    | No   | VDU connection instance alias. Default value: None      |
    ...
    [Arguments]  ${VDU_cell_ids_list}  ${timeout}=60  ${vdu_connection}=None

    FOR  ${item}  IN  @{VDU_cell_ids_list}

        ${status}=  Run Keyword And Return Status  VDU Check Cell Expected Status  cell_id=${item}  operational_state=${CBTS_Enabled_Disabled_}
        ...  blocking_state=${CBTS_Blocked_}  vdu_connection=${vdu_connection}

        Continue For Loop If  not ${status}

        Run Keyword If  ${status}  VDU Unblock Cell  cell_id=${item}  timeout=${timeout}  vdu_connection=${vdu_connection}

        Wait until keyword succeeds  ${timeout}s  3s  VDU Check Cell Expected Status  cell_id=${item}  operational_state=${CBTS_Enabled_}
        ...  blocking_state=${CBTS_Unblocked_}  vdu_connection=${vdu_connection}

        Log  Cell ${item} unblock recovery indicated  console=True

    END

VDU Reset VDU
    [Documentation]
    ...  Perform VDU reset VDU
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                           |
    ...  | expected_status | No   | Expected status for reset VDU. Default value: ongoing |
    ...  | timeout         | No   | Timeout for the operation. Default value: 60          |
    ...  | vdu_connection  | No   | VDU connection instance alias. Default value: None    |
    ...  | graceful_cell_shutdown  | No   | Graceful Cell Shutdown. Default value: False    |
    ...
    [Arguments]  ${expected_status}=ongoing  ${timeout}=60  ${vdu_connection}=None
    ...  ${graceful_cell_shutdown}=False

    ${vdu_reset_vdu_info}=  vdu.Reset Vdu  timeout=${timeout}  vdu_connection=${vdu_connection}
    ...  graceful_cell_shutdown=${graceful_cell_shutdown}

    ${vdu_reset_vdu_id}=  Get From Dictionary  ${vdu_reset_vdu_info}  id

    Wait Until Keyword Succeeds  ${timeout}  1s  VDU Check Reset VDU Status  operation_id=${vdu_reset_vdu_id}  expected_status=${expected_status}
    ...  timeout=${timeout}  vdu_connection=${vdu_connection}

VDU Check Reset VDU Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s  ${vdu_connection}=None
    ${operation_result}=  vdu.Get Reset Vdu Operation Status  operation_id=${operation_id}  timeout=${timeout}  vdu_connection=${vdu_connection}
    ${status_check}=  Get From Dictionary  ${operation_result}  status
    Should Be True  '${status_check}' == '${expected_status}'

VDU Get RMOD sn id pn interface info
    [Documentation]
    ...  Get VDU radio modules serial number, id, product name and interface protocol info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                        |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter                  | Description                                                            |
    ...  | VDU_RMOD_sn_id_dict        | Dict containing structure: {'RMOD_serial_number': 'RMOD_id'}           |
    ...  | VDU_RMOD_id_sn_dict        | Dict containing structure: {'RMOD_id': 'RMOD_serial_number'}           |
    ...  | VDU_RMOD_sn_pn_dict        | Dict containing structure: {'RMOD_serial_number': 'RMOD_product_name'} |
    ...  | VDU_RMOD_sn_interface_dict | Dict containing structure: {'RMOD_serial_number': 'RMOD_interface'}    |
    ...
    [Arguments]  ${vdu_connection}=None

    ${VDU_RMOD_sn_id_dict}=  Create Dictionary
    ${VDU_RMOD_id_sn_dict}=  Create Dictionary
    ${VDU_RMOD_sn_pn_dict}=  Create Dictionary
    ${VDU_RMOD_sn_interface_dict}=  Create Dictionary

    ${VDU_RMOD_info}=  vdu.Get Rmods Status  vdu_connection=${vdu_connection}

    FOR  ${rmod_info}  IN  @{VDU_RMOD_info}

        ${VDU_RMOD_sn}=  Get From Dictionary  ${rmod_info}  serial_number
        ${VDU_RMOD_id}=  Get From Dictionary  ${rmod_info}  id
        ${VDU_RMOD_pn}=  Get From Dictionary  ${rmod_info}  product_name
        ${VDU_RMOD_interface}=  Get From Dictionary  ${rmod_info}  interface_type

        Set To Dictionary  ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_sn}  ${VDU_RMOD_id}
        Set To Dictionary  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_id}  ${VDU_RMOD_sn}
        Set To Dictionary  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn}  ${VDU_RMOD_pn}
        Set To Dictionary  ${VDU_RMOD_sn_interface_dict}  ${VDU_RMOD_sn}  ${VDU_RMOD_interface}

    END

    [Return]  ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}

VDU Get RMOD sn config runtime info
    [Documentation]
    ...  Get VDU radio modules serial number, config and runtime info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                        |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter                | Description                                                          |
    ...  | VDU_RMOD_sn_config_dict  | Dict containing structure: {'RMOD_serial_number': 'RMOD_config_dn'}  |
    ...  | VDU_RMOD_config_sn_dict  | Dict containing structure: {'RMOD_config_dn': 'RMOD_serial_number'}  |
    ...  | VDU_RMOD_sn_runtime_dict | Dict containing structure: {'RMOD_serial_number': 'RMOD_runtime_dn'} |
    ...  | VDU_RMOD_runtime_sn_dict | Dict containing structure: {'RMOD_runtime_dn': 'RMOD_serial_number'} |
    ...
    [Arguments]  ${vdu_connection}=None

    ${VDU_RMOD_sn_config_dict}=  Create Dictionary
    ${VDU_RMOD_config_sn_dict}=  Create Dictionary
    ${VDU_RMOD_sn_runtime_dict}=  Create Dictionary
    ${VDU_RMOD_runtime_sn_dict}=  Create Dictionary

    ${VDU_RMOD_info}=  vdu.Get Rmods Status  vdu_connection=${vdu_connection}

    FOR  ${rmod_info}  IN  @{VDU_RMOD_info}

        ${VDU_RMOD_sn}=  Get From Dictionary  ${rmod_info}  serial_number
        ${rmod_info_dist_names}=  Get From Dictionary  ${rmod_info}  dist_names
        ${VDU_RMOD_config_dn}=  Get From Dictionary  ${rmod_info_dist_names}  config
        ${VDU_RMOD_runtime_dn}=  Get From Dictionary  ${rmod_info_dist_names}  runtime

        Set To Dictionary  ${VDU_RMOD_sn_config_dict}  ${VDU_RMOD_sn}  ${VDU_RMOD_config_dn}
        Set To Dictionary  ${VDU_RMOD_config_sn_dict}  ${VDU_RMOD_config_dn}  ${VDU_RMOD_sn}
        Set To Dictionary  ${VDU_RMOD_sn_runtime_dict}  ${VDU_RMOD_sn}  ${VDU_RMOD_runtime_dn}
        Set To Dictionary  ${VDU_RMOD_runtime_sn_dict}  ${VDU_RMOD_runtime_dn}  ${VDU_RMOD_sn}

    END

    [Return]  ${VDU_RMOD_sn_config_dict}  ${VDU_RMOD_config_sn_dict}  ${VDU_RMOD_sn_runtime_dict}  ${VDU_RMOD_runtime_sn_dict}

VDU Reset RMOD
    [Documentation]
    ...  Perform VDU reset RMOD
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                            |
    ...  | rmods_list      | Yes  | VDU RMOD ids list                                      |
    ...  | expected_status | No   | Expected status for reset RMOD. Default value: ongoing |
    ...  | timeout         | No   | Timeout for the operation. Default value: 60           |
    ...  | vdu_connection  | No   | VDU connection instance alias. Default value: None     |
    ...  | graceful_cell_shutdown  | No   | Graceful Cell Shutdown. Default value: False    |
    ...
    [Arguments]  ${rmods_list}  ${expected_status}=ongoing  ${timeout}=60  ${vdu_connection}=None
    ...  ${graceful_cell_shutdown}=False

    ${vdu_reset_rmod_info}=  vdu.Reset Rmods  rmods_list=${rmods_list}  timeout=${timeout}  vdu_connection=${vdu_connection}
    ...  graceful_cell_shutdown=${graceful_cell_shutdown}

    ${vdu_reset_rmod_id}=  Get From Dictionary  ${vdu_reset_rmod_info}  operation_id

    Wait Until Keyword Succeeds  ${timeout}  1s  VDU Check Reset RMOD Status  operation_id=${vdu_reset_rmod_id}  expected_status=${expected_status}
    ...  timeout=${timeout}  vdu_connection=${vdu_connection}

VDU Check Reset RMOD Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s  ${vdu_connection}=None
    ${operation_result}=  vdu.Get Reset Rmods Operation Status  operation_id=${operation_id}  timeout=${timeout}  vdu_connection=${vdu_connection}
    ${status_check}=  Get From Dictionary  ${operation_result}  status
    Should Be True  '${status_check}' == '${expected_status}'

VDU Get Cells Mapped On RMOD
    [Documentation]
    ...  Get VDU cells mapped on RMOD
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description  |
    ...  | timeout         | No   | Timeout for the operation. Default value: 60       |
    ...  | vdu_connection  | No   | VDU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description                                                     |
    ...  | VDU_RMOD_id_CELL_ids_dict | Dict containing structure: {'RMOD_id': '<CELL_ids>'}            |
    ...
    [Arguments]  ${vdu_connection}=None  ${timeout}=60

    ${VDU_RMOD_id_NR_CELL_ids_dict}=  Create Dictionary
    ${VDU_RMOD_id_LTE_CELL_ids_dict}=  Create Dictionary
    ${VDU_RMOD_id_WCDMA_CELL_ids_dict}=  Create Dictionary
    ${VDU_RMOD_id_GSM_CELL_ids_dict}=  Create Dictionary
    ${VDU_RMOD_cell_empty_list}=  Create List


    ${VDU_RMOD_info}=  vdu.Get Rmods Status  vdu_connection=${vdu_connection}  timeout=${timeout}

    FOR  ${rmod_info}  IN  @{VDU_RMOD_info}

        ${VDU_RMOD_id}=  Get From Dictionary  ${rmod_info}  id
        ${VDU_RMOD_cell_ids}=  Get From Dictionary  ${rmod_info}  cell_ids

        Set To Dictionary  ${VDU_RMOD_id_NR_CELL_ids_dict}  ${VDU_RMOD_id}  ${VDU_RMOD_cell_ids}
        Set To Dictionary  ${VDU_RMOD_id_LTE_CELL_ids_dict}  ${VDU_RMOD_id}  ${VDU_RMOD_cell_empty_list}
        Set To Dictionary  ${VDU_RMOD_id_WCDMA_CELL_ids_dict}  ${VDU_RMOD_id}  ${VDU_RMOD_cell_empty_list}
        Set To Dictionary  ${VDU_RMOD_id_GSM_CELL_ids_dict}  ${VDU_RMOD_id}  ${VDU_RMOD_cell_empty_list}

    END

    [Return]  ${VDU_RMOD_id_NR_CELL_ids_dict}  ${VDU_RMOD_id_LTE_CELL_ids_dict}  ${VDU_RMOD_id_WCDMA_CELL_ids_dict}  ${VDU_RMOD_id_GSM_CELL_ids_dict}

VDU Lock RMOD
    [Documentation]
    ...  Perform VDU lock RMOD
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                           |
    ...  | rmod_id_list    | Yes  | VDU RMOD ids list                                     |
    ...  | expected_status | No   | Expected status for lock RMOD. Default value: ongoing |
    ...  | timeout         | No   | Timeout for the operation. Default value: 60          |
    ...  | vdu_connection  | No   | VDU connection instance alias. Default value: None    |
    ...
    [Arguments]  ${rmod_id_list}  ${expected_status}=ongoing  ${timeout}=60  ${vdu_connection}=None

    ${vdu_lock_rmod_info}=  vdu.Lock Rmods  rmod_id_list=${rmod_id_list}  timeout=${timeout}  vdu_connection=${vdu_connection}

    ${vdu_lock_rmod_id}=  Get From Dictionary  ${vdu_lock_rmod_info}  id

    Wait Until Keyword Succeeds  ${timeout}  1s  VDU Check Lock RMOD Status  operation_id=${vdu_lock_rmod_id}  expected_status=${expected_status}
    ...  timeout=${timeout}  vdu_connection=${vdu_connection}

VDU Check Lock RMOD Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s  ${vdu_connection}=None
    ${operation_result}=  vdu.Get Operation State Of Locking Rmods  operation_id=${operation_id}  timeout=${timeout}  vdu_connection=${vdu_connection}
    ${status_check}=  Get From Dictionary  ${operation_result}  status
    Should Be True  '${status_check}' == '${expected_status}'

VDU Unlock RMOD
    [Documentation]
    ...  Perform VDU unlock RMOD
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                                             |
    ...  | rmod_id_list    | Yes  | VDU RMOD ids list                                       |
    ...  | expected_status | No   | Expected status for unlock RMOD. Default value: ongoing |
    ...  | timeout         | No   | Timeout for the operation. Default value: 60            |
    ...  | vdu_connection  | No   | VDU connection instance alias. Default value: None      |
    ...
    [Arguments]  ${rmod_id_list}  ${expected_status}=ongoing  ${timeout}=60  ${vdu_connection}=None

    ${vdu_unlock_rmod_info}=  vdu.Unlock Rmods  rmod_id_list=${rmod_id_list}  timeout=${timeout}  vdu_connection=${vdu_connection}

    ${vdu_unlock_rmod_id}=  Get From Dictionary  ${vdu_unlock_rmod_info}  id

    Wait Until Keyword Succeeds  ${timeout}  1s  VDU Check Unlock RMOD Status  operation_id=${vdu_unlock_rmod_id}  expected_status=${expected_status}
    ...  timeout=${timeout}  vdu_connection=${vdu_connection}

VDU Check Unlock RMOD Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s  ${vdu_connection}=None
    ${operation_result}=  vdu.Get Operation Of Unlocking Rmods  operation_id=${operation_id}  timeout=${timeout}
    ...  vdu_connection=${vdu_connection}
    ${status_check}=  Get From Dictionary  ${operation_result}  status
    Should Be True  '${status_check}' == '${expected_status}'

VDU Recover VDU locked RMODs
    [Documentation]
    ...  Check VDU radio modules to be unlocked. If needed perform unlock VDU radio modules.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                             |
    ...  | VDU_rmod_ids_list | Yes  | VDU rmod ids list                                       |
    ...  | timeout           | No   | Timeout for the operation in seconds. Default value: 60 |
    ...  | vdu_connection    | No   | VDU connection instance alias. Default value: None      |
    ...
    [Arguments]  ${VDU_rmod_ids_list}  ${timeout}=60  ${vdu_connection}=None

    FOR  ${item}  IN  @{VDU_rmod_ids_list}

        ${status}=  Run Keyword And Return Status  VDU Check RMOD Expected Status  rmod_id=${item}  operational_state=${CBTS_Enabled_Disabled_}
        ...  administrative_state=${CBTS_Locked_}  vdu_connection=${vdu_connection}

        Continue For Loop If  not ${status}

        ${rmod_id_list}=  Create List  ${item}
        Run Keyword If  ${status}  VDU Unlock RMOD  rmod_id_list=${rmod_id_list}  timeout=${timeout}  vdu_connection=${vdu_connection}

        Wait until keyword succeeds  ${timeout}s  3s  VDU Check RMOD Expected Status  rmod_id=${item}  operational_state=${CBTS_Enabled_}
        ...  administrative_state=${CBTS_Unlocked_}  vdu_connection=${vdu_connection}

        Log  RMOD ${item} unlock recovery indicated  console=True

    END

Check cloud BTS VDU all RMODs expected states
    [Arguments]  ${operational_state}  ${availability_status}  ${administrative_state}  ${vdu_alias}
    ${VDU_RMOD_check_status}=  VDU Check RMODs Expected Status  operational_state=${operational_state}  availability_status=${availability_status}
    ...  administrative_state=${administrative_state}  vdu_connection=${vdu_alias}
    Should Be True  ${VDU_RMOD_check_status}

Check cloud BTS VDU all cells expected states
    [Arguments]  ${operational_state}  ${availability_status}  ${administrative_state}  ${vdu_alias}
    ${VDU_CELL_check_status}=  VDU Check Cells Expected Status  operational_state=${operational_state}  availability_status=${availability_status}
    ...  administrative_state=${administrative_state}  vdu_connection=${vdu_alias}
    Should Be True  ${VDU_CELL_check_status}

VDU Perform Delta Recommissioning
    [Arguments]  ${delta_file}  ${wait_for_completion}=True  ${should_activate}=True  ${timeout}=300  ${vdu_connection}=None

    ${wait_for_completion}=  Convert To Boolean  ${wait_for_completion}
    ${should_activate}=  Convert To Boolean  ${should_activate}
    ${timeout}=  Convert To Number  ${timeout}

    ${vdu_perform_delta_recommissioning_info}=  vdu.Perform Delta Recommissioning  delta_file=${delta_file}
    ...  wait_for_completion=${wait_for_completion}  should_activate=${should_activate}  timeout=${timeout}  vdu_connection=${vdu_connection}

    ${vdu_perform_delta_recommissioning_id}=  Get From Dictionary  ${vdu_perform_delta_recommissioning_info}  id
    Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check Perform Delta Recommissioning Status  operation_id=${vdu_perform_delta_recommissioning_id}
    ...  expected_status=success  vdu_connection=${vdu_connection}

VDU Check Perform Delta Recommissioning Status
    [Arguments]  ${operation_id}  ${expected_status}  ${vdu_connection}=None  ${timeout}=30

    ${timeout}=  Convert To Number  ${timeout}

    ${operation_result}=  vdu.Get Status Of Perform Delta Recommissioning  operation_id=${operation_id}   vdu_connection=${vdu_connection}
    ...  timeout=${timeout}
    ${status_check}=  Get From Dictionary  ${operation_result}  status
    Should Be True  '${status_check}' == '${expected_status}'

VDU Get VNF And RMOD Checkpoints
    [Documentation]
    ...  List of VNF checkpoint IDs to be executed. Those IDs can will used in start_customized_diagnostic_check keyword.
    ...
    ...  *INPUT*
    ...  | Parameter         | Man. | Description                                             |
    ...  | vdu_connection    | No   | VDU connection instance alias. Default value: None      |
    ...  | timeout           | No   | Timeout for the operation in seconds. Default value: 30 |
    ...
    ...  *RETURN*
    ...  | Parameter                        | Description                             |
    ...  | vnf_and_rmod_checkpoints_details | List with diagnostic check checkpoints  |

    [Arguments]  ${vdu_connection}=None  ${timeout}=30

    ${vnf_and_rmod_checkpoints_details}=  vdu.Get VNF And RMOD Checkpoints  vdu_connection=${vdu_connection}  timeout=${timeout}

    [Return]  ${vnf_and_rmod_checkpoints_details}

VDU Start Customized Diagnostic Check
    [Documentation]
    ...  Start customized diagnostic check.
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Description                                                                                                |
    ...  | vnf_checkpoint_ids  | Yes  | List of VNF checkpoint IDs to be executed. Can be taken from get_vnf_and_rmod_checkpoints keyword response |
    ...  | rmod_checkpoint_ids | Yes  | List of dicts of RMOD dist names and RMOD checkpoint IDs to be executed. Can be taken from                 |
    ...  |                              get_vnf_and_rmod_checkpoints keyword response                                                              |
    ...  | wait_for_completion | No   | If set to True, the keyword will wait for the operation to finish. Possible values: True or False.         |
    ...  | vdu_connection      | No   | VDU connection instance alias. Default value: None                                                         |
    ...  | timeout             | No   | Timeout for the operation in seconds. Default value: 300                                                   |
    ...
    ...  *RETURN*
    ...  | Parameter                          | Description                                         |
    ...  | customized_diagnostic_check_status | Dict with operation_id and status of the operation  |

    [Arguments]  ${vnf_checkpoint_ids}  ${rmod_checkpoint_ids}  ${wait_for_completion}=True  ${timeout}=300  ${vdu_connection}=None

    ${customized_diagnostic_check_status}=  vdu.Start Customized Diagnostic Check  vnf_checkpoint_ids=${vnf_checkpoint_ids}
    ...  rmod_checkpoint_ids=${rmod_checkpoint_ids}  wait_for_completion=${wait_for_completion}  timeout=${timeout}  vdu_connection=${vdu_connection}
    ${status_check}=  Get From Dictionary  ${customized_diagnostic_check_status}  status
    Run Keyword If  '${status_check}' != 'succeeded'  Run Keywords
    ...  Log  Start Customized Diagnostic Check could not be performed!  level=ERROR
    ...  AND  Fail  Start Customized Diagnostic Check could not be performed!

    [Return]  ${customized_diagnostic_check_status}

VDU Get Diagnostic Check Reports
    [Documentation]
    ...  Start customized diagnostic check.
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Description                                              |
    ...  | vdu_connection      | No   | VDU connection instance alias. Default value: None       |
    ...  | timeout             | No   | Timeout for the operation in seconds. Default value: 30  |
    ...
    ...  *RETURN*
    ...  | Parameter                | Description                      |
    ...  | diagnostic_check_reports | List of diagnostic check reports |

    [Arguments]  ${vdu_connection}=None  ${timeout}=30

    ${diagnostic_check_reports}=  vdu.Get Diagnostic Check Reports  vdu_connection=${vdu_connection}  timeout=${timeout}

    [Return]  ${diagnostic_check_reports}

VDU Perform Parameter Recommissioning
    [Arguments]  ${dist_name}  ${parameter}  ${operation}  ${value}  ${should_activate}=True  ${timeout}=300  ${vdu_connection}=None

    ${should_activate}=  Convert To Boolean  ${should_activate}
    ${timeout}=  Convert To Number  ${timeout}

    ${vdu_perform_parameter_recommissioning_info}=  vdu.Perform Parameter Recommissioning  dist_name=${dist_name}  parameter=${parameter}
    ...  operation=${operation}  value=${value}  should_activate=${should_activate}  timeout=${timeout}  vdu_connection=${vdu_connection}

    ${vdu_perform_parameter_recommissioning_status}=  Get From Dictionary  ${vdu_perform_parameter_recommissioning_info}  status
    Should Be True  '${vdu_perform_parameter_recommissioning_status}' == 'success'

VDU Get VDU RMOD Uptime info
    [Arguments]  ${RMOD_sn_id_dict}  ${vdu_alias}
    ${RMOD_sn_Uptime_dict}=  Create Dictionary
    ${RMOD_sn_list}=  Get Dictionary Keys  ${RMOD_sn_id_dict}
    FOR  ${RMOD_sn}  IN  @{RMOD_sn_list}
        ${RMOD_id}=  Get From Dictionary  ${RMOD_sn_id_dict}  ${RMOD_sn}
        ${RMOD_info}=  vdu.Get Rmod Measurements By Id  rmod_id=${RMOD_id}  vdu_connection=${vdu_alias}
        ${Uptime_info}=  Set Variable  ${RMOD_info['upTime']['seconds']}
        Set To Dictionary  ${RMOD_sn_Uptime_dict}  ${RMOD_sn}  ${Uptime_info}
    END
    [Return]  ${RMOD_sn_Uptime_dict}

VDU Get MHA Information
    [Documentation]
    ...  Get MHAs ALD info
    ...
    ...  | Parameter            | Man. | Description                                             |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None      |
    ...  | timeout              | No   | Timeout for the operation in seconds. Default value: 30 |
    ...
    ...  *RETURN*
    ...  | Parameter    | Description                       |
    ...  | mha_ald_info | List of MHA ALD state information |
    ...
    [Arguments]  ${vdu_connection}=None  ${timeout}=30

    ${mha_ald_info}=  vdu.Get MHAs Information  vdu_connection=${vdu_connection}  timeout=${timeout}

     [Return]  ${mha_ald_info}

VDU Get RET Information
    [Documentation]
    ...  Get RET ALD info
    ...
    ...  | Parameter            | Man. | Description                                             |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None      |
    ...  | timeout              | No   | Timeout for the operation in seconds. Default value: 30 |
    ...
    ...  *RETURN*
    ...  | Parameter    | Description                       |
    ...  | ret_ald_info | List of RET ALD state information |
    ...
    [Arguments]  ${vdu_connection}=None  ${timeout}=30

    ${ret_ald_info}=  vdu.Get RETs Information  vdu_connection=${vdu_connection}  timeout=${timeout}

     [Return]  ${ret_ald_info}

VDU Perform Commissioning
    [Arguments]  ${scf_file}  ${vdu_connection}=None  ${timeout}=300  ${wait_for_completion}=${True}  ${should_activate}=${True}

    ${vdu_perform_commissioning_info}=  vdu.Perform Commissioning  scf_file=${scf_file}  vdu_connection=${vdu_connection}  timeout=${timeout}
    ...  wait_for_completion=${wait_for_completion}  should_activate=${should_activate}

    ${vdu_perform_commissioning_id}=  Get From Dictionary  ${vdu_perform_commissioning_info}  id
    Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check Perform Commissioning Status  operation_id=${vdu_perform_commissioning_id}
    ...  expected_status=success  vdu_connection=${vdu_connection}  should_activate=${should_activate}

VDU Check Perform Commissioning Status
    [Arguments]  ${operation_id}  ${expected_status}  ${vdu_connection}=None  ${timeout}=30  ${should_activate}=${True}

    ${timeout}=  Convert To Number  ${timeout}

    ${operation_result}=  vdu.Get Status Of Perform Commissioning  operation_id=${operation_id}   vdu_connection=${vdu_connection}
    ...  timeout=${timeout}  should_activate=${should_activate}
    ${status_check}=  Get From Dictionary  ${operation_result}  status
    Should Be True  '${status_check}' == '${expected_status}'

VDU Check MHAs Expected Status
    [Documentation]
    ...  Check all VDU MHA modules current status to be aligned with expected status
    ...
    ...  | Parameter            | Man. | Description                                        |
    ...  | operational_state    | Yes  | Expected VDU MHA operational state.                |
    ...  | availability_status  | Yes  | Expected VDU MHA availability status.              |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None |
    ...
    [Arguments]  ${operational_state}  ${availability_status}  ${vdu_connection}=None

    ${VDU_MHA_info}=  VDU Get MHA Information  vdu_connection=${vdu_connection}

    FOR  ${mha_info}  IN  @{VDU_MHA_info}

        ${VDU_ALD_dict}=  Get From Dictionary  ${mha_info}  ald

        ${VDU_MHA_operational_state}=  Get From Dictionary  ${VDU_ALD_dict}  operational_state
        ${VDU_MHA_availability_status}=  Get From Dictionary  ${VDU_ALD_dict}  availability_status

        ${cond_operational_state}=  Evaluate  '${VDU_MHA_operational_state}' in '${operational_state}'
        ${cond_availability_status}=  Evaluate  '${VDU_MHA_availability_status}' in '${availability_status}'

        ${VDU_MHA_check_status}=  Evaluate  ${cond_operational_state} and ${cond_availability_status}

        Should Be True  ${VDU_MHA_check_status}

    END

VDU Check RETs Expected Status
    [Documentation]
    ...  Check all VDU RET modules current status to be aligned with expected status
    ...
    ...  | Parameter            | Man. | Description                                        |
    ...  | operational_state    | Yes  | Expected VDU RET operational state.                |
    ...  | availability_status  | Yes  | Expected VDU RET availability status.              |
    ...  | vdu_connection       | No   | VDU connection instance alias. Default value: None |
    ...
    [Arguments]  ${operational_state}  ${availability_status}  ${vdu_connection}=None

    ${VDU_RET_info}=  VDU Get RET Information  vdu_connection=${vdu_connection}

    FOR  ${ret_info}  IN  @{VDU_RET_info}

        ${VDU_ALD_dict}=  Get From Dictionary  ${ret_info}  ald

        ${VDU_RET_operational_state}=  Get From Dictionary  ${VDU_ALD_dict}  operational_state
        ${VDU_RET_availability_status}=  Get From Dictionary  ${VDU_ALD_dict}  availability_status

        ${cond_operational_state}=  Evaluate  '${VDU_RET_operational_state}' in '${operational_state}'
        ${cond_availability_status}=  Evaluate  '${VDU_RET_availability_status}' in '${availability_status}'

        ${VDU_RET_check_status}=  Evaluate  ${cond_operational_state} and ${cond_availability_status}

        Should Be True  ${VDU_RET_check_status}

    END
