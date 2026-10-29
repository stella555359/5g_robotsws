*** Settings ***
Documentation
...  author: Kamil Kluz
...  contact: kamil.kluz@nokia.com
...  Description: These TC's are validating CB008662 subfeature parity with ABIP BB-MOD


Library         ute_ue
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/resources/keywords_8662.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/resources/keywords.robot

*** Variables ***
${resource_path_8662-A}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/resources
${tput_deviation}          10%
${ABIP}                    True

*** Keywords ***
[1]CB008662-A_1_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_LOKI_ABIP
    [Documentation]  This user scenario validates the basic algorithm of the adaptive retransmission scheme for
    ...              UL transmissions on LOKI
    Load scf for NR    ${resource_path_8662-A}    SCFs    scf_8662-A_1_AB2_ABIP.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Setup attenuators
    Set attenuation for 8622-A_1  ABIP=${ABIP}
    Set test variable  ${test_name}  CB008662-A_1
    Start syslog collection
    Attach UE    UE_2
    Sleep  5s
    Start ULDL UDP SA   50Mbits/sec   50MBits/sec   150s
    ${start_tput_date}= 	Get Current Date   result_format=epoch
    Start New L1L2 Logs
    Continuous change of radio conditions   ABIP=${ABIP}
    Stop New L1L2 Logs And Download PCAP    dir=${OUTPUT DIR}/PCAPs/${TEST NAME}.pcap
    Await Data Transfer Finish   DT_DL_SA
    Get Average Throughput       DT_DL_SA
    Await Data Transfer Finish   DT_UL_SA
    Get Average Throughput       DT_UL_SA
    Verify reserved MCS for uplink
    Verify PM counters 8662-A
    [Teardown]    Run keyword
    ...           Run keyword and ignore error    Detach UEs Used By Test

[1]CB008662-A_2_A#B2_basic_algoritm_without_change_of_modulation_order_in_UL_DftSOfdm_ABIP
    [Documentation]  This user scenario validates the basic algorithm of the adaptive retransmission scheme for
    ...              UL transmissions on LOKI
    Load scf for NR    ${resource_path_8662-A}    SCFs    scf_8662-A_1_AB2_ABIP.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Setup attenuators
    Set attenuation for 8622-A_1  ABIP=${ABIP}
    Set test variable  ${test_name}  CB008662-A_2
    Attach UE    UE_2
    Sleep  5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_2    direction=dl    duration=150s    throughput=50Mbits/sec
    ...                    protocol=tcp
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_2    direction=ul    duration=300s    throughput=50Mbits/sec
    ...                    protocol=tcp
    ${start_tput_date}= 	Get Current Date   result_format=epoch
    Start New L1L2 Logs
    Sleep  3s
    Continuous change of radio conditions  ABIP=${ABIP}
    Stop New L1L2 Logs And Download PCAP    dir=${OUTPUT DIR}/PCAPs/${TEST NAME}.pcap
    Await Data Transfer Finish   DT_DL_SA
    Get Average Throughput       DT_DL_SA
    Await Data Transfer Finish   DT_UL_SA
    Get Average Throughput       DT_UL_SA
    Verify reserved MCS for uplink
    Verify PM counters 8662-A
    [Teardown]    Run keyword
    ...           Run keyword and ignore error    Detach UEs Used By Test

[1]CB008662-A_8_A#B6_Interworking_with_Carrier_Aggregation_ABIP
    [Documentation]  This user scenario validates the interworking between the Carrier Aggregation
    ...              feature and the adaptive retransmission feature CB008662.
    Load scf for NR    ${resource_path_8662-A}    SCFs    scf_8662-A_8_AB6_ABIP.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Setup attenuators
    Set attenuation for 8622-A_8   ABIP=${ABIP}
    Set test variable  ${test_name}  CB008662-A_8
    Attach UE    UE_2
    Sleep  5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_2    direction=dl    duration=150s    throughput=150Mbits/sec
    ...                    protocol=tcp
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_2    direction=ul    duration=400s    throughput=50Mbits/sec
    ...                    protocol=tcp
    ${start_tput_date}= 	Get Current Date   result_format=epoch
    Start New L1L2 Logs
    Sleep    3s
    Continuous change of radio conditions for CA   ABIP=${ABIP}
    Stop New L1L2 Logs And Download PCAP    dir=${OUTPUT DIR}/PCAPs/${TEST NAME}.pcap
    Stop Data Transfer           DT_DL_SA
    Get Average Throughput       DT_DL_SA
    Stop Data Transfer           DT_UL_SA
    Get Average Throughput       DT_UL_SA
    Verify reserved MCS for uplink
    Verify PM counters 8662-A for CA case
    [Teardown]    Run keyword
    ...           Run keyword and ignore error    Detach UEs Used By Test
