*** Settings ***
Documentation
...    common keyword for cloud vdu operations
Library           taf.gnb.oam.coam.cu    WITH NAME    cu
Library           taf.gnb.oam.coam.vdu                                    WITH NAME   vdu
Library           taf.rfrl.cbts.utilities.generic_utils
Library           taf.rfrl.cbts.connections.rest_conn_vdu.GenericVDU    WITH NAME    vdu_gen
Library           taf.rfrl.cbts.connections.ssh_connections.SSHConnExec   WITH NAME   ssh_conn
Library           taf.rfrl.cbts.utilities.tl_config   WITH NAME  tl_config
Library           taf.rfrl.cbts.devices.vdu.business.vdu_ope_business    WITH NAME   vdu_ope_business
Library           taf.rfrl.cbts.devices.vdu.base.vdu_cm_base.vDUCM        WITH NAME   vdu_cm_base
Library           taf.rfrl.cbts.devices.vdu.business.vdu_cm_business        WITH NAME   vdu_cm_business
Library           taf.rfrl.cbts.devices.vdu.base.vdu_ope_base.vDUOPE      WITH NAME   vdu_ope_base
Library           taf.rfrl.cbts.devices.vdu.base.vdu_cli_base.VDUCli      WITH NAME   vdu_cli_base
Library           taf.rfrl.cbts.parsers.parsers  WITH NAME   parser
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/cloud_analysis.py
Resource          taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Resource          taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource          taf/rfrl/cbts/robot/vdu/vdu_log.robot
Resource          taf/rfrl/cbts/robot/vcu/vcu_log.robot
Resource          taf/rfrl/cbts/robot/ru/ru_operations.robot
Resource          taf/rfrl/cbts/robot/vcu/vcu_fm.robot
Resource          taf/rfrl/cbts/robot/vdu/vdu_fm.robot

*** Keywords ***
Cloud Reset vDU and Check Cell On Air
    [Arguments]    ${need_check_on_air}=${True}    ${vdu_index}=${0}    ${gnb_index}=0
    [Documentation]    *****************
    ...    This keyword is designed to perform vDU reset and check cell status after resetting.
    ...    - [Keyword Details]
    ...    It firstly login vDU via rest API, the do vDU reset and check the status is ongoing.
    ...    It also check all the cells' status shall be on restore to on air after resetting.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | need_check_on_air | No | check on air or not. Default is True. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | gnb_index | No | The gnb index. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${out}    vdu.reset_vdu    vdu_connection=${conn_alias}
    ${status}    set variable  ${out["status"]}
    should contain    ${status}    ongoing
    # no "error_message" any more and check status in out instead of get_reset_vdu_operation_status
    # ${error_msg}    set variable  ${out["error_message"]}
    # should contain    ${error_msg}    No error
    # Wait Until Keyword Succeeds    60s   10s   Cloud Check Reset vDU Status Should Be Expected    operation_id=${out["id"]}
    # ...    expected_status=ongoing    vdu_connection=${conn_alias}
    sleep    60s
    Run Keyword If   ${need_check_on_air}   Wait Until Keyword Succeeds  20min   30s
    ...    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud vDU Reset With Duration Check
    [Arguments]  ${vdu_index}=0    ${gnb_index}=0    ${user_unexpected_alarms}=@{EMPTY}
    [Documentation]    *****************
    ...    This keyword is designed to check duration and alarms after performming vDU reset.
    ...    - [Keyword Details]
    ...    It firstly login vDU via rest API, the do vDU reset. After reset, it will check the duration and alarms.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vdu index. Default is 0. |
    ...    | gnb_index | No | The gnb index. Default is 0. |
    ...    | user_unexpected_alarms | No | user defined unexpected alarms, default is empty |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 17.06.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${start_time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d_%H-%M-%S
    Log To Console    \n vDU Reset in progress start at: ${start_time_stamp}
    ${out}    vdu.reset_vdu    vdu_connection=${conn_alias}
    # no "error_message" in reset_vdu any more
    # ${error_msg}    set variable  ${out["error_message"]}
    # should contain    ${error_msg}    No error
    #vDU reset in progress, to avoid flood prints of waiting for cell onair
    Sleep    4min
    Wait Until Keyword Succeeds  10min   5s
    ...    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${end_time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y-%m-%d_%H-%M-%S
    vdu_fm.Checking No unexpected Active Alarms Raised    user_unexpected_alarms=${user_unexpected_alarms}
    vcu_fm.Checking No unexpected Active Alarms Raised    user_unexpected_alarms=${user_unexpected_alarms}
    Log To Console    \n vDU Reset completed at: ${end_time_stamp}
    ${duration}=    Subtract Date from Date    ${end_time_stamp}    ${start_time_stamp}
    Set Test Variable    ${duration}
    Log To Console    \n vDU Reset duration: ${duration}s
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Check Reset vDU Status Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}     ${vdu_connection}=default
    [Documentation]    *****************
    ...    This keyword is designed to check vDU operation status after reset vdu executed.
    ...    - [Keyword Details]
    ...    after reset vdu executed, it returns the operation status, e.g. ongoing.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | operation_id | Yes | id inherits from previous operation. |
    ...    | expected_status | Yes | The expected staus, e.g. ongoing. |
    ...    | timeout | No | The gnb index. Default is 60. |
    ...    | vdu_connection | No | The gnb index. Default is 'default'. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${out}    vdu.get_reset_vdu_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

Cloud Lock RUs On Specific vDU
    [Arguments]    ${rmod_id_list}    ${vdu_index}=0    ${gnb_index}=0    ${timeout}=${60}
    [Documentation]    *****************
    ...    This keyword is designed to perform RU locks under specific vDU.
    ...    - [Keyword Details]
    ...    It firstly login vDU via rest API, the do RU locks with given RU list.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | rmod_id_list | Yes | rmod to be locked. |
    ...    | vdu_index | No | The vdu index. Default is 0. |
    ...    | gnb_index | No | The gnb index. Default is 0. |
    ...    | timeout | No | timeout. Default is 60. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${out}    vdu.lock_rmods    rmod_id_list=${rmod_id_list}    timeout=${timeout}    vdu_connection=${conn_alias}
    Should Be True    "${out["status"]}"=="ongoing"
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Unlock RUs On Specific vDU
    [Arguments]    ${rmod_id_list}    ${vdu_index}=0    ${gnb_index}=0    ${timeout}=${60}
    [Documentation]    *****************
    ...    This keyword is designed to perform RU unlocks under specific vDU.
    ...    - [Keyword Details]
    ...    It firstly login vDU via rest API, the do RU unlocks with given RU list.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | rmod_id_list | Yes | rmod to be unlocked. |
    ...    | vdu_index | No | The vdu index. Default is 0. |
    ...    | gnb_index | No | The gnb index. Default is 0. |
    ...    | timeout | No | timeout. Default is 60. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* xuewen.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_05
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${out}    vdu.unlock_rmods    rmod_id_list=${rmod_id_list}    timeout=${timeout}    vdu_connection=${conn_alias}
    Should Be True    "${out["status"]}"=="ongoing"

Cloud Get Cells Id List
    [Documentation]    *****************
    ...    This keyword is used to get the cells ID list.
    ...    - [Keyword Details]
    ...    This keyword accepts the cell ID, vDU index, and gNB index as arguments.
    ...    It then generates a unique string and uses it to connect to the vDU.
    ...    If the cell ID is set to 'all', it retrieves the list of all cell IDs from the vDU.
    ...    Otherwise, it creates a list with the provided cell ID.
    ...    After the operation, it logs out from the vDU.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_id | No | The cell ID. Default is all. |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | cell_list | The cells ID list. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]  ${cell_id}=all    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${cell_list}    run keyword if    '${cell_id}'=='all'    vdu_ope_base.get_cells_id_list_from_vdu_webem    conn_alias=${conn_alias}
    ...    ELSE    create list    ${cell_id}
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}
    [Return]    ${cell_list}

