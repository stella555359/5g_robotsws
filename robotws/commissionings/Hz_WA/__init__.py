__maintainer__ = 'TBD'
__team__ = 'TBS'
__email__ = 'TBD'

from cloud5g.commissioning import CustomCommissioningBase


PARAMS_TO_DELETE = [
    # delete entire Manage Object
    dict(dist_name='MRBTS-1969/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-5'),
]


PARAMS_TO_MODIFY_TL = [
    dict(value='10.57.247.83',
         dist_name='MRBTS-1969/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(value='27',
         dist_name='MRBTS-1969/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(value='10.57.247.81', dist_name='MRBTS-1969/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='gateway')
]
