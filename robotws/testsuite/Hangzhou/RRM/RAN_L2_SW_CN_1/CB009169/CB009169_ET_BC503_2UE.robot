*** Settings ***
Documentation    ...
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CB009169    CRT    RAN_5G_TDD
#...               Owner_peafu    CN1_SQ6    SBTS00    SBTS23R3
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/Config/
#${FULL_SCFC}        SCF_CB009169_ET_BC503.xml
#${IPHY_XML}         ${CURDIR}/Resources/wts/iphy_CB009169_ET_BC102_BC503.xml
#${LOCAL_WTS_DIR}    ${CURDIR}/Resources/wts
#${WTS_AP_XML}       airphone.xml
#${WTS_CFG}          CB009169_ET_BC102_BC503.cfg
#${UE_ID}            2
#
#*** Test Cases ***
#CB009169_ET_BC503_FR1_TDD_FDD_FDD_DL3CC_UL2CC_Blind_ScellAdd_BufferBaseScellAct_Overheating
#    Two UE Attach And Scell Addition
#    Start DLUL Traffic For 2UEs
#    Capture BIP And TTitrace 1
#    Check Tput For 2UEs
#    CQI And UL BLER Mode Profile Setting
#    Check Scell Suspend When CQI Overheating Happen
#    Active UL Bad RLQ
#    Check Scell Resume With CQI 15 Plus UL BAD RLQ
#    Deactive UL Bad RLQ
#    Capture BIP And TTitrace 4
#    Check Tput For 2UEs
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#Two UE Attach And Scell Addition
#    SA Single UE Attach    1
#    Trigger A1 Scell Addition    ue_id=1    srsrp_nr=120    phycell_id=60
#    SA Single UE Attach    2
#    Trigger A1 Scell Addition    ue_id=2    srsrp_nr=120    phycell_id=60
#
#Start DLUL Traffic For 2UEs
#    SA Start UL Traffic Internal    ue_id=1    pdu_id=1    mbps=100
#    SA Start DL Traffic Internal    ue_id=1    pdu_id=1    mbps=400
#    SA Start UL Traffic Internal    ue_id=2    pdu_id=1    mbps=100
#    SA Start DL Traffic Internal    ue_id=2    pdu_id=1    mbps=400
#    Sleep    10s    reason=wait for traffic stable
#
#Check Tput For 2UEs
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    200
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    1    10
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    2    75
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    20
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    1    ul    scell    2    20
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    2    dl    pcell    0    200
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    2    dl    scell    1    10
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    2    dl    scell    2    75
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    2    ul    pcell    0    20
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    2    ul    scell    2    20
#
#Capture BIP And TTitrace 1
#    CUDU L2 Capture And Decode TTitrace    log_id=1    duration=2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/1
#
#Capture BIP And TTitrace 4
#    CUDU L2 Capture And Decode TTitrace    log_id=4    duration=2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/4
#
#Check UE2 Tput For CQI Overheating
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=pcell    scell_index=0    target_tp=235
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=scell    scell_index=1    target_tp=10
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=scell    scell_index=2    target_tp=0
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=ul    cell_type=scell    scell_index=0    target_tp=20
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=ul    cell_type=scell    scell_index=2    target_tp=0
#
#Check UE2 Tput For Combined Algs
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=pcell    scell_index=0    target_tp=235
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=scell    scell_index=1    target_tp=10
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=dl    cell_type=scell    scell_index=2    target_tp=80
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=ul    cell_type=scell    scell_index=0    target_tp=20
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=2    dir=ul    cell_type=scell    scell_index=2    target_tp=0
#
#Check Scell Suspend When CQI Overheating Happen
#    CUDU L2 Send Action To GNB    ue_id=2    testmode=csi_override    action=activate    profile_id=11    scell=2
#    Sleep    10s    reason=Wait for traffic stable
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/2
#    CUDU L2 Capture And Decode TTitrace    log_id=2    duration=2
#    Check UE2 Tput For CQI Overheating
#    ${scell_TP_DL}    Get CA Cell Average Throughput    ${UE_ID}    dl    scell    2
#    Log To Console    DL Troughput is ${scell_TP_DL}    console=True
#    Should Be True    ${scell_TP_DL}==0
#    ${scell_TP_UL}    Get CA Cell Average Throughput    ${UE_ID}    ul    scell    2
#    Log To Console    Ul Troughput is ${scell_TP_UL}    console=True
#    Should Be True    ${scell_TP_UL}==0
#
#Check Scell Resume With CQI 15 Plus UL BAD RLQ
#    CUDU L2 Send Action To GNB    ue_id=2    testmode=csi_override    action=activate    profile_id=12    scell=2
#    Sleep    10s    reason=Wait for traffic stable
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/3
#    CUDU L2 Capture And Decode TTitrace    log_id=3    duration=2
#    Check UE2 Tput For Combined Algs
#    ${scell_TP_UL}    Get CA Cell Average Throughput    ${UE_ID}    ul    scell    2
#    Log To Console    Ul Troughput is ${scell_TP_UL}    console=True
#    Should Be True    ${scell_TP_UL}<0.02
#
#CQI And UL BLER Mode Profile Setting
#    Set CQI Testmode    profile_id=11    cqi=0    ri=1
#    Set CQI Testmode    profile_id=12    cqi=15    ri=1
#    Set BLER Testmode    profile_id=30    ul_bler=950,950,950,950,950,950,950,950
#
#Active UL Bad RLQ
#    CUDU L2 Send Action To GNB    ue_id=2    testmode=bler    action=activate    profile_id=30    scell=2
#    Sleep    10s    reason=Wait for traffic stable
#
#Deactive UL Bad RLQ
#    CUDU L2 Send Action To GNB    ue_id=2    testmode=bler    action=deactivate    profile_id=30    scell=2
#    Sleep    10s    reason=Wait for traffic stable
