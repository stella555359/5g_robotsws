*** Settings ***
Documentation
...   Author: Dandan Fang
...   Description: Test case steps implementation

Resource    CB010411_keywords.robot

*** Variables ***
${NRBTS_DN}    MRBTS-${tl.gnbs[${GNB_INDEX}].dus[${VDU_INDEX}].instance_id}/NRBTS-${tl.gnbs[${GNB_INDEX}].dus[${VDU_INDEX}].global_bts_id}

*** Keywords ***
Step1.UE Attach without Scell Add
    #cloud 8311 scell add method as covBasedA1 and 8311 enabled default.
    ${du_counter_list} =       _Get CB009267 DU no Scell active Counters And Set Expected Value
    ${counter_pre_timestamp}    Waiting time for new counter update period For Cloud   bts_type=du
    Cloud CA UE attach and check Scell addition in tcpdump log
    ...   NSA_SA=SA   gnb_index=${GNB_INDEX}
    ...   scell_addition_method=covBasedA1     actBufferBasedScellAddition=oneShot_Dl_Fr1   pcell_id=${PCELL_ID}
    ...   tcpdump_log_name=ue_attach_without_scelladd

    ${counter_post_timestamp}    Waiting time for new counter update period For Cloud   bts_type=du

    Check Counter Value match expectations    counter_list=${du_counter_list}    bts_type=du
    ...    start_time_lower_limit=${counter_pre_timestamp['log_generator_timestamp']}
    ...    start_time_upper_limit=${counter_post_timestamp['log_generator_timestamp']}

_Get CU Scell Add Counters And Set Expected Value
    # Sum of CA UEs in the cell configured as PCell with 3 configured SCells in DL
    ${counter_id_list}    run keyword if    'sdx80' in @{tl.ues[0].capabilities}
    ...    create list    M55118C00004    M55118C00001    M55138C03504    M55138C03507
    ...    ELSE     create list    M55118C09502    M55118C09503    M55138C03001    M55138C03002
    ${counters_list}    Create Counters information list and set expected value    counter_id_list=${counter_id_list}
    ...   expect_value=${1}    bts_type=cu    dimension_dist_name=${CU_PCELL_DN}
    [Return]    ${counters_list}

_Get CU Scell Release Counters And Set Expected Value
    # The number of SCells to be released on PCell due to prolonged inactivity for SA
    ${dl_scell_number}    get length    ${SCELL_ID_DL_ADD}
    ${ul_scell_number}    run keyword if    "${SCELL_ID_UL_ADD}"=="${None}"    set variable    ${0}
    ...    ELSE    get length    ${SCELL_ID_UL_ADD}
    ${scell_number}    evaluate    ${dl_scell_number}+${ul_scell_number}
    ${counter_id_list}    run keyword if    'sdx80' in @{tl.ues[0].capabilities}
    ...    create list    M55118C10511    M55118C10512
    ...    ELSE    create list    M55139C03001    M55139C03002
    ${counters_list}    Create Counters information list and set expected value    counter_id_list=${counter_id_list}
    ...   expect_value=${scell_number}    bts_type=cu    dimension_dist_name=${CU_PCELL_DN}
    [Return]    ${counters_list}

