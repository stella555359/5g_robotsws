*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB010801/resources/keywords.robot

*** Variables ***
${tput_deviation}            20%
${Packet_Size}               1300
${resource_path}      ${CURDIR}${/}resources

*** Keywords ***

CB010801-SR-C_2CC_16DL8UL+1CC8DL8UL_100_50_30_DL_MU-MIMO_with_CA
    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}basic_mcs_configuration.csv
    Load scf for NR    ${resource_path}    SCFs    3CC.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Change cellBarred  value=barred       cell_id=501
    Change cellBarred  value=notBarred    cell_id=502
    Change cellBarred  value=barred       cell_id=503
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_2  #Lahaina
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=420s
    ...                  throughput=1000 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=420s
    ...                  throughput=80 Mbits/sec             protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_UL_SA_2
    Get Average Throughput       DT_DL_SA_2
    Get Average Throughput       DT_UL_SA_2
    # Verify Average Throughput With Deviation   DT_DL_SA_2   1000 Mbits/sec   ${tput_deviation}
    # Verify Average Throughput With Deviation   DT_UL_SA_2   80 Mbits/sec   ${tput_deviation}
    Change cellBarred  value=notBarred    cell_id=501
    Change cellBarred  value=barred       cell_id=502
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_1
    Attach Ue     UE_3
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=150s
    ...                  throughput=1100 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=150s
    ...                  throughput=150 Mbits/sec             protocol=udp
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=150s
    ...                  throughput=1100 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_3  ue_alias=UE_3  direction=ul  duration=150s
    ...                  throughput=150 Mbits/sec             protocol=udp
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_UL_SA_1
    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_UL_SA_3
    Start New L1L2 Logs
    Start TTI trace streaming
    # Verify Average Throughput With Deviation   DT_DL_SA_1   1100 Mbits/sec   ${tput_deviation}
    # Verify Average Throughput With Deviation   DT_UL_SA_1   150 Mbits/sec   ${tput_deviation}
    # Verify Average Throughput With Deviation   DT_DL_SA_3   1100 Mbits/sec   ${tput_deviation}
    # Verify Average Throughput With Deviation   DT_UL_SA_3   150 Mbits/sec   ${tput_deviation}
    Get Average Throughput       DT_DL_SA_1
    Get Average Throughput       DT_UL_SA_1
    Get Average Throughput       DT_DL_SA_3
    Get Average Throughput       DT_UL_SA_3
    Stop TTI trace
    Stop New L1L2 Logs And Download PCAP
    Check modulation on tti
    Check ue mupaired
    Check prb 10801 3CC
    Verify PM Counters For 10801
    Await Data Transfer Finish                 DT_DL_SA_1
    Await Data Transfer Finish                 DT_UL_SA_1
    Await Data Transfer Finish                 DT_DL_SA_2
    Await Data Transfer Finish                 DT_UL_SA_2
    Await Data Transfer Finish                 DT_DL_SA_3
    Await Data Transfer Finish                 DT_UL_SA_3
    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter

CB010801-SR-C_4CC8DL8UL_80_50_30_30_DL_MU-MIMO_with_CA
    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}4cc.csv
    Load scf for NR    ${resource_path}    SCFs    4CC.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Change cellBarred  value=barred       cell_id=501
    Change cellBarred  value=notBarred    cell_id=502
    Change cellBarred  value=barred       cell_id=503
    Change cellBarred  value=barred       cell_id=504
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_2  #Lahaina
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=720s
    ...                  throughput=1000 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=720s
    ...                  throughput=80 Mbits/sec             protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_UL_SA_2
    Get Average Throughput       DT_DL_SA_2
    Get Average Throughput       DT_UL_SA_2
    # Verify Average Throughput With Deviation   DT_DL_SA_2   1000 Mbits/sec   ${tput_deviation}
    # Verify Average Throughput With Deviation   DT_UL_SA_2   80 Mbits/sec   ${tput_deviation}
    Change cellBarred  value=notBarred    cell_id=504
    Change cellBarred  value=barred       cell_id=502
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_4  #Lahaina
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_4  ue_alias=UE_4  direction=dl  duration=620s
    ...                  throughput=400 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_4  ue_alias=UE_4  direction=ul  duration=620s
    ...                  throughput=40 Mbits/sec             protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_4
    Check Data Transfer Is Alive               DT_UL_SA_4
    Get Average Throughput       DT_DL_SA_4
    Get Average Throughput       DT_UL_SA_4
    # Verify Average Throughput With Deviation   DT_DL_SA_4   400 Mbits/sec   ${tput_deviation}
    # Verify Average Throughput With Deviation   DT_UL_SA_4   40 Mbits/sec   ${tput_deviation}
    Change cellBarred  value=notBarred    cell_id=501
    Change cellBarred  value=barred       cell_id=504
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_1
    Attach Ue     UE_3
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=150s
    ...                  throughput=800 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=150s
    ...                  throughput=140 Mbits/sec             protocol=udp
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=150s
    ...                  throughput=800 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_3  ue_alias=UE_3  direction=ul  duration=150s
    ...                  throughput=140 Mbits/sec             protocol=udp
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_UL_SA_1
    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_UL_SA_3
    Start New L1L2 Logs
    Start TTI trace streaming
    # Verify Average Throughput With Deviation   DT_DL_SA_1   800 Mbits/sec   ${tput_deviation}
    # Verify Average Throughput With Deviation   DT_UL_SA_1   140 Mbits/sec   ${tput_deviation}
    # Verify Average Throughput With Deviation   DT_DL_SA_3   800 Mbits/sec   ${tput_deviation}
    # Verify Average Throughput With Deviation   DT_UL_SA_3   140 Mbits/sec   ${tput_deviation}
    Get Average Throughput       DT_DL_SA_1
    Get Average Throughput       DT_UL_SA_1
    Get Average Throughput       DT_DL_SA_3
    Get Average Throughput       DT_UL_SA_3
    Stop TTI trace
    Stop New L1L2 Logs And Download PCAP
    Check modulation on tti
    Check ue mupaired
    Check prb 10801 4CC
    Verify PM Counters For 10801
    Await Data Transfer Finish                 DT_DL_SA_1
    Await Data Transfer Finish                 DT_UL_SA_1
    Await Data Transfer Finish                 DT_DL_SA_2
    Await Data Transfer Finish                 DT_UL_SA_2
    Await Data Transfer Finish                 DT_DL_SA_3
    Await Data Transfer Finish                 DT_UL_SA_3
    Await Data Transfer Finish                 DT_DL_SA_4
    Await Data Transfer Finish                 DT_UL_SA_4
    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter
