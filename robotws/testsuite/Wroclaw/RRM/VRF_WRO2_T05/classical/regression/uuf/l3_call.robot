*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot

*** Variables ***
${tput_DL_bandwith}     10 Mbits/sec
${tput_UL_bandwith}     10 MBits/sec
${tput_deviation}       20%
${tput_duration}        30s
${Packet_Size}          1200

*** Keywords ***
E2E_L3_CALL
    Require Ue    UE_1    capabilities=CSV4ALL_L3_CALL
    Attach Ue     UE_1
    Start Data Transfer  dt_name=DT_DL_NSA  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_NSA  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_NSA
    Check Data Transfer Is Alive               DT_UL_NSA
    Start TTI trace streaming
    Sleep  10s
    Stop TTI trace
    Await Data Transfer Finish                 DT_DL_NSA
    Await Data Transfer Finish                 DT_UL_NSA
    Verify Average Throughput With Deviation   DT_DL_NSA   ${tput_DL_bandwith}   ${tput_deviation}
    Verify Average Throughput With Deviation   DT_UL_NSA   ${tput_UL_bandwith}   ${tput_deviation}
    Detach Ue     UE_1
