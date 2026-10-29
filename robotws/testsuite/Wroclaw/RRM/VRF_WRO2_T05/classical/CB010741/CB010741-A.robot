*** Settings ***
Documentation
...  author: Karol palac
...  contact: karol.palac@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010741/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010741/resources/keywords.py


*** Variables ***
${resource_path_10741}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010741/resources


*** Keywords ***
[1]CB010741_A_B9_Ul_Buffer_Triggered_A1_And_A4_Measurement_Based_SCell_Addition
    [Documentation]    This test verifies that A1 and A4 measurement based SCell Addition can be triggered
    ...                due to UL buffer overflow.
    Load scf for NR    ${resource_path_10741}    SCFs    scf_10741-A_B9.xml
    Set test variable  ${test_name}  CB010741-A_B9
    Setup attenuators
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=15
    Deattenuate scells 10741
    Prepare and start new DCAP       dcap_host=10.44.180.37  bts_mplane=10.44.137.26   nrCells=NRCELL_R-800 NRCELL_R-100
    Attach Ue     UE_3
    Sleep         10s
    ${PCI_UE3}=       ute_ue.Get Ue Info    UE_3   PCI
    Log to Console    UE attached PCI now: ${PCI_UE3}
    Start Data Transfer    dt_name=DL_SA    ue_alias=UE_3    direction=dl    duration=500s    throughput=500Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep  15s
    Run keyword and ignore error    Stop Data Transfer     DL_SA
    Detach Ue     UE_3
    Set attenuation and check    lines=${lines_gNB_215_AHFIB_1}  value=0
    Sleep  5s
    Attach Ue     UE_3
    Sleep  1s
    Start Data Transfer    dt_name=UL_SA    ue_alias=UE_3    direction=ul    duration=500s    throughput=300Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Start Data Transfer    dt_name=DL_SA2    ue_alias=UE_3    direction=dl    duration=500s    throughput=600Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep    90s
    Run keyword and ignore error    Stop Data Transfer     DL_SA
    Run keyword and ignore error    Stop Data Transfer     DL_SA2
    Run keyword and ignore error    Stop Data Transfer     UL_SA
    Detach Ue     UE_3
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Verify JSON file from DCAP  expected_messages=${messages_10741_A_B9}
    Verify PM Counters 10741-A_B9

