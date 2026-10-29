__maintainer__ = 'Zhang Yuan'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS'

# F_T_ALLOCATION = {'FDD': [2, 3], 'TDD': [1, 4, 5]} TL049 same with TL255
F_T_ALLOCATION = {'FDD': [2, 3], 'TDD': [1, 4, 5]}
ALL_CELLS = F_T_ALLOCATION['FDD'] + F_T_ALLOCATION['TDD']
INIT_PA_F1_F2_T1_T2_9311 = {0: [0, 0, 0, 3]}

# T1:F4,T2,T3,F4,F5 and T1+F4 CA
T1_F4_2CC_CA_T1_F5_T2_T3_NonCA_GROUP = {
    'pcell_id': F_T_ALLOCATION['TDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['FDD'][0]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind',
                    'isRplCellForPSCell': 'false',
                },
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None,
                    'isRplCellForPSCell': 'false',
                },
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None,
                    'isRplCellForPSCell': 'false',
                },
                F_T_ALLOCATION['TDD'][2]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None,
                    'isRplCellForPSCell': 'false',
                }
            }
        }
    ],
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][0]]
}

# F4:T1 CA
F4_T1_2CC_CA_GROUP = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind',
                    'isRplCellForPSCell': 'false',
                }
            }
        }
    ],
    'verify_scell_add_dl': [F_T_ALLOCATION['TDD'][0]]
}

# T2(cell4):T1(cell1)   cell4+cell1  no CA
T2_T1_NonCA_GROUP = {
    'pcell_id': F_T_ALLOCATION['TDD'][1],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None,
                    'isRplCellForPSCell': 'false',
                },
            }
        }
    ],
}

# F_T_ALLOCATION['FDD'][1]
# F5:T1 cell3+cell1 no CA
F5_T1_NonCA_GROUP = {
    'pcell_id': F_T_ALLOCATION['FDD'][1],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None,
                    'isRplCellForPSCell': 'false',
                },
                # F_T_ALLOCATION['TDD'][1]: {
                #     'sCellOperationalMode': None,
                #     'sCellAdditionMethod': None,
                #     'isRplCellForPSCell': 'false',
                # }
            }
        }
    ],
}

# T3:T1 cell5+cell1 no CA
T3_T1_NonCA_GROUP = {
    'pcell_id': F_T_ALLOCATION['TDD'][2],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None,
                    'isRplCellForPSCell': 'false',
                }
            }
        }
    ]
}

INIT_PA_T1_F1_20 = {0: [0, 20, 0, 0]}
