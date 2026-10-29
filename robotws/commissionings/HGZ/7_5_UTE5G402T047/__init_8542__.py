from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Zhou Charlie'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'charlie.zhou@nokia-sbell.com'


# below info is dummy for debug use only
adjacent_gnb = {
    'gNbId': '10660',
    'gNbIdLength': '32',
    'mcc': '310',
    'mnc': '260',
    'mncLength': '3',
    # below is PCEll(TDD Cell) info on target gNB for handover use.
    'fiveGsTac': '270',
    'cellDepType': 'SA+NSA',
    'freqBandIndicatorNR': '41',
    'lcrId': '1',
    'nrarfcn': '512250',
    'physCellId': '924',
    # 'ssbFrequency': '128170',
    'chBw': '100MHz',
    'ssbScs': '30KHz',
    'scs': '30KHz',
    'ssBurstSetPeriod': '20',
    # for intra-freq
    # 'nrarfcn_intra': '127180',
}

Tdd_cell_1 = {
    'nrCellId': 1,
    'lcrId': '1',
    'nrCellGrpId': '0',
    'tddAbil': '2',
    'ru_index_in_testline_file': 0
}

Fdd_cell_1 = {
    'nrCellId': 2,
    'lcrId': '2',
    'nrCellGrpId': '1',
    'fddAbil': '1',
    'ru_index_in_testline_file': 1
}

F_T_ca_group_1 = {'pcell': Fdd_cell_1, 'scell': Tdd_cell_1}
T_F_ca_group_1 = {'pcell': Tdd_cell_1, 'scell': Fdd_cell_1}

ca_group_list = {'F+T': [F_T_ca_group_1], 'T+F': [T_F_ca_group_1]}
F_T_ALLOCATION = {'FDD': [Fdd_cell_1], 'TDD': [Tdd_cell_1]}
T_F_ALLOCATION = {'TDD': [Tdd_cell_1], 'FDD': [Fdd_cell_1]}
# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
# Left: TDD 248, FDD 494; Right: TDD 198, FDD 404
INIT_PA_F_T = {0: [0, 0]}
