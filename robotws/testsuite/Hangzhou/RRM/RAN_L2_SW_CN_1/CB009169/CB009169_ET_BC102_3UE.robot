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
#${FULL_SCFC}        SCF_CB009169_ET_BC102.xml
#${IPHY_XML}         ${CURDIR}/Resources/wts/iphy_CB009169_ET_BC102_BC503.xml
#${LOCAL_WTS_DIR}    ${CURDIR}/Resources/wts
#${WTS_AP_XML}       airphone.xml
#${WTS_CFG}          CB009169_ET_BC102_BC503.cfg
#${EGATE_FILE}       /opt/iphy/latest/egate_console.log
#
#*** Test Cases ***
#CB009169_ET_BC102_FR1_TDD_FDD_UL_2CC_A1_ScellAdd_BufferBaseScellActivation_MultiUEs_1208
#    UE3 Attach And Scell Addition
#    Start DLUL Traffic For UE3
#    Check Tput For UE3
#    Capture BIP And TTitrace 1
#    UE4 Attach And Scell Addition
#    Start DLUL Traffic For UE4
#    Check Tput For UE4
#    Capture BIP And TTitrace 2
#    UE5 Attach And Scell Addition
#    Start DLUL Traffic For UE5
#    Capture BIP And TTitrace 3
#    Check Tput For All UEs
#    Stop UE5 UL Traffic And Check Tput
#    Stop UE5 DL Traffic
#    Verify UE5 Scell Is Deactived
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#UE3 Attach And Scell Addition
#    SA Single UE Attach    3
#    Trigger A1 Scell Addition    ue_id=3    srsrp_nr=120    phycell_id=60
#
#UE4 Attach And Scell Addition
#    SA Single UE Attach    4
#    Trigger A1 Scell Addition    ue_id=4    srsrp_nr=120    phycell_id=60
#
#UE5 Attach And Scell Addition
#    SA Single UE Attach    5
#    Trigger A1 Scell Addition    ue_id=5    srsrp_nr=120    phycell_id=60
#
#Start DLUL Traffic For UE3
#    SA Start UL Traffic Internal    ue_id=3    pdu_id=1    mbps=150
#    SA Start DL Traffic Internal    ue_id=3    pdu_id=1    mbps=1000
#    Sleep    10s    reason=wait for data stable
#
#Start DLUL Traffic For UE4
#    SA Start UL Traffic Internal    ue_id=4    pdu_id=1    mbps=70
#    SA Start DL Traffic Internal    ue_id=4    pdu_id=1    mbps=500
#    Sleep    10s    reason=wait for data stable
#
#Start DLUL Traffic For UE5
#    SA Start UL Traffic Internal    ue_id=5    pdu_id=1    mbps=50
#    SA Start DL Traffic Internal    ue_id=5    pdu_id=1    mbps=350
#    Sleep    10s    reason=wait for data stable
#
#Check Tput For UE3
#    Check CA UE Pcell Scell Cell TPut On Target    3    dl    pcell    0    460
#    Check CA UE Pcell Scell Cell TPut On Target    3    dl    scell    1    177
#    Check CA UE Pcell Scell Cell TPut On Target    3    ul    pcell    0    55
#    Check CA UE Pcell Scell Cell TPut On Target    3    ul    scell    1    55
#
#Check Tput For UE4
#    Check CA UE Pcell Scell Cell TPut On Target    4    dl    pcell    0    240
#    Check CA UE Pcell Scell Cell TPut On Target    4    dl    scell    1    90
#    Check CA UE Pcell Scell Cell TPut On Target    4    ul    pcell    0    25
#    Check CA UE Pcell Scell Cell TPut On Target    4    ul    scell    1    25
#
#Check Tput For All UEs
#    Check CA UE Pcell Scell Cell TPut On Target    3    dl    pcell    0    150
#    Check CA UE Pcell Scell Cell TPut On Target    3    dl    scell    1    52
#    Check CA UE Pcell Scell Cell TPut On Target    3    ul    pcell    0    18
#    Check CA UE Pcell Scell Cell TPut On Target    3    ul    scell    1    18
#    Check CA UE Pcell Scell Cell TPut On Target    4    dl    pcell    0    150
#    Check CA UE Pcell Scell Cell TPut On Target    4    dl    scell    1    52
#    Check CA UE Pcell Scell Cell TPut On Target    4    ul    pcell    0    18
#    Check CA UE Pcell Scell Cell TPut On Target    4    ul    scell    1    18
#    Check CA UE Pcell Scell Cell TPut On Target    5    dl    pcell    0    150
#    Check CA UE Pcell Scell Cell TPut On Target    5    dl    scell    1    52
#    Check CA UE Pcell Scell Cell TPut On Target    5    ul    pcell    0    18
#    Check CA UE Pcell Scell Cell TPut On Target    5    ul    scell    1    18
#
#Capture BIP And TTitrace 1
#    Capture Convert Format Ttitrace With Streaming Mode    capture_time=2s    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/1
#
#Capture BIP And TTitrace 2
#    Capture Convert Format Ttitrace With Streaming Mode    capture_time=2s    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/2
#
#Capture BIP And TTitrace 3
#    Capture Convert Format Ttitrace With Streaming Mode    capture_time=2s    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
#    ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=BIP/3
#
#Stop UE5 DL Traffic
#    Log To Console    stop UE1 DL traffic...\n
#    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=5 pdu\=1 dir=dl trf_id\=1
#    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=5 pdu\=1 dir=dl trf_id\=2
#    Sleep    10s    reason=wait for Tput stable
#
#Stop UE5 UL Traffic And Check Tput
#    Log To Console    stop UE5 UL traffic...\n
#    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=5 pdu\=1 dir=ul trf_id\=1
#    Sleep    20s    reason=wait for Tput stable
#    Check CA UE Pcell Scell Cell TPut On Target    5    dl    pcell    0    150
#    Check CA UE Pcell Scell Cell TPut On Target    5    dl    scell    1    52
#    Check UL Tput After Stopping UL Traffic    5    0
#    Check UL Tput After Stopping UL Traffic    5    1
#
#Check UL Tput After Stopping UL Traffic
#    [Arguments]    ${ueId}    ${scell_index}
#    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
#    Should Be True    ${scell_dlTP}<0.01
#
#Verify UE5 Scell Is Deactived
#    Log To Console    Wait for UE5 Scell deactive ...
#    Wait Until Keyword Succeeds    20s    1s    Check Egate Log With Message    ${egate_file}
#    ...    SCellIndex 1 deactivated successfully
