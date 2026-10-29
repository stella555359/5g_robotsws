*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the ROBOT KEYWORDS file for feature 5GC001178_BE for Real UE

Library     taf.ue
Library     ./test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils   WITH NAME   AdminUtils
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2      WITH NAME    L1L2
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py    WITH NAME    TTI
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME   TcpdumpSmod
Library     testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Variables       ./test_specific_keywords.py


*** Keywords ***
[1]5GC001178_BE_13_Proactive_scheduling_4UEs_20MHz_bandwidth
    [Documentation]  The purpose of this test case is to check the proactive scheduling of UEs.
    Setup and check preconditions in scf   params_to_check=${default_scf_params}    bandwidth=20
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_random_one
    Require UEs   2
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    Attach UEs    2
    ${ng_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    BuiltIn.Sleep   15s   reason=Collect TTI traces
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    L1L2.start_gnbmirroring   filename=${test_name}_l1l2.pcap
    Start UL Data Transfer on UEs    num_of_ues=2    duration=5s    throughput=5Mbits/sec
    Start DL Data Transfer on UEs    num_of_ues=2    duration=5s    throughput=5Mbits/sec
    BuiltIn.Sleep   5s
    Start DL Data Transfer on UEs    num_of_ues=2    duration=100s    throughput=200Mbits/sec
    BuiltIn.Sleep   50s   reason=Let traffic run
    Run Keyword and Ignore Error     Verify Average DL Throughput    num_of_ues=2    tput_min=15Mbits/sec
    ${l1l2_logs}=   L1L2.stop_gnbmirroring_and_download_logs


    ${rntis}=    get_attached_rntis    ${ng_logs}
    check_proactive_scheduling_uldl    ${tti_file_path}   ${rntis}

    [Teardown]  Run keywords
    ...         TTI.teardown_tti_traces_in_streaming_mode    AND
    ...         Detach UEs   2                               AND
    ...         AdminUtils.unlock_all_cells


[1]5GC001178_BE_7_MCS_Reduction_4UEs_DL_goodRC_20MHz_bandwidth
    [Documentation]  The purpose of this test case is to check DL MCS reduction due to
    ...              low amount of data in buffer for multi Ues scenario.
    Setup and check preconditions in scf   params_to_check=${default_scf_params}    bandwidth=20
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_random_one
    Require UEs   2
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UEs    2
    ${ng_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Start DL Data Transfer on UEs    num_of_ues=2    duration=100s    throughput=200Mbits/sec
    BuiltIn.Sleep   50s   reason=Let traffic run
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep   10s
    ${tti_filepath_high_dl}=     TTI.stop_tti_traces_in_streaming_mode    decoded_output_file=${test_name}_HIGH_DL_TTI
    Run Keyword and Ignore Error    Stop DL Data Transfer on UEs     num_of_ues=2

    Start DL Data Transfer on UEs    num_of_ues=2    duration=100s    throughput=5Mbits/sec
    BuiltIn.Sleep    30s
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep   10s
    ${tti_filepath_low_dl}=     TTI.stop_tti_traces_in_streaming_mode    decoded_output_file=${test_name}_LOW_DL_TTI

    ${rntis}=    get_attached_rntis        ${ng_logs}
    check_used_mcs_equals_proposed         ${tti_filepath_high_dl}    ${rntis}
    check_used_mcs_is_less_than_proposed   ${tti_filepath_low_dl}     ${rntis}
    # Check prb allocation is the same for all dl   ${tti_filepath_low_dl}    ${rntis}   not needed in this TC

    [Teardown]  Run keywords
    ...         TTI.teardown_tti_traces_in_streaming_mode     AND
    ...         TcpdumpSmod.teardown_tcpdump_on_smod          AND
    ...         Detach UEs   2                                AND
    ...         AdminUtils.unlock_all_cells


[1]5GC001178_BE_3_Attach_UE_GoodCondition_WithoutTraffic_CSI-RS_CSI report_check_20MHz_bandwidth
    [Documentation]  The puropose of the test is to check if CSI-RS in SS slot are received by the UE and the
     ...             CSI reports for channel measurement are sent periodically by the UE on the PUCCH.
    Setup and check preconditions in scf   params_to_check=${default_scf_params}    bandwidth=20
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_random_one
    Require UE   UE_1   capabilities=REAL_UE
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    ${ng_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    L1L2.start_gnbmirroring   filename=${test_name}.pcap
    BuiltIn.Sleep  6s
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    ${l1l2_logs}=   L1L2.stop_gnbmirroring_and_download_logs

    ${rntis}=    get_attached_rntis    ${ng_logs}
    check_csi_rs_periodicity           ${l1l2_logs}
    ${csi_msgs}=   check_csi_sr_report_periodicity    ${tti_file_path}    ${rntis}
    check_csi_pucch_configuration      ${l1l2_logs}   ${csi_msgs}

    [Teardown]  Run keywords
    ...         TTI.teardown_tti_traces_in_streaming_mode    AND
    ...         TcpdumpSmod.teardown_tcpdump_on_smod         AND
    ...         Detach UEs   1                               AND
    ...         AdminUtils.unlock_all_cells


[1]5GC001178_BE_10_RACH_Priority_Handling_2UEs_goodRC_20MHz_bandwidth
    [Documentation]  The purpose of this TC is to check the RACH procedure for
    ...              initial attach of two UEs on the same timeslot.
    Setup and check preconditions in scf   params_to_check=${default_scf_params}    bandwidth=20
    Require UEs  2
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    L1L2.start_gnbmirroring   filename=${test_name}_l1l2.pcap
    BuiltIn.Sleep   5s
    Attach UEs   2
    Sleep   5s
    ${l1l2_logs}=   L1L2.stop_gnbmirroring_and_download_logs
    ${ng_logs}=     TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode

    ${rntis}=    get_attached_rntis               ${ng_logs}
    check_rach_msg1_is_sent_on_single_occasion    ${l1l2_logs}
    check_rach_msg2_sent_according_to_msg1_peak_metric  ${tti_file_path}     ${rntis}
    Log  RACH proceure finished successfully!  console=True

    [Teardown]  Run Keywords
    ...         TTI.teardown_tti_traces_in_streaming_mode     AND
    ...         TcpdumpSmod.teardown_tcpdump_on_smod          AND
    ...         Detach UEs   2


[1]5GC001178_BE_4_2UE_UL&DL_TimingCheck_UlDataPucchReceiveReq and UlDataPucchReceiveRespPs_CSI-RS_SSBslot_check_CSI-RS_CSI_report_20MHz_bandwidth
    [Documentation]  The purpose of this test case is to validate the timing of UlDataPucchReceiveRespPs
    ...              and UlDataPucchReceiveReq. They should be sent on the same SFN and slot.
    Setup and check preconditions in scf   params_to_check=${default_scf_params}    bandwidth=20
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    Require UEs   2
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UEs    2
    ${ng_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Start UL Data Transfer on UEs    num_of_ues=2    duration=100s    throughput=100Mbits/sec
    Start DL Data Transfer on UEs    num_of_ues=2    duration=100s    throughput=100Mbits/sec
    Sleep   50s   reason=Let traffic run
    Run Keyword and Ignore Error     Verify Average UL Throughput    num_of_ues=2    tput_min=20Mbits/sec
    Run Keyword and Ignore Error     Verify Average DL Throughput    num_of_ues=2    tput_min=40Mbits/sec

    L1L2.start_gnbmirroring   filename=${test_name}_l1l2.pcap
    Sleep  10s   reason=Collect L1L2 logs
    ${l1l2_logs}=   L1L2.stop_gnbmirroring_and_download_logs

    ${rntis}=    get_attached_rntis    ${ng_logs}
    check_pucch_timing                 ${l1l2_logs}

    [Teardown]  Run Keywords
    ...         TcpdumpSmod.teardown_tcpdump_on_smod     AND
    ...         Detach UEs   2


[1]5GC001178_BE_6_SR_handling_10UE_UL_DL_20MHz_bandwidth
    [Documentation]  The purpose of this test case is to validate scheduling request handling.
    Setup and check preconditions in scf   params_to_check=${default_scf_params}    bandwidth=20
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_random_one
    Require UEs    2
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UEs     2
    ${ng_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Start UL Data Transfer on UEs    num_of_ues=2    duration=100s    throughput=50Mbits/sec
    Start DL Data Transfer on UEs    num_of_ues=2    duration=100s    throughput=50Mbits/sec
    Sleep   50s   reason=Let traffic run
    Run Keyword and Ignore Error     Verify Average UL Throughput    num_of_ues=2    tput_min=10Mbits/sec
    Run Keyword and Ignore Error     Verify Average DL Throughput    num_of_ues=2    tput_min=10Mbits/sec

    L1L2.start_gnbmirroring   filename=${test_name}_traffic.pcap
    Sleep  10s   reason=Collect L1L2
    ${l1l2_logs}=   L1L2.stop_gnbmirroring_and_download_logs


    ${rntis}=   get_attached_rntis   ${ng_logs}
    check_first_pucch_receiver_responses_for_each_ue   ${l1l2_logs}   ${rntis}

    [Teardown]  Run Keywords
    ...         AdminUtils.unlock_all_cells              AND
    ...         TcpdumpSmod.teardown_tcpdump_on_smod     AND
    ...         Detach UEs   2
