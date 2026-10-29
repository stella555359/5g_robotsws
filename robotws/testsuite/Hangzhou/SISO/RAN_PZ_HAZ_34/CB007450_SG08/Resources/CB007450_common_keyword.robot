*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Variables    ../TestData/variables_7450.py

Documentation
...    author: Jianjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${PA_INFO}    ${tl.attenuator}
${throughput_dl_LTE}    300
${throughput_ul_LTE}    50
${target_throughput_dl_LTE}    189
${target_throughput_ul_LTE}    8.75
${ue_type_4G}    cpe_lte

*** Keywords ***
General_SiSo_E2E_system_setup_with_data_transfer_conducted_7450
    [Arguments]    ${duration}=${600}
    # nr cell 1 call + lte cell 401 or 402 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_1}
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_3}
    ${tput_cell_1}    set variable    ${tput_cells[1]}
    ${ue_index}    set variable    ${tput_cell_1['ue_index']}
    make_call    tput_info=${tput_cell_1}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${243}
    ...    target_throughput_ul=${11.2}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${1}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # nr cell 3 call + lte cell 405 or 406 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_1}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_2}
    ${tput_cell_3}    set variable    ${tput_cells[3]}
    ${ue_index}    set variable    ${tput_cell_3['ue_index']}
    make_call    tput_info=${tput_cell_3}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${243}
    ...    target_throughput_ul=${11.2}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${3}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # nr cell 2 call + lte cell 403 or 404 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_2}    value=${5}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_3}    value=${2}
    ${tput_cell_2}    set variable    ${tput_cells[2]}
    ${ue_index}    set variable    ${tput_cell_2['ue_index']}
    make_call    tput_info=${tput_cell_2}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=1800
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${243}
    ...    target_throughput_ul=${11.2}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${2}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

General_SiSo_Online_Sector_Addition_Deletion_7450
    [Arguments]    ${duration}=${30}
    # delete nr cell 3, lte cell 405
    # add nr cell 3, lte cell 405
    NR AND LTE Cell addition deletion    addition_deletion_cell_nr=${3}    addition_deletion_cellgrp_nr=${2}    lcrId_nr=${3}
    ...    lnbtsID=${2156}    addition_deletion_cell_lte=${405}    lcrId_lte=${5}
    # nr cell 3 call + lte 405 or 406 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_1}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_2}
    ${tput_cell_3}    set variable    ${tput_cells[3]}
    ${ue_index}    set variable    ${tput_cell_3['ue_index']}
    make_call    tput_info=${tput_cell_3}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${3}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Manual_SiSo_SM_BTS_Site_Reset
    [Arguments]    ${duration}=${30}
    # reset site
    Perform BTS Site Reset
    # check bts onair
    Sleep    5min
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    Connect to gnb coam via ssl
    # nr cell 3 call + lte cell 405 or 406 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_1}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_2}
    ${tput_cell_3}    set variable    ${tput_cells[3]}
    ${ue_index}    set variable    ${tput_cell_3['ue_index']}
    make_call    tput_info=${tput_cell_3}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${3}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # nr cell 2 call + lte cell 403 or 404 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_2}    value=${5}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_3}    value=${2}
    ${tput_cell_2}    set variable    ${tput_cells[2]}
    ${ue_index}    set variable    ${tput_cell_2['ue_index']}
    make_call    tput_info=${tput_cell_2}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${2}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Manual_SiSo_SM_RF_Module_lock_unlock
    [Arguments]    ${duration}=${30}
    Selenium Login And Disable Screen Lock
    # ru1 lock unlock
    selenium_coam.lock_ru  ru_index=${1}
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${1}
    selenium_coam.unlock_ru  ru_index=${1}
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${1}
    # nr cell 1 call + lte cell 401 or 402 call
