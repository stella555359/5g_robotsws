*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the ROBOT KEYWORDS file for CB008238_B

Library     taf.ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils         WITH NAME    AdminUtils
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2     WITH NAME    L1L2
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME    TTI
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/A/resources/test_specific_keywords.py
...         WITH NAME    keywords_8238_A
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/B/resources/test_specific_keywords.py
...         WITH NAME    keywords_8238_B
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/B/resources/test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore.DeltaStore   WITH NAME   DeltaStore
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot


*** Variables ***
${DL_TPUT_B2}=                      10Mbits/sec
${DL_TPUT_B1}=                      40Mbits/sec
${PACING_TIMER}=                    9000
${DL_TPUT_B4}=                      2Mbits/sec
${PACING_TIMER_B4}=                 30000
${TTI_COLLECTION_TIME}=             20s
${SA_UE_CAPS}=                      REAL_UE_SA
${CELL_ID_CB008238}=                1


*** Keywords ***
CB008238-5G-B_1_Single-UE_non_GBR_traffic_and_delay_sensitive_data_interaction_evaluation
    check preconditions in scf 8238      params_to_check=${scf_params_b1}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    Require UE   UE_1   capabilities=${SA_UE_CAPS}
    Check TTI and L1L2 logs for 8238_B_1   sctp_filename=L3_call_SA_B_1            dl_tput=${DL_TPUT_B1}
    ...                                    pacing_timer=${PACING_TIMER}


Check TTI and L1L2 logs for 8238_B_1
    [Arguments]   ${sctp_filename}   ${dl_tput}   ${pacing_timer}

    TcpdumpSmod.start_tcpdump_on_smod   filename=${sctp_filename}  smod_master=${true}  smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                  direction=dl     duration=130s
    ...                   packet_size=1200            throughput=${dl_tput}          protocol=udp
    ...                   iperf_version=3             pacing_timer=${pacing_timer}
    BuiltIn.Sleep    30s
    check_data_transfer_is_alive    dt_name=DT_DL
    Verify average throughput    dt_name=DT_DL    tput_min=1Mbits/sec

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    L1L2.start_gnbmirroring   filename=tput
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME}
    ${l1l2_logs}=   L1L2.stop_gnbmirroring_and_download_logs
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode

    Stop data transfer   dt_name=DT_DL

    ${attached_rntis}=    find_exactly_x_attached_rntis    ${sctp_logs}   1
    check_prio_14_is_assigned_correctly_after_prio_18   ${tti_file_path}   ${attached_rntis}
    check_sched_on_sib_or_paging_slots    ${tti_file_path}
    check_pdsch_at_ssb_slots   ${l1l2_logs}   ${attached_rntis}


CB008238-5G-B_2_Multi-UE_SA_DTX_interactions_with_non_GBR_traffic
    check preconditions in scf 8238    params_to_check=${scf_params_b2}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${CELL_ID_CB008238}
    Nullify attenuation on all ports
    Require UE   UE_1   capabilities=${SA_UE_CAPS}
    Require UE   UE_2   capabilities=${SA_UE_CAPS}
    Check TTI logs for 8238_B_2    sctp_filename=L3_call_SA_B_2
    ...                                  dl_tput=${DL_TPUT_B2}   pacing_timer=${PACING_TIMER}


Check TTI logs for 8238_B_2
    [Arguments]   ${sctp_filename}   ${dl_tput}   ${pacing_timer}
    TcpdumpSmod.start_tcpdump_on_smod  filename=${sctp_filename}  smod_master=${true}  smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    Attach UE    UE_2
    BuiltIn.Sleep   10s   reason=Wait for core connection before starting tput
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    Start data transfer   dt_name=DT_DL_1             ue_alias=UE_1                  direction=dl   duration=120s
    ...                   packet_size=1200            throughput=${dl_tput}          protocol=udp
    ...                   iperf_version=3             pacing_timer=${pacing_timer}

    Start data transfer   dt_name=DT_DL_2             ue_alias=UE_2                  direction=dl     duration=120s
    ...                   packet_size=1200            throughput=${dl_tput}          protocol=udp
    ...                   iperf_version=3             pacing_timer=${pacing_timer}

    BuiltIn.Sleep    20s
    check_data_transfer_is_alive    dt_name=DT_DL_1
    check_data_transfer_is_alive    dt_name=DT_DL_2
    Verify average throughput    dt_name=DT_DL_1    tput_min=400Kbits/sec
    Verify average throughput    dt_name=DT_DL_2    tput_min=400Kbits/sec

    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode

    ${attached_rntis}=    find_exactly_x_attached_rntis    ${sctp_logs}   2
    check_prio_14_is_assigned_correctly_after_prio_18   ${tti_file_path}    ${attached_rntis}
    check_highest_class_prio_for_optimized_dtx          ${tti_file_path}    ${attached_rntis}


CB008238-5G-B_4_Multi-UE_interactions_with_delay_sensitive_data_(VoNR)
    check preconditions in scf 8238     params_to_check=${scf_params_b4}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

    Require UE   UE_1   capabilities=${SA_UE_CAPS}
    Require UE   UE_2   capabilities=${SA_UE_CAPS}

    Check TTI logs for 8238_B_4    sctp_filename=L3_call_SA_B_4       dl_tput=${DL_TPUT_B4}
    ...                            pacing_timer=${PACING_TIMER_B4}


Check TTI logs for 8238_B_4
    [Arguments]   ${sctp_filename}   ${dl_tput}   ${pacing_timer}
    TcpdumpSmod.start_tcpdump_on_smod  filename=${sctp_filename}_tput_UE
    ...                                smod_master=${true}  smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    ${tput_ue_sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    TcpdumpSmod.start_tcpdump_on_smod    filename=${sctp_filename}_VoNR_UE
     ...                                 smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_2
    ${vonr_ue_sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Start data transfer   dt_name=DT_DL_1             ue_alias=UE_1                direction=dl      duration=150s
    ...                   packet_size=1200            throughput=${dl_tput}        protocol=udp
    ...                   iperf_version=3             pacing_timer=${pacing_timer}

    BuiltIn.Sleep    20s
    check_data_transfer_is_alive    dt_name=DT_DL_1
    Verify average throughput    dt_name=DT_DL_1    tput_min=1Mbits/sec

    ${auto_responder_number}=     Set variable   +555800903300998
    taf.ue.Start voice call      vc_alias=VC_1    ue_alias=UE_2    to=${auto_responder_number}
    BuiltIn.Sleep   10s

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME}
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode

    ${tput_ue_rnti}=    find_exactly_x_attached_rntis    ${tput_ue_sctp_logs}   1
    ${vonr_ue_rnti}=    find_exactly_x_attached_rntis    ${vonr_ue_sctp_logs}   1
    check_optimized_dtx_interaction_with_vonr   ${tti_file_path}   ${tput_ue_rnti[0]}   ${vonr_ue_rnti[0]}


TC_teardown_B_1
    Detach UE   UE_1
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod


TC_teardown_B_2
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod
    AdminUtils.unlock_all_cells
    Detach UE    UE_1
    Detach UE    UE_2


TC_teardown_B_4
    Detach UE   UE_1
    Detach UE   UE_2
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod
