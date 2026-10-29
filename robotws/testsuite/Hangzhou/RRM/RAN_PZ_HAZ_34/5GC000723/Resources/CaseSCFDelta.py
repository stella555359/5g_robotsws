import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'


PARAMS_TO_MODIFY_FOR_723_ATB = [
    dict(value='-104', dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='initialPreambleReceivedTargetPower'),
    dict(value='-65', dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='qRxLevMin'),
    dict(value='28', dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='ssPbchBlockPower')

]

PARAMS_TO_DELETE_723 = [
    # can be Mo, Element, list and so on.
    dict(dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='configuredEpsTac')
]

PARAMS_TO_MODIFY_723 = [
    # modify Element under Mo, will add if not present.
    dict(value='5GC000723_TA_1cell_SA', dist_name='MRBTS-1107', p_name='btsName'),
    dict(value='SA', dist_name='MRBTS-1101/NRBTS-1101', p_name='gNbCuType'),
    dict(value='SA', dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='cellDepType'),
    dict(value='false', dist_name='MRBTS-1107/NRBTS-1107/NRCELLGRP-0', p_name='actProactUlScheduling'),
    dict(value='0', dist_name='MRBTS-1101/NRBTS-1101', p_name='x2LinkSupervisionTmr'),

]

MOs_TO_ADD_723 = [
]

LIST_PARAMS_TO_MODIFY_723 = [
]

List_TO_ADD_723 = [
]
