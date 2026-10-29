*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Variables    ../TestData/6876_variables.py

Documentation
...    author: Jiangjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MAX_LOOP}    20
${throughput_dl}    300
${throughput_ul}    50
${target_throughput_dl}    145
${target_throughput_ul}    70
${target_avg_percent_LTE}    0.8

*** Keywords ***
General_SiSo_E2E_system_setup_with_data_transfer_conducted_by_config
    [Arguments]    ${tput_self_define}    ${config_id}    ${cell_id_NR}    ${duration}=${600}    ${tput_from}=self_define
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id_NR}    duration=${duration}    tput_from=${tput_from}
    [Teardown]   run keyword and ignore error     Selenium Logout And Close Browser

General_SiSo_Cell_lock_and_unlock_by_config
    [Arguments]    ${tput_self_define}    ${config_id}    ${cell_id_NR}    ${cell_id_LTE}    ${duration}=${30}    ${ue_index}=0
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Get X2 link shutdown waiting time
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error     Selenium Logout And Close Browser
    log to console    make call with NR cell1
    ${tput_info}    set variable    ${tput_self_define[${cell_id_NR}[0]]}
    make_call    tput_info=${tput_info}    ue_index=${ue_index}
    log to console    block lte cell 401, check NR call not dropped
    run keyword and ignore error     Selenium Logout And Close Browser
    Block LTE cells and check status   block_list=${cell_id_LTE}
     run keyword and ignore error     Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${cell_id_NR}[0]    ue_index=${0}    tput_log=${tput_log}
    log to console    unblock lte cell, check NR call not dropped
    run keyword and ignore error     Selenium Logout And Close Browser
    UnBlock LTE Cells and check status   block_list=${cell_id_LTE}
     run keyword and ignore error     Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${cell_id_NR}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
#    log to console    make call with lte cell
#    make_call_4G    ue_type_4G=mtk_lte    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800    ue_index=${1}
#    log to console    block NR cell
#    Block cells and check status    block_list=${cell_id_NR}    check_alarm=${False}    gnb_type=${gNb_CuType}
#    log to console    unblock NR cell, check lte call not dropped
#    UnBlock cells and check status    block_list=${cell_id_NR}    check_alarm=${False}    gnb_type=${gNb_CuType}
#    check_tput_for_4G_call    ue_type_4G=mtk_lte    target_throughput_dl=${target_throughput_dl}    target_throughput_ul=${target_throughput_ul}
#    ...    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
#    run keyword and ignore error    detach_for_4G_call    ue_type_4G=mtk_lte    ue_index=${ue_index}
#    log to console    make call with NR cell, check tput
#    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id_NR}    duration=${duration}    tput_from=${tput_from}
    [Teardown]   run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

General_SiSo_RU_lock_unlock_with_config2
    [Arguments]    ${tput_self_define}    ${config_id}    ${cell_id_NR}    ${duration}=${30}    ${ue_index}=0
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make call with NR cell1
    ${tput_info}    set variable    ${tput_self_define[${cell_id_NR}[0]]}
    make_call    tput_info=${tput_info}    ue_index=${ue_index}
    log to console    lock ru2, check NR call not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru  ru_index=${2}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${2}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${cell_id_NR}[0]    ue_index=${0}    tput_log=${tput_log}
    log to console    unlock ru2, check NR call not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.unlock_ru  ru_index=${2}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${2}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${cell_id_NR}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make call with LTE cell 1
    make_call_4G    ue_type_4G=mtk_lte    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800    ue_index=${1}
    log to console    lock ru1
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru  ru_index=${1}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${1}
    log to console    unlock ru1, check LTE call not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.unlock_ru  ru_index=${1}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${1}
    check_tput_for_4G_call    ue_type_4G=mtk_lte    target_throughput_dl=${target_throughput_dl}    target_throughput_ul=${target_throughput_ul}
    ...    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=mtk_lte    ue_index=${1}
    log to console    make call with NR
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id_NR}    duration=${duration}    tput_from=${tput_from}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=mtk_lte    ue_index=${1}
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

General_SiSo_RU_lock_unlock_with_config3
    [Arguments]    ${tput_self_define}    ${config_id}    ${cell_id_NR}    ${duration}=${30}    ${ue_index}=0
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    lock ru1
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru  ru_index=${1}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${1}
    log to console    unlock ru1
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.unlock_ru  ru_index=${1}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${1}
    log to console    make call with NR and LTE
    ${tput_info}    set variable    ${tput_self_define[${cell_id_NR}[0]]}
    make_call    tput_info=${tput_info}    ue_index=${ue_index}
