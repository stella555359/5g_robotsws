*** Settings ***
Library      ${CURDIR}/../TestData/overheat.py
Library      overheat.Overheat_operate    WITH NAME    Overheat

Documentation
...   This is template of automation testing
...   squad group: MMW_SG1

Resource          ./CA_keywords.robot

*** Keywords ***
CA_basic_L3_call
    [Documentation]     Author: Wang Yixiang
    ...    1. check CA in f1ap log
    ...    2. check CA counter
    ...    3. start traffic and check TPUT of pcell and scell including DL and UL
    ...    check_scell_activation only valid while sCellActivationMethod=bufferBased
    ...    ${wa_flag}/${4G_check} is no longer used
    [Arguments]     ${data_transfer_direction}=both     ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${duration}=${DURATION_OF_DATA_TRANSFER}
    ...    ${dl_cell_id}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=${PCELL_EXP_DL},${SCELL_EXP_DL}    ${ul_cell_id}=${PCELL_ID},${SCELL_ID}
    ...    ${exp_ul}=${PCELL_EXP_UL},0         ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${wa_flag}=${False}    ${check_counter}=${False}    ${scell_addition_method}=blind    ${check_scell_activation}=${False}
    ...    ${tcpdump_log_name}=basic_l3_call_CA    ${ue_index}=${0}   ${4G_check}=False   ${NSA_SA}=SA  ${window}=10M
    ...    ${ENB_Cellid}=${4}
    UE attach to Pcell and verify CA    ue_index=${ue_index}    tcpdump_log_name=${tcpdump_log_name}
    ...    scell_addition_method=${scell_addition_method}    check_counter=${check_counter}    NSA_SA=${NSA_SA}   ENB_Cellid=${ENB_Cellid}
    run keyword if    ${check_scell_activation}    Prepare and start aasyslog
    Start data transfer based on direction    dl_tput=${dl_tput}     ul_tput=${ul_tput}    window=${window}
    ...    duration=${duration}    data_transfer_direction=${data_transfer_direction}
    Sleep    ${sleep_time}    reason=Wait for traffic to be stable.
    run keyword if   ${check_scell_activation}    Run keyword and continue on failure
    ...    Stop aasyslog to check scell activation
    run keyword and ignore error    check iperf process on appserver
    ${tput_info_cell}    Check Tput info for each cell    dl_cell_id=${dl_cell_id}    exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}
    ...    exp_ul=${exp_ul}    tput_duration=${tput_duration}
    [Return]    ${tput_info_cell}

CA_L3_call_tput
    [Documentation]     Author: Wang Yixiang
    ...    compare with keyword "CA_basic_L3_call", this keyword check tput via power ue
    ...    1. check CA in f1ap log
    ...    2. check CA counter
    ...    3. start traffic and check TPUT of pcell and scell including DL and UL
    ...    check_scell_activation only valid while sCellActivationMethod=bufferBased
    ...    ${wa_flag}/${4G_check} is no longer used
    [Arguments]     ${data_transfer_direction}=both     ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${process_num}=${IPERF_PROCESS_NUM}    ${duration}=3000s
    ...    ${cell_id}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=${PCELL_EXP_DL},${SCELL_EXP_DL}    ${exp_ul}=${PCELL_EXP_UL},-1
    ...    ${tput_duration}=${DURATION_OF_TPUT_CHECK}
    ...    ${wa_flag}=${False}    ${check_counter}=${False}    ${scell_addition_method}=blind    ${check_scell_activation}=${False}
    ...    ${tcpdump_log_name}=basic_l3_call_CA    ${ue_index}=${0}   ${4G_check}=False    ${min_percent}=0.8
    ...    ${protocol}=udp    ${target_avg_percent}=0.95      ${window}=16M     ${buffer_size}=1400B    ${NSA_SA}=SA
    ...    ${seg_size}=1350    ${ENB_Cellid}=${4}    ${is_need_to_stop_traffic}=${False}    ${customized_log_name}=${None}
    ...    ${ignore_time}=1min
    UE attach to Pcell and verify CA    ue_index=${ue_index}    tcpdump_log_name=${tcpdump_log_name}
    ...    scell_addition_method=${scell_addition_method}    check_counter=${check_counter}    NSA_SA=${NSA_SA}   ENB_Cellid=${ENB_Cellid}
    run keyword if    ${check_scell_activation}    Prepare and start aasyslog
    Start data transfer based on direction    dl_tput=${dl_tput}     ul_tput=${ul_tput}    protocol=${protocol}    window=${window}
    ...    duration=${duration}    process_num=${process_num}   data_transfer_direction=${data_transfer_direction}
    ...    buffer_size=${buffer_size}    seg_size=${seg_size}
    run keyword if   ${check_scell_activation}    Run keyword and continue on failure
    ...    Stop aasyslog to check scell activation
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${tput_duration}    ignore_time=${ignore_time}    filter=L2Lo
    Check tput via power UE    cell_id=${cell_id}    exp_ul=${exp_ul}    exp_dl=${exp_dl}    log=${tput_log}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    customized_log_name=${customized_log_name}
    [Teardown]  Run keyword and ignore error    run keyword if    '${is_need_to_stop_traffic}'=='${True}'
    ...    Stop data transfer and detach UE    data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}
    [Return]  ${tput_log}

