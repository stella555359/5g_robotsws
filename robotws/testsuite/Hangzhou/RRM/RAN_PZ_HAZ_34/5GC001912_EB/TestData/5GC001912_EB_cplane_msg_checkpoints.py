# -*- coding: utf-8 -*
"""
This file defines the filters for checkpoints of control plane messages triggered during pscell handover scenarios.
"""

xpath_x2ap_SgnbAddReq = 'x2ap//..//x2ap.SgNBAdditionRequest_element'
xpath_x2ap_SgnbAddReqAck = 'x2ap//..//x2ap.SgNBAdditionRequestAcknowledge_element//../nr-rrc.pSCellFrequency'
xpath_x2ap_SgnbReconfigComp = 'x2ap//..//x2ap.SgNBReconfigurationComplete_element'
xpath_x2ap_SgnbMod = 'x2ap//..//x2ap.SgNBModificationRequired_element'
xpath_x2ap_SgnbModConf = 'x2ap//..//x2ap.SgNBModificationConfirm_element'
xpath_x2ap_MeasReport = 'x2ap//..//x2ap.RRCTransfer_element//..//nr-rrc.measurementReport_element'
xpath_f1ap_UeCxtSetupReq = 'f1ap//..//f1ap.UEContextSetupRequest_element'
xpath_f1ap_UeCxtSetupResp = 'f1ap//..//f1ap.UEContextSetupResponse_element'
xpath_f1ap_UeCxtModReq = 'f1ap//..//f1ap.UEContextModificationRequest_element'
xpath_f1ap_UeCxtModResp = 'f1ap//..//f1ap.UEContextModificationResponse_element'
xpath_f1ap_UeCxtRelCmd = 'f1ap//..//f1ap.UEContextReleaseCommand_element'
xpath_f1ap_UeCxtRelComp = 'f1ap//..//f1ap.UEContextReleaseComplete_element'
xpath_f1ap_MeasReport = 'f1ap//..//f1ap.ULRRCMessageTransfer_element//..//nr-rrc.measurementReport_element'
xpath_f1ap_RrcReconf = 'f1ap//..//f1ap.DLRRCMessageTransfer_element//..//nr-rrc.rrcReconfiguration_element'
xpath_f1ap_RrcReconfComp = 'f1ap//..//f1ap.ULRRCMessageTransfer_element//..//nr-rrc.rrcReconfigurationComplete_element'


PSCELL_CHANGE_SRB1 = [
    xpath_x2ap_SgnbAddReq,
    xpath_f1ap_UeCxtSetupReq,
    xpath_f1ap_UeCxtSetupResp,
    xpath_x2ap_SgnbAddReqAck,
    xpath_x2ap_SgnbReconfigComp,
    xpath_x2ap_MeasReport,  # A2 meas report
    xpath_f1ap_UeCxtModReq,
    xpath_f1ap_UeCxtModResp,
    xpath_x2ap_SgnbMod,     # A1/A3 meas config
    xpath_x2ap_SgnbModConf,
    xpath_f1ap_UeCxtModReq,
    xpath_f1ap_UeCxtModResp,
    xpath_x2ap_MeasReport,  # A3 meas report
    xpath_f1ap_UeCxtSetupReq,
    xpath_f1ap_UeCxtSetupResp,
    xpath_f1ap_UeCxtModReq,
    xpath_f1ap_UeCxtModResp,
    xpath_x2ap_SgnbMod,
    xpath_x2ap_SgnbModConf,
    xpath_f1ap_UeCxtRelCmd,
    xpath_f1ap_UeCxtRelComp,
    xpath_f1ap_UeCxtModReq,
    xpath_f1ap_UeCxtModResp
]

PSCELL_CHANGE_SRB3 = [
    xpath_x2ap_SgnbAddReq,
    xpath_f1ap_UeCxtSetupReq,
    xpath_f1ap_UeCxtSetupResp,
    xpath_x2ap_SgnbAddReqAck,
    xpath_x2ap_SgnbReconfigComp,
    xpath_f1ap_MeasReport,  # A2 meas report
    xpath_f1ap_UeCxtModReq,
    xpath_f1ap_UeCxtModResp,
    xpath_f1ap_RrcReconf,     # A1/A3 meas config
    xpath_f1ap_RrcReconfComp,
    xpath_f1ap_UeCxtModReq,
    xpath_f1ap_UeCxtModResp,
    xpath_f1ap_MeasReport,  # A3 meas report
    xpath_f1ap_UeCxtSetupReq,
    xpath_f1ap_UeCxtSetupResp,
    xpath_f1ap_UeCxtModReq,
    xpath_f1ap_UeCxtModResp,
    xpath_f1ap_RrcReconf,
    xpath_f1ap_RrcReconfComp,
    xpath_f1ap_UeCxtRelCmd,
    xpath_f1ap_UeCxtRelComp,
    xpath_f1ap_UeCxtModReq,
    xpath_f1ap_UeCxtModResp
]
