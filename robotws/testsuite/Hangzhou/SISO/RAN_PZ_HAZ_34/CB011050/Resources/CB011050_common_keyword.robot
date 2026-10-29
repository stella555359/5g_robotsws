*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Variables    ../TestData/11050_variables.py

Documentation
...    author: Jiangjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
@{nr_cell_1}    ${1}
@{nr_cell_2}    ${2}
@{nr_cell_3}    ${3}
@{lte_cell_401}    ${401}
@{lte_cell_402}    ${402}
@{lte_cell_403}    ${403}
@{lte_cell_404}    ${404}
@{lte_cell_405}    ${405}
@{lte_cell_406}    ${406}
${ue_type_4G}    nokia_fastmile
${throughput_dl_LTE}    300
${throughput_ul_LTE}    50
${target_throughput_dl_LTE}    261
${target_throughput_ul_LTE}    12
${PA_call}    ${20}
@{PA_1}
@{PA_401_402}
@{PA_2}
@{PA_403_404}
@{PA_3}
@{PA_405_406}


*** Keywords ***
General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Arguments]    ${tput_self_define}    ${duration}=${300}    ${duration_call}=${1800}    ${tput_from}=self_define
    log to console    *************************  make call with nr_cell_1 and lte_cell_401  *************************
    log to console    make call for nr cell 1
    # set PA for nr cell 1 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_1}    value=${PA_call}
    # set nr cell access control for nr cell 1 call
    access control for nr cell    cell_id_call=${1}
    make_call    tput_info=${tput_cell_1}    ue_index=${0}    duration_call=${duration_call}
    log to console    make call for lte cell 401
    # set PA for lte cell 401 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_401_402}    value=${PA_call}
    # set lte cell access control for lte cell 401 call
    Lte cell access control    cell_id_call=${401}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}
    ...    duration_call=${duration_call}    ue_index=${1}
    log to console    collect tput...
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    check tput for lte cell 401
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    duration=${duration}
    log to console    check tput for nr cell 1
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_1}    ue_index=${0}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    *************************  make call with nr_cell_2 and lte_cell_404  *************************
    log to console    make call for nr cell 2
    # set PA for nr cell 2 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_1}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_2}    value=${PA_call}
    # set nr cell access control for nr cell 2 call
    access control for nr cell    cell_id_call=${2}
    make_call    tput_info=${tput_cell_2}    ue_index=${0}    duration_call=${duration_call}
    log to console    make call for lte cell 404
    # set PA for lte cell 404 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_401_402}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_403_404}    value=${PA_call}
    # set lte cell access control for lte cell 404 call
    Lte cell access control    cell_id_call=${404}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}
    ...    duration_call=${duration_call}    ue_index=${1}
    log to console    collect tput...
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    check tput for lte cell 404
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    duration=${duration}
    log to console    check tput for nr cell 2
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_2}    ue_index=${0}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    ************************* make call with nr_cell_3 and lte_cell_405  *************************
    log to console    make call for nr cell 3
    # set PA for nr cell 3 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_2}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_3}    value=${PA_call}
    # set nr cell access control for nr cell 3 call
    access control for nr cell    cell_id_call=${3}
    make_call    tput_info=${tput_cell_3}    ue_index=${0}    duration_call=${duration_call}
    log to console    make call for lte cell 405
    # set PA for lte cell 405 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_403_404}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_405_406}    value=${PA_call}
    # set lte cell access control for lte cell 405 call
    Lte cell access control    cell_id_call=${405}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}
    ...    duration_call=${duration_call}    ue_index=${1}
    log to console    collect tput...
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    check tput for lte cell 405
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    duration=${duration}
    log to console    check tput for nr cell 3
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_3}    ue_index=${0}    tput_log=${tput_log}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}


