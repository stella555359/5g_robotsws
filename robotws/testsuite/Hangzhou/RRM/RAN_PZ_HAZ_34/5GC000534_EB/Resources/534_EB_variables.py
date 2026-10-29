import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

PARAMS_534_beam1 = [
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_1', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='1 beam', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
]

PARAMS_534_beam2 = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_2', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='2 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
]

PARAMS_534_beam4 = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_4', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='4 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
]

PARAMS_534_B1_01 = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_2', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='2 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
]

PARAMS_534_B1_08 = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_4', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='4 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
]

PARAMS_534_B1_15 = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_3_1', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='4 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
]

PARAMS_534_B1_21 = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_5_1', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='6 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
]

PARAMS_534_B1_21_element = [
    dict(value='0', dist_name=MR_NR_CELL_NAME, list_name='fPdcchMonOccsnPo'),
]

PARAMS_534_B1_14 = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_8', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='8 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
    dict(value='80ms', dist_name=MR_NR_CELL_NAME, p_name='csirsTrackingPeriod'),
    dict(value='52RB', dist_name=MR_NR_CELL_NAME, p_name='rbAllocation'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='startRB'),
    dict(value='3ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='162', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex'),
    dict(value='30', dist_name=MR_NR_CELL_NAME, p_name='lteToNrTimeOffset'),
]

PARAMS_534_B1_14_element = [
    dict(value='2', dist_name=MR_NR_CELL_NAME, list_name='fPdcchMonOccsnPo'),
]

PARAMS_534_B1_33 = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_2', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='2 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
    dict(value='4', dist_name=MR_NR_CELL_NAME, p_name='type0SearchSpaceConfigurationIndex'),
    dict(value='158', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex'),
    dict(value='80ms', dist_name=MR_NR_CELL_NAME, p_name='csirsTrackingPeriod'),
    dict(value='52RB', dist_name=MR_NR_CELL_NAME, p_name='rbAllocation'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='startRB'),
]

PARAMS_534_B1_33_element = [
    dict(value='2', dist_name=MR_NR_CELL_NAME, list_name='fPdcchMonOccsnPo'),
]

PARAMS_534_B1_45 = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_4', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='4 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
    dict(value='5', dist_name=MR_NR_CELL_NAME, p_name='type0SearchSpaceConfigurationIndex'),
    dict(value='158', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex'),
    dict(value='80ms', dist_name=MR_NR_CELL_NAME, p_name='csirsTrackingPeriod'),
    dict(value='1', dist_name=MR_NR_CELL_NAME, p_name='pagingOffset'),
]

PARAMS_534_B1_45_element = [
    dict(value='0', dist_name=MR_NR_CELL_NAME, list_name='fPdcchMonOccsnPo'),
]

PARAMS_534_B2_02 = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='beamSet_6', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='6 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='nrBtsBeamRefinementP2'),
    dict(value='45', dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='tiltOffset'),
    dict(value='5', dist_name=MR_NR_CELL_NAME, p_name='type0SearchSpaceConfigurationIndex'),
    dict(value='158', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex'),
    dict(value='80ms', dist_name=MR_NR_CELL_NAME, p_name='csirsTrackingPeriod'),
    dict(value='1', dist_name=MR_NR_CELL_NAME, p_name='pagingOffset'),
]

PARAMS_534_B2_02_element = [
    dict(value='0', dist_name=MR_NR_CELL_NAME, listname='fPdcchMonOccsnPo'),
]
