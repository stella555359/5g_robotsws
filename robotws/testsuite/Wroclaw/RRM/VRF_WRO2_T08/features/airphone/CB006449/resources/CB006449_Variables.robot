*** Settings ***

Documentation    :copyright: Nokia

*** Variables ***

${FULL_COMMISSIONING}=        ${FALSE}
${RESET_TL}=                  ${FALSE}
${RESTORE_DEFAULT_CONFIG}=    ${FALSE}

${delta_set_collecting_counters_to_five_minutes}
...   /home/ute/robotws/testsuite/RRM/5G_SW_WRO/resources/config/SBTS22R2/delta_set_collecting_counters_to_five_minutes.json

@{pdu_qos_list_high_reliability}     3,2

############# WIRESHARK ################
${DEFAULT_S1_MME_ALIAS}    default_s1_x2
${DEFAULT_UU_ALIAS}    default_uu

${event_A1}    nr-rrc.eventId == 0
${event_A2}    nr-rrc.eventId == 1

${UE1_CELL1}    1
${UE2_CELL1}    2
${UE2_CELL2}    2
${UE3_CELL1}    3
${UE4_CELL1}    4
${UE5_CELL1}    5
${UE6_CELL1}    6


${UE1_CELL2}    5
${UE1_CELL3}    1
${UE2_CELL3}    2