Basic_L3_call_No_CA
    [Documentation]    ${wa_flag}/${4G_check} is no longer used
    [Arguments]     ${data_transfer_direction}=both     ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${duration}=${DURATION_OF_DATA_TRANSFER}
    ...    ${dl_cell_id}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=${PCELL_EXP_DL},0
    ...    ${ul_cell_id}=${PCELL_ID},${SCELL_ID}     ${exp_ul}=${PCELL_EXP_UL},0
    ...    ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}   ${NSA_SA}=SA  ${ENB_Cellid}=${4}
    ...    ${tcpdump_log_name}=basic_l3_call_non-CA    ${wa_flag}=${False}    ${ue_index}=${0}   ${4G_check}=${False}
    ...    ${is_need_to_stop_traffic}=${False}
    UE attach to Pcell and verify NO CA    ue_index=${ue_index}    tcpdump_log_name=${tcpdump_log_name}
    ...   NSA_SA=${NSA_SA}    ENB_Cellid=${ENB_Cellid}
    Start data transfer based on direction   data_transfer_direction=${data_transfer_direction}
    ...    dl_tput=${dl_tput}     ul_tput=${ul_tput}    duration=${duration}
    Sleep    ${sleep_time}    reason=Wait for traffic to be stable.
    Check Tput info for each cell    dl_cell_id=${dl_cell_id}    exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}
    ...    exp_ul=${exp_ul}    tput_duration=${tput_duration}
    [Teardown]  Run keyword and ignore error    run keyword if    '${is_need_to_stop_traffic}'=='${True}'
    ...    Stop data transfer and detach UE    data_transfer_direction=${data_transfer_direction}    ue_index=${ue_index}

CA_basic_L3_call_bi_direction_and_single-direction_traffic
    [Documentation]     Author: Wang Yixiang
    ...    1. Attach UE check CA in f1ap log
    ...    2. start udp traffic(DL,UL) check TPUT of pcell and scell including DL and UL
    ...    3. Stop traffic and detach UE
    ...    4. Start udp traffic(DL) of bi-direction check TPUT of pcell and scell of DL traffic
    ...    5. Stop traffic and detach UE
    ...    6. Start udp traffic(UL) of bi-direction check TPUT of pcell and scell of UL traffic
    [Arguments]     ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${duration}=${DURATION_OF_DATA_TRANSFER}
    ...    ${dl_cell_id}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=${PCELL_EXP_DL},${SCELL_EXP_DL}
    ...    ${ul_cell_id}=${PCELL_ID}     ${exp_ul}=${PCELL_EXP_UL}
    ...    ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${wa_flag}=${False}   ${4G_check}=${False}
    log    start DL and UL udp traffic and check TPUT
    Run keyword and continue on failure  CA_basic_L3_call    dl_tput=${dl_tput}    ul_tput=${ul_tput}    duration=${duration}
    ...    dl_cell_id=${dl_cell_id}     exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}
    ...    exp_ul=${exp_ul}    sleep_time=${sleep_time}    tput_duration=${tput_duration}    wa_flag=${wa_flag}
    ...   4G_check=${4G_check}
    Stop data transfer and detach UE

    log   start DL udp traffic and check TPUT
    Run keyword and continue on failure   CA_basic_L3_call    dl_tput=${dl_tput}    ul_tput=${ul_tput}    duration=${duration}
    ...     dl_cell_id=${dl_cell_id}     exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}     exp_ul=0    sleep_time=${sleep_time}
    ...     data_transfer_direction=dl     tput_duration=${tput_duration}    wa_flag=${wa_flag}
    Stop data transfer and detach UE

    log   start UL udp traffic and check TPUT
    Run keyword and continue on failure   CA_basic_L3_call    dl_tput=${dl_tput}    ul_tput=${ul_tput}    duration=${duration}
    ...     dl_cell_id=${dl_cell_id}     exp_dl=0,0    ul_cell_id=${ul_cell_id}     exp_ul=${exp_ul}    sleep_time=${sleep_time}
    ...     data_transfer_direction=ul   tput_duration=${tput_duration}    wa_flag=${wa_flag}
    Stop data transfer and detach UE

#Remove_and_add_NRREL_check_data_transmission
#    [Documentation]     Author: Wang Yixiang
#    ...    1. Set 5GC002255 false without 5GC001390 and check PDL error
#    ...    2. Deactivate feature 5GC001390 by carrierAggregationSupportList to none
#    ...    3. Remove NRREL MO by rest api and wait onair
#    ...    4. Add NRREL MO and check tput not stop
#    ...    5. Deactivate feature 5GC001390 and 5GC002255 by rest api
#    ...    6. UE attach to FDD cell and verify NO CA
#    ...    7. UE attach to TDD cell and check NO CA
#    [Arguments]   ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}   ${4G_check}=${False}
#    ...     ${dl_cell_id}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=${PCELL_EXP_DL},${SCELL_EXP_DL}
#    ...     ${ul_cell_id}=${PCELL_ID}     ${exp_ul}=${PCELL_EXP_UL}
#    ...     ${check_counter}=${False}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
#    ...     ${tput_duration}=${DURATION_OF_TPUT_CHECK}     ${NSA_SA}=SA   ${ENB_Cellid}=${4}
#    run keyword and continue on failure  CA_basic_L3_call    tcpdump_log_name=l3call_ca  dl_tput=${dl_tput}    ul_tput=${ul_tput}
#    ...     dl_cell_id=${dl_cell_id}     exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}     exp_ul=${exp_ul}
#    ...     check_counter=${check_counter}    tput_duration=${tput_duration}    4G_check=${4G_check}
#    ...    NSA_SA=${NSA_SA}   ENB_Cellid=${ENB_Cellid}
#
#    Remove NRREL MO by rest api and wait onair and verify performance   NSA_SA=${NSA_SA}
#    run keyword and ignore error    Stop data transfer and detach UE
#    sleep    30s    # wait until cell full ready for ue attach success after reset or cell lock unlock
#
#    run keyword and ignore error    _WA_for_ssh_issue
#    run keyword and continue on failure  Basic_L3_call_No_CA    tcpdump_log_name=L3call_remove_NRREL   NSA_SA=${NSA_SA}
#    ...   ENB_Cellid=${ENB_Cellid}
#    Add NRREL MO by rest api and wait onair
#    run keyword and continue on failure  wait until keyword succeeds  3 times  1 sec  Data transmission only on PCell
#    run keyword and ignore error    Stop data transfer and detach UE
#    run keyword and ignore error    _WA_for_ssh_issue
#    run keyword and continue on failure  CA_basic_L3_call    tcpdump_log_name=L3call_add_NRREL   dl_tput=${dl_tput}    ul_tput=${ul_tput}
#    ...     dl_cell_id=${dl_cell_id}     exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}     exp_ul=${exp_ul}
#    ...     check_counter=${check_counter}    tput_duration=${tput_duration}
#    ...     NSA_SA=${NSA_SA}    ENB_Cellid=${ENB_Cellid}
#    run keyword and ignore error    Stop data transfer and detach UE
#    [Teardown]    Run keyword and ignore error    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}

