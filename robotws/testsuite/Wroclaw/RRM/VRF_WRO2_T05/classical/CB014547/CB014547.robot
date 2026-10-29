*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB014547/resources/keywords.robot

*** Variables ***
${tput_deviation}            20%
${Packet_Size}               1300

*** Keywords ***

CB014547_SR_B1_Habrok_64TRX_AVQL_RU_Supports_up_to_250MHz_oBW_16DL8UL_with_Srs_SubbandBm_on
    Load scf for NR    ${CURDIR}${/}resources    SCFs    250MHz.xml
    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}cb014547.csv
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Change cellBarred  value=notBarred    cell_id=501
    Change cellBarred  value=barred       cell_id=502
    Change cellBarred  value=barred       cell_id=503
    Change cellBarred  value=barred       cell_id=504
    Wait until keyword succeeds    20 min     10s     Verify all cells are onair with admin
    Log to console  Attach UE_4 17930ac6
    Attach Ue     UE_4
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_4  ue_alias=UE_4  direction=dl  duration=1320s
    ...                  throughput=1000 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_4  ue_alias=UE_4  direction=ul  duration=1320s
    ...                  throughput=40 Mbits/sec             protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_4
    Check Data Transfer Is Alive               DT_UL_SA_4
    Get Average Throughput       DT_DL_SA_4
    Get Average Throughput       DT_UL_SA_4

    Change cellBarred  value=notBarred    cell_id=503
    Change cellBarred  value=barred       cell_id=501
    Wait until keyword succeeds    20 min    10s     Verify all cells are onair with admin
    Log to console  Attach UE_2 fb0882d9
    Attach Ue     UE_2
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=1620s
    ...                  throughput=1000 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=1620s
    ...                  throughput=40 Mbits/sec             protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_UL_SA_2
    Get Average Throughput       DT_DL_SA_2
    Get Average Throughput       DT_UL_SA_2
    Change cellBarred  value=notBarred    cell_id=502
    Change cellBarred  value=barred       cell_id=503
    Log to console  Attach UE_1 HZQN1876AAKA2000131
    Attach Ue     UE_1
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=1120s
    ...                  throughput=1000 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=1120s
    ...                  throughput=40 Mbits/sec             protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_UL_SA_1
    Get Average Throughput       DT_DL_SA_1
    Get Average Throughput       DT_UL_SA_1

    Change cellBarred  value=notBarred    cell_id=504
    Wait until keyword succeeds    20 min    10s     Verify all cells are onair with admin
    Log to console  Attach UE_3 HZQN1876AAK60100436
    Attach Ue     UE_3
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=1920s
    ...                  throughput=1000 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_3  ue_alias=UE_3  direction=ul  duration=1920s
    ...                  throughput=80 Mbits/sec             protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_UL_SA_3
    Get Average Throughput       DT_DL_SA_3
    Get Average Throughput       DT_UL_SA_3
    Log to console  Start New L1L2 Logs
    Start New L1L2 Logs
    Start TTI trace streaming
    sleep  7s
    Stop TTI trace
    Stop New L1L2 Logs And Download PCAP
    Check beamtype subband 14547  cellId=501    should_be_subband=True
    Check beamtype subband 14547  cellId=502    should_be_subband=False
    Check beamtype subband 14547  cellId=503    should_be_subband=True
    Check beamtype subband 14547  cellId=504    should_be_subband=False
    Verify PM Counters For 14547
    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter


CB014547_SR_B1_Habrok_64TRX_AVQL_RU_Supports_up_to_300MHz_oBW_8DL4UL_with_SRS_SubbandBm_on
    Load scf for NR    ${CURDIR}${/}resources    SCFs    300MHz.xml
    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}cb014547.csv
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Change cellBarred  value=notBarred    cell_id=501
    Change cellBarred  value=barred       cell_id=502
    Change cellBarred  value=barred       cell_id=503
    Change cellBarred  value=barred       cell_id=504
    Wait until keyword succeeds    20 min     10s     Verify all cells are onair with admin
    Log to console  Attach UE_4 17930ac6
    Attach Ue     UE_4
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_4  ue_alias=UE_4  direction=dl  duration=1320s
    ...                  throughput=1000 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_4  ue_alias=UE_4  direction=ul  duration=1320s
    ...                  throughput=40 Mbits/sec             protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_4
    Check Data Transfer Is Alive               DT_UL_SA_4
    Get Average Throughput       DT_DL_SA_4
    Get Average Throughput       DT_UL_SA_4

    Change cellBarred  value=notBarred    cell_id=503
    Change cellBarred  value=barred       cell_id=501
    Wait until keyword succeeds    20 min    10s     Verify all cells are onair with admin
    Log to console  Attach UE_2 fb0882d9
    Attach Ue     UE_2
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=1620s
    ...                  throughput=1000 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=1620s
    ...                  throughput=40 Mbits/sec             protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_UL_SA_2
    Get Average Throughput       DT_DL_SA_2
    Get Average Throughput       DT_UL_SA_2
    Change cellBarred  value=notBarred    cell_id=502
    Change cellBarred  value=barred       cell_id=503
    Log to console  Attach UE_1 HZQN1876AAKA2000131
    Attach Ue     UE_1
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=1120s
    ...                  throughput=1000 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=1120s
    ...                  throughput=40 Mbits/sec             protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_UL_SA_1
    Get Average Throughput       DT_DL_SA_1
    Get Average Throughput       DT_UL_SA_1

    Change cellBarred  value=notBarred    cell_id=504
    Wait until keyword succeeds    20 min    10s     Verify all cells are onair with admin
    Log to console  Attach UE_3 HZQN1876AAK60100436
    Attach Ue     UE_3
    Sleep                10s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=1920s
    ...                  throughput=1000 Mbits/sec              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_3  ue_alias=UE_3  direction=ul  duration=1920s
    ...                  throughput=80 Mbits/sec             protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_UL_SA_3
    Get Average Throughput       DT_DL_SA_3
    Get Average Throughput       DT_UL_SA_3
    Log to console  Start New L1L2 Logs
    Start New L1L2 Logs
    Start TTI trace streaming
    sleep  7s
    Stop TTI trace
    Stop New L1L2 Logs And Download PCAP
    Check beamtype subband 14547  cellId=501    should_be_subband=True
    Check beamtype subband 14547  cellId=502    should_be_subband=False
    Check beamtype subband 14547  cellId=503    should_be_subband=True
    Check beamtype subband 14547  cellId=504    should_be_subband=False
    Verify PM Counters For 14547
    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter