SECTORS_DATA_TRANSFER_INFO_T01SK137 = {
    "SECTOR_0": {
        "attached_nr_pci": "201",
        "nrcellgrp_id": "0",
        "lnrelgnbcell_id": "2",
        "lncel_id": "2",
        "downlink": "4300 Mbits/sec",
        "uplink": "570 Mbits/sec",
        "deviation": "30",
    },
    "SECTOR_1": {
        "attached_nr_pci": "211",
        "nrcellgrp_id": "1",
        "lnrelgnbcell_id": "3",
        "lncel_id": "2",
        "downlink": "4300 Mbits/sec",
        "uplink": "570 Mbits/sec",
        "deviation": "30",
    }
}

SECTORS_DATA_TRANSFER_INFO_T01SK127 = {
    "SECTOR_0": {
        "nrcellgrp_id": "0",
        "attached_nr_cell": "1",
        "lncel_id": "1",
        "lnrelgnbcell_id": "0",
        "downlink": "4300 Mbits/sec",
        "uplink": "570 Mbits/sec",
        "deviation": "40",
    },
    "SECTOR_1": {
        "nrcellgrp_id": "1",
        "attached_nr_cell": "11",
        "lncel_id": "1",
        "lnrelgnbcell_id": "1",
        "downlink": "4300 Mbits/sec",
        "uplink": "570 Mbits/sec",
        "deviation": "40",
    }
}

IBW_RECONFIGURATION_FLOW = {
    'STEP_1': {
        "fr2_operation_mode": "One_Sector_1600MHz_IBW_2T2R_SU_MIMO",
        "reconfigure_sectors": "deletion",
        "reset_bts": False,
    },
    'STEP_2': {
        "fr2_operation_mode": "One_Sector_3200MHz_IBW_2T2R_SU_MIMO",
        "reconfigure_sectors": None,
        "reset_bts": False,
    },
    'STEP_3': {
        "fr2_operation_mode": "One_Sector_1600MHz_IBW_2T2R_SU_MIMO",
        "reconfigure_sectors": None,
        "reset_bts": False,
    },
    'STEP_4': {
        "fr2_operation_mode": "Two_Sector_1600MHz_PER_SECTOR_IBW_2T2R_SU_MIMO",
        "reconfigure_sectors": "addition",
        "reset_bts": True,  # OM_GEN_SFS_SYSM.5287
    },
}

TBS_SCRIPT_RUS = ['RMOD-3/RMOD_R-1 (AWKUC)']
AWKUC_ID = "3"


ANTENNA_MONITORING_VALIDATION_DATA = {
    'RTWP': {
        "expected_value": {"call_event": {"value": -50,
                                          "deviation": 20},
                           "break_event": {"value": "-",
                                           "deviation": None},
                           "idle_state": {"value": -80,
                                          "deviation": 10}
                           },
        "carrier_type": "RX",
    },
    'RSSI': {
        "expected_value": {"call_event": {"value": -70,
                                          "deviation": 20},
                           "break_event": {"value": "-",
                                           "deviation": None},
                           "idle_state": {"value": "-",
                                          "deviation": None}
                           },
        "carrier_type": "RX",
    },
    'ETP': {
        "expected_value": {"call_event": {"value": 70,
                                          "deviation": 20},
                           "break_event": {"value": "-",
                                           "deviation": None},
                           "idle_state": {"value": 5,
                                          "deviation": 4}
                           },
        "carrier_type": "TX",
    },
}
