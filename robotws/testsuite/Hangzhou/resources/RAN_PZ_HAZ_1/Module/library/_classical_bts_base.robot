*** Settings ***
Documentation
...    Author: He winnie
...    Contact: winnie.he@nokia-sbell.com
...    Common KWs use to operate the bts
Library             BuiltIn
Library             Collections
Library             DateTime
Library             json
Library             OperatingSystem
Library             Process
Library             String
Library             taf.sbts.oam.coam.admin    WITH NAME    coam
Library             taf.fdsw.rc   WITH NAME    rc
Library             bts_worker/bts_base.py       WITH NAME    bts_base
Library             bts_worker/tool_for_ping.py     WITH NAME    tool_for_ping
Library             bts_worker/downloads.py     WITH NAME    wft_sw
Resource            ../Alarm_Operation.robot
Library             ./module_utils/module_utils.py
Library             taf.transport.ssh    WITH NAME    transport_ssh

*** Keywords ***
Classical BTS Operation
    [Arguments]    ${operation}
    ...    ${product_type}=gnb
    ...    ${gnb_index}=${0}
    ...    ${cudu_index}=${0}
    ...    ${distname_id}=${None}
    ...    ${need_verify}=${True}
    ...    ${connection}=${None}
    ...    ${verify_status}=${None}
    ...    ${timeout}=${None}
    ...    &{kwargs}
    ${origin_conn}    Set Variable    ${connection}
    ${is_input_oam_ip}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}[kwargs]    oam_ip
    ${oam_ip}    Set Variable If    ${is_input_oam_ip}    ${kwargs['kwargs']['oam_ip']}    ${None}
    ${connection}     _bts.login    connection=${connection}
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${operation}
    ...    oam_ip=${oam_ip}
    ${supported_operation_type}    Create List    cell    site    rat    cell_group
    ...    component    link    verify    reset_configuration    upgrade    downgrade     rollback
    ${is_supported_operation}    Set Variable    ${None}
    FOR    ${operation_type}    IN    @{supported_operation_type}
        ${is_supported_operation}    _bts.is_supported_operation    ${operation_type}
        ...        ${operation}
        Run Keyword If    ${is_supported_operation}
        ...    Run Keyword    _bts.${operation_type}_operation    ${operation}
        ...    connection=${connection}
        ...    distname_id=${distname_id}
        ...    du_index=${cudu_index}
        ...    need_verify=${need_verify}
        ...    verify_status=${verify_status}
        ...    timeout=${timeout}
        ...    &{kwargs['kwargs']}
        Exit For Loop If    ${is_supported_operation}
    END
    Run Keyword If
    ...     '${is_supported_operation}'=='${None}' or '${is_supported_operation}'=='${False}'
    ...    Fail    msg=Your operation no support yet. Please contact the model owner.
    [Teardown]    Run Keyword And Ignore Error   _bts.logout    connection=${connection}


_bts.attribute available
    [Arguments]    ${obj}    ${attr}
    ${is_existed}    Run Keyword And Return Status  Set Variable    ${obj.${attr}}
    ${validate}    Run Keyword If    ${is_existed}
    ...    Run Keyword And Return Status    Should Be True    ${obj.${attr} is not ${None}}
    ...    ELSE    Set Variable    ${False}
    [Return]    ${validate}

_bts.login
    [Arguments]    ${connection}=${None}    ${product_type}=gnb    ${alias}=default    ${gnb_index}=${0}
    ...    ${oam_ip}=${None}
    Log    ${oam_ip} is not used
    Return From Keyword If    '${connection}'!='${None}'    ${connection}
    ${site_info}    get_site_info    product_type=${product_type}
    ...    info_type=oam
    ...    bts_index=${gnb_index}
    coam.connect_to    bts_host=${site_info.addr}
    ...    username=${site_info.username}
    ...    password=${site_info.password}
    ...    admin_api_log_dir=${OUTPUT_DIR}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    name=${alias}
    [Return]    ${alias}

_bts.logout
    [Arguments]    ${connection}=${None}
    coam.teardown    connection=${connection}
    [Return]    ${connection}

_bts.is_supported_operation
    [Arguments]    ${handle_type}    ${operation}
    ${handle}    Run Keyword    _bts.get_${handle_type}_handle
    ${is_needed_operation}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${handle}    ${operation}
    [Return]    ${is_needed_operation}

################################ BTS cell operation #################################
_bts.get_cell_type_by_distname_id
    [Arguments]    ${distname_id}
    ${nr_distnameid_list}    Create List
    ${lte_distnameid_list}    Create List
    ${wcdma_distnameid_list}    Create List
    ${distnameid_list}    Split String    ${distname_id}
    FOR    ${distnameid}    IN    @{distnameid_list}
        ${celltype_cellid}    Split String    ${distnameid}    -
        Run Keyword If    'NRCELL' in '${distname_id}'
        ...    Append To List    ${nr_distnameid_list}
        ...    ${celltype_cellid}[-1]
        Run Keyword If    'LNCEL' in '${distname_id}'
        ...    Append To List    ${lte_distnameid_list}
        ...    ${celltype_cellid}[-1]
        Run Keyword If    'WNCEL' in '${distname_id}'
        ...    Append To List    ${wcdma_distnameid_list}
        ...    ${celltype_cellid}[-1]
    END
    ${celltype_distname}    Create Dictionary
    Run Keyword If    ${nr_distnameid_list}    Set To Dictionary    ${celltype_distname}    nr=${nr_distnameid_list}
    Run Keyword If    ${lte_distnameid_list}   Set To Dictionary    ${celltype_distname}    lte=${lte_distnameid_list}
    Run Keyword If    ${wcdma_distnameid_list}    Set To Dictionary    ${celltype_distname}    wcdma=${wcdma_distnameid_list}
    [Return]    ${celltype_distname}

_bts.get_cell_handle
    ${cell_handle}    Create Dictionary    cell_lock=lock
    ...    cell_unlock=unlock
    ...    cell_block=block_cell
    ...    cell_unblock=unblock_cell
    ...    cell_reset=reset_cell
    [Return]    ${cell_handle}

_bts.get_upgrade_handle
    ${upgrade_handle}    Create Dictionary    upgrade=upgrade
    [Return]    ${upgrade_handle}

_bts.get_downgrade_handle
    ${downgrade_handle}    Create Dictionary    downgrade=downgrade
    [Return]    ${downgrade_handle}

_bts.get_rollback_handle
    ${downgrade_handle}    Create Dictionary    rollback=rollback
    [Return]    ${downgrade_handle}


_bts.get_cell_interal_id
    [Arguments]    ${cell_info}    ${obj_cells_list}=${None}
    ${cell_distname_id}    Create List
    ${has_obj_cell}    Evaluate    ${obj_cells_list}==${None}
    FOR    ${cell}    IN    @{cell_info}
        Run Keyword If    ${has_obj_cell}
        ...    Run Keywords    Append To List    ${cell_distname_id}    ${cell['id']['internal']}
        ...    AND
        ...    Continue For Loop
        ${prefix}    ${cell_full_id}=    string.Split String From Right    ${cell['id']['configuration']}    separator=/    max_split=${1}
        ${prefix}    ${cell_id}=    string.Split String From Right    ${cell_full_id}    separator=-    max_split=${1}
        Run Keyword If    '${cell_id}' in @{obj_cells_list}
        ...    Append To List    ${cell_distname_id}    ${cell['id']['internal']}
    END
    [Return]    ${cell_distname_id}

_bts.One Cell Operation
    [Arguments]    ${operation}
    ...    ${global_cell_id}=1    ${cell_type}=nr    ${connection}=COAM
    ${cells_list}=    string.split string    ${global_cell_id}
    ${cell_info}=    coam.get_cells_info    cell_type=${cell_type}   connection=${connection}
    ${upper_global_id}    Convert To Upper Case    ${global_cell_id}
    ${upper_cell_type}    Convert To Upper Case    ${cell_type}
    ${all_cell_distname_id}     Run Keyword If    '${upper_global_id}'=="ALL"
    ...    _bts.get_cell_interal_id    ${cell_info}
    ...    ELSE
    ...    _bts.get_cell_interal_id    ${cell_info}    ${cells_list}
    Run Keyword If    ("lock"=='${operation}' or 'unlock'=='${operation}')
    ...    Run Keywords    coam.${operation}    ${all_cell_distname_id}    connection=${connection}
    ...    timeout=60
    ...    AND    Set Test Variable    ${operation_with_all}    ${True}
    ...    ELSE    Set Test Variable    ${operation_with_all}    ${False}
    Run Keyword If    "block_cell"=='${operation}' and '${upper_global_id}'=="ALL"
    ...    Run Keywords    coam.block_all_cells    ${upper_cell_type}    connection=${connection}
    ...    timeout=60
    ...    AND    Set Test Variable    ${operation_with_all}    ${True}
    ...    ELSE    Set Test Variable    ${operation_with_all}    ${False}
    Run Keyword If    'unblock_cell'=='${operation}' and '${upper_global_id}'=="ALL"
    ...    Run Keywords    coam.unblock_all_cells    ${upper_cell_type}    connection=${connection}
    ...    timeout=60
    ...    AND    Set Test Variable    ${operation_with_all}    ${True}
    ...    ELSE    Set Test Variable    ${operation_with_all}    ${False}
    Run Keyword If    'reset_cell'=='${operation}' and '${upper_global_id}'=="ALL"
    ...    Run Keywords    coam.reset_all_cells    ${upper_cell_type}    connection=${connection}
    ...    timeout=60
    ...    AND    Set Test Variable    ${operation_with_all}    ${True}
    ...    ELSE    Set Test Variable    ${operation_with_all}    ${False}
    Return From Keyword If    '${operation_with_all}'=='${True}'
    FOR    ${cell}    IN    @{cell_info}
        ${prefix}    ${cell_full_id}=    string.Split String From Right    ${cell['id']['configuration']}    separator=/    max_split=${1}
        ${prefix}    ${cell_id}=    string.Split String From Right    ${cell_full_id}    separator=-    max_split=${1}
        Run Keyword If    '${cell_id}' in @{cells_list}    run keywords
        ...    Log To Console    \n ${operation} cell ${cell_full_id}
        ...    AND    coam.${operation}    ${cell['id']['internal']}    connection=${connection}
        ...    timeout=60
    END

