*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Variables    ../TestData/8798_variables.py

Documentation
...    author: Jiangjing Lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MAX_LOOP}    20
${throughput_dl}    300
${throughput_ul}    100
${target_throughput_dl_peak}    143.1
${target_throughput_dl}    143.1
${target_throughput_ul}    68.4
${ue_type_4G}    nokia_fastmile
${duration_call_LTE}    1800
${target_avg_percent_LTE}    0.8
${target_avg_percent_NR}    0.8
${min_percent_NR}    0.6
${PA_call}    ${20}


*** Keywords ***
General_SiSo_E2E_system_setup_with_data_transfer_conducte_8798_config
    [Arguments]    ${config_id}    ${tput_nr}=${None}    ${tput_lte}=${None}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    Get lnbtsID via SCF
    Get scf name    config_id=${config_id}
    General_DATA_transfer_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_nr}    tput_define_lte=${tput_lte}    pa_call_default=${PA_call}    scf_name=${scf_name}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.95}    min_percent_nr=${0.85}    target_avg_percent_lte=${0.95}    min_percent_lte=${0.85}    duration=${300}
    [Teardown]   Selenium Logout And Close Browser

Get scf name
    [Arguments]    ${config_id}
    ${scf_path}    Replace String    ${Golden_SCF_Path}    .xml    _config${config_id}.xml
    ${scf_name}      set variable    ${scf_path.split("/")[-1]}
    set test variable    ${scf_name}

Manual_SiSo_SM_RF_Module_lock_unlock_8798_config
    [Arguments]    ${config_id}    ${tput_nr}=${None}    ${tput_lte}=${None}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    Get lnbtsID via SCF
    Get scf name    config_id=${config_id}
    General_SISO_RU_Lock_Unlock_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_nr}    tput_define_lte=${tput_lte}    pa_call_default=${PA_call}    scf_name=${scf_name}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.3}    min_percent_nr=${0.2}    target_avg_percent_lte=${0.3}    min_percent_lte=${0.2}    duration=${60}
    [Teardown]   Selenium Logout And Close Browser

General_SiSo_Cell_block_and_unblock_8798_config
    [Arguments]    ${config_id}    ${tput_nr}=${None}    ${tput_lte}=${None}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    Get lnbtsID via SCF
    Get scf name    config_id=${config_id}
    General_SISO_Cell_Block_Unblock_SG08_Config    mrbtsId=${mrbtsID}    nrbtsId=${nrbtsID}    lnBtsId=${lnBtsId}
    ...    tput_define_nr=${tput_nr}    tput_define_lte=${tput_lte}    pa_call_default=${PA_call}    scf_name=${scf_name}    process_num_ul=${5}
    ...    target_avg_percent_nr=${0.8}    min_percent_nr=${0.5}    target_avg_percent_lte=${0.8}    min_percent_lte=${0.5}    duration=${60}
    [Teardown]    Selenium Logout And Close Browser

General_SiSo_E2E_system_setup_with_data_transfer_conducte_8798_J
    [Arguments]    ${tput_self_define}    ${config_id}    ${duration}=${300}    ${tput_from}=self_define    ${ue_type_nr}=mtk
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make call for nr cell 1
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU4}
    Nr cell access control    cell_id_call=${1}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}
    ...    pci=${781}
#    log to console    make call for nr cell 2
#    Nr cell access control    cell_id_call=${2}
#    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_2}    duration=${duration}
#    ...    pci=${782}
#    log to console    make call for nr cell 3
#    Nr cell access control    cell_id_call=${3}
#    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_3}    duration=${duration}
#    ...    pci=${783}
    log to console    make call for lte cell 401
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}    value=${PA_call}
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${401}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}    process_num_ul=5
    sleep    300s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_peak}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    min_percent=0.3
