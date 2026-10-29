*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    ../../resources/cbrs_common_keywords.robot
Library     CB010475.py
Variables    ../TestData/10475_variables.py

Documentation    This is for SG8 common keywords
...              Author: linjiangjing
...              Squard: HZ SG8

*** Variables ***
${sas_log_path}    ${CURDIR}/../../resources/SASSim_HZ/SAS_Sim.log
${conf_path}    ${CURDIR}/conf
${proxy_conf_path}    ${CURDIR}/../../resources/Proxy_Config
${CB010475_NR_LTE_conf}    ${conf_path}/nr_lte.conf
${CB010475_NR_conf}    ${conf_path}/nr.conf
${CB010475_json_path}    ${CURDIR}/json
${disable_actcbrs}    ${CB010475_json_path}/disable_actcbrs.json
${enable_actcbrs}    ${CB010475_json_path}/enable_actcbrs.json
${ue_type_4G}    nokia_fastmile
${exp_dl_LTE}    400
${exp_ul_LTE}    30
${target_dl_LTE}    276
${target_ul_LTE}    11.88
@{nr_cell_1}    ${1}
@{nr_cell_2}    ${2}
@{nr_cell_3}    ${3}
@{nr_cell_4}    ${4}
@{nr_cell_7}    ${7}
@{nr_cell_10}   ${10}
@{lte_cell_7}    ${7}
@{lte_cell_8}    ${8}
@{lte_cell_9}    ${9}
@{lte_cell_10}    ${10}
@{lte_cell_13}    ${13}
@{lte_cell_16}    ${16}
*** Keywords ***
Simply_reboot_ue
    [Documentation]  Use adb command to reboot cpe ue
    [Arguments]    ${hostname}=10.101.47.221    ${username}=mn5gran    ${password}=nokia123@    ${serial}=LPL221400464
    csn.connect to    hostname=${hostname}    username=${username}    password=${password}    alias=cpc
    csn.execute    command=adb -s ${serial} reboot   connection=cpc
    sleep    45s
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc


Check AWHQU configuration
    ${cell_list_nr}    Get All Cell Id    ru_index=${1}    cell_type=nr
    ${goal}    Check_configuration    cell_list_nr=${cell_list_nr}
    [Return]    ${goal}


CB010475 CBRS Test Setup
    [Arguments]    ${enable_delta_file}=${enable_actcbrs}
    CBRS Test Setup
    ${goal}    Check AWHQU configuration
    run keyword if    '${goal}'=='NR_LTE'    coam.perform_delta_recommissioning
    ...    delta_file=${enable_delta_file}    connection=GNB_OAM
    run keyword if    '${goal}'=='NR_LTE'    sleep    120s


CB010475 CBRS Test Teardown
    ${goal}    Check AWHQU configuration
    run keyword if    '${goal}'=='NR_LTE'    Deactivate LTE CBRS
    CBRS Test Teardown


Deactivate LTE CBRS
    [Arguments]    ${disable_delta_file}=${disable_actcbrs}
    coam.perform_delta_recommissioning    delta_file=${disable_delta_file}    connection=GNB_OAM
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be disabled    connection=GNB_OAM


Start SAS server for NR
    Commission scf    scf_name=nr_only
    start SAS server    config_name=${CB010475_NR_conf}
    Wait until keyword succeeds    15min    120s    verify all cells should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}


Start SAS server for NR LTE
    Commission scf    scf_name=nr_lte
    start SAS server    config_name=${CB010475_NR_LTE_conf}
    Wait until keyword succeeds    15min    120s    Check all cells info should be onair
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}


CB010475_SR_B_NR_only_Manual_SiSo_SM_NR_RAT_reset
    Selenium Login And Disable Screen Lock
    log to console    NR RAT Reset
    selenium_coam.reset_nr
    log to console    check operationalState is disabled
    Wait Until Keyword Succeeds    5 min    10 sec    check cell operational status
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
    Make L3 call for NR only mode cell1
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


