*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    DateTime
Library    taf.selenium.sbts  WITH NAME  selenium_coam

*** Variables ***

*** Keywords ***
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

Get Single Parameter Value on WebUI
    [Arguments]  ${dist_name}    ${filter_param}
    ${currect_value}    selenium_coam.Get Parameter Value    dist_name=${dist_name}
    ...    filter_param=${filter_param}
    [Return]  ${currect_value}

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

Modify Single Parameter Value on WebUI
    [Arguments]  ${dist_name}    ${filter_param}    ${abbr}    ${new_value}
    selenium_coam.set_parameter_value  dist_name=${dist_name}
        ...    filter_param=${filter_param}
        ...    abbr=${abbr}    new_value=${new_value}
    selenium_coam.validate_plan
    ${defErrs_dic}    selenium_coam.get_definition_errors
    ${list_num}   Get Length   ${defErrs_dic}
    Should be true    ${list_num}==${0}
    selenium_coam.activate_plan

Execute Configuration Reset on WehUI
    [Arguments]  ${timeout_for_reset}=60
    selenium_coam.configuration_reset  timeout_for_reset=${timeout_for_reset}

Perform BTS Site Reset On WebUI
    ${is_startup_window_exist}      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_site

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
