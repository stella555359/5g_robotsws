__maintainer__ = 'Lingxue Cui'
__team__ = 'I_NSB_MN_RAN_RD_VRF_HAZ3_01@internal.nsn.com'
__email__ = 'lingxue.cui@nokia-sbell.com'

# # PA related variables
PA_OUT_PORTS = [1, 2, 3, 4]
PA_ROWS = 32
# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
INIT_PA = {0: [10, 10, 10, 10, 10, 10, 127]}

ALL_CELLS = [1, 2, 3]   # NRCELL-1 and NRCELL-2 are supercells, NRCELL-3 is normal cell with AVQC
SUPERCELLS = [1, 2]
ALL_RMODS = [1, 2, 3, 4, 5, 6, 7]
SUPERCELL_RMODS = [1, 2, 3, 4, 5, 6]

EXP_DL_TPUT = 1466
EXP_UL_TPUT = 151

# # used for CA case
CA_GROUP_COMMON = {
    'gnb_connection_alias_pcell': 'OAM_CU0',
    'pcell_id': SUPERCELLS[0],
    'pcell_ru_list': [1, 2, 3],
    'cell_chbw_config': '2CC_T100M_T100M',
    'BAND_INFO': 'N77_N77',
    'exp_dl_indiv': [EXP_DL_TPUT, EXP_DL_TPUT],
    'exp_ul_indiv': [EXP_UL_TPUT, -1],
    'nrrel_info': [
        {
            'gnb_connection_alias': 'OAM_CU0',
            'nrrel_config': {
                SUPERCELLS[1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'covBasedA1'}
            }
        },
    ],
    'verify_scell_add_dl': [SUPERCELLS[1]],
    'verify_scell_add_ul': [],
    'scell_ru_list': [[4, 5, 6]],
    'init_pa_value': INIT_PA
}
