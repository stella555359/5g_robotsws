*** Settings ***
Documentation    Cloud resets keywords.
...              Authors:    Patryk Tatarek, Jagoda Kubacka
...              Contact:    patryk.tatarek@nokia.com, jagoda.kubacka@nokia.com

Resource    ../connections/connections.robot
Resource    taf/rfrl/cbts/robot/vcu/vcu_cm.robot
Resource    taf/rfrl/cbts/robot/vdu/vdu_cm.robot

Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin

*** Variables ***
${ng_link_status}=    'ng_link_status': 'Inactive'

*** Keywords ***

#################################################### Main  Keywords ####################################################

Perform Reset and Wait for Expected State
    [Documentation]    Description:    Perform vCU/vDU reset and wait for chosen state (or onAir for vCU)
    ...                Input:          hw_type = vCU/vDU
    ...                                state = valid only for vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${state}=${NONE}    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Perform Reset on vCU
    ...    ELSE IF    '${hw_type}'=='vDU'    _Perform Reset on vDU    state=${state}
    ...    ELSE        FAIL                  hw_type doesn't exist


Check if Unit Status is OnAir
    [Documentation]    Description:    Waiting when vCU/vDU will be in onAir state.
    ...                Input:          hw_type = vCU/vDU
    ...                                state = default is onAir (possible to change it and you can expect another state)
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${state}=onAir    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Check if vCU is in OnAir State and is Fully Functioned
    ...                                      pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Check if vDU is in Expected State
    ...                                      state=${state}    pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Get Current BTS State
    [Documentation]    Description:    Check the current state of vCU/vDU
    ...                Input:          hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Output:         State of chosen HW
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    ${state}=          Run Keyword If    '${hw_type}'=='vCU'    _Get Current State of vCU    pre-conn=${pre-connection}
    ...                ELSE IF           '${hw_type}'=='vDU'    _Get Current State of vDU    pre-conn=${pre-connection}
    ...                ELSE               FAIL                  hw_type doesn't exist
    [Return]           ${state}

Block Cell
    [Documentation]    Description:    Trigger block cell operation on vCU/vDU
    ...                Input:          cell_id = ID of cell to block
    ...                                hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${cell_id}=${0}    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Block vCU Cell    cell_id=${cell_id}    pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Block vDU Cell    cell_id=${cell_id}    pre-conn=${pre-connection}
    ...     ELSE       FAIL                  hw_type doesn't exist

Unblock Cell
    [Documentation]    Description:    Trigger unblock cell operation on vCU/vDU
    ...                Input:          cell_id = ID of cell to unblock
    ...                                hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${cell_id}=${0}    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Unblock vCU Cell    cell_id=${cell_id}    pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Unblock vDU Cell    cell_id=${cell_id}    pre-conn=${pre-connection}
    ...     ELSE       FAIL                  hw_type doesn't exist

################################################ Supplementary Keywords ################################################

_Perform Reset on vCU
    ${temp_conn_main}=    Connect to ADMIN      hw_type=vCU
    ${reset}=             vcu_admin.reset_cu    connection=${temp_conn_main}
    Should Be True        "${reset["status"]}"=="ongoing"
    Wait Until Keyword Succeeds    15min    15s    _Check if vCU is in OnAir State and is Fully Functioned
    [Teardown]    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${temp_conn_main}    hw_type=vCU

_Check if vCU is ready for action
    [Arguments]         ${pre-conn}=${NONE}
    ${temp_conn}=       Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                 ELSE    Set Variable    ${pre-conn}
    ${state}=           vcu_admin.get_cu_state    connection=${temp_conn}
    Should be True     "${state["operational_state"]}"=="enabled"
    ${amfs}=            Get From List    ${state["amfs"]}    0
    Should be True     "${amfs["ng_link_status"]}"=="Active"
    [Teardown]          Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                               connection=${temp_conn}    hw_type=vCU

_Check if vCU is in OnAir State and is Fully Functioned
    [Arguments]          ${pre-conn}=${NONE}
    ${temp_conn}=        Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                  ELSE    Set Variable    ${pre-conn}
    ${cells_summary}=    vcu_admin.get_cells_summary    timeout=30    connection=${temp_conn}
    Run Keyword and Continue on Failure    Should be Equal as Integers
    ...                  ${cells_summary["basic_cells_summary"]["administrative_state"]["shutting_down"]}
    ...                  0    Some cells are shutting down!
    Run Keyword and Continue on Failure    Should be Equal as Integers
    ...                  ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}
    ...                  0    Some cells are locked!
    Run Keyword and Continue on Failure    Should be Equal as Integers
    ...                  ${cells_summary["basic_cells_summary"]["operational_state"]["disabled"]}
    ...                  0    Some cells are disabled!
    ${state}=            vcu_admin.get_cu_state    connection=${temp_conn}
    Should be True      "${state["operational_state"]}"=="enabled"
    ${amfs}=             Get From List    ${state["amfs"]}    0
    Should be True      "${amfs["ng_link_status"]}"=="Active"
    [Teardown]           Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                               connection=${temp_conn}    hw_type=vCU

