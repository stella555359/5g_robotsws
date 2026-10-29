__maintainer__ = 'Jakub Hupinow'
__team__ = 'TRS team'
__email__ = 'jakub.hupinow@nokia.com'


PATH_TO_SCF = ''


PARAMS_TO_MODIFY = [
    dict(value=1, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value=2, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachRootSequenceIndex'),
    dict(value='192.168.4.111', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='localIpAddr'),
    dict(value='192.168.4.112', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='localIpAddr'),
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