Manual_SiSo_SM_NR RAT reset
    [Arguments]    ${tput_self_define}    ${duration}=${30}    ${duration_call}=${1800}    ${tput_from}=self_define
    ...    ${target_avg_percent}=0.98    ${min_percent}=0.85
    log to console    make nr rat reset, check all nr and lte cells on air
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    NR RAT Reset
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    *************************   make call with nr cell 2 and lte cell 404    *************************
    log to console    make call for nr cell 2
    # set PA for nr cell 2 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_2}    value=${PA_call}
    # set nr cell access control for nr cell 2 call
    access control for nr cell    cell_id_call=${2}
    make_call    tput_info=${tput_cell_2}    ue_index=${0}    duration_call=${duration_call}
    log to console    make call for lte cell 404
    # set PA for lte cell 404 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_403_404}    value=${PA_call}
    # set lte cell access control for lte cell 404 call
    Lte cell access control    cell_id_call=${404}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}
    ...    duration_call=${duration_call}    ue_index=${1}
    log to console    collect tput...
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    check tput for lte cell 404
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    check tput for nr cell 2
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_2}    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    *************************   make call with nr cell 3 and lte cell 406    *************************
    log to console    make call for nr cell 3
    # set PA for nr cell 3 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_2}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_3}    value=${PA_call}
    # set nr cell access control for nr cell 3 call
    access control for nr cell    cell_id_call=${3}
    make_call    tput_info=${tput_cell_3}    ue_index=${0}    duration_call=${duration_call}
    log to console    make call for lte cell 406
    # set PA for lte cell 406 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_403_404}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_405_406}    value=${PA_call}
    # set lte cell access control for lte cell 406 call
    Lte cell access control    cell_id_call=${406}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}
    ...    duration_call=${duration_call}    ue_index=${1}
    log to console    collect tput...
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    check tput for lte cell 406
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    check tput for nr cell 3
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_3}    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make lte rat reset, check all nr and lte cells on air
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    LTE RAT Reset
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    *************************   make call with nr cell 1 and lte cell 401    *************************
    log to console    make call for nr cell 1
    # set PA for nr cell 1 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_3}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_1}    value=${PA_call}
    # set nr cell access control for nr cell 1 call
    access control for nr cell    cell_id_call=${1}
    make_call    tput_info=${tput_cell_1}    ue_index=${0}    duration_call=${duration_call}
    log to console    make call for lte cell 401
    # set PA for lte cell 401 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_405_406}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_401_402}    value=${PA_call}
    # set lte cell access control for lte cell 401 call
    Lte cell access control    cell_id_call=${401}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}
    ...    duration_call=${duration_call}    ue_index=${1}
    log to console    collect tput...
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    check tput for lte cell 401
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    check tput for nr cell 1
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_1}    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    *************************   make call with nr cell 3 and lte cell 405    *************************
    log to console    make call for nr cell 3
    # set PA for nr cell 3 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_1}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_3}    value=${PA_call}
    # set nr cell access control for nr cell 3 call
    access control for nr cell    cell_id_call=${3}
    make_call    tput_info=${tput_cell_3}    ue_index=${0}    duration_call=${duration_call}
    log to console    make call for lte cell 405
    # set PA for lte cell 405 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_401_402}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_405_406}    value=${PA_call}
    # set lte cell access control for lte cell 405 call
    Lte cell access control    cell_id_call=${405}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}
    ...    duration_call=${duration_call}    ue_index=${1}
    log to console    collect tput...
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    check tput for lte cell 405
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    check tput for nr cell 3
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_3}    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}


