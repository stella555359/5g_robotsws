TRUNK_SOURCE_CELL = '602'
BRANCH_SOURCE_CELL = '100'

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
    }
}

qos1 = r"'qoSFlowIdentifier'\s*:\s*9"
qos1_1 = r"'fiveQI'\s*:\s*9"
qos2 = r"'qoSFlowIdentifier'\s*:\s*8"
qos2_1 = r"'fiveQI'\s*:\s*8"
f1 = r"'ZMQ_SCTP_name':\s*'F1AP:\s*Paging'"
rrc = f"rrcResumeRequest1"
RAN_PAG = {
    "Paging Timer": "Starting tRanPagingAttPeriodGuardTimer timer"
}
MIN_ATTENUATION = 0

TRUNK_VCU_PARAMS_11041 = {
    'MRBTS-8505/NRBTS-8505': {
        'actPagingEnh': 'pagingStratForRrcInact'
    }
}
TRUNK_VDU_PARAMS_11041 = {
    'MRBTS-8505/NRBTS-8505': {
        'actPagingEnh': 'pagingStratForRrcInact'
    }
}
BRANCH_VCU_PARAMS_11041 = {
    'MRBTS-8674/NRBTS-8674': {
        'actPagingEnh': 'pagingStratForRrcInact'
    }
}
BRANCH_VDU_PARAMS_11041 = {
    'MRBTS-8674/NRBTS-8674': {
        'actPagingEnh': 'pagingStratForRrcInact'
    }
}

snapshot_vCU_vDU1_vDU_2 = ['10.42.93.184', '10.42.38.208', '10.42.38.209']

vdu_pm_counters_dict = {"M55117C00004": 0, "M55331C00004": 0, "M55117C04501": 0}
vdu_counter_ids = ["M55117C00004", "M55331C00004", "M55117C04501"]
vcu_pm_counters_dict = {"M55124C00007": 0, "M55124C00010": 0}
vcu_counter_ids = ["M55124C00007", "M55124C00010"]
