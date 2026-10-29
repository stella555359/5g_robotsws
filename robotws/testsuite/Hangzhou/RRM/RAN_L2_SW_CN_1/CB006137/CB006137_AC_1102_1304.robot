*** Settings ***
Documentation    ...
##Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown
##Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CB006137      RAN_5G    RAN_5G_TDD
#...               Owner_peafu    CN1_SQ06    SBTS00    SBTS23R1
#Resource          ../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config/
#${FULL_SCFC_1304}            CB006137_AC_BO_1304_InterRAT_HO.xml
#${FULL_SCFC_1102}            CB006137_AC_BO_1102.xml
#${IPHY_XML_1304}             ${CURDIR}/config/WTS/iphy_2T_2F_for_1304.xml
#${IPHY_XML_1102}             ${CURDIR}/config/WTS/iphy_2T_2F_for_1102.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config/WTS
#${WTS_AP_XML}                airphone.xml
#${WTS_CFG_1304}              6137_AC_2T_2F_for_1304.cfg
#${WTS_CFG_1102}              6137_AC_2T_2F_for_1102.cfg
#${CA_UE_ID}                  3
#${SCELL_PCI_1st}             50
#${SCELL_PCI_2nd}             52
#${PCELL_PCI}                 51
#${SWCONFIG_PARAM}            0x58056B=1;0x580307=0x5FE;
#
#
#*** Test Cases ***
#CB006137_ET_AC1102_BO_Single_UE_Intra_Band_Intra_Freq_HO_From_F1_T1_To_F2_T2
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_1102}
#    ...        AND    Suite Setup Update GNB    scf_file=${FULL_SCFC_1102}    iphy_file=${IPHY_XML_1102}    swconfig_param=${SWCONFIG_PARAM}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    SA Attach    sa_ue_id=${CA_UE_ID}
#	Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL_PCI_1st}    scell_index=1
#    Start ULDL Traffic And Check The Tput    ${CA_UE_ID}    600    100    560    90
#    Check Pcell And Scell Tput Per UE    ${CA_UE_ID}    95    470    35    50
#    Trigger A3 Event And Check Handover Status
#	Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL_PCI_2nd}    scell_index=1
#    Start ULDL Traffic And Check The Tput    ${CA_UE_ID}    600    100    560    90
#    Check Pcell And Scell Tput Per UE    ${CA_UE_ID}    95    470    35    50
#
#
#CB006137_ET_AC1304_BO_Single_UE_Bi_Directional_Iner_RAT_HO_Between_2CC_ULCA_And_LTE
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_1304}
#    ...        AND    Suite Setup Update GNB    scf_file=${FULL_SCFC_1304}    iphy_file=${IPHY_XML_1304}    swconfig_param=${SWCONFIG_PARAM}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#	SA Attach    sa_ue_id=${CA_UE_ID}
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=${CA_UE_ID}    pcell_id=${PCELL_PCI}    rsrp=95    mea_id=3
#	Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL_PCI_1st}    scell_index=1
#    Start ULDL Traffic And Check The Tput    ${CA_UE_ID}    600    100    560    90
#    Check Pcell And Scell Tput Per UE    ${CA_UE_ID}    95    470    35    50
#    Trigger A2 Event For UE3
#    Trigger B2 Event For UE3 And Check Handover From 5G To LTE
#	Sleep    5s    reason=wait for last handover complete
#    Trigger Handover For UE3 From LTE To 5G
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=${CA_UE_ID}    pcell_id=${PCELL_PCI}    rsrp=95    mea_id=5
#	Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL_PCI_1st}    scell_index=1
#    Start ULDL Traffic And Check The Tput    ${CA_UE_ID}    600    100    560    90
#    Check Pcell And Scell Tput Per UE    ${CA_UE_ID}    95    470    35    50
#
#
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}    swconfig_param=0x58056B=1;0x580307=0x5FE;
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#
#Trigger A2 Event For UE3
#    Log To Console    Trigger A2 event...
#    ${pattern}    Set Variable    rrcReconfigurationComplete
#    ${cmd}    Catenate    ue_measurement_send_nr id\=3 meas_id\=1 event\=A2 srsrp_nr\=11
#    ...    phycell_id\=51
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#
#Trigger B2 Event For UE3 And Check Handover From 5G To LTE
#    Log To Console    Trigger B2 event...
#    ${pattern}    Set Variable    UE3: Successful handover from EXT_ENB-2.3 to ENB-1.1
#    ${cmd}    Catenate    ue_measurement_send_nr id\=3 meas_id\=6 event\=B2 srsrp_nr\=11
#    ...    srsrq_nr\=11 phycell_id\=11 nrsrp_nr\=30 nrsrq_nr\=30
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#
#Trigger Handover For UE3 From LTE To 5G
#    Log To Console    Trigger HO from LTE to 5G ...
#    ${pattern}    Set Variable    UE3: Inter-eNB handover from ENB-1.1 to EXT_ENB-2.3 performed
#    ${cmd}    Catenate    gnb_trigger_inter_rat_handover_to_5g ue\=3 target_gnb\=2 target_cell\=3
#    ...    plmn\=311:489
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#
#Trigger A3 Event And Check Handover Status
#    Log To Console    Trigger A3 event...
#    ${pattern}    Set Variable    UE3: Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.4 performed
#    ${cmd}    Catenate    ue_measurement_send_nr id\=3 meas_id\=1 event\=A3 srsrp_nr\=20
#    ...    phycell_id\=53 nrsrp_nr\=80
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
