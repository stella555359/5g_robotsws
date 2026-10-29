*** Settings ***
Documentation  vDU OAM operations keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    DateTime
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.config.scf                        WITH NAME    scf

Resource    ./common_resources.robot
Resource    ./setup_teardown.robot
Resource    ./ltevdu_oam_operations.robot
Resource    ../../../resources/Robot/common_kw.robot

*** Keywords ***
# Login
vDU Rest Login
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${default_vdu_version}=${True}  ${timeout}=30s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword provides connection and authorization to vDU.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | default_vdu_version    |  No  | Specifies whether the default SW version of vDU should be used.            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for the operation to vDU.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}
    IF  not ${default_vdu_version}
      ${status}  ${restapi_version}=  Run Keyword And Ignore Error
      ...  Get vDU Rest Api Version  gnb_index=${gnb_index}  vdu_index=${vdu_index}
      ${restapi_version}=  Set Variable If  '${status}'=='FAIL'
      ...  ${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}  ${restapi_version}
    END
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
    ${port}=  Set Variable  ${oam_http_connection["port"]}
    ${username}=  Set Variable  ${oam_http_connection["username"]}
    ${password}=  Set Variable  ${VDU_OAM_PASSWORD}
    ${secure}=  Set Variable  True
    IF  ${default_vdu_version}
      vdu.Connect To  host=${ip_addr}  port=${port}  username=${username}
      ...  password=${password}  secure=${secure}  connection_name=${vdu_connection}
      ...  need_all_info=${True}  timeout=${timeout}
    ELSE
      vdu.Connect To  host=${ip_addr}  port=${port}  username=${username}
      ...  password=${password}  vdu_version=${restapi_version}  secure=${secure}
      ...  connection_name=${vdu_connection}  need_all_info=${True}  timeout=${timeout}
    END
    [Return]  ${vdu_connection}

vDU Rest Logout
    [Arguments]  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword allows to logout of vDU.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    vdu.Disconnect  vdu_connection=${vdu_connection}

Get vDU Rest Api Version
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets vDU rest api version from global variables file (variables.robot).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of vDU connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  vDU Rest Api version for example cuoam_23r3.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${build_version}=  Get vDU Build Number  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${build_number_list}=  Split String  string=${build_version}  separator=.
    ${built_stream}=  Set Variable  ${build_number_list[0]}.${build_number_list[1]}
    ${restapi_version}=  Set Variable  ${VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING['${built_stream}']}
    [Return]  ${restapi_version}

Set vDU Rest Api Version
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]
    ...  Description:
    ...  Keyword sets vDU Rest Api version based on the software release obtained from the vDU parameters.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | alias                  |  No  | Alias of vDU connection.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  vDU Rest Api version for example: cuoam_24r1.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${build_version}=  Get vDU Build Number  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${software_release}  ${software_build_number}=  vDU Get Software Release And Version Number
    Should Be Equal As Strings  first=${build_version}  second=${software_build_number}
    ...  msg='Build numbers are different'
    ${restapi_version}=  Set Variable  cuoam_${software_release}
    [Return]  ${restapi_version}

#Radio modules operations
vDU Radio Modules Should Be Online
    [Arguments]  ${rmods_count}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if all radio modules are on line if 5G vDU is used.
    ...  Radio module expected states:  administrative_state = unlocked
    ...                                 operational_state = enabled
    ...                                 availability_status = on_line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmods_count            | Yes  | Number of all radio modules if 5G vDU is used.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_rmods_params}=  vdu.Get Rmods Summary  vdu_connection=${vdu_connection}
    Should Be Equal As Numbers
    ...  first=${all_rmods_params['operational_state']['enabled']}  second=${rmods_count}
    Should Be Equal As Numbers
    ...  first=${all_rmods_params['administrative_state']['unlocked']}  second=${rmods_count}
    Should Be Equal As Numbers
    ...  first=${all_rmods_params['availability_status']['on_line']}  second=${rmods_count}

vDU All Radio Modules Should Be Online
    [Arguments]  ${rmods_count}=0  ${lte_rmods_count}=0  ${vdu_connection}=default  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword checks if all radio modules are on line.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmods_count            | Yes  | Number of all radio modules if 5G vDU is used.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_rmods_count        | Yes  | Number of all radio modules if 4G vDU is used.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${rmods_count}>0
    ...  vDU Radio Modules Should Be Online  rmods_count=${rmods_count}  vdu_connection=${vdu_connection}
    Run Keyword If  ${lte_rmods_count}>0
    ...  LTEvDU Radio Modules Should Be Online  rmods_count=${lte_rmods_count}  lte_vdu_connection=${lte_vdu_connection}

Wait Until All Radio Modules Are Online
    [Arguments]  ${rmods_count}=0  ${lte_rmods_count}=0  ${timeout}=600s
    ...  ${vdu_connection}=default  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword waits until all radio modules are on line.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmods_count            | Yes  | Number of all radio modules if 5G vDU is used.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_rmods_count        | Yes  | Number of all radio modules if 4G vDU is used.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Wait until all radio modules are on line.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  5s
    ...  vDU All Radio Modules Should Be Online  rmods_count=${rmods_count}  lte_rmods_count=${lte_rmods_count}
    ...  vdu_connection=${vdu_connection}  lte_vdu_connection=${lte_vdu_connection}

RMOD Get Current State
    [Arguments]  ${rmod_sn}  ${rmod_state}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns the value of the given state (${rmod_state}) of the radio module.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_state             | Yes  | Radio module state to check.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Value of the given state of the radio module.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_rmods_params}=  vdu.Get Rmods Status  vdu_connection=${vdu_connection}
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_state_value}=  Set Variable  ${rmod_params['${rmod_state}']}
      ${rmod_sn_value}=  Set Variable  ${rmod_params['serial_number']}
      Exit For Loop If  '${rmod_sn_value}'=='${rmod_sn}'
    END
    [Return]  ${rmod_state_value}

RMOD Check Expected State
    [Arguments]  ${rmod_sn}  ${rmod_state}  ${rmod_state_value}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the state (${rmod_state}) of the radio module
    ...  has the expected value (${rmod_state_value}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_state             | Yes  | Radio module state to check.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_state_value       | Yes  | Value of expected state.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${current_rmod_state_value}=  RMOD Get Current State
    ...  rmod_sn=${rmod_sn}
    ...  rmod_state=${rmod_state}
    ...  vdu_connection=${vdu_connection}
    Should Be True  '${current_rmod_state_value}'=='${rmod_state_value}'

RMOD Wait For Expected State
    [Arguments]  ${rmod_sn}  ${rmod_state}  ${rmod_state_value}  ${timeout}=400s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for given radio module state (${rmod_state}) value (${rmod_state_value}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_state             | Yes  | Radio module state to check.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_state_value       | Yes  | Value of expected state.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected state.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  RMOD Check Expected State
    ...  rmod_sn=${rmod_sn}
    ...  rmod_state=${rmod_state}
    ...  rmod_state_value=${rmod_state_value}
    ...  vdu_connection=${vdu_connection}

RMOD Lock Operation Status Should Be
    [Arguments]  ${operation_id}  ${expected_status}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the lock operation has a given expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of locking rmods.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of lock operation.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${lock_result}=  vdu.Get Operation State Of Locking Rmods
    ...  operation_id=${operation_id}
    ...  vdu_connection=${vdu_connection}
    Should Be True  '${lock_result['status']}'=='${expected_status}'

RMOD Lock Wait For Expected Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=300s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for lock operation status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of locking rmods.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of lock operation.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of lock operation.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  RMOD Lock Operation Status Should Be
    ...  operation_id=${operation_id}
    ...  expected_status=${expected_status}
    ...  vdu_connection=${vdu_connection}

RMOD Unlock Operation Status Should Be
    [Arguments]  ${operation_id}  ${expected_status}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the unlock operation has a given expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of locking rmods.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | Value of expected operation status.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${unlock_result}=  vdu.Get Operation Of Unlocking Rmods
    ...  operation_id=${operation_id}
    ...  vdu_connection=${vdu_connection}
    Should Be True  '${unlock_result['status']}'=='${expected_status}'

RMOD Unlock Wait For Expected Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=300s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for unlock operation status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of unlocking rmods.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of unlock operation.                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of unlock operation.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  RMOD Unlock Operation Status Should Be
    ...  operation_id=${operation_id}
    ...  expected_status=${expected_status}
    ...  vdu_connection=${vdu_connection}

RMOD Should Be Online
    [Arguments]  ${rmod_sn}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if radio module is on line.
    ...  Radio module expected states:  administrative_state = Unlocked
    ...                                 operational_state = enabled
    ...                                 availability_status = on line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_rmods_params}=  vdu.Get Rmods Status  vdu_connection=${vdu_connection}
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_administrative_state}=  Set Variable  ${rmod_params['administrative_state']}
      ${rmod_operational_state}=  Set Variable  ${rmod_params['operational_state']}
      ${rmod_availability_status}=  Set Variable  ${rmod_params['availability_status']}
      ${rmod_sn_value}=  Set Variable  ${rmod_params['serial_number']}
      Exit For Loop If  '${rmod_sn_value}'=='${rmod_sn}'
    END
    Should Be Equal As Strings  first=${rmod_administrative_state}  second=Unlocked
    Should Be Equal As Strings  first=${rmod_operational_state}  second=enabled
    Should Be Equal As Strings  first=${rmod_availability_status}  second=on line

RMOD Wait For Online
    [Arguments]  ${rmod_sn}  ${timeout}=10min  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits until radio module is on line.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for radio module on line status.                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  5s
    ...  RMOD Should Be Online
    ...  rmod_sn=${rmod_sn}
    ...  vdu_connection=${vdu_connection}

RMOD Should Be Offline
    [Arguments]  ${rmod_sn}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if radio module is off line.
    ...  Radio module expected states:  administrative_state = Unlocked
    ...                                 operational_state = disabled
    ...                                 availability_status = not installed
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_rmods_params}=  vdu.Get Rmods Status  vdu_connection=${vdu_connection}
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_administrative_state}=  Set Variable  ${rmod_params['administrative_state']}
      ${rmod_operational_state}=  Set Variable  ${rmod_params['operational_state']}
      ${rmod_availability_status}=  Set Variable  ${rmod_params['availability_status']}
      ${rmod_sn_value}=  Set Variable  ${rmod_params['serial_number']}
      Exit For Loop If  '${rmod_sn_value}'=='${rmod_sn}'
    END
    Should Be Equal As Strings  first=${rmod_administrative_state}  second=Unlocked
    Should Be Equal As Strings  first=${rmod_operational_state}  second=disabled
    Should Be Equal As Strings  first=${rmod_availability_status}  second=not installed

RMOD Wait For Offline
    [Arguments]  ${rmod_sn}  ${timeout}=5min  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits until radio module is off line.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for radio module off line status.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  5s
    ...  RMOD Should Be Offline
    ...  rmod_sn=${rmod_sn}
    ...  vdu_connection=${vdu_connection}

vDU RMODs Get Serial Number And Id
    [Documentation]
    ...  Description:
    ...  Keyword returns current radio module serial number and id.
    ...  Return example:
    ...  {'1': 'K9181046216', '2': 'K9175116255', '3': 'K9190632468'}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_dict}=  Create Dictionary
    ${all_rmods_params}=  vdu.Get Rmods Status
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_id}=  Set Variable  ${rmod_params['id']}
      ${rmod_serial_number}=  Set Variable  ${rmod_params['serial_number']}
      Set To Dictionary  ${rmods_dict}  ${rmod_id}=${rmod_serial_number}
    END
    [Return]  ${rmods_dict}