#    Set All PA Port Value to 127
#    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_1}
#    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_3}
#    ${tput_cell_1}    set variable    ${tput_cells[1]}
#    ${ue_index}    set variable    ${tput_cell_1['ue_index']}
#    make_call    tput_info=${tput_cell_1}    ue_index=${ue_index}
#    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
#    ...    ue_index=${1}
#    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
#     stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
#    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
#    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${1}    ue_index=${ue_index}    tput_log=${tput_log}
#    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # nr cell 3 call + lte cell 405 or 406 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_1}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_2}
    ${tput_cell_3}    set variable    ${tput_cells[3]}
    ${ue_index}    set variable    ${tput_cell_3['ue_index']}
    make_call    tput_info=${tput_cell_3}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${3}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # ru2 lock unlock
    selenium_coam.lock_ru  ru_index=${2}
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${2}
    selenium_coam.unlock_ru  ru_index=${2}
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${2}
    # nr cell 2 call + lte cell 403 or 404 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_2}    value=${5}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_3}    value=${2}
    ${tput_cell_2}    set variable    ${tput_cells[2]}
    ${ue_index}    set variable    ${tput_cell_2['ue_index']}
    make_call    tput_info=${tput_cell_2}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${2}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    [Teardown]   Selenium Logout And Close Browser

BS-RF__LTE_cell_lock_unlock_administrative_state_change_from_WebEm
    [Arguments]    ${duration}=${30}    ${tput_from}=self_define
    Get X2 link shutdown waiting time
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    # block nr cell 1
    ${cell_id_list}    create list    ${1}
    Block cells and check status    block_list=${cell_id_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
    # lte cell 401 or 402 call
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    Sleep    ${duration}s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    # unblock nr cell 1
    UnBlock cells and check status    block_list=${cell_id_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
    # nr cell 1 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_1}
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_3}
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    # **********************************
    # block nr cell 3
#    ${cell_id_list}    create list    ${3}
#    Block cells and check status    block_list=${cell_id_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
#    # lte cell 405 or 406 call
#    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
#    ...    ue_index=${1}
#    Sleep    ${duration}s
#    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
#    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
#    # unblock nr cell 3
#    UnBlock cells and check status    block_list=${cell_id_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
#    # nr cell 3 call
#    Set All PA Port Value to 127
#    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_1}
#    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_2}
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_3}    duration=${duration}    tput_from=${tput_from}
    # **********************************
    # block nr cell 2
    ${cell_id_list}    create list    ${2}
    Block cells and check status    block_list=${cell_id_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
    # lte cell 403 or 404 call
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    Sleep    ${duration}s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    # unblock nr cell 2
     UnBlock cells and check status    block_list=${cell_id_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
    # nr cell 2 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_2}    value=${5}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_3}    value=${2}
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_2}    duration=${duration}    tput_from=${tput_from}
    # **********************************
    # block lte cell 401 or 402
#    ${cell_id_list}    create list    ${401}
#    Block LTE cells and check status    block_list=${cell_id_list}
#    # nr cell 1 call
#    Set All PA Port Value to 127
#    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_1}
#    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_3}
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
#    # unblock lte cell 401 or 402
#    UnBlock LTE cells and check status    block_list=${cell_id_list}
#    # lte cell 401 or 402 call
#    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
#    ...    ue_index=${1}
#    Sleep    ${duration}s
#    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
#    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    # **********************************
    # block lte cell 405 or 406
    ${cell_id_list}    create list    ${405}
    Block LTE cells and check status    block_list=${cell_id_list}
    # nr cell 3 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_1}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_2}
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_3}    duration=${duration}    tput_from=${tput_from}
    # unblock lte cell 405 or 406
    UnBlock LTE cells and check status    block_list=${cell_id_list}
    # lte cell 405 or 406 call
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    Sleep    ${duration}s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    # **********************************
    # block lte cell 403 or 404
    ${cell_id_list}    create list    ${403}
    Block LTE cells and check status    block_list=${cell_id_list}
    # nr cell 2 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_2}    value=${5}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_3}    value=${2}
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_2}    duration=${duration}    tput_from=${tput_from}
    # unblock lte cell 403 or 404
    UnBlock LTE cells and check status    block_list=${cell_id_list}
    # lte cell 403 or 404 call
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    Sleep    ${duration}s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    [Teardown]    Selenium Logout And Close Browser

