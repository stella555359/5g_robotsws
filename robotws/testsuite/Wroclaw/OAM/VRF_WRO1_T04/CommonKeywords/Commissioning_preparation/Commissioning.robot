*** Settings ***
Documentation
...     Test suite for Keywords in progress
...     Functionalities can be used
...     Restoring correct commissioning - using basic SCF for cOAM1/scfs folder
...     Get parameter values based on configuration (not from info model).
...     Create and upload Delta for new cell and/or to modify other parameters. All list/dict examples are python variables.

Resource    ../Component_states/Component_states_resources/component_states_checker.robot
Library     taf.sbts.oam.coam.admin     WITH NAME     cli
Library     ../Prepare_TL/resources.py
Resource   ../Connections/Connectivity_keywords.robot
Resource   ../Admin_CLI/Basic_WebEM_operation.robot
Resource   ../Component_states/Check_while_component_status.robot
Library    taf.config.scf    WITH NAME    scf
Library    OperatingSystem
Library    Collections
Library    String

*** Variables ***
${btsid}                  ${tl.gnbs[0].instance_id}

*** Keywords ***
Restoring correct commissioning
    [Documentation]    Restoring basic SCF for current TL
    ...                As optional arguments it takes the connection alias.
    [Arguments]    ${connection}=default
    log to console    ___START Restoring basic scf file from repository
    ${MRBTS_id}    convert to string    ${btsid}
    ${stream}=       cli.get_sw_release_name
    ${stream}=       fetch from left    ${stream}    _
    ${stream}=       remove string    ${stream}    SBTS
    ${upload_SCF}=    proper_scf_mapping    ${MRBTS_id}
    ${upload_SCF_path}=    replace string    ${upload_SCF}    /scfs/   /scfs/${stream}/
    ${scf_exist}=    run keyword and return status    OperatingSystem.file should exist    ${upload_SCF_path}
    ${upload_SCF}    set variable if    '${scf_exist}'=='True'    ${upload_SCF_path}    ${upload_SCF}
    wait until keyword succeeds    7 min   30 sec   cli.Perform Commissioning
    ...     scf_file=${upload_SCF}
    ...     skip_parameter_relation_errors=${False}
    ...     connection=${connection}
    ...     timeout=900
    wait until keyword succeeds    900    10    Check if BTS is OnAir state
    log to console    ___DONE Restoring basic configuration.

#KW to check parameter values based on SCF
Get SCF file from BTS
    [Documentation]    Required to retrieve values from SCF.
    ${scf_file}    admin_cli.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=actual_SCF.xml
    scf.load_scf    ${scf_file}

Get value from SCF
    [Documentation]    Will get param value from uploaded SCF. Only works when "Get SCF file from BTS" was executed. Arguments example:
    ...    MRBTS-10000/NRBTS-10000/NRCELL-2    physCellId
    [Arguments]    ${dist_name}    ${param_name}
    ${param_value}    scf.get_value_from_scf
    ...    dist_name=${dist_name}
    ...    p_name=${param_name}
    [Return]    ${param_value}

Get list value from SCF
    [Documentation]    Only works when "Get SCF file from BTS" was executed. Works only on lists. Index starts from 0.Arguments example:
    ...    MRBTS-10000/NRBTS-10000/NRDU-1    refNrCellGroup    1
    [Arguments]    ${dist_name}    ${list_name}    ${index_number}
    ${param_value}    scf.get_value_from_scf
    ...    dist_name=${dist_name}
    ...    list_name=${list_name}
    ...    index=${index_number}
    [Return]    ${param_value}

Remove SCF file from logs
    [Documentation]    Only works when "Get SCF file from BTS" was executed. Remove SCF file that was downloaded from BTS.
    Run   rm ${OUTPUT_DIR}/actual_SCF.xml