Make L3 call for NR only mode cell1
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}    exp_pa_value=${63}
    log to console    make L3 call (peak is not needed) for cell1 under RU1
    Set PA Value For Pointed Port    PA_Port_List=${A1B5_A4B8_RU1_UE2}   value=${10}
    Set qRxLevMin For cells under ru    ru_index=${1}    value=${-25}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_1}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_nr_only}    cell_id=${nr_cell_1}
    ...    duration=${300}    target_avg_percent=0.5    min_percent=0.3
    Set PA Value For Pointed Port    PA_Port_List=${A1B5_A4B8_RU1_UE2}    value=${63}


Make L3 call for NR only mode cell2
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}    exp_pa_value=${63}
    log to console    make L3 call (peak is not needed) for cell2 under RU2
    Set PA Value For Pointed Port    PA_Port_List=${A5B5_A8B8_RU2_UE2}    value=${10}
    Set qRxLevMin For cells under ru    ru_index=${2}    value=${-25}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_2}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_nr_only}    cell_id=${nr_cell_2}
    ...    duration=${300}    target_avg_percent=0.5    min_percent=0.3
    Set PA Value For Pointed Port    PA_Port_List=${A5B5_A8B8_RU2_UE2}    value=${63}

Make L3 call for NR only mode cell3
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}    exp_pa_value=${63}
    log to console    make L3 call (peak is not needed) for cell3 under RU3
    Set PA Value For Pointed Port    PA_Port_List=${A9B5_A12B8_RU3_UE2}    value=${10}
    Set qRxLevMin For cells under ru    ru_index=${3}    value=${-25}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_3}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_nr_only}    cell_id=${nr_cell_3}
    ...    duration=${300}    target_avg_percent=0.5    min_percent=0.3
    Set PA Value For Pointed Port    PA_Port_List=${A9B5_A12B8_RU3_UE2}   value=${63}


CB010475_SR_B_NR_only_General_SiSo_Cell_block_and_unblock
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${cell_id_list}    Get All Cell Id
    log to console    block all the cells
    run keyword and continue on failure    Block cells and check status    block_list=${cell_id_list}
    ...    check_alarm=${False}    gnb_type=${gNb_CuType}
    log to console    unblock all the cells
    UnBlock cells and check status    block_list=${cell_id_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
    Make L3 call for NR only mode cell2
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


CB010475_SR_B_NR_only_General_SiSo_E2E_system_setup_with_data_transfer_conducted_NR30+40+40+40MHz
    Selenium Login And Disable Screen Lock
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    ...    exp_pa_value=${63}
    Set PA Value For Pointed Port    PA_Port_List=${A1B5_A4B8_RU1_UE2}    value=${10}
    Set qRxLevMin For cells under ru    ru_index=${1}    value=${-25}
    log to console    make peak call for cell1
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_1}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_nr_only}    cell_id=${nr_cell_1}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_1}    value_call=${-25}
    log to console    make peak call for cell4
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_4}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_nr_only}    cell_id=${nr_cell_4}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_4}    value_call=${-25}
    log to console    make peak call for cell7
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_7}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_nr_only}    cell_id=${nr_cell_7}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_7}    value_call=${-25}
#    log to console    make peak call for cell10
#    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_10}    value_call=${-40}
#    data_transfer_common    tput_self_define=${tput_nr_only}    cell_id=${nr_cell_10}
#    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_10}    value_call=${-25}
    Set PA Value For Pointed Port    PA_Port_List=${A1B5_A4B8_RU1_UE2}    value=${63}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


Make L3 call for NR LTE concurrent mode for NRcell1 and LTEcell7
    Make L3 call for NR LTE concurrent mode for NRcell1
    Make L3 call for NR LTE concurrent mode for LTEcell7


Make L3 call for NR LTE concurrent mode for NRcell1
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    ...    exp_pa_value=${63}
    ${cell_list_nr}    Get All Cell Id    ru_index=${1}    cell_type=nr
    Set qRxLevMin For pointed NR cell    cell_id_list=${cell_list_nr}    value_call=${-25}
    log to console   make L3 call for NR cell 1
    Set PA Value For Pointed Port    PA_Port_List=${A1B5_A4B8_RU1_UE2}    value=${10}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_1}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_NR_LTE}    cell_id=${nr_cell_1}
    ...    duration=${300}    target_avg_percent=0.5    min_percent=0.3
    Set PA Value For Pointed Port    PA_Port_List=${A1B5_A4B8_RU1_UE2}    value=${63}


