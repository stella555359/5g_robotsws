*** Settings ***
#Resource    ../5GC001167/feature_keywords.robot
Library    CB007949_messaging_filters.py
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/logging.robot
Resource    testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/L3_Call.robot
Library     ute_wtssim
Library     ta5g_ue_mobility

Documentation   :copyright: Nokia
...             :contact: dominik.chalupczynski@nokia.com, marta.klukas@nokia.com

*** Variables ***
${F1AP_BAND_COMBINATION_INDEX}=             nr-rrc.bandCombinationIndex == 1
${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=         f1ap.SCell_ToBeSetupMod_List == 2
${F1AP_CSI_REPORTING_CONFIG_FOR_SCELLS}=    (nr-rrc.reportConfigId == 13) && (nr-rrc.reportConfigId == 14) &&
                                       ...  (nr-rrc.resourceSetToAddModList == 2) && !(nr-rrc.rrc_TransactionIdentifier)
${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST_1}=     (nr-rrc.pucch_ResourceSetId == 1) && (nr-rrc.PUCCH_ResourceId == 10) &&
                                       ...  (nr-rrc.PUCCH_ResourceId == 11) && (nr-rrc.maxPayloadSize == 16)  &&
                                       ...  (nr-rrc.resourceSetToAddModList == 2) && !(nr-rrc.rrc_TransactionIdentifier)
${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST_2}=     (nr-rrc.pucch_ResourceSetId == 2) &&
                                       ...  (nr-rrc.PUCCH_ResourceId == 9) && (nr-rrc.PUCCH_ResourceId == 19) &&
                                       ...  (nr-rrc.resourceSetToAddModList == 2) && !(nr-rrc.rrc_TransactionIdentifier)
${F1AP_SCELL_TO_ADD_MOD_LIST}=              (nr-rrc.sCellToAddModList == 2) &&
                                       ...  (nr-rrc.FreqBandIndicatorNR == 77)  && (nr-rrc.FreqBandIndicatorNR == 41) &&
                                       ...  (nr-rrc.resourceSetToAddModList == 2) && !(nr-rrc.rrc_TransactionIdentifier)
${F1AP_SCELL_TO_ADD_MOD_LIST_WITH_PCSI_BUNDLING}=    (nr-rrc.sCellToAddModList == 2) &&
                                       ...  (nr-rrc.FreqBandIndicatorNR == 77)  && (nr-rrc.FreqBandIndicatorNR == 41) &&
                                       ...  (nr-rrc.resourceSetToAddModList == 1) && nr-rrc.rrcReconfiguration_element
${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST_AFTER_SCELL_RELEASE_1}=       (nr-rrc.pucch_ResourceSetId == 1) &&
                                       ...  (nr-rrc.PUCCH_ResourceId == 17) &&
                                       ...  (nr-rrc.maxPayloadSize == 12) && !(nr-rrc.rrc_TransactionIdentifier) &&
                                       ...  (nr-rrc.resourceSetToAddModList == 2)
${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST_AFTER_SCELL_RELEASE_2}=       (nr-rrc.pucch_ResourceSetId == 1) &&
                                       ...  (nr-rrc.PUCCH_ResourceId == 17) &&
                                       ...  (nr-rrc.maxPayloadSize == 8) && !(nr-rrc.rrc_TransactionIdentifier) &&
                                       ...  (nr-rrc.resourceSetToAddModList == 1)
${NRCELLIDENTITY_&_BAND_COMBINATION}=             f1ap.nRCellIdentity == 00:00:04:00:40 &&
                                             ...  f1ap.nRCellIdentity == 00:00:04:00:60 &&
                                             ...  f1ap.procedureCode == 7 && f1ap.SCell_ToBeSetupMod_List == 2 &&
                                             ...  nr-rrc.bandCombinationIndex == 1 && nr-rrc.FeatureSetEntryIndex == 1
${SCELL_TO_ADD_MOD_LIST}=                         nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 53 &&
                                             ...  nr-rrc.physCellId == 55 && f1ap.procedureCode == 7
${RRC_RECONFIGURATION}=                           nr-rrc.sCellToAddModList == 2 && nr-rrc.message == 0 &&
                                             ...  nr-rrc.physCellId == 53 && nr-rrc.physCellId == 55 &&
                                             ...  nr-rrc.csi_ReportConfigToAddModList == 4 &&
                                             ...  nr-rrc.reportConfigId == 13 && nr-rrc.reportConfigId == 21 &&
                                             ...  nr-rrc.pucch_Resource == 20 && nr-rrc.reportQuantity == 6 &&
                                             ...  nr-rrc.reportConfigId == 14 && nr-rrc.reportConfigId == 22 &&
                                             ...  nr-rrc.pucch_Resource == 22
${PUCCH_CONFIGURATION_SCELLS}=                    nr-rrc.csi_ReportConfigToAddModList == 4 &&
                                             ...  nr-rrc.reportConfigId == 13 && nr-rrc.reportConfigId == 21 &&
                                             ...  nr-rrc.pucch_Resource == 20 && nr-rrc.reportQuantity == 6 &&
                                             ...  nr-rrc.reportConfigId == 14 && nr-rrc.reportConfigId == 22 &&
                                             ...  nr-rrc.pucch_Resource == 22 && !nr-rrc.reportQuantity == 5 &&
                                             ...  f1ap.procedureCode == 7
${F1AP_FULL_CONFIGURATION}=                       nr-rrc.csi_ReportConfigToAddModList == 6 &&
                                             ...  nr-rrc.reportConfigId == 0 && nr-rrc.reportConfigId == 2 &&
                                             ...  nr-rrc.pucch_Resource == 18 && nr-rrc.reportQuantity == 5 &&
                                             ...  nr-rrc.reportConfigId == 13 && nr-rrc.reportConfigId == 21 &&
                                             ...  nr-rrc.pucch_Resource == 20 && nr-rrc.reportQuantity == 6 &&
                                             ...  nr-rrc.reportConfigId == 14 && nr-rrc.reportConfigId == 22 &&
                                             ...  nr-rrc.pucch_Resource == 22 && f1ap.procedureCode == 7 &&
                                             ...  nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 53 &&
                                             ...  nr-rrc.physCellId == 55
${UE_ATTACHED_PCELL}=                             f1ap.nRCellIdentity == 00:00:04:00:30 && f1ap.procedureCode == 11
${SCELL_CHANGE_TFF_TTT}=                          nr-rrc.sCellToReleaseList == 2 && nr-rrc.sCellToAddModList == 2 &&
                                             ...  nr-rrc.physCellId == 53 && nr-rrc.physCellId == 55
${SCELL_CHANGE_TTT_TF}=                           nr-rrc.sCellToReleaseList == 2 && nr-rrc.sCellToAddModList == 1 &&
                                             ...  nr-rrc.physCellId == 54
${MEAS_CONFIG_TFF_TTT}=                           nr-rrc.measIdToAddModList == 2 && nr-rrc.measObjectToAddModList == 2
                                             ...  && nr-rrc.ssbFrequency == 649920 && nr-rrc.ssbFrequency == 531870
                                             ...  && nr-rrc.measIdToRemoveList == 3
${MEAS_CONFIG_TTT_TF}=                            nr-rrc.measIdToAddModList == 1 && nr-rrc.measObjectToAddModList == 1
                                             ...  && nr-rrc.ssbFrequency == 392410 && nr-rrc.measIdToRemoveList == 3
${MAX_PAYLOAD_SIZE_VALUE_TTT}=                    16
${MAX_PAYLOAD_SIZE_VALUE_TF}=                     12
${MAX_PAYLOAD_SIZE_VALUE_TF_SINCE_23R2}=          8
${F1AP_A1_CONFIGURATION}=                         nr-rrc.eventId == 0  && nr-rrc.measId == 1 &&
                                             ...  nr-rrc.measObjectId == 1 && nr-rrc.reportConfigId == 1
${A1_CONFIGURATION_RRC_RECONFIGURATION}=          nr-rrc.eventId == 0  && nr-rrc.measId == 1 &&
                                             ...  nr-rrc.measObjectId == 1 && nr-rrc.reportConfigId == 1
                                             ...  && nr-rrc.rrcReconfiguration_element
${CSI_RS_AND_ACSI_ALLOC_PCELL}=                   nr-rrc.reportConfigId == 1 && nr-rrc.csi_IM_ResourceToAddModList == 4
                                             ...  && nr-rrc.nzp_CSI_RS_ResourceToAddModList == 4 &&
                                             ...  nr-rrc.nzp_CSI_RS_ResourceId == 0 &&
                                             ...  nr-rrc.nzp_CSI_RS_ResourceId == 181 &&
                                             ...  nr-rrc.nzp_CSI_RS_ResourceId == 182 &&
                                             ...  nr-rrc.nzp_CSI_RS_ResourceId == 183 &&
                                             ...  nr-rrc.nzp_CSI_ResourceSetId == 0 && nr-rrc.nzp_CSI_RS_Resources == 4
                                             ...  && nr-rrc.NZP_CSI_RS_ResourceId == 183 &&
                                             ...  nr-rrc.NZP_CSI_RS_ResourceId == 182 &&
                                             ...  nr-rrc.NZP_CSI_RS_ResourceId == 181 &&
                                             ...  nr-rrc.NZP_CSI_RS_ResourceId == 0
${SCELL_ADDITION_TTT}=                            nr-rrc.bandCombinationIndex == 1 && f1ap.SCell_ToBeSetupMod_List == 2 &&
                                             ...  f1ap.nRCellIdentity == 00:00:04:00:30 &&
                                             ...  f1ap.nRCellIdentity == 00:00:04:00:60
${A1_A2_MEASUREMENTS_RECONFIGURATION}=            nr-rrc.measObjectToAddModList == 2 &&
                                             ...  nr-rrc.reportConfigToAddModList == 1 && nr-rrc.eventId == 1 &&
                                             ...  nr-rrc.measIdToAddModList == 2 && nr-rrc.measId == 2 &&
                                             ...  nr-rrc.measObjectId == 2 && nr-rrc.reportConfigId == 2 &&
                                             ...  nr-rrc.measId == 3 && nr-rrc.measObjectId == 3 &&
                                             ...  nr-rrc.reportConfigToRemoveList == 1 && nr-rrc.measIdToRemoveList == 1
${A2_MEASUREMENTS_CONFIGURATION}=            nr-rrc.eventA2_element && nr-rrc.measObjectToAddModList == 2 &&
                                             ...  nr-rrc.reportConfigToAddModList == 1 &&
                                             ...  nr-rrc.measIdToAddModList == 2 && nr-rrc.measId == 2 &&
                                             ...  nr-rrc.measObjectId == 2 && nr-rrc.reportConfigId == 2 &&
                                             ...  nr-rrc.measId == 3 && nr-rrc.measObjectId == 3 &&
                                             ...  nr-rrc.reportConfigToRemoveList == 1 && nr-rrc.measIdToRemoveList == 1
${CSI_RS_ALLOCATION_FOR_SCELLS}=                  nr-rrc.csi_IM_ResourceToAddModList == 4 &&
                                             ...  nr-rrc.nzp_CSI_RS_ResourceId == 0 &&
                                             ...  nr-rrc.nzp_CSI_RS_ResourceId == 181 &&
                                             ...  nr-rrc.nzp_CSI_RS_ResourceId == 182 &&
                                             ...  nr-rrc.nzp_CSI_RS_ResourceId == 183 && nr-rrc.sCellIndex == 1 &&
                                             ...  nr-rrc.sCellIndex == 2 &&
                                             ...  nr-rrc.nzp_CSI_ResourceSetId == 0 && nr-rrc.nzp_CSI_RS_Resources == 4
                                             ...  && nr-rrc.NZP_CSI_RS_ResourceId == 183
${SCELL_2_RELEASE_A2_MEASUREMENT_DECONFIGURATION}=  nr-rrc.measIdToRemoveList == 1 && nr-rrc.MeasId == 3 &&
                                             ...  nr-rrc.sCellToReleaseList == 1 && nr-rrc.SCellIndex == 2
${SCELL_1_RELEASE_A2_MEASUREMENT_DECONFIGURATION}=  nr-rrc.measIdToRemoveList == 1 && nr-rrc.MeasId == 2 &&
                                             ...  nr-rrc.sCellToReleaseList == 1 && nr-rrc.SCellIndex == 1
${CSI_RS_AND_ACSI_REMAIN_PCELL}=                  !nr-rrc.aperiodicTriggerStateList == 1 &&
                                             ...  !nr-rrc.nzp_CSI_RS_ResourceToAddModList == 4 &&
                                             ...  !nr-rrc.nzp_CSI_RS_ResourceId == 0 &&
                                             ...  !nr-rrc.nzp_CSI_RS_ResourceId == 181 &&
                                             ...  !nr-rrc.nzp_CSI_RS_ResourceId == 182 &&
                                             ...  !nr-rrc.nzp_CSI_RS_ResourceId == 183 &&
                                             ...  !nr-rrc.nzp_CSI_ResourceSetId == 0 && !nr-rrc.reportConfigId &&
                                             ...  nr-rrc.c1 == 0 && f1ap.procedureCode == 12
${RRC_CSI-RS_AND_aCSI_AFTER_PDU_SESSION_SETUP}=    (((((((((nr-rrc.nzp_CSI_RS_ResourceToAddModList == 4) &&
                                            ...  (nr-rrc.nzp_CSI_RS_ResourceId == 0)) &&
                                            ...  (nr-rrc.nzp_CSI_RS_ResourceId == 181)) &&
                                            ...  (nr-rrc.nzp_CSI_RS_ResourceId == 182)) &&
                                            ...  (nr-rrc.nzp_CSI_RS_ResourceId == 183)) &&
                                            ...  (nr-rrc.csi_IM_ResourceToAddModList == 4)) &&
                                            ...  (nr-rrc.csi_IM_ResourceId == 0)) && (nr-rrc.csi_IM_ResourceId == 1)) &&
                                            ...  (nr-rrc.csi_IM_ResourceId == 2)) && (nr-rrc.csi_IM_ResourceId == 3) &&
                                            ...  !(nr-rrc.aperiodicTriggerStateList == 1)
${RRC_RECONFIGURATION_WITH_ONE_OCCURENCE_OF_MULTI_CSI_PUCCH_RESOURCELIST}=  nr-rrc.rrcReconfiguration_element &&
                                            ...  nr-rrc.multi_CSI_PUCCH_ResourceList


*** Keywords ***
Register UE With PDU Session Setup
    [Arguments]     ${ue_id}    ${pdu_id}    ${gw_id}
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue                           ue_id=${ue_id}
    Establish Pdu Session
    ...    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}
    ...    gw_id=${gw_id}
    ...    nwslice=1
    ...    check_timestamps=${False}

