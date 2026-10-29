*** Settings ***
Documentation
...    author: fangmin.wu
...    contact:fangmin.wu@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    feature : 5GC001358-C

Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot

*** Variables ***
${ue_type}                   ${tl.ues[-1].capabilities[-1]}
${mrbtsId}                   ${tl.gnbs[0].instance_id}
${nrbtsId}                   ${tl.gnbs[0].global_bts_id}
${data_amount}    2M
${seg_size}    1300
${process_num}    5
${protocol}  udp
${deviation}    1%
${SAVE LOG DIRECTORY}    /home/ute/Downloads/
${default_scf_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/

*** Keywords ***

DU_WebEM.Get NR Cell distname and id
    [Documentation]  This KW is for get cell distname and id list
    ${cell_info}=    coam.get_cells_info    cell_type=nr    timeout=30    connection=GNB_OAM
    @{cell_id_list}    create list
    FOR    ${elem}    IN    @{cell_info}
        #Append to list    ${cell_distname_list}   ${elem['id']['configuration']}
        Append to list    ${cell_id_list}   ${elem['id']}
        Set Suite Variable    ${cell_id_list}
    END

Get parameter value
    [Arguments]    ${para}
    ${bts_info}=  coam.get_current_scf_content    connection=GNB_OAM
    ${value}    get lines containing string    ${bts_info}    ${para}
    ${value}    remove string    ${value}    <p name="${para}">    </p>    ${SPACE}
    ${value}    fetch from left    ${value}    ${\n}
    [Return]    ${value}

Get nrarfcn and gscn original value
    ${nrarfcn_value}    Get parameter value    para=nrarfcn
    ${gscn_value}    Get parameter value    para=gscnOrSsPbchArfcn
    set test variable     ${original_nrarfcn}    ${nrarfcn_value}
    set test variable     ${original_gscn}    ${gscn_value}

Change parameter value
    [Arguments]    ${para_name}    ${para_value}
    coam.perform_parameter_recommissioning      dist_name=MRBTS-${mrbtsId}/NRBTS-${mrbtsId}/NRCELL-1
    ...                                         parameter=${para_name}
    ...                                         operation=update
    ...                                         value=${para_value}
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
Block cell
    [Arguments]    ${cell_id}
    log to console    \n ###block cell-${cell_id} ###
    coam.block_cell    dist_name=MRBTS-${mrbtsId}/NRBTS-${mrbtsId}/NRCELL-${cell_id}
    ...               connection=GNB_OAM
    FOR    ${i}    IN RANGE    ${60}
        ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${mrbtsId}/NRCELL_R-${cell_id}
        ...    timeout=30   operational_State=Disabled    procedural_Status=configured
        ...    blockingState=Blocked    administrative_State=Unlocked
        Exit For Loop If    '${res[0]}'=='PASS'
    END

Unblock cell
    [Arguments]    ${cell_id}
    log to console    \n ###unblock cell-${cell_id} ###
    coam.unblock_cell    dist_name=MRBTS-${mrbtsId}/NRBTS-${mrbtsId}/NRCELL-${cell_id}
    ...               connection=GNB_OAM
    FOR    ${i}    IN RANGE    ${60}
        ${res}    run keyword and ignore error    DU_WebEM.Check NR Cell status
        ...    cell_internal_id=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-${mrbtsId}/NRCELL_R-${cell_id}
        ...    timeout=30   operational_State=Enabled
        ...    procedural_Status=configured
        ...    blockingState=Unblocked    administrative_State=Unlocked
        Exit For Loop If    '${res[0]}'=='PASS'
    END

DU_WebEM.Check NR Cell status
    [Documentation]  This KW is for get one cell status and check cell onair
    [Arguments]    ${cell_internal_id}    ${timeout}    ${operational_State}=${empty}
    ...    ${procedural_Status}=${empty}    ${availability_Status}=${empty}    ${blockingState}=${empty}
    ...    ${administrative_State}=${empty}
    ${cell_info}=    coam.get_cell_specific_info
    ...   cell_id=${cell_internal_id}   timeout=30    connection=GNB_OAM
    Run keyword if   '${operational_State}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['operationalState']}    ${operational_State}    ignore_case=true
    Run keyword if   '${procedural_Status}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['proceduralStatus']}    ${procedural_Status}     ignore_case=true
    Run keyword if   '${availability_Status}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['availabilityStatus']}    ${availability_Status}    ignore_case=true
    Run keyword if   '${blockingState}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['blockingState']}    ${blockingState}    ignore_case=true
    Run keyword if   '${administrative_State}' != '${empty}'
    ...   Should be equal    ${cell_info['status']['administrativeState']}    ${administrative_State}    ignore_case=true


Change nrarfcn value out of range
    Log    \n Change nrarfcn value out of range   console=yes
    Change parameter value    para_name=gscnOrSsPbchArfcn    para_value=7864
    Change parameter value    para_name=nrarfcn    para_value=636782

Restore nrarfcn value
    Log    \n Restore nrarfcn value  console=yes
    Change parameter value    para_name=gscnOrSsPbchArfcn    para_value=7880
    Change parameter value    para_name=nrarfcn    para_value=636666


Check nrarfcn value and restore to previous version
    Log    \n Wait For Fault with Alarm to appear    console=yes
    ${nrarfcn_val}    Get parameter value    para=nrarfcn
    ${gscn_val}    Get parameter value    para=gscnOrSsPbchArfcn
    run keyword if    '${nrarfcn_val}'=='${original_nrarfcn}' and '${gscn_val}'=='${original_gscn}'
    ...      return from keyword
    restore nrarfcn value

Wait until cell is on air status
    [Arguments]  ${timeout}=15 min    ${connection}=GNB_OAM
    log    ${timeout}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB cell on air    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    Verify all cells should be onair

Test Case setup to on air
    [Arguments]    ${scf_name}    ${scf_parameters}    ${is_pdl_checking_needed}=${False}
    COAM Create log directory
    Connect to gnb coam via ssl
    ${output_scf_file_path}    COAM Modify scf file    scf_file_path=${default_scf_path}${scf_name}  scf_parameters_list=${scf_parameters}
    COAM Commission with scf file    scf_file_path=${output_scf_file_path}    is_pdl_checking_needed=${False}
   	Wait Until Keyword Succeeds    30min    20s    Verify all cells should be onair    connection=GNB_OAM

Power UE Precondition
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}    reset_sol=ue_reboot

