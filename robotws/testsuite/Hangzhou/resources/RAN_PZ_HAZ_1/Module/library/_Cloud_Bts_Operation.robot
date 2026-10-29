*** Settings ***
Documentation
...    Author: Xiang Liangliang
...    Contact: liang.xiang@nokia-sbell.com
...    Common KWs use to operate the cloud bts

Library           Collections
Library           re
Library           DateTime
Library           OperatingSystem
Library           Process
Library           Screenshot
Library           String
Library           yaml
Library           XML
Library           Telnet
Library           json
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.gnb.oam.coam.cu.interface.cu    WITH NAME    cu
Resource      taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Resource      taf/rfrl/cbts/robot/vcu/vcu_operations.robot


*** Keywords ***
################################ BTS Operation VDU Part #################################
Cloud BTS Operation for VDU
    [Arguments]    ${operation}
    ...    ${gnb_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${distname_id}=${None}
    ...    ${need_verify}=${True}
    ...    ${verify_status}=${None}
    ...    ${timeout}=90s
    ...    &{kwargs}
    ${connection}    _cbts.vdu_login
    ...    vdu_index=${cudu_index}
    ...    gnb_index=${gnb_index}
    ...    alias=${operation}
    ${supported_operation_type}    Create List    cell    site    cell_group    component    verify
    ${is_supported_operation}    Set Variable    ${None}
    FOR    ${operation_type}    IN    @{supported_operation_type}
        ${is_supported_operation}    _cbts.vdu_is_supported_operation
        ...    ${operation_type}
        ...    ${operation}
        Run Keyword If    ${is_supported_operation}
        ...    Run Keyword    _cbts.vdu_${operation_type}_operation    ${operation}
        ...    connection=${connection}
        ...    distname_id=${distname_id}
        ...    gnb_index=${gnb_index}
        ...    vdu_index=${cudu_index}
        ...    need_verify=${need_verify}
        ...    verify_status=${verify_status}
        ...    timeout=${timeout}
        Exit For Loop If    ${is_supported_operation}
    END
    Run Keyword If
    ...     '${is_supported_operation}'=='${None}' or '${is_supported_operation}'=='${False}'
    ...    Fail    msg=Your operation does not support yet. Please contact the module owner.
    [Teardown]    Run Keyword And Ignore Error    _cbts.vdu_logout    alias=${connection}

_cbts.vdu_login
    [Arguments]    ${alias}=default    ${vdu_index}=${0}    ${gnb_index}=${0}
    vdu.connect to
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}
    [Return]    ${alias}

_cbts.vdu_logout
    [Arguments]    ${alias}=default
    vdu.disconnect    ${alias}

_cbts.vdu_is_supported_operation
    [Arguments]    ${handle_type}    ${operation}
    ${handle}    Run Keyword    _cbts.vdu_get_${handle_type}_handle
    ${is_needed_operation}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${handle}    ${operation}
    [Return]    ${is_needed_operation}

################################ VDU cell operation #################################
_cbts.get_cell_type_by_distname_id
    [Arguments]    ${distname_id}
    ${nr_distnameid_list}    Create List
    ${distnameid_list}    Split String    ${distname_id}
    FOR    ${distnameid}    IN    @{distnameid_list}
        ${celltype_cellid}    Split String    ${distnameid}    -
        Run Keyword If    'NRCELL' in '${distname_id}'
        ...    Append To List    ${nr_distnameid_list}
        ...    ${celltype_cellid}[-1]
    END
    ${celltype_distname}    Create Dictionary    nr=${nr_distnameid_list}
    [Return]    ${celltype_distname}

_cbts.vdu_get_cell_handle
    &{cell_handle}    Create Dictionary
    ...    cell_lock=VDU Lock Cell
    ...    cell_unlock=VDU Unlock Cell
    ...    cell_block=VDU Block Cell
    ...    cell_unblock=VDU UnBlock Cell
    ...    cell_reset=VDU Reset Cell
    [Return]    &{cell_handle}

_cbts.vdu_cell_operation
    [Arguments]    ${operation}    ${connection}    ${distname_id}=NRCELL-1 NRCELL-2
    ...            ${timeout}=90   ${gnb_index}=${0}
        ...        ${vdu_index}=${0}    &{kwargs}
    [Documentation]    operation can be lock, unlock, block, unblock
    ...    distname_id can be NRCELL-1, or NRCEL-ALL
    log    ${timeout}
    ${celltype_distname}    _cbts.get_cell_type_by_distname_id    ${distname_id}
    &{cell_handle}    _cbts.vdu_get_cell_handle
    ${celltypes}    Get Dictionary Keys    ${celltype_distname}
    ${VDU_CELL_ID_LIST}   vDU Get Cell List From Webem
    Set Test Variable   ${VDU_CELL_ID_LIST}
    FOR    ${type}    IN    @{celltypes}
        @{cell_ids}    Set Variable    ${celltype_distname}[${type}]
        ${cell_id_str}    Catenate    @{cell_ids}
        Continue For Loop If    '${cell_id_str}'==''
        Run Keyword If    "${operation}" in ["cell_block", "cell_unblock"]
        ...    VDU Block Cell Operation    cell_handle=${cell_handle}
        ...    operation=${operation}    global_cell_id=${cell_id_str}
        ...    connection=${connection}
        ...    ELSE IF    "${operation}" in ["cell_lock", "cell_unlock"]
        ...    VDU lock Cell Operation    cell_handle=${cell_handle}
        ...    operation=${operation}    global_cell_id=${cell_id_str}
        ...    connection=${connection}
        ...    ELSE IF    "${operation}" in ["cell_reset"]
        ...    VDU Cell Reset Operation    cell_handle=${cell_handle}
        ...    operation=${operation}    global_cell_id=${cell_id_str}
        ...    connection=${connection}
    END
    Return From Keyword If    '${kwargs}[need_verify]'=='${False}'
    ${except_status}    Run Keyword If
    ...    'un' in '${operation}' or '${operation}'=='cell_reset'
    ...    set variable    on_air
    ...    ELSE
    ...    set variable    ${operation}
    ${except_status}    Run Keyword If
    ...    'cell_' in '${except_status}'
    ...    Replace String    ${except_status}    cell_    ${EMPTY}
    ...    ELSE
    ...    set variable    ${except_status}
    FOR    ${type}    IN    @{celltypes}
        @{cell_ids}    Set Variable    ${celltype_distname}[${type}]
        Wait Until Keyword Succeeds    10 min    40 sec
        ...    _cbts.vdu_verify_cell_status    connection=${connection}
        ...    cell_id_list=${cell_ids}    except_status=${except_status}
        ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    END

