*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Cezary Dudek <cezary.dudek@nokia.com>
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Tomasz Pyrek <michal.szymakowski@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB008379-common_keywords.robot
Library     hex_container.py

*** Keywords ***
Verify in NGAP that default nonGBR and 5QI${5qi:\d+} QoS flows were requested during interRAT HO for UE${ue_id:\d+}
    [Documentation]   This keyword is used for 5G-> LTE verififcation, relies on simulated AP response.
    ${hoResAlloc}=    Get flow name
    ...     procedure=handoverResourceAllocation
    ...     device=AMF1

    ${hoPrep}=    Get flow name
    ...     procedure=handoverPreparation
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (fiveQI contains (5, ${5qi}))
    ...     and
    ...     length(QosFlowSetupRequestList) eq 2
    ...     message_alias=HandoverRequest
    ...     flow_alias=${hoResAlloc}

    Verify That Message Fulfills Query
    ...     length(qosFlowSetupResponseList) eq 2
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${hoResAlloc}

    Verify That Message Fulfills Query
    ...     (HandoverType eq "fivegs-to-eps")
    ...     and
    ...     (radioNetwork eq "ng-inter-system-handover-triggered" or radioNetwork eq "time-critical-handover")
    ...     message_alias=HandoverRequired
    ...     flow_alias=${hoPrep}
#   Not included by AP response during HO, but it is not a matter of test to verify AP responses
#    Verify That Message Fulfills Query
#    ...     (HandoverType eq "fivegs-to-eps")
#    ...     and
#    ...     length(qosFlowToBeForwardedList) eq 2
#    ...     message_alias=HandoverCommand
#    ...     flow_alias=${hoPrep}

Verify handover preparation failure during interRAT HO for UE${ue_id:\d+}
    ${handoverPreparation_flow}=    Get flow name
    ...     procedure=handoverPreparationFailure
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (HandoverType eq "fivegs-to-eps")
    ...     and
    ...     (radioNetwork eq "ng-inter-system-handover-triggered" or radioNetwork eq "time-critical-handover")
    ...     message_alias=HandoverRequired
    ...     flow_alias=${handoverPreparation_flow}

    Verify That Message Fulfills Query
    ...     (Cause contains (misc eq 'unspecified'))
    ...     message_alias=HandoverPreparationFailure
    ...     flow_alias=${handoverPreparation_flow}

Verify handover preparation failure during incoming interRAT HO with cause=${cause}
    ${flow_alias}=    Get flow name
    ...     procedure=handoverPreparationFailure
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq "${cause}")
    ...     message_alias=HandoverPreparationFailure
    ...     flow_alias=${flow_alias}

Verify in NGAP that default nonGBR and 5QI${5qi:\d+} QoS flows were requested during interRAT HO from LTE to 5G for UE${ue_id:\d+}
    ${hoResAlloc}=    Get flow name
    ...     procedure=handoverResourceAllocation
    ...     device=AMF1

    ${hoPrep}=    Get flow name
    ...     procedure=handoverPreparation
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     ((HandoverType eq "eps-to-5gs")
    ...     and
    ...     (radioNetwork eq "ng-inter-system-handover-triggered" or radioNetwork eq "time-critical-handover"))
    ...     message_alias=HandoverRequired
    ...     flow_alias=${hoPrep}

    Verify That Message Fulfills Query
    ...     ((length(QosFlowSetupRequestList) eq 2)
    ...     and
    ...     (fiveQI contains (5, ${5qi}))
    ...     and
    ...     (HandoverType eq "eps-to-5gs"))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${hoResAlloc}

    Verify That Message Fulfills Query
    ...     length(qosFlowSetupResponseList) eq 2
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${hoResAlloc}

    Verify That Message Fulfills Query
    ...     (HandoverType eq "eps-to-5gs")
    ...     and
    ...     length(qosFlowToBeForwardedList) eq 2
    ...     message_alias=HandoverCommand
    ...     flow_alias=${hoPrep}

