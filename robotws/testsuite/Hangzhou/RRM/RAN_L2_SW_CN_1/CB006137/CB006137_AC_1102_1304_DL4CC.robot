*** Settings ***
Documentation    ...
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CB006137    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_peafu    CN1_SQ6    SBTS00
#Resource          ../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config/
#${FULL_SCFC_1304_DL4CC}      CB006137_AC_BO_1304_InterRAT_HO_DL4CC.xml
#${FULL_SCFC_1102_DL4CC}      CB006137_AC_BO_1102_DL4CC.xml
#${IPHY_XML_1304_DL4CC}       ${CURDIR}/config/WTS/iphy_2T_2F_for_1102_1304_DL4CC.xml
#${IPHY_XML_1102_DL4CC}       ${CURDIR}/config/WTS/iphy_2T_2F_for_1102_1304_DL4CC.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config/WTS
#${WTS_AP_XML}                airphone.xml
#${WTS_CFG_1304_DL4CC}        6137_AC_2T_2F_for_1304_DL4CC.cfg
#${WTS_CFG_1102_DL4CC}        6137_AC_2T_2F_for_1102_DL4CC.cfg
#${CA_UE_ID}                  1
#${SCELL1_PCI}                50
#${SCELL2_PCI}                60
#${SCELL3_PCI}                61
#${egate_file}                /opt/iphy/latest/egate_console.log
#
#
#*** Test Cases ***
#CB006137_ET_AC1102_BO_Single_UE_Intra_Band_Intra_Freq_HO_From_F1_T1_To_F2_T2
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_1102_DL4CC}
#    ...        AND    Suite Setup Update GNB    scf_file=${FULL_SCFC_1102_DL4CC}    iphy_file=${IPHY_XML_1102_DL4CC}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    SA Attach    sa_ue_id=${CA_UE_ID}
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL1_PCI}    scell_index=1
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL2_PCI}    scell_index=2
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL3_PCI}    scell_index=3
#    Start ULDL Traffic    ${CA_UE_ID}    1000    100
#    Check Pcell And Scell UL Tput Per UE    ${CA_UE_ID}    30    0    50    0
#    Check Pcell And Scell DL Tput Per UE    ${CA_UE_ID}    85    30    390    390
#    Trigger A3 Event And Check Handover Status
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL1_PCI}    scell_index=1
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL2_PCI}    scell_index=2
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL3_PCI}    scell_index=3
#    Check Pcell And Scell UL Tput Per UE    ${CA_UE_ID}    30    0    50    0
#    Check Pcell And Scell DL Tput Per UE    ${CA_UE_ID}    85    30    390    390
#
#
#CB006137_ET_AC1304_BO_Single_UE_Bi_Directional_Iner_RAT_HO_Between_2CC_ULCA_And_LTE
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_1304_DL4CC}
#    ...        AND    Suite Setup Update GNB    scf_file=${FULL_SCFC_1304_DL4CC}    iphy_file=${IPHY_XML_1304_DL4CC}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir
#    ...        AND    Common Test Setup
#    SA Attach    sa_ue_id=${CA_UE_ID}
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL1_PCI}    scell_index=1
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL2_PCI}    scell_index=2
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL3_PCI}    scell_index=3
#    Start ULDL Traffic    ${CA_UE_ID}    1000    100
#    Check Pcell And Scell UL Tput Per UE    ${CA_UE_ID}    30    0    50    0
#    Check Pcell And Scell DL Tput Per UE    ${CA_UE_ID}    85    30    390    390
#    Trigger A2 Event For UE1
#    Trigger B2 Event For UE1 And Check Handover From 5G To LTE
#    Verify HO Is Done At AMF
#    Trigger Handover For UE1 From LTE To 5G
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL1_PCI}    scell_index=1
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL2_PCI}    scell_index=2
#    Check SA Scell PhysicalID With UE ID    ue_id=${CA_UE_ID}    scell_physicalid=${SCELL3_PCI}    scell_index=3
#    Check Pcell And Scell UL Tput Per UE    ${CA_UE_ID}    30    0    50    0
#    Check Pcell And Scell DL Tput Per UE    ${CA_UE_ID}    85    30    390    390
#
#
#*** Keywords ***
#Trigger A3 Event And Check Handover Status
#    Log To Console    Trigger A3 event...
#    ${pattern}    Set Variable    UE1: Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.3 performed
#    ${cmd}    Catenate    ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=20
#    ...    phycell_id\=52 nrsrp_nr\=80
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#Trigger A2 Event For UE1
#    Log To Console    Trigger A2 event...
#    ${pattern}    Set Variable    rrcReconfigurationComplete
#    ${cmd}    Catenate    ue_measurement_send_nr id\=1 meas_id\=1 event\=A2 srsrp_nr\=11
#    ...    phycell_id\=51
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#
#Trigger B2 Event For UE1 And Check Handover From 5G To LTE
#    Log To Console    Trigger B2 event...
#    ${pattern}    Set Variable    UE1: Successful handover from EXT_ENB-2.2 to ENB-1.1
#    ${cmd}    Catenate    ue_measurement_send_nr id\=1 meas_id\=4 event\=B2 srsrp_nr\=11
#    ...    srsrq_nr\=11 phycell_id\=11 nrsrp_nr\=30 nrsrq_nr\=30
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#Verify HO Is Done At AMF
#    Log To Console    Wait for AMF is ready...
#    Wait Until Keyword Succeeds    5s    1s    Check Egate Log With Message    ${egate_file}
#    ...    Successfully switched source context with AMF
#
#Trigger Handover For UE1 From LTE To 5G
#    Log To Console    Trigger HO from LTE to 5G ...
#    ${pattern}    Set Variable    UE1: Inter-eNB handover from ENB-1.1 to EXT_ENB-2.2 performed
#    ${cmd}    Catenate    gnb_trigger_inter_rat_handover_to_5g ue\=1 target_gnb\=2 target_cell\=2
#    ...    plmn\=311:489
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#
#
#Start ULDL Traffic
#    [Arguments]    ${ue}    ${dl_trf}    ${ul_trf}
#    Start SA DL Big Traffic Internal    ${ue}    ${dl_trf}
#    Start SA UL Big Traffic Internal    ${ue}    ${ul_trf}
