*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   updates: Marcin Wolczyns
...   contact: marcin.wolczynski@nokia.com
...   This is the ROBOT KEYWORDS file for CB008238_F

Library            taf.ue
Library            testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils         WITH NAME    AdminUtils
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME    TTI
Library            taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter                  WITH NAME    GnbCounter
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/F/resources/test_specific_keywords.py   WITH NAME    keywords_8238_F
Variables          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/F/resources/test_specific_keywords.py

Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot


*** Variables ***
${DL_TPUT_F4}=                      12Mbits/sec
${DL_TPUT_F7}=                      20Mbits/sec
${PACING_TIMER_F4}=                 500000
${PACING_TIMER_F7}=                 60000
${TTI_COLLECTION_TIME}=             12s
${SA_UE_CAPS_F}=                    REAL_UE_SA
${CELL_ID_CB008238}=                1
${PM_INTERVAL_IN_MINS}=             5


*** Keywords ***
CB008238-5G-F_4
    Setup and check preconditions in scf    params_to_check=${scf_params_f}
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${CELL_ID_CB008238}
    Require UE   UE_1   capabilities=${SA_UE_CAPS_F}
    GnbCounter.wait_for_next_pm_period   interval=${PM_INTERVAL_IN_MINS}

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                    direction=dl       duration=130s
    ...                   packet_size=1200            throughput=${DL_TPUT_F4}         protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER_F4}
    BuiltIn.Sleep    30s

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME}
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    GnbCounter.Wait for next pm period     interval=${PM_INTERVAL_IN_MINS}
    ${pi_dir}=   Collect Counters    log_name=TC_F_4

    ${rntis}=   find_exactly_x_attached_rntis    ${sctp_logs}   1
    check_above_delay_since_last_scheduled    ${tti_file_path}
    check_optimized_dtx_counters    ${pi_dir}   ${CELL_ID_CB008238}   ABOVE


CB008238-5G-F_7
    setup scf 8238 F7
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    BuiltIn.Sleep      10s
    AdminUtils.wait_for_all_cells_on_air_state
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${CELL_ID_CB008238}
    Require UE   UE_1   capabilities=${SA_UE_CAPS_F}
    GnbCounter.wait_for_next_pm_period   interval=${PM_INTERVAL_IN_MINS}

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                    direction=dl       duration=130s
    ...                   packet_size=1200            throughput=${DL_TPUT_F7}         protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER_F7}
    BuiltIn.Sleep    30s

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME}
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    GnbCounter.Wait for next pm period     interval=${PM_INTERVAL_IN_MINS}
    ${pi_dir}=   Collect Counters    log_name=TC_F_7

    ${rntis}=   find_exactly_x_attached_rntis    ${sctp_logs}   1
    keywords_8238_F.check_below_delay_since_last_scheduled    ${tti_file_path}   ${rntis[0]}
    keywords_8238_F.check_optimized_dtx_counters    ${pi_dir}   ${CELL_ID_CB008238}   BELOW


TC_teardown_F_4
    Detach UE   UE_1
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod
    AdminUtils.unlock_all_cells


TC_teardown_F_7
    Detach UE   UE_1
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod
    AdminUtils.unlock_all_cells
