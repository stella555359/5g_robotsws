*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the ROBOT KEYWORDS file for CB008238_D

Library     taf.ue
Library     testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils         WITH NAME    AdminUtils
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME    TTI
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/A/resources/test_specific_keywords.py
...         WITH NAME    keywords_8238_A
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/D/resources/test_specific_keywords.py
...         WITH NAME    keywords_8238_D
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/B/resources/test_specific_keywords.py
...         WITH NAME    keywords_8238_B
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/D/resources/test_specific_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot


*** Variables ***
${DL_TPUT_D1}=                      35Mbits/sec
${PACING_TIMER}=                    11000
${SA_UE_CAPS_D}=                    REAL_UE_SA
${CELL_ID_CB008238}=                1


*** Keywords ***
CB008238-5G-D_01_DTX_Scheduler_Enabling_Disabling_Based_On_Ues_In_C1_List
    keywords_8238_B.check preconditions in scf 8238    params_to_check=${scf_params_d1}
    Nullify attenuation on all ports
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    AdminUtils.lock_all_cells_except_chosen_one   chosen_cell_id=${CELL_ID_CB008238}
    Log to console  require ue 1
    Require UE   UE_1   capabilities=${SA_UE_CAPS_D}
    Log to console  require ue 2
    Require UE   UE_2   capabilities=${SA_UE_CAPS_D}

    Log to console  start tcpdump
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    Log to console  attach ue 1
    Attach UE    UE_1
    Log to console  attach ue 2
    Attach UE    UE_2
    BuiltIn.Sleep   30s
    Log to console  stop tcpdump
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Log to console  start data transfer 1
    Log to console  start tti
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep   5s
    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                    direction=dl       duration=230s
    ...                   packet_size=1200            throughput=${DL_TPUT_D1}         protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    Log to console  start data transfer 2
    Start data transfer   dt_name=DT_DL_2             ue_alias=UE_2                    direction=dl       duration=230s
    ...                   packet_size=1200            throughput=${DL_TPUT_D1}         protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    Log to console  sleep 20s
    BuiltIn.Sleep    20s

    Log to console  stop tti
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode

    Stop data transfer    dt_name=DT_DL
    Stop data transfer    dt_name=DT_DL_2

    ${rntis}=   find_exactly_x_attached_rntis    ${sctp_logs}   2
    verify_csi_size_threshold_is_reached    ${tti_file_path}
    keywords_8238_A.check_highest_class_prio_for_optimized_dtx    ${tti_file_path}   ${rntis}


TC_teardown_D_1
    Detach UE   UE_1
    Detach UE   UE_2
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod
    AdminUtils.unlock_all_cells
