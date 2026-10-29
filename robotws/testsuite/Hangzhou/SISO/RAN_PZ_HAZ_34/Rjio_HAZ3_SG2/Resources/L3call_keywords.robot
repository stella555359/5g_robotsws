*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
#Variables    ../TestData/Rjio_variables_haz3_sg2.py
Library    BuiltIn
Library    Collections
Library    taf.hw.rf_attenuator    WITH NAME    attenuator



Documentation
...    Author: Dong Tingting
...    Contact: tingting.dong@nokia-sbell.com
...    squad group: HAZ3_SG2
...    E2E Rjio

*** Variables ***

*** Keywords ***
Rjio_commission_scf
    [Arguments]    ${scf_suffix}=${.xml}    ${L3call}=${False}
    ${SCF_new}    Replace String    ${Golden_SCF_Path}    .xml    ${scf_suffix}
    Commissioning SCF And Check On Air    scf_path=${SCF_new}
    sleep    10s
#    run keyword if    ${L3call}    Rjio_CA_Call
#    [Teardown]    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}

#Rjio_CA_Call
#    Set_PA_Value    value=${20}    attenuator_index=${2}
#    sleep    300s
#    Prepare_UE_Only
#    L3call_Traffic_CA_CELL

L3call_Traffic_CELL_${GCI}
    ${GCI_key}    Convert To Integer    ${GCI}
    Run Keyword And Continue On Failure
    ...    data_transfer_KPI    tput_info=${tput_define_HO}    cell_id=${GCI_key}     duration_call=${1800}
    ...    target_avg_percent=${0.8}    min_percent=${0.7}    duration=${1200}    tput_from=self_define
    Run Keyword And Continue On Failure
    ...    collect_check_tput    duration=${20}    cell_id=${GCI_key}    target_avg_percent=${0.8}   min_percent=${0.7}
    Run Keyword And Continue On Failure
    ...    detach_UE_stop_traffic

L3call_Traffic_CA_CELL_${GCIP}_${GCIS}
    ${GCI_keyP}    Convert To Integer    ${GCIP}
    ${GCI_keyS}    Convert To Integer    ${GCIS}
    Run Keyword And Continue On Failure
    ...    data_transfer_KPI    tput_info=${tput_define}    cell_id=${GCI_keyP}     duration_call=${1800}
    ...    target_avg_percent=${0.8}    min_percent=${0.7}    duration=${1200}    tput_from=self_define
    Run Keyword And Continue On Failure
    ...    collect_check_tput    duration=${20}    cell_id=${GCI_keyP}    target_avg_percent=${0.8}    min_percent=${0.7}
    Run Keyword And Continue On Failure
    ...    collect_check_tput    duration=${20}    cell_id=${GCI_keyS}    target_avg_percent=${0.8}    min_percent=${0.7}
    ...    tput_info=${tput_define_Scell}
    Run Keyword And Continue On Failure
    ...    detach_UE_stop_traffic

not_first_L3call_Traffic_CELL_${GCI}
    ${GCI_key}    Convert To Integer    ${GCI}
    Run Keyword And Continue On Failure
    ...    data_transfer_KPI    tput_info=${tput_define_HO}    cell_id=${GCI_key}     duration_call=${1800}
    ...    target_avg_percent=${0.8}    min_percent=${0.7}    duration=${1200}    tput_from=self_define
    ...    ue_prepare=${False}
    Run Keyword And Continue On Failure
    ...    collect_check_tput    duration=${20}    cell_id=${GCI_key}    target_avg_percent=${0.8}   min_percent=${0.7}
    Run Keyword And Continue On Failure
    ...    detach_UE_stop_traffic

not_first_L3call_Traffic_CA_CELL_${GCIP}_${GCIS}
    ${GCI_keyP}    Convert To Integer    ${GCIP}
    ${GCI_keyS}    Convert To Integer    ${GCIS}
    Run Keyword And Continue On Failure
    ...    data_transfer_KPI    tput_info=${tput_define}    cell_id=${GCI_keyP}     duration_call=${1800}
    ...    target_avg_percent=${0.8}    min_percent=${0.7}    duration=${1200}    tput_from=self_define
    ...    ue_prepare=${False}
    Run Keyword And Continue On Failure
    ...    collect_check_tput    duration=${20}    cell_id=${GCI_keyP}    target_avg_percent=${0.8}    min_percent=${0.7}
    Run Keyword And Continue On Failure
    ...    collect_check_tput    duration=${20}    cell_id=${GCI_keyS}    target_avg_percent=${0.8}    min_percent=${0.7}
    ...    tput_info=${tput_define_Scell}
    Run Keyword And Continue On Failure
    ...    detach_UE_stop_traffic

detach_attach_CELL_${GCI}_for_${loopNum}_times
    [Documentation]
    ...    ********************************
    ...    GCI: Global cell ID
    FOR   ${index}   IN RANGE   0    ${loopNum}
        log to console    \n***the ${index} call***\n
        ${start_time}    DateTime.Get Current Date    result_format=timestamp
        log to console    \n***start_time：${start_time}***\n
        detach_attach_UE_repeat    tput_self_define=${tput_define}    cell_id=${GCI}    loop_times=${loopNum}
        ${end_time}    DateTime.Get Current Date    result_format=timestamp
        log to console    \n***end_time：${end_time}***\n
        ${elapsed_time}    DateTime.Subtract Date From Date    ${end_time}    ${start_time}
        log to console    \n***elapsed_time:${elapsed_time}***\n
    END

Set_PA_Value
    [Arguments]    ${value}    ${attenuator_index}=${0}
    ${ports_info}    set variable    ${tl.attenuators[${attenuator_index}].attenuator_ports}
    ${ports}    Get Dictionary Keys    ${ports_info}
    ${PA}    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_index}]}    alias=PA_alias
    FOR    ${port}    IN    @{ports}
        attenuator.set_attenuation    port=${port}    value=${value}    confirm=True    attenuator_device=${PA}
    END


