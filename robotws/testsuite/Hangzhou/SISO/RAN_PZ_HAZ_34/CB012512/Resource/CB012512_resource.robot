*** Settings ***
Documentation
...    author: zhang lusha
...    contact: lusha.zhang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_CM_Recommissioning.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_SM_BTS_Site_Reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007501_CB007503/Resource/CB007501_CB007503_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

Library    BuiltIn
Library    Collections
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py

*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${ue_type}    ${tl.ues[0].capabilities[2]}
${BASIC_PATH_5G}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G
# ${UTE_syslogs_path}   /home/ute

*** Keywords ***
# CB012512 Start Syslog
#     Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
#     ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
#     ...      Test_PC_password=${Test_PC_password}
#     ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
#     ...      btslog_launcher_path=/opt/btslog/btslog
#     sleep     2s

# CB012512 Stop Syslog And Check ERR WRN
#     Stop BTSlogs Collection And Download Logs To Log Server
#     log to console      UTE_logs_path is : ${UTE_syslogs_path}
#     Run Keyword And Continue On Failure      Check ERR Or WRN From Syslog
#     ...      sys_logs_path=${UTE_syslogs_path}
#     ...      UTE_logs_path=${UTE_logs_path}
#     ...      base_file=${Base_ERR_WRN_csv_path}
#     ...      Expected_ERR_WRN_deviation=0.08      Delete_old_ERR_WRN=1
#     ...       Fail_Case=False       Clear_log=True
#     ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.7

CB012512 Throughput test
    ${list_of_cell_ids}    Create List    33210369
    Throughput test        cells=${list_of_cell_ids}    dl_tp=712
    ...    dl_exp=500   ul_tp=80   ul_exp=50    ul_iperf_process=2

CB012512 Online Cell Addition
    [Arguments]  ${cell_add_info}    ${copy_scf_path}    ${connection}=GNB_OAM
    selenium login and disable screen lock
    CB012512 Online Cell Addition Steps    cell_add_info=${cell_add_info}    copy_scf_path=${copy_scf_path}    connection=${connection}
    [Teardown]  selenium logout and close browser

CB012512 Online Cell Addition Steps
    [Documentation]  Author: lusha zhang
    ...    this KW is aim to add 1 cell copy from other SCF, now only used for CB012512 cases
    ...    cell_add_info: cell info dict have nrcell_id cellgrp_id and lcrid, describe the cell to be added
    ...    copy_scf_path: new added cell copy from this SCF
    [Arguments]  ${cell_add_info}    ${copy_scf_path}    ${with_active}=${True}    ${connection}=GNB_OAM
    Log to console    \n+++ CB012512 Online NR Cell addition cell_add_info:${cell_add_info} +++
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    ${addition_cell}    Get From Dictionary    ${cell_add_info}    nrcell_id
    ${addition_cellgrp}    Get From Dictionary    ${cell_add_info}    cellgrp_id
    ${addition_lcrid}    Get From Dictionary    ${cell_add_info}    lcrid
    ${cell_grp}  Get All Cell Group Id    connection=${connection}
    ${addition_cellgrp_iddex}    convert to integer    ${addition_cellgrp}
    append to list    ${cell_grp}    ${addition_cellgrp_iddex}
    # load SCF to be copied
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${copy_scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    ${copy_conf_name}    Get Source Plan Name    scf_file_path=${copy_scf_path}

    log to console  \nadd object NRCELL-${addition_cell} with_active:${with_active}
    wait until keyword succeeds    3x    30s    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=${copy_conf_name}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=${copy_conf_name}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=${copy_conf_name}
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_cellgrp}
    ...    id_value=${addition_cellgrp}    timeout=15
    Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${addition_lcrid}
    wait until keyword succeeds    3x    30s    selenium_coam.add_element
    ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR  ${i}  IN  @{cell_grp}
        Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${addition_cellgrp}
        ...    node_index=${addition_cellgrp_iddex}
    END
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    log to console    CB012512 Online Cell Addition Steps result scf_path: ${scf_path}
    sleep    30S
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    run keyword if    ${with_active}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}