_Get DU Scell Add Counters And Set Expected Value
    ${counter_id_list}        run keyword if    'sdx80' in @{tl.ues[0].capabilities}
    ...    create list    M55139C03003    M55139C03006
    ...    ELSE    create list    M55139C03001    M55139C03002
    ${counters_list}    Create Counters information list and set expected value    counter_id_list=${counter_id_list}
    ...   expect_value=${1}    bts_type=du    dimension_dn=${DU_PCELL_DN}

    FOR    ${index}    ${scell_id}   IN ENUMERATE    @{SCELL_ID_DL_ADD}
        ${cell_dn}    set variable   ${NRBTS_DN}/NRCELL-${scell_id}
        # Radio admission requests for the SCell in DU in SA mode
        ${counter_id_list_M55139C01001}    create list    M55139C01001
        ${counters_list_scell_M55139C01001}    Create Counters information list and set expected value
        ...   counter_id_list=${counter_id_list_M55139C01001}    expect_value=${1}    bts_type=du    dimension_dn=${cell_dn}
        # Successful radio admissions for the SCell in DU in SA mode
        ${counter_id_list_M55139C01002}    create list    M55139C01002
        ${counters_list_scell_M55139C01002}    Create Counters information list and set expected value
        ...   counter_id_list=${counter_id_list_M55139C01002}    expect_value=${1}    bts_type=du    dimension_dn=${cell_dn}
        ${counters_list}    combine lists    ${counters_list}    ${counters_list_scell_M55139C01001}    ${counters_list_scell_M55139C01002}
    END
    [Return]    ${counters_list}

Step2.8311 Scell Add Triggered Through DL UL Peak Data
    [Arguments]
    ...       ${tcpdump_log_name}=gNB${GNB_INDEX}_vcu_f1ap_scell_add_bufferbased

    ${legacy_cu_counter_list} =       _Get CU Scell Add Counters And Set Expected Value
    ${CB009267_cu_counter_list} =       _Get CB009267 CU Pcell Counters And Set Expected Value after add scell
    ${legacy_du_counter_list} =       _Get DU Scell Add Counters And Set Expected Value
    ${CB009267_du_counter_list} =       _Get CB009267 DU Pcell Counters And Set Expected Value after add scell
    ${cu_counter_list}    Evaluate     ${legacy_cu_counter_list} + ${CB009267_cu_counter_list}
    ${du_counter_list}    Evaluate     ${legacy_du_counter_list} + ${CB009267_du_counter_list}
    ${counter_pre_timestamp}    Waiting time for new counter update period For Cloud   bts_type=du

    Start F1AP Log On vCU OCP Master
    ...                gnb_index=${GNB_INDEX}   f1ap_collector_alias=${tcpdump_log_name}

    # debug for pr, buffer_size as 1500 in cloud
    Start data transfer based on direction
    ...    dl_tput=${DL_TPUT_IPERF}      ul_tput=${UL_TPUT_IPERF}    data_transfer_direction=both
    ...    duration=1200s
    ...    buffer_size=1400B    process_num=${3}

    ${tput_log_path}=      Cloud Standard Capturing Kubectl Throughput
    ...       gnb_index=${GNB_INDEX}   vdu_index=${VDU_INDEX}
    ...       duration=300s    check_tput_ignore_time=30s

    Run keyword and continue on failure
    ...    Check tput via power UE optimized     cell_index=${CELL_INDEX_LIST}     tput_log_path=${tput_log_path}    direction=both
    ...    exp_ul=1    exp_dl=1    target_avg_percent=0.98    min_percent=0.85
    ...    exp_ul_indiv=${EXP_UL_INDIV}    exp_dl_indiv=${EXP_DL_INDIV}    connection=OAM_gnb${GNB_INDEX}_du${VDU_INDEX}
    ...    is_need_to_fail_keyword=${True}    is_analysis_log_captured=${False}   customized_log_name=cloud_CA_L3_Call_tput

    ${ute_log_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    Verify scell addition from f1ap log    log_file_path=${ute_log_path_f1ap}
    ...            scell_index_ul=${SCELL_ID_UL_ADD}    scell_index_dl=${SCELL_ID_DL_ADD}

    ${counter_post_timestamp}    Waiting time for new counter update period For Cloud   bts_type=du

    run keyword and continue on failure    Check Counter Value match expectations    counter_list=${du_counter_list}    bts_type=du
    ...    start_time_lower_limit=${counter_pre_timestamp['log_generator_timestamp']}
    ...    start_time_upper_limit=${counter_post_timestamp['log_generator_timestamp']}
    Check Counter Value match expectations    counter_list=${cu_counter_list}    bts_type=cu
    ...    start_time_lower_limit=${counter_pre_timestamp['log_generator_timestamp']}
    ...    start_time_upper_limit=${counter_post_timestamp['log_generator_timestamp']}
    [Teardown]    run keyword and ignore error    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}

