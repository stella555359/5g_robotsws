__maintainer__ = 'Fang Dandan'
__team__ = 'I_NSB_MN_RAN_RD_VRF_HAZ3_01_S3 '
__email__ = 'dandan.fang@nokia-sbell.com'


F_T_ALLOCATION = {'FDD': [1], 'TDD': [2, 3]}
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
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None},
                F_T_ALLOCATION['FDD'][0]: {
                    'sCellOperationalMode': None,
                    'sCellAdditionMethod': None}
            }
        },
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['TDD'][0], F_T_ALLOCATION['TDD'][1]]
}

INIT_PA_F1_F2_T1_T2 = {0: [0, 0, 0, 0]}
INIT_PA_F1_T1_F2_T3 = {0: [0, 0, 15, 127]}

PCELL_GOOD = 0
PCELL_GOOD_FOR_FDD_ADD = 35
SCELL_GOOD = 0
