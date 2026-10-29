*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CBRS/CB010475/Resources/CB010475_common_keywords.robot
#Resource    ../../resources/cbrs_common_keywords.robot
#Library     CB010475.py
#Variables    ../TestData/10475_variables.py

Documentation    This is for SG8 common keywords
...              Author: linjiangjing
...              Squard: HZ SG8

*** Variables ***
${CB010295_LTE_conf}    ${conf_path}/lte.conf
${0_6_10M_DL}    150
${0_6_10M_UL}    50
${target_0_6_10M_DL}    56.09
${target_0_6_10M_UL}    19.07
${0_7_20M_DL}    300
${0_7_20M_UL}    60
${target_0_7_20M_DL}    123.4
${target_0_7_20M_UL}    40.47
${CB010295_json_path}    ${CURDIR}/json
${frame0_6_ru1}    ${CB010295_json_path}/frame0_6_ru1.json
${frame0_6_ru2}    ${CB010295_json_path}/frame0_6_ru2.json
${frame0_6_ru3}    ${CB010295_json_path}/frame0_6_ru3.json
${frame1_7_ru1}    ${CB010295_json_path}/frame1_7_ru1.json
${frame1_7_ru2}    ${CB010295_json_path}/frame1_7_ru2.json
${frame1_7_ru3}    ${CB010295_json_path}/frame1_7_ru3.json
${prachindex4}     ${CB010295_json_path}/prachindex4.json
${10M_chbw}    ${CB010295_json_path}/10M_chbw.json
*** Keywords ***
CB010295 LTE TL CBRS Suite Setup
    LTE TL CBRS Suite Setup
    run keyword and ignore error    Simply_reboot_ue


CB010295 4G L3 call check
    [Arguments]    ${target_avg_percent}    ${throughput_dl}    ${throughput_ul}    ${target_throughput_dl}
    ...    ${target_throughput_ul}    ${4G_duration}=${660}    ${ue_index}=${0}    ${min_percent}=0.3
    make_call_4G    ue_type_4G=${ue_type_4G}    throughput_dl=${throughput_dl}
    ...    throughput_ul=${throughput_ul}     duration_call=${1200}    ue_index=${ue_index}
    check_tput_for_4G_call    ue_type_4G=${ue_type_4G}
    ...    target_throughput_dl=${target_throughput_dl}
    ...    target_throughput_ul=${target_throughput_ul}    ue_index=${ue_index}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    duration=${4G_duration}
    ...    stop_cpe=True    ignore_time=${60}
    [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type_4G}    ue_index=${ue_index}


CB010295 Make L3 call for LTE cell7
    [Arguments]    ${tput_dl}    ${tput_ul}    ${target_tput_dl}    ${target_tput_ul}
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    ...    exp_pa_value=${63}
    ${cell_list_lte}    Get All Cell Id    ru_index=${1}    cell_type=lte
    Set qRxLevMin For pointed LTE cell    cell_id_list=${cell_list_lte}   value_call=${-44}
    log to console   make L3 call for LTE cell 7
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE1}    value=${0}
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_7}   value_call=${-140}
    CB010295 4G L3 call check    target_avg_percent=0.98    4G_duration=${600}    ue_index=${0}
    ...    throughput_dl=${tput_dl}    throughput_ul=${tput_ul}   target_throughput_dl=${target_tput_dl}
    ...    target_throughput_ul=${target_tput_ul}
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_7}   value_call=${-44}
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE1}    value=${63}


CB010295 Make L3 call for LTE cell8
    [Arguments]    ${tput_dl}    ${tput_ul}    ${target_tput_dl}    ${target_tput_ul}
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    ...    exp_pa_value=${63}
    ${cell_list_lte}    Get All Cell Id    ru_index=${2}    cell_type=lte
    Set qRxLevMin For pointed LTE cell    cell_id_list=${cell_list_lte}   value_call=${-44}
    log to console   make L3 call for LTE cell 8
    Set PA Value For Pointed Port    PA_Port_List=${A5B1_A8B4_RU2_UE1}    value=${0}
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_8}   value_call=${-140}
    CB010295 4G L3 call check    target_avg_percent=0.98    4G_duration=${300}    ue_index=${0}
    ...    throughput_dl=${tput_dl}    throughput_ul=${tput_ul}   target_throughput_dl=${target_tput_dl}
    ...    target_throughput_ul=${target_tput_ul}
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_8}   value_call=${-44}
    Set PA Value For Pointed Port    PA_Port_List=${A5B1_A8B4_RU2_UE1}    value=${63}


CB010295 Make L3 call for LTE cell9
    [Arguments]    ${tput_dl}    ${tput_ul}    ${target_tput_dl}    ${target_tput_ul}
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
    ...    exp_pa_value=${63}
    ${cell_list_lte}    Get All Cell Id    ru_index=${3}    cell_type=lte
    Set qRxLevMin For pointed LTE cell    cell_id_list=${cell_list_lte}   value_call=${-44}
    log to console   make L3 call for LTE cell 9
    Set PA Value For Pointed Port    PA_Port_List=${A9B1_A12B4_RU3_UE1}    value=${0}
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_9}   value_call=${-140}
    CB010295 4G L3 call check    target_avg_percent=0.98    4G_duration=${300}    ue_index=${0}
    ...    throughput_dl=${tput_dl}    throughput_ul=${tput_ul}   target_throughput_dl=${target_tput_dl}
    ...    target_throughput_ul=${target_tput_ul}
    Set qRxLevMin For pointed LTE cell    cell_id_list=${lte_cell_9}   value_call=${-44}
    Set PA Value For Pointed Port    PA_Port_List=${A9B1_A12B4_RU3_UE1}    value=${63}


