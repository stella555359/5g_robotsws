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
[1]CB008055-D#B1_A2_based_PCell_change_for_SA_call_(5CC_FDD_DL_CA)
    [Documentation]    This test case verifies the successful PCell Change procedure triggered by A2 event
    ...    measurement activated on PCell frequency for 5G-UE connected to FDD PCell with 4 FDD SCells in SA.
    Load scf for NR    ${resource_path_8055}    SCFs    scf_8055-D.xml
    Set test variable  ${test_name}  CB008055-DB1
    Setup attenuators
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=0
    Prepare and start new DCAP   dcap_host=10.44.180.37  bts_mplane=10.44.137.26   nrCells=NRCELL_R-800
    Attach Ue     UE_3
    Sleep         5s
    ${PCI_UE3}=       ute_ue.Get Ue Info    UE_3   PCI
    Log to Console    UE attached PCI now: ${PCI_UE3}
    keywords.Deattenuate scells
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_3    direction=dl    duration=300s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_3    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep    10s
    ${DL_tput}         Get Average Throughput       DT_DL_SA
    Log to Console     DL Throughput: ${DL_tput}
    ${UL_tput}         Get Average Throughput       DT_UL_SA
    Log to Console     UL Throughput: ${UL_tput}
    Trigger A2 PCell Change
    Sleep    30s
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Verify JSON file from DCAP  expected_messages=${messages_8055_D}
    Verify PM Counters 8055-D