RMOD Get Cell Id List
    [Arguments]  ${rmod_id}=${EMPTY}  ${rmod_sn}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword gets radio module cells based on the radio module id or optionally the serial number.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_id                | Yes  | Id of radio module.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn                |  No  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_rmods_params}=  vdu.Get Rmods Status
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_sn_value}=  Set Variable  ${rmod_params['serial_number']}
      ${rmod_id_value}=  Set Variable  ${rmod_params['id']}
      ${rmod_cell_list}=  Set Variable  ${rmod_params['cell_ids']}
      ${type_string}=  Evaluate  expression=type(${rmod_cell_list}).__name__
      Exit For Loop If  ('${rmod_id_value}'=='${rmod_id}' or '${rmod_sn_value}'=='${rmod_sn}') and '${type_string}'=='list'
      ${rmod_cell_list}=  Create List
    END
    [Return]  ${rmod_cell_list}

vDU RMOD Get Serial Number Based On Id
    [Arguments]  ${rmod_id}
    [Documentation]
    ...  Description:
    ...  Keyword gets radio module serial number based on radio module id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_id                | Yes  | Id of radio module.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_rmods_params}=  vdu.Get Rmods Status
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_sn}=  Set Variable  ${rmod_params['serial_number']}
      ${rmod_id_value}=  Set Variable  ${rmod_params['id']}
      Exit For Loop If  '${rmod_id_value}'=='${rmod_id}'
    END
    [Return]  ${rmod_sn}

vDU RMOD Get Dist Names Based On Serial Number
    [Arguments]  ${rmod_sn}
    [Documentation]
    ...  Description:
    ...  Keyword gets radio module configuration and runtime Distinguished Name (DN) based on radio module serial number.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_rmods_params}=  vdu.Get Rmods Status
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_dn}=  Set Variable  ${rmod_params['dist_names']['config']}
      ${rmod_runtime_dn}=  Set Variable  ${rmod_params['dist_names']['runtime']}
      ${rmod_sn_value}=  Set Variable  ${rmod_params['serial_number']}
      Exit For Loop If  '${rmod_sn_value}'=='${rmod_sn}'
    END
    Run Keyword If  '${rmod_sn_value}'!='${rmod_sn}'
    ...  Fail  Radio module serial number ${rmod_sn} not found in current configuration !
    [Return]  ${rmod_dn}  ${rmod_runtime_dn}

vDU RMOD Get Antennas Runtime Dist Name Based On Serial Number
    [Arguments]  ${rmod_sn}  ${ant_port_direction}=@{EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword gets radio module active antennas runtime Distinguished Name (DN)
    ...  based on radio module serial number and direction.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ant_port_direction     |  No  | Antennas port direction list.                                              |
    ...  |                        |      | If ${ant_port_direction}=@{EMPTY} all antennas will be included.           |
    ...  |                        |      | Example of ${ant_port_direction} list: [TXRX, RX]                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${ants_runtime_dn_list}  Create List
    ${all_rmods_params}=  vdu.Get Rmods Status
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_sn_value}=  Set Variable  ${rmod_params['serial_number']}
      ${rmod_ant_ports}=  Set Variable  ${rmod_params['ant_ports']}
      Exit For Loop If  '${rmod_sn_value}'=='${rmod_sn}'
    END
    Run Keyword If  '${rmod_sn_value}'!='${rmod_sn}'
    ...  Fail  Radio module serial number ${rmod_sn} not found in current configuration !
    FOR  ${ant_port}  IN  @{rmod_ant_ports}
      Continue For Loop If  '${ant_port['direction']}'=='${None}'
      Run Keyword If  ${ant_port_direction}==@{EMPTY}
      ...  Append To List  ${ants_runtime_dn_list}  ${ant_port['dist_names']['runtime']}
      ...  ELSE IF  '${ant_port['direction']}' in ${ant_port_direction}
      ...  Append To List  ${ants_runtime_dn_list}  ${ant_port['dist_names']['runtime']}
    END
    [Return]  ${ants_runtime_dn_list}

vDU RMOD Get Serial Numbers And Given Parameters Value
    [Arguments]  ${rmod_param}  ${rmod_sub_param}=${None}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns radio module serial numbers and given parameters value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_param             |  Yes | RMOD parameter name, for example 'product_name'.                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sub_param         |  No  | Name of the subparameter defined in the rmod_param.                        |
    ...  |                        |      | Example: 'dist_names': {'config': 'MRBTS-8533/EQM-1/APEQM-1/RMOD-3'}       |
    ...  |                        |      | 'dist_names' is rmod_param, 'config' is rmod_sub_param                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of given parameters value, where the key is the radio module serial number.
    ...  Example (rmod_param=product_name):
    ...  {'LR231902254': 'ARGA', '1M190413180': 'AHCA', '1M230816495': 'AHNA'}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_dict}=  Create Dictionary
    ${all_rmods_params}=  vdu.Get Rmods Status  vdu_connection=${vdu_connection}
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_parameter}=  Set Variable If  '${rmod_sub_param}'=='${None}'
      ...  ${rmod_params['${rmod_param}']}  ${rmod_params['${rmod_param}']['${rmod_sub_param}']}
      ${rmod_serial_number}=  Set Variable  ${rmod_params['serial_number']}
      Set To Dictionary  ${rmods_dict}  ${rmod_serial_number}=${rmod_parameter}
    END
    [Return]  ${rmods_dict}

vDU RMOD Get Parameter Value Based On Serial Number
    [Arguments]  ${rmod_sn}  ${rmod_param}
    [Documentation]
    ...  Description:
    ...  Keyword gets radio module parameter value based on radio module serial number.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                |  Yes | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_param             |  Yes | RMOD parameter name, for example 'product_name'.                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_rmods_params}=  vdu.Get Rmods Status
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_param_value}=  Set Variable  ${rmod_params['${rmod_param}']}
      ${rmod_sn_value}=  Set Variable  ${rmod_params['serial_number']}
      Exit For Loop If  '${rmod_sn_value}'=='${rmod_sn}'
    END
    [Return]  ${rmod_param_value}

RMOD Reset Operation Status Should Be
    [Arguments]  ${operation_id}  ${expected_status}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the reset operation has a given expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of reset rmods.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of reset operation.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${reset_result}=  vdu.Get Reset Rmods Operation Status
    ...  operation_id=${operation_id}
    ...  vdu_connection=${vdu_connection}
    Should Be True  '${reset_result['status']}'=='${expected_status}'

RMOD Reset Wait For Expected Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=300s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for reset operation status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of reset rmods.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of reset operation.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of reset operation.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  1s
    ...  RMOD Reset Operation Status Should Be
    ...  operation_id=${operation_id}
    ...  expected_status=${expected_status}
    ...  vdu_connection=${vdu_connection}

RMOD Unit Reset
    [Arguments]  ${rmod_sn}  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword resets radio module and waits for success reset operation.
    ...  Keyword waits until radio module is on line after reset operation.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_sn                | Yes  | Serial number of radio module to reset.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set info log prefix to message or not.                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value  rmod_param=id
    ${rmod_id}=  Get From Dictionary  dictionary=${rmods_id_dict}  key=${rmod_sn}
    ${rmods_id_list}=  Create List  ${rmod_id}
    Log  ${log_prefix}Wait a while for the radio module (sn: ${rmod_sn}) to reset ...  console=${log_to_console}
    ${reset_result}=  vdu.Reset Rmods  rmods_list=${rmods_id_list}
    RMOD Reset Wait For Expected Status  operation_id=${reset_result["operation_id"]}  expected_status=success
    RMOD Wait For Online  rmod_sn=${rmod_sn}
    Log  ${log_prefix}Radio module (serial number: ${rmod_sn}) is online now  console=${log_to_console}

vDU RMOD Get Fans Realtime Dist Names
    [Arguments]  ${rmod_runtime_dn}
    [Documentation]
    ...  Description:
    ...  Keyword gets radio module fans runtime Distinguished Names (DN) list based on radio module Distinguished Name (DN).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_runtime_dn        | Yes  | Radio module real time Distinguished Name (DN).                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rmods_info_dict}=  Get Real Time Measurements Info
    ${rmods_info_list}=  Get From Dictionary  dictionary=${rmods_info_dict}  key=rmods
    FOR  ${rmod_info}  IN  @{rmods_info_list}
      ${rmod_runtime_dn_value}=  Set Variable  ${rmod_info['rmod_id']['runtime']}
      ${fans_runtime_dn_list}=  Create List  @{rmod_info['fans']}
      Exit For Loop If  '${rmod_runtime_dn_value}'=='${rmod_runtime_dn}'
    END
    Run Keyword If  '${rmod_runtime_dn_value}'!='${rmod_runtime_dn}'
    ...  Fail  Radio module dist name ${rmod_runtime_dn} not found in current configuration !
    [Return]  ${fans_runtime_dn_list}
#vDU ALD operations
Wait Until All ALDs Are OnAir
    [Arguments]  ${alds_count}  ${timeout}=60s  ${time_interval}=5s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits until all ALDs are onAir.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | alds_count             | Yes  | Number of all alds.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Wait until all ALDs are onAir.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vDU All ALDs Should Be Onair  alds_count=${alds_count}  vdu_connection=${vdu_connection}

vDU All ALDs Should Be OnAir
    [Arguments]  ${alds_count}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if all ALDs are onAir.
    ...  Keyword checks the following status:   operational_state = enabled
    ...                                         availability_status = on line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | alds_count             | Yes  | Number of all alds.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${vdu_alds_summary}=  vdu.Get Alds  vdu_connection=${vdu_connection}
    ${runtime_alds_count}=  Evaluate  len(${vdu_alds_summary})
    Should Be Equal As Numbers
    ...  first=${alds_count}
    ...  second=${runtime_alds_count}
    ...  msg=Number of ALDs mismatch between scf and runtime!
    FOR  ${ald}  IN  @{vdu_alds_summary}
      Should Be Equal As Strings
      ...  first=${ald['operational_state']}
      ...  second=enabled
      ...  msg=ALD ${ald['dist_names']['runtime']} operational state is not 'enabled'
      Should Be Equal As Strings
      ...  first=${ald['availability_status']}
      ...  second=on line
      ...  msg=ALD ${ald['dist_names']['runtime']} availability status is not 'on line'
    END

Wait Until All RETs Are OnAir
    [Arguments]  ${rets_count}  ${timeout}=60s  ${time_interval}=5s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits until all RETs are onAir.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rets_count             | Yes  | Number of all rets.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Wait until all RET are onAir.                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vDU All RETs Should Be Onair  rets_count=${rets_count}  vdu_connection=${vdu_connection}

vDU All RETs Should Be OnAir
    [Arguments]  ${rets_count}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if all RETs are onAir.
    ...  Keyword checks the following status:   operational_state = enabled
    ...                                         availability_status = on line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rets_count             | Yes  | Number of all rets.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    ${vdu_rets_summary}=  vdu.Get Rets Information  vdu_connection=${vdu_connection}
    ${ret_state_dict}=  Create Dictionary
    FOR  ${ald}  IN  @{vdu_rets_summary}
      FOR  ${subunit}  IN  @{ald['subunits']}
        ${state_list}=  Create List  operational_state=${subunit['operational_state']}  availability_status=${subunit['availability_status']}
        Set To Dictionary  ${ret_state_dict}  ${subunit['dist_names']['runtime']}=${state_list}
      END
    END
    ${runtime_rets_count}=  Evaluate  len(${ret_state_dict})
    Should Be Equal As Numbers
    ...  first=${rets_count}
    ...  second=${runtime_rets_count}
    ...  msg=Number of RETs mismatch between scf and runtime!
    ${ref_state_list}=  Create list  operational_state=enabled  availability_status=on line
    FOR  ${ret}  IN  @{ret_state_dict}
      Lists Should Be Equal
      ...  list1=${ret_state_dict['${ret}']}
      ...  list2=${ref_state_list}
      ...  msg=RET ${ret} operational/availability state is not correct
    END