#    log to console    make call for lte cell 402
#    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${402}
#    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
#    ...    duration_call=${duration_call_LTE}    ue_index=${1}    process_num_ul=5
#    sleep    300s
#    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_peak}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    min_percent=0.3
#    log to console    make call for lte cell 403
#    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${403}
#    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
#    ...    duration_call=${duration_call_LTE}    ue_index=${1}    process_num_ul=5
#    sleep    300s
#    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_peak}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    min_percent=0.3
    log to console    make call for lte cell 405
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU4}    value=${PA_call}
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${405}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}    process_num_ul=5
    sleep    300s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_peak}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    min_percent=0.3
#    log to console    make call for lte cell 406
#    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${406}
#    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
#    ...    duration_call=${duration_call_LTE}    ue_index=${1}    process_num_ul=5
#    sleep    300s
#    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_peak}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    min_percent=0.3
#    log to console    make call for nr cell 4 and lte cell 404 together, and check tput
#    Nr cell access control    cell_id_call=${4}
#    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${404}
#    make_call    tput_info=${tput_nr_cell_4}   ue_index=${0}
#    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
#    ...    duration_call=${duration_call_LTE}    ue_index=${1}    process_num_ul=5
#    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type_nr}    duration=${duration}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}
#    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_4}[0]    ue_index=${0}    tput_log=${tput_log}
#    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser
#    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
#    ...    AND    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}

CB006876_ASOE_Concurrent_Mode_Individual_RAT_Reset_8798-J
    [Arguments]    ${tput_self_define}    ${config_id}    ${duration}=${30}    ${tput_from}=self_define    ${ue_type_nr}=mtk
    ...    ${connection}=GNB_OAM
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    NR RAT Reset
    run keyword and ignore error    Selenium Logout And Close Browser
    Verify all cells should be onair    connection=${connection}
#    log to console    make call for lte cell 404
#    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${404}
#    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
#    ...    duration_call=${duration_call_LTE}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
#    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    make lte rat reset
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    LTE RAT Reset
    run keyword and ignore error    Selenium Logout And Close Browser
    Verify all lte cells should be onair    connection=${connection}
    log to console    make call for nr cell 1
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU4}
    Nr cell access control    cell_id_call=${1}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    # check call with all others
    log to console    make call for nr cell 2
    Nr cell access control    cell_id_call=${2}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_2}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 3
    Nr cell access control    cell_id_call=${3}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_3}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 4
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}    value=${PA_call}
    Nr cell access control    cell_id_call=${4}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_4}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for lte cell 401
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}    value=${PA_call}
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${401}
    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    make call for lte cell 402
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${402}
    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    make call for lte cell 403
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${403}
    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    make call for lte cell 405
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU4}    value=${PA_call}
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${405}
    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    make call for lte cell 406
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${406}
    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}

General_SiSo_Cell_block_and_unblock_8798_J
    [Arguments]    ${tput_self_define}    ${config_id}    ${duration}=${30}    ${connection}=GNB_OAM    ${tput_from}=self_define
    ...    ${ue_type_nr}=mtk
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Get X2 link shutdown waiting time
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make call for nr cell 4
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU4}
    Nr cell access control    cell_id_call=${4}
    make_call    tput_info=${tput_nr_cell_4}   ue_index=${0}
    log to console    block lte cell 404, check nr cell 4 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block LTE cells and check status   block_list=${lte_cell_404}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_4}[0]    ue_index=${0}    tput_log=${tput_log}
    log to console    unblock lte cell 404, check nr cell 4 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock LTE Cells and check status   block_list=${lte_cell_404}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_4}[0]    ue_index=${0}    tput_log=${tput_log}
#    log to console    make call for lte cell 404
#    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${404}
#    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
#    ...    duration_call=${duration_call_LTE}    ue_index=${1}
    log to console    block nr cell 1, check nr cell 4 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${nr_cell_1}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_4}[0]    ue_index=${0}    tput_log=${tput_log}
    log to console    unblock nr cell 1, check nr cell 4 and lte cell 404 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${nr_cell_1}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_4}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
