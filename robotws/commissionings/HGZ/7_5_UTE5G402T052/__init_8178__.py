from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Jiang Xian'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'xian.jiang@nokia-sbell.com'

tl = BuiltIn().get_variable_value("${tl}")
MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)
DN_CELL = NR_BTS_NAME + "/NRCELL-1"

MR_BTS_NAME_VICTIM = "MRBTS-" + str(tl.gnbs[1].instance_id)
NR_BTS_NAME_VICTIM = MR_BTS_NAME_VICTIM + "/NRBTS-" + str(tl.gnbs[1].global_bts_id)
DN_CELL_VICTIM = NR_BTS_NAME_VICTIM + "/NRCELL-1"

PROGRAM = BuiltIn().get_variable_value("${PROGRAM}")
NRARFCN_PARA = 509226

TDD_UL_EXP_TPUT_100M = 150
TDD_DL_EXP_TPUT_100M = 1500
TDD_DL_EXP_TPUT_100M_CA_PCELL = 1550
TDD_DL_EXP_TPUT_100M_CA_SCELL = 1400
TDD_UL_EXP_TPUT_100M_CA = 150

TDD_UL_EXP_TPUT_80M = 180
TDD_DL_EXP_TPUT_80M = 1000

TDD_UL_EXP_TPUT_80M_1070 = 173
TDD_DL_EXP_TPUT_80M_1070 = 1030

TDD_UL_EXP_TPUT_90M_1116 = 153
TDD_DL_EXP_TPUT_90M_1116 = 1600

TARGET_AVG_PERCENT = 0.9
MIN_PERCENT = 0.8

Cell_ALLOCATION = {'TDD': [1, 2]}

T_T_2CC_CA_GROUP_COMMON = {
    'pcell_id': Cell_ALLOCATION['TDD'][0],
    'gnb_connection_alias_pcell': 'GNB_OAM',
    'nrrel_info': [
        {
            'gnb_connection_alias': 'GNB_OAM',
            'nrrel_config': {
                Cell_ALLOCATION['TDD'][1]: {
                    'sCellOperationalMode': 'dlOnly',
                    'sCellAdditionMethod': 'blind'}
            }
        }
    ],
    'verify_scell_add_dl': Cell_ALLOCATION['TDD'][1]
}
