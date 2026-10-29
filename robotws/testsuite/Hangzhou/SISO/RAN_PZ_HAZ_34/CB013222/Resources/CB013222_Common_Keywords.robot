*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Variables    ../TestData/CB013222_variables.py

Documentation    This is for SG8 common keywords
...              Author: linjiangjing
...              Squard: HZ SG8

*** Variables ***
#${ue_type_4G}    samsung_lte
${ue_type_4G}    mtk_lte
${lte_tput_dl}    200
${lte_tput_ul}    60
${lte_target_tput_dl}    122.07
${lte_target_tput_ul}    12
${ue_index_lte}    ${1}
${ui_version_M40P}    M40PUI1.1
@{lte_cell_0}    ${0}


*** Keywords ***
Commissioning SCF And Check alarm
#    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _${scf_name}.xml
    log to console    start SCF commission
    COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}    timeout=${600}
    Wait until keyword succeeds    15min    180s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}


General_SiSo_Auto_Startup_BTS_power_reset_with_L3call_CB013222
    Perform BTS power off and power on
    log to console    begin to make L3 call
    data_transfer_for_defined_nr_and_lte_cell    cell_id_nr=${0}    cell_id_lte=${0}    tput_define_nr=${tput_AVNB_NR}
    ...    target_avg_percent_nr=0.98    min_percent_nr=0.8    target_avg_percent_lte=0.7    duration=${600}
    ...    ui_version=${ui_version_M40P}


Perform BTS power off and power on
    log to console    begin power off BTS
    Perform Site Power Off
    sleep    2min
    log to console    begin power on BTS
    Perform Site Power On
    sleep    5min
    log to console    check cell status and alarms
    wait until keyword succeeds    10min    120s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}


SiSo_RFS_Cell_block_and_unblock_with_L3call_CB013222
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Set Test Variable    ${cell_type}
    Set Test Variable    ${cell_list_nr}
    Set Test Variable    ${cell_list_lte}
    ${lnbtsID}    run keyword if    '${cell_type}' != 'nr_only'    Get lnbts ID via online SCF
    log to console    begin to block/unblock cell and check status
    run keyword if    '${cell_type}' != 'lte_only'    Block nr cells and check cell status
    run keyword if    '${cell_type}' != 'nr_only'    Block LTE cells and check cell status
    run keyword if    '${cell_type}' != 'lte_only'    Unblock nr cells and check cell status
    run keyword if    '${cell_type}' != 'nr_only'    Unblock LTE cells and check cell status
    add fault to the allowed history fault list    faultId=${49}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    log to console    begin to make L3 call
    data_transfer_for_defined_nr_and_lte_cell    cell_id_nr=${0}    cell_id_lte=${0}    tput_define_nr=${tput_AVNB_NR}
    ...    target_avg_percent_nr=0.98    min_percent_nr=0.8    target_avg_percent_lte=0.7    duration=${600}
    ...    ui_version=${ui_version_M40P}


add fault to the allowed history fault list
    [Arguments]    ${faultId}=${49}
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${fault_dic}    Create Dictionary    faultId=${faultId}
    Append To List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${fault_dic}
    Set test Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}


General_SiSo_RAT_Reset_CB013222
    [Arguments]    ${connection}=GNB_OAM
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    log to console    begin rat reset and check cell status
    Run Keyword If    '${cell_type}' == 'lte_only' or '${cell_type}' == 'nr_lte'
    ...    coam.rat_reset       rat_type=LTE     timeout=300    connection=${connection}
    sleep    5
    Wait Until Keyword Succeeds    5min    60s    Check all cells info should be onair
    Run Keyword If    '${cell_type}' == 'nr_only' or '${cell_type}' == 'nr_lte'
    ...    coam.rat_reset       rat_type=NR     timeout=300    connection=${connection}
    sleep    5
    Wait Until Keyword Succeeds    5min    60s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    log to console    begin to make L3 call
    data_transfer_for_defined_nr_and_lte_cell    cell_id_nr=${0}    cell_id_lte=${0}    tput_define_nr=${tput_AVNB_NR}
    ...    target_avg_percent_nr=0.98    min_percent_nr=0.8    target_avg_percent_lte=0.7    duration=${600}
    ...    ui_version=${ui_version_M40P}