#    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    make call on nr cell 1 and lte cell 401
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}    value=${PA_call}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}    value=${PA_call}
    Nr cell access control    cell_id_call=${1}
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${401}
    make_call    tput_info=${tput_nr_cell_1}   ue_index=${0}
    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}
    log to console    block nr cell 2, check nr cell 1 not dropped
     Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${nr_cell_2}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_1}[0]    ue_index=${0}    tput_log=${tput_log}
    log to console    unblock nr cell 2, check nr cell 1 and lte cell 401 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${nr_cell_2}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_1}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # check call with all others
    log to console    make call for nr cell 2
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Nr cell access control    cell_id_call=${2}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_2}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 3
    Nr cell access control    cell_id_call=${3}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_3}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for lte cell 402
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}    value=${PA_call}
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${402}
    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    make call for lte cell 403
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${403}
    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    make call for lte cell 405
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU4}    value=${PA_call}
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${405}
    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    log to console    make call for lte cell 406
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${406}
    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Manual_SiSo_SM_RF_Module_lock_unlock_8798_J
    [Arguments]    ${tput_self_define}    ${config_id}    ${duration}=${30}    ${tput_from}=self_define    ${ue_type_nr}=mtk
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make call for nr cell 1
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU4}
    Nr cell access control    cell_id_call=${1}
    make_call    tput_info=${tput_nr_cell_1}   ue_index=${0}    pci=${781}
    log to console    lock ru3, check nr cell 1 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru  ru_index=${3}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${3}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell_for_config    cell_id=${nr_cell_1}[0]    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}
    log to console    unlock ru3, check nr cell 1 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.unlock_ru  ru_index=${3}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${3}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell_for_config    cell_id=${nr_cell_1}[0]    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
#    log to console    make call for nr cell 4 and lte cell 404 together
#    Nr cell access control    cell_id_call=${4}
#    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${404}
#    make_call    tput_info=${tput_nr_cell_4}    ue_index=${0}
#    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
#    ...    duration_call=${duration_call_LTE}    ue_index=${1}
#    log to console    lock ru1, check nr cell 4 not dropped
#    selenium_coam.lock_ru  ru_index=${1}
#    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${1}
#    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type_nr}    duration=${duration}
#    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_4}[0]    ue_index=${0}    tput_log=${tput_log}
#    log to console    unlock ru1, check nr cell 4 and lte cell 404 not dropped
#    selenium_coam.unlock_ru  ru_index=${1}
#    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${1}
#    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type_nr}    duration=${duration}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
#    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_4}[0]    ue_index=${0}    tput_log=${tput_log}
#    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    # check call with all others
#    log to console    make call for nr cell 2
#    Nr cell access control    cell_id_call=${2}
#    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_2}    duration=${duration}
#    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}    pci=${782}
#    log to console    make call for nr cell 3
#    Nr cell access control    cell_id_call=${3}
#    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_3}    duration=${duration}
#    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}    pci=${783}
    log to console    make call for lte cell 401
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}    value=${PA_call}
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${401}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}    process_num_ul=5
    sleep    300s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_peak}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    min_percent=0.3
#    log to console    make call for lte cell 402
#    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${402}
#    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
#    ...    duration_call=${duration_call_LTE}    ue_index=${1}    process_num_ul=5
#    sleep    300s
#    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_peak}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    min_percent=0.3
#    log to console    make call for lte cell 403
#    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${403}
#    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
#    ...    duration_call=${duration_call_LTE}    ue_index=${1}    process_num_ul=5
#    sleep    300s
#    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_peak}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    min_percent=0.3
    log to console    make call for lte cell 405
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU4}    value=${PA_call}
    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${405}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
    ...    duration_call=${duration_call_LTE}    ue_index=${1}    process_num_ul=5
    sleep    300s
    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_peak}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    min_percent=0.3
#    log to console    make call for lte cell 406
#    Lte cell access control    mrbtsId=${948}    lnBtsId=${948}    cell_id_call=${406}
#    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
#    ...    duration_call=${duration_call_LTE}    ue_index=${1}    process_num_ul=5
#    sleep    300s
#    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl_peak}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    min_percent=0.3
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    stop_traffic_and_detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