_cbts.vdu_verify_cell_status
    [Arguments]    ${connection}    ${cell_id_list}=1    ${except_status}=on_air
    ...            ${gnb_index}=0    ${vdu_index}=0
    [Documentation]    except_status: on_air, lock, block
    log    ${connection}
    ${cell_id_list}=    Set Variable If    "ALL" in "${cell_id_list}"    ${VDU_CELL_ID_LIST}   ${cell_id_list}
    Run Keyword If    "${except_status}"=="block"    Run Keywords
    ...    Log To Console    \n*** wait and check vdu blocked cells as expected ***    AND
    ...    vDU Blocked Cells Status Should Be As Expected    ${cell_id_list}
    ...    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...    ELSE IF     "${except_status}"=="lock"    Run Keywords
    ...    Log To Console    \n*** wait and check vdu locked cells as expected ***    AND
    ...    vDU Locked Cells Status Should Be As Expected    ${cell_id_list}
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...    ELSE IF    "${except_status}"=="on_air"    Run Keywords
    ...    Log To Console    \n*** wait and check vdu cells should be on air ***    AND
    ...    vDU Cells Status Should Be As Expected   ${cell_id_list}
    ...    gnb_index=${gnb_index}   vdu_index=${vdu_index}

################################ vdu block cell  #################################
VDU Block Cell
    [Arguments]    ${cell_id}=1    ${connection}=default
    Log To Console    \n*** start to block cell ${cell_id} ***
    ${out}    vdu.block_cell    cell_id=${cell_id}
    ...       timeout=${60}    vdu_connection=${connection}
    Wait Until Keyword Succeeds  60  5   Check Block Cell Status Should Be Expected
    ...    operation_id=${out["id"]}
    ...    expected_status=success
    ...    vdu_connection=${connection}

VDU Unblock Cell
    [Arguments]    ${cell_id}=1    ${connection}=default
    Log To Console    \n*** start to unblock cell ${cell_id} ***
    ${out}    vdu.unblock_cell    cell_id=${cell_id}
    ...       timeout=${60}    vdu_connection=${connection}
    Wait Until Keyword Succeeds  60   5   Check Unblock Cell Status Should Be Expected
    ...    operation_id=${out["id"]}
    ...    expected_status=success
    ...    vdu_connection=${connection}

Check Block Cell Status Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}    ${vdu_connection}=default
    ${out}    vdu.get_block_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...                                          vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

Check Unblock Cell Status Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}    ${vdu_connection}=default
    ${out}    vdu.get_unblock_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...                                          vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

VDU Block Cell Operation
    [Arguments]    ${cell_handle}    ${operation}
    ...    ${global_cell_id}=1       ${connection}=default
    @{cells_list}=    string.split string    ${global_cell_id}
    ${upper_global_id}    Convert To Upper Case    ${global_cell_id}
    FOR    ${cell}    IN    @{VDU_CELL_ID_LIST}
        Run Keyword If    '${upper_global_id}'=="ALL"
        ...    run keyword    ${cell_handle}[${operation}]    ${cell}    connection=${connection}
        Continue For Loop If    '${upper_global_id}'=="ALL"
        Run Keyword If    '${cell}' in ${cells_list}
        ...    run keyword    ${cell_handle}[${operation}]    ${cell}    connection=${connection}
    END

VDU Cell Reset Operation
    [Arguments]    ${cell_handle}    ${operation}
    ...    ${global_cell_id}=1       ${connection}=default
    @{cells_list}=    string.split string    ${global_cell_id}
    ${upper_global_id}    Convert To Upper Case    ${global_cell_id}
    FOR    ${cell}    IN    @{VDU_CELL_ID_LIST}
        Run Keyword If    '${upper_global_id}'=="ALL"
        ...    run keyword    ${cell_handle}[${operation}]    ${cell}    connection=${connection}
        Continue For Loop If    '${upper_global_id}'=="ALL"
        Run Keyword If    '${cell}' in ${cells_list}
        ...    run keyword    ${cell_handle}[${operation}]    ${cell}    connection=${connection}
    END

VDU Reset Cell
    [Arguments]    ${cell_id}    ${connection}=default
    Log To Console    \n*** Reset Cell By REST ***
    ${dist_name}    Get Dist Name By Cell ID    ${cell_id}    connection=${connection}
    ${out}    vdu.reset_cells    dist_name=${dist_name}    vdu_connection=${connection}
    Sleep    30s    reason=wait for cell reset

Get Dist Name By Cell ID
    [Arguments]    ${cell_id}    ${connection}
    ${cells_status}    vdu.get_vdu_cells_status    vdu_connection=${connection}
    ${dist_name}    Set Variable    ${None}
    FOR    ${cell}    IN    @{cells_status}
        ${dist_name}=    Set Variable If    '${cell["id"]}' == '${cell_id}'    ${cell["dist_names"]["config"]}
        Run Keyword If    '${cell["id"]}' == '${cell_id}'    Exit For Loop
    END
    [Return]    ${dist_name}

################################ vdu lock cell #################################
VDU lock Cell Operation
    [Arguments]    ${cell_handle}    ${operation}
    ...    ${global_cell_id}=1       ${connection}=default
    @{cells_list}=    string.split string    ${global_cell_id}
    ${upper_global_id}    Convert To Upper Case    ${global_cell_id}
    Run Keyword If    '${upper_global_id}'=="ALL"
    ...    run keyword    ${cell_handle}[${operation}]    ${VDU_CELL_ID_LIST}    vdu_connection=${connection}
    ...    ELSE
    ...    run keyword    ${cell_handle}[${operation}]    ${cells_list}    vdu_connection=${connection}

VDU Lock Cell
    [Arguments]   ${cells_id_list}    ${vdu_connection}=default
    Log To Console    \n*** start to lock cell ${cells_id_list} ***
    ${out}   vdu.Lock Cells   cell_id_list=${cells_id_list}   vdu_connection=${vdu_connection}
    Wait Until Keyword Succeeds  100   10   _Lock Cells Should Be Successful
    ...    operation_id=${out['id']}
    ...    expected_status=success
    ...    vdu_connection=${vdu_connection}

VDU Unlock Cell
    [Arguments]   ${cells_id_list}  ${vdu_connection}=default
    Log To Console    \n*** start to unlock cell ${cells_id_list} ***
    ${out}   vdu.Unlock Cells   cell_id_list=${cells_id_list}   vdu_connection=${vdu_connection}
    Wait Until Keyword Succeeds  100   10   _Unlock Cells Should Be Successful
    ...    operation_id=${out['id']}
    ...    expected_status=success
    ...    vdu_connection=${vdu_connection}

_Lock Cells Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}  ${vdu_connection}=default
    ${out}   vdu.get_operation_state_of_locking_cells   operation_id=${operation_id}  vdu_connection=${vdu_connection}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

_Unlock Cells Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}  ${vdu_connection}=default
    ${out}   vdu.get_operation_state_of_unlocking_cells   operation_id=${operation_id}  vdu_connection=${vdu_connection}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

################################ VDU cell group operation #################################
_cbts.vdu_get_cell_group_handle
    ${cell_handle}    Create Dictionary    cell_group_reset=VDU Cell Group Reset
    [Return]    ${cell_handle}

_cbts.vdu_cell_group_operation
    [Arguments]    ${operation}    ${connection}    ${gnb_index}    ${vdu_index}
    ...    ${distname_id}=NRCELLGRP-0    ${timeout}=90        &{kwargs}
    log    ${timeout}
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].dus[0].instance_id}
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/${distname_id}
    ${cell_handle}    _cbts.vdu_get_cell_group_handle
    Run Keyword    ${cell_handle}[${operation}]    dist_name=${dist_name}    vdu_connection=${connection}
    Return From Keyword If    '${kwargs['need_verify']}'=='${False}'
    ${VDU_CELL_ID_LIST}   vDU Get Cell List From Webem
    Run Keyword If    '${operation}'=='cell_group_reset'    Run Keywords
    ...    log to console    \n*** cell_group_reset done, check vdu cells should be on air ***    AND
    ...    vDU Cells Status Should Be As Expected   ${VDU_CELL_ID_LIST}
    ...    gnb_index=${gnb_index}   vdu_index=${vdu_index}

VDU Cell Group Reset
    [Arguments]    ${dist_name}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELLGRP-1
    ...            ${timeout}=30   ${vdu_connection}=default
    ${res}    vdu.trigger_cell_groups_reset   dist_name=${dist_name}   graceful_cell_shutdown=${False}
    ...    timeout=${timeout}   vdu_connection=${vdu_connection}
    sleep  5s
    ${operation_id}   Set Variable    ${res['id']}
    Wait Until Keyword Succeeds    2 min    20 sec    Check VDU Cell Group Reset Should Be Successfully
    ...    operation_id=${operation_id}
    ...    vdu_connection=${vdu_connection}

Check VDU Cell Group Reset Should Be Successfully
    [Arguments]    ${operation_id}    ${vdu_connection}=default
    ${status_operation}   vdu.get_operation_of_reset_cell_group    operation_id=${operation_id}
    ...     vdu_connection=${vdu_connection}
    should be equal    ${status_operation["status"]}    success    the operation of reset cell group failed!
################################ VDU site operation #################################
_cbts.vdu_get_site_handle
    ${handle}    Create Dictionary    vdu_reset=VDU Reset
    [Return]    ${handle}

_cbts.vdu_site_operation
    [Arguments]    ${operation}    ${connection}
    ...    ${timeout}=90    &{kwargs}
    log    ${timeout}
    ${handle}    _cbts.vdu_get_site_handle
    Run Keyword    ${handle}[${operation}]    connection=${connection}
    Return From Keyword If    '${kwargs['need_verify']}'=='${False}'
    Run Keyword If    '${operation}'=='vdu_reset'
    ...    Wait Until Keyword Succeeds    10 min    10 sec    _cbts.verify_vdu_onair    connection=${connection}

_cbts.verify_vdu_onair
    [Arguments]    ${connection}
    ${VDU_CELL_ID_LIST}   vDU Get Cell List From Webem
    ${cell_number}    Get Length    ${VDU_CELL_ID_LIST}
    ${vdu_cells_summary}=    vdu.get_vdu_cells_summary    vdu_connection=${connection}
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}    0
    Should Be Equal As Numbers
    ...    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}    0
    ${on_line}    set variable    ${vdu_cells_summary['availability_status']['on_line']}
    should be true    ${on_line}==${cell_number}

vDU Reset
    [Arguments]    ${connection}=default
    log to console  \n*** Reset VDU By REST ***
    ${out}    vdu.reset_vdu    vdu_connection=${connection}
    Dictionary Should Not Contain Key    ${out}    error_message
#    ${error_msg}    set variable  ${out["error_message"]}
#    should contain    ${error_msg}    No error
    Log To Console    \n*** Check Reset VDU Status Should Be Expected After Reset***
    ${out}    Wait Until Keyword Succeeds  60   10   Check Reset VDU Status Should Be As Expected
    ...    operation_id=${out["id"]}
    ...    vdu_connection=${connection}
    ...    expected_status=ongoing
    Sleep    30s    reason=wait for vdu reset

Check Reset VDU Status Should Be As Expected
    [Arguments]    ${operation_id}    ${vdu_connection}    ${expected_status}
    ${out}    vdu.get_reset_vdu_operation_status    operation_id=${operation_id}    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"
    [Return]    ${out}

################################ VDU component operation #################################
_cbts.vdu_get_component_handle
    ${handle}    Create Dictionary    ru_lock=VDU RU Lock
    ...    ru_unlock=VDU RU Unlock
    ...    ru_reset=VDU Rmod Reset
    ...    rannic_reset=VDU Rannic Reset
    [Return]    ${handle}

_cbts.get_rmod_distname_id
    [Arguments]    ${vdu_connection}    ${distname_id}
    ${distname_id_list}    Create List
    ${rmod_id_list}=  create list
    ${rmods_info}=   vdu.get_rmods_status    vdu_connection=${vdu_connection}
    FOR  ${rmod}  IN  @{rmods_info}
        ${result}=    Get Regexp Matches    ${rmod["dist_names"]["config"]}    RMOD-(\\d+)
        ${parts}=     Split String    ${result[0]}    -
        append to list   ${rmod_id_list}   ${parts[1]}
    END
    ${distname_id_list}=    Set Variable If    "ALL" in "${distname_id}"   ${rmod_id_list}    ${distname_id_list}
    Return From Keyword If    "ALL" in "${distname_id}"    ${distname_id_list}
    ${rmod_list}    Split String    ${distname_id}
    FOR    ${rmodid}    IN    @{rmod_list}
        ${rmod}    Split String    ${rmodid}    -
        Run Keyword If    "${rmod[1]}" in ${rmod_id_list}    Append To List    ${distname_id_list}    ${rmod[1]}
    END
    [Return]    ${distname_id_list}

_cbts.verify_ru
    [Arguments]    ${connection}    ${distname_id}    ${except_status}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${connection}
    FOR  ${ru_info}  IN  @{rmods_status}
        Run Keyword If    "${ru_info['id']}" in "${distname_id}"
        ...    Run Keyword    _cbts.ru_${except_status}    ${ru_info}
    END

_cbts.verify_rannic
    [Arguments]    ${connection}    ${rannic_r_dn}    ${except_status}
    log    ${except_status}
    log to console    \n*** Geting Rannic Info and Verify Status***
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[0].dus[0].instance_id}
    ${rannic_r_dn_full}    Set Variable    MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/${rannic_r_dn}
    ${rnics_info}=    vdu.get_rnic_info_from_plan    mrbts_id=${MRBTS_ID}    vdu_connection=${connection}
    FOR  ${rnic_info}   IN  @{rnics_info}
        Run Keyword If  "${rannic_r_dn_full}" == "${rnic_info}[r_nic_mod_dist_name]"   Run Keywords
        ...    Should be equal as strings   ${rnic_info}[operational_state]    enabled    AND
        ...    Should be equal as strings   ${rnic_info}[availability_status]    on line    AND
        ...    Should be equal as strings   ${rnic_info}[procedural_status]    configured
    END

_cbts.ru_onair
    [Arguments]    ${ru_info}
    Should be equal as strings    ${ru_info['administrative_state']}    Unlocked
    ...  msg=administrative_state for ru ${ru_info['id']} is not Unlocked
    Should be equal as strings    ${ru_info['availability_status']}    on line
    ...  msg=availability_status for ru ${ru_info['id']} is not on line
    Should be equal as strings    ${ru_info['operational_state']}    enabled
    ...  msg=operational_state for ru ${ru_info['id']} is not enabled
    Should be equal as strings    ${ru_info['procedural_status']}    configured
    ...  msg=procedural_status for ru ${ru_info['id']} is not configured

_cbts.ru_lock
    [Arguments]    ${ru_info}
    Should be equal as strings    ${ru_info['administrative_state']}    Locked
    ...  msg=administrative_state for ru ${ru_info['id']} is not Locked
    Should be equal as strings    ${ru_info['availability_status']}    on line
    ...  msg=availability_status for ru ${ru_info['id']} is not on line
    Should be equal as strings    ${ru_info['operational_state']}    enabled
    ...  msg=operational_state for ru ${ru_info['id']} is not enabled
    Should be equal as strings    ${ru_info['procedural_status']}    configured
    ...  msg=procedural_status for ru ${ru_info['id']} is not configured

_cbts._vdu_component_operation
    [Arguments]    ${operation}    ${connection}    ${distname_id}
    ...    ${timeout}=90s    ${gnb_index}=${None}    ${vdu_index}=${None}    &{kwargs}
    log    ${timeout}
    ${handle}    _cbts.vdu_get_component_handle
    ${distname_id_list}    Run Keyword If    "ru_" in '${operation}'
    ...    _cbts.get_rmod_distname_id    ${connection}    ${distname_id}
    Run Keyword If    "${operation}" in ["ru_lock", "ru_unlock", "ru_reset"]
    ...    Run Keyword    ${handle}[${operation}]    rmods_id_list=${distname_id_list}    vdu_connection=${connection}
    ...    ELSE IF   "${operation}" in ["rannic_reset"]
    ...    Run Keyword    ${handle}[${operation}]    rannic_r_dn=${distname_id}
    ...    gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}
    ...    vdu_connection=${connection}
    Return From Keyword If    '${kwargs['need_verify']}'=='${False}'
    Run Keyword If    "${operation}"=="ru_lock"
    ...    Wait Until Keyword Succeeds    5 min    10 sec    _cbts.verify_ru    connection=${connection}
    ...    distname_id=${distname_id_list}    except_status=lock
    ...    ELSE IF    "${operation}" in ["ru_unlock", "ru_reset"]
    ...    Wait Until Keyword Succeeds   5 min    20 sec    _cbts.verify_ru    connection=${connection}
    ...    distname_id=${distname_id_list}    except_status=onair
    ...    ELSE IF    "${operation}"=="rannic_reset"
    ...    Wait Until Keyword Succeeds    15 min    20 sec    _cbts.verify_rannic    connection=${connection}
    ...    rannic_r_dn=${distname_id}    except_status=onair

VDU Rmod Reset
    [Arguments]   ${rmods_id_list}   ${vdu_connection}=default
    log to console   \n*** Reset RUs ${rmods_id_list} by REST ***
    ${out}   vdu.reset_rmods     ${rmods_id_list}    vdu_connection=${vdu_connection}
    Wait Until Keyword Succeeds  600   30   _Reset RUs Status Should Be Expected
    ...    operation_id=${out["operation_id"]}
    ...    expected_status=ongoing
    ...    vdu_connection=${vdu_connection}
    Sleep    60s

_Reset RUs Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}    ${vdu_connection}
    ${out}   vdu.get_reset_rmods_operation_status   operation_id=${operation_id}    vdu_connection=${vdu_connection}
    Should Be True  "${out["status"]}"=="${expected_status}"

VDU Rannic Reset
    [Arguments]    ${rannic_r_dn}    ${gnb_index}    ${vdu_index}    ${vdu_connection}=default
    log to console  \n*** Reset Rannic By Rest Api ***
    ${MRBTS_ID}    Set Variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].instance_id}
    ${rannic_r_dn_full}    Set Variable    MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/${rannic_r_dn}
    ${out}    vdu.reset_rannic    rannic_r_dn=${rannic_r_dn_full}    vdu_connection=${vdu_connection}
    log to console  \n*** Checking Rannic Reset Operation Status ***
    Wait Until Keyword Succeeds  300s   20s   _Check Rannic Reset Status Should Be Expected
    ...    operation_id=${out["id"]}
    ...    expected_status=success
    ...    vdu_connection=${vdu_connection}

_Check Rannic Reset Status Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${vdu_connection}
    ${out}    vdu.get_rnic_reset_operation    operation_id=${operation_id}    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

VDU RU Lock
    [Arguments]   ${rmods_id_list}  ${gnb_index}=0   ${vdu_index}=0    ${vdu_connection}=default
    log    ${gnb_index}
    log    ${vdu_index}
    ${out}   vdu.lock_rmods     ${rmods_id_list}    vdu_connection=${vdu_connection}
    Wait Until Keyword Succeeds  300   10   _Lock RUs Should Be Successful
    ...    operation_id=${out["id"]}
    ...    expected_status=success
    ...    vdu_connection=${vdu_connection}

VDU RU Unlock
    [Arguments]   ${rmods_id_list}  ${gnb_index}=0   ${vdu_index}=0    ${vdu_connection}=default
    log    ${gnb_index}
    log    ${vdu_index}
    ${out}   vdu.unlock_rmods     ${rmods_id_list}    vdu_connection=${vdu_connection}
    Wait Until Keyword Succeeds  300   10   _Unlock RUs Should Be Successful
    ...    operation_id=${out["id"]}
    ...    expected_status=success
    ...    vdu_connection=${vdu_connection}

_Lock RUs Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}    ${vdu_connection}
    ${out}   vdu.get_operation_state_of_locking_rmods   operation_id=${operation_id}    vdu_connection=${vdu_connection}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

_Unlock RUs Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}    ${vdu_connection}
    ${out}   vdu.get_operation_of_unlocking_rmods   operation_id=${operation_id}    vdu_connection=${vdu_connection}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

################################ BTS VDU Status Verify #################################
_cbts.vdu_get_verify_handle
    ${handle}    Create Dictionary    verify=${None}
    [Return]    ${handle}

_cbts.vdu_verify_operation
    [Arguments]    ${operation}    ${connection}    ${verify_status}=${None}
    ...    ${distname_id}=${None}    ${timeout}=${None}    ${gnb_index}=${0}    ${vdu_index}=${0}    &{kwargs}
    ${timeout}    _base.vdu_get_time_out    ${timeout}    ${verify_status}
    log    ${operation}
    Run Keyword If    'CELL_ONAIR' in '${verify_status}'
    ...    _cbts.until cell as except status    connection=${connection}
    ...    distname_id=${distname_id}
    ...    timeout=${timeout}
    ...    gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}
    ...    except_status=on_air
    Run Keyword If    'CELL_BLOCK' in '${verify_status}'
    ...    _cbts.until cell as except status    connection=${connection}
    ...    distname_id=${distname_id}
    ...    timeout=${timeout}
    ...    gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}
    ...    except_status=block
    ...    ELSE IF    'CELL_LOCK' in '${verify_status}'
    ...    _cbts.until cell as except status    connection=${connection}
    ...    distname_id=${distname_id}
    ...    timeout=${timeout}
    ...    gnb_index=${gnb_index}
    ...    vdu_index=${vdu_index}
    ...    except_status=lock
    ...    ELSE IF    'RRU_ONAIR' in '${verify_status}'
    ...    Wait Until Keyword Succeeds   ${timeout}    5 sec
    ...    _cbts.until ru as except status    connection=${connection}
    ...    distname_id=${distname_id}    except_status=onair
    ...    ELSE IF    'RRU_LOCK' in '${verify_status}'
    ...    Wait Until Keyword Succeeds   ${timeout}    5 sec
    ...    _cbts.until ru as except status    connection=${connection}
    ...    distname_id=${distname_id}    except_status=lock

_base.vdu_get_time_out
    [Arguments]    ${timeout}    ${status}
    Return From Keyword If   '${timeout}' !='${None}'    ${timeout}
    ${default_timeout}    Create Dictionary
    ...    CELL_LOCK=${5}
    ...    CELL_ONAIR=${15}
    ...    CELL_BLOCK=${5}
    ...    RRU_ONAIR=${10}
    ...    RRU_LOCK=${5}
    ...    SITE_ONAIR=${10}
    ${except_time}    Set Variable    ${5}
    ${status_list}    Split String    ${status}     +
    FOR    ${sta}    IN    @{status_list}
        ${except_time}    Run Keyword If    ${except_time} < ${default_timeout}[${sta}]
        ...    Set Variable    ${default_timeout}[${sta}]
        ...    ELSE
        ...    Set Variable    ${except_time}
    END
   ${except_time}    Convert To String    ${except_time}
    [Return]    ${except_time} min

_cbts.until cell as except status
    [Arguments]    ${connection}    ${distname_id}=${None}    ${timeout}=${None}
    ...            ${gnb_index}=${0}    ${vdu_index}=${0}    ${except_status}=on_air
    ${celltype_distname}    Run Keyword If    '${distname_id}'!='${None}'
    ...    _cbts.get_cell_type_by_distname_id    ${distname_id}
    ...    ELSE
    ...    Create Dictionary    nr=ALL
    ${timeout}    Run Keyword If    '${timeout}'=='${None}' and '${except_status}'=='on_air'
    ...    Set Variable    15 min
    ...    ELSE IF    '${timeout}'=='${None}' and '${except_status}'!='on_air'
    ...    Set Variable    5 min
    ...    ELSE    Set Variable    ${timeout}
    ${celltypes}    Get Dictionary Keys    ${celltype_distname}
    ${VDU_CELL_ID_LIST}   vDU Get Cell List From Webem
    Set Test Variable   ${VDU_CELL_ID_LIST}
    FOR    ${type}    IN    @{celltypes}
        ${cell_ids}    Set Variable    ${celltype_distname}[${type}]
        Wait Until Keyword Succeeds    ${timeout}    20 sec
        ...    _cbts.vdu_verify_cell_status    connection=${connection}
        ...    cell_id_list=${cell_ids}    except_status=${except_status}
        ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    END

_cbts.until ru as except status
    [Arguments]    ${connection}    ${distname_id}    ${except_status}
    ${distname_id_list}    _cbts.get_rmod_distname_id    ${connection}    ${distname_id}
    ${rmods_status}    vdu.get_rmods_status    vdu_connection=${connection}
    FOR  ${ru_info}  IN  @{rmods_status}
        Run Keyword If    "${ru_info['id']}" in "${distname_id_list}"
        ...    Run Keyword    _cbts.ru_${except_status}    ${ru_info}
    END

################################ BTS Operation VCU Part #################################
Cloud BTS Operation for VCU
    [Arguments]    ${operation}
    ...    ${gnb_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${distname_id}=${None}
    ...    ${need_verify}=${True}
    ...    ${verify_status}=${None}
    ...    ${timeout}=90s
    ...    &{kwargs}
    ${connection}    _cbts.vcu_login
    ...    gnb_index=${gnb_index}
    ...    alias=${operation}
    ${supported_operation_type}    Create List    cell    cell_group    site    link    verify
    ${is_supported_operation}    Set Variable    ${None}
    FOR    ${operation_type}    IN    @{supported_operation_type}
        ${is_supported_operation}    _cbts.vcu_is_supported_operation
        ...    ${operation_type}
        ...    ${operation}
        Run Keyword If    ${is_supported_operation}
        ...    Run Keyword    _cbts.vcu_${operation_type}_operation    ${operation}
        ...    connection=${connection}
        ...    distname_id=${distname_id}
        ...    gnb_index=${gnb_index}
        ...    vdu_index=${cudu_index}
        ...    need_verify=${need_verify}
        ...    verify_status=${verify_status}
        ...    timeout=${timeout}
        Exit For Loop If    ${is_supported_operation}
    END
    Run Keyword If
    ...     '${is_supported_operation}'=='${None}' or '${is_supported_operation}'=='${False}'
    ...    Fail    msg=Your operation does not support yet. Please contact the module owner.
    [Teardown]    Run Keyword And Ignore Error    _cbts.vcu_logout    alias=${connection}

_cbts.vcu_login
    [Arguments]    ${alias}=default    ${gnb_index}=${0}
    cu.connect to    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}

_cbts.vcu_logout
    [Arguments]    ${alias}=default
    cu.disconnect    ${alias}

_cbts.vcu_is_supported_operation
    [Arguments]    ${handle_type}    ${operation}
    ${handle}    Run Keyword    _cbts.vcu_get_${handle_type}_handle
    ${is_needed_operation}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${handle}    ${operation}
    [Return]    ${is_needed_operation}

