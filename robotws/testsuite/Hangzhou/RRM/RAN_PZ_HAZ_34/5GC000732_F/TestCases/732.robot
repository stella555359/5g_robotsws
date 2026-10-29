*** Settings ***
Resource    ./../Resources/5GC000732_F_Keywords.robot


Documentation    Suite description
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: MMW_SG1
...   Feature 5GC000732-F

Force Tags    5G_RRM
...    PY36    RF50
Suite Setup     Suite preparation for 732
Suite Teardown  Run keyword and ignore error    CA Suite teardown


*** Test Cases ***
[1]5GC000732_F_3_RRC_Reestablishment_With_The_Serving_Cell_interaction_with_CA_And_Measurement_F_T_CA_part
    [Tags]    CIT_TRUNK    CIT_22R2    CIT_22R3    CDRT_22R2    CIT_22R4    CDRT_22R3
    [Documentation]    Author: Liu Zheng
    [Setup]    Common case setup    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    sleep    30s    msg=Wait for gNB stable to be attach after restart.
    ${tput_info_before_rre}    CA_basic_L3_call    tcpdump_log_name=ca_basic_l3_call    dl_tput=1100M    ul_tput=100M
    ...    duration=3000s    dl_cell_id=${PCELL_ID},${SCELL_ID}     exp_dl=${EXP_DL_${MRBTS_ID}_PCELL},${EXP_DL_${MRBTS_ID}_SCELL}
    ...    ul_cell_id=${PCELL_ID},${SCELL_ID}    exp_ul=${EXP_UL_${MRBTS_ID}},0
    ...     tput_duration=${DURATION_OF_TPUT_CHECK}    scell_addition_method=covBasedA1

    log to console    \nthroughput_info_before_RRE:${tput_info_before_rre}
    set test variable    ${rre_result}    ${False}
    FOR    ${index}    IN RANGE    ${5}
        Start capture F1AP log    tcpdump_collector_name=RRE_${index}_time    options=-i any sctp
        log to console    Tune PA to trigger RRE
        Adjust pcell attenuator multi ports to trigger RRE
        sleep    8s    msg=Wait for messages can be collected fully.
        ${log_path}    Stop tcpdump log collection    tcpdump_collector_name=RRE_${index}_time
        ${rre_req}    run keyword and return status    Verify RRE messages in config in f1ap log    log_path_pcap=${log_path}
        ...    check_only_rrcReestablishmentRequest=${True}
        continue_for_loop_if    ${rre_req}==${False}
        ${rre_result}     run keyword and return status    check f1ap logs for test case 03    log_path=${log_path}
        set test variable    ${rre_result}
        exit for loop if   ${rre_req}==${True}
    END
    run keyword and continue on failure     should be true    ${rre_result}
    ${tput_info_after_rre}   Get tput summary from GNB log    dl_cell=${PCELL_ID},${SCELL_ID}    ul_cell=${PCELL_ID},${SCELL_ID}
    ...    tput_duration=${DURATION_OF_TPUT_CHECK}
    log to console    \nthroughput_info_after_RRE:${tput_info_after_rre}

    run keyword and continue on failure     verify throughput returned by CA_basic_l3_call should be as expected
    ...    pcell_id=${PCELL_ID}    scell_id=${SCELL_ID}
    ...    tput_info_cell_before=${tput_info_before_rre}    tput_info_cell_after=${tput_info_after_rre}

    [Teardown]    run keywords    Run keyword and ignore error    Restore PA settings    AND
    ...    Run keyword and ignore error    Common case teardown    detach_ue=${True}

[1]5GC000732_F_8_RRC_Reestablishment_The_Serving_Cell_Interaction_With_VoNR_And_A1_Measurement_And_DRX_Configuration_F_T_CA_part
    [Tags]    CRT_TRUNK     CRT_22R3    CRT_22R4    CRT_23R1
    [Documentation]    Author: Liu Zheng
    ...    Description: This user scenario describes the behaviour, when a UE in RRC_CONNECTED state re-establishes RRC Connection
    ...    to the serving cel in serving gNB-DU with valid UE context interaction with A1 measurement CA/VONR/DRX/A3(inter-frequency).
    ...    test steps:
    ...    1. Enable 732 flag(MRBTS/NRBTS.rrcReestabTypeSA =1) 、configure A1 measurement FDD+TDD CA parameters、configure VONR parameters
    ...    、configure DRX parmeters, configure inter-frequency A3 measurement and SA cell is onAir with AMF.
    ...    2. UDP ul/dl data transmition successfully.
    ...    3. VONR start successfully, and UDP traffic is not affected.
    ...    4. Pcell PA 0---127---0, step_time:2300ms, trigger RRE. check RRE process, DRX recoverd after RRE. VONR is not affect.
    ...     throughput on Pcell and Scell are normal.
    ...    5. stop VoNR
    ...    6. Pcell PA 0---31, trigger MeasGap.
    ...    7. Pcell PA 31---127---31, trigger RRE. after RRE, MeasGap recovered.
    ...     there is no throughput on scell due to scell activation method is bufferbased.
    ...    8. Pcell PA 31---0, there is throughput on scell. MeasGap release and drx setup.
    ...    9. stop UDP, ping UE IP, the latence should match the drx function.
    ...    10. Pcell PA 0---31, scell PA 10---0, trigger A3, handover to TDD.
    [Setup]     case setup for 732_F_08
    ${counter_log_start_time}    prepare for counter log    reporting_interval=5
    #set scell PA to 15, then make sure A3 not triggered before step10.
    Adjust attenuator multi ports to same value    ru_index=${SCELL_RU_INDEX}    pa_value=${SCELL_08_CASE_PA_VALUE_${MRBTS_ID}}
    Adjust attenuator multi ports to same value    ru_index=${PCELL_RU_INDEX}    pa_value=${PCELL_INIT_PA_VALUE_${MRBTS_ID}}   pa_port_num=${2}
    test and verify RRE with vonr and drx configuration for case 08    dl_tput=300M    ul_tput=100M    exp_dl=10,50    exp_ul=10,0
    ...    tput_duration=${DURATION_OF_TPUT_CHECK}    duration=1800s    try_voice_call_duration=50    vonr_num=9988
    Trigger measgap and verify measgap setup successfully
    Trigger RRE and measgap recovered after RRE
    Adjust PA back to check measgap release
    Check DRX should work correctly before and after traffic
    # check counter
    run keyword and continue on failure     Download PM files and verify 732 counters value
    ...    starting_log_timestamp=${counter_log_start_time['log_generator_timestamp']}    reporting_interval=5
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=all    timeout=${TIMER_FOR_MODIFY_VIA_API}
    Handover to Tdd should succeed
    [Teardown]    run keyword and ignore error    Run Keywords   hang up voice call    AND
    ...    Restore PA settings    AND    Common case teardown    detach_ue=${True}


*** Keywords ***
Suite preparation for 732
    [Documentation]    Author: Liu Zheng
    Set Suite Variable    ${dpa_enable}    ${True}
    Import NIDD variables    if_vonr_conf_needed=${False}
    import variables        testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000732_F/TestData/rre_nidd_delete_add_modify.py
    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_FOR_RRE_COMMON}
    CA Suite preparation


case setup for 732_F_08
    Import NIDD variables    if_vonr_conf_needed=${True}
    import variables        testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000732_F/TestData/rre_nidd_delete_add_modify.py
    set suite variable    ${PARAMS_TO_ADD}    ${PARAMS_TO_ADD_FOR_732_08_CASE}
    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_FOR_INTERFREQHO_VONR_RRE}
    set suite variable    ${PARAMS_TO_DELETE}    ${PARAMS_TO_DELETE_FOR_732_08_CASE}
    Suite common setup preparation
    ...    prepare_ue=${False}    scf_template_path=${SCF_DEFAULT_FILE_PATH}
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    ...    detach_request=${False}    enb_default_scf_file=${None}  swconfig_modify=${None}
    Common case setup    is_alias_created=${True}    is_enb_status_check_needed=${False}
    ...    is_x2_check_from_enb_needed=${False}
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${PCELL_ID}    timeout=2min