General_SiSo_E2E_system_setup_with_data_transfer_conducte_8798_M1
    [Arguments]    ${tput_self_define}    ${config_id}    ${duration}=${600}    ${tput_from}=self_define    ${ue_type_nr}=mtk
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make call for nr cell 1
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Nr cell access control    cell_id_call=${1}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 2
    Nr cell access control    cell_id_call=${2}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_2}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 5
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}    value=${PA_call}
    Nr cell access control    cell_id_call=${5}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_5}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 6
    Nr cell access control    cell_id_call=${6}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_6}    duration=${duration}    tput_from=${tput_from}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

General_SiSo_Cell_block_and_unblock_8798_M1
    [Arguments]    ${tput_self_define}    ${config_id}    ${duration}=${30}    ${connection}=GNB_OAM    ${tput_from}=self_define
    ...    ${ue_type_nr}=mtk
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Get X2 link shutdown waiting time
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make call for nr cell 5
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Nr cell access control    cell_id_call=${5}
    make_call    tput_info=${tput_nr_cell_5_M}   ue_index=${0}
    log to console    block nr cell 6, check nr cell 5 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${nr_cell_6}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_5}[0]    ue_index=${0}    tput_log=${tput_log}
    log to console    unblock nr cell 6, check nr cell 5 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${nr_cell_6}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_5}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make call for nr cell 6
    Nr cell access control    cell_id_call=${6}
    make_call    tput_info=${tput_nr_cell_6_M}   ue_index=${0}
    log to console    block nr cell5, check nr cell 6 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${nr_cell_5}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_6}[0]    ue_index=${0}    tput_log=${tput_log}
    log to console    unblock nr cell 5, check nr cell 6 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${nr_cell_5}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_6}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make call for cells that under RU1 and RU3
    log to console    make call for nr cell 1
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}    value=${PA_CALL}
    Nr cell access control    cell_id_call=${1}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 2
    Nr cell access control    cell_id_call=${2}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_2}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 5
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}    value=${PA_CALL}
    Nr cell access control    cell_id_call=${5}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_5}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 6
    Nr cell access control    cell_id_call=${6}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_6}    duration=${duration}    tput_from=${tput_from}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Manual_SiSo_SM_RF_Module_lock_unlock_8798_M1
    [Arguments]    ${tput_self_define}    ${config_id}    ${duration}=${30}    ${tput_from}=self_define    ${ue_type_nr}=mtk
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make call for nr cell 1
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Nr cell access control    cell_id_call=${1}
    make_call    tput_info=${tput_nr_cell_1_M}   ue_index=${0}    pci=${787}
    log to console    lock ru3, check nr cell 1 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru  ru_index=${3}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${3}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell_for_config    cell_id=${nr_cell_1}[0]    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}
    log to console    unlock ru3, check nr cell 1 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.unlock_ru  ru_index=${3}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${3}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell_for_config    cell_id=${nr_cell_1}[0]    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make call for nr cell 5
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}    value=${PA_call}
    Nr cell access control    cell_id_call=${5}
    make_call    tput_info=${tput_nr_cell_5_M}   ue_index=${0}    pci=${791}
    log to console    lock ru1, check nr cell 5 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru  ru_index=${1}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell_for_config    cell_id=${nr_cell_5}[0]    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}
    log to console    unlock ru1, check nr cell 5 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.unlock_ru  ru_index=${1}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell_for_config    cell_id=${nr_cell_5}[0]    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make call for cells that under RU1 and RU3
    log to console    make call for nr cell 1
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}    value=${PA_call}
    Nr cell access control    cell_id_call=${1}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}    pci=${787}
#    log to console    make call for nr cell 2
#    Nr cell access control    cell_id_call=${2}
#    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_2}    duration=${duration}
#    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}    pci=${788}
    log to console    make call for nr cell 5
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}    value=${PA_call}
    Nr cell access control    cell_id_call=${5}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_5}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}    pci=${791}
#    log to console    make call for nr cell 6
#    Nr cell access control    cell_id_call=${6}
#    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_6}    duration=${duration}
#    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}    pci=${792}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

