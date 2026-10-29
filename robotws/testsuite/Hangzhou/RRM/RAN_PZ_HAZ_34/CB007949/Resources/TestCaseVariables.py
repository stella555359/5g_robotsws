# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lin Stella
:contact: stella.lin@nokia-sbell.com
"""

from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
SOURCE_BTS_ID = "NRBTS-" + str(tl.gnbs[0].global_bts_id)
# TARGET_BTS_ID = "NRBTS-" + str(tl.gnbs[1].global_bts_id)

T820_PA_BASE_VALUE_MAPPING_TABLE = {
    "0": {
        "0": "10",
        "1": "33",
        "2": "0",
        "3": "25",
        "4": "25",
        "5": "25",
        "6": "25",
    },
    "1": {"0": "15", "1": "5", "2": "5"},
}

T081_PA_BASE_VALUE_MAPPING_TABLE = {
    "0": {"0": "5", "1": "10", "2": "5", "3": "35", "4": "35", "5": "50"},
    "1": {"0": "0"},
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

TESTCASE_INFO_MAPPING_TABLE_7949 = {
    "A_B1_01": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "302",
            "scell_index": ["402", "502"],
            "case_level_params": [
                "add:NRCELL-302/NRREL-52:sCellAdditionMethod=blind",
                "add:NRCELL-302/NRREL-52:sCellOperationalMode=dlOnly",
                "modify:NRCELL-302/NRREL-42:sCellAdditionMethod=blind",
                "add:NRCELL-302/NRREL-12:sCellAdditionMethod=blind",
                "add:NRCELL-302/NRREL-12:sCellOperationalMode=dlOnly",
                "delete:NRCELL-302/NRREL-41:sCellAdditionMethod",
                "delete:NRCELL-302/NRREL-41:sCellOperationalMode",
                "delete:NRCELL-302/NRREL-41:sCellPrio",
                "delete:NRCELL-302/NRREL-42:sCellPrio",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "3",
            "scell_index": ["4", "5"],
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=blind",
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=blind",
                # "add:NRCELL-3/NRREL-6:sCellAdditionMethod=blind",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-5:sCellOperationalMode=dlOnly",
                # "add:NRCELL-3/NRREL-6:sCellOperationalMode=dlOnly",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "3",
            "scell_index": ["4", "5"],
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=blind",
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=blind",
                # "add:NRCELL-3/NRREL-6:sCellAdditionMethod=blind",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-5:sCellOperationalMode=dlOnly",
                # "add:NRCELL-3/NRREL-6:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "B_B2_01": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "402",
            "scell_index": ["302", "502"],
            "cell_chbw": {"401": "40MHz", "402": "40MHz"},
            "case_level_params": [
                "add:NRCELL-402/NRREL-32:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-402/NRREL-52:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-401/NRREL-31:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-401/NRREL-51:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-401/NRREL-31:sCellOperationalMode=dlOnly",
                "add:NRCELL-401/NRREL-51:sCellOperationalMode=dlOnly",
                "add:NRCELL-402/NRREL-32:sCellOperationalMode=dlOnly",
                "add:NRCELL-402/NRREL-52:sCellOperationalMode=dlOnly",
                # "add:NRCELL-302/NRREL-52:sCellAdditionMethod=covBasedA1",
                # "add:NRCELL-301/NRREL-51:sCellAdditionMethod=covBasedA1",
                # "add:NRCELL-302/NRREL-52:sCellOperationalMode=dlOnly",
                # "add:NRCELL-301/NRREL-51:sCellOperationalMode=dlOnly",
                "modify:NRCELL-402:gscnOrSsPbchArfcn=0",
                "modify:NRCELL-402/NRHOIF-2:ssbFrequency=512910",
                "modify:NRCELL-401/NRHOIF-2:ssbFrequency=511710",
                "modify:MRBTS-10611/NRBTS-10611:actHoOptimizationCa=true",
                "delete:NRCELL-302/NRREL-41:sCellAdditionMethod",
                "delete:NRCELL-302/NRREL-41:sCellOperationalMode",
                "delete:NRCELL-302/NRREL-41:sCellPrio",
                "delete:NRCELL-302/NRREL-42:sCellPrio",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "1",
            "scell_index": ["2", "5"],
            "cell_chbw": {"2": "40MHz", "4": "40MHz"},
            "case_level_params": [
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=covBasedA1",
                "modify:MRBTS-10997/NRBTS-10997:actHoOptimizationCa=true",
                "modify:NRCELL-3:gscnOrSsPbchArfcn=0",
                "modify:NRCELL-1/NRHOIF-1:ssbFrequency=522270",
                "modify:NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41",
                "modify:NRCELL-3/NRHOIF-1:ssbFrequency=527790",
                "modify:NRCELL-3/NRHOIF-1:freqBandIndicatorNR=41",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
                "add:NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-5:sCellOperationalMode=dlOnly",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "1",
            "scell_index": ["2", "5"],
            "cell_chbw": {"2": "40MHz", "4": "40MHz"},
            "case_level_params": [
                "add:NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=covBasedA1",
                "modify:MRBTS-79/NRBTS-79:actHoOptimizationCa=true",
                "modify:NRCELL-3:gscnOrSsPbchArfcn=0",
                "modify:NRCELL-1/NRHOIF-1:ssbFrequency=522270",
                "modify:NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41",
                "modify:NRCELL-3/NRHOIF-1:ssbFrequency=527790",
                "modify:NRCELL-3/NRHOIF-1:freqBandIndicatorNR=41",
                "add:NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly",
                "add:NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-5:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "A_B3_03": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "301",
            "scell_index": ["303"],
            "framestructure": {"303": "1070"},
            "cell_chbw": {"301": "100MHz", "303": "60MHz"},
            "case_level_params": [
                "delete:NRCELL-301/NRREL-41:sCellAdditionMethod",
                "delete:NRCELL-301/NRREL-41:sCellOperationalMode",
                "delete:NRCELL-301/NRREL-41:sCellPrio",
                "delete:NRCELL-301/NRREL-42:sCellAdditionMethod",
                "delete:NRCELL-301/NRREL-42:sCellOperationalMode",
                "delete:NRCELL-301/NRREL-42:sCellPrio",
                "add:NRCELL-301/NRREL-33:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-301/NRREL-33:sCellOperationalMode=dlOnly",
            ],
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "1",
            "scell_index": ["5"],
            "framestructure": {"5": "1070"},
            "cell_chbw": {"5": "60MHz"},
            "case_level_params": [
                "add:NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "1",
            "scell_index": ["5"],
            "framestructure": {"5": "1070"},
            "cell_chbw": {"5": "60MHz"},
            "case_level_params": [
                "add:NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "A_B4_02": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "302",
            "scell_index": ["402", "502"],
            "case_level_params": [
                "add:NRCELL-302/NRREL-52:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-302:iniNumSCellsToActivate=1",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "3",
            "scell_index": ["4", "5"],
            "case_level_params": [
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-3:iniNumSCellsToActivate=1",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "3",
            "scell_index": ["4", "5"],
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-3:iniNumSCellsToActivate=1",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-5:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "D_Extend_02": {
        "T820": {
            # "running_gnb": "0",
            # "pcell_index": "302",
            # "scell_index": ["402", "502"],
            # "case_level_params": [
            #     "add:NRCELL-302/NRREL-52:sCellAdditionMethod=covBasedA1",
            #     "add:NRCELL-302/NRREL-52:sCellOperationalMode=dlOnly",
            #     "delete:NRCELL-301/NRREL-41:sCellAdditionMethod",
            #     "delete:NRCELL-301/NRREL-41:sCellOperationalMode",
            # ],
            # "lte_cell_index": "121",
            # "lte_bts_id": "10316",
            "running_gnb": "0",
            "pcell_index": "301",
            "scell_index": ["401", "501"],
            "case_level_params": [
                "add:NRCELL-301/NRREL-51:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-301/NRREL-51:sCellOperationalMode=dlOnly",
                "delete:NRCELL-301/NRREL-42:sCellAdditionMethod",
                "delete:NRCELL-301/NRREL-42:sCellOperationalMode",
                "modify:NRCELL-401:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=48",
                "modify:NRCELL-501:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "3",
            "scell_index": ["4", "5"],
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-5:sCellOperationalMode=dlOnly",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "3",
            "scell_index": ["4", "5"],
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-5:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "B_B3_01": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "302",
            "scell_index": ["402", "502"],
            "case_level_params": [
                "add:NRCELL-302/NRREL-52:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-302/NRREL-52:sCellOperationalMode=dlOnly",
                "modify:NRCELL-302:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34",
                "modify:NRCELL-402:a2MeasSCellRelEnabled=rsrp",
                "modify:NRCELL-402:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=54",
                "modify:NRCELL-502:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=64",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "3",
            "scell_index": ["4", "5"],
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-5:sCellOperationalMode=dlOnly",
                "modify:NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=64",
                "modify:NRCELL-5:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=50",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "3",
            "scell_index": ["4", "5"],
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-4:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=64",
                "modify:NRCELL-5:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=60",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-5:sCellOperationalMode=dlOnly",
            ],
        },
    },
    "B_B4_01": {
        "T820": {
            "running_gnb": "0",
            "pcell_index": "302",
            "scell_index": ["402", "502"],
            "case_level_params": [
                "add:NRCELL-302/NRREL-52:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-302/NRREL-21:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-302/NRREL-52:sCellOperationalMode=dlOnly",
                "add:NRCELL-302/NRREL-21:sCellOperationalMode=dlOnly",
                "modify:NRCELL-302:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=80",
                "modify:NRCELL-302:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90",
            ],
            "lte_cell_index": "121",
            "lte_bts_id": "10316",
        },
        "T081": {
            "running_gnb": "0",
            "pcell_index": "3",
            "scell_index": ["4", "5"],
            "cell_chbw": {"2": "40MHz", "4": "40MHz"},
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-6:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-8:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-5:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-6:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-8:sCellOperationalMode=dlOnly",
                "modify:NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=76",
                "modify:NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=86",
            ],
        },
        "T079": {
            "running_gnb": "0",
            "pcell_index": "3",
            "scell_index": ["4", "5"],
            "cell_chbw": {"2": "40MHz", "4": "40MHz"},
            "case_level_params": [
                "add:NRCELL-3/NRREL-4:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-5:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-6:sCellAdditionMethod=covBasedA1",
                "add:NRCELL-3/NRREL-8:sCellAdditionMethod=covBasedA1",
                "modify:NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=73",
                "modify:NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=83",
                "add:NRCELL-3/NRREL-4:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-5:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-6:sCellOperationalMode=dlOnly",
                "add:NRCELL-3/NRREL-8:sCellOperationalMode=dlOnly",
            ],
        },
    },
}

SWCONFIG_8941 = [
    "0x600012=1",
    "0x190297=1",
    "0x190305=1",
    "0x600017=1",
    "0x190306=1",
    "0x600018=1",
]
