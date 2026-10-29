*** Settings ***
Documentation
...   This is for  5GC000732-F TA keywords
...   squad group: MMW_SG1
Resource    ./5GC000732_Variables.robot
Resource    ./../../CB007873/Resources/CB007873_keywords.robot
Resource    ./RRE.robot
Resource    ./../../../../resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/vonr.robot


*** Keywords ***
check f1ap logs for test case 03
    [Documentation]    Author: Liu Zheng
    [Arguments]     ${log_path}
    run keyword and continue on failure    Verify RRE messages in config in f1ap log    log_path_pcap=${log_path}
    run keyword and continue on failure    Verify RRCReconfiguration messages should be correct after RRE in f1ap log
    ...    log_path_pcap=${log_path}
    ${a1_report_id}    run keyword and continue on failure
    ...    Get reportConfigId for special measEvent in cpif log    measEvent=eventA1      log_path_pcap=${log_path}
    run keyword and continue on failure
    ...            verify a1 scell addition measurement config in cpif log    log_path_pcap=${log_path}

test and verify RRE with vonr and drx configuration for case 08
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${dl_tput}=300M    ${ul_tput}=100M
    ...    ${exp_dl}=80,200    ${exp_ul}=70,0    ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${duration}=${DURATION_OF_DATA_TRANSFER}
    ...    ${ue_index}=${0}    ${try_voice_call_duration}=50    ${vonr_num}=6688
    Start capture F1AP log    tcpdump_collector_name=RRE_vonr_drx    options=-i any sctp
    ${udp_tput_info_with_vonr}    Test CA UDP plus VoNR without hung up voice call and wireshark log analysis
    ...    pcell_id=${PCELL_ID}    scell_id=${SCELL_ID}    dl_tput=${dl_tput}    ul_tput=${ul_tput}
    ...    exp_dl=${exp_dl}   exp_ul=${exp_ul}    tput_duration=${DURATION_OF_TPUT_CHECK}    duration=${duration}
    ...    ue_index=${0}    try_voice_call_duration=${try_voice_call_duration}    vonr_num=${vonr_num}
    log to console    UDP throughput with vonr before RRE: ${udp_tput_info_with_vonr}
    log to console    Tune PA to trigger RRE
    Adjust pcell attenuator multi ports to trigger RRE    pa_begin_value=${PCELL_INIT_PA_VALUE_${MRBTS_ID}}
    ...    pa_end_value=${PCELL_RRE_PA_VALUE_${MRBTS_ID}}
    ...    pa_back_value=${PCELL_INIT_PA_VALUE_${MRBTS_ID}}
    sleep    3s    msg=Wait for messages can be collected fully and scell throughput stable.
    ${tput_info_after_rre1}   Get tput summary from GNB log    dl_cell=${PCELL_ID},${SCELL_ID}    ul_cell=${PCELL_ID},${SCELL_ID}
    ...    tput_duration=60s
    log to console    UDP throughput with vonr after RRE: ${tput_info_after_rre1}
    log to console    hang up voice call
    hang up voice call
    sleep    5s
    ${log_path_vonr_drx}    Stop tcpdump log collection    tcpdump_collector_name=RRE_vonr_drx
    run keyword and continue on failure    analysis wireshark log for VoNR    pcap_file=${log_path_vonr_drx}    expect_duration=${28}
    run keyword and continue on failure    Verify RRE messages in config in f1ap log    log_path_pcap=${log_path_vonr_drx}
    run keyword and continue on failure    Verify RRCReconfiguration messages should be correct after RRE in f1ap log
    ...    log_path_pcap=${log_path_vonr_drx}
    ${a1_report_id}    run keyword and continue on failure
    ...    Get reportConfigId for special measEvent in cpif log    measEvent=eventA1      log_path_pcap=${log_path_vonr_drx}
    run keyword and continue on failure
    ...            verify a1 scell addition measurement config in cpif log    log_path_pcap=${log_path_vonr_drx}
    run keyword and continue on failure    Verify drx config setup in cpif log    log_path_pcap=${log_path_vonr_drx}
    run keyword and continue on failure    verify throughput should be as expected    pcell_id=${PCELL_ID}    scell_id=${SCELL_ID}
    ...    tput_info_1=${tput_info_after_rre1}    tput_info_2=${udp_tput_info_with_vonr}