General_SiSo_E2E_system_setup_with_data_transfer_conducte_8798_M2
    [Arguments]    ${tput_self_define}    ${config_id}    ${duration}=${600}    ${tput_from}=self_define    ${ue_type_nr}=mtk
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make call for nr cell 1
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Nr cell access control    cell_id_call=${1}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 2
    Nr cell access control    cell_id_call=${2}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_2}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 5
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}    value=${PA_call}
    Nr cell access control    cell_id_call=${5}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_5}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 6
    Nr cell access control    cell_id_call=${6}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_6}    duration=${duration}    tput_from=${tput_from}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

General_SiSo_Cell_block_and_unblock_8798_M2
    [Arguments]    ${tput_self_define}    ${config_id}    ${duration}=${30}    ${tput_from}=self_define    ${ue_type_nr}=mtk
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Get X2 link shutdown waiting time
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make call for nr cell 5
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Nr cell access control    cell_id_call=${5}
    make_call    tput_info=${tput_nr_cell_5_M}   ue_index=${0}    pci=${791}
    log to console    bock nr cell 6, check nr cell 5 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${nr_cell_6}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell_for_config    cell_id=${nr_cell_5}[0]    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}
    log to console    unblock nr cell 6, check nr cell 5 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${nr_cell_6}    check_alarm=${False}    gnb_type=${gNb_CuType}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell_for_config    cell_id=${nr_cell_5}[0]    ue_index=${0}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
#    log to console    make call for nr cell 6
#    Nr cell access control    cell_id_call=${6}
#    make_call    tput_info=${tput_nr_cell_6_M}   ue_index=${0}    pci=${792}
#    log to console    block nr cell5, check nr cell 6 dropped
#    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
#    Block cells and check status    block_list=${nr_cell_5}    check_alarm=${False}    gnb_type=${gNb_CuType}
#    run keyword and ignore error    Selenium Logout And Close Browser
#    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
#    check_tput_for_each_cell_for_config    cell_id=${nr_cell_6}[0]    ue_index=${0}    tput_log=${tput_log}
#    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}
#    log to console    unblock nr cell 5, check nr cell 6 not dropped
#    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
#    UnBlock cells and check status    block_list=${nr_cell_5}    check_alarm=${False}    gnb_type=${gNb_CuType}
#    run keyword and ignore error    Selenium Logout And Close Browser
#    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
#    check_tput_for_each_cell_for_config    cell_id=${nr_cell_6}[0]    ue_index=${0}    tput_log=${tput_log}
#    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}
#    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make call for cells that under RU1 and RU3
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}    value=${PA_call}
    log to console    make call for nr cell 1
    Nr cell access control    cell_id_call=${1}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}    pci=${787}
#    log to console    make call for nr cell 2
#    Nr cell access control    cell_id_call=${2}
#    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_2}    duration=${duration}
#    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}    pci=${788}
    log to console    make call for nr cell 5
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}    value=${PA_call}
    Nr cell access control    cell_id_call=${5}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_5}    duration=${duration}
    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}    pci=${791}
