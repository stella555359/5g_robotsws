__maintainer__ = 'Kacper Falkiewicz'
__team__ = 'MN 5G RAN I&V 3 Prodzn 04 RF & SiSo'
__email__ = 'kacper.falkiewicz@nokia.com'


PATH_TO_SCF = '/tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf' \
              '/5G19/5gClassicalBTS/SBTS5G19_5g_pid12_classical.xml'

PARAMS_TO_MODIFY = [
    dict(value='5G19/5g_pid12_class_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='646666', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='10.1.1.3', dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', p_name='amfIPAddress'),
    dict(value='10.1.1.3', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(value='10.1.1.3', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name='localIpAddr'),
    dict(value='10.1.1.4', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name='localIpAddr'),
    dict(value='10.1.1.4', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4', p_name='localIpAddr'),
]


AMOUNT_OF_CELLS = 1
