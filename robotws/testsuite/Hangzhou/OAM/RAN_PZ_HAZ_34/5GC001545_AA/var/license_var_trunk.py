from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
nrbts_id = "NRBTS-%d" % tl.gnbs[0].instance_id

DICT__feature_flag_def = {
    "bronze": {
        "syncInputType": {
            "open": ["1pps/ToD from Sync Hub Master", "1pps/ToD from external GNSS receiver"],
            "para_name": "Sync input type",
            "dist_name": "MNL-1/MNLENT-1/SYNC-1/CLOCK-1",
            "object_name": nrbts_id
        },
        "actCarrierAggregation": {
            "open": ["true"],
            "para_name": "Activate carrier aggregation",
            "dist_name": nrbts_id,
            "object_name": nrbts_id
        },
        "actBeamforming": {
            "open": ["true"],
            "para_name": "Activate Beamforming",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": "%s/NRCELL-1" % nrbts_id,
        },
        "actEirpControl": {
            "open": ["true"],
            "para_name": "Activate EIRP control",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": "%s/NRCELL-1" % nrbts_id,
        },
        "actExternalAntennaBF": {
            "open": ["true"],
            "para_name": "Activate external antenna beamforming",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": "%s/NRCELL-1" % nrbts_id,
        },
        "actCellTraceReport": {
            "open": ["true"],
            "para_name": "Activate cell trace report",
            "dist_name":  nrbts_id,
            "object_name": nrbts_id,
        },
        "actSecDataUsageRep": {
            "open": ["true"],
            "para_name": "Activate secondary data usage report",
            "dist_name": nrbts_id,
            "object_name": nrbts_id,
        },
        "actA2SgnbRelease": {
            "open": ["true"],
            "para_name": "Activate A2 based SgNB release",
            "dist_name": nrbts_id,
            "object_name": nrbts_id,
        },
        "actMultVlan": {
            "open": ["true"],
            "para_name": "Activate Multiple VLAN interfaces",
            "dist_name": nrbts_id,
            "object_name": nrbts_id,
        },
        "actUESpecificULResCoordination": {
            "open": ["true"],
            "para_name": "Activate UE Specific Dynamic UL resource coordination",
            "dist_name": nrbts_id,
            "object_name": nrbts_id,
        },
        "actFdmScheduling": {
            "open": ["true"],
            "para_name": "Activate frequency domain scheduling",
            "dist_name": nrbts_id,
            "object_name": nrbts_id,
        },
        "actMultiDrbNSA": {
            "open": ["true"],
            "para_name": "Activate multi DRBs per NSA UE",
            "dist_name": nrbts_id,
            "object_name": nrbts_id,
        },
        "actCoverageNonCoherentUes": {
            "open": ["true"],
            "para_name": "Activate coverage non-coherent MIMO UEs",
            "dist_name": nrbts_id,
            "object_name": nrbts_id,
        },
        "actCDrx": {
            "open": ["true"],
            "para_name": "Activate connected DRX",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": "%s/NRCELL-1" % nrbts_id,
        },
    },
    "bronze_txt": {
        "targetTotalLoad": {
            "open": [100],
            "para_name": "Target total load with artificial load",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": "%s/NRCELL-1" % nrbts_id,
        },
        "prachConfigurationIndex": {
            "open": [200],
            "para_name": "PRACH configuration index",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": nrbts_id,
        },
    },
    "bronze_mo": {
        "actPCMDReporting": {
            "open": ["true"],
            "para_name": "Activate PCMD reporting",
            "dist_name": "%s/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1" % nrbts_id,
            "object_name": "%s/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1" % nrbts_id,
        },
        "TOPP": {
            "open": ["true"],
            "para_name": "TOP Phase Synchronization instance identifier",
            "dist_name": "MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1",
            "object_name": "MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1",
        },
        "ipSecEnabled": {
            "open": ["true"],
            "para_name": "IPsec enabling switch",
            "dist_name": "TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-1",
            "object_name": "TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-1",
        },
    },
    "silver": {
        "actDl256Qam": {
            "open": ["true"],
            "para_name": "Activate 256QAM in DL",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": "%s/NRCELL-1" % nrbts_id,
        },
        "actDlMuMimo": {
            "open": ["true"],
            "para_name": "Activate DL MU-MIMO",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": "%s/NRCELL-1" % nrbts_id,
        },
        "actUlMuMimo": {
            "open": ["true"],
            "para_name": "Activate UL MU-MIMO",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": "%s/NRCELL-1" % nrbts_id,
        },
        "actDynUlDataSplitMode": {
            "open": ["true"],
            "para_name": "Activate dynamic UL data split mode",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": "%s/NRCELL-1" % nrbts_id,
        },
        "actRanSharing": {
            "open": ["true"],
            "para_name": "Activate dynamic UL data split mode",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": "%s/NRCELL-1" % nrbts_id,
        },
        "actPRBBlanking": {
            "open": ["true"],
            "para_name": "Activate PRB blanking",
            "dist_name": "%s/NRCELL-1" % nrbts_id,
            "object_name": "%s/NRCELL-1" % nrbts_id,
        },
    },
    "gold": {
        "actLteNrDss": {
            "open": ["true"],
            "para_name": "Activate LTE-NR dynamic spectrum sharing",
            "dist_name": nrbts_id,
            "object_name": nrbts_id,
        },
    },
}

LIST__uclap_flag_fit_list = [
    ["true", "true", "true"],
    ["false", "true", "true"],
]
