*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com
...  !!!!!!!
...  It is required to change network mode to SA on below UEs manually before execution:
...  COM19 MTK2
...  COM20  F2138
...  COM27  ABCDEFGH12345
...  with below AT commands.
...  SA mode:
...  AT+ERAT=15 AT+E5GOPT=3
...  To restore NSA mode after test use:
...  AT+ERAT=19 AT+E5GOPT=5
...  !!!!!!!

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008950/resources/CB008950_kw.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008950/resources/CB008950.py    WITH NAME    CB008950
Resource        taf/rfrl/common_resources/robot/libraries_instances.robot

*** Variables ***
${tput_DL_bandwith}          500 Mbits/sec
${tput_UL_bandwith}          100 MBits/sec
${packet_Size}               1200
${mrbts_id}                  ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${resource_path_8950-A}      /home/ute/testline_configuration
${swconfig_default}          ${CURDIR}/config/swconfig.txt


*** Keywords ***
[1]CB008950-A#B3_SCell_selection_during_A1_measurement_based_SCell_Addition_for_SA_UE_equal_SCellprio
    Set attenuation 8950_310
    Set test variables CB008950-AB3
    Setup bands C and A
    Setup deployment mode DB5 and A
    put swconfig file    ${swconfig_default}
    CB008950_kw.Load scf for 8950    ${resource_path_8950-A}    SCFs    CB008950-C_B1.xml
    @{cells}=    Create List    100    116    106    108    109    110    209    210
    Check specific cells are on air    ${cells}  connection=cOAM
    Check gNB status after Commm  connection=cOAM

    Prepare and start new DCAP    bts_mplane=${bts_mplane}    nrCells=NRCELL_R-100 NRCELL_R-108 NRCELL_R-109 NRCELL_R-110
    ...    timeout=100
    Sleep    30s
    ute_ue.Attach Ue     UE_1    timeout=60
    sleep  5s
    turn_mobile_data_on    UE_1
    sleep  5s
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=600s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=600s
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    sleep  5s
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_UL_SA_1
    Stop new DCAP trace and download logs json  suffix=UE_1    subdir=${test_name}_UE_1

    Prepare and start new DCAP   bts_mplane=${bts_mplane}   nrCells=NRCELL_R-100 NRCELL_R-108 NRCELL_R-109 NRCELL_R-110
        ...    timeout=100
    Sleep    30s
    ute_ue.Attach Ue     UE_2    timeout=60
    sleep  5s
    turn_mobile_data_on    UE_2
    sleep  5s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=400s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=400s
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    sleep  5s
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_UL_SA_2
    Stop new DCAP trace and download logs json  suffix=UE_2    subdir=${test_name}_UE_2

    Prepare and start new DCAP   bts_mplane=${bts_mplane}  nrCells=NRCELL_R-100 NRCELL_R-108 NRCELL_R-109 NRCELL_R-110
        ...    timeout=100
    Sleep    30s
    ute_ue.Attach Ue     UE_3    timeout=60
    sleep  5s
    turn_mobile_data_on    UE_3
    sleep  5s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=200s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_3  ue_alias=UE_3  direction=ul  duration=200s
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    sleep  5s
    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_UL_SA_3
    Stop new DCAP trace and download logs json  suffix=UE_3    subdir=${test_name}_UE_3

    CB008950.add_scellphycellid  UE_1  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_UE_1  ${cells_dict}
    CB008950.add_scellphycellid  UE_2  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_UE_2  ${cells_dict}
    CB008950.add_scellphycellid  UE_3  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_UE_3  ${cells_dict}
    ${result}=  CB008950.has_common_cell    ${cells_dict}
    Should Be True  ${result}
    ...  scellphycellid in F1AP: UEContextModificationResponse for UE1, UE2, UE3 should be equal, please check DCAP logs

    sleep  40s
    ${avg_tput_DL_UE_1}  Get Average Throughput  DT_DL_SA_1  omit=130
    ${avg_tput_DL_UE_2}  Get Average Throughput  DT_DL_SA_2  omit=80
    ${avg_tput_DL_UE_3}  Get Average Throughput  DT_DL_SA_3  omit=40
    Check scell tput on each UE  ${avg_tput_DL_UE_1}   ${avg_tput_DL_UE_2}   ${avg_tput_DL_UE_3}  80000

    Stop Data Transfer                DT_DL_SA_1
    Stop Data Transfer                DT_UL_SA_1
    Stop Data Transfer                DT_DL_SA_2
    Stop Data Transfer                DT_UL_SA_2
    Stop Data Transfer                DT_DL_SA_3
    Stop Data Transfer                DT_UL_SA_3



