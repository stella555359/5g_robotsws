*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB007873/resources/kw_cb007873.robot
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008950/resources/CB008950_kw.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008950/resources/CB008950.py    WITH NAME    CB008950
Library         ta5g_commissioning
Library         taf.ul.ettf.setups
Library         ta5g_enb


*** Variables ***
${tput_DL_bandwith}          500 Mbits/sec
${tput_UL_bandwith}          100 MBits/sec
${packet_Size}               1200
${mrbts_id}                  ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${resource_path_8950-D}      /home/ute/testline_configuration
@{DB5_FLAGS}                 0x89006C=3    0x89006D=3    0x59021E=3    0x590247=3
${swconfig_db5}              ${CURDIR}/config/swconfig_DB5.txt
${swconfig_db201}            ${CURDIR}/config/swconfig_DB201.txt

*** Keywords ***


DB5 Setup
    [Documentation]    0x89006C=3 #rdMaxActiveIncomingCaRelFlexSCellSelect for CU
    ...                0x89006D=3 #rdMaxActiveOutgoingCaRelFlexSCellSelect for CU
    ...                0x59021E=3 #rdMaxActiveIncomingCaRelFlexSCellSelect for DU
    ...                0x590247=3 #rdMaxActiveOutgoingCaRelFlexSCellSelect for DU
    Set test variables CB008950-DB5
    Set attenuation on ports and check    lines=${lines_gNB_310_AHFII_1_FDD_n25_n66}    value=0    alias=att_2
    Setup bands DB5
    Setup deployment mode DB5 and A
    put swconfig file    ${swconfig_db5}
    CB008950_kw.Load scf for 8950    ${resource_path_8950-A}    SCFs    CB008950-DB5.xml
    @{cells}=    Create List    100    116    106    108    109    110    #209    210
    Check specific cells are on air    ${cells}  connection=cOAM
    Check gNB status after Commm  connection=cOAM
    wait until keyword succeeds  15min      1min    Check if X2 link Up

[1]CB008950-D#B5_SCell_swap_is_executed_only_if_the_number_of_active_outgoing_CA_relations_towards_the_target_SCell_does_not_exceed_the_limit
    [Documentation]    All UEs COM19, COM20, COM27 must be in SA mode.
    ...                AT commands to set SA in ELT: AT+ERAT=15  AT+E5GOPT=3
    ...                COM19 set n66 and n71 bands (pcell 114, CA scell 101)
    ...                COM20 set n66, n41 bands (cell 114, CA scell 108)
    ...                COM27 set n66, n25 bands (cell 114, CA scell 105)
    ...                mediatek M80 Figeac secret codes: *#*#3646633#*#*, *#*#4636#*#*

    DB5 Setup
    Prepare and start new DCAP   bts_mplane=${bts_mplane}     nrCells=NRCELL_R-114
        ...                      timeout=120

    ute_ue.Attach Ue    UE_3    timeout=60
    turn_mobile_data_on    UE_3
    sleep  5s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=360s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    ute_ue.Attach Ue     UE_2    timeout=60
    turn_mobile_data_on    UE_2
    sleep  5s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=360s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    ute_ue.Attach Ue    UE_1    timeout=60
    turn_mobile_data_on    UE_1
    sleep  5s
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=360s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}

    sleep  5s

    Set attenuation CB008950-DB5_310

    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_DL_SA_1

    sleep  20s

    Set attenuation on ports and check    lines=${lines_gNB_310_AHFII_2_FDD_n25_n66}    value=5    alias=att_2

    sleep  30s

    Run keyword and ignore error    Stop Data Transfer           DT_DL_SA_1
    Run keyword and ignore error    Stop Data Transfer           DT_DL_SA_2
    Run keyword and ignore error    Stop Data Transfer           DT_DL_SA_3

    Stop new DCAP trace and download logs json   subdir=${test_name}

    Verify CA configured  ${dcap_logs}

    ${report_config_id}=  Get event a6 reportconfigid  ${dcap_logs}
    ${a6_event_counter}=  Check a6 events in measurement reports  ${dcap_logs}  ${report_config_id}

    Verify CB008950-DB5 counters  ${a6_event_counter}



DB201 Setup
    [Documentation]    0x89006C=3 #rdMaxActiveIncomingCaRelFlexSCellSelect for CU
    ...                0x89006D=3 #rdMaxActiveOutgoingCaRelFlexSCellSelect for CU
    ...                0x59021E=2 #rdMaxActiveIncomingCaRelFlexSCellSelect for DU
    ...                0x590247=2 #rdMaxActiveOutgoingCaRelFlexSCellSelect for DU
    Set test variables CB008950-DB201
    Set Attenuation CB008950-DB201_310
    Setup bands DB201
    Setup deployment mode DB201
    put swconfig file    ${swconfig_db201}
    CB008950_kw.Load scf for 8950    ${resource_path_8950-A}    SCFs    CB008950-DB201.xml
    @{cells}=    Create List    100    108    109    110    209    210
    Check specific cells are on air    ${cells}  connection=cOAM
    Check gNB status after Commm  connection=cOAM
    wait until keyword succeeds  10min      1min    Check if X2 link Up