_Perform Reset on vDU
    [Arguments]      ${state}
    ${temp_conn}=    Connect to ADMIN    hw_type=vDU
    ${reset}=        vdu_admin.reset_vdu    vdu_connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    5s      _Check if vDU Reset Happens
    ...                                            id=${reset['id']}    conn=${temp_conn}
    Wait Until Keyword Succeeds    15min    15s    _Check if vDU is in Expected State
    ...                                            state=${state}    pre-conn=${temp_conn}
    [Teardown]       Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Check if vDU Reset Happens
    [Arguments]        ${id}    ${conn}
    ${output}=         vdu_admin.get_reset_vdu_operation_status    operation_id=${id}    vdu_connection=${conn}
    Should Be True    "${output["status"]}"=="ongoing"

_Check if vDU is in Expected State
    [Arguments]        ${state}    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${data}=           vdu_admin.get_vdu_state_data    vdu_connection=${temp_conn}
    Should Be True    "${data["operational_state"]}"=="${state}"
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU

_Get Current State of vCU
    [Arguments]         ${pre-conn}=${NONE}
    ${temp_conn}=       Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                 ELSE    Set Variable    ${pre-conn}
    ${data}=            vcu_admin.get_cu_state    connection=${temp_conn}
    [Return]            ${data["operational_state"]}
    [Teardown]          Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                               connection=${temp_conn}    hw_type=vCU

_Get Current State of vDU
    [Arguments]      ${pre-conn}=${NONE}
    ${temp_conn}=    Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...              ELSE    Set Variable    ${pre-conn}
    ${data}=         vdu_admin.get_vdu_state_data    vdu_connection=${temp_conn}
    [Return]         ${data["operational_state"]}
    [Teardown]       Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                            connection=${temp_conn}    hw_type=vDU

_Block vCU Cell
    [Arguments]         ${cell_id}    ${pre-conn}=${NONE}
    ${temp_conn}=       Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                 ELSE    Set Variable    ${pre-conn}
    ${cell_id_str}=     Convert to String    ${cell_id}
    ${cell_id_list}=    Create List    ${cell_id_str}
    ${oper}=            vcu_admin.lock_cells    cell_ids=${cell_id_list}    connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    10s    _Check Blocking Cell Operation Status on vCU
    ...                            oper_id=${oper["id"]}    loop_conn=${temp_conn}
    [Teardown]          Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                               connection=${temp_conn}    hw_type=vCU

_Block vDU Cell
    [Arguments]        ${cell_id}    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${cell_id_str}=    Convert to String    ${cell_id}
    ${oper}=           vdu_admin.block_cell    cell_id=${cell_id_str}    vdu_connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    10s    _Check Blocking Cell Operation Status on vDU
    ...                            oper_id=${oper["id"]}    loop_conn=${temp_conn}
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                            connection=${temp_conn}    hw_type=vDU

_Check Blocking Cell Operation Status on vCU
    [Arguments]    ${oper_id}    ${loop_conn}
    ${status}=     vcu_admin.get_operation_state_of_locking_cells    operation_id=${oper_id}    connection=${loop_conn}
    Should Be Equal As Strings    ${status["status"]}    success

_Check Blocking Cell Operation Status on vDU
    [Arguments]    ${oper_id}    ${loop_conn}
    ${status}=     vdu_admin.get_block_cell_operation_status    operation_id=${oper_id}    vdu_connection=${loop_conn}
    Should Be Equal As Strings    ${status["status"]}    success

_Unblock vCU Cell
    [Arguments]         ${cell_id}    ${pre-conn}=${NONE}
    ${temp_conn}=       Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                 ELSE    Set Variable    ${pre-conn}
    ${cell_id_str}=     Convert to String    ${cell_id}
    ${cell_id_list}=    Create List    ${cell_id_str}
    ${oper}=            vcu_admin.unlock_cells    cell_ids=${cell_id_list}    connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    10s    _Check Unblocking Cell Operation Status on vCU
    ...                            oper_id=${oper["id"]}    loop_conn=${temp_conn}
    [Teardown]          Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                               connection=${temp_conn}    hw_type=vCU

_Unblock vDU Cell
    [Arguments]        ${cell_id}    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${cell_id_str}=    Convert to String    ${cell_id}
    ${oper}=           vdu_admin.unblock_cell    cell_id=${cell_id_str}    vdu_connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    10s    _Check Unblocking Cell Operation Status on vDU
    ...                            oper_id=${oper["id"]}    loop_conn=${temp_conn}
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                            connection=${temp_conn}    hw_type=vDU

_Check Unblocking Cell Operation Status on vCU
    [Arguments]    ${oper_id}    ${loop_conn}
    ${status}=     vcu_admin.get_operation_state_of_unlocking_cells    operation_id=${oper_id}    connection=${loop_conn}
    Should Be Equal As Strings    ${status["status"]}    success

_Check Unblocking Cell Operation Status on vDU
    [Arguments]    ${oper_id}    ${loop_conn}
    ${status}=     vdu_admin.get_unblock_cell_operation_status    operation_id=${oper_id}    vdu_connection=${loop_conn}
    Should Be Equal As Strings    ${status["status"]}    success
