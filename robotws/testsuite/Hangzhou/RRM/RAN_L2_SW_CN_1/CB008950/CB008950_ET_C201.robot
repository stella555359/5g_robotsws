*** Settings ***
Documentation    ...
#Test Teardown     Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_nilei
#...               SBTS00    CN1_SG06    CB008950
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/Config/
#${SCFC_FILE}        CB008950_2F_6T_C201.xml
#${LOCAL_WTS_DIR}    ${CURDIR}/Config/wts/
#${WTS_DIR}          /opt/iphy/latest
#${IPHYFILE}         ${CURDIR}/Config/wts/iphy_2F_6T.xml
#${WTS_CFG}          CB008950_2F_6T.cfg
#${UE_ID}            1
#${PCELL_ID}         50
#${SCELL1_ID}        60
#${SCELL2_ID}        61
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB008950_ET_C201_Scell_Swap_SA_More_Than_2_Scell_Candidates
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHYFILE}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID}
#    Trigger A1 Scell Addition    ${UE_ID}    100    ${PCELL_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL1_ID}    1
#    Start SA DLUL Big Traffic Internal For UE
#    Sleep    10s    reason=wait for dl traffic stable
#    Check TP On Target FT    ${UE_ID}    0    1    640    90
#    Trigger Scell Swap And Check Scell Addition Successful
#    Sleep    10s    reason=wait for dl traffic stable
#    Check TP On Target FT    ${UE_ID}    0    2    640    90
#    #Capture Logs And Check TTitrace    log_id=1
#
#*** Keywords ***
#Start SA DLUL Big Traffic Internal For UE
#    [Documentation]    this keyword is to start all traffic.
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=110    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=680    trf_id=1
#
#Check TP On Target FT
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}    ${target_ulsum_tp}
#    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
#    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
#    ${dlsum_tp}    Evaluate    ${pcell_dlTP}+${scell_dlTP}
#    Log To Console    DL Troughput is ${dlsum_tp}    console=True
#    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}
#    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    0
#    Log To Console    UL Troughput is ${pcell_ulTP}    console=True
#    Should Be True    ${pcell_ulTP}>=${target_ulsum_tp}
#
#Trigger Scell Swap And Check Scell Addition Successful
#    Trigger A6 Scell Swape    ${UE_ID}    4    1    ${SCELL2_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL2_ID}    2
#
#Capture Logs And Check TTitrace
#    [Arguments]    ${log_id}
#    Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/${log_id}
#    CUDU L2 Capture And Decode TTitrace    log_id=${log_id}    duration=3
#    CUDU L2 Check DTXNACK Rate    log_id=${log_id}
#    CUDU L2 Check UL DTXCRC Rate    log_id=${log_id}
