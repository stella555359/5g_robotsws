from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Fang ludan'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'ludan.fang@nokia-sbell.com'


# NR_CELL_ID_MAPPING = BuiltIn().get_variable_value('${NR_CELL_ID_MAPPING}')

gnb_info = {
    'gNbId': '10152',
    'gNbIdLength': '32',
    'mcc': '310',
    'mnc': '260',
    'mncLength': '3',
    'enb_id': '4'
}
adjacent_gnb = {
    'gNbId': '10153',
    'gNbIdLength': '32',
    'mcc': '310',
    'mnc': '260',
    'mncLength': '3',
    # below is PCEll(FDD Cell) info on target gNB for handover use.
    'fiveGsTac': '270',
    'cellDepType': 'SA+NSA',
    'freqBandIndicatorNR': '71',
    'lcrId': '1',
    'nrarfcn': '126900',
    'physCellId': '195',
    'ssbFrequency': '126750',
    'chBw': '20MHz',
    'ssbScs': '15KHz',
    'scs': '15 KHz',
    'ssBurstSetPeriod': '20',
    # for intra-freq
    'nrarfcn_intra': '125780',
}


Fdd_cell_1 = {
    'nrCellId': 2,                      # Keep it
    'lcrId': '2',                       # Keep it
    'nrCellGrpId': '1',                 # Keep it
    'fddAbil': '2',
    # below info is for handover use.
    'fiveGsTac': '270',
    'cellDepType': 'SA+NSA',            # Get from GNB
    'freqBandIndicatorNR': '71',
    'lcrId': '2',
    'nrarfcn': '125780',
    'physCellId': '176',
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
    'tddAbil': '1',
    'ru_index_in_testline_file': '0',
    # # below info is for handover use.
    # 'fiveGsTac': '270',
    # 'cellDepType': 'SA+NSA',  # Get from GNB
    # 'freqBandIndicatorNR': '41',
    # 'ssbFrequency': '509070',
    # 'chBw': '100MHz',
    # 'ssbScs': '30 KHz',
    # 'scs': '30 KHz',
    # 'ssBurstSetPeriod': '20'
}

# ca_group_1 = {'pcell': Fdd_cell_1, 'scell': Tdd_cell_1}
# ca_group_2 = {'pcell': Fdd_cell_2, 'scell': Tdd_cell_1}
# ca_group_3 = {'pcell': Fdd_cell_3, 'scell': Tdd_cell_1}

# ca_group_list = [ca_group_1, ca_group_2, ca_group_3]
# F_T_ALLOCATION = {'FDD': [Fdd_cell_1, Fdd_cell_2, Fdd_cell_3], 'TDD': [Tdd_cell_1]}
# # Initial PA values for RUs, format should be as bellow:
# # { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# # GNB index and RU sequence should align with testline config file
# # Left: TDD 491, FDD 492, FDD 493, FDD 494; Right: FDD 495, TDD 496
# INIT_PA_F_T = {0: [0, 0, 0, 0], 1: [127, 127]}

ca_group_1 = {'pcell': Fdd_cell_1, 'scell': Tdd_cell_1}

ca_group_list = [ca_group_1]
F_T_ALLOCATION = {'FDD': [Fdd_cell_1], 'TDD': [Tdd_cell_1]}
# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
# Left: TDD 936, FDD 937; Right: FDD 938, TDD 939
INIT_PA_F_T = {0: [0, 0, 127, 127]}
PA_OUT_PORTS = [1, 2, 3, 4]
PA_ROWS = 32

# for 5GC0000732 A3 HO
A3_TARGET_SSB_FRE = 509070

# For align bwp, created by tony
F_T_ALLOCATION_ALIGNBWP = {'FDD': [2], 'TDD': [1]}
ALL_CELLS = F_T_ALLOCATION_ALIGNBWP['FDD'] + F_T_ALLOCATION_ALIGNBWP['TDD']
