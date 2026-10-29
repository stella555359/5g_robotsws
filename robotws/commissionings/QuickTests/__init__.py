__maintainer__ = 'QT WRO'
__team__ = 'MN 5G RAN Pz WRO CI'
__email__ = 'I_5GQT_WRO@internal.nsn.com'

PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19/SBTS5G19_5g_pid11.xml'

PARAMS_TO_MODIFY = [
    dict(value='Nokia Wroclaw TL1907', dist_name='MRBTS-1900', p_name='btsName'),
    # dict(value=1, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    # dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    # dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='192.168.4.120', dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', p_name='amfIPAddress'),
    # dict(value='192.168.4.111', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
    #      p_name='localIpAddr'),
    # dict(value='192.168.4.112', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
    #      p_name='localIpAddr'),
    dict(value='5G19/5g_pid11_CPNRT_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='2059000', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    # dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-2/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    # dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServicePortState'),
    # dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServicePortState'),
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
