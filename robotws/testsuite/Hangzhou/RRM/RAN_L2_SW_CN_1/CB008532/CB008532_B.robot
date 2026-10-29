*** Settings ***
Resource    ./keywords_CB008532_common_AP.robot
Resource    ../CUDU_L2/common_setup_teardown.robot
Suite Setup    Common Suite Setup
Test Teardown    Common Test Teardown 2
Suite Teardown    Common Suite Teardown 2
Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    SBTS23R1     CN1_SQ
...               RAN_5G    RAN_5G_TDD    CRT

*** Variables ***
${SCF_60_60_20_20_20_B}         SCF_1T3F_60M_60M_20M_20M_20M.xml
${IPHY_60_60_20_20_20_B}        iphy_1T3F_60M_60M_20M_20M_20M.xml
${WTS_CFG_60_60_20_20_20_B}     wts_cfg_ASIB_ABIO_60M_60M_20M_20M_20M_B02.cfg

${SCF_60_60_20_20_20_B03}         SCF_2T3F_60M_60M_20M_20M_20M_B.xml
${IPHY_60_60_20_20_20_B03}        iphy_2T3F_60M_60M_20M_20M_20M_B.xml
${WTS_CFG_60_60_20_20_20_B03}     wts_cfg_ASIB_ABIO_60M_60M_20M_20M_20M_B.cfg

${gNB_swconfig}                   swconfig_gnb.txt
${Egatelog_path}    ${CURDIR}

*** Test Cases ***
#CB008532_ET_B02_RRCConnectionRe-establishment_blind_SCell_addition(ABIO)(1T+3F)
#    [Tags]     Owner_Susie    case_B02
#    [Setup]    Setup 1T3F TL For Each Case    ${SCF_60_60_20_20_20_B}    ${IPHY_60_60_20_20_20_B}    ${WTS_CFG_60_60_20_20_20_B}    ${gNB_swconfig}
#    [Timeout]    90min
#    Clear PM Counter Reports
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
#    SA 5G Attach    ue_id=1
#    SA 5G PDU Session Setup    ue_id=1
#    Wait Until Keyword Succeeds    20min    3min    Check PM Counter For CA
#    UE RRC Reestablish To One Cell
#    Sleep    360s    reason=Wait for Process Handling
#    Clear PM Counter Reports
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/NonCA
#    Check PM Counter For NonCA

#CB008532_ET_B03_RRCConnectionRe-establishment_A1_based_SCelladdition(ABIL)(2T+2F)
#    [Tags]     Owner_Yulei    case_B03
#    [Setup]    Setup TL For Each Case    ${SCF_60_60_20_20_20_B03}    ${IPHY_60_60_20_20_20_B03}    ${WTS_CFG_60_60_20_20_20_B03}   ${gNB_swconfig}
#    #Start UTE WTS And Check Cell Setup    ${WTS_CFG}
#    Attach SA UE1 Do A1 To 4CC    UE_ID=1    dl_tp_set=175    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=20
#    Save Egate Log    log_path=${Egatelog_path}
#    ${Scellindex_list}    Get Scellindex
#    Check 4CC Cell Contain TDD    ${Scellindex_list}
#    Trigger Reestablish To FDD
#    Save Egate Log    log_path=${Egatelog_path}
#    ${measIdA1}=    Get MeasID A1 After Reestablish
#    Trigger F+T+T A1 Scell Addition    UE_ID=1    meas_id=${measIdA1}

*** Keywords ***



    