Set Internal Traffic Type To UEs
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal

Verify Successful 3CC TTT SCell Addition
    Verify Tcpdump Log      packet_filter=${F1AP_BAND_COMBINATION_INDEX}             number_of_messages=1
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}         number_of_messages=1
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}              number_of_messages=1

Verify Successful 3CC TTT SCell Addition With PCSI Bundling
    Verify Tcpdump Log      packet_filter=${F1AP_BAND_COMBINATION_INDEX}                      number_of_messages=1
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}                  number_of_messages=1
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST_WITH_PCSI_BUNDLING}    number_of_messages=1

Verify PUCCH Resource For 3CC TTT
    Verify Tcpdump Log      packet_filter=${F1AP_CSI_REPORTING_CONFIG_FOR_SCELLS}    number_of_messages=1
    Verify Tcpdump Log      packet_filter=${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST_1}     number_of_messages=1
    Verify Tcpdump Log      packet_filter=${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST_2}     number_of_messages=1

Verify Successful 3CC TTT On F1AP Messages
    Verify Tcpdump Log      packet_filter=${NRCELLIDENTITY_&_BAND_COMBINATION}           continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${SCELL_TO_ADD_MOD_LIST}                       continue_on_failure=False
                                                                                  ...    relation_symbol= >=

