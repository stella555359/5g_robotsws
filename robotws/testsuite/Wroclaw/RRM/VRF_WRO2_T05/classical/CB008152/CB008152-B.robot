*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008152/resources/CB008152_kw.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008152/resources/CB008152.py    WITH NAME    CB008152

*** Variables ***
${tput_DL_bandwith}          1000 Mbits/sec
${tput_UL_bandwith}          300 MBits/sec
${packet_Size}               1200
${tput_duration_ABIP}        420s
${tput_duration_ABIQ}        190s
${mrbts_id}                  ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${resource_path}             /home/ute/testline_configuration

*** Keywords ***
[1]CB008152-B.B4_13_11_SA_FDD_35MHz_DFT-OFDM_UL_ABIP
    Set test variable  ${test_name}  CB008152-B4_13_11
    Set test variable  ${DFT_OFDM_enabled_suffix}  DFT_OFDM_enabled
    Set test variable  ${DFT_OFDM_disabled_suffix}  DFT_OFDM_disabled
    Set test variable  ${DFT_OFDM_enabled_logs_path}  ${OUTPUT_DIR}${/}DCAPs${/}${DFT_OFDM_enabled_suffix}
    Set test variable  ${DFT_OFDM_disabled_logs_path}  ${OUTPUT_DIR}${/}DCAPs${/}${DFT_OFDM_disabled_suffix}
    ${filter_list}=  Set Variable  "ZMQ/SCTP name"="SrbSendReq","Mapping"="cpSbAddress","User data"="DL RRC: rrcReconfiguration"
    Load scf for NR  ${resource_path}  SCFs  CB008152-B5.xml
    Set attenuation 8152_B4_13_11_SA_FDD_35MHz_DFT-OFDM_UL_ABIP  att_value_503_504=0

    Attach Ue     UE_2
    sleep  5s
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_2  direction=dl  duration=${tput_duration_ABIP}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_2  direction=ul  duration=${tput_duration_ABIP}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    sleep  5s
    Check Data Transfer Is Alive               DT_DL_SA
    Check Data Transfer Is Alive               DT_UL_SA

    Prepare and start new DCAP   bts_mplane=${mrbts_id}  nrCells=NRCELL_R-503
    sleep  15s
    Set attenuation 8152_B4_13_11_SA_FDD_35MHz_DFT-OFDM_UL_ABIP  att_value_503_504=47
    sleep  30s
    Stop new DCAP trace and download logs json  filter=${filter_list}  subdir=${DFT_OFDM_enabled_suffix}
    Verify DFT OFDM  enabled  ${DFT_OFDM_enabled_logs_path}

    Check Data Transfer Is Alive               DT_DL_SA
    Check Data Transfer Is Alive               DT_UL_SA

    Prepare and start new DCAP   bts_mplane=${mrbts_id}  nrCells=NRCELL_R-503
    sleep  15s
    Set attenuation 8152_B4_13_11_SA_FDD_35MHz_DFT-OFDM_UL_ABIP  att_value_503_504=0
    Start TTI trace streaming
    sleep  30s
    Stop TTI trace  decoded_output_file=${DFT_OFDM_disabled_suffix}
    Stop new DCAP trace and download logs json  filter=${filter_list}  subdir=${DFT_OFDM_disabled_suffix}
    Verify DFT OFDM  disabled  ${DFT_OFDM_disabled_logs_path}

    Check bler based on ttitrace  decoded_output_file=${DFT_OFDM_disabled_suffix}

    Await Data Transfer Finish                 DT_DL_SA
    Await Data Transfer Finish                 DT_UL_SA

    [Teardown]  Run keyword
    ...         Delete active DCAP trace for BTS  ${mrbts_id}


[1]CB008152-B.B4_05_02_SA_2UEs_FDD_35MHz_PeakTput_UL_DL_ABIQ
    Set test variable  ${test_name}  CB008152-B4_05_02
    Load scf for NR  ${resource_path}  SCFs  CB008152-B5.xml
    Set attenuation 8152_B4_B4_05_02_SA_2UEs_FDD_35MHz_PeakTput_UL_DL_ABIQ  att_value_505_506=0

    Attach Ue     UE_1
    Attach Ue     UE_2

    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=${tput_duration_ABIQ}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_1  ue_alias=UE_1  direction=ul  duration=${tput_duration_ABIQ}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp

    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=${tput_duration_ABIQ}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_2  ue_alias=UE_2  direction=ul  duration=${tput_duration_ABIQ}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp

    sleep  5s

    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_UL_SA_1
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_UL_SA_2

    Start TTI trace streaming
    sleep  30s

    ${avg_tput_DL_UE_1}  Get Average Throughput  DT_DL_SA_1  omit=20
    ${avg_tput_UL_UE_1}  Get Average Throughput  DT_UL_SA_1  omit=20
    ${avg_tput_DL_UE_2}  Get Average Throughput  DT_DL_SA_2  omit=20
    ${avg_tput_UL_UE_2}  Get Average Throughput  DT_UL_SA_2  omit=20

    Stop TTI trace

    Await Data Transfer Finish                 DT_DL_SA_1
    Await Data Transfer Finish                 DT_UL_SA_1
    Await Data Transfer Finish                 DT_DL_SA_2
    Await Data Transfer Finish                 DT_UL_SA_2

    Check bler based on ttitrace
    Check tput on UEs  ${avg_tput_DL_UE_1}  ${avg_tput_UL_UE_1}  ${avg_tput_DL_UE_2}  ${avg_tput_UL_UE_2}
    ...  220000  160000


[1]CB008152-B.B5_20_03_SA_FDD_35MHz_CB008532_4CC_DL_CA_1T+3F
    Set test variable  ${test_name}  CB008152-B5_20_03
    ${filter_list}=  Set Variable  "Message name"="ITF_CP_CPUE_CPRT_CPRT_SENDTOCPUE_ID"
    Set test variable  ${dcap_logs}  ${OUTPUT_DIR}${/}DCAPs${/}

    Load scf for NR  ${resource_path}  SCFs  CB008152-B5.xml

    Set attenuation CB008152-B5_20_03_SA_FDD_35MHz_CB008532_4CC_DL_CA_1T+3F  att_value_100_107=15  att_value_505_506=90

    Prepare and start new DCAP   bts_mplane=${mrbts_id}  nrCells=NRCELL_R-177
    sleep  5s
    Attach Ue     UE_1
    sleep  5s
    Stop new DCAP trace and download logs json  filter=${filter_list}

    Verify CA configured  ${dcap_logs}

    Set attenuation CB008152-B5_20_03_SA_FDD_35MHz_CB008532_4CC_DL_CA_1T+3F  att_value_100_107=0  att_value_505_506=0

    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_1  direction=dl  duration=${tput_duration_ABIQ}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_1  direction=ul  duration=${tput_duration_ABIQ}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    sleep  10s
    Check Data Transfer Is Alive               DT_DL_SA
    Check Data Transfer Is Alive               DT_UL_SA

    Await Data Transfer Finish                 DT_DL_SA
    Await Data Transfer Finish                 DT_UL_SA

    Verify Tput with counter M55309C12001  8000000  70000000  30000000
