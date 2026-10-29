*** Variables ***
${custom-scf-2}    ${CURDIR}/../resources/custom-config/2_CELLS_SANSA_TDD_CA/gNB_scf_ASIL_ABIO_TDD_ECPRI_cmwv_SANSA_FS_2CC_CA_N77_N41.xml
${custom-iphy-2}   ${CURDIR}/../resources/custom-config/2_CELLS_SANSA_TDD_CA/AP_iphy_AWHQX_AEHC_ASIL_ABIO_TDD_ECPRI_cmwv_SANSA_FS_2CC_CA_N77_N41.xml
${custom-scf-4}    ${CURDIR}/../resources/custom-config/2_CELLS_SANSA_TDD_CA/gNB_scf_ASIL_ABIO_TDD_ECPRI_cmwv_SANSA_FS_2CC_CA_N78_N41.xml
${custom-iphy-4}   ${CURDIR}/../resources/custom-config/2_CELLS_SANSA_TDD_CA/AP_iphy_AEQE_AEHC_ASIL_ABIO_TDD_ECPRI_cmwv_SANSA_FS_2CC_CA_N78_N41.xml
${custom-scf-9}    ${CURDIR}/../resources/custom-config/2_CELLS_SANSA_TDD_CA/gNB_scf_ASIL_ABIO_TDD_ECPRI_cmwv_SANSA_FS_2CC_CA_N41_N79.xml
${custom-iphy-9}   ${CURDIR}/../resources/custom-config/2_CELLS_SANSA_TDD_CA/AP_iphy_AQHA_AZTA_ASIL_ABIO_TDD_ECPRI_cmwv_SANSA_FS_2CC_CA_N41_N79.xml
${UE_POWER_CLASS_PC1_5} =    ${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && nr-rrc.ue_PowerClass_v1610 == 0
${UE_BAND_N77} =     nr-rrc.ueCapabilityEnquiry_element && nr-rrc.bandNR == 77
${UE_BAND_N78} =     nr-rrc.ueCapabilityEnquiry_element && nr-rrc.bandNR == 78
${UE_BAND_N79} =     ${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION} && nr-rrc.bandNR == 79
${UE_PMAX1_N77} =     ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.p_Max == 29 && nr-rrc.FreqBandIndicatorNR == 77
${UE_PMAX2_N77} =     ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.p_Max == -16 && nr-rrc.FreqBandIndicatorNR == 77
${UE_PMAX3_N77} =     ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.p_Max == 5 && nr-rrc.FreqBandIndicatorNR == 77
${UE_PMAX1_N78} =     ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.p_Max == 29 && nr-rrc.FreqBandIndicatorNR == 78
${UE_PMAX2_N78} =     ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.p_Max == -29 && nr-rrc.FreqBandIndicatorNR == 78
${UE_PMAX3_N78} =     ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.p_Max == 0 && nr-rrc.FreqBandIndicatorNR == 78
${UE_PMAX_N79_1} =     ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.p_Max == 1 && nr-rrc.FreqBandIndicatorNR == 79
${UE_PMAX_N79_23} =     ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.p_Max == 23 && nr-rrc.FreqBandIndicatorNR == 79
${UE_PMAX_N79_30} =     ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.p_Max == 29 && nr-rrc.FreqBandIndicatorNR == 79
${FULL_POWER_MODE} =    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.ul_FullPowerTransmission_r16 == 1
${SCELL_N41} =       ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.sCellToAddModList >= 1 && nr-rrc.FreqBandIndicatorNR == 41


*** Keywords ***

Attach UE and verify tcpdump
    [Arguments]  ${ue}  ${packet_filter}    ${pmax_value}   ${nrband}  ${cell_id}
    Perform Parameter Commissioning
    ...    parameter=pMaxNROwnCell
    ...    value=${pmax_value}
    ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    Wait For Sib1 Reception
    Attach Ue    ue_id=${ue}
    Establish Pdu Session With Traffic   ue_id=${ue}    pdu_id=${ue}    gw_id=${ue}     throughput=3mbps
    Verify Tcpdump Log    packet_filter=${packet_filter}      number_of_messages=1    relation_symbol= >=
    Deregister Ue Without Confirmation    ue_id=${ue}
    Verify Tcpdump Log    packet_filter=${nrband}      number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${SCELL_N41}      number_of_messages=1    relation_symbol= >=
    Verify Ngap Messages  packet_filter=${UE_POWER_CLASS_PC1_5}      number_of_messages=1    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${FULL_POWER_MODE}  number_of_messages=1    relation_symbol= >=