Cloud Check vDU Status Should Be Expected
    [Documentation]    *****************
    ...    This keyword is designed to check if the operational state of the vDU matches the expected status.
    ...    - [Keyword Details]
    ...    This keyword accepts the vDU index, gNB index, and expected status as arguments.
    ...    It then generates a unique string and uses it to login to the vDU.
    ...    It retrieves the operational state of the vDU and checks if it matches the expected status.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | expected_status | Yes | The expected operational state of the vDU. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]   ${vdu_index}=0    ${gnb_index}=0    ${expected_status}=test
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${vdu_state_data}=   vdu.get_vdu_state_data    vdu_connection=${conn_alias}
    should be true   "${vdu_state_data['operational_state']}"=="${expected_status}"
    [Teardown]  vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Delete Delta Plan MO DN
    [Documentation]    *****************
    ...    This keyword is used to delete the MO by Delta Plan in the Cloud.
    ...    - [Keyword Details]
    ...    This keyword accepts the Delta Plan ID, MO DN, timeout, vDU index, and gNB index as arguments.
    ...    It then generates a unique string and uses it to login to the vDU.
    ...    It deletes the MO of the Delta Plan and retrieves the action ID.
    ...    It then checks if the deletion status matches the expected status.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | plan_id | Yes | The Delta Plan ID. |
    ...    | mo_dn | Yes | The MO DN. |
    ...    | timeout | No | The timeout value. Default is 60s. |
    ...    | vdu_index | No | vdu index in testline configuration file. Default is 0. |
    ...    | gnb_index | No | gnb index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]  ${plan_id}   ${mo_dn}    ${timeout}=${60}    ${vdu_index}=${0}    ${gnb_index}=${0}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${out}    vdu.delete_mo_of_delta_plan    delta_plan_id=${plan_id}    mo_dn=${mo_dn}    timeout=${timeout}    vdu_connection=${conn_alias}
    ${action_id}  set variable  ${out["action_id"]}
    Wait Until Keyword Succeeds    20    2    Cloud Delete Delta Plan MO DN Should Be Expected
    ...   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Delete Delta Plan MO DN Should Be Expected
    [Documentation]    *****************
    ...    This keyword is used to check the status of deleting MO by Delta Plan is expected or not.
    ...    - [Keyword Details]
    ...    This keyword accepts the Delta Plan ID, Action ID, expected status, vDU index, and gNB index as arguments.
    ...    It then generates a unique string and uses it to login to the vDU.
    ...    It retrieves the status of deleting MO by Delta Plan.
    ...    It then checks if the retrieved status matches the expected status.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | plan_id          | Yes | The Delta Plan ID. |
    ...    | action_id        | Yes | The Action ID. |
    ...    | expected_status  | Yes | The expected status. |
    ...    | vdu_index        | No  | vdu index in testline configuration file. Default is 0. |
    ...    | gnb_index        | No  | gnb index in testline configuration file. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 15.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}    ${vdu_index}=${0}    ${gnb_index}=${0}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${out}   vdu.get_deleting_mo_action_state_of_delta_plan    delta_plan_id=${plan_id}  action_id=${action_id}    vdu_connection=${conn_alias}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Verify All Cells Are Disabled for vDU
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]
    ...    This keyword is to check cell status disabled on vDU.
    ...    - [Keyowrd Details]
    ...    This keyword is to check cell status disabled on vDU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    log to console     Verify All Cells Are Disabled for vDU
    ${cells_id_list}    vdu_operations.vDU Get Cell List From Webem    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    vDU Cells Status Should Be As Expected    cells_id_list=${cells_id_list}   gnb_index=${gnb_index}
    ...   vdu_index=${vdu_index}   administrative_state=Unlocked    operational_state=disabled    availability_status=failed

Block Cell In vDU
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${cell_id}=1
    [Documentation]
    ...    This keyword is to check cell status disabled on vDU.
    ...    - [Keyowrd Details]
    ...    This keyword is to check cell status disabled on vDU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | cell_id | No | The cell id index. Default value is 1. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    log to console     Block Cell In vDU ${gnb_index}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}    alias=${conn_alias}
    ${cell_id}    convert to string     ${cell_id}
    ${out}    vdu.block_cell    cell_id=${cell_id}    vdu_connection=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Unblock Cell In vDU
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${cell_id}=1
    [Documentation]
    ...    This keyword is to check cell status disabled on vDU.
    ...    - [Keyowrd Details]
    ...    This keyword is to check cell status disabled on vDU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | cell_id | No | The cell id index. Default value is 1. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    log to console    Unblock Cell In vDU
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}    alias=${conn_alias}
    ${cell_id}    convert to string     ${cell_id}
    ${out}    vdu.unblock_cell    cell_id=${cell_id}    vdu_connection=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Check Cell Should Be Blocked On vDU
    [Arguments]  ${vdu_index}=0    ${gnb_index}=0    ${cell_id}=${1}
    [Documentation]
    ...    This keyword is to check cell status disabled on vDU.
    ...    - [Keyowrd Details]
    ...    This keyword is to check cell status disabled on vDU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | cell_id | No | The cell id index. Default value is 1. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    log to console    Check Cell Should Be Blocked On vDU
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}    alias=${conn_alias}
    ${cells_status}    vdu.get_vdu_cells_status    vdu_connection=${conn_alias}
    FOR  ${cell}  IN  @{cells_status}
        Run keyword if    '${cell_id}'!='${cell}[id]'    Continue For Loop
        Should Be Equal As Strings  ${cell["operational_state"]}    disabled
        Should Be Equal As Strings  ${cell["availability_status"]}    off line
        Should Be Equal As Strings  ${cell["administrative_state"]}    Unlocked
        Should Be Equal As Strings  ${cell["blocking_state"]}    Blocked
        Should Be Equal As Strings  ${cell["procedural_status"]}    configured
    END
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Expect Fault Should Present On vDU
    [Arguments]    ${fault_id}    ${alarming_object}=${None}    ${severity}=${None}    ${alarm_id}=${None}
    ...            ${vdu_index}=0    ${gnb_index}=0
    [Documentation]
    ...    This keyword is to check expect alarm on vDU.
    ...    - [Keyowrd Details]
    ...    This keyword is to check expect alarm on vDU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | fault_id | Mandatory | The fault id index. No detault value. |
    ...    | alarming_object | No | The alarming context. Default value is None. |
    ...    | severity | No | The alarm severity. Default value is None. |
    ...    | alarm_id | No | The alarming id. Default value is None. |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    log to console   Check Fault 49
    ${fault_id}    Convert To Integer    ${fault_id}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}    alias=${conn_alias}
    ${alarms}    vdu.vdu_get_active_alarms    vdu_connection=${conn_alias}
    ${alarm_num}    Get From Dictionary    ${alarms}    total
    Run Keyword If    ${alarm_num}==0    Fail
    ${alarms}    Get From Dictionary    ${alarms}    alarms
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...    Dictionary Should Contain Item    ${alarm}    fault_id    ${fault_id}    AND
        ...    Run Keyword If    '${alarming_object}'!='${None}'
        ...    Should Contain     ${alarm['alarming_object']}    ${alarming_object}    case_insensitive=True    AND
        ...    Run Keyword If    '${severity}'!='${None}'
        ...    Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
        ...    Run Keyword If    '${alarmId}'!='${None}'
        ...    Should Be Equal As Strings    ${alarm['alarm_id']}    ${alarm_id}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Lock Cell on vDU
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${cell_id}=1
    [Documentation]
    ...    This keyword is to lock cells on vDU.
    ...    - [Keyowrd Details]
    ...    This keyword is to lock cells on vDU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | cell_id | No | The cell id index. Default value is 1. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 3.06.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}    alias=${conn_alias}
    vdu.lock_cells    cell_id_list=${cell_id}    vdu_connection=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Unlock Cell on vDU
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${cell_id}=1
    [Documentation]
    ...    This keyword is to unlock cells on vDU.
    ...    - [Keyowrd Details]
    ...    This keyword is to unlock cells on vDU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | cell_id | No | The cell id index. Default value is 1. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 3.06.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}    alias=${conn_alias}
    vdu.unlock_cells    cell_id_list=${cell_id}    vdu_connection=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Deletion Cell on vDU
    [Documentation]
    ...    This keyword is to do cell deletion vDU.
    ...    - [Keyowrd Details]
    ...    This keyword is to do cell deletion vDU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | du_deletion_scf | Yes | The cell deletion delta scf and need to prepare by test owner. No default. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | vdu_index | No | The vdu index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 11.06.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    [Arguments]   ${du_deletion_scf}    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    vdu_cm_business.fast_delta_commission_with_delta_xml_file    xml_file_path=${du_deletion_scf}    conn_alias=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Addition Cell on vDU
    [Documentation]
    ...    This keyword is to do cell addition vDU.
    ...    - [Keyowrd Details]
    ...    This keyword is to do cell addition vDU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | du_addition_scf | Yes | The cell addition delta scf and need to prepare by test owner. No default. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | vdu_index | No | The vdu index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 11.06.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    [Arguments]   ${du_addition_scf}    ${vdu_index}=0    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    vdu_cm_business.fast_delta_commission_with_delta_xml_file    xml_file_path=${du_addition_scf}    conn_alias=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud vDu Delete Cell By Cell Index
    [Arguments]  ${deleted_cell_index}=1   ${gnb_index}=0  ${vdu_index}=0   ${nrdu}=1
    [Documentation]    Cloud Vdu Delete Cell By Cell Index
    ...
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | deleted_cell_index | yes | the cell index of deleted
    ...    | vdu_index | No | the index of vdu, default value is 0 |
    ...    | gnb_index | No | the index of gnb, default value is 0 |
    ...    | nrdu | Yes | nrduid
    ...
    ...    *Return*
    ...    the information of deleted cell, type is dictionary, e.g,
    ...     {'cell_id': '2',
    ...      'channel_group_info': [['1', '2', '3', '4', '5', '6', '7', '8']],
    ...       'lcrId': '2',
    ...       'nrarfcn': '638000',
    ...       'nrcellgrpId': '2',
    ...       'nrdu': '1',
    ...       'physCellId': '313',
#    ...       'rmod_id': '2'
    ...     }
    ...
    ...   *Example*
    ...  | ${deleted_cell_info} | Cloud vDu Delete Cell By Cell Index | deleted_cell_index=1 | nrdu=1
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 07.06.2024 - - Created
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    Log To Console    \n****Start Cloud vDu Delete Cell By Cell Index
    ${conn_alias}   generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}

    Log To Console    \n****vDU Save current vDU scfc  file
    ${vdu_scfc_path}  Get Cloud vDU SCF From Current Plan    gnb_index=${gnb_index}  vdu_index=${vdu_index}    alias=${conn_alias}
    Log To Console  vdu_scfc_path=${vdu_scfc_path}

    Log To Console    \n****vDU Create vDU delta plan
    ${uni_id}   generic_utils.get_unique_id_string
    Check Cloud vDU Max Delta Plan Number And Delete One If Reach Max Number   alias=${conn_alias}
    ${plan_id}   ${action_id}    Cloud vDU Generate Delta Plan   plan_name=delete_cell_${uni_id}   alias=${conn_alias}

    Log To Console    \n****vDU get delete cell info
    ${nrcell_id_list}   Cloud Get Cells Id List   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    Log To Console    \n****vDU NRCELL_id_list=${nrcell_id_list}
    ${LCELNR_id_list}   Get Cloud LCELNR ID From vDU SCF File  scf_path=${vdu_scfc_path}
    Log To Console    \n****vDU LCELNR_id_list=${LCELNR_id_list}
    ${NRCELLGRP_id_list}   Get Cloud NRCELLGRP ID list From vDU SCF File   scf_path=${vdu_scfc_path}
    Log To Console    \n****vDU NRCELLGRP_id_list=${NRCELLGRP_id_list}

    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get Cloud BTS ID From vDU SCF    scf_path=${vdu_scfc_path}
    ${grp_id}    ${refgrp_id_index}    Get Cloud vDU Cell Group ID by Cell ID    cell_index=${deleted_cell_index}   mbts_id=${mrbts_id}
    ...    nrbts_id=${nrbts_id}    nrdu=${nrdu}   alias=${conn_alias}

    ${del_cell_value}=    Convert To String    ${deleted_cell_index}
    ${cell_index}=    Get Index From List    ${nrcell_id_list}    ${del_cell_value}
    ${to_be_deleted_NRCELL_id}  Set Variable  ${NRCELL_id_list[${cell_index}]}
    ${to_be_deleted_LCELNR_id}  Set Variable  ${LCELNR_id_list[${cell_index}]}
    ${to_be_deleted_NRCELLGRP_id}  Set Variable  ${grp_id}

    ${NRCELL_dn}  Set Variable  MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${to_be_deleted_NRCELL_id}
    ${LCELNR_dn}  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${to_be_deleted_LCELNR_id}
    ${NRCELLGRP_dn}  Set Variable  MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-${to_be_deleted_NRCELLGRP_id}
    ${NRDU_dn}   Set Variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-${nrdu}

    Log To Console    \n****vDU Save cell value before delete it
    ${lcrId}     Get Cloud VDU Parameter Value Online    mo_dn=${NRCELL_dn}    para_name=lcrId   alias=${conn_alias}
    ${physCellId}   Get Cloud VDU Parameter Value Online   mo_dn=${NRCELL_dn}  para_name=physCellId   alias=${conn_alias}
#    ${nrarfcn}   Get Cloud VDU Parameter Value Online      mo_dn=${NRCELL_dn}  para_name=nrarfcn   alias=${conn_alias}

    ${CHANNEL_dn}  Set Variable   ${LCELNR_dn}/CHANNELGROUP-1/CHANNEL-1
    ${scf_content}   OperatingSystem.Get File   ${vdu_scfc_path}
    ${channel_group}     Get Regexp Matches    ${scf_content}   .*${LCELNR_dn}/CHANNELGROUP-1/CHANNEL-(\\d)".+   1
    ${channel_group_info}  Create List  ${channel_group}

    ${deleted_cell_info}   Create Dictionary   cell_id=${to_be_deleted_NRCELL_id}  nrdu=${nrdu}   lcrId=${lcrId}
       ...  nrcellgrpId=${to_be_deleted_NRCELLGRP_id}   physCellId=${physCellId}    channel_group_info=${channel_group_info}
#       ...  nrarfcn=${nrarfcn}

    Log To Console    \n****vDU begin to delete cell info in delta plan
    vdu.delete_mo_of_delta_plan    delta_plan_id=${plan_id}    mo_dn=${NRCELL_dn}    vdu_connection=${conn_alias}
    sleep  5s
    ${out}=    vdu.delete_mo_of_delta_plan    delta_plan_id=${plan_id}    mo_dn=${LCELNR_dn}    vdu_connection=${conn_alias}
    Log To Console    \n**** vDU out LCELNR_dn delete_mo_of_delta_plan=${out}
    sleep  5s
    ${out}=    vdu.delete_mo_of_delta_plan    delta_plan_id=${plan_id}    mo_dn=${NRCELLGRP_dn}    vdu_connection=${conn_alias}
    Log To Console    \n**** vDU out NRCELLGRP_dn delete_mo_of_delta_plan=${out}
    sleep  5s

    ${refgrp_id_index_value}    Convert To Integer    ${refgrp_id_index}
    ${to_be_deleted_NRCELLGRP_str}    Convert To String    ${to_be_deleted_NRCELLGRP_id}
    ${paras}=   Create Dictionary   /refNrCellGroup/${refgrp_id_index_value}=${to_be_deleted_NRCELLGRP_str}
    Update Cloud vDU Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${NRDU_dn}   updated_paras_dict=${paras}   operation=remove
    ...    alias=${conn_alias}

    Log To Console    \n****vDU delete cell validate delta plan
    Validate Cloud vDU Delta Plan By REST   ${plan_id}   alias=${conn_alias}
    Log To Console    \n****vDU delete cell activate delta plan
    Cloud vDU Activate Delta Plan By REST   plan_id=${plan_id}   alias=${conn_alias}
    [Return]  ${deleted_cell_info}    ${vdu_scfc_path}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}


Cloud vDU Add Cell By Copy Cell
    [Arguments]     ${base_cell_id}   ${cell_dict}   ${scfc_load_file}=${None}
    ...   ${gnb_index}=0  ${vdu_index}=0
    [Documentation]    Vdu Copy a cell from a existing cell

    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | base_cell_id    | yes | the reference cell id for copy |
    ...    | cell_dict       | yes | the infos of added cell, like {nrdu=1}|
    ...    | scfc_load_file   | yes | scfc file include base_cell |
    ...    | vdu_index | No | the index of vdu, default value is 0 |
    ...    | gnb_index | No | the index of gnb, default value is 0 |
    ...   *Example*
    ...   | ${cell_dict} | create dictionary  | nrdu=1 | lcrId=9 | nrcellgrpId=9 |  physCellId=419 | rmod_id=9 |
    ...   | ${CHANNEL_list1} | create list | 1 | 2 | 3  |4 |
    ...   | ${channel_group}  | create list | ${CHANNEL_list1}
    ...   | Cloud vDU Copy Cell | base_cell_id=5 | cell_dict=${cell_dict} | channel_group=${channel_group} |
    ...   *Return*
    ...   None
    ...    History of changes
    ...    ******************
    ...    - 07.06.2024 - - Created
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    Log To Console    Cloud vDU Add Cell By Copy Cell
    ${conn_alias}   generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    Log To Console    \n****conn_alias=${conn_alias}

    Log To Console    \n****vdu load base cell scfc file
    Check Cloud vDU Max Load Plan Number And Delete One If Reach Max Number   alias=${conn_alias}
    ${load_plan_id}    ${load_action_id}    Cloud vDU Load SCFC File    scfc_load_file=${scfc_load_file}   alias=${conn_alias}
    log to console  load_plan_id=${load_plan_id}

    Log To Console    \n****vdu backup current scfc
    ${backup_scf_path}    set variable    /home/ute/
    ${vdu_scf}=  vdu.get_current_plan_file  local_dir_path=${backup_scf_path}  filename=base_scf.xml  include_runtime_data=${False}
    ...    vdu_connection=${conn_alias}

    Log To Console    \n****vdu get bts info
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get Cloud BTS ID From vDU SCF    scf_path=${vdu_scf}
    ${DN}   set variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}

    Log To Console    \n****vdu create delta plan
    ${uni_id}   generic_utils.get_unique_id_string
    Check Cloud vDU Max Delta Plan Number And Delete One If Reach Max Number    alias=${conn_alias}
    ${plan_id}   ${action_id}   Cloud vDU Generate Delta Plan   plan_name=add_cell_${uni_id}    alias=${conn_alias}

    Log To Console    \n****vdu get mo_uuid and prarent_mo_uuid
    ${plan_info_list}   vdu.get_tree_of_delta_plan    plan_id=${plan_id}   vdu_connection=${conn_alias}
    ${parent_plan_info_list}   vdu.get_tree_of_staged_plan    plan_id=${load_plan_id}    vdu_connection=${conn_alias}
    ${nrcell_mo_uuid}    get_value_from_plan_tree_info     info_list=${parent_plan_info_list}
    ...   dist_name=${DN}/NRCELL-${base_cell_id}   key=mo_uuid
    ${parent_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
    ...   dist_name=${DN}   key=mo_uuid


    Log To Console    \n****vdu Copy NRCELL MO from NRCELL-${base_cell_id}
    ${added_cell_id}    set variable    ${cell_dict["cell_id"]}
    Copy Cloud vDU MO Into Delta Plan    plan_id=${plan_id}   source_plan_id=${load_plan_id}   parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${nrcell_mo_uuid}   new_instance_id=${added_cell_id}    include_children_objects=${True}    alias=${conn_alias}

    ${nrcell_grp_id}    set variable    ${cell_dict["nrcellgrpId"]}
    ${nrcell_grp_id_str}    Convert To String    ${nrcell_grp_id}
    Log To Console    \n****vdu Copy NRCELLGRP MO from NRCELLGRP, update nrCellList
    ${nrcellgrp_mo_uuid}    get_value_from_plan_tree_info
    ...   info_list=${parent_plan_info_list}    dist_name=${DN}/NRCELLGRP-${nrcell_grp_id}   key=mo_uuid

    Copy Cloud vDU MO Into Delta Plan   plan_id=${plan_id}   source_plan_id=${load_plan_id}   parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${nrcellgrp_mo_uuid}   new_instance_id=${added_cell_id}   include_children_objects=${True}    alias=${conn_alias}

   Log To Console    \n****vdu Add refNrCellGroup into NRDU-${cell_dict['nrdu']}
    ${NRCELLGRP_id_list}   Get Cloud NRCELLGRP ID list From vDU SCF File   scf_path=${vdu_scf}
    ${nrcell_grp_list_len}    Get Length    ${NRCELLGRP_id_list}
    ${nrcellgrp_index}    set variable    ${nrcell_grp_list_len}
    Log To Console    nrcell_grp_id=${nrcell_grp_id},nrcell_grp_id_str=${nrcell_grp_id_str},nrcell_grp_list_len=${nrcell_grp_list_len}
    ${updated_paras_dict}   create dictionary   /refNrCellGroup/${nrcellgrp_index}=${nrcell_grp_id_str}
    Update Cloud vDU Delta Plan Parameter  plan_id=${plan_id}  mo_dn=${DN}/NRDU-${cell_dict['nrdu']}
    ...   updated_paras_dict=${updated_paras_dict}    operation=add    alias=${conn_alias}


   ${lcrid}    set variable   ${cell_dict['lcrId']}
   Log To Console    \n****vdu Copy CELLMAPPING-1/LCELNR MO from LCELNR-${base_cell_id}
    ${lcelnr_mo_uuid}    get_value_from_plan_tree_info     info_list=${parent_plan_info_list}
    ...   dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${base_cell_id}    key=mo_uuid
    ${lcelnr_parent_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
    ...   dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1   key=mo_uuid
    Copy Cloud vDU MO Into Delta Plan    plan_id=${plan_id}   source_plan_id=${load_plan_id}   parent_mo_uuid=${lcelnr_parent_mo_uuid}
    ...    mo_uuid=${lcelnr_mo_uuid}   new_instance_id=${lcrid}    include_children_objects=${True}       alias=${conn_alias}

    Log To Console    \n****vdu add cell validate delta plan
    Validate Cloud vDU Delta Plan By REST   ${plan_id}   alias=${conn_alias}
    Log To Console    \n****vdu add cell activate delta plan
    Cloud vDU Activate Delta Plan By REST   ${plan_id}   alias=${conn_alias}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}


Get Cloud vDU SCF From Current Plan
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0   ${include_runtime_data}=${False}   ${alias}=default
    [Documentation]  Get Cloud VDU SCF From Current Plan
    ...
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | gnb_index | no | gnb_index, default is 0 |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...    | include_runtime_data | no | include_runtime_data, default is ${False} |
    ...
    ...    *RETURN VALUE*
    ...    scf file full name
    ...
    ...    Example
    ...    | ${scf_file_with_fullpath} | Get VDU SCF From Current Plan | gnb_index=0 | vdu_index=0 |
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 07.06.2024 - - Created
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    #todo
    Log To Console    \n****gnb_index=${gnb_index}
    Log To Console    \n****vdu_index=${vdu_index}
    ${tmp_scf_path}    set variable    /home/ute/
    ${file_name}   generic_utils.get_unique_id_string  prefix=scf_vdu_   suffix=.xml   precise=LOW
    ${tmp_scf_full_path}  vdu.get_current_plan_file
      ...   local_dir_path=${tmp_scf_path}  filename=${file_name}  include_runtime_data=${include_runtime_data}   vdu_connection=${alias}
    [Return]  ${tmp_scf_full_path}


Get Cloud vDU Conf From SCF File
    [Arguments]  ${scf_path}=${EMPTY}   ${vdu_index}=0   ${gnb_index}=0    ${alias}=default
    [Documentation]  Get Cloud vDU Conf From SCF File.
    ...
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | scf_path  | no | abosolute path of scf file, if it's ${EMPTY} it will download scf from CURRENT plan, default is ${EMPTY} |
    ...    | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of configuration in SCF file.
    ...    example: {'mrbts_id': '1234', 'nrbts_id': '5678', 'nrdu_id': '1',‘nrbts_version’:'xxx'  }
    ...
    ...    Example
    ...    | ${vdu_conf} | Get Cloud vDU Conf From SCF File | scf_path=/home/ute/a.scf |
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 07.06.2024 - - Created
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${scf_path}   run keyword if  "${scf_path}"=="${EMPTY}"  Get Cloud vDU SCF From Current Plan    gnb_index=${gnb_index}  vdu_index=${vdu_index}
       ...    alias=${alias}    ELSE    set variable  ${scf_path}

    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get Cloud BTS ID From vDU SCF    scf_path=${scf_path}
    ${nrbts_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-${nrdu_id}   attribute=version
    ${mnl_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/MNL-1   attribute=version
    ${eqm_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/EQM-1  attribute=version
    ${conf}   create dictionary
    ...  mrbts_id=${mrbts_id}
    ...  nrbts_id=${nrbts_id}
    ...  nrdu_id=${nrdu_id}
    ...  nrbts_version=${nrbts_version}
    ...  mnl_version=${mnl_version}
    ...  eqm_version=${eqm_version}
    [Return]  ${conf}


Get Cloud BTS ID From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]  Get Cloud BTS ID From vDU SCF
    ...   *Arguments Description*
    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | scf_path | Yes | scf file with absolute path, it's vDU scf file. |
    ...   *Return*
    ...   list value, contains [<mrbts_id>, <nrbts_id>, <nrdu_id>]
    ...   *Example*
    ...   | ${mrbts_id} | ${nrbts_id} | ${nrdu_id} | Get Cloud BTS ID From vDU SCF | scf_path=/tmp/a.scf |
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 07.06.2024 - - Created
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRDU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRDU-(\\d+)"\\s+.*   1  2  3
    ${mrbts_id}  Set Variable If  ${result}   ${result[0][0]}
    ${nrbts_id}  Set Variable If  ${result}   ${result[0][1]}
    ${nrdu_id}   Set Variable If  ${result}   ${result[0][2]}
    [Return]  ${mrbts_id}   ${nrbts_id}  ${nrdu_id}

Get Cloud LCELNR ID From vDU SCF File
    [Arguments]  ${scf_path}
    [Documentation]  Get Cloud LCELNR ID From vDU SCF File
    ...   *Arguments Description*
    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | scf_path | Yes | scf file with absolute path, it's vDU scf file. |
    ...
    ...   *Return*
    ...   list value, contains LCELNR id
    ...
    ...   *Example*
    ...   | ${LCELNR_id} | Get LCELNR ID From vDU SCF | scf_path=/home/ute/vcd_scf.xml |
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 07.06.2024 - - Created
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${matches}     Get Regexp Matches    ${scf_content}   .*MRBTS-\\d+/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-(\\d+)".+   1
    Sort List   ${matches}
    [Return]  ${matches}


Get Cloud NRCELLGRP ID list From vDU SCF File
   [Arguments]  ${scf_path}
   [Documentation]      Get Cloud NRCELLGRP ID list From vDU SCF File.
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...	   | scf_path | yes | scf_path, e.g, /tmp/scf.xml  |
    ...
    ...    *RETURN VALUE*
    ...    NRCELLGRP id list
    ...
    ...    Example
    ...    | ${NRCELLGRP_id_list} | vDU Get NRCELLGRP ID list  |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*MRBTS-\\d+/NRBTS-\\d+/NRCELLGRP-(\\d+)"   1
    [Return]   ${result}

Check Cloud vDU Max Delta Plan Number And Delete One If Reach Max Number
    [Arguments]   ${alias}=default
    [Documentation]   Check Cloud vDU Max Delta Plan Number And Delete One If Reach Max Number
    ...
    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...  | alias | yes| return rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | ${alias}  VDU Rest Login |
    ...  | Check Cloud vDU Max Delta Plan Number And Delete One If Reach Max Number | alias=${alias} |
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 07.06.2024 - - Created
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${all_plans}   vdu.Get_Delta_Plan_Info_List  vdu_connection=${alias}
    Run Keyword If  ${all_plans.__len__()}==1   Cloud vDU Delete Delta Plan By Plan Id   plan_id=${all_plans[0]["plan_id"]}    alias=${alias}


Cloud vDU Delete Delta Plan By Plan Id
    [Arguments]  ${plan_id}    ${alias}=default
    [Documentation]   Delete Delta Plan By Plan Id
    ...
    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | plan_id  | yes | delta plan id |
    ...  | alias | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | ${alias}  VDU Rest Login |
    ...   | Cloud vDU Delete Delta Plan By Plan Id | plan_id=my_plan_id | ${alias}|
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${out}    vdu.delete_delta_plan_file   plan_id=${plan_id}    vdu_connection=${alias}
    wait until keyword succeeds  60   5   _Cloud vDU Make Sure Delta Plan Is Deleted Once    alias=${alias}


_Cloud vDU Make Sure Delta Plan Is Deleted Once
	[Arguments]  ${alias}=default
    ${all_plans}   vdu.Get_Delta_Plan_Info_List     vdu_connection=${alias}
    Should Be True  ${all_plans.__len__()}==0

Get Cloud VDU Parameter Value Online
    [Arguments]  ${mo_dn}   ${para_name}    ${timeout}=60   ${alias}=default
    [Documentation]   Get Cloud vDU Parameter Value Online
    ...    *Argument Description*
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | mo_dn     | yes | the distname of given parameter |
    ...    | para_name | yes | parameter name   |
    ...    | timeout   | no | timeout, default is 60, unit is second
    ...    | alias | yes | return value rest login |
    ...
    ...    *RETURN VALUE*
    ...    the parameter value getting from current plan
    ...
    ...   *Example*
    ...  | ${alias}        | vdu rest login | gnb_index=0 | vdu_index=1 |
    ...  | ${mo}          | Set Variable | MRBTS-1234/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1 |
    ...  | ${list_name}   | Set Variable | acceptedClockClass |
    ...  | ${value}       | Get Cloud vDU Parameter Value Online | mo_dn=${mo} | para_name=acceptedClockClass | alias |
    ...
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}  vdu_connection=${alias}
    [Return]  ${out}


Update Cloud vDU Delta Plan Parameter
    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30   ${alias}=${None}
    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | updated_paras_dict | yes | updated_paras_dict   |
    ...   | operation          | no | operation: add, replace, remove, revert   |
    ...   | mo_uuid            | no | mo_uuid, default is ${None}  |
    ...   | timeout           | no | timeout, default is 30, unit is second   |
    ...   | alias              | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${added_dict} |  create dictionary  | f1SctpProfileIdOfDu=5 | sctpProfile/0/sctpHeartbeatInterval=21 |
    ...  | ${validation_id} | Update Cloud vDU Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=add | alias |
    ...
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.update_vdu_parameter_of_delta_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}  vdu_connection=${alias}

    ${action_id}  set variable  ${out["action_id"]}
    ${out}    Update Cloud vDU Delta Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}  alias=${alias}
    [Return]  ${out}

