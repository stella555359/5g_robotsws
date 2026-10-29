from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Cheng Catherine'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'catherine.cheng@nokia-sbell.com'

tl = BuiltIn().get_variable_value("${tl}")
MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)
DN_CELL = NR_BTS_NAME + "/NRCELL-1"

MR_BTS_NAME_AGGRESSOR = "MRBTS-" + str(tl.gnbs[1].instance_id)
NR_BTS_NAME_AGGRESSOR = MR_BTS_NAME_AGGRESSOR + "/NRBTS-" + str(tl.gnbs[1].global_bts_id)
DN_CELL_AGGRESSOR = NR_BTS_NAME_AGGRESSOR + "/NRCELL-1"
RI_THRES_BASE = -95
NRARFCN_PARA = 659900

PARAMS_TO_MODIFY_72E_VICTIM = [
    dict(value="true", dist_name=DN_CELL, p_name="actEcpri72e"),
    dict(value="16Rx", dist_name=DN_CELL, p_name="numberOfRxBeamforming"),
    dict(value="8Rx", dist_name=DN_CELL, p_name="numberOfRxPucch"),
    dict(value="true", dist_name=NR_BTS_NAME, p_name="actBbPoolTddFr1"),
    dict(value="true", dist_name=NR_BTS_NAME, p_name="actBbPoolTddFr1AlgEnh"),
    dict(value="true", dist_name=NR_BTS_NAME, p_name="actBbPoolTddFr1Enh"),
    dict(value="true", dist_name=NR_BTS_NAME, p_name="actBbPoolExtensionTddFr1"),
    dict(value="true", dist_name=NR_BTS_NAME, p_name="actPaging"),
    dict(value="quaterT", dist_name=DN_CELL, p_name="numOfPagingFrames"),
    dict(value="1", dist_name=DN_CELL, p_name="pagingOffset"),
    dict(value="one", dist_name=DN_CELL, p_name="numPagingOccsnPagingFrame"),
    dict(value="2", dist_name=DN_CELL, list_name="fPdcchMonOccsnPo"),
]

PARAMS_TO_MODIFY_72E_AGGRESSOR = [
    dict(value="true", dist_name=DN_CELL_AGGRESSOR, p_name="actEcpri72e"),
    dict(value="16Rx", dist_name=DN_CELL_AGGRESSOR, p_name="numberOfRxBeamforming"),
    dict(value="8Rx", dist_name=DN_CELL_AGGRESSOR, p_name="numberOfRxPucch"),
    dict(value="true", dist_name=NR_BTS_NAME_AGGRESSOR, p_name="actBbPoolTddFr1"),
    dict(value="true", dist_name=NR_BTS_NAME_AGGRESSOR, p_name="actBbPoolTddFr1AlgEnh"),
    dict(value="true", dist_name=NR_BTS_NAME_AGGRESSOR, p_name="actBbPoolTddFr1Enh"),
    dict(value="true", dist_name=NR_BTS_NAME_AGGRESSOR, p_name="actBbPoolExtensionTddFr1"),
    dict(value="true", dist_name=NR_BTS_NAME_AGGRESSOR, p_name="actPaging"),
    dict(value="quaterT", dist_name=DN_CELL_AGGRESSOR, p_name="numOfPagingFrames"),
    dict(value="1", dist_name=DN_CELL_AGGRESSOR, p_name="pagingOffset"),
    dict(value="one", dist_name=DN_CELL_AGGRESSOR, p_name="numPagingOccsnPagingFrame"),
    dict(value="2", dist_name=DN_CELL_AGGRESSOR, list_name="fPdcchMonOccsnPo"),
]

TDD_UL_EXP_TPUT_100M = 150
# TDD_DL_EXP_TPUT_100M_PEAK = 1500
TDD_DL_EXP_TPUT_100M = 1500

TDD_UL_EXP_TPUT_80M = 180
# TDD_DL_EXP_TPUT_80M_PEAK = 1000
TDD_DL_EXP_TPUT_80M = 1000

# 12564
TDD_UL_EXP_TPUT_80M_1070 = 251
TDD_DL_EXP_TPUT_80M_1070 = 1031

TDD_UL_EXP_TPUT_80M_1070_65535 = 190
TDD_DL_EXP_TPUT_80M_1070_65535 = 1000

TDD_UL_EXP_TPUT_90M_1116 = 136
TDD_DL_EXP_TPUT_90M_1116 = 1380

# 12564
TDD_UL_EXP_TPUT_60M = 118
TDD_DL_EXP_TPUT_60M = 885
# TDD_DL_EXP_TPUT_60M_PEAK = 850

TDD_UL_EXP_TPUT_40M = 50
# TDD_DL_EXP_TPUT_40M_PEAK = 550
TDD_DL_EXP_TPUT_40M = 550

# 12564
TDD_UL_EXP_TPUT_40M_1208 = 72

TDD_DL_EXP_TPUT_40M_1208 = 586

TDD_DL_EXP_TPUT_40M_1208_mute_S = 492

TDD_UL_EXP_TPUT_20M_1116 = 17.3
TDD_DL_EXP_TPUT_20M_1116 = 287

TARGET_AVG_PERCENT = 0.9
MIN_PERCENT = 0.8
