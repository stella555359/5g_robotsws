__maintainer__ = 'Liu Zheng'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'zheng.4.liu@nokia-sbell.com'


T_F_ALLOCATION = {'TDD': [1, 4, 5], 'FDD': [2, 3]}
ALL_CELLS = T_F_ALLOCATION['TDD'] + T_F_ALLOCATION['FDD']

F_T_ALLOCATION_6137 = {'FDD': [2, 3], 'TDD': [1, 4, 5]}

PA_END_FOR_UL_SUSPEND = 50
PA_END_FOR_DL_SUSPEND = 56  # match cqi as 2 ,not trigger overheating

# F1 F2 refer to 1st and 2nd cell in F_T_ALLOCATION['FDD']
# same for T1, T2, T3

T1_F1_T3_F2_4CC_CA_GROUP_COMMON = {
    'pcell_id': T_F_ALLOCATION['TDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                T_F_ALLOCATION['FDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'},
                T_F_ALLOCATION['TDD'][2]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                T_F_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'}
            }
        }
    ],
    'verify_scell_add_ul': [T_F_ALLOCATION['FDD'][0]],
    'verify_scell_add_dl': [T_F_ALLOCATION['FDD'][0], T_F_ALLOCATION['TDD'][2], T_F_ALLOCATION['FDD'][1]]
}

T1_F1_T2_F2_4CC_CA_GROUP_COMMON = {
    'pcell_id': T_F_ALLOCATION['TDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                T_F_ALLOCATION['FDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'},
                T_F_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                T_F_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'}
            }
        }
    ],
    'verify_scell_add_ul': [T_F_ALLOCATION['FDD'][0]],
    'verify_scell_add_dl': [T_F_ALLOCATION['FDD'][0], T_F_ALLOCATION['TDD'][1], T_F_ALLOCATION['FDD'][1]]
}

T1_F1_F2_3CC_CA_GROUP_COMMON = {
    'pcell_id': T_F_ALLOCATION['TDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                T_F_ALLOCATION['FDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'},
                T_F_ALLOCATION['TDD'][2]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None},
                T_F_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
            }
        },
    ],
    'verify_scell_add_ul': [T_F_ALLOCATION['FDD'][0]],
    'verify_scell_add_dl': [T_F_ALLOCATION['FDD'][0], T_F_ALLOCATION['FDD'][1]]
}

F1_F2_T1_T2_4CC_CA_GROUP_6137 = {
    'pcell_id': F_T_ALLOCATION_6137['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION_6137['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION_6137['TDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION_6137['TDD'][2]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'}
            }
        }
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION_6137['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION_6137['FDD'][1], F_T_ALLOCATION_6137['TDD'][0], F_T_ALLOCATION_6137['TDD'][2]]
}

# block the AWHHH signal
INIT_PA_T1_F1_T3_F2 = {0: [0, 0, 0, 127]}

# unblock the AWHHH signal
INIT_PA_T1_F1_T2_F2 = {0: [0, 0, 0, 3]}

PCELL_BAD = 30
PCELL_GOOD = 0
# PCELL_GOOD_FOR_FDD_ADD = 35
SCELL_BAD = 25
SCELL_GOOD = 0
# FDD_PA_SUSPEND = 35
# TDD_PA_SUSPEND = 25
# PCELL_SUPEND = [FDD_PA_SUSPEND, TDD_PA_SUSPEND]
# SCELL_SUPEND = [TDD_PA_SUSPEND, FDD_PA_SUSPEND]
#
SCELL_A2_RELEASED_PA = 50
A2_THRES_SCELL_REL_SSB_RSRP = 60
PA_PCELL_DL_BLER = 17

#
# # SCELL SWAP
# SOURCE_SCELL_BAD = 30
# TARGET_SCELL_GOOD = 0
# INIT_PA_BEFORE_SCELL_SWAP = {0: [127, 0, 0, 0]}
# SOURCE_TARGET_SCELLS = [F_T_ALLOCATION['TDD'][1], F_T_ALLOCATION['TDD'][2]]
#
# # CB006137_C_US_B27_01 Transform Precoder PA adjust for pcell
# PA_PCELL_BAD_RETRY_START = 45
# PA_PCELL_BAD_RETRY_END = 50

gnb_info = {
    'gNbId': '255',
    'gNbIdLength': '32',
    'mcc': '262',
    'mnc': '3',
    'mncLength': '2',
}

Tdd_cell_1_for_pcell_change = {
    'nrCellId': 1,
    'lcrId': '1',
    'nrCellGrpId': '0',
    'tddAbil': '1',
    'ru_index_in_testline_file': 0,
    'cellDepType': 'SA+NSA',
    'freqBandIndicatorNR': '41',
    'ssbFrequency': '510750',
    'chBw': '100MHz',
    'ssbScs': '30 KHz',
    'scs': '30 KHz',
    'ssBurstSetPeriod': '20'
}

Fdd_cell_1_for_pcell_change = {
    'nrCellId': 2,
    'lcrId': '2',
    'nrCellGrpId': '1',
    'fddAbil': '1',
    'ru_index_in_testline_file': 1,
    'cellDepType': 'SA+NSA',
    'freqBandIndicatorNR': '71',
    'ssbFrequency': '125570',
    'chBw': '20MHz',
    'ssbScs': '15KHz',
    'scs': '15 KHz',
    'ssBurstSetPeriod': '20',
}

CA_ALLOCATION_FOR_PCELL_CHANGE = {'FDD': [Fdd_cell_1_for_pcell_change], 'TDD': [Tdd_cell_1_for_pcell_change]}