Step3.8311 Scell Release Triggered Through Stop DL UL
    [Arguments]
    ...       ${tcpdump_log_name}=gNB${GNB_INDEX}_vcu_f1ap_scell_release_cause_buffer
    ${scell_id_list}    string2list    ${SCELL_ID_DL_ADD}
    ${scell_number}    get length    ${scell_id_list}
    ${legacy_cu_counter_list} =    _Get CU Scell Release Counters And Set Expected Value
    ${CB009267_cu_counter_list} =    _Get CB009267 CU Pcell Counters And Set Expected Value after release scell
    ${CB009267_du_counter_list} =    _Get CB009267 DU Counters And Set Expected Value after release scell
    ${cu_counter_list}    Evaluate     ${legacy_cu_counter_list} + ${CB009267_cu_counter_list}
    ${counter_pre_timestamp}    Waiting time for new counter update period For Cloud   bts_type=cu

    Start F1AP Log On vCU OCP Master
    ...                gnb_index=${GNB_INDEX}   f1ap_collector_alias=${tcpdump_log_name}

    run keyword and continue on failure     Stop data transfer based on direction    protocol=udp    data_transfer_direction=both
    sleep   30s   reason=wait for data stop normal and throught buffer clear

    ${counter_post_timestamp}    Waiting time for new counter update period For Cloud   bts_type=cu
    run keyword and continue on failure     Check Counter Value match expectations    counter_list=${cu_counter_list}
    ...    bts_type=cu    start_time_lower_limit=${counter_pre_timestamp['log_generator_timestamp']}
    ...    start_time_upper_limit=${counter_post_timestamp['log_generator_timestamp']}
    run keyword and continue on failure     Check Counter Value match expectations    counter_list=${CB009267_du_counter_list}
    ...    bts_type=du    start_time_lower_limit=${counter_pre_timestamp['log_generator_timestamp']}
    ...    start_time_upper_limit=${counter_post_timestamp['log_generator_timestamp']}

    run keyword and continue on failure    check DU scell active counters
    ...    start_time_lower_limit=${counter_pre_timestamp['log_generator_timestamp']}
    ...    start_time_upper_limit=${counter_post_timestamp['log_generator_timestamp']}
    Check CU scell DUR counters    start_time_lower_limit=${counter_pre_timestamp['log_generator_timestamp']}
    ...    start_time_upper_limit=${counter_post_timestamp['log_generator_timestamp']}

    ${ute_log_path_f1ap}    run keyword and continue on failure   Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}

    ${scell_index_list}    set variable
    FOR    ${scell_index}    IN RANGE    ${scell_number}
        ${scell_index}    evaluate    ${scell_index}+1
        ${scell_index_list}    run keyword if    ${scell_index}==${1}    set variable    ${scell_index}
        ...    ELSE     catenate    ${scell_index_list}    ,    ${scell_index}
    END

    Verify Scell Released from F1AP log
    ...     log_path_pcap=${ute_log_path_f1ap}    scell_index=${scell_index_list}
    [Teardown]    run keyword and ignore error    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}