Power UE Attach and Verify attach
    [Arguments]    ${4g_check}=False    ${gnb_index}=${0}
     Log To Console    \n ###UE attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    set test variable    ${5Grach_ed_0}    ${5Grach_ed_0}
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Power UE Detach
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

Block unblock cell 2 and check the result
    Block cell    cell_id=2
    Check UE status and throughput
    Unblock cell    cell_id=2
    Check UE status and throughput
    Power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
#    Stop traffic and detach UE

Block unblock cell 1 and check the result
    Block cell     cell_id=1
    Check UE status and throughput
    Unblock cell    cell_id=1
    Check UE status and throughput
    Power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
#    Stop traffic and detach UE

Online Cell addition deletion and make call
    [Documentation]  Online last Cell addition deletion via webem
    [Arguments]  ${addition_deletion_cell}=1  ${addition_deletion_cellgrp}=0    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}  Get All Cell Group Id
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    Set Test Variable    ${cell_id_remain}    1
    run keyword if    ${addition_deletion_cell}==1    set test variable    ${cell_id_remain}    2
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}    timeout=15
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
#    log to console  make call on cell1
#    Set Test Variable    ${cell_id}    1
#    run keyword if    ${addition_deletion_cell}==1    set test variable    ${cell_id}    2
#    Make call and check result
    Check UE status and throughput
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    id_value=${addition_deletion_cellgrp}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${addition_deletion_cell}
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
    Wait Until Keyword Succeeds    5min    5s    verify all cells should be onair
    Check UE status and throughput
    Stop traffic and detach UE
#    log to console  make call on all cells
#    Make call and check result
#    Change defaultLnRelGnbCellId value    target_value=${addition_deletion_cell}
#    Make call and check result
    [Return]  selenium logout and close browser

Make call and start traffic on cell
    [Arguments]     ${cell_id}     ${data_send_dl}=800M    ${data_send_ul}=80M
	...             ${tp_direction}=both
	Change defaultLnRelGnbCellId value    target_value=${cell_id}
	Power UE Attach and Verify attach
    Start traffic according to direction and protocol  data_send_dl=${data_send_dl}    tp_direction=${tp_direction}
    ...            data_send_ul=${data_send_ul}

Check UE status and throughput
    [Arguments]    ${dltp_expected}=200    ${ultp_expected}=50
	...            ${tp_direction}=both    ${sleep_time}=15s
	log to console     \n ###Check UE status and throughput ###
	Power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    AAsys log captrue    sleep_time=${sleep_time}
    Run keyword and continue on failure    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}

Stop traffic and detach UE
    Stop traffic according to direction and protocol   tp_direction=both
    Power UE Detach

Make call and check result
    [Arguments]    ${dltp_expected}=700  ${data_send_dl}=800M    ${data_send_ul}=100M
	...             ${ultp_expected}=50    ${tp_direction}=both    ${sleep_time}=30s
	Power UE Attach and Verify attach
    Start traffic according to direction and protocol  data_send_dl=${data_send_dl}    tp_direction=${tp_direction}
    ...            data_send_ul=${data_send_ul}
    AAsys log captrue    sleep_time=${sleep_time}
    Run keyword and continue on failure    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}
    Stop traffic according to direction and protocol   tp_direction=${tp_direction}
    Power UE Detach

Start traffic according to direction and protocol
    [Arguments]  ${data_send_dl}    ${data_send_ul}=60M     ${tp_direction}=both
    log to console      Start traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${data_send_ul}    duration=3600    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=2M
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${data_send_dl}    duration=3600    ue_type=${ue_type}    seg_size=${seg_size}    protocol=${protocol}
	...    process_num=${process_num}    window=32M
    sleep    20s

Check throughput according to direction and protocol
    [Arguments]    ${dltp_expected}=10    ${ultp_expected}=10    ${tp_direction}=both
    log to console      Check throughput

    ${all_tp}    Get ul and dl peak and ave throughput from syslog     aasys_start_flag=${False}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'          Run keyword and continue on failure
    ...      should be true    ${all_tp[1]}>${dltp_expected}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'          Run keyword and continue on failure
    ...     should be true    ${all_tp[4]}>${ultp_expected}
    Set Suite Variable     ${all_tp}

Stop traffic according to direction and protocol
    [Arguments]  ${tp_direction}=both
    log to console      Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    protocol=tcp
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}    protocol=tcp

Get ul and dl peak and ave throughput from syslog
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
#    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_number}    get length    ${cell_id}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

Change defaultLnRelGnbCellId value
    [Arguments]    ${target_value}
    Connect to eNB via ssl
    Modify the parameter on enblte    dist_name=MRBTS-3111/LNBTS-3111/LNCEL-57877     parameter_name=defaultLnRelGnbCellId    value=${target_value}
    [Teardown]    coam.teardown    connection=enblte


