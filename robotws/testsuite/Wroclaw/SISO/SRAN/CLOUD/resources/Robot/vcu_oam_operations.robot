*** Settings ***
Documentation  vCU OAM operations keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu

Resource    ./common_resources.robot

*** Keywords ***
# Login
vCU Rest Login
   [Arguments]  ${gnb_index}=0  ${default_cu_version}=${True}  ${timeout}=120  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword allows login to vCU by restful api.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | default_cu_version     |  No  | Specifies whether the default cu version should be used.                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for the operation to CU.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Ignore Error  vCU Rest Logout  vcu_connection=${vcu_connection}
    IF  not ${default_cu_version}
      ${status}  ${restapi_version}=  Run Keyword And Ignore Error
      ...  Get vCU Rest Api Version  gnb_index=${gnb_index}  alias=default
      ${restapi_version}=  Set Variable If  '${status}'=='FAIL'
      ...  ${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}  ${restapi_version}
      ${index}=  Get Index From List  ${VCU_REST_TAF_LIB_SUPPORTED_VERSION}  ${restapi_version}
    END
    ${oam_http_connection}=  Get vCU Oam Http Connection Parameters From Init File
    ...  gnb_index=${gnb_index}
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
    ${port}=  Set Variable  ${oam_http_connection["port"]}
    ${username}=  Set Variable  ${oam_http_connection["username"]}
    ${password}=  Set Variable  ${VDU_OAM_PASSWORD}
    ${secure}=  Set Variable  ${True}
    IF  ${default_cu_version}
      cu.Connect To  host=${ip_addr}  port=${port}  username=${username}  password=${password}
      ...  secure=${secure}  alias=${vcu_connection}  timeout=${timeout}
    ELSE
      cu.Connect To  host=${ip_addr}  port=${port}  username=${username}  password=${password}
      ...  cu_version=${restapi_version}  secure=${secure}  alias=${vcu_connection}  timeout=${timeout}
    END
    [Return]  ${vcu_connection}

vCU Rest Logout
    [Arguments]  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword allows to logout of vCU.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | connection             |  No  | Unique identifier of vCU connection.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    cu.Disconnect  connection=${vcu_connection}

Get vCU Rest Api Version
    [Arguments]  ${gnb_index}=0  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vCU rest api version from global variables file (variables.robot).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of vCU connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  vDU Rest Api version for example cuoam_23r3
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${build_version}=  Get vCU Build Number  gnb_index=${gnb_index}  alias=${alias}
    ${build_number_list}=  Split String  string=${build_version}  separator=.
    ${build_number}=  Set Variable  ${build_number_list[0]}.${build_number_list[1]}
    ${restapi_version}=  Set Variable  ${VCU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING['${build_number}']}
    [Return]  ${restapi_version}

vCU Activate CLI Parameter Should Be Enabled
    [Arguments]  ${gnb_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword gets online Activate CLI parameter (actCli) from the current plan.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              | Yes  | Index of gnb object list                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    vCU Rest Login  gnb_index=${gnb_index}
    ${parameter_info}=  cu.Search Parameters Of Current Plan  parameter_name=actCli
    ${actcli_value}=  Set Variable  ${parameter_info['items'][0]['parameter']['simple_parameter']['value']}
    Run Keyword If  '${actcli_value}'=='False'
    ...  Log  Please set actCli parameter
    [Return]  ${actcli_value}
    [Teardown]   vCU Rest Logout

vCU All Cells Should Be OnAir
    [Arguments]  ${cells_count}  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if all vCU cells are onAir.
    ...  Keyword checks the following status:   operational_state = enabled
    ...                                         administrative_state = unlocked
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_count            | Yes  | Number of all cells.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vcu_cells_summary}=  cu.Get Cells Summary
    ...  connection=${vcu_connection}
    Should Be Equal As Numbers
    ...  first=${vcu_cells_summary['basic_cells_summary']['operational_state']['enabled']}  second=${cells_count}
    Should Be Equal As Numbers
    ...  first=${vcu_cells_summary['basic_cells_summary']['administrative_state']['unlocked']}  second=${cells_count}

vCU Wait Until All Cells Are OnAir
    [Arguments]  ${cells_count}  ${timeout}=300s  ${time_interval}=10s  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits until all vCU cells are onAir.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_count            | Yes  | Number of all cells.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Wait until all cells are onAir.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vCU All Cells Should Be Onair
    ...  cells_count=${cells_count}
    ...  vcu_connection=${vcu_connection}

