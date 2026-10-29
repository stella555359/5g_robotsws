*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/resources/keywords.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB007477/resources/CB007477.py    WITH NAME    CB007477

*** Variables ***
${tput_DL_bandwith_1}        300 Mbits/sec
${tput_DL_bandwith_2}        700 Mbits/sec
${tput_UL_bandwith}          100 MBits/sec
${tput_deviation}            10%
${tput_duration}             100s
${Packet_Size}               1300

*** Keywords ***

CB009262-SR-I_CB008701_16DL_4Ues_noRankDowngrade
    keywords.Setup phase shifter
    keywords.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}basic_mcs_configuration.csv
    CB007477.delta_commisioning    json_delta=noRankDowngrade_8
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_1
    Attach Ue     UE_2
    Attach Ue     UE_3
    Attach Ue     UE_4
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_1}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_1}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_1}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_3  ue_alias=UE_3  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_4  ue_alias=UE_4  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_1}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_4  ue_alias=UE_4  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_DL_SA_4
    Start New L1L2 Logs
    Start TTI trace streaming
    sleep  10s
    Stop TTI trace
    Stop New L1L2 Logs And Download PCAP

    Check mcs on tti  traffic_type=ul
    CB007477.delta_commisioning    json_delta=noRankDowngrade_16
    Await Data Transfer Finish                 DT_DL_SA_1
    Await Data Transfer Finish                 DT_DL_SA_2
    Await Data Transfer Finish                 DT_DL_SA_3
    Await Data Transfer Finish                 DT_DL_SA_4

    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_1
    Attach Ue     UE_2
    Attach Ue     UE_3
    Attach Ue     UE_4
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_2}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_2}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_2}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_3  ue_alias=UE_3  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_4  ue_alias=UE_4  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_2}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_4  ue_alias=UE_4  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_DL_SA_4
    Start New L1L2 Logs
    Start TTI trace streaming
    sleep  10s
    Stop TTI trace
    Stop New L1L2 Logs And Download PCAP

    # Check ue mupaired
    Check number of layers  traffic_type=uldl
    Await Data Transfer Finish                 DT_DL_SA_1
    Await Data Transfer Finish                 DT_DL_SA_2
    Await Data Transfer Finish                 DT_DL_SA_3
    Await Data Transfer Finish                 DT_DL_SA_4

    [Teardown]  Run keyword
    ...         keywords.Teardown phase shifter



CB009262-SR-I_CB009359_CB008701 DL MU MIMO for 16 DL layers per 2CC
    keywords.Setup phase shifter
    keywords.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}basic_mcs_configuration.csv
    CB007477.delta_commisioning    json_delta=noRankDowngrade_8
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_1
    Attach Ue     UE_2
    Attach Ue     UE_3
    Attach Ue     UE_4
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_1}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_1}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_1}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_3  ue_alias=UE_3  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_4  ue_alias=UE_4  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_1}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_4  ue_alias=UE_4  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_DL_SA_4
    Start New L1L2 Logs
    Start TTI trace streaming
    sleep  10s
    Stop TTI trace
    Stop New L1L2 Logs And Download PCAP

    Check mcs on tti  traffic_type=ul
    CB007477.delta_commisioning    json_delta=noRankDowngrade_16
    Await Data Transfer Finish                 DT_DL_SA_1
    Await Data Transfer Finish                 DT_DL_SA_2
    Await Data Transfer Finish                 DT_DL_SA_3
    Await Data Transfer Finish                 DT_DL_SA_4

    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_1
    Attach Ue     UE_2
    Attach Ue     UE_3
    Attach Ue     UE_4
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_2}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_2}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_2}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_3  ue_alias=UE_3  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_4  ue_alias=UE_4  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith_2}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_4  ue_alias=UE_4  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_DL_SA_4
    Start New L1L2 Logs
    Start TTI trace streaming
    sleep  10s
    Stop TTI trace
    Stop New L1L2 Logs And Download PCAP

    # Check ue mupaired
    Check number of layers  traffic_type=uldl
    Await Data Transfer Finish                 DT_DL_SA_1
    Await Data Transfer Finish                 DT_DL_SA_2
    Await Data Transfer Finish                 DT_DL_SA_3
    Await Data Transfer Finish                 DT_DL_SA_4

    [Teardown]  Run keyword
    ...         keywords.Teardown phase shifter