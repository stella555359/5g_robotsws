from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Cui Lingxue'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'lingxue.cui@nokia-sbell.com'

Fdd_cell_1 = {
    'nrCellId': 1,
    'lcrId': '1',
    'nrCellGrpId': '0'
}

Tdd_cell_1 = {
    'nrCellId': 2,
    'lcrId': '2',
    'nrCellGrpId': '1'
}

T_F_ca_group_1 = {'pcell': Tdd_cell_1, 'scell': Fdd_cell_1}

ca_group_list = {'T+F': [T_F_ca_group_1]}

F_T_ALLOCATION = {'FDD': [Fdd_cell_1], 'TDD': [Tdd_cell_1]}

# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
INIT_PA_F_T = {0: [0, 0]}
PCELL_BAD = 30
PCELL_GOOD = 0
SCELL_BAD = 40
SCELL_GOOD = 0

SCELL_LOW_THAN_BAD_MCS = 65