CB012512 Online Cells Addition Steps
    [Arguments]  ${cells_add_info}    ${copy_scf_path}    ${with_active}=${True}    ${connection}=GNB_OAM
    Log to console    \n+++ CB012512 Online NR Cells addition cells_add_info:${cells_add_info} with_active:${with_active} +++
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    # load SCF to be copied
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${copy_scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    ${copy_conf_name}    Get Source Plan Name    scf_file_path=${copy_scf_path}
    FOR    ${cell_add_info}    IN    @{cells_add_info}
        ${addition_cell}    Get From Dictionary    ${cell_add_info}    nrcell_id
        ${addition_cellgrp}    Get From Dictionary    ${cell_add_info}    cellgrp_id
        ${addition_lcrid}    Get From Dictionary    ${cell_add_info}    lcrid
        ${cell_grp}  Get All Cell Group Id    connection=${connection}
        ${addition_cellgrp_iddex}    convert to integer    ${addition_cellgrp}
        append to list    ${cell_grp}    ${addition_cellgrp_iddex}
        log to console  \nadd object NRCELL-${addition_cell}
        wait until keyword succeeds    3x    30s    selenium_coam.add_object
        ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
        ...    object_class_name=LCELNR    plan_to_copy_from=${copy_conf_name}
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_cell}
        ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
        wait until keyword succeeds    3x    30s    selenium_coam.add_object
        ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELL    plan_to_copy_from=${copy_conf_name}
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
        ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
        wait until keyword succeeds    3x    30s    selenium_coam.add_object
        ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELLGRP    plan_to_copy_from=${copy_conf_name}
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_cellgrp}
        ...    id_value=${addition_cellgrp}    timeout=15
        Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_cell}
        ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${addition_lcrid}
        wait until keyword succeeds    3x    30s    selenium_coam.add_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    timeout=15
        FOR  ${i}  IN  @{cell_grp}
            Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
            ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
            ...    filter_param=Reference to cell group     new_value=${addition_cellgrp}
            ...    node_index=${addition_cellgrp_iddex}
        END
    END
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    log to console    CB012512 Online Cell Addition Steps result scf_path: ${scf_path}
    sleep    30S
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    run keyword if    ${with_active}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}

CB012512 Online Cell deletion
    [Arguments]    ${deletion_cell}=1    ${connection}=GNB_OAM
    selenium login and disable screen lock
    CB012512 Online Cell Deletion Steps    deletion_cell=${deletion_cell}    connection=${connection}
    [Teardown]  selenium logout and close browser

CB012512 Online Cell Deletion Steps
    [Arguments]    ${deletion_cell}=1    ${with_active}=${True}    ${connection}=GNB_OAM
    log to console  \n+++ delete object cell${deletion_cell} with_active:${with_active} +++
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    ${deletion_cellgrp}    Get Cell Group From Cell    cell_id=${deletion_cell}    connection=${connection}
    ${cell_grp}  Get All Cell Group Id    connection=${connection}
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${deletion_cell}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${deletion_cell}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${deletion_cellgrp}    timeout=15
    ${cell_grp_len}    Get Length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    wait until keyword succeeds    3x    30s    selenium_coam.get_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${deletion_cellgrp}'    wait until keyword succeeds    3x    30s
        ...    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        Exit For Loop If    '${value}'=='${deletion_cellgrp}'
    END
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    run keyword if    ${with_active}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}

CB012512 Online LTE Cell addition
    [Arguments]  ${addition_cell}    ${copy_scf_path}    ${addition_lcrid}=${None}
    selenium login and disable screen lock
    CB012512 Online LTE Cell Addition Steps    addition_cell=${addition_cell}    copy_scf_path=${copy_scf_path}
    ...    addition_lcrid=${addition_lcrid}
    [Teardown]  selenium logout and close browser

CB012512 Online LTE Cell Addition Steps
    [Arguments]  ${addition_cell}    ${copy_scf_path}    ${addition_lcrid}=${None}        ${with_active}=${True}
    ${addition_lcrid}    Set Variable If    ${addition_lcrid}==${None}    ${addition_cell}    ${addition_lcrid}
    Log to console    \n+++ CB012512 Online LTE Cell Addition Steps, addition_cell:${addition_cell} addition_lcrid: ${addition_lcrid} +++
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    ${lncell}    Run    cat ${copy_scf_path} | grep -oE "MRBTS-[0-9]+/LNBTS-[0-9]+" | head -n 1
    ${lnbtsID}    Run    echo ${lncell}|grep -oE "LNBTS-[0-9]+"| awk -F '-' '{print $2}'

    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${copy_scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    ${copy_conf_name}    Get Source Plan Name    scf_file_path=${copy_scf_path}

    log to console    add object LNCEL-${addition_cell}
    wait until keyword succeeds    3x    30s    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELL    plan_to_copy_from=${copy_conf_name}
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}
    ...    object_class_name=LNCEL    plan_to_copy_from=${copy_conf_name}
    ...    copy_from=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${addition_cell}
    ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
    Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${addition_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${addition_lcrid}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    log to console    CB012512 Online LTE Cell Addition Steps result scf_path: ${scf_path}
    sleep    30S
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    run keyword if    ${with_active}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}

