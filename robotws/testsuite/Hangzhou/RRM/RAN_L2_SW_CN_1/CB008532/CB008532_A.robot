*** Settings ***
Documentation    ...
#Resource    ./keywords_CB008532_common_AP.robot
#Resource    ../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    CN1_SQ
#...               RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#
#${SCF_80_80_5_5_5}            SCF_2T3F_80M_80M_5M_5M_5M.xml
#${IPHY_80_80_5_5_5}           iphy_2T3F_80M_80M_5M_5M_5M.xml
#${WTS_CFG_80_80_5_5_5}        wts_cfg_ASIB_ABIO_80M_80M_5M_5M_5M.cfg
#${SCF_100_60_10_10_10}        SCF_2T3F_100M_60M_10M_10M_10M.xml
#${SCF_100_60_20_20_20}        SCF_2T3F_100M_60M_20M_20M_20M.xml
#${IPHY_100_60_10_10_10}       iphy_2T3F_100M_60M_10M_10M_10M.xml
#${WTS_CFG_100_60_10_10_10}    wts_cfg_ASIB_ABIO_100M_60M_10M_10M_10M.cfg
#${SCF_60_60_20_20_20}         SCF_2T3F_60M_60M_20M_20M_20M.xml
#${IPHY_60_60_20_20_20}        iphy_2T3F_60M_60M_20M_20M_20M.xml
#${WTS_CFG_60_60_20_20_20}     wts_cfg_ASIB_ABIO_60M_60M_20M_20M_20M.cfg
#${SCF_80_60_10_10_15}         SCF_2T3F_80M_60M_10M_10M_15M.xml
#${IPHY_80_60_10_10_15}        iphy_2T3F_80M_60M_10M_10M_15M.xml
#${WTS_CFG_80_60_10_10_15}     wts_cfg_ASIB_ABIO_80M_60M_10M_10M_15M.cfg
#${Egatelog_path}    ${CURDIR}
#${gNB_swconfig}               swconfig_gnb.txt
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#
#CB008532_ET_A17_UE_DL_ULdata_scheduling_2T_2F_ABIO_beamforming_enabled
#    [Tags]     Owner_Susie    case_A17
#    [Setup]    Setup TL For Each Case    ${SCF_60_60_20_20_20}    ${IPHY_60_60_20_20_20}    ${WTS_CFG_60_60_20_20_20}   ${gNB_swconfig}
#    [Timeout]    90min
#    Attach SA UE1 4CC    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#    Capture TTItrace And BIP Logs Of BO    TCA17
#    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/TCA17/ttitrace/1    1
#    Check PCSI Periodicity On Each Cell    A17    ${OUTPUT_DIR}/TCA17/ttitrace/1
#    Check BeamReport Periodicity On TDD Cell    A17    ${OUTPUT_DIR}/TCA17/ttitrace/1
#    Check MaxPayloadSize After Scelladdition
#    SA 5G Detach    ue_id=all
#
#
##CB008532_ET_A12_4CC_CA_2T_2F_ABIO_feature_deactivation
##    [Tags]     Owner_Yulei    case_A12
##    [Setup]    Setup TL For Each Case    ${SCF_100_60_10_10_10}    ${IPHY_100_60_10_10_10}    ${WTS_CFG_100_60_10_10_10}    ${gNB_swconfig}
##    #Start UTE WTS And Check Cell Setup    ${WTS_CFG}
##    Attach SA UE1 4CC    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    Online Delete NRREL
##    Save Egate Log    ${Egatelog_path}
##    Check UE1 Release
##    Attach SA UE2 3CC    UE_ID=2    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    ${Scell_list}=    Get CA SCell Number    2
##    Check UE2 Only 2Scell Addition    ${Scell_list}
##    SA 5G Detach    ue_id=all
##
##CB008532_ET_A09_4CC_CA_2T_2F_ABIL_feature_activation
##    [Tags]     Owner_Susie    case_A09
##    [Setup]    Setup TL For Each Case    ${SCF_80_80_5_5_5}    ${IPHY_80_80_5_5_5}    ${WTS_CFG_80_80_5_5_5}    ${gNB_swconfig}
##    [Timeout]    40min
##    SA 5G Attach    ue_id=1
##    SA 5G PDU Session Setup    ue_id=1
##    ${scell_act_nums}=    Create List   1    1    0
##    Check Scell Activition Info    4    ${scell_act_nums}
##    CB008532 Feature Activation
##    Sleep    60s
##    SA 5G Attach    ue_id=2
##    SA 5G PDU Session Setup    ue_id=2
##    ${scell_act_nums_2}=    Create List    2    2    1
##    Check Scell Activition Info    4    ${scell_act_nums_2}
##    SA 5G Detach    ue_id=all
##
##CB008532_ET_A11_4CC_CA_2T_2F_ABIL_feature_deactivation
##    [Tags]     Owner_Yulei    case_A11
##    [Setup]    Setup TL For Each Case    ${SCF_100_60_10_10_10}    ${IPHY_100_60_10_10_10}    ${WTS_CFG_100_60_10_10_10}    ${gNB_swconfig}
##    #Start UTE WTS And Check Cell Setup    ${WTS_CFG}
##    Attach SA UE1 4CC    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    CB008532 Feature Deactivation
##    ${Scell_list}=    Get CA SCell Number    1
##    Check UE1 No SCell release immediately    ${Scell_list}
##    Attach SA UE2 3CC    UE_ID=2    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    ${Scell_list}=    Get CA SCell Number    2
##    Check UE2 Only 2Scell Addition    ${Scell_list}
##    SA 5G Detach    ue_id=all
##
##CB008532_ET_A22_UE_DL_ULdata_scheduling_1T_3F_ABIO_beamforming_disabled
##    [Tags]     Owner_Yulei    case_A22
##    [Setup]    Setup TL For Each Case    ${SCF_100_60_20_20_20}    ${IPHY_100_60_10_10_10}    ${WTS_CFG_100_60_10_10_10}   ${gNB_swconfig}
##    #Start UTE WTS And Check Cell Setup    ${WTS_CFG}
##    Attach SA UE1 4CC    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    ${Scell_list}=    Get CA SCell Number    1
##    Check UE1 SCell Addition 4CC   ${Scell_list}
##    Capture TTItrace And BIP Logs Of BO    TCA22
##    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/TCA22/ttitrace/1    1
##    Check PCSI Periodicity On Each Cell    A22    ${OUTPUT_DIR}/TCA22/ttitrace/1
##    SA 5G Detach    ue_id=all
##
##CB008532_ET_A33_SCellSelection_Admissioncontrolcheck_4CCbandcombinationselection(BC1sselected)_2T_2F
##    [Tags]     Owner_Susie    case_A33
##    [Setup]    Setup TL For Each Case    ${SCF_80_60_10_10_15}    ${IPHY_80_60_10_10_15}    ${WTS_CFG_80_60_10_10_15}   ${gNB_swconfig}
##    [Timeout]    90min
##    Clear PM Counter Reports
##    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
##    Attach SA UE1 4CC    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
##    Capture TTItrace And BIP Logs Of BO    TCA33
##    Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/TCA33/ttitrace/1    1
##    Check PCSI Periodicity On Each Cell    A33    ${OUTPUT_DIR}/TCA33/ttitrace/1
##    Check BeamReport Periodicity On TDD Cell    A33    ${OUTPUT_DIR}/TCA33/ttitrace/1
##    Wait Until Keyword Succeeds    20min    5min    Check PM Counter For CA
##    SA 5G Detach    ue_id=all
#
#
#*** Keywords ***
#
#
#
#
#