_bts.cell_operation
    [Arguments]    ${operation}    ${connection}    ${distname_id}=LNCELL-1 NRCELL-1
    ...    ${timeout}=${None}    &{kwargs}
    [Documentation]    operation can be lock, unlock, block, unblock, or reset_cell
    ...    distname_id can be LNCELL-ALL, or WNCEL-ALL
    ${celltype_distname}    _bts.get_cell_type_by_distname_id    ${distname_id}
    ${cell_handle}    _bts.get_cell_handle
    ${celltypes}    Get Dictionary Keys    ${celltype_distname}
    FOR    ${type}    IN    @{celltypes}
        ${cell_ids}    Set Variable    ${celltype_distname}[${type}]
        ${cell_id_str}    Catenate    @{cell_ids}
        Continue For Loop If    '${cell_id_str}'==''
        _bts.One Cell Operation    operation=${cell_handle}[${operation}]    global_cell_id=${cell_id_str}
        ...    cell_type=${type}
        ...    connection=${connection}
    END
    Return From Keyword If    '${kwargs}[need_verify]'=='${False}'
    ${except_status}    Run Keyword If
    ...    'un' in '${operation}' or 'reset' in '${operation}'
    ...    set variable    onair
    ...    ELSE
    ...    set variable    ${operation}
    ${except_status}    Run Keyword If
    ...    'cell_' in '${except_status}'
    ...    Replace String    ${except_status}    cell_    ${EMPTY}
    ...    ELSE
    ...    set variable    ${except_status}
    ${timeout}    Set Variable If    '${timeout}'=='${None}'    5 min
    ...    ${timeout}
    FOR    ${type}    IN    @{celltypes}
        ${cell_ids}    Set Variable    ${celltype_distname}[${type}]
        ${cell_id_str}    Catenate    @{cell_ids}
        Wait Until Keyword Succeeds    ${timeout}    5 sec
        ...    _bts.verify_cell_status    connection=${connection}
        ...    cell_ids=${cell_id_str}    except_status=${except_status}
        ...    cell_type=${type}
    END

__bts.is_cellid_in_list
    [Arguments]    ${cellid}    ${cell_ids}
    Return From Keyword If    '${cell_ids}'=='' or '${cell_ids}'=='${None}'    ${False}
    ${is_list}    instance_for_robot    ${cell_ids}    list
    ${cell_ids_str}    Run Keyword If    ${is_list}    Catenate    SEPARATOR=,    @{cell_ids}
    ...    ELSE    Convert To String    ${cell_ids}
    ${cell_ids_list}    Evaluate    re.split(r'[;,\\s]+', '''${cell_ids_str}''')    re
    ${cell_ids_list}    Remove Values From List    ${cell_ids_list}    ${EMPTY}
    ${is_in}    Run Keyword And Return Status    List Should Contain Value    ${cell_ids_list}    ${cellid}
    ${is_in}    Run Keyword if    'ALL' in '${cell_ids}'
    ...    Set Variable    ${True}
    ...    ELSE    Set Variable    ${is_in}
    [Return]    ${is_in}

_bts.verify_cell_status
    [Arguments]    ${connection}    ${cell_ids}=1    ${cell_type}=nr
    ...    ${except_status}=onair
    [Documentation]    except_status: onair, lock, block
    ${cell_info}    coam.get_cells_info
    ...    cell_type=${cell_type}
    ...    timeout=10
    ...    connection=${connection}
    FOR    ${cell}    IN    @{cell_info}
        ${prefix}    ${cell_full_id}=    string.Split String From Right    ${cell['id']['configuration']}    separator=/    max_split=${1}
        ${prefix}    ${cellid}=    string.Split String From Right    ${cell_full_id}    separator=-    max_split=${1}
        ${is_in}    __bts.is_cellid_in_list    ${cellid}    ${cell_ids}
        Run Keyword If    ${is_in}
        ...    _bts.verify_${cell_type}_${except_status}
        ...    status=${cell['status']}
    END

_bts.verify_wcdma_block
    [Arguments]    ${status}
    Should Be Equal As Strings    ${status['operationalState']}    disabled
    Should Be Equal As Strings    ${status['availabilityStatus']}    off line
    Should Be Equal As Strings    ${status['blockingState']}    Blocked
    Should Be Equal As Strings    ${status['usageState']}    Idle

_bts.verify_lte_block
    [Arguments]    ${status}
    Should Be Equal As Strings    ${status['operationalState']}    disabled
    Should Be Equal As Strings    ${status['availabilityStatus']}    off line
    Should Be Equal As Strings    ${status['blockingState']}    Blocked
    Should Be Equal As Strings    ${status['usageState']}    Idle
    Should Be Equal As Strings    ${status['administrativeState']}    unlocked

_bts.verify_nr_block
    [Arguments]    ${status}
    Should Be Equal As Strings    ${status['operationalState']}    disabled
    Should Be Equal As Strings    ${status['availabilityStatus']}    off line
    Should Be Equal As Strings    ${status['blockingState']}    Blocked
    Should Be Equal As Strings    ${status['usageState']}    Idle
    Should Be Equal As Strings    ${status['administrativeState']}    Unlocked

_bts.verify_lte_lock
    [Arguments]    ${status}
    Should Be Equal As Strings    ${status['operationalState']}    disabled
    Should Be Equal As Strings    ${status['availabilityStatus']}    off line
    Should Be Equal As Strings    ${status['blockingState']}    Unblocked
    Should Be Equal As Strings    ${status['usageState']}    Idle
    Should Be Equal As Strings    ${status['administrativeState']}    locked

_bts.verify_nr_lock
    [Arguments]    ${status}
    Should Be Equal As Strings    ${status['operationalState']}    disabled
    Should Be Equal As Strings    ${status['availabilityStatus']}    off line
    Should Be Equal As Strings    ${status['blockingState']}    Unblocked
    Should Be Equal As Strings    ${status['usageState']}    Idle
    Should Be Equal As Strings    ${status['administrativeState']}    Locked

_bts.verify_lte_onair
    [Arguments]    ${status}
    Run Keyword If    '${status['administrativeState']}'=='Unlocked'
    ...    Run Keywords    Should Be Equal As Strings    ${status['availabilityStatus']}    Online
    ...    AND    Should Be Equal As Strings    ${status['operationalState']}    Enabled
    ...    ELSE
    ...    Run Keywords    Should Be Equal As Strings    ${status['administrativeState']}    unlocked
    ...    AND    Should Be True   "${status['usageState']}"=="Active" or "${status['usageState']}"=="Idle"
    ...    AND    Should Be Equal As Strings    ${status['operationalState']}    enabled

_bts.verify_wcdma_onair
    [Arguments]    ${status}
    Run Keywords    Should Be Equal As Strings    ${status['blockingState']}    Unblocked
    ...    AND    Should Be True   "${status['usageState']}"=="Active" or "${status['usageState']}"=="Idle"
    ...    AND    Should Be Equal As Strings    ${status['operationalState']}    enabled

_bts.verify_nr_onair
    [Arguments]    ${status}
    ${has_availabilityStatus}    ${value}    Run Keyword And Ignore Error
    ...    dictionary should contain key    ${status}    availabilityStatus
    ${has_usageState}    Run Keyword And Return Status
    ...    dictionary should contain key    ${status}    usageState
    ${operationalState}    Convert To Lower Case    ${status['operationalState']}
    Run Keyword If    '${has_availabilityStatus}'=='PASS'
    ...    Run Keywords
    ...    Should Be Equal As Strings    ${status['administrativeState']}    Unlocked
    ...    AND    Should Be True   "${status['availabilityStatus']}"=="Online"
    ...    AND    Should Be True   "${operationalState}"=="enabled"
    Run Keyword If    ${has_usageState}
    ...    Run Keywords    Should Be Equal As Strings    ${status['administrativeState']}    Unlocked
    ...    AND    Should Be True   "${status['usageState']}"=="Active" or "${status['usageState']}"=="Idle"
    ...    AND    Should Be True   "${operationalState}"=="enabled"
    ...    ELSE
    ...    Run Keywords    Should Be Equal As Strings    ${status['administrativeState']}    Unlocked
    ...    AND    Should Be True   "${status['blockingState']}"=="Unblocked"
    ...    AND    Should Be True   "${operationalState}"=="enabled"

################################ cell group operation #################################
_bts.get_cell_group_handle
    ${cell_handle}    Create Dictionary
    ...    cell_group_lock=coam.lock_cell_group
    ...    cell_group_unlock=coam.unlock_cell_group
    [Return]    ${cell_handle}

_bts.get_cell_group_distname_id
    [Arguments]    ${distname}    ${connection}
    ${info}    coam.get_bts_info    connection=${connection}
    ${complete_distname}    Set Variable    ${None}
    FOR    ${cell_group_info}    IN    @{info['cellsGroup']}
        ${complete_distname}
        ...    Run Keyword If    '${cell_group_info}[name]'=='${distname}'
        ...    Set Variable    ${cell_group_info}[id][internal]
        Exit For Loop If    '${cell_group_info}[name]'=='${distname}'
    END
    [Return]    ${complete_distname}

_bts.cell_group_operation
    [Arguments]    ${operation}    ${connection}    ${distname_id}=NRCELLGRP-0
    ...    ${timeout}=${None}    &{kwargs}
    ${dist_name}    _bts.get_cell_group_distname_id    ${distname_id}    ${connection}
    ${cell_handle}    _bts.get_cell_group_handle
    Run Keyword    ${cell_handle}[${operation}]    dist_name=${dist_name}    connection=${connection}
    Return From Keyword If    '${kwargs['need_verify']}'=='${False}'
    ${timeout}    Set Variable If    '${timeout}'=='${None}'    90s
    ...    ${timeout}
    Run Keyword If    '${operation}'=='cell_group_lock'
    ...    Wait Until Keyword Succeeds    ${timeout}    5 sec
    ...    _bts.verify_cell_group_lock    connection=${connection}    cellgroup_name=${distname_id}
    Run Keyword If    '${operation}'=='cell_group_unlock'
    ...    Wait Until Keyword Succeeds    ${timeout}    5 sec
    ...    _bts.verify_cell_group_unlock    connection=${connection}    cellgroup_name=${distname_id}

_bts.verify_cell_group_lock
    [Arguments]    ${connection}    ${cellgroup_name}
    ${subcells}    coam.get_subcells_status    connection=${connection}
    Dictionary Should Contain Key    ${subcells}    ${cellgroup_name}
    ${cell_names}    Get Dictionary Keys    ${subcells}[${cellgroup_name}]
    FOR    ${cell_name}    IN    @{cell_names}
        ${states}    Set Variable    ${subcells}[${cellgroup_name}][${cell_name}][NRCELL_R]
        Should be Equal    ${states}[administrativeState]    Locked
        Should be Equal    ${states}[operationalState]    disabled
    END