Make L3 call for NR LTE concurrent mode for LTEcell7
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    ...    exp_pa_value=${63}
    ${cell_list_lte}    Get All Cell Id    ru_index=${1}    cell_type=lte
    Set qRxLevMin For pointed LTE cell    cell_id_list=${cell_list_lte}   value_call=${-44}
    log to console   make L3 call for LTE cell 7
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE1}    value=${0}
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_7}   value_call=${-140}
    4G L3 call check    target_avg_percent=0.5    4G_duration=${300}    ue_index=${0}
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE1}    value=${63}


Make L3 call for NR LTE concurrent mode for NRcell2 and LTEcell8
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    ...    exp_pa_value=${63}
    ${cell_list_nr}    Get All Cell Id    ru_index=${2}    cell_type=nr
    Set qRxLevMin For pointed NR cell    cell_id_list=${cell_list_nr}    value_call=${-25}
    log to console   make L3 call for NR cell 2
    Set PA Value For Pointed Port    PA_Port_List=${A5B5_A8B8_RU2_UE2}    value=${10}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_2}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_NR_LTE}    cell_id=${nr_cell_2}
    ...    duration=${300}    target_avg_percent=0.5    min_percent=0.3
    Set PA Value For Pointed Port    PA_Port_List=${A5B5_A8B8_RU2_UE2}    value=${63}
    ${cell_list_lte}    Get All Cell Id    ru_index=${2}    cell_type=lte
    Set qRxLevMin For pointed LTE cell    cell_id_list=${cell_list_lte}   value_call=${-44}
    log to console   make L3 call for LTE cell 8
    Set PA Value For Pointed Port    PA_Port_List=${A5B1_A8B4_RU2_UE1}    value=${0}
    Set qRxLevMin For pointed LTE cell   cell_id_list=${lte_cell_8}    value_call=${-140}
    4G L3 call check    target_avg_percent=0.5    4G_duration=${300}    ue_index=${0}
    Set PA Value For Pointed Port    PA_Port_List=${A5B1_A8B4_RU2_UE1}    value=${63}


Make L3 call for NR LTE concurrent mode for NRcell3 and LTEcell9
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    ...    exp_pa_value=${63}
    ${cell_list_nr}    Get All Cell Id    ru_index=${3}    cell_type=nr
    Set qRxLevMin For pointed NR cell    cell_id_list=${cell_list_nr}    value_call=${-25}
    log to console   make L3 call for NR cell 3
    Set PA Value For Pointed Port    PA_Port_List=${A9B5_A12B8_RU3_UE2}    value=${10}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_3}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_NR_LTE}    cell_id=${nr_cell_3}
    ...    duration=${300}    target_avg_percent=0.5    min_percent=0.3
    Set PA Value For Pointed Port    PA_Port_List=${A9B5_A12B8_RU3_UE2}    value=${63}
    ${cell_list_lte}    Get All Cell Id    ru_index=${3}    cell_type=lte
    Set qRxLevMin For pointed LTE cell    cell_id_list=${cell_list_lte}   value_call=${-44}
    log to console   make L3 call for LTE cell 9
    Set PA Value For Pointed Port    PA_Port_List=${A9B1_A12B4_RU3_UE1}    value=${0}
    Set qRxLevMin For pointed LTE cell   cell_id_list=${lte_cell_9}    value_call=${-140}
    4G L3 call check    target_avg_percent=0.5    4G_duration=${300}    ue_index=${0}
    Set PA Value For Pointed Port    PA_Port_List=${A9B1_A12B4_RU3_UE1}    value=${63}


4G L3 call check
    [Arguments]    ${target_avg_percent}     ${min_percent}=0.3    ${4G_duration}=${600}    ${ue_index}=${0}
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${exp_dl_LTE}    throughput_ul=${exp_ul_LTE}
    ...    duration_call=${1200}    ue_index=${ue_index}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}
    ...    target_throughput_dl=${target_dl_LTE}
    ...    target_throughput_ul=${target_ul_LTE}    ue_index=${ue_index}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}     duration=${4G_duration}
    ...    stop_cpe=True    ignore_time=${60}
    [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type_4G}    ue_index=${ue_index}