#Check_PDL_error_and_check_data_transmission
#    [Documentation]     Author: Wang Yixiang
#    ...    1. Set 5GC001390 active without 5GC002255 and check PDL error
#    ...    2. Check data transmission on DL and UL
#    ...    3. Check data transmission on only DL
#    ...    4. Check data transmission on only UL
#    ...    5. UE attach to TDD cell and verify NO CA
#
#    [Arguments]    ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
#    ...     ${dl_cell_id}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=${PCELL_EXP_DL},${SCELL_EXP_DL}
#    ...     ${ul_cell_id}=${PCELL_ID}     ${exp_ul}=${PCELL_EXP_UL}
#    ...     ${wa_flag}=${False}    ${check_counter}=${True}
#    ...     ${tput_duration}=${DURATION_OF_TPUT_CHECK}   ${NSA_SA}=SA  ${4G_check}=${False}   ${ENB_Cellid}=${4}
#    Change status for parameter cellBarred on GNB    exp_status=notBarred
#    Set 5GC001390 active without 5GC002255 and check PDL error
#
#    Deactivate feature 5GC001390 and 5GC002255 by rest api
#    sleep    30s    # wait until cell full ready for ue attach success after reset or cell lock unlock
#    UE attach to TDD cell and verify NO CA    wa_flag=${True}  NSA_SA=${NSA_SA}  4G_check=${4G_check}
#    ...   ENB_Cellid=${ENB_Cellid}
#    run keyword and ignore error    Retry commercial ue detach if failed
#    UE attach to FDD cell and verify NO CA    wa_flag=${True}  NSA_SA=${NSA_SA}  4G_check=${4G_check}
#    ...    ENB_Cellid=${ENB_Cellid}
#    run keyword and ignore error    Retry commercial ue detach if failed
#    Change status for parameter cellBarred on GNB    exp_status=notBarred
#    Activate feature 5GC001390 and 5GC002255 by rest api
#    sleep    30s    # wait until cell full ready for ue attach success after reset or cell lock unlock
#    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}
#    run keyword and continue on failure  CA_basic_L3_call    tcpdump_log_name=act_l3_call   dl_tput=${dl_tput}    ul_tput=${ul_tput}
#    ...     dl_cell_id=${dl_cell_id}     exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}     exp_ul=${exp_ul}
#    ...     wa_flag=${wa_flag}    check_counter=${check_counter}    tput_duration=${tput_duration}  NSA_SA=${NSA_SA}  4G_check=${4G_check}
#    ...    ENB_Cellid=${ENB_Cellid}
#    run keyword if    '${PROGRAM}'=='21A'    run keyword and ignore error    Stop data transfer and detach UE
#    run keyword if    '${PROGRAM}'=='21A'    UE attach to TDD cell and verify NO CA    wa_flag=${True}   NSA_SA=${NSA_SA}
#    ...    ENB_Cellid=${ENB_Cellid}
#    [Teardown]    Run keyword and ignore error    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}

Single_UE_context_setup_in_SA_option2_with_inter-band_DL_CA_FDD_cell_as_Pcell_and_TDD_cell_as_Scell_with_beamforming_SA_CPRI
    [Documentation]    Author: Wang Yixiang
    ...    Step 1	Attach UE-1 to the FDD NR cell
    ...    Step 2	start UL/DL data transfer and check csi report on pusch
    [Arguments]     ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${duration}=${DURATION_OF_DATA_TRANSFER}
    ...    ${dl_cell_id}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=${PCELL_EXP_DL},${SCELL_EXP_DL}
    ...    ${ul_cell_id}=${PCELL_ID}     ${exp_ul}=${PCELL_EXP_UL}
    ...    ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${wa_flag}=${False}    ${tcpdump_log_name}=tcpdump_log_name

    log to console    UE attach and check TPUT
    CA_basic_L3_call    dl_tput=${dl_tput}    ul_tput=${ul_tput}    duration=${duration}
    ...    dl_cell_id=${dl_cell_id}     exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}
    ...    exp_ul=${exp_ul}    sleep_time=${sleep_time}    wa_flag=${wa_flag}    tput_duration=${tput_duration}
    ...    tcpdump_log_name=${tcpdump_log_name}

    log to console     Capture BIP and check CSI
    ${sleep_time}    set variable if    '${PROGRAM}'=='master'    100s    80s
    Bip Capture with gnbMirroring scripts with retry    bb_slot_1=true    bb_slot_2=true    filtering=on
    sleep   ${sleep_time}
    ${bip_log_pusch_list}   Stop BIP capture on ASIK if needed and download BIP Logs to testPC
    _WA_for_ssh_issue
    ${csi_slot_list}   Get CSI slot in rrc msg    tcpdump_log=${attach_f1ap_logpath}
    Run keyword and continue on failure   Check csi beam report in biplog
    ...    tcpdump_log=${bip_log_pusch_list[0]}    csi_slot_list=${csi_slot_list}

    Stop data transfer and detach UE

    log to console    UE attach and check TPUT
    CA_basic_L3_call    dl_tput=${dl_tput}    ul_tput=${ul_tput}    duration=${duration}
    ...     dl_cell_id=${dl_cell_id}     exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}     exp_ul=0    sleep_time=${sleep_time}
    ...     data_transfer_direction=dl     tput_duration=${tput_duration}

