from robot.libraries.BuiltIn import BuiltIn

__maintainer__ = 'Cheng Catherine'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_01_GMS '
__email__ = 'catherine.cheng@nokia-sbell.com'

tl = BuiltIn().get_variable_value("${tl}")
MR_BTS_NAME = "MRBTS-" + str(tl.gnbs[0].instance_id)
NR_BTS_NAME = MR_BTS_NAME + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)
DN_CELL = NR_BTS_NAME + "/NRCELL-1"

PROGRAM = BuiltIn().get_variable_value("${PROGRAM}")
MR_BTS_NAME_VICTIM = "MRBTS-" + str(tl.gnbs[1].instance_id)
NR_BTS_NAME_VICTIM = MR_BTS_NAME_VICTIM + "/NRBTS-" + str(tl.gnbs[1].global_bts_id)
DN_CELL_VICTIM = NR_BTS_NAME_VICTIM + "/NRCELL-1"
RI_THRES_BASE = -95
BB_POOL_ENABLE_VICTIM = "true" if PROGRAM >= "24R3" else "false"
PDCCH_MON_OCCSN_VICTIM = "2" if PROGRAM >= "24R3" else "0"

PARAMS_TO_MODIFY_PAGING_AGGRESSOR = [
    dict(value="true", dist_name=NR_BTS_NAME, p_name="actBbPoolTddFr1"),
    dict(value="true", dist_name=NR_BTS_NAME, p_name="actPaging"),
    dict(value="quaterT", dist_name=DN_CELL, p_name="numOfPagingFrames"),
    dict(value="1", dist_name=DN_CELL, p_name="pagingOffset"),
    dict(value="one", dist_name=DN_CELL, p_name="numPagingOccsnPagingFrame"),
    dict(value="2", dist_name=DN_CELL, list_name="fPdcchMonOccsnPo"),
]

PARAMS_TO_MODIFY_PAGING_VICTIM = [
    dict(value=BB_POOL_ENABLE_VICTIM, dist_name=NR_BTS_NAME_VICTIM, p_name="actBbPoolTddFr1"),
    dict(value="true", dist_name=NR_BTS_NAME_VICTIM, p_name="actPaging"),
    dict(value="quaterT", dist_name=DN_CELL_VICTIM, p_name="numOfPagingFrames"),
    dict(value="1", dist_name=DN_CELL_VICTIM, p_name="pagingOffset"),
    dict(value="one", dist_name=DN_CELL_VICTIM, p_name="numPagingOccsnPagingFrame"),
    dict(value=PDCCH_MON_OCCSN_VICTIM, dist_name=DN_CELL_VICTIM, list_name="fPdcchMonOccsnPo"),
]

TDD_UL_EXP_TPUT_100M = 110
TDD_DL_EXP_TPUT_100M = 1500

TDD_UL_EXP_TPUT_80M = 130
TDD_DL_EXP_TPUT_80M = 950

TDD_UL_EXP_TPUT_60M = 50
TDD_DL_EXP_TPUT_60M = 850

TDD_UL_EXP_TPUT_40M = 35
TDD_DL_EXP_TPUT_40M = 550

TARGET_AVG_PERCENT = 0.9
MIN_PERCENT = 0.8