Update Cloud vDU Delta Plan Parameter Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}  ${alias}=${None}
    [Documentation]   Update Cloud vDU Delta Plan Parameter Should Be Successful

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...  | alias            | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update Delta Plan Parameter Should Be Successful | plan_id=<plan_id> | action_id=<action_id> | alias |
    ...
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Update Cloud vDU Delta Plan Parameter Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    ...   alias=${alias}
    [Return]  ${rtn}


_Update Cloud vDU Delta Plan Parameter Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}    ${alias}=${None}
    [Documentation]    _Update Cloud vDU Delta Plan Parameter Should Be Expected
    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id       | yes | action_id |
    ...   | alias            | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Validate Plan Status Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...  | alias |
    ...
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************

    ${out}   vdu.get_update_paras_action_status_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}   vdu_connection=${alias}
    Log To Console    \n****out=${out}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Validate Cloud vDU Delta Plan By REST
    [Arguments]  ${plan_id}    ${alias}=${None}
    [Documentation]   Validate Delta Plan By REST

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | plan_id    | yes | plan_id |
    ...  | alias       | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    Return validation_id
    ...
    ...   Example
    ...  | ${alias}    | vdu rest login | gnb_index=0 | vdu_index=1 |
    ...  | ${delta_plan_name} | get unique id | prefix=TA_delta_plan | precise=LOW |
    ...  | ${plan_id} | ${action_id} | Generate Delta Plan | plan_name=${delta_plan_name} | plan_description=TA |
    ...  | ${nrcell} | create dictionary | nrcell=1
    ...  | ${mo} | set variable | MRBTS-5200/MNL-1/TCEADM-1/TCE-1 |
    ...  | Update Cloud vDU Delta Plan Parameter | plan_id=${plan_id} | mo_dn=${mo} | updated_paras_dict=${nrcell} | operation=add |
    ...  | alias |
    ...
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************

    ${out}  vdu.Validate_Delta_Plan   delta_plan_id=${plan_id}    vdu_connection=${alias}
    ${action_id}   Set Variable  ${out["action_id"]}
    ${out}    Cloud vDU Validate Delta Plan Status Should Be Successful   action_id=${action_id}  plan_id=${plan_id}   alias=${alias}
    ${validation_id}  Set Variable   ${out["validation_id"]}
    [Return]   ${validation_id}


_Validate Cloud vDU Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}   ${plan_id}  ${alias}=${None}
    ${out}   vdu.Get_Validate_Delta_Plan_Operation_Status   action_id=${action_id}   delta_plan_id=${plan_id}    vdu_connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Cloud vDU Validate Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}   ${plan_id}   ${alias}=${None}
    [Documentation]   Validate Delta Plan Status Should Be Successful
    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...  | alias       | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Cloud vDU Validate Delta Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> | alias |
    ...
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************

    ${rtn}  Wait Until Keyword Succeeds  20   2
     ...   _Validate Cloud vDU Delta Plan Status Should Be Expected   action_id=${action_id}    plan_id=${plan_id}   expected_status=success
     ...   alias=${alias}
    [Return]  ${rtn}

