*** Settings ***
Documentation
...  author: Karol palac
...  contact: karol.palac@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/kw_2640.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/resources/keywords.py


*** Variables ***
${resource_path_8055}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/resources


*** Keywords ***
[1]CB008055-B#B6_A4_based_NR_FR1_SCell_addition_for_6CC_DL_CA
    [Documentation]    This test case verifies triggering of FR1 CA SCell Addition when UE reported A4-based SCell
    ...    Candidates within A4 Measurement Report based on RSRP quantities for FR1 CA UE in 6CC CA (F+F) in SA mode.
    Load scf for NR    ${resource_path_8055}    SCFs    scf_8055-B.xml
    Set test variable  ${test_name}  CB008055-BB6
    Setup attenuators
    keywords.Deattenuate scells
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=20
    Prepare and start new DCAP   dcap_host=10.44.180.37  bts_mplane=10.44.137.26   nrCells=NRCELL_R-800
    Attach Ue     UE_3
    Sleep         8s
    ${PCI_UE3}=       ute_ue.Get Ue Info    UE_3   PCI
    Log to Console    UE attached PCI now: ${PCI_UE3}
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_3    direction=dl    duration=300s    throughput=900Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_3    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep    20s
    ${DL_tput}         Get Average Throughput       DT_DL_SA
    Log to Console     DL Throughput: ${DL_tput}
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=0
    Sleep    50s
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Verify JSON file from DCAP  expected_messages=${messages_8055_B}
    Verify PM Counters 8055-B
