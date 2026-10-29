from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Wang Yixiang'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'yixiang.x.wang@nokia-sbell.com'

# NR_CELL_ID_MAPPING = BuiltIn().get_variable_value('${NR_CELL_ID_MAPPING}')

# # record the target gNB and target cell's info, for TL251, the target is TL254, mapping is to record TL254 info
# adjacent_gnb_tdd_cell_1 = {
#     'gNbId': '564',
#     'gNbIdLength': '32',
#     'mcc': '460',
#     'mnc': '2',
#     'mncLength': '2',
#     # below is PCEll(FDD Cell) info on target gNB for handover use.
#     'fiveGsTac': '270',
#     'cellDepType': 'SA',
#     'freqBandIndicatorNR': '78',
#     'lcrId': '2',
#     'nrarfcn': '636666',
#     'physCellId': '253',
#     'ssbFrequency': '636576',
#     'chBw': '60MHz',
#     'ssbScs': '30 KHz',
#     'scs': '30 KHz',
#     'ssBurstSetPeriod': '20',
# }
#
# adjacent_gnb_fdd_cell_1 = {
#     'gNbId': '564',
#     'gNbIdLength': '32',
#     'mcc': '460',
#     'mnc': '2',
#     'mncLength': '2',
#     # below is PCEll(FDD Cell) info on target gNB for handover use.
#     'fiveGsTac': '270',
#     'cellDepType': 'SA',
#     'freqBandIndicatorNR': '1',
#     'lcrId': '1',
#     'nrarfcn': '428000',
#     'physCellId': '252',
#     'ssbFrequency': '427970',
#     'chBw': '20MHz',
#     'ssbScs': '15KHz',
#     'scs': '15 KHz',
#     'ssBurstSetPeriod': '20',
# }

Fdd_cell_1 = {
    'nrCellId': 2,
    'lcrId': '2',
    'nrCellGrpId': '1',
    'abil_idx': 2,
    # below info is for handover use.
    'fiveGsTac': '270',
    'cellDepType': 'SA',
    'nrarfcn': '128380',
    'freqBandIndicatorNR': '71',
    'physCellId': '255',
    'ssbFrequency': '128170',
    'chBw': '20MHz',
    'ssbScs': '15KHz',
    'scs': '15 KHz',
    'ssBurstSetPeriod': '20',
    'ru_index_in_testline_file': 1
}

Tdd_cell_1 = {
    'nrCellId': 1,
    'lcrId': '1',
    'nrCellGrpId': '0',
    'abil_idx': 1,
    # below info is for handover use.
    'fiveGsTac': '270',
    'cellDepType': 'SA+NSA',
    'freqBandIndicatorNR': '41',
    'physCellId': '254',
    'nrarfcn': '510306',
    'ssbFrequency': '510270',
    'chBw': '100MHz',
    'ssbScs': '30 KHz',
    'scs': '30 KHz',
    'ssBurstSetPeriod': '20',
    'ru_index_in_testline_file': 0
}


F_T_ca_group_1 = {'pcell': Fdd_cell_1, 'scell': Tdd_cell_1}
T_F_ca_group_1 = {'pcell': Tdd_cell_1, 'scell': Fdd_cell_1}

ca_group_list = {'F+T': [F_T_ca_group_1], 'T+F': [T_F_ca_group_1]}

F_T_ALLOCATION = {'FDD': [Fdd_cell_1], 'TDD': [Tdd_cell_1]}

# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
# left: FDD 255, TDD 254; Right: FDD 252, TDD 253
INIT_PA_F_T = {0: [0, 0]}

# INIT_PA_2329_INTER_FREQ_BEFORE_HO = {0: [0, 0], 1: [0, 15]}
# INIT_PA_2329_INTER_FREQ_TO_TRIGGER_HO = {0: [0, 30], 1: [0, 10]}

PCELL_BAD = 30
PCELL_GOOD = 0
SCELL_BAD = 40
SCELL_GOOD = 0

SCELL_A2_RELEASED_PA = 50
SCELL_LOW_THAN_BAD_MCS = 60

A1_THRES_HO_SSB_RSRP_SA = 100
A2_THRES_HO_SSB_RSRP_SA = 78

PA_OUT_PORTS = [5, 6, 7, 8]
PA_ROWS = 32

# Tput values
PCELL_DL_EXP_TPUT_100M_1116_3 = 1482
PCELL_UL_EXP_TPUT_100M_1116_3 = 140
SCELL_DL_EXP_TPUT_20M_1116_3 = 203.8