CB010475_SR_B_NR-LTE_Concurrent_BBMOD_reset_from_GUI
    Selenium Login And Disable Screen Lock
    log to console    reset 2 BBmod
    ${bbmod_index_list}  Get All BBmod Index
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        selenium_coam.reset_baseband    baseband_index=${bbmod_index}    timeout=30
        Wait Until Keyword Succeeds    5min    5s    bbmod Should Be Offline    bbmod_index=${bbmod_index}
    END
    Wait Until Keyword Succeeds    10 min    120 sec    Verify all cells should be onair    cell_type=nr
    Wait Until Keyword Succeeds    10 min    120 sec    Verify all cells should be onair    cell_type=lte
    Make L3 call for NR LTE concurrent mode for NRcell1 and LTEcell7
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_RU_lock_unlock
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Create file in RU to check reboot    ru_index=${ru_index}
        selenium_coam.lock_ru  ru_index=${ru_index}
        Sleep   10 sec
        log to console    check Administrative state for radio unit MO is set to Locked,Operational state remains as Enabled
        run keyword and continue on failure    RU Should Be Locked    ru_index=${ru_index}
        selenium_coam.unlock_ru  ru_index=${ru_index}
        Sleep   10 sec
        log to console    check Administrative state for radio unit MO is set to Unlocked
        RU Should Be Unlocked    ru_index=${ru_index}
        Wait Until Keyword Succeeds    5 min    60 sec    Verify all cells should be onair    cell_type=nr
        Wait Until Keyword Succeeds    5 min    60 sec    Verify all cells should be onair    cell_type=lte
        Check file should still Exist in RU    ru_index=${ru_index}
    END
    Make L3 call for NR LTE concurrent mode for NRcell2 and LTEcell8
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_Cell_block_and_unblock
    Selenium Login And Disable Screen Lock
    Get X2 link shutdown waiting time
    ${cell_list_nr}    Get All Cell Id    cell_type=nr
    run keyword and continue on failure    Block cells and check status    block_list=${cell_list_nr}
    ...    check_alarm=${False}    gnb_type=${gNb_CuType}
    UnBlock cells and check status    block_list=${cell_list_nr}    check_alarm=${False}    gnb_type=${gNb_CuType}
    ${cell_list_lte}    Get All Cell Id    cell_type=lte
    run keyword and continue on failure    Block cells and check status    block_list=${cell_list_lte}
    ...    check_alarm=${False}    gnb_type=${gNb_CuType}    technology=LTE
    UnBlock cells and check status    block_list=${cell_list_lte}    check_alarm=${False}    gnb_type=${gNb_CuType}
    ...    technology=LTE
    Make L3 call for NR LTE concurrent mode for NRcell3 and LTEcell9
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_E2E_system_setup_with_data_transfer_conducted_NR30+40MHz_LTE20+20+20+20MHz
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    ...    exp_pa_value=${63}
    Selenium Login And Disable Screen Lock
    ${cell_list_nr}    Get All Cell Id    ru_index=${1}    cell_type=nr
    ${cell_list_lte}    Get All Cell Id    ru_index=${1}    cell_type=lte
    Set qRxLevMin For pointed NR cell    cell_id_list=${cell_list_nr}    value_call=${-25}
    Set qRxLevMin For pointed LTE cell    cell_id_list=${cell_list_lte}   value_call=${-44}
    Set PA Value For Pointed Port    PA_Port_List=${A1B5_A4B8_RU1_UE2}    value=${10}
    log to console    make L3 call peak for NR cell 1
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_1}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_NR_LTE}    cell_id=${nr_cell_1}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_1}    value_call=${-25}
#    log to console    make L3 call peak for NR cell 4
#    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_4}    value_call=${-40}
#    data_transfer_common    tput_self_define=${tput_NR_LTE}    cell_id=${nr_cell_4}
    Set PA Value For Pointed Port    PA_Port_List=${A1B5_A4B8_RU1_UE2}    value=${63}
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE1}    value=${0}
    log to console    make L3 call peak LTE cell 7
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_7}   value_call=${-140}
    4G L3 call check    4G_duration=${600}    ue_index=${0}    target_avg_percent=0.98    min_percent=0.3
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_7}   value_call=${-44}
    log to console    make L3 call peak LTE cell 10
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_10}   value_call=${-140}
    4G L3 call check    4G_duration=${300}    ue_index=${0}    target_avg_percent=0.98    min_percent=0.3
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_10}   value_call=${-44}
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE1}    value=${63}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


