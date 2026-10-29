import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

MR_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_NAME = MR_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_NAME + '/NRCELL-1'
MR_NR_CELLGRP_NAME = MR_NR_NAME + '/NRCELLGRP-0'

ALLOW_FAULT = [
    {'faultId': 61652},
    {'faultId': 61524},
    {'faultId': 61649},
    {'faultId': 9000},
    {'faultId': 4592},
    {'faultId': 4527},
    {'faultId': 1932},
    {'faultId': 4334},
    {'faultId': 61074},
    {'faultId': 61618},
    {'faultId': 4687},
    {'faultId': 4654},
    {'faultId': 4655},
    {'faultId': 4681},
]


Para_5GC002089 = [
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actBeamforming',
        new_value='true'),
    dict(
        operate='update',
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='numberOfTransmittedSsBlocks',
        new_value='4 beam'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF',
        new_value='true'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet',
        new_value='beamSet_4')
]
