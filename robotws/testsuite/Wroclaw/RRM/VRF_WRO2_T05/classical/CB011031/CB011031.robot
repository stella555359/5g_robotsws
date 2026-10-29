*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB011031/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot


*** Variables ***
${resource_path_CB011031}       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB011031/resources
${tput_DL_bandwith}             300 Mbits/sec
${tput_UL_bandwith}             30 MBits/sec
${tput_deviation}               30%
${tput_deviation_ul}            50%
${tput_duration}                30s
${Packet_Size}                  1200
${DRX_CONFIG}                   nr-rrc.drx_Config == 1
${RRC_RELEASE}                  ngap.procedureCode == 42 && ngap.radioNetwork == 20

*** Keywords ***
USCCB011031-A#5_Paging_broadcast_for_Idle_state_UE_with_DL_throughput
    @{mnCells}=    Create List    NRCELL_R-1  NRCELL_R-2
    Setup attenuators
    Turn off attenuation
    Set initial attenuation for CB011031
    Load scf for NR    ${resource_path_CB011031}    SCFs    USCCB011031-Paging.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Start Tshark SCTP
    ute_ue.Attach Ue     UE_1
    Turn screen off    UE_1
    Confirm that UE is in IDLE state
    Start Data Transfer  dt_name=DT_DL_NSA  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_NSA  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_NSA
    Check Data Transfer Is Alive               DT_UL_NSA
    Await Data Transfer Finish                 DT_DL_NSA
	Await Data Transfer Finish                 DT_UL_NSA
    Verify Average Throughput With Deviation   DT_DL_NSA   ${tput_DL_bandwith}   ${tput_deviation}
    Verify Average Throughput With Deviation   DT_UL_NSA   ${tput_UL_bandwith}   ${tput_deviation_ul}
    Stop Tshark and download logs SCTP
    Verify that DRX was configured
    Check_f1_ng_paging    dir=${OUTPUT DIR}/tcpdump.pcap


USCCB011031-B3#_Interworking_with_power_saving_BWP_(5GC000937)
    Setup attenuators
    Turn off attenuation
    Set attenuation and check    lines=${lines_gNB_210_AZQS_1_FDD}   value=0
    Load scf for NR    ${resource_path_CB011031}    SCFs    USCCB011031-Interworking.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    ute_ue.Attach Ue     UE_1
    Start Data Transfer  dt_name=DT_DL_NSA  ue_alias=UE_1  direction=dl  duration=100s  interval=1
    ...                  throughput=10 Mbits/sec              protocol=udp   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_NSA  ue_alias=UE_1  direction=ul  duration=100s  interval=1
    ...                  throughput=10 Mbits/sec             protocol=udp
    Sleep                10s
    Start TTI trace streaming
    Check Data Transfer Is Alive               DT_DL_NSA
    Check Data Transfer Is Alive               DT_UL_NSA
    Await Data Transfer Finish                 DT_DL_NSA
	Await Data Transfer Finish                 DT_UL_NSA
    Stop TTI trace
    Check bler based on ttitrace  traffic_type=uldl
    Check bwpId powersaving
    Log to console  Waiting for counters update 300s...
    sleep  300s
    Verify PM Counters 11031

