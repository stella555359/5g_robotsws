CELL_PORTS = {
    '501': {
        'attenuator_id': 0,
        'ports': [1, 2, 3, 4],
    },
    '502': {
        'attenuator_id': 0,
        'ports': [9, 10, 11, 12],
    },
    '505': {
        'attenuator_id': 0,
        'ports': [13, 14, 15, 16],
    },
    # yes, 505 and 506 are on the same ports
    '506': {
        'attenuator_id': 0,
        'ports': [13, 14, 15, 16],
    },
    '504': {
        'attenuator_id': 1,
        'ports': [13, 14, 15, 16],
    },
    '605': {
        'attenuator_id': 2,
        'ports': [1, 2, 3, 4],
    },
    # yes, 605 and 606 are on  the same ports
    '606': {
        'attenuator_id': 2,
        'ports': [1, 2, 3, 4],
    },
    '602': {
        'attenuator_id': 2,
        'ports': [9, 10, 11, 12],
    },
    '100': {
        'attenuator_id': 0,
        'ports': [1, 2, 3, 4]
    },
    '101': {
        'attenuator_id': 0,
        'ports': [5, 6, 7, 8]
    },
    '105': {
        'attenuator_id': 0,
        'ports': [17, 18, 19, 20]
    }
}
PCI_MAPPING = {
    "CU26R1_": {
        "15MHZ": "105",
        "20MHZ": "101"
    },
    "CU26R2_": {
        "15MHZ": "506",
        "20MHZ": "502"
    }
}

snapshot_vCU_vDU1_vDU_2 = ['10.42.93.184', '10.42.38.208', '10.42.38.209']

CONFIGS = {
    "BRANCH": {
        "VM_IP": "10.42.38.21",
    },
    "TRUNK": {
        "VM_IP": "10.42.38.17",
    }
}

L1L2_SERVER = "kubectl exec it -n cran1 po-l2rt-0 n-c ctr-l2rt -- hal-cli pdump port all path /tmp/dpdkdump"

L1L2_TERMINATE = "sudo pkill tcpdump"

vdu_pm_counters_dict = {"M55308C10004": 0, "M55308C36002": 0}
vdu_counter_ids = ["M55308C10004", "M55308C36002"]


feature_disabled_20MHz = {
    "feature_state": "20MHz_feature_disabled",
    "json_file": "20MHz_feature_disabled.json",
    "min_prb": 96,
    "max_prb": 101
}
feature_enabled_20MHz = {
    "feature_state": "20MHz_feature_enabled",
    "json_file": "20MHz_feature_enabled.json",
    "min_prb": 100,
    "max_prb": 103
}
feature_disabled_15MHz = {
    "feature_state": "15MHz_feature_disabled",
    "json_file": "15MHz_feature_disabled.json",
    "min_prb": 69,
    "max_prb": 74
}
feature_enabled_15MHz = {
    "feature_state": "15MHz_feature_enabled",
    "json_file": "15MHz_feature_enabled.json",
    "min_prb": 73,
    "max_prb": 76
}
feature_disabled_20MHz_blanking = {
    "feature_state": "20MHz_feature_disabled",
    "json_file": "20MHz_feature_disabled.json",
    "min_prb": 70,
    "max_prb": 75
}
feature_enabled_20MHz_blanking = {
    "feature_state": "20MHz_feature_enabled",
    "json_file": "20MHz_feature_enabled.json",
    "min_prb": 74,
    "max_prb": 77
}
