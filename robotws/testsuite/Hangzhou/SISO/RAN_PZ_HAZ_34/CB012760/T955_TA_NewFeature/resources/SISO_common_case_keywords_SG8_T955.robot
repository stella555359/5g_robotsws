*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot

*** Variables ***
@{cell_id_all}    ${1}    ${2}
@{cell_id_call}    ${1}
${ui_version}    M40PUI1.1
${ue_type_4G}    mtk_lte
${lte_tput_dl}    200
${lte_tput_ul}    60
${lte_target_tput_dl}    120
${lte_target_tput_ul}    12
${ue_index_lte}    ${2}
@{lte_cell_0}    ${0}


*** Keywords ***
RU returning from PowerSaving Mode to normal operation due to change of EnergySavingMode
    [Arguments]    ${ru_index}=1
    AlarmWatchdog.add_allow_alarms    fault_id=49
    log to console    **************************step1_commission************************************************
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _CB012760.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    15min    180s    Check all cells info should be onair
    log to console    block all nr cells
    Block all nr cell  block_list=${cell_id_all}
    log to console    set energySavingMode to DEEPSLEEP
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
    ...    value=DEEPSLEEP
    log to console    check all nr cells blocked
    FOR    ${cell_idx}    IN    @{cell_id_all}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=disabled    usageState=idle    blockState=blocked
    END
    log to console    check RU Power state is SLEEP
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP
    log to console    **************************step2******************************************************
    log to console    Change energySavingMode to DEEPSLEEP_EXTREME_SFP
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
    ...    value=DEEPSLEEP_EXTREME_SFP
    log to console    check RU Power state=SLEEP_EXTREME
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    sleep    10min
    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    log to console    **************************step3******************************************************
    log to console    Change energySavingMode to NORMAL
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
    ...    value=NORMAL
    log to console    check RU power state is AWAKE
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    unblock all nr cells
    UnBlock all nr cell  block_list=${cell_id_all}
    log to console    check all nr cells unblocked
    FOR    ${cell_idx}    IN    @{cell_id_all}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=enabled    usageState=active    blockState=unblocked
    END
    log to console    check RU power state is AWAKE
    Wait Until Keyword Succeeds    5min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    log to console    **************************step4******************************************************
    log to console    make call for nr cell1 and check tput
    data_transfer_common    tput_self_define=${tput_define_CB012760}    cell_id=${cell_id_call}    target_avg_percent=${0.98}
    ...    min_percent=${0.85}    loop_times=${1}    duration=${300}      ui_version=${ui_version}
    AlarmWatchdog.remove_allow_alarms    fault_id=49

From PowerSaving Mode to normal operation due to change of EnergySavingMode
    [Arguments]    ${ru_index}=1
    AlarmWatchdog.add_allow_alarms    fault_id=49
    log to console    **************************step1_commission************************************************
    log to console    block all nr cells
    Block all nr cell  block_list=${cell_id_all}
    log to console    set energySavingMode to DEEPSLEEP
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
    ...    value=DEEPSLEEP
    log to console    check all nr cells blocked
    FOR    ${cell_idx}    IN    @{cell_id_all}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=disabled    usageState=idle    blockState=blocked
    END
    log to console    check RU Power state is SLEEP
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP
    sleep    2min
    log to console    **************************step2******************************************************
    log to console    Change energySavingMode to DEEPSLEEP_EXTREME_SFP
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
    ...    value=DEEPSLEEP_EXTREME_SFP
    log to console    check RU Power state=SLEEP_EXTREME
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    sleep    10min
    SG8 Check RU Power State by ru index    expect_state=SLEEP_EXTREME
    log to console    **************************step3******************************************************
    log to console    Change energySavingMode to NORMAL
    SG8 modify the parameter    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    parameter_name=energySavingMode
    ...    value=NORMAL
    log to console    check RU power state is AWAKE
    Wait Until Keyword Succeeds    10min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    unblock all nr cells
    UnBlock all nr cell  block_list=${cell_id_all}
    log to console    check all nr cells unblocked
    FOR    ${cell_idx}    IN    @{cell_id_all}
        Wait Until Keyword Succeeds    10min    5s    Check single NR cell status    cell_idx=${cell_idx}
        ...    operationalState=enabled    usageState=active    blockState=unblocked
    END
    log to console    check RU power state is AWAKE
    Wait Until Keyword Succeeds    5min    5s    SG8 Check RU Power State by ru index    expect_state=AWAKE
    AlarmWatchdog.remove_allow_alarms    fault_id=49

