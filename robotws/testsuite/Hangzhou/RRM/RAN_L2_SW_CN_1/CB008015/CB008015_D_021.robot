*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Run Keywords    Detach All UE
#...               AND    Common Test Teardown
##Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD    Owner_molyang
##...               CN1_SQ6    CB008015    SBTS00    SBTS23R1    SBTS22R4    SBTS22R3
#Resource          ../5GC001167/5GC001167_Resource.robot
#Resource          resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/config
#${SCF_FILE}                 Configuration_scf_CB008015_D_021.xml
#${IPHY_FILE}                ${CURDIR}/config/wts/iphy_2T_F_D_021.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/config/wts
#${WTS_CFG}                  basic_l1by_sa_call_fdd_cmwv_2T_F_D_021.cfg
#${LOCKED_CELL}              MRBTS-1/NRBTS-1/NRCELL-1
#${EXPECT_TPUT_DL_ALL}       580
#${EXPECT_TPUT_DL_CELL}      190
#${SCELL_NUMS}               1
#${UE_ID1}                   81    #cell1+2(T+T A1)
#${UE_ID2}                   82    #cell2+1(T+T Blind)
#${UE_ID3}                   83    #cell3+1(F+T Blind)
#@{UE_ID_LIST}               81    82    83
#@{CELL_ID_LIST}             1    2    3
#${BEARER_ID}                2
#@{PCI_LIST}                 50    52    51
#${GNB_ID}                   2
#${CELL_LOCK_MESSAGE_NSA}    Bearer-type change from SCG-split to MCG is successful
#${CELL_ON_AIR_MESSAGE}      eNB 2 cell 1: SystemInformationBlockType1-NR
#@{BAND_LIST}                41    78    66
#
#*** Test Cases ***
#CB008015_D_021_NSA_T_T_Lock_TDD_Cell_Configured_A1_Scell_Addition_Method_Ungracefully
#    Three UE Attach And Check Scell Addition
#    Start Three UE Traffic
#    Verify Three UE 2CC Tput
#    Lock Cell    ${LOCKED_CELL}
#    Wait Until Keyword Succeeds    2min    10s    Check Egate Log With Message    ${egate_path}    ${CELL_LOCK_MESSAGE_NSA}    3
#    Unlock Cell    ${LOCKED_CELL}
#    Wait Until Keyword Succeeds    2min    10s    Check Egate Log With Message    ${egate_path}    ${CELL_ON_AIR_MESSAGE}    2
#    Log To Console    check ue reattach
#    :FOR    ${ue_id}    ${cell_id}    IN ZIP    ${UE_ID_LIST}    ${CELL_ID_LIST}
#    \    NSA 5G Attach    ${ue_id}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}
#    Trigger A1 Scell Addition    ${UE_ID1}    90    @{PCI_LIST}[0]
#    Start Three UE Traffic
#    Verify Three UE 2CC Tput
#
#*** Keywords ***
#Verify Three UE 2CC Tput
#    Log To Console    check ue${UE_ID1} pcell scell Tput
#    Check UE Pcell Scell TP On Target    ${UE_ID1}    dl    pcell    8    105
#    Check UE Pcell Scell TP On Target    ${UE_ID1}    dl    scell    9    165
#    Log To Console    check ue${UE_ID2} pcell scell Tput
#    Check UE Pcell Scell TP On Target    ${UE_ID2}    dl    pcell    8    165
#    Check UE Pcell Scell TP On Target    ${UE_ID2}    dl    scell    9    105
#    Log To Console    check ue${UE_ID3} pcell scell Tput
#    Check UE Pcell Scell TP On Target    ${UE_ID3}    dl    pcell    8    70
#    Check UE Pcell Scell TP On Target    ${UE_ID3}    dl    scell    9    105
#    :FOR    ${ue_id}    IN    @{UE_ID_LIST}
#    \    Log To Console    check ue${ue_id} UL Tput
#    \    NSA Check Average Traffic Bigger Than Target    ${ue_id}    ${BEARER_ID}    ul    1
#
#Start Three UE Traffic
#    Log To Console    start DL and UL Traffic
#    :FOR    ${trf_id}    IN RANGE    1    5
#    \    NSA Start DL Traffic    ${UE_ID1}    ${BEARER_ID}    150    ${trf_id}
#    :FOR    ${trf_id}    IN RANGE    1    5
#    \    NSA Start DL Traffic    ${UE_ID2}    ${BEARER_ID}    150    ${trf_id}
#    :FOR    ${trf_id}    IN RANGE    1    5
#    \    NSA Start DL Traffic    ${UE_ID3}    ${BEARER_ID}    150    ${trf_id}
#    :FOR    ${ue_id}    IN    @{UE_ID_LIST}
#    \    NSA Start UL Traffic    ${ue_id}    ${BEARER_ID}    10
#    Sleep    20s    reason=Wait For Data Transmission
#
#Three UE Attach And Check Scell Addition
#    NSA UE Attach    ${UE_ID1}    ${GNB_ID}    @{CELL_ID_LIST}[0]    ${BEARER_ID}
#    Trigger A1 Scell Addition    ${UE_ID1}    90    @{PCI_LIST}[0]
#    Check SA Scell PhysicalID With UE ID    ${UE_ID1}    @{PCI_LIST}[1]    9
#    NSA UE Attach    ${UE_ID2}    ${GNB_ID}    @{CELL_ID_LIST}[1]    ${BEARER_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID2}    @{PCI_LIST}[0]    9
#    NSA UE Attach    ${UE_ID3}    ${GNB_ID}    @{CELL_ID_LIST}[2]    ${BEARER_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID3}    @{PCI_LIST}[0]    9
#
#NSA UE Attach
#    [Arguments]    ${ue_id}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}
#    NSA LTE Attach    ${ue_id}
#    NSA 5G Attach    ${ue_id}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}
#
#Detach All UE
#    :FOR    ${ue_id}    IN    @{UE_ID_LIST}
#    \    NSA LTE Detach    ${ue_id}
#
