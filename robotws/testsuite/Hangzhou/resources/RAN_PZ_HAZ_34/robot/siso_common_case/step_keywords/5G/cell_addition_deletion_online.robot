*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot

*** Keywords ***
Get lcrId via webem
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}
    ${orig_value}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...  filter_param=Local cell resource ID
    [Return]  ${orig_value}

Online Cell addition deletion
    [Documentation]    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${addition_deletion_cell}=1    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${addition_deletion_cellgrp}    Get Cell Group From Cell    cell_id=${addition_deletion_cell}    connection=${connection}
    ${cell_grp}  Get All Cell Group Id    connection=${connection}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    ${lcrid}    Get lcrId via webem    cell_id=${addition_deletion_cell}
    log to console  delete object
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrid}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    wait until keyword succeeds    3x    30s    selenium_coam.get_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${addition_deletion_cellgrp}'    wait until keyword succeeds    3x    30s
        ...    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        Exit For Loop If    '${value}'=='${addition_deletion_cellgrp}'
    END
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}
    COAM Check GNB cell on air
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    ${copy_conf_name}    Get Source Plan Name    scf_file_path=${scf_path}
    log to console  add object
    wait until keyword succeeds    3x    30s    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=${copy_conf_name}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrid}
    ...    include_subobject=${True}   id_value=${lcrid}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=${copy_conf_name}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=${copy_conf_name}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    id_value=${addition_deletion_cellgrp}    timeout=15
    Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}
    # recover NRDU-1 as prev
    wait until keyword succeeds    3x    30s    selenium_coam.add_element
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR    ${index}    ${cell_grp_id}    IN ENUMERATE    @{cell_grp}
        Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${cell_grp_id}
        ...    node_index=${index}
    END
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    wait until keyword succeeds    3x    30s    selenium_coam.activate_plan
    ...    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}
    Wait Until Keyword Succeeds    5min   15s    verify all cells should be onair
    [Teardown]  selenium logout and close browser

Get gscn via webem
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}
    ${orig_value}    selenium_coam.get_parameter_value  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...  filter_param=Synchronization channel number
    [Return]  ${orig_value}

Online Modify Cell to Wrong
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}
    Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...  filter_param=Synchronization channel number    abbr=gscnOrSsPbchArfcn    new_value=10
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}
    Wait until keyword succeeds    2min    20sec    Expect Fault Should Present    faultId=7516

Generate Randon Cell id
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    ${cell_list}    get all cell id    connection=${connection}
    ${new_list}    create list
    FOR    ${i}    IN RANGE    ${100}
        append to list    ${new_list}    ${i}
    END
    remove values from list    ${new_list}    ${cell_list}
    ${new_cell}    evaluate    random.choice(${new_list})    modules=random
    [Return]  ${new_cell}

Online Add New Cell and Delete Old Cell
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}    ${lcrid}    ${gscn}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${new_cell}    Generate Randon Cell id    connection=${connection}
    log to console  \nadd new cell ${new_cell}
    ${cellgrp_id}    Get Cell Group From Cell    cell_id=${cell_id}    connection=${connection}
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    include_subobject=${True}   id_value=${new_cell}    timeout=15
    Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${new_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}
    Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${new_cell}
    ...  filter_param=Synchronization channel number    abbr=gscnOrSsPbchArfcn    new_value=${gscn}
    Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${cellgrp_id}
    ...    filter_param=List of NR cells assigned to cell group    abbr=nrCellList    new_value=${new_cell}    node_index=${0}
    log to console    \ndelete old cell ${cell_id}
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}    timeout=15
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}
    sleep    60
    wait until keyword succeeds    3min    10sec    verify all cells should be onair
    [Return]  ${new_cell}

Prepare for Online Cell Addition Deletion
    [Documentation]    author_shifu.lan@nokia-sbell.com
    [Arguments]  ${addition_deletion_cell_list}    ${connection}=GNB_OAM
    Log    Backup the parameters value for cells addition and deletion    console=${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    ${cell_grp}    Get All Cell Group Id    connection=${connection}
    @{lcrid_list}    create list
    @{addition_deletion_cellgrp_list}    create list

    FOR    ${addition_deletion_cell}    IN    @{addition_deletion_cell_list}
        ${addition_deletion_cellgrp}    Get Cell Group From Cell    cell_id=${addition_deletion_cell}    connection=${connection}
        Append To List    ${addition_deletion_cellgrp_list}    ${addition_deletion_cellgrp}
        ${lcrid}    Get lcrId via webem    cell_id=${addition_deletion_cell}
        Append To List    ${lcrid_list}    ${lcrid}
    END
    [Return]    ${scf_path}    ${cell_grp}    ${lcrid_list}    ${addition_deletion_cellgrp_list}

Delete Reference Cell And CellGroup
    [Arguments]  ${addition_deletion_cellgrp}    ${cell_grp_num}
    FOR    ${index}    IN RANGE    ${cell_grp_num}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        IF    '${value}'=='${addition_deletion_cellgrp}'
            selenium_coam.remove_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
            ...    abbr=refNrCellGroup    filter_param=Reference to cell group
            ...    node_index=${index}
            BREAK
        END
    END

Online Cells Deletion
    [Arguments]  ${addition_deletion_cell_list}    ${addition_deletion_cellgrp_list}    ${cell_grp}
    ${cell_grp_num}    Get Length    ${cell_grp}
    @{split_version}    String.Split String    ${Active_SW_version}    separator=_
    ${stream}    Set Variable     ${split_version}[0]
    FOR    ${addition_deletion_cell}    ${addition_deletion_cellgrp}    IN ZIP    ${addition_deletion_cell_list}
    ...    ${addition_deletion_cellgrp_list}
        Log To Console    \nDelete cell ${addition_deletion_cell}
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}    timeout=15
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}    timeout=15
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}    timeout=15
        Delete Reference Cell And CellGroup    ${addition_deletion_cellgrp}    ${cell_grp_num}
        IF    '${stream}'>='SBTS25R3'
            ${cell_grp_num}    Evaluate    ${cell_grp_num} - 1
        END
    END
    Activate Parameters

Online Cells Addition
    [Documentation]    shifu.lan@nokia-sbell.com
    [Arguments]  ${addition_deletion_cell_list}    ${addition_deletion_cellgrp_list}    ${lcrid_list}    ${cell_grp}    ${scf_path}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    ${copy_conf_name}    Get Source Plan Name    scf_file_path=${scf_path}
    FOR    ${addition_deletion_cell}    ${addition_deletion_cellgrp}    ${lcrid}    IN ZIP    ${addition_deletion_cell_list}
    ...    ${addition_deletion_cellgrp_list}    ${lcrid_list}
        Log To Console    \nAdd cell ${addition_deletion_cell}
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
        ...    object_class_name=LCELNR    plan_to_copy_from=${copy_conf_name}
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
        ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELL    plan_to_copy_from=${copy_conf_name}
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
        ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELLGRP    plan_to_copy_from=${copy_conf_name}
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
        ...    id_value=${addition_deletion_cellgrp}    timeout=15
        Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
        ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrid}
        # recover NRDU-1 as prev
        selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    timeout=15
    END
    FOR  ${index}  IN  @{cell_grp}
        Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${index}
        ...    node_index=${index}
    END
    Activate Parameters

Activate Parameters
    [Documentation]    shifu.lan@nokia-sbell.com
    [Arguments]  ${timeout}=360
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${timeout}
    Wait Until Keyword Succeeds    10min    30s    Check all cells info should be onair

Get Source Plan Name
    [Documentation]  Author: shifu.lan@nokia-sbell.com
    [Arguments]    ${scf_file_path}    ${default_conf_name}=CONF-1
    @{split_version}    String.Split String    ${Active_SW_version}    separator=_
    ${stream}    Set Variable     ${split_version}[0]
    IF    '${stream}'>='SBTS25R2'
        ${scf_file_name}    Fetch from right    ${scf_file_path}    /
        ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
        ${conf_name}    Catenate    SEPARATOR=_    ${default_conf_name}    ${file_name_without_extention}
    ELSE
        ${conf_name}    Set Variable     ${default_conf_name}
    END
    [Return]  ${conf_name}
