from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl

remote_vm_ip = tl.test_pcs[2].default_ssh_connection_details.addr
country_codes = ["310", "555"]

INTERDLCA_PM_COUNTERS = {
    "UE_SCELL_ACROSS_2_GNB_SA": {
        "PI_ID": "M55118C00103",
        "value": {},
        "key": "NRCELL",
        "percent_deviation": 10,
    },
    "UE_SCELL_ACROSS_MULT_GNB_SA": {
        "PI_ID": "M55118C00117",
        "value": {},
        "key": "NRCELL",
        "percent_deviation": 10,
    },
    "UE_PCELL_1_CONF_SCELL_DL_SA": {
        "PI_ID": "M55118C05507",
        "value": {},
        "key": "NRCELL",
        "percent_deviation": 15,
    },
    "UE_PCELL_2_CONF_SCELL_DL_SA": {
        "PI_ID": "M55118C07001",
        "value": {},
        "key": "NRCELL",
        "percent_deviation": 15,
    },
    "UE_PCELL_3_CONF_SCELL_DL_SA": {
        "PI_ID": "M55118C09501",
        "value": {},
        "key": "NRCELL",
        "percent_deviation": 15,
    },
    "UE_PCELL_4_CONF_SCELL_DL_SA": {
        "PI_ID": "M55118C02016",
        "value": {},
        "key": "NRCELL",
        "percent_deviation": 15,
    },
    "UE_PCELL_5_CONF_SCELL_DL_SA": {
        "PI_ID": "M55118C00013",
        "value": {},
        "key": "NRCELL",
        "percent_deviation": 15,
    },
    "NR_RLC_PDU_DL_VOL_CA_PCELL": {
        "PI_ID": "M55310C20001",
        "value": {},
        "key": "NRCELL",
    },
    "NR_RLC_PDU_DL_VOL_CA_SCELL": {
        "PI_ID": "M55310C20000",
        "value": {},
        "key": "NRCELL",
    },
    "A1_SCELL_ADDED_SA": {
        "PI_ID": "M55118C00032",
        "value": {},
        "key": "NRCELL",
    },
    "A4_SCELL_ADDED_SA": {
        "PI_ID": "M55118C00031",
        "value": {},
        "key": "NRCELL",
    },
    "A2MEAS_REL1DLSCELL_ATT_SA": {
        "PI_ID": "M55118C06501",
        "value": {},
        "key": "NRCELL",
    },
    "A2MEAS_REL1DLSCELL_SUCC_SA": {
        "PI_ID": "M55118C06502",
        "value": {},
        "key": "NRCELL",
    },
    "A2MEAS_IMMEDIATE_REL_SCELL": {
        "PI_ID": "M55118C06505",
        "value": {},
        "key": "NRCELL",
    },
    "NRRCC_RRC_RELEASE_SENT": {
        "PI_ID": "M55124C00001",
        "value": {},
        "key": "NRCELL",
    },
}

INTERDLCA_INACTIVE_PM_COUNTERS = {
    "A1_SCELL_ADDED_SA": {
        "PI_ID": "M55118C00032",
        "value": {},
        "key": "NRCELL",
    },
    "A4_SCELL_ADDED_SA": {
        "PI_ID": "M55118C00031",
        "value": {},
        "key": "NRCELL",
    },
    "A2MEAS_REL1DLSCELL_ATT_SA": {
        "PI_ID": "M55118C06501",
        "value": {},
        "key": "NRCELL",
    },
    "A2MEAS_REL1DLSCELL_SUCC_SA": {
        "PI_ID": "M55118C06502",
        "value": {},
        "key": "NRCELL",
    },
    "A2MEAS_IMMEDIATE_REL_SCELL": {
        "PI_ID": "M55118C06505",
        "value": {},
        "key": "NRCELL",
    },
    "NRPAG_RAN_PAGING_SUCC_SENT": {
        "PI_ID": "M55331C00004",
        "value": {},
        "key": "NRCELL",
    },
    "NRRCC_RRC_REL_WITH_SUSP_NRNAU": {
        "PI_ID": "M55124C00006",
        "value": {},
        "key": "NRCELL",
    },
    "NRRCC_RRC_RESUME_REQUEST1": {
        "PI_ID": "M55124C00007",
        "value": {},
        "key": "NRCELL",
    },
    "NRRCC_RRC_RESUME_REQUEST": {
        "PI_ID": "M55124C00008",
        "value": {},
        "key": "NRCELL",
    },
    "NRRCC_RRC_RESUME_REJECT": {
        "PI_ID": "M55124C00009",
        "value": {},
        "key": "NRCELL",
    },
    "NRRCC_RRC_RESUME_SUCC": {
        "PI_ID": "M55124C00010",
        "value": {},
        "key": "NRCELL",
    },
    "NRRCC_RRC_RELEASE_SENT": {
        "PI_ID": "M55124C00001",
        "value": {},
        "key": "NRCELL",
    },
    "NG_FLOW_SUSP_RRC_CONN_INACTIVE": {
        "PI_ID": "M55125C00021",
        "value": {},
        "key": "NRCELL",
    },
}

INTERDLCA_PCELL_SWITCH_PM_COUNTERS = {
    "A1_SCELL_ADDED_SA": {
        "PI_ID": "M55118C00032",
        "value": {},
        "key": "NRCELL",
    },
    "A4_SCELL_ADDED_SA": {
        "PI_ID": "M55118C00031",
        "value": {},
        "key": "NRCELL",
    },
    "NRRCC_MEAS_A2_REC": {
        "PI_ID": "M55124C02002",
        "value": {},
        "key": "NRCELL",
    },
    "ATT_A2_IF_INTRA_DU_HO_SLICE": {
        "PI_ID": "M55149C02501",
        "value": {},
        "key": "MCC",
    },
    "SUCC_A2_IF_INTRA_DU_HO_SLICE": {
        "PI_ID": "M55149C02502",
        "value": {},
        "key": "MCC",
    },
}