#Delta creation - Main KW
Create new Cell via Delta
	[Documentation]    This KW will create new Cell by copy another one from SCF. All neccesary parameters will be updated accordingly.
	...    Arguments:
	...    cell_id - Mandatory parameter. Correct Cell ID number that will be used to create new one.
	...    t_rmod - Targed RMOD of new cell. Type "None" to no changes.
	...    prachc_i - PrachConfigurationIndex for new cell. Default - prach_from_old_one +1.
	...    t_cellgroup - Target CellGroup ID - Default value - 50.
	...    t_cell_id - Target Cell ID of new cell - Default value - 50.
	...    phys_id - physCellId of new cell - Default value - 100.
	...    cellgroup_i - index from nrCellList in NRCELLGRP of new cell.
	...    mrbts_id_delta - MNBTSID - Default value is taken from init file.
	...    Returns:
	...    Cell ID of new cell.
	...    New CellGroup ID.
    [Arguments]    ${cell_id}    ${t_rmod}=None    ${prachc_i}=None    ${t_cellgroup}=50
    ...    ${t_cell_id}=50    ${phys_id}=100    ${cellgroup_i}=0    ${mrbts_id_delta}=${btsid}    ${skip_parameter_relation_errors}=False
    ${scf_1}    ${scf_2}    Start Delta preparation
    ${t_cell_id}    ${t_cellgroup}  Add new cell to Delta    ${cell_id}    ${t_rmod}    ${prachc_i}    ${t_cellgroup}
    ...    ${t_cell_id}    ${phys_id}    ${cellgroup_i}    ${mrbts_id_delta}
    Create and upload Delta    ${scf_1}    ${scf_2}    ${skip_parameter_relation_errors}
    [Return]    ${t_cell_id}    ${t_cellgroup}

Delete Cell via Delta
    [Documentation]    By this KW cell will be deleted using delta json. NRCELLGRP from target cell will be erased also.
    ...    Arguments:
    ...    t_cell_id - Cell ID which will be removed.
    ...    mrbts_id_delta - MNBTSID - Default value is taken from init file.
    [Arguments]    ${t_cell_id}    ${mrbts_id_delta}=${btsid}
    ${scf_1}    ${scf_2}    Start Delta preparation
    Delete Cell by Delta    ${t_cell_id}    ${mrbts_id_delta}
    Create and upload Delta    ${scf_1}    ${scf_2}

Modify parameter via Delta
    [Documentation]    This KW can be used to change any configurable parameter via delta json.
    ...    Arguments:
    ...    Param_and_Values - List of values that can be changed. If param doesn't exist then it will be ignored without TC abort.
    ...    List example: (first - modify standard value, second - modify value on the list)
    ...    [["MRBTS-10000/NRBTS-10000/NRCELL-100", "prachConfigurationIndex", "15"],
    ...    ["MRBTS-10000/NRBTS-10000/NRDU-1", "refNrCellGroup", "2", "10"]]
    [Arguments]  ${Param_and_Values}
    ${scf_1}    ${scf_2}    Start Delta preparation
    Modify Cell parameter by full list    ${Param_and_Values}
    Create and upload Delta    ${scf_1}    ${scf_2}


#Delta creation - low level KW
#These KW require execution of:
#"Start Delta preparation" at the beggining and "Create and upload Delta" at the end. Example:
#
#${scf_1}    ${scf_2}    Start Delta preparation
#Add new cell to Delta    1
#Modify Cell parameter    MRBTS-50324/NRBTS-50324/NRCELL-50    [["prachConfigurationIndex", "15"], ["a1MeashoSsbRsrp", "2", "25"]]
#Create and upload Delta    ${scf_1}    ${scf_2}

Start Delta preparation
    [Documentation]    Required to create new Delta. Returns scfs path that will be used during delta commissioning.
    ${scf_file}=     admin_cli.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=basic_SCF.xml
    ${scf_file_delta}=     admin_cli.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=delta_SCF.xml
    scf.load_scf    ${scf_file_delta}
    [Return]    ${scf_file}    ${scf_file_delta}