_bts.verify_cell_group_unlock
    [Arguments]    ${connection}    ${cellgroup_name}
    ${subcells}    coam.get_subcells_status    connection=${connection}
    Dictionary Should Contain Key    ${subcells}    ${cellgroup_name}
    ${cell_names}    Get Dictionary Keys    ${subcells}[${cellgroup_name}]
    FOR    ${cell_name}    IN    @{cell_names}
        ${states}    Set Variable    ${subcells}[${cellgroup_name}][${cell_name}][NRCELL_R]
        Should be Equal    ${states}[administrativeState]    Unlocked
        Should be Equal    ${states}[usageState]    Active
        Should be Equal    ${states}[operationalState]    enabled
    END

################################ rat operation #################################
_bts.get_rat_handle
    ${handle}    Create Dictionary
    ...    rat_block=coam.block_rat
    ...    rat_unblock=coam.unblock_rat
    ...    rat_reset=coam.rat_reset
    [Return]    ${handle}

_bts.get_rat_type
    [Arguments]    ${dist_name}
    ${rat}    Run keyword If   'NRCELL-ALL'=='${dist_name}'
    ...    Set Variable    NR
    ...    ELSE IF    'LNCEL-ALL'=='${dist_name}'
    ...    Set Variable    LTE
    ...    ELSE IF    'WNCEL-ALL'=='${dist_name}'
    ...    Set Variable    WCDMA
    ...    ELSE
    ...    Fail    msg=no support this type of rat
    [Return]    ${rat}
    # [Arguments]    ${connection}    ${cell_ids_str}=1    ${cell_type}=nr
    # ...    ${except_status}=onair
_bts.rat_operation
    [Arguments]    ${operation}    ${connection}    ${distname_id}
    ...    ${timeout}=${None}   &{kwargs}
    [Documentation]    distname_id should be NRCELL-ALL, LNCEL-ALL, WNCEL-ALL
    ${rat_type}    _bts.get_rat_type    ${distname_id}
    ${handle}    _bts.get_rat_handle
    ${parameter_keys}    Get Dictionary Keys    ${kwargs}
    ${append_parameter}    Create Dictionary
    Run Keyword If    "reset_type" in ${parameter_keys}
    ...    Set To Dictionary    ${append_parameter}    reset_type=${kwargs['reset_type']}
    Run Keyword    ${handle}[${operation}]    ${rat_type}    timeout=5 min
    ...    connection=${connection}    &{append_parameter}
    Return From Keyword If    '${kwargs['need_verify']}'=='${False}'
    ${timeout}    Set Variable If    '${timeout}'=='${None}'    10 min
    ...    ${timeout}
    ${cell_type}    Convert To Lower Case    ${rat_type}
    Run Keyword If    '${operation}'=='rat_block'
    ...    Wait Until Keyword Succeeds    5 min    5 sec
    ...    _bts.verify_cell_status    connection=${connection}    cell_ids=${distname_id}
    ...    cell_type=${cell_type}    except_status=block
    Run Keyword If    '${operation}'=='rat_unblock'
    ...    Wait Until Keyword Succeeds    ${timeout}    5 sec
    ...    _bts.verify_cell_status    connection=${connection}    cell_ids=${distname_id}
    ...    cell_type=${cell_type}    except_status=onair
    Run Keyword If    '${operation}'=='rat_reset'
    ...    Wait Until Keyword Succeeds    ${timeout}    5 sec
    ...    _bts.verify_cell_status    connection=${connection}    cell_ids=${distname_id}
    ...    cell_type=${cell_type}    except_status=onair

################################ BTS operation #################################
# _bts.is_bts_operation
#     [Arguments]    ${operation}
#     ${bts_handle}    _bts.get_site_handle
#     ${is_bts_operation}    Run Keyword And Return Status
#     ...    Dictionary Should Contain Key    ${bts_handle}    ${operation}
#     [Return]    ${is_bts_operation}

_bts.get_nrdu_distname_id
    [Arguments]    ${du_index}    ${connection}
    ${info}    coam.get_bts_info    connection=${connection}
    FOR    ${du_info}    IN    @{info['nrDU']}
        ${complete_distname}
        ...    Run Keyword If    '${du_info}[gNbDuId]'=='${du_index}'
        ...    Set Variable    ${du_info}[id][internal]
        Exit For Loop If    '${du_info}[gNbDuId]'=='${du_index}'
    END
    [Return]    ${complete_distname}

_bts.get_bts_distname_id
    [Arguments]    ${connection}
    ${info}    coam.get_bts_info    connection=${connection}
    ${complete_distname}    Set Variable    ${info}[id][internal]
    [Return]    ${complete_distname}

_bts.get_site_handle
    ${handle}    Create Dictionary    bts_lock=coam.lock
    ...    bts_unlock=coam.unlock
    ...    bts_block=coam.block
    ...    bts_unblock=coam.unblock
    ...    bts_reset=coam.reset_site
    [Return]    ${handle}

_bts.site_operation
    [Arguments]    ${operation}    ${connection}    ${du_index}
    ...    ${timeout}=90    &{kwargs}
    ${handle}    _bts.get_site_handle
    ${dist_name}    Run Keyword If    '${operation}'=='bts_block' or '${operation}'=='bts_unblock'
    ...    _bts.get_bts_distname_id    ${connection}
    ...    ELSE    _bts.get_nrdu_distname_id    ${du_index}    ${connection}
    ${parameter_keys}    Get Dictionary Keys    ${kwargs}
    ${append_parameter}    Create Dictionary
    Run Keyword If    "reset_without_ru" in ${parameter_keys}
    ...    Set To Dictionary    ${append_parameter}    reset_without_ru=${kwargs['reset_without_ru']}

    Run Keyword    ${handle}[${operation}]    dist_name=${dist_name}    connection=${connection}
    ...    timeout=300    &{append_parameter}
    Return From Keyword If    '${kwargs['need_verify']}'=='${False}'
    ${timeout}    Set Variable If    '${timeout}'=='${None}'    15 min
    ...    ${timeout}
    Run Keyword If    '${operation}'=='bts_lock'
    ...    Wait Until Keyword Succeeds    ${timeout}    5 sec    _bts.verify_site_lock    connection=${connection}
    ...    du_index=${du_index}
    Run Keyword If    '${operation}'=='bts_unlock'
    ...    Wait Until Keyword Succeeds    ${timeout}    5 sec    _bts.verify_site_unlock    connection=${connection}
    ...    du_index=${du_index}
    Run Keyword If    '${operation}'=='bts_block'
    ...    Wait Until Keyword Succeeds    ${timeout}    5 sec    _bts.verify_site_block    connection=${connection}
    Run Keyword If    '${operation}'=='bts_unblock'
    ...    Wait Until Keyword Succeeds    ${timeout}    5 sec    _bts.verify_site_onair    connection=${connection}
    Run Keyword If    '${operation}'=='bts_reset'
    ...    Wait Until Keyword Succeeds    ${timeout}    10 sec    _bts.verify_site_onair    connection=${connection}

_bts.verify_site_onair
    [Arguments]    ${connection}
    ${bts_status}    coam.get_bts_statuses    connection=${connection}
    Should Be Equal   ${bts_status['proceduralState']}    OnAir
    Should Be Equal   ${bts_status['operationalState']}    Enabled

_bts.verify_site_lock
    [Arguments]    ${connection}    ${du_index}
    ${info}    coam.get_bts_info    connection=${connection}
    FOR    ${du_info}    IN    @{info['nrDU']}
        ${complete_distname}
        ...    Run Keyword If    '${du_info}[gNbDuId]'=='${du_index}'
        ...    Set Variable    ${du_info}[id][internal]
        Exit For Loop If    '${du_info}[gNbDuId]'=='${du_index}'
    END
    Should Be True    '${complete_distname}'!='${None}'
    Should be Equal    ${du_info}[status][administrativeState]    Locked

_bts.verify_site_unlock
    [Arguments]    ${connection}    ${du_index}
    ${info}    coam.get_bts_info    connection=${connection}
    FOR    ${du_info}    IN    @{info['nrDU']}
        ${complete_distname}
        ...    Run Keyword If    '${du_info}[gNbDuId]'=='${du_index}'
        ...    Set Variable    ${du_info}[id][internal]
        Exit For Loop If    '${du_info}[gNbDuId]'=='${du_index}'
    END
    Should Be True    '${complete_distname}'!='${None}'
    Should be Equal    ${du_info}[status][administrativeState]    Unlocked

_bts.verify_site_block
    [Arguments]    ${connection}
    ${bts_status}    coam.get_bts_statuses    connection=${connection}
    Should Be Equal   ${bts_status['blockingState']}    Blocked
    Should Be Equal   ${bts_status['operationalState']}    Disabled
    Should Be True   bts_status['proceduralState']=='IntegratedToRan' or bts_status['proceduralState']=='Configured'

################################ BTS component operation #################################
_bts.get_component_handle
    ${handle}    Create Dictionary    ru_lock=coam.lock
    ...    ru_unlock=coam.unlock
    ...    bbmod_lock=coam.lock
    ...    bbmod_unlock=coam.unlock
    ...    ru_reset=coam.reset_unit
    ...    bbmod_reset=coam.reset_unit
    [Return]    ${handle}

_bts.get_rmod_distname_id
    [Arguments]    ${connection}    ${distname_id}
    ${input_distname_id_list}    Split String    ${distname_id}
    ${distname_id_list}    Create List
    ${info}    coam.get_bts_info    connection=${connection}
    FOR    ${ru_info}    IN    @{info['radioModules']['rmod']}
        ${configuration_distname}    Set Variable    ${ru_info}[id][configuration]
        ${configuration_distid}    Split String From Right    ${configuration_distname}    /
        Run Keyword If    "ALL" in '${distname_id}' or '${configuration_distid}[-1]' in "${input_distname_id_list}"
        ...    Append To List    ${distname_id_list}    ${ru_info}[id][internal]
        Exit For Loop If    '${configuration_distid}[-1]'=='${distname_id}'
    END
    Should Not Be Empty    ${distname_id_list}
    [Return]    ${distname_id_list}

_bts.get_rmod_status
    [Arguments]    ${connection}    ${distname_id}
    ${input_distname_id_list}    Split String    ${distname_id}
    ${distname_id_status}    Create Dictionary
    ${info}    coam.get_bts_info    connection=${connection}
    FOR    ${ru_info}    IN    @{info['radioModules']['rmod']}
        ${configuration_distname}    Set Variable    ${ru_info}[id][configuration]
        ${configuration_distid}    Split String From Right    ${configuration_distname}    /
        Run Keyword If    "ALL" in '${distname_id}' or '${configuration_distid}[-1]' in "${input_distname_id_list}"
        ...    Set To Dictionary    ${distname_id_status}    ${configuration_distid}[-1]=${ru_info}[status]
        Exit For Loop If    '${configuration_distid}[-1]'=='${distname_id}'
    END
    Should Not Be Empty    ${distname_id_status}
    [Return]    ${distname_id_status}

_bts.get_bbmod_distname_id
    [Arguments]    ${connection}    ${distname_id}
    ${distname_id_list}    Create List
    ${input_distname_id_list}    Split String    ${distname_id}
    ${info}    coam.get_bts_info    connection=${connection}
    FOR    ${bbmod_info}    IN    @{info['basebandModules']}
        ${configuration_distname}    Set Variable    ${bbmod_info}[id][configuration]
         ${configuration_distid}    Split String From Right    ${configuration_distname}    /
        Run Keyword If    "ALL" in '${distname_id}' or '${configuration_distid}[-1]' in "${input_distname_id_list}"
        ...    Append To List    ${distname_id_list}    ${bbmod_info}[id][internal]
        Exit For Loop If    '${configuration_distid}[-1]'=='${distname_id}'
    END
    Should Not Be Empty    ${distname_id_list}
    [Return]    ${distname_id_list}

_bts.verify_ru
    [Arguments]    ${connection}    ${distname_id}    ${except_status}
    ${info}    coam.get_bts_info    connection=${connection}
    ${input_distname_id_list}    Run Keyword If    '${distname_id}'!='${None}'
    ...    Split String    ${distname_id}
    ...    ELSE    Set Variable    ALL
    FOR    ${ru_info}    IN    @{info['radioModules']["rmod"]}
        ${configuration_distname}
        ...    Set Variable    ${ru_info}[id][configuration]
        ${configuration_distid}    Split String From Right    ${configuration_distname}    /
        Run Keyword If    "ALL" in '${distname_id}' or '${configuration_distid}[-1]' in "${input_distname_id_list}"
        ...    Run Keyword    _bts.ru_${except_status}    ${ru_info}[status]
        Exit For Loop If    '${configuration_distid}[-1]'=='${distname_id}'
    END

_bts.get_one_ru_operation_status
    [Arguments]    ${connection}    ${distname_id}
    ${input_distname_id_list}    Split String    ${distname_id}
    ${info}    coam.get_bts_info    connection=${connection}
    ${status}    Set Variable   ${None}
    FOR    ${ru_info}    IN    @{info['radioModules']["rmod"]}
        ${configuration_distname}
        ...    Set Variable    ${ru_info}[id][configuration]
        ${configuration_distid}    Split String From Right    ${configuration_distname}    /
        ${status}    Run Keyword If    '${configuration_distid}[-1]' in "${input_distname_id_list}"
        ...    Set Variable    ${status}[operationalState]
        ...    ELSE    Set Variable    ${status}
        Exit For Loop If    '${configuration_distid}[-1]'=='${distname_id}'
    END
    Should Be True    '${status}'!='${None}'
    [Return]    ${status}

_bts.ru_onair
    [Arguments]    ${status}
    Should be Equal    ${status}[administrativeState]    Unlocked
    Should be Equal    ${status}[operationalState]    enabled
    Should be True    '${status}[usageState]'=='Active' or '${status}[usageState]'=='Idle'

_bts.ru_lock
    [Arguments]    ${status}
    Should be Equal    ${status}[administrativeState]    Locked
    Should be Equal    ${status}[operationalState]    enabled
    Should be True    '${status}[usageState]'=='Active' or '${status}[usageState]'=='Idle'

_bts.ru_disabled
    [Arguments]    ${status}
    Should be Equal    ${status}[operationalState]    disabled

_bts.ru_enabled
    [Arguments]    ${status}
    Should be Equal    ${status}[operationalState]    enabled

_bts.verify_bbmod
    [Arguments]    ${connection}    ${distname_id}    ${except_status}
    ${info}    coam.get_bts_info    connection=${connection}
    FOR    ${bbmod_info}    IN    @{info['basebandModules']}
        ${complete_distname}
        ...    Set Variable    ${bbmod_info}[id][configuration]
        ${runtime_dist_id}    Split String From Right    ${complete_distname}    /
        Run Keyword If    "ALL" in '${distname_id}' or '${runtime_dist_id}[-1]' in '${distname_id}'
        ...    Run Keyword    _bts.ru_${except_status}    ${bbmod_info}[status]
        Exit For Loop If    '${runtime_dist_id}[-1]'=='${distname_id}'
    END

_bts.bbmod_onair
    [Arguments]    ${status}
    Should be Equal    ${status}[administrativeState]    Unlocked
    Should be Equal    ${status}[operationalState]    enabled
    Should be True    '${status}[usageState]'=='Active' or '${status}[usageState]'=='Idle'

_bts.bbmod_lock
    [Arguments]    ${status}
    Should be Equal    ${status}[administrativeState]    locked
    Should be Equal    ${status}[operationalState]    disabled
    Should be True    '${status}[usageState]'=='Active' or '${status}[usageState]'=='Idle'

_bts.component_operation
    [Arguments]    ${operation}    ${connection}    ${distname_id}
    ...    ${timeout}=90s    &{kwargs}
    ${handle}    _bts.get_component_handle
    ${distname_id_list}    Run Keyword If    "ru_" in '${operation}'
    ...    _bts.get_rmod_distname_id    ${connection}    ${distname_id}
    ...    ELSE IF    "bbmod_" in '${operation}'
    ...    _bts.get_bbmod_distname_id    ${connection}    ${distname_id}
    ${reset_type}    Set Variable If    "bbmod_" in '${operation}'    Warm
    ...    Hard
    ${reset_type}    Set Variable If    "reset_type" in ${kwargs}    ${kwargs['reset_type']}
    ...    Warm

    FOR    ${distname}    IN    @{distname_id_list}
        Run Keyword If    "reset" in '${operation}'
        ...    Run Keyword    ${handle}[${operation}]    dist_name=${dist_name}    connection=${connection}
        ...    reset_type=${reset_type}
        ...    detailed_output=${True}
        ...    timeout=900
        ...    ELSE
        ...    Run Keyword    ${handle}[${operation}]    dist_name=${dist_name}    connection=${connection}
        ...    timeout=300
    END
    Return From Keyword If    '${kwargs['need_verify']}'=='${False}'
    ${timeout}    Run Keyword If    '${operation}'=='ru_reset' or '${operation}'=='bbmod_reset'
    ...    Set Variable If    '${timeout}'=='${None}'    5 min    ${timeout}
    ...    ELSE
    ...    Set Variable If    '${timeout}'=='${None}'    15 min    ${timeout}
    Run Keyword If    '${operation}'=='ru_lock'
    ...    Wait Until Keyword Succeeds    5 min    5 sec    _bts.verify_ru    connection=${connection}
    ...    distname_id=${distname_id}    except_status=lock
    Run Keyword If    '${operation}'=='bbmod_lock'
    ...    Wait Until Keyword Succeeds    5 min    5 sec    _bts.verify_bbmod    connection=${connection}
    ...    distname_id=${distname_id}    except_status=lock
    Run Keyword If    '${operation}'=='ru_unlock'
    ...    Wait Until Keyword Succeeds   5 min    5 sec    _bts.verify_ru    connection=${connection}
    ...    distname_id=${distname_id}    except_status=onair
    Run Keyword If    '${operation}'=='bbmod_unlock'
    ...    Wait Until Keyword Succeeds    5 min    5 sec    _bts.verify_bbmod    connection=${connection}
    ...    distname_id=${distname_id}    except_status=onair
    Run Keyword If    '${operation}'=='ru_reset'
    ...    Wait Until Keyword Succeeds    15 min    5 sec    _bts.verify_ru    connection=${connection}
    ...    distname_id=${distname_id}    except_status=onair
    Run Keyword If    '${operation}'=='bbmod_reset'
    ...    Wait Until Keyword Succeeds    15 min    5 sec    _bts.verify_bbmod    connection=${connection}
    ...    distname_id=${distname_id}    except_status=onair

################################ BTS link operation #################################
_bts.get_link_handle
    ${handle}    Create Dictionary    nglink_lock=_bts.lock_ng_link
    ...    nglink_unlock=_bts.unlock_ng_link
    ...    x2link_lock=_bts.lock_x2link
    ...    x2link_unlock=_bts.unlock_x2link
    [Return]    ${handle}

_bts.lock_ng_link
    [Arguments]    ${dist_name}    ${connection}    ${du_index}=${0}
    ${distname_prefix}    _bts.get_distname_prefix    ${connection}
    ...    du_index=${du_index}
    coam.lock_ng_link    dist_name=${distname_prefix}/${dist_name}
    ...    connection=${connection}

_bts.unlock_ng_link
    [Arguments]    ${dist_name}    ${connection}    ${du_index}=${0}
    ${distname_prefix}    _bts.get_distname_prefix    ${connection}
    ...    du_index=${du_index}
    coam.unlock_ng_link    dist_name=${distname_prefix}/${dist_name}
    ...    connection=${connection}

_bts.get_distname_prefix
    [Arguments]    ${connection}    ${du_index}=${0}
    Log    ${du_index} is not used
    ${info}    coam.get_bts_info    connection=${connection}
    ${distname_prefix}    Set Variable    ${info}[id][configuration]
    # FOR    ${du_info}    IN    @{info['nrDU']}
    #     Continue For Loop If    ${du_info}[gNbDuId]!=${du_index}
    #     ${internal_id}    Run Keyword If    ${du_info}[gNbDuId]==${du_index}
    #     ...    Set Variable    ${du_info}[id][configuration]
    #     ${internal_str}    Split String From Right    ${internal_id}    /    1
    #     ${distname_prefix}    Set Variable    ${internal_str}[0]
    # END
    Should Not Be Equal    ${distname_prefix}    ${None}
    [Return]    ${distname_prefix}

