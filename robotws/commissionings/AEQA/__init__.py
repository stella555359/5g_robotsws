__maintainer__ = 'Anna Prusakowska'
__team__ = 'RRM team'
__email__ = 'anna.prusakowska@nokia.com'


PATH_TO_SCF = ''

PARAMS_TO_MODIFY = [
    dict(value='false', dist_name='MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='555', dist_name='NRBTS-1', p_name='mcc'),
    dict(value='10', dist_name='NRBTS-1', p_name='mnc'),
    dict(value='2', dist_name='NRBTS-1', p_name='mncLength'),
    dict(value='94', dist_name='NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='633356', dist_name='NRBTS-1/NRCELL-1', p_name='nrarfcn')
]


AMOUNT_OF_CELLS = 1
