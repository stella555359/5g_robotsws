*** Settings ***
Resource     ./CB007873_keywords.robot

Documentation
...   This is for 1390 and 7873 case level keywords.
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: MMW_SG1

*** Keywords ***
Basic_split_mode_flow_control
    [Arguments]    ${pcell_id}=${PCELL_ID}    ${scell_id}=${SCELL_ID}
    ${list_measurement_ids}    create list    M55310C05007    M55310C01007    M55310C03007

    Set PCell primaryPathMaxQueueingDelay=10 and SCell secondaryPathMaxQueueingDelay=0

    log    L3call and verify scell activation
#    UE attach to FDD cell and verify CA    tcpdump_log_name=l3_call_scell_pathDelay_0
#    run keyword and continue on failure    Start UL data transfer and verify no Scell is activated    duration=1200s
#    run keyword and continue on failure    Start DL data transfer and verify Scell is activated    duration=1200s
#    ${tput_info_cell_p10_s0}    run keyword and continue on failure    Check Tput info for each cell    dl_cell_id=${pcell_id},${scell_id}
#    ...    exp_dl=150,0    ul_cell_id=${pcell_id},${scell_id}    exp_ul=50,0    tput_duration=60s
    ${tput_info_cell_p10_s0}     run keyword and continue on failure    CA_basic_L3_call    dl_cell_id=${pcell_id},${scell_id}     exp_dl=150,0
    ...    ul_cell_id=${pcell_id},${scell_id}     exp_ul=50,0    duration=1200s

    log    Download PM files and verify counter values
    Wait for next PM counter file is generated    reporting_interval=5
    ${case_start_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}

    ${cell_check_list}    create list     ${pcell_id}    ${scell_id}
    ${dict_measurements_value}    counter.get_cell_counters_from_file    file_path=${pm_files_local_path[0]}    list_cell=${cell_check_list}
    ...    list_measurement_ids=${list_measurement_ids}

    run keyword and continue on failure    check M55310C05007 M55310C01007 M55310C03007 counter should be success
    ...    pcell_id=${pcell_id}    scell_id=${scell_id}    dict_measurements_value=${dict_measurements_value}
    ...    tput_info_cell=${tput_info_cell_p10_s0}    pcell_primaryPathMaxQueueingDelay=10    scell_secondaryPathMaxQueueingDelay=0

    ### verify counter value, primary path delay should be larger than secondary, throughput counter should have value.
    Stop data transfer and detach UE

    Set PCell primaryPathMaxQueueingDelay=0 and SCell secondaryPathMaxQueueingDelay=10
    ${tput_info_cell_p0_s10}    run keyword and continue on failure    CA_basic_L3_call    dl_cell_id=${pcell_id},${scell_id}     exp_dl=0,380
    ...    ul_cell_id=${pcell_id},${scell_id}     exp_ul=50,0    duration=1200s
    Wait for next PM counter file is generated    reporting_interval=5
    ${case_start_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${case_start_time_info['log_generator_timestamp']}

    ${dict_measurements_value}    counter.get_cell_counters_from_file    file_path=${pm_files_local_path[0]}    list_cell=${cell_check_list}
    ...    list_measurement_ids=${list_measurement_ids}
    run keyword and continue on failure    check M55310C05007 M55310C01007 M55310C03007 counter should be success
    ...    pcell_id=${pcell_id}    scell_id=${scell_id}    dict_measurements_value=${dict_measurements_value}
    ...    tput_info_cell=${tput_info_cell_p0_s10}    pcell_primaryPathMaxQueueingDelay=0    scell_secondaryPathMaxQueueingDelay=10
    ### verify counter value, primary path delay should be larger than secondary, throughput counter should have value.
    Stop data transfer and detach UE

check M55310C05007 M55310C01007 M55310C03007 counter should be success
    [Arguments]    ${pcell_id}    ${scell_id}    ${dict_measurements_value}    ${tput_info_cell}    ${miNrLowRlcReport}=5min
    ...    ${pcell_primaryPathMaxQueueingDelay}=10    ${scell_secondaryPathMaxQueueingDelay}=0    ${check_diff}=0.05
    ${pcell_M55310C05007}    set variable    ${dict_measurements_value['${pcell_id}']['M55310C05007']}
    ${pcell_M55310C01007}    set variable    ${dict_measurements_value['${pcell_id}']['M55310C01007']}
    ${pcell_M55310C03007}    set variable    ${dict_measurements_value['${pcell_id}']['M55310C03007']}

    ${scell_M55310C05007}    set variable    ${dict_measurements_value['${scell_id}']['M55310C05007']}
    ${scell_M55310C01007}    set variable    ${dict_measurements_value['${scell_id}']['M55310C01007']}
    ${scell_M55310C03007}    set variable    ${dict_measurements_value['${scell_id}']['M55310C03007']}

    ${pcell_dl_avg_tp}    set variable    ${tput_info_cell['${pcell_id}']['dl_avg_tput']}
    ${pcell_ul_avg_tp}    set variable    ${tput_info_cell['${pcell_id}']['ul_avg_tput']}

    ${scell_dl_avg_tp}    set variable    ${tput_info_cell['${scell_id}']['dl_avg_tput']}
    ${scell_ul_avg_tp}    set variable    ${tput_info_cell['${scell_id}']['ul_avg_tput']}

    ${pcell_dl_diff}    evaluate    ${pcell_dl_avg_tp}*${check_diff}
    ${pcell_ul_diff}    evaluate    ${pcell_ul_avg_tp}*${check_diff}

    ${scell_dl_diff}    evaluate    ${scell_dl_avg_tp}*${check_diff}
    ${scell_ul_diff}    evaluate    ${scell_ul_avg_tp}*${check_diff}

    ${pcell_dl_min_border}    evaluate    ${pcell_dl_avg_tp} - ${pcell_dl_diff}
    ${pcell_dl_max_border}    evaluate    ${pcell_dl_avg_tp} + ${pcell_dl_diff}
    ${pcell_ul_min_border}    evaluate    ${pcell_ul_avg_tp} - ${pcell_ul_diff}
    ${pcell_ul_max_border}    evaluate    ${pcell_ul_avg_tp} + ${pcell_ul_diff}

    ${scell_dl_min_border}    evaluate    ${scell_dl_avg_tp} - ${scell_dl_diff}
    ${scell_dl_max_border}    evaluate    ${scell_dl_avg_tp} + ${scell_dl_diff}
    ${scell_ul_min_border}    evaluate    ${scell_ul_avg_tp} - ${scell_ul_diff}
    ${scell_ul_max_border}    evaluate    ${scell_ul_avg_tp} + ${scell_ul_diff}


    ${min_time}    fetch from left    ${miNrLowRlcReport}    min
    ${counter_duration_sec}    evaluate    ${min_time}*60

    ${pcell_M55310C03007_tp}    evaluate  ${pcell_M55310C03007}*8/1024/1000/${counter_duration_sec}
    ${pcell_M55310C01007_tp}    evaluate  ${pcell_M55310C01007}*8/1024/1000/${counter_duration_sec}

    ${scell_M55310C03007_tp}    evaluate  ${scell_M55310C03007}*8/1024/1000/${counter_duration_sec}
    ${scell_M55310C01007_tp}    evaluate  ${scell_M55310C01007}*8/1024/1000/${counter_duration_sec}

    run keyword and continue on failure    run keyword if    '${scell_secondaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${pcell_ul_min_border} <= ${pcell_M55310C03007_tp} <= ${pcell_ul_max_border}

    run keyword and continue on failure    run keyword if    '${scell_secondaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${pcell_dl_min_border} <= ${pcell_M55310C01007_tp} <= ${pcell_dl_max_border}

    run keyword and continue on failure    run keyword if    '${scell_secondaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${pcell_M55310C05007} > ${0}

    run keyword and continue on failure    run keyword if    '${scell_secondaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${scell_M55310C03007_tp} == ${0}

    run keyword and continue on failure    run keyword if   '${scell_secondaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${scell_M55310C01007_tp} == ${0}

    run keyword and continue on failure    run keyword if    '${scell_secondaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${scell_M55310C05007} == ${0}


    run keyword and continue on failure    run keyword if   '${pcell_primaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${pcell_ul_min_border} <= ${pcell_M55310C03007_tp} <= ${pcell_ul_max_border}

    run keyword and continue on failure    run keyword if   '${pcell_primaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${pcell_M55310C01007_tp} == ${0}

    run keyword and continue on failure    run keyword if   '${pcell_primaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${pcell_M55310C05007} == ${0}

    run keyword and continue on failure    run keyword if    '${pcell_primaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${scell_M55310C03007_tp} == ${0}

    run keyword and continue on failure    run keyword if    '${pcell_primaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${scell_dl_min_border} <= ${scell_M55310C01007_tp} <= ${scell_dl_max_border}

    run keyword and continue on failure    run keyword if    '${pcell_primaryPathMaxQueueingDelay}'=='0'
    ...    should be true    ${scell_M55310C05007} > ${0}

Long_drx_in_CA_mode
    [Arguments]    ${is_drx_cycle_above_80ms}=${True}
    ${delta_file_list_reverse}    Disable cDRX via restapi
    set test variable    ${original_value}    ${delta_file_list_reverse}

    log to console    UE attach without CDRX
    UE attach to FDD cell and verify CA    tcpdump_log_name=attach01_wo_drx
    wait until keyword succeeds    1 min    10 sec    Connect to Common Unit Master    alias=ASIK Master
    Start Bip Capture for different program    bb_slot_1=true    bb_slot_2=false    add_mirror_port=true    backhaul_mirroring=true
    ${latency_wo_drx}    Perform DL ping and calculate latency    numberofping=${60}
    # TODO: adapt stop BIP capture on ASIB+ABIO+ABIL
    run keyword and ignore error    Stop Bip Capture and Collect logs for different program
    # memo: need to detach UE before gNB restart caused by modifying actProactUlScheduling
    Retry commercial ue detach if failed

    Connect to gnb coam via ssl
    Enable cDRX and configure DRX profile    is_drx_cycle_above_80ms=${is_drx_cycle_above_80ms}
    sleep    30s    msg=Wait for gNB stable to be attach after restart.

    log to console    UE attach with CDRX
    UE attach check CA and DRX    tcpdump_log_name=attach02_wi_drx
    Start data transfer based on direction    dl_tput=${DL_TPUT}     ul_tput=${UL_TPUT}    duration=600s
    ${latency_wi_drx_cont_trf}    Perform DL ping and calculate latency    numberofping=${60}
    run keyword and ignore error    Check Tput info for each cell    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL}
    ...    ul_cell_id=${PCELL_ID},${SCELL_ID}   exp_ul=${PCELL_EXP_UL},0
    Stop data transfer based on direction

    log to console    Start DL ping...
    wait until keyword succeeds    1 min    10 sec    Connect to Common Unit Master    alias=ASIK Master
    Start Bip Capture for different program    bb_slot_1=true    bb_slot_2=false    add_mirror_port=true    backhaul_mirroring=true
    ${latency_wi_drx_bursty_trf}    Perform DL ping and calculate latency    numberofping=${60}
    # TODO: adapt stop BIP capture on ASIB+ABIO+ABIL
    run keyword and ignore error     Stop Bip Capture and Collect logs for different program
    # memo: need to detach UE before gNB restart caused by modifying actProactUlScheduling
    Retry commercial ue detach if failed

    Verify ping latency within allowed range    ping_latency_wi_drx=${latency_wi_drx_bursty_trf}    ping_latency_wo_drx=${latency_wo_drx}
    ...    is_drx_cycle_above_80ms=${is_drx_cycle_above_80ms}
    [Teardown]    run keyword and ignore error    run keywords
    ...    Stop Bip Log Via Interface Mirroring Collector    AND
    ...    Connect to gnb coam via ssl    AND
    ...    Restore NIDD parameters to original value via restapi    delta_file_list_reverse=${original_value}
    ...    timeout=${TIMER_FOR_MODIFY_VIA_API}    AND
    ...    Wait until cluster is on cell on air status    timeout=${TIMER_FOR_MODIFY_VIA_API}
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    ...    is_need_to_setup_gnb_connection=${False}
