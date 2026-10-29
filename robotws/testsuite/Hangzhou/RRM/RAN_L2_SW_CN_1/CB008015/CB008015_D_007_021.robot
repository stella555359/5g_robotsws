*** Settings ***
Documentation    ...
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G    RAN_5G_TDD    Owner_molyang
#...               CN1_SQ6    CB008015    SBTS00    SBTS23R1    SBTS22R4
#Resource          ../5GC001167/5GC001167_Resource.robot
#Resource          resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config
#${SCF_FILE_D_007}            Configuration_scf_CB008015_D_007.xml
#${SCF_FILE_D_021}            Configuration_scf_CB008015_D_021.xml
#${IPHY_FILE_D_007}           ${CURDIR}/config/wts/iphy_3F_D_007.xml
#${IPHY_FILE_D_021}           ${CURDIR}/config/wts/iphy_2T_F_D_021.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config/wts
#${WTS_CFG_D_007}             basic_l1by_sa_call_fdd_cmwv_3F_D_007.cfg
#${WTS_CFG_D_021}             basic_l1by_sa_call_fdd_cmwv_2T_F_D_021.cfg
#${LOCKED_CELL}               MRBTS-1/NRBTS-1/NRCELL-1
#${EXPECT_TPUT_DL_ALL_D7}     200
#${EXPECT_TPUT_DL_CELL_D7}    30
#${SCELL_NUMS_D7}             2
#${UE_ID1}                    1    #pcell1+scell2+scell3
#${UE_ID2}                    2    #pcell2+scell1+scell3
#${UE_ID81}                   81    #cell1+2(T+T A1)
#${UE_ID82}                   82    #cell2+1(T+T Blind)
#${UE_ID83}                   83    #cell3+1(F+T Blind)
#@{UE_ID_LIST}                81    82    83
#@{CELL_ID_LIST}              1    2    3
#${BEARER_ID}                 2
#@{PCI_LIST}                  50    52    51
#${GNB_ID}                    2
#${CELL_LOCK_MESSAGE_NSA}     Bearer-type change from SCG-split to MCG is successful
#${CELL_LOCK_MESSAGE_SA}      Received NG Reset from GNB-2
#${CELL_ON_AIR_MESSAGE}       eNB 2 cell 1: SystemInformationBlockType1-NR
#@{BAND_LIST}                 41    78    66
#
#*** Test Cases ***
#CB008015_D_007_SA_Lock_FDD_Cell_Configured_Blind_Scell_Addition_Method_Ungracefully
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_D_007}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_FILE_D_007}    iphy_file=${IPHY_FILE_D_007}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    CB008015_lib.Set Reordering Timer    ${reordering_window_size}    ${reordering_timer}
#    Two SA UE Register
#    Verify Scells Are Activation    ${SCELL_NUMS_D7}
#    Start Two UE DL And UL Traffic
#    Verify Two UE DL And UL Traffic
#    Lock Cell    ${LOCKED_CELL}
#    Wait Until Keyword Succeeds    2min    10s    Check Egate Log With Message    ${egate_path}    ${CELL_LOCK_MESSAGE_SA}    1
#    Unlock Cell    ${LOCKED_CELL}
#    Wait Until Keyword Succeeds    2min    10s    Check Egate Log With Message    ${egate_path}    ${CELL_ON_AIR_MESSAGE}    2
#    Log To Console    check ue reattach
#	Detach UE2
#    Two SA UE Register
#    Verify Scells Are Activation    ${SCELL_NUMS_D7}
#    Start Two UE DL And UL Traffic
#    Verify Two UE DL And UL Traffic
#    [Teardown]    Run Keywords    Detach All SA UE
#    ...           AND    Common Test Teardown
#
#CB008015_D_021_NSA_T_T_Lock_TDD_Cell_Configured_A1_Scell_Addition_Method_Ungracefully
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_D_021}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_FILE_D_021}    iphy_file=${IPHY_FILE_D_021}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
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
#    Trigger A1 Scell Addition    ${UE_ID81}    90    @{PCI_LIST}[0]
#    Start Three UE Traffic
#    Verify Three UE 2CC Tput
#    [Teardown]    Run Keywords    Detach All NSA UE
#    ...           AND    Common Test Teardown
#
#*** Keywords ***
#Two SA UE Register
#    FOR    ${ue_id}    IN    ${UE_ID1}    ${UE_ID2}
#    \    SA Attach    ${ue_id}
#
#Start Two UE DL And UL Traffic
#    Log To Console    start DL and UL Traffic
#    FOR    ${trf_id}    IN RANGE    1    5
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID1} pdu\=${pdu_id} dir=dl mbps\=170 trf_id\=${trf_id}
#    FOR    ${trf_id}    IN RANGE    1    5
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID2} pdu\=${pdu_id} dir=dl mbps\=170 trf_id\=${trf_id}
#    FOR    ${ue_id}    IN    ${UE_ID1}    ${UE_ID2}
#    \    SA Start UL Traffic EGate    ${ue_id}    ${pdu_id}    10
#    Sleep    20s    reason=Wait For Data Transmission
#
#Verify Two UE DL And UL Traffic
#    FOR    ${ue_id}    IN    ${UE_ID1}    ${UE_ID2}
#    \    Log To Console    Verify ue${ue_id} Traffic
#    \    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    dl    ${EXPECT_TPUT_DL_ALL_D7}
#    \    SA Check Average Traffic Bigger Than Target EGate    ${ue_id}    ${pdu_id}    ul    ${expected_tput_ul}
#    \    SA Check 3CC Traffic Bigger Than Target EGate    ${ue_id}    dl    ${EXPECT_TPUT_DL_CELL_D7}
#
#Detach All SA UE
#    SA 5G Detach    ${UE_ID1}
#    SA 5G Detach    ${UE_ID2}
#
#Verify Three UE 2CC Tput
#    Log To Console    check ue${UE_ID81} pcell scell Tput
#    Check UE Pcell Scell TP On Target    ${UE_ID81}    dl    pcell    8    105
#    Check UE Pcell Scell TP On Target    ${UE_ID81}    dl    scell    9    165
#    Log To Console    check ue${UE_ID82} pcell scell Tput
#    Check UE Pcell Scell TP On Target    ${UE_ID82}    dl    pcell    8    165
#    Check UE Pcell Scell TP On Target    ${UE_ID82}    dl    scell    9    105
#    Log To Console    check ue${UE_ID83} pcell scell Tput
#    Check UE Pcell Scell TP On Target    ${UE_ID83}    dl    pcell    8    70
#    Check UE Pcell Scell TP On Target    ${UE_ID83}    dl    scell    9    105
#    :FOR    ${ue_id}    IN    @{UE_ID_LIST}
#    \    Log To Console    check ue${ue_id} UL Tput
#    \    NSA Check Average Traffic Bigger Than Target    ${ue_id}    ${BEARER_ID}    ul    1
#
#Start Three UE Traffic
#    Log To Console    start DL and UL Traffic
#    :FOR    ${trf_id}    IN RANGE    1    5
#    \    NSA Start DL Traffic    ${UE_ID81}    ${BEARER_ID}    150    ${trf_id}
#    :FOR    ${trf_id}    IN RANGE    1    5
#    \    NSA Start DL Traffic    ${UE_ID82}    ${BEARER_ID}    150    ${trf_id}
#    :FOR    ${trf_id}    IN RANGE    1    5
#    \    NSA Start DL Traffic    ${UE_ID83}    ${BEARER_ID}    150    ${trf_id}
#    :FOR    ${ue_id}    IN    @{UE_ID_LIST}
#    \    NSA Start UL Traffic    ${ue_id}    ${BEARER_ID}    10
#    Sleep    20s    reason=Wait For Data Transmission
#
#Three UE Attach And Check Scell Addition
#    NSA UE Attach    ${UE_ID81}    ${GNB_ID}    @{CELL_ID_LIST}[0]    ${BEARER_ID}
#    Trigger A1 Scell Addition    ${UE_ID81}    90    @{PCI_LIST}[0]
#    Check SA Scell PhysicalID With UE ID    ${UE_ID81}    @{PCI_LIST}[1]    9
#    NSA UE Attach    ${UE_ID82}    ${GNB_ID}    @{CELL_ID_LIST}[1]    ${BEARER_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID82}    @{PCI_LIST}[0]    9
#    NSA UE Attach    ${UE_ID83}    ${GNB_ID}    @{CELL_ID_LIST}[2]    ${BEARER_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID83}    @{PCI_LIST}[0]    9
#
#NSA UE Attach
#    [Arguments]    ${ue_id}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}
#    NSA LTE Attach    ${ue_id}
#    NSA 5G Attach    ${ue_id}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}
#
#Detach All NSA UE
#    :FOR    ${ue_id}    IN    @{UE_ID_LIST}
#    \    NSA LTE Detach    ${ue_id}
#
#Detach UE2
#    Log To Console    Detach UE2
#	${cmd}    Set Variable    ue_deregister id=2 ue_deregister_type=switch_off
#	${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=UE2: detached    timeout=1min