[1]CB008950-A#B4_SCell_selection_during_A1_measurement_based_SCell_Addition_for_SA_UE_different_SCellprio
    Set attenuation 8950_310
    Set test variables CB008950-AB4
    Setup bands C and A
    Setup deployment mode DB5 and A
    send delta commissioning    input_filepath=${CURDIR}/resources/delta_templates/CB008950-A_B4_different_Scellprio.json
    @{cells}=    Create List    100    116    106    108    109    110    209    210
    Check specific cells are on air    ${cells}      connection=cOAM

    Prepare and start new DCAP   bts_mplane=${bts_mplane}  nrCells=NRCELL_R-100 NRCELL_R-108 NRCELL_R-109 NRCELL_R-110
        ...     timeout=100
    Sleep    30s
    ute_ue.Attach UE     UE_1
    sleep  5s
    turn_mobile_data_on    UE_1
    sleep  5s
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=600s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=600s
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    sleep  5s
    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_UL_SA_1
    Stop new DCAP trace and download logs json  suffix=UE_1    subdir=${test_name}_UE_1
    CB008950.add_scellphycellid  UE_1  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_UE_1  ${cells_dict}

    Prepare and start new DCAP   bts_mplane=${bts_mplane}   nrCells=NRCELL_R-100 NRCELL_R-108 NRCELL_R-109 NRCELL_R-110
        ...    timeout=100
    Sleep    30s
    ute_ue.Attach Ue     UE_2
    sleep  5s
    turn_mobile_data_on    UE_2
    sleep  5s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=400s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=400s
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    sleep  5s
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_UL_SA_2
    Stop new DCAP trace and download logs json  suffix=UE_2    subdir=${test_name}_UE_2
    CB008950.add_scellphycellid  UE_2  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_UE_2  ${cells_dict}


    Prepare and start new DCAP   bts_mplane=${bts_mplane}   nrCells=NRCELL_R-100 NRCELL_R-108 NRCELL_R-109 NRCELL_R-110
      ...    timeout=100
    Sleep    30s
    ute_ue.Attach Ue    UE_3
    sleep  5s
    turn_mobile_data_on    UE_3
    sleep  5s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=200s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_3  ue_alias=UE_3  direction=ul  duration=200s
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    sleep  5s
    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_UL_SA_3
    Stop new DCAP trace and download logs json  suffix=UE_3    subdir=${test_name}_UE_3
    CB008950.add_scellphycellid  UE_3  ${OUTPUT_DIR}${/}DCAPs${/}${test_name}_UE_3  ${cells_dict}

    ${result}=  CB008950.has_common_cell  ${cells_dict}
    Should Be True  ${result}
    ...  scellphycellid in F1AP: UEContextModificationResponse for UE1, UE2, UE3 should be equal, please check DCAP logs

    sleep  40s
    ${avg_tput_DL_UE_1}  Get Average Throughput  DT_DL_SA_1  omit=130
    ${avg_tput_DL_UE_2}  Get Average Throughput  DT_DL_SA_2  omit=80
    ${avg_tput_DL_UE_3}  Get Average Throughput  DT_DL_SA_3  omit=40
    Check scell tput on each UE  ${avg_tput_DL_UE_1}   ${avg_tput_DL_UE_2}   ${avg_tput_DL_UE_3}  80000

    Run keyword and ignore error    Stop Data Transfer                DT_DL_SA_1
    Run keyword and ignore error    Stop Data Transfer                DT_UL_SA_1
    Run keyword and ignore error    Stop Data Transfer                DT_DL_SA_2
    Run keyword and ignore error    Stop Data Transfer                DT_UL_SA_2
    Run keyword and ignore error    Stop Data Transfer                DT_DL_SA_3
    Run keyword and ignore error    Stop Data Transfer                DT_UL_SA_3