CB010475_SR_B_NR-LTE_Concurrent_Cell online add delete NR cell
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
        Online Cell addition deletion     addition_deletion_cell=${cell_id_ru[0]}
    END
    Make L3 call for NR LTE concurrent mode for NRcell1 and LTEcell7
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


CB010475_SR_B_NR-LTE_Concurrent_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    FOR    ${index}    IN RANGE    ${20}
        log to console    reset bts for time:${index}
        Connect to gnb coam via ssl
        coam.reset_site   connection=GNB_OAM
        sleep    120s
        log to console    check bts status
        Wait Until Keyword Succeeds    15 min    60 sec    Check all cells info should be onair
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
        csn.reset_cache
    END
    [Teardown]    run keyword and ignore error   COAM Teardown gnb connections


CB010475_SR_B_NR-LTE_Concurrent_Manual_SiSo_SM_NR_RAT_reset
    Selenium Login And Disable Screen Lock
    log to console    nr rat reset
    selenium_coam.reset_nr
    log to console    Checking states during reset: –operationalState = disabled
    Wait Until Keyword Succeeds    5 min    10 sec    check cell operational status
    ...    cell_type=nr    operationalState=disabled
    Wait Until Keyword Succeeds    10 min    60 sec    Verify all cells should be onair    cell_type=nr
    Wait Until Keyword Succeeds    10 min    60 sec    Verify all cells should be onair    cell_type=lte
    Make L3 call for NR LTE concurrent mode for NRcell2 and LTEcell8
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


CB010475_SR_B_NR-LTE_Concurrent_Manual_SiSo_SM_LTE_RAT_reset
    Selenium Login And Disable Screen Lock
    log to console    lte rat reset
    selenium_coam.reset_lte
    log to console    Checking states during reset: –operationalState = disabled
    Wait Until Keyword Succeeds    5 min    10 sec   check cell operational status
    ...    cell_type=lte    operationalState=disabled
    Wait Until Keyword Succeeds    10 min    60 sec    Verify all cells should be onair    cell_type=lte
    Wait Until Keyword Succeeds    10 min    60 sec    Verify all cells should be onair    cell_type=nr
    Make L3 call for NR LTE concurrent mode for NRcell3 and LTEcell9
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


CB010475_SR_B_NR-LTE_Concurrent_General_SiSo_RAT_Block_Unblock_with_L3Call
    [Arguments]    ${connection}=GNB_OAM
    Selenium Login And Disable Screen Lock
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Create file in RU to check reboot    ru_index=${ru_index}
    END
    log to console    block/unblock nr rat and make L3 call on LTE cell
    coam.block_rat    rat=NR     timeout=600    connection=${connection}
    Wait For Expect Fault Present    faultId=4614    timeout=300
    ${cell_list_nr}    Get All Cell Id    cell_type=nr
    FOR  ${cell_index}  IN  @{cell_list_nr}
        check single cell should be blocked    cell_type=nr
    END
    Make L3 call for NR LTE concurrent mode for LTEcell7
    coam.unblock_rat    rat=NR     timeout=600    connection=${connection}
    Wait For Expect Fault To Disappear    faultId=4614    timeout=300
    Wait Until Keyword Succeeds    10 min    60 sec    Verify all cells should be onair    cell_type=nr
    log to console    block/unblock lte rat and make L3 call on nr cell
    coam.block_rat    rat=LTE     timeout=600    connection=${connection}
    Wait For Expect Fault Present    faultId=4614    timeout=300
    ${cell_list_lte}    Get All Cell Id    cell_type=lte
    FOR  ${cell_index}  IN  @{cell_list_lte}
        check single cell should be blocked    cell_type=lte
    END
    Make L3 call for NR LTE concurrent mode for NRcell1
    coam.unblock_rat    rat=LTE     timeout=600    connection=${connection}
    Wait For Expect Fault To Disappear    faultId=4614    timeout=300
    Wait Until Keyword Succeeds    10 min    60 sec    Verify all cells should be onair    cell_type=lte
    FOR  ${ru_index}  IN  @{ru_index_list}
        Check file should still Exist in RU    ru_index=${ru_index}
    END
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