Single_UE_Call_Setup_with_FDD_TDD_CA_without_FDM_with_beamforming_with_beam_refinement
    [Documentation]    Author: Wang Yixiang
    ...    Step 1	Attach UE-1 to the FDD NR cell, CA activate
    ...    Step 2	Start UL/DL data transfer, check peak tput and csi report on pusch
    ...    Step 3	Active beam refinement
    ...    Step 4	Start UL/DL data transfer, check peak tput and csi report on pusch
    [Arguments]     ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${duration}=${DURATION_OF_DATA_TRANSFER}
    ...    ${dl_cell_id}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=180,400    ${ul_cell_id}=${PCELL_ID}     ${exp_ul}=50
    ...    ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${wa_flag}=${False}   ${exp_dl_beam_refine}=100,50
    Single_UE_context_setup_in_SA_option2_with_inter-band_DL_CA_FDD_cell_as_Pcell_and_TDD_cell_as_Scell_with_beamforming_SA_CPRI
    ...    dl_tput=${dl_tput}    ul_tput=${ul_tput}    duration=${duration}
    ...    dl_cell_id=${dl_cell_id}     exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}     exp_ul=${exp_ul}    sleep_time=${sleep_time}
    ...    wa_flag=${wa_flag}    tput_duration=${tput_duration}    tcpdump_log_name=l3call_with_beamforming

    Stop data transfer and detach UE
    Activate beam refinement by rest api

    # after open beam refinement, cannot reach peak, only check scell have throughput
    Single_UE_context_setup_in_SA_option2_with_inter-band_DL_CA_FDD_cell_as_Pcell_and_TDD_cell_as_Scell_with_beamforming_SA_CPRI
    ...    dl_tput=${dl_tput}    ul_tput=${ul_tput}    duration=${duration}
    ...    dl_cell_id=${dl_cell_id}     exp_dl=${exp_dl_beam_refine}    ul_cell_id=${ul_cell_id}     exp_ul=${exp_ul}    sleep_time=${sleep_time}
    ...    wa_flag=${wa_flag}    tput_duration=${tput_duration}    tcpdump_log_name=l3call_with_beamrefine

Buffer_based_Scell_Activation_Deactivation
    [Documentation]    Author: Wang Yixiang
    ...    Step1: UE attach with CA
    ...    Step2: Active scell by start traffic
    ...    Step3: Deactivate scell by stop traffic
    ...    Step4: Repeat step2 and step3 three times
    [Arguments]    ${data_transfer_direction}=both     ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${duration}=${DURATION_OF_DATA_TRANSFER}
    ...    ${dl_cell_id}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=${PCELL_EXP_DL},${SCELL_EXP_DL}
    ...    ${ul_cell_id}=${PCELL_ID},${SCELL_ID}  ${exp_ul}=${PCELL_EXP_UL},0
    ...    ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${ue_type}=${UE_TYPE}    ${4G_check}=False    ${tcpdump_log_name}=basic_l3_call   ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${act_deact_times}=${3}
    UE attach and check Scell addition in tcpdump log    ue_type=${ue_type}    4G_check=${4G_check}    tcpdump_log_name=${tcpdump_log_name}
    FOR   ${i}    IN RANGE    ${act_deact_times}
        Start data transfer based on direction    dl_tput=${dl_tput}     ul_tput=${ul_tput}
        ...    duration=${duration}    data_transfer_direction=${data_transfer_direction}
        Sleep    ${sleep_time}    reason=Wait for traffic to be stable.
        ${tput_info_cell}    Check Tput info for each cell    dl_cell_id=${dl_cell_id}    exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}
        ...    exp_ul=${exp_ul}    tput_duration=${tput_duration}
        check Scell deactivated
    END

Online_modification_of_CA_Relationship_removal_SA
    [Documentation]    Author: Wang Yixiang
    CA_basic_L3_call    tcpdump_log_name=Initial_ca_l3call
    run keyword and ignore error    Stop data transfer and detach UE

    Remove NIDD sCellAdditionMethod via restapi and verify performance
    sleep    30s    # wait until cell full ready for ue attach success after reset or cell lock unlock
    run keyword and ignore error    _WA_for_ssh_issue
    run keyword and continue on failure  Basic_L3_call_No_CA    tcpdump_log_name=L3call_remove_scellAdd

    Add NIDD sCellAdditionMethod via restapi
    run keyword and continue on failure  Data transmission only on FDD Cell
    run keyword and ignore error    Stop data transfer and detach UE
    run keyword and ignore error    _WA_for_ssh_issue
    run keyword and continue on failure  CA_basic_L3_call    tcpdump_log_name=L3call_add_scellAdd

    Deactivate feature 5GC001390 by carrierAggregationSupportList to none
    run keyword and continue on failure  Data transimission on both Pcell and Scell
    run keyword and ignore error    Stop data transfer and detach UE
    run keyword and ignore error    _WA_for_ssh_issue
    run keyword and continue on failure  Basic_L3_call_No_CA    tcpdump_log_name=L3call_deact_1390

    Activate feature 5GC001390 by setting carrierAggregationSupportList to ca_Fdd_Fr1Tdd
    run keyword and continue on failure  Data transmission only on FDD Cell
    run keyword and ignore error    Stop data transfer and detach UE
    run keyword and ignore error    _WA_for_ssh_issue

    # unstable, continue to debug