Create Counters information list and set expected value
    [Documentation]    Author: rong.2.wu@nokia-sbell.com
    ...      ${counter_id_list}: list of counters to be checked .  Data structure should be as :
    ...      ['M55316C15030', 'M55316C15038']
    ...      ${dimension_dn}: du Counter object, eg: MRBTS-1/NRBTS-1/NRCELL-1
    ...      ${dimension_dist_name}: cu Counter object, eg: MRBTS-1/NRBTS-1/NRCELL-1
    ...      ${bts_type}: cloud gnb, value should be cu or du
    ...      ${expect_value}: Counter expected value
    [Arguments]     ${counter_id_list}    ${bts_type}    ${dimension_dn}=${None}    ${dimension_dist_name}=${None}
    ...    ${count_all_values}=${True}    ${expect_value}=${None}
    @{list_counters}   create list
    FOR    ${counter_id}    IN     @{counter_id_list}
        ${counter_info}     run keyword if    '${bts_type}'=="du"
        ...    create dictionary       counter_id=${counter_id}    dimension_dn=${dimension_dn}
        ...    ELSE    create dictionary       counter_id=${counter_id}    dimension_dist_name=${dimension_dist_name}
        ${counter}    create dictionary       counter_info=${counter_info}
        ...   expect_value=${expect_value}    count_all_values=${count_all_values}
        append to list    ${list_counters}    ${counter}
    END
    [Return]    ${list_counters}

_Get CB009267 DU no Scell active Counters And Set Expected Value
    [Documentation]    Author: rong.2.wu@nokia-sbell.com
    ...    M55316C15030: PCELL_UE_0_ACT_SCELL_DL_SA, expect value is 0 since no CA, updated in pcell
    ...    M55316C15038: PCELL_UE_0_ACT_SCELL_UL_SA, expect value is 0 since no CA, updated in pcell
    ${counter_id_list}    create list    M55316C15030    M55316C15038
    ${counters_list}    Create Counters information list and set expected value    counter_id_list=${counter_id_list}
    ...   expect_value=${0}    bts_type=du    dimension_dn=${DU_PCELL_DN}
    [Return]    ${counters_list}

_Get CB009267 DU Pcell Counters And Set Expected Value after add scell
    [Documentation]    Author: rong.2.wu@nokia-sbell.com
    ...    M55139C05502:GNB_DU_DL_SCELL_1_ADMI_REQ_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55139C05503:GNB_DU_DL_SCELL_2_ADMI_REQ_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55139C05504:GNB_DU_DL_SCELL_3_ADMI_REQ_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55139C05505:GNB_DU_DL_SCELL_4_ADMI_REQ_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55139C05506:GNB_DU_DL_SCELL_5_ADMI_REQ_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55139C05507:GNB_DU_DL_SCELL_7_ADMI_REQ_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55139C05508:GNB_DU_DL_SCELL_8_ADMI_REQ_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55139C05513:GNB_DU_DL_SCELL_5_ADMI_SUCC_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55139C05516:GNB_DU_UL_SCELL_1_ADMI_REQ_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55139C05517:GNB_DU_UL_SCELL_2_ADMI_REQ_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55139C05518:GNB_DU_UL_SCELL_3_ADMI_REQ_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55139C05519:GNB_DU_UL_SCELL_1_ADMI_SUCC_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55316C15075:SCELL_ACT_DL_SCELL_ACT_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in DL scell
    ...    M55316C15076:SCELL_ACT_UL_SCELL_ACT_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in UL scell

    ${counter_id_list_value_0}    create list    M55139C05502    M55139C05503    M55139C05504    M55139C05505
    ...    M55139C05507    M55139C05508    M55139C05517    M55139C05518
    ${list_counters_value_0}    Create Counters information list and set expected value    counter_id_list=${counter_id_list_value_0}
    ...   expect_value=${0}    bts_type=du    dimension_dn=${DU_PCELL_DN}

    ${counter_id_list_value_1}    create list    M55139C05506    M55139C05513    M55139C05516    M55139C05519
    ${list_counters_value_1}    Create Counters information list and set expected value    counter_id_list=${counter_id_list_value_1}
    ...   expect_value=${1}    bts_type=du    dimension_dn=${DU_PCELL_DN}

    ${counter_id_list_ul_scell_value_1}    create list    M55316C15076
    ${list_counters_ul_scell}    Create Counters information list and set expected value    bts_type=du
    ...   counter_id_list=${counter_id_list_ul_scell_value_1}    expect_value=${1}    dimension_dn=${NRBTS_DN}/NRCELL-${SCELL_ID_UL_ADD}[0]
    ${counters_list}    Evaluate    ${list_counters_value_0}+${list_counters_value_1}+${list_counters_ul_scell}

    FOR    ${index}    ${scell_id}   IN ENUMERATE    @{SCELL_ID_DL_ADD}
        ${cell_dn}    set variable   ${NRBTS_DN}/NRCELL-${scell_id}
        ${counter_id_list_dl_scell_value_1}    create list    M55316C15075
        ${list_counters_dl_scell_M55316C15075}    Create Counters information list and set expected value    bts_type=du
        ...   counter_id_list=${counter_id_list_dl_scell_value_1}    expect_value=${1}    dimension_dn=${cell_dn}
        ${counters_list}    combine lists    ${counters_list}    ${list_counters_dl_scell_M55316C15075}
    END
    [Return]    ${counters_list}

