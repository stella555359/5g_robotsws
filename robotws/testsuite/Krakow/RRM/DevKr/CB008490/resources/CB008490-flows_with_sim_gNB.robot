*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Michal Szymakowski 	<michal.szymakowski@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

*** Variables ***

*** Keywords ***
Set expected messages flows for SNodeAddition for UE${ue_id:\d+}, MN real gNB${mn_gnb_id:\d+} and SN sim gNB${sn_gnb_id}
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP xnUAddressIndication
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    EXPECT FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer

Verify expected messages flows for SNodeAddition for UE${ue_id:\d+}, MN real gNB${mn_gnb_id:\d+} and SN sim gNB${sn_gnb_id}
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} E1AP 2*bearerContextModification
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} F1AP 2*uEContextModification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} NGAP pDUSessionResourceModifyIndication
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNGRANnodeAdditionPreparation
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP xnUAddressIndication
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNGRANnodeReconfigurationCompletion
    PASS FLOW[timeout=10]: gNB${mn_gnb_id} XNAP sNStatusTransfer