Manual_SiSo_REC_Radio_Module_power_reset
    [Arguments]    ${duration}=${30}
    # ru1 power off and check status
    Perform RU Power Off    ru_index=${1}
    Wait until keyword succeeds    10 min    20 sec    RU Should Be Power Off    ru_index=${1}
    # ru1 power on and check status
    Perform RU Power On    ru_index=${1}
    Wait until keyword succeeds    15 min    20 sec    RU Should Be Online    ru_index=${1}
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
    # nr cell 1 call + lte cell 401 or 402 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_1}
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_3}
    ${tput_cell_1}    set variable    ${tput_cells[1]}
    ${ue_index}    set variable    ${tput_cell_1['ue_index']}
    make_call    tput_info=${tput_cell_1}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${1}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # nr cell 3 call + lte cell 405 or 406 call
#    Set All PA Port Value to 127
#    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_1}
#    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_2}
#    ${tput_cell_3}    set variable    ${tput_cells[3]}
#    ${ue_index}    set variable    ${tput_cell_3['ue_index']}
#    make_call    tput_info=${tput_cell_3}    ue_index=${ue_index}
#    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
#    ...    ue_index=${1}
#    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
#    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
#    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
#    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${3}    ue_index=${ue_index}    tput_log=${tput_log}
#    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # ru2 power off and check status
    Perform RU Power Off    ru_index=${2}
    Wait until keyword succeeds    10 min    20 sec    RU Should Be Power Off    ru_index=${2}
    # ru2 power on and check status
    Perform RU Power On    ru_index=${2}
    Wait until keyword succeeds    15 min    20 sec    RU Should Be Online    ru_index=${2}
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
    # nr cell 2 call + lte cell 403 or 404 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_2}    value=${5}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_3}    value=${2}
    ${tput_cell_2}    set variable    ${tput_cells[2]}
    ${ue_index}    set variable    ${tput_cell_2['ue_index']}
    make_call    tput_info=${tput_cell_2}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${2}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Manual_SiSo_SM_NR_RAT_reset
    [Arguments]    ${duration}=${30}
    Selenium Login And Disable Screen Lock
    # nr reset
    NR RAT Reset
    # check bts onair
    Sleep    5min
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    # nr cell 1 call + lte cell 401 or 402 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_1}
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_3}
    ${tput_cell_1}    set variable    ${tput_cells[1]}
    ${ue_index}    set variable    ${tput_cell_1['ue_index']}
    make_call    tput_info=${tput_cell_1}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${1}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # nr cell 3 call + lte cell 405 or 406 call
#    Set All PA Port Value to 127
#    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_1}
#    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_2}
#    ${tput_cell_3}    set variable    ${tput_cells[3]}
#    ${ue_index}    set variable    ${tput_cell_3['ue_index']}
#    make_call    tput_info=${tput_cell_3}    ue_index=${ue_index}
#    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
#    ...    ue_index=${1}
#    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
#    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
#    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
#    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${3}    ue_index=${ue_index}    tput_log=${tput_log}
#    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # nr cell 2 call + lte cell 403 or 404 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_2}    value=${5}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_3}    value=${2}
    ${tput_cell_2}    set variable    ${tput_cells[2]}
    ${ue_index}    set variable    ${tput_cell_2['ue_index']}
    make_call    tput_info=${tput_cell_2}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${2}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    [Teardown]    Selenium Logout And Close Browser

Manual_SiSo_SM_BTS_Block_Site
    [Arguments]    ${duration}=${30}
    # block site
    Perform BTS Site Block
    # unblock site
    Perform BTS Site UnBlock
    Sleep    5min
    Wait Until Keyword Succeeds    10min    30s    verify all cells should be onair
    Connect to gnb coam via ssl
    # nr cell 1 call + lte cell 401 or 402 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_1}
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_3}
    ${tput_cell_1}    set variable    ${tput_cells[1]}
    ${ue_index}    set variable    ${tput_cell_1['ue_index']}
    make_call    tput_info=${tput_cell_1}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${1}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # nr cell 2 call + lte cell 403 or 404 call
    Set All PA Port Value to 127
    Set PA For Special Cell Call    attenuator_index=${0}    PA_Port_List=${PA1_Port_List_2}    value=${5}
    Set PA For Special Cell Call    attenuator_index=${1}    PA_Port_List=${PA2_Port_List_3}    value=${2}
    ${tput_cell_2}    set variable    ${tput_cells[2]}
    ${ue_index}    set variable    ${tput_cell_2['ue_index']}
    make_call    tput_info=${tput_cell_2}    ue_index=${ue_index}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}    duration_call=600
    ...    ue_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=askey    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_cells}    cell_id=${2}    ue_index=${ue_index}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Perform BTS Site Block
    [Arguments]   ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.block_site
    Wait For Expect Fault Present   faultId=${50}   timeout=600
    [Teardown]  COAM selenium logout