Add new cell to Delta
    [Documentation]    Create new cell by copying another existing cell. Arguments are the same like in "Create new Cell via Delta" KW.
    ...    Returns new Cell ID and Cell Group.
    [Arguments]    ${original_cell_id}    ${target_rmod}=None    ${prach_conf_index}=None    ${target_cellgroup_id}=50
    ...    ${target_cell_id}=50    ${phys_cell_id}=100    ${cellgroup_index}=0    ${mrbts_id_for_new_cell}=${btsid}
    ${original_cellgroup_id}    Get CellGroup number from Cell    ${original_cell_id}
    scf.clone_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${original_cell_id}
    ...    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}
    scf.clone_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${original_cell_id}
    ...    MRBTS-${mrbts_id_for_new_cell}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${target_cell_id}
    scf.clone_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELLGRP-${original_cellgroup_id}
    ...    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELLGRP-${target_cellgroup_id}
    scf.modify_scf_element    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELLGRP-${target_cellgroup_id}
    ...    list_name=nrCellList    index=${cellgroup_index}    value=${target_cell_id}
    scf.modify_scf_element    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}    p_name=lcrId
    ...    value=${target_cell_id}
    scf.add_elements_to_list    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRDU-1    list_name=refNrCellGroup
    ...    elements=c
    ${refNrCellGroup_modified}    scf.get_all_values_from_scf    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRDU-1
    ...    list_name=refNrCellGroup
    set test variable    ${refNrCellGroup_index}    0
    FOR    ${i}    IN    @{refNrCellGroup_modified}
        ${cellgroup_c}    run keyword and return status    should be equal    ${i}    c
        run keyword if    '${cellgroup_c}'=='True'    scf.modify_scf_element
        ...    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRDU-1
        ...    list_name=refNrCellGroup    index=${refNrCellGroup_index}    value=${target_cellgroup_id}
        ${refNrCellGroup_index}    evaluate    ${refNrCellGroup_index}+1
    END
    run keyword if    '${prach_conf_index}'=='None'    Prach index change    ${target_cell_id}    ELSE    scf.modify_scf_element
    ...    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}    p_name=prachConfigurationIndex
    ...    value=${prach_conf_index}
    scf.modify_scf_element    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}    p_name=physCellId
    ...    value=${phys_cell_id}
    run keyword if    '${target_rmod}'!='None'    Change RMOD in new Cell    ${original_cell_id}    ${target_cell_id}    ${target_rmod}
    ...    ${mrbts_id_for_new_cell}
    [Return]    ${target_cell_id}    ${target_cellgroup_id}

Create and upload Delta
    [Documentation]    Only works when "Start Delta preparation" was executied and other changes was made (for example
    ...    new cell or parameter modify).
    [Arguments]    ${scf_file}    ${scf_file_delta}    ${skip_parameter_relation_errors}=False
    scf.save_scf    ${scf_file_delta}
    scf.calculate_delta_scf    ${scf_file_delta}    ${scf_file}    ${OUTPUT_DIR}/delta.json
    admin_cli.perform_delta_recommissioning
    ...     delta_file=${OUTPUT_DIR}/delta.json
    ...     skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...     should_activate=True
    ...     timeout=1800

Delete Cell by Delta
    [Documentation]    Will delete Cell from uploaded SCF.
    [Arguments]    ${target_cell_id}    ${mrbts_id_for_new_cell}=${btsid}
    ${target_cellgroup_id}    Get CellGroup number from Cell    ${target_cell_id}
    scf.remove_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}
    scf.remove_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${target_cell_id}
    scf.remove_mo_with_descendant_mos    MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELLGRP-${target_cellgroup_id}
    ${refNrCellGroup_modified}    scf.get_all_values_from_scf    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRDU-1
    ...    list_name=refNrCellGroup
    set test variable    ${refNrCellGroup_index}    0
    FOR    ${i}    IN    @{refNrCellGroup_modified}
        ${cellgroup_c}    run keyword and return status    should be equal    ${i}    ${target_cellgroup_id}
        run keyword if    '${cellgroup_c}'=='True'    scf.remove_element_from_scf
        ...    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRDU-1
        ...    list_name=refNrCellGroup    index=${refNrCellGroup_index}
        ${refNrCellGroup_index}    evaluate    ${refNrCellGroup_index}+1
    END

Get CellGroup number from Cell
    [Documentation]    KW used to retrieve Cell Group number based on Cell ID.
    [Arguments]    ${cell_number}
    ${cellggroup_list}    admin_cli.get_bts_info
    FOR    ${c}    IN    @{cellggroup_list["cellsGroup"]}
        ${cell_is_visible}    run keyword and return status    should contain    ${c["nrCellList"]}    NRCELL-${cell_number}
        run keyword if    '${cell_is_visible}'=='False'    continue for loop
        ${cellgroup_id}    fetch from right    ${c["name"]}    -
    END
    [Return]    ${cellgroup_id}