Trigger measgap and verify measgap setup successfully
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${ul_tp_expect}=${60}    ${dl_tp_expect}=${280}
    #Trigger measgap and check measgap in RRC reconfiguration message
    Start capture F1AP log    tcpdump_collector_name=MG_setup    options=-i any sctp
    Adjust attenuator multi ports to same value    ru_index=${PCELL_RU_INDEX}
    ...    pa_value=${PCELL_MEASGAP_PA_VALUE_${MRBTS_ID}}    pa_port_num=${2}
    ${tput_info_after_MG_setup}   Get tput summary from GNB log    dl_cell=${PCELL_ID},${SCELL_ID}    ul_cell=${PCELL_ID},${SCELL_ID}
    ...    tput_duration=60s
    log to console    \nUDP_throughput_after_measurementgap_setup: ${tput_info_after_MG_setup}
    run keyword and continue on failure    Verify DL TP sum and UL TP should be as except    tput_info=${tput_info_after_MG_setup}
    ...    ul_tp_expect=${ul_tp_expect}    dl_tp_expect=${dl_tp_expect}
    ${log_path_mg_setup}    Stop tcpdump log collection    tcpdump_collector_name=MG_setup
    run keyword and continue on failure
    ...            Verify measurement gap in cpif log    meas_gap=${SCF_PCELL_MEAS_GAP}    log_path_pcap=${log_path_mg_setup}
    run keyword and continue on failure
    ...            Verify drx config release after measurement gap in cpif log    log_path_pcap=${log_path_mg_setup}

Trigger RRE and measgap recovered after RRE
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${ul_tp_expect}=${60}    ${dl_tp_expect}=${100}
    ## trigger RRE and check RRE success, measgap recovered
    Start capture F1AP log    tcpdump_collector_name=MG_RRE    options=-i any sctp
    Adjust pcell attenuator multi ports to trigger RRE    pa_begin_value=${PCELL_MEASGAP_PA_VALUE_${MRBTS_ID}}
    ...    pa_end_value=${PCELL_RRE_PA_VALUE_${MRBTS_ID}}
    ...    pa_back_value=${PCELL_MEASGAP_PA_VALUE_${MRBTS_ID}}
    sleep    2s    msg=Wait for messages can be collected fully and scell throughput stable.
    ${tput_info_after_rre2}   Get tput summary from GNB log    dl_cell=${PCELL_ID},${SCELL_ID}    ul_cell=${PCELL_ID},${SCELL_ID}
    ...    tput_duration=60s
    log to console    \nUDP_throughput_with_measurementgap_after_RRE: ${tput_info_after_rre2}
    run keyword and continue on failure    Verify DL TP sum and UL TP should be as except    tput_info=${tput_info_after_rre2}
    ...    ul_tp_expect=${ul_tp_expect}    dl_tp_expect=${dl_tp_expect}
    ${log_path_rre_mg_recoverd}    Stop tcpdump log collection    tcpdump_collector_name=MG_RRE
    #check MG recovered after RRE
    run keyword and continue on failure    Verify RRE messages in config in f1ap log    log_path_pcap=${log_path_rre_mg_recoverd}
    run keyword and continue on failure    Verify RRCReconfiguration messages should be correct after RRE in f1ap log
    ...    log_path_pcap=${log_path_rre_mg_recoverd}
    run keyword and continue on failure
    ...            Verify measurement gap in cpif log    meas_gap=${SCF_PCELL_MEAS_GAP}    log_path_pcap=${log_path_rre_mg_recoverd}

Adjust PA back to check measgap release
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${ul_tp_expect}=${70}    ${dl_tp_expect}=${290}
    ## agjust pcell pa back to check scell throughput normal
    Start capture F1AP log    tcpdump_collector_name=MG_release_by_pa_back    options=-i any sctp
    Adjust attenuator multi ports to same value    ru_index=${PCELL_RU_INDEX}
    ...    pa_value=${PCELL_INIT_PA_VALUE_${MRBTS_ID}}    pa_port_num=${2}
    sleep    1s
    ${tput_info_after_MG_release}   Get tput summary from GNB log    dl_cell=${PCELL_ID},${SCELL_ID}    ul_cell=${PCELL_ID},${SCELL_ID}
    ...    tput_duration=60s
    log to console    \nUDP_throughput_after_measurementgap_release: ${tput_info_after_MG_release}
    run keyword and continue on failure    Verify DL TP sum and UL TP should be as except    tput_info=${tput_info_after_MG_release}
    ...    ul_tp_expect=${ul_tp_expect}    dl_tp_expect=${dl_tp_expect}
    ${log_path_mg_release}    Stop tcpdump log collection    tcpdump_collector_name=MG_release_by_pa_back
    #check MG release, drx setup
    run keyword and continue on failure
    ...        Verify measurement gap release after A1 report    log_path_pcap=${log_path_mg_release}
    run keyword and continue on failure    Verify drx config setup in cpif log    log_path_pcap=${log_path_mg_release}

