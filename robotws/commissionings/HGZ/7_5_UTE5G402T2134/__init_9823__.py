from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Cheng Catherine'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'catherine.cheng@nokia-sbell.com'

tl = BuiltIn().get_variable_value("${tl}")
MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)
DN_CELL = NR_BTS_NAME + "/NRCELL-1"

MR_BTS_NAME_VICTIM = "MRBTS-" + str(tl.gnbs[1].instance_id)
NR_BTS_NAME_VICTIM = MR_BTS_NAME_VICTIM + "/NRBTS-" + str(tl.gnbs[1].global_bts_id)
DN_CELL_VICTIM = NR_BTS_NAME_VICTIM + "/NRCELL-1"
RI_THRES_BASE = -95
NRARFCN_PARA = 636636

TDD_UL_EXP_TPUT_100M = 110
TDD_DL_EXP_TPUT_100M = 1500

TDD_UL_EXP_TPUT_80M = 130
TDD_DL_EXP_TPUT_80M = 950

TDD_UL_EXP_TPUT_60M = 50
TDD_DL_EXP_TPUT_60M = 850

TDD_UL_EXP_TPUT_40M = 35
TDD_DL_EXP_TPUT_40M = 550

TDD_UL_EXP_TPUT_90M_1116 = 98
TDD_DL_EXP_TPUT_90M_1116 = 1385

TDD_UL_EXP_TPUT_20M_1116 = 24
TDD_DL_EXP_TPUT_20M_1116 = 315

TARGET_AVG_PERCENT = 0.9
MIN_PERCENT = 0.8