Change RMOD in new Cell
    [Documentation]    Will change RMOD id on target Cell. Base will taken from original cell.
    [Arguments]    ${original_cell_id}    ${target_cell_id}    ${target_rmod}    ${mrbts_id_for_new_cell}=${btsid}
    ${scf_rmod}=     admin_cli.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=rmod_SCF.xml
    ${number_of_channels}    Run    grep LCELNR-${original_cell_id}/CHANNELGROUP-1/CHANNEL ${scf_rmod} | wc -l
    ${number_of_channels}    evaluate    ${number_of_channels}+1
    FOR    ${g}    IN RANGE   ${number_of_channels}
        run keyword if    '${g}'=='0'    continue for loop
        ${orininal_param}    scf.get_value_from_scf
        ...    dist_name=MRBTS-${mrbts_id_for_new_cell}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${target_cell_id}/CHANNELGROUP-1/CHANNEL-${g}
        ...    p_name=antlDN
        ${target_param}    replace string using regexp    ${orininal_param}    RMOD-\\d+    RMOD-${target_rmod}
        scf.modify_scf_element
        ...    dist_name=MRBTS-${mrbts_id_for_new_cell}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${target_cell_id}/CHANNELGROUP-1/CHANNEL-${g}
        ...    p_name=antlDN    value=${target_param}
    END
    [Teardown]    run keyword and ignore error    Run    rm ${scf_rmod}

Prach index change
    [Documentation]    prachConfigurationIndex of target cell will be increased by deklared amount (default is 1).
    [Arguments]    ${target_cell_id}    ${target_num}=1    ${mrbts_id_for_new_cell}=${btsid}
    ${prach_conf_index}    scf.get_value_from_scf
    ...    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}
    ...    p_name=prachConfigurationIndex
    ${prach_conf_index}    evaluate    ${prach_conf_index}+${target_num}
    scf.modify_scf_element    dist_name=MRBTS-${mrbts_id_for_new_cell}/NRBTS-${mrbts_id_for_new_cell}/NRCELL-${target_cell_id}
    ...    p_name=prachConfigurationIndex    value=${prach_conf_index}

Modify Cell parameter
    [Documentation]    KW to modify params from one object. Arguments:
    ...    Dist_name - target object. For example: MRBTS-10000/NRBTS-1000-/NRDU-1
    ...    Param_and_Values - List of parameters and list index. Example:
    ...    [["prachConfigurationIndex", "15"],["refNrCellGroup", "2", "10"]]
    ...    If object doesn't exist it will be ignored.
    [Arguments]    ${Dist_Name}   ${Param_and_Values}
    ${correct_values}    evaluate    [2, 3]
    FOR    ${p}    IN    @{Param_and_Values}
        ${items_in_list}    get length    ${p}
        #\    run keyword if    '${item_in_list}'!='2' or '${item_in_list}'!='3'    run keywords
        #...    log    Invalid list ${p}.    AND    continue for loop
        ${matched_v}    get index from list    ${correct_values}    ${items_in_list}
        #\    ${matched_v}    run keyword and return status    should contain any    ${item_in_list}    2    3
        run keyword if    '${matched_v}'=='-1'    run keywords    log    Modify. Invalid list ${p}. It has been ignrored.    level=WARN
        ...    AND    continue for loop
        run keyword if    '${items_in_list}'=='2'    Modify Element in string    ${Dist_Name}    ${p}[0]    ${p}[1]
        ...    ELSE    Modify Element in list    ${Dist_Name}    ${p}[0]    ${p}[1]    ${p}[2]
    END

Modify Cell parameter by full list
    [Documentation]    KW to modify params in all objects. Argument example:
    ...    [["MRBTS-10000/NRBTS-10000/NRCELL-100", "prachConfigurationIndex", "15"],
    ...    ["MRBTS-10000/NRBTS-10000/NRDU-1", "refNrCellGroup", "2", "10"]]
    ...    If object doesn't exist Midify command won't be executed.
    [Arguments]    ${Param_and_Values}
    ${correct_values}    evaluate    [3, 4]
    FOR    ${p}    IN    @{Param_and_Values}
        ${items_in_list}    get length    ${p}
        ${matched_v}    get index from list    ${correct_values}    ${items_in_list}
        run keyword if    '${matched_v}'=='-1'    run keywords    log    Modify. Invalid list ${p}. It has been ignrored.    level=WARN
        ...    AND    continue for loop
        run keyword if    '${items_in_list}'=='3'    Modify Element in string    ${p}[0]    ${p}[1]    ${p}[2]
        ...    ELSE    Modify Element in list    ${p}[0]    ${p}[1]    ${p}[2]    ${p}[3]
    END