import scf
    [Arguments]    ${scf_name}=nr_only
    ${cell_list_nr}    Get All Cell Id    ru_index=${1}    cell_type=nr
    ${flag}    Check_scf_cell_match    scf_name=${scf_name}    cell_list_nr=${cell_list_nr}
    run keyword if  ${flag} == 0    Commission scf    scf_name=${scf_name}


Commission scf
    [Arguments]    ${scf_name}=nr_only
    log to console    import scf of ${scf_name}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _${scf_name}.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}


check cell operational status
    [Arguments]    ${cell_type}=nr    ${operationalState}=disabled    ${connection}=GNB_OAM
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${connection}
    FOR    ${item}    IN    @{cell_status}
        ${Status}    Get From Dictionary    ${item}    status
        ${tmp}   Get From Dictionary    ${status}    operationalState
        should be equal as strings    ${tmp}    ${operationalState}    ignore_case=${True}
    END


Create file in RU to check reboot
    [Arguments]    ${log_name}=123.txt    ${ru_index}=1    ${connection}=GNB_OAM    ${gnb_index}=${0}    ${asik_alias}=ASIK Master
    connection_alias_store.Connect to Common Unit Master    gnb_index=${gnb_index}    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}   asik_alias=${asik_alias}
    ...      connection=${connection}
    ...       ru_username=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...       ru_password=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    csn.execute     cd /tmp;${sudo} touch ${log_name}    connection=RU_${ru_index}
    sleep  2
    ${output}    csn.execute    command=${sudo} ls -l /tmp/${log_name}    connection=RU_${ru_index}
    sleep  2
    log    ${output}
    Should Not Contain      ${output}      No such file or directory
    [Return]  run keywords  csn.disconnect   connection=RU_${ru_index}


Check file should still Exist in RU
    [Arguments]    ${log_name}=123.txt    ${ru_index}=1    ${connection}=GNB_OAM    ${gnb_index}=${0}    ${asik_alias}=ASIK Master
    connection_alias_store.Connect to Common Unit Master   gnb_index=${gnb_index}    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}  connection=${connection}
    ...       asik_alias=${asik_alias}
    ...       ru_username=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...       ru_password=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${output}    csn.execute    command=${sudo} ls -l /tmp/${log_name}    connection=RU_${ru_index}
    sleep  2
    log to console    ${output}
    Should Not Contain      ${output}      No such file or directory
    [Return]  run keywords  csn.disconnect   connection=RU_${ru_index}


Set qRxLevMin For cells under ru
    [Arguments]    ${mrbtsId}=${1908}    ${nrBtsId}=${10557}    ${ru_index}=1    ${connection}=GNB_OAM
    ...    ${value}=${-25}
    log to console    start to set qrxlevmin
    ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
    FOR  ${cell_id}  IN  @{cell_id_ru}
        wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrBtsId}/NRCELL-${cell_id}    parameter=qRxLevMin    value=${value}
        ...    operation=update    connection=${connection}
        Sleep    10s
    END


Set qRxLevMin For pointed NR cell
    [Arguments]    ${cell_id_list}    ${mrbtsId}=${1908}    ${nrBtsId}=${10557}    ${connection}=GNB_OAM
    ...    ${value_call}=${-40}
    log to console    start to set NR cell qrxlevmin
    FOR  ${cell_id_call}  IN  @{cell_id_list}
        wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrBtsId}/NRCELL-${cell_id_call}    parameter=qRxLevMin
        ...    value=${value_call}    operation=update    connection=${connection}
        sleep    10s
    END


Set qRxLevMin For pointed LTE cell
    [Arguments]    ${cell_id_list}    ${mrbtsId}=${1908}    ${lnBtsId}=${1908}    ${connection}=GNB_OAM
    ...    ${value_call}=${-140}
    log to console    start to set LTE cell qrxlevmin
    FOR  ${cell_id_call}  IN  @{cell_id_list}
        wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/LNBTS-${lnBtsId}/LNCEL-${cell_id_call}/SIB-0    parameter=qrxlevmin
        ...    value=${value_call}    operation=update    connection=${connection}
        sleep    10s
    END