#    ${pcell_len}    Get Length    ${PCELL_LIST}
#    run keyword if    '${PROGRAM}'!='21A' and ${pcell_len}>1
#    ...    Modify NRREL's lcrid and check UE released

check iperf process on appserver
    [Documentation]    Author: Liu Zheng
    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep    connection=APPserver
    [Teardown]    csn.disconnect    connection=APPserver


Check Scell activate when DL traffic increase from Small to Big with Bufferbased
    [Documentation]    Author: Dandan Fang
    [Arguments]       ${dlTraffic_Small}=100     ${dlTraffic_big}=${DL_TPUT}
    run keyword and continue on failure    Start UL data transfer and verify no Scell is activated    duration=1200s

    run keyword and continue on failure    Start Small DL data transfer and verify Scell is inactivated For Bufferbased
    ...    duration=1200s    dl_tput=${dlTraffic_Small}M

    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=1min    filter=L2Lo
    Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}    direction=both
    ...    target_avg_percent=0.8   min_percent=0.6
    ...    exp_ul_indiv=${PCELL_EXP_UL},0    exp_dl_indiv=${dlTraffic_Small},0

#    Check Tput info for each cell    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl=${dlTraffic_Small},0
#    ...    exp_ul=${PCELL_EXP_UL},0   ul_cell_id=${PCELL_ID},${SCELL_ID}   min_tp_check_needed=${False}

    run keyword and continue on failure    Start DL data transfer and verify Scell is activated
    ...    duration=1200s    dl_tput=${dlTraffic_big}
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=1min    filter=L2Lo
    Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}    direction=both
    ...    target_avg_percent=0.8   min_percent=0.6
    ...    exp_ul_indiv=${PCELL_EXP_UL},0    exp_dl_indiv=${PCELL_EXP_DL},${SCELL_EXP_DL}

#    Check Tput info for each cell    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL}
#    ...    exp_ul=${PCELL_EXP_UL},0   ul_cell_id=${PCELL_ID},${SCELL_ID}   min_tp_check_needed=${False}

Check Scell deactivate when DL traffic stop with Bufferbased
    [Documentation]    Author: Dandan Fang
    ...    ${scell_id}: scell id, can be 1 or 1,2
    ...    ${scell_operator_mode}: scell operational mode, can be dl_only or dl_only,dlAndUl
    [Arguments]    ${scell_operator_mode}=dl_only    ${scell_id}=${SCELL_ID}
    check Scell deactivated    scell_id=${scell_id}    scell_operator_mode=${scell_operator_mode}

Verify A1 configured and no Scell addition after attach with Pcell signal bad
    [Documentation]    Author: Dandan Fang
    [Arguments]    ${tcpdump_log_name}=A1Config_NonCA_When_PCell_Bad      ${NSA_SA}=SA
    ...            ${exp_pa_value}=${40}       ${ru_index}=${PCELL_RU_INDEX}
    Initialize attenuator for specified RU     exp_pa_value=${exp_pa_value}    ru_index=${ru_index}

    ${A1_configured_log_path}    UE attach and verify NO CA  tcpdump_log_name=${tcpdump_log_name}   scell_addition_method=covBasedA1
    ...            NSA_SA=${NSA_SA}

    [Return]    ${A1_configured_log_path}

Verify A1 report and Scell addition but in inactivate when Pcell Signal From Bad To Good
    [Documentation]    Author: Dandan Fang
    ...      Note: It is just called when scell addition method as covBasedA1
    ...      a2_meas_for_scell_released control whether need to check A2 configured for Scell release, False no check
    ...                                         true need to check
    [Arguments]    ${tcpdump_log_name}=CA_A1_Report_When_Pcell_Good
    ...            ${exp_pa_value}=${40}       ${ru_index}=${PCELL_RU_INDEX}
    ...            ${a1_rsrp_thres}=${80}     ${meas_id}=${1}     ${a2_meas_for_scell_released}=${False}
    Prepare and start aasyslog
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    log to console    Tune PA to trigger UE A1 measurement report
    Initialize attenuator for specified RU     exp_pa_value=${exp_pa_value}    ru_index=${ru_index}
    sleep    5s    msg=Wait for UE send A1 measurement report.

    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    run keyword and continue on failure  Verify A1 measurement report in cpif log
    ...    log_path_pcap=${ute_log_path}   a1_rsrp_thres=${a1_rsrp_thres}     meas_id=${meas_id}

    run keyword if      ${a2_meas_for_scell_released}         Verify A2 measurement config for scell released in cpif log
    ...     log_path_pcap=${ute_log_path}

    run keyword and continue on failure    Check Scell addition in tcpdump log    tcpdump_log=${ute_log_path}

    ${is_scell_activated}    Run keyword and return status    Stop aasyslog to check scell activation
    should not be true    ${is_scell_activated}
    [Return]    ${ute_log_path}
    [Teardown]    run keyword and ignore error    Run keywords    Stop Tcpdump via collector
    ...       tcpdump_collector_name=${tcpdump_log_name}    AND
    ...       Teardown the Aasyslog save progress

