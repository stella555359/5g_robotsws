*** Settings ***
Documentation    CA Feature CB009843 Automation cases common steps
...              Author: jun.8.chen@nokia-sbell.com

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot


*** Variables ***
${if_pdl_check}       True


*** Keywords ***
General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    General_SiSo_Cell_lock_and_unlock.General_SiSo_Cell_lock_and_unlock    with_call=${False}
    Run Keyword And Continue On Failure    Make MTK Attach    cellid=401    is_do_require_ue=${True}
    Run Keyword And Continue On Failure    Make MTK Attach    cellid=501    is_do_require_ue=${False}
    Run Keyword And Continue On Failure    MTK L3 Call And Verify Throughput    cellid=601     is_do_require_ue=${False}
    Start To Check L1L2 Error Info From Syslog

General_SiSo_Online_Cell_Addition_Deletion
    Online Cell addition deletion For 9843    addition_deletion_cell=501
    Wait Gnb Ready And Cell On Air
    Online Cell addition deletion For 9843    addition_deletion_cell=601
    Wait Gnb Ready And Cell On Air
    Run Keyword And Continue On Failure    MTK L3 Call And Verify Throughput    cellid=501    is_do_require_ue=${True}
    Run Keyword And Continue On Failure    Make MTK Attach    cellid=601    is_do_require_ue=${False}
    Start To Check L1L2 Error Info From Syslog


Suite_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]  ${connection}=GNB_OAM
    run keyword and ignore error    Check And Power on RUs
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    ${ute_env}    Run Keyword And Return Status    Run Keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   Run Keyword If    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    Set Variable     ${testline_name}
    Set Suite Variable    ${testline_name}    ${testline}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${0}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    Set Suite Variable    ${gNb_CuType}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    Set Suite Variable      ${Active_SW_version}
    Suite Log Path Create
    Set Suite Variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    Log To Console    MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    Set Suite Variable    ${mrbtsID}
    Set Suite Variable    ${nrbtsID}
    Common_setup_and_teardown.Suite Common SetUp    is_commission=${False}
    Initial PA Value Setting For All Attenuators
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Case_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=0
    ...            ${is_commission}=${True}
    ...            ${timeout_for_commission}=900
    ...            ${wait_gnb_up_timeout}=20 min
    ...            ${is_pdl_checking_needed}=${True}
    ...            ${gnb_index}=0
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    ${basic_scf_path_for_ute}    Get Basic SCF File Path
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    Log To Console    ue index is ${ue_index}, ue type is ${ue_type}
    Create Case Log Path
    ${stream_version}    Get Active SW Version Based On Stream Version
    Set Suite Variable    ${STREAM_VERSION}    ${stream_version}
    Upload Swconfig File
    Run Keyword If    ${is_commission}    Perform Commission    scf_file_path=${basic_scf_path_for_ute}
    ...                                                         gnb_index=${gnb_index}
    ...                                                         timeout_for_commission=${timeout_for_commission}
    ...                                                         wait_gnb_up_timeout=${wait_gnb_up_timeout}
    ...                                                         is_pdl_checking_needed=${is_pdl_checking_needed}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    Initial PA Value Setting For Whole PA    value=${15}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Case_Teardown
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Initial PA Value Setting For All Attenuators
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${0}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}

Check And Power on RUs
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    ${ru_numbers}    get length    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus}
    log to console    ru_numbers: ${ru_numbers}
    FOR    ${index}    IN RANGE    0    ${ru_numbers}
        ${model}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.__class__.__name__}
        ${address}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.pdu.addr}
        ${port}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${index}].pdu_port.port_no}
        ${ru_index}    evaluate    ${index}+1
        log to console    for ru ${ru_index}, model is ${model}, pb ip is ${address}, pb port is ${port}
        pdu.Setup Pdu    model=${model}   host=${address}    alias=pdu_ru_${ru_index}
        ${port_status}    pdu.Get Port Status    port=${port}    pdu_device=pdu_ru_${ru_index}
        log to console    port status of ru ${ru_index} is ${port_status}
        run keyword if    '${port_status}'=='off'    pdu.power on    port=${port}    pdu_device=pdu_ru_${ru_index}
        sleep    5s
    END

Upload Swconfig File
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${swconfig_path}=${CURDIR}/swconfig.txt    ${connection}=GNB_OAM
    ...            ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=swconfig
    Log    ${connection}
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ssh.Force Reconnect    connection=${alias}
    Log To Console    Start update Swconfig file.
    swconf.Upload swConfig file to asik and crasign    localFilePath=${swconfig_path}    asik_alias=${alias}
    csn.disconnect    connection=${alias}

