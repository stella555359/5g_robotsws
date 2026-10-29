__maintainer__ = 'Wang Yixiang'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'yixiang.x.wang@nokia-sbell.com'


F_T_ALLOCATION = {'FDD': [6, 2, 7], 'TDD': [3, 5]}
ALL_CELLS = F_T_ALLOCATION['FDD'] + F_T_ALLOCATION['TDD']
F_T_2CC_CA_GROUP_COMMON = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]:{
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'blind'}
            }
        }
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['TDD'][0]]
}

F_T_2CC_CA_GROUP_BUFFERBASE = {
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                F_T_ALLOCATION['TDD'][0]:{
                    'sCellOperationalMode': 'dlAndUl',
                    'sCellAdditionMethod': 'bufferBased'}
            }
        }
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['TDD'][0]]
}

INIT_PA_F_T = {0: [0, 0, 0, 0]}

PCELL_BAD = 30
PCELL_GOOD = 0
SCELL_BAD = 25
SCELL_GOOD = 0

SCELL_A2_RELEASED_PA = 47