${WIRESHARK_U_ID}    and iphy.ue_id ==
${NSETAPX_PROTOCOL}    nsetapx
${NSETAPX_SBA}    nsetapx.traceActivationType == 1
${NSETAPX_MBA}    nsetapx.traceActivationType == 0
${NSETAPX_IS_ALIVE}    nsetapx.TraceMessage == 0
${NSETAPX_START_RECORDING_SESSION}    ${NSETAPX_PROTOCOL} && nsetapx.startRecordingSession_element
${NSETAPX_STOP_RECORDING_SESSION}    ${NSETAPX_PROTOCOL} && nsetapx.stopRecordingSession_element
${NSETAPX_REPORT}    nsetapx.report_element
${UE1_NGAP_ID}    ngap.AMF_UE_NGAP_ID == 1
${UE2_NGAP_ID}    ngap.AMF_UE_NGAP_ID == 2
${UE_1_ICS_RESP}    ${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA} && ${UE1_NGAP_ID}
${UE_2_ICS_RESP}    ${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${NSETAPX_PROTOCOL} && ${NSETAPX_SBA} && ${UE2_NGAP_ID}


${RRC_RECONF_SCELLADD}
...    nr-rrc.sCellToAddModList == 1
${RRC_RECONF_COMPLETE_FILTER}
...    nr-rrc.rrcReconfigurationComplete_element

${NRRRC_SRB_TOADDMODLIST}    nr-rrc.srb_ToAddModList
${RRC_RECONF_SRS_RESOURCETOADDMODLIST_PCI_53_PCI_51}
...    nr-rrc.srs_ResourceToAddModList && nr-rrc.physCellId==51 && nr-rrc.physCellId==53 && nr-rrc.usage == 1 && nr-rrc.codebookType==0
...    && nr-rrc.nrofSRS_Ports  && nr-rrc.transmissionComb == 0 && nr-rrc.c_SRS==25 && nr-rrc.b_SRS ==0 && nr-rrc.sequenceId == 53
...    && nr-rrc.freqDomainPosition == 0 && nr-rrc.resourceType == 2
${RRC_RECONF_SRS_RESOURCETOADDMODLIST}
...    nr-rrc.srs_ResourceToAddModList && nr-rrc.physCellId==51 && nr-rrc.physCellId==52 && nr-rrc.usage == 1 && nr-rrc.codebookType==0
${RRC_RECONF_PCI_52_DL_UL_PCI_53_DL}
...    nr-rrc.sCellToAddModList==2 && nr-rrc.physCellId==52 && nr-rrc.physCellId==53 && nr-rrc.uplinkBWP_ToAddModList==1
${RRC_RECONF_PCI_52_DL_UL_PCI_60_DL}
...    nr-rrc.sCellToAddModList==2 && nr-rrc.physCellId==52 && nr-rrc.physCellId==60 && nr-rrc.uplinkBWP_ToAddModList==1
${RRC_RECONF_PCI_52_DL_UL_PCI_53_DL_PCI_60_DL}
...    nr-rrc.sCellToAddModList==3 && nr-rrc.physCellId==52 && nr-rrc.physCellId==53 && nr-rrc.physCellId==60 && nr-rrc.uplinkBWP_ToAddModList==1
${RRC_RECONF_PCI_52_DL_PCI_53_DL_PCI_60_DL}
...    nr-rrc.sCellToAddModList==3 && nr-rrc.physCellId==52 && nr-rrc.physCellId==53 && nr-rrc.physCellId==60 && !(nr-rrc.uplinkBWP_ToAddModList==1)
${RRC_RECONF_PCI_52_DL_UL_PCI_53_DL_PCI_57_DL_PCI_58_DL_PCI_60_DL}
...    nr-rrc.sCellToAddModList==5 && nr-rrc.physCellId==52 && nr-rrc.physCellId==53 && nr-rrc.physCellId==57 && nr-rrc.physCellId==58
...    && nr-rrc.physCellId==60 && nr-rrc.uplinkBWP_ToAddModList==1
${RRC_RECONF_PCI_53_DL_UL_PCI_58_DL_PCI_60_DL}
...    nr-rrc.sCellToAddModList==3 && nr-rrc.physCellId==53 && nr-rrc.physCellId==58 && nr-rrc.physCellId==60
...    && nr-rrc.uplinkBWP_ToAddModList==1
${RRC_RECONF_PCI_53_DL_PCI_60_DL}
...    nr-rrc.sCellToAddModList==2 && nr-rrc.physCellId==53 && nr-rrc.physCellId==60
${RRC_RECONF_PCI_51_DL_UL_PCI_60_DL}
...    nr-rrc.sCellToAddModList==2 && nr-rrc.physCellId==51 && nr-rrc.physCellId==60 && nr-rrc.uplinkBWP_ToAddModList==1
${RRC_RECONF_PCI_52_DL_UL_PCI_58_DL_PCI_60_DL}
...    nr-rrc.sCellToAddModList==3 && nr-rrc.physCellId==52 && nr-rrc.physCellId==58 && nr-rrc.physCellId==60 && nr-rrc.uplinkBWP_ToAddModList==1
${RRC_RECONF_PCI_52_DL_UL}
...    nr-rrc.sCellToAddModList==1 && nr-rrc.physCellId==52 && nr-rrc.uplinkBWP_ToAddModList==1
${RRC_RECONF_PCI_53_DL_UL_PCI_58_DL_PCI_60_DL_WITHOUT_MEASCONFIG}
...    nr-rrc.sCellToAddModList==3 && nr-rrc.physCellId==53 && nr-rrc.physCellId==58 && nr-rrc.physCellId==60
...    && nr-rrc.uplinkBWP_ToAddModList==1 && !(nr-rrc.measIdToAddModList) && !(nr-rrc.measObjectToRemoveList)
${RRC_RECONF_A2_SCELL_RELEASE_SCELL_ID1_WITHOUT_MEASCONFIG}
...    nr-rrc.sCellToReleaseList == 1 && nr-rrc.SCellIndex == 1 && !(nr-rrc.measIdToAddModList) && !(nr-rrc.measObjectToRemoveList)
${SCELL_RELEASE}
...    nr-rrc.sCellToReleaseList==3
${RRC_RECONF_PCI_53_DL_UL}
...    nr-rrc.sCellToAddModList==1 && nr-rrc.physCellId==53

${RRC_RECONF_ULTX_SWITCH_WITH_SCELLS_ADD}
...    nr-rrc.maxRank == 2 && nr-rrc.nrofSRS_Ports == 1 && nr-rrc.uplinkTxSwitchingCarrier_r16 == 1
...    && nr-rrc.uplinkTxSwitchingPeriodLocation_r16 == False
...    && nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 52 && nr-rrc.physCellId == 53
${RRC_RECONF_WITHOUT_ULTX_SWITCH_WITH_SCELLS_ADD}
...    nr-rrc.maxRank != 2 && !nr-rrc.uplinkTxSwitchingCarrier_r16 && !nr-rrc.uplinkTxSwitchingPeriodLocation_r16
...    && nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 51 && nr-rrc.physCellId == 53
