*** Settings ***
Documentation    ...
#Test Teardown      Common Test Teardown
#Suite Teardown     Common Suite Teardown
#Force Tags         CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G
#...                SBTS00    CN1_SG06_SM1    CB008950    owner_suxu
#
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/Config/
#${SCFC_FILE}                8950_2F_6T_SCF_C102.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts
#${WTS_DIR}                  /opt/iphy/latest
#${IPHY_2F_4T}               ${CURDIR}/Config/wts/iphy_2F_6T.xml
#${WTS_CFG}                  CB008950_2F_6T_C102.cfg
#${UE12_ID}                  12
#${UE13_ID}                  13
#${UE14_ID}                  14
#@{2CA_UE_LIST}              1    2
#@{2CC_DLTPUT_LIST}          80    80
#${2CC_SCELL_PCI_CELL2}      51
#${2CC_SCELL_PCI_CELL11}     60
#${2CC_SCELL_PCI_CELL12}     61
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB008950_ET_C102_SCell_Selection_A1BasedSCellAddition_UniqueSCellPriority_SCellRacFailure_NSA
#    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_2F_4T}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#    ...        AND    Common Test Setup
#    NSA F+T CA UE Attach     ueId=12    cellId=1
#    Trigger A1 Scell Addition    ${UE12_ID}    110    50
#    Check SA Scell PhysicalID With UE ID    ${UE12_ID}    ${2CC_SCELL_PCI_CELL12}    9
#    NSA F+T CA UE Attach     ueId=13    cellId=1
#    Trigger A1 Scell Addition    ${UE13_ID}    110    50
#    Check SA Scell PhysicalID With UE ID    ${UE13_ID}    ${2CC_SCELL_PCI_CELL12}    9
#    NSA F+T CA UE Attach     ueId=14    cellId=1
#    Trigger A1 Scell Addition    ${UE14_ID}    110    50
#    Check SA Scell PhysicalID With UE ID    ${UE14_ID}    ${2CC_SCELL_PCI_CELL11}    9
#    NSA Start Traffic And Check Tput
#    Capture Logs And Check TTitrace    log_idx=1
#
#
#*** Keywords ***
#Capture Logs And Check TTitrace
#    [Arguments]    ${log_idx}
#    #Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/${log_idx}
#    CUDU_L2 Capture And Decode TTitrace    log_id=${log_idx}    duration=1
#    CUDU_L2 Check DTXNACK Rate    log_id=${log_idx}
#    CUDU_L2 Check UL DTXCRC Rate    log_id=${log_idx}
#
#NSA F+T CA UE Attach
#    [Arguments]    ${ueId}    ${gnbId}=2   ${cellId}=1    ${bearID}=2
#    [Documentation]    NRREL.sCellPrio is set to unique value for all SCells(lowest value for SCell 12/15 NRREL.sCellPrio);
#    ...    F1 SCell 11/SCell 12/SCell 13 channel bandwidths equal to F2 SCell 14/SCell 15/SCell 16 channel bandwidths;
#    ...    NRBTS/NRCELL.weightForSCellSelection values for F1 SCell 11/SCell 12/SCell 13 are greater than for F2 SCell 14/SCell 15/SCell 16;
#    ...    NRBTS/NRCELL.maxNumOfSCellAlloc=2 for F1 SCell 12.
#    ...    Fdd cell 11/12/13:20MHz, Fdd cell 14/15/16:20MHz, Tdd cell 1:60MHz, Tdd cell 2: 60MHz
#    ...    UE1 Fdd cell 1+Fdd cell 12
#    ...    UE2 Fdd cell 1+Fdd cell 12
#    ...    UE3 Fdd cell 1+Fdd cell 11 due to maxNumOfSCellAlloc=2 for cell 12
#    NSA LTE Attach  ue_id=${ueid}
#    NSA 5G Attach   ue_id=${ueId}   gnb_id=${gnbId}   cell_id=${cellId}  bearer_id=${bearID}
#    Log To Console    UE${ueId} NSA rach successfully.
#
#NSA Start Traffic And Check Tput
#    NSA Start Traffic For UE    ueId=12    dlTput=330
#    NSA Start Traffic For UE    ueId=13    dlTput=330
#    NSA Start Traffic For UE    ueId=14    dlTput=450
#    Sleep    20s    reason=Wait For Data Transmission
#    Wait Until Keyword Succeeds    30s    6s    NSA Check TP For CA UE    ueId=12
#    Wait Until Keyword Succeeds    30s    6s    NSA Check TP For CA UE    ueId=13
#    Wait Until Keyword Succeeds    30s    6s    NSA Check TP For CA UE    ueId=14
#
#NSA Start Traffic For UE
#    [Arguments]    ${ueId}    ${dlTput}
#    NSA Start DL Big Traffic Internal    ue_id=${ueId}    bearer_id=2    mbps=${dlTput}
#    NSA Start UL Traffic    ue_id=${ueId}     bearer_id=2     mbps=45
#
#NSA Check TP For CA UE
#    [Arguments]    ${ueId}
#    #NSA Check Average Traffic Bigger Than Target    ${ueId}    2   dl    270
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ueId}    dir=dl    cell_type=pcell    scell_index=8    target_tp=40
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=9    target_tp=190
#    Check CA UE Pcell Scell Cell TPut On Target    ue_id=${ueId}    dir=ul    cell_type=pcell    scell_index=8    target_tp=30
