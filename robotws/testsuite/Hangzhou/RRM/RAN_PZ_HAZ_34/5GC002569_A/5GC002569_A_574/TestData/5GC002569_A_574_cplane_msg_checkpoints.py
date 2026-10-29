# -*- coding: utf-8 -*
"""
This file defines the filters for checkpoints of control plane messages triggered during 574 handover scenarios.
"""

xpath_x2ap_SgnbAddReq = 'x2ap//..//x2ap.SgNBAdditionRequest_element'
xpath_x2ap_SgnbAddReqAck = 'x2ap//..//x2ap.SgNBAdditionRequestAcknowledge_element//../nr-rrc.pSCellFrequency'
xpath_x2ap_SgnbReconfigComp = 'x2ap//..//x2ap.SgNBReconfigurationComplete_element'
xpath_x2ap_SgnbModReq = 'x2ap//..//x2ap.SgNBModificationRequest_element'
xpath_x2ap_SgnbModReqAck = 'x2ap//..//x2ap.SgNBModificationRequestAcknowledge_element'
xpath_x2ap_MeasReport = 'x2ap//..//x2ap.RRCTransfer_element//..//nr-rrc.measurementReport_element'
xpath_x2ap_SgnbRelReq = 'x2ap//..//x2ap.SgNBReleaseRequest_element//..//x2ap.UE_ContextKeptIndicator'
xpath_x2ap_SgnbRelReqAck = 'x2ap//..//x2ap.SgNBReleaseRequestAcknowledge_element'
xpath_x2ap_UeCxtRel = 'x2ap//..//x2ap.UEContextRelease_element'
xpath_f1ap_UeCxtSetupReq = 'f1ap//..//f1ap.UEContextSetupRequest_element'
xpath_f1ap_UeCxtSetupResp = 'f1ap//..//f1ap.UEContextSetupResponse_element'
xpath_f1ap_UeCxtModReq = 'f1ap//..//f1ap.UEContextModificationRequest_element'
xpath_f1ap_UeCxtModResp = 'f1ap//..//f1ap.UEContextModificationResponse_element'
xpath_f1ap_UeCxtRelCmd = 'f1ap//..//f1ap.UEContextReleaseCommand_element'
xpath_f1ap_UeCxtRelComp = 'f1ap//..//f1ap.UEContextReleaseComplete_element'
xpath_f1ap_MeasReport = 'f1ap//..//f1ap.ULRRCMessageTransfer_element//..//nr-rrc.measurementReport_element'
xpath_f1ap_RrcReconf = 'f1ap//..f1ap.DLRRCMessageTransfer_element//..//nr-rrc.rrcReconfiguration_element'
xpath_f1ap_RrcReconfComp = 'f1ap//..//f1ap.ULRRCMessageTransfer_element//..//nr-rrc.rrcReconfigurationComplete_element'

xpath_x2ap_HandoverReq = 'x2ap//..//x2ap.HandoverRequest_element'
xpath_x2ap_HandoverReqAck = 'x2ap//..//x2ap.HandoverRequestAcknowledge_element'
xpath_s1ap_PathSwitchReq = 's1ap//..//s1ap.PathSwitchRequest_element'
xpath_s1ap_PathSwitchReqAck = 's1ap//..//s1ap.PathSwitchRequestAcknowledge_element'
xpath_s1ap_UlNASTrans = 's1ap//..//s1ap.UplinkNASTransport_element'
xpath_s1ap_DlNASTrans = 's1ap//..//s1ap.DownlinkNASTransport_element'


INTER_eNB_HO_WO_SGW_CHANGE = [
    xpath_x2ap_SgnbAddReq,
    xpath_x2ap_SgnbAddReqAck,
    xpath_x2ap_SgnbReconfigComp,
    xpath_x2ap_SgnbModReq,
    xpath_x2ap_SgnbModReqAck,
    xpath_x2ap_SgnbAddReq,
    xpath_f1ap_UeCxtModReq,
    xpath_f1ap_UeCxtModResp,
    xpath_x2ap_SgnbAddReqAck,
    xpath_x2ap_SgnbRelReq,
    xpath_x2ap_SgnbRelReqAck,
    xpath_x2ap_SgnbReconfigComp,
    xpath_f1ap_UeCxtModReq,
    xpath_x2ap_UeCxtRel,
]

