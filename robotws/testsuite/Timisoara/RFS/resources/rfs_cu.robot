*** Settings ***
Documentation    Keywords using taf cu library
...              Resource used by RF Sharing Vrf tribe
...              Author: Dinu Olariu
...              Contact: dinu.olariu@nokia.com

Library    Collections
Library    OperatingSystem
Library    python_resources/alarms_analysis.py
Library    String
Library    taf.gnb.oam.coam.cu  WITH NAME  cu

*** Keywords ***

CU Get SW Version
    [Documentation]
    ...  Get active software version on CBTS CU.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter  | Man. | Description                                       |
    ...  | connection | No   | CU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter           | Description                |
    ...  | CU_software_version | CU active software version |
    ...
    [Arguments]  ${connection}=None

    ${CU_software_version}=  cu.Get Active Software Version  connection=${connection}

    [Return]  ${CU_software_version}

CU Get Name
    [Documentation]
    ...  Get CBTS CU name.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter  | Man. | Description                                       |
    ...  | connection | No   | CU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter | Description |
    ...  | CU_name   | CU name     |
    ...
    [Arguments]  ${connection}=None

    ${CU_state_info}=  cu.Get Cu State  connection=${connection}
    ${CU_name}=  Get From Dictionary  ${CU_state_info}  bts_name

    [Return]  ${CU_name}

CU Get Current Plan File
    [Documentation]
    ...  Get CBTS CU SCF.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                              |
    ...  | path                 | No   | Path to directory to stored SCF                          |
    ...  | filename             | No   | Filename stored SCF                                      |
    ...  | include_runtime_data | No   | Include runtime data or not. Default value: False        |
    ...  | timeout              | No   | Timeout for the operation in seconds. Default value: 120 |
    ...  | connection           | No   | CU connection instance alias. Default value: None        |
    ...
    ...  *RETURN*
    ...  | Parameter             | Description                                |
    ...  | CU_SCF_path_file_info | CBTS CU SCF full path where file is stored |
    ...
    [Arguments]  ${path}=${EMPTY}  ${filename}=${EMPTY}  ${timeout}=120  ${include_runtime_data}=False  ${connection}=None

    ${include_runtime_data}=  Convert To Boolean  ${include_runtime_data}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${path}=  Set Variable If  '${path}' == '${EMPTY}'  /tmp  ${path}
    ${filename}=  Set Variable If  '${filename}' == '${EMPTY}'  CU_SCF_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}.xml  ${filename}
    ${CU_SCF_path_file_info}=  Set Variable  ${path}/${filename}

    cu.Get Current Plan File  path=${CU_SCF_path_file_info}  include_runtime_data=${include_runtime_data}  timeout=${timeout}
    ...  connection=${connection}

    ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${CU_SCF_path_file_info}
    Run Keyword If  not ${status}  Run Keywords
    ...  Log  ${connection} SCF file not available at ${CU_SCF_path_file_info}  level=ERROR
    ...  AND  Fail  ${connection} SCF file not available at ${CU_SCF_path_file_info}

    [Return]  ${CU_SCF_path_file_info}

CU Check Cells Expected Status
    [Documentation]
    ...  Check all CU cells current status to be aligned with expected status
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                       |
    ...  | operational_state    | No   | Expected CU cell operational state.               |
    ...  | administrative_state | No   | Expected CU cell administrative state.            |
    ...  | connection           | No   | CU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description                                                                                |
    ...  | CU_CELL_check_status | ${True} if CU all cells current status is aligned with expected status, otherwise ${False} |
    ...
    [Arguments]  ${operational_state}  ${administrative_state}  ${connection}=None

    ${CU_CELL_check_status}=  Set Variable  ${True}

    ${CU_cells_info}=  cu.Get Cells Statuses  connection=${connection}

    FOR  ${cell_info}  IN  @{CU_cells_info}

        ${CU_cell_operational_state}=  Get From Dictionary  ${cell_info}  operational_state
        ${CU_cell_administrative_state}=  Get From Dictionary  ${cell_info}  administrative_state

        ${cond_operational_state}=  Set Variable  '${CU_cell_operational_state}' not in '${operational_state}'
        ${cond_administrative_state}=  Set Variable  '${CU_cell_administrative_state}' not in '${administrative_state}'

        ${CU_CELL_check_status}=  Set Variable If  ${cond_operational_state} or ${cond_administrative_state}  ${False}  ${CU_CELL_check_status}

    END

    [Return]  ${CU_CELL_check_status}

CU Check Expected Operational State
    [Documentation]
    ...  Check CU current operational state to be aligned with expected operational state
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter         | Man. | Description                                       |
    ...  | operational_state | Yes  | Expected CU operational state.                    |
    ...  | connection        | No   | CU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter                  | Description                                                                                            |
    ...  | CU_check_operational_state | ${True} if CU current operational state is aligned with expected operational state, otherwise ${False} |
    ...

    [Arguments]  ${operational_state}  ${connection}=None

    ${CU_check_operational_state}=  Set Variable  ${True}

    ${CU_state_data}=  cu.Get Cu State  connection=${connection}

    ${CU_operational_state}=  Get From Dictionary  ${CU_state_data}  operational_state

    ${cond_operational_state}=  Set Variable  '${CU_operational_state}' not in '${operational_state}'

    ${CU_check_operational_state}=  Set Variable If  ${cond_operational_state}  ${False}  ${CU_check_operational_state}

    [Return]  ${CU_check_operational_state}

CU Get Cells List
    [Documentation]
    ...  Get CU cells config dist names list
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter  | Man. | Description                                       |
    ...  | connection | No   | CU connection instance alias. Default value: None |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description                     |
    ...  | CU_CELL_config_dn_list | CU cells config dist names list |
    ...
    [Arguments]  ${connection}=None

    ${CU_CELL_config_dn_list}=  Create List
    ${CU_CELL_info}=  cu.Get Cells Statuses  connection=${connection}

    FOR  ${cell_info}  IN  @{CU_CELL_info}

        ${cell_info_dist_names}=  Get From Dictionary  ${cell_info}  dist_names
        ${CU_CELL_config_dn}=  Get From Dictionary  ${cell_info_dist_names}  config

        Append To List  ${CU_CELL_config_dn_list}  ${CU_CELL_config_dn}

    END

    [Return]  ${CU_CELL_config_dn_list}
