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

*** Keywords ***
Verify in ${num:\d+} out of ${all:\d+} that UECtxModReq ue-CapabilityInfo is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

   Verify That Message Fulfills Query
    ...     ue-CapabilityInfo is present
    ...     message_alias=UEContextModificationRequest_${num}
    ...     flow_alias=${flow_alias}

Verify in ${num:\d+} out of ${all:\d+} that UECtxModReq BandCombinationIndex: ${band:\d+} and allowedFeatureSetsList: ${set:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     (bandCombinationIndex eq ${band})
    ...     and
    ...     (allowedFeatureSetsList contains (${set}))
    ...     message_alias=UEContextModificationRequest_${num}
    ...     flow_alias=${flow_alias}

Verify that in ${num:\d+} out of ${all:\d+} UECtxModResp ${mimo_ul:\d+} MIMO in UL and ${mimo_dl:\d+} MIMO in DL for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     (pusch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo_ul}))
    ...     and
    ...     (pdsch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo_dl}))
    ...     message_alias=UEContextModificationResponse_${num}
    ...     flow_alias=${flow_alias}

Verify that in ${num:\d+} out of ${all:\d+} UECtxModReq was success for gNB${gnb_id:\d+}
    Verify in ${num} out of ${all} that UECtxModReq ue-CapabilityInfo is present for gNB${gnb_id}
    Verify in ${num} out of ${all} that UECtxModReq BandCombinationIndex: 1 and allowedFeatureSetsList: 1 for gNB${gnb_id}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} does not contain measGapConfig for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     measGapConfig is not present
    ...     message_alias=UEContextModificationRequest_${msg_num}
    ...     flow_alias=${flow_alias}

Verify that UEContextModificationResponse_${msg_num:\d+} of ${all:\d+} does not contain measGapConfig for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     measGapConfig is not present
    ...     message_alias=UEContextModificationResponse_${msg_num}
    ...     flow_alias=${flow_alias}

Verify that UEContextModificationResponse_${msg_num:\d+} of ${all:\d+} contains measGapConfig for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     measGapConfig is present
    ...     message_alias=UEContextModificationResponse_${msg_num}
    ...     flow_alias=${flow_alias}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains RRCReconfigurationCompleteIndicator=${value:\S+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     RRCReconfigurationCompleteIndicator eq '${value}'
    ...     message_alias=UEContextModificationRequest_${msg_num}
    ...     flow_alias=${flow_alias}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains measConfig related to PCell and band ${band:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

# TODO
#    Verify That Message Fulfills Query
#    ...     measConfig contains (measObjectToAddModList contains ((measObjectId eq 1) and (ssbFrequency eq 633312) and (freqBandIndicatorNR eq 78)))
##    ...     and length(measObjectToAddModList) eq 1
#    ...     message_alias=UEContextModificationRequest_${msg_num}
#    ...     flow_alias=${flow_alias}

    ${ssbFreq}=    Set Variable If   ${band}==66    425070    633312

    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  measObjectId  1
    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  ssbFrequency  ${ssbFreq}
    verify_if_measConfig_contains  ${flow_alias}  UEContextModificationRequest_${msg_num}  freqBandIndicatorNR  ${band}

Verify that UEContextModificationRequest_${msg_num:\d+} of ${all:\d+} contains DRXCycle for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     DRXCycle is present
    ...     message_alias=UEContextModificationRequest_${msg_num}
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     DRXCycle contains ('ms160')
    ...     message_alias=UEContextModificationRequest_${msg_num}
    ...     flow_alias=${flow_alias}

Verify that UEContextModificationResponse_${msg_num:\d+} of ${all:\d+} contains drx-Config eq ${value:\S+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     drx-Config contains ('${value}')
    ...     message_alias=UEContextModificationResponse_${msg_num}
    ...     flow_alias=${flow_alias}

Verify that A2,A3,A5 measurements are deactivated in ${msg:\d+} out of ${all:\d+} UEContextModificationRequest message
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

   verify_length_of_IE_in_measConfig    ${flow_alias}    UEContextModificationRequest_${msg}    reportConfigToRemoveList    3
   verify_length_of_IE_in_measConfig    ${flow_alias}    UEContextModificationRequest_${msg}    measIdToRemoveList    3

Verify that A4 measurements are ${status:(configured|not configured)} in ${msg:\d+} out of ${all:\d+} UEContextModificationRequest message
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${state} =  Evaluate    '${status}' == 'configured'
    ${query} =  Set Variable If    ${state}  present  not present

    verify_if_measConfig_contains    ${flow_alias}    UEContextModificationRequest_${msg}    eventA4    is ${query}


Verify that A2/A3/A5 measurements are ${status:(configured|not configured)} in ${msg:\d+} out of ${all:\d+} UEContextModificationRequest message
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${state} =  Evaluate    '${status}' == 'configured'
    ${query} =  Set Variable If    ${state}  present  not present

    verify_if_measConfig_contains    ${flow_alias}    UEContextModificationRequest_${msg}    eventA2    is ${query}
    verify_if_measConfig_contains    ${flow_alias}    UEContextModificationRequest_${msg}    eventA3    is ${query}
    verify_if_measConfig_contains    ${flow_alias}    UEContextModificationRequest_${msg}    eventA5    is ${query}

Verify that measurements are not configured in ${msg:\d+} out of ${all:\d+} UEContextModificationRequest message
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     measConfig is not present
    ...     message_alias=UEContextModificationRequest_${msg}
    ...     flow_alias=${flow_alias}
