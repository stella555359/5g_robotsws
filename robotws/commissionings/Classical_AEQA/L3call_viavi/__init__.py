__maintainer__ = 'Kacper Falkiewicz'
__team__ = 'MN 5G RAN I&V 3 Prodzn 04 RF & SiSo'
__email__ = 'kacper.falkiewicz@nokia.com'


PATH_TO_SCF = '/tmp/node_0xe000/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf' \
              '/5G19/5gClassicalBTS/SBTS5G19_5g_pid12_classical.xml'


PARAMS_TO_MODIFY = [
    dict(value='555', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1', p_name='mncLength'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea0'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea1_128'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea2_128'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea3_128'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab5', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab6', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab7', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab8', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab9', p_name='dlFlowControlAlgo'),
    dict(value='5G19/5g_pid12_class_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='10.1.1.3', dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', p_name='amfIPAddress'),
    dict(value='10.1.1.3', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(value='10.1.1.3', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name='localIpAddr'),
    dict(value='10.1.1.4', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name='localIpAddr'),
    dict(value='10.1.1.4', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4', p_name='localIpAddr'),
    dict(value='633356', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='dllaIniMcs'),
    dict(value='97', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='4Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='15', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='zeroCorrelationZoneConfig'),
    dict(value='12', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='type0CoresetConfigurationIndex'),
    dict(value='tdLte', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='frameStructureType'),

]


AMOUNT_OF_CELLS = 1