#    log to console    make call for nr cell 6
#    Nr cell access control    cell_id_call=${6}
#    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_6}    duration=${duration}
#    ...    target_avg_percent=${target_avg_percent_NR}    min_percent=${min_percent_NR}    pci=${792}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Manual_SiSo_SM_RF_Module_lock_unlock_8798_M2
    [Arguments]    ${tput_self_define}    ${config_id}    ${duration}=${30}    ${tput_from}=self_define    ${ue_type_nr}=mtk
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make call for nr cell 1
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Nr cell access control    cell_id_call=${1}
    make_call    tput_info=${tput_nr_cell_1_M}   ue_index=${0}
    log to console    lock ru3, check nr cell 1 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru  ru_index=${3}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${3}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_1}[0]    ue_index=${0}    tput_log=${tput_log}
    log to console    unlock ru3, check nr cell 1 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.unlock_ru  ru_index=${3}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${3}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile   duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_1}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make call for nr cell 5
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}    value=${PA_call}
    Nr cell access control    cell_id_call=${5}
    make_call    tput_info=${tput_nr_cell_5_M}   ue_index=${0}
    log to console    lock ru1, check nr cell 5 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru  ru_index=${1}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Locked  ru_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_5}[0]    ue_index=${0}    tput_log=${tput_log}
    log to console    unlock ru1, check nr cell 5 not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.unlock_ru  ru_index=${1}
    run keyword and ignore error    Selenium Logout And Close Browser
    wait until keyword succeeds  5min  20sec  RU Should Be Unlocked  ru_index=${1}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_5}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    make call for cells that under RU1 and RU3
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}    value=${PA_call}
    log to console    make call for nr cell 1
    Nr cell access control    cell_id_call=${1}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 2
    Nr cell access control    cell_id_call=${2}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_2}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 5
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3}    value=${PA_call}
    Nr cell access control    cell_id_call=${5}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_5}    duration=${duration}    tput_from=${tput_from}
    log to console    make call for nr cell 6
    Nr cell access control    cell_id_call=${6}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_6}    duration=${duration}    tput_from=${tput_from}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
	
Get btsName
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
	${btsName}    selenium_coam.get_bts_name
    Set Test Variable    ${btsName}
    [Teardown]    Selenium Logout And Close Browser

Get expect tput for each cell
    [Arguments]    ${tput_info}=${tput}
    ${tput_info}    get_self_define_tput_by_release    tput_info=${tput_info}
    ${tput_nr_cell_1}    set variable    ${tput_info[${nr_cell_1}[0]]}
    Set Suite Variable    ${tput_nr_cell_1}
    ${tput_nr_cell_2}    set variable    ${tput_info[${nr_cell_2}[0]]}
    Set Suite Variable    ${tput_nr_cell_2}
    ${tput_nr_cell_3}    set variable    ${tput_info[${nr_cell_3}[0]]}
    Set Suite Variable    ${tput_nr_cell_3}
    ${tput_nr_cell_4}    set variable    ${tput_info[${nr_cell_4}[0]]}
    Set Suite Variable    ${tput_nr_cell_4}
    ${tput_nr_cell_5}    set variable    ${tput_info[${nr_cell_5}[0]]}
    Set Suite Variable    ${tput_nr_cell_5}
    ${tput_nr_cell_6}    set variable    ${tput_info[${nr_cell_6}[0]]}
    Set Suite Variable    ${tput_nr_cell_6}

Get expect tput for each cell M
    [Arguments]    ${tput_info}=${tput_M}
    ${tput_info}    get_self_define_tput_by_release    tput_info=${tput_info}
    ${tput_nr_cell_1_M}    set variable    ${tput_info[${nr_cell_1}[0]]}
    Set Suite Variable    ${tput_nr_cell_1_M}
    ${tput_nr_cell_2_M}    set variable    ${tput_info[${nr_cell_2}[0]]}
    Set Suite Variable    ${tput_nr_cell_2_M}
    ${tput_nr_cell_3_M}    set variable    ${tput_info[${nr_cell_3}[0]]}
    Set Suite Variable    ${tput_nr_cell_3_M}
    ${tput_nr_cell_4_M}    set variable    ${tput_info[${nr_cell_4}[0]]}
    Set Suite Variable    ${tput_nr_cell_4_M}
    ${tput_nr_cell_5_M}    set variable    ${tput_info[${nr_cell_5}[0]]}
    Set Suite Variable    ${tput_nr_cell_5_M}
    ${tput_nr_cell_6_M}    set variable    ${tput_info[${nr_cell_6}[0]]}
    Set Suite Variable    ${tput_nr_cell_6_M}

Commission SCF Accorfing configuration
    [Arguments]    ${btsName}    ${config_id}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _config${config_id}.xml
    ${config_on_bts}    Fetch From Right    ${btsName}    config
    Run Keyword If    '${config_on_bts}'!='${config_id}'    Commissioning SCF And Check On Air    ${SCF_upload}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

