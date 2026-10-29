from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl

remote_vm_ip = tl.test_pcs[2].default_ssh_connection_details.addr

INTERANR_PM_COUNTERS = {
    "SGNB_SA_CU_HO_ADMISSION_REQ": {
        "PI_ID": "M55138C00023",
        "value": {},
        "key": "NRCELL",
    },
    "SGNB_SA_CU_HO_ADMISSION_SUCC": {
        "PI_ID": "M55138C00024",
        "value": {},
        "key": "NRCELL",
    },
    "NRRCC_NRCGI_REPORT_CONF_SENT": {
        "PI_ID": "M55124C05001",
        "value": {},
        "key": "NRCELL",
    },
    "NRRCC_NRCGI_REPORT_RECV": {
        "PI_ID": "M55124C05002",
        "value": {},
        "key": "NRCELL",
    },
    "TOT_INTER_FREQ_HO_DECISION_A3": {
        "PI_ID": "M55147C00024",
        "value": {},
        "key": "NRCELL",
    },
    "TOT_INTER_FREQ_HO_DECISION_A5": {
        "PI_ID": "M55147C00025",
        "value": {},
        "key": "NRCELL",
    },
    "NMOCU_ANR_NRREL_ADD": {
        "PI_ID": "M55147C01001",
        "value": {},
        "key": "NRCELL",
    },
    "NMOCU_ANR_NRREL_OVER_LIMIT": {
        "PI_ID": "M55147C01002",
        "value": {},
        "key": "NRCELL",
    },
    "XN_HO_REQ_ACK_RECEIVED": {
        "PI_ID": "M55143C00001",
        "value": {},
        "key": "NRCELL",
    },
    "XN_HO_PREP_FAIL_RECEIVED": {
        "PI_ID": "M55143C00002",
        "value": {},
        "key": "NRCELL",
    },
    "XN_HO_CANCEL_SENT": {
        "PI_ID": "M55143C00003",
        "value": {},
        "key": "NRCELL",
    },
    "XN_HO_REQ_SENT": {
        "PI_ID": "M55143C00004",
        "value": {},
        "key": "NRCELL",
    },
    "XN_HO_REQ__RECEIVED": {
        "PI_ID": "M55143C00005",
        "value": {},
        "key": "NRCELL",
    },
    "XN_HO_REQ_ACK_SENT": {
        "PI_ID": "M55143C00006",
        "value": {},
        "key": "NRCELL",
    },
    "XN_HO_CANCEL_RECEIVED": {
        "PI_ID": "M55143C00007",
        "value": {},
        "key": "NRCELL",
    },
    "IEF_XN_HO_PR_ATT_SRC": {
        "PI_ID": "M55143C00019",
        "value": {},
        "key": "NRCELL",
    },
}


"""
    "ATT_HO_NRREL": {
        "PI_ID": "M55153C00001",
        "value": {},
        "key": "NRCELL",
    },
    "SUCC_HO_NRREL": {
        "PI_ID": "M55153C00002",
        "value": {},
        "key": "NRCELL",
    },
    "FAIL_HO_NRREL_PREP": {
        "PI_ID": "M55153C00003",
        "value": {},
        "key": "NRCELL",
    },
    "DYN_UNAVAIL_NRREL": {
        "PI_ID": "M55153C00004",
        "value": {},
        "key": "NRCELL",
    },
    "DYN_UNAVAIL_NRREL_HO_FAIL": {
        "PI_ID": "M55153C00005",
        "value": {},
        "key": "NRCELL",
    },
    """
