*** Settings ***
Documentation
...   author: Dandan Fang
...   contact: dandan.fang@nokia-sbell.com
...   squad group: SG_01
...   Feature CB013394 in SBTS26R1 program

*** Keywords ***
Do L3 Call and Traffic on Cells
    [Documentation]
    ...    *****************
    ...    Owner_dandan.fang@nokia-sbell.com
    ...    ${ru_type}:    use to match expected throughput on each CC which deployed on the radio,
    ...    ${cell_list}:  cell id used to test.
    ...    ${need_traffic_test}:    do ue attch only or also need to test traffic
    ...    ${data_transfer_direction}: if value as "unidir_then_bidir" means ul only first , then dl only first, then both
    ...    ******************
    [Arguments]    ${ru_type}    ${cell_list}
    ...     ${need_traffic_test}   ${connection}=GNB_OAM   ${data_transfer_direction}=both    ${peak_check}=${False}
    ...     ${need_stop}=${True}
    return from keyword if    '${ru_type}'=='AVQF'      #templory solution, avqf signal connect to shiftphase
    ${cell_list}      enb_lte.Convert data type to a list   input_data=${cell_list}
    FOR  ${cell_id}  IN  @{cell_list}
        log to console    \n***L3 Call on CellId ${cell_id} after Rmod ${ru_type} Unlock***
        Step : UE attach    cell_index=${cell_id}   connection=${connection}
        Run Keyword If  '${need_traffic_test}'=='${False}'
        ...    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}
        Continue For Loop If    '${need_traffic_test}'=='${False}'
        Decode and Set TP Variable for Cell Case Level   ru_type=${ru_type}   cell_id=${cell_id}
        run keyword if  '${data_transfer_direction}'=='unidir_then_bidir'
        ...       UL Only then DL Only then bi-direction Traffic Verify  cell_index=${cell_id}
        ...       ELSE       Step : start traffic and verify   cell_index=${cell_id}
        ...                       data_transfer_direction=${data_transfer_direction}  peak_check=${peak_check}  need_stop=${need_stop}
        run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}
    END
    [Teardown]  run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${0}

Do Attach With Or Without Traffic On Selected RU
    [Arguments]    ${ru_index_list}   ${need_traffic_test}  ${test_with_single_cc}
    ...       ${data_transfer_direction}=both     ${peak_check}=${False}
    Should Not Be Empty    ${ru_index_list}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_index}  Convert To Integer    ${ru_index}
        ${ru_type}    Get RU type     ru_index=${ru_index}
        ${cellIds_SpecificRu}    Get All Cell Id    ru_index=${ru_index}
        ${cells_present_on_ru}    Run Keyword And Return Status   Should Not Be Empty    ${cellIds_SpecificRu}
        Continue For Loop If    '${cells_present_on_ru}'=='${False}'
        ${cell_random_to_attach}   Evaluate    random.choice(${cellIds_SpecificRu})   modules=random
        ${cell_list}     Run Keyword If    '${test_with_single_cc}'=='${True}'
        ...      Create List     ${cell_random_to_attach}
        ...      ELSE
        ...      Set Variable       ${cellIds_SpecificRu}
        Adjust attenuator For L3 Call and Avoid Same Band Interference Due to Same Band    ru_used_for_l3=${ru_index}
        Do L3 Call and Traffic on Cells  ru_type=${ru_type}  cell_list=${cell_list}
        ...    need_traffic_test=${need_traffic_test}      peak_check=${peak_check}
        ...    data_transfer_direction=${data_transfer_direction}
    END

UL Only then DL Only then bi-direction Traffic Verify
    [Arguments]    ${cell_index}
    #ul only first
    Step : start traffic and verify   cell_index=${cell_index}      data_transfer_direction=ul  need_stop=${True}
    sleep    1min    reason=Need to wait some time before start DL traffic, otherwise DL layer will degrade.
    #stop ul and start dl only
    Step : start traffic and verify   cell_index=${cell_index}      data_transfer_direction=dl  need_stop=${False}
    #start ul traffic again check bi-direction
    Step : start traffic and verify   cell_index=${cell_index}      data_transfer_direction=ul  need_stop=${False}
    Stop data transfer based on direction    data_transfer_direction=both

Step : UE attach
    [Documentation]    Author: Cui Lingxue
    ...  come from CB009787
    [Arguments]    ${prepare_ue_needed}=${False}    ${connection}=GNB_OAM      ${cell_index}=1
    log to console    Step : UE attach
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${cell_index}    connection=${connection}
    Retry commercial ue attach if failed
    ...    prepare_ue_needed=${prepare_ue_needed}    4G_check=${False}   cell_id=${cell_index}   detach_request=${True}

Step : start traffic and verify
    [Arguments]  ${cell_index}  ${data_transfer_direction}=both
    ...    ${customized_log_name}=CC_${cell_index}_Traffic      ${need_stop}=${False}  ${peak_check}=${False}
    run keyword if  ${peak_check}        run keywords
    ...       Set Test Variable    ${DURATION_OF_TPUT_CHECK}         300s      AND
    ...       Set Test Variable    ${PERCENT_TARGET_AVG}    0.98      AND
    ...       Set Test Variable    ${PERCENT_TARGET_MIN}    0.9

    Set test variable    ${exp_ul}  ${EXP_UL_INDIV}
    Set test variable    ${exp_dl}  ${EXP_DL_INDIV}
    run keyword if  '${data_transfer_direction}'=='ul'
    ...          Set test variable    ${exp_dl}     1
    ...        ELSE IF    '${data_transfer_direction}'=='dl'
    ...          Set test variable    ${exp_ul}     1

    ${iperf_ul_tput}   Evaluate    str(${exp_ul}+20)
    ${iperf_dl_tput}   Evaluate    str(${exp_dl}+20)

    log to console    Step : start ${data_transfer_direction} traffic and verify on Cell ${cell_index}
    Start data transfer based on direction    data_transfer_direction=${data_transfer_direction}
    ...    ul_tput=${iperf_ul_tput}M    duration=${DURATION_OF_TRAFFIC}
    ...    dl_tput=${iperf_dl_tput}M
    ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    filter=L2Lo    check_source=Aasyslog
    run keyword and continue on failure    check tput via power ue optimized
    ...    cell_index=${cell_index}    direction=${data_transfer_direction}
    ...    tput_log_path=${tput_log_path}   exp_dl=${exp_dl}
    ...    exp_ul=${exp_ul}    target_avg_percent=${PERCENT_TARGET_AVG}    min_percent=${PERCENT_TARGET_MIN}
    ...    customized_log_name=${customized_log_name}_${data_transfer_direction}    actCarrierAggregation=${False}
    run keyword if  '${need_stop}'=='${True}'
    ...    Stop data transfer based on direction     data_transfer_direction=${data_transfer_direction}

Decode and Set TP Variable for Cell Case Level
    [Documentation]  Author: Fang Dandan
    ...    exp_cc_num_in_use: refers to 3CC/4CC/${None}, if set as 3CC or 4CC will return the input value directly,
    [Arguments]  ${ru_type}=AVQC   ${cell_id}=301
    Should Not Be Empty    ${RU_CELLS_INFO}
    ${ru_cc_info}     Get From Dictionary    ${RU_CELLS_INFO}    ${ru_type}
    Should Not Be Empty    ${ru_cc_info}
    Set test variable    ${EXP_DL_INDIV}       ${ru_cc_info[${cell_id}]['exp_dl_indiv']}
    Set test variable    ${EXP_UL_INDIV}       ${ru_cc_info[${cell_id}]['exp_ul_indiv']}
