*** Settings ***
Documentation    ...
#Resource    ./keywords_CB008532_common_AP.robot
#Resource    ../CUDU_L2/common_setup_teardown.robot
#Resource    ../CUDU_L2/common_CA.robot
#Suite Setup    Common Suite Setup
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1     CN1_SQ
#...               RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${SCF_60_60_20_20_20_F}         SCF_60M_60M_20M_20M_20M_F.xml
#${IPHY_60_60_20_20_20_F}        iphy_1T3F_60M_60M_20M_20M_20M.xml
#${WTS_CFG_60_60_20_20_20_F}     wts_cfg_ASIB_ABIO_60M_60M_20M_20M_20M_F.cfg
#${SCF_60_60_20_20_20_F17}         SCF_60M_60M_20M_20M_20M_F17.xml
#${WTS_CFG_60_60_20_20_20_F17}     wts_cfg_ASIB_ABIO_60M_60M_20M_20M_20M_F17.cfg
#${SCF_60_60_20_20_20_F8}        SCF_60M_60M_20M_20M_20M_F8.xml
#${WTS_CFG_60_60_20_20_20_F8}        wts_cfg_ASIB_ABIO_60M_60M_20M_20M_20M_F8.cfg
#${IPHY_60_60_20_20_20_F8}        iphy_60M_60M_20M_20M_20M_F8.xml
#${gNB_swconfig}               swconfig_gnb.txt
#${Egatelog_path}    ${CURDIR}
#${SCF_20_20_20_10_5_D27}         SCF_2T3F_20M_20M_20M_10M_5M_D27.xml
#${IPHY_20_20_20_10_5_D27}          iphy_2T3F_20M_20M_20M_10M_5M_D27.xml
#${WTS_CFG_20_20_20_10_5_D27}     wts_cfg_ASIB_ABIO_20M_20M_20M_10M_5M_D27.cfg
#${Scell_Active_Message}    SCellIndex 3 activated successfully
#${Scell_Deac_Message}    SCellIndex 3 deactivated successfully
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#
#CB008532_ET_F17_UE_capability_4_CSIRS_T_T_to_T_3F
#    [Tags]      Owner_Susie    case_F017
#    [Setup]    Setup TL For Each Case    ${SCF_60_60_20_20_20_F17}    ${IPHY_60_60_20_20_20_F}    ${WTS_CFG_60_60_20_20_20_F17}   ${gNB_swconfig}
#    Attach SA UE1 Do A1 To 4CC Only With UL    TCF17    5    0
#    Trigger A1 Event    1    20
#    Capture TTItrace And BIP Logs Of BO    TCF17    2
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/TCF17/ttitrace/2    2
#    Check No ACSI On PCell   TCF17    ${OUTPUT_DIR}/TCF17/ttitrace/2
#    Check Num Of CSIRS    7    2
#    Trigger A1 Event    3    56
#    Capture TTItrace And BIP Logs Of BO    TCF17    3
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/TCF17/ttitrace/3    3
#    Check No ACSI On PCell   TCF17    ${OUTPUT_DIR}/TCF17/ttitrace/3
#    Check Num Of CSIRS    8    2
#
#CB008532_ET_F19_Buffer_Based_ScellsActivation_Deactivation_10_times
#    [Tags]     Owner_xinwang    case_F019
#    [Setup]    Setup TL For Each Case    ${SCF_20_20_20_10_5_D27}    ${IPHY_20_20_20_10_5_D27}    ${WTS_CFG_20_20_20_10_5_D27}    ${gNB_swconfig}
#    Clear PM Counter Reports
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
#
#    FOR   ${index}   IN RANGE   10
#        Lock Cell  cell_name=MRBTS-1/NRBTS-1/NRCELL-3
#        Sleep    30s    reason=wait for cell lock
#        Unlock Cell  cell_name=MRBTS-1/NRBTS-1/NRCELL-3
#        Sleep    30s    reason=wait for cell unlock
#        SA 5G Attach    ue_id=1
#        SA 5G PDU Session Setup    ue_id=1
#        Trigger A1 Event    meas_id=1   srsrp=100
#        Start UDP DL Traffic By Iperf    dlmbps=350    duration=10
#        Sleep    10s
#        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=100
#        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=1    target_tp=60
#        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=2    target_tp=20
#        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=3    target_tp=10
#        Stop DL UL Traffic Of Iperf
#    END
#    Wait Until Keyword Succeeds    2min    10s    Check Egate Log With Message    /opt/iphy/latest/egate_console.log    ${Scell_Active_Message}    10
#    Wait Until Keyword Succeeds    2min    10s    Check Egate Log With Message    /opt/iphy/latest/egate_console.log    ${Scell_Deac_Message}    10
#    Wait Until Keyword Succeeds    20min    3min    Check PM Counter For CA
#
##CB008532_ET_F01_UE_capability_14_CSIRS_2T_2F_to_2T_F
##    [Tags]      Owner_Susie    case_F01
##    [Setup]    Setup TL For Each Case    ${SCF_60_60_20_20_20_F}    ${IPHY_60_60_20_20_20_F}    ${WTS_CFG_60_60_20_20_20_F}    ${gNB_swconfig}
##    Attach SA UE1 Do A1 To 4CC Only With UL    TCF01    5    0
##    Trigger A1 For 2T2F
##    Capture TTItrace And BIP Logs Of BO    TCF01    2
##    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/TCF01/ttitrace/2    2
##    Check ACSI On PCell    TCF01    ${OUTPUT_DIR}/TCF01/ttitrace/2
##    Check Num Of CSIRS    5    4
##    A2 trigger Scell Release    3    2
##    Capture TTItrace And BIP Logs Of BO    TCF01    3
##    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/TCF01/ttitrace/3    3
##    Check ACSI On PCell    TCF01    ${OUTPUT_DIR}/TCF01/ttitrace/3
##    Check Num Of CSIRS    5    4
#
##CB008532_ET_F08_UE_capability_8_CSIRS_T_3F_to_T_2F
##    [Tags]      Owner_Susie    case_F08
##    [Setup]    Setup TL For Each Case    ${SCF_60_60_20_20_20_F8}    ${IPHY_60_60_20_20_20_F8}    ${WTS_CFG_60_60_20_20_20_F8}   ${gNB_swconfig}
##    Attach SA UE1 Do A1 To 4CC Only With UL    TCF08    5    0
##    Trigger A1 Event    1    100
##    Capture TTItrace And BIP Logs Of BO    TCF08    2
##    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/TCF08/ttitrace/2    2
##    Check No ACSI On PCell   TCF08    ${OUTPUT_DIR}/TCF08/ttitrace/2
##    Check Num Of CSIRS    5    0
##    A2 trigger Scell Release    2    1    115
##    Capture TTItrace And BIP Logs Of BO    TCF08    3
##    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/TCF08/ttitrace/3    3
##    Check No ACSI On PCell   TCF08    ${OUTPUT_DIR}/TCF08/ttitrace/3
##    Check Num Of CSIRS    5    0
#
#
#*** Keywords ***
#
#Lock Cell
#    [Arguments]    ${cell_name}
#    Setup Admin
#    Block Cell    dist_name=${cell_name}
#    Sleep    30s    reason=wait for cell lock
#    Teardown Admin
#
#Unlock Cell
#    [Arguments]    ${cell_name}
#    Setup Admin
#    UnBlock Cell    dist_name=${cell_name}
#    Sleep    30s    reason=wait for cell unlock
#    Teardown Admin
#
