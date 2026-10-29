*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the ROBOT KEYWORDS file for feature 5GC002481_5GC001796_B

Library    taf.ue
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME   TcpdumpSmod
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py                WITH NAME    TTI
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_lte.TcpdumpLte      WITH NAME    TcpdumpLte
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC002481/AGBL/B/resources/test_specific_keywords.py
Library    testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Variables  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC002481/AGBL/B/resources/test_specific_keywords.py


*** Keywords ***
5GC002481_AGBL_5GC001796_BB_TC73_UL_LA_iniDeltaSinr_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-5MHz_NSA
    [Documentation]  check that during the transient phase improvement of 1796-B is applied and update of iniDeltaSinr
    ...              occurs for MCS different than highest and lowest MCS when NIDD parameter is set to TRUE (default value)
    Setup and check preconditions in scf   params_to_check=${default_scf_params}    bandwidth=5
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    TcpdumpLte.start_tcpdump_on_lte   filename=${test_name}_nsa_attach_logs.pcap
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    Require UE   UE_1   capabilities=REAL_UE_NSA
    Attach UE    UE_1
    Start Data Transfer
    ...     dt_name=DT_UL
    ...     ue_alias=UE_1
    ...     direction=UL
    ...     duration=380s
    ...     throughput=200Mbits/sec
    ...     protocol=udp
    ...     packet_size=1200
    BuiltIn.Sleep    15s
    Verify Average Throughput    dt_name=DT_UL    tput_min=5Mbits/sec

    Gradually increase attenuation      init_value=0    max_value=23    step=2    interval=1
    BuiltIn.Sleep   15s
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode

    Check that laIniDelta is updated correctly    ${tti_file_path}
    [Teardown]   Run Keywords
    ...          Detach UE    UE_1                                           AND
    ...          TcpdumpLte.stop_tcpdump_and_download_logs_from_lte          AND
    ...          TTI.teardown_tti_traces_in_streaming_mode                   AND
    ...          nullify_attenuation_on_all_ports


5GC002481_AGBL_5GC001796_BB_TC76_DL_LA_iniDeltaCqi_Calculation_Updated_Case_different_MCS0_or_MaxMCS_BW-15MHz_SA
    [Documentation]  check that during the transient phase improvement of 1796-B is applied and update of iniDeltaCqi
    ...              occurs for MCS different than highest and lowest MCS when NIDD parameter is set to TRUE (default value)
    Setup and check preconditions in scf   params_to_check=${default_scf_params}    bandwidth=15
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    Require UE   UE_1   capabilities=REAL_UE_SA
    Attach UE    UE_1
    Start Data Transfer
    ...     dt_name=DT_DL
    ...     ue_alias=UE_1
    ...     direction=DL
    ...     duration=60s
    ...     throughput=500Mbits/sec
    ...     protocol=udp
    ...     packet_size=1200
    BuiltIn.Sleep   15s
    Verify Average Throughput    dt_name=DT_DL    tput_min=5Mbits/sec

    Gradually increase attenuation      init_value=10    max_value=23    step=2    interval=1
    BuiltIn.Sleep   10s
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode

    Check that laIniDelta is updated correctly    ${tti_file_path}
    [Teardown]   Run Keywords
    ...          Detach UE    UE_1                                                   AND
    ...          TTI.teardown_tti_traces_in_streaming_mode                           AND
    ...          TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod                AND
    ...          nullify_attenuation_on_all_ports
