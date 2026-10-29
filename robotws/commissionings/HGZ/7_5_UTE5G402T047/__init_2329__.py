from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Cui Lingxue'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'lingxue.cui@nokia-sbell.com'


# below info is dummy for debug use only
adjacent_gnb = {
    'gNbId': '10660',
    'gNbIdLength': '32',
    'mcc': '262',
    'mnc': '3',
    'mncLength': '2',
    # below is PCEll(FDD Cell) info on target gNB for handover use.
    'fiveGsTac': '270',
    'cellDepType': 'SA',
    'freqBandIndicatorNR': '71',
    'lcrId': '1',
    'nrarfcn': '128380',
    'physCellId': '938',
    'ssbFrequency': '128170',
    'chBw': '20MHz',
    'ssbScs': '15KHz',
    'scs': '15 KHz',
    'ssBurstSetPeriod': '20',
    # for intra-freq
    'nrarfcn_intra': '127180',
}

Fdd_cell_1 = {
    'nrCellId': 2,
    'lcrId': '2',
    'nrCellGrpId': '1',
    'fddAbil': '1',
    'ru_index_in_testline_file': 1
}

Tdd_cell_1 = {
    'nrCellId': 1,
    'lcrId': '1',
    'nrCellGrpId': '0',
    'tddAbil': '2',
    'ru_index_in_testline_file': 0
}

F_T_ca_group_1 = {'pcell': Fdd_cell_1, 'scell': Tdd_cell_1}
T_F_ca_group_1 = {'pcell': Tdd_cell_1, 'scell': Fdd_cell_1}

ca_group_list = {'F+T': [F_T_ca_group_1], 'T+F': [T_F_ca_group_1]}
F_T_ALLOCATION = {'FDD': [Fdd_cell_1], 'TDD': [Tdd_cell_1]}
# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
# Left: TDD 248, FDD 494; Right: TDD 198, FDD 404
INIT_PA_F_T = {0: [0, 0]}
