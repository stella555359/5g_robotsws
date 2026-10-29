__maintainer__ = 'Oleksii Mikhanchuk'
__team__ = 'MN 5G RAN I&V Cloud'
__email__ = 'I_5G_TLM_WRO@internal.nsn.com'
__owner_email__ = 'oleksii.mikhanchuk@nokia.com'


PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19/SBTS5G19_5g_pid11.xml'


PARAMS_TO_MODIFY = [
    dict(dist_name='MRBTS-1900', p_name='btsName', value='cloud 016 T01'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn', value='2071591'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='gscn', value='22446'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex', value=1),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable', value='false'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-2/FEATCADM-1', p_name='systemAcctPermEnable', value='false'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh', value='true'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServiceAccountSsh', value='true'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServicePortState', value='false'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServicePortState', value='false'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled', value='false'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='ethernetPortSecurityEnabled', value='false'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachRootSequenceIndex', value='0'),
    dict(dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile', value='5G19/rap/5g_pid11'),
    dict(dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='location', value='WL rack 636'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone', value='(GMT+1) Europe/Warsaw')
]


PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),


    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1')
]

AMOUNT_OF_CELLS = 1
