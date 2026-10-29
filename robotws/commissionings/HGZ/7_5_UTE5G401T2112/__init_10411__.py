__maintainer__ = 'Fang Dandan'
__team__ = 'I_NSB_MN_RAN_RD_VRF_HAZ3_01_S3 '
__email__ = 'dandan.fang@nokia-sbell.com'
from robot.libraries.BuiltIn import BuiltIn

F_T_ALLOCATION = {'FDD': [1, 2, 3, 6], 'TDD': [4, 5]}
ALL_CELLS = F_T_ALLOCATION['FDD'] + F_T_ALLOCATION['TDD']
INIT_PA_F_T = {0: [0, 0, 0, 0, 0]}

tl = BuiltIn().get_variable_value('${tl}')

_F1_EXP_UL = 81.51
_T1_EXP_UL = 78.70
_F1_EXP_6CC_UL = 56.8
_T1_EXP_6CC_UL = 78.70  # Only 1 layer when UL CA
# Only 1 layer when UL CA

if "sdx70_dlonly" in str(tl.ues[0].capabilities):
    ulca_support_or_not = 'dlOnly'
    scell_ul_index_6137 = None
    scell_ul_index_9169 = None
    # exp_ul_indiv_6137 = [_F1_EXP_UL*2, -1, 0, -1]
    # exp_ul_indiv_9169 = [_T1_EXP_UL*2, 0, -1, -1]
    exp_ul_indiv_6137 = [_F1_EXP_UL, -1, 0, -1]
    exp_ul_indiv_9169 = [_T1_EXP_UL, 0, -1, -1]
elif "sdx75" in str(tl.ues[0].capabilities):
    ulca_support_or_not = 'dlAndUl'
    scell_ul_index_6137 = [F_T_ALLOCATION['TDD'][0]]
    scell_ul_index_9169 = [F_T_ALLOCATION['FDD'][0]]
    exp_ul_indiv_6137 = [_F1_EXP_UL, -1, 74.57, -1]
    exp_ul_indiv_9169 = [_T1_EXP_UL, 57, -1, -1]
else:
    ulca_support_or_not = 'dlAndUl'
    scell_ul_index_6137 = [F_T_ALLOCATION['TDD'][0]]
    scell_ul_index_9169 = [F_T_ALLOCATION['FDD'][0]]
    exp_ul_indiv_6137 = [_F1_EXP_6CC_UL, -1, -1, 78.7, -1, -1]
    exp_ul_indiv_9169 = [_T1_EXP_6CC_UL, 45, -1, -1, -1, -1]

# F1 F2 refer to 1st and 2nd cell in F_T_ALLOCATION['FDD']
# same for T1, T2, T3
# all UL 256qam is disable
#     'exp_ul_indiv': [72.08, -1, 74.57, -1],

F1_F2_T1_T2_4CC_CA_GROUP_COMMON = {
    'gnb_connection_alias_pcell': 'OAM_CU0',
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'cell_chbw_config': '4CC_F20M_F10M_T100M_T100M',
    'BAND_INFO': 'N66_N66_N41_N77',
    'exp_dl_indiv': [404.48, 106.62, 1571.71, 1573.62],
    'exp_ul_indiv': exp_ul_indiv_6137,
    'exp_ul_indiv_no_ca': [_F1_EXP_UL*2, -1, 0, -1],
    'nrrel_info': [
        {
            'gnb_connection_alias': 'OAM_CU0',
            'nrrel_config': {
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': ulca_support_or_not,
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'}
            }
        },
    ],
    'verify_scell_add_ul': scell_ul_index_6137,
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['TDD'][0], F_T_ALLOCATION['TDD'][1]],
    'init_pa_value': INIT_PA_F_T
}

# Used by 11178 cases
T1_F1_T2_F2_4CC_CA_GROUP_COMMON = {
    'gnb_connection_alias_pcell': 'OAM_CU0',
    'pcell_id': F_T_ALLOCATION['TDD'][0],
    'cell_chbw_config': '4CC_F20M_F10M_T100M_T100M',
    'BAND_INFO': 'N66_N66_N41_N77',
    'exp_dl_indiv': [1565.21, 405.95, 1573.48, 106.64],
    'exp_ul_indiv': exp_ul_indiv_9169,
    'exp_ul_indiv_no_ca': [_T1_EXP_UL*2, 0, -1, -1],
    'nrrel_info': [
        {
            'gnb_connection_alias': 'OAM_CU0',
            'nrrel_config': {
                F_T_ALLOCATION['FDD'][0]: {
                    'sCellOperationalMode': ulca_support_or_not,
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'}
            }
        },
    ],
    'verify_scell_add_ul': scell_ul_index_9169,
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][0], F_T_ALLOCATION['TDD'][1], F_T_ALLOCATION['FDD'][1]],
    'init_pa_value': INIT_PA_F_T
}

T1_F1_T2_F2_4CC_CA_GROUP_covBasedA1 = {
    'gnb_connection_alias_pcell': 'OAM_CU0',
    'pcell_id': F_T_ALLOCATION['TDD'][0],
    'cell_chbw_config': '4CC_F20M_F10M_T100M_T100M',
    'BAND_INFO': 'N66_N66_N41_N77',
    'exp_dl_indiv': [1469, 203, 1481, 96],
    'exp_ul_indiv': exp_ul_indiv_9169,
    'exp_ul_indiv_no_ca': [_T1_EXP_UL*2, 0, -1, -1],
    'nrrel_info': [
        {
            'gnb_connection_alias': 'OAM_CU0',
            'nrrel_config': {
                F_T_ALLOCATION['FDD'][0]: {
                    'sCellOperationalMode': ulca_support_or_not,
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'}
            }
        },
    ],
    'verify_scell_add_ul': scell_ul_index_9169,
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][0], F_T_ALLOCATION['TDD'][1], F_T_ALLOCATION['FDD'][1]],
    'init_pa_value': INIT_PA_F_T
}

F1_F2_T1_T2_6CC_CA_GROUP_COMMON = {
    'gnb_connection_alias_pcell': 'OAM_CU0',
    'pcell_id': F_T_ALLOCATION['FDD'][0],
    'cell_chbw_config': '6CC_F15M_F5M_F20M_T100M_T100M_F10M',
    'BAND_INFO': 'N66_N66_N41_N71_N71_N77',
    'exp_dl_indiv': [297.6, 45.5, 219.6, 1571.71, 1573.62, 106.64],
    'exp_ul_indiv': exp_ul_indiv_6137,
    'exp_ul_indiv_no_ca': [_F1_EXP_6CC_UL*2, -1, -1, 0, -1, -1],
    'nrrel_info': [
        {
            'gnb_connection_alias': 'OAM_CU0',
            'nrrel_config': {
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['FDD'][2]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['FDD'][3]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['TDD'][0]: {
                    'sCellOperationalMode': ulca_support_or_not,
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'}
            }
        },
    ],
    'verify_scell_add_ul': scell_ul_index_6137,
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['FDD'][2],
                            F_T_ALLOCATION['TDD'][0], F_T_ALLOCATION['TDD'][1], F_T_ALLOCATION['FDD'][3]],
    'init_pa_value': INIT_PA_F_T
}

# Used by 11178 cases
T1_F1_T2_F2_6CC_CA_GROUP_COMMON = {
    'gnb_connection_alias_pcell': 'OAM_CU0',
    'pcell_id': F_T_ALLOCATION['TDD'][0],
    'cell_chbw_config': '6CC_F15M_F5M_F20M_T100M_T100M_F10M',
    'BAND_INFO': 'N66_N66_N41_N71_N71_N77',
    'exp_dl_indiv': [1565.21, 297.6, 45.5, 219.6, 1573.48, 106.64],
    'exp_ul_indiv': exp_ul_indiv_9169,
    'exp_ul_indiv_no_ca': [_T1_EXP_6CC_UL*2, 0, -1, -1, -1, -1],
    'nrrel_info': [
        {
            'gnb_connection_alias': 'OAM_CU0',
            'nrrel_config': {
                F_T_ALLOCATION['FDD'][0]: {
                    'sCellOperationalMode': ulca_support_or_not,
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['FDD'][2]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['FDD'][3]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'},
            }
        },
    ],
    'verify_scell_add_ul': scell_ul_index_9169,
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][0], F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['FDD'][2],
                            F_T_ALLOCATION['TDD'][1], F_T_ALLOCATION['FDD'][3]],
    'init_pa_value': INIT_PA_F_T
}

T1_F1_T2_F2_6CC_CA_GROUP_covBasedA1 = {
    'gnb_connection_alias_pcell': 'OAM_CU0',
    'pcell_id': F_T_ALLOCATION['TDD'][0],
    'cell_chbw_config': '6CC_F15M_F5M_F20M_T100M_T100M_F10M',
    'BAND_INFO': 'N66_N66_N41_N71_N71_N77',
    # 'exp_dl_indiv': [1469, 203, 1481, 96],
    'exp_dl_indiv': [1469, 297.6, 45.5, 219.6, 1481, 106.64],
    'exp_ul_indiv': exp_ul_indiv_9169,
    'exp_ul_indiv_no_ca': [_T1_EXP_6CC_UL*2, 0, -1, -1, -1, -1],
    'nrrel_info': [
        {
            'gnb_connection_alias': 'OAM_CU0',
            'nrrel_config': {
                F_T_ALLOCATION['FDD'][0]: {
                    'sCellOperationalMode': ulca_support_or_not,
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['FDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['FDD'][2]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['FDD'][3]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
                F_T_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'},
            }
        },
    ],
    'verify_scell_add_ul': scell_ul_index_9169,
    'verify_scell_add_dl': [F_T_ALLOCATION['FDD'][0], F_T_ALLOCATION['FDD'][1], F_T_ALLOCATION['FDD'][2],
                            F_T_ALLOCATION['TDD'][1], F_T_ALLOCATION['FDD'][3]],
    'init_pa_value': INIT_PA_F_T
}

GRACEFUL_SHUTDOWN_HO_TARGET_CELL = F_T_ALLOCATION['FDD'][2]
GRACEFUL_SHUTDOWN_SCELL_RELEASE_CELL = F_T_ALLOCATION['FDD'][0]
