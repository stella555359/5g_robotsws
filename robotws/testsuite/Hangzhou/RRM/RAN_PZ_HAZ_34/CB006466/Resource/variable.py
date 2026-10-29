import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MRBTSID = str(tl.gnbs[0].instance_id)
NRBTSID = str(tl.gnbs[0].global_bts_id)
MRBTSname = 'MRBTS-'+MRBTSID
NRBTSname = 'NRBTS-'+NRBTSID
NRCELL1name = 'NRCELL-1'
CELLDISTname = MRBTSname+'/'+NRBTSname+'/'+NRCELL1name
NRCELLGRP0name = 'NRCELLGRP-0'
CELLGRPDISTname = MRBTSname+'/'+NRBTSname+'/'+NRCELLGRP0name

PARAMS_TO_MODIFY_2_SSBs = [
    dict(
        dist_name=CELLDISTname,
        parameter='dlMimoMode',
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing'),
    dict(
        value=[dict(basicBeamSet='beamSet_2', leftEdgeAngle='60', rightEdgeAngle='60')],
        dist_name=CELLDISTname,
        parameter='beamSet'),
    dict(
        dist_name=CELLGRPDISTname,
        parameter='numberOfTransmittedSsBlocks',
        value='2 beams')
]

PARAMS_TO_MODIFY_FD_BF_disabling = [
    dict(
        value='false',
        dist_name=CELLDISTname,
        parameter='actBeamforming'),
    dict(
        value=[dict(basicBeamSet='beamSet_1', leftEdgeAngle='60', rightEdgeAngle='60')],
        dist_name=CELLDISTname,
        parameter='beamSet'),
    dict(
        value='1 beam',
        dist_name=CELLGRPDISTname,
        parameter='numberOfTransmittedSsBlocks')
]
