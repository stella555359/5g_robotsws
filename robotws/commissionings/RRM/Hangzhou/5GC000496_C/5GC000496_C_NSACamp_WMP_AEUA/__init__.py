__maintainer__ = 'Xing Jing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jing.1.xing@nokia-sbell.com'

PATH_TO_SCF = ''


_distname = 'MRBTS-1900/NRBTS-1'
_p_name = 'dlFlowControlAlgo'
_p_data = 'ulDataPath'
_dist_name = 'MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1'
_dista = 'MRBTS-1900/NRBTS-1/NRCELL-1'


PARAMS_TO_MODIFY_FOR_FEATURE = [
    dict(value='Nokia Hangzhou', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='location'),
    dict(value='Nokia HZ TL029', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='38', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='15', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='zeroCorrelationZoneConfig'),
    dict(value='2073343', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='5G18A/5g_pid11_classical_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='0.0.0.0', dist_name=_dist_name, list_name='staticRoutes', p_name='destIpAddr'),
    dict(value='0', dist_name=_dist_name, list_name='staticRoutes', p_name='destinationIpPrefixLength'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='-72', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPusch'),
    dict(value='-108', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPucch'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab5Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab5Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab69Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab69Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab6Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab6Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab70Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab70Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab79Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab79Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab7Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab7Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab8Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab8Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab9Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab9Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab5', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab6', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab7', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab8', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab9', p_name=_p_name),
    dict(value='semiStatic', dist_name=_dista, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_dista, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_dista, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='16', dist_name=_dista, p_name='nrofHARQProcessesForPDSCH')
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
