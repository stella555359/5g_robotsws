*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#
#
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD    Owner_qiaren
#...               CN1_SQ6    SBTS00    SBTS23R1    SBTS22R4
#*** Variables ***
#
#${SCF_PATH}                ${CURDIR}/config/
#${FULL_SCFC}               full_scfc.xml
#${IPHY_XML}                ${CURDIR}/config/iphy_4F_2T.xml
#${LOCAL_WTS_DIR}           ${CURDIR}/config
#${WTS_CFG}                  basic_2546.cfg
#${WTS_AP_XML}               airphone.xml
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#*** Test Cases ***
#5GC002546_ET_BB002_Verify_2CaUEs_BufferBased_ScellActivationMethod_NSA
#    NSA F+T CA UE Attach     ueId=82    cellId=1
#    NSA F+T CA UE Attach     ueId=83    cellId=2
#    A1 Triggered Scell Addition    ueId=83    measId=3
#    NSA F+T CA UE Attach     ueId=84    cellId=5
#    NSA Start Traffic And Check TP
#    Run Keyword And Ignore Error     Start And Stop Tti Trace
#
#
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB     scf_file=${FULL_SCFC}       iphy_file=${IPHY_XML}
#    #Suite Setup Update GNB
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ${KW_status}    ${BTSonair_status}    Run Keyword And Ignore Error    Suite Setup Start WTS And Check OnAir
#    Run Keyword If    '${KW_status}'=='FAIL'    Not OnAir Workaround
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#NSA F+T CA UE Attach
#    [Arguments]    ${ueId}    ${gnbId}=2   ${cellId}=1    ${bearID}=2
#    NSA LTE Attach  ue_id=${ueid}
#    NSA 5G Attach   ue_id=${ueId}   gnb_id=${gnbId}   cell_id=${cellId}  bearer_id=${bearID}
#    Log To Console    ue${ueId} NSA rach successfully.
#
#Start And Stop Tti Trace
#    Start GNB TTI Trace
#    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
#    Stop And Decode GNB TTI Trace    ${TEST_LOG_DIRECTORY}
#
#NSA Start Traffic And Check TP
#    NSA Start Traffic For UE    ueId=82
#    NSA Start Traffic For UE    ueId=83
#    NSA Start Traffic For UE    ueId=84
#    NSA Check TP For CA UE    ueId=82
#    NSA Check TP For CA UE    ueId=83
#    NSA Check TP For CA UE    ueId=84
#
#NSA Start Traffic For UE
#    [Arguments]    ${ueId}
#    NSA Start DL Traffic    ue_id=${ueId}     bearer_id=2    mbps=175
#    NSA Start DL Traffic    ue_id=${ueId}     bearer_id=2    mbps=175    trf_id=2
#    NSA Start UL Traffic    ue_id=${ueId}     bearer_id=2     mbps=10
#
#NSA Check TP For CA UE
#    [Arguments]    ${ueId}
#    NSA Check Average Traffic Bigger Than Target    ${ueId}    2   dl    90
#    #NSA Check Average Traffic Bigger Than Target    ${ueId}    2   ul    5
#    Wait Until Keyword Succeeds    1min    5s    Check Pcell Scell TP On Target    ${ueId}
#
#Check Pcell Scell TP On Target
#    [Arguments]    ${ueId}
#      ${pcell_TP}     Get CA Cell Average Throughput      ${ueId}    dl    scell  8
#    ${scell_TP}     Get CA Cell Average Throughput      ${ueId}    dl    scell  9
#    Log To Console    DL Troughput is ${pcell_TP}    console=True
#    Log To Console    UL Troughput is ${scell_TP}    console=True
#    Should Be True    ${pcell_TP}>=50
#    Should Be True    ${scell_TP}>=100
#
#A1 Triggered Scell Addition
#    [Arguments]    ${ueId}    ${rsrpnr}=90    ${measId}=1
#    ${command}    Set Variable    ue_measurement_send_nr id=${ueId} meas_id=${measId} event=A1 srsrp_nr=${rsrpnr} phycell_id=51
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}
#    ...   pass_regexp=rrcConnectionReconfigurationComplete    timeout=1minutes
#
#
#Set Reordering Timer
#    [Arguments]    ${reordering_window_size}    ${reordering_timer}
#    ${cmd_reordering}    Catenate    SEPARATOR=${space}    uec_param id\=1
#    ...    reordering_window_size\=${reordering_window_size} reordering_timer\=${reordering_timer}
#    ute_wtssim.Execute Egate Command    cmd=${cmd_reordering}
#
#Not OnAir Workaround
#    Reboot TL And Check Configured
#    Run Keyword And Ignore Error    Clean Edaemon And Egate
#    Suite Setup Start WTS And Check OnAir
