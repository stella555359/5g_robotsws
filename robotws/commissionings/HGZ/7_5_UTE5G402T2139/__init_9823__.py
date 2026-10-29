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

PROGRAM = BuiltIn().get_variable_value("${PROGRAM}")
RI_THRES_BASE = -110
NRARFCN_PARA = 641156

# TDD_UL_EXP_TPUT_80M_1070 = 170
TDD_UL_EXP_TPUT_80M_1070 = 85
TDD_DL_EXP_TPUT_80M_1070 = 1030   # prach format B4

# TDD_UL_EXP_TPUT_80M_1070_65535 = 190
TDD_UL_EXP_TPUT_80M_1070_65535 = 95
TDD_DL_EXP_TPUT_80M_1070_65535 = 1000

# TDD_UL_EXP_TPUT_90M_1116 = 130
TDD_UL_EXP_TPUT_90M_1116 = 65
TDD_DL_EXP_TPUT_90M_1116 = 1380

# TDD_UL_EXP_TPUT_40M_1208 = 49
TDD_UL_EXP_TPUT_40M_1208 = 24
TDD_DL_EXP_TPUT_40M_1208 = 588
TDD_DL_EXP_TPUT_40M_1208_mute_S = 492

TDD_UL_EXP_TPUT_20M_1116 = 24
TDD_DL_EXP_TPUT_20M_1116 = 315

TARGET_AVG_PERCENT = 0.9
MIN_PERCENT = 0.8
