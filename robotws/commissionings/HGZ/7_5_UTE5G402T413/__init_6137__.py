__maintainer__ = 'Ding Binmei'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'binmei.ding@nokia-sbell.com'

F_T_ALLOCATION = {'FDD': [1, 2, 3], 'TDD': [4, 5]}
ALL_CELLS = F_T_ALLOCATION['FDD'] + F_T_ALLOCATION['TDD']
F_T_2CC_CA_GROUP_COMMON = {
    'pcell_id': F_T_ALLOCATION['FDD'][1],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    # 'a1HysteresisSCellAddSsbRsrp': 0,
    # 'a1ThresholdSCellAddSsbRsrpTDD': 80,
    # 'a1TimeToTriggerSCellAddSsbRsrp': '320ms',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {    # This is used for update nrrel settings
                F_T_ALLOCATION['TDD'][0]:{'sCellOperationalMode': 'dlAndUl', 'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][1]:{'sCellOperationalMode': 'dlOnly', 'sCellAdditionMethod': 'blind'}
            }
        }
    ],
    'verify_scell_add_ul': [F_T_ALLOCATION['TDD'][0]],
    'verify_scell_add_dl': [F_T_ALLOCATION['TDD'][0], F_T_ALLOCATION['TDD'][1]]
}
