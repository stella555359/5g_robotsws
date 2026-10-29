*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Adrianna Zenczak <adrianna.zenczak@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     CB8717.py
*** Variables ***
&{FeatureSetEntryIndex}=              '1'="0x00"    '2'="0x02"
&{BandCombinationIndex}=               '1'="0x0000"  '2'="0x0001"  '3'="0x0002"  '4'="0x0003"
*** Keywords ***
Verify in UECtxSetupReq that cg-ConfigInfo is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

   Verify That Message Fulfills Query
    ...     ue-CapabilityInfo is present
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq that bandCombinationIndex: ${bcomb:\d+} , allowedFeatureSetsList: ${num:\d+} for gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     (bandCombinationIndex eq ${bcomb})
    ...     and
    ...     (length(allowedFeatureSetsList) eq ${num})
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq that candidateCellInfoListMN contains ${num:\d+} item for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     length(candidateCellInfoListMN) eq ${num}
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq that ServCellIndex eq ${serv_cell:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     ServCellIndex eq ${serv_cell}
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq that PLMN-${PLMN:\S+} and NRCellID-${nrcell_id:\d+} for gNB${gnb_id:\d+} are present
    ${nrcell_id_bin}   Convert to binary    ${nrcell_id}    prefix=0b	length=36
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     pLMN-Identity eq ${PLMN}
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

     Verify That Message Fulfills Query
    ...     nRCellIdentity eq "${nrcell_id_bin}"
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in ${msg_name:\S+} that ${drb_num:\d+} DRBs set according to E1AP for gNB${gnb_id:\d+}
    ${drb_container_name}=    Set variable if    '${msg_name}'=='UEContextSetupRequest'
    ...    DRBs-ToBeSetup-List    DRBs-Setup-List
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     length(${drb_container_name}) eq ${drb_num}
    ...     message_alias=${msg_name}
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupReq that uLUEConfiguration eq ${ulue_conf:\S+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     uLUPTNLInformation is present
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     uLConfiguration contains (uLUEConfiguration eq ${ulue_conf})
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp that CellGroupID eq ${cellgroup_id:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     cellGroupId eq ${cellgroup_id}
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp that servCellIndex ${serv_cell:\d+}, ${mimo_ul:\d+} MIMO in UL and ${mimo_dl:\d+} MIMO in DL for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     spCellConfig contains ( (servCellIndex eq ${serv_cell})
    ...     and
    ...     (pusch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo_ul}))
    ...     and
    ...     (pdsch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo_dl})) )
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq ${band:\d+}, SelectedFeatureSetEntryIndex eq ${set:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${hex_band_combination}=  set variable  ${BandCombinationIndex}['${band}']      #generate_ASN1_octetsting  ${band}  4
    ${hex_feature_set_index}=  set variable  ${FeatureSetEntryIndex}['${set}']      #generate_ASN1_octetsting  ${set}  2

    Verify That Message Fulfills Query
    ...     SelectedBandCombinationIndex eq ${hex_band_combination}
    ...     and
    ...     SelectedFeatureSetEntryIndex eq ${hex_feature_set_index}
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupResponse that csi-ResourceConfigId: ${res_id:\d+}, SSB-Index: ${ssb:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     csi-ResourceConfigToAddModList contains (csi-ResourceConfigId eq ${res_id}
    ...     and
    ...     csi-SSB-ResourceSetList contains (${ssb}))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UECtxSetupResp that gTPTunnel is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     (gTP-TEID is present) and (transportLayerAddress is present)
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify that UECtxSetupReq PDUSessionID-${pdu:\d+} with ${drb_num:\d+} DRB was success for gNB${gnb_id:\d+}
    Log    Verify that UECtxSetupReq PDUSessionID-${pdu} with ${drb_num} DRB was success for gNB${gnb_id}
    Verify in UECtxSetupReq that cg-ConfigInfo is present for gNB${gnb_id}
    Verify in UECtxSetupReq that bandCombinationIndex: 1 , allowedFeatureSetsList: 1 for gNB${gnb_id}
    Verify in UECtxSetupReq that candidateCellInfoListMN contains 1 item for gNB${gnb_id}
    Verify in UECtxSetupReq that ServCellIndex eq 1 for gNB${gnb_id}
    Verify in UECtxSetupReq that PLMN-"0x134198" and NRCellID-16386 for gNB${gnb_id} are present
    Verify in UEContextSetupRequest that ${drb_num} DRBs set according to E1AP for gNB${gnb_id}
    Verify in UECtxSetupReq that uLUEConfiguration eq 'no-data' for gNB${gnb_id}

Verify UECtxSetupReq for ulDataPath set to ulOverLteNrPrimaryPathOverLte for gNB${gnb_id:\d+}
    Verify in UEContextSetupRequest that 2 DRBs set according to E1AP for gNB${gnb_id}
    Verify in UECtxSetupReq that uLUEConfiguration eq 'shared' for gNB${gnb_id}
    Verify in UECtxSetupReq that uLUEConfiguration eq 'only' for gNB${gnb_id}

Verify UECtxSetupReq for ulDataPath: ulOverLteNrPrimaryPathOverNr, uLUEConfiguration: ${ulc:\S+} for gNB${gnb_id:\d+}
    Verify in UEContextSetupRequest that 1 DRBs set according to E1AP for gNB${gnb_id}
    Verify in UECtxSetupReq that uLUEConfiguration eq ${ulc} for gNB${gnb_id}

Verify that UECtxSetupResp PDUSessionID-${pdu_id:\d+} with ${drb_num:\d+} DRB was success for gNB${gnb_id:\d+}
    Log    Verify that UECtxSetupResp PDUSessionID-${pdu_id} with ${drb_num} DRB was success for gNB${gnb_id}
    Verify in UECtxSetupResp that CellGroupID eq 1 for gNB${gnb_id}
    Verify in UECtxSetupResp that servCellIndex 1, 2 MIMO in UL and 2 MIMO in DL for gNB${gnb_id}
    Verify in UEContextSetupResponse that SelectedBandCombinationIndex eq 1, SelectedFeatureSetEntryIndex eq 1 for gNB${gnb_id}
    Verify in UEContextSetupResponse that ${drb_num} DRBs set according to E1AP for gNB${gnb_id}
    Verify in UECtxSetupResp that gTPTunnel is present for gNB${gnb_id}

Verify in UEContextSetupRequest that allowedBC_ListMRDC includes bandCombinationIndex eq ${bcomb1:\d+} and ${bcomb2:\d+} for gNB${gnb_id:\d+}
     Verify in UEContextSetupRequest that allowedBC-ListMRDC has 2 elem for gNB2
     ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     allowedBC-ListMRDC contains
    ...     ((bandCombinationIndex eq ${bcomb1}), (bandCombinationIndex eq ${bcomb2}))
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupRequest that allowedBC_ListMRDC includes allowedFeatureSetsList with ${list_len:\d+} items for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     (allowedBC-ListMRDC contains
    ...     (length(allowedFeatureSetsList) eq ${list_len}))
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupRequest contains measurement results of PSCell for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     measResultNeighCellListNR contains ((resultsSSB-Cell is present) and (rsIndexResults is present))
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupRequest contains measurement results of PSCell without rsIndexResults for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     measResultNeighCellListNR contains ((resultsSSB-Cell is present) and (rsIndexResults is not present))
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupResponse contains cellGroupConfig and cfra is not present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DUtoCURRCInformation contains ((cellGroupConfig is present) and (cellGroupConfig contains (cfra is not present)))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DUtoCURRCInformation contains ((cellGroupConfig is present) and (cellGroupConfig contains (cfra is present)))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupResponse contains physCellId eq ${pci:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     physCellId eq ${pci}
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupRequest contains physCellId eq ${pci:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     physCellId eq ${pci}
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupRequest contains physCellIds eq ${pci1:\d+} and ${pci2:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     candidateCellInfoListMN contains (physCellId contains (${pci1}) and physCellId contains (${pci2}))
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupRequest that allowedBC-ListMRDC has ${num:\d+} elem for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     (length(allowedBC-ListMRDC) eq ${num})
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-${cell_id:\d+} for gNB${gnb_id:\d+}
    ${nRCellIdentity_hex}=    Evaluate  ${cell_id} + 16384
    ${nRCellIdentity_bin}=    Convert To Binary    ${nRCellIdentity_hex}  prefix=0b  length=36

    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     nRCellIdentity eq "${nRCellIdentity_bin}"
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupFailure that cause ${cause_failure:\S+} is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetupFailure
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq ${cause_failure})
    ...     message_alias=UEContextSetupFailure
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupRequest ${status:(contains|contains no)} A2,A3,A5 measurements for UE${ue_id:\d+} and gNB${gnb_id:\d+}
    Log    Verify that UEContextSetupRequest A2,A3,A5 measurements for UE${ue_id} and gNB${gnb_id}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${state} =  Evaluate    '${status}' == 'contains'
    ${query} =  Set Variable If    ${state}  present  not present

    verify_if_measConfig_contains  ${flow_alias}    UEContextSetupRequest    eventA2    is ${query}
    verify_if_measConfig_contains  ${flow_alias}    UEContextSetupRequest    eventA3    is ${query}
    verify_if_measConfig_contains  ${flow_alias}    UEContextSetupRequest    eventA5    is ${query}