_bts.set parameter value
    [Arguments]    ${dist_name}    ${parameter}    ${new_value}    ${operation}=update
    ...            ${sleep_time}=${30}    ${timeout}=${800}    ${connection}=COAM
    ...            ${skip_parameter_relation_errors}=true    ${should_activate}=${true}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...                                       operation=${operation}    value=${new_value}
    ...                                       skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                       should_activate=${should_activate}    timeout=${timeout}
    ...                                       connection=${connection}
    Sleep    ${sleep_time}

_bts.lock_x2link
    [Arguments]    ${dist_name}    ${connection}    ${du_index}=${0}
    ${distname_prefix}    _bts.get_distname_prefix    ${connection}
    ...    du_index=${du_index}
    ${pattern}    Run Keyword If    "LTEENB" in '${dist_name}'
    ...    Set Variable    x2LinkLock
    ...    ELSE IF    "LNADJGNB" in '${dist_name}'
    ...    Set Variable    administrativeState
    Should Be True    '${pattern}'!='${None}'
    _bts.set parameter value    dist_name=${distname_prefix}/${dist_name}
    ...    parameter=${pattern}    new_value=locked    connection=${connection}
    # ${value}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-23/SCF-1/MRBTS_A-6142/NRBTS_A-6142/LTEENB_A-0
    # ...    pattern=${pattern}    connection=${connection}
    # Should Be Equal     ${value}[${pattern}]    locked

_bts.unlock_x2link
    [Arguments]    ${dist_name}    ${connection}        ${du_index}=${0}
    ${distname_prefix}    _bts.get_distname_prefix    ${connection}
    ...    du_index=${du_index}
    ${pattern}    Run Keyword If    "LTEENB" in '${dist_name}'
    ...    Set Variable    x2LinkLock
    ...    ELSE IF    "LNADJGNB" in '${dist_name}'
    ...    Set Variable    administrativeState
    Should Be True    '${pattern}'!='${None}'
    _bts.set parameter value    dist_name=${distname_prefix}/${dist_name}
    ...    parameter=${pattern}    new_value=unlocked    connection=${connection}

_bts.link_operation
    [Arguments]    ${operation}    ${connection}    ${distname_id}
    ...    ${du_index}    &{kwargs}
    ${handle}    _bts.get_link_handle
    Run Keyword    ${handle}[${operation}]    ${distname_id}
    ...    ${connection}     ${du_index}

################################ BTS Status Verify #################################
_bts.get_verify_handle
    ${handle}    Create Dictionary    verify=${None}
    [Return]    ${handle}

_bts.verify_operation
    [Arguments]    ${operation}    ${connection}    ${verify_status}=${None}
    ...    ${distname_id}=${None}    ${timeout}=${None}    &{kwargs}
    Log    ${operation} is not used
    ${timeout}    _base.get_time_out    ${timeout}    ${verify_status}
    ${each_wait_time}    _bts.get_convert_each_wait_time    ${timeout}
    Run Keyword If    'CELL_ONAIR' in '${verify_status}'
    ...   _bts.until cell as except status    connection=${connection}
    ...    distname_id=${distname_id}
    ...    timeout=${timeout}
    Run Keyword If    'CELL_BLOCK' in '${verify_status}'
    ...   _bts.until cell as except status    connection=${connection}
    ...    distname_id=${distname_id}
    ...    timeout=${timeout}
    ...    except_status=block
    Run Keyword If    'CELL_LOCK' in '${verify_status}'
    ...   _bts.until cell as except status    connection=${connection}
    ...    distname_id=${distname_id}
    ...    timeout=${timeout}
    ...    except_status=lock
    Run Keyword If    'BBU_ONAIR' in '${verify_status}'
    ...    Wait Until Keyword Succeeds   ${timeout}    ${each_wait_time}
    ...    _bts.verify_bbmod    connection=${connection}
    ...    distname_id=${distname_id}    except_status=onair
    Run Keyword If    'RRU_ONAIR' in '${verify_status}'
    ...    Wait Until Keyword Succeeds   ${timeout}    ${each_wait_time}
    ...    _bts.verify_ru    connection=${connection}
    ...    distname_id=${distname_id}    except_status=onair
    Run Keyword If    'BBU_LOCK' in '${verify_status}'
    ...    Wait Until Keyword Succeeds   ${timeout}    ${each_wait_time}
    ...    _bts.verify_bbmod    connection=${connection}
    ...    distname_id=${distname_id}    except_status=lock
    Run Keyword If    'RRU_LOCK' in '${verify_status}'
    ...    Wait Until Keyword Succeeds   ${timeout}    ${each_wait_time}
    ...    _bts.verify_ru    connection=${connection}
    ...    distname_id=${distname_id}    except_status=lock
    Run Keyword If    'SITE_ONAIR' in '${verify_status}'
    ...    Wait Until Keyword Succeeds   ${timeout}    ${each_wait_time}
    ...    _bts.verify_site_onair    connection=${connection}
    Run Keyword If    "RRU_RESET_CHECK" in '${verify_status}'
    ...    _bts.check_rru_reset    connection=${connection}
    ...    distname_id=${distname_id}
    ...    timeout=${timeout}

_base.get_time_out
    [Arguments]    ${timeout}    ${status}
    Return From Keyword If   '${timeout}'!='${None}'    ${timeout}
    ${default_timeout}    Create Dictionary
    ...    CELL_LOCK=${5}
    ...    CELL_ONAIR=${15}
    ...    CELL_BLOCK=${5}
    ...    BBMOD_ONAIR=${10}
    ...    RRU_ONAIR=${10}
    ...    RRU_LOCK=${5}
    ...    BBU_ONAIR=${10}
    ...    BBU_LOCK=${5}
    ...    SITE_ONAIR=${10}
    ...    RRU_RESET_CHECK=${10}
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

_bts.get_convert_each_wait_time
    [Arguments]    ${timeout}    ${x}=${12}
    ${timeout_second}    Convert Time    ${timeout}
    ${each_wait_time}    Evaluate    int(${timeout_second}/${x})
    [Return]    ${each_wait_time}

_bts.until cell as except status
    [Arguments]    ${connection}    ${distname_id}=${None}    ${timeout}=${None}
    ...    ${except_status}=onair
    ${ALL_list}    Create List    ALL
    ${celltype_distname}    Run Keyword If    '${distname_id}'!='${None}'
    ...    _bts.get_cell_type_by_distname_id    ${distname_id}
    ...    ELSE    Create Dictionary    nr=${ALL_list}    lte=${ALL_list}    wcdma=${ALL_list}
    ${timeout}    Run Keyword If    '${timeout}'=='${None}' and '${except_status}'=='onair'
    ...    Set Variable    15 min
    ...    ELSE IF    '${timeout}'=='${None}' and '${except_status}'!='onair'
    ...    Set Variable    5 min
    ...    ELSE    Set Variable    ${timeout}
    ${celltypes}    Get Dictionary Keys    ${celltype_distname}
    ${each_wait_time}    _bts.get_convert_each_wait_time    ${timeout}
    FOR    ${type}    IN    @{celltypes}
        ${cell_ids}    Set Variable    ${celltype_distname}[${type}]
        ${cell_ids_str}    Catenate    @{cell_ids}
        Wait Until Keyword Succeeds    12x    ${each_wait_time}
        ...    _bts.verify_cell_status    connection=${connection}
        ...    cell_ids=${cell_ids_str}    except_status=${except_status}
        ...    cell_type=${type}
    END

_bts.check_rru_reset
    [Arguments]    ${connection}    ${distname_id}
    ...    ${timeout}=10 min
    ${state_machine}    Create List    enabled    disabled    enabled
    ${distname_status}    _bts.get_rmod_status    ${connection}    ${distname_id}
    ${rru_dist_list}    Get Dictionary Keys    ${distname_status}
    ${state_machine_index_for_ru}    Create Dictionary
    FOR    ${rru_full_distname_id}    IN    @{rru_dist_list}
       ${status}    Set Variable    ${distname_status}[${rru_full_distname_id}][operationalState]
        ${start_index}    Get Index From List    ${state_machine}    ${status}
        Set To Dictionary    ${state_machine_index_for_ru}
        ...    ${rru_full_distname_id}=${${start_index}+${1}}
        Log To Console    RRU ${rru_full_distname_id} operation state is ${status}
    END
    ${all_ru_len}    Get Length    ${rru_dist_list}
    _bts.one_loop_for_rru_reset_check    ${connection}
    ...    ${all_ru_len}
    ...    ${state_machine_index_for_ru}
    ...    ${state_machine}
    ...    ${distname_id}
    ...    ${timeout}

_bts.one_loop_for_rru_reset_check
    [Arguments]    ${connection}    ${all_ru_len}    ${state_machine_index_for_ru}
    ...    ${state_machine}    ${distname_id}    ${timeout}=10 min
    ${current_reset_sucessful_status_ru}    Create List
    ${timeout_second}    Convert Time    ${timeout}
    ${loop_times}    Evaluate    int(${timeout_second}/30)
    FOR    ${i}    IN RANGE    ${loop_times}
        ${state_machine_index_for_ru}    ${current_reset_sucessful_status_ru}
        ...    _bts.one_loop_for_rru_reset_state    ${connection}    ${distname_id}
        ...    ${state_machine_index_for_ru}
        ...    ${state_machine}    ${current_reset_sucessful_status_ru}
        Sleep    30 s
        ${complete_ru_len}    Get Length    ${current_reset_sucessful_status_ru}
        Exit For Loop If    ${all_ru_len}==${complete_ru_len}
    END
    Run Keyword If    ${all_ru_len}!=${complete_ru_len}    Fail
    ...    msg=rru reset status no meet disabled -> enabled or enabled -> disabled -> enabled

