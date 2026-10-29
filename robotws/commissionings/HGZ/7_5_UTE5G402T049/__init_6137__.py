from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Wang Yixiang'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'yixiang.x.wang@nokia-sbell.com'

F_T_ALLOCATION = {'FDD': [2, 3], 'TDD': [1, 4, 5]}
ALL_CELLS = F_T_ALLOCATION['FDD'] + F_T_ALLOCATION['TDD']

# F1 F2 refer to 1st and 2nd cell in F_T_ALLOCATION['FDD']
# same for T1, T2, T3

F1_T1_T3_3CC_CA_GROUP_COMMON = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][2]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None}
            }
        },
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['TDD'][0], F_T_ALLOCATION['TDD'][2]]
}

F1_F2_T1_3CC_CA_GROUP = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'}
            }
        }
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['TDD'][0]]
}

F1_F2_T1_T2_4CC_CA_GROUP = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'}
            }
        }
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['TDD'][0], F_T_ALLOCATION['TDD'][1]]
}

F1_T1_F2_T3_4CC_CA_GROUP_COMMON = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][2]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None}
            }
        },
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['TDD'][0], F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['TDD'][2]]
}

# 5CC is for scell selection
F1_F2_T1_T2_T3_5CC_CA_GROUP = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][2]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'}
            }
        },
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['TDD'][0], F_T_ALLOCATION['TDD'][1],
                            F_T_ALLOCATION['TDD'][2]]
}

F1_F2_T1_NOT2_NOT3_3CC_CA_GROUP = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None},
                F_T_ALLOCATION['TDD'][2]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None}
            }
        }
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['TDD'][0]]
}

F1_F2_T1_NOT2_NOT3_3CC_CA_GROUP_covbasedA1 = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None},
                F_T_ALLOCATION['TDD'][2]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None}
            }
        }
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['TDD'][0]]
}

F1_T1_T2_NOF2_NOT3_3CC_CA_GROUP = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None},
                F_T_ALLOCATION['TDD'][2]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None}
            }
        },
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['TDD'][0], F_T_ALLOCATION['TDD'][1]]
}

F1_T1_T2_NOF2_NOT3_3CC_CA_GROUP_covbasedA1 = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None},
                F_T_ALLOCATION['TDD'][2]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None}
            }
        },
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['TDD'][0], F_T_ALLOCATION['TDD'][1]]
}

F1_T1_T2_3CC_CA_SCELL_SWAP = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'covBasedA1',
                    'sCellPrio': '1'},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['TDD'][2]: {
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'covBasedA1',
                    'sCellPrio': '2'},
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None}
            }
        }
    ],
    # before scell swap
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][1]],
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['TDD'][1]],
    # after scell swap
    'scell_swap_ul': [F_T_ALLOCATION['TDD'][2]],
    'scell_swap_dl': [F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['TDD'][2]]
}

INIT_PA_F1_F2_T1_T2 = {0: [0, 0, 0, 0]}
INIT_PA_F1_T1_F2_T3 = {0: [0, 0, 0, 127]}

PCELL_BAD = 40
PCELL_GOOD = 0
PCELL_GOOD_FOR_FDD_ADD = 35
SCELL_BAD = 25
SCELL_GOOD = 0
FDD_PA_SUSPEND = 35
TDD_PA_SUSPEND = 25
PCELL_SUPEND = [FDD_PA_SUSPEND, TDD_PA_SUSPEND]
SCELL_SUPEND = [TDD_PA_SUSPEND, FDD_PA_SUSPEND]

SCELL_A2_RELEASED_PA = 47

# SCELL SWAP
SOURCE_SCELL_BAD = 30
TARGET_SCELL_GOOD = 0
INIT_PA_BEFORE_SCELL_SWAP = {0: [127, 0, 0, 0]}
SOURCE_TARGET_SCELLS = [F_T_ALLOCATION['TDD'][1], F_T_ALLOCATION['TDD'][2]]

# CB006137_C_US_B27_01 Transform Precoder PA adjust for pcell
PA_PCELL_BAD_RETRY_START = 44
PA_PCELL_BAD_RETRY_END = 52

# DL RLQ
PCELL_BAD_RLQ = 30
PCELL_GOOD_RLQ = 0
SCELL_BAD_RLQ = 25
SCELL_GOOD_RLQ = 0

SCELL_LOW_THAN_BAD_MCS = 40

# PEAK tput expected values: For 6137-A cases
EXP_DL_F20M_2x2_256QAM = 217
EXP_DL_T100M_4x4_256QAM = 1500
EXP_DL_T60M_4x4_256QAM = 881
EXP_DL_F10M_2x2_256QAM = 98
EXP_UL_F20M_2x2_64QAM = 78.9
EXP_UL_T100M_2x2_64QAM = 76.9
# peak value for 6137-A scell swap cases
EXP_UL_T60M_2x2_64QAM = 35    # before && after swap
EXP_DL_T60M_2x2_256QAM = 460  # before swap
EXP_DL_T100M_4x4_256QAM_8406 = 975
EXP_DL_T60M_4x4_256QAM_8406 = 578
EXP_UL_T100M_2x2_64QAM_8406 = 119

# for CB006137-B
FDD2_ARFCNDL_NON_CONTINUOUS = 129180
FDD2_ARFCNDL_CONTINUOUS = 128700