data_transfer_for_defined_nr_and_lte_cell
    [Arguments]    ${cell_id_nr}=${3}    ${cell_id_lte}=${1}    ${tput_define_nr}=${None}
    ...    ${target_avg_percent_nr}=${None}    ${min_percent_nr}=${None}    ${target_avg_percent_lte}=${None}
    ...    ${duration}=${300}    ${tput_from}=tool    ${omit_time}=${10}    ${process_num_ul}=1    ${ui_version}=default
    ...    ${connection}=GNB_OAM    ${scf_name}=default
    Connect to gnb coam via ssl    connection=GNB_OAM
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
    log to console    stop NR traffic
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    stop traffic and_detach for lte call
    MTK_Lte_Call_Teardown    ue_index=${ue_index_lte}
    log to console    check tput for lte cell
    run keyword and continue on failure    Check MTK_Lte_Call    ue_type_4G=${ue_type_4G}    lte_target_tput_dl=${lte_target_tput_dl}
    ...    lte_target_tput_ul=${lte_target_tput_ul}    ue_index=${ue_index_lte}    omit_time=${omit_time}
    ...    target_avg_percent=${target_avg_percent_lte}
    log to console    check tput for nr cell ${cell_id_nr}
    ${tput_define_nr_new}    create dictionary
    set to dictionary    ${tput_define_nr_new}    ${cell_id_nr}    ${tput_cell}
    check_tput_for_each_cell    tput_info=${tput_define_nr_new}    cell_id=${cell_id_nr}    ue_index=${ue_index_nr}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_nr}    min_percent=${min_percent_nr}
    [Teardown]    run keywords    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}    AND
    ...    run keyword and ignore error    MTK_Lte_Call_Teardown    ue_index=${ue_index_lte}

data_transfer_for_lte_cell
    [Arguments]    ${cell_id_lte}=${1}
    ...    ${target_avg_percent_lte}=${None}        ${duration}=${300}       ${omit_time}=${30}
#    Connect to gnb coam via ssl    connection=GNB_OAM
    ${target_avg_percent_lte}    Run Keyword If    ${target_avg_percent_lte}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent_lte}
#    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_0}    value_call=${-44}
    log to console    make call for lte cell ${cell_id_lte}
#    ${ue_type_4G}     translate_power_ue_type_from_testline    ue_index=${ue_index_lte}
    make_call_for_MTK_Lte    ue_type_4G=${ue_type_4G}    lte_tput_dl=${lte_tput_dl}    lte_tput_ul=${lte_tput_ul}    ue_index=${ue_index_lte}
    ...    duration=${duration}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    stop traffic and_detach for lte call
    MTK_Lte_Call_Teardown    ue_index=${ue_index_lte}
    log to console    check tput for lte cell
    run keyword and continue on failure    Check MTK_Lte_Call    ue_type_4G=${ue_type_4G}    lte_target_tput_dl=${lte_target_tput_dl}
    ...    lte_target_tput_ul=${lte_target_tput_ul}    ue_index=${ue_index_lte}    omit_time=${omit_time}
    ...    target_avg_percent=${target_avg_percent_lte}
    [Teardown]    run keyword and ignore error    MTK_Lte_Call_Teardown    ue_index=${ue_index_lte}

MTK_lte_data_transfer
    [Arguments]      ${ue_type_4G}    ${lte_tput_dl}    ${lte_tput_ul}    ${target_avg_percent}    ${lte_target_tput_dl}
    ...    ${lte_target_tput_ul}     ${duration}=${300}    ${omit_time}=${30}    ${ue_index}=${0}
    log to console    start to have LTE L3 call
    Connect to gnb coam via ssl    connection=GNB_OAM
    make_call_for_MTK_Lte    duration=${duration}    ue_type_4G=${ue_type_4G}    lte_tput_dl=${lte_tput_dl}
    ...    lte_tput_ul=${lte_tput_ul}    ue_index=${ue_index}
    log to console    collect lte tput
    sleep    ${omit_time}
    sleep    ${duration}
    MTK_Lte_Call_Teardown    ue_index=${ue_index}
    Check MTK_Lte_Call    ue_type_4G=${ue_type_4G}    target_avg_percent=${target_avg_percent}
    ...    lte_target_tput_dl=${lte_target_tput_dl}    lte_target_tput_ul=${lte_target_tput_ul}
    ...    omit_time=${omit_time}    ue_index=${ue_index}
    [Teardown]    run keyword and ignore error    MTK_Lte_Call_Teardown    ue_index=${ue_index}

MTK_Lte_Call_Teardown
    [Arguments]   ${traffic_stop}=${true}    ${ue_index}=${0}
    run keyword and ignore error   run keyword if   ${traffic_stop}   power_ue.UE Detach   ue_type=${ue_type_4G}   ue_index=${ue_index}
    run keyword and ignore error   run keyword if   ${traffic_stop}
    ...   power_ue.Stop traffic   ue_type=${ue_type_4G}   direction=dl   ue_index=${ue_index}
    run keyword and ignore error   run keyword if   ${traffic_stop}
    ...   power_ue.Stop traffic   ue_type=${ue_type_4G}   direction=ul   ue_index=${ue_index}

Set qRxLevMin For pointed LTE cell
    [Arguments]    ${cell_id_list}    ${mrbtsId}=${955}    ${lnBtsId}=${5955}    ${connection}=GNB_OAM
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