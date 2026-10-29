import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'


# ###Feature level change
PARAMS_TO_MODIFY_866 = [
    dict(value='5GC000866_TA_1CELL_SA', dist_name='MRBTS-1107', p_name='btsName'),
    dict(value='SA', dist_name='MRBTS-1107/NRBTS-1107', p_name='gNbCuType'),
    dict(value='SA', dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='cellDepType'),
]
PARAMS_TO_REMOVE_866 = [
    dict(dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='configuredEpsTac'),
]
