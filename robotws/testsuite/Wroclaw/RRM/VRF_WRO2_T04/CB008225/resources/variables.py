from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import nrbts_id


PM_COUNTERS = {
    "NF1CD_RAN_PAGING_SUCC_SENT": {
        "PI_ID": "M55117C00004",
        "value": 0,
        "shark_filter": "f1ap.Paging_element",
        "shark_msg": "Paging",
        "cause": ["iRNTI", "*"],
    },
    "NRRCC_RRC_REL_WITH_SUSP_NRNAU": {
        "PI_ID": "M55124C00006",
        "value": {},
        "shark_filter": "e1ap.BearerContextModificationRequest_element",
        "shark_msg": "BearerContextModificationRequest",
        "cause": ["BearerContextStatusChange", "suspend*"],
        "comment": "'f1ap.UEContextReleaseCommand_element' contains 'suspendConfig'",
    },
    "NRRCC_RRC_RESUME_REQUEST1": {
        "PI_ID": "M55124C00007",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
    },
    "NRRCC_RRC_RESUME_REQUEST": {
        "PI_ID": "M55124C00008",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest",
        "comment": "This counter is updated only if actRrcInactState=intra-gNB",
    },
    "NRRCC_RRC_RESUME_REJECT": {
        "PI_ID": "M55124C00009",
        "value": {},
        "shark_filter": "f1ap.UEContextReleaseCommand_element",
        "shark_msg": "rrcReject",
    },
    "NRRCC_RRC_RESUME_SUCC": {
        "PI_ID": "M55124C00010",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "comment": "f1ap.ULRRCMessageTransfer_element with rrcResumeComplete, packet malformed",
    },
    "NRRCC_RRC_RESUME_REQUEST1_RNAU": {
        "PI_ID": "M55124C00011",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "cause": ["resumeCause", "rna-Update*"],
    },
    "NRRCC_RRC_REL_WITH_SUSP_RNAU": {
        "PI_ID": "M55124C00012",
        "value": {},
        "shark_filter": None,
        "shark_msg": "",
    },
    "NRRCC_RRC_RESUME_FALLBACK_ATT": {
        "PI_ID": "M55124C00013",
        "value": {},
        "shark_filter": None,
        "shark_msg": "",
    },
    "NRRCC_RRC_RESUME_FALLBACK_SUCC": {
        "PI_ID": "M55124C00014",
        "value": {},
        "shark_filter": None,
        "shark_msg": "",
    },
    "SA_RRC_RESUME_FAIL_OVLCP": {
        "PI_ID": "M55124C00015",
        "value": {},
        "shark_filter": None,
        "shark_msg": "",
    },
    "UAI_RRC_REL_INACT_PREF_INACT": {
        "PI_ID": "M55124C00016",
        "value": {},
        "shark_filter": None,
        "shark_msg": "",
    },
    "UAI_RRC_REL_INACT_PREF_OUTCONN": {
        "PI_ID": "M55124C00017",
        "value": {},
        "shark_filter": None,
        "shark_msg": "",
    },
    "NRRCC_RRC_RESUME_PLMN_DIFF": {
        "PI_ID": "M55124C00022",
        "value": {},
        "shark_filter": None,
        "shark_msg": "",
    },
    "NG_FLOW_SUSP_RRC_CONN_INACTIVE": {
        "PI_ID": "M55125C00021",
        "value": {},
        "shark_filter": "e1ap.BearerContextModificationRequest_element",
        "shark_msg": "BearerContextModificationRequest",
        "cause": ["BearerContextStatusChange", "suspend*"],
        "multiplier": 2,   # two pdu session for data and vonr
        "comment": "'f1ap.UEContextReleaseCommand_element' contains 'suspendConfig'",
    },
    "NRRCC_RRC_RELEASE_SENT": {
        "PI_ID": "M55124C00001",
        "value": {},
        "shark_filter": "f1ap.UEContextReleaseCommand_element",
        "shark_msg": "UEContextReleaseCommand",
    },
    "NE1CS_CTXT_MOD_REQ_SENT": {
        "PI_ID": "M55135C00505",
        "value": 0,
        "shark_filter": "e1ap.BearerContextModificationRequest_element",
        "shark_msg": "BearerContextModificationRequest",
    },
    "NE1CS_CTXT_MOD_RSP_RECD": {
        "PI_ID": "M55135C00506",
        "value": 0,
        "shark_filter": "e1ap.BearerContextModificationResponse_element",
        "shark_msg": "BearerContextModificationResponse",
    },
    "NE1US_CTXT_MOD_REQ_RECD": {
        "PI_ID": "M55133C01004",
        "value": 0,
        "shark_filter": "e1ap.BearerContextModificationRequest_element",
        "shark_msg": "BearerContextModificationRequest",
    },
    "NE1US_CTXT_MOD_RSP_SENT": {
        "PI_ID": "M55133C01005",
        "value": 0,
        "shark_filter": "e1ap.BearerContextModificationResponse_element",
        "shark_msg": "BearerContextModificationResponse",
    },
}

TPUT = {
    "IDLE": {
        "DL": "0",
        "UL": "0",
        "DL_CA": "0",
    },
    "INACTIVE": {
        "DL": "0",
        "UL": "0",
        "DL_CA": "0",
    },
}