CB012512 Online Add LNBTS
    [Arguments]  ${addition_cells}    ${copy_scf_path}        ${with_active}=${True}
    Log to console    \n+++ CB012512 Online Add LNBTS, addition_cells:${addition_cells} +++
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    ${lncell}    Run    cat ${copy_scf_path} | grep -oE "MRBTS-[0-9]+/LNBTS-[0-9]+" | head -n 1
    ${lnbtsID}    Run    echo ${lncell}|grep -oE "LNBTS-[0-9]+"| awk -F '-' '{print $2}'

    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${copy_scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    ${copy_conf_name}    Get Source Plan Name    scf_file_path=${copy_scf_path}

    wait until keyword succeeds    3x    30s    selenium_coam.add_object
    ...    object_name=MRBTS-${mrbtsID}
    ...    object_class_name=LNBTS    plan_to_copy_from=${copy_conf_name}
    ...    copy_from=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}
    ...    include_subobject=${True}   id_value=${lnbtsID}    timeout=15

    FOR    ${addition_cell}    IN    @{addition_cells}
        log to console    adding LNCEL-${addition_cell}
        wait until keyword succeeds    3x    30s    selenium_coam.add_object
        ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
        ...    object_class_name=LCELL    plan_to_copy_from=${copy_conf_name}
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${addition_cell}
        ...    include_subobject=${True}   id_value=${addition_cell}    timeout=15
        Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${addition_cell}
        ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${addition_cell}
    END
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    log to console    CB012512 Online LTE Cell Addition Steps result scf_path: ${scf_path}
    sleep    30S
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    run keyword if    ${with_active}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}

CB012512 Online LTE Cell Deletion
    [Arguments]    ${deletion_cell}=1
    selenium login and disable screen lock
    CB012512 Online LTE Cell Deletion Steps    deletion_cell=${deletion_cell}
    [Teardown]  selenium logout and close browser

CB012512 Online LTE Cell Deletion Steps
    [Arguments]    ${deletion_cell}=1    ${with_active}=${True}
    log to console  \n+++ delete LTE cell ${deletion_cell}, with_active=${with_active} +++
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${deletion_cell}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/LNBTS-${nrbtsID}/LNCEL-${deletion_cell}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    run keyword if    ${with_active}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}

Check If Given NR Cell On Air
    [Arguments]    ${cell}
    return from keyword if    '${cell['status']['operationalState'].lower()}' != 'enabled'    ${False}
    return from keyword if    '${cell['status']['proceduralStatus'].lower()}' != 'configured'    ${False}
    return from keyword if    '${cell['status']['usageState'].lower()}' != 'active'    ${False}
    return from keyword if    '${cell['status']['administrativeState'].lower()}' != 'unlocked'    ${False}
    return from keyword if    '${cell['status']['blockingState'].lower()}' != 'unblocked'    ${False}
    return from keyword    ${True}

Check If Given LTE Cell On Air
    [Arguments]    ${cell}
    return from keyword if    '${cell['status']['operationalState'].lower()}' != 'enabled'    ${False}
    return from keyword if    '${cell['status']['usageState'].lower()}' != 'idle'    ${False}
    return from keyword if    '${cell['status']['administrativeState'].lower()}' != 'unlocked'    ${False}
    return from keyword if    '${cell['status']['blockingState'].lower()}' != 'unblocked'    ${False}
    return from keyword    ${True}