Verify Correct PUCCH Configuration For SCells
    Verify Tcpdump Log      packet_filter=${PUCCH_CONFIGURATION_SCELLS}                  continue_on_failure=False

Verify RRC Reconfiguration
    Verify Tcpdump Log      packet_filter=${RRC_RECONFIGURATION}                         continue_on_failure=False
                                                                                  ...    relation_symbol= >=

Verify Full Configuration
    Verify Tcpdump Log      packet_filter=${F1AP_FULL_CONFIGURATION}                     continue_on_failure=False

Verify If Ue Is Attached To PCell
    Verify Tcpdump Log      packet_filter=${UE_ATTACHED_PCELL}                           continue_on_failure=False

Send A1 Measurement
    [Arguments]    ${ue_id}    ${a1_meas_id}    ${a1_rsrp}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a1_meas_id} srsrp_nr\=${a1_rsrp} event\=A1
    ...    pass_regexp=message c1 : rrcReconfigurationComplete

Send A1 Measurement With Capture
    [Arguments]   ${ue_id}    ${a1_meas_id}    ${a1_rsrp}
    Run Keyword And Return    With Message Capture    eth4   Send A1 Measurement
    ...    ue_id=${ue_id}
    ...    a1_meas_id=${a1_meas_id}
    ...    a1_rsrp=${a1_rsrp}

