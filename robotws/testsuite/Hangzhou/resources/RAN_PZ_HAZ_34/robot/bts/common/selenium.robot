*** Settings ***
Documentation    Selenium related keywords for classical.
...              Please notify 5G_HGZ_Core_Testers when modifying the file
...              Author: HAZ3&4_common
Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    DateTime
Library    taf.selenium.sbts  WITH NAME  selenium_coam


*** Keywords ***
Selenium Coam Login And Disable Screen Lock
    [Arguments]    ${download_dir}=${CASE_LOG_PATH}
    ...            ${timeout}=${60}
    ...            ${url}=https://${sbts_addr}
    ...            ${username}=${http_username}
    ...            ${password}=${http_password}
    ...            ${version}=SBTS23R3
    ...            ${browser}=Firefox
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    ...                    version=${version}
    ...                    browser=${browser}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Selenium Coam Logout And Close Browser
    Run Keyword And Ignore Error    Close Start Up View Window    timeout=5
    Run Keyword And Ignore Error    selenium_coam.logout
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display
    Run Keyword And Ignore Error    selenium_coam.close_browser

Close Start Up View Window
    [Documentation]  workarounds for PR530939, should change it back after PR closed
    [Arguments]   ${timeout}=300
    ${close_flag}    selenium_coam.start_up_view_window_exists    timeout=${timeout}
    run keyword if    ${close_flag}    selenium_coam.close_start_up_view_window

Get Single Parameter Value on WebUI
    [Arguments]  ${dist_name}    ${filter_param}
    ${currect_value}    selenium_coam.Get Parameter Value    dist_name=${dist_name}
    ...    filter_param=${filter_param}
    [Return]  ${currect_value}

Modify Single Parameter Value on WebUI
    [Arguments]  ${dist_name}    ${filter_param}    ${abbr}    ${new_value}  ${timeout}=300
    selenium_coam.set_parameter_value  dist_name=${dist_name}
        ...    filter_param=${filter_param}
        ...    abbr=${abbr}    new_value=${new_value}
    selenium_coam.validate_plan
    ${defErrs_dic}    selenium_coam.get_definition_errors
    ${list_num}   Get Length   ${defErrs_dic}
    Should be true    ${list_num}==${0}
    selenium_coam.activate_plan  timeout=${timeout}

Check and Modify Single Parameter on WebUI
    [Arguments]  ${dist_name}    ${filter_param}    ${abbr}    ${new_value}
    ${currect_status}    Get Single Parameter Value on WebUI    dist_name=${dist_name}    filter_param=${filter_param}
    log to console  \n Modify ${abbr} from ${currect_status} to ${new_value}
    Run Keyword If    '${currect_status}'!='${new_value}'
    ...    Modify Single Parameter Value on WebUI    dist_name=${dist_name}    filter_param=${filter_param}
    ...    abbr=${abbr}    new_value=${new_value}

Verify Out Range Single Parameter Value And Undo Change
    [Arguments]  ${dist_name}    ${filter_param}    ${abbr}    ${new_value}
    selenium_coam.set_parameter_value  dist_name=${dist_name}
        ...    filter_param=${filter_param}
        ...    abbr=${abbr}    new_value=${new_value}
    selenium_coam.validate_plan
    ${defErrs_dic}    run keyword and continue on failure    selenium_coam.get_definition_errors
    ${list_num}   Get Length   ${defErrs_dic}
    Should be true    ${list_num}==${1}
    selenium_coam.undo_changes

Modify and Check Single Parameter Value without reset
    [Arguments]  ${dist_name}    ${filter_param}    ${abbr}    ${new_value}
    Modify Single Parameter Value on WebUI  dist_name=${dist_name}
    ...    filter_param=${filter_param}
    ...    abbr=${abbr}    new_value=${new_value}
    sleep    60
    ${currect_value}    selenium_coam.Get Parameter Value    dist_name=${dist_name}
    ...    filter_param=${filter_param}
    ${new_value}  convert to string  ${new_value}
    Should Contain      ${currect_value}      ${new_value}

Execute Configuration Reset on WehUI
    [Arguments]  ${timeout_for_reset}=60
    selenium_coam.configuration_reset  timeout_for_reset=${timeout_for_reset}

Perform BTS Site Reset On WebUI
    ${is_startup_window_exist}      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_site    with_graceful=${False}

