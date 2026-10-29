__maintainer__ = 'Fabienne Magueur'
__team__ = 'RRM Nps team'
__email__ = 'fabienne.magueur@nokia.com'

PATH_TO_SCF = ''

PARAMS_TO_MODIFY = [
    dict(value='378', dist_name='MRBTS-10191/NRBTS-23177/NRCELL-1', list_name='fPdcchMonOccsnPo', index=0),
    dict(value='19', dist_name='MRBTS-10191/NRBTS-23177/NRCELL-1', p_name='rsrpThresholdSSB'),
    dict(value='2', dist_name='MRBTS-10191/NRBTS-23177', p_name='mncLength'),
    dict(value='474214A', dist_name='MRBTS-10191/EQM-1/APEQM-1/RMOD-1', p_name='prodCodePlanned')
]