Check DRX should work correctly before and after traffic
    [Documentation]    Author: Liu Zheng
    ${latency_wi_drx_with_trfaffic}    run keyword and continue on failure     Perform DL ping and calculate latency    numberofping=${60}
    log to console    *********stop UDP Traffic*********
    run keyword and continue on failure     Stop data transfer based on direction    protocol=udp    data_transfer_direction=both
    sleep    2s
    ${latency_wi_drx_no_traffic}    run keyword and continue on failure     Perform DL ping and calculate latency    numberofping=${60}
    ${latency_wi_drx_no_traffic}    run keyword and continue on failure     Perform DL ping and calculate latency    numberofping=${60}
    run keyword and continue on failure     Verify ping latency within allowed range    ping_latency_wi_drx=${latency_wi_drx_no_traffic}
    ...    ping_latency_wo_drx=${latency_wi_drx_with_trfaffic}    retry_time=${5}    is_drx_cycle_above_80ms=${True}    sr_period=80

Handover to Tdd should succeed
    [Documentation]    Author: Liu Zheng
    log to console    **********do A3 handover and check the handover shoud be successed**********
    Start capture F1AP log    tcpdump_collector_name=A3_handover    options=-i any sctp
    Adjust attenuator multi ports to same value    ru_index=${PCELL_RU_INDEX}
    ...    pa_value=${PCELL_MEASGAP_PA_VALUE_${MRBTS_ID}}    pa_port_num=${2}
    sleep    5s
    Adjust attenuator multi ports to same value    ru_index=${SCELL_RU_INDEX}
    ...    pa_value=${SCELL_INIT_PA_VALUE_${MRBTS_ID}}    pa_port_num=${4}
    sleep    5s
    ${log_path_a3_handover}    Stop tcpdump log collection    tcpdump_collector_name=A3_handover
    #check handover success
    run keyword and continue on failure
    ...            Verify a3 measurement config in cpif log    log_path_pcap=${log_path_a3_handover}
    run keyword and continue on failure
    ...            verify A3 handover succeed in cpif log   log_path_pcap=${log_path_a3_handover}

verify A3 handover succeed in cpif log
    [Arguments]    ${log_path_pcap}=${CPIF_LOG}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable
    ...    (f1ap) && (f1ap.procedureCode == 12)
    ${RrcReconf}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter}
    ${a3ho_target_pci_list}    pcap.get_field_value_by_xpath
    ...    xpath=.//nr-rrc.spCellConfigCommon_element//nr-rrc.physCellId
    ...    attribute_name=show
    ${a3ho_target_pci}    Remove Duplicates    ${a3ho_target_pci_list}
    run keyword and continue on failure    should be equal as strings    ${NR_CELL_ID_MAPPING[${SCELL_ID}]['physicalCellId']}    ${a3ho_target_pci[0]}

Restore PA settings
    [Documentation]    Author: Liu Zheng
    Adjust attenuator multi ports to same value    ru_index=${PCELL_RU_INDEX}
    ...    pa_value=${PCELL_INIT_PA_VALUE_${MRBTS_ID}}   pa_port_num=${2}
    Adjust attenuator multi ports to same value    ru_index=${SCELL_RU_INDEX}    pa_value=${SCELL_INIT_PA_VALUE_${MRBTS_ID}}

