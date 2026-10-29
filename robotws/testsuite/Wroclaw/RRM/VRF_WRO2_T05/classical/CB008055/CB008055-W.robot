*** Settings ***
Documentation
...  author: Karol palac
...  contact: karol.palac@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008055/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot

*** Keywords ***
[1]CB008055-W#11209_5G_DL_peak_Throughput_per_UE
    [Documentation]    This test case verifies the DL throughput with 6CC FDD CA enabled.
    Set test variable  ${test_name}  CB008055-W
    Setup attenuators
    Set attenuation and check    lines=${lines_gNB_215_AHLOA_8}  value=15
    Attach Ue     UE_3
    Sleep         5s
    ${PCI_UE3}=       ute_ue.Get Ue Info    UE_3   PCI
    Log to Console    UE attached PCI now: ${PCI_UE3}
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_3    direction=dl    duration=300s    throughput=2000Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_3    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep    5s
    keywords.Deattenuate scells
    Sleep    250s
    ${DL_tput}         Get Average Throughput       dt_name=DT_DL_SA    omit=40    tput_collection_src=control_app
    Should be true         ${DL_tput}>=600000    # Real current throughput is 0,8-1.1Gbps
    Get Data Transfer statistics    DT_DL_SA
    Log to Console     DL Throughput: ${DL_tput}
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