DETAIL_IE_INTER_eNB_HO_WO_SGW_CHANGE = [
    {'detail_ie_xpath': 'x2ap//..//x2ap.SCGConfigurationQuery',
     'detail_id_showname': 'SCGConfigurationQuery: true (0)',
     'detail_ie_show': '0'
     },
    {'detail_ie_xpath': 'x2ap//..//x2ap.SgNBModificationRequestAcknowledge_element//..//nr-rrc.pSCellFrequency',
     'detail_id_showname': 'pSCellFrequency: 2232667',
     'detail_ie_show': '2232667',
     },
    {'detail_ie_xpath': 'x2ap//..//x2ap.SGNB_Addition_Trigger_Ind',
     'detail_id_showname': 'SGNB-Addition-Trigger-Ind: inter-eNB-HO (1)',
     'detail_ie_show': '1'
     },
    {'detail_ie_xpath': 'f1ap//..//f1ap.UEContextModificationRequest_element//..//f1ap.TransmissionActionIndicator',
     'detail_id_showname': 'TransmissionActionIndicator: stop (0)',
     'detail_ie_show': '0'
     },
    {'detail_ie_xpath': 'x2ap//..//x2ap.SgNBAdditionRequestAcknowledge_element//..//x2ap.RRC_Config_Ind',
     'detail_id_showname': 'RRC-Config-Ind: delta-config (1)',
     'detail_ie_show': '1'
     },
    [
        {'detail_ie_xpath': 'x2ap//..//x2ap.SgNBReleaseRequest_element//..//x2ap.radioNetwork',
         'detail_id_showname': 'radioNetwork: mCG-Mobility (46)',
         'detail_ie_show': '46'},
        {'detail_ie_xpath': 'x2ap//..//x2ap.SgNBReleaseRequest_element//..//x2ap.UE_ContextKeptIndicator',
         'detail_id_showname': 'UE-ContextKeptIndicator: true (0)',
         'detail_ie_show': '0'}
    ]
]


INTER_eNB_HO_WI_SGW_CHANGE = [
    xpath_x2ap_SgnbAddReq,
    xpath_x2ap_SgnbAddReqAck,
    xpath_x2ap_SgnbReconfigComp,
    xpath_x2ap_SgnbModReq,
    xpath_x2ap_SgnbModReqAck,
    xpath_x2ap_SgnbAddReq,
    xpath_f1ap_UeCxtModReq,
    xpath_f1ap_UeCxtModResp,
    xpath_x2ap_SgnbAddReqAck,
    xpath_x2ap_SgnbRelReq,
    xpath_x2ap_SgnbRelReqAck,
    xpath_x2ap_SgnbReconfigComp,
    xpath_x2ap_UeCxtRel,
    xpath_x2ap_SgnbModReq,
    xpath_x2ap_SgnbModReqAck
]

DETAIL_IE_INTER_eNB_HO_WI_SGW_CHANGE = [
    {'detail_ie_xpath': 'x2ap//..//x2ap.SCGConfigurationQuery',
     'detail_id_showname': 'SCGConfigurationQuery: true (0)',
     'detail_ie_show': '0'
     },
    {'detail_ie_xpath': 'x2ap//..//x2ap.SgNBModificationRequestAcknowledge_element//..//nr-rrc.pSCellFrequency',
     'detail_id_showname': 'pSCellFrequency: 2232667',
     'detail_ie_show': '2232667',
     },
    {'detail_ie_xpath': 'x2ap//..//x2ap.SGNB_Addition_Trigger_Ind',
     'detail_id_showname': 'SGNB-Addition-Trigger-Ind: inter-eNB-HO (1)',
     'detail_ie_show': '1'
     },
    {'detail_ie_xpath': 'f1ap//..//f1ap.UEContextModificationRequest_element//..//f1ap.TransmissionActionIndicator',
     'detail_id_showname': 'TransmissionActionIndicator: stop (0)',
     'detail_ie_show': '0'
     },
    {'detail_ie_xpath': 'x2ap//..//x2ap.SgNBAdditionRequestAcknowledge_element//..//x2ap.RRC_Config_Ind',
     'detail_id_showname': 'RRC-Config-Ind: delta-config (1)',
     'detail_ie_show': '1'
     },
    [
        {'detail_ie_xpath': 'x2ap//..//x2ap.SgNBReleaseRequest_element//..//x2ap.radioNetwork',
         'detail_id_showname': 'radioNetwork: mCG-Mobility (46)',
         'detail_ie_show': '46'},
        {'detail_ie_xpath': 'x2ap//..//x2ap.SgNBReleaseRequest_element//..//x2ap.UE_ContextKeptIndicator',
         'detail_id_showname': 'UE-ContextKeptIndicator: true (0)',
         'detail_ie_show': '0'}
    ]
]

SRC_ENB_LTE_HO_WO_SGW_CHANGE = [
    xpath_x2ap_SgnbModReq,
    xpath_x2ap_SgnbModReqAck,
    xpath_x2ap_HandoverReq,
    xpath_x2ap_HandoverReqAck,
    xpath_x2ap_SgnbRelReq,
    xpath_x2ap_SgnbRelReqAck,
    xpath_x2ap_UeCxtRel,
    xpath_x2ap_UeCxtRel
]

TGT_ENB_LTE_HO_WO_SGW_CHANGE = [
    xpath_x2ap_HandoverReq,
    xpath_x2ap_SgnbAddReq,
    xpath_x2ap_SgnbAddReqAck,
    xpath_x2ap_HandoverReqAck,
    xpath_s1ap_PathSwitchReq,
    xpath_s1ap_PathSwitchReqAck,
    xpath_x2ap_UeCxtRel
]

