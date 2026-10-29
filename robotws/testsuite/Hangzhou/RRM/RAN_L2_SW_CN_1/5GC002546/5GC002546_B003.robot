*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown    debug
#
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5GC002546    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_suxu    CN1_SQ6    SBTS00    SBTS23R1    SBTS22R4
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                ${CURDIR}/config/
#${FULL_SCFC}               full_scfc.xml
#${DELTA_SCFC}              2546_B004.json
#${IPHY_XML}                ${CURDIR}/config/iphy_4F_2T.xml
#${LOCAL_WTS_DIR}           ${CURDIR}/config
#${WTS_CFG}                   basic_2546.cfg
#${WTS_AP_XML}                airphone.xml
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#
#*** Test Cases ***
#5GC002546_ET_B003_Verify_3CaUEs_BufferBased_ScellActivationMethod_SA
#    SA F+T CA UE Attach    ueId=1    cellId=1
#    SA F+T CA UE Attach    ueId=2    cellId=2
#    A1 Triggered Scell Addition    ueId=2    rsrpnr=90
#    Check SA Scell PhyCellId With UeId    ue_id=2    scell_physicalid=52    scell_index=1
#    SA F+T CA UE Attach    ueId=3    cellId=5
#    SA Start Traffic And Check Tput    ueId=1    dlTput=360    ulTput=20
#    SA Start Traffic And Check Tput    ueId=2    dlTput=200    ulTput=20
#    SA Start Traffic And Check Tput    ueId=3    dlTput=100    ulTput=20
#    [Teardown]    2546 B003 Teardown
#
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#A1 Triggered Scell Addition
#    [Arguments]    ${ueId}    ${rsrpnr}=80    ${measId}=1
#    ${command}    Set Variable    ue_measurement_send_nr id=${ueId} meas_id=${measId} event=A1 srsrp_nr=${rsrpnr} phycell_id=51
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=1minutes
#    Run Keyword And Ignore Error    Get And Check Scell Infos    ('1', '52', '41')
#
#Check SA Scell PhyCellId With UeId
#    [Arguments]    ${ue_id}    ${scell_physicalid}    ${scell_index}
#    Save Egate Log
#    ${t_scell_id}    Get PhysCellId With UE Id From Egate Log
#    ...    ${ue_id}    ${scell_index}    ${SUITE_LOG_DIRECTORY}/egate_console.log
#    Should Be True    "${scell_physicalid}"=="${t_scell_id}"
#
#SA F+T CA UE Attach
#    [Arguments]    ${ueId}    ${cellId}
#    SA 5G Attach    ue_id=${ueId}
#    SA Set Traffic Type To Internal    ue_id=${ueId}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${ueId}
#    Log To Console    ue${ueId} SA rach successfully.
#
#SA Start Traffic And Check Tput
#    [Arguments]    ${ueId}    ${dlTput}    ${ulTput}
#    SA Start DL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=150    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=150    trf_id=2
#    SA Start DL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=150    trf_id=3
#    SA Start UL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=50    trf_id=1
#    Wait Until Keyword Succeeds    1min    5s    SA UE Check Throughput    ${ueId}    ${dlTput}    ${ulTput}
#    ${pcell_TP}     Get CA Cell Average Throughput      ${ueId}    dl    pcell  0
#    ${scell_TP}     Get CA Cell Average Throughput      ${ueId}    dl    scell  1
#    Log To Console    pcell DL Troughput is ${pcell_TP}    console=True
#    Log To Console    scell DL Troughput is ${scell_TP}    console=True
#
#NonCA UE Start Traffic And Check Tput
#    [Arguments]    ${ueId}    ${sendDlData}    ${dlTput}    ${ulTput}
#    SA Start DL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=${sendDlData}    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=50    trf_id=1
#    Wait Until Keyword Succeeds    30s    5s    SA UE Check Throughput    ${ueId}    ${dlTput}    ${ulTput}
#
#Set Reordering Timer
#    [Arguments]    ${reordering_window_size}    ${reordering_timer}
#    ${cmd_reordering}    Catenate    SEPARATOR=${space}    uec_param id\=1
#    ...    reordering_window_size\=${reordering_window_size} reordering_timer\=${reordering_timer}
#    ute_wtssim.Execute Egate Command    cmd=${cmd_reordering}
#
#2546 B003 Teardown
#    SA 5G Detach    ue_id=1
#    SA 5G Detach    ue_id=2
#    SA 5G Detach    ue_id=3
#
#Start And Stop Tti Trace
#    Start GNB TTI Trace
#    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
#    Stop And Decode GNB TTI Trace    ${TEST_LOG_DIRECTORY}
