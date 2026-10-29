__maintainer__ = 'Mateusz Nykiel'
__team__ = 'cOAM'
__email__ = 'mateusz.nykiel@nokia.com'


PATH_TO_SCF = ''


PARAMS_TO_MODIFY = [
    dict(value='1904', dist_name='MRBTS-10191/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-5', p_name='vlanId'),
    dict(value='10.1.1.1', dist_name='MRBTS-10191/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(value='24', dist_name='MRBTS-10191/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(value='10.1.1.100', dist_name='MRBTS-10191/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='gateway',
         list_name='staticRoutes', index=2),
]
