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


*** Keywords ***
##### PDUSessionResourceModifyIndication keywords #####
Verify in PDUSessionResourceModifyIndication and PDUSessionResourceModifyConfirm are present for MN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=pDUSessionResourceModifyIndication
    ...     device=gNB${gnb}
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     PDUSessionResourceModifyIndication is present
    ...     message_alias=PDUSessionResourceModifyIndication
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     PDUSessionResourceModifyConfirm is present
    ...     message_alias=PDUSessionResourceModifyConfirm
    ...     flow_alias=${flow_alias}

Verify in PDUSessionResourceModifyIndication that associatedQosFlowList contains ${qfi_num} QFIs for MN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=pDUSessionResourceModifyIndication
    ...     device=gNB${gnb}
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     dLQosFlowPerTNLInformation contains (length(associatedQosFlowList) eq ${qfi_num})
    ...     message_alias=PDUSessionResourceModifyIndication
    ...     flow_alias=${flow_alias}

Verify that NGAP PDUSessionResourceModifyResponse contains cause:radioNetwork:ims-voice-eps-fallback-or-rat-fallback-triggered, gNB${gnb}
    Log    Verify that NGAP PDUSessionResourceModifyResponse contains cause:radioNetwork:ims-voice-eps-fallback-or-rat-fallback-triggered, gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=pDUSessionResourceModify
    ...     device=AMF1
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     cause contains (radioNetwork eq 'ims-voice-eps-fallback-or-rat-fallback-triggered')
    ...     message_alias=PDUSessionResourceModifyResponse
    ...     flow_alias=${flow_alias}
