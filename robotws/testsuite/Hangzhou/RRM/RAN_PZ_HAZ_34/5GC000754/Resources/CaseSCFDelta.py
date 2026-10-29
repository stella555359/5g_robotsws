import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'


PARAMS_TO_MODIFY_754 = [
    dict(value='TA-5GC000754', dist_name='MRBTS-1107', p_name='btsName'),
    dict(value='SA', dist_name='MRBTS-1107/NRBTS-1107', p_name='gNbCuType'),
    dict(value='SA', dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='cellDepType'),
    dict(value='0', dist_name='MRBTS-1101/NRBTS-1101', p_name='x2LinkSupervisionTmr'),
]

MOs_TO_Add_754 = [
    # Adapt to keyword of gNB.ModifySCF
]

PARAMS_TO_DELETE_754 = [
    dict(dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='configuredEpsTac'),
    # Adapt to keyword of gNB.ModifySCF
]

LIST_PARAMS_TO_MODIFY_754 = [
  # Adapt to keyword of gNB.ModifySCF
]

LIST_TO_ADD_754 = [
  # Adapt to keyword of gNB.ModifySCF
]

PARAMS_TO_MODIFY_754_B_4 = [
    dict(value='10.107.180.5', dist_name='MRBTS-19213/NRBTS-1213/SERVEDAMF-1', p_name='amfIPAddress')
]

MOs_TO_ADD_754_A_10 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREDRT', dist_name='MRBTS-1102/NRBTS-1102/NRCELL-1/NRREDRT-1',
         version='NRBTSCL5G20A_2003_200')
]
PARAMS_TO_MODIFY_754_A_10 = [
    # modify Element under Mo, will add if not present.
    dict(value='TA-MRBTS-1102-754_A10_SA', dist_name='MRBTS-1102', p_name='btsName'),
    dict(value='true', dist_name='MRBTS-1102/NRBTS-1102', p_name='actNormVCFallback'),
    dict(value='true', dist_name='MRBTS-1102/NRBTS-1102', p_name='actRedirect'),
    dict(value='SA', dist_name='MRBTS-1102/NRBTS-1102', p_name='gNbCuType'),
    dict(value='redirection', dist_name='MRBTS-1102/NRBTS-1102/NRCELL-1', p_name='voiceFBMode'),
    dict(value='2300', dist_name='MRBTS-1102/NRBTS-1102/NRCELL-1/NRREDRT-1', p_name='redirFreqEutra'),
    dict(value='1', dist_name='MRBTS-1102/NRBTS-1102/NRCELL-1/NRREDRT-1', p_name='redirPrio'),
    dict(value='eutra', dist_name='MRBTS-1102/NRBTS-1102/NRCELL-1/NRREDRT-1', p_name='redirRat')

]