vCU Get Operational State
    [Arguments]  ${vcu_connection}=default  ${log_to_console}=False
    [Documentation]
    ...  Description:
    ...  Keyword returns vCU operational state value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  vCU operational state value.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vcu_states}=  cu.Get Cu State
    ...  connection=${vcu_connection}
    ${vcu_state_value}=  Set Variable  ${vcu_states['operational_state']}
    Log  \nvCU operational state is ${vcu_state_value} now.\n  console=${log_to_console}
    [Return]  ${vcu_state_value}

vCU Check Operational State
    [Arguments]  ${vcu_state_value}  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the operational state of the vCU has the expected value (${vcu_state_value}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_state_value        | Yes  | Value of vCU expected state.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${current_vcu_state_value}=  vCU Get Operational State
    ...  vcu_connection=${vcu_connection}
    Should Be True  '${current_vcu_state_value}'=='${vcu_state_value}'

vCU Wait For Expected Operational State
    [Arguments]  ${vcu_state_value}  ${timeout}=120s  ${time_interval}=10s  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for vCU operation state value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_state_value        | Yes  | Value of vCU expected state.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected state.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vCU Check Operational State
    ...  vcu_state_value=${vcu_state_value}
    ...  vcu_connection=${vcu_connection}

vCU Get Ng Links Status
    [Arguments]  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns NG links status list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vcu_ng_links_status}=  Create list
    ${vcu_state}=  cu.Get Cu State
    ...  connection=${vcu_connection}
    ${ng_links_params}=  Set Variable  ${vcu_state['amfs']}
    FOR  ${ng_link_param}  IN  @{ng_links_params}
      Append To List  ${vcu_ng_links_status}  ${ng_link_param['ng_link_status']}
    END
    [Return]  ${vcu_ng_links_status}

vCU Check Ng Links Status
    [Arguments]  ${vcu_ng_link_status}  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether all NG links status have the expected values (${vcu_ng_link_status}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_ng_link_status     | Yes  | Value of NG links expected status.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vcu_ng_links_status}=  vCU Get Ng Links Status
    ...  vcu_connection=${vcu_connection}
    FOR  ${vcu_current_ng_link_status}  IN  @{vcu_ng_links_status}
      Should Be True  '${vcu_current_ng_link_status}'=='${vcu_ng_link_status}'
    END

vCU Wait For Expected Ng Links Status
    [Arguments]  ${vcu_ng_link_status}  ${timeout}=600s  ${time_interval}=10s  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for all NG links status values.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_ng_link_status     | Yes  | Value of NG links expected status.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vCU Check Ng Links Status
    ...  vcu_ng_link_status=${vcu_ng_link_status}
    ...  vcu_connection=${vcu_connection}

vCU Get Number Of F1 Links Status
    [Arguments]  ${vcu_f1_link_status}  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns the number of F1 links with the given status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_f1_link_status     | Yes  | Value of F1 links expected status.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vcu_state}=  cu.Get Du State
    ...  connection=${vcu_connection}
    ${f1_available_links_numbers}=  Set Variable  ${vcu_state['f1_link_status']['${vcu_f1_link_status}']}
    [Return]  ${f1_available_links_numbers}

vCU Check F1 Links Status
    [Arguments]  ${vcu_f1_link_status}  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether all F1 links status have the expected value (${vcu_f1_link_status}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_f1_link_status     | Yes  | Value of F1 links expected status.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${f1_available_links_numbers}=  vCU Get Number Of F1 Links Status
    ...  vcu_f1_link_status=${vcu_f1_link_status}
    ...  vcu_connection=${vcu_connection}
    ${vdu_numbers}=  Get vDU Number From Init File
    Should Be True  '${f1_available_links_numbers}'=='${vdu_numbers}'

vCU Wait For Expected F1 Links Status
    [Arguments]  ${vcu_f1_link_status}  ${timeout}=600s  ${time_interval}=10s  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for F1 links status values.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_f1_link_status     | Yes  | Value of F1 links expected status.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vCU Check F1 Links Status
    ...  vcu_f1_link_status=${vcu_f1_link_status}
    ...  vcu_connection=${vcu_connection}

vCU Get Number Of vDUs Administrative States
    [Arguments]  ${vdu_state_value}  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns the number of vDUs with the given administrative state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_state_value        | Yes  | Value of vDUs expected state.                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vcu_state}=  cu.Get Du State
    ...  connection=${vcu_connection}
    ${vdu_administrative_states_numbers}=  Set Variable  ${vcu_state['administrative_state']['${vdu_state_value}']}
    [Return]  ${vdu_administrative_states_numbers}

