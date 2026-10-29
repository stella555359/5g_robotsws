DICT__feature_flag_def = {
    "bronze": {
        "syncInputType": {
            "open": ["1pps/ToD from Sync Hub Master", "1pps/ToD from external GNSS receiver"],
            "para_name": "Sync input type",
            "dist_name": "MNL-1/MNLENT-1/SYNC-1/CLOCK-1",
            "object_name": "MNL-1/MNLENT-1/SYNC-1/CLOCK-1.syncInputList-1"
        },
        "actCarrierAggregation": {
            "open": ["true"],
            "para_name": "Activate carrier aggregation",
            "dist_name": "NRBTS-${MRBTS_ID}",
            "object_name": "NRBTS-${MRBTS_ID}"
        },
        # "actBeamforming": {
        #     "open": ["true"],
        #     "para_name": "Activate Beamforming",
        #     "dist_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        #     "object_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        # },
        # "dlMimoMode": {
        #     "open": [40, 60],
        #     "path": "NRBTS-${MRBTS_ID}/NRCELL-1"
        # },
        "actMultVlan": {
            "open": ["true"],
            "para_name": "Activate Multiple VLAN interfaces",
            "dist_name": "NRBTS-${MRBTS_ID}",
            "object_name": "NRBTS-${MRBTS_ID}",
        },
        "actInterFreqInterGnbMobilitySA": {
            "open": ["true"],
            "para_name": "Activate inter-frequency inter-gNB mobility SA",
            "dist_name": "NRBTS-${MRBTS_ID}",
            "object_name": "NRBTS-${MRBTS_ID}",
        },
        "actUESpecificULResCoordination": {
            "open": ["true"],
            "para_name": "Activate UE Specific Dynamic UL resource coordination",
            "dist_name": "NRBTS-${MRBTS_ID}",
            "object_name": "NRBTS-${MRBTS_ID}",
        },
        "actCpclResiliency": {
            "open": ["true"],
            "para_name": "Activate CP-CELL resiliency",
            "dist_name": "NRBTS-${MRBTS_ID}",
            "object_name": "NRBTS-${MRBTS_ID}",
        },
        # "actCDrx": {
        #     "open": ["true"],
        #     "para_name": "Activate connected DRX",
        #     "dist_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        #     "object_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        # },
        # "beamManagementType": {
        #     "open": ["reportAndSrs"],
        #     "para_name": "Beam Management Type",
        #     "dist_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        #     "object_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        # },
    },
    "bronze_txt": {
        # "targetTotalLoad": {
        #     "open": [100],
        #     "para_name": "Target total load with artificial load",
        #     "dist_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        #     "object_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        # },
    },
    "bronze_mo": {
        "actPCMDReporting": {
            "open": ["true"],
            "para_name": "Activate PCMD reporting",
            "dist_name": "NRBTS-${MRBTS_ID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1",
            "object_name": "NRBTS-${MRBTS_ID}/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1",
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
        # "actDl256Qam": {
        #     "open": ["true"],
        #     "para_name": "Activate 256QAM in DL",
        #     "dist_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        #     "object_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        # },
        # "actDlMuMimo": {
        #     "open": ["true"],
        #     "para_name": "Activate DL MU-MIMO",
        #     "dist_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        #     "object_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        # },
        # "actUlMuMimo": {
        #     "open": ["true"],
        #     "para_name": "Activate UL MU-MIMO",
        #     "dist_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        #     "object_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        # },
        # "actSUL": {
        #     "open": ["true"],
        #     "para_name": "Activate Supplemental UL",
        #     "dist_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        #     "object_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        # },
        # "actDynUlDataSplitMode": {
        #     "open": ["true"],
        #     "para_name": "Activate dynamic UL data split mode",
        #     "dist_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        #     "object_name": "NRBTS-${MRBTS_ID}/NRCELL-1",
        # },
        "actRanSharing": {
            "open": ["true"],
            "para_name": "Activate RAN sharing",
            "dist_name": "NRBTS-${MRBTS_ID}",
            "object_name": "NRBTS-${MRBTS_ID}",
        },
    },
    "gold": {

    },
}

LIST__uclap_flag_fit_list = [
    ["true", "true", "true"],
    ["false", "true", "true"],
]