detach_attach_UE_repeat
    [Arguments]    ${tput_self_define}    ${ru_index}=${None}    ${cell_id}=${None}
    ...    ${gnb_index}=0    ${du_index}=0    ${loop_times}=${2}    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ${cell_list}    run keyword if    ${cell_id}!=${None}    Create List    ${cell_id}
    ...    ELSE    Get All Cell Id    ru_index=${ru_index}
    FOR  ${i}  IN RANGE  ${loop_times}
        ${status}    run keyword and return status    RJIO_attach_detach_UE_cells    tput_info=${tput_self_define}
        ...    cell_list=${cell_list}
        ...    gnb_index=${gnb_index}    du_index=${du_index}
        ...    alias=${alias}    connection=${connection}
        exit for loop if    ${status}==${False}
    END
    run keyword if      not ${status}    FAIL

RJIO_attach_detach_UE_cells
    [Arguments]    ${tput_info}    ${cell_list}    ${gnb_index}=0    ${du_index}=0
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ${tput_info_total}    create dictionary
    FOR  ${cell_index}  IN  @{cell_list}
        ${ue_index}    set variable    ${tput_info[${cell_index}]['ue_index']}
        log to console    \n***use ue${ue_index} to make call on cell${cell_index}***\n
        attch_detach_UE   ue_index=${ue_index}
        ...    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}    connection=${connection}
    END

attch_detach_UE
    [Arguments]   ${ue_index}=0    ${gnb_index}=0    ${du_index}=0    ${alias}=ASIK MASTER    ${connection}=GNB_OAM
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword and ignore error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    #${cell_id}    get_ue_attached_cell_id    ue_index=${ue_index}    alias=${alias}    connection=${connection}
    #log to console    \n***ue attached to cell ${cell_id}***\n
    run keyword and ignore error    power_ue.verify attach    ue_type=${ue_type}  ue_index=${ue_index}    4G_check=False
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

Prepare_UE_Only
    log to console    \n***Prepare_UE_Only***\n
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}

data_transfer_KPI
    [Arguments]    ${tput_info}    ${ru_index}=${None}    ${cell_id}=${None}    ${target_avg_percent}=${None}    ${min_percent}=${None}
    ...    ${protocol}=udp    ${duration}=${600}    ${gnb_index}=0    ${du_index}=0    ${tput_from}=tool
    ...    ${alias}=ASIK MASTER    ${connection}=GNB_OAM    ${duration_call}=${1800}   ${ue_index}=${0}    ${ue_prepare}=${False}
    ${avg_expect_rate}    Run Keyword If    ${target_avg_percent}==${None}    get_avg_expect_rate    ELSE
    ...    set variable    ${target_avg_percent}
    ${min_expect_rate}    Run keyword If    ${min_percent}==${None}    get_min_expect_rate    ELSE
    ...    set variable    ${min_percent}
    ${tput_info_total}    create dictionary
    log to console    \n***use ue${ue_index} to make call on cell${cell_id}
    ${tput_cell}    run keyword if    '${tput_from}'=='tool'    get_tput_info_by_tool
    ...    cell_id=${cell_id}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    duration=${duration}    connection=${connection}    ELSE    set variable    ${tput_info[${cell_id}]}
    log to console    \n***tput info for cell ${cell_id} is: ${tput_cell}***\n
    set to dictionary    ${tput_info_total}    ${cell_id}    ${tput_cell}
    Set Suite Variable    ${tput_info_total}
    ${tput_info}   set variable    ${tput_cell}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    run keyword if    ${ue_prepare}    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    run keyword if    '${ue_type}'=='huawei_sigspark'   prepare_aasyslog_process_RJIO    gnb_index=${gnb_index}    du_index=${du_index}
    csn.reset_cache
	power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=5G_${gNb_CuType}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    ${dl_tp}    set variable    ${tput_info['dl_tp']}
    ${ul_tp}    set variable    ${tput_info['ul_tp']}
    ${tput_spark}    run keyword if    '${ue_type}'=='huawei_sigspark'    generate_tput_for_spark_ue    dl_tp=${dl_tp}    ul_tp=${ul_tp}
    ${dl_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable     ${tput_spark[0]}   ELSE    set variable   ${dl_tp}
    ${ul_tp}    run keyword if    '${ue_type}'=='huawei_sigspark'    set variable    ${tput_spark[1]}    ELSE    set variable   ${ul_tp}
    ${process_num}    set variable if      '${protocol}'=='udp'    ${1}    ${16}
    log to console    \n***start dl traffic...***\n
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    process_num=${process_num}    ue_mode=${gNb_CuType}
    log to console    \n***start ul traffic...***\n
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}
    ...    protocol=${protocol}    duration=${duration_call}    ue_index=${ue_index}    iperf_type=${iperf_type}
    ...    data_amount=2M    ue_mode=${gNb_CuType}

collect_check_tput
    [Arguments]    ${duration}=${1200}    ${cell_id}=1    ${ue_index}=0    ${connection}=GNB_OAM
    ...    ${target_avg_percent}=${0.9}    ${min_percent}=${0.85}    ${tput_info}=${tput_info_total}
    #${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    check_tput_for_each_cell    tput_info=${tput_info}    cell_id=${cell_id}    ue_index=${ue_index}    tput_log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    duration=${duration}    connection=${connection}

detach_UE_stop_traffic
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${iperf_type}  set variable if  '${ue_type}'=='huawei'    via_app    via_command
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    protocol=${protocol}
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_type=${iperf_type}    protocol=${protocol}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

prepare_aasyslog_process_RJIO
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
