*** Settings ***
Documentation
...  author: Karol palac
...  contact: karol.apalac@nokia.com


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CNI-130245-C/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot


*** Variables ***
${resource_path_CNI-130245}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CNI-130245-C/resources


*** Keywords ***
[1]CNI-130245-C-Config_and_block_periodic_act_of_interfreq_A4_measurement_for_mobility_to_higher_prio_NR_freq_NSA
    [Documentation]    The purpose of this test is to check whether A4 measurements are being configured and blocked
    ...                accordingly to parameters (NSA: cell 5G 700 + LTE 20 -> cell 5G 400 + LTE 20)
    Load scf for NR    ${resource_path_CNI-130245}    SCFs    scf_CNI-130245-C.xml
    Set test variable  ${test_name}  CNI-130245
    Setup attenuators
    Set attenuation and check    lines=${lines_gNB_215_AHFIB_2}  value=0
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_7}  value=15
    Attach Ue     UE_1
    Sleep    5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=100s    throughput=50Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=100s    throughput=50Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Sleep    10s
    Log to Console  >Performing handover<
    Set attenuation and check    lines=${lines_gNB_215_AVHA_4}   value=30
    Sleep    1s
    Set attenuation and check    lines=${lines_gNB_215_AVHA_4}   value=20
    Sleep    1s
    Set attenuation and check    lines=${lines_gNB_215_AVHA_4}   value=10
    Sleep    1s
    Set attenuation and check    lines=${lines_gNB_215_AVHA_4}   value=0
    Sleep    15s
    Log to Console  >Handover has been triggered.<
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Verify PM Counters 130245