A2 report and Scell released when Scell signal in bad
    [Documentation]    Author: Dandan Fang
    ...            Note:Pcell and Scell Signal need to be bad at the same time
    [Arguments]    ${tcpdump_log_name}=CA_A2_Report_When_Scell_Bad
    ...            ${exp_pa_value_pcell}=${40}         ${exp_pa_value_scell}=${40}
    ...            ${pcell_ru_index}=${PCELL_RU_INDEX}      ${scell_ru_index}=${SCELL_RU_INDEX}
    ...            ${a2_rsrp_thres}=${60}       ${meas_id}=${2}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    log to console    Tune PA to trigger UE A2 measurement report

    Initialize attenuator for specified RU     exp_pa_value=${exp_pa_value_pcell}    ru_index=${pcell_ru_index}
    Initialize attenuator for specified RU     exp_pa_value=${exp_pa_value_scell}    ru_index=${scell_ru_index}

    sleep    5s    msg=Wait for UE send A2 measurement report.
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    run keyword and continue on failure     Verify A2 report for special cell in cpif log
    ...    log_path_pcap=${ute_log_path}   a2_rsrp_thres=${a2_rsrp_thres}     meas_id=${meas_id}     cellId=${SCELL_ID}

    run keyword and continue on failure    Check Scell release in tcpdump log    tcpdump_log=${ute_log_path}
    [Teardown]    run keyword and ignore error    Run keywords    Stop Tcpdump via collector
    ...       tcpdump_collector_name=${tcpdump_log_name}    AND
    ...       Teardown the Aasyslog save progress

Verify scell added again after released when pcell signal back to good
    [Documentation]    Author: Dandan Fang
    ...            Note:Pcell and Scell Signal need to be bad at the same time
    [Arguments]    ${tcpdump_log_name}=Scell_add_again_after_released
    ...            ${exp_pa_value_pcell}=${INIT_PA_F_T}
    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp

    Initialize attenuator values for testline  pa_values_mapping=${exp_pa_value_pcell}

    sleep    5s    msg=Wait for scell addition
    ${ute_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    run keyword and continue on failure    Check Scell addition in tcpdump log    tcpdump_log=${ute_log_path}
    [Teardown]    run keyword and ignore error    Stop Tcpdump via collector        tcpdump_collector_name=${tcpdump_log_name}

Verify scell data suspened and not deactivated when scell rlq in bad
    [Documentation]    Author: Dandan Fang
     ...    Note: sleep time 60s need small than bad_rlq_count*sCellChannelEstimationPeriod/1000,80*2000ms/1000
    [Arguments]     ${scell_ru_index}=${SCELL_RU_INDEX}      ${pa_scell_rlq_bad}=${40}
    ...             ${scell_deactivation_method}=qualitybased
    ...             ${log_name}=scell_suspend_no_deactive_when_rlq_go_into_bad.txt
    Prepare and start aasyslog   log_name=${log_name}
    ${list_pa_initial_value}    Get attenuator value for specific RU    ru_index=${scell_ru_index}
    ${pa_start}    Evaluate    list(set(${list_pa_initial_value}))[0]
    Adjust PA gradually for specified RUs    pa_start=${pa_start}    pa_end=${pa_scell_rlq_bad}    ru_idx_list=${scell_ru_index}

    Sleep     10s    reason=Wait for Bad RLQ, Scell data suspend

    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=10s    filter=L2Lo
    Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}    direction=dl
    ...    target_avg_percent=0.8   min_percent=0.6
    ...    exp_ul_indiv=-1,-1    exp_dl_indiv=${PCELL_EXP_DL},0

    #during 60s, no scell deactive happened
    ${is_scell_deactivated}    Run keyword and return status    Stop aasyslog to check scell deactivation
    ...                sCelldeactivationMethod=${scell_deactivation_method}   log_name=${log_name}      timeout=60s
    should not be true    ${is_scell_deactivated}
    [Teardown]    run keyword and ignore error    Teardown the Aasyslog save progress

Verify scell data resumed when scell rlq back to good
    [Documentation]    Author: Dandan Fang
    [Arguments]     ${scell_ru_index}=${SCELL_RU_INDEX}        ${pa_scell_rlq_good}=${0}
    #Adjust to Good
    Adjust PA gradually for specified RUs    pa_start=${pa_scell_rlq_good}    pa_end=${pa_scell_rlq_good}    ru_idx_list=${scell_ru_index}
    Sleep    10s    reason=Wait for traffic to be stable.

    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=10s    filter=L2Lo
    Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}    direction=both
    ...    target_avg_percent=0.8   min_percent=0.6
    ...    exp_ul_indiv=${PCELL_EXP_UL},0   exp_dl_indiv=${PCELL_EXP_DL},${SCELL_EXP_DL}
#    Check Tput info for each cell    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL}
#    ...    exp_ul=${PCELL_EXP_UL},0   ul_cell_id=${PCELL_ID},${SCELL_ID}   min_tp_check_needed=${false}

Verify scell permanent deactivated when scell rlq remain in bad
    [Documentation]    Author: Dandan Fang
    [Arguments]     ${scell_ru_index}=${SCELL_RU_INDEX}
    ...             ${pa_scell_rlq_bad}=${40}     ${scell_deactivate_time}=${0}
    ...             ${scell_deactivation_method}=qualitybased
    ...             ${log_name}=scell_deactivated_when_rlq_remain_bad.txt
    ...             ${scell_operator_mode}=dl_only    ${scell_id}=${SCELL_ID}
    Prepare and start aasyslog   log_name=${log_name}
    ${list_pa_initial_value}    Get attenuator value for specific RU    ru_index=${scell_ru_index}
    ${pa_start}    Evaluate    list(set(${list_pa_initial_value}))[0]
    Adjust PA gradually for specified RUs    pa_start=${pa_start}    pa_end=${pa_scell_rlq_bad}    ru_idx_list=${scell_ru_index}

    ${sleep_time}      Evaluate    ${scell_deactivate_time}+${20}
    run keyword if     ${scell_deactivate_time}>0
    ...       Sleep    ${sleep_time}s    reason=Wait for Bad RLQ Count Match,then Trigger Scell deactivate

    ${is_scell_deactivated}    Run keyword and return status    Stop aasyslog to check scell deactivation
    ...                sCelldeactivationMethod=${scell_deactivation_method}   log_name=${log_name}
    ...                scell_id=${scell_id}    scell_operator_mode=${scell_operator_mode}
    should be true    ${is_scell_deactivated}
    [Teardown]    run keyword and ignore error    Teardown the Aasyslog save progress

