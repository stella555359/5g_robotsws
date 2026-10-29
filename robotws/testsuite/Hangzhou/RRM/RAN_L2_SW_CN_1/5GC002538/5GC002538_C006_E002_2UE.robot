*** Settings ***
Documentation    ...
#Suite Setup    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCFC_layer2}    iphy_file=${IPHY_XML}
#...            AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...            AND    Suite Setup Start WTS And Check OnAir
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags     CLOUD_5G_I_LO_AP_LO    5GC002538    CRT    RAN_5G    RAN_5G_TDD
#...            Owner_peafu    CN1_SG06    SBTS00    SBTS23R1
#Resource       ./5GC002538_Resource.robot
#
#*** Variables ***
#${SCF_PATH}                ${CURDIR}/config
#${FULL_SCFC_layer4}        5GC002538_TDD_SCFC_4layers.xml
#${FULL_SCFC_layer2}        5GC002538_TDD_SCFC_2layers.xml
#${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
#${WTS_CFG}                 2538.cfg
#${IPHY_XML}                ${CURDIR}/resources/wts/2538_iphy.xml
#${SWCONFIG_PARAM}          0x590004=4
#${UE_1}                    11
#${UE_2}                    12
#${PROFILE_ID}              1
#${GNB_ID}                  2
#${CELL_ID}                 1
#${BEAR_ID}                 2
#${TWO_LAYERS_2538_OFF}     728
#${TWO_LAYERS_2538_ON}      750
#${FOUR_LAYERS_2538_OFF}    440
#${FOUR_LAYERS_2538_ON}     480
#${TARGET_TPUT}             500
#
#*** Test Cases ***
#5GC002538_C006_PDSCH_In_SSB_And_TRS_Slot_For_TDD_100M_DL_SlotType_1208_1UE_NSA
#    [Setup]    Common Test Setup
#	NSA UE Attach    ${UE_1}    ${PROFILE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEAR_ID}
#	Start Traffic    ${UE_1}
#	CUDU L2 Capture And Decode TTitrace    log_id=2Layer_2538off_TTitrace    duration=2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=2Layer_2538off_BIP
#	Check TP    ${UE_1}    ${TWO_LAYERS_2538_OFF}
#    NSA LTE Detach    11
#    Enable 2534 And 2538
#    NSA UE Attach    ${UE_1}    ${PROFILE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEAR_ID}
#	Start Traffic    ${UE_1}
#	CUDU L2 Capture And Decode TTitrace    log_id=2Layer_2538on_TTitrace    duration=2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=2Layer_2538on_BIP
#    Check TP    ${UE_1}    ${TWO_LAYERS_2538_ON}
#    Covert BIP To Csv 2Layer
#    Verify Single UE PDSCH Schedule In SSB Slot
#    Verify Single UE PDSCH Schedule In TRS Slot
#	CUDU_L2 Check DTXNACK Rate    log_id=2Layer_2538on_TTitrace
#	CUDU_L2 Check UL DTXCRC Rate    log_id=2Layer_2538on_TTitrace
#
#5GC002538_E002_PDSCH_In_SSB_And_TRS_Slot_80M_DL_Mimo_4x2_SlotType_1208_4Beam_2UE_NSA
#    [Setup]    Run Keywords    Test Setup With Layer4
#    NSA UE Attach With DL Traffic Setup
#	CUDU L2 Capture And Decode TTitrace    log_id=4Layer_2538off_TTitrace    duration=2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=4Layer_2538off_BIP
#    DL Tput Check    ${FOUR_LAYERS_2538_OFF}
#	Two UE Detach
#    Enable 2534 And 2538
#    NSA UE Attach With DL Traffic Setup
# 	CUDU L2 Capture And Decode TTitrace    log_id=4Layer_2538on_TTitrace    duration=2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=4Layer_2538on_BIP
#    DL Tput Check    ${FOUR_LAYERS_2538_ON}
#	Covert BIP To Csv 4Layer
#    Verify Multi UE PDSCH Schedule In SSB Slot
#    Verify Multi UE PDSCH Schedule In TRS Slot
#	CUDU_L2 Check DTXNACK Rate    log_id=4Layer_2538on_TTitrace
#	CUDU_L2 Check UL DTXCRC Rate    log_id=4Layer_2538on_TTitrace
#
#*** Keywords ***
#Test Setup With Layer4
#    Suite Setup Update GNB    ${SWCONFIG_PARAM}    ${FULL_SCFC_layer4}    iphy_file=${IPHY_XML}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#    Modify WTS For Rank4
#    Common Test Setup
#
#Modify WTS For Rank4
#    Log To Console    Modify WTS For Rank4...
#    OperatingSystem.Run    sudo sysctl -w net.core.wmem_max=20971520
#    OperatingSystem.Run    sudo sysctl -w net.core.wmem_default=20971520
#    OperatingSystem.Run    sudo sysctl -w net.core.rmem_max=20971520
#    OperatingSystem.Run    sudo sysctl -w net.core.rmem_default=20971520
#
#NSA UE Attach
#    [Arguments]    ${UE_ID}    ${PROFILE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEAR_ID}
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEAR_ID}
#    Log To Console    ue${ueId} NSA rach successfully.
#
#NSA UE Attach With DL Traffic Setup
#    : FOR    ${UE_ID}    IN RANGE    ${UE_1}    ${UE_2}+1
#    \    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    \    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEAR_ID}
#    \    Set PDSCH Test Mode
#    \    Start NSA DL Big Traffic Internal    ${UE_ID}    875
#    \    Sleep    15s    reason=Wait for DL Tput stable
#
#
#Start Traffic
#    [Arguments]    ${UE_ID}
#    NSA Start DL Traffic    ue_id=${ueId}    bearer_id=2    mbps=175    trf_id=1
#    NSA Start DL Traffic    ue_id=${ueId}    bearer_id=2    mbps=175    trf_id=2
#    NSA Start DL Traffic    ue_id=${ueId}    bearer_id=2    mbps=175    trf_id=3
#    NSA Start DL Traffic    ue_id=${ueId}    bearer_id=2    mbps=175    trf_id=4
#    NSA Start DL Traffic    ue_id=${ueId}    bearer_id=2    mbps=175    trf_id=5
#    NSA Start DL Traffic    ue_id=${ueId}    bearer_id=2    mbps=175    trf_id=6
#    NSA Start DL Traffic    ue_id=${ueId}    bearer_id=2    mbps=175    trf_id=7
#    NSA Start DL Traffic    ue_id=${ueId}    bearer_id=2    mbps=175    trf_id=8
#    NSA Start DL Traffic    ue_id=${ueId}    bearer_id=2    mbps=175    trf_id=9
#    Sleep    15s    reason=Wait for DL Tput stable
#
#
#Check TP
#    [Arguments]    ${UE_ID}    ${TARGET_TPUT}
#    NSA Check Average Traffic Bigger Than Target    ${ueId}    2    dl    ${TARGET_TPUT}
#
#Enable 2534 And 2538
#    Log To Console    Enable 2534 And 2538...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    actPdschAtSsbSlots    true
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    actPdschRmCsirsForTracking    true
#    Wait Until Keyword Succeeds    10s    3s    Verify BTS Is OnAir
#	Sleep     90s    reason=Wait for Online Change Done
#
#Covert BIP To Csv 2Layer
#    ${bip_name}    Set Variable    ${TEST_LOG_DIRECTORY}/2Layer_2538on_BIP/5GBipL2L1_filtering_off.pcap
#    Convert BIP To CSV By MCShark    ${bip_name}    ${OUTPUT_DIR}/5GBipL2L1_filtering_off.csv    filter=${FILTER}    csv_title_list=${COLUMN_NAME}
#
#Covert BIP To Csv 4Layer
#    ${bip_name}    Set Variable    ${TEST_LOG_DIRECTORY}/4Layer_2538on_BIP/5GBipL2L1_filtering_off.pcap
#    Convert BIP To CSV By MCShark    ${bip_name}    ${OUTPUT_DIR}/5GBipL2L1_filtering_off.csv    filter=${FILTER}    csv_title_list=${COLUMN_NAME}
#
#DL Tput Check
#    [Arguments]    ${TARGET_TPUT}
#    : FOR    ${UE_ID}    IN RANGE    ${UE_1}    ${UE_2}+1
#    \    NSA Check Average Traffic Bigger Than Target    ${UE_ID}    2    dl    ${TARGET_TPUT}
#
#Start NSA DL Big Traffic Internal
#    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
#    [Documentation]    this keyword is to start big dl udp traffic which more than 175.
#    ${dl_times}    Evaluate    int(${mbps}/${175})
#    : FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
#    \    NSA Start DL Traffic    ${ue_id}    ${BEAR_ID}    mbps=175    trf_id=${t_time}
#    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
#    NSA Start DL Traffic    ${ue_id}    ${BEAR_ID}    mbps=${last_mbps}    trf_id=${dl_times+1}
#
#Two UE Detach
#    : FOR    ${UE_ID}    IN RANGE    ${UE_1}    ${UE_2}+1
#    \    NSA LTE Detach    ${UE_ID}
