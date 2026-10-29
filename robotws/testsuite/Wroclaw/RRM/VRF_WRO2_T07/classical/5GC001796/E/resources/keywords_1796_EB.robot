*** Settings ***
Documentation
...   author: Maciej Dzimira
...   contact: maciej.dzimira@nokia.com
...   This is the ROBOT KEYWORDS file for feature 5GC001796-EB

Library         taf.ue
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001796/E/resources/test_specific_keywords.py
Library         testsuite/Wroclaw/RRM/resources/tti_verification/csv_verification.py
Library         testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py                WITH NAME    TTI
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001796/E/resources/test_specific_keywords.py
Variables       ./mcs_tables_abil.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot


*** Keywords ***
[1]5GC001796_EB_TC42_ULDL_LA_64QAM-table_MIMO_4x4_PTRS-ON_MaxTput_20min_BW-20MHz_SA
    Setup and check preconditions in scf    params_to_check=${scf_params_default}    bandwidth=20
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    Attach Ue    UE_1
    Log to console    Start ULDL traffic for 20 minutes.
    ${duration}=    Set variable    1200s
    Start Data Transfer   dt_name=DT_UL             ue_alias=UE_1
    ...                   direction=ul              duration=${duration}
    ...                   packet_size=1200          buffer=4M
    ...                   throughput=150Mbits/sec   protocol=udp
    Start Data Transfer   dt_name=DT_DL             ue_alias=UE_1
    ...                   direction=dl              duration=${duration}
    ...                   packet_size=1200          buffer=4M
    ...                   throughput=350Mbits/sec   protocol=udp
    BuiltIn.Sleep     ${duration}
    Verify Average Throughput    dt_name=DT_UL    tput_min=120Mbits/sec
    Verify Average Throughput    dt_name=DT_DL    tput_min=300Mbits/sec

    [Teardown]   Run Keywords
    ...          Stop Data Transfer   DT_UL                                                              AND
    ...          Stop Data Transfer   DT_DL                                                              AND
    ...          Detach UE    UE_1                                                                       AND
    ...          TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod


[1]5GC001796_EB_TC36_UL_LA_64QAM-table_PTRS-ON_from_Edge_to_Near_Cell_radio_condition_NIDD_non_defaultBW-20MHz_SA
    Setup and check preconditions in scf    params_to_check=${scf_params_default}    bandwidth=20
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    Attach Ue    UE_1
    Start Data Transfer   dt_name=DT_UL             ue_alias=UE_1
    ...                   direction=ul              duration=120s
    ...                   packet_size=1200          buffer=4M
    ...                   throughput=150Mbits/sec   protocol=udp
    BuiltIn.Sleep    15s
    Verify Average Throughput    dt_name=DT_UL    tput_min=120Mbits/sec

    Set attenuation    10
    Gradually increase attenuation      init_value=10    max_value=${tl.max_atten_value}    step=2    interval=1
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    Gradually decrease attenuation      init_value=${tl.max_atten_value}    min_value=10    step=2    interval=1
    BuiltIn.Sleep   5s
    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode

    Check UL MCS mapping    ${tti_file_path}    ${mcs_tables_abil}    PTRS_ON    64QAM    20    RANK2

    [Teardown]   Run Keywords
    ...          Stop Data Transfer   DT_UL                                       AND
    ...          Detach UE    UE_1                                                AND
    ...          TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod             AND
    ...          TTI.teardown_tti_traces_in_streaming_mode


[1]5GC001796_EB_TC46_UL_LA_64QAM-table_PTRS-ON_from_Near_to_Edge_Cell_radio_condition_SingleTX_BW-20MHz_SA
    Setup and check preconditions in scf    params_to_check=${scf_params_default}    bandwidth=20
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    Attach Ue    UE_1
    Start Data Transfer   dt_name=DT_UL             ue_alias=UE_1
    ...                   direction=ul              duration=120s
    ...                   packet_size=1200          buffer=4M
    ...                   throughput=150Mbits/sec   protocol=udp
    BuiltIn.Sleep    15s
    Verify Average Throughput    dt_name=DT_UL    tput_min=55Mbits/sec

    Set attenuation    10
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    Gradually increase attenuation      init_value=10    max_value=${tl.max_atten_value}    step=2    interval=1
    BuiltIn.Sleep    5s

    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    Check UL MCS mapping    ${tti_file_path}    ${mcs_tables_abil}    PTRS_ON    64QAM    20    RANK1

    [Teardown]   Run Keywords
    ...          Stop Data Transfer   DT_UL                                         AND
    ...          Detach UE    UE_1                                                  AND
    ...          TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod               AND
    ...          TTI.teardown_tti_traces_in_streaming_mode


[1]5GC001796_EB_TC115_DL_LA_256QAM-table_MIMO_4x4_PTRS-OFF_from_Near_to_Edge_Cell_radio_condition_NIDD_non_default_BW-20MHz_SA
    Setup and check preconditions in scf     params_to_check=${scf_params_no_default}    bandwidth=20
    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    Attach Ue    UE_1
    Start Data Transfer   dt_name=DT_DL             ue_alias=UE_1
    ...                   direction=dl              duration=120s
    ...                   packet_size=1200          buffer=4M
    ...                   throughput=350Mbits/sec   protocol=udp
    BuiltIn.Sleep    15s
    Verify Average Throughput    dt_name=DT_DL    tput_min=300Mbits/sec

    Set attenuation    10
    TTI.start_tti_traces_in_streaming_mode    collector_type=sbts
    Gradually increase attenuation      init_value=10    max_value=${tl.max_atten_value}    step=2    interval=1
    BuiltIn.Sleep    5s

    ${tti_file_path}=     TTI.stop_tti_traces_in_streaming_mode
    Check DL MCS mapping    ${tti_file_path}    ${mcs_tables_abil}    PTRS_OFF    256QAM    20    RANK4

    [Teardown]   Run Keywords
    ...          Stop Data Transfer   DT_DL                                          AND
    ...          Detach UE    UE_1                                                   AND
    ...          TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod                AND
    ...          TTI.teardown_tti_traces_in_streaming_mode