#vDU cells operations
vDU All Cells Should Be OnAir Check Status
    [Arguments]  ${cells_count}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if all cells are onAir.
    ...  Keyword only support rest api v2.
    ...  Keyword checks the following status: operational_state = enabled, administrative_state = Unlocked,
    ...  availability_status = on line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_count            | Yes  | Number of all cells.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_cells_info}=  vdu.Get Vdu Cells Status  vdu_connection=${vdu_connection}
    ${all_cells_count}=  Get Length  item=${all_cells_info}
    Should Be Equal As Numbers  first=${all_cells_count}  second=${cells_count}
    FOR  ${cell_info}  IN  @{all_cells_info}
      Should Be Equal As Strings  first=${cell_info['operational_state']}  second=enabled
      Should Be Equal As Strings  first=${cell_info['administrative_state']}  second=Unlocked
      Should Be Equal As Strings  first=${cell_info['availability_status']}  second=on line
    END

vDU All NR Cells Should Be OnAir
    [Arguments]  ${nrcells_count}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks if all NR cells are onAir.
    ...  Keyword checks the following status:   operational_state = enabled
    ...                                         administrative_state = unlocked
    ...                                         availability_status = on_line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | nrcells_count          | Yes  | Number of all NR cells.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_cells_summary}=  vdu.Get Vdu Cells Summary  vdu_connection=${vdu_connection}
    Should Be Equal As Numbers
    ...  first=${vdu_cells_summary['basic_cells_summary']['operational_state']['enabled']}  second=${nrcells_count}
    Should Be Equal As Numbers
    ...  first=${vdu_cells_summary['basic_cells_summary']['administrative_state']['unlocked']}  second=${nrcells_count}
    Should Be Equal As Numbers
    ...  first=${vdu_cells_summary['availability_status']['on_line']}  second=${nrcells_count}

vDU All Cells Should Be OnAir
    [Arguments]  ${cells_count}=0  ${lcells_count}=0  ${vdu_connection}=default  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword checks if all cells are onAir.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_count            | Yes  | Number of all NR cells.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcells_count           | Yes  | Number of all LTE cells.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${cells_count}>0
    ...  vDU All NR Cells Should Be OnAir  nrcells_count=${cells_count}  vdu_connection=${vdu_connection}
    Run Keyword If  ${lcells_count}>0
    ...  LTEvDU All Lte Cells Should Be OnAir  lcells_count=${lcells_count}  lte_vdu_connection=${lte_vdu_connection}

Wait Until All Cells Are OnAir
    [Arguments]  ${cells_count}=0  ${lcells_count}=0  ${timeout}=${VDU_CELLS_ONAIR_TIMEOUT}
    ...  ${time_interval}=5s  ${vdu_connection}=default  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword waits until all cells are onAir.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_count            | Yes  | Number of all NR cells.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcells_count           | Yes  | Number of all LTE cells.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Wait until all cells are onAir.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vDU All Cells Should Be Onair  cells_count=${cells_count}  lcells_count=${lcells_count}
    ...  vdu_connection=${vdu_connection}  lte_vdu_connection=${lte_vdu_connection}

Cell Block Operation Status Should Be
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the block operation has a given expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of blocking cell.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of block operation.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for block operation status.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${block_result}=  vdu.Get Block Cell Operation Status
    ...  operation_id=${operation_id}
    ...  timeout=${timeout}
    ...  vdu_connection=${vdu_connection}
    Should Be True  "${block_result["status"]}"=="${expected_status}"

Cell Block Wait For Expected Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s  ${time_interval}=10s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for block operation status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of blocking cell.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of block operation.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of block operation.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  Cell Block Operation Status Should Be
    ...  operation_id=${operation_id}
    ...  expected_status=${expected_status}
    ...  vdu_connection=${vdu_connection}

vDU Block Cell And Check
    [Arguments]  ${cell_id}  ${timeout}=60s  ${time_interval}=10s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword blocks cell based on cell id and operation result.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id                | Yes  | Id of cell to be blocked.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for the block operation.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${block_result}=  vdu.Block Cell
    ...  cell_id=${cell_id}
    ...  timeout=${timeout}
    ...  vdu_connection=${vdu_connection}
    Cell Block Wait For Expected Status
    ...  operation_id=${block_result["id"]}
    ...  expected_status=success
    ...  timeout=${timeout}
    ...  time_interval=${time_interval}
    ...  vdu_connection=${vdu_connection}
    [Teardown]  vdu.Delete Block Cell Operation
    ...  operation_id=${block_result["id"]}
    ...  vdu_connection=${vdu_connection}

Cell Unblock Operation Status Should Be
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the unblock operation has a given expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of unblocking cell.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of unblock operation.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for unblock operation status.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${unblock_result}=  vdu.Get Unblock Cell Operation Status
    ...  operation_id=${operation_id}
    ...  timeout=${timeout}
    ...  vdu_connection=${vdu_connection}
    Should Be True  "${unblock_result["status"]}"=="${expected_status}"

Cell Unblock Wait For Expected Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s  ${time_interval}=10s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for unblock operation status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of unblocking cell.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of unblock operation.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of unblock operation.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  Cell Unblock Operation Status Should Be
    ...  operation_id=${operation_id}
    ...  expected_status=${expected_status}
    ...  vdu_connection=${vdu_connection}

vDU Unblock Cell And Check
    [Arguments]  ${cell_id}  ${timeout}=60s  ${time_interval}=10s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword unblocks cell based on cell id and operation result.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id                | Yes  | Id of cell to be unblocked.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Timeout for the unblock operation.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${unblock_result}=  vdu.Unblock Cell
    ...  cell_id=${cell_id}
    ...  timeout=${timeout}
    ...  vdu_connection=${vdu_connection}
    Cell Unblock Wait For Expected Status
    ...  operation_id=${unblock_result["id"]}
    ...  expected_status=success
    ...  timeout=${timeout}
    ...  time_interval=${time_interval}
    ...  vdu_connection=${vdu_connection}
    [Teardown]  vdu.Delete Unblock Cell Operation
    ...  operation_id=${unblock_result["id"]}
    ...  vdu_connection=${vdu_connection}

Cell Get Current State
    [Arguments]  ${cell_id}  ${cell_state}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns the value of the given cell state (${cell_state}).
    ...  Cell is defined by id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id                | Yes  | Cell id.                                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_state             | Yes  | Cell state to get.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Value of the cell given state.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_cells_info}=  vdu.Get Vdu Cells Status  vdu_connection=${vdu_connection}
    FOR  ${cell_info}  IN  @{all_cells_info}
      ${cell_state_value}=  Set Variable  ${cell_info['${cell_state}']}
      ${cell_id_value}=  Set Variable  ${cell_info['id']}
      Exit For Loop If  '${cell_id_value}'=='${cell_id}'
    END
    [Return]  ${cell_state_value}

Cell Check Expected State
    [Arguments]  ${cell_id}  ${cell_state}  ${cell_state_value}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the cell state (${cell_state}) has the expected value (${cell_state_value}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id                | Yes  | Cell id.                                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_state             | Yes  | Cell state to check.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_state_value       | Yes  | Value of the expected state.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${current_cell_state_value}=  Cell Get Current State
    ...  cell_id=${cell_id}
    ...  cell_state=${cell_state}
    ...  vdu_connection=${vdu_connection}
    Should Be True  '${current_cell_state_value}'=='${cell_state_value}'

Cell Wait For Expected State
    [Arguments]  ${cell_id}  ${cell_state}  ${cell_state_value}  ${timeout}=60s
    ...  ${time_interval}=10s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for given cell state (${cell_state}) value (${cell_state_value}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id                | Yes  | Cell id.                                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_state             | Yes  | Cell state to check.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_state_value       | Yes  | Value of the expected state.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected state.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for state query.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  Cell Check Expected State
    ...  cell_id=${cell_id}
    ...  cell_state=${cell_state}
    ...  cell_state_value=${cell_state_value}
    ...  vdu_connection=${vdu_connection}

Cell Get Current State Or Status
    [Arguments]  ${cell_id}  ${cell_state_status}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns the value of the given cell state or status.
    ...  Available state names: administrativeState, blockingState, operationalState.
    ...  Available status names: availabilityStatus, energySavingState, proceduralStatus.
    ...  Cell is defined by id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id                | Yes  | Cell id.                                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_state_status      | Yes  | Cell state or status to get.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Value of the cell state or status.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cell_info}=  vdu.Get Cell Specific Info
    ...  cell_id=${cell_id}
    ...  vdu_connection=${vdu_connection}
    ${state_result}=  Run Keyword And Return Status
    ...  Should Match  string=${cell_state_status}  pattern=*State
    ${energysavingstate_result}=  Run Keyword And Return Status
    ...  Should Match  string=${cell_state_status}  pattern=energySavingState
    ${cell_state_status_value}=  Set Variable If  ${state_result} and not ${energysavingstate_result}
    ...  ${cell_info['basicCell']['${cell_state_status}']}  ${cell_info['${cell_state_status}']}
    [Return]  ${cell_state_status_value}

Cell Check Expected States or Statuses
    [Arguments]  ${cell_id}  ${state_status_dict}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the cell states or statuses have the expected values.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id                | Yes  | Cell id.                                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | state_status_dict      | Yes  | Dictionary of cell states or statuses and expected values e.g.             |
    ...  |                        |      | e.g. {'availabilityStatus': 'on line', 'operationalState': 'enabled'}      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cell_state_status_list}=  Create List
    ${cell_state_list}=  Get Dictionary Keys  dictionary=${state_status_dict}
    FOR  ${cell_state_status}  IN  @{cell_state_list}
      ${cell_state_status_value}=  Cell Get Current State Or Status
      ...  cell_id=${cell_id}
      ...  cell_state_status=${cell_state_status}
      ...  vdu_connection=${vdu_connection}
      ${cell_state_status}=  Run Keyword And Return Status
      ...  Should Match Regexp  string=${cell_state_status_value}  pattern=${state_status_dict['${cell_state_status}']}
      Append to List  ${cell_state_status_list}  ${cell_state_status}
    END
    List Should Not Contain Value  ${cell_state_status_list}  ${False}

Cell Wait For Expected States Or Statuses
    [Arguments]  ${cell_id}  ${state_status_dict}  ${timeout}=60s  ${time_interval}=5s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for given cell states or statuses.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id                | Yes  | Cell id.                                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | state_status_dict      | Yes  | Dictionary of cell states or statuses and expected values e.g.             |
    ...  |                        |      | e.g. {'availabilityStatus': 'on line', 'operationalState': 'enabled'}      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected state.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for state query.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  Cell Check Expected States Or Statuses
    ...  cell_id=${cell_id}
    ...  state_status_dict=${state_status_dict}
    ...  vdu_connection=${vdu_connection}

vDU Any Cell Check Expected States or Statuses
    [Arguments]  ${cell_id_list}  ${state_status_dict}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether any cell states or statuses have the expected values.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id_list           | Yes  | List of cell ids.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | state_status_dict      | Yes  | Dictionary of cell states or statuses and expected values e.g.             |
    ...  |                        |      | e.g. {'availabilityStatus': 'on line', 'operationalState': 'enabled'}      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cell_state_status_list}=  Create List
    ${all_cell_state_status_list}=  Create List
    ${cell_state_list}=  Get Dictionary Keys  dictionary=${state_status_dict}
    FOR  ${cell_id}  IN  @{cell_id_list}
      FOR  ${cell_state_status}  IN  @{cell_state_list}
        ${cell_state_status_value}=  Cell Get Current State Or Status
        ...  cell_id=${cell_id}
        ...  cell_state_status=${cell_state_status}
        ...  vdu_connection=${vdu_connection}
        ${cell_state_status}=  Run Keyword And Return Status
        ...  Should Be True  '${cell_state_status_value}'=='${state_status_dict['${cell_state_status}']}'
        Append to List  ${cell_state_status_list}  ${cell_state_status}
      END
      ${all_cell_state_status}=  Run Keyword And Return Status
      ...  List Should Not Contain Value  ${cell_state_status_list}  ${False}
      Append to List  ${all_cell_state_status_list}  ${all_cell_state_status}
      ${cell_state_status_list}=  Create List
      Exit For Loop If  ${all_cell_state_status}
    END
    List Should Contain Value  ${all_cell_state_status_list}  ${True}

