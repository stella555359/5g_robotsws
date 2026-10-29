*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    suffix.robot

*** Variables ***

*** Keywords ***
Verify that UECtxSetupReq_${n:\d+} out of ${all:\d+} was send for ${s:\d+}-SCells with ${d:\d+} DRB, BandCombIdx=${bc:\d+} for gNB${gnb_id:\d+}
    Verify in UECtxSetupReq_${n} out of ${all} that ServCellIndex eq 1 for gNB${gnb_id}
    Verify in UECtxSetupReq_${n} out of ${all} that ue-CapabilityInfo is present for gNB${gnb_id}
    Verify in UECtxSetupReq_${n} out of ${all} that cg-ConfigInfo contains candidateCellInfoListMN for gNB${gnb_id}
    Verify in UECtxSetupReq_${n} out of ${all} that bandCombinationIndex eq ${bc}, allowedFeatureSetsList has 1 elem for gNB${gnb_id}
    Verify in UECtxSetupReq_${n} out of ${all} that PSCell PLMN-"0x134198" and NRCellID-16386 for gNB${gnb_id}
    Verify in UECtxSetupReq_${n} out of ${all} that ${s}-SCells with PLMN-"0x134198", starting NRCellID-16387 for gNB${gnb_id}
    Verify in UEContextSetupRequest_${n} out of ${all} that ${d} DRB is set according to E1AP for gNB${gnb_id}
    Verify in UECtxSetupReq_${n} out of ${all} that uLUEConfiguration eq 'shared' for gNB${gnb_id}

Verify that UECtxSetupResp_${num:\d+} out of ${all:\d+} with ${d:\d+} DRB, BandCombIdx=${bc:\d+}, ${s:\d+}-SCells, MIMO-${mimo:\d+} for gNB${id:\d+}
    Verify in UECtxSetupResp_${num} out of ${all} that CellGroupID eq 1 for gNB${id}
    Verify in UECtxSetupResp_${num} out of ${all} servCellIndex 1, 2 MIMO in UL and 2 MIMO in DL for gNB${id}
    Verify in UECtxSetupResp_${num} out of ${all} contains sCellToAddModList with ${s} elements and MIMO-${mimo} for gNB${id}
    Verify in UECtxSetupResp_${num} out of ${all} SelectedBandCombinationIndex=${bc}, SelectedFeatureSetEntryIndex=1 for gNB${id}
    Verify in UEContextSetupResponse_${num} out of ${all} that ${d} DRB is set according to E1AP for gNB${id}
    Verify in UECtxSetupResp_${num} out of ${all} that gTPTunnel is present for gNB${id}

Verify that UECtxSetupResp_${num:\d+} out of ${all:\d+} has sCellFailedTBStpList with ${s:\d+} elements for gNB${id:\d+} with start NRCellID-${n:\d+}
    Verify in UECtxSetupResp_${num} out of ${all} has sCellFailedTBStpList with ${s} elements, PLMN-"0x134198", start NRCellID-${n} for gNB${id}

Verify that UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} is with expected content for PSCELL and no SCells for gNB${gnb_id:\d+} with ${drb:\d+} DRB
    Verify in UECtxSetupReq_${msg_num} out of ${all} that ServCellIndex eq 1 for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that ue-CapabilityInfo is present for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that cg-ConfigInfo contains candidateCellInfoListMN for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that bandCombinationIndex eq 3, allowedFeatureSetsList has 1 elem for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that PSCell PLMN-"0x134198" and NRCellID-16386 for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that SCell-ToBeSetup-Item is not present for gNB${gnb_id}
    Verify in UEContextSetupRequest_${msg_num} out of ${all} that ${drb} DRB is set according to E1AP for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that uLUEConfiguration eq 'shared' for gNB${gnb_id}

