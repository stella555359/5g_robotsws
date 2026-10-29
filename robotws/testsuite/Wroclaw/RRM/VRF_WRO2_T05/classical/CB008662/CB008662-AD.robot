*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This subfeature validates adaptive retransmission feature CB008662 without change of modulation order.


Library         ute_ue
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/resources/keywords_8662.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/resources/keywords.robot

*** Variables ***
${resource_path_8662-A}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008662/resources
${tput_deviation}          10%

*** Keywords ***
[1]CB008662-AD_1_Basic_algoritm_without_change_of_modulation_order_in_ABIL_DL_256QAM
    [Documentation]  This user scenario validates the basic algorithm of the adaptive retransmission scheme for
    ...              DL transmissions on LONER with 256QAM enabled.
    # Load scf for NR    ${resource_path_8662-A}    SCFs    scf_8662-AD.xml
    Delta commissioning 8663 T153
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Setup attenuators
    Set attenuation for 8622-AD_1
    Set test variable  ${test_name}  CB008662-AD_1
    Attach UE    UE_2
    Sleep  5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_2    direction=dl    duration=300s    throughput=50Mbits/sec
    ...                    protocol=tcp
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_2    direction=ul    duration=300s    throughput=50Mbits/sec
    ...                    protocol=tcp
    Start New L1L2 Logs
    Continuous change of radio conditions for 8662-AD
    Stop New L1L2 Logs And Download PCAP    dir=${OUTPUT DIR}/PCAPs/${TEST NAME}.pcap
    Await Data Transfer Finish   DT_DL_SA
    Get Average Throughput       DT_DL_SA
    Await Data Transfer Finish   DT_UL_SA
    Get Average Throughput       DT_UL_SA
    Verify reserved MCS for downlink
    Verify PM counters 8662-A
    [Teardown]    Run keyword
    ...           Run keyword and ignore error    Detach UEs Used By Test