Verify scell not activate when rlq bad into good after scell permanent deactivated
    [Documentation]    Author: Dandan Fang
    [Arguments]     ${scell_ru_index}=${SCELL_RU_INDEX}     ${scell_rlq_good}=${0}
    ...             ${log_name}=scell_no_activated_after_permanent_deactivated_by_rlq.txt
    Prepare and start aasyslog       log_name=${log_name}
    Initialize attenuator for specified RU     exp_pa_value=${scell_rlq_good}    ru_index=${scell_ru_index}

    #scell should not activate again during 60s
    ${is_scell_activated}    Run keyword and return status    Stop aasyslog to check scell activation
    ...                   log_name=${log_name}      timeout=60s

    should not be true    ${is_scell_activated}
    [Teardown]    run keyword and ignore error    Teardown the Aasyslog save progress


Verify scell data suspend and no deactivated when overheating trigger
    [Documentation]    Author: Dandan Fang
    ...   Important, With 2329, When Overheating triggered, if Pcell as 4 layer, it will down to 2 layer
    ...   set:0:modem:1     this command is to set mitigation level 1 and cause UE to report SCC CQI 0
    [Arguments]     ${log_name}=scell_data_suspend_no_deactivated_when_OH_trigger.txt
    Prepare and start aasyslog   log_name=${log_name}

    ${is_sdx65}     run keyword and return status    List should contain value    ${tl.ues[0].capabilities}    sdx65
    run keyword if    ${is_sdx65}
    ...    wait until keyword succeeds     3X    1s    Overheat.set_cqi_value    cqi_value=${6}
    ...    ue_sn=${tl.ues[${0}].serial_number}    hostname=${tl.ues[${0}].ssh_connection_details.addr}
    ...    ELSE
    ...    wait until keyword succeeds     3X    1s    Overheat.set_cqi_value    cqi_value=${1}
    ...    ue_sn=${tl.ues[${0}].serial_number}    hostname=${tl.ues[${0}].ssh_connection_details.addr}
    sleep    10s

    ${PCELL_EXP_DL}    run keyword if    '${ca_group_type}'=='T+F'       evaluate     ${PCELL_EXP_DL}/2

    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=1min    filter=L2Lo
    Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}    direction=both
    ...    target_avg_percent=0.8   min_percent=0.6
    ...    exp_ul_indiv=${PCELL_EXP_UL},0     exp_dl_indiv=${PCELL_EXP_DL},0

#    run keyword and continue on failure        wait until keyword succeeds     3X    1s     Check Tput info for each cell
#    ...    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl=${PCELL_EXP_DL},0
#    ...    exp_ul=${PCELL_EXP_UL},0   ul_cell_id=${PCELL_ID},${SCELL_ID}   min_tp_check_needed=${false}

    ${is_scell_deactivated}    Run keyword and return status    Stop aasyslog to check scell deactivation
    ...        log_name=${log_name}      timeout=60s

    run keyword and continue on failure         should not be true    ${is_scell_deactivated}
    [Teardown]    run keyword and ignore error    Teardown the Aasyslog save progress

Verify scell data resume when overheating stop
    [Documentation]    Author: Dandan Fang
    ...   set:0:modem:1     this command is to set mitigation level 0 and cause UE to revert back to normal
    wait until keyword succeeds     3X    1s    Overheat.set_cqi_value    cqi_value=${0}   ue_sn=${tl.ues[${0}].serial_number}
    ...    hostname=${tl.ues[${0}].ssh_connection_details.addr}
    sleep    10s

    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    ignore_time=1min    filter=L2Lo
    Check tput with UL rank1 issue ignored for T+F TDD cell    tput_log_path=${tput_log}    direction=both
    ...    target_avg_percent=0.8   min_percent=0.6
    ...    exp_ul_indiv=${PCELL_EXP_UL},0     exp_dl_indiv=${PCELL_EXP_DL},${SCELL_EXP_DL}

#    run keyword and continue on failure       wait until keyword succeeds     3X    1s      Check Tput info for each cell
#    ...    dl_cell_id=${PCELL_ID},${SCELL_ID}    exp_dl=${PCELL_EXP_DL},${SCELL_EXP_DL}
#    ...    exp_ul=${PCELL_EXP_UL},0   tput_duration=20    ul_cell_id=${PCELL_ID},${SCELL_ID}

Verify Pcell ID Changed after pcell switch through RRC reconfiguration
    [Documentation]    author: Dandan Fang
    ...     expected_target_cell should be as Scell ID when Pcell switch supported
    ...     when pcell switch happened, old scell will be released
    [Arguments]     ${log_path_pcap}=${CPIF_LOG}       ${expected_target_pcell}=${SCELL_ID}    ${scell_number}=${1}
    #spcell changed, old scell released
    ${filter}    set variable
    ...    ( f1ap.procedureCode == 12 ) && (nr-rrc.spCellConfigCommon_element)
    ${pkt_pcell_change}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=${filter}

    ${expectedCellPCI}   set variable    ${NR_CELL_ID_MAPPING[${expected_target_pcell}]['physicalCellId']}

    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.spCellConfig_element//nr-rrc.reconfigurationWithSync_element
    ...    /nr-rrc.spCellConfigCommon_element/nr-rrc.physCellId
    ${target_cell_pci}    pcap.get_field_value_by_xpath
    ...    pdml_list=${pkt_pcell_change}      xpath=${xpath}       attribute_name=show

    ${release_scell_index}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.sCellToReleaseList       attribute_name=show

    run keyword and continue on failure   should be true    ${expectedCellPCI} == ${target_cell_pci[0]}
    run keyword and continue on failure   should be true    ${release_scell_index[0]} == ${scell_number}

Verify new scell add after pcell switch through RRC Info
    [Documentation]    author: Dandan Fang
    ...      check new scell added, pci updated.
    [Arguments]     ${log_path_pcap}=${CPIF_LOG}        ${expected_target_scell}=${PCELL_ID}
    #new scell addition
    ${expected_scellPCI}   set variable    ${NR_CELL_ID_MAPPING[${expected_target_scell}]['physicalCellId']}
    ${filter}    set variable
    ...     ( f1ap.procedureCode == 12 ) && (nr-rrc.sCellToAddModList) && ( nr-rrc.physCellId == ${expected_scellPCI} )
    ${pkt_new_scell_addition}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=${filter}
    ${new_scell_pci}    pcap.get_field_value_by_xpath
    ...    pdml_list=${pkt_new_scell_addition}        attribute_name=show
    ...    xpath=.//nr-rrc.sCellConfigCommon_element/nr-rrc.physCellId

    run keyword and continue on failure   should be true    ${expected_scellPCI} == ${new_scell_pci[0]}

Verify A1 report for scell to trigger pcell switch in cpif log
    [Documentation]    author: Dandan Fang
    ...    check A1 report on Scell
    [Arguments]    ${log_path_pcap}=${CPIF_LOG}    ${cellId}=${SCELL_ID}          ${a1_rsrp_thres}=${85}
    ${physicalCellId}   set variable    ${NR_CELL_ID_MAPPING[${cellId}]['physicalCellId']}
    ${filter}    set variable
    ...    (f1ap.procedureCode == 13) && (nr-rrc.measResultServingMOList) && (nr-rrc.physCellId == ${physicalCellId})
    ${pkt_measReport}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=${filter}

    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
    ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp

    ${a1_rsrp}  pcap.get_field_value_by_xpath    xpath=${xpath}      attribute_name=show

    run keyword and continue on failure    should be true    ${a1_rsrp[0]} >= ${a1_rsrp_thres}


Verify A2 report for pcell to trigger pcell swith in cpif log
    [Documentation]    author: Jin Journey
    [Arguments]    ${log_path_pcap}=${CPIF_LOG}    ${cellId}=${PCELL_ID}          ${a2_rsrp_thres}=${85}
    ${physicalCellId}   set variable    ${NR_CELL_ID_MAPPING[${cellId}]['physicalCellId']}
    ${filter}    set variable
    ...    (f1ap.procedureCode == 13) && (nr-rrc.measResultServingMOList) && (nr-rrc.physCellId == ${physicalCellId})
    pcap.setup     infile=${log_path_pcap}    display_filter=${filter}
    ${xpath}  catenate    SEPARATOR=${EMPTY}     .//nr-rrc.measResultServingMOList//*//nr-rrc.physCellId[@show='${physicalCellId}']
    ...    /following-sibling::nr-rrc.measResult_element//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.measQuantityResults.rsrp

    ${a2_rsrp}  pcap.get_field_value_by_xpath    xpath=${xpath}      attribute_name=show

    run keyword and continue on failure    should be true    ${a2_rsrp[0]} <= ${a2_rsrp_thres}

#Verify A1 configured on scell when pcell switch enabled in cpif log
#    [Documentation]    author: Dandan Fang
#    ...         id-DLRRCMessageTransfer  procedureCode as 12
#    ...         measCycleSCell just support with SA
#    ...          it is used for A1 based or A2 based on Pcell to trigger pcell changed feature
#    [Arguments]     ${log_path_pcap}=${CPIF_LOG}
#    ${filter}    set variable
#    ...    (f1ap.procedureCode == 12) && (nr-rrc.measObjectToAddModList) && (nr-rrc.measCycleSCell)
#    ${pkt_measReport}    Load pcap file with filter    log_path_pcap=${log_path_pcap}     filter=${filter}
#
#    ${a1meas_type}  pcap.get_field_value_by_xpath
#    ...      xpath=.//nr-rrc.eventA1_element/nr-rrc.a1_Threshold
#    ...      attribute_name=showname
#
#    run keyword and continue on failure    should be equal as strings    rsrp    ${a1meas_type[0].split()[1]}

Verify A2 configured on pcell when pcell switch enabled in cpif log
    [Documentation]    author: Jin Journey
    ...         id-DLRRCMessageTransfer  procedureCode as 12
    ...         measCycleSCell just support with SA
    ...          it is used for A1 based or A2 based on Pcell to trigger pcell changed feature
    [Arguments]     ${log_path_pcap}=${CPIF_LOG}
    ${filter}    set variable
    ...    (f1ap.procedureCode == 12) && (nr-rrc.measObjectToAddModList) && (nr-rrc.measCycleSCell)
    ${pkt_measReport}    Load pcap file with filter    log_path_pcap=${log_path_pcap}     filter=${filter}

    ${a2meas_type}  pcap.get_field_value_by_xpath
    ...      xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold
    ...      attribute_name=showname

    run keyword and continue on failure    should be equal as strings    rsrp    ${a2meas_type[0].split()[1]}