################################ VCU link operation #################################
_cbts.vcu_get_link_handle
    ${handle}    Create Dictionary    nglink_lock=VCU Lock NG Links
    ...    nglink_unlock=VCU Unlock NG Links
    ...    xnlink_lock=VCU Lock Xn Link
    ...    xnlink_unlock=VCU Unlock Xn Link
    ...    x2link_lock=VCU Lock X2 Link
    ...    x2link_unlock=VCU Unlock X2 Link
    [Return]    ${handle}

_cbts.vcu_link_operation
    [Arguments]    ${operation}    ${connection}    ${distname_id}
    ...    ${vdu_index}    ${gnb_index}    &{kwargs}
    ${handle}    _cbts.vcu_get_link_handle
    Run Keyword    ${handle}[${operation}]    ${distname_id}
    ...            ${vdu_index}    ${gnb_index}    ${connection}
    Return From Keyword If    '${kwargs['need_verify']}'=='${False}'
    Run Keyword If    "${operation}"=="nglink_lock"
    ...    Run Keywords    Log To Console    \n*** checking NG links Should Be Locked ***    AND
    ...    Wait Until Keyword Succeeds  240s  30s
    ...    Status of Given NG Links Should Be As Expected
    ...    ng_links_ids=${ng_links_id_list}
    ...    expected_ng_link_status=Inactive
    ...    expected_administrative_state=Locked
    ...    gnb_index=${gnb_index}
    ...    conn_alias=${connection}
    ...    ELSE IF    "${operation}"=="nglink_unlock"
    ...    Run keywords    Log To Console    \n*** checking NG links Should Be Unlocked ***    AND
    ...    Wait Until Keyword Succeeds  240s  30s
    ...    Status of Given NG Links Should Be As Expected
    ...    ng_links_ids=${ng_links_id_list}
    ...    expected_ng_link_status=Active
    ...    expected_administrative_state=Unlocked
    ...    gnb_index=${gnb_index}
    ...    conn_alias=${connection}

VCU Lock NG Links
    [Arguments]             ${distname_id}    ${vdu_index}    ${gnb_index}    ${connection}
    log    ${gnb_index}
    log    ${vdu_index}
    ${ng_links_id_list}=    _cbts.get_nglink_id    ${distname_id}    connection=${connection}
    Set Test Variable    ${ng_links_id_list}
    cu.lock_ng_links    ng_links_ids=${ng_links_id_list}    connection=${connection}

VCU Unlock NG Links
    [Arguments]             ${distname_id}    ${vdu_index}    ${gnb_index}    ${connection}
    log    ${gnb_index}
    log    ${vdu_index}
    ${ng_links_id_list}=    _cbts.get_nglink_id    ${distname_id}    connection=${connection}
    Set Test Variable    ${ng_links_id_list}
    cu.unlock_ng_links    ng_links_ids=${ng_links_id_list}    connection=${connection}

_cbts.get_nglink_id
    [Arguments]        ${distname_id}    ${connection}
    ${distname_id_list}    Create List
    ${nglink_id_list}=  create list
    ${nglinks_info}=   cu.get_ng_links_info    connection=${connection}
    FOR  ${nglink}  IN  @{nglinks_info}
        append to list   ${nglink_id_list}   ${nglink["served_amf_id"]}
    END
    ${distname_id_list}=    Set Variable If    "ALL" in "${distname_id}"   ${nglink_id_list}    ${distname_id_list}
    Return From Keyword If    "ALL" in "${distname_id}"    ${distname_id_list}
    ${nglink_list}    Split String    ${distname_id}
    FOR    ${nglink_id}    IN    @{nglink_list}
        ${nglink}    Split String    ${nglink_id}    -
        Run Keyword If    "${nglink[1]}" in ${nglink_id_list}    Append To List    ${distname_id_list}    ${nglink[1]}
    END
    [Return]    ${distname_id_list}

VCU Lock Xn Link
    [Arguments]     ${distname_id}    ${vdu_index}    ${gnb_index}    ${connection}
    log    ${gnb_index}
    log    ${vdu_index}
    ${xn_links_id_list}=    Convert Distname ID to List    ${distname_id}
    cu.lock_xn_links    xn_links_ids=${xn_links_id_list}    connection=${connection}

VCU Unlock Xn Link
    [Arguments]      ${distname_id}    ${vdu_index}    ${gnb_index}    ${connection}
    log    ${gnb_index}
    log    ${vdu_index}
    ${xn_links_id_list}=    Convert Distname ID to List    ${distname_id}
    cu.unlock_xn_links    xn_links_ids=${xn_links_id_list}    connection=${connection}

Convert Distname ID to List
    [Arguments]    ${distname_id}
    ${id_list}=    Create List
    ${id}=    Split String    ${distname_id}    -    1
    Append To List    ${id_list}    ${id[1]}
    [Return]    ${id_list}
################################ VCU cell operation #################################
_cbts.vcu_get_cell_handle
    &{cell_handle}    Create Dictionary
    ...    cell_lock=VCU Lock Cell
    ...    cell_unlock=VCU Unlock Cell
    ...    cell_reset=VCU Reset Cell
    [Return]    &{cell_handle}

_cbts.vcu_cell_operation
    [Arguments]    ${operation}    ${connection}    ${distname_id}=NRCELL-1 NRCELL-2
    ...            ${timeout}=90   ${gnb_index}=${0}
        ...        ${vdu_index}=${0}    &{kwargs}
    [Documentation]    operation can be lock, unlock, block, unblock
    ...    distname_id can be NRCELL-1, or NRCEL-ALL
    log    ${timeout}
    log    ${vdu_index}
    ${celltype_distname}    _cbts.get_cell_type_by_distname_id    ${distname_id}
    &{cell_handle}    _cbts.vcu_get_cell_handle
    ${celltypes}    Get Dictionary Keys    ${celltype_distname}
    ${VCU_CELL_ID_LIST}   vCU Get Cell List From Webem    gnb_index=${gnb_index}
    Set Test Variable   ${VCU_CELL_ID_LIST}
    FOR    ${type}    IN    @{celltypes}
        @{cell_ids}    Set Variable    ${celltype_distname}[${type}]
        ${cell_id_str}    Catenate    @{cell_ids}
        Continue For Loop If    '${cell_id_str}'==''
        Run Keyword If    "${operation}" in ["cell_lock", "cell_unlock"]
        ...    VCU lock Cell Operation    cell_handle=${cell_handle}
        ...    operation=${operation}    global_cell_id=${cell_id_str}
        ...    connection=${connection}
        ...    ELSE IF    "${operation}" in ["cell_reset"]
        ...    VCU Cell Reset Operation    cell_handle=${cell_handle}
        ...    operation=${operation}    global_cell_id=${cell_id_str}
        ...    connection=${connection}
    END
    Return From Keyword If    '${kwargs}[need_verify]'=='${False}'
    ${except_status}    Run Keyword If
    ...    'un' in '${operation}' or '${operation}'=='cell_reset'
    ...    set variable    on_air
    ...    ELSE
    ...    set variable    ${operation}
    ${except_status}    Run Keyword If
    ...    'cell_' in '${except_status}'
    ...    Replace String    ${except_status}    cell_    ${EMPTY}
    ...    ELSE
    ...    set variable    ${except_status}
    FOR    ${type}    IN    @{celltypes}
        @{cell_ids}    Set Variable    ${celltype_distname}[${type}]
        Wait Until Keyword Succeeds    4 min    50 sec
        ...    _cbts.vcu_verify_cell_status    connection=${connection}
        ...    cell_id_list=${cell_ids}    except_status=${except_status}
        ...    gnb_index=${gnb_index}
    END

