*** Settings ***
Documentation
...   author: xxx xxx
...   contact: xxx.xxx@nokia.com
...   This is the ROBOT KEYWORDS file for feature 5GC001178_BB for Real UE

Library     taf.ue
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils   WITH NAME   AdminUtils
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2    WITH NAME    L1L2
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME   TcpdumpSmod
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/5GC001178/resources/test_specific_keywords.py
Library     testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/harq_verification/interface.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py

Variables   ./test_specific_keywords.py


*** Keywords ***
[1]5GC001178_BB_TC06_5GC001178_BB_DL_UL_HARQ_With_No_HARQ_Retransmissions
    Setup and check preconditions in scf   params_to_check=${default_scf_params}    bandwidth=20
    AdminUtils.lock_all_cells_except_random_one
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Require UE   UE_1   capabilities=REAL_UE
    Attach UE    UE_1
    ${ng_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Start Data Transfer     dt_name=DT_UL               ue_alias=UE_1
    ...                     direction=UL                duration=90s
    ...                     throughput=200Mbits/sec     protocol=udp
    ...                     packet_size=1200
    Start Data Transfer     dt_name=DT_DL               ue_alias=UE_1
    ...                     direction=DL                duration=60s
    ...                     throughput=200Mbits/sec     protocol=udp
    ...                     packet_size=1200
    BuiltIn.Sleep    15s
    Run keyword and ignore error   Check Data Transfer Is Alive   DT_UL
    Run keyword and ignore error   Check Data Transfer Is Alive   DT_DL
    Verify Average Throughput    dt_name=DT_UL    tput_min=40Mbits/sec
    Verify Average Throughput    dt_name=DT_DL    tput_min=100Mbits/sec

    L1L2.start_gnbmirroring   filename=${test_name}_l1l2.pcap
    BuiltIn.Sleep  10s   reason=Collecting L1L2 logs
    ${l1l2_logs}=   L1L2.stop_gnbmirroring_and_download_logs
    ${rntis}=    get_attached_rntis    ${ng_logs}
    Check positive harq transmissions   pcap_file=${l1l2_logs}

    [Teardown]   Run Keywords
    ...          AdminUtils.unlock_all_cells                    AND
    ...          Stop Data Transfer   DT_UL                     AND
    ...          Stop Data Transfer   DT_DL                     AND
    ...          Detach UE    UE_1                              AND
    ...          TcpdumpSmod.teardown_tcpdump_on_smod


[1]5GC001178_BB_TC05_5GC001178_BB_DL_UL_HARQ_With_HARQ_Retransmissions
    Setup and check preconditions in scf   params_to_check=${default_scf_params}    bandwidth=20
    AdminUtils.lock_all_cells_except_random_one
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_ng_logs.pcap    smod_master=${true}    smod_slave=${tl.smod_slave}
    Require UE   UE_1   capabilities=REAL_UE
    Attach UE    UE_1
    ${ng_logs}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Start Data Transfer     dt_name=DT_UL               ue_alias=UE_1
    ...                     direction=UL                duration=100s
    ...                     throughput=200Mbits/sec     protocol=udp
    ...                     packet_size=1200
    Start Data Transfer     dt_name=DT_DL               ue_alias=UE_1
    ...                     direction=DL                duration=100s
    ...                     throughput=200Mbits/sec     protocol=udp
    ...                     packet_size=1200
    BuiltIn.Sleep    15s
    Verify Average Throughput    dt_name=DT_UL    tput_min=40Mbits/sec
    Verify Average Throughput    dt_name=DT_DL    tput_min=100Mbits/sec

    Set Attenuation   20
    ${middle_atten_value} = 	Evaluate 	${tl.max_atten_value} - 10
    Gradually increase attenuation   init_value=40   max_value=${tl.max_atten_value}   step=2  interval=1

    L1L2.start_gnbmirroring   filename=${test_name}_l1l2.pcap
    Gradually decrease attenuation      init_value=${tl.max_atten_value}    min_value=${middle_atten_value}    step=2    interval=1
    BuiltIn.Sleep   5s
    Gradually increase attenuation      init_value=${middle_atten_value}    max_value=${tl.max_atten_value}    step=1    interval=1
    BuiltIn.Sleep   5s
    ${l1l2_logs}=   L1L2.stop_gnbmirroring_and_download_logs
    Check negative harq transmissions   pcap_file=${l1l2_logs}   threshold=96

    [Teardown]   Run Keywords
    ...          AdminUtils.unlock_all_cells                 AND
    ...          Stop Data Transfer   DT_UL                  AND
    ...          Stop Data Transfer   DT_DL                  AND
    ...          Detach UE    UE_1                           AND
    ...          TcpdumpSmod.teardown_tcpdump_on_smod        AND
    ...          nullify_attenuation_on_all_ports