_bts.one_loop_for_rru_reset_state
    [Arguments]    ${connection}    ${distname_id}    ${state_machine_index_for_ru}
    ...    ${state_machine}    ${reset_sucessful_status_ru}
    ${len_of_machine}    Get Length    ${state_machine}
    ${len_of_machine}    Evaluate    ${len_of_machine}-${1}
    ${distname_status}    _bts.get_rmod_status    ${connection}    ${distname_id}
    ${rru_dist_list}    Get Dictionary Keys    ${distname_status}
    FOR    ${rru_distname_id}    IN    @{rru_dist_list}
        ${expect_status_index}    Set Variable    ${state_machine_index_for_ru}[${rru_distname_id}]
        ${status}    Set Variable    ${distname_status}[${rru_distname_id}][operationalState]
        ${state_machine_index}    Set Variable    ${state_machine_index_for_ru}[${rru_distname_id}]
        ${expert_status}    Set Variable    ${state_machine}[${state_machine_index}]
         Log To Console    RRU ${rru_distname_id} operation state is ${status} expert next is ${expert_status}
        Run Keyword If
        ...    '${rru_distname_id}' in ${reset_sucessful_status_ru} and '${status}'!='${expert_status}' and ${expect_status_index}==${len_of_machine}
        ...    Remove Values From List    ${reset_sucessful_status_ru}    ${rru_distname_id}
        Continue For Loop If    '${status}'!='${expert_status}'
        Run Keyword If
        ...    ${expect_status_index}==${len_of_machine} and '${rru_distname_id}' not in ${reset_sucessful_status_ru}
        ...    Append To List    ${reset_sucessful_status_ru}    ${rru_distname_id}
        Run Keyword If     ${expect_status_index}<${len_of_machine}
        ...    Set To Dictionary    ${state_machine_index_for_ru}
        ...    ${rru_distname_id}=${${state_machine_index_for_ru}[${rru_distname_id}]+${1}}
    END
    [Return]   ${state_machine_index_for_ru}    ${reset_sucessful_status_ru}

################################ BTS reset configuration #################################
_bts.get_reset_configuration_handle
    ${handle}    Create Dictionary    reset_configuration=coam.reset_configuration
    [Return]    ${handle}

_bts.reset_configuration_operation
    [Arguments]    ${operation}    ${connection}    &{kwargs}
    ${handle}    _bts.get_reset_configuration_handle
    Run Keyword    ${handle}[${operation}]
    ...    connection=${connection}


#######################upgrade#############################

Classical Get Software Version
    [Arguments]  ${product_type}   ${gnb_index}=${0}   ${oam_ip}=${None}    ${connection}=COAM
    ${connection}     _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=${60}
    ${active}   Set Variable   ${sw_info['Active SW version']}
    ${passive}   Set Variable   ${sw_info['Passive SW version']}
    ${planned}   Set Variable   ${sw_info['Planned SW version']}

    ${active}   Set Variable If   "${active}"!="${None}" and "${active}"!=""   ${active}   None
    ${passive}   Set Variable If   "${passive}"!="${None}" and "${passive}"!=""   ${passive}   None
    ${planned}   Set Variable If   "${planned}"!="${None}" and "${planned}"!=""   ${planned}   None

    ${active_version}   ${active_release}   Run Keyword If   "${active}"!="${None}" and "${active}"!=""
    ...   Get SW Version and Convert Trunk or Branch   sw_version=${active}
    ...   ELSE   Set Variable   None   None
    ${passive_version}   ${passive_release}   Run Keyword If   "${passive}"!="${None}" and "${passive}"!=""
    ...   Get SW Version and Convert Trunk or Branch   sw_version=${passive}
    ...   ELSE   Set Variable   None   None
    ${planned_version}   ${planned_release}   Run Keyword If   "${planned}"!="${None}" and "${planned}"!=""
    ...   Get SW Version and Convert Trunk or Branch   sw_version=${planned}
    ...   ELSE   Set Variable   None   None

    ${software_dict}   Create Dictionary
    ...   active_version=${active_version}
    ...   passive_version=${passive_version}
    ...   planned_version=${planned_version}
    ...   active_release=${active_release}
    ...   passive_release=${passive_release}
    ...   planned_release=${planned_release}
    [Return]   ${software_dict}
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

Get SW Version and Convert Trunk or Branch
    [Arguments]    ${sw_version}     ${connection}=COAM
    Log    ${connection} is not used
    ${SW_version_list1}    split string    ${sw_version}    _
    ${trunk_or_branch}    get from list    ${SW_version_list1}    2
    ${branch_tag}    get from list    ${SW_version_list1}    0
    ${SW_version_list2}    split string    ${sw_version}    ENB
    ${SBTS_VER_FULL}    get from list    ${SW_version_list2}    1
    ${branch}=    Run keyword if    ${trunk_or_branch}==${9999}    Set Variable   SBTS00
    ...   ELSE       Set Variable   ${SW_version_list1[0]}
    ${new_sw_version}    Set Variable    ${branch}_ENB${SBTS_VER_FULL}
    [Return]    ${new_sw_version}    ${branch}


Check Configured or Onair
    [Arguments]    ${connection}=COAM
    ${bts_info}    coam.get_bts_info    connection=${connection}    timeout=10
    ${status}    Set Variable    ${bts_info['status']['proceduralState']}
    Log to Console    Bts stats is ${status}
#    Should Contain    ${status}    Configured
    should be true    "${status}"=="Configured" or "${status}"=="OnAir"


_bts.rollback_operation
    [Arguments]  ${operation}   ${product_type}=gnb   ${gnb_index}=${0}  ${oam_ip}=${None}   ${connection}=COAM    &{kwargs}
    Log    ${gnb_index},${operation} is not used
    Rollback software for Classical    product_type=${product_type}     oam_ip=${oam_ip}     connection=${connection}


_bts.upgrade_operation
    [Arguments]  ${operation}   ${product_type}=gnb   ${gnb_index}=${0}  ${oam_ip}=${None}   ${connection}=COAM    &{kwargs}
    Log    ${gnb_index} is not used
#    ${sw_path}    Set Variable   ${kwargs['kwargs']['sw_path']}
    ${is_input_sw_path}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    sw_path
    ${sw_path}    Set Variable If    ${is_input_sw_path}    ${kwargs['sw_path']}    ${None}
    ${is_input_indicated_sw_version}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    indicated_sw_version
    ${indicated_sw_version}   Set Variable If   ${is_input_indicated_sw_version}   ${kwargs['indicated_sw_version']}   ${None}

    ${is_independent_sw_update}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    independent_sw_update_type
    ${independent_sw_update_type}   Set Variable If    ${is_independent_sw_update}   ${kwargs['independent_sw_update_type']}
    ...     All
    _upgrade_operation    operation=${operation}   product_type=${product_type}   oam_ip=${oam_ip}   connection=${connection}
    ...   sw_path=${sw_path}   indicated_sw_version=${indicated_sw_version}
    ...   independent_sw_update_type=${independent_sw_update_type}



_upgrade_operation_path
    [Arguments]  ${operation}   ${product_type}=gnb   ${gnb_index}=${0}  ${oam_ip}=${None}   ${connection}=COAM
    ...    ${sw_path}=${None}     ${same_sw_verify_flag}=${True}     ${independent_sw_update_type}=All
    Log    ${operation} is not used
    ${software_dict}     Classical Get Software Version     product_type=${product_type}     oam_ip=${oam_ip}
    log to console    ${software_dict["active_version"]}
    ${sw_path_list}    split string    ${sw_path}    /
    ${sw_file_name}    get from list    ${sw_path_list}    -1
    ${sw_version_list}   split string    ${sw_file_name}    _release
    ${indicated_sw_version}    get from list    ${sw_version_list}    0
    ${sw_path_list}  Split String From Right    ${sw_path}    /    1
    ${sw_dictionary}  Get From List    ${sw_path_list}    0
    Run Keyword If    "${same_sw_verify_flag}" == "${True}" and "${indicated_sw_version}" == "${software_dict["active_version"]}"
    ...     Log    The current version on the BTS is already satisfied
    Return From Keyword If
    ...    "${same_sw_verify_flag}" == "${True}" and "${indicated_sw_version}" == "${software_dict["active_version"]}"
    Log To Console    \nWill be upgraded to SWB Version: ${indicated_sw_version}
    _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    ${reset_number}    Get Reset info For SW Precheck
    ...     sw_file=${sw_path}
    ...    product_type=${product_type}     gnb_index=${gnb_index}     oam_ip=${oam_ip}    connection=${connection}
    Update BTS SW with SW Path    sw_path=${sw_path}    product_type=${product_type}
    ...        independent_sw_update_type=${independent_sw_update_type}
#    sleep    350s
#    SW Postcheck For Classical    product_type=${product_type}    oam_ip=${oam_ip}    connection=${connection}
    Log To Console    Wait for the upgrade done and stable.
    wait until keyword succeeds    6x    1min        _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
#    Wait until keyword succeeds    15 min    10 sec    Check GNB Systemboard Status
#    Wait until keyword succeeds    15 min    10 sec    Check GNB Basebandboard Status
#    Wait until keyword succeeds    15 min    10 sec    Check GNB RU Status
    ${software_dict}     Classical Get Software Version     product_type=${product_type}     oam_ip=${oam_ip}
    log to console    ${software_dict["active_version"]}
    Run Keyword If    "${independent_sw_update_type}"=="All"
    ...     should be equal    ${software_dict["active_version"]}    ${indicated_sw_version}
    Wait Until Keyword Succeeds    600    5s    Check Configured or Onair    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}


Update BTS SW with SW Path
    [Arguments]    ${sw_path}    ${product_type}     ${gnb_index}=${0}    ${oam_ip}=${None}    ${activate}=yes    ${connection}=COAM
    ...            ${independent_sw_update_type}=All
    ${connection}     _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    Log To Console    Start Software Updating...
    ${should_activate}    Set Variable If    '${activate}'=='yes'    ${True}
    ...    '${activate}'=='no'    ${False}
    csn.connect_to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}    alias=VM
    coam.update_software    sw_package=${sw_path}
    ...                     should_activate=${True}
    ...                     timeout=${3600}
    ...                     connection=${connection}
    ...                     independent_sw_update_type=${independent_sw_update_type}
    Log To Console    Software Update Finished, Waiting For Resetting...
    Sleep    100s
    [Teardown]    coam.teardown    connection=${connection}




_upgrade_operation_download_sw
    [Arguments]  ${operation}   ${product_type}=gnb   ${gnb_index}=${0}  ${oam_ip}=${None}   ${connection}=COAM
    ...    ${indicated_sw_version}=${None}   ${same_sw_verify_flag}=${True}    ${independent_sw_update_type}=All
    Log    ${operation} is not used
    ${software_dict}     Classical Get Software Version     product_type=${product_type}     oam_ip=${oam_ip}
    log to console    ${software_dict["active_version"]}
    Run Keyword If    "${same_sw_verify_flag}" == "${True}" and "${indicated_sw_version}" == "${software_dict["active_version"]}"
    ...     Log    The current version on the BTS is already satisfied
    Return From Keyword If
    ...    "${same_sw_verify_flag}" == "${True}" and "${indicated_sw_version}" == "${software_dict["active_version"]}"
    _download_sw     indicated_sw_version=${indicated_sw_version}
    Log To Console    \nDownload pacakge successfully!!!
    Log To Console    \nWill be upgraded to SWB Version: ${indicated_sw_version}
    _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    ${dictionary_sw}    set variable   /home/ute/${indicated_sw_version}/${indicated_sw_version}_release_BTSSM_downloadable_A54.zip
    ${reset_number}    Get Reset info For SW Precheck
    ...     sw_file=${dictionary_sw}
    ...     product_type=${product_type}     gnb_index=${gnb_index}     oam_ip=${oam_ip}    connection=${connection}
    Update SW for BTS    product_type=${product_type}     directory=/home/ute/${indicated_sw_version}/
    ...        independent_sw_update_type=${independent_sw_update_type}
    Log To Console    Wait for the upgrade done and stable.
    wait until keyword succeeds    6x    1min        _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    ssh.execute    command=rm -rf /home/ute/${indicated_sw_version}/    connection=VM
    sleep    10s
    ssh.disconnect    connection=VM
    ${software_dict}     Classical Get Software Version     product_type=${product_type}     oam_ip=${oam_ip}
    log to console    ${software_dict["active_version"]}
    Run Keyword If    "${independent_sw_update_type}"=="All"
    ...     should be equal    ${software_dict["active_version"]}    ${indicated_sw_version}
    Wait Until Keyword Succeeds    600    5s    Check Configured or Onair    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}


_upgrade_operation
    [Arguments]  ${operation}   ${product_type}=gnb   ${gnb_index}=${0}  ${oam_ip}=${None}   ${connection}=COAM
    ...      ${sw_path}=${None}   ${indicated_sw_version}=${None}   ${same_sw_verify_flag}=${True}
    ...      ${independent_sw_update_type}=All
    run keyword if   "${sw_path}"!="${None}"   _upgrade_operation_path   operation=${operation}  product_type=${product_type}
    ...    gnb_index=${gnb_index}  oam_ip=${oam_ip}  connection=${connection}  sw_path=${sw_path}
    ...    same_sw_verify_flag=${same_sw_verify_flag}   independent_sw_update_type=${independent_sw_update_type}
    run keyword if   "${indicated_sw_version}"!="${None}"   _upgrade_operation_download_sw    operation=${operation}
    ...    product_type=${product_type}    gnb_index=${gnb_index}  oam_ip=${oam_ip}  connection=${connection}
    ...    indicated_sw_version=${indicated_sw_version}    same_sw_verify_flag=${same_sw_verify_flag}
    ...    independent_sw_update_type=${independent_sw_update_type}


Check GNB Systemboard Status
    [Arguments]    ${connection}=COAM
    Log to console    Check Systemboard status from GNB
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_system}    Set variable    ${hw_info['systemModules']}
    ${count_system}    Get length    ${list_system}
    Should be true    ${count_system}>=${1}    msg=Check systemboard status failed as total systemboard number is less than 1
    FOR    ${system}    IN    @{list_system}
        __Gnb Status Check    status=${system['status']}    checked_part=systemModules
    END

__Gnb Status Check
    [Arguments]    ${status}   ${checked_part}
    ${has_availabilityStatus}    ${value}    Run Keyword And Ignore Error
    ...    dictionary should contain key    ${status}    availabilityStatus
    Run Keyword If    '${has_availabilityStatus}'=='PASS'    Run Keywords
    ...    Should be equal as strings    ${status['administrativeState']}    Unlocked
    ...    msg=Current ${checked_part} administrativeState is not in Unlocked status    ignore_case=${True}
    ...    AND    Should be equal as strings    ${status['availabilityStatus']}    Online
    ...    msg=Current ${checked_part} availabilityStatus is not in Online status    ignore_case=${True}
    ...    ELSE    Run Keywords
    ...    Should be equal as strings    ${status['administrativeState']}    Unlocked
    ...    msg=Current ${checked_part} administrativeState is not in Unlocked status    ignore_case=${True}
    ...    AND    Should be equal as strings    ${status['operationalState']}    enabled
    ...    msg=Current ${checked_part} operationalState is not in enabled status    ignore_case=${True}

Check GNB Basebandboard Status
    [Arguments]    ${connection}=COAM
    Log to console    Check Basebandboard status from GNB
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_baseband}    Set variable    ${hw_info['basebandModules']}
    ${count_baseband}    Get length    ${list_baseband}
    Should be true    ${count_baseband}>=${1}    msg=Check basebandboard status failed as total basebandboard number is less than 1
    FOR    ${baseband}    IN    @{list_baseband}
        __Gnb Status Check    status=${baseband['status']}    checked_part=basebandModules
    END


Check GNB RU Status
    [Arguments]    ${connection}=COAM    ${ru_sn}=all
    Log to console    Check RU status from GNB
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${ru_item}    Set variable    ${0}
    Should be true    ${count_RUs}>=${1}    msg=Check RU status failed as total RU number is less than 1
    FOR    ${ru}    IN    @{list_RUs}
        Run keyword if    '${ru_sn}'!='all' and '${ru_sn}'!='${ru['serialNumber']}'    continue for loop
        ${ru_item}=    evaluate    ${ru_item}+1
        __Gnb Status Check    status=${ru['status']}    checked_part=RU
    END
    should be true    ${ru_item}>${0}    msg=Check RU status failed as no RU found !!!



Update SW for BTS
    [Arguments]    ${product_type}     ${gnb_index}=${0}    ${oam_ip}=${None}    ${activate}=yes    ${connection}=COAM
    ...            ${directory}=/home/ute/Downloads     ${independent_sw_update_type}=All
    ${connection}     _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    Log To Console    Start Software Updating...
    ${should_activate}    Set Variable If    '${activate}'=='yes'    ${True}
    ...    '${activate}'=='no'    ${False}
    csn.connect_to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}    alias=VM
    @{SBTS_Version}    bts_base.get_file_under_directory    directory=${directory}
    ...                connection=VM
    ...                file_indicator=*_release_BTSSM_downloadable*.zip
    coam.update_software    sw_package=${directory}/${SBTS_Version[0]}
    ...                     should_activate=${True}
    ...                     timeout=${3600}
    ...                     connection=${connection}
    ...                     independent_sw_update_type=${independent_sw_update_type}
    Log To Console    Software Update Finished, Waiting For Resetting...
    Sleep    100s
    [Teardown]    coam.teardown    connection=${connection}


####################rollback#################
Rollback software for Classical
    [Arguments]    ${product_type}     ${gnb_index}=${0}     ${oam_ip}=${None}     ${connection}=COAM
    ${connection}     _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    coam.rollback_software    connection=${connection}
#    ${software_dict}     Classical Get Software Version     product_type=${product_type}     oam_ip=${oam_ip}
#    log to console    ${software_dict["active_version"]}
#    should be equal    ${software_dict["active_version"]}    ${indicated_sw_version}
    Wait Until Keyword Succeeds    600    5s    Check Configured or Onair    connection=${connection}
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}





Get Reset info For SW Precheck
    [Arguments]  ${sw_file}    ${product_type}=gnb   ${gnb_index}=${0}   ${oam_ip}=${None}   ${timeout}=120  ${connection}=COAM
    ${connection}     _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    ${reset_number}=  Set Variable  0
    ${output_dict}=  coam.software_precheck_local  sw_package=${sw_file}  precheck_type=RebootCheck  timeout=${timeout}
    ...    alias=${connection}
    ${resetCoverage_found}=  Run Keyword And Return Status
    ...  Variable Should Exist  ${output_dict['reportResult']['resetCoverageReport'][0]['resetCoverage']}
    Set Test Variable  ${resetCoverage_found}
    Return From Keyword If  not ${resetCoverage_found}  1
    ${reset_info}=  Set Variable  ${output_dict['reportResult']['resetCoverageReport'][0]['resetCoverage']}
    Return From Keyword If  len(${reset_info}) == 0  ${reset_number}
    ${reset_number}=  Run Keyword If  len(${reset_info}) != 0 and '${reset_info[0]}' == 'Site'
    ...    Evaluate  ${reset_number} + 1
    [Return]  ${reset_number}
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}



SW Postcheck For Classical
    [Arguments]  ${product_type}    ${gnb_index}=${0}    ${oam_ip}=${None}    ${timeout}=120  ${connection}=COAM
    Log    ${timeout} is not used
    ${connection}     _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    Log  Start software postcheck procedure  console=${TRUE}
    ${postcheck_status}  Run keyword and return status  Software Postcheck
    Run keyword if  ${postcheck_status}  Log  Software Postcheck done successfully  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  Software Postcheck failed!
    ...  AND
    ...  Log  Software Postcheck failed!  console=${TRUE}
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}



_Backup_SCF
    [Arguments]    ${local_dir}=${OUTPUT_DIR}    ${file_name}=old_commission.xml    ${connection}=COAM
    coam.get_current_scf_file    local_dir_path=${local_dir}    file_name=${file_name}    connection=${connection}    timeout=10
    ${backupfile}=    Join Path    ${local_dir}    ${file_name}
    [Return]    ${backupfile}


Commissioning SCF For BTS
    [Arguments]   ${scf_file}    ${product_type}   ${gnb_index}=${0}    ${oam_ip}=${None}    ${timeout}=${600}
    ...    ${connection}=COAM
    ${connection}     _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    coam.perform_commissioning    scf_file=${scf_file}
    ...                           skip_parameter_relation_errors=True
    ...                           should_activate=${true}
    ...                           timeout=${timeout}
    ...                           connection=${connection}
    #   Wait Until Keyword Succeeds    20 min    10 sec
    #  ...    Check Configured or Onair     connection=${connection}
    sleep    200s
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}


_download_sw
    [Arguments]     ${indicated_sw_version}
    ${new_version}   ${sw_release}    Get SW Version and Convert Trunk or Branch    ${indicated_sw_version}
    ssh.Connect to    hostname=127.0.0.1
    ...     username=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}    alias=VM
    ssh.execute    command=rm -rf ${indicated_sw_version}    connection=VM
    ${url}   Catenate   SEPARATOR=   https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local
    ...    /build/${sw_release}/${indicated_sw_version}/${indicated_sw_version}_release_BTSSM_downloadable_A54.zip
    ${swb_cmd}=    Catenate
    ...    mkdir ${indicated_sw_version} &&
    ...    cd ${indicated_sw_version} &&
    ...    wget ${url}
    ssh.execute    command=${swb_cmd}    connection=VM
    ${sha256_wft}  wft_sw.get_sha    plan_sw_build=${indicated_sw_version}    WFT_ACCESS_KEY=S3roP5dXbVm4tlZnIhigteyuUHNlgt8mxe2566VD
    ${sha256_file}     wft_sw.sha256_of_file
    ...    filename=/home/ute/${indicated_sw_version}/${indicated_sw_version}_release_BTSSM_downloadable_A54.zip
    Should Be Equal    ${sha256_wft}    ${sha256_file}    msg=download file fail!!!!!
    [Return]   /home/ute/${indicated_sw_version}/${indicated_sw_version}_release_BTSSM_downloadable_A54.zip
    [Teardown]    run keyword and ignore error    ssh.disconnect