vDU Any Cell Wait For Expected States Or Statuses
    [Arguments]  ${cell_id_list}  ${state_status_dict}  ${timeout}=60s  ${time_interval}=5s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for given any cell states or statuses.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id_list           | Yes  | List of cell ids.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | state_status_dict      | Yes  | Dictionary of cell states or statuses and expected values e.g.             |
    ...  |                        |      | e.g. {'availabilityStatus': 'on line', 'operationalState': 'enabled'}      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected state.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for state query.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vDU Any Cell Check Expected States Or Statuses
    ...  cell_id_list=${cell_id_list}
    ...  state_status_dict=${state_status_dict}
    ...  vdu_connection=${vdu_connection}

vDU Cells Get Identity And Id
    [Arguments]  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns current cells identity and id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cells_dict}=  Create Dictionary
    ${all_cells_params}=  vdu.Get Vdu Cells Status  vdu_connection=${vdu_connection}
    FOR  ${cell_params}  IN  @{all_cells_params}
      ${cell_id}=  Set Variable  ${cell_params['id']}
      ${cell_identity}=  Set Variable  ${cell_params['nr_cell_identity']}
      Set To Dictionary  ${cells_dict}  ${cell_id}=${cell_identity}
    END
    [Return]  ${cells_dict}

vDU Cells Get Dist Name Based On Id
    [Arguments]  ${cell_id}
    [Documentation]
    ...  Description:
    ...  Keyword returns cell Distinguished Names (DN) based on cell id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id                | Yes  | Cell Distinguished Name (DN).                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${all_cells_params}=  vdu.Get Vdu Cells Status
    FOR  ${cell_params}  IN  @{all_cells_params}
      ${cell_dist_name}=  Set Variable  ${cell_params['dist_names']['config']}
      ${cell_id_value}=  Set Variable  ${cell_params['id']}
      Exit For Loop If  '${cell_id_value}'=='${cell_id}'
    END
    [Return]  ${cell_dist_name}

vDU Cells Get Dist Names Based On Ids
    [Arguments]  ${cell_id_list}
    [Documentation]
    ...  Description:
    ...  Keyword returns cell Distinguished Names (DN) based on cells id list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_id_list           | Yes  | Cell Distinguished Names (DN) list.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cells_dist_name_list}=  Create List
    ${all_cells_params}=  vdu.Get Vdu Cells Status
    FOR  ${cell_params}  IN  @{all_cells_params}
      Continue For Loop If  '${cell_params['id']}' not in ${cell_id_list}
      Append To List  ${cells_dist_name_list}  ${cell_params['dist_names']['config']}
    END
    [Return]  ${cells_dist_name_list}

vDU Cells Get Ids And Given Parameters Value
    [Arguments]  ${cell_param}  ${cell_sub_param}=${None}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns cells ids and given parameters value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cell_param             |  Yes | Cell parameter name, for example 'nr_cell_identity'.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cell_sub_param         |  No  | Name of the subparameter defined in the cell_param.                        |
    ...  |                        |      | Example: 'dist_names': {'config': 'MRBTS-8533/NRBTS-8533/NRCELL-10'}       |
    ...  |                        |      | 'dist_names' is cell_param, 'config' is cell_sub_param                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of given parameter value, where the key is cell id.
    ...  Example (cell_param=dist_names, cell_sub_param=config):
    ...  {'3': 'MRBTS-8533/NRBTS-8533/NRCELL-3', '5': 'MRBTS-8533/NRBTS-8533/NRCELL-5'}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cells_dict}=  Create Dictionary
    ${all_cells_params}=  vdu.Get Vdu Cells Status  vdu_connection=${vdu_connection}
    FOR  ${cell_params}  IN  @{all_cells_params}
      ${cell_parameter}=  Set Variable If  '${cell_sub_param}'=='${None}'
      ...  ${cell_params['${cell_param}']}  ${cell_params['${cell_param}']['${cell_sub_param}']}
      ${cell_id}=  Set Variable  ${cell_params['id']}
      Set To Dictionary  ${cells_dict}  ${cell_id}=${cell_parameter}
    END
    [Return]  ${cells_dict}

#vDU operations
vDU Get Current State
    [Arguments]  ${vdu_state}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets current vDU state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_state              | Yes  | vDU state to get.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_state_info}=  vdu.Get Vdu State Data
    ...  vdu_connection=${vdu_connection}
    ${vdu_state_value}=  Set Variable  ${vdu_state_info['${vdu_state}']}
    [Return]  ${vdu_state_value}

vDU Check Expected State
    [Arguments]  ${vdu_state}  ${vdu_state_value}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the vDU state (${vdu_state}) has the expected value (${vdu_state_value}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_state              | Yes  | vDU state to check.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_state_value        | Yes  | Value of the expected state.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${current_vdu_state}=  vDU Get Current State
    ...  vdu_state=${vdu_state}
    ...  vdu_connection=${vdu_connection}
    Should Be True  '${current_vdu_state}'=='${vdu_state_value}'

vDU Wait For Expected State
    [Arguments]  ${vdu_state}  ${vdu_state_value}  ${timeout}=15min
    ...  ${time_interval}=20s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for given vDU state (${vdu_state}) value (${vdu_state_value}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_state              | Yes  | vDU state to check.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_state_value        | Yes  | Value of vDU expected state.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for vDU expected state.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for state query.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vDU Check Expected State
    ...  vdu_state=${vdu_state}
    ...  vdu_state_value=${vdu_state_value}
    ...  vdu_connection=${vdu_connection}

vDU Reset Operation Status Should Be
    [Arguments]  ${operation_id}  ${expected_status}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the vDU reset operation has a given expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of reset vDU.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of reset vDU operation.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${reset_result}=  vdu.Get Reset Vdu Operation Status  operation_id=${operation_id}
    Should Be True  '${reset_result['status']}'=='${expected_status}'

vDU Reset Wait For Expected Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s
    [Documentation]
    ...  Description:
    ...  Keyword waits for vDU reset operation status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of reset vDU.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of reset vDU operation.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of reset vDU operation.                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  vDU Reset Operation Status Should Be
    ...  operation_id=${operation_id}  expected_status=${expected_status}

vDU Get Operational State
    [Arguments]  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns vDU operational state value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  vDU operational state value.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_params}=  vdu.Get Vdu State Data  vdu_connection=${vdu_connection}
    ${vdu_state_value}=  Set Variable  ${vdu_params['operational_state']}
    [Return]  ${vdu_state_value}

vDU Check Operational State
    [Arguments]  ${vdu_state_value}  ${vdu_check}=${True}  ${lte_vdu_check}=${False}
    ...  ${vdu_connection}=default  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the operational state of the vDU has the expected value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_state_value        | Yes  | Value of vDU expected state.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_check              |  Yes | Check 5G vDU operational state.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_check          |  No  | Check 4G vDU operational state.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${current_vdu_state_value}=  Run Keyword If  ${vdu_check}
    ...  vDU Get Operational State
    ...  vdu_connection=${vdu_connection}
    Run Keyword If  ${vdu_check}
    ...  Should Be True  '${current_vdu_state_value}'=='${vdu_state_value}'
    ${current_lte_vdu_state_value}=  Run Keyword If  ${lte_vdu_check}
    ...  LTEvDU Get Operational State
    ...  lte_vdu_connection=${lte_vdu_connection}
    Run Keyword If  ${lte_vdu_check}
    ...  Should Be True  '${current_lte_vdu_state_value}'=='${vdu_state_value}'

vDU Wait For Expected Operational State
    [Arguments]  ${vdu_state_value}  ${timeout}=600s  ${time_interval}=10s  ${vdu_check}=${True}
    ...  ${lte_vdu_check}=${False}  ${vdu_connection}=default  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword waits for vDU operation state value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_state_value        | Yes  | Value of vDU expected state.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected state.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for state query.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_check              |  Yes | Check 5G vDU operational state.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_check          |  No  | Check 4G vDU operational state.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vDU Check Operational State
    ...  vdu_state_value=${vdu_state_value}
    ...  vdu_check=${vdu_check}
    ...  lte_vdu_check=${lte_vdu_check}
    ...  vdu_connection=${vdu_connection}
    ...  lte_vdu_connection=${lte_vdu_connection}

vDU Get F1 Link Status
    [Arguments]  ${log_to_console}=${False}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns vDU F1-C link status value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  vDU operational state value.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_params}=  vdu.Get Vdu State Data
    ...  vdu_connection=${vdu_connection}
    ${vdu_f1_link_status_value}=  Set Variable  ${vdu_params['f1_c_link_status_du']}
    Log  \nvDU F1 link status is ${vdu_f1_link_status_value}.\n  console=${log_to_console}
    [Return]  ${vdu_f1_link_status_value}

vDU Check F1 Link Status
    [Arguments]  ${f1_link_status_value}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether vDU F1-C link status has the expected value (${f1_link_status_value}).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | f1_link_status_value   | Yes  | Value of vDU F1-C link status expected state.                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${current_f1_link_status_value}=  vDU Get F1 Link Status
    ...  vdu_connection=${vdu_connection}
    Should Be True  '${current_f1_link_status_value}'=='${f1_link_status_value}'

vDU Wait For Expected F1 Link Status
    [Arguments]  ${f1_link_status_value}  ${timeout}=600s  ${time_interval}=10s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for vDU F1-C link status value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | f1_link_status_value   | Yes  | Value of vDU F1-C link status expected state.                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected state.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  vDU Check F1 Link Status
    ...  f1_link_status_value=${f1_link_status_value}
    ...  vdu_connection=${vdu_connection}

vDU Get Running Software Version
    [Arguments]  ${gnb_index}=0  ${vdu_login}=True  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gets running vDU software version.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vdu_login}
    ...  vDU Rest Login  gnb_index=${gnb_index}  vdu_connection=${vdu_connection}
    ${vdu_state_date}=  vdu.Get Vdu State Data  vdu_connection=${vdu_connection}
    ${vdu_sw_version}=  Set Variable  ${vdu_state_date['software_version']}
    [Return]  ${vdu_sw_version}
    [Teardown]  Run Keyword If  ${vdu_login}
    ...  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

vDU Perform Reset
    [Arguments]  ${vdu_connection}=default  ${log_prefix}=${EMPTY}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Keyword performs vDU reset and wait for API connection established.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

# vDU reset
    ${reset_result}=  vdu.Reset Vdu
    ...  vdu_connection=${vdu_connection}
    ${reset_status}=  vdu.Get Reset Vdu Operation Status
    ...  operation_id=${reset_result['id']}
    ...  vdu_connection=${vdu_connection}
    Log  ${log_prefix}vDU reset operation status: ${reset_status['status']}  console=${log_to_console}
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
# Check if vDU OAM IP address is unavailable
    Ip Address Is Unavailable  ip_addr=${ip_addr}
    Log  ${log_prefix}vDU is unavailable. Wait a while for vDU availability ...  console=${log_to_console}
# Check if vDU OAM IP address is available
    Ip Address Is Available  ip_addr=${ip_addr}
    Log  ${log_prefix}vDU is available  console=${log_to_console}
# Check if API connection is established
    Log  ${log_prefix}Waiting for API connection to be established ...  console=${log_to_console}
    Wait Until Keyword Succeeds  30  2
    ...  vdu.Get Vdu State Data
    ...  vdu_connection=${vdu_connection}
    Log  ${log_prefix}API connection established  console=${log_to_console}

vDU Perform Reset And Alarm Check
    [Arguments]  ${activation_timeout}  ${cancellation_timeout}  ${vdu_connection}=default
    ...  ${log_prefix}=${EMPTY}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Keyword performs vDU reset and wait for vDU OnAir operational state.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | activation_timeout     | Yes  | Wait until alarm 4592 is active.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cancellation_timeout   | Yes  | Wait until alarm 4592 is inactive.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

