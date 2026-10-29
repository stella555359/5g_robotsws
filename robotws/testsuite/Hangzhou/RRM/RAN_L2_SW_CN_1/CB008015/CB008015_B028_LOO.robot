*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready With DSS
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Resource          ./../CUDU_L2/common_CA_DSS.robot
#Resource          ./resources/CB008015_lib.robot
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G    RAN_5G_TDD    Owner_qiaren
#...               CN1_SQ6    CB008015    SBTS00    SBTS23R1    SBTS22R4
#
#*** Variables ***
#${SCF_PATH}                ${CURDIR}/config/
#${FULL_SCFC}               8015_full_scfc_dss_LOO.xml
#${DELTA_SCFC}              CB008015_B028.json
#${IPHY_XML}                ${CURDIR}/config/wts/iphy_4F_2T_AP_LOO_DSS.xml
#${LOCAL_WTS_DIR}           ${CURDIR}/config/wts
#${WTS_DIR}                 /opt/wts/latest/
#${WTS_CFG}                  basic_8015_DSS_LOO.cfg
#${WTS_AP_XML}               airphone.xml
#${SA_UE}                   1,6
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#${ENBID}                        2
#${GNBID}                        1
#${CELL1_ID}                     1
#${ANTP_NUM}                     2
#${MBSFN_SUBFRAME}               110000110000110000110000
#${NORMAL_SUBFRAME_P3_MODE}     0011101000-0111101110-0011101000-0111101110-0011101000-0111101110-0011101000-0111101110
#${UL_PRB_LST}                  1,3|5,35|49,3
#*** Test Cases ***
#CB008015_B_028_Blind_CA_10MHz_DSS_Prbblanklow_SA
#    Online Change MaxNumOfSCellAlloc For Cell6
#    Four SA CA UE Attach And Scell Check
#    Start DL UL Traffic For Ues
#    Wait Until Keyword Succeeds    1min    5s    Check Pcell And Scell Throughput For 4UE
#    Wait Until Keyword Succeeds    1min    5s    Check SA UE Throughput For 4UE
#    Run Keyword And Ignore Error     Start And Stop Tti Trace
#
#*** Keywords ***
#Suite Setup Make TL Ready With DSS
#    Suite Setup Update GNB     scf_file=${FULL_SCFC}       iphy_file=${IPHY_XML}
#    #Suite Setup Update GNB
#    Delta Commission With SCF File     ${DELTA_SCFC}
#    Verify Coam Site Is Ready
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And and load cfg file
#    Config DSS Resource    30    100    20    70
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#Start DL UL Traffic For Ues
#    Start SA DL Big Traffic Internal    ue_id=5    mbps=300
#    SA Start UL Traffic Internal    ue_id=5    pdu_id=1    mbps=50    trf_id=1
#    Start SA DL Big Traffic Internal    ue_id=11    mbps=300
#    SA Start UL Traffic Internal    ue_id=11    pdu_id=1    mbps=50    trf_id=1
#    @{sa_ue_list}    Split String    ${SA_UE}    ,
#    Start Multi SA UE Traffic       @{sa_ue_list}     trf_type=dl    mbps=150
#    SA Start UL Traffic Internal    ue_id=${SA_UE}    pdu_id=1    mbps=50    trf_id=1
#
#Start And Stop Tti Trace
#    Start GNB TTI Trace
#    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
#    Stop And Decode GNB TTI Trace    ${TEST_LOG_DIRECTORY}
#
#Online Change MaxNumOfSCellAlloc For Cell6
#    Log To Console    Online change maxNumOfSCellAlloc for cell6...
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-6    maxNumOfSCellAlloc    1
#
#Four SA CA UE Attach And Scell Check
#    [Documentation]    This keyword is to attach 4 CA UE:
#    ...    Fdd cell1:20MHz DSS, Tdd cell3:60MHz, Tdd cell6 60MHz
#    ...    UE1 Fdd cell1+Tdd cell3
#    ...    UE5 Tdd cell3+Tdd cell6
#    ...    UE6 Tdd cell3+Fdd cell1
#    ...    UE11 Tdd cell6+Tdd cell3
#    SA Attach   sa_ue_id=5
#    Wait Until Keyword Succeeds    5s    1s    Check SA Scell PhysicalID With UE ID     ue_id=5     scell_physicalid=55    scell_index=1
#    SA Attach   sa_ue_id=11
#    Wait Until Keyword Succeeds    5s    1s     Check SA Scell PhysicalID With UE ID     ue_id=11     scell_physicalid=52    scell_index=1
#    SA Attach   sa_ue_id=1
#    Wait Until Keyword Succeeds    5s    1s    Check SA Scell PhysicalID With UE ID     ue_id=1     scell_physicalid=52    scell_index=1
#    SA Attach   sa_ue_id=6
#    Wait Until Keyword Succeeds    5s    1s    Check SA Scell PhysicalID With UE ID     ue_id=6     scell_physicalid=50     scell_index=1
#
#Check Pcell And Scell Throughput For 4UE
#    Check UE Pcell Scell TP On Target    ue_id=5    dir=dl    cell_type=pcell    scell_index=0    target_tp=70
#    Check UE Pcell Scell TP On Target    ue_id=5    dir=dl    cell_type=scell    scell_index=1    target_tp=160
#    Check UE Pcell Scell TP On Target    ue_id=11    dir=dl    cell_type=pcell    scell_index=0    target_tp=160
#    Check UE Pcell Scell TP On Target    ue_id=11    dir=dl    cell_type=scell    scell_index=1    target_tp=70
#    Check UE Pcell Scell TP On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=3
#    Check UE Pcell Scell TP On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=1    target_tp=70
#    Check UE Pcell Scell TP On Target    ue_id=6    dir=dl    cell_type=pcell    scell_index=0    target_tp=70
#    Check UE Pcell Scell TP On Target    ue_id=6   dir=dl    cell_type=scell    scell_index=1    target_tp=6
#    Check Fdd Cell TP    target_tp=17
#
#Check SA UE Throughput For 4UE
#    SA UE Check Throughput    5    130    10
#    SA UE Check Throughput    11    130    40
#    SA UE Check Throughput    1    40    10
#    SA UE Check Throughput    6    40    10
#
#Check Fdd Cell TP
#    [Arguments]    ${target_tp}
#    ${as_pcelltp}    Get CA Cell Average Throughput    ue_id=1    dir=dl    cell_type=pcell    scell_index=0
#    ${as_scelltp}    Get CA Cell Average Throughput    ue_id=6    dir=dl    cell_type=scell    scell_index=1
#    ${cell_tp}    Evaluate    ${as_pcelltp}+${as_scelltp}
#    ${tp_delta}    Evaluate    ${cell_tp}-${target_tp}
#    Should Be True    ${tp_delta}>=0    fdd cell Throughtput is not in the accetable range
#    Log To Console    The FDD cell tput is on target: ${target_tp}Mb \n
#
#Config DSS Resource
#   [Arguments]    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#    Setup X2 Connection    ${ENBID}    ${GNBID}
#    Setup XP LINK    ${ENBID}    ${GNBID}
#    Enable DSS DMS3 Feature On    ${ENBID}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL1_ID}    ${ANTP_NUM}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL1_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL1_ID}
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL1_ID}    DL
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL1_ID}
#    Cell Allocation    ${NORMAL_SUBFRAME_P3_MODE}    ${UL_PRB_LST}    ${ENBID}    ${GNBID}    ${CELL1_ID}
#    UE SIB Decoding Should Be Successful
