# -*- coding: utf-8 -*
"""
This file defines the filters for checkpoints of control plane messages.
"""

# xpath_x2ap_SgnbAddReq = 'x2ap//..//x2ap.SgNBAdditionRequest_element'
# xpath_x2ap_SgnbAddReqAck = 'x2ap//..//x2ap.SgNBAdditionRequestAcknowledge_element//../nr-rrc.pSCellFrequency'
# xpath_x2ap_SgnbReconfigComp = 'x2ap//..//x2ap.SgNBReconfigurationComplete_element'
# xpath_x2ap_SgnbMod = 'x2ap//..//x2ap.SgNBModificationRequired_element'
# xpath_x2ap_SgnbModConf = 'x2ap//..//x2ap.SgNBModificationConfirm_element'
# xpath_x2ap_MeasReport = 'x2ap//..//x2ap.RRCTransfer_element//..//nr-rrc.measurementReport_element'
xpath_f1ap_UeCxtSetupReq = 'f1ap//..//f1ap.UEContextSetupRequest_element'
xpath_f1ap_UeCxtSetupResp = 'f1ap//..//f1ap.UEContextSetupResponse_element'
xpath_f1ap_UeCxtModReq = 'f1ap//..//f1ap.UEContextModificationRequest_element'
xpath_f1ap_UeCxtModResp = 'f1ap//..//f1ap.UEContextModificationResponse_element'
xpath_f1ap_UeCxtRelCmd = 'f1ap//..//f1ap.UEContextReleaseCommand_element'
xpath_f1ap_UeCxtRelComp = 'f1ap//..//f1ap.UEContextReleaseComplete_element'
xpath_f1ap_MeasReport = 'f1ap//..//f1ap.ULRRCMessageTransfer_element//..//nr-rrc.measurementReport_element'
xpath_f1ap_RrcReconf = 'f1ap//..//nr-rrc.rrcReconfiguration_element'
xpath_f1ap_RrcReconfComp = 'f1ap//..//nr-rrc.rrcReconfigurationComplete_element'
xpath_ngap_PathSwitchReq = 'ngap//..//ngap.PathSwitchRequest_element'
xpath_ngap_PathSwitchReqAck = 'ngap//..//ngap.PathSwitchRequestAcknowledge_element'
xpath_xnap_HandoverReq = "//*[@showname='HandoverRequest']"
xpath_xnap_HandoverReqAck = "//*[@showname='HandoverRequestAcknowledge']"

SA_INTER_FREQ_INTER_GNB_HO_SRC = [
    xpath_f1ap_MeasReport,  # A2 meas report
    xpath_f1ap_RrcReconf,
    xpath_f1ap_RrcReconfComp,
    xpath_f1ap_MeasReport,  # A3 meas report
    xpath_xnap_HandoverReq,
    xpath_xnap_HandoverReqAck,
    xpath_f1ap_RrcReconf,
    xpath_f1ap_UeCxtRelCmd,
    xpath_f1ap_UeCxtRelComp,
]

SA_INTER_FREQ_INTER_GNB_HO_TGT = [
    xpath_xnap_HandoverReq,
    xpath_f1ap_UeCxtSetupReq,
    xpath_f1ap_UeCxtSetupResp,
    xpath_xnap_HandoverReqAck,
    xpath_f1ap_RrcReconfComp,
    xpath_ngap_PathSwitchReq,
    xpath_ngap_PathSwitchReqAck,
    xpath_f1ap_RrcReconf,
    xpath_f1ap_RrcReconfComp
]

SA_INTRA_FREQ_INTER_GNB_HO_SRC = [
    xpath_f1ap_MeasReport,  # A3 meas report
    xpath_xnap_HandoverReq,
    xpath_xnap_HandoverReqAck,
    xpath_f1ap_RrcReconf,
    xpath_f1ap_UeCxtRelCmd,
    xpath_f1ap_UeCxtRelComp,
]

SA_INTRA_FREQ_INTER_GNB_HO_TGT = SA_INTER_FREQ_INTER_GNB_HO_TGT


DETAIL_IE_SA_SCELL_RELEASE = [
    [
        {'detail_ie_xpath': 'f1ap//..//nr-rrc.rrcReconfiguration_element//..//nr-rrc.nonCriticalExtension_element'
                            '//..//nr-rrc.drx_Config',
         'detail_id_showname': 'drx-Config: release (0)',
         'detail_ie_show': '0'},
        {'detail_ie_xpath': 'f1ap//..//nr-rrc.rrcReconfiguration_element//..//nr-rrc.nonCriticalExtension_element'
                            '//..//nr-rrc.sCellToReleaseList//..//nr-rrc.SCellIndex',
         'detail_id_showname': 'SCellIndex: 1',
         'detail_ie_show': '1'},
    ]
]