General_SiSo_Cell_block_and_unblock
    [Arguments]    ${tput_self_define}    ${duration}=${30}    ${duration_call}=${1800}    ${tput_from}=self_define
    ...    ${target_avg_percent}=0.98    ${min_percent}=0.85
    log to console    *************************   make call with nr cell 1    *************************
    log to console    make call for nr cell 1
    # set PA for nr cell 1 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_1}    value=${PA_call}
    # set nr cell access control for nr cell 1 call
    access control for nr cell    cell_id_call=${1}
    make_call    tput_info=${tput_cell_1}    ue_index=${0}    duration_call=${duration_call}
    log to console    block lte cell 401, check status of lte cell 401
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block LTE cells and check status    block_list=${lte_cell_401}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    check nr call not dropped , and check tput
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${1}    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    unblock lte cell 401, check status of lte cell 401
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock LTE cells and check status    block_list=${lte_cell_401}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    check nr call not dropped, and check tput
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${1}    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make call for lte cell 401
    # set PA for lte cell 401 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_401_402}    value=${PA_call}
    # set lte cell access control for lte cell 401 call
    Lte cell access control    cell_id_call=${401}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}
    ...    duration_call=${duration_call}    ue_index=${1}
    log to console    block nr cell 1, and check status of nr cell 1
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${nr_cell_1}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    check lte call not dropped, and check tput
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    duration=${duration}
    log to console    unblock nr cell 1, check status of nr cell 1
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${nr_cell_1}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    check lte call not dropped ,and check tput
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    make call for nr cell 1, and check tput
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    *************************    make call with nr cell 3 *************************
    log to console    make call for nr cell 3
    # set PA for nr cell 3 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_1}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_3}    value=${PA_call}
    # set nr cell access control for nr cell 3 call
    access control for nr cell    cell_id_call=${3}
    make_call    tput_info=${tput_cell_3}    ue_index=${0}    duration_call=${duration_call}
    log to console    block lte cell 405, check status of lte cell 405
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block LTE cells and check status    block_list=${lte_cell_405}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    check nr call not dropped , and check tput
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${3}    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    log to console    unblock lte cell 405, check status of lte cell 405
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock LTE cells and check status    block_list=${lte_cell_405}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    check nr call not dropped, and check tput
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${3}    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make call for lte cell 405, check tput
    # set PA for lte cell 405 call
    Set PA Value For Pointed Port    PA_Port_List=${PA_401_402}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_405_406}    value=${PA_call}
    # set lte cell access control for lte cell 401 call
    Lte cell access control    cell_id_call=${405}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl_LTE}    throughput_ul=${throughput_ul_LTE}
    ...    duration_call=${duration_call}    ue_index=${1}
    log to console    block nr cell 3, and check status of nr cell 3
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${nr_cell_3}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    check lte call not dropped, and check tput
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    duration=${duration}
    log to console    unblock nr cell 3, check status of nr cell 3
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${nr_cell_3}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    check lte call not dropped ,and check tput
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_LTE}
    ...    target_throughput_ul=${target_throughput_ul_LTE}    ue_index=${1}    target_avg_percent=${target_avg_percent}
    ...    min_percent=${min_percent}    duration=${duration}
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    make call for nr cell3, and check tput
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_3}    duration=${duration}    tput_from=${tput_from}


Get expect tput for each nr cell
    [Arguments]    ${tput_info}=${tput}
    ${tput_info}    get_self_define_tput_by_release    tput_info=${tput_info}
    ${tput_nr_cell_1}    set variable    ${tput_info[${nr_cell_1}[0]]}
    Set Suite Variable    ${tput_nr_cell_1}
    ${tput_nr_cell_2}    set variable    ${tput_info[${nr_cell_2}[0]]}
    Set Suite Variable    ${tput_nr_cell_2}
    ${tput_nr_cell_3}    set variable    ${tput_info[${nr_cell_3}[0]]}
    Set Suite Variable    ${tput_nr_cell_3}


access control for nr cell
    [Arguments]    ${mrbtsId}=${948}    ${nrBtsId}=${1116}    ${cell_id_call}=${1}    ${connection}=GNB_OAM
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    @{nr_cell_all}    Evaluate    @{nr_cell_1}+@{nr_cell_2}+@{nr_cell_3}
    ${nr_cell_num}    Get Length    ${nr_cell_all}
    FOR    ${cell_id}    IN RANGE    1    ${nr_cell_num}+1
        run keyword If    '${cell_id}'!='${cell_id_call}'    wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    parameter=qRxLevMin    value=${-22}    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrBtsId}/NRCELL-${cell_id}
        ...    operation=update    connection=${connection}
        ...    ELSE    wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrBtsId}/NRCELL-${cell_id}    parameter=qRxLevMin    value=${-65}
        ...    operation=update    connection=${connection}
        Sleep    5s
    END
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

Get scf name
    ${scf_path_11050}    Replace String    ${Golden_SCF_Path}    .xml    _11050.xml
    ${scf_name_11050}      set variable    ${scf_path_11050.split("/")[-1]}
    set suite variable    ${scf_name_11050}

Commission SCF Accorfing Feature Id
    [Arguments]    ${feature_id}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _${feature_id}.xml
    Commissioning SCF And Check On Air    ${SCF_upload}