Cloud vDU Activate Delta Plan By REST
    [Arguments]  ${plan_id}   ${force_reset}=${True}   ${auto_lock_cells}=${True}   ${timeout}=60   ${alias}=${None}
    [Documentation]   Activate Delta Plan By REST

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | plan_id          | yes | delta plan id |
    ...   | force_reset      | no | default is ${True} |
    ...   | auto_lock_cells  | no | default is ${True} |
    ...   | timeout          | no | default is 60 (seconds) |
    ...   | alias            | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example of changing btsName
    ...   | vdu rest login |
    ...   | Cloud vDU Activate Delta Plan By REST |  ${plan_id} |
    ...   | VDU Rest Logout |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}
     ...   force_reset=${force_reset}   auto_lock_cells=${auto_lock_cells}   timeout=${timeout}    vdu_connection=${alias}
    Cloud vDU Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}   alias=${alias}


_Cloud vDU Activate Delta Plan Status Should Be Expected
    [Arguments]  ${operation_id}    ${plan_id}   ${expected_status}   ${alias}=${None}
    ${out}   vdu.Get_Activate_Delta_Plan_Operation_Status   operation_id=${operation_id}   delta_plan_id=${plan_id}    vdu_connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Cloud vDU Activate Delta Plan Status Should Be Successful
    [Arguments]  ${operation_id}   ${plan_id}    ${alias}=${None}
    [Documentation]   Activate Delta Plan Status Should Be Successful

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...   | alias           | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    dictionary contains result
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Activate Delta Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> | alias |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${rtn}   Wait until keyword succeeds  10min  30s
     ...   _Cloud vDU Activate Delta Plan Status Should Be Expected   operation_id=${operation_id}    plan_id=${plan_id}   expected_status=success
     ...   alias=${alias}
    [Return]  ${rtn}


Cloud vDU Generate Delta Plan
    [Arguments]    ${plan_name}  ${plan_description}=${EMPTY}  ${delete_old_one}=${True}    ${alias}=default
    [Documentation]   Cloud vDU Generate Delta Plan

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | plan_name    | yes | plan_name |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | delete_old_one   | no | delete_old_one , if ${true}, old delta plan will be deleted, default is ${True} |
    ...   | alias           | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    Return (<plan_id>, <action_id>)
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${plan_id} | ${action_id} | Cloud vDU Generate Delta Plan | plan_name=my_plan_name |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    run keyword if  "${delete_old_one}"=="${True}"   Check Cloud vDU Max Delta Plan Number And Delete One If Reach Max Number    alias=${alias}

    ${out}  vdu.Generate_Delta_Plan  plan_name=${plan_name}   plan_description=${plan_description}    vdu_connection=${alias}
    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}

    Cloud vDU Generate Delta Plan Status Should Be Successful  action_id=${temp_action_id}    alias=${alias}
    [Return]   ${temp_plan_id}   ${temp_action_id}


_Cloud vDU Generate Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}    ${alias}=default
    [Documentation]   _Cloud vDU Generate Delta Status Should Be Expected

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | action_id       | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...   | alias           | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Upload Status Should Be Expected | action_id=<my_operation_id> | expected_status=success |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${out}   vdu.Get_Delta_Plan_Generated_Action_Status   action_id=${action_id}    vdu_connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"


Cloud vDU Generate Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}    ${alias}=default
    [Documentation]   Cloud vDU Generate Delta Plan Status Should Be Successful

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | action_id    | yes | action_id |
    ...   | alias        | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Cloud vDU Generate Delta Plan Status Should Be Successful | action_id=<my_action_id> | alias
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    Wait Until Keyword Succeeds  30   3  _Cloud vDU Generate Delta Plan Status Should Be Expected   action_id=${action_id}    expected_status=success
    ...    alias=${alias}

_Update Cloud vDu Channel resourceDN
    [Arguments]     ${channel_list}   ${group_id}   ${rmod_id}   ${MRBTS_ID}   ${plan_id}  ${lnrcell}    ${alias}=default
    ${resourceDN}  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_id}/PHYANT-1
    ${dict_resourceDN}=   Create Dictionary  resourceDN=${resourceDN}
    FOR    ${index}    IN    @{CHANNEL_list}
        ${MO_LCELNR_GP}  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lnrcell}/CHANNELGROUP-${group_id}/CHANNEL-${index}
        Update Cloud vDu Delta Plan Parameter  plan_id=${plan_id}  mo_dn=${MO_LCELNR_GP}  updated_paras_dict=${dict_resourceDN}    alias=${alias}
    END

Copy Cloud vDU MO Into Delta Plan
    [Arguments]  ${plan_id}   ${source_plan_id}   ${parent_mo_uuid}   ${mo_uuid}     ${new_instance_id}
    ...   ${include_children_objects}    ${timeout}=30    ${alias}=${None}
    [Documentation]    Vdu Copy MO Into Delta Plan
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | plan_id          | yes | plan id for delta plan         |
    ...    | source_plan_id   | yes | source plan id, could be delta plan or current plan |
    ...    | parent_mo_uuid   | yes | parent managed object id in source plan|
    ...    | mo_uuid          | yes | Unique managed object id which is being copied in source plan|
    ...    | new_instance_id  | yes | new instance id |
    ...    | include_children_objects | yes | is include children objects |
    ...    | timeout          | no  | Timeout for the operation, defaults to 30|
    ...    | alias           | yes | return value rest login |
    ...
    ...   *Example*
    ...   | vdu rest login |
    ...   | ${plan_info_list} |  vdu.get_tree_of_delta_plan  |  plan_id=${plan_id}  |
    ...   | ${mo_uuid} | get_value_from_plan_tree_info  | info_list=${plan_info_list} | dist_name=XXXX | key=mo_uuid |
    ...   | ${parent-mo_uuid} | get_value_from_plan_tree_info | info_list=${plan_info_list} | dist_name=XXXX | key=parent_mo_uuid |
    ...   | Copy Cloud vDU MO Into Delta Plan | plan_id=${plan_id} |  source_plan_id=${plan_id} |  parent_mo_uuid=${parent_mo_uuid}
    ...   | mo_uuid=${nrcell_mo_uuid} |  new_instance_id=9 |   include_children_objects=${True} | alias |
    ...
    ...   *Return*
    ...   None
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    Log To Console    \n****Start Copy Cloud vDU MO Into Delta Plan
    ${ret_dict}    vdu.copy_managed_objects_into_delta_plan
    ...    plan_id=${plan_id}
    ...    source_plan_id=${source_plan_id}
    ...    parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${mo_uuid}
    ...    new_instance_id=${new_instance_id}
    ...    include_children_objects=${include_children_objects}
    ...    timeout= ${timeout}
    ...    vdu_connection=${alias}
    wait until keyword succeeds   10x   2s
    ...   _Copy Cloud vDU MO Into Delta Plan Should Be Successful   plan_id=${plan_id}   action_id=${ret_dict['action_id']}   expected_status=success
    ...   alias=${alias}


_Copy Cloud vDU MO Into Delta Plan Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}  ${expected_status}   ${alias}=${None}
    ${out}   vdu.get_copy_managed_objects_into_delta_plan_status    plan_id=${plan_id}  action_id=${action_id}   vdu_connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Cloud vDU Load SCFC File
    [Arguments]     ${scfc_load_file}    ${alias}=default
    [Documentation]   load SCF
    ...    | scfc_load_file   | yes  | vdu scfc file absolute path|
    ...    | alias           | yes | return value rest login |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    log to console   \n*** Start plan upload operation ***
    ${upload_plan_response}=  vdu.upload_plan    ${scfc_load_file}    vdu_connection=${alias}
    wait until keyword succeeds  10s  1s
    ...    Cloud vDU Upload Plan Operation Should Be Successful  ${upload_plan_response['action_id']}    alias=${alias}
    [Return]    ${upload_plan_response['plan_id']}    ${upload_plan_response['action_id']}