_Get CB009267 DU Counters And Set Expected Value after release scell
    [Documentation]    Author: rong.2.wu@nokia-sbell.com
    ...    M55316C15031:PCELL_UE_1_ACT_SCELL_DL_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55316C15032:PCELL_UE_2_ACT_SCELL_DL_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55316C15033:PCELL_UE_3_ACT_SCELL_DL_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55316C15034:PCELL_UE_4_ACT_SCELL_DL_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55316C15036:PCELL_UE_6_ACT_SCELL_DL_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55316C15037:PCELL_UE_7_ACT_SCELL_DL_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55316C15040:PCELL_UE_2_ACT_SCELL_UL_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55316C15041:PCELL_UE_3_ACT_SCELL_UL_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55316C15016:SCELL_SUSP_RECOV_SA, expect value is 0, updated in pcell
    ...    M55316C15017:SCELL_SUSP_DEACT_REL_SA, expect value is 0, updated in pcell
    ...    M55316C15063:PSCELL_UE_0_ACT_SCELL_DL_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55316C15068:PSCELL_UE_5_ACT_SCELL_DL_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55316C15071:PSCELL_UE_0_ACT_SCELL_DL_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55316C15072:PSCELL_UE_1_ACT_SCELL_DL_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55316C15010:SCELL_UL_SUSPEND_UEOVHT_SA, expect value is 0, updated in UL scell
    ...    M55316C15011:SCELL_DL_SUSPEND_UEOVHT_SA, expect value is 0, updated in DL scell

    ${counter_id_list_value_0}    create list    M55316C15031    M55316C15032    M55316C15033    M55316C15034
    ...    M55316C15036    M55316C15037    M55316C15040    M55316C15041    M55316C15016    M55316C15017
    ...    M55316C15063    M55316C15068    M55316C15071    M55316C15072
    ${list_counters_value_0}    Create Counters information list and set expected value    counter_id_list=${counter_id_list_value_0}
    ...   expect_value=${0}    bts_type=du    dimension_dn=${DU_PCELL_DN}

    ${counter_id_list_ul_scell_value_1}    create list    M55316C15010
    ${list_counters_ul_scell}    Create Counters information list and set expected value    bts_type=du
    ...    counter_id_list=${counter_id_list_ul_scell_value_1}    expect_value=${0}    dimension_dn=${NRBTS_DN}/NRCELL-${SCELL_ID_UL_ADD}[0]
    ${counters_list}    Evaluate    ${list_counters_value_0}+${list_counters_ul_scell}

    FOR    ${index}    ${scell_id}   IN ENUMERATE    @{SCELL_ID_DL_ADD}
        ${cell_dn}    set variable   ${NRBTS_DN}/NRCELL-${scell_id}
        ${counter_id_list_dl_scell_value_0}    create list    M55316C15011
        ${list_counters_dl_scell}    create list
        ${list_counters_dl_scell_M55316C15011}    Create Counters information list and set expected value    bts_type=du
        ...    counter_id_list=${counter_id_list_dl_scell_value_0}    expect_value=${0}    dimension_dn=${cell_dn}
        ${counters_list}    combine lists    ${counters_list}    ${list_counters_dl_scell_M55316C15011}
    END
    [Return]    ${counters_list}