Perform BTS Site UnBlock
    [Arguments]   ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.unblock_site
    Wait For Expect Fault To Disappear    faultId=${50}    timeout=600
    [Teardown]  COAM selenium logout

Set All PA Port Value to 127
    ${attenuators_num}    get length    ${PA_INFO}
    FOR    ${i}    IN RANGE    ${attenuators_num}
        Set PA Port Value To 127    attenuator_index=${i}
    END

Set PA Port Value To 127
    [Arguments]    ${attenuator_index}=${0}
    ${ports_info}    set variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    ${ports}    Get Dictionary Keys    ${ports_info}
    ${PA}    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}    alias=HBTE
    FOR    ${port}    IN    @{ports}
        attenuator.set_attenuation    port=${port}    value=${127}    attenuator_device=${PA}
    END

Set PA For Special Cell Call
    [Arguments]    ${attenuator_index}    ${PA_Port_List}    ${value}=${15}
    # for nr cell1: attenuator_index=0, PA_Port_List=[10,12,14,16]---15--PA1_Port_List_3
    # for nr cell3: attenuator_index=1, PA_Port_List=[6,8,10,12]---15--PA2_Port_List_2
    # for nr cell2: attenuator_index=1, PA_Port_List=[13,14,15,16]---2--PA2_Port_List_3
    # for nr lte cell 401/402: attenuator_index=0, PA_Port_List=[9,11,13,15]---15--PA1_Port_List_1
    # for nr lte cell 405/406: attenuator_index=1, PA_Port_List=[5,7,9,11]---15--PA2_Port_List_1
    # for nr lte cell 403/404: attenuator_index=0, PA_Port_List=[1,3,5,7]----5--PA1_Port_List_2
    ${PA}    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}    alias=HBTE
    FOR    ${port}    IN    @{PA_Port_List}
        ${port}  Evaluate  int(${port})
        attenuator.set_attenuation    port=${port}    value=${value}    attenuator_device=${PA}
    END

NR AND LTE Cell addition deletion
    [Arguments]    ${addition_deletion_cell_nr}    ${addition_deletion_cellgrp_nr}   ${lcrId_nr}
    ...    ${lnbtsID}    ${addition_deletion_cell_lte}    ${lcrId_lte}    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}  Get All Cell Group Id
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    log to console  delete nr object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell_nr}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell_nr}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp_nr}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${addition_deletion_cellgrp_nr}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    log to console  delete lte object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${addition_deletion_cell_lte}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${lcrId_lte}    timeout=15
    log to console    begin to validate
    selenium_coam.validate_plan
    log to console    begin to activate
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=300
    verify all cells should be onair
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}
    get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add nr object
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell_nr}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell_nr}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell_nr}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell_nr}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp_nr}
    ...    id_value=${addition_deletion_cellgrp_nr}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell_nr}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrId_nr}
    # recover NRDU-1 as prev
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR  ${i}  IN  @{cell_grp}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END
    log to console    add lte object
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}
    ...    object_class_name=LNCEL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${addition_deletion_cell_lte}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell_lte}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${lcrId_lte}
    ...    include_subobject=${True}   id_value=${lcrId_lte}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/LNBTS-${lnbtsID}/LNCEL-${addition_deletion_cell_lte}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${lcrId_lte}
    log to console    begin to validate
    selenium_coam.validate_plan
    log to console    begin to activate
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=300
    verify all cells should be onair
    [Return]  selenium logout and close browser
