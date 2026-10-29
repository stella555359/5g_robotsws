__maintainer__ = 'Chen Jun'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_6_GMS <I_MN_5G_RAN_IV4_LINE_HZG_6@internal.nsn.com>'
__email__ = 'jun.8.chen@nokia-sbell.com'

PATH_TO_SCF = ''

PARAMS_TO_MODIFY = [
    dict(value='5G18A/5g_pid11_classical_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='Nokia HZ', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='location'),
    dict(value='(GMT+8) Asia/Shanghai', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x',
         p_name='ulDataPath'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x',
         p_name='ulDataPath'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x',
         p_name='ulDataPath'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x',
         p_name='ulDataPath'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x',
         p_name='ulDataPath'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x',
         p_name='ulDataPath'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x',
         p_name='ulDataPath'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x',
         p_name='ulDataPath'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab5',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab6',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab7',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab8',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab9',
         p_name='dlFlowControlAlgo'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable')
]

PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1')
]

AMOUNT_OF_CELLS = 1
