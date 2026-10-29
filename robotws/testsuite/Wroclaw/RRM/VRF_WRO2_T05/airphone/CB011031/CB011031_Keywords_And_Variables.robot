*** Settings ***
Documentation    :copyright: Nokia

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_ue_measurements
Library      ta5g_tshark
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_enb

*** Variables ***
${FULL_COMMISSIONING}=    ${TRUE}
${RESET_TL}=    ${FALSE}
${RESTORE_DEFAULT_CONFIG}=    ${TRUE}
${NRREL_OBJECT_CREATION_TIME}=    120
${EXPECTED_NRREL_OBJECTID}=    256
${SIB1_SSBPOSITIONS_DEFAULT}=    f1ap.nRARFCN == 634728 && nr-rrc.mediumBitmap == 80
${SIB1_SSBPOSITIONS_ON}=    f1ap.nRARFCN == 634728 && nr-rrc.mediumBitmap == 20
${SIB2_SSBPOSITIONS_ON}=    f1ap.sIBtype == 2 && nr-rrc.mediumBitmap == a0
${SSBPOSITIONS_CELL_50}=    nr-rrc.hoppingId == 50 && nr-rrc.mediumBitmap == 80 && nr-rrc.reportConfigId == 1
${SSBPOSITIONS_CELL_51}=    nr-rrc.hoppingId == 51 && nr-rrc.mediumBitmap == 20 && nr-rrc.reportConfigId == 1
${SIB1_SSBPOSITIONS_DEFAULT_INTER_FREQ}=    f1ap.nRARFCN==635394 && nr-rrc.mediumBitmap==80
${SIB1_SSBPOSITIONS_ON_INTER_FREQ}=    f1ap.nRARFCN == 631428 && nr-rrc.mediumBitmap == 20
${SIB2_SSBPOSITIONS_ON_INTER_FREQ}=    f1ap.sIBtype == 2 && nr-rrc.mediumBitmap == 20
${SSBPOSITIONS_CELL_50_A2}=    nr-rrc.hoppingId == 50 && nr-rrc.mediumBitmap == 20&& nr-rrc.mediumBitmap == 80
${SSBPOSITIONS_CELL_50_A5}=    f1ap.UEContextModificationResponse_element && f1ap.measGapConfig &&
...                            nr-rrc.hoppingId == 50 && nr-rrc.mediumBitmap == 80
${SSBPOSITIONS_CELL_51_A2}=    nr-rrc.hoppingId == 51 && nr-rrc.mediumBitmap == 80 && nr-rrc.mediumBitmap == 20
${SSBPOSITIONS_CELL_51_A5}=    f1ap.UEContextModificationResponse_element && f1ap.measGapConfig &&
...                            nr-rrc.hoppingId == 51 && nr-rrc.mediumBitmap == 20

*** Keywords ***
Verify Existing NRREL
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${EXPECTED_NRREL_OBJECTID}    moc=NRREL_A
    ...    timeout=${NRREL_OBJECT_CREATION_TIME}

Start Multiple Vms Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB2_X2     ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:gNB3_X2     ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:gNB_S1U     ip_with_mask=10.0.1.112/24

Stop Multiple Vms Interfaces
    Stop Vm Ethernet Interface     if_name=eth3:gNB2_X2     ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface     if_name=eth3:gNB3_X2     ip_with_mask=10.0.1.4/24
    Stop Vm Ethernet Interface     if_name=eth3:gNB_S1U     ip_with_mask=10.0.1.112/24
