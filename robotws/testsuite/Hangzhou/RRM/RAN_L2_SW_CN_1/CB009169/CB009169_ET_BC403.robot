*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF}    swconfig_param=${SWCONF}    iphy_file=${IPHYFILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CB009169    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_nilei    CN1_SQ6    SBTS00    SBTS23R3
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/Config
#${FULL_SCF}                  CB009169_LOO_BC403.xml
#${IPHYFILE}                  ${CURDIR}/Resources/wts/iphy_LOO2T3F_BC403.xml
#${SWCONF}                    0x580692=1;0x5801FC=3;0x580161=3;0x5801FB=100
#${WTS_LOCAL}                 ${CURDIR}/Resources/wts
#${WTS_DIR}                   /opt/wts/latest/
#${WTS_CFG}                   CB009169_LOO_BC403.cfg
#${WTS_AP_XML}                airphone.xml
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#${UE_ID}                     1
#${SCELL_ID}                  51
#
#*** Test Cases ***
#CB009169_ET_BC403_FR1_TDD_FDD_UL_2CC_Blind_ScellAdd_BufferBaseScellAct_Both_Pcell_Scell_UL_NACK_Flood
#    [Documentation]
#    ...    Check point    1.bufferSplitTrigger is 1 not 15 when Both_PCell_and_SCell_UL_NACK_flood_are_triggered
#    ...    2.laTimer.event start,stop when enterNFD,exitNFD
#    ...    3.When enter NFD, ulLaDeltaSinr.rrmPauseUeInUlScheduling=0 and stop UL Scheduling
#    ...    When exit NFD, ulLaDeltaSinr.rrmPauseUeInUlScheduling=1 and start UL Scheduling
#    ...    4.After rdPeriodUlScheduling(pscell both 100ms, 10SFN), time out, if receive 3 crc nok,
#    ...    wait rdPeriodUlScheduling again
#    ...    rd parameter:0x580692 # enable/disable CB009169
#    ...    0x5801FC # rdMinCrcNackIndUlEnhancedSCell
#    ...    0x580161 # rdMinCrcNackIndUlEnhanced
#    ...    0x5801FB # rdPeriodUlSchedulingSCell
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
#    ...    AND    Common Test Setup
#    SA Attach    ${UE_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL_ID}    1
#    Start SA DLUL Big Traffic Internal For UE
#    Check TP On Target    ${UE_ID}    0    1    390    90
#    Capture And Decode TTitrace When NACKFLOOD Trigger
#    Check NACKFLOOD From TTI    ${TEST_LOG_DIRECTORY}/ttitrace/BC403
#
#*** Keywords ***
#SA Attach
#    [Arguments]    ${sa_ue_id}
#    [Documentation]    This keyword is to start SA UE attach. it includes 3 steps
#    ...    ue_register
#    ...    set_pdu_param
#    ...    ue_pdu_session_setup
#    SA 5G Attach    ue_id=${sa_ue_id}
#    SA Set Traffic Type To Internal    ue_id=${sa_ue_id}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${sa_ue_id}
#
#Start SA DLUL Big Traffic Internal For UE
#    [Documentation]    this keyword is to start all traffic.
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=100    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=400    trf_id=1
#
#Check TP On Target
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}    ${target_ulsum_tp}
#    Sleep    30s    reason=Wait for TP collection...
#    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
#    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
#    ${dlsum_tp}    Evaluate    ${pcell_dlTP}+${scell_dlTP}
#    Log To Console    DL Troughput is ${dlsum_tp}    console=True
#    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}
#    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
#    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
#    ${ulsum_tp}    Evaluate    ${pcell_ulTP}+${scell_ulTP}
#    Log To Console    UL Troughput is ${ulsum_tp}    console=True
#    Should Be True    ${ulsum_tp}>=${target_ulsum_tp}
#
#Add UL Bler For PSCELL To Make NACKFLOOD
#    Set BLER Testmode    profile_id=1    ul_bler=800,800,800,800,800,800,800,800
#    CUDU L2 Send Action To GNB    ue_id=1    testmode=bler    action=activate    profile_id=1    scell=0,1
#
#Capture And Decode TTitrace When NACKFLOOD Trigger
#    Start Ttitrace With Streaming Mode
#    Add UL Bler For PSCELL To Make NACKFLOOD
#    Sleep    3s    reason=Wait for log collection...
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/BC403
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/BC403
#
#Check NACKFLOOD From TTI
#    [Arguments]    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/CB009169_BC/ttitrace_nfd.ini    output_ul.csv    ${csv_file_path}