USCCB011031-A#4_HO_Intra_Freq_event_A3_between_5G_cells_from_cell_with_CB011031_off_to_cell_with_CB011031_on_SA
    @{mnCells}=    Create List    NRCELL_R-1  NRCELL_R-2
    ${filter}=   Set Variable    ${None}
    @{mn_logs}=    Create List    cp_5g    pmFiles
    @{messages}=    Create List
    ...  \{"reportConfigNR": \{"reportType": \{"eventTriggered": \{"eventId": \{"eventA3"
    ...  result:.*Success..IntraGnbTargetHo
    Load scf for NR    ${resource_path_CB011031}    SCFs    USCCB011031-HO_SA.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Setup attenuators
    Set initial attenuation for CB011031
    ute_ue.Attach Ue     UE_1
    Start UTF Lab Tracing  cells=${mnCells}  alias=MN
    ${CELL_ID}    ute_ue.Get Ue Info   UE_1  PCI
    Log to console   Cell ID before HO: ${CELL_ID}
    Should Be Equal As Numbers  ${CELL_ID}  1
    Start Data Transfer  dt_name=DT_DL_NSA  ue_alias=UE_1  direction=dl  duration=100s  interval=1
    ...                  throughput=500 Mbits/sec              protocol=udp   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_NSA  ue_alias=UE_1  direction=ul  duration=100s  interval=1
    ...                  throughput=50 Mbits/sec             protocol=udp
    Change radio conditions to perform Handover to cell 2
    ${CELL_ID_after_HO}    ute_ue.Get Ue Info   UE_1  PCI
    Log to console   Cell ID after HO: ${CELL_ID_after_HO}
    Should Be Equal As Numbers  ${CELL_ID_after_HO}  2
    Stop UTF Lab Tracing    alias=MN
    ${cp_5g}=    Prepare Logs For Analysis    requested_logs=${mn_logs}    source_dir=MN    target_dir=_extracted
    ...  filter=${filter}
    Verify Message Sequence In Json    ${messages}    ${cp_5g}
    Verify PM Counters eventA3
    [Teardown]  Run keywords
    ...   Await Data Transfer Finish     DT_DL_NSA    AND
    ...   Await Data Transfer Finish     DT_UL_NSA


USCCB011031-A#4_HO_Inter_Freq_event_A5_between_5G_cells_from_cell_with_CB011031_on_to_cell_with_CB011031_off_NSA
    Log to console   Please set UE to NSA mode before test run.
    @{mnCells}=    Create List    NRCELL_R-1  NRCELL_R-2
    ${filter}=   Set Variable    ${None}
    @{mn_logs}=    Create List    cp_5g    pmFiles
    @{messages}=    Create List  "reportConfig":.*"reportConfigNR":.*"reportType":.*"eventTriggered":.*"eventId":.*"eventA5":
    Load scf for NR    ${resource_path_CB011031}    SCFs    USCCB011031-HO_NSA.xml
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Wait until keyword succeeds    20 min    1 min    X2-C is available
    Setup attenuators
    Set initial attenuation for CB011031    is_nsa=True
    ute_ue.Attach Ue     UE_2
    Start UTF Lab Tracing  cells=${mnCells}  alias=MN
    ${CELL_ID}    ute_ue.Get Ue Info   UE_2  PCI
    Log to console   Cell ID before HO: ${CELL_ID}
    # Should Be Equal As Numbers  ${CELL_ID}  1
    Start Data Transfer  dt_name=DT_DL_NSA  ue_alias=UE_2  direction=dl  duration=100s  interval=1
    ...                  throughput=500 Mbits/sec              protocol=udp   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_NSA  ue_alias=UE_2  direction=ul  duration=100s  interval=1
    ...                  throughput=50 Mbits/sec             protocol=udp
    Change radio conditions to perform Handover to cell 2
    ${CELL_ID_after_HO}    ute_ue.Get Ue Info   UE_2  PCI
    Log to console   Cell ID after HO: ${CELL_ID_after_HO}
    Stop UTF Lab Tracing    alias=MN
    ${cp_5g}=    Prepare Logs For Analysis    requested_logs=${mn_logs}    source_dir=MN    target_dir=_extracted
    ...  filter=${filter}
    Verify Message Sequence In Json    ${messages}    ${cp_5g}
    # Verify PM Counters eventA5
    [Teardown]  Run keywords
    ...   Await Data Transfer Finish     DT_DL_NSA    AND
    ...   Await Data Transfer Finish     DT_UL_NSA


Verify that DRX was configured
    verify_tshark    alias=tcpdump    timeout=90    packet_filter=${DRX_CONFIG}    pcap_file_path=${OUTPUT DIR}/tcpdump.pcap
    ...              continue_on_failure=True     pass_criteria=>=1
    Log to console   DRX setup message found in pcap

Confirm that UE is in IDLE state
    verify_tshark    alias=tcpdump    timeout=90    packet_filter=${RRC_RELEASE}    pcap_file_path=${OUTPUT DIR}/tcpdump.pcap
    ...              continue_on_failure=True          pass_criteria=>=1
    Log to console   UE is in IDLE state

Start and verify traffic for normal BWP
    Start and verify traffic    100s    10 Mbits/sec    10 Mbits/sec

Start and verify traffic for powersaving BWP
    Start and verify traffic    100s    10 Kbits/sec    10 Kbits/sec

Start and verify traffic
    [Arguments]    ${duration}    ${dl_thrpt}    ${ul_thrpt}
	Start Data Transfer  dt_name=DT_DL_NSA  ue_alias=UE_1  direction=dl  duration=${duration}    interval=1
    ...                  throughput=${dl_thrpt}    protocol=udp   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_NSA  ue_alias=UE_1  direction=ul  duration=${duration}    interval=1
    ...                  throughput=${ul_thrpt}    protocol=udp
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_NSA
    Check Data Transfer Is Alive               DT_UL_NSA
    Await Data Transfer Finish                 DT_DL_NSA
	Await Data Transfer Finish                 DT_UL_NSA
    Verify Average Throughput With Deviation   DT_DL_NSA   ${dl_thrpt}   ${tput_deviation}
    Verify Average Throughput With Deviation   DT_UL_NSA   ${ul_thrpt}   ${tput_deviation}

Set initial attenuation for CB011031
    [Arguments]    ${is_nsa}=False
    Turn off attenuation
    IF    ${is_nsa}
        Set attenuation and check    lines=${lines_gNB_210_AHEC_1_LTE}   value=5
    END
    IF  '${sw_release}'=='SBTS24R2' or '${sw_release}'=='SBTS24R3'
        Set attenuation and check    lines=${lines_gNB_210_AZQS_1_FDD}   value=5
    ELSE
        Set attenuation and check    lines=${lines_gNB_210_AZQS_1_FDD_25R1}   value=5
    END

Change radio conditions to perform Handover to cell 2
    IF  '${sw_release}'=='SBTS24R2' or '${sw_release}'=='SBTS24R3'
        Attenuation procedure    ${lines_gNB_210_AZQS_1_FDD}    ${lines_gNB_210_AZQS_2_FDD}
    ELSE
        Attenuation procedure    ${lines_gNB_210_AZQS_1_FDD_25R1}    ${lines_gNB_210_AZQS_2_FDD_25R1}
    END

Attenuation procedure
    [Arguments]    ${source_cell_atten_lines}    ${target_cell_atten_lines}
    Sleep                10s
    Log to console  Decreasing radio conditions at first cell and handover
    Set attenuation and check  lines=${target_cell_atten_lines}   value=0
    sleep  3s
    Set attenuation and check  lines=${source_cell_atten_lines}   value=20
    Sleep  3s
    Set attenuation and check  lines=${source_cell_atten_lines}   value=40
    sleep  3s
    Set attenuation and check  lines=${source_cell_atten_lines}   value=65
    Sleep  3s
    Set attenuation and check  lines=${source_cell_atten_lines}   value=90
    Log to console  Attenuation set for HO
    Sleep  15s