General_SiSo_RU_module_reset_from_GUI_CB013222
    log to console    begin to reset radio
    Reset all RMOD via coam
    sleep    10
    Wait Until Keyword Succeeds    10min    60s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    log to console    begin to make L3 call
    data_transfer_for_defined_nr_and_lte_cell    cell_id_nr=${0}    cell_id_lte=${0}    tput_define_nr=${tput_AVNB_NR}
    ...    target_avg_percent_nr=0.98    min_percent_nr=0.8    target_avg_percent_lte=0.7    duration=${600}
    ...    ui_version=${ui_version_M40P}


Data_transfer_for_LTE_MTK
    MTK_Lte_Call


MTK_Lte_Call
    [Arguments]   ${lte_pci}=${1}    ${traffic_stop}=${true}   ${duration}=90    ${ue_index}=${1}
    power_ue.Prepare UE    ue_type=${ue_type_4G}   ue_index=${ue_index}
#    Run Keyword And Ignore Error   power_ue.UE Detach   ue_type=${ue_type_4G}   ue_index=${ue_index}
#    ${lte_pci}   selenium_coam.get_parameter_value   dist_name=MRBTS-${BTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-${ltecall_cell_index}
#    ...   filter_param=Physical layer cell identity
    power_ue.UE Attach   ue_type=${ue_type_4G}   ue_index=${ue_index}    pci=${lte_pci}
    log to console    start DL traffic
    power_ue.Start traffic   ue_type=${ue_type_4G}   direction=dl   throughput=${lte_tput_dl}   duration=${duration}    ue_index=${ue_index}
    log to console    start UL traffic
    power_ue.Start traffic   ue_type=${ue_type_4G}   direction=ul   throughput=${lte_tput_ul}   duration=${duration}   ue_index=${ue_index}
    power_ue.Collect Tput    ue_type=${ue_type_4G}   ue_index=${ue_index}   duration=${duration}   ignore_time=30    check_source=Iperf
    ${dl_status}    power_ue.Check Tput    ue_type=${ue_type_4G}    ue_index=${ue_index}
    ...    direction=dl    target_throughput=${lte_target_tput_dl}   target_avg_percent=0.3
    should be true    ${dl_status}
    ${ul_status}    power_ue.Check Tput    ue_type=${ue_type_4G}    ue_index=${ue_index}
    ...    direction=ul    target_throughput=${lte_target_tput_ul}   target_avg_percent=0.3
    should be true    ${ul_status}
    [Teardown]   MTK_Lte_Call_Teardown   traffic_stop=${traffic_stop}


MTK_Lte_Call_Teardown
    [Arguments]   ${traffic_stop}=${true}    ${ue_index}=${0}
    run keyword and ignore error   run keyword if   ${traffic_stop}   power_ue.UE Detach   ue_type=${ue_type_4G}   ue_index=${ue_index}
    run keyword and ignore error   run keyword if   ${traffic_stop}
    ...   power_ue.Stop traffic   ue_type=${ue_type_4G}   direction=dl   ue_index=${ue_index}
    run keyword and ignore error   run keyword if   ${traffic_stop}
    ...   power_ue.Stop traffic   ue_type=${ue_type_4G}   direction=ul   ue_index=${ue_index}


Set qRxLevMin For pointed LTE cell
    [Arguments]    ${cell_id_list}    ${mrbtsId}=${1133}    ${lnBtsId}=${51133}    ${connection}=GNB_OAM
    ...    ${value_call}=${-140}
    log to console    start to set LTE cell qrxlevmin
    FOR  ${cell_id_call}  IN  @{cell_id_list}
        wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/LNBTS-${lnBtsId}/LNCEL-${cell_id_call}/SIB-0    parameter=qrxlevmin
        ...    value=${value_call}    operation=update    connection=${connection}
        sleep    10s
    END


make_call_for_MTK_Lte
    [Arguments]   ${duration}    ${ue_type_4G}    ${lte_tput_dl}    ${lte_tput_ul}    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type_4G}   ue_index=${ue_index}
    power_ue.UE Attach   ue_type=${ue_type_4G}   ue_index=${ue_index}    timeout=300
    log to console    start DL traffic
    power_ue.Start traffic   ue_type=${ue_type_4G}   direction=dl   throughput=${lte_tput_dl}   duration=${duration}    ue_index=${ue_index}
    log to console    start UL traffic
    power_ue.Start traffic   ue_type=${ue_type_4G}   direction=ul   throughput=${lte_tput_ul}   duration=${duration}    ue_index=${ue_index}