Get Failed Cells Info
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=900
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=${timeout}    connection=${connection}
    ${nr_failed_cells_info}    create list
    FOR    ${cell}    IN    @{nr_cells_info}
        ${cell_is_on_air}    Check If Given NR Cell On Air    cell=${cell}
        Continue For Loop If    '${cell_is_on_air}'=='True'
        Append to List    ${nr_failed_cells_info}      ${cell['id']['configuration'].lower()}
    END
    Log to console    *** nr_failed_cells_info:${nr_failed_cells_info} ***

    ${lte_cells_info}   coam.get_cells_info  cell_type=lte    timeout=${timeout}    connection=${connection}
    ${lte_failed_cells_info}    create list
    FOR    ${cell}    IN    @{lte_cells_info}
        ${cell_is_on_air}    Check If Given LTE Cell On Air    cell=${cell}
        Continue For Loop If    '${cell_is_on_air}'=='True'
        Append to List    ${lte_failed_cells_info}      ${cell['id']['configuration'].lower()}
    END
    Log to console    *** lte_failed_cells_info:${lte_failed_cells_info} ***
    [Return]    ${nr_failed_cells_info}    ${lte_failed_cells_info}

Check FID1868 On Expected Cells And Other Cells On Air
    [Arguments]    ${nr_alarm_1868_list}=${None}    ${lte_alarm_1868_list}=${None}    ${nr_alarm_count}=0    ${lte_alarm_count}=0
    Log to console    Check FID1868 expect ${nr_alarm_count} NR cells and ${lte_alarm_count} LTE cells
    ${nr_failed_cells_info}    ${lte_failed_cells_info}    Get Failed Cells Info
    ${nr_failed_cells_num}    Get Length    ${nr_failed_cells_info}
    ${lte_failed_cells_num}    Get Length    ${lte_failed_cells_info}
    Should be True    ${nr_failed_cells_num}==${nr_alarm_count}
    Should be True    ${lte_failed_cells_num}==${lte_alarm_count}
    FOR    ${nr_failed_cell_info}    IN    @{nr_failed_cells_info}
        Expect Fault Should Present    faultId=1868     configObjectName=${nr_failed_cell_info.upper()}
    END
    FOR    ${lte_failed_cell_info}    IN    @{lte_failed_cells_info}
        Expect Fault Should Present    faultId=1868     configObjectName=${lte_failed_cell_info.upper()}
    END
    run keyword if    ${nr_alarm_1868_list}!=${None}    Check FID 1868 list contain cell info
    ...    alarm_1868_list=${nr_failed_cells_info}    expect_alarm_1868_list=${nr_alarm_1868_list}
    run keyword if    ${lte_alarm_1868_list}!=${None}    Check FID 1868 list contain cell info
    ...    alarm_1868_list=${lte_failed_cells_info}    expect_alarm_1868_list=${lte_alarm_1868_list}

Check FID 1868 list contain cell info
    [Arguments]    ${alarm_1868_list}     ${expect_alarm_1868_list}
    FOR    ${expect_alarm_1868_info}    IN    @{expect_alarm_1868_list}
        List Should Contain Value    ${alarm_1868_list}    ${expect_alarm_1868_info}
    END

Commission SCF And Check FID 1868
    [Arguments]    ${SCF_Path}    ${nr_alarm_count}=0    ${lte_alarm_count}=0
    Log to console    +++ Commission SCF And Check FID 1868 SCF:${SCF_Path} +++
    COAM Commission with scf file    scf_file_path=${SCF_Path}    timeout=900
    coam wait for gnb ready and cell setup
    wait until keyword succeeds    20min    10s
    ...    Check FID1868 On Expected Cells And Other Cells On Air
    ...    nr_alarm_count=${nr_alarm_count}    lte_alarm_count=${lte_alarm_count}

Perform BTS Site Reset And Check FID 1868
    [Arguments]    ${nr_alarm_count}=0    ${lte_alarm_count}=0
    Perform BTS Site Reset
    sleep     90s
    coam wait for gnb ready and cell setup
    wait until keyword succeeds    20min    10s
    ...    Check FID1868 On Expected Cells And Other Cells On Air
    ...    nr_alarm_count=${nr_alarm_count}    lte_alarm_count=${lte_alarm_count}

Recovery SCF From EC case
    [Arguments]    ${connection}=GNB_OAM
    Log to console    \n*** Recovery SCF From EC case ***
    Connect to gnb coam via ssl    connection=${connection}
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}    connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

CB012512 Change Celltype From 16D8U To 8D8U Steps
    [Arguments]    ${Change_cell_list}    ${with_active}=${True}
    log to console  change cell: ${Change_cell_list} from 16D8U to 8D8U with_active:${with_active}
    FOR    ${Change_cell}    IN    @{Change_cell_list}
        wait until keyword succeeds    3x    30s    selenium_coam.remove_object
        ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${Change_cell}/CHANNELGROUP-3    timeout=15
        wait until keyword succeeds    3x    30s    selenium_coam.remove_object
        ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${Change_cell}/CHANNELGROUP-4    timeout=15
        Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${Change_cell}
        ...    filter_param=NR Cell type    abbr=nrCellType    new_value=8DL8UL
    END
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    run keyword if    ${with_active}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}