[1]CB008950-D-B201 FR1 CA is setup only if the number of active incoming CA relations in the SCells does not exceed the limit
    [Documentation]    UEs COM19 and COM20 must be in SA mode. COM27 must be in NSA mode.
    ...                AT commands to set SA in ELT: AT+ERAT=15  AT+E5GOPT=3. AT commands to set NSA in ELT: AT+ERAT=19 AT+E5GOPT=5
    ...                COM19 set n25 and n41 bands (pcell 106, CA scell 108)
    ...                COM20 set n66, n41 bands (cell 116, CA scell 108)
    ...                COM27 set b2, n41, n71 bands (attach LTE 214, NSA with pcell 101 and CA scell 108)
    ...                mediatek M80 Figeac secret codes: *#*#3646633#*#*, *#*#4636#*#*

    DB201 Setup

    Prepare and start new DCAP    bts_mplane=${bts_mplane}   nrCells=NRCELL_R-101 NRCELL_R-106 NRCELL_R-108 NRCELL_R-116
    ...                           timeout=60
    sleep  20s
    ute_ue.Attach Ue    UE_3    timeout=60
    turn_mobile_data_on    UE_3
    sleep  1s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=600s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    ute_ue.Attach Ue    UE_2    timeout=60
    turn_mobile_data_on    UE_2
    sleep  1s
    Start Data Transfer  dt_name=DT_DL_SA_2  ue_alias=UE_2  direction=dl  duration=600s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    ute_ue.Attach Ue    UE_1    timeout=60
    turn_mobile_data_on    UE_1
    sleep  1s
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=600s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}

    sleep  5s

    Check Data Transfer Is Alive               DT_DL_SA_3
    Check Data Transfer Is Alive               DT_DL_SA_2
    Check Data Transfer Is Alive               DT_DL_SA_1

    Stop Data Transfer           DT_DL_SA_3    # STOP COM19 SA UE WILL GO IDLE
    Sleep    20s    Waiting for the UE to go to IDLE
    Stop Data Transfer           DT_DL_SA_1     # STOP COM27 NSA UE
    ute_ue.Detach Ue     UE_3
    ute_ue.Detach Ue     UE_1

    Stop new DCAP trace and download logs json  filter=${filter_list_exceeded_limit}
    ...    suffix=${exceeded_limit_suffix}
    ...    subdir=${test_name}_${exceeded_limit_suffix}

    Verify if NSA CA limited  ${dcap_logs_exceeded_limit}

    Prepare and start new DCAP   bts_mplane=${bts_mplane}   nrCells=NRCELL_R-101 NRCELL_R-106 NRCELL_R-108 NRCELL_R-116
    ...                           timeout=60
    sleep  10s
    ute_ue.Attach Ue    UE_1
    sleep  1s
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=120s
    ...                  throughput=${tput_DL_bandwith}              protocol=udp  packet_size=${packet_Size}
    sleep  10s

    Check Data Transfer Is Alive               DT_DL_SA_1
    Check Data Transfer Is Alive               DT_DL_SA_2

    Stop Data Transfer           DT_DL_SA_1
    Stop Data Transfer           DT_DL_SA_2
    Stop new DCAP trace and download logs json  filter=${filter_list_not_exceeded_limit}
    ...    suffix=${not_exceeded_limit_suffix}
    ...    subdir=${test_name}_${not_exceeded_limit_suffix}

    Verify if NSA CA not limited  ${dcap_log_not_exceeded_limits}

    Verify CB008950-D-B201 counters

[1]CB008950-D-B101 Measurement activation for ext-SCell addition does not depend on number of active incoming relations of the candidate ext-SCell
    [Documentation]    UE_1 R5CWB1KEQ4T set n71 and n41 bands (pcell 1, CA scell 311)
    ...                UE_4 R5CW80FLKER set n66, n41 bands (cell 21, CA scell 311)
    ...                UE_3 R5CWB1KEPHF set n41 band (cell 561, CA scell 311)
    ...                Samsung secret code to band change: *#2263#

    Set test variables CB008950-DB101
    Add flags to sw config CB008950-DB101 t410
#    Add flags to sw config CB008950-DB101 t186
    Load scf for second NR    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008950/resources
    ...                       SCFs    CB008950-DB101_t186_scf.xml
    #CB008950_kw.Load scf for 8950    ${resource_path_8950-D}    SCFs    CB008950-D_B101.xml
    ${stream_name}    Get stream name
    ${stream_name}=   Set Variable If  '${stream_name}' == 'TRUNK'  default    ${stream_name}
	Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    coam.perform_delta_recommissioning
    ...   delta_file=testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/config/default/delta_8950-DB101-mainGNB.json   connection=cOAM
	Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    Setup T186 attenuator
    Set attenuation CB008950-DB101
    Log to Console    Set attenuation CB008950-DB101