Verify MaxPayloadSize Value
   [Arguments]    ${value}    ${message_to_check}=${scell_change}
    Verify Tshark For Single Message
    ...   alias=${message_to_check}
    ...   packet_filter= nr-rrc.maxPayloadSize == ${value}

Verify PUCCH Resource After First SCell Release
    Verify Tcpdump Log      packet_filter=${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST_AFTER_SCELL_RELEASE_1}       number_of_messages=1

Verify PUCCH Resource After Second SCell Release
    Verify Tcpdump Log      packet_filter=${F1AP_RESOURCE_SET_TO_ADD_MOD_LIST_AFTER_SCELL_RELEASE_2}       number_of_messages=1

Verify ${number} Of Messages With ${filter} In Tcpdump Log
    Verify Tcpdump Log      packet_filter=${filter}                                                        number_of_messages=${number}

Establish PDU Session Setup With Capture
    [Arguments]   ${ue_id}   ${pdu_id}    ${gw_id}
    Run Keyword And Return    With Message Capture    eth4   Establish PDU Session
    ...    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}
    ...    gw_id=${gw_id}

Verify Csi-IM and nzp-CSI-RS on RRC after PDU Session Setup
   [Arguments]    ${message_to_check}=${pdu_session}
   Verify Tshark For Single Message
   ...    alias=${message_to_check}
   ...    packet_filter=${RRC_CSI-RS_AND_aCSI_AFTER_PDU_SESSION_SETUP}