Verify that UECtxSetupResp_${num:\d+} out of ${all:\d+} for ${pdu_id:\d+} PDU session has ${drb:\d+} DRB and no SCells for gNB${id:\d+}
    Verify in UECtxSetupResp_${num} out of ${all} that CellGroupID eq 1 for gNB${id}
    Verify in UECtxSetupResp_${num} out of ${all} servCellIndex 1, 2 MIMO in UL and 2 MIMO in DL for gNB${id}
    Verify in UECtxSetupResp_${num} out of ${all} that sCellToAddModList is not present for gNB2
    Verify in UECtxSetupResp_${num} out of ${all} that SCell-FailedtoSetup-List is not present for gNB2
    Verify in UECtxSetupResp_${num} out of ${all} SelectedBandCombinationIndex=3, SelectedFeatureSetEntryIndex=1 for gNB${id}
    Verify in UEContextSetupResponse_${num} out of ${all} that ${drb} DRB is set according to E1AP for gNB${id}
    Verify in UECtxSetupResp_${num} out of ${all} that gTPTunnel is present for gNB${id}

Verify in UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} that ue-CapabilityInfo is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

   Verify That Message Fulfills Query
    ...     ue-CapabilityInfo is present
    ...     message_alias=UEContextSetupRequest${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} that cg-ConfigInfo contains candidateCellInfoListMN for gNB${gnb_id}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

   Verify That Message Fulfills Query
    ...     ((cg-ConfigInfo is present) and (candidateCellInfoListMN is present))
    ...     message_alias=UEContextSetupRequest${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq_${num:\d+} out of ${all:\d+} that bandCombinationIndex eq ${b:\d+}, allowedFeatureSetsList has ${n:\d+} elem for gNB${id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${num}

    Verify That Message Fulfills Query
    ...     (bandCombinationIndex eq ${b})
    ...     and
    ...     (length(allowedFeatureSetsList) eq ${n})
    ...     message_alias=UEContextSetupRequest${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} that ServCellIndex eq ${serv_cell:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     ServCellIndex eq ${serv_cell}
    ...     message_alias=UEContextSetupRequest${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} that PLMN-${PLMN:\S+} and NRCellID-${nrcell_id:\d+} for gNB${gnb_id:\d+} are present
    ${nrcell_id_bin}   Convert to binary    ${nrcell_id}    prefix=0b	length=36
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     pLMN-Identity eq ${PLMN}
    ...     message_alias=UEContextSetupRequest_${msg_num}
    ...     flow_alias=${flow_alias}

     Verify That Message Fulfills Query
    ...     nRCellIdentity eq "${nrcell_id_bin}"
    ...     message_alias=UEContextSetupRequest_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} that PSCell PLMN-${PLMN:\S+} and NRCellID-${nrcell_id:\d+} for gNB${gnb_id:\d+}
    ${nrcell_id_bin}   Convert to binary    ${nrcell_id}    prefix=0b	length=36
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     NRCGI contains ((pLMN-Identity eq ${PLMN}) and (nRCellIdentity eq "${nrcell_id_bin}"))
    ...     message_alias=UEContextSetupRequest${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq_${num:\d+} out of ${all:\d+} that ${s:\d+}-SCells with PLMN-${PLMN:\S+}, starting NRCellID-${nrcell:\d+} for gNB${id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${id}
    ...     protocol=F1AP

    ${expectation_1}=    KeywordsCB008717.Build Query For SCellToBeSetup With Given Number Of Scells And PLMN And NRCellId
    ...     num_of_scells=${s}
    ...     plmn=${PLMN}
    ...     starting_nrcellidentity=${nrcell}

    ${suffix}=    Set Index    all=${all}    msg_index=${num}

    Verify That Message Fulfills Query
    ...     ${expectation_1}
    ...     message_alias=UEContextSetupRequest${suffix}
    ...     flow_alias=${flow_alias}

    ${expectation_2}=    KeywordsCB008717.Build Query For SCellToBeSetup With Given Number Of Scells And SCellULConfigured
    ...     num_of_scells=${s}

    Verify That Message Fulfills Query
    ...     ${expectation_2}
    ...     message_alias=UEContextSetupRequest${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp_${num} out of ${all} has sCellFailedTBStpList with ${s} elements, PLMN-${PLMN:\S+}, start NRCellID-${n:\d+} for gNB${id:\d+}
   ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${id}
    ...     protocol=F1AP

    ${expectation}=    KeywordsCB008717.Build Query For SCellFailed With Given Number Of Scells And PLMN And NRCellId And Cause
    ...     num_of_scells=${s}
    ...     plmn=${PLMN}
    ...     starting_nrcellid=${n}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=UEContextSetupResponse_${num}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq_${num:\d+} out of ${all:\d+} that SCell-ToBeSetup-Item is not present for gNB${id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${num}

    Verify That Message Fulfills Query
    ...     SCell-ToBeSetup-Item is not present
    ...     message_alias=UEContextSetupRequest${suffix}
    ...     flow_alias=${flow_alias}

Verify in ${msg_name:\S+}_${msg_num:\d+} out of ${all:\d+} that ${drb_num:\d+} DRB is set according to E1AP for gNB${gnb_id:\d+}
    ${drb_container_name}=    Set variable if    '${msg_name}'=='UEContextSetupRequest'
    ...    DRBs-ToBeSetup-List    DRBs-Setup-List
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     length(${drb_container_name}) eq ${drb_num}
    ...     message_alias=${msg_name}${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} that uLUEConfiguration eq ${ulue_conf:\S+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     uLUPTNLInformation is present
    ...     message_alias=UEContextSetupRequest${suffix}
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     uLConfiguration contains (uLUEConfiguration eq ${ulue_conf})
    ...     message_alias=UEContextSetupRequest${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp_${msg_num:\d+} out of ${all:\d+} that CellGroupID eq ${cellgroup_id:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     cellGroupId eq ${cellgroup_id}
    ...     message_alias=UEContextSetupResponse${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp_${num:\d+} out of ${all:\d+} servCellIndex ${serv:\d+}, ${m_ul:\d+} MIMO in UL and ${m_dl:\d+} MIMO in DL for gNB${id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${num}

    Verify That Message Fulfills Query
    ...     spCellConfig contains ((servCellIndex eq ${serv})
    ...     and
    ...     (pusch-ServingCellConfig contains (maxMIMO-Layers eq ${m_ul}))
    ...     and
    ...     (pdsch-ServingCellConfig contains (maxMIMO-Layers eq ${m_dl})) )
    ...     message_alias=UEContextSetupResponse${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp_${num:\d+} out of ${all:\d+} SelectedBandCombinationIndex=${b:\d+}, SelectedFeatureSetEntryIndex=${set:\d+} for gNB${id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${id}
    ...     protocol=F1AP

    ${hex_band_combination}=  generate_ASN1_octetsting  ${b}  4
    ${hex_feature_set_index}=  generate_ASN1_octetsting  ${set}  2

    ${suffix}=    Set Index    all=${all}    msg_index=${num}

    Verify That Message Fulfills Query
    ...     SelectedBandCombinationIndex eq ${hex_band_combination}
    ...     and
    ...     SelectedFeatureSetEntryIndex eq ${hex_feature_set_index}
    ...     message_alias=UEContextSetupResponse${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp_${msg_num:\d+} out of ${all:\d+} that gTPTunnel is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     (gTP-TEID is present) and (transportLayerAddress is present)
    ...     message_alias=UEContextSetupResponse${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp_${msg_num:\d+} out of ${all:\d+} contains sCellToAddModList with ${s:\d} elements and MIMO-${mimo:\d} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${expectation}=    KeywordsCB008717.Build Query For SCellToAddModList With Given Number Of Scells And Mimo
    ...     num_of_scells=${s}
    ...     mimo=${mimo}

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=UEContextSetupResponse${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp_${msg_num:\d+} out of ${all:\d+} that sCellToAddModList is not present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     sCellToAddModList is not present
    ...     message_alias=UEContextSetupResponse_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp_${msg_num:\d+} out of ${all:\d+} that SCell-FailedtoSetup-List is not present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     SCell-FailedtoSetup-List is not present
    ...     message_alias=UEContextSetupResponse_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp_${num} out of ${all:\d+} contains ${m_dl:\d+} MIMO in DL for SCell-${scell:\d+} for gNB${id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${id}
    ...     protocol=F1AP

   Verify That Message Fulfills Query
    ...    sCellToAddModList  contains (
    ...    (sCellIndex eq ${scell})
    ...    and
    ...    (sCellConfigDedicated contains (pdsch-ServingCellConfig contains (maxMIMO-Layers eq ${m_dl})))
    ...    and
    ...    (uplinkConfig is not present))
    ...    message_alias=UEContextSetupResponse_${num}
    ...    flow_alias=${flow_alias}

Get SN GNB-CU-UE-F1AP-ID From UeCtxSetupRequest_${msg_num:\d+} out of ${all:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set variable if    ${all}==1    ${EMPTY}    _${msg_num}

    ${SN_gnb_id}=    Get Values Of Parameter From Message Flow    flow_alias=${flow_alias}
    ...     message_alias=UEContextSetupRequest${suffix}   parameter_name=GNB-CU-UE-F1AP-ID
    [Return]    ${SN_gnb_id}

Verify A${meas_nr} measurement report configuration in UEContextSetupRequest for gNB${gnb_id:\d+}
        ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    KeywordsCB008717.Verify If MeasConfig Contains
    ...     flow_alias=${flow_alias}
    ...     message_alias=UEContextSetupRequest
    ...     field=eventA${meas_nr}
    ...     value=is present

Verify that UECtxSetupReq_${msg_num:\d+} out of ${all:\d+} is with expected content for PSCELL for gNB${gnb_id:\d+} with ${drb:\d+} DRB
    Verify in UECtxSetupReq_${msg_num} out of ${all} that ServCellIndex eq 1 for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that PSCell PLMN-"0x134198" and NRCellID-16386 for gNB${gnb_id}
    Verify in UECtxSetupReq_${msg_num} out of ${all} that SCell-ToBeSetup-Item is not present for gNB${gnb_id}
    Verify in UEContextSetupRequest_${msg_num} out of ${all} that ${drb} DRB is set according to E1AP for gNB${gnb_id}

Verify that UECtxSetupResp_${num:\d+} out of ${all:\d+} for ${pdu_id:\d+} PDU session has ${drb:\d+} DRB for gNB${id:\d+}
    Verify in UECtxSetupResp_${num} out of ${all} that CellGroupID eq 1 for gNB${id}
    Verify in UECtxSetupResp_${num} out of ${all} servCellIndex 1, 2 MIMO in UL and 2 MIMO in DL for gNB${id}
    Verify in UEContextSetupResponse_${num} out of ${all} that ${drb} DRB is set according to E1AP for gNB${id}


Verify in UECtxSetupReq_${n:\d+} out of ${a:\d+} that PSCell PLMN-${p:\S+} and NRCellID-${nrc:\d+} servCellIndex ${s:\d+} for gNB${id:\d+} with 1 DRB
    ${nrcell_id_bin}   Convert to binary    ${nrc}    prefix=0b	length=36
    ${flow_alias}=     Get flow name
    ...     procedure=${a}*uEContextSetup
    ...     device=gNB${id}
    ...     protocol=F1AP
    ${suffix}=    Set Index    all=${a}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     NRCGI contains (pLMN-Identity eq ${p}) and (nRCellIdentity eq "${nrcell_id_bin}")
    ...     and (ServCellIndex eq ${s})
    ...     and (length(DRBs-ToBeSetup-List) eq 1)
    ...     message_alias=UEContextSetupRequest${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp_${num:\d+} out of ${all:\d+} that CellGroupID eq ${cellgroup_id:\d+} & servCellId eq ${serv:\d+} for gNB${id:\d+} with 1 DRB
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextSetup
    ...     device=gNB${id}
    ...     protocol=F1AP
    ${suffix}=    Set Index    all=${all}    msg_index=${num}

    Verify That Message Fulfills Query
    ...     spCellConfig contains (servCellIndex eq ${serv})
    ...     and (cellGroupId eq ${cellgroup_id})
    ...     and (length(DRBs-Setup-List) eq 1)
    ...     message_alias=UEContextSetupResponse${suffix}
    ...     flow_alias=${flow_alias}