# vDU reset
    ${reset_result}=  vdu.Reset Vdu
    ...  vdu_connection=${vdu_connection}
    ${reset_status}=  vdu.Get Reset Vdu Operation Status
    ...  operation_id=${reset_result['id']}
    ...  vdu_connection=${vdu_connection}
    Log  ${log_prefix}vDU reset operation status: ${reset_status['status']}  console=${log_to_console}
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
# Check if vDU OAM IP address is unavailable
    Ip Address Is Unavailable  ip_addr=${ip_addr}
    Log  ${log_prefix}vDU is unavailable. Wait a while for vDU availability ...  console=${log_to_console}
# Check if vDU OAM IP address is available
    Ip Address Is Available  ip_addr=${ip_addr}
    Log  ${log_prefix}vDU is available  console=${log_to_console}
# Check if API connection is established
    Log  ${log_prefix}Waiting for API connection to be established ...  console=${log_to_console}
    Wait Until Keyword Succeeds  60  2
    ...  vdu.Get Vdu State Data
    ...  vdu_connection=${vdu_connection}
    Log  ${log_prefix}API connection established  console=${log_to_console}
# Check BTS Reset Cause Alarm
    vDU Check BTS Reset Cause Alarm
    ...  activation_timeout=${activation_timeout}
    ...  cancellation_timeout=${cancellation_timeout}
    ...  info_pattern=*due to user request*
    ...  vdu_connection=${vdu_connection}
    ...  log_prefix=${log_prefix}

vDU Get MRBTS Id
    [Arguments]  ${vdu_login}=False  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword gest MRBTS Id from current plan.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_login              |  No  | vDU login/logout or not.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${vdu_login}
    ...  vDU Rest Login  ${gnb_index}  vdu_connection=${vdu_connection}
    ${class_names}=  Create List  MRBTS
    ${mrbts_current_plan}=  vdu.Get Current Plan Objects
    ...  class_name=${class_names}  vdu_connection=${vdu_connection}
    ${mrbts_dist_name}=  Set Variable  ${mrbts_current_plan['objects'][0]['distName']}
    ${mrbts_id}=  Fetch From Right  string=${mrbts_dist_name}  marker=-
    [Return]  ${mrbts_id}
    [Teardown]  Run Keyword If  ${vdu_login}
    ...  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Get Dist Names Current Plan Objects
    [Arguments]  ${class_name_list}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns dist names list for objects of a given class.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | class_name_list        | Yes  | List of class names for object matching filtering.                         |
    ...  |                        |      | If only one class name is required it can be provided as a string.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${dist_names_list}=  Create List
    ${class_object}=  vdu.Get Current Plan Objects
    ...  class_name=${class_name_list}
    ...  vdu_connection=${vdu_connection}
    ${objects_list}=  Set Variable  ${class_object['objects']}
    FOR  ${object_item}  IN  @{objects_list}
      Append To List  ${dist_names_list}  ${object_item['distName']}
    END
    [Return]  ${dist_names_list}

vDU Get Software Release And Version Number
    [Documentation]
    ...  Description:
    ...  Keyword gest vDU software release and build number.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_state_data}=  vdu.Get Vdu State Data
    ${software_version_list}=  Split String  string=${vdu_state_data['software_version']}  separator=_
    ${software_release}=  Set Variable  ${software_version_list[0]}
    ${software_release}=  Remove String  ${software_release}  vDUCNF
    ${software_build_number}=  Set Variable  ${software_version_list[1]}
    [Return]  ${software_release}  ${software_build_number}

vDU Get Software Release And Version Number From Current Plan
    [Documentation]
    ...  Description:
    ...  Keyword gest vDU software release and build number from current plan.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=False
    ${mnl_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNL_R-1
    ${software_version}=  vdu.Search Parameter Of Current Plan  mo_dn=${mnl_mo_dn}  para_name=activeSWReleaseVersion
    ${software_version_list}=  Split String  string=${software_version}  separator=_
    ${software_release}=  Set Variable  ${software_version_list[0]}
    ${software_release}=  Remove String  ${software_release}  vDUCNF
    ${software_build_number}=  Set Variable  ${software_version_list[1]}
    [Return]  ${software_release}  ${software_build_number}

#RAN NIC operations
vDU Rannics Get Serial Numbers And Given Parameters Value
    [Arguments]  ${rannic_param}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns RAN NICs serial numbers and given parameters value.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rannic_param           |  Yes | RAN NIC parameter name, for example 'product_code'.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  Dictionary of given parameters value, where the key is the RAN NIC serial number.
    ...  Example (rannic_param=r_nic_mod_dist_name):
    ...  {'L1232810438': 'MRBTS-8474/EQM_R-1/APEQM_R-1/RNICMOD_R-1'}
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rannics_dict}=  Create Dictionary
    ${mrbts_id}=  vDU Get MRBTS Id
    ${rannics_info}=  vdu.Get Rnic Info From Plan  mrbts_id=${mrbts_id}  vdu_connection=${vdu_connection}
    FOR  ${rannic_info}  IN  @{rannics_info}
      ${rannic_parameter}=  Set Variable  ${rannic_info['${rannic_param}']}
      ${rannic_serial_number}=  Set Variable  ${rannic_info['serial_number']}
      Set To Dictionary  ${rannics_dict}  ${rannic_serial_number}=${rannic_parameter}
    END
    [Return]  ${rannics_dict}

vDU Rannics Should Be Online
    [Arguments]  ${rannics_sn_list}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the RAN NICs given by serial numbers are on line if 5G vDU is used.
    ...  Rannic expected states:  operational_state = enabled
    ...                           availability_status = on line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rannics_sn_list        | Yes  | List of RAN NICs serial numbers if 5G vDU is used.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${operational_states_list}=  Create List
    ${availability_statuses_list}=  Create List
    ${mrbts_id}=  vDU Get MRBTS Id
    ${rannics_info}=  vdu.Get Rnic Info From Plan  mrbts_id=${mrbts_id}  vdu_connection=${vdu_connection}
    FOR  ${rannic_info}  IN  @{rannics_info}
      IF  '${rannic_info['serial_number']}' in ${rannics_sn_list}
        Append To List  ${operational_states_list}  ${rannic_info['operational_state']}
        Append To List  ${availability_statuses_list}  ${rannic_info['availability_status']}
      END
    END
    List Should Not Contain Value  ${operational_states_list}  disabled
    List Should Not Contain Value  ${operational_states_list}  off line

vDU All Rannics Should Be Online
    [Arguments]  ${rannics_sn_list}=@{EMPTY}  ${lte_rannics_sn_list}=@{EMPTY}
    ...  ${vdu_connection}=default  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword checks if all RAN NICs given by serial number are on line.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rannics_sn_list        | Yes  | List of RAN NICs serial numbers if 5G vDU is used.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_rannics_sn_list    | Yes  | List of RAN NICs serial numbers if 4G vDU is used.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${rannics_sn_list}!=@{EMPTY}
    ...  vDU Rannics Should Be Online
    ...  rannics_sn_list=${rannics_sn_list}
    ...  vdu_connection=${vdu_connection}
    Run Keyword If  ${lte_rannics_sn_list}!=@{EMPTY}
    ...  Fail  msg=LTE vDU not supported (${lte_vdu_connection})

vDU Wait Until Rannics Are Online
    [Arguments]  ${rannics_sn_list}=@{EMPTY}  ${lte_rannics_sn_list}=@{EMPTY}  ${timeout}=300s
    ...  ${vdu_connection}=default  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword waits until RAN NICs given by serial numbers are on line.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rannics_sn_list        | Yes  | List of RAN NICs serial numbers if 5G vDU is used.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_rannics_sn_list    | Yes  | List of RAN NICs serial numbers if 4G vDU is used.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Wait until all RAN NICs are on line.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  vDU All Rannics Should Be Online
    ...  rannics_sn_list=${rannics_sn_list}
    ...  lte_rannics_sn_list=${lte_rannics_sn_list}
    ...  vdu_connection=${vdu_connection}
    ...  lte_vdu_connection=${lte_vdu_connection}

vDU Rannics Should Be Offline
    [Arguments]  ${rannics_sn_list}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the RAN NICs given by serial numbers are off line if 5G vDU is used.
    ...  Rannic expected states:  operational_state = disabled
    ...                           availability_status = off line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rannics_sn_list        | Yes  | List of RAN NICs serial numbers if 5G vDU is used.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${operational_states_list}=  Create List
    ${availability_statuses_list}=  Create List
    ${mrbts_id}=  vDU Get MRBTS Id
    ${rannics_info}=  vdu.Get Rnic Info From Plan  mrbts_id=${mrbts_id}  vdu_connection=${vdu_connection}
    FOR  ${rannic_info}  IN  @{rannics_info}
      IF  '${rannic_info['serial_number']}' in ${rannics_sn_list}
        Append To List  ${operational_states_list}  ${rannic_info['operational_state']}
        Append To List  ${availability_statuses_list}  ${rannic_info['availability_status']}
      END
    END
    List Should Not Contain Value  ${operational_states_list}  enabled
    List Should Not Contain Value  ${operational_states_list}  on line

vDU All Rannics Should Be Offline
    [Arguments]  ${rannics_sn_list}=@{EMPTY}  ${lte_rannics_sn_list}=@{EMPTY}
    ...  ${vdu_connection}=default  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword checks if all RAN NICs given by serial number are off line.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rannics_sn_list        | Yes  | List of RAN NICs serial numbers if 5G vDU is used.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_rannics_sn_list    | Yes  | List of RAN NICs serial numbers if 4G vDU is used.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${rannics_sn_list}!=@{EMPTY}
    ...  vDU Rannics Should Be Online
    ...  rannics_sn_list=${rannics_sn_list}
    ...  vdu_connection=${vdu_connection}
    Run Keyword If  ${lte_rannics_sn_list}!=@{EMPTY}
    ...  Fail  msg=LTE vDU not supported (${lte_vdu_connection})

vDU Wait Until Rannics Are Offline
    [Arguments]  ${rannics_sn_list}=@{EMPTY}  ${lte_rannics_sn_list}=@{EMPTY}  ${timeout}=600s
    ...  ${vdu_connection}=default  ${lte_vdu_connection}=default_lte
    [Documentation]
    ...  Description:
    ...  Keyword waits until RAN NICs given by serial numbers are off line.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rannics_sn_list        | Yes  | List of RAN NICs serial numbers if 5G vDU is used.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_rannics_sn_list    | Yes  | List of RAN NICs serial numbers if 4G vDU is used.                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Wait until all RAN NICs are on line.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  vDU All Rannics Should Be Offline
    ...  rannics_sn_list=${rannics_sn_list}
    ...  lte_rannics_sn_list=${lte_rannics_sn_list}
    ...  vdu_connection=${vdu_connection}
    ...  lte_vdu_connection=${lte_vdu_connection}

vDU Rannic Reset Operation Status Should Be
    [Arguments]  ${operation_id}  ${expected_status}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the rannic reset operation has a given expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of rannic reset.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of rannic reset operation.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${reset_operation}=  vdu.Get Rnic Reset Operation
    ...  operation_id=${operation_id}
    ...  vdu_connection=${vdu_connection}
    Should Be True  '${reset_operation['status']}'=='${expected_status}'

vDU Rannic Reset Wait For Expected Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=180s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for rannic reset operation status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of rannic reset.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of rannic reset operation.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of rannic reset operation.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  10s
    ...  vDU Rannic Reset Operation Status Should Be
    ...  operation_id=${operation_id}
    ...  expected_status=${expected_status}
    ...  vdu_connection=${vdu_connection}

