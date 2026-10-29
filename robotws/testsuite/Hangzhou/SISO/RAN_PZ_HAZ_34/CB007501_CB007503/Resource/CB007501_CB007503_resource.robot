*** Settings ***
Documentation
...    author: zhang lusha
...    contact: lusha.zhang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_2_SG


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot

*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${ue_type}    ${tl.ues[0].capabilities[1]}

*** Keywords ***
SISO Coam Suite Setup With Specify SCF
    [Arguments]    ${enb_flag}=${True}    ${scf_suffix}=0    ${gnb_index}=0
    robot_common_operations.Common Suite Setup
    log to console    \n*** SISO Coam Suite Setup With Specify SCF  scf_suffix:${scf_suffix} ***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path_Temp}    Get Golden SCF Path    gnb_index=${gnb_index}
    ${Golden_SCF_Path}=    Replace String    ${Golden_SCF_Path_Temp}    .xml    ${scf_suffix}.xml
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    run keyword if     '${ru_type_init}'=='AEQN'    remove fault 4687 from allowed fault list
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    run keyword if     '${gNb_CuType}'=='NSA' and '${enb_flag}'=='${True}' or '${gNb_CuType}'=='SA+NSA' and '${enb_flag}'=='${True}'
    ...    Run Keyword And Ignore Error    get eNB active version
    run keyword if     ${if_commissioning} and '${testline_name}' != 'null'
    ...    bts_coam.Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    set suite variable    ${suite_setup_fail_flag}    ${False}

1:Prepare UE
    [Arguments]     ${ue_index}=${0}
    log to console      Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}

2:UE Attach
    [Arguments]     ${ue_index}=${0}
    log to console      UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    ...    attach_mode=5G_NSA
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

3:Start traffic udp
    [Arguments]   ${ul_throughput}=150M    ${dl_throughput}=600M    ${protocol}=udp    ${ue_index}=${0}
    log to console      Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=600    ue_type=${ue_type}
    ...    iperf_type=via_command
    ...    protocol=udp
    sleep    1s
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=600    ue_type=${ue_type}
    ...    protocol=udp    buffer_size=1280B    seg_size=1350    process_num=${2}
    sleep    2s

4:Check Throughput
    [Arguments]    ${list_of_cell_ids}=${0}
    log to console    check tput
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=3m
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
    ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${True}
    ...    min_percent=0.7

5:Stop traffic
    [Arguments]     ${ue_index}=0
    log to console      Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_command
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}

6:UE Detach
    [Arguments]     ${ue_index}=${0}
    log to console      UE Detach
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

Data Transfer DL UL
    [Arguments]    ${ue_index}=${0}    ${ul_throughput}=220M    ${dl_throughput}=2G
    ...    ${list_of_cell_ids}=${0}
    1:Prepare UE
    2:UE Attach
    3:Start traffic udp    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
    4:Check Throughput    list_of_cell_ids=${list_of_cell_ids}
    5:Stop traffic
    6:UE Detach

UE L3 Call
    1:Prepare UE
    2:UE Attach
    6:UE Detach

General_SiSo_Cell_lock_and_unlock
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}
    Get X2 link shutdown waiting time
    # ${cell_id_list}  Get All Cell Id
    # ${cell_num}    get length  ${cell_id_list}
    # Lock and Unlock Cells or Groups and L3  lock_list=${cell_id_list}  is_group=${False}  with_call=${with_call}  with_peak=${with_peak}
    Connect to gnb coam via ssl
    ${cellgrp_id_list}  Get All Cell Group Id
    ${cellgrp_num}    get length  ${cellgrp_id_list}
    Lock and Unlock Cells or Groups and L3  lock_list=${cellgrp_id_list}  is_group=${True}  with_call=${with_call}  with_peak=${with_peak}
    # run keyword if  ${cell_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}
    # run keyword if  ${cellgrp_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cellgrp_id_list}  is_group=${True}

Online Cell addition deletion without cellgrp
    [Documentation]  Online last Cell addition deletion via webem
    [Arguments]  ${addition_deletion_cell_list}=${1}  ${addition_deletion_cellgrp}=0    ${connection}=GNB_OAM
    ${cell_in_grp}    Get Cell From Cell Group    cellgrp_id=${addition_deletion_cellgrp}
    List Should Contain Sub List    ${cell_in_grp}    ${addition_deletion_cell_list}
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    log to console  delete celllist ${addition_deletion_cell_list}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    FOR    ${cell_index}    IN    @{addition_deletion_cell_list}
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}    timeout=15
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    timeout=15
    END
    Delete celllist in grp celllist    cell_id_list=${addition_deletion_cell_list}    addition_deletion_cellgrp=${addition_deletion_cellgrp}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    COAM Check GNB cell on air

    log to console  add object
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    log to console  add object 1
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object 2
    FOR    ${addition_deletion_cell}    IN    @{addition_deletion_cell_list}
        log to console  add object addition_deletion_cell:${addition_deletion_cell}
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
        ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
        ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
        log to console  add object 3
        sleep    2s
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
        ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
        sleep    2s
        log to console  add object 4
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
        ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${addition_deletion_cell}
        log to console  add object 5
    END
    Add celllist in grp celllist    cell_id_list=${addition_deletion_cell_list}    addition_deletion_cellgrp=${addition_deletion_cellgrp}
    log to console  add object 4
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}

    Wait Until Keyword Succeeds    5min    5s    verify all cells should be onair
    [Return]  selenium logout and close browser

Delete celllist in grp celllist
    [Arguments]    ${cell_id_list}    ${addition_deletion_cellgrp}=0    ${connection}=GNB_OAM
    ${cell_in_grp}    Get Cell From Cell Group    cellgrp_id=${addition_deletion_cellgrp}
    ${cell_list_len}    get length    ${cell_in_grp}
    FOR    ${index}    IN RANGE    ${cell_list_len}
        ${value}    selenium_coam.get_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
        ...    abbr=nrCellList
        ...    filter_param=List of NR cells assigned to cell group
        ...    node_index=${index}
        ${cell_id_index}=    Get Index From List    ${cell_id_list}    ${${value}}
        run keyword if    ${cell_id_index}>=0    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
        ...    abbr=nrCellList
        ...    filter_param=List of NR cells assigned to cell group
        ...    node_index=${index}
    END

Add celllist in grp celllist
    [Arguments]    ${cell_id_list}    ${addition_deletion_cellgrp}=0    ${connection}=GNB_OAM
    ${cell_in_grp}    Get Cell From Cell Group    cellgrp_id=${addition_deletion_cellgrp}
    ${cell_list_len}    get length    ${cell_in_grp}
    FOR    ${cell_id}    IN    @{cell_id_list}
        selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
        ...    abbr=nrCellList
        ...    filter_param=List of NR cells assigned to cell group
        ...    timeout=15
        selenium_coam.set_parameter_value
            ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
            ...    filter_param=List of NR cells assigned to cell group
            ...    new_value=${cell_id}
            ...    node_index=${cell_list_len}
        ${cell_list_len}    Set Variable     ${cell_list_len+1}
    END

Online Cell addition deletion within cellgrp
    [Documentation]  Online Cellgrp addition deletion via webem
    [Arguments]  ${addition_deletion_cellgrp}=0    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${addition_deletion_cell_list}    Get Cell From Cell Group    cellgrp_id=${addition_deletion_cellgrp}
    log to console  delete celllist ${addition_deletion_cell_list} and cellgrp ${addition_deletion_cellgrp}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    FOR    ${cell_index}    IN    @{addition_deletion_cell_list}
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}    timeout=15
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_index}    timeout=15
    END
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}    timeout=15
    ${cell_grp}    Get All Cell Group Id
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

    log to console  celllist ${addition_deletion_cell_list} and cellgrp ${addition_deletion_cellgrp}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    FOR    ${addition_deletion_cell}    IN    @{addition_deletion_cell_list}
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
        ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
        ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
        ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
        ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${addition_deletion_cell}
    END
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    id_value=${addition_deletion_cellgrp}    timeout=15
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

    Wait Until Keyword Succeeds    5min    5s    verify all cells should be onair
    [Return]  selenium logout and close browser
