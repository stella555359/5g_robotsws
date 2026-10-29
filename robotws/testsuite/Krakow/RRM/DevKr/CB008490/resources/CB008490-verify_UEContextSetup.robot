*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Michal Szymakowski 	<michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     CB008490.py
Library     ../../CB008717/resources/CB8717.py

*** Variables ***

*** Keywords ***
##### UEContextSetupRequest keywords #####
Verify in UEContextSetupRequest that id-SpCell-ID and NRCGI and nRCellIdentity is present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    # id-SpCell-ID (id:63) value: NRCGI
    ...     protocolIEs contains (id eq 63) and NRCGI is present and NRCGI contains (nRCellIdentity is present)
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupRequest that uLUPTNLInformation-ToBeSetup-List has 1 element for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     length(uLUPTNLInformation-ToBeSetup-List) eq 1
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupRequest that uLConfiguration contains uLUEConfiguration is no-data for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     uLConfiguration contains (uLUEConfiguration eq "no-data")
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupRequest that DLPDCPSNLength is 18bits and ULPDCPSNLength is 18bits for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    verify_UEContextSetupRequest_DLPDCPSNLength_ULPDCPSNLength    flow_alias=${flow_alias}    message_alias=UEContextSetupRequest

Verify that UEContextSetupRequest contains nRCellIdentity of PSCell NRCELL-${cell_id:\d+} for SN gNB${gnb_id:\d+}
    [Documentation]    To calculate 36 bit length nRCellIdentity following parameters are needed:
    ...                  - NRBTS.nrBtsId
    ...                  - NRBTS.gNbIdLength
    ...                  - NRBTS.NRCELL.lcrId
    ...                 For example, nrBtsId=3. gNbIdLength=22, lcrId=2:
    ...                   0000 0000 0000 0000 0000 11|00 0000 0000 0010 -> in decimal = 49154

    ${lcrid}=    Get object attributes    NRCELL-${cell_id}    lcrId   bts_id=2

    ${nRCellIdentity_hex}=    Evaluate  ${lcrid['lcrid']} + 49152
    ${nRCellIdentity_bin}=    Convert To Binary    ${nRCellIdentity_hex}  prefix=0b  length=36

    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     nRCellIdentity eq "${nRCellIdentity_bin}"
    ...     message_alias=UEContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupRequest ${drbs:\d+} DRBs in DRBs-ToBeSetup-List for SN gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_drbs_in_UEContextSetupRequest    ${flow_alias}    UEContextSetupRequest    ${drbs}

Verify in UEContextSetupRequest candidateCellInfoListMN for SN gNB${gnb_id:\d+}
    ${flow_alias_XNAP}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb_id}
    ...     protocol=XNAP
    ${flow_alias_F1AP}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    compare_candidateCellInfoListMN
    ...    ${flow_alias_XNAP}    SNodeAdditionRequest
    ...    ${flow_alias_F1AP}    UEContextSetupRequest

##### UEContextSetupResponse keywords #####
Verify in UEContextSetupResponse that DUtoCURRCInformation contains CellGroupConfig with cellGroupId 1 for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DUtoCURRCInformation contains (CellGroupConfig contains (cellGroupId eq 1))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupResponse that CellGroupConfig contains rlc-BearerToAddModList and logicalChannelIdentity is 4 for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DUtoCURRCInformation contains (CellGroupConfig contains ((length(rlc-BearerToAddModList) eq 1) and (logicalChannelIdentity eq 4)))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupResponse in rlc-BearerToAddModList logicalChannelIdentity eq [${lcids}] for SN gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_lcids_in_rlc_BearerToAddModList    ${flow_alias}    UEContextSetupResponse    ${lcids}

