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
${tput_DL_bandwith}          500 Mbits/sec
${tput_deviation}            10%
${tput_duration}             100s
${Packet_Size}               1300
${resource_path_7477_C}      ${CURDIR}${/}resources

*** Keywords ***
CB007477-C_5GC000524_A_FR1_TDD_2UEs_4x4_Activation_of_DL_MU-MIMO_feature
    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}CB007477-C_5GC000524_A_FR1.csv
    Load scf for NR    ${resource_path_7477_C}    SCFs    scf_7477_C.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_1
    Attach Ue     UE_3
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_3  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${Packet_Size}
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_DL_SA_2
    sleep  10s
    Start TTI trace streaming
    sleep  5s
    Get Average Throughput       DT_DL_SA_1   omit=20
    Get Average Throughput       DT_DL_SA_2   omit=20
    Stop TTI trace
    Check bler based on ttitrace  10
    Check prb  actDlMuMimo=False
    Check muMimoSchedData  should_exist=False
    Await Data Transfer Finish                 DT_DL_SA_1
    Await Data Transfer Finish                 DT_DL_SA_2
    Detach Ue     UE_1
    Detach Ue     UE_3
    CB007477.delta_commisioning    json_delta=actDlMuMimo_true
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_1
    Attach Ue     UE_3
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_3  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${Packet_Size}
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_DL_SA_2
    sleep  10s
    Start TTI trace streaming
    sleep  5s
    Get Average Throughput       DT_DL_SA_1   omit=20
    Get Average Throughput       DT_DL_SA_2   omit=20
    Stop TTI trace
    Check bler based on ttitrace  10
    Check muMimoSchedData  should_exist=True
    Chack ue paired
    Check prb  actDlMuMimo=True
    Check beamId for rntis and verified
    Await Data Transfer Finish                 DT_DL_SA_1
    Await Data Transfer Finish                 DT_DL_SA_2
    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter

CB007477-C_5GC001695_A_64TRX_Beam_Refinement_ULDL_BeamSet_4_2_FrameType_1208_OpeningAngle_120
    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}CB007477-C_5GC001695_A_4_2.csv
    Load scf for NR    ${resource_path_7477_C}    SCFs    scf_CB007477-C_5GC001695_A_4_2.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_4
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_4  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_4  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA
    Check Data Transfer Is Alive               DT_UL_SA
    Start TTI trace streaming
    sleep  10s
    Get Average Throughput       DT_DL_SA   omit=20
    Get Average Throughput       DT_UL_SA   omit=20
    Stop TTI trace
    Check bler based on ttitrace  traffic_type=uldl
    Check mcs on tti  traffic_type=uldl   mcs_level=25
    Check modulation on tti  traffic_type=uldl
    Check selected BeamId     best=32   second=16
    # Check number of layers  traffic_type=uldl
    Await Data Transfer Finish                 DT_DL_SA
    Await Data Transfer Finish                 DT_UL_SA
    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter

CB007477-C_5GC001695_A_64TRX_ULDL_BeamSet_5_1_FrameType_1208_OpeningAngle_120
    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}CB007477-C_5GC001695_A_5_1.csv
    Load scf for NR    ${resource_path_7477_C}    SCFs    scf_CB007477-C_5GC001695_A_5_1.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_4
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_4  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_4  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA
    Check Data Transfer Is Alive               DT_UL_SA
    Start TTI trace streaming
    sleep  10s
    Get Average Throughput       DT_DL_SA   omit=20
    Get Average Throughput       DT_UL_SA   omit=20
    Stop TTI trace
    Check bler based on ttitrace  traffic_type=uldl
    # Check number of layers  traffic_type=uldl
    Check mcs on tti  traffic_type=uldl  mcs_level=25
    Check modulation on tti  traffic_type=uldl
    Check selected BeamId    best=33   second=26
    Await Data Transfer Finish                 DT_DL_SA
    Await Data Transfer Finish                 DT_UL_SA
    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter

CB007477-C_5GC001086-B_Single_UE_access_network_with_UL_SU-MIMO_with_5GC001070_frame_structure
    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}CB007477-C_5GC001086-B.csv
    Load scf for NR    ${resource_path_7477_C}    SCFs    scf_CB007477-C_5GC001086-B.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Prepare and start new DCAP   bts_mplane=10.42.47.5
    Attach Ue     UE_4
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_4  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_4  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA
    Check Data Transfer Is Alive               DT_UL_SA
    Start TTI trace streaming
    sleep  10s
    Get Average Throughput       DT_DL_SA   omit=20
    Get Average Throughput       DT_UL_SA   omit=20
    Stop TTI trace
    Stop DCAP trace and download logs
    Check bler based on ttitrace  traffic_type=uldl
    Check ulSrsBm BestBeamPatternId
    Check mcs on tti  traffic_type=uldl   mcs_level=25
    Check modulation on tti  traffic_type=uldl
    ${antennaSwitching}=  CB007477.check_antennaSwitching_exit_csv
    ${codebook}=  CB007477.check_codebook_exit_csv
    Should Be True  ${antennaSwitching}
    Should Be True  ${codebook}
    # Check number of layers  traffic_type=uldl
    Await Data Transfer Finish                 DT_DL_SA
    Await Data Transfer Finish                 DT_UL_SA
    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter

CB007477-C_5GC002200_F_check_DL_Tput_with_4_resources_good_condition_eCPRI
    CB009208_kw.Setup phase shifter
    CB009208_kw.Update phase shifter config    config_file=${CURDIR}${/}resources${/}mcs${/}CB007477-C_5GC002200_F.csv
    Load scf for NR    ${resource_path_7477_C}    SCFs    scf_CB007477-C_5GC002200_F.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Attach Ue     UE_4
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_4  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_4  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA
    Check Data Transfer Is Alive               DT_UL_SA
    Start TTI trace streaming
    sleep  10s
    Get Average Throughput       DT_DL_SA   omit=20
    Get Average Throughput       DT_UL_SA   omit=20
    Stop TTI trace
    Check bler based on ttitrace  traffic_type=uldl
    Check mcs on tti  traffic_type=uldl   mcs_level=25
    Check modulation on tti  traffic_type=uldl
    Await Data Transfer Finish                 DT_DL_SA
    Await Data Transfer Finish                 DT_UL_SA
    Detach Ue  UE_4
    Log to console   Enabling 2200 feature
    # delta commisioning
    Attach Ue     UE_4
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_4  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_4  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA
    Check Data Transfer Is Alive               DT_UL_SA
    Start TTI trace streaming
    sleep  10s
    Get Average Throughput       DT_DL_SA   omit=20
    Get Average Throughput       DT_UL_SA   omit=20
    Stop TTI trace
    Check bler based on ttitrace  traffic_type=uldl
    Check mcs on tti  traffic_type=uldl   mcs_level=25
    Check modulation on tti  traffic_type=uldl
    ${beamType}=  tti.check_beamType_tti
    Should Be True   ${beamType}
    Await Data Transfer Finish                 DT_DL_SA
    Await Data Transfer Finish                 DT_UL_SA
    [Teardown]  Run keyword
    ...         CB009208_kw.Teardown phase shifter