Set expected call flow for UE${ue_id} inter-gNB handover from gNB${src_gnb} to gNB${tgt_gnb}
    EXPECT FLOW: gNB3_XN XNAP handoverPreparation,sNStatusTransfer
    EXPECT FLOW: UE_${ue_id}  NR-RRC RRCReconfigurationComplete
    EXPECT FLOW: AMF1 NGAP pathSwitchRequest

Verify that handoverRequest message contains pdu session with default and 5QI${5qi_gbr:\d+} QoS flow for UE${ue_id:\d+}
    ${flow_alias}=  Get Flow Name
    ...     procedure=handoverPreparation,sNStatusTransfer
    ...     device=gNB3_XN

    Verify That Message Fulfills Query
    ...     ((length(pduSessionResourcesToBeSetup-List) eq 1)
    ...     and
    ...     (qosFlowsToBeSetup-List contains (fiveQI eq 5))
    ...     and
    ...     (qosFlowsToBeSetup-List contains (fiveQI eq ${5qi_gbr}))
    ...     and
    ...     (length(sourceDRBtoQoSFlowMapping) eq 2))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (length(qosFlowsAdmitted-List) eq 2)
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify data forwarding during successfull XN Handover for UE${ue_id:\d+}
    ${handoverPreparation_flow_alias}=  Get Flow Name
    ...     procedure=handoverPreparation,sNStatusTransfer
    ...     device=gNB3_XN

    ${pathSwitch_flow_alias}=  Get Flow Name
    ...     procedure=pathSwitchRequest
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (dataforwardinginfofromSource contains (length(qosFlowsToBeForwarded) eq 2))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${handoverPreparation_flow_alias}

    Verify That Message Fulfills Query
    ...     ((dataForwardingInfoFromTarget contains (length(qosFlowsAcceptedForDataForwarding-List) eq 2))
    ...     and
    ...     (length(dataForwardingResponseDRBItemList) eq 2))
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${handoverPreparation_flow_alias}

Verify that XNAP Inter-gNB Handover was completed successfully for UE${ue_id:\d+} with 5QI1, 5QI5 and 5QI${5qi_id:\d+} QoS flows
    PASS FLOW[timeout=10]: gNB3_XN XNAP handoverPreparation,sNStatusTransfer
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest

    ${flow_alias}=  Get Flow Name
    ...     procedure=handoverPreparation,sNStatusTransfer
    ...     device=gNB3_XN

    Verify That Message Fulfills Query
    ...     ((length(pduSessionResourcesToBeSetup-List) eq 1)
    ...     and
    ...     (qosFlowsToBeSetup-List contains (fiveQI eq 5))
    ...     and
    ...     (qosFlowsToBeSetup-List contains (fiveQI eq 1))
    ...     and
    ...     (qosFlowsToBeSetup-List contains (fiveQI eq ${5qi_gbr}))
    ...     and
    ...     (length(sourceDRBtoQoSFlowMapping) eq 3))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourcesAdmitted-List) eq 1)
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify that PathSwitchRequest contains ${num_qos} QoS flows for UE${ue_id:\d+}
    ${flow_alias}=  Get Flow Name
    ...     procedure=pathSwitchRequest
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceToBeSwitchedDLList) eq 1)
    ...     and
    ...     (length(qosFlowAcceptedList) eq ${num_qos}))
    ...     message_alias=PathSwitchRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceSwitchedList) eq 1)
    ...     message_alias=PathSwitchRequestAcknowledge
    ...     flow_alias=${flow_alias}

Verify that pdu session with default and 5QI${5qi_gbr:\d+} QoS flow during NG Handover for UE${ue_id:\d+}
    ${flow_alias_handoverPreparation}=  Get Flow Name
    ...     procedure=handoverPreparation
    ...     device=AMF1

    ${flow_alias_handoverResourceAllocation}=  Get Flow Name
    ...     procedure=handoverResourceAllocation
    ...     device=AMF1

    ${source_to_target_hex_container}=  Set Variable  SourceToTarget-TransparentContainer
    ${target_to_source_hex_container}=  Set Variable  TargetToSource-TransparentContainer

