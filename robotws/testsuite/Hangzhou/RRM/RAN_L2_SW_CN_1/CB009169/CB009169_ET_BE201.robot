*** Settings ***
Documentation    ...
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CB009169    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_peafu    CN1_SQ6    SBTS00    SBTS23R3
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}              ${CURDIR}/Config/
#${FULL_SCFC}             SCF_CB009169_ET_BC201.xml
#${IPHY_XML}              ${CURDIR}/Resources/wts/iphy_CB009169_ET_BC102_BC503.xml
#${LOCAL_WTS_DIR}         ${CURDIR}/Resources/wts
#${WTS_AP_XML}            airphone.xml
#${WTS_CFG}               CB009169_ET_BE201.cfg
#${EGATE_FILE}            /opt/iphy/latest/egate_console.log
#@{CA_UE_LIST}            1    2
#@{2CC_PCELL_ID_LIST}     60    60
#@{2CC_SCELL_ID_LIST1}    52
#@{2CC_SCELL_ID_LIST2}    52
#@{2CC_SCELL_ID_LIST}     ${2CC_SCELL_ID_LIST1}    ${2CC_SCELL_ID_LIST2}
#${A1THRESHOLD}           100
#${UE_3}                  3
#${UE_4}                  4
#${UE_5}                  5
#${2CC_DL_DATA}           525
#${2CC_UL_DATA}           100
#@{CA_UL_TPUT}            10    30    10    30
#@{CA_DL_TPUT}            90    45    90    45
#
#*** Test Cases ***
#CB009169_ET_BE201_T_F_100Mhz_20Mhz_MultiUE_Cell_Lock_With_Graceful_Cell_Shutdown_On_Pcell_ABIO
#    SA Multi UE Attach With Scell A1 Addition    ${CA_UE_LIST}    ${2CC_PCELL_ID_LIST}
#    ...    ${2CC_SCELL_ID_LIST}    ${A1THRESHOLD}    2
#    Non CA UE Attach
#    Start DLUL Traffic For All UEs
#    Check Tput For All UEs
#    Enable Graceful Shutdown For Cell 11
#    Verify Handover For UE1
#    Verify Handover For UE3
#    Tput Check After HO For UE1 UE3
#    Wait Until Keyword Succeeds    3min    30s    Verify UE2 UE4 Release
#    Verify UE5 Is Normal
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#Non CA UE Attach
#    SA Single UE Attach    ${UE_3}
#    SA Single UE Attach    ${UE_4}
#    SA Single UE Attach    ${UE_5}
#
#Start DLUL Traffic For All UEs
#    SA Multi UE Start DL And UL Traffic    ${CA_UE_LIST}    ${2CC_DL_DATA}    ${2CC_UL_DATA}
#    SA Start DL Traffic Internal    ue_id=3    pdu_id=1    mbps=400
#    SA Start UL Traffic Internal    ue_id=3    pdu_id=1    mbps=100
#    SA Start DL Traffic Internal    ue_id=4    pdu_id=1    mbps=400
#    SA Start UL Traffic Internal    ue_id=4    pdu_id=1    mbps=100
#    SA Start DL Traffic Internal    ue_id=5    pdu_id=1    mbps=150
#    SA Start UL Traffic Internal    ue_id=5    pdu_id=1    mbps=150
#
#Check Tput For All UEs
#    sleep    10s
#    CUDU L2 Capture And Decode TTitrace    log_id=1    duration=2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/1
#    Wait Until Keyword Succeeds    60s    5s    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${CA_UE_LIST}    ${CA_UL_TPUT}    ${CA_DL_TPUT}    2
#    Check CA UE Pcell Scell Cell TPut On Target    3    dl    pcell    0    90
#    Check CA UE Pcell Scell Cell TPut On Target    3    ul    pcell    0    25
#    Check CA UE Pcell Scell Cell TPut On Target    4    dl    pcell    0    90
#    Check CA UE Pcell Scell Cell TPut On Target    4    ul    pcell    0    25
#    Check CA UE Pcell Scell Cell TPut On Target    5    dl    pcell    0    45
#    Check CA UE Pcell Scell Cell TPut On Target    5    ul    pcell    0    60
#
#Enable Graceful Shutdown For Cell 11
#    Log To Console    Enable graceful shutdown for cell 11...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-11    administrativeState    Shutting Down
#
#Verify Handover For UE1
#    Trigger A2 Event For UE1
#    Trigger A3 Event And Check Handover Status For UE1
#
#Trigger A2 Event For UE1
#    Log To Console    Trigger A2 event...
#    ${pattern}    Set Variable    rrcReconfigurationComplete
#    ${cmd}    Catenate    ue_measurement_send_nr id\=1 meas_id\=1 rs_type\=ssb event\=A2
#    ...    srsrp_nr\=25
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#Trigger A3 Event And Check Handover Status For UE1
#    Log To Console    Trigger A3 event...
#    ${pattern}    Set Variable    UE1: Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.1 performed
#    ${cmd}    Catenate    ue_measurement_send_nr id\=1 meas_id\=6 event\=A3 srsrp_nr\=20
#    ...    phycell_id\=50 nrsrp_nr\=100
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#Tput Check After HO For UE1 UE3
#    sleep    10s
#    CUDU L2 Capture And Decode TTitrace    log_id=2    duration=2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/2
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    12
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    5
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    3    dl    pcell    0    12
#    Wait Until Keyword Succeeds    1min    5s    Check CA UE Pcell Scell Cell TPut On Target    3    ul    pcell    0    12
#
#Verify Handover For UE3
#    Trigger A2 Event For UE3
#    Trigger A3 Event And Check Handover Status For UE3
#
#Trigger A2 Event For UE3
#    Log To Console    Trigger A2 event...
#    ${pattern}    Set Variable    rrcReconfigurationComplete
#    ${cmd}    Catenate    ue_measurement_send_nr id\=3 meas_id\=1 rs_type\=ssb event\=A2
#    ...    srsrp_nr\=25
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#Trigger A3 Event And Check Handover Status For UE3
#    Log To Console    Trigger A3 event...
#    ${pattern}    Set Variable    UE3: Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.1 performed
#    ${cmd}    Catenate    ue_measurement_send_nr id\=3 meas_id\=4 event\=A3 srsrp_nr\=20
#    ...    phycell_id\=50 nrsrp_nr\=100
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#Verify UE2 UE4 Release
#    UE2 Detach
#    UE4 Detach
#
#UE2 Detach
#    Log To Console    Verify UE2 release...
#    Wait Until Keyword Succeeds    90s    10s    Check Egate Log With Message    ${EGATE_FILE}
#    ...    UE2: detached
#
#UE4 Detach
#    Log To Console    Verify UE4 release...
#    Wait Until Keyword Succeeds    90s    10s    Check Egate Log With Message    ${EGATE_FILE}
#    ...    UE4: detached
#
#Verify UE5 Is Normal
#    sleep    10s
#    CUDU L2 Capture And Decode TTitrace    log_id=3    duration=2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/3
#    Check CA UE Pcell Scell Cell TPut On Target    5    dl    pcell    0    140
#    Check CA UE Pcell Scell Cell TPut On Target    5    ul    pcell    0    140
