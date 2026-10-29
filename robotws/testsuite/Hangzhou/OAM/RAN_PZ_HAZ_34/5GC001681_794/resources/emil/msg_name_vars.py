LIST__xn_msgs = [
    # sctp message
    "DownlinkNASTransport",
    "UplinkNASTransport",
    "InitialUEMessage",
    "InitialContextSetupRequest",
    "InitialContextSetupResponse",
    "UERadioCapabilityInfoIndication",
    # With CB007208, E1AP and F1AP are sent directly over syscom(BTS_E2E_TRBL_433)
    "BearerContextSetupRequest",
    "BearerContextSetupResponse",
    "UEContextSetupRequest",
    "UEContextSetupResponse",
    "UEContextModificationRequest",
    "UEContextModificationResponse",
    "rrcReconfiguration",
    "rrcReconfigurationComplete"
]

LIST__zmq_msgs = [
    "CpUeRecvInitialRRCMsg",
    "CpCellRrcResourceReq",
    "CpCellRrcResourceResp",
    "BearerSetupReq",
    "BearerSetupResp",
    "UlPduReceiveInd",
    "SendToCore",
    "CpIfReceiveFromCore",
    "SrbSendReq",
    "SrbSendResp",
    "BearerDeleteReq",
    "BearerDeleteResp",
    "CpCellResourceReleaseReq",
    "CpCellResourceReleaseResp",
    "CpCellPduSessionResourceReq",
    "CpCellPduSessionResourceResp"
]

LIST__cpnrt_msgs = [
    "ITF_L2_HI_CU_USER_BEARERSETUPREQ_ID",
    "ITF_L2_HI_CU_USER_BEARERSETUPRESP_ID",
    "ITF_L2_HI_CU_USER_PDUSESSIONSETUPREQ_ID",
    "ITF_L2_HI_CU_USER_PDUSESSIONSETUPRESP_ID"
]

LIST__cprt_msgs = [
    "ITF_L2_LO_USER_CCCHDATARECEIVEIND_ID",
    "ITF_L2_PS_USER_USERSETUPREQ_ID",
    "ITF_L2_PS_USER_USERSETUPRESP_ID",
    "ITF_L2_LO_USER_USERSETUPREQ_ID",
    "ITF_L2_LO_USER_USERSETUPRESP_ID",
    "ITF_L2_HI_DU_USER_BEARERSETUPREQ_ID",
    "ITF_L2_HI_DU_USER_BEARERSETUPRESP_ID",
    "ITF_CP_RT_CPIFDU_CPIFDU_SENDTOCUIND_ID"
    #    "ITF_CP_RT_CPIFDU_CPIFDU_RECEIVEDFROMCUIND_ID"
]

LIST__cpue_msgs = [
    "AAFILE_SICFTP_TIMEOUT_MSG"
]

LIST__cpif_msgs = [
    "AAPRO_NODE_POLL_REQ_MSG",
    "AAPRO_NODE_POLL_RESP_MSG"
]

LIST__cpcell_msgs = [
    "CPCM_CELLSTATUSIND_ID"
]

# LIST__cpnb_msgs = [
#     "CPCM_POOLCONFIGURATIONRESP_ID",
#     "CPCM_NETWORKPLANUPDATEIND_ID"
# ]

LIST__cpnb_msgs = [
    "CPCM_NETWORKPLANUPDATEIND_ID"
]

LIST__coam_msgs = [
    " 10 11 "
]

LIST__xpif_msgs = [
    "FAULT_REQ_MSG",
    "FAULT_ACK_MSG"
]

# LIST__cpnrt_msgs = [
#     "15",
#     "20"
# ]
#
# LIST__cprt_msgs = [
#     "15",
#     "21"
# ]
#
# LIST__cpue_msgs = [
#     "17",
#     "30"
# ]
#
# LIST__cpif_msgs = [
#     "15",
#     "11"
# ]
#
# LIST__cpcell_msgs = [
#     "15",
#     "10"
# ]
#
# LIST__cpnb_msgs = [
#     "15",
#     "14"
# ]
#
# LIST__coam_msgs = [
#     "10",
#     "11"
# ]
#
# LIST__xpif_msgs = [
#     "FAULT_REQ_MSG",
#     "FAULT_ACK_MSG"
# ]
#
# LIST__several_msgs = [
#     "FAULT_REQ_MSG"
# ]

LIST__zmq_msgs_5752 = [
    "CpCellResourceReleaseReq",
    "CpCellResourceReleaseResp"
]

LIST__cprt_msgs_5752 = [
    "ITF_L2_PS_USER_USERSETUPREQ_ID",
    "ITF_L2_LO_USER_USERSETUPREQ_ID"
]

LIST__sa_msgs = [
    "DownlinkNASTransport",
    "UplinkNASTransport",
    "InitialUEMessage",
    "InitialContextSetupRequest",
    "InitialContextSetupResponse",
    "UERadioCapabilityInfoIndication",
    "BearerContextSetupRequest",
    "BearerContextSetupResponse",
    "UEContextSetupRequest",
    "UEContextSetupResponse",
    "UEContextModificationRequest",
    "UEContextModificationResponse",
    "rrcReconfiguration",
    "rrcReconfigurationComplete",
    "ZmqMessage",
    "ITF_L2_PS",
    "ITF_L2_HI_DU",
    "ITF_L2_HI_CU",
    "ITF_L2_LO",
    "ITF_CP_RT",
    " 10 11 "
]

LIST__nsa_msgs = [
    "SgNBAdditionRequest",
    "SgNBAdditionRequestAcknowledge",
    "SgNBReconfigurationComplete",
    "BearerContextSetupRequest",
    "BearerContextSetupResponse",
    "UEContextSetupRequest",
    "UEContextSetupResponse",
    "rrcReconfiguration",
    "rrcReconfigurationComplete",
    "ZmqMessage",
    "ITF_L2_PS",
    "ITF_L2_HI_DU",
    "ITF_L2_HI_CU",
    "ITF_L2_LO",
    "ITF_CP_RT",
    " 10 11 "
]
