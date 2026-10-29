*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   updates: Marcin Wolczynski
...   contact: marcin.wolczynski@nokia.com
...   This is the ROBOT KEYWORDS file for CB008238_E

Library            taf.ue
Library            testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils         WITH NAME    AdminUtils
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME    TTIs
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/E/resources/test_specific_keywords.py   WITH NAME    keywords_8238_E
Variables          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/E/resources/test_specific_keywords.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library            testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/test_specific_keywords_9333.py
Library            testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore.DeltaStore   WITH NAME   DeltaStore
Resource           testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot


*** Variables ***
${DL_TPUT_E_LOW}=                     10Mbits/sec
${DL_TPUT_E_HIGH}=                    300Mbits/sec
${PACING_TIMER}=                      11000
${TTI_COLLECTION_TIME}=               60s
${SA_UE_CAPS_E}=                      REAL_UE_SA
${CELL_ID_11}=                           1
${BTS_ID}=                          ${tl.gnbs[0].global_bts_id}
${NRBTS_DIST_NAME}=                 MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
@{CELLS_TO_LOCK_IN_E1}=             5   6    7    8    9


*** Keywords ***
CB008238-5G-E_1_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_SA_mode_FDD_FDD
    AdminUtils.Lock Cells       ${CELLS_TO_LOCK_IN_E1}
    setup buffer based CA
    Require UE   UE_1   capabilities=${SA_UE_CAPS_E}
    attenuation_8238_E3
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    ${rntis}=   find_exactly_x_attached_rntis    ${sctp_logs}   1
    ${tti_file_path_high}=    Collect TTI from traffic   ${DL_TPUT_E_HIGH}
    keywords_8238_E.check_optimized_dtx_for_scell_activated      ${tti_file_path_high}    ${rntis[0]}
    ${tti_file_path_low}=     Collect TTI from traffic   ${DL_TPUT_E_LOW}
    keywords_8238_E.check optimized dtx for scell deactivated   ${tti_file_path_low}     ${rntis[0]}
    ${tti_file_path_low_2}=   Collect TTI from traffic   ${DL_TPUT_E_LOW}
    keywords_8238_E.check_optimized_dtx_for_scell_deactivated    ${tti_file_path_low_2}   ${rntis[0]}

CB008238-5G-E_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_for_SA_mode_for_blind_method_activation_FDD_FDD
    AdminUtils.Lock Cells       ${CELLS_TO_LOCK_IN_E1}
    setup blind CA
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    attenuation_8238_E3
    Require UE   UE_1   capabilities=${SA_UE_CAPS_E}

    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach UE    UE_1
    ${sctp_logs}=    TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    ${tti_file_path_low}=     Collect TTI from traffic   ${DL_TPUT_E_LOW}

    ${rntis}=   find_exactly_x_attached_rntis    ${sctp_logs}   1
    keywords_8238_E.check optimized dtx for scell activated       ${tti_file_path_low}     ${rntis[0]}


Collect TTI from traffic
    [Arguments]   ${tput}
    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                     direction=dl       duration=180s
    ...                   packet_size=1200            throughput=${tput}                protocol=udp
    ...                   iperf_version=3             pacing_timer=${PACING_TIMER}
    BuiltIn.Sleep    30s

    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    BuiltIn.Sleep    ${TTI_COLLECTION_TIME}
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    [Return]   ${tti_file_path}
    Stop data transfer   dt_name=DT_DL


TC_teardown_E
    Detach UE   UE_1
    TTI.teardown_tti_traces_in_streaming_mode
    TcpdumpSmod.teardown_tcpdump_on_smod
    AdminUtils.unlock_all_cells