Online Cell addition for LTE
    [Arguments]  ${add_cell_id}=${2}    ${new_earfcn}=${41990}
    log to console  add cell-${add_cell_id}
    selenium_coam.add_object    object_name=LNBTS-${NRBTS_ID}
    ...    object_class_name=LNCEL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-1
    ...    include_subobject=${True}   id_value=${add_cell_id}    timeout=15
    selenium_coam.add_object    object_name=CELLMAPPING-1
    ...    object_class_name=LCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-1
    ...    include_subobject=${True}   id_value=${add_cell_id}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${add_cell_id}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${add_cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${add_cell_id}
    ...    filter_param=Physical layer cell identity    abbr=phyCellId    new_value=${add_cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${add_cell_id}/LNCEL_TDD-0
    ...    filter_param=EARFCN for both downlink and uplink (TDD)    abbr=earfcn    new_value=${new_earfcn}
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    sleep    60

Online Cell deletion for LTE
    [Arguments]  ${delete_cell_id}=${2}
    log to console  delete cell-${delete_cell_id}
    ${object_list}    selenium_coam.get_object_name_list    object_name=LNCEL-${delete_cell_id}
    ${object_num}   Get Length   ${object_list}
    Run Keyword If  ${object_num}!=${0}    selenium_coam.remove_object    object_name=LNCEL-${delete_cell_id}    timeout=15
    Run Keyword If  ${object_num}!=${0}    selenium_coam.remove_object    object_name=LCELL-${delete_cell_id}    timeout=15
    Run Keyword If  ${object_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${object_num}!=${0}    selenium_coam.activate_plan
    sleep    60

Online add CABLINK
    [Arguments]  ${add_cablink_id}=${3}    ${firstEndpointPortId}=${2}    ${secondEndpointPortId}=${2}
    log to console  add CABLINK-${add_cablink_id}
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1
    ...    object_class_name=CABLINK    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-2
    ...    include_subobject=${True}   id_value=${add_cablink_id}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-${add_cablink_id}
    ...    filter_param=First endpoint port identifier    abbr=firstEndpointPortId    new_value=${firstEndpointPortId}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-${add_cablink_id}
    ...    filter_param=Second endpoint port identifier    abbr=secondEndpointPortId    new_value=${secondEndpointPortId}
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    sleep    60

Online delete CABLINK
    [Arguments]  ${del_cablink_id}=${3}
    log to console  delete CABLINK-${del_cablink_id}
    ${object_list}    selenium_coam.get_object_name_list    object_name=CABLINK-${del_cablink_id}
    ${object_num}   Get Length   ${object_list}
    Run Keyword If  ${object_num}!=${0}    selenium_coam.remove_object    object_name=CABLINK-${del_cablink_id}    timeout=15
    Run Keyword If  ${object_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${object_num}!=${0}    selenium_coam.activate_plan
    sleep    60

Online NRPGRP addition
    [Arguments]  ${NRPGRP_ID}=${1}    ${cell_num}=${2}    ${cell_id_list}=${None}
    log to console  \n add NRPGRP-${NRPGRP_ID}
    ${status}   Run Keyword And Return Status    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=New Radio Power Saving Group instance identifier
    ...    abbr=nrPGrpId
    Run keyword if    '${status}' != 'True'
    ...    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    object_class_name=NRPGRP    is_load_default_values=${True}    id_value=${NRPGRP_ID}    timeout=15
    #set basic
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving last cell switch off enabled    abbr=lbpsLastCellSOEnabled
    ...    new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving maximum load    abbr=lbpsMaxLoad    new_value=${15}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving minimum load    abbr=lbpsMinLoad    new_value=${4}
    #set lbpsCellList
    ${stream}    get stream from version    ${Active_SW_version}
    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving cell period list    abbr=lbpsCellPeriodList
    FOR    ${index}    IN RANGE    0    ${cell_num}
        ${lbpsCellSOOrder}   set variable    ${{60 + ${index} * 3}}
        # Use real cell ID from cell_id_list if provided, otherwise fall back to index + 1
        ${nrCellId}   set variable if    ${cell_id_list} != ${None}    ${cell_id_list}[${index}]    ${{${index} + 1}}
        run keyword if    '${index}'!='0'    selenium_coam.add_element
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving cell list    abbr=lbpsCellList    timeout=15
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving cell switch off order    abbr=lbpsCellSOOrder
        ...    new_value=${lbpsCellSOOrder}    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=NR cell configuration identifier    abbr=nrCellId
        ...    new_value=${nrCellId}    node_index=${index}
        Run Keyword if   '${stream}'!='SBTS23R1' and '${stream}'!='SBTS23R2'
        ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Use load-based power saving extended configurations    abbr=lbpsUseExtConfig
        ...    new_value=false    node_index=${index}
    END
    #set lbpsPeriodList
    FOR    ${index}    IN RANGE    0    7
        ${lbpsDayOfWeek}   set variable if
        ...     ${index}==0        Mon
        ...     ${index}==1        Tue
        ...     ${index}==2        Wed
        ...     ${index}==3        Thu
        ...     ${index}==4        Fri
        ...     ${index}==5        Sat
        ...     Sun
        run keyword if    '${index}'!='0'    selenium_coam.add_element
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving period list    abbr=lbpsPeriodList    timeout=15
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving day of week    abbr=lbpsDayOfWeek    new_value=${lbpsDayOfWeek}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving duration    abbr=lbpsDuration    new_value=${1440}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving start time hour    abbr=lbpsStartTimeHour    new_value=${1}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving start time minute    abbr=lbpsStartTimeMinute    new_value=${0}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-Based Power Saving Suspended    abbr=lbpsSuspended    new_value=notSuspended
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    sleep    60

Online delete NRPGRP
    [Arguments]  ${NRPGRP_ID}=${1}
    log to console  \n delete NRPGRP-${NRPGRP_ID}
    ${object_list}    selenium_coam.get_object_name_list    object_name=NRPGRP-${NRPGRP_ID}
    ${object_num}   Get Length   ${object_list}
    Run Keyword If  ${object_num}!=${0}    selenium_coam.remove_object    object_name=NRPGRP-${NRPGRP_ID}    timeout=15
    Run Keyword If  ${object_num}!=${0}    selenium_coam.validate_plan
    Run Keyword If  ${object_num}!=${0}    selenium_coam.activate_plan
    sleep    60
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}