#    comment: wait for AP CNI (except 5qi-1, 5qi-2 and 5qi-3)
#    ${flow_alias_uplinkRANStatusTransfer}=  Get Flow Name
#    ...     procedure=uplinkRANStatusTransfer
#    ...     device=AMF1
#
#    ${flow_alias_downlinkRANStatusTransfer}=  Get Flow Name
#    ...     procedure=downlinkRANStatusTransfer
#    ...     device=AMF1
#
#    Verify That Message Fulfills Query
#    ...     (length(dRBsSubjectToStatusTransferList) eq 2))
#    ...     message_alias=UplinkRANStatusTransfer
#    ...     flow_alias=${flow_alias_uplinkRANStatusTransfer}
#
#    Verify That Message Fulfills Query
#    ...     (length(dRBsSubjectToStatusTransferList) eq 2))
#    ...     message_alias=DownlinkRANStatusTransfer
#    ...     flow_alias=${flow_alias_uplinkRANStatusTransfer}

    verify_number_of_elements_in_dRBsToQosFlowsMappingList_field_inside_hex_container
    ...     flow_alias=${flow_alias_handoverPreparation}
    ...     message_alias=HandoverRequired
    ...     container=${source_to_target_hex_container}
    ...     elements=2

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceListHORqd) eq 1)
    ...     and
#    comment: wait for new messaging version
#    ...     (length(dRBsToQosFlowsMappingList) eq 2)
#    ...     and
    ...     (Cause contains (radioNetwork eq "handover-desirable-for-radio-reason")))
    ...     message_alias=HandoverRequired
    ...     flow_alias=${flow_alias_handoverPreparation}

    verify_number_of_elements_in_dRBsToQosFlowsMappingList_field_inside_hex_container
    ...     flow_alias=${flow_alias_handoverResourceAllocation}
    ...     message_alias=HandoverRequest
    ...     container=${source_to_target_hex_container}
    ...     elements=2

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceSetupListHOReq) eq 1)
    ...     and
#    comment: wait for new messaging version
#    ...     (length(qosFlowInformationList) eq 2)
#    ...     and
#    ...     (length(dRBsToQosFlowsMappingList) eq 2)
#    ...     and
    ...     (QosFlowSetupRequestList contains (fiveQI eq 5))
    ...     and
    ...     (QosFlowSetupRequestList contains (fiveQI eq ${5qi_gbr})))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${flow_alias_handoverResourceAllocation}

    verify_number_of_elements_in_mappedQoSFlowsToAdd_field_inside_hex_container
    ...     flow_alias=${flow_alias_handoverResourceAllocation}
    ...     message_alias=HandoverRequestAcknowledge
    ...     container=${target_to_source_hex_container}
    ...     elements=2

    Verify That Message Fulfills Query
    ...     ((length(qosFlowSetupResponseList) eq 2)
    ...     and
    ...     (length(PDUSessionResourceAdmittedList) eq 1))
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias_handoverResourceAllocation}

    verify_number_of_elements_in_mappedQoSFlowsToAdd_field_inside_hex_container
    ...     flow_alias=${flow_alias_handoverPreparation}
    ...     message_alias=HandoverCommand
    ...     container=${target_to_source_hex_container}
    ...     elements=2

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceHandoverList) eq 1)
    ...     message_alias=HandoverCommand
    ...     flow_alias=${flow_alias_handoverPreparation}

Verify that pdu session with 5QI1, 5QI${5qi_gbr:\d+} and 5QI5 QoS flows during NG Handover for UE${ue_id:\d+}
    ${flow_alias_handoverPreparation}=  Get Flow Name
    ...     procedure=handoverPreparation
    ...     device=AMF1

    ${flow_alias_handoverResourceAllocation}=  Get Flow Name
    ...     procedure=handoverResourceAllocation
    ...     device=AMF1

#    comment: wait for AP CNI (except 5qi-1, 5qi-2 and 5qi-3)
#    ${flow_alias_uplinkRANStatusTransfer}=  Get Flow Name
#    ...     procedure=uplinkRANStatusTransfer
#    ...     device=AMF1
#
#    ${flow_alias_downlinkRANStatusTransfer}=  Get Flow Name
#    ...     procedure=downlinkRANStatusTransfer
#    ...     device=AMF1
#
#    Verify That Message Fulfills Query
#    ...     (length(dRBsSubjectToStatusTransferList) eq 3))
#    ...     message_alias=UplinkRANStatusTransfer
#    ...     flow_alias=${flow_alias_uplinkRANStatusTransfer}
#
#    Verify That Message Fulfills Query
#    ...     (length(dRBsSubjectToStatusTransferList) eq 3))
#    ...     message_alias=DownlinkRANStatusTransfer
#    ...     flow_alias=${flow_alias_uplinkRANStatusTransfer}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceListHORqd) eq 1)
    ...     and
#    comment: wait for new messaging version
#    ...     (length(dRBsToQosFlowsMappingList) eq 3)
#    ...     and
    ...     (Cause contains (radioNetwork eq "handover-desirable-for-radio-reason")))
    ...     message_alias=HandoverRequired
    ...     flow_alias=${flow_alias_handoverPreparation}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceSetupListHOReq) eq 1)
    ...     and
#    comment: wait for new messaging version
#    ...     (length(qosFlowInformationList) eq 3)
#    ...     and
#    ...     (length(dRBsToQosFlowsMappingList) eq 3)
#    ...     and
    ...     (QosFlowSetupRequestList contains (fiveQI eq 5))
    ...     and
    ...     (QosFlowSetupRequestList contains (fiveQI eq 1))
    ...     and
    ...     (QosFlowSetupRequestList contains (fiveQI eq ${5qi_gbr})))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${flow_alias_handoverResourceAllocation}

    Verify That Message Fulfills Query
    ...     ((length(qosFlowSetupResponseList) eq 3)
    ...     and
    ...     (length(PDUSessionResourceAdmittedList) eq 1))
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias_handoverResourceAllocation}

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceHandoverList) eq 1)
    ...     message_alias=HandoverCommand
    ...     flow_alias=${flow_alias_handoverPreparation}

Verify data forwarding during successfull NG Handover for UE${ue_id:\d+}
    ${flow_alias_handoverPreparation}=  Get Flow Name
    ...     procedure=handoverPreparation
    ...     device=AMF1

    ${flow_alias_handoverResourceAllocation}=  Get Flow Name
    ...     procedure=handoverResourceAllocation
    ...     device=AMF1

    ${source_to_target_hex_container}=  Set Variable  SourceToTarget-TransparentContainer
    ${target_to_source_hex_container}=  Set Variable  TargetToSource-TransparentContainer
    ${dlForwarding_value}=  Set Variable  dl-forwarding-proposed

    verify_dlforwarding_field_inside_hex_container
    ...     flow_alias=${flow_alias_handoverPreparation}
    ...     message_alias=HandoverRequired
    ...     container=${source_to_target_hex_container}
    ...     value=${dlForwarding_value}
    ...     occurences=2

    verify_dlforwarding_field_inside_hex_container
    ...     flow_alias=${flow_alias_handoverResourceAllocation}
    ...     message_alias=HandoverRequest
    ...     container=${source_to_target_hex_container}
    ...     value=${dlForwarding_value}
    ...     occurences=2

    Verify That Message Fulfills Query
    ...     ((qosFlowSetupResponseList contains (dataForwardingAccepted eq "data-forwarding-accepted"))
    ...     and
    ...     (dataForwardingResponseDRBList is not present))
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias_handoverResourceAllocation}

Verify data forwarding for 5QI1, 5QI${5qi_gbr:\d+} and 5QI5 during successfull XN Handover for UE${ue_id:\d+}
    ${handoverPreparation_flow_alias}=  Get Flow Name
    ...     procedure=handoverPreparation,sNStatusTransfer
    ...     device=gNB3_XN

    ${pathSwitch_flow_alias}=  Get Flow Name
    ...     procedure=pathSwitchRequest
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (dataforwardinginfofromSource contains (length(qosFlowsToBeForwarded) eq 3))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${handoverPreparation_flow_alias}

    Verify That Message Fulfills Query
    ...     ((dataForwardingInfoFromTarget contains (length(qosFlowsAcceptedForDataForwarding-List) eq 3))
    ...     and
    ...     (length(dataForwardingResponseDRBItemList) eq 3))
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${handoverPreparation_flow_alias}

