__maintainer__ = 'Zhao Nana'
__team__ = 'MN 5G RAN I&V  Line HZG 7 GMS'
__email__ = 'nana.zhao@nokia.com'

PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19B/SBTS5G19B_5g_3x_1956_A_AEUD.xml'


PARAMS_TO_MODIFY = [
    dict(value='Nokia HangZhou TL134', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='2a00:8a00:8000:13f::14', dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', p_name='amfIPAddress'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1', p_name='actMultVlan'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1', p_name='actDlDataForwardingX2Limit'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1', p_name='actGeneralConnectivityBronze'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1', p_name='actPdlRuleValidation'),
    dict(value='true',
         dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='true',
         dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1', p_name='interfaceDN'),
    dict(value='30', dist_name='MRBTS-1900/EQM-1/APEQM-1/RMOD-1', p_name='cableLength'),
    dict(value='474214A', dist_name='MRBTS-1900/EQM-1/APEQM-1/RMOD-1', p_name='prodCodePlanned'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='22454', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='gscn'),
    dict(value='22460', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='gscn'),
    dict(value='22466', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='gscn'),
    dict(value='22472', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='gscn'),
    dict(value='22478', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='gscn'),
    dict(value='22484', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='gscn'),
    dict(value='22490', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='gscn'),
    dict(value='22496', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='gscn'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x',
         p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x',
         p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab5',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab6',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab7',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab8',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab9',
         p_name='dlFlowControlAlgo'),
    dict(value='262', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='3', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1', p_name='mncLength'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='dllaIniMcs'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='dllaIniMcs'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='dllaIniMcs'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='dllaIniMcs'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='dllaIniMcs'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='dllaIniMcs'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='dllaIniMcs'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='dllaIniMcs'),
    dict(value='16376', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='lcrId'),
    dict(value='2073979', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='170', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMax'),
    dict(value='16377', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='lcrId'),
    dict(value='2075643', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='nrarfcn'),
    dict(value='170', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='pMax'),
    dict(value='51', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='physCellId'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='ullaDeltaSinrMin'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='freqBandIndicatorNR'),
    dict(value='16378', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='lcrId'),
    dict(value='2077307', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='nrarfcn'),
    dict(value='170', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='pMax'),
    dict(value='52', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='physCellId'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='ullaDeltaSinrMin'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='freqBandIndicatorNR'),
    dict(value='16379', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='lcrId'),
    dict(value='16380', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='lcrId'),
    dict(value='16381', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='lcrId'),
    dict(value='16382', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='lcrId'),
    dict(value='16383', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='lcrId'),
    dict(value='2078971', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='nrarfcn'),
    dict(value='2080635', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='nrarfcn'),
    dict(value='2082299', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='nrarfcn'),
    dict(value='2083963', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='nrarfcn'),
    dict(value='2085627', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='nrarfcn'),
    dict(value='170', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='pMax'),
    dict(value='170', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='pMax'),
    dict(value='170', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='pMax'),
    dict(value='170', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='pMax'),
    dict(value='170', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='pMax'),
    dict(value='53', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='physCellId'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='ullaDeltaSinrMin'),
    dict(value='54', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='physCellId'),
    dict(value='55', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='physCellId'),
    dict(value='56', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='physCellId'),
    dict(value='57', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='physCellId'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='ullaDeltaSinrMin'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='ullaDeltaSinrMin'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='ullaDeltaSinrMin'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='ullaDeltaSinrMin'),
    dict(value='barred', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='cellBarred'),
    dict(value='notAllowed', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='intraFreqReselection'),
    dict(value='barred', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='cellBarred'),
    dict(value='notAllowed', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='intraFreqReselection'),
    dict(value='barred', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='cellBarred'),
    dict(value='notAllowed', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='intraFreqReselection'),
    dict(value='barred', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='cellBarred'),
    dict(value='notAllowed', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='intraFreqReselection'),
    dict(value='barred', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='cellBarred'),
    dict(value='notAllowed', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='intraFreqReselection'),
    dict(value='barred', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='cellBarred'),
    dict(value='notAllowed', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='intraFreqReselection'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='(GMT+8) Asia/Shanghai', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone'),
    dict(value='2DL0UL', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='nrCellType'),
]

PARAMS_LIST_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRDU-1', list_name='f1Uplane'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRDU-1', list_name='f1Cplane'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRDU-1', list_name='f1Mplane'),
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='f1Uplane'),
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='f1Cplane'),
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='f1Mplane'),
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='s1Uplane'),
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='x2Cplane'),
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='x2Uplane')
]

PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1'),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2"),
    dict(dist_name="MRBTS-1900/NRBTS-1/SERVEDAMF-1", p_name='ngLinkStatus'),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1"),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-5/IPNO-1/IPIF-1/IPADDRESSV4-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1', p_name='btsSyncMode'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/ECPRIMASTER-1'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/TIME-1', p_name='timeZone'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1', p_name='speedAndDuplex'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-1', p_name='speedAndDuplex'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2', p_name='speedAndDuplex'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-1', p_name='speedAndDuplex'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-2', p_name='speedAndDuplex'),
    dict(dist_name='MRBTS-1900/EQM-1/SMOD_EXT-1'),
    dict(dist_name='MRBTS-1900/MNL-1', p_name='actSSHMaxAuthAttemptConfig'),
    dict(dist_name='MRBTS-1900/MNL-1', p_name='actTLS11CBCCiphersRemoval'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='beamSet', p_name='nrBtsBeamRefinementP2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='beamSet', p_name='nrBtsBeamRefinementP2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='beamSet', p_name='nrBtsBeamRefinementP2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='beamSet', p_name='nrBtsBeamRefinementP2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', list_name='beamSet', p_name='nrBtsBeamRefinementP2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', list_name='beamSet', p_name='nrBtsBeamRefinementP2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', list_name='beamSet', p_name='nrBtsBeamRefinementP2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', list_name='beamSet', p_name='nrBtsBeamRefinementP2'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-6/IPNO-1/IPIF-1/IPADDRESSV4-1')
]

OBJECTS_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        class_name="com.nokia.srbts.mnl:NTP",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRTV6-1",
        class_name="com.nokia.srbts.tnl:IPRTV6",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRTV6-1",
        class_name="com.nokia.srbts.tnl:IPRTV6",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1',
        class_name="com.nokia.srbts.tnl:VLANIF",
        version="TNL5G19B_1911_100"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-2",
         class_name="com.nokia.srbts.tnl:IPADDRESSV6",
         version="TNL5G19B_1911_100"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-3",
         class_name="com.nokia.srbts.tnl:IPADDRESSV6",
         version="TNL5G19B_1911_100"),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1',
         class_name="com.nokia.srbts.tnl:IPADDRESSV6",
         version="TNL5G19B_1911_100"),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1',
         class_name="com.nokia.srbts.tnl:IPADDRESSV6",
         version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV6-1',
        class_name="com.nokia.srbts.tnl:IPADDRESSV6",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV6-1',
        class_name="com.nokia.srbts.tnl:IPADDRESSV6",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV6-1',
        class_name="com.nokia.srbts.tnl:IPADDRESSV6",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV6-1',
        class_name="com.nokia.srbts.tnl:IPADDRESSV6",
        version="TNL5G19B_1911_100"),
]

LIST_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name="ntpServerList"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRTV6-1",
        list_name="staticIpv6Routes"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRTV6-1",
        list_name="staticIpv6Routes"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRDU-1',
        list_name='f1Uplane'),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRDU-1',
        list_name='f1Cplane'),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRDU-1',
        list_name='f1Mplane'),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='f1Uplane'),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='f1Cplane'),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='f1Mplane'),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='s1Uplane'),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='x2Cplane'),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='x2Uplane')
]

LIST_ITEM_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name='ntpServerList',
        elements={
            'ntpServerIpAddr': '10.56.126.22'}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRTV6-1",
        list_name="staticIpv6Routes",
        elements={
            "destIpv6Addr": "::",
            "destinationIpv6PrefixLength": "0",
            "gatewayIpv6Addr": "2a00:8a00:8000:136:10:57:159:8001",
            "preference": "1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="f1Cplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV6-1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="f1Mplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="f1Uplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV6-1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="s1Uplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV6-1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="x2Cplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV6-1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="x2Uplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV6-1"}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRTV6-1",
        list_name="staticIpv6Routes",
        elements={
              "destIpv6Addr": "::",
              "destinationIpv6PrefixLength": "0",
              "gatewayIpv6Addr": "2a00:8a00:8000:136:10:57:159:8001",
              "preference": "1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRDU-1",
        list_name="f1Uplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-2"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRDU-1",
        list_name="f1Cplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRDU-1",
        list_name="f1Mplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-3"}),
    ]

LIST_ELEMENT_TO_ADD = []

# parameters with value to add
PARAMS_TO_ADD = [
    dict(
        value='F1-M',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='DISCOVERED',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='X2-C',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV6-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='DISCOVERED',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV6-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='F1-C',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV6-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='DISCOVERED',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV6-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='X2-U S1-U',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV6-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='DISCOVERED',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV6-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='F1-U',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV6-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='DISCOVERED',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV6-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='1806',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1',
        p_name='vlanId'),
    dict(
        value='fc00::172:16:5:180',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-2',
        p_name='localIpAddr'),
    dict(
        value='112',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-2',
        p_name='localIpPrefixLength'),
    dict(
        value='MANUAL',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-2',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='fc00::172:16:5:160',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-3',
        p_name='localIpAddr'),
    dict(
        value='112',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-3',
        p_name='localIpPrefixLength'),
    dict(
        value='MANUAL',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-3',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/CERTHENT-1',
        p_name='sModDN'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='configuredEpsTac'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='configuredEpsTac'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='configuredEpsTac'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='configuredEpsTac'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-5',
        p_name='configuredEpsTac'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-6',
        p_name='configuredEpsTac'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-7',
        p_name='configuredEpsTac'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-8',
        p_name='configuredEpsTac'),
    dict(
        value='fc00::172:16:5:170',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1',
        p_name='localIpAddr'),
    dict(
        value='112',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1',
        p_name='localIpPrefixLength'),
    dict(
        value='MANUAL',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='3',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='e1NbResetRetryForFault'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='timerX2DataFwdGuard'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1',
        p_name='actEcpriMasterClock'),
    dict(
        value='Disabled',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        p_name='outputConfiguration1Pps'),
    dict(
        value='Disabled',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        p_name='outputConfiguration2M048'),
]