Modify Element in list
    [Documentation]    KW to modify single index on the list. If object doesn't exist modify command will not be executed. Example:
    ...    MRBTS-10000/NRBTS-10000/NRDU-1    refNrCellGroup    2    10
    [Arguments]    ${dist_n}    ${list_n}    ${index_n}    ${value_n}
    ${param_exist}    scf.is_list_in_object    ${dist_n}    ${list_n}
    run keyword if    '${param_exist}'=='False'    run keywords
    ...    log    Modify. List ${list_n} in object ${dist_n} and index ${index_n} doesn't exist. No changes has been made.    level=WARN
    ...    AND   return from keyword
    scf.modify_scf_element    dist_name=${dist_n}    list_name=${list_n}    index=${index_n}    value=${value_n}

Modify Element in string
    [Documentation]    KW to modify single non-list parameter. If object doesn't exist modify command will not be executed. Example:
    ...    MRBTS-10000/NRBTS-10000/NRCELL-3    physCellId    54
    [Arguments]    ${dist_n}    ${param_n}   ${value_n}
    ${param_exist}    scf.is_element_in_object    ${dist_n}    ${param_n}
    run keyword if    '${param_exist}'=='False'    run keywords
    ...    log    Modify. Param ${param_n} in object ${dist_n} doesn't exist. No changes has been made.    level=WARN
    ...    AND   return from keyword
    scf.modify_scf_element    dist_name=${dist_n}    p_name=${param_n}    value=${value_n}

