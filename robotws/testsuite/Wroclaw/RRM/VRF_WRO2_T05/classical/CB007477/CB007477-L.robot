*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB007477/resources/CB007477.py    WITH NAME    CB007477

*** Variables ***
${tput_DL_bandwith}          1000 Mbits/sec
${tput_DL_1208}              1350 Mbits/sec
${tput_UL_bandwith}          200 MBits/sec
${tput_deviation}            10%
${tput_duration}             100s
${Packet_Size}               1300

*** Keywords ***

CB007477-L_Different_frame_structures_configuration_5GC001070_in_case_of_256QAM_modulation_and_80MHz_bandwidth_with_AVQL_RU
    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}basic_mcs_configuration.csv
    CB007477.delta_commisioning    json_delta=CB007477-L_5GC001070
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_1
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA
    Start New L1L2 Logs
    Start TTI trace streaming
    sleep  10s
    Get Average Throughput       DT_DL_SA   omit=20  tput_collection_src=control_app
    Get Average Throughput       DT_UL_SA   omit=20  tput_collection_src=control_app
    # Verify Average Throughput With Deviation   DT_DL_SA   ${tput_DL_bandwith}   ${tput_deviation}  omit=20  tput_collection_src=control_app
    # Verify Average Throughput With Deviation   DT_UL_SA   ${tput_UL_bandwith}   ${tput_deviation}  omit=20  tput_collection_src=control_app
    Stop TTI trace
    Stop New L1L2 Logs And Download PCAP
    Check bler based on ttitrace  traffic_type=uldl
    # Check number of layers  traffic_type=uldl
    Check mcs on tti  traffic_type=uldl
    Check modulation on tti  traffic_type=uldl
    Await Data Transfer Finish                 DT_DL_SA
    Await Data Transfer Finish                 DT_UL_SA
    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter

CB007477-L_Different_frame_structures_configuration_5GC001208_in_case_of_256QAM_modulation_and_100MHz_bandwidth_with_AVQL_RU
    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}basic_mcs_configuration.csv
    CB007477.delta_commisioning    json_delta=CB007477-L_5GC001208
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_1
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_1208}         protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA
    Start New L1L2 Logs
    Start TTI trace streaming
    sleep  10s
    Get Average Throughput       DT_DL_SA   omit=20  tput_collection_src=control_app
    Get Average Throughput       DT_UL_SA   omit=20  tput_collection_src=control_app
    # Verify Average Throughput With Deviation   DT_DL_SA   ${tput_DL_1208}       ${tput_deviation}  omit=20  tput_collection_src=control_app
    # Verify Average Throughput With Deviation   DT_UL_SA   ${tput_UL_bandwith}   ${tput_deviation}  omit=20  tput_collection_src=control_app
    Stop TTI trace
    Stop New L1L2 Logs And Download PCAP
    Check bler based on ttitrace  traffic_type=uldl
    Check number of layers  traffic_type=uldl
    Check mcs on tti  traffic_type=uldl
    Check modulation on tti  traffic_type=uldl
    Await Data Transfer Finish                 DT_DL_SA
    Await Data Transfer Finish                 DT_UL_SA
    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter
