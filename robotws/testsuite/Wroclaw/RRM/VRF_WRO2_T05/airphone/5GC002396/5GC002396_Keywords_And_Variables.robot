*** Settings ***
Documentation    :copyright: Nokia

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot

Library    ta5g_testline_management
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_ue_measurements
Library    ta5g_pm_counters
Library    ta5g_cell_operations
Library    ta5g_iperf_traffic

*** Variables ***
${NONCOHERENT_CODEBOOK} =    ${RRC_RECONFIGURATION} && nr-rrc.codebookSubset == 2
${NUMBER_OF_SRS_PORTS} =    ${RRC_RECONFIGURATION} && nr-rrc.nrofSRS_Ports == 1
${MAX_MIMO_LAYERS} =    ${RRC_RECONFIGURATION} && nr-rrc.maxMIMO_Layers == 2
${UE_POWER_CLASS_PC3} =    ${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && nr-rrc.ue_PowerClass == 2
${UE_POWER_CLASS_PC2} =    ${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && nr-rrc.ue_PowerClass == 1
${UE_POWER_CLASS_PC1_5} =    ${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && nr-rrc.ue_PowerClass_v1610 == 0
${UE_BAND_78} =    ${UE_CAPABILITY_ENQUIRY} && nr-rrc.bandNR == 78
${FULL_POWER_MODE_0} =    ${RRC_RECONFIGURATION} && nr-rrc.ul_FullPowerTransmission_r16 == 0
${FULL_POWER_MODE_1} =    ${RRC_RECONFIGURATION} && nr-rrc.ul_FullPowerTransmission_r16 == 1
${FULL_POWER_MODE_2} =    ${RRC_RECONFIGURATION} && nr-rrc.ul_FullPowerTransmission_r16 == 2
${PHYS_CELL_ID_AFTER_MEAS} =    ${RRC_RECONFIGURATION} && nr-rrc.physCellId == 50 && nr-rrc.physCellId == 51
${FULL_POWER_TRANSMISSION_OFF} =    ${RRC_RECONFIGURATION} && !nr-rrc.ul_FullPowerTransmission_r16 == 0

*** Keywords ***

Register Ue And Start Traffic And Deregister UE
    [Arguments]    ${ue_id}    ${pdu_gw_id}
    Attach Ue    ue_id=${ue_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_gw_id}    gw_id=${pdu_gw_id}
    Start Traffic And Check If Average Throughput Is Reached
    ...    pdu_gw_id=${pdu_gw_id}
    ...    throughput=2m
    ...    duration=20
    ...    direction=ul
    Deregister Ue    ue_id=${ue_id}
