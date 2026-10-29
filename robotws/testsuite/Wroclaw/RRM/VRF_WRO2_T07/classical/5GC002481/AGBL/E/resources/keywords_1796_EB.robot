*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the ROBOT KEYWORDS file for feature 5GC002481_AGBL_5GC001796-EB

Library   taf.ue
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001796/E/resources/test_specific_keywords.py  WITH NAME  1796E
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py                WITH NAME    TTI
Library   testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library   testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils         WITH NAME    AdminUtils
Library   testsuite/Wroclaw/RRM/resources/tti_verification/csv_verification.py
Library   testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/test_specific_keywords_9333.py

Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001796/E/resources/test_specific_keywords.py
Variables       ./mcs_tables_abio.py

*** Variables ***
@{Cells_to_be_locked}=     3

*** Keywords ***
5GC002481_AGBL_5GC001796_EB_TC46_UL_LA_64QAM-table_PTRS-ON_from_Near_to_Edge_Cell_radio_condition_SingleTX_BW-20MHz_SA
    Setup and check preconditions in scf    params_to_check=${scf_params_default}    bandwidth=20
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    AdminUtils.Lock Cells    ${Cells_to_be_locked}
    Require Ue   UE_1   capabilities=REAL_UE_SA
    Attach Ue    UE_1
    Start Data Transfer   dt_name=DT_UL             ue_alias=UE_1
    ...                   direction=ul              duration=120s
    ...                   packet_size=1200          buffer=4M
    ...                   throughput=100Mbits/sec   protocol=udp
    BuiltIn.Sleep    15s
    Verify Average Throughput    dt_name=DT_UL    tput_min=55Mbits/sec

    Set attenuation    10
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    Gradually increase attenuation      init_value=10    max_value=${tl.max_atten_value}    step=4    interval=1
    BuiltIn.Sleep    5s

    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    ${bts_branch}=     assign_release_version

    Run Keyword If   '${bts_branch}' >= 'SBTS22R4'
    ...              Check UL MCS mapping    ${tti_file_path}    ${mcs_tables_abio_updated}    PTRS_ON    64QAM    20    RANK1
    ...              ELSE
    ...              Check UL MCS mapping    ${tti_file_path}    ${mcs_tables_abio}    PTRS_ON    64QAM    20    RANK1

    [Teardown]   Run Keywords
    ...          Stop Data Transfer   DT_UL                                       AND
    ...          Detach UE    UE_1                                                AND
    ...          TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod             AND
    ...          TTI.teardown_tti_traces_in_streaming_mode                        AND
    ...          AdminUtils.unlock_all_cells
