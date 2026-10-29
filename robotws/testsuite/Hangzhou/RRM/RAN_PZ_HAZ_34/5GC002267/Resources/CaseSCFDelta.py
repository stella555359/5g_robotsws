import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'

PARAMS_TO_MODIFY_2267 = [
    dict(value='5GC002267_1cellSA_caseA02', dist_name='MRBTS-207', p_name='btsName'),
    dict(value='viaRRCSetup', dist_name='MRBTS-207/NRBTS-207', p_name='rrcReestabTypeSA'),
    dict(value='t1', dist_name='MRBTS-207/NRBTS-207/NRDRB_RLC_AM-1', p_name='dlMaxRetxThreshold'),
    dict(value='t1', dist_name='MRBTS-207/NRBTS-207/NRDRB_RLC_AM-1', p_name='ulMaxRetxThreshold'),
    dict(value='t1', dist_name='MRBTS-207/NRBTS-207/NRDRB_RLC_AM-2', p_name='dlMaxRetxThreshold'),
    dict(value='t1', dist_name='MRBTS-207/NRBTS-207/NRDRB_RLC_AM-2', p_name='ulMaxRetxThreshold'),
    dict(value='5min', dist_name='MRBTS-19209/NRBTS-1209/NRPMRNL-1', p_name='miNrRRCC'),
    dict(value='5min', dist_name='MRBTS-19209/NRBTS-1209/NRPMRNL-1', p_name='miNrRRCD'),
    dict(value='5min', dist_name='MRBTS-19209/NRBTS-1209/NRPMRNL-1', p_name='miNrRlfPerCell')

]

MOs_TO_Add_2267 = [
    # Adapt to keyword of gNB.ModifySCF
]

PARAMS_TO_DELETE_2267 = [
    # Adapt to keyword of gNB.ModifySCF
]

LIST_PARAMS_TO_MODIFY_2267 = [
    # Adapt to keyword of gNB.ModifySCF
]

LIST_TO_ADD_2267 = [
    # Adapt to keyword of gNB.ModifySCF
]