Add Cell parameter
    [Documentation]    Will add new parameters in single object. If object doesn't exist in SCF Add command will be ignored.
    ...    New list will be created if needed.
    ...    Arguments:
    ...    Dist_name - target object. For example: MRBTS-10000/NRBTS-1000-/NRDU-1
    ...    Param_and_Values - List of parameters and list index. Example: (last one is for dict type of list.
    ...    [["prachConfigurationIndex", "15"],["refNrCellGroup", "2", "10"],["a1MeashoSsbRsrp", {"param1": "pa1", "param2": "pa2"}]]
    [Arguments]    ${Dist_Name}   ${Param_and_Values}
    ${correct_values}    evaluate    [2]
    FOR    ${p}    IN    @{Param_and_Values}
        ${items_in_list}    get length    ${p}
        ${matched_v}    get index from list    ${correct_values}    ${items_in_list}
        run keyword if    '${matched_v}'=='-1'    run keywords    log    Invalid list ${p}.    level=WARN
        ...    AND    continue for loop
        ${element_type}    Check variable type    ${p}[1]
        run keyword if    '${element_type}'=='string'    run keywords    Add Element in string    ${Dist_Name}    ${p}[0]    ${p}[1]
        ...    AND    continue for loop
        ${list_exist}    scf.is_list_in_object    ${Dist_Name}    ${p}[0]
        run keyword if    '${list_exist}'=='False'    Add list to delta    ${Dist_Name}    ${p}[0]
        run keyword if    '${element_type}'=='list'    Add Element in list by Index    ${Dist_Name}    ${p}[0]    ${p}[1]
        ...    ELSE   Add Element in list by Param    ${Dist_Name}    ${p}[0]    ${p}[1]
    END

Add Cell parameter by full list
    [Documentation]    Will add new parameters in all object. If object doesn't exist in SCF Add command will be ignored.
    ...    New list will be created if needed.
    ...    Example:
    ...    [["MRBTS-10000/NRBTS-10000/NRCELL-100", "param1", "pa1"],
    ...    ["MRBTS-10000/NRBTS-10000/NRCELL-100", "a1MeashoSsbRsrp", ["25", "35"]],
    ...    ["MRBTS-10000/NRBTS-10000/NRCELL-100", "a1MeashoSsbRsrp", {"param1": "pa1", "param2": "pa2"}]]
    [Arguments]    ${Param_and_Values}
    ${correct_values}    evaluate    [3]
    FOR    ${p}    IN    @{Param_and_Values}
        ${items_in_list}    get length    ${p}
        ${matched_v}    get index from list    ${correct_values}    ${items_in_list}
        run keyword if    '${matched_v}'=='-1'    run keywords    log    Invalid list ${p}. It has been ignrored.    level=WARN
        ...    AND    continue for loop
        ${element_type}    Check variable type    ${p}[2]
        run keyword if    '${element_type}'=='string'    run keywords    Add Element in string    ${p}[0]    ${p}[1]    ${p}[2]
        ...    AND    continue for loop
        ${list_exist}    scf.is_list_in_object    ${p}[0]    ${p}[1]
        run keyword if    '${list_exist}'=='False'    Add list to delta    ${p}[0]    ${p}[1]
        run keyword if    '${element_type}'=='list'    Add Element in list by Index    ${p}[0]    ${p}[1]    ${p}[2]
        ...    ELSE   Add Element in list by Param    ${p}[0]    ${p}[1]    ${p}[2]
    END

Add Element in list by Param
    [Documentation]    Will add new element in dict. Some lists in SCFs dictionary and other KW have to be used. Arguments example:
    ...    MRBTS-10000/NRBTS-10000/NRCELL-100    a1MeashoSsbRsrp    {"param1": "pa1", "param2": "pa2"}\
    ...    If object or list doesn't exist in SCF Add command will be ignored.
    [Arguments]    ${dist_n}    ${list_n}    ${index_n}
    ${param_exist}    scf.is_object_in_scf    ${dist_n}
    run keyword if    '${param_exist}'=='False'    run keywords
    ...    log    Add. Object ${dist_n} doesn't exist. No changes has been made.    level=WARN
    ...    AND   return from keyword
    ${list_exist}    scf.is_list_in_object    ${dist_n}    ${list_n}
    run keyword if    '${list_exist}'=='False'    run keywords
    ...    log    Add. List ${list_n} in object ${dist_n} doesn't exist. No changes has been made.    level=WARN
    ...    AND   return from keyword
    scf.add_item_to_list    dist_name=${dist_n}    list_name=${list_n}    elements=${index_n}

Add Element in list by Index
    [Documentation]    Will add new element in list. Arguments example:
    ...    MRBTS-10000/NRBTS-10000/NRCELL-100    a1MeashoSsbRsrp    ["15", "16", "17"]
    ...    If object or list doesn't exist in SCF Add command will be ignored.
    [Arguments]    ${dist_n}    ${list_n}    ${index_n}
    ${param_exist}    scf.is_object_in_scf    ${dist_n}
    run keyword if    '${param_exist}'=='False'    run keywords
    ...    log    Add. Object ${dist_n} doesn't exist. No changes has been made.    level=WARN
    ...    AND   return from keyword
    ${list_exist}    scf.is_list_in_object    ${dist_n}    ${list_n}
    run keyword if    '${list_exist}'=='False'    run keywords
    ...    log    Add. List ${list_n} in object ${dist_n} doesn't exist. No changes has been made.    level=WARN
    ...    AND   return from keyword
    scf.add_elements_to_list    dist_name=${dist_n}    list_name=${list_n}    elements=${index_n}

Add Element in string
    [Documentation]    Add new element in object. Example:
    ...    MRBTS-10000/NRBTS-10000/NRCELL-3    cellParam2    true
    ...    If object doesn't exist in SCF Add command will be ignored.
    [Arguments]    ${dist_n}    ${param_n}   ${value_n}
    ${param_exist}    scf.is_object_in_scf    ${dist_n}
    run keyword if    '${param_exist}'=='False'    run keywords
    ...    log    Add. Object ${dist_n} doesn't exist. No changes has been made.    level=WARN
    ...    AND   return from keyword
    scf.add_element_to_scf    dist_name=${dist_n}    p_name=${param_n}    value=${value_n}

Add list to delta
    [Documentation]    This KW will add new list to object. It is required to create new list modifying it by adding new element. Example:
    ...    MRBTS-10000/NRBTS-10000/NRCELL-123    newList2
    ...   If object doesn't exist or list is already in SCF Add command will be ignored.
    [Arguments]    ${dist_n}    ${list_n}
    ${param_exist}    scf.is_object_in_scf    ${dist_n}
    run keyword if    '${param_exist}'=='False'    run keywords
    ...    log    Add. Object ${dist_n} doesn't exist. No changes has been made.    level=WARN
    ...    AND   return from keyword
    ${list_exist}    scf.is_list_in_object    ${dist_n}    ${list_n}
    run keyword if    '${list_exist}'=='True'    run keywords
    ...    log    Add. List ${list_n} in object ${dist_n} exist already. No changes has been made.    level=WARN
    ...    AND   return from keyword
    scf.add_list_to_scf    dist_name=${dist_n}    list_name=${list_n}

Delete Cell parameter
    [Documentation]    KW will remove parameters and/or elements from SCF.
    ...    If object/param/element doesn't exist in SCF it will be ignored during execution.
    ...    Arguments: (Parameter, object, element on the list)
    ...    [["MRBTS-10000/NRBTS-10000/NRCELL-100", "prachConfigurationIndex"],
    ...    ["MRBTS-50324/NRBTS-50324/NRCELL-1/NRRELLTE-1"],
    ...    ["MRBTS-50324/NRBTS-50324/NRDU-1", "refNrCellGroup", "0", "2"]]
    [Arguments]    ${Param_and_Values}
    ${correct_values}    evaluate    [1, 2, 3]
    FOR    ${p}    IN    @{Param_and_Values}
        ${items_in_list}    get length    ${p}
        ${matched_v}    get index from list    ${correct_values}    ${items_in_list}
        run keyword if    '${matched_v}'=='-1'    run keywords    log    Delete. Invalid list ${p}. It has been ignrored.    level=WARN
        ...    AND    continue for loop
        run keyword if    '${items_in_list}'=='1'    run keywords    Delete Object    ${p}[0]    AND    continue for loop
        run keyword if    '${items_in_list}'=='2'    Delete Element in string    ${p}[0]    ${p}[1]
        ...    ELSE    Delete Element in list    ${p}[0]    ${p}[1]    ${p}[2]
    END

Delete Object
    [Documentation]    KW will delete whole object with all parameters and lists.
    ...   Delete command will be ignored if object doesn't exist already.
    ...   Argument example:    MRBTS-10000/NRBTS-10000/NRCELL-100
    [Arguments]    ${dist_n}
    ${param_exist}    scf.is_object_in_scf    ${dist_n}
    run keyword if    '${param_exist}'=='False'    run keywords
    ...    log    Delete. Object ${dist_n} doesn't exist. No changes has been made.    level=WARN
    ...    AND   return from keyword
    scf.remove_mo_with_descendant_mos    dist_name=${dist_n}
    ${param_exist}    scf.is_object_in_scf    ${dist_n}

Delete Element in list
    [Documentation]    KW will delete element from target list. If this element doesn't exist in SCF Delete command will be ignored.
    ...    Arguments example:
    ...    MRBTS-50324/NRBTS-50324/NRDU-1    refNrCellGroup    10
    [Arguments]    ${dist_n}    ${list_n}    ${index_n}
    ${param_exist}    run keyword and return status    scf.get_value_from_scf    dist_name=${dist_n}    list_name=${list_n}    index=${index_n}
    run keyword if    '${param_exist}'=='False'    run keywords
    ...    log    Delete. List ${list_n} in object ${dist_n} and index ${index_n} doesn't exist. No changes has been made.    level=WARN
    ...    AND   return from keyword
    scf.remove_element_from_scf    dist_name=${dist_n}    list_name=${list_n}    index=${index_n}

Delete Element in string
    [Documentation]    KW will delete parameter/list from SCF. Delete command won't be executed if parameter/list doesn't exist in SCF.
    [Arguments]    ${dist_n}    ${param_n}
    ${param_exist}    scf.is_element_in_object    ${dist_n}    ${param_n}
    ${list_exist}    scf.is_list_in_object    ${dist_n}    ${param_n}
    run keyword if    '${list_exist}'=='True'    run keywords    scf.remove_list_from_scf    dist_name=${dist_n}    list_name=${param_n}
    ...    AND   return from keyword
    ...    ELSE IF    '${param_exist}'=='True'    run keywords    scf.remove_element_from_scf    dist_name=${dist_n}    p_name=${param_n}
    ...    AND   return from keyword
    ...    ELSE    run keywords    log    Delete. Param ${param_n} in object ${dist_n} doesn't exist. No changes has been made.    level=WARN
    ...    AND   return from keyword
    scf.remove_element_from_scf    dist_name=${dist_n}    p_name=${param_n}    value=${value_n}

Check variable type
    [Documentation]    Will check variable type. Returns "sting", "list" or "dict".
    [Arguments]    ${var_to_check}
    ${non_string}    ${type}    run keyword and ignore error    evaluate    type(${var_to_check})
    return from keyword if  '${non_string}'=='FAIL'    string
    ${is_int}    run keyword and return status    should contain    '${type}'    int
    run keyword if    '${is_int}'=='True'    return from keyword    string
    ${is_list}    run keyword and return status    should contain    '${type}'    list
    run keyword if    '${is_list}'=='True'    return from keyword    list
    ...    ELSE    return from keyword    dict
