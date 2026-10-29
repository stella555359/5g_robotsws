*** Settings ***
Documentation
...  author: Karol palac
...  contact: karol.apalac@nokia.com


Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CNI-131238-C/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot


*** Keywords ***
[1]CNI-131238-C-Config_of_interfreq_A4_measurement_for_mobility_to_higher_prio_NR_freq_SA
    [Documentation]    The purpose of this test is to check whether A4 measurements are being configured and blocked
    ...                accordingly to parameters (SA: cell 5G 700 -> cell 5G 400)
    Set test variable  ${test_name}  CNI-131238
    Setup attenuators
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_7}  value=0
    Attach Ue     UE_2
    Sleep    5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_2    direction=dl    duration=100s    throughput=50Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_2    direction=ul    duration=100s    throughput=50Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Sleep    10s
    Log to Console  >Performing handover<
    Set attenuation and check    lines=${lines_gNB_215_AVHA_4}   value=0
    Sleep    10s
    Log to Console  >Handover has been triggered.<
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Verify PM Counters 131238
