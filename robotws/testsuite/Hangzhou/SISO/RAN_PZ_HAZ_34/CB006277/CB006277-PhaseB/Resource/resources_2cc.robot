*** Settings ***
Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB006277 in 5G22R1 program

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

*** Keywords ***
General_SiSo_Online_Cell_addition_deletion_AQQL
    [Arguments]    ${addition_deletion_cell}=${1}    ${addition_deletion_cellgrp}=${0}
	log to console    General_SiSo_Online_Cell_addition_deletion_AQQL
    ${addition_deletion_cell_list}  create list    ${addition_deletion_cell}
    #Get UE From Init File and Make call    cell_list=${addition_deletion_cell_list}
    Online Cell addition deletion flexible lCelnrId    addition_deletion_cell=${addition_deletion_cell}
    ...    addition_deletion_cellgrp=${addition_deletion_cellgrp}
    #Get UE From Init File and Make call    cell_list=${addition_deletion_cell_list}
Online Cell addition deletion flexible lCelnrId
    [Documentation]  Online last Cell addition deletion via webem and get online lCelnrId
    [Arguments]  ${addition_deletion_cell}=1  ${addition_deletion_cellgrp}=0    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}  Get All Cell Group Id
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
	${lcrId}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${addition_deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    COAM Check GNB cell on air
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lcrId}
    ...    include_subobject=${True}   id_value=${lcrId}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    id_value=${addition_deletion_cellgrp}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrId}
    # recover NRDU-1 as prev
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR  ${i}  IN  @{cell_grp}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    sleep    60s
    verify all cells should be onair
    [Return]  selenium logout and close browser
General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith_AQQL
    [Arguments]  ${bandlist}    ${cell_id}=${None}  ${ue_num_each_call}=1  ${random_access}=${False}
    ...     ${L3call}=Not_Test_Throughput    ${duration}=${300}    &{kwargs}
    ${test_flag}  set variable  PASS
    ${bands}    set variable    ${EMPTY}
    FOR    ${item}    IN    @{bandlist}
        ${bands}    catenate    SEPARATOR=_    ${bands}    ${item}MHz
    END
    ${length}     Get length    ${frame_structure_list_${bands}}[0][frame]
    FOR    ${index}    IN RANGE    ${length}
        ${frame_info}    Get framestructinfo   framelistname=${frame_structure_list_${bands}}    frameindex=${index}
        ${status}  run keyword and ignore error  Modify_Band_Frame_Structure_${L3call}_multi_cc_with_different_bandwith
        ...    frames_info=${frame_info}    ue_num_each_call=${ue_num_each_call}  random_access=${random_access}
        ...    cell_id=${cell_id}    duration=${duration}    &{kwargs}
        ${test_flag}  set variable  ${status[0]}
    END
    run keyword if  '${test_flag}'=='FAIL'  fail   not all frame structure pass
Modify_Band_Frame_Structure_Not_Test_Throughput_multi_cc_with_different_bandwith
     [Arguments]  ${frames_info}    ${ue_num_each_call}=1   ${cell_id}=${None}
    ...    ${4G_check}=${False}    ${protocol}=udp    ${loop_times}=${2}    ${check_wait_time}=30    ${random_access}=${false}
    ...    ${connection}=GNB_OAM    ${duration}=${300}    ${ue_ul_layer}=1    &{kwargs}
    ${cell_index}    run keyword if    '${cell_id}'!='${None}'    convert to integer    ${cell_id}
    ${cell_list}    ${release}   ${scf_path}    Modify_Band_Frame_Structure_multi_cc_with_different_bandwith
    ...    frames_info=${frames_info}    cell_id=${cell_id}    &{kwargs} 
    [Teardown]  run keyword if    ('${gNb_CuType.upper()}'=='SA' or '${gNb_CuType.upper()}'=='BOTH') and '${cell_index}'!='${None}'
    ...    run keywords    connect to gnb coam via ssl    connection=${connection}    AND
    ...    coam_parameter.perform_scf_delta_commission    delta_file=${delta_file['reverse']}    connection=${connection}
	