Verify in UEContextSetupResponse that CellGroupConfig contains mac-CellGroupConfig and physicalCellGroupConfig SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DUtoCURRCInformation contains (CellGroupConfig contains ((mac-CellGroupConfig is present) and (physicalCellGroupConfig is present)))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig and servCellIndex is present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DUtoCURRCInformation contains (CellGroupConfig contains (spCellConfig contains (servCellIndex is present)))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupResponse that CellGroupConfig contains spCellConfig contains spCellConfigCommon and physCellId is ${pci} for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DUtoCURRCInformation contains (CellGroupConfig contains (spCellConfig contains (reconfigurationWithSync contains
    ...     (spCellConfigCommon contains (physCellId eq ${pci})))))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupResponse contains cellGroupConfig and cfra is not present for SN gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DUtoCURRCInformation contains ((CellGroupConfig is present) and (cellGroupConfig contains (cfra is not present)))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupResponse contains cellGroupConfig and cfra is present for SN gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DUtoCURRCInformation contains ((CellGroupConfig is present) and (cellGroupConfig contains (cfra is present)))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupResponse that iE-Extensions contains SelectedBandCombinationIndex and SelectedFeatureSetIndex is present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DUtoCURRCInformation contains
    ...     ((iE-Extensions contains ((extensionValue contains (SelectedBandCombinationIndex is present)))) and
    ...     (iE-Extensions contains ((extensionValue contains (SelectedFeatureSetEntryIndex is present)))))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupResponse that DRBs-Setup-List has 1 element and dRBID is 4 for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     length(DRBs-Setup-List) eq 1 and DRBs-Setup-List contains (dRBID eq 4)
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupResponse that DRBs-Setup-List contains dLUPTNL-Information-ToBeSetup-List dLUPTNLInformation is present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DRBs-Setup-List contains (DRBs-Setup-Item contains
    ...     ((length(dLUPTNLInformation-ToBeSetup-List ) eq 1) and (dLUPTNLInformation is present)))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in UEContextSetupResponse ${drbs:\d+} DRBs in DRBs-Setup-List for SN gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    verify_drbs_in_DRBs_Setup_List    ${flow_alias}    UEContextSetupResponse    ${drbs}

Verify in UEContextSetupResponse that CellGroupConfig contains pusch maxMIMO-Layers is ${ul}, pdsch maxMIMO-Layers is ${dl} for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DUtoCURRCInformation contains (CellGroupConfig contains (spCellConfig contains (spCellConfigDedicated contains
    ...     ((pusch-ServingCellConfig contains (setup contains (maxMIMO-Layers eq ${ul}))) and
    ...     (pdsch-ServingCellConfig contains (setup contains (maxMIMO-Layers eq ${dl})))))))
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

##### UEContextSetupFailure keywords #####
Verify that UEContextSetupFailure contains cause:${cause_group:\S+}:${cause:\S+} for SN gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetupFailure
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=UEContextSetupFailure
    ...     flow_alias=${flow_alias}

Verify that UEContextSetupRequest ${status:(contains|contains no)} A2,A3,A5 measurements
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    ${state} =  Evaluate    '${status}' == 'contains'
    ${query} =  Set Variable If    ${state}  present  not present

    verify_if_measConfig_contains  ${flow_alias}    UEContextSetupRequest    eventA2    is ${query}
    verify_if_measConfig_contains  ${flow_alias}    UEContextSetupRequest    eventA3    is ${query}
    verify_if_measConfig_contains  ${flow_alias}    UEContextSetupRequest    eventA5    is ${query}

Verify that UEContextSetupRequest ${status:(contains|contains no)} A3,A5 measurements
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    ${state} =  Evaluate    '${status}' == 'contains'
    ${query} =  Set Variable If    ${state}  present  not present

    verify_if_measConfig_contains  ${flow_alias}    UEContextSetupRequest    eventA3    is ${query}
    verify_if_measConfig_contains  ${flow_alias}    UEContextSetupRequest    eventA5    is ${query}

Verify that UEContextSetupRequest ${status:(contains|contains no)} A2 measurements
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    ${state} =  Evaluate    '${status}' == 'contains'
    ${query} =  Set Variable If    ${state}  present  not present

    verify_if_measConfig_contains  ${flow_alias}    UEContextSetupRequest    eventA2    is ${query}

Verify that UEContextSetupRequest contains ${meas_num:\d+} measurements in total
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

   verify_length_of_IE_in_measConfig    ${flow_alias}    UEContextSetupRequest    reportConfigToAddModList    ${meas_num}
   verify_length_of_IE_in_measConfig    ${flow_alias}    UEContextSetupRequest    measIdToAddModList    ${meas_num}