Test CA UDP plus VoNR without hung up voice call and wireshark log analysis
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${pcell_id}    ${scell_id}=${SCELL_ID}    ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${exp_dl}=100,600    ${exp_ul}=50,0    ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${duration}=${DURATION_OF_DATA_TRANSFER}
    ...    ${ue_index}=${0}    ${try_voice_call_duration}=50    ${vonr_num}=6688    ${target_avg_percent}=0.95
    ${udp_tput_info_without_vonr}    Run keyword and continue on failure    CA_L3_call_no_verify_CA    dl_tput=${dl_tput}    ul_tput=${ul_tput}
    ...    dl_cell_id=${pcell_id},${scell_id}    exp_dl=${exp_dl}    ul_cell_id=${pcell_id}     exp_ul=${exp_ul}    duration=${duration}
    ${tput_aasyslog_local_path}    Run keyword and continue on failure    collect udp throughput data when do VoNR call
    ...    try_voice_call_duration=${try_voice_call_duration}    vonr_num=${vonr_num}        hung_up_voice_call=${False}
    Connect to Common Unit Master    alias=ASIK Master
    ${list_of_nrcellidentity_ids}    Get the nrcellidentity_list    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
    ${ul_exp_tp_sum}    get the sum of the expect dl or ul throughput    exp_tp_number=${exp_ul}
    ${dl_exp_tp_sum}    get the sum of the expect dl or ul throughput    exp_tp_number=${exp_dl}

    ${ul_tput_after}   ${dl_tput_after}    power_ue.Check Bi Tput    ue_type=${UE_TYPE}   log=${tput_aasyslog_local_path}
    ...    cells=${list_of_nrcellidentity_ids}   ultarget_throughput=${ul_exp_tp_sum}   dltarget_throughput=${dl_exp_tp_sum}
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${True}

    ${throughput_info_with_vonr}  Create Dictionary   UL=${ul_tput_after}   DL=${dl_tput_after}

    log to console    \ntput_info_with_vonr: ${throughput_info_with_vonr}

    run keyword and continue on failure    _verify throughput should be as expected    pcell_id=${pcell_id}    scell_id=${scell_id}
    ...    tput_info_1=${udp_tput_info_without_vonr}    tput_info_2=${throughput_info_with_vonr}

    [Return]    ${throughput_info_with_vonr}

CA_L3_call_no_verify_CA
    [Documentation]    Author: Liu Zheng
    [Arguments]     ${data_transfer_direction}=both     ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${process_num}=default    ${duration}=${DURATION_OF_DATA_TRANSFER}
    ...    ${dl_cell_id}=${PCELL_ID},${SCELL_ID}     ${exp_dl}=${PCELL_EXP_DL},${SCELL_EXP_DL}    ${ul_cell_id}=${PCELL_ID},${SCELL_ID}
    ...    ${exp_ul}=${PCELL_EXP_UL},0         ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${sleep_time}=${WAIT_TIME_FOR_TPUT_STABLE}
    ...    ${ue_index}=${0}  ${window}=10M    ${connection}=GNB_OAM
    ${retry_attach_times}    run keyword and continue on failure
    ...    Retry commercial ue attach if failed     prepare_ue_needed=${False}    4G_check=${False}    ue_index=${ue_index}
    ...    connection=${connection}
    Start data transfer based on direction    dl_tput=${dl_tput}     ul_tput=${ul_tput}    window=${window}
    ...    duration=${duration}    process_num=${process_num}   data_transfer_direction=${data_transfer_direction}
    Sleep    ${sleep_time}    reason=Wait for traffic to be stable.
    run keyword and ignore error    check iperf process on appserver
    ${tput_info_cell}    Check Tput info for each cell    dl_cell_id=${dl_cell_id}    exp_dl=${exp_dl}    ul_cell_id=${ul_cell_id}
    ...    exp_ul=${exp_ul}    tput_duration=${tput_duration}
    [Return]    ${tput_info_cell}

Verify DL TP sum and UL TP should be as except
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${tput_info}    ${ul_tp_expect}=${60}    ${dl_tp_expect}=${280}
    log to console    \nCell throughput is ${tput_info}
    ${ul_pcell}    set variable    ${tput_info['${pcell_id}']['ul_avg_tput']}
    ${dl_pcell}    set variable    ${tput_info['${pcell_id}']['dl_avg_tput']}
    ${dl_scell}    set variable    ${tput_info['${scell_id}']['dl_avg_tput']}
    ${dl_tp}    evaluate    ${dl_pcell}+${dl_scell}
    run keyword and continue on failure    should be true    ${dl_scell} > ${10}
    run keyword and continue on failure    should be true    ${ul_pcell} > ${ul_tp_expect}
    run keyword and continue on failure    should be true    ${dl_tp} > ${dl_tp_expect}

Download PM files and verify 732 counters value
    [Documentation]    Author: Liu Zheng
    ...    Download counter log to ute
    ...    Check counters from WebUI:
    ...    M55124C00501: RRC_REESTAB_DISCARD, The number of the RRCReestablishmentRequest which is not accepted
    ...    M55124C00502 : RRC_REESTAB_FALLBACK, The number of RRCSetup is performed as response for RRCReestablishmentRequest
    ...    M55124C00505：RRC_REESTAB_OTHER_FAILURE, The number of the RRCReestablishmentRequest with the reestablishmentCause of otherFailure
    ...    M55124C00512：REESTAB_ACC_OTHER_FAIL,
    ...        The number of successful RRC Reestablishment procedures when the reestablishmentCause is otherFailure
    ...    M55127C00503：RRC_REESTAB_OTHER_FAILURE_DU,The number of the RRCReestablishmentRequest with the reestablishmentCause of otherFailure
    ...    M55127C00512：REESTAB_ACC_OTHER_FAIL_DU,
    ...         The number of successful RRC Reestablishment procedures when the reestablishmentCause is otherFailure
    ...    M55127C00513: RRC_REESTAB_DISCARD_DU, The number of the RRCReestablishmentRequest which is not accepted.
    ...    M55124C00516: REESTAB_RRCRECONFIG_SUCC, the number of RRC reconfiguration succeed in RRC reestablishment procedure
    ...    M55124C00517: REESTAB_RRCRECONFIG_UNSUCC, The number of RRC reconfiguration failed in RRC reestablishment procedure
    ...    M55124C00518: RRC_REESTAB_ACC_VONR, The number of successful RRC Reestablishment procedure for VONR for all reestablishment cause
    ...    M55124C00520: RRC_REESTAB_ATT_VONR, The number of RRC Re-establishment Request attempts for VONR for any cause RRC_REESTAB_ATT_VONR
    ...    for VoNR counter check: M55124C00520 = M55124C00518
    ...    for RRC Reconfiguration check: M55124C00516 should > 0
    ...    for RRC Reconfiguration check:M55124C00517 should < 1
    ...    for RRE fallback: M55124C00502 < 1
    ...    for RRE counter on gNB-CU:
    ...        RRCReestablishmentRequest = RRCReestablishmentComplete + Discard
    ...        RRCReestablishmentRequest = M55124C00503 + M55124C00504 + M55124C00505
    ...                                our case related is OTHER_FAILURE type, so only M55124C00505 need to be checked.
    ...                                M55124C00503(RRC_REESTAB_RECONF_FAILURE), M55124C00504(RRC_REESTAB_HO_FAILURE) no need to check.
    ...        RRCReestablishmentComplete = M55124C00510 + M55124C00511 + M55124C00512
    ...                                our case related is OTHER_FAILURE type, so only M55124C00512 need to be checked.
    ...                                M55124C00510(REESTAB_ACC_RECONF_FAIL), M55124C00511(REESTAB_ACC_HO_FAIL) no need to check.
    ...        Discard = M55124C00501
    ...        So on gNB-CU: M55124C00505 = M55124C00512 + M55124C00501
    ...    for RRE counter check on gNB-DU:
    ...        RRCReestablishmentRequest = RRCReestablishmentComplete +Discard
    ...        RRCReestablishmentRequest = M55127C00501 + M55127C00502 + M55127C00503
    ...                                our case related is OTHER_FAILURE type, so only M55127C00503 need to be checked.
    ...                                M55127C00501(RRC_REESTAB_RECONF_FAILURE_DU), M55127C00502(RRC_REESTAB_HO_FAILURE_DU) no need to check.
    ...        RRCReestablishmentComplete = M55127C00510 + M55127C00511 + M55127C00512
    ...                                our case related is OTHER_FAILURE type, so only M55127C00512 need to be checked.
    ...                                M55127C00510(REESTAB_ACC_RECONF_FAIL_DU), M55127C00511(REESTAB_ACC_HO_FAIL_DU) no need to check.
    ...        Discard = M55127C00513
    ...        so on gNB-DU: M55127C00503 = M55127C00512 + M55127C00513

    [Arguments]    ${starting_log_timestamp}    ${reporting_interval}=5
    ${counter_ids}    create list  M55124C00520    M55124C00518    M55124C00516    M55124C00517    M55124C00502
    ...    M55124C00505    M55124C00512    M55124C00501    M55127C00503    M55127C00512    M55127C00513

    ${local_counter_file_path}    Wait for PM file generated and download     starting_log_timestamp=${starting_log_timestamp}
    ...    reporting_interval=${reporting_interval}
    ${counter_ids_value}      counter.get_total_counter_from_multiple_files   list_file_path=${local_counter_file_path}
    ...  list_measurement_ids=${counter_ids}
    log to console    \ncounter info:${counter_ids_value}
    ${type}    evaluate    type(${counter_ids_value})
    ${counter_RRC_REESTAB_ATT_VONR}    set variable     ${counter_ids_value['M55124C00520']}
    ${counter_RRC_REESTAB_ACC_VONR}    set variable     ${counter_ids_value['M55124C00518']}
    ${counter_REESTAB_RRCRECONFIG_SUCC}    set variable     ${counter_ids_value['M55124C00516']}
    ${counter_REESTAB_RRCRECONFIG_UNSUCC}    set variable     ${counter_ids_value['M55124C00517']}
    ${counter_RRC_REESTAB_FALLBACK}    set variable     ${counter_ids_value['M55124C00502']}
    ${counter_RRC_REESTAB_OTHER_FAILURE}    set variable     ${counter_ids_value['M55124C00505']}
    ${counter_REESTAB_ACC_OTHER_FAIL}    set variable     ${counter_ids_value['M55124C00512']}
    ${counter_RRC_REESTAB_DISCARD}    set variable     ${counter_ids_value['M55124C00501']}
    ${counter_RRC_REESTAB_OTHER_FAILURE_DU}    set variable     ${counter_ids_value['M55127C00503']}
    ${counter_REESTAB_ACC_OTHER_FAIL_DU}    set variable     ${counter_ids_value['M55127C00512']}
    ${counter_RRC_REESTAB_DISCARD_DU}    set variable     ${counter_ids_value['M55127C00513']}
    ${str1}  catenate  55124C00518(RRC_REESTAB_ACC_VONR,number of successful RRC Reestablishment procedure for VONR for all reestablishment cause)
    ...    is not equal to M55124C00520(RRC_REESTAB_ATT_VONR, The number of RRC Re-establishment Request attempts for VONR for any cause
    ...    RRC_REESTAB_ATT_VONR) !
    ${str2}  catenate  M55124C00517(REESTAB_RRCRECONFIG_UNSUCC, The number of RRC reconfiguration failed in RRC reestablishment procedure)
    ...    should less than 1, which means all rrc reconfiguration should be successed!
    ${str3}  catenate  M55124C00502(RRC_REESTAB_FALLBACK, The number of RRCSetup is performed as response for RRCReestablishmentRequest) should
    ...    less than 1 which means there should no RRE FALLBACK
    Run keyword and continue on failure  should be true    ${counter_RRC_REESTAB_ACC_VONR} == ${counter_RRC_REESTAB_ATT_VONR}
    ...    msg=${str1}
    Run keyword and continue on failure  should be true  ${counter_REESTAB_RRCRECONFIG_SUCC} >= 2
    ...    msg=M55124C00516(REESTAB_RRCRECONFIG_SUCC,the number of RRC reconfiguration succeed in RRC reestablishment procedure) should larger than 1
    Run keyword and continue on failure  should be true  ${counter_REESTAB_RRCRECONFIG_UNSUCC} < 1
    ...    msg=${str2}
    Run keyword and continue on failure  should be true  ${counter_RRC_REESTAB_FALLBACK} < 1
    ...    msg=${str3}
    Run keyword and continue on failure  should be true
    ...    ${counter_RRC_REESTAB_OTHER_FAILURE} == ${counter_REESTAB_ACC_OTHER_FAIL} + ${counter_RRC_REESTAB_DISCARD}
    ...    msg=on gNB-CU: RCReestablishmentRequest=RRCReestablishmentComplete+Discard(M55124C00505=M55124C00512+M55124C00501) should be true.
    Run keyword and continue on failure  should be true
    ...    ${counter_RRC_REESTAB_OTHER_FAILURE_DU} == ${counter_REESTAB_ACC_OTHER_FAIL_DU} + ${counter_RRC_REESTAB_DISCARD_DU}
    ...    msg=so on gNB-DU: RRCReestablishmentRequest=RRCReestablishmentComplete +Discard(M55127C00503=M55127C00512+M55127C00513) should be true.