#    make_call_4G    ue_type_4G=mtk_lte    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
#    log to console    check tput of LTE call
#    check_tput_for_4G_call    ue_type_4G=mtk_lte    target_throughput_dl=${target_throughput_dl}    target_throughput_ul=${target_throughput_ul}
#    ...    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
#    run keyword and ignore error    detach_for_4G_call    ue_type_4G=mtk_lte    ue_index=${1}
#    log to console    check tput of NR call
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${cell_id_NR}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Concurrent_Mode_Individual_RAT_Reset_with_config2
    [Arguments]    ${tput_self_define}    ${config_id}    ${cell_id_NR}=${None}    ${duration}=${30}    ${connection}=GNB_OAM    ${ue_index}=0
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
#    log to console    make call with LTE
#    make_call_4G    ue_type_4G=mtk_lte    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800    ue_index=${1}
    log to console    make NR RAT Reset
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    NR RAT Reset
    run keyword and ignore error    Selenium Logout And Close Browser
    Verify all cells should be onair    connection=${connection}
#    log to console    check LTE call not dropped
#    check_tput_for_4G_call    ue_type_4G=mtk_lte    target_throughput_dl=${target_throughput_dl}    target_throughput_ul=${target_throughput_ul}
#    ...    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
#    run keyword and ignore error    detach_for_4G_call    ue_type_4G=mtk_lte    ue_index=${1}
    log to console    makr call with NR
    ${tput_info}    set variable    ${tput_self_define[${cell_id_NR}[0]]}
    make_call    tput_info=${tput_info}    ue_index=${ue_index}
    log to console    make LTE RAT Reset
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    LTE RAT Reset
    run keyword and ignore error    Selenium Logout And Close Browser
    Verify all lte cells should be onair    connection=${connection}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check NR call not dropped
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${cell_id_NR}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
#    log to console    make call with LTE
#    make_call_4G    ue_type_4G=mtk_lte    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=mtk_lte    target_throughput_dl=${target_throughput_dl}    target_throughput_ul=${target_throughput_ul}
#    ...    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
#    run keyword and ignore error    detach_for_4G_call    ue_type_4G=mtk_lte    ue_index=${1}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Concurrent_Mode_Individual_RAT_Reset_with_config3
    [Arguments]    ${tput_self_define}    ${config_id}    ${cell_id_NR}=${None}    ${duration}=${30}    ${connection}=GNB_OAM    ${ue_index}=0
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make NR RAT Reset
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    NR RAT Reset
    run keyword and ignore error    Selenium Logout And Close Browser
    Verify all cells should be onair    connection=${connection}
    log to console    make call with NR and LTE
    ${tput_info}    set variable    ${tput_self_define[${cell_id_NR}[0]]}
    make_call    tput_info=${tput_info}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=mtk_lte    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_4G_call    ue_type_4G=mtk_lte    target_throughput_dl=${target_throughput_dl}    target_throughput_ul=${target_throughput_ul}
    ...    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=mtk_lte    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${cell_id_NR}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make LTE RAT Reset
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    LTE RAT Reset
    run keyword and ignore error    Selenium Logout And Close Browser
    Verify all lte cells should be onair    connection=${connection}
    log to console    make call with NR and LTE
    make_call    tput_info=${tput_info}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=mtk_lte    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}    duration_call=1800    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_4G_call    ue_type_4G=mtk_lte    target_throughput_dl=${target_throughput_dl}    target_throughput_ul=${target_throughput_ul}
    ...    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=mtk_lte    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${cell_id_NR}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=mtk_lte    ue_index=${1}
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Auto_BTS_site_reset_kpi
    [Arguments]    ${config_id}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Teardown]   Selenium Logout And Close Browser
	
Get btsName
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
	${btsName}    selenium_coam.get_bts_name
    Set Test Variable    ${btsName}
    [Teardown]    Selenium Logout And Close Browser

Commission SCF Accorfing configuration
    [Arguments]    ${btsName}    ${config_id}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _config${config_id}.xml
    ${config_on_bts}    Fetch From Right    ${btsName}    config
    Run Keyword If    '${config_on_bts}'!='${config_id}'    Commissioning SCF And Check On Air    ${SCF_upload}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