Nr cell access control
    [Arguments]    ${mrbtsId}=${948}    ${nrBtsId}=${1116}    ${cell_id_call}=${1}    ${connection}=GNB_OAM
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    @{nr_cell_all}    Evaluate    @{nr_cell_1}+@{nr_cell_2}+@{nr_cell_3}+@{nr_cell_4}+@{nr_cell_5}+@{nr_cell_6}
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

#Lte cell access control
#    [Arguments]    ${mrbtsId}=${948}    ${lnBtsId}=${948}    ${cell_id_call}=${401}    ${connection}=GNB_OAM
#    @{lte_cell_all}    Evaluate    @{lte_cell_401}+@{lte_cell_402}+@{lte_cell_403}+@{lte_cell_404}+@{lte_cell_405}+@{lte_cell_406}
#    FOR    ${lte_cell_id}    IN    @{lte_cell_all}
#        run keyword If    '${lte_cell_id}'!='${cell_id_call}'    coam.perform_parameter_recommissioning    parameter=qRxLevMin    value=${-44}
#        ...    dist_name=MRBTS-${mrbtsId}/LNBTS-${lnBtsId}/LNCEL-${lte_cell_id}/SIB-0    operation=update    connection=${connection}
#        ...    ELSE    run keyword    coam.perform_parameter_recommissioning    parameter=qRxLevMin    value=${-130}
#        ...    dist_name=MRBTS-${mrbtsId}/LNBTS-${lnBtsId}/LNCEL-${lte_cell_id}/SIB-0    operation=update    connection=${connection}
#        Sleep    5s
#    END
#    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair

Lte cell access control
    [Arguments]    ${mrbtsId}=${948}    ${lnBtsId}=${948}    ${cell_id_call}=${401}    ${connection}=GNB_OAM
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    @{lte_cell_all}    Evaluate    @{lte_cell_401}+@{lte_cell_402}+@{lte_cell_403}+@{lte_cell_404}+@{lte_cell_405}+@{lte_cell_406}
    ${modify_params}  create list
    set test variable    ${modify_params}
    FOR    ${lte_cell_id}    IN    @{lte_cell_all}
        run keyword If    '${lte_cell_id}'!='${cell_id_call}'    add lte cell modify params to list   lte_cell_id=${lte_cell_id}    value=${-44}
        ...    mrbtsId=${mrbtsId}    lnBtsId=${lnBtsId}    ELSE    run keyword    add lte cell modify params to list   lte_cell_id=${lte_cell_id}
        ...    value=${-130}    mrbtsId=${mrbtsId}    lnBtsId=${lnBtsId}
    END
    FOR    ${item}    IN    @{modify_params}
        selenium_coam.Set Parameter Value    dist_name=${item}[dist_name]    filter_param=${item}[filter_param]    abbr=${item}[p_name]
        ...    new_value=${item}[value]
    END
    selenium_coam.Validate Plan
    selenium_coam.Activate Plan    activate_plan_despite_errors=${true}    execute=${true}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair
    Sleep    10s
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

#add lte cell modify params to list
#    [Arguments]    ${lte_cell_id}    ${value}    ${mrbtsId}=${948}    ${lnBtsId}=${948}    ${connection}=GNB_OAM
#    ${item}    create dictionary    dist_name=MRBTS-${mrbtsId}/LNBTS-${lnBtsId}/LNCEL-${lte_cell_id}/SIB-0
#    ...    filter_param=Minimum required RX level in cell    p_name=qRxLevMin    value=${value}
#    append to list    ${modify_params}    ${item}

Set PA Port Value To default value
    [Arguments]    ${attenuator_index}=${0}    ${value}=${20}
    ${ports_info}    set variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    ${ports}    Get Dictionary Keys    ${ports_info}
    ${PA}    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}    alias=HBTE
    FOR    ${port}    IN    @{ports}
        attenuator.set_attenuation    port=${port}    value=${value}    attenuator_device=${PA}
    END

Auto_BTS_site_reset_kpi
    [Arguments]    ${config_id}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Teardown]   Selenium Logout And Close Browser