test RRE for debug
    [Documentation]    Author: Liu Zheng
    run keyword and continue on failure    Start capture F1AP log    tcpdump_collector_name=RRE    options=-i any sctp
    log to console    Tune PA to trigger RRE
    Adjust pcell attenuator multi ports to trigger RRE
    sleep    2s
    ${tput_info_after_rre}   Get tput summary from GNB log    dl_cell=${PCELL_ID},${SCELL_ID}    ul_cell=${PCELL_ID},${SCELL_ID}
    ...    tput_duration=60s
    log to console    \nCell throughput is ${tput_info_after_rre}
    ${ul_pcell_after}    set variable    ${tput_info_after_rre['${pcell_id}']['ul_avg_tput']}
    ${dl_pcell_after}    set variable    ${tput_info_after_rre['${pcell_id}']['dl_avg_tput']}
    ${dl_scell_after}    set variable    ${tput_info_after_rre['${scell_id}']['dl_avg_tput']}
    ${dl_tp_after}    evaluate    ${dl_pcell_after}+${dl_scell_after}
    run keyword and continue on failure    should be true    ${ul_pcell_after} > ${60}
    run keyword and continue on failure    should be true    ${dl_tp_after} > ${280}
    ${log_path}    run keyword and continue on failure    Stop tcpdump log collection    tcpdump_collector_name=RRE
    run keyword and continue on failure    Verify RRE messages in config in f1ap log    log_path_pcap=${log_path}
    run keyword and continue on failure    Verify RRCReconfiguration messages should be correct after RRE in f1ap log
    ...    log_path_pcap=${log_path}
    ${a1_report_id}    run keyword and continue on failure
    ...    Get reportConfigId for special measEvent in cpif log    measEvent=eventA1      log_path_pcap=${log_path}
    run keyword and continue on failure
    ...            verify a1 scell addition measurement config in cpif log    log_path_pcap=${log_path}
    [Teardown]    Run keyword and ignore error    Stop tcpdump log collection    tcpdump_collector_name=RRE

verify throughput returned by CA_basic_l3_call should be as expected
    [Documentation]   Author: Liu Zheng
    ...    compare the throughputs which are returned from CA_basic_l3_call
    [Arguments]    ${pcell_id}    ${scell_id}    ${tput_info_cell_before}    ${tput_info_cell_after}
    ${ul_pcell_before}    set variable    ${tput_info_cell_before['${pcell_id}']['ul_avg_tput']}
    ${dl_pcell_before}    set variable    ${tput_info_cell_before['${pcell_id}']['dl_avg_tput']}
    ${dl_scell_before}    set variable    ${tput_info_cell_before['${scell_id}']['dl_avg_tput']}

    ${ul_pcell_after}    set variable    ${tput_info_cell_after['${pcell_id}']['ul_avg_tput']}
    ${dl_pcell_after}    set variable    ${tput_info_cell_after['${pcell_id}']['dl_avg_tput']}
    ${dl_scell_after}    set variable    ${tput_info_cell_after['${scell_id}']['dl_avg_tput']}

    run keyword and continue on failure    should be true   ${ul_pcell_before}*0.99 < ${ul_pcell_after} < ${ul_pcell_before}*1.01
    run keyword and continue on failure    should be true    ${dl_pcell_before}*0.99 < ${dl_pcell_after} < ${dl_pcell_before}*1.01
    run keyword and continue on failure    should be true    ${dl_scell_before}*0.99 < ${dl_scell_after} < ${dl_scell_before}*1.01