Cloud vDU Upload Plan Operation Should Be Successful
     [Arguments]  ${upload_action_id}    ${alias}=default
    [Documentation]   checking upload plan operation status should be successful
     ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | upload_action_id | yes | upload action id, get from upload_plan |
    ...    | alias           | yes | return value rest login |
    ...    *RETURN VALUE*
    ...    None
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...

    ${upload_operation_response}=  vdu.get_upload_plan_operation_status  ${upload_action_id}    vdu_connection=${alias}
    should be equal as strings  ${upload_operation_response['status']}  success
    Log To Console    \n****Cloud vDU Upload Plan Success

Check Cloud vDU Max Load Plan Number And Delete One If Reach Max Number
    [Arguments]   ${alias}=default
    [Documentation]   Check Cloud vDU Max Load Plan Number And Delete One If Reach Max Number
    ...
    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...  | alias           | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | ${alias}  VDU Rest Login |
    ...  | Check Cloud vDU Max Delta Plan Number And Delete One If Reach Max Number | alias=${alias} |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${all_plans}   vdu.get_staged_plans_info_list  vdu_connection=${alias}
    Run Keyword If  ${all_plans.__len__()}>=3   vdu.delete_staged_plan_file   plan_id=${all_plans[0]["plan_id"]}    vdu_connection=${alias}

Get Cloud vDU Cell Group ID by Cell ID
    [Arguments]  ${cell_index}=1   ${mbts_id}=1   ${nrbts_id}=1    ${nrdu}=1    ${alias}=default
    [Documentation]    Cloud Vdu Delete Cell By Cell Index
    ...
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_index | yes | the cell index of deleted
    ...    | mbts_id | Yes | the index of vdu, default value is 0 |
    ...    | nrdu | Yes | nrduid |
    ...   | alias            | yes | return value rest login |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${NRDU_dn}   Set Variable   MRBTS-${mbts_id}/NRBTS-${nrbts_id}/NRDU-${nrdu}
    ${grp_value_list}   Get Cloud vDU Parameter Value Online   mo_dn=${NRDU_dn}   para_name=refNrCellGroup   alias=${alias}
    log to console   refNrCellGroup_value=${grp_value_list}
#    ${grp_id}    set variable    ${0}
#    ${refgrp_id_index}    set variable    ${0}
     FOR    ${grp_id}    IN    @{grp_value_list}
         ${grp_id_value}    Convert To Integer    ${grp_id}
         ${cell_grp_dn}    set variable    MRBTS-${mbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-${grp_id_value}
         ${grp_cell_list}   Get Cloud vDU Parameter Value Online   ${cell_grp_dn}   nrCellList   alias=${alias}
         ${cell_index_str}    Convert To String    ${cell_index}
         ${index}=    Get Index From List    ${grp_value_list}    ${grp_id}
         run keyword if    '${cell_index_str}' in @{grp_cell_list}
         ...    Run Keywords   Set Suite Variable    ${grp_id}    ${grp_id_value}
         ...    AND    Set Suite Variable    ${refgrp_id_index}    ${index}
         ...   AND  exit for loop
     END

    [Return]   ${grp_id}    ${refgrp_id_index}



Get Cloud vDU Specific RU Related Cell id
   [Arguments]    ${rmods_id_list}    ${alias}=default
   [Documentation]      Get Cloud vDU Specific RU Related Cell id
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | rmods_id_list | Yes |  rmod id list, [1, 2, 3].   |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...    *Example*
    ...    | Get Cloud vDU Specific RU Related Cell id | rmods_id_list=${rmods_id_list} |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************

    ${ru_info}=  vdu.get_rmods_status        vdu_connection=${alias}
    @{cell_id_list}  Create List
    FOR    ${i}    IN RANGE    0    ${ru_info.__len__()}
        ${ru_id}   get from dictionary    ${ru_info}[${i}]   id
        ${cell_ids}   get from dictionary    ${ru_info}[${i}]   cell_ids
        @{cell_id_list}=   run keyword if    "${ru_id}" in "${rmods_id_list}"
         ...  _combine cell_id_list    cell_id_list=${cell_id_list}    cell_ids=${cell_ids}
         ...  ELSE   set variable   ${cell_id_list}
    END
    [Return]    ${cell_id_list}

_combine cell_id_list
    [Arguments]    ${cell_id_list}    ${cell_ids}
    ${cell_id_list}=   run keyword if    "${cell_id_list}"!="None"
    ...  combine lists    ${cell_id_list}    ${cell_ids}
    ...  ELSE   set variable   ${cell_id_list}
    [Return]    ${cell_id_list}

Get Cell List Except Specific Cell
    [Arguments]  ${cell_list}  ${cell_id}
    [Documentation]    *****************
    ...    This keyword is designed to get a list of cell IDs excluding a specific cell ID.
    ...    - [Keyword Details]
    ...    This keyword accepts a list of cell IDs and a specific cell ID as arguments.
    ...    It then iterates over the list of cell IDs and excludes the specific cell ID.
    ...    It returns a new list of cell IDs without the specific cell ID.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_list | Yes | The list of all cell IDs. |
    ...    | cell_id | Yes | The specific cell ID to be excluded. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | new_list | The list of cell IDs excluding the specific cell ID. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 21.06.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************
    ${new_list}    create list
    FOR    ${idx}    IN    @{cell_list}
        run keyword if    ${idx}!=${cell_id}    Append To List    ${new_list}    ${idx}
    END
    [Return]  ${new_list}

Expect Fault Should Absent On vDU
    [Arguments]   ${fault_id}   ${alarming_object}=${None}    ${severity}=${None}    ${alarm_id}=${None}
    ...    ${vdu_index}=0    ${alias}=default
    [Documentation]
    ...    This keyword is to check expect alarm should be absent on vDU.
    ...    - [Keyowrd Details]
    ...    This keyword is to check expect alarm on vDU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | fault_id | Mandatory | The fault id index. No detault value. |
    ...    | alarming_object | No | The alarming context. Default value is None. |
    ...    | severity | No | The alarm severity. Default value is None. |
    ...    | alarm_id | No | The alarming id. Default value is None. |
    ...    | vdu_index | No | The vDU index. Default value is 0. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 12.06.2024 - - Created
    ...    *******************
    ...    *Author* wenjin.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_01
    ...    *******************
    log to console   \n****alias=${alias}
    ${fault_id}    Convert To Integer    ${fault_id}
    ${status}    Run Keyword And Return Status   Expect Fault Should Present On vDU
    ...          fault_id=${fault_id}
    ...          alarming_object=${alarming_object}
    ...          severity=${severity}
    ...          alarm_id=${alarm_id}
    ...          vdu_index=${vdu_index}
    Run Keyword If  ${status}==${True}   Fail