General_SiSo_E2E_system_setup_with_data_transfer_conducted_by_config_6876
    [Arguments]    ${tput_self_define}    ${config_id}    ${cell_id_NR}    ${duration}=${600}    ${tput_from}=self_define
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id_NR}    duration=${duration}    tput_from=${tput_from}
    [Teardown]   run keyword and ignore error    Selenium Logout And Close Browser

General_SiSo_Cell_lock_and_unlock_by_config_6876
    [Arguments]    ${tput_self_define}    ${config_id}    ${cell_id_NR}    ${cell_id_LTE}    ${duration}=${30}    ${ue_index}=0
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Get X2 link shutdown waiting time
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    btsName=${btsName}    config_id=${config_id}
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    make call with NR cell1
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2}
    ${tput_info}    set variable    ${tput_self_define[${cell_id_NR}[0]]}
    make_call    tput_info=${tput_info}    ue_index=${ue_index}
    log to console    block lte cell 401, check NR call not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block LTE cells and check status   block_list=${cell_id_LTE}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile   duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${cell_id_NR}[0]    ue_index=${0}    tput_log=${tput_log}
    log to console    unblock lte cell, check NR call not dropped
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock LTE Cells and check status   block_list=${cell_id_LTE}
    run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${cell_id_NR}[0]    ue_index=${0}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
#    log to console    make call with lte cell
#    make_call_4G_8798    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}    throughput_ul=${throughput_ul}
#    ...    duration_call=${duration_call_LTE}    ue_index=${1}
#    log to console    block NR cell. check lte call not dropped
#    Block cells and check status    block_list=${cell_id_NR}    check_alarm=${False}    gnb_type=${gNb_CuType}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
#    log to console    unblock NR cell, check lte call not dropped
#    UnBlock cells and check status    block_list=${cell_id_NR}    check_alarm=${False}    gnb_type=${gNb_CuType}
#    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}    target_throughput_dl=${target_throughput_dl}
#    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${1}    duration=${duration}    target_avg_percent=${target_avg_percent_LTE}
#    run keyword and ignore error    detach_for_4G_call    ue_type_4G=${ue_type_4G}    ue_index=${1}
#    log to console    make call with NR cell, check tput
#    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${cell_id_NR}    duration=${duration}    tput_from=${tput_from}
    [Teardown]    run keywords    run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Get PA Ports For All RUs
    ${PA_RU1}    Get PA Ports For each RU    ru_index=${0}
    ${PA_RU2}    Get PA Ports For each RU    ru_index=${1}
    ${PA_RU3}    Get PA Ports For each RU    ru_index=${2}
    ${PA_RU4}    Get PA Ports For each RU    ru_index=${3}
    Set Suite Variable    ${PA_RU1}
    Set Suite Variable    ${PA_RU2}
    Set Suite Variable    ${PA_RU3}
    Set Suite Variable    ${PA_RU4}

make_call_4G_8798
    [Arguments]  ${ue_type_4G}    ${throughput_dl}    ${throughput_ul}    ${duration_call}    ${ue_index}=${0}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type_4G}    ue_index=${ue_index}
    ${log_type}    run keyword if    '${ue_type_4G}'=='nokia_fastmile'    set variable    Iperf
    ...    ELSE    set variable    Aasyslog
    power_ue.UE Attach    ue_type=${ue_type_4G}    ue_index=${ue_index}    log_type=${log_type}
    power_ue.UE Detach  ue_type=${ue_type_4G}    ue_index=${ue_index}
    sleep    30s
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type_4G}    ue_index=${ue_index}
    power_ue.UE Attach    ue_type=${ue_type_4G}    ue_index=${ue_index}    log_type=${log_type}
    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=dl    throughput=${throughput_dl}
    ...    duration=${duration_call}    ue_index=${ue_index}
    log to console    4G call dl start ...
    power_ue.Start traffic    ue_type=${ue_type_4G}    direction=ul    throughput=${throughput_ul}
    ...    duration=${duration_call}    ue_index=${ue_index}
    log to console    4G call ul start ...