DETAIL_IE_LTE_HO_WO_SGW_CHANGE = [
    # Handover Req
    {'detail_ie_xpath': 'x2ap//..//x2ap.HandoverRequest_element//..//x2ap.radioNetwork',
     'detail_id_showname': 'radioNetwork: handover-desirable-for-radio-reasons (0)',
     'detail_ie_show': '0'
     },
    # Handover Req Ack
    [
        {'detail_ie_xpath': 'x2ap//..//x2ap.HandoverRequestAcknowledge_element//..//lte-rrc.targetPhysCellId',
         'detail_id_showname': 'targetPhysCellId: 48',
         'detail_ie_show': '48'
         },
        {'detail_ie_xpath': 'x2ap//..//x2ap.HandoverRequestAcknowledge_element//..//nr-rrc.physCellId',
         'detail_id_showname': 'physCellId: 416',
         'detail_ie_show': '416'
         },
        {'detail_ie_xpath': 'x2ap//..//x2ap.HandoverRequestAcknowledge_element//..//x2ap.UE_ContextKeptIndicator',
         'detail_id_showname': 'UE-ContextKeptIndicator: true (0)',
         'detail_ie_show': '0'
         }
    ],
    # Paht Switch Req
    {'detail_ie_xpath': 's1ap//..//s1ap.PathSwitchRequest_element//..//s1ap.tAC',
     'detail_id_showname': 'tAC: 20001 (0x4e21)',
     'detail_ie_show': '20001'
     }
]

SRC_ENB_LTE_HO_WI_SGW_CHANGE = SRC_ENB_LTE_HO_WO_SGW_CHANGE

TGT_ENB_LTE_HO_WI_SGW_CHANGE = [
    xpath_x2ap_HandoverReq,
    xpath_x2ap_SgnbAddReq,
    xpath_x2ap_SgnbAddReqAck,
    xpath_x2ap_HandoverReqAck,
    xpath_s1ap_PathSwitchReq,
    xpath_s1ap_PathSwitchReqAck,
    xpath_x2ap_UeCxtRel,
    xpath_x2ap_SgnbModReq,
    xpath_s1ap_UlNASTrans,   # TAU Request
    xpath_s1ap_DlNASTrans,   # TAU Accept
    # xpath_x2ap_SgnbModReqAck,
    xpath_s1ap_UlNASTrans   # TAU Complete
]

DETAIL_IE_LTE_HO_WI_SGW_CHANGE = [
    # Handover Req
    {'detail_ie_xpath': 'x2ap//..//x2ap.HandoverRequest_element//..//x2ap.radioNetwork',
     'detail_id_showname': 'radioNetwork: handover-desirable-for-radio-reasons (0)',
     'detail_ie_show': '0'
     },
    # Handover Req Ack
    [
        {'detail_ie_xpath': 'x2ap//..//x2ap.HandoverRequestAcknowledge_element//..//lte-rrc.targetPhysCellId',
         'detail_id_showname': 'targetPhysCellId: 48',
         'detail_ie_show': '48'
         },
        {'detail_ie_xpath': 'x2ap//..//x2ap.HandoverRequestAcknowledge_element//..//nr-rrc.physCellId',
         'detail_id_showname': 'physCellId: 416',
         'detail_ie_show': '416'
         },
        {'detail_ie_xpath': 'x2ap//..//x2ap.HandoverRequestAcknowledge_element//..//x2ap.UE_ContextKeptIndicator',
         'detail_id_showname': 'UE-ContextKeptIndicator: true (0)',
         'detail_ie_show': '0'
         }
    ],
    # Paht Switch Req
    {'detail_ie_xpath': 's1ap//..//s1ap.PathSwitchRequest_element//..//s1ap.tAC',
     'detail_id_showname': 'tAC: 6666 (0x1a0a)',
     'detail_ie_show': '6666'
     },
    # TAU Request
    [
        {'detail_ie_xpath': 's1ap//..//s1ap.UplinkNASTransport_element//..//nas_eps.nas_msg_emm_type',
         'detail_id_showname': 'NAS EPS Mobility Management Message Type: Tracking area update request (0x48)',
         'detail_ie_show': '72'
         },
        {'detail_ie_xpath': 's1ap//..//s1ap.UplinkNASTransport_element//..//nas_eps.emm.tai_tac',
         'detail_id_showname': 'Tracking area code(TAC): 20000',
         'detail_ie_show': '20000'
         },
        {'detail_ie_xpath': 's1ap//..//s1ap.UplinkNASTransport_element//..//s1ap.tAC',
         'detail_id_showname': 'tAC: 6666 (0x1a0a)',
         'detail_ie_show': '6666'
         },
    ],
    # TAU Accept
    {'detail_ie_xpath': 's1ap//..//s1ap.DownlinkNASTransport_element//..//nas_eps.nas_msg_emm_type',
     'detail_id_showname': 'NAS EPS Mobility Management Message Type: Tracking area update accept (0x49)',
     'detail_ie_show': '73'
     },
    # TAU Complete
    {'detail_ie_xpath': 's1ap//..//s1ap.UplinkNASTransport_element//..//nas_eps.nas_msg_emm_type',
     'detail_id_showname': 'NAS EPS Mobility Management Message Type: Tracking area update complete (0x4a)',
     'detail_ie_show': '74'
     },
]