Check MTK_Lte_Call
    [Arguments]   ${ue_type_4G}    ${target_avg_percent}    ${lte_target_tput_dl}    ${lte_target_tput_ul}
    ...    ${omit_time}    ${ue_index}=${0}
    ${omit_time}    convert to integer    ${omit_time}
    Set Test Variable    ${omit_time}
    ${dl_status}    Run keyword and return status    power_ue.Check Tput    ue_type=${ue_type_4G}    ue_index=${ue_index}
    ...    direction=dl    target_throughput=${lte_target_tput_dl}    target_avg_percent=${target_avg_percent}
    ...    omit_time=${omit_time}
    Run Keyword If    ${dl_status} == False    log to console    check DL tput failed    ELSE
    ...    log to console    check DL tput success
    ${ul_status}    Run keyword and return status    power_ue.Check Tput    ue_type=${ue_type_4G}    ue_index=${ue_index}
    ...    direction=ul    target_throughput=${lte_target_tput_ul}    target_avg_percent=${target_avg_percent}
    ...    omit_time=${omit_time}
    Run Keyword If    ${ul_status} == False    log to console    check UL tput failed    ELSE
    ...    log to console    check UL tput success
    should be true    ${dl_status}
    should be true    ${ul_status}


data_transfer_for_defined_nr_and_lte_cell
    [Arguments]    ${cell_id_nr}=${1}    ${cell_id_lte}=${1}    ${tput_define_nr}=${None}
    ...    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}
    ...    ${duration}=${600}    ${tput_from}=tool    ${omit_time_lte}=30    ${process_num_ul}=1    ${ui_version}=default
    ...    ${connection}=GNB_OAM    ${scf_name}=default
    ${tput_define_nr}    get_self_define_tput_by_release    tput_info=${tput_define_nr}
    ${target_avg_percent_nr}    Run Keyword If    ${target_avg_percent_nr}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent_nr}
    ${min_percent_nr}    Run keyword If    ${min_percent_nr}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent_nr}
    ${target_avg_percent_lte}    Run Keyword If    ${target_avg_percent_lte}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent_lte}
    log to console    make call for nr cell ${cell_id_nr}
    ${ue_index_nr}    set variable    ${tput_define_nr[${cell_id_nr}]['ue_index']}
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id_nr}    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}    scf_name=${scf_name}
    ...    duration=${duration}    ue_index=${ue_index_nr}    connection=${connection}    ELSE    set variable    ${tput_define_nr[${cell_id_nr}]}
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_0}    value_call=${-44}
    make_call    tput_info=${tput_cell}    ue_index=${ue_index_nr}    process_num_ul=${process_num_ul}    ui_version=${ui_version}
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_0}    value_call=${-140}
    log to console    make call for lte cell ${cell_id_lte}
#    ${ue_type_4G}     translate_power_ue_type_from_testline    ue_index=${ue_index_lte}
    make_call_for_MTK_Lte    ue_type_4G=${ue_type_4G}    lte_tput_dl=${lte_tput_dl}    lte_tput_ul=${lte_tput_ul}    ue_index=${ue_index_lte}
    ...    duration=${duration}
    log to console    collect tput for nr cell ${cell_id_nr}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    stop traffic and_detach for lte call
    MTK_Lte_Call_Teardown    ue_index=${ue_index_lte}
    log to console    check tput for lte cell
    run keyword and continue on failure    Check MTK_Lte_Call    ue_type_4G=${ue_type_4G}    lte_target_tput_dl=${lte_target_tput_dl}
    ...    lte_target_tput_ul=${lte_target_tput_ul}    ue_index=${ue_index_lte}    omit_time=${omit_time_lte}
    ...    target_avg_percent=${target_avg_percent_lte}
    log to console    check tput for nr cell ${cell_id_nr}
    ${tput_define_nr_new}    create dictionary
    set to dictionary    ${tput_define_nr_new}    ${cell_id_nr}    ${tput_cell}
    check_tput_for_each_cell    tput_info=${tput_define_nr_new}    cell_id=${cell_id_nr}    ue_index=${ue_index_nr}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}
    [Teardown]    run keywords    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}    AND
    ...    run keyword and ignore error    MTK_Lte_Call_Teardown    ue_index=${ue_index_lte}