_Get CB009267 CU Pcell Counters And Set Expected Value after add scell
    [Documentation]    Author: rong.2.wu@nokia-sbell.com
    ...    M55138C03534:GNB_DL_SCELL_5_ADMI_UNSUCC_SA, expect value is 0 since 6CC DL 2CC UL CA is successful, updated in pcell
    ...    M55138C03537:GNB_UL_SCELL_1_ADMI_UNSUCC_SA, expect value is 0 since 6CC DL 2CC UL CA is successful, updated in pcell
    ...    M55114C01563:PCELL_UE_CAP_1_CC_DL_SA, expect value is 0 since it is SDX80 supported 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01564:PCELL_UE_CAP_2_CC_DL_SA, expect value is 0 since it is SDX80 supported 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01565:PCELL_UE_CAP_3_CC_DL_SA, expect value is 0 since it is SDX80 supported 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01566:PCELL_UE_CAP_4_CC_DL_SA, expect value is 0 since it is SDX80 supported 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01567:PCELL_UE_CAP_5_CC_DL_SA, expect value is 0 since it is SDX80 supported 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01569:PCELL_UE_CAP_7_CC_DL_SA, expect value is 0 since it is SDX80 supported 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01570:PCELL_UE_CAP_8_CC_DL_SA, expect value is 0 since it is SDX80 supported 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01571:PCELL_UE_CAP_1_CC_UL_SA, expect value is 0 since it is SDX80 supported 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01573:PCELL_UE_CAP_3_CC_UL_SA, expect value is 0 since it is SDX80 supported 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01574:PCELL_UE_CAP_4_CC_UL_SA, expect value is 0 since it is SDX80 supported 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01544:PSCELL_UE_CAP_6_CC_DL_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55114C01556:PSCELL_UE_CAP_6_CC_DL_MAX_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55114C01548:PSCELL_UE_CAP_2_CC_UL_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55114C01560:PSCELL_UE_CAP_2_CC_UL_MAX_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55138C03514:GNB_DL_SCELL_5_ADMI_REQ_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55138C03521:GNB_DL_SCELL_5_ADMI_SUCC_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55138C03524:GNB_UL_SCELL_1_ADMI_REQ_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55138C03527:GNB_UL_SCELL_1_ADMI_SUCC_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55118C11055:GNB_DL_SCELL_5_CONFIG_REQ_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55118C11065:GNB_DL_SCELL_5_CONFIG_SUCC_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55118C11058:GNB_UL_SCELL_1_CONFIG_REQ_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55118C11068:GNB_UL_SCELL_1_CONFIG_SUCC_SA, expect value is 1 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01580:PCELL_UE_CAP_6_CC_DL_MAX_SA, expect value is 2,
    ...                 since it is UE attached 6CC DL 2CC UL CA for 2 measurement cycles , updated in pcell
    ...    M55114C01584:PCELL_UE_CAP_2_CC_UL_MAX_SA,  expect value is 2
    ...                 since it is UE attached 6CC DL 2CC UL CA for 2 measurement cycles, updated in pcell

    ${counter_id_list_value_0}    create list    M55138C03534    M55138C03537    M55114C01563    M55114C01564
    ...    M55114C01565    M55114C01566    M55114C01567    M55114C01569    M55114C01570    M55114C01548
    ...    M55114C01571    M55114C01573    M55114C01574    M55114C01544    M55114C01556    M55114C01560
    ${list_counters_value_0}    Create Counters information list and set expected value    counter_id_list=${counter_id_list_value_0}
    ...   expect_value=${0}    bts_type=cu    dimension_dist_name=${CU_PCELL_DN}

    ${counter_id_list_value_1}    create list    M55138C03514    M55138C03521    M55138C03524    M55138C03527
    ...    M55118C11055    M55118C11065    M55118C11058    M55118C11068
    ${list_counters_value_1}    Create Counters information list and set expected value    counter_id_list=${counter_id_list_value_1}
    ...   expect_value=${1}    bts_type=cu    dimension_dist_name=${CU_PCELL_DN}

    ${counter_id_list_value_2}    create list    M55114C01580    M55114C01584
    ${list_counters_value_2}    Create Counters information list and set expected value    counter_id_list=${counter_id_list_value_2}
    ...   expect_value=${2}    bts_type=cu    dimension_dist_name=${CU_PCELL_DN}
    ${counters_list}    Evaluate    ${list_counters_value_0}+${list_counters_value_1}+${list_counters_value_2}
    [Return]    ${counters_list}


