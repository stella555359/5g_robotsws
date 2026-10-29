from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = "Fang Dandan"
__team__ = "I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS "
__email__ = "Dandan.Fang@nokia-sbell.com"

gnb_info = {
    "gNbId": "10359",
    "gNbIdLength": "22",
    "mcc": "262",
    "mnc": "3",
    "mncLength": "2",
    "enb_id": "10275",
}

Fdd_cell_1 = {
    "nrCellId": 1,
    "lcrId": "1",
    "nrCellGrpId": "0",
    "fddAbil": 1,
    "ru_index_in_testline_file": 0,
    "physCellId": "522",
    # below info is for handover use.
    'fiveGsTac': '270',
    'cellDepType': 'SA',
    'freqBandIndicatorNR': '66',
    'physCellId': '522',
    'ssbFrequency': '430850',
    'chBw': '20MHz',
    'ssbScs': '15KHz',
    'scs': '15 KHz',
    'ssBurstSetPeriod': '20',
}

Fdd_cell_2 = {
    "nrCellId": 3,
    "lcrId": "3",
    "nrCellGrpId": "2",
    "fddAbil": 1,
    "ru_index_in_testline_file": 1,
    "physCellId": "524",
    # below info is for handover use.
    'fiveGsTac': '270',
    'cellDepType': 'SA',
    'freqBandIndicatorNR': '71',
    'ssbFrequency': '127210',
    'chBw': '20MHz',
    'ssbScs': '15KHz',
    'scs': '15 KHz',
    'ssBurstSetPeriod': '20',
}

Tdd_cell_1 = {
    "nrCellId": 2,
    "lcrId": "2",
    "nrCellGrpId": "1",
    "tddAbil": 2,
    "ru_index_in_testline_file": 2,
    "physCellId": "523",
    'fiveGsTac': '270',
    'cellDepType': 'SA',
    'freqBandIndicatorNR': '41',
    'physCellId': '523',
    'ssbFrequency': '518910',
    'chBw': '100MHz',
    'ssbScs': '30 KHz',
    'scs': '30 KHz',
    'ssBurstSetPeriod': '20',
}

F_T_ca_group_1 = {"pcell": Fdd_cell_1, "scell": Tdd_cell_1}
F_T_ca_group_2 = {"pcell": Fdd_cell_2, "scell": Tdd_cell_1}

T_F_ca_group_1 = {"pcell": Tdd_cell_1, "scell": Fdd_cell_2}

ca_group_list = {"F+T": [F_T_ca_group_1, F_T_ca_group_2], "T+F": [T_F_ca_group_1]}
F_T_ALLOCATION = {'FDD': [Fdd_cell_2], 'TDD': [Tdd_cell_1]}
# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
INIT_PA_F_T = {0: [0, 0, 0]}

PCELL_BAD = 30
PCELL_GOOD = 0
SCELL_BAD = 40
SCELL_GOOD = 0

SCELL_LOW_THAN_BAD_MCS = 80
