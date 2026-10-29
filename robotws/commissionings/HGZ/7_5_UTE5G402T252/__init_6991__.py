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
BB_POOL_ENABLE = "false"
PDCCH_MON_OCCSN = "0"
RI_THRES_BASE = -120

PARAMS_TO_MODIFY_PAGING_AGGRESSOR = [
    dict(value=BB_POOL_ENABLE, dist_name=NR_BTS_NAME, p_name="actBbPoolTddFr1"),
    dict(value="true", dist_name=NR_BTS_NAME, p_name="actPaging"),
    dict(value="quaterT", dist_name=DN_CELL, p_name="numOfPagingFrames"),
    dict(value="1", dist_name=DN_CELL, p_name="pagingOffset"),
    dict(value="one", dist_name=DN_CELL, p_name="numPagingOccsnPagingFrame"),
    dict(value=PDCCH_MON_OCCSN, dist_name=DN_CELL, list_name="fPdcchMonOccsnPo"),
]

PARAMS_TO_MODIFY_PAGING_VICTIM = [
    dict(value="false", dist_name=NR_BTS_NAME_VICTIM, p_name="actBbPoolTddFr1"),
    dict(value="true", dist_name=NR_BTS_NAME_VICTIM, p_name="actPaging"),
    dict(value="quaterT", dist_name=DN_CELL_VICTIM, p_name="numOfPagingFrames"),
    dict(value="1", dist_name=DN_CELL_VICTIM, p_name="pagingOffset"),
    dict(value="one", dist_name=DN_CELL_VICTIM, p_name="numPagingOccsnPagingFrame"),
    dict(value="0", dist_name=DN_CELL_VICTIM, list_name="fPdcchMonOccsnPo"),
]

TDD_UL_EXP_TPUT_100M = 150
# TDD_DL_EXP_TPUT_100M_PEAK = 1500
TDD_DL_EXP_TPUT_100M = 600

TDD_UL_EXP_TPUT_80M = 180
# TDD_DL_EXP_TPUT_80M_PEAK = 1000
TDD_DL_EXP_TPUT_80M = 400

TDD_UL_EXP_TPUT_60M = 80
TDD_DL_EXP_TPUT_60M = 300
# TDD_DL_EXP_TPUT_60M_PEAK = 850

TDD_UL_EXP_TPUT_40M = 50
# TDD_DL_EXP_TPUT_40M_PEAK = 550
TDD_DL_EXP_TPUT_40M = 250

TARGET_AVG_PERCENT = 0.9
MIN_PERCENT = 0.7