_Get CB009267 CU Pcell Counters And Set Expected Value after release scell
    [Documentation]    Author: rong.2.wu@nokia-sbell.com
    ...    M55118C00092:PCELL_DL_6_SCELL_CONFIG_DUR_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55118C00093:PCELL_DL_7_SCELL_CONFIG_DUR_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55118C00095:PCELL_UL_2_SCELL_CONFIG_DUR_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55118C00096:PCELL_UL_3_SCELL_CONFIG_DUR_SA, expect value is 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55118C11033:DL_INA_PRO_REL_SCELL_ATT_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55118C11034:DL_INA_PRO_REL_SCELL_SUC_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55118C11041:UL_RRC_FSCELL_REL_ATT_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55118C11042:UL_RRC_FSCELL_REL_SUC_NSA, expect value is 0 since it is SA CA, updated in pcell
    ...    M55118C11073:UL_INA_PRO_REL_SCELL_ATT_SA, expect value is 1 since there are 1 UL scell was released, updated in pcell
    ...    M55118C11074:UL_INA_PRO_REL_SCELL_SUC_SA, expect value is 1 since there are 1 UL scell was released, updated in pcell
    ...    M55118C11095:UL_RRC_FSCELL_REL_ATT_SA, expect value is 1 since UL scell was full released, updated in pcell
    ...    M55118C11096:UL_RRC_FSCELL_REL_SUC_SA, expect value is 1 since UL scell was full released, updated in pcell
    ...    M55118C11071:DL_INA_PRO_REL_SCELL_ATT_SA, expect value is 5 since there are 5 DL scells was released, updated in pcell
    ...    M55118C11072:DL_INA_PRO_REL_SCELL_SUC_SA, expect value is 5 since there are 5 DL scells was released, updated in pcell
    ...    M55114C01587:SAMP_UE_CC_CAP, expect value is 300 since increments each time a sample, updated in pcell
    ...    M55114C01568:PCELL_UE_CAP_6_CC_DL_SA, expect value is 300 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55114C01572:PCELL_UE_CAP_2_CC_UL_SA, expect value is 300 since it is 6CC DL 2CC UL CA, updated in pcell

    ${counter_id_list_value_0}    create list    M55118C00092    M55118C00093    M55118C00095    M55118C00096
    ...    M55118C11033    M55118C11034    M55118C11041    M55118C11042
    ${list_counters_value_0}    Create Counters information list and set expected value    counter_id_list=${counter_id_list_value_0}
    ...   expect_value=${0}    bts_type=cu    dimension_dist_name=${CU_PCELL_DN}

    ${counter_id_list_value_1}    create list    M55118C11073    M55118C11074     M55118C11095    M55118C11096
    ${list_counters_value_1}    Create Counters information list and set expected value    counter_id_list=${counter_id_list_value_1}
    ...   expect_value=${1}    bts_type=cu    dimension_dist_name=${CU_PCELL_DN}

    ${counter_id_list_value_5}    create list    M55118C11071    M55118C11072
    ${list_counters_value_5}    Create Counters information list and set expected value    counter_id_list=${counter_id_list_value_5}
    ...   expect_value=${5}    bts_type=cu    dimension_dist_name=${CU_PCELL_DN}

    ${counter_id_list_value_300}    create list    M55114C01587    M55114C01568    M55114C01572
    ${list_counters_value_300}    Create Counters information list and set expected value    counter_id_list=${counter_id_list_value_300}
    ...   expect_value=${300}    bts_type=cu    dimension_dist_name=${CU_PCELL_DN}
    ${counters_list}    Evaluate    ${list_counters_value_0}+${list_counters_value_1}+${list_counters_value_5}+${list_counters_value_300}
    [Return]    ${counters_list}

