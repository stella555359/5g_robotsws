# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jun
:contact: jun.8.chen@nokia-sbell.com
"""

from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
SOURCE_BTS_ID = "NRBTS-" + str(tl.gnbs[0].global_bts_id)


T082_PA_BASE_VALUE_MAPPING_TABLE = {
    "0": {"0": "15"},
}


PCELL_MAPPING = {
    'bbMod_index': '1',
    'bbmod_index': ['1'],
    'cell_group_id': 1,
    'detail_cells_info': {'act5gRTPM': False,
                          'band': 'n78',
                          'cellDepType': 'SA+NSA',
                          'cellName': 'D510_Sector1',
                          'chBw': '100MHz',
                          'counters': {'activeUEs': 1},
                          'downlinkMimoMode': '4x4 or 4x2 Closed Loop Spatial Multiplexing',
                          'energySavingState': 'notEnergySaving',
                          'expectedCellSize': '15km',
                          'globalCellId': 1,
                          'id': {'configuration': 'MRBTS-36929/NRBTS-36929/NRCELL-1',
                                 'internal': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-36929/NRCELL_R-1'},
                          'maximumOutputPower': 32.7,
                          'nrCellType': '8DL4UL',
                          'nrarfcn': 639936,
                          'physicalCellId': 182,
                          'status': {'administrativeState': 'Unlocked',
                                     'barringStatus': 'unbarred',
                                     'blockingState': 'Unblocked',
                                     'operationalState': 'enabled',
                                     'proceduralStatus': 'configured',
                                     'usageState': 'Active'},
                          'subCellList': ['Subcell-0 (DL)',
                                          'Subcell-0 (UL)',
                                          'Subcell-1 (DL)'],
                          'technology': 'TDD'},
    'framestructure': '1116',
    'gscn': '1',
    'lcrId': 1,
    'maxNumOfSCellAlloc': '500',
    'meas_config': {
        'A1_scell_addition_rsrp_fdd': '40',
        'A1_scell_addition_rsrp_tdd': '56',
        'A2_ho_rsrp': '37',
        'A2_scell_release_rsrp': '24'},
    'nrCellIdentity': 151261185,
    'physicalCellId': 182,
    'rmod_index': '1',
    'ruIndex_in_init': 0,
    'ru_index_mapping': '0',
    'ssbfrequency': 639936,
    'weightForSCellSelection': '100'
}


TESTCASE_INFO_MAPPING_TABLE_9198 = {
    "A_B1": {
        "T082": {
            "running_gnb": "0",
            "pcell_index": "1",
            "framestructure": "11163ms",
            "cell_chbw": {"1": "20MHz"},
            "case_level_params": [],
        },
    },
    "B_B1": {
        "T082": {
            "running_gnb": "0",
            "pcell_index": "1",
            "framestructure": "1208",
            "cell_chbw": {"1": "40MHz"},
            "case_level_params": [],
        },
    },
    "B_B2": {
        "T082": {
            "running_gnb": "0",
            "pcell_index": "1",
            "framestructure": "1070",
            "cell_chbw": {"1": "60MHz"},
            "case_level_params": [],
        },
    },
    "B_B3": {
        "T082": {
            "running_gnb": "0",
            "pcell_index": "1",
            "framestructure": "11160ms",
            "cell_chbw": {"1": "80MHz"},
            "case_level_params": [],
        },
    },
    "B_B4": {
        "T082": {
            "running_gnb": "0",
            "pcell_index": "1",
            "framestructure": "11160ms",
            "cell_chbw": {"1": "100MHz"},
            "case_level_params": [
                "modify:NRCELL-1:actUlDftSOfdm=true",
                "modify:NRCELL-1:puschMappingType=TypeA",
                "modify:NRCELL-1:ulPtrs:actUlPtrs=false",
            ],
        },
    },
}
