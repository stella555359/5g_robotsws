import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
BSR_file = BuiltIn().get_variable_value('${BSR_file}')

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

MR_NR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

Enable_feature_1866 = [
     dict(
         abbr='actBeamforming',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Activate Beamforming',
         new_value='true'),
     dict(
         abbr='actCustomBsr',
         dist_name=MR_NR_BTS_NAME,
         filter_param='Activate custom beam set realization',
         new_value='true'),
     dict(
         abbr='basicBeamSet',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Basic Beam Set',
         new_value='beamSet_1'),
     dict(
         abbr='nrBtsBeamRefinementP2',
         dist_name=MR_NR_CELL_NAME,
         filter_param='BTS Beam Refinement P2',
         new_value='true'),
     dict(
         abbr='numberOfTransmittedSsBlocks',
         dist_name=MR_NR_CELLGRP_NAME,
         filter_param='Number of transmitted Synchronization Signal Blocks',
         new_value='6 beams'),
     dict(
         abbr='customBeamSetName',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Custom Beam Set Name',
         new_value=BSR_file),
     dict(
         abbr='leftEdgeAngle',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Left Cell Edge Angle',
         new_value='45'),
     dict(
         abbr='rightEdgeAngle',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Right Cell Edge Angle',
         new_value='45')
]
Disable_feature_1866 = [
     dict(
         abbr='basicBeamSet',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Basic Beam Set',
         new_value='beamSet_6'),
     dict(
         abbr='actCustomBsr',
         dist_name=MR_NR_BTS_NAME,
         filter_param='Activate custom beam set realization',
         new_value='false'),
     dict(
         abbr='nrBtsBeamRefinementP2',
         dist_name=MR_NR_CELL_NAME,
         filter_param='BTS Beam Refinement P2',
         new_value='false'),
     dict(
         abbr='customBeamSetName',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Custom Beam Set Name',
         new_value='')
]
