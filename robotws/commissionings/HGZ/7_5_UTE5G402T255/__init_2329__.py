from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Wang Yixiang'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'yixiang.x.wang@nokia-sbell.com'


adjacent_gnb_tdd_cell_1 = {
    'gNbId': '1173',
    'gNbIdLength': '32',
    'mcc': '262',
    'mnc': '3',
    'mncLength': '2',
    # below is PCEll(FDD Cell) info on target gNB for handover use.
    'fiveGsTac': '270',
    'cellDepType': 'SA',
    'freqBandIndicatorNR': '41',
    'lcrId': '2',
    'nrarfcn': '519000',
    'physCellId': '939',
    'ssbFrequency': '518910',
    'chBw': '100MHz',
    'ssbScs': '30 KHz',
    'scs': '30 KHz',
    'ssBurstSetPeriod': '20',
}

adjacent_gnb_fdd_cell_1 = {
    'gNbId': '1173',
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
}


Fdd_cell_1 = {
    'nrCellId': 2,                      # Keep it
    'lcrId': '2',                       # Keep it
    'nrCellGrpId': '1',                 # Keep it
    'abil_idx': '2',
    # below info is for handover use.
    'fiveGsTac': '270',
    'cellDepType': 'SA+NSA',            # Get from GNB
    'freqBandIndicatorNR': '71',
    'lcrId': '2',
    'nrarfcn': '125780',
    'physCellId': '937',
    'ssbFrequency': '125570',
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
    'abil_idx': '1',
    'ru_index_in_testline_file': '0',
    # below info is for handover use.
    'fiveGsTac': '270',
    'cellDepType': 'SA+NSA',  # Get from GNB
    'freqBandIndicatorNR': '41',
    'ssbFrequency': '509790',
    'chBw': '100MHz',
    'ssbScs': '30 KHz',
    'scs': '30 KHz',
    'ssBurstSetPeriod': '20'
}

F_T_ca_group_1 = {'pcell': Fdd_cell_1, 'scell': Tdd_cell_1}
T_F_ca_group_1 = {'pcell': Tdd_cell_1, 'scell': Fdd_cell_1}

ca_group_list = {'F+T': [F_T_ca_group_1], 'T+F': [T_F_ca_group_1]}

F_T_ALLOCATION = {'FDD': [Fdd_cell_1], 'TDD': [Tdd_cell_1]}

# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
# Left: TDD 936, FDD 937; Right: FDD 938, TDD 939
# if PA value of some RU is set to -1, it means this RU's PA ports won't be updated.
# For example: HO_A2_PA_F_T = {0: [-1, 20]}
INIT_PA_F_T = {0: [0, 0, 127, 127]}

INIT_PA_2329_INTER_FREQ_BEFORE_HO = {0: [0, 0], 1: [0, 15]}
INIT_PA_2329_INTER_FREQ_TO_TRIGGER_HO = {0: [30, 0], 1: [0, 15]}

PCELL_BAD = 30
PCELL_GOOD = 0
SCELL_BAD = 25
SCELL_GOOD = 0

SCELL_A2_RELEASED_PA = 47
SCELL_LOW_THAN_BAD_MCS = 60

A1_THRES_HO_SSB_RSRP_SA = 90
A2_THRES_HO_SSB_RSRP_SA = 78

PA_OUT_PORTS = [1, 2, 3, 4]
PA_ROWS = 32

# Tput values
PCELL_DL_EXP_TPUT_100M_1116_3 = 1482
PCELL_UL_EXP_TPUT_100M_1116_3 = 150
SCELL_DL_EXP_TPUT_20M_1116_3 = 203.8
