*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   updates: Marcin Wolczynski
...   contact: marcin.wolczynski@nokia.com
...   This is the ROBOT KEYWORDS file for CB008238_C

Library            taf.ue
Library            testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils         WITH NAME    AdminUtils
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME    TTI
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/C/resources/test_specific_keywords.py   WITH NAME    keywords_8238_C
Variables          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/C/resources/test_specific_keywords.py
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore.DeltaStore   WITH NAME   DeltaStore
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot


*** Variables ***
${DL_TPUT_C1_HIGH}=                 100Mbits/sec
${DL_TPUT_C1_LOW}=                  5Mbits/sec
${PACING_TIMER}=                    30000
${DL_TPUT_C6}=                      50Mbits/sec
${TTI_COLLECTION_TIME}=             17s
${SA_UE_CAPS_C}=                    REAL_UE_SA
${BTS_ID}=                          ${tl.gnbs[0].global_bts_id}
${CELL_ID_CB008238}=                1
${NRBTS_DIST_NAME}=                 MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
${NRCELL_DIST_NAME}=                ${NRBTS_DIST_NAME}/NRCELL-${CELL_ID_CB008238}


*** Keywords ***
CB008238-5G-C_1_Single_UE_Data_Schedule_Exceed_dtxPrbThreshold_low_value_and_high_value
    Setup and check preconditions in scf    params_to_check=${scf_params_c1}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${CELL_ID_CB008238}
    Require UE   UE_1   capabilities=${SA_UE_CAPS_C}

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                     direction=dl       duration=130s
    ...                   packet_size=1200            throughput=${DL_TPUT_C1_LOW}      protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    30s

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME}
    ${tti_file_path_LOW}=     TTI.stop_tti_traces_in_streaming_mode    decoded_output_file=${test_name}_LOW_DL_TTI
    Stop data transfer    dt_name=DT_DL

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                     direction=dl       duration=130s
    ...                   packet_size=1200            throughput=${DL_TPUT_C1_HIGH}     protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    30s

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME}
    ${tti_file_path_HIGH}=     TTI.stop_tti_traces_in_streaming_mode    decoded_output_file=${test_name}_HIGH_DL_TTI

    ${rntis}=   find_exactly_x_attached_rntis    ${sctp_logs}   1
    analyze_prb_lower_than_threshold    ${tti_file_path_LOW}
    analyze_prb_higher_than_threshold   ${tti_file_path_HIGH}


CB008238-5G-C_6_Single_UE_Max_Throughput
    setup scf 8238 C6
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${CELL_ID_CB008238}
    Require UE   UE_1   capabilities=${SA_UE_CAPS_C}

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                    direction=dl       duration=130s
    ...                   packet_size=1200            throughput=${DL_TPUT_C6}         protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    60s
    ${dl_tput_kbits_feature_on}=   Get average throughput    dt_name=DT_DL
    Stop data transfer    dt_name=DT_DL

    Deactivate optimized DTX scheduler

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                    direction=dl       duration=130s
    ...                   packet_size=1200            throughput=${DL_TPUT_C6}         protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    60s
    ${dl_tput_kbits_feature_off}=   Get average throughput    dt_name=DT_DL
    Stop data transfer    dt_name=DT_DL

    keywords_8238_C.verify_throughput_with_and_without_8238   ${dl_tput_kbits_feature_on}   ${dl_tput_kbits_feature_off}   error_in_percent=10


Deactivate optimized DTX scheduler
    Log   Start delta commissioning...    console=True
    DeltaStore.initialise_delta_store         name=nr_delta
    DeltaStore.add_parameters_to_delta       ${NRCELL_DIST_NAME}    actDtxOptimizedScheduler=false
    DeltaStore.add_parameters_to_delta       ${NRCELL_DIST_NAME}    actEnhDtxOptimizedScheduler=false

    ${delta_store}=    DeltaStore.collect_delta_store
    DeltaStore.perform_delta_recommissioning    ${delta_store}
    Log   Delta commissioning finished successfully!    console=True


TC_teardown_C_1
    Detach UE   UE_1
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod
    AdminUtils.unlock_all_cells


TC_teardown_C_6
    Detach UE   UE_1
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod
    AdminUtils.unlock_all_cells
