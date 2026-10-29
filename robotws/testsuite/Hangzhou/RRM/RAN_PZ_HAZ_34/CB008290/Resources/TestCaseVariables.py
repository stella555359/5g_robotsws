# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Su Li
:contact: li.su@nokia-sbell.com
"""

from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
SOURCE_BTS_ID = "NRBTS-" + str(tl.gnbs[0].global_bts_id)
# TARGET_BTS_ID = "NRBTS-" + str(tl.gnbs[1].global_bts_id)

T820_PA_BASE_VALUE_MAPPING_TABLE = {
    "0": {
        "0": "10",
        "1": "22",
        "2": "5",
        "3": "30",
        "4": "30",
        "5": "30",
        "6": "30",
    },
    "1": {"0": "6", "1": "5", "2": "5"},
}

T079_PA_BASE_VALUE_MAPPING_TABLE = {
    "0": {
        "0": ["10", "20", "10", "10"],
        "1": ["10", "20", "10", "10"],
        "2": "20",
        "3": "35",
        "4": "35",
        "5": "35",
        "6": "35",
    },
    "1": {"0": "20"},
}

T081_PA_BASE_VALUE_MAPPING_TABLE = {
    "0": {"0": "5", "1": "10", "2": "5", "3": "35", "4": "35", "5": "35"},
    "1": {"0": "0"},
}

TESTCASE_INFO_MAPPING_TABLE_8290 = {
    "A_13": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "303",
            "scell_index": ["21"],
            "swap_scell_index": {"source_scell": ["21"], "target_scell": ["22"]},
            "case_level_params": [
                "add:NRCELL-303/NRREL-21:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-22:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-21:sCellOperationalMode=dlOnly",
                "add:NRCELL-303/NRREL-22:sCellOperationalMode=dlOnly",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["10"],
            "swap_scell_index": {"source_scell": ["10"], "target_scell": ["6"]},
            "case_level_params": [
                "add:NRCELL-5/NRREL-6:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-10:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-6:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-10:sCellOperationalMode=dlOnly",
            ],
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["8"],
            "swap_scell_index": {"source_scell": ["8"], "target_scell": ["9"]},
            "case_level_params": [
                "add:NRCELL-5/NRREL-8:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-9:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-8:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-9:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "A_14": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "303",
            "scell_index": ["401"],
            "swap_scell_index": {"source_scell": ["401"], "target_scell": ["402"]},
            "case_level_params": [
                "add:NRCELL-303/NRREL-41:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-42:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-402:a6OffsetSCellSwapSsbRsrp=4",
                "add:NRCELL-303/NRREL-41:sCellOperationalMode=dlOnly",
                "add:NRCELL-303/NRREL-42:sCellOperationalMode=dlOnly",
                "modify:NRCELL-401:useAllowedCellListRsrp=true",
                "modify:NRCELL-402:useAllowedCellListRsrp=true",
                "modify:NRCELL-401:useAllowedCellListRsrq=true",
                "modify:NRCELL-402:useAllowedCellListRsrq=true",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["1"],
            "swap_scell_index": {"source_scell": ["1"], "target_scell": ["3"]},
            "case_level_params": [
                "add:NRCELL-5/NRREL-1:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-3:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-1:a6OffsetSCellSwapSsbRsrp=15",
                "add:NRCELL-5/NRREL-1:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-3:sCellOperationalMode=dlOnly",
            ],
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["1"],
            "swap_scell_index": {"source_scell": ["1"], "target_scell": ["3"]},
            "case_level_params": [
                "add:NRCELL-5/NRREL-1:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-3:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-1:a6OffsetSCellSwapSsbRsrp=15",
                "add:NRCELL-5/NRREL-1:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-3:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "B_1": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "303",
            "scell_index": ["21", "11"],
            "swap_scell_index": {"source_scell": ["21"], "target_scell": ["22"]},
            "case_level_params": [
                "add:NRCELL-303/NRREL-11:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-21:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-22:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-21:sCellOperationalMode=dlOnly",
                "add:NRCELL-303/NRREL-22:sCellOperationalMode=dlOnly",
                "add:NRCELL-303/NRREL-11:sCellOperationalMode=dlOnly",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["10", "8"],
            "swap_scell_index": {"source_scell": ["8"], "target_scell": ["11"]},
            "case_level_params": [
                "add:NRCELL-5/NRREL-8:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-10:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-11:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-8:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-10:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-11:sCellOperationalMode=dlOnly",
            ],
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["6", "8"],
            "swap_scell_index": {"source_scell": ["8"], "target_scell": ["9"]},
            "case_level_params": [
                "add:NRCELL-5/NRREL-6:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-8:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-9:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-6:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-8:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-9:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "B_5": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "303",
            "scell_index": ["401", "501"],
            "swap_scell_index": {
                "source_scell": ["401", "501"],
                "target_scell": ["402", "502"],
            },
            "case_level_params": [
                "add:NRCELL-303/NRREL-41:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-42:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-51:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-52:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-41:sCellOperationalMode=dlOnly",
                "add:NRCELL-303/NRREL-42:sCellOperationalMode=dlOnly",
                "add:NRCELL-303/NRREL-51:sCellOperationalMode=dlOnly",
                "add:NRCELL-303/NRREL-52:sCellOperationalMode=dlOnly",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["1", "2"],
            "swap_scell_index": {
                "source_scell": ["1", "2"],
                "target_scell": ["3", "4"],
            },
            "case_level_params": [
                "add:NRCELL-5/NRREL-1:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-2:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-3:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-1:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-2:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-3:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-4:sCellOperationalMode=dlOnly",
            ],
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["1", "2"],
            "swap_scell_index": {
                "source_scell": ["1", "2"],
                "target_scell": ["3", "4"],
            },
            "case_level_params": [
                "add:NRCELL-5/NRREL-1:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-2:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-3:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-1:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-2:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-3:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-4:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "B_19": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "303",
            "scell_index": ["401"],
            "swap_scell_index": {"source_scell": ["401"], "target_scell": ["402"]},
            "case_level_params": [
                "add:NRCELL-303/NRREL-41:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-42:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-41:sCellOperationalMode=dlOnly",
                "add:NRCELL-303/NRREL-42:sCellOperationalMode=dlOnly",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["1"],
            "swap_scell_index": {"source_scell": ["1"], "target_scell": ["3"]},
            "case_level_params": [
                "add:NRCELL-5/NRREL-1:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-3:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-1:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-3:sCellOperationalMode=dlOnly",
            ],
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["1"],
            "swap_scell_index": {"source_scell": ["1"], "target_scell": ["3"]},
            "case_level_params": [
                "add:NRCELL-5/NRREL-1:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-3:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-1:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-3:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "B_24": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "303",
            "scell_index": ["402", "502"],
            "swap_scell_index": {"source_scell": ["402"], "target_scell": ["401"]},
            "case_level_params": [
                "add:NRCELL-303/NRREL-41:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-42:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-52:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-303/NRREL-41:sCellOperationalMode=dlOnly",
                "add:NRCELL-303/NRREL-42:sCellOperationalMode=dlOnly",
                "add:NRCELL-303/NRREL-52:sCellOperationalMode=dlOnly",
                "modify:NRCELL-303/NRREL-41:sCellPrio=2",
                "modify:NRCELL-303/NRREL-42:sCellPrio=1",
                "modify:NRCELL-303/NRREL-52:sCellPrio=1",
                "modify:NRCELL-303/NRREL-51:sCellPrio=2",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["3", "4"],
            "swap_scell_index": {"source_scell": ["3"], "target_scell": ["1"]},
            "case_level_params": [
                "add:NRCELL-5/NRREL-1:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-3:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-4:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-5/NRREL-1:sCellPrio=2",
                "modify:NRCELL-5/NRREL-3:sCellPrio=1",
                "modify:NRCELL-5/NRREL-4:sCellPrio=1",
                "modify:NRCELL-5/NRREL-2:sCellPrio=2",
                "add:NRCELL-5/NRREL-1:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-3:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-4:sCellOperationalMode=dlOnly",
            ],
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "5",
            "scell_index": ["3", "4"],
            "swap_scell_index": {"source_scell": ["3"], "target_scell": ["1"]},
            "case_level_params": [
                "add:NRCELL-5/NRREL-1:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-3:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-5/NRREL-1:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-3:sCellOperationalMode=dlOnly",
                "add:NRCELL-5/NRREL-4:sCellOperationalMode=dlOnly",
                "modify:NRCELL-5/NRREL-1:sCellPrio=2",
                "modify:NRCELL-5/NRREL-3:sCellPrio=1",
                "modify:NRCELL-5/NRREL-4:sCellPrio=1",
                "modify:NRCELL-5/NRREL-2:sCellPrio=2",
            ],
        },
    },
}