Verify data forwarding for 5QI1 and 5QI5 during successfull NG Handover for UE${ue_id:\d+}
    ${flow_alias_handoverPreparation}=  Get Flow Name
    ...     procedure=handoverPreparation
    ...     device=AMF1

    ${flow_alias_handoverResourceAllocation}=  Get Flow Name
    ...     procedure=handoverResourceAllocation
    ...     device=AMF1

#    comment: wait for new messaging version
#    Verify That Message Fulfills Query
#    ...     ((qosFlowInformationList contains ((dLForwarding eq "data-forwarding-accepted") and (qosFlowIdentifier eq 1)))
#    ...     and
#    ...     (qosFlowInformationList contains ((dLForwarding eq "data-forwarding-accepted") and (qosFlowIdentifier eq 2))))
#    ...     message_alias=HandoverRequired
#    ...     flow_alias=${flow_alias_handoverPreparation}

#    comment: wait for new messaging version
#    Verify That Message Fulfills Query
#    ...     ((qosFlowInformationList contains ((dLForwarding eq "data-forwarding-accepted") and (qosFlowIdentifier eq 1)))
#    ...     and
#    ...     (qosFlowInformationList contains ((dLForwarding eq "data-forwarding-accepted") and (qosFlowIdentifier eq 2))))
#    ...     message_alias=HandoverRequest
#    ...     flow_alias=${flow_alias_handoverResourceAllocation}

    Verify That Message Fulfills Query
    ...     ((qosFlowSetupResponseList contains ((dataForwardingAccepted eq "data-forwarding-accepted") and (qosFlowIdentifier eq 1)))
    ...     and
    ...     (qosFlowSetupResponseList contains ((dataForwardingAccepted eq "data-forwarding-accepted") and (qosFlowIdentifier eq 2)))
    ...     and
    ...     (dataForwardingResponseDRBList is not present))
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias_handoverResourceAllocation}

#    comment: wait for new messaging version
#    Verify That Message Fulfills Query
#    ...     (length(qosFlowToBeForwardedList) eq 2)
#    ...     message_alias=HandoverCommand
#    ...     flow_alias=${flow_alias_handoverPreparation}

Verify data forwarding for 5QI1, 5QI${5qi_gbr:\d+} and 5QI5 during successfull NG Handover for UE${ue_id:\d+}
    ${flow_alias_handoverPreparation}=  Get Flow Name
    ...     procedure=handoverPreparation
    ...     device=AMF1

    ${flow_alias_handoverResourceAllocation}=  Get Flow Name
    ...     procedure=handoverResourceAllocation
    ...     device=AMF1

#    comment: wait for new messaging version
#    Verify That Message Fulfills Query
#    ...     ((qosFlowInformationList contains ((dLForwarding eq "data-forwarding-accepted") and (qosFlowIdentifier eq 1)))
#    ...     and
#    ...     (qosFlowInformationList contains ((dLForwarding eq "data-forwarding-accepted") and (qosFlowIdentifier eq 2)))
#    ...     and
#    ...     (qosFlowInformationList contains ((dLForwarding eq "data-forwarding-accepted") and (qosFlowIdentifier eq 3))))
#    ...     message_alias=HandoverRequired
#    ...     flow_alias=${flow_alias_handoverPreparation}

#    comment: wait for new messaging version
#    Verify That Message Fulfills Query
#    ...     ((qosFlowInformationList contains ((dLForwarding eq "data-forwarding-accepted") and (qosFlowIdentifier eq 1)))
#    ...     and
#    ...     (qosFlowInformationList contains ((dLForwarding eq "data-forwarding-accepted") and (qosFlowIdentifier eq 2)))
#    ...     and
#    ...     (qosFlowInformationList contains ((dLForwarding eq "data-forwarding-accepted") and (qosFlowIdentifier eq 3))))
#    ...     message_alias=HandoverRequest
#    ...     flow_alias=${flow_alias_handoverResourceAllocation}

    Verify That Message Fulfills Query
    ...     ((qosFlowSetupResponseList contains ((dataForwardingAccepted eq "data-forwarding-accepted") and (qosFlowIdentifier eq 1)))
    ...     and
    ...     (qosFlowSetupResponseList contains ((dataForwardingAccepted eq "data-forwarding-accepted") and (qosFlowIdentifier eq 2)))
    ...     and
    ...     (qosFlowSetupResponseList contains ((dataForwardingAccepted eq "data-forwarding-accepted") and (qosFlowIdentifier eq 3)))
    ...     and
    ...     (dataForwardingResponseDRBList is not present))
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias_handoverResourceAllocation}

#    comment: wait for new messaging version
#    Verify That Message Fulfills Query
#    ...     (length(qosFlowToBeForwardedList) eq 3)
#    ...     message_alias=HandoverCommand
#    ...     flow_alias=${flow_alias_handoverPreparation}

Verify lack of data forwarding during successfull NG Handover for UE${ue_id:\d+}
    ${flow_alias_handoverResourceAllocation}=  Get Flow Name
    ...     procedure=handoverResourceAllocation
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (DataForwardingNotPossible eq "data-forwarding-not-possible")
    ...     message_alias=HandoverRequest
    ...     flow_alias=${flow_alias_handoverResourceAllocation}

    Verify That Message Fulfills Query
    ...     (dataForwardingResponseDRBList is not present)
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias_handoverResourceAllocation}

Verify lack of data forwarding for successfull NG Handover for UE${ue_id:\d+}
    ${flow_alias_handoverResourceAllocation}=  Get Flow Name
    ...     procedure=handoverResourceAllocation
    ...     device=AMF1

    ${flow_alias_handoverPreparation}=  Get Flow Name
    ...     procedure=handoverPreparation
    ...     device=AMF1

#    comment: wait for new messaging version
#    Verify That Message Fulfills Query
#    ...     ((length(qosFlowInformationList) eq 2)
#    ...     and
#    ...     (QosFlowInformationItem contains((qosFlowIdentifier eq 1) and (dlForwarding eq "dl-forwarding-proposed")))
#    ...     and
#    ...     (QosFlowInformationItem contains((qosFlowIdentifier eq 2) and (dlForwarding eq "dl-forwarding-proposed"))))
#    ...     message_alias=HandoverRequest
#    ...     flow_alias=${flow_alias_handoverResourceAllocation}

    Verify That Message Fulfills Query
    ...     (length(dataForwardingResponseDRBList) eq 1)
#    comment: wait for new messaging version
#    ...     and
#    ...     (QosFlowItemWithDataForwarding contains ((qosFlowIdentifier eq 2) and (dlForwarding is not present))))
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${flow_alias_handoverResourceAllocation}

    Verify That Message Fulfills Query
    ...     (length(qosFlowToBeForwardedList) eq 1)
    ...     message_alias=HandoverCommand
    ...     flow_alias=${flow_alias_handoverPreparation}

Verify lack of VoNR data forwarding during successfull XN Handover for UE${ue_id:\d+}
    ${handoverPreparation_flow_alias}=  Get Flow Name
    ...     procedure=handoverPreparation,sNStatusTransfer
    ...     device=gNB3_XN

    ${pathSwitch_flow_alias}=  Get Flow Name
    ...     procedure=pathSwitchRequest
    ...     device=AMF1

    Verify That Message Fulfills Query
    ...     (dataforwardinginfofromSource contains (length(qosFlowsToBeForwarded) eq 2))
    ...     message_alias=HandoverRequest
    ...     flow_alias=${handoverPreparation_flow_alias}

    Verify That Message Fulfills Query
    ...     ((dataForwardingInfoFromTarget contains (length(qosFlowsAcceptedForDataForwarding-List) eq 1))
    ...     and
    ...     (length(dataForwardingResponseDRBItemList) eq 1))
    ...     message_alias=HandoverRequestAcknowledge
    ...     flow_alias=${handoverPreparation_flow_alias}