#Pod operations
Check If Pod Name Exists
    [Arguments]  ${pod_name}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the pod name exists or not.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | pod_name               |  Yes | Name of the pod that exists or doesn't exist.                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pods_names_list}=  Create List
    ${pods_info}=  vdu.Get Pods Info  vdu_connection=${vdu_connection}
    FOR  ${pod_info}  IN  @{pods_info}
      Append To List  ${pods_names_list}  ${pod_info['name']}
    END
    ${pod_name_status}=  Run Keyword And Return Status
    ...  List Should Contain Value  ${pods_names_list}  ${pod_name}
    [Return]  ${pod_name_status}

vDU Get Matches Pod Name
    [Arguments]  ${pod_name_pattern}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword returns list of pod names consist given pattern.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | pod_name_pattern       | Yes  | Pattern name of the pod that exists or doesn't exist.                      |
    ...  |                        |      | Example: pod_name_pattern=po-oamfh-0, pod_name_pattern=regexp=.*oamfh-0    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${pod_names_list}=  Create List
    ${pods_info}=  vdu.Get Pods Info  vdu_connection=${vdu_connection}
    FOR  ${pod_info}  IN  @{pods_info}
      Append To List  ${pod_names_list}  ${pod_info['name']}
    END
    ${pod_names_list}=  Get Matches  list=${pod_names_list}  pattern=${pod_name_pattern}
    [Return]  ${pod_names_list}

#PM counters
vDU EE Pm Counters Existance Check
    [Arguments]  ${dist_name}  ${counters_list}  ${ref_time_stamp}  ${exist}=${TRUE}
    [Documentation]
    ...  Description:
    ...  Keyword that verifies if required counter exist or not depending on "exist" switch
    ...  under specific counter dist_name. Keyword passes or failes. Counter timestamp is compared with ref_timestamp
    ...  gathered from the point of parameter recommissioning (activating/deactivating measurements).
    ...  ref_time_stamp can be gathered using KW "Get VDU timestamp"
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dist_name              | Yes  | The dist name that the counter belongs to.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | counters_list          | Yes  | list of specific counters to check                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ref_time_stamp         | Yes  | ref_timestamp to compare with counter timestamp, YMDHMS format allowed     |
    ...  |                        |      | example: 2024-09-23T10:15:00 -> 20240923101500                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | exist                  | No   | TRUE - if counters should exist, FALSE - if counters should not exist      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    FOR  ${counter}  IN  @{counters_list}
      ${counter_content}=  vdu.Get Counter Values  counter_id=${counter}  dimension_dn=${dist_name}
      ${counter_status}  ${res}=  Run Keyword And Ignore Error  Fetch From Left  ${counter_content[-1]['start_time']}  +
      ${counter_timestamp}=  Run Keyword If  '${counter_status}'=='PASS'  Evaluate  $res.replace('-', '').replace('T', '').replace(':', '')
      ...  ELSE  Set Variable  ${0}
      ${counter_status}=  Set Variable If  ${counter_timestamp}>${ref_time_stamp}  PASS  FAIL
      Run Keyword If  ${exist} and '${counter_status}'=='FAIL'  Run Keywords
      ...  Run Keyword And Continue On Failure  Fail  Error - counter ${counter} under ${dist_name} doesn't exist
      ...  AND  Continue For Loop
      ...  ELSE IF  not ${exist} and '${counter_status}'=='PASS'  Run Keywords
      ...  Run Keyword And Continue On Failure  Fail  Error - counter ${counter} under ${dist_name} exists
      ...  AND  Continue For Loop
      ...  ELSE IF  not ${exist} and '${counter_status}'=='FAIL'  Continue For Loop
      ${counter_value}=  Set Variable  ${counter_content[-1]['value']}
      ${type_status}=  Run Keyword And Return Status  Evaluate  isinstance(${counter_value}, int)
      ${value_status}=  Evaluate  '${counter_value}'=='-' or ${type_status}
      Run Keyword If  not ${value_status}  Run Keyword And Continue On Failure
      ...  Fail  Error - counter ${counter}=${counter_value} under ${dist_name} has wrong value
    END

vDU EE Check Pm Counters
    [Arguments]  ${dist_name_list}  ${counters_list}  ${ref_time_stamp}  ${exist}=${TRUE}
    [Documentation]
    ...  Description:
    ...  Keyword that verifies if required counter exist or not depending on "exist" switch.
    ...  Keyword passes or failes. Counter timestamp is compared with vdu_timestamp
    ...  gathered from the point of parameter recommissioning (activating/deactivating measurements).
    ...  ref_time_stamp can be gathered using KW "Get VDU timestamp".
    ...  Keyword is able to check specified counters list for several distnames.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dist_name_list         | Yes  | The dist name list that the counter belongs to.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | counters_list          | Yes  | list of specific counters to check                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | ref_time_stamp         | Yes  | timestamp to compare with counter timestamp, YMDHMS format allowed         |
    ...  |                        |      | example: 2024-09-23T10:15:00 -> 20240923101500                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | exist                  | No   | TRUE - if counters should exist, FALSE - if counters should not exist      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    FOR  ${dist_name}  IN  @{dist_name_list}
      vDU EE Pm Counters Existance Check
      ...  dist_name=${dist_name}
      ...  counters_list=${counters_list}
      ...  ref_time_stamp=${ref_time_stamp}
      ...  exist=${exist}
    END
    [Teardown]  Run Keyword If  '${KEYWORD STATUS}'=='FAIL'  Fail  Counters check failed

Check If Counter Value Is In Range Or Zero
    [Arguments]  ${dist_name}  ${counter_id}  ${counter_value}  ${start_range}  ${end_range}
    ${range_result}=  Evaluate  expression=( ${start_range}<=${counter_value}<=${end_range} or ${counter_value}==0)
    Run Keyword If  '${range_result}'=='False'  Run Keyword And Continue On Failure
    ...  Fail  Counter ${counter_id}=${counter_value} (dist_name=${dist_name}) is not in range <${start_range}; ${end_range}> or is not 0 !

Check If Counter Value Is Natural Number
    [Arguments]  ${dist_name}  ${counter_id}  ${counter_value}
   ${value_result}=  Evaluate  expression=(0<=${counter_value}<=65535)
   Run Keyword If  '${value_result}'=='False'  Run Keyword And Continue On Failure
    ...  Fail  Counter ${counter_id}=${counter_value} (dist_name=${dist_name}) is not a natural number !

Get And Verify PIM Counters
  [Arguments]  ${dist_name}  ${counter_id}  ${counter_values_list}
      FOR  ${counter}  IN  @{counter_values_list}
        ${counter_value}=  Set Variable  ${counter['value']}
#        Log  Counter ${counter_id} (${dist_name}): ${counter_value}  console=True
        ${counter_id_status}=  Run Keyword And Return Status
        ...  Should Match Regexp  string=${counter_id}  pattern=M55303C2700\\d
        Run Keyword If  ${counter_id_status}
        ...  Check If Counter Value Is Natural Number  dist_name=${dist_name}  counter_id=${counter_id}
        ...  counter_value=${counter_value}
        ...  ELSE
        ...  Check If Counter Value Is In Range Or Zero  dist_name=${dist_name}  counter_id=${counter_id}
      ...  counter_value=${counter_value}  start_range=-180  end_range=-83.67
      END

Get And Verify PIM Counters And Return Length
  [Arguments]  ${dist_name}  ${counter_id_list}  ${verify_counters}=True
    ${counters_length}=  Set Variable  0
    FOR  ${counter_id}  IN  @{counter_id_list}
      ${counter_values_list}=  vdu.Get Counter Values  counter_id=${counter_id}  dimension_dn=${dist_name}
      Run Keyword If  ${counter_values_list}==@{EMPTY}  Run Keyword And Continue On Failure
      ...  Fail  Counters ${counter_id} (dist_name=${dist_name}) do not exist !
      Continue For Loop If  ${counter_values_list}==@{EMPTY}
      Run Keyword If  ${verify_counters}
      ...  Get And Verify PIM Counters  dist_name=${dist_name}  counter_id=${counter_id}  counter_values_list=${counter_values_list}
      ${counter_length}=  Get Length  item=${counter_values_list}
      ${counters_length}=   Evaluate  expression=${counters_length}+${counter_length}
    END
    [Return]  ${counters_length}

Get Counters And Return Length
  [Arguments]  ${dist_name}  ${counter_id}
    ${counter_values_list}=  vdu.Get Counter Values  counter_id=${counter_id}  dimension_dn=${dist_name}
    Run Keyword If  ${counter_values_list}==@{EMPTY}  Run Keyword And Continue On Failure
    ...  Fail  Counters ${counter_id} (dist_name=${dist_name}) do not exist !
    ${counters_length}=  Get Length  item=${counter_values_list}
    [Return]  ${counters_length}

Get Counter Start Time
    [Arguments]  ${counter_id}  ${dist_name}
    [Documentation]
    ...  Description:
    ...  Keyword returns the counter start time.
    ...  If there is no counter, keyword returns the value ${None}.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | counter_id             | Yes  | Counter id.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name              | Yes  | Configuration Distinguished Name (DN) of object                            |
    ...  |                        |      | that the counter belongs to.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${counter_values}=  vdu.Get Counter Values  counter_id=${counter_id}  dimension_dn=${distname}
    ${counters_result}=  Run Keyword And Return Status  Should Be Empty  item=${counter_values}
    ${counter_start_time}=  Set Variable If  ${counters_result}  ${None}  ${counter_values[-1]['start_time']}
    [Return]  ${counter_start_time}

Get Counter And Check If Collected
    [Arguments]  ${counter_id}  ${dist_name}  ${prev_counter_time}=${None}
    [Documentation]
    ...  Description:
    ...  Keyword checks if the counter was collected after a specified interval time
    ...  by comparing the actual start time with the previous start time and next
    ...  keyword returns the counter value and start time.
    ...  If the counter has not been collected, keyword returns the value ${None}.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | counter_id             | Yes  | Counter id.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name              | Yes  | Configuration Distinguished Name (DN) of object                            |
    ...  |                        |      | that the counter belongs to.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | prev_counter_time      | Yes  | Previous counter collection start time value.                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${diff_status_list}=  Create List
    ${counters_dict}=  Create Dictionary
    ${counter_values}=  vdu.Get Counter Values  counter_id=${counter_id}  dimension_dn=${dist_name}
    ${counter_is_empty}=  Run Keyword And Return Status  Should Be Empty  item=${counter_values}
    ${diff_time}=  Run Keyword If  ${counter_is_empty}
    ...  Set Variable  ${0}
    ...  ELSE IF  '${prev_counter_time}'!='${None}'
    ...  Subtract Date From Date  date1=${counter_values[-1]['start_time']}  date2=${prev_counter_time}
    ...  ELSE
    ...  Set Variable  ${1}
    Run Keyword And Continue On Failure
    ...  Should Not Be Equal As Numbers  first=${0}  second=${diff_time}
    ...  msg=Counter ${counter_id} was not collected, it should have been !  values=False
    ${diff_status}=  Run Keyword And Return Status
    ...  Should Not Be Equal As Numbers  first=${0}  second=${diff_time}
    ${counter_value}=  Set Variable If  ${diff_status}  ${counter_values[-1]['value']}  ${None}
    ${counter_start_time}=  Set Variable If  ${diff_status}  ${counter_values[-1]['start_time']}  ${None}
    [Return]  ${counter_value}  ${counter_start_time}

Counter Should Be Deactivated
    [Arguments]  ${counter_id}  ${dist_name}  ${prev_counter_time}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether counter collection is stopped after it has been disabled.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | counter_id             | Yes  | Counter id.                                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | dist_name              | Yes  | Configuration Distinguished Name (DN) of object                            |
    ...  |                        |      | that the counter belongs to.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | prev_counter_time      | Yes  | Previous counter collection start time value.                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${counter_values}=  vdu.Get Counter Values  counter_id=${counter_id}  dimension_dn=${dist_name}
    ${counter_start_time}=  Set Variable  ${counter_values[-1]['start_time']}
    ${time_diff}=  Subtract Date From Date  date1=${counter_start_time}  date2=${prev_counter_time}
    Run Keyword And Continue On Failure
    ...  Should Be Equal As Numbers  first=0  second=${time_diff}
    ...  msg=Counter ${counter_id} was collected, it shouldn't have been !  values=False