_cbts.vcu_verify_cell_status
    [Arguments]    ${connection}    ${cell_id_list}=1    ${except_status}=on_air
    ...            ${gnb_index}=0
    [Documentation]    except_status: on_air, lock
    log    ${connection}
    ${cell_id_list}=    Set Variable If    "ALL" in "${cell_id_list}"    ${VCU_CELL_ID_LIST}   ${cell_id_list}
    FOR    ${cell_id}    IN    @{cell_id_list}
        Run Keyword If    "${except_status}"=="lock"    Run Keywords
        ...    Log To Console    \n*** wait check vcu locked cell ${cell_id} as expected ***    AND
        ...    vCU Cell Status Should Be Locked    ${cell_id}    gnb_index=${gnb_index}
        ...    ELSE IF    "${except_status}"=="on_air"    Run Keywords
        ...    Log To Console    \n*** wait and check vcu cell ${cell_id} should be on air ***    AND
        ...    vCU Cell Status Should Be Unlocked   ${cell_id}    gnb_index=${gnb_index}
    END

VCU lock Cell Operation
    [Arguments]    ${cell_handle}    ${operation}
    ...    ${global_cell_id}=1       ${connection}=COAM
    @{cells_list}=    string.split string    ${global_cell_id}
    ${upper_global_id}    Convert To Upper Case    ${global_cell_id}
    Run Keyword If    '${upper_global_id}'=="ALL"
    ...    run keyword    ${cell_handle}[${operation}]    ${VCU_CELL_ID_LIST}    connection=${connection}
    ...    ELSE
    ...    Run Keyword    ${cell_handle}[${operation}]    ${cells_list}    connection=${connection}

VCU Lock Cell
    [Arguments]    ${cells_id_list}    ${connection}=default
    Log To Console    \n*** locking vcu cell ***
    ${operation_id}   vcu_ope_business.lock_cell_on_vcu    cell_id_list=${cells_id_list}    conn_alias=${connection}
    vcu_ope_business.lock_cell_on_vcu_should_be_success    operation_id=${operation_id}    conn_alias=${connection}

VCU Unlock Cell
    [Arguments]    ${cells_id_list}    ${connection}=default
    Log To Console    \n*** unlocking vcu cell ***
    ${operation_id}   vcu_ope_business.unlock_cell_on_vcu    cell_id_list=${cells_id_list}    conn_alias=${connection}
    vcu_ope_business.unlock_cell_on_vcu_should_be_success    operation_id=${operation_id}    conn_alias=${connection}

VCU Cell Reset Operation
    [Arguments]    ${cell_handle}    ${operation}
    ...    ${global_cell_id}=1       ${connection}=default
    @{cells_list}=    string.split string    ${global_cell_id}
    ${upper_global_id}    Convert To Upper Case    ${global_cell_id}
    FOR    ${cell}    IN    @{VCU_CELL_ID_LIST}
        Run Keyword If    '${upper_global_id}'=="ALL"
        ...    run keyword    ${cell_handle}[${operation}]    ${cell}    connection=${connection}
        Continue For Loop If    '${upper_global_id}'=="ALL"
        Run Keyword If    '${cell}' in ${cells_list}
        ...    run keyword    ${cell_handle}[${operation}]    ${cell}    connection=${connection}
    END

VCU Reset Cell
    [Arguments]    ${cell_id}    ${connection}=default
    Log To Console    \n*** Reset Cell By REST ***
    ${dist_name}    VCU Get Dist Name By Cell ID    ${cell_id}    connection=${connection}
    ${out}    cu.reset_cells    dist_name=${dist_name}    connection=${connection}
    Sleep    30s    reason=wait for cell reset

VCU Get Dist Name By Cell ID
    [Arguments]    ${cell_id}    ${connection}
    ${cells_status}    cu.get_cells_statuses    connection=${connection}
    ${dist_name}    Set Variable    ${None}
    FOR    ${cell}    IN    @{cells_status}
        ${dist_name}=    Set Variable If    '${cell["id"]}' == '${cell_id}'    ${cell["dist_names"]["config"]}
        Run Keyword If    '${cell["id"]}' == '${cell_id}'    Exit For Loop
    END
    [Return]    ${dist_name}
################################ VDU site operation #################################
_cbts.vcu_get_site_handle
    ${handle}    Create Dictionary
    ...          vcu_reset=VCU Reset
    ...          vdu_lock=VDU Lock
    ...          vdu_unlock=VDU Unlock
    [Return]    ${handle}

_cbts.vcu_site_operation
    [Arguments]    ${operation}    ${connection}    ${vdu_index}    ${gnb_index}
    ...    ${timeout}=90    &{kwargs}
    log    ${gnb_index}
    log    ${timeout}
    ${handle}    _cbts.vcu_get_site_handle
    Run Keyword    ${handle}[${operation}]    ${vdu_index}    connection=${connection}
    Return From Keyword If    '${kwargs['need_verify']}'=='${False}'
    Run Keyword If    '${operation}'=='vcu_reset'
    ...    Wait Until Keyword Succeeds    10 min    10 sec    _cbts.verify_vcu_onair    connection=${connection}

_cbts.verify_vcu_onair
    [Arguments]  ${gnb_index}=0    ${connection}=default
    ${cells_summary}=   cu.get_cells_summary   connection=${connection}
    ${cell_list}  VCU Get Cell List From Webem   gnb_index=${gnb_index}
    ${cell_numbers}    Get Length   ${cell_list}
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["shutting_down"]}   0
    ...    Some cells are shutting down!
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}   0
    ...    Some cells are locked!
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["operational_state"]["disabled"]}    0
    ...    Some cells are disabled!
    run keyword and continue on failure  should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["operational_state"]["enabled"]}    ${cell_numbers}
    ...    Some cells are disabled!

VCU Reset
    [Arguments]    ${vdu_index}    ${connection}=default
    Log    ${vdu_index}
    log to console  \n*** Reset CU By REST ***
    ${out}  cu.reset_cu  connection=${connection}
#    ${error_msg}   set variable  ${out["error_message"]}
#    Should Be True   """${error_msg}"""=="""${None}"""
    Sleep    20s    reason=wait for vcu to restart

VDU Lock
    [Arguments]    ${vdu_index}    ${connection}=default
    log to console  \n*** Lock VDU By REST ***
    ${vdu_index_str}    Convert To String    ${vdu_index}
    ${vdu_index_list}    Create List    ${vdu_index_str}
    ${out}  cu.lock_du  du_id=${vdu_index_list}    connection=${connection}
    Wait Until Keyword Succeeds  100   10   _Lock VDU Should Be Successful
    ...    operation_id=${out['id']}
    ...    expected_status=success
    ...    connection=${connection}

_Lock VDU Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}  ${connection}=default
    ${out}   cu.get_opeartion_state_of_locking_du   operation_id=${operation_id}  connection=${connection}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

VDU UnLock
    [Arguments]    ${vdu_index}    ${connection}=default
    log to console  \n*** Unlock VDU By REST ***
    ${vdu_index_str}    Convert To String    ${vdu_index}
    ${vdu_index_list}    Create List    ${vdu_index_str}
    ${out}  cu.unlock_du  du_id=${vdu_index_list}    connection=${connection}
    Wait Until Keyword Succeeds  100   10   _Unlock VDU Should Be Successful
    ...    operation_id=${out['id']}
    ...    expected_status=success
    ...    connection=${connection}

_Unlock VDU Should Be Successful
    [Arguments]  ${operation_id}   ${expected_status}  ${connection}=default
    ${out}   cu.get_opeartion_state_of_unlocking_du   operation_id=${operation_id}  connection=${connection}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}
################################ VCU Cell Group Operation #################################
_cbts.vcu_get_cell_group_handle
    ${cell_handle}    Create Dictionary
    ...    cell_group_lock=VCU Cell Group Lock
    ...    cell_group_unlock=VCU Cell Group Unlock
    [Return]    ${cell_handle}

_cbts.vcu_cell_group_operation
    [Arguments]    ${operation}    ${connection}    ${gnb_index}    ${vdu_index}
    ...    ${distname_id}=NRCELLGRP-1    ${timeout}=90        &{kwargs}
    log    ${vdu_index}
    log    ${timeout}
    ${cell_handle}    _cbts.vcu_get_cell_group_handle
    Run Keyword    ${cell_handle}[${operation}]    dist_name=${distname_id}    connection=${connection}
    Return From Keyword If    '${kwargs['need_verify']}'=='${False}'
    ${result_cell_summary}    cu.get_cells_statuses    connection=${connection}
    FOR    ${item}    IN    @{result_cell_summary}
        Run Keyword If    "${item['cell_group_id']}" in ${cell_group_id} and '${operation}'=='cell_group_lock'
        ...    _cbts.vcu_until cell as except status    connection=${connection}
        ...    distname_id=${item['dist_names']['config'].split('/')[-1]}
        ...    gnb_index=${gnb_index}
        ...    except_status=lock
        ...    ELSE IF    "${item['cell_group_id']}" in ${cell_group_id} and '${operation}'=='cell_group_unlock'
        ...    _cbts.vcu_until cell as except status    connection=${connection}
        ...    distname_id=${item['dist_names']['config'].split('/')[-1]}
        ...    gnb_index=${gnb_index}
        ...    except_status=on_air
    END

VCU Cell Group Lock
    [Arguments]    ${dist_name}=NRCELLGRP-1    ${timeout}=30   ${connection}=default
    log    ${timeout}
    ${cell_group_id}    _cbts.vcu_get_cell_group_distname_id    ${dist_name}
    Set Test Variable    ${cell_group_id}
    Log To Console    \n*** start to lock cell group  ${cell_group_id} ***
    ${res}    cu.lock_cell_group   cell_group_id=${cell_group_id}   connection=${connection}

VCU Cell Group Unlock
    [Arguments]    ${dist_name}=NRCELLGRP-1    ${timeout}=30   ${connection}=default
    log    ${timeout}
    ${cell_group_id}    _cbts.vcu_get_cell_group_distname_id    ${dist_name}
    Set Test Variable    ${cell_group_id}
    Log To Console    \n*** start to unlock cell group  ${cell_group_id} ***
    ${res}    cu.unlock_cell_group   cell_group_id=${cell_group_id}    connection=${connection}

_cbts.vcu_get_cell_group_distname_id
    [Arguments]    ${distname_id}
    ${distname_id_list}    Create List
    ${prefix}    ${cell_group_id}=    string.Split String From Right    ${distname_id}    separator=-    max_split=${1}
    append to list    ${distname_id_list}    ${cell_group_id}
    [Return]    ${distname_id_list}

################################ BTS VCU Status Verify #################################
_cbts.vcu_get_verify_handle
    ${handle}    Create Dictionary    verify=${None}
    [Return]    ${handle}

_cbts.vcu_verify_operation
    [Arguments]    ${operation}    ${connection}    ${verify_status}=${None}
    ...    ${distname_id}=${None}    ${timeout}=${None}    ${gnb_index}=${0}    ${vdu_index}=${0}    &{kwargs}
    log    ${operation}
    log    ${vdu_index}
    Run Keyword If    'CELL_ONAIR' in '${verify_status}'
    ...   _cbts.vcu_until cell as except status    connection=${connection}
    ...    distname_id=${distname_id}
    ...    timeout=${timeout}
    ...    gnb_index=${gnb_index}
    ...    except_status=on_air
    ...    ELSE IF    'CELL_LOCK' in '${verify_status}'
    ...   _cbts.vcu_until cell as except status    connection=${connection}
    ...    distname_id=${distname_id}
    ...    timeout=${timeout}
    ...    gnb_index=${gnb_index}
    ...    except_status=lock

_cbts.vcu_until cell as except status
    [Arguments]    ${connection}    ${distname_id}=${None}    ${timeout}=90s
    ...            ${gnb_index}=${0}    ${except_status}=on_air
    ${celltype_distname}    Run Keyword If    '${distname_id}'!='${None}'
    ...    _cbts.get_cell_type_by_distname_id    ${distname_id}
    ...    ELSE
    ...    Create Dictionary    nr=ALL
    ${celltypes}    Get Dictionary Keys    ${celltype_distname}
    ${VCU_CELL_ID_LIST}   vCU Get Cell List From Webem
    Set Test Variable   ${VCU_CELL_ID_LIST}
    FOR    ${type}    IN    @{celltypes}
        ${cell_ids}    Set Variable    ${celltype_distname}[${type}]
        ${timeout}    Set Variable If    '${timeout}'=='${None}'    240s    ${timeout}
        Wait Until Keyword Succeeds    ${timeout}    20 sec
        ...    _cbts.vcu_verify_cell_status    connection=${connection}
        ...    cell_id_list=${cell_ids}    except_status=${except_status}
        ...    gnb_index=${gnb_index}
    END
