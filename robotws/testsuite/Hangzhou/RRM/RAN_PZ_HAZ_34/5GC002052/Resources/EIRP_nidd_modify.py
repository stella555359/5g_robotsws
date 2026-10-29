import os
import sys
from py_script import *
from robot.libraries.BuiltIn import BuiltIn
sys.path.append('${CURDIR}/../../5GC001655/Resources')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
scf_file = BuiltIn().get_variable_value('${_scf_file_path}')
ids = get_mrbtsid_from_scf(scf_file)
MR_NR_CELL_NAME = 'MRBTS-' + str(ids[0]) + '/NRBTS-' + str(ids[1]) + \
    '/NRCELL-' + str(ids[2])

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(ids[0]) + '/NRBTS-' + str(ids[1]) + \
    '/NRCELLGRP-0'

MODIFY_SCF_EIRP_BASE = [
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actEirpControl')
]

EIRP_ELEMENT_PARAMS_TO_ADD = [
    dict(
        value='0',
        dist_name=MR_NR_CELL_NAME,
        p_name='antennaMechanicalDowntilt')
]

EIRP_LIST_NAME_PARAMS_TO_ADD = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='eirpControl'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='eirpControlPowerReductionFactorList'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='beamSet'),
]

EIRP_LIST_ITEMS_PARAMS_TO_ADD = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='eirpControl',
        elements=dict(eirpControlTimeAveragingWindow='6', minGuaranteedBudgetRatio='50',
                      minGuaranteedBudgetRatioMode='actualEirpBudgetRatio',
                      minSignificantNormalizedBeamGain='-20', numOfSegmentAzimuthEdges='1',
                      numOfSegmentElevationEdges='0',
                      schedulWeightFactorEnabled='false', segmentAzimuthEdge0='0')),
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='beamSet',
        elements=dict(basicBeamSet='beamSet_4', leftEdgeAngle='45', nrBtsBeamRefinementP2='false',
                      rightEdgeAngle='45', tiltOffset='3'))
]

TILT_LIST_ITEMS_PARAMS_TO_ADD = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='beamSet',
        elements=dict(tiltOffset='3')),
]

EIRP_LIST_ELEMENTS_PARAMS_TO_ADD = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='eirpControlPowerReductionFactorList',
        elements=['-60']),
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='eirpControlPowerReductionFactorList',
        elements=['0'])
]

Beamset_LIST_NAME_PARAMS_TO_Remove = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='beamSet'),
]

MODIFY_SCF_EIRP_BASE = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actEirpControl'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_4', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='4 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='3', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
    dict(value='longPucch', dist_name=MR_NR_CELL_NAME, p_name='pucchModeSelect'),
]