Get Basic SCF File Path
    [Documentation]   Author: jun.8.chen@nokia-sbell.com
    ${SCF_Path}    ${result}    Split String From Right    ${CURDIR}    testsuite     1
    ${ute_env}    Run Keyword And Return Status    Run Keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${tmp_testline}   Run Keyword If    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    Set Variable     ${testline_name}
    ${stream}    ${build}     Run Keyword If    ${ute_env}    CI_commssion._Get Stream From Variable    ${ENB_BUILD}
    ...    ELSE   CI_commssion._Get Stream From Variable    ${AF_PATH}
    ${basic_scf_path}    Set Variable    ${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}.xml
    [Return]    ${basic_scf_path}

Make MTK Attach
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cellid}=3     ${is_do_require_ue}=${True}
    Change cellBarred Parameter Value On Gnb    pcell_index=${cellid}    exp_status=notBarred
    Run Keyword If    ${is_do_require_ue}    Procedures.UE Prepare    ue_type=${ue_type}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
    ${attach_info}    Procedures.UE Attach    wireshark_log_prefix=attach
    ...                                       ue_type=${ue_type}
    ...                                       sleep_interval=15 sec
    ...                                       4G_check=${False}

MTK L3 Call And Verify Throughput
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ul_data_transfer}=200M    ${dl_data_transfer}=1500M
    ...            ${expect_ul_tput}=160    ${expect_dl_tput}=1400
    ...            ${cellid}=3    ${duration}=180
    ...            ${target_avg_percent}=0.8    ${min_percent}=0.3
    ...            ${is_do_require_ue}=${True}
    Change cellBarred Parameter Value On Gnb    pcell_index=${cellid}    exp_status=notBarred
    Run Keyword If    ${is_do_require_ue}    Procedures.UE Prepare    ue_type=${ue_type}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
    ${attach_info}    Procedures.UE Attach    wireshark_log_prefix=attach
    ...                                       ue_type=${ue_type}
    ...                                       sleep_interval=15 sec
    ...                                       4G_check=${False}
    Start L3 Call Data Transfer    ul_data_transfer=${ul_data_transfer}
    ...                            dl_data_transfer=${dl_data_transfer}
    ...                            duration=1200
    ...                            need_get_ue_ip=${True}
    ...                            cpif_log_path=${attach_info['cpif_log_path']}
    ...                            ue_iperf_path=/data/local/tmp/iperf
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=${duration}
    ...                                                                expect_ul_tput=${expect_ul_tput}
    ...                                                                expect_dl_tput=${expect_dl_tput}
    ...                                                                cellid=${cellid}
    ...                                                                target_avg_percent=${target_avg_percent}
    ...                                                                ue_type=${ue_type}
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=${min_percent}

Online Cell addition deletion For 9843
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]  ${addition_deletion_cell}=1    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
#    ${cell_grp}    Create List    0    4    5
#    ${cell_grp_mapping}    Create Dictionary    401=0    501=4    601=5
#    ${addition_deletion_cellgrp}    Set Variable    ${cell_grp_mapping['${addition_deletion_cell}']}
    ${addition_deletion_cellgrp}    Get Cell Group From Cell    cell_id=${addition_deletion_cell}    connection=${connection}
    ${cell_grp}  Get All Cell Group Id    connection=${connection}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    ${lcrid}    Get lcrId via webem    cell_id=${addition_deletion_cell}
    log to console  delete object
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}    timeout=15
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
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
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
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${cell_grp[${index}]}
        ...    node_index=${index}
    END
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}
    Wait Until Keyword Succeeds    5min   15s    verify all cells should be onair
    [Teardown]  selenium logout and close browser

General_SiSo_Cell_lock_and_unlock For 9843
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    ${cellgrp_id_list}    Create List    0    4    5
    ${cell_grp_mapping}    Create Dictionary    401=0    501=4    601=5
    Set Test Variable    ${cell_grp_mapping}
    ${401_list}    Create List    401
    ${501_list}    Create List    501
    ${601_list}    Create List    601
    ${grp_cell_mapping}    Create Dictionary    0=${401_list}    4=${501_list}    5=${601_list}
    Set Test Variable    ${grp_cell_mapping}
    Lock and Unlock Cells or Groups and L3 For 9843  lock_list=${cell_id_list}  is_group=${False}
    Connect to gnb coam via ssl
    ${cellgrp_num}    get length  ${cellgrp_id_list}
    Lock and Unlock Cells or Groups and L3 For 9843  lock_list=${cellgrp_id_list}  is_group=${True}
    run keyword if  ${cell_num}>1  Lock and Unlock all Cells or Groups For 9843    lock_list=${cell_id_list}    is_group=${False}
    run keyword if  ${cellgrp_num}>1  Lock and Unlock all Cells or Groups For 9843    lock_list=${cellgrp_id_list}    is_group=${True}