Connect to ASIB
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${alias}=First_ASIB
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    transport_ssh.Connect To    hostname=${host}    username=${username}    password=${password}    alias=${alias}


SW Downgrade By Clear Configuration
    [Arguments]  ${operation}    ${product_type}    ${sw_path}  ${indicated_sw_version}
    ...      ${gnb_index}=${0}   ${oam_ip}=${None}    ${timeout}=120    ${connection}=COAM     ${scf_path}=${None}
    Log    ${timeout} is not used
    &{expected_alarms}        Create Dictionary    faultId=23    faultName=Incompatible SW version detected
    @{expected_list}          Create List     ${expected_alarms}
    &{CRITICAL_ALARM1}        Create Dictionary    severity=Critical
    @{CRITICAL}               Create List     ${CRITICAL_ALARM1}
    ${connection}     _bts.login
    ...    product_type=${product_type}
    ...    gnb_index=${gnb_index}
    ...    alias=${connection}
    ...    oam_ip=${oam_ip}
    ${DATE}=    Get Current Date    result_format=%Y%m%d_%H%M
    ${res}   ${backupfile}    Run Keyword And Ignore Error    _Backup_SCF    local_dir=/home/ute/test_results
    ...      file_name=SCF_${DATE}.xml     connection=${connection}
    Wait Until Keyword Succeeds    15 min    3 sec    Connect to ASIB    alias=First_ASIB
    Run Keyword And Ignore Error    bts_base.download_file_to_test_pc
    ...    localFilePath=/home/ute/swconfig.txt
    ...    remoteFilePath=/ffs/run/swconfig.txt    asib_alias=First_ASIB
    ${sw_download_path}    run keyword if   "${indicated_sw_version}"!="${None}"   _download_sw
    ...    indicated_sw_version=${indicated_sw_version}
    ${sw_path}    set variable if     "${sw_download_path}"!="None"    ${sw_download_path}    ${sw_path}
    run keyword and ignore error    coam.Reset Configuration    remove_operator_certificates=False
    ...    remove_user_account_credentials=False    alias=${connection}    timeout=800
    ...    reset_type=ConfigurationWithDiagnosticAndRecoverySw
    ${ping_status_after_reset}   tool_for_ping.check_target_stable
    ...  ip=192.168.255.129  min_uptime=300  max_downtime=600  timeout=1800
    Run keyword unless  ${ping_status_after_reset}  FAIL  BTS is not stable after downgrade.
    Wait Until Keyword Succeeds  10 min  5 sec    Connected to RSW BTS by RC
    sleep    60s
    ${active_part_ID}    rc.get_active_sw_partition    timeout=10
    run keyword and ignore error  rc.software_update  sw_slot_id=${active_part_ID}  sw_pkg_path=${sw_path}
    ...     timeout=1200  activate=True
#    rc.trigger_software_update_activation  timeout=300
    ${ping_status}    tool_for_ping.check_target_stable  ip=192.168.255.129  min_uptime=300  max_downtime=300  timeout=1200
    Run keyword unless  ${ping_status}  FAIL  BTS is not stable after downgrade.
    run keyword and ignore error     _bts_upload_swconfig_file    local_path=/home/ute/swconfig.txt
    ...    remote_path=/ffs/run/swconfig.txt    alias=First_ASIB
    ${scf_file}    Set Variable If    "${scf_path}"!="${None}"     ${scf_path}    ${backupfile}
    Commissioning SCF For BTS    scf_file=${scf_file}   product_type=${product_type}   oam_ip=${oam_ip}
    sleep    60s
    Wait Until Keyword Succeeds  20 min  60 sec     Check Alarm 23   expected_list=${expected_list}   CRITICAL=${CRITICAL}
    ...     product_type=${product_type}    bts_index=${gnb_index}
    log to console    fault 23**
    _upgrade_operation  operation=${operation}  product_type=${product_type}
    ...    oam_ip=${oam_ip}    sw_path=${sw_path}   same_sw_verify_flag=${False}   indicated_sw_version=${indicated_sw_version}
    [Teardown]    Clear Configuration Teardown    connection=${connection}


_bts_upload_swconfig_file
    [Arguments]    ${local_path}=home/ute/swconfig/swconfig.txt    ${remote_path}=/ffs/run/swconfig.txt
    ...            ${alias}=First_ASIB
    transport_ssh.upload_file    local_path=${local_path}    remote_path=${remote_path}    connection=${alias}
    ${cmd}=    Catenate    cd /ffs/run/ && crasign swconfig.txt
    transport_ssh.execute    command=${cmd}    connection=${alias}


Clear Configuration Teardown
    [Arguments]    ${connection}
    run keyword and ignore error    coam.teardown    connection=${connection}
    Run Keyword And Ignore Error    rc.teardown
    Run Keyword And Ignore Error    transport_ssh.disconnect    connection=First_ASIB


Check Alarm 23
    [Arguments]    ${expected_list}    ${CRITICAL}    ${product_type}=gnb    ${bts_index}=0
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=${product_type}    bts_index=${bts_index}
    ...                          expected_alarms=${expected_list}
    ...                          critical_alarms=${CRITICAL}
    should be equal    ${res["flag_expect_alarm"]}    ${True}

Connected to RSW BTS by RC
    [Arguments]    ${ip_address}=192.168.255.129   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser  ${fdsw_version}=fdsw21c
    ...    ${auto_discover}=True    ${secure}=True    ${name}=default
#    Run Keyword And Ignore Error    rc.teardown
    Log    ${fdsw_version} is not used
    rc.connect_to    ip_address=${ip_address}   port=${port}    username=${username}    password=${password}
    ...    auto_discover=${auto_discover}    secure=${secure}    name=${name}
    Log  FDSW RC Connected to BTS successfully with IP ${ip_address}
    enable_SSH_Access_On_RC

enable_SSH_Access_On_RC
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10min    1min    rc.enable_ethernet_port_security
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    10min    1min    rc.enable_ssh_service


SW Rollback and Upgrade
    [Arguments]   ${operation}    ${product_type}  ${sw_path}    ${indicated_sw_version}   ${independent_sw_update_type}
    ...       ${oam_ip}=${None}    ${connection}=COAM
    Rollback software for Classical    product_type=${product_type}     oam_ip=${oam_ip}     connection=${connection}
    sleep    300s
    run keyword if   "${sw_path}"!="${None}"   _upgrade_operation_path   operation=${operation}  product_type=${product_type}
    ...    oam_ip=${oam_ip}  connection=${connection}  sw_path=${sw_path}    same_sw_verify_flag=${False}
    ...    independent_sw_update_type=${independent_sw_update_type}
    run keyword if   "${indicated_sw_version}"!="${None}"   _upgrade_operation_download_sw    operation=${operation}
    ...    product_type=${product_type}    oam_ip=${oam_ip}  connection=${connection}
    ...    indicated_sw_version=${indicated_sw_version}    same_sw_verify_flag=${False}
    ...      independent_sw_update_type=${independent_sw_update_type}

_get_sw_version
    [Arguments]  ${sw_path}
    ${sw_path_list}    split string    ${sw_path}    /
    ${sw_file_name}    get from list    ${sw_path_list}    -1
    ${sw_version_list}   split string    ${sw_file_name}    _release
    ${indicated_sw_version}    get from list    ${sw_version_list}    0
    [Return]    ${indicated_sw_version}


_bts.downgrade_operation
    [Arguments]  ${operation}   ${product_type}=gnb    ${oam_ip}=${None}    ${connection}=COAM
    ...          &{kwargs}
    ${is_input_sw_path}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    sw_path
    ${sw_path}    Set Variable If    ${is_input_sw_path}    ${kwargs['sw_path']}    ${None}
    ${is_input_indicated_sw_version}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}   indicated_sw_version
    ${indicated_sw_version}   Set Variable If   ${is_input_indicated_sw_version}   ${kwargs['indicated_sw_version']}   ${None}
    ${is_input_scf_path}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    scf_path
    ${scf_path}    Set Variable If    ${is_input_scf_path}     ${kwargs['scf_path']}    ${None}
    log to console    ${sw_path}
    ${is_independent_sw_update}    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${kwargs}    independent_sw_update_type
    ${independent_sw_update_type}   Set Variable If    ${is_independent_sw_update}   ${kwargs['independent_sw_update_type']}
    ...     All
    ${software_dict}     Classical Get Software Version     product_type=${product_type}     oam_ip=${oam_ip}
    ${sw_version}    run keyword if    "${sw_path}"!="${None}"  _get_sw_version    sw_path=${sw_path}
    ${package_version}    set variable if    "${sw_path}"!="${None}"    ${sw_version}     ${indicated_sw_version}
    ${active_version}    set variable    ${software_dict["active_version"]}
    ${passive_version}    set variable    ${software_dict["passive_version"]}
    ${flag_return}   ${flag_rollback}   ${flag_configuration}  bts_base.verify_sw_ways
    ...    indicated_sw_version=${package_version}    sw_version_active=${active_version}
    ...    sw_version_passive=${passive_version}
    Run Keyword If    ${flag_rollback}==${True}   SW Rollback and Upgrade   operation=${operation}    product_type=${product_type}
    ...    sw_path=${sw_path}  indicated_sw_version=${indicated_sw_version}   independent_sw_update_type=${independent_sw_update_type}
    ...    oam_ip=${oam_ip}   connection=${connection}
    ...    ELSE IF   ${flag_configuration}==${True}   SW Downgrade By Clear Configuration  operation=${operation}
    ...    product_type=${product_type}   sw_path=${sw_path}   indicated_sw_version=${indicated_sw_version}
    ...    oam_ip=${oam_ip}   connection=${connection}   scf_path=${scf_path}
    ...    ELSE IF   ${flag_return}==${True}  log   The given package version does not meet the downgrade condition!!!    WARN
    Return From Keyword If    ${flag_return}==${True}
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}