CB010295 Start SAS server for LTE only
    Commission scf    scf_name=lte_only
    start SAS server    config_name=${CB010295_LTE_conf}
    Wait until keyword succeeds    10min    60s    verify all cells should be onair    cell_type=lte


Change prachindex to 4
    coam.perform_delta_recommissioning    delta_file=${prachindex4}    connection=GNB_OAM
    Wait Until Keyword Succeeds    10 min    60 sec    Verify all cells should be onair    cell_type=lte


CB010295_General_SiSo_RU_lock_and_unlock
    Change prachindex to 4
    Selenium Login And Disable Screen Lock
    ${ru_index_list}    Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        selenium_coam.lock_ru  ru_index=${ru_index}
        Sleep   10 sec
        log to console    check Administrative state for radio unit MO is set to Locked,Operational state remains as Enabled
        run keyword and continue on failure    RU Should Be Locked    ru_index=${ru_index}
        selenium_coam.unlock_ru  ru_index=${ru_index}
        Sleep   10 sec
        log to console    check Administrative state for radio unit MO is set to Unlocked
        RU Should Be Unlocked    ru_index=${ru_index}
        Wait Until Keyword Succeeds    5 min    60 sec    Verify all cells should be onair    cell_type=lte
    END
    CB010295 Make L3 call for LTE cell7    tput_dl=${0_7_20M_DL}    tput_ul=${0_7_20M_UL}
    ...    target_tput_dl=${target_0_7_20M_DL}    target_tput_ul=${target_0_7_20M_UL}
    CB010295 Make L3 call for LTE cell8    tput_dl=${0_7_20M_DL}    tput_ul=${0_7_20M_UL}
    ...    target_tput_dl=${target_0_7_20M_DL}    target_tput_ul=${target_0_7_20M_UL}
    CB010295 Make L3 call for LTE cell9    tput_dl=${0_7_20M_DL}    tput_ul=${0_7_20M_UL}
    ...    target_tput_dl=${target_0_7_20M_DL}    target_tput_ul=${target_0_7_20M_UL}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


CB010295_General_SiSo_Cell_block_and_unblock_with_L3call
    Selenium Login And Disable Screen Lock
    Set Test Variable    ${X2_link_shutdown_time}    2
    ${cell_list_lte}    Get All Cell Id    cell_type=lte
    run keyword and continue on failure    Block cells and check status    block_list=${cell_list_lte}
    ...    check_alarm=${False}    technology=LTE
    UnBlock cells and check status    block_list=${cell_list_lte}    check_alarm=${False}    technology=LTE
    CB010295 Make L3 call for LTE cell7    tput_dl=${0_7_20M_DL}    tput_ul=${0_7_20M_UL}
    ...    target_tput_dl=${target_0_7_20M_DL}    target_tput_ul=${target_0_7_20M_UL}
    CB010295 Make L3 call for LTE cell8    tput_dl=${0_7_20M_DL}    tput_ul=${0_7_20M_UL}
    ...    target_tput_dl=${target_0_7_20M_DL}    target_tput_ul=${target_0_7_20M_UL}
    CB010295 Make L3 call for LTE cell9    tput_dl=${0_7_20M_DL}    tput_ul=${0_7_20M_UL}
    ...    target_tput_dl=${target_0_7_20M_DL}    target_tput_ul=${target_0_7_20M_UL}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser


CB010295_General_SiSo_Online_Commissioning_From_Frame_1_7_To_0_6
    Change frame to 1_7 and chbw
    Change frame to 0_6 and prach
    CB010295 Make L3 call for LTE cell7    tput_dl=${0_6_10M_DL}    tput_ul=${0_6_10M_UL}
    ...    target_tput_dl=${target_0_6_10M_DL}    target_tput_ul=${target_0_6_10M_UL}
    CB010295 Make L3 call for LTE cell8    tput_dl=${0_6_10M_DL}    tput_ul=${0_6_10M_UL}
    ...    target_tput_dl=${target_0_6_10M_DL}    target_tput_ul=${target_0_6_10M_UL}
    CB010295 Make L3 call for LTE cell9    tput_dl=${0_6_10M_DL}    tput_ul=${0_6_10M_UL}
    ...    target_tput_dl=${target_0_6_10M_DL}    target_tput_ul=${target_0_6_10M_UL}


Change frame to 1_7 and chbw
    [Arguments]    ${connection}=GNB_OAM
    log to console    start to change frame to 1_7 and chbw
    coam.perform_delta_recommissioning    delta_file=${frame1_7_ru1}    connection=GNB_OAM
    sleep    60s
    coam.perform_delta_recommissioning    delta_file=${frame1_7_ru2}    connection=GNB_OAM
    sleep    60s
    coam.perform_delta_recommissioning    delta_file=${frame1_7_ru3}    connection=GNB_OAM
    sleep    60s
    Wait Until Keyword Succeeds    10 min    60 sec    Verify all cells should be onair    cell_type=lte
    coam.perform_delta_recommissioning    delta_file=${10M_chbw}    connection=GNB_OAM
    sleep    60s
    Wait Until Keyword Succeeds    10 min    120 sec    Verify all cells should be onair    cell_type=lte


Change frame to 0_6 and prach
    [Arguments]    ${connection}=GNB_OAM
    log to console    start to change frame to 0_6 and prach
    coam.perform_delta_recommissioning    delta_file=${frame0_6_ru1}    connection=GNB_OAM
    sleep    60s
    coam.perform_delta_recommissioning    delta_file=${frame0_6_ru2}    connection=GNB_OAM
    sleep    60s
    coam.perform_delta_recommissioning    delta_file=${frame0_6_ru3}    connection=GNB_OAM
    sleep    60s
    Wait Until Keyword Succeeds    10 min    120 sec    Verify all cells should be onair    cell_type=lte