Lock and Unlock Cells or Groups and L3 For 9843
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${lock_list}    ${is_group}=${True}
    ${lock_num}    get length  ${lock_list}
    FOR  ${lock_id}  IN  @{lock_list}
        ${check_alarm}  set variable if  ${lock_num}==1  ${True}  ${False}
        ${other_cells}  Get Other Ids    id_list=${lock_list}    given_id=${lock_id}
        ${check_cell}  create list  ${lock_id}
        ${operate_list}    set variable if  ${lock_num}==1  ${check_cell}  ${other_cells}
#        ${cell_list}    run keyword if  ${is_group}    Get Cell From Cell Group  cellgrp_id=${lock_id}
#        ...    ELSE   set variable  ${check_cell}
        Lock cells or groups and check status For 9843  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        Unlock cells or groups and check status For 9843  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
    END

Lock cells or groups and check status For 9843
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${lock_list}  ${is_group}=${True}  ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
    ${output}   set variable if      ${is_group}==${False}    NRCELL-    NRCELLGRP-
    connect to gnb coam via ssl    connection=${connection}
    FOR    ${idx}  IN  @{lock_list}
        log to console  \n***Lock ${output}${idx} and check status***
        run keyword if    ${is_group}==${True}
        ...    perform_cell_group_lock_via_admin   cellgrp_id=${idx}    connection=${connection}    lock_timeout=120
        ...    ELSE
        ...    perform_cell_lock_via_admin    cell_id=${idx}    connection=${connection}    lock_timeout=120
        run keyword if    ${is_group}==${True}
        ...    Wait Until Keyword Succeeds   5 min  5 sec    Check cells under group should be locked For 9843    cell_group_idx=${idx}
        ...    connection=${connection}
        ...    ELSE
        ...    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked For 9843    cell_id=${idx}
    END
    ${sleep_time}       Evaluate    ${X2_link_shutdown_time}-1
    run keyword if  ${check_alarm}==${True} and ${gNB_type}=='NSA'
    ...    run keywords  sleep    ${sleep_time}min   AND
    ...    Expect Fault Should Absent    faultId=7300   AND
    ...    Expect Fault Should Absent    faultId=7319   AND
    ...    Wait For Expect Fault Present  faultId=7300   timeout=180   AND
    ...    Wait For Expect Fault Present  faultId=7319   timeout=180

Unlock cells or groups and check status For 9843
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${lock_list}  ${is_group}=${True}  ${check_alarm}=${True}    ${gnb_type}='NSA'    ${connection}=GNB_OAM
    ${output}   set variable if      ${is_group}==${False}    NRCELL-    NRCELLGRP-
    ${status}    run keyword and return status    variable should not exist    ${check_ru_details}
    ${check_ru_details}    run keyword if    ${status}    create dictionary
    ...    ELSE    set variable    ${check_ru_details}
    set test variable    ${check_ru_details}
    connect to gnb coam via ssl    connection=${connection}
    FOR    ${idx}  IN  @{lock_list}
        log to console  \n***unLock ${output}${idx} and check status***
        ${cell_list}    run keyword if    ${is_group}==${True}    Set Variable    ${grp_cell_mapping['${idx}']}
        ${cell_id}    set variable if    ${is_group}==${True}    ${cell_list[0]}    ${idx}
        ${ru_index}    get ru index from cell id via admin    cell_id=${cell_id}
        ${status}    run keyword and return status    RU Status Info Should Be as Expect    ru_index=${ru_index}    powerState=SLEEP
        ${ru_detail}    create dictionary    allowed_reset=${status}
        set to dictionary    ${check_ru_details}    ${ru_index}=${ru_detail}
        run keyword if    ${is_group}==${True}
        ...    perform_cell_group_unlock_via_admin  cellgrp_id=${idx}    connection=${connection}    lock_timeout=120
        ...    ELSE
        ...    perform_cell_unlock_via_admin    cell_id=${idx}    connection=${connection}    lock_timeout=120
        sleep  30
        Run Keyword If  ${check_ru_details['${ru_index}']['allowed_reset']}
        ...    Wait until keyword succeeds    10min    10sec    RU Should Be Online    ru_index=${ru_index}    connection=${connection}
        run keyword if    ${is_group}==${True}
        ...    Wait Until Keyword Succeeds   5 min  5 sec    Check cells under group should be unlocked For 9843   cell_group_idx=${idx}
        ...    connection=${connection}
        ...    ELSE
        ...    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked For 9843   cell_id=${idx}    connection=${connection}
    END
    run keyword if  ${check_alarm}==${True} and ${gNB_type}=='NSA'
    ...    run keywords  Wait For Expect Fault To Disappear  faultId=7300   timeout=600   AND
    ...    Wait For Expect Fault To Disappear  faultId=7319   timeout=300
    Wait Until Keyword Succeeds    10min    30s    Verify all cells should be onair

