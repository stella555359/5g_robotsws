__maintainer__ = 'Cai Wenjuan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1_GMS <I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com>'
__email__ = 'wenjuan.cai@nokia-sbell.com'

PATH_TO_SCF = ''


PARAMS_TO_MODIFY_FOR_FEATURE = [
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', p_name='nea1_128'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', p_name='nea2_128'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', p_name='nea3_128'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', p_name='nia1_128'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', p_name='nia2_128'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', p_name='nia3_128'),
    dict(value='633356', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='dllaIniMcs'),
    dict(value='15', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='zeroCorrelationZoneConfig'),
    dict(value='12', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='type0CoresetConfigurationIndex'),
    dict(value='90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='5G18A/5g_pid12_classical_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='0.0.0.0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1',
         list_name='staticRoutes', p_name='destIpAddr'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='qciTab5Nsa3x', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='qciTab69Nsa3x', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='qciTab6Nsa3x', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='qciTab70Nsa3x', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='qciTab79Nsa3x', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='qciTab7Nsa3x', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='qciTab8Nsa3x', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='qciTab9Nsa3x', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='fiveQiTab5', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='fiveQiTab6', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='fiveQiTab7', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='fiveQiTab8', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1',
         list_name='fiveQiTab9', p_name='dlFlowControlAlgo')
]


AMOUNT_OF_CELLS = 1