CB012512 Change Celltype From 8D8U To 16D8U Steps
    [Arguments]    ${Change_cell_list}    ${copy_scf_path}    ${with_active}=${True}
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    log to console  change cell: ${Change_cell_list} from 8D8U to 16D8U steps with_active:${with_active}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${copy_scf_path}
    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    ${copy_conf_name}    Get Source Plan Name    scf_file_path=${copy_scf_path}
    FOR    ${Change_cell}    IN    @{Change_cell_list}
        wait until keyword succeeds    3x    30s    selenium_coam.add_object
        ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${Change_cell}
        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=${copy_conf_name}
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${Change_cell}/CHANNELGROUP-3
        ...    include_subobject=${True}   id_value=${3}    timeout=15
        wait until keyword succeeds    3x    30s    selenium_coam.add_object
        ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${Change_cell}
        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=${copy_conf_name}
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${Change_cell}/CHANNELGROUP-4
        ...    include_subobject=${True}   id_value=${4}    timeout=15
        Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${Change_cell}
        ...    filter_param=NR Cell type    abbr=nrCellType    new_value=16DL8UL
    END
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    run keyword if    ${with_active}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}

Alarm 1868 in Given Alarm list Present
    [Arguments]  ${connection}=GNB_OAM
    log to console  \n Check fault 1900 or 4008 on WebUI
    ${alarm_list}    create list    1868
    ${status}    set variable    ${False}
    FOR    ${faultId}    IN    @{alarm_list}
        ${status}    run keyword and return status  Expect Fault Should Present    faultId=${faultId}    connection=${connection}
        run keyword if    ${status}    log to console  \n fault ${faultId} raise on WebUI
        exit for loop if    ${status}
    END
    should be true    ${status}

peak_throughput
    [Arguments]    ${ue_index}=${0}    ${dl_tp}=1496    ${ul_tp}=50    ${duration}=460    ${ul_iperf_process}=4    ${cap_duration}=300
	...    ${pci}=62    ${cells}=${cells}    ${Case_SCF_Path}=${Case_SCF_Path}
    [Documentation]    params ${dl_tp}, ${ul_tp} unit:Mbits/sec
    ${peak_dl}    ${peak_ul}    get_theoretical_throughput    scf_path=${Case_SCF_Path}
    ...                                                       cell_id=0
    ...                                                 ue_ul_layer=${2}    ue_dl_layer=${4}
    log to console    \n***Prepare UE***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    log to console    \n***UE Detach ***
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}
    log to console    \n***UE Attach***
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    pci=${pci}    log_type=aasyslog    timeout=900
    log to console    \n***start traffic***
    ${start_traffic_duration}    evaluate    ${duration}+${60}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}Mbits/sec
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}Mbits/sec
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}    process_num=${ul_iperf_process}
    ${Tput_logs}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${cap_duration}    check_source=aasyslog

    log to console    \n***Stop traffic ***
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}

    log to console    \n***check tput ***
	${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${Tput_logs}    cells=${cells}
	...    check_source=aasyslog
    ...    ultarget_throughput=${peak_ul}    dltarget_throughput=${peak_dl}    actCarrierAggregation=${False}

Block and unblock single cell
    [Documentation]  jerry.wu@nokia-sbell.com
    [Arguments]  ${idx}=0    ${technology}=NR    ${timeout}=120
    Selenium Login And Disable Screen Lock
    log to console  \nBlock Global cell ID : ${idx} for ${technology} and check status
    selenium_coam.block_cell    cell_idx=${idx}    technology=${technology}    timeout=${timeout}
    Wait Until Keyword Succeeds   3 min  10 sec   check single cell should be blocked   cell_idx=${idx}   cell_type=${technology.lower()}
    Wait For Expect Fault Present    faultId=49    timeout=30
	selenium_coam.unblock_cell    cell_idx=${idx}  timeout=${timeout}  technology=${technology}
    Wait Until Keyword Succeeds   7 min  10 sec   check single cell should be unblocked   cell_idx=${idx}   cell_type=${technology.lower()}