check DU scell active counters
    [Documentation]    Author: rong.2.wu@nokia-sbell.com
    ...    M55316C15035:PCELL_UE_5_ACT_SCELL_DL_SA, expect value large than 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55316C15039:PCELL_UE_1_ACT_SCELL_UL_SA, expect value large than 0 since it is 6CC DL 2CC UL CA, updated in pcell
    [Arguments]     ${start_time_lower_limit}=${None}    ${start_time_upper_limit}=${None}

    ${du_counter_id_list}    create list    M55316C15035    M55316C15039
    ${list_counters_du_scell_active}    Create Counters information list and set expected value    counter_id_list=${du_counter_id_list}
    ...    bts_type=du    dimension_dn=${DU_PCELL_DN}

    Check Counter Value match expectations    counter_list=${list_counters_du_scell_active}    bts_type=du
    ...    expression_1= <    start_time_lower_limit=${start_time_lower_limit}    start_time_upper_limit=${start_time_upper_limit}

Check CU scell DUR counters
    [Documentation]    Author: rong.2.wu@nokia-sbell.com
    ...    M55118C00087:PCELL_DL_1_SCELL_CONFIG_DUR_SA, expect value is 0 or 1 since it is based on buffer base add, updated in pcell
    ...    M55118C00088:PCELL_DL_2_SCELL_CONFIG_DUR_SA, expect value is 0 or 1 since it is based on buffer base add, updated in pcell
    ...    M55118C00089:PCELL_DL_3_SCELL_CONFIG_DUR_SA, expect value is 0 or 1 since it is based on buffer base add, updated in pcell
    ...    M55118C00090:PCELL_DL_4_SCELL_CONFIG_DUR_SA, expect value is 0 or 1 since it is based on buffer base add, updated in pcell
    ...    M55118C00091:PCELL_DL_5_SCELL_CONFIG_DUR_SA, expect value large than 0 since it is 6CC DL 2CC UL CA, updated in pcell
    ...    M55118C00094:PCELL_UL_1_SCELL_CONFIG_DUR_SA, expect value large than 0 since it is 6CC DL 2CC UL CA, updated in pcell
    [Arguments]    ${start_time_lower_limit}=${None}    ${start_time_upper_limit}=${None}

    ${cu_counter_id_list}    create list    M55118C00091    M55118C00094
    ${list_counters_cu_scell_DUR}    Create Counters information list and set expected value    counter_id_list=${cu_counter_id_list}
    ...    bts_type=cu    dimension_dist_name=${CU_PCELL_DN}

    Check Counter Value match expectations    counter_list=${list_counters_cu_scell_DUR}    bts_type=cu
    ...    expression_1= <    start_time_lower_limit=${start_time_lower_limit}    start_time_upper_limit=${start_time_upper_limit}

    ${cu_counter_id_list_1}    create list    M55118C00087    M55118C00088    M55118C00089    M55118C00090
    ${list_counters_cu_scell_DUR_1}    Create Counters information list and set expected value    counter_id_list=${cu_counter_id_list_1}
    ...    bts_type=cu    dimension_dist_name=${CU_PCELL_DN}

    Check Counter Value match expectations    counter_list=${list_counters_cu_scell_DUR_1}    bts_type=cu    expression_1= <=
    ...    expression_2= <=    start_time_lower_limit=${start_time_lower_limit}    start_time_upper_limit=${start_time_upper_limit}
