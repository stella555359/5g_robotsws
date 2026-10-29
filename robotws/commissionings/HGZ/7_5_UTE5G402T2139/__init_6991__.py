from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Cheng Catherine'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'catherine.cheng@nokia-sbell.com'

tl = BuiltIn().get_variable_value("${tl}")
PROGRAM = BuiltIn().get_variable_value("${PROGRAM}")
MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)
DN_CELL = NR_BTS_NAME + "/NRCELL-1"

MR_BTS_NAME_VICTIM = "MRBTS-" + str(tl.gnbs[1].instance_id)
NR_BTS_NAME_VICTIM = MR_BTS_NAME_VICTIM + "/NRBTS-" + str(tl.gnbs[1].global_bts_id)
DN_CELL_VICTIM = NR_BTS_NAME_VICTIM + "/NRCELL-1"
RI_THRES_BASE = -90
BBPOOL_ENHANCE_ENABLE = [dict(value="true", dist_name=NR_BTS_NAME, p_name="actBbPoolTddFr1AlgEnh")]
BBPOOL_ENHANCE_ENABLE_USE = BBPOOL_ENHANCE_ENABLE if PROGRAM >= "24R1" else []
BBPOOL_ENHANCE_ENABLE_VICTIM = [dict(value="true", dist_name=NR_BTS_NAME_VICTIM, p_name="actBbPoolTddFr1AlgEnh")]
BBPOOL_ENHANCE_ENABLE_USE_VICTIM = BBPOOL_ENHANCE_ENABLE_VICTIM if PROGRAM >= "24R1" else []

PARAMS_TO_MODIFY_PAGING_AGGRESSOR = [
    dict(value="true", dist_name=NR_BTS_NAME, p_name="actBbPoolTddFr1"),
    dict(value="true", dist_name=NR_BTS_NAME, p_name="actPaging"),
    dict(value="quaterT", dist_name=DN_CELL, p_name="numOfPagingFrames"),
    dict(value="1", dist_name=DN_CELL, p_name="pagingOffset"),
    dict(value="one", dist_name=DN_CELL, p_name="numPagingOccsnPagingFrame"),
    dict(value="2", dist_name=DN_CELL, list_name="fPdcchMonOccsnPo"),
] + BBPOOL_ENHANCE_ENABLE_USE

PARAMS_TO_MODIFY_PAGING_VICTIM = [
    dict(value="true", dist_name=NR_BTS_NAME_VICTIM, p_name="actBbPoolTddFr1"),
    dict(value="true", dist_name=NR_BTS_NAME_VICTIM, p_name="actPaging"),
    dict(value="quaterT", dist_name=DN_CELL_VICTIM, p_name="numOfPagingFrames"),
    dict(value="1", dist_name=DN_CELL_VICTIM, p_name="pagingOffset"),
    dict(value="one", dist_name=DN_CELL_VICTIM, p_name="numPagingOccsnPagingFrame"),
    dict(value="2", dist_name=DN_CELL_VICTIM, list_name="fPdcchMonOccsnPo"),
] + BBPOOL_ENHANCE_ENABLE_USE_VICTIM

# TDD_UL_EXP_TPUT_100M = 165
TDD_UL_EXP_TPUT_100M = 75
TDD_DL_EXP_TPUT_100M = 1500

# TDD_UL_EXP_TPUT_80M = 206
TDD_UL_EXP_TPUT_80M = 90
TDD_DL_EXP_TPUT_80M = 1000

# TDD_UL_EXP_TPUT_60M = 88
TDD_UL_EXP_TPUT_60M = 35
TDD_DL_EXP_TPUT_60M = 880

# TDD_UL_EXP_TPUT_40M = 60
TDD_UL_EXP_TPUT_40M = 25
TDD_DL_EXP_TPUT_40M = 586

TARGET_AVG_PERCENT = 0.9
MIN_PERCENT = 0.8