Check cell should be locked For 9843
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]  ${cell_id}   ${connection}=GNB_OAM
    Cell Should Be Locked Tmp   cell_idx=${cell_id}    connection=${connection}

Check cell should be unlocked For 9843
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]  ${cell_id}   ${connection}=GNB_OAM
    Cell Should Be Unlocked Tmp   cell_idx=${cell_id}    connection=${connection}

Check cells under group should be locked For 9843
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]   ${cell_group_idx}=${0}   ${connection}=GNB_OAM
    ${cell_list}    Set Variable    ${grp_cell_mapping['${cell_group_idx}']}
    FOR    ${cell_id}    IN    @{cell_list}
            Cell Should Be Locked Tmp    cell_idx=${cell_id}    connection=${connection}
    END

Check cells under group should be unlocked For 9843
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]   ${cell_group_idx}=${0}   ${connection}=GNB_OAM
    ${cell_list}    Set Variable    ${grp_cell_mapping['${cell_group_idx}']}
    FOR    ${cell_id}    IN    @{cell_list}
            Cell Should Be Unlocked Tmp    cell_idx=${cell_id}    connection=${connection}
    END

Cell Should Be Locked Tmp
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${cell_idx}=${1}   ${connection}=GNB_OAM
    ${subcell_status}=  Get Cell Status For 9843    cell_idx=${cell_idx}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${offline}    Set Variable If    ${result}    Offline    off line
    ${locked}    Set Variable If    ${result}    Locked    Locked
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   ${disabled}
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  ${offline}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  ${locked}

Cell Should Be Unlocked Tmp
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${cell_idx}=${1}    ${connection}=GNB_OAM
    ${subcell_status}=  Get Cell Status For 9843    cell_idx=${cell_idx}
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    Should Be Equal As Strings  ${subcell_status["operationalState"]}    ${enabled}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}    ${unlocked}
    run keyword if    ${result}    Should be equal as strings    ${subcell_status["availabilityStatus"]}    Online

Get Cell Status For 9843
    [Arguments]    ${cell_idx}=${1}    ${technology}=NR
    Selenium Login And Disable Screen Lock
    ${cell_info}    selenium_coam.get_cell_info    cell_idx=${cell_idx}    technology=${technology}
    ${status_dict}   Catenate
    ...                         'operationalState':
    ...                         '${cell_info["Status"]["Operational state"]}',
    ...                         'administrativeState':
    ...                         '${cell_info["Status"]["Administrative state"]}',
    ...                         'blockingState':
    ...                         '${cell_info["Status"]["Blocking state"]}',
    ...                         'availabilityStatus':
    ...                         '${cell_info["Status"]["Availability status"]}',
    ${subcell_status}    Evaluate   {${status_dict}}
    [Return]   ${subcell_status}
    [Teardown]    Selenium Logout And Close Browser

Lock and Unlock all Cells or Groups For 9843
    [Documentation]  Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${lock_list}  ${is_group}=${True}
    ${output}   set variable if      ${is_group}==${False}   all cells    all cell groups
    log to console  \n***Lock ${output} and check status***
    Lock cells or groups and check status For 9843  lock_list=${lock_list}  is_group=${is_group}  check_alarm=${True}  gnb_type='${gNb_CuType}'
    log to console  \n***unLock ${output} and check status***
    Unlock cells or groups and check status For 9843  lock_list=${lock_list}  is_group=${is_group}  check_alarm=${True}  gnb_type='${gNb_CuType}'