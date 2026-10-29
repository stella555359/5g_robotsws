import math
from robot.libraries.BuiltIn import BuiltIn
import NIDD_Modify_data_template as data_template
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')

# Params defined in init file under commissioning folder
ALL_CELLS = BuiltIn().get_variable_value('${ALL_CELLS}')

tl = BuiltIn().get_variable_value("${tl}")
PROGRAM = BuiltIn().get_variable_value("${PROGRAM}")
DN_MRBTS = "MRBTS-" + str(tl.gnbs[0].instance_id)
DN_NRBTS = DN_MRBTS + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)
DN_DU = DN_NRBTS + "/NRDU-1"

TDD_CELL_ID = 1
TDD_CELL_ID_GNB1 = 1

TDD_CELL_ID_LIST = [TDD_CELL_ID]
CELL_LIST_GNB0 = [TDD_CELL_ID]
CELL_LIST_GNB1 = [TDD_CELL_ID_GNB1]

DN_TDDCELL = DN_NRBTS + "/NRCELL-%s" % TDD_CELL_ID
DN_BEAM = DN_TDDCELL + "/beamSet"
DN_MRBTS_GNB1 = "MRBTS-" + str(tl.gnbs[1].instance_id)
DN_NRBTS_GNB1 = DN_MRBTS_GNB1 + "/NRBTS-" + str(tl.gnbs[1].global_bts_id)

ACT_BBPOOLING = [
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1'),
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1AlgEnh'),
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actBbPoolExtensionTddFr1'),
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1Enh'),
    dict(
        value='true',
        dist_name=DN_TDDCELL,
        p_name='actShortBsrLimitAdaptation'),
    dict(
        value='false',
        dist_name=DN_TDDCELL,
        p_name='actDlMuMimo'),
    dict(
        value='longPucch',
        dist_name=DN_TDDCELL,
        p_name='pucchModeSelect'),
    dict(
        value='80ms',
        dist_name=DN_TDDCELL,
        list_name='csirsForTracking',
        p_name='csirsTrackingPeriod'),
    dict(
        value="true",
        dist_name=DN_NRBTS,
        p_name="actPaging"),
    dict(
        value="quaterT",
        dist_name=DN_TDDCELL,
        p_name="numOfPagingFrames"),
    dict(
        value="1",
        dist_name=DN_TDDCELL,
        p_name="pagingOffset"),
    dict(
        value="one",
        dist_name=DN_TDDCELL,
        p_name="numPagingOccsnPagingFrame"),
    dict(
        value="7",
        dist_name=DN_TDDCELL,
        list_name="fPdcchMonOccsnPo")
]

DIS_BBPOOLING = [
    dict(
        value='false',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1'),
    dict(
        value='false',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1AlgEnh'),
    dict(
        value='false',
        dist_name=DN_NRBTS,
        p_name='actBbPoolExtensionTddFr1'),
    dict(
        value='false',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1Enh'),
    dict(
        value='true',
        dist_name=DN_TDDCELL,
        p_name='actShortBsrLimitAdaptation'),
    dict(
        value='false',
        dist_name=DN_TDDCELL,
        p_name='actDlMuMimo'),
    dict(
        value='longPucch',
        dist_name=DN_TDDCELL,
        p_name='pucchModeSelect'),
    dict(
        value='80ms',
        dist_name=DN_TDDCELL,
        list_name='csirsForTracking',
        p_name='csirsTrackingPeriod'),
    dict(
        value="true",
        dist_name=DN_NRBTS,
        p_name="actPaging"),
    dict(
        value="quaterT",
        dist_name=DN_TDDCELL,
        p_name="numOfPagingFrames"),
    dict(
        value="1",
        dist_name=DN_TDDCELL,
        p_name="pagingOffset"),
    dict(
        value="one",
        dist_name=DN_TDDCELL,
        p_name="numPagingOccsnPagingFrame"),
    dict(
        value="0",
        dist_name=DN_TDDCELL,
        list_name="fPdcchMonOccsnPo")
]

SCF_TEMPLATE_BEAMSET2 = [
    dict(
        value='beamSet_2',
        dist_name=DN_BEAM,
        p_name='basicBeamSet'),
    dict(
            value='45',
            dist_name=DN_BEAM,
            p_name='leftEdgeAngle'),
    dict(
            value='135',
            dist_name=DN_BEAM,
            p_name='lowerEdgeAngle'),
    dict(
            value='false',
            dist_name=DN_BEAM,
            p_name='nrBtsBeamRefinementP2'),
    dict(
            value='45',
            dist_name=DN_BEAM,
            p_name='rightEdgeAngle'),
    dict(
            value='80',
            dist_name=DN_BEAM,
            p_name='upperEdgeAngle')
]

MODIFY_SCF_LOAD = [
    dict(value='-50', dist_name=DN_TDDCELL, p_name="qRxLevMin"),
    dict(value='disabled', dist_name=DN_DU, p_name="actInterGnbCa")
]
