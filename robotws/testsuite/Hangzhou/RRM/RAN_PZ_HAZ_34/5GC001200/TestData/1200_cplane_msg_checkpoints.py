# -*- coding: utf-8 -*
"""
This file defines the filters for checkpoints of control plane messages triggered during 1200 scenarios.
"""

# 2020-05-21: add two more msg according to CFAM 5G_RAN_CP_23958 update.
RLO_CP_FILTERS_SRB1 = [
    dict(
        msgType='rlo_e1ap_BrCtxModReqd',
        filter='e1ap.id == 21 and '
               'e1ap.uL_Configuration == 0'
    ),
    dict(
        msgType='rlo_x2ap_SgNBModReqd',
        filter='x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 30 and nr-rrc.criticalExtensions == 0 and '
               'nr-rrc.criticalExtensions == 0 and nr-rrc.cellGroup == 0 and nr-rrc.ul_DataSplitThreshold == 23'
    ),
    dict(
        msgType='rlo_x2ap_SgNBModConf',
        filter='x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 30 and nr-rrc.criticalExtensions == 0'
    ),
    dict(
        msgType='rlo_e1ap_BrCtxModConf',
        filter='e1ap.id == 20'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.RRCReconfigurationCompleteIndicator == 0 and '
               'f1ap.uLUEConfiguration == 0'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.id == 162'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7 and f1ap.id == 39'
    )
]


RLO_CP_FILTERS_SRB3 = [
    dict(
        msgType='rlo_e1ap_BrCtxModReqd',
        filter='e1ap.id == 21 and  '
               'e1ap.uL_Configuration == 0'
    ),
    dict(
        msgType='rlo_f1ap_DlRrcMsgTran',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and f1ap.id == 50 and f1ap.SRBID == 3'
    ),
    dict(
        msgType='rlo_f1ap_UlRrcMsgTran',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13'
    ),
    dict(
        msgType='rlo_e1ap_BrCtxModConf',
        filter='e1ap.id == 20'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.RRCReconfigurationCompleteIndicator == 0 '
               'and f1ap.uLUEConfiguration == 0'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.id == 162'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7 and f1ap.id == 39'
    )
]


RL_Resume_NR_CP_FILTERS_SRB1 = [
    dict(
        msgType='rl_resume_e1ap_BrCtxModReqd',
        filter='e1ap.id == 21 and '
               'e1ap.uL_Configuration == 2'
    ),
    dict(
        msgType='rl_resume_x2ap_SgNBModReqd',
        filter='x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 30 and nr-rrc.criticalExtensions == 0 and '
               'nr-rrc.cellGroup == 1 and nr-rrc.ul_DataSplitThreshold == 23'
    ),
    dict(
        msgType='rl_resume_x2ap_SgNBModConf',
        filter='x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 30 and nr-rrc.criticalExtensions == 0'
    ),
    dict(
        msgType='rl_resume_e1ap_BrCtxModConf',
        filter='e1ap.id == 20'
    ),
    dict(
        msgType='rl_resume_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.RRCReconfigurationCompleteIndicator == 0 '
               'and f1ap.uLUEConfiguration == 2'
    ),
    dict(
        msgType='rl_resume_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.id == 162'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7 and f1ap.id == 39'
    )
]


RL_Resume_NRLTE_CP_FILTERS_SRB1 = [
    dict(
        msgType='rl_resume_e1ap_BrCtxModReqd',
        filter='e1ap.id == 21 and '
               'e1ap.uL_Configuration == 1'
    ),
    dict(
        msgType='rl_resume_x2ap_SgNBModReqd',
        filter='x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 30 and nr-rrc.criticalExtensions == 0 and '
               'nr-rrc.cellGroup == 1 and nr-rrc.ul_DataSplitThreshold == 0'
    ),
    dict(
        msgType='rl_resume_x2ap_SgNBModConf',
        filter='x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 30 and nr-rrc.criticalExtensions == 0'
    ),
    dict(
        msgType='rl_resume_e1ap_BrCtxModConf',
        filter='e1ap.id == 20'
    ),
    dict(
        msgType='rl_resume_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.RRCReconfigurationCompleteIndicator == 0 '
               'and f1ap.uLUEConfiguration == 1'
    ),
    dict(
        msgType='rl_resume_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.id == 162'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7 and f1ap.id == 39'
    )
]

# no pcap captured for scenario 'Resume with SRB3 enabled' for now, will be updated later

RL_Resume_NR_CP_FILTERS_SRB3 = [
    dict(
        msgType='rl_resume_e1ap_BrCtxModReqd',
        filter='e1ap.id == 21 and '
               'e1ap.uL_Configuration == 2'
    ),
    dict(
        msgType='rl_resume_f1ap_DlRrcMsgTran',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and f1ap.id == 50 and f1ap.SRBID == 3'
    ),
    dict(
        msgType='rl_resume_f1ap_UlRrcMsgTran',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13'
    ),
    dict(
        msgType='rl_resume_e1ap_BrCtxModConf',
        filter='e1ap.id == 20'
    ),
    dict(
        msgType='rl_resume_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.RRCReconfigurationCompleteIndicator == 0 '
               'and f1ap.uLUEConfiguration == 2'
    ),
    dict(
        msgType='rl_resume_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.id == 162'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7 and f1ap.id == 39'
    )
]

RL_Resume_NRLTE_CP_FILTERS_SRB3 = [
    dict(
        msgType='rl_resume_e1ap_BrCtxModReqd',
        filter='e1ap.id == 21 and '
               'e1ap.uL_Configuration == 1'
    ),
    dict(
        msgType='rl_resume_f1ap_DlRrcMsgTran',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12 and f1ap.id == 50 and f1ap.SRBID == 3'
    ),
    dict(
        msgType='rl_resume_f1ap_UlRrcMsgTran',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13'
    ),
    dict(
        msgType='rl_resume_e1ap_BrCtxModConf',
        filter='e1ap.id == 20'
    ),
    dict(
        msgType='rl_resume_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.RRCReconfigurationCompleteIndicator == 0 '
               'and f1ap.uLUEConfiguration == 1'
    ),
    dict(
        msgType='rl_resume_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.id == 162'
    ),
    dict(
        msgType='rlo_f1ap_UeCtxModResp',
        filter='f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7 and f1ap.id == 39'
    )
]

RLO_F1AP_X2AP_FILTERS_SRB1_MULUE = [
    dict(
        msgType='rlo_f1ap_UeCtxModReq',
        filter='f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and f1ap.RRCReconfigurationCompleteIndicator == 0 and '
               'f1ap.uLUEConfiguration == 0'
    )
]
