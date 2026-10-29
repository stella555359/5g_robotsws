import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'

PARAMS_TO_MODIFY_6555_A02 = [
    dict(value='CB006555_A02_TA', dist_name='MRBTS-207', p_name='btsName'),
    dict(value='20', dist_name='MRBTS-5/NRBTS-5/NRCELLGRP-0', p_name='ssBurstSetPeriod'),
    dict(value='251', dist_name='MRBTS-207/NRBTS-207/NRSYSINFO_PROFILE-1', p_name='systemInformationTargetRate'),
    dict(value='10', dist_name='MRBTS-207/NRBTS-207/NRCELL-1', p_name='type0CoresetConfigurationIndex'),
    dict(value='pos3', dist_name='MRBTS-207/NRBTS-207/NRCELL-1', p_name='dmrsTypeAPosition'),
]

PARAMS_TO_DELETE_6555_A02 = [

]

ADD_MOs_6555_A02 = [
]

LIST_TO_ADD_6555_A02 = [
]

LIST_PARAMS_TO_MODIFY_6555_A02 = [
    # BWP
    dict(dist_name='MRBTS-1107/NRBTS-1107/BWP_PROFILE-1/PDCCH-1/PDCCH_CONFIG_COMMON-1', list_name='searchSpaceCommon',
         elements=[dict(p_name='monitoringSymbolWithinSlot', value='symbol_0', index=0),
                   dict(p_name='searchSpaceType', value='Type0A', index=0),
                   dict(p_name='monitoringSymbolWithinSlot', value='symbol_0', index=1),
                   dict(p_name='searchSpaceType', value='Type1', index=1),
                   dict(p_name='numOfPdcchCandidatesInAL4', value='n2', index=1),
                   dict(p_name='monitoringSymbolWithinSlot', value='symbol_0', index=2),
                   dict(p_name='searchSpaceType', value='Type2', index=2)]),
    dict(dist_name='MRBTS-1107/NRBTS-1107/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1', list_name='searchSpaceCommon',
         elements=[dict(p_name='monitoringSymbolWithinSlot', value='symbol_0', index=0),
                   dict(p_name='searchSpaceType', value='Type0A', index=0),
                   dict(p_name='monitoringSymbolWithinSlot', value='symbol_0', index=1),
                   dict(p_name='searchSpaceType', value='Type1', index=1),
                   dict(p_name='numOfPdcchCandidatesInAL4', value='n2', index=1),
                   dict(p_name='monitoringSymbolWithinSlot', value='symbol_0', index=2),
                   dict(p_name='searchSpaceType', value='Type2', index=2)]),
    dict(dist_name='MRBTS-1107/NRBTS-1107/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         list_name='searchSpaceDedicated',
         elements=[dict(p_name='coresetId', value='0', index=0),
                   dict(p_name='searchSpaceType', value='Type3', index=0),
                   dict(p_name='coresetId', value='1', index=1),
                   dict(p_name='monitoringSymbolWithinSlot', value='symbol_0_1_2', index=1),
                   dict(p_name='numOfPdcchCandidatesInAL4', value='n2', index=1)]),
]