vCU Check vDUs Administrative States
    [Arguments]  ${vdu_state_value}  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether all vDUs administrative states have the expected value (${vdu_state_value}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_state_value        | Yes  | Value of vDUs expected state.                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_administrative_states_numbers}=  vCU Get Number Of vDUs Administrative States
    ...  vdu_state_value=${vdu_state_value}
    ...  vcu_connection=${vcu_connection}
    ${vdu_numbers}=  Get vDU Number From Init File
    Should Be True  '${vdu_administrative_states_numbers}'=='${vdu_numbers}'

vCU Wait For Expected vDUs Administrative States
    [Arguments]  ${vdu_state_value}  ${timeout}=120s  ${time_interval}=10s  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for vDUs administrative states values.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_state_value        | Yes  | Value of vDUs expected state.                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vCU Check vDUs Administrative States
    ...  vdu_state_value=${vdu_state_value}
    ...  vcu_connection=${vcu_connection}

vCU Get Vnfcs States
    [Arguments]  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns vCU VNFCs states dictionary.
    ...  Dictionary key is VNFC name.
    ...  Dictionary value is VNFC state list ("availability_status", "operational_state").
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vcu_vnfcs_states}=  Create Dictionary
    ${vnfcs_states}=  cu.Get Vnfcs States
    ...  connection=${vcu_connection}
    FOR  ${vnfc_state}  IN  @{vnfcs_states}
      ${vnfc_state_list}=  Create List
      ...  ${vnfc_state['availability_status']}  ${vnfc_state['operational_state']}
      Set To Dictionary  ${vcu_vnfcs_states}  ${vnfc_state['name']}=${vnfc_state_list}
    END
    [Return]  ${vcu_vnfcs_states}

vCU Check Vnfcs State
    [Arguments]  ${vcu_vnfcs_availability_status}  ${vcu_vnfcs_operational_state}  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether vCU VNFCs states have the expected values.
    ...  (${vcu_vnfcs_availability_status}, ${vcu_vnfcs_operational_state}).
    ...
    ...  Arguments:
    ...  +===============================+======+=====================================================================+
    ...  | Argument                      | Man. | Description                                                         |
    ...  +===============================+======+=====================================================================+
    ...  | vcu_vnfcs_availability_status | Yes  | Value of vCU VNFs expected availability status.                     |
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...  | vcu_vnfcs_operational_state   | Yes  | Value of vCU VNFs expected operational state.                       |
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...  | vcu_connection                |  No  | vCU connection object or string name alias if used.                 |
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vcu_vnfcs_states}=  vCU Get Vnfcs States
    ...  vcu_connection=${vcu_connection}
    ${vnfc_states}=  Get Dictionary Values  dictionary=${vcu_vnfcs_states}
    FOR  ${current_vnfc_states}  IN  @{vnfc_states}
      Should Be True  '${current_vnfc_states[0]}'=='${vcu_vnfcs_availability_status}'
      Should Be True  '${current_vnfc_states[1]}'=='${vcu_vnfcs_operational_state}'
    END

vCU Wait For Expected Vnfcs States
    [Arguments]  ${vcu_vnfcs_availability_status}  ${vcu_vnfcs_operational_state}  ${timeout}=120s
    ...  ${time_interval}=10s  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for vCU VNFCs states and statuses values.
    ...
    ...  Arguments:
    ...  +===============================+======+=====================================================================+
    ...  | Argument                      | Man. | Description                                                         |
    ...  +===============================+======+=====================================================================+
    ...  | vcu_vnfcs_availability_status | Yes  | Value of vCU VNFs expected availability status.                     |
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...  | vcu_vnfcs_operational_state   | Yes  | Value of vCU VNFs expected operational state.                       |
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...  | timeout                       |  No  | Waiting time for expected state and status.                         |
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...  | time_interval                 |  No  | Time interval for status query.                                     |
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...  | vcu_connection                |  No  | vCU connection object or string name alias if used.                 |
    ...  +-------------------------------+------+---------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vCU Check Vnfcs State
    ...  vcu_vnfcs_availability_status=${vcu_vnfcs_availability_status}
    ...  vcu_vnfcs_operational_state=${vcu_vnfcs_operational_state}
    ...  vcu_connection=${vcu_connection}

vCU Get Running Software Version
    [Arguments]  ${gnb_index}=0  ${vcu_login}=True  ${vcu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets running vCU build version.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vcU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vcu_login}
    ...  vCU Rest Login  gnb_index=${gnb_index}  vcu_connection=${vcu_connection}
    ${vcu_sw_version}=  cu.Get Active Software Version
    ...  connection=${vcu_connection}
    [Return]  ${vcu_sw_version}
    [Teardown]  Run Keyword If  ${vcu_login}
    ...  Run Keyword And Ignore Error  vCU Rest Logout  vcu_connection=${vcu_connection}