#CM operations
vDU Activate CLI Parameter Should Be Enabled
    [Arguments]   ${gnb_index}=0
    [Documentation]
    ...  Description:
    ...  Keyword checks online actCli parameter from the current plan.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${vdu_number}=  Get vDU Number From Init File  gnb_index=${gnb_index}
    FOR  ${vdu_index}  IN RANGE   ${vdu_number}
      ${actcli_value}=  vDU Get Online Activate CLI Parameter Value
      ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
      Run Keyword If  '${actcli_value}'=='False'
      ...  Log  Please set actCli parameter
    END

vDU Get Online Activate CLI Parameter Value
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${timeout}=60s
    [Documentation]
    ...  Description:
    ...  Keyword gets online Activate CLI parameter (actCli) from the current plan.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | gnb_index              |  No  | Index of gnb object list.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_index              |  No  | Index of DU (Distributed Unit) class instance objects list.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for this request.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${mrbts_id}=  Get vDU Instance Id From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    vDU Rest Login  vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${actcli_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${mo_dn}  para_name=actCli  timeout=${timeout}
    [Return]  ${actcli_value}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout

vDU Verify And Update Parameter Of Delta Plan
    [Arguments]  ${mo_dn}  ${updated_params_dict}
    [Documentation]
    ...  Description:
    ...  Keyword verifies that values of the vDU parameters to be changed are the same as the current parameters.
    ...  If at least one of the parameters is different, a vDU delta plan update is executed.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | mo_dn                  | Yes  | Managed object DN path that contains the updated parameters.               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | updated_params_dict    | Yes  | Dictionary with parameters to update.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${actual_params_dict}=  Create Dictionary
    ${updated_params_list}=  Get Dictionary Keys  dictionary=${updated_params_dict}
    FOR  ${updated_parameter}  IN  @{updated_params_list}
      ${parameter_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${mo_dn}  para_name=${updated_parameter}
      Set To Dictionary  ${actual_params_dict}  ${updated_parameter}=${parameter_value}
    END
    ${parameter_status}=  Run Keyword And Return Status
    ...  Dictionaries Should Be Equal  dict1=${updated_params_dict}  dict2=${actual_params_dict}
    Return From Keyword If  ${parameter_status}
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=${mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    vdu.Perform Delta Recommissioning  delta_file=${json_parameters_update[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}

vDU Rf Scan Test Operation Status Should Be
    [Arguments]  ${operation_id}  ${expected_status}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether RF scan test operation has a given expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | RF scan test operation id.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of RF scan test operation.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rf_scan_test_result}=  vdu.Get Rf Scan Test Operation Status  operation_id=${operation_id}
    Should Be True  '${rf_scan_test_result['status']}'=='${expected_status}'

vDU Rf Scan Test Wait For Expected Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s
    [Documentation]
    ...  Description:
    ...  Keyword waits for start RF scan test operation status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | RF scan test operation id.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of RF scan test operation.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of start RF scan test operation.          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  5s
    ...  vDU Rf Scan Test Operation Status Should Be
    ...  operation_id=${operation_id}  expected_status=${expected_status}

vDU Start RF Scan Test
    [Arguments]  ${rmod_dn}  ${capture_type}  ${antenna_dn}=${None}  ${antenna_carrier}=${None}
    ...  ${antenna_panel}=${None}  ${timeout}=60
    [Documentation]
    ...  Description:
    ...  Keyword starts RF scan test operation and waits for expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_dn                |  Yes | Radio module runtime managed object DN path.                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | capture_type           |  Yes | Capture type.                                                              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | antenna_dn             |  No  | Antenna runtime managed object DN path.                                    |
    ...  |                        |      | Will be received only if target radio is not an mMIMO and user doesn't     |
    ...  |                        |      | intend to perform test on "All ANTL".                                      |
    ...  |                        |      | Example: MRBTS-11111/EQM_R-1/APEQM_R-1/RMOD_R-1/ANTL_R-1                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | antenna_carrier        |  No  | Managed object DN path of cell.                                            |
    ...  |                        |      | Example: MRBTS-1/NRBTS-11077/NRCELL-1                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | antenna_panel          |  No  | Will be received only when the requested radio is an mMiMO                 |
    ...  |                        |      | one it's meaningful.                                                       |
    ...  |                        |      | One of [Full_Array, Top_Array, Bottom_Array, Left_Array, Right_Array,      |
    ...  |                        |      | All_Arrays ]                                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of start RF scan test operation.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${start_rf_scan_result}=  vdu.Start Rf Scan Test  ru_dn=${rmod_dn}  signal=${capture_type}  antenna=${antenna_dn}
    ...  antenna_carrier=${antenna_carrier}  antenna_panel=${antenna_panel}
    vDU Rf Scan Test Wait For Expected Status  operation_id=${start_rf_scan_result['operation_id']}
    ...  expected_status=success  timeout=${timeout}

vDU Cancel Rf Scan Test Operation Status Should Be
    [Arguments]  ${operation_id}  ${expected_status}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether cancel RF scan test operation has a given expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | Cancel RF scan test operation id.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of cancel RF scan test operation.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${rf_scan_cancellation_result}=  vdu.Get Rf Scan Test Cancellation Status  operation_id=${operation_id}
    Should Be True  '${rf_scan_cancellation_result['status']}'=='${expected_status}'

vDU Cancel Rf Scan Test Wait For Expected Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s
    [Documentation]
    ...  Description:
    ...  Keyword waits for cancel RF scan test operation status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | Cancel RF scan test operation id.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of cancel RF scan test operation.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of cancel RF scan test operation.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  5s
    ...  vDU Cancel Rf Scan Test Operation Status Should Be
    ...  operation_id=${operation_id}  expected_status=${expected_status}

vDU Cancel RF Scan Test
    [Arguments]  ${timeout}=60
    [Documentation]
    ...  Description:
    ...  Keyword cancels RF scan test operation and waits for expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | timeout                |  No  | Waiting time for expected status of cancel RF scan test operation.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cancel_rf_scan_result}=  vdu.Cancel Rf Scan Test Operation
    vDU Cancel Rf Scan Test Wait For Expected Status  operation_id=${cancel_rf_scan_result['operation_id']}
    ...  expected_status=success  timeout=${timeout}

#Test Models
vDU Enter Into TDS Mode
    [Arguments]  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword enters into Test Dedicated State Mode by parameter recommissioning.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${cmd_object}=  vdu.Get Current Plan Objects  class_name=CMD
    ${swreset_dist_name}=  Set Variable  ${cmd_object['objects'][0]['distName']}/SWRESETREQ-1
    ${dist_name_list}=  Create List  ${swreset_dist_name}
    ${current_plan}=  vdu.Get Current Plan Objects
    ...  dist_names=${dist_name_list}
    ...  vdu_connection=${vdu_connection}
    ${dist_name_exist_status}=  Run Keyword And Return Status
    ...  Should Not Be Empty  item=${current_plan['objects']}
    IF  ${dist_name_exist_status}
      ${parameters_list}=  Create List
      vdu.Perform Object Recommissioning
      ...  dist_name=${swreset_dist_name}
      ...  parameter=${parameters_list}
      ...  operation=delete
      ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
      ...  vdu_connection=${vdu_connection}
    END
    ${updated_params_dict}=  Create Dictionary  parameterName=swResetLevel
    ...  operation=update  value=resetToTestLevel
    ${parameters_list}=  Create List  ${updated_params_dict}
    vdu.Perform Object Recommissioning
    ...  dist_name=${swreset_dist_name}
    ...  parameter=${parameters_list}
    ...  operation=create
    ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    vDU Wait For Expected State
    ...  vdu_state=operational_state
    ...  vdu_state_value=test
    ...  timeout=15min
    ...  vdu_connection=${vdu_connection}

vDU Exit From TDS Mode
    [Arguments]  ${activation_timeout}=60s  ${cancellation_timeout}=30s  ${vdu_connection}=default
    ...  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword exit from Test Dedicated State Mode by vDU reset operation.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | activation_timeout     | Yes  | Wait until alarm 4592 is active.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cancellation_timeout   | Yes  | Wait until alarm 4592 is inactive.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Set log prefix to message or not.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    vDU Perform Reset And Alarm Check
    ...  activation_timeout=${activation_timeout}
    ...  cancellation_timeout=${cancellation_timeout}
    ...  vdu_connection=${vdu_connection}
    ...  log_prefix=${log_prefix}
    ...  log_to_console=${log_to_console}
# Check F1-C link status
    Log  ${log_prefix}Wait for F1-C link to activate...  console=${log_to_console}
    vDU Wait For Expected F1 Link Status
    ...  f1_link_status_value=available
    ...  timeout=600s
    ...  vdu_connection=${vdu_connection}
    Log  ${log_prefix}F1-C link is available  console=${log_to_console}
# Wait for expected vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=60s
    ...  vdu_connection=${vdu_connection}
    Log  ${log_prefix}vDU operational state is onAir  console=${log_to_console}

Start NR Downlink Test Model
    [Arguments]  ${nrcell_id}  ${test_model}  ${phys_cell_id}  ${nrarfcn_dl}
    ...  ${nrarfcn_ul}  ${pmax}  ${duration}=60s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword starts NR downlink test model.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | nrcell_id              | Yes  | NR cell id, e.g. 1.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | test_model             | Yes  | Test model name.                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | phys_cell_id           | Yes  | Physical cell ID.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrarfcn_dl             | Yes  | NR-ARFCN DL used in test.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrarfcn_ul             | Yes  | NR-ARFCN UL used in test.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | pmax                   | Yes  | Maximum output power of the cell per TX in test.                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | duration               |  No  | Test model duration.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

   ${beam_pattern_id}=  Create List  2  2  2  2
   vdu.Start 5g Downlink Test
    ...    nrcell_id=${nrcell_id}
    ...    test_model=${test_model}
    ...    beam_pattern_id=${beam_pattern_id}
    ...    polarization=P_both
    ...    power_backoff=0
    ...    ru_mode=NR_only
    ...    phys_cell_id=${phys_cell_id}
    ...    codebook_2_antports=0
    ...    i11_codebook_4_antports=0
    ...    i2_codebook_4_antports=0
    ...    i13_codebook_4_antports=0
    ...    mimo_rank=Rank1
    ...    nrarfcn=${nrarfcn_dl}
    ...    nrarfcn_dl=${nrarfcn_dl}
    ...    nrarfcn_ul=${nrarfcn_ul}
    ...    p_max=${pmax}
    ...    timeout=60
    ...    vdu_connection=${vdu_connection}
    Sleep  ${duration}

Start NR Uplink Test Model
    [Arguments]  ${nrcell_id}  ${frc_index}  ${phys_cell_id}  ${nrarfcn_dl}
    ...  ${nrarfcn_ul}  ${duration}=60s  ${get_results}=${True}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword starts uplink test model.
    ...  Optionally keyword gets uplink test model results.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | nrcell_id              | Yes  | NR cell id, e.g. 1.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | frc_index              | Yes  | Specifies FRC index.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | phys_cell_id           | Yes  | Physical cell ID.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrarfcn_dl             | Yes  | NR-ARFCN DL used in test.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrarfcn_ul             | Yes  | NR-ARFCN UL used in test.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | duration               |  No  | Test model duration.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_results            |  No  | Get NR PUCCH test model results or not.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

   ${beam_pattern_id}=  Create List  2  2  2  2
    vdu.start_5g_uplink_test
    ...  nrcell_id=${nrcell_id}
    ...  frc_index=${frc_index}
    ...  beam_pattern_id=${beam_pattern_id}
    ...  interval=1
    ...  prb_offset=0
    ...  ru_mode=NR_only
    ...  phys_cell_id=${phys_cell_id}
    ...  nrarfcn=${nrarfcn_dl}
    ...  nrarfcn_dl=${nrarfcn_dl}
    ...  nrarfcn_ul=${nrarfcn_ul}
    ...  vdu_connection=${vdu_connection}
    Sleep  ${duration}
    ${test_results}=  Run Keyword If  ${get_results}
    ...  vdu.Get 5g Uplink Test Results
    ...  nrcell_id=${nrcell_id}
    ...  vdu_connection=${vdu_connection}

Start NR Performance PUSCH Test Model
    [Arguments]  ${nrcell_id}  ${frc_index}  ${phys_cell_id}  ${nrarfcn_dl}
    ...  ${nrarfcn_ul}  ${duration}=60s  ${get_results}=${True}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword starts NR PUSCH Performance CCM test model.
    ...  Optionally keyword gets NR PUSCH test model results.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | nrcell_id              | Yes  | NR cell id, e.g. 1.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | frc_index              | Yes  | Specifies FRC index.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | phys_cell_id           | Yes  | Physical cell ID.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrarfcn_dl             | Yes  | NR-ARFCN DL used in test.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrarfcn_ul             | Yes  | NR-ARFCN UL used in test.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | duration               |  No  | Test model duration.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_results            |  No  | Get NR PUSCH test model results or not.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

   ${beam_pattern_id}=  Create List  0  0  0  0
    vdu.Start 5g Uplink Ccm Test Pusch
    ...  nrcell_id=${nrcell_id}
    ...  interval=1
    ...  beam_pattern_id=${beam_pattern_id}
    ...  frc_index=${frc_index}
    ...  prb_offset=0
    ...  digital_out_type=SerialRs
    ...  digital_out_rate=Bitrate_115dot2K
    ...  ru_mode=NR_only
    ...  phys_cell_id=${phys_cell_id}
    ...  ul_dmrs_mapping_type=A
    ...  bb_selector=0
    ...  nrarfcn=${nrarfcn_dl}
    ...  nrarfcn_dl=${nrarfcn_dl}
    ...  nrarfcn_ul=${nrarfcn_ul}
    ...  digital_output_enable=True
    ...  act_high_speed_cell=False
    ...  vdu_connection=${vdu_connection}
    Sleep  ${duration}
    ${test_results}=  Run Keyword If  ${get_results}
    ...  vdu.Get 5g Pusch Test Results
    ...  nrcell_id=${nrcell_id}
    ...  vdu_connection=${vdu_connection}

Start NR Performance PUCCH Test Model
    [Arguments]  ${nrcell_id}  ${pucch_format}  ${phys_cell_id}  ${nrarfcn_dl}
    ...  ${nrarfcn_ul}  ${num_pucch_symbol}  ${largest_prb_index}  ${duration}=60s
    ...  ${get_results}=${True}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword starts NR PUCCH Performance CCM test model.
    ...  Optionally keyword gets NR PUCCH test model results.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | nrcell_id              | Yes  | NR cell id, e.g. 1.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | pucch_format           | Yes  | Specifies PUCCH format.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | phys_cell_id           | Yes  | Physical cell ID.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrarfcn_dl             | Yes  | NR-ARFCN DL used in test.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrarfcn_ul             | Yes  | NR-ARFCN UL used in test.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | num_pucch_symbol       | Yes  | Specifies number of PUCCH sybmols used in test.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | largest_prb_index      | Yes  | The largest PRB index used in test.                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | duration               |  No  | Test model duration.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_results            |  No  | Get NR PUCCH test model results or not.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

   ${beam_pattern_id}=  Create List  0  0  0  0
    vdu.Start 5g Uplink Ccm Test Pucch
    ...  nrcell_id=${nrcell_id}
    ...  interval=1
    ...  beam_pattern_id=${beam_pattern_id}
    ...  receiving_slot=1023
    ...  expectation_slot=1023
    ...  pucch_format=${pucch_format}
    ...  ru_mode=NR_only
    ...  phys_cell_id=${phys_cell_id}
    ...  format3_additional_dmrs=Disabled
    ...  prb_offset=0
    ...  largest_prb_index=${largest_prb_index}
    ...  num_pucch_symbol=${num_pucch_symbol}
    ...  num_payload_bit=2
    ...  pucch_payload_content=0
    ...  nrarfcn=${nrarfcn_dl}
    ...  nrarfcn_dl=${nrarfcn_dl}
    ...  nrarfcn_ul=${nrarfcn_ul}
    ...  vdu_connection=${vdu_connection}
    Sleep  ${duration}
    ${test_results}=  Run Keyword If  ${get_results}
    ...  vdu.Get 5g Pucch Test Results
    ...  nrcell_id=${nrcell_id}
    ...  vdu_connection=${vdu_connection}

Start NR Performance PRACH Test Model
    [Arguments]  ${nrcell_id}  ${prach_conf_index}  ${phys_cell_id}  ${nrarfcn_dl}
    ...  ${nrarfcn_ul}  ${duration}=60s  ${get_results}=${True}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword starts NR PRACH Performance CCM test model.
    ...  Optionally keyword gets NR PRACH test model results.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | nrcell_id              | Yes  | NR cell id, e.g. 1.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | prach_conf_index       | Yes  | Specifies PRACH configuration index.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | phys_cell_id           | Yes  | Physical cell ID.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrarfcn_dl             | Yes  | NR-ARFCN DL used in test.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrarfcn_ul             | Yes  | NR-ARFCN UL used in test.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | duration               |  No  | Test model duration.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_results            |  No  | Get NR PRACH test model results or not.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${beam_pattern_id}=  Create List  2  2  2  2
    ${zero_correlation_zone_config}=  Set Variable  ${14}
    vdu.start_5g_uplink_ccm_test_prach
    ...  nrcell_id=${nrcell_id}
    ...  interval=1
    ...  beam_pattern_id=${beam_pattern_id}
    ...  receiving_slot=1023
    ...  expectation_slot=1023
    ...  preamble_index=0
    ...  accepted_timing_error=260
    ...  constant_offset=0
    ...  delay_pattern_single_step_duration=0
    ...  ru_mode=NR_only
    ...  phys_cell_id=${phys_cell_id}
    ...  prach_configuration_index=${prach_conf_index}
    ...  pfa_target_prach_id=P_None
    ...  prach_root_sequence_index=0
    ...  nrarfcn=${nrarfcn_dl}
    ...  nrarfcn_dl=${nrarfcn_dl}
    ...  nrarfcn_ul=${nrarfcn_ul}
    ...  zero_correlation_zone_config=${zero_correlation_zone_config}
    ...  prach_sequence_type=Unrestricted
    ...  vdu_connection=${vdu_connection}
    Sleep  ${duration}
    ${test_results}=  Run Keyword If  ${get_results}
    ...  vdu.Get 5g Prach Test Results
    ...  nrcell_id=${nrcell_id}
    ...  vdu_connection=${vdu_connection}

Stop NR Test Model
    [Arguments]  ${test_model_type}  ${nrcell_id}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword stops NR test model.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | test_model_type        | Yes  | Type test model. One of 'Downlink', 'Uplink', 'Performance'.               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | nrcell_id              | Yes  | NR cell id, e.g. 1.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  '${test_model_type}'=='Downlink'
    ...  vdu.Stop 5g Downlink Test
    ...  nrcell_id=${nrcell_id}
    ...  vdu_connection=${vdu_connection}
    ...  ELSE IF  '${test_model_type}'=='Uplink'
    ...  vdu.Stop 5g Uplink Test
    ...  nrcell_id=${nrcell_id}
    ...  vdu_connection=${vdu_connection}
    ...  ELSE IF  '${test_model_type}'=='Performance'
    ...  vdu.Stop 5g Uplink Ccm Test
    ...  nrcell_id=${nrcell_id}
    ...  vdu_connection=${vdu_connection}

# TRS API Operations
TRS API Operations Status Should Be
    [Arguments]  ${operation_id}  ${expected_status}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the TRS API operations has an expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of TRS API operations.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of TRS API operations.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${operation_result}=  vdu.Get Trs Api Operation Status
    ...  operation_id=${operation_id}
    ...  vdu_connection=${vdu_connection}
    Should Be True  '${operation_result['status']}'=='${expected_status}'

TRS API Operations Wait For Expected Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s  ${time_interval}=5s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for TRS API operations status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of TRS API operations.                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of TRS API operations.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of TRS API operations.                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  TRS API Operations Status Should Be
    ...  operation_id=${operation_id}
    ...  expected_status=${expected_status}
    ...  vdu_connection=${vdu_connection}

# Service Account Management
Operation Of Serviceuser Synchronization Status Should Be
    [Arguments]  ${operation_id}  ${expected_status}  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the operation of Serviceuser synchronization has an expected status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of Serviceuser synchronization.                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of Serviceuser synchronization.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${operation_result}=  vdu.Get Operation Of Serviceuser Sync Status
    ...  operation_id=${operation_id}
    ...  vdu_connection=${vdu_connection}
    Should Be True  '${operation_result['status']}'=='${expected_status}'

Operation Of Serviceuser Synchronization Wait For Expected Status
    [Arguments]  ${operation_id}  ${expected_status}  ${timeout}=60s  ${time_interval}=5s  ${vdu_connection}=default
    [Documentation]
    ...  Description:
    ...  Keyword waits for operation of Serviceuser synchronization status.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | operation_id           | Yes  | The operation id of operation of Serviceuser synchronization.              |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_status        | Yes  | The expected status of operation of Serviceuser synchronization.           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Waiting time for expected status of operation of Serviceuser sync.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | time_interval          |  No  | Time interval for status query.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Wait Until Keyword Succeeds  ${timeout}  ${time_interval}
    ...  Operation Of Serviceuser Synchronization Status Should Be
    ...  operation_id=${operation_id}
    ...  expected_status=${expected_status}
    ...  vdu_connection=${vdu_connection}

#NOT USED
vDU Pm Counters Should Exist
    [Arguments]  ${dist_name}
    [Documentation]
    ...  Description:
    ...  Keyword
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dist_name              | Yes  | Distinguished Name (DN) that the counter belongs to.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${res}=  vdu.Get Counter Values  counter_id=M55318C00001  dimension_dn=${dist_name}
    ${M55318C00001}=  Set Variable  ${res[-1]['value']}
    ${is_int1}=  Evaluate  isinstance(${M55318C00001}, int)
    ${res}=  vdu.Get Counter Values  counter_id=M55318C00003  dimension_dn=${dist_name}
    ${M55318C00003}=  Set Variable  ${res[-1]['value']}
    ${is_int2}=  Evaluate  isinstance(${M55318C00003}, int)
    ${res}=  vdu.Get Counter Values  counter_id=M55318C00005  dimension_dn=${dist_name}
    ${M55318C00005}=  Set Variable  ${res[-1]['value']}
    ${is_int3}=  Evaluate  isinstance(${M55318C00005}, int)
    ${res}=  vdu.Get Counter Values  counter_id=M55318C00007  dimension_dn=${dist_name}
    ${M55318C00007}=  Set Variable  ${res[-1]['value']}
    ${is_int4}=  Evaluate  isinstance(${M55318C00007}, int)
    ${res}=  vdu.Get Counter Values  counter_id=M55318C00009  dimension_dn=${dist_name}
    ${M55318C00009}=  Set Variable  ${res[-1]['value']}
    ${is_int5}=  Evaluate  isinstance(${M55318C00009}, int)
    @{list} =   Create List  ${is_int1}  ${is_int2}  ${is_int3}  ${is_int4}  ${is_int5}
    List Should Not Contain Value  ${list}  False

vDU Check Pm Counters
    [Arguments]  ${dist_name_list}
    [Documentation]
    ...  Description:
    ...  Keyword
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dist_name_list         | Yes  | The dist name list that the counter belongs to.                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    FOR  ${dist_name}  IN  @{dist_name_list}
      vDU Pm Counters Should Exist  dist_name=${dist_name}
    END
