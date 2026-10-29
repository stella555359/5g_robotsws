from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import nrbts_id

timers = {
    "drbRrcInactInactivityTimerSA": "5",
    "srbInactivityTimerSA": "30",
    "drbInactivityTimerSA": "60",
    "drbRrcInactInactivityTimerSARedCap": "5",
    "srbInactivityTimerSARedCap": "15",
    "drbInactivityTimerSARedCap": "30",
    "maxUeRrcInactTime": "6",
    "t380": "5min",
}

inactive_redcap_timers = [
    "drbRrcInactInactivityTimerSARedCap",
    "srbInactivityTimerSARedCap",
    "drbInactivityTimerSARedCap",
]


PM_COUNTERS = {
    "REDCAP_RRC_REL_WITH_SUSP_NRNAU": {
        "PI_ID": "M55138C00062",
        "value": {},
        "shark_filter": "f1ap.UEContextReleaseCommand_element",
        "shark_msg": "suspendConfig",
        "redcap_ue_recalculation": True,
    },
    "NRRCC_RRC_REL_WITH_SUSP_NRNAU": {
        "PI_ID": "M55124C00006",
        "value": {},
        "shark_filter": "f1ap.UEContextReleaseCommand_element",
        "shark_msg": "suspendConfig",
        "redcap_ue_recalculation": False,
    },
    "REDCAP_RRC_RESUME_REQ1": {
        "PI_ID": "M55138C00063",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "redcap_ue_recalculation": True,
    },
    "NRRCC_RRC_RESUME_REQUEST1": {
        "PI_ID": "M55124C00007",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "redcap_ue_recalculation": False,
    },
    "REDCAP_RRC_RESUME_SUCC": {
        "PI_ID": "M55138C00064",
        "value": {},
        "shark_filter": "f1ap.ULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeComplete",
        "redcap_ue_recalculation": True,
    },
    "NRRCC_RRC_RESUME_SUCC": {
        "PI_ID": "M55124C00010",
        "value": {},
        "shark_filter": "f1ap.ULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeComplete",
        "redcap_ue_recalculation": False,
    },
    "AVG_SA_REDCAP_RRC_INA_NOM": {
        "PI_ID": "M55138C00065",
        "value": {},
        "shark_filter": None,
        "shark_msg": "",
        "redcap_ue_recalculation": False,
    },
    "REDCAP_RRC_REL_WITH_SUSP_RNAU": {
        "PI_ID": "M55138C00066",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "cause": ["resumeCause", "rna-Update*"],
        "redcap_ue_recalculation": True,
    },
    "NRRCC_RRC_REL_WITH_SUSP_RNAU": {
        "PI_ID": "M55124C00012",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "cause": ["resumeCause", "rna-Update*"],
        "redcap_ue_recalculation": False,
    },
    "REDCAP_RRC_RESUME_REQ1_RNAU": {
        "PI_ID": "M55138C00067",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "cause": ["resumeCause", "rna-Update*"],
        "redcap_ue_recalculation": True,
    },
    "NRRCC_RRC_RESUME_REQUEST1_RNAU": {
        "PI_ID": "M55124C00011",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "cause": ["resumeCause", "rna-Update*"],
        "redcap_ue_recalculation": False,
    },
    "REDCAP_RRC_RESUME_REQ": {
        "PI_ID": "M55138C00068",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest",
        "redcap_ue_recalculation": True,
    },
    "NRRCC_RRC_RESUME_REQUEST": {
        "PI_ID": "M55124C00008",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest",
        "redcap_ue_recalculation": False,
    },
    "REDCAP_RRC_RESUME_FALBK_ATT": {
        "PI_ID": "M55138C00069",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "cause": ["resumeCause", "highPriorityAccess*"],   # after the msg with this cause fallback to rrcsetup
        "redcap_ue_recalculation": True,
    },
    "NRRCC_RRC_RESUME_FALLBACK_ATT": {
        "PI_ID": "M55124C00013",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "cause": ["resumeCause", "highPriorityAccess*"],   # after the msg with this cause fallback to rrcsetup
        "redcap_ue_recalculation": False,
    },
    "REDCAP_RRC_RESUME_FALBK_SUCC": {
        "PI_ID": "M55138C00070",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "cause": ["resumeCause", "highPriorityAccess*"],   # after the msg with this cause fallback to rrcsetup
        "redcap_ue_recalculation": True,
    },
    "NRRCC_RRC_RESUME_FALLBACK_SUCC": {
        "PI_ID": "M55124C00014",
        "value": {},
        "shark_filter": "f1ap.InitialULRRCMessageTransfer_element",
        "shark_msg": "rrcResumeRequest1",
        "cause": ["resumeCause", "highPriorityAccess*"],   # after the msg with this cause fallback to rrcsetup
        "redcap_ue_recalculation": False,
    },
    "PEAK_SA_REDCAP_RRC_INA": {
        "PI_ID": "M55156C00052",
        "value": {},
        "shark_filter": None,
        "shark_msg": "",
        "redcap_ue_recalculation": False,
    },
    "REDCAP_UE_RRC_STP_SUCC": {
        "PI_ID": "M55166C00012",
        "value": {},
        "shark_filter": "f1ap.ULRRCMessageTransfer_element",
        "shark_msg": "rrcSetupComplete",
        "redcap_ue_recalculation": True,
    },
}