Verify A1 Configuration
    Verify 1 Of Messages With ${A1_CONFIGURATION_RRC_RECONFIGURATION} In Tcpdump Log

Send A1 Measurement And Verify A2 Configuration On 2 Scells
    Expect SCell Addition messages flow    ue_id=${ue_id}    gNB_id=${gnb_id}
    Execute Egate Command And Wait For Data
    ...     cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a1_meas_id} event\=A1 srsrp_nr\=${a1_rsrp}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete
    Check if SCell Addition messages flow occured    ue_id=${ue_id}
    Verify 1 Of Messages With ${A2_MEASUREMENTS_CONFIGURATION} In Tcpdump Log

Send A2 Measurement And Verify SCell2 Release
    [Arguments]    ${a2_meas_id}    ${a2_rsrp}    ${scell_id}
    Expect SCell Release messages flow    ue_id=${ue_id}
    Execute Egate Command And Wait For Data
    ...     cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a2_meas_id} event\=A2 srsrp_nr\=${a2_rsrp} scell\=${scell_id}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete
    Check if SCell Release messages flow occured   ue_id=${ue_id}
    Verify 1 Of Messages With ${SCELL_2_RELEASE_A2_MEASUREMENT_DECONFIGURATION} In Tcpdump Log

Verify PSCI Bundling After RRC Setup
    Verify That Message Fulfills Query
    ...  ${pCSI_enabled_after_RRC_setup}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=Established_PDU_UE${ue_id}

Verify PCSI Bundling After SCell Addition
   [Arguments]    ${starting_prb}
   ${pCSI_enabled_after_TT_SCell_addition}=    Create PCSI After TT SCell Addition Filter    ${starting_prb}
   Verify That Message Fulfills Query
    ...  ${pCSI_enabled_after_TT_SCell_addition}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify PCSI Bundling After SCell2 Release
   Verify That Message Fulfills Query
    ...  ${pCSI_enabled_after_SCell2_release}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellRelease_UE${ue_id}

