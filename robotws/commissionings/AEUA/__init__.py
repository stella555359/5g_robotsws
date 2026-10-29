__maintainer__ = 'Pawel Zabawczuk'
__team__ = 'RRM team'
__email__ = 'pawel.k.zabawczuk@nokia.com'


PATH_TO_SCF = ''


PARAMS_TO_MODIFY = [
    dict(value=38, dist_name='NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='false', dist_name='MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='true', dist_name='MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='2059000', dist_name='NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='semiStatic', dist_name='NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio')
]


PARAMS_TO_DELETE = [
    dict(dist_name='NRBTS-1/NRCELL-2'),
    dict(dist_name='NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='NRBTS-1/NRCELL-3'),
    dict(dist_name='NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='NRBTS-1/NRCELL-4'),
    dict(dist_name='NRBTS-1/NRCELL-4/NRCELL_FDD-1')
]


AMOUNT_OF_CELLS = 1
