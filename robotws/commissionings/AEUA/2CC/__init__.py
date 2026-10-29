__maintainer__ = 'Pawel Zabawczuk'
__team__ = 'RRM team'
__email__ = 'pawel.k.zabawczuk@nokia.com'


PATH_TO_SCF = ''


PARAMS_TO_MODIFY = [
    dict(value=38, dist_name='NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='2059000', dist_name='NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='semiStatic', dist_name='NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value=38, dist_name='NRBTS-1/NRCELL-2', p_name='prachConfigurationIndex'),
    dict(value='2060731', dist_name='NRBTS-1/NRCELL-2', p_name='nrarfcn'),
    dict(value='semiStatic', dist_name='NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio')
]


AMOUNT_OF_CELLS = 2
