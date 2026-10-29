import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'


PARAMS_TO_MODIFY_638 = [
    dict(value='TA_1cellSA_5GC000638', dist_name='MRBTS-1107', p_name='btsName'),
    dict(value='SA', dist_name='MRBTS-1107/NRBTS-1107', p_name='gNbCuType'),
    dict(value='SA', dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='cellDepType'),
    dict(value='0', dist_name='MRBTS-1101/NRBTS-1101', p_name='x2LinkSupervisionTmr'),
]

MOs_TO_Add_638 = [
 # Adapt to keyword of gNB.ModifySCF
]

PARAMS_TO_DELETE_638 = [
    dict(dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='configuredEpsTac'),

]

LIST_PARAMS_TO_MODIFY_638 = [
 # Adapt to keyword of gNB.ModifySCF
]

LIST_TO_ADD_638 = [
 # Adapt to keyword of gNB.ModifySCF
]