#    Prepare and start new DCAP  bts_mplane=10.44.76.47  nrCells=NRCELL_R-1 NRCELL_R-311 NRCELL_R-21  connection=t410
#    Prepare and start new DCAP  bts_mplane=10.42.234.104  nrCells=NRCELL_R-561  connection=t186
    Attach Ue    UE_1
    sleep  5s
    ${PCI_UE1}=            ute_ue.Get Ue Info    UE_1   PCI
    Log to Console         UE1: ${PCI_UE1}
    Start Data Transfer  dt_name=DT_DL_SA_1  ue_alias=UE_1  direction=dl  duration=800s
    ...                  throughput=1400Mbits/sec              protocol=udp  packet_size=${packet_Size}
    Change cellBarred    value=barred    cell_id=1
    Sleep  3s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}   value=0
    Attach Ue    UE_4
    sleep  5s
    ${PCI_UE4}=            ute_ue.Get Ue Info    UE_4   PCI
    Log to Console         UE4: ${PCI_UE4}
    Start Data Transfer  dt_name=DT_DL_SA_4  ue_alias=UE_4  direction=dl  duration=800s
    ...                  throughput=1400Mbits/sec              protocol=udp  packet_size=${packet_Size}
    Set T186 attenuator for cell 561  att_value=${0}
    Change cellBarred    value=barred    cell_id=21
    Attach Ue    UE_3
    sleep  5s
    ${PCI_UE3}=            ute_ue.Get Ue Info    UE_3   PCI
    Log to Console         UE3: ${PCI_UE3}
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=600s
    ...                  throughput=1400Mbits/sec              protocol=udp  packet_size=${packet_Size}
    sleep  15s
#    Check Data Transfer Is Alive               DT_DL_SA_1
#    Check Data Transfer Is Alive               DT_DL_SA_4
#    Check Data Transfer Is Alive               DT_DL_SA_3

    Run keyword and ignore error    Stop Data Transfer           DT_DL_SA_3
    Detach Ue     UE_3
    Run keyword and ignore error    Stop Data Transfer           DT_DL_SA_1
    Detach Ue     UE_1
#    Stop new DCAP trace and download logs json  filter=${filter_list_exceeded_t410}
#    ...    subdir=${test_name}_${exceeded_limit_suffix_t410}  connection=t410
#    Stop new DCAP trace and download logs json  filter=${filter_list_exceeded_t186}
#    ...    subdir=${test_name}_${exceeded_limit_suffix_t186}  connection=t186

#    Verify t410 dcap logs if ext scell addition limited  ${dcap_logs_exceeded_limit_t410}
#    Verify t186 dcap logs if ext scell addition limited  ${dcap_logs_exceeded_limit_t186}

    sleep  5s
#    Prepare and start new DCAP  bts_mplane=10.42.234.104  nrCells=NRCELL_R-561  connection=t186
    Attach Ue    UE_3
    ${PCI_UE3_2}=            ute_ue.Get Ue Info    UE_3   PCI
    Log to Console         UE3: ${PCI_UE3_2}
    sleep  5s
    Start Data Transfer  dt_name=DT_DL_SA_3  ue_alias=UE_3  direction=dl  duration=600s
    ...                  throughput=1400Mbits/sec              protocol=udp  packet_size=${packet_Size}
#    Prepare and start new DCAP  bts_mplane=10.44.76.47  nrCells=NRCELL_R-1 NRCELL_R-311 NRCELL_R-21  connection=t410

#    Check Data Transfer Is Alive               DT_DL_SA_3
#    Check Data Transfer Is Alive               DT_DL_SA_4
    sleep  10s
#    Stop new DCAP trace and download logs json  filter=${filter_list_not_exceeded_t410}
#    ...    subdir=${test_name}_${not_exceeded_limit_suffix_t410}  connection=t410

    Run keyword and ignore error    Stop Data Transfer           DT_DL_SA_3
    Run keyword and ignore error    Stop Data Transfer           DT_DL_SA_4

#    Stop new DCAP trace and download logs json  filter=${filter_list_not_exceeded_t186}
#    ...    subdir=${test_name}_${not_exceeded_limit_suffix_t186}  connection=t186
#    Verify t410 dcap logs if ext scell addition not limited  ${dcap_log_not_exceeded_limits_t410}
#    Verify t186 dcap logs if ext scell addition not limited  ${dcap_log_not_exceeded_limits_t186}

    Verify CB008950-D-B101 counters

    [Teardown]  Run keywords
    ...  Change cellBarred    value=notBarred    cell_id=1    AND
    ...  Change cellBarred    value=notBarred    cell_id=21
#    ...  Restore original sw config CB008950  reset=${True}  AND
#    ...  Restore original sw config CB008950 t186
