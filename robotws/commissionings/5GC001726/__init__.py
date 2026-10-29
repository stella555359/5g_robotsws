__maintainer__ = 'Zhao Nana'
__team__ = 'MN 5G RAN I&V  Line HZG 7 GMS'
__email__ = 'nana.zhao@nokia.com'

PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19B/SBTS5G19B_5g_1596_H_AEUD_ASOD.xml'

PARAMS_TO_MODIFY = [
    dict(value='Nokia HGZ TL123', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='ASOD', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProductVariantPlanned'),
    dict(value='2a00:8a00:8000:13f::14', dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', p_name='amfIPAddress'),
    dict(value='true',
         dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='true',
         dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='backhaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-1', p_name='underLyingInterface'),
    dict(value='fronthaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2', p_name='underLyingInterface'),
    dict(value='backhaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-1', p_name='underLyingInterface'),
    dict(value='fronthaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-2', p_name='underLyingInterface'),
    dict(value='474611A', dist_name='MRBTS-1900/EQM-1/APEQM-1/RMOD-1', p_name='prodCodePlanned'),
    dict(value='30', dist_name='MRBTS-1900/EQM-1/APEQM-1/RMOD-1', p_name='cableLength'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='22446', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='gscn'),
    dict(value='22452', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='gscn'),
    dict(value='22458', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='gscn'),
    dict(value='22464', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='gscn'),
    dict(value='22470', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='gscn'),
    dict(value='22476', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='gscn'),
    dict(value='22482', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='gscn'),
    dict(value='22488', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='gscn'),
    dict(value='false', dist_name='MRBTS-1900/NRBTS-1', p_name='actCarrierAggregation'),
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
    dict(value='16372', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='lcrId'),
    dict(value='2071675', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMax'),
    dict(value='-20', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssPbchBlockPower'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='freqBandIndicatorNR'),
    dict(value='16373', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='lcrId'),
    dict(value='2073339', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='nrarfcn'),
    dict(value='90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='pMax'),
    dict(value='-20', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='ssPbchBlockPower'),
    dict(value='51', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='physCellId'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='ullaDeltaSinrMin'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='freqBandIndicatorNR'),
    dict(value='16374', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='lcrId'),
    dict(value='2075003', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='nrarfcn'),
    dict(value='90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='pMax'),
    dict(value='-20', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='ssPbchBlockPower'),
    dict(value='52', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='physCellId'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='ullaDeltaSinrMin'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='freqBandIndicatorNR'),
    dict(value='16375', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='lcrId'),
    dict(value='2076667', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='nrarfcn'),
    dict(value='90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='pMax'),
    dict(value='-20', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='ssPbchBlockPower'),
    dict(value='53', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='physCellId'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='ullaDeltaSinrMin'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='freqBandIndicatorNR'),
    dict(value='16376', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='lcrId'),
    dict(value='2078331', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='nrarfcn'),
    dict(value='90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='pMax'),
    dict(value='-20', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='ssPbchBlockPower'),
    dict(value='54', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='physCellId'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='ullaDeltaSinrMin'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='freqBandIndicatorNR'),
    dict(value='16377', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='lcrId'),
    dict(value='2079995', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='nrarfcn'),
    dict(value='90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='pMax'),
    dict(value='-20', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='ssPbchBlockPower'),
    dict(value='55', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='physCellId'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='ullaDeltaSinrMin'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='freqBandIndicatorNR'),
    dict(value='16378', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='lcrId'),
    dict(value='2081659', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='nrarfcn'),
    dict(value='90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='pMax'),
    dict(value='-20', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='ssPbchBlockPower'),
    dict(value='56', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='physCellId'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='ullaDeltaSinrMin'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='freqBandIndicatorNR'),
    dict(value='16379', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='lcrId'),
    dict(value='2083323', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='nrarfcn'),
    dict(value='90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='pMax'),
    dict(value='-20', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='ssPbchBlockPower'),
    dict(value='57', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='physCellId'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='ullaDeltaSinrMin'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-3/IPADDRESSV6-1',
         dist_name='MRBTS-1900/NRBTS-1/NRDU-1', list_name='f1Mplane', p_name='ipV4AddressDN1'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV6-1',
         dist_name='MRBTS-1900/NRBTS-1/NRDU-1', list_name='f1Uplane', p_name='ipV4AddressDN1'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1', p_name='actPdlRuleValidation'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='maxNoCPUEVMs'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1', p_name='interfaceDN'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-2',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2', p_name='interfaceDN'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-3',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-3', p_name='interfaceDN'),
    dict(value='2DL2UL', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrCellType'),
    dict(value='2DL2UL', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name='MRBTS-1900/NRBTS-1/NRCELL-5', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name='MRBTS-1900/NRBTS-1/NRCELL-6', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name='MRBTS-1900/NRBTS-1/NRCELL-7', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name='MRBTS-1900/NRBTS-1/NRCELL-8', p_name='nrCellType'),
    dict(value='(GMT+8) Asia/Shanghai', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-2/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='f1om', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1', p_name='underLyingInterface'),
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
    dict(dist_name='MRBTS-1900/EQM-1/SMOD_EXT-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-5/ETHSVC-1/ETHIF-1/VLANIF-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-5/ETHSVC-1/ETHLK-1', p_name='modDN'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-5/ETHSVC-1/ETHLK-1', p_name='connectorLabel'),
]

OBJECTS_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-2',
        class_name="com.nokia.srbts.tnl:ETHLK",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-3',
        class_name="com.nokia.srbts.tnl:ETHLK",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-2',
        class_name="com.nokia.srbts.tnl:ETHIF",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-2/VLANIF-1',
        class_name="com.nokia.srbts.tnl:VLANIF",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-3',
        class_name="com.nokia.srbts.tnl:ETHIF",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-3/VLANIF-1',
        class_name="com.nokia.srbts.tnl:VLANIF",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2',
        class_name="com.nokia.srbts.tnl:IPIF",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-3",
        class_name="com.nokia.srbts.tnl:IPIF",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-2',
        class_name="com.nokia.srbts.eqm:SFP",
        version="EQM5G19B_1911_200"),
    dict(
        dist_name="MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-3",
        class_name="com.nokia.srbts.eqm:SFP",
        version="EQM5G19B_1911_200"),
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
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1",
         class_name="com.nokia.srbts.tnl:IPADDRESSV6",
         version="TNL5G19B_1911_100"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-3/IPADDRESSV6-1",
         class_name="com.nokia.srbts.tnl:IPADDRESSV6",
         version="TNL5G19B_1911_100"),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV6-1',
         class_name="com.nokia.srbts.tnl:IPADDRESSV6",
         version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1',
        class_name="com.nokia.srbts.tnl:VLANIF",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-2',
        class_name="com.nokia.srbts.tnl:VLANIF",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-3',
        class_name="com.nokia.srbts.tnl:VLANIF",
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
            'ntpServerIpAddr': '2a00:8a00:8000:101::6'}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRTV6-1",
        list_name="staticIpv6Routes",
        elements={
            "destIpv6Addr": "::",
            "destinationIpv6PrefixLength": "0",
            "gatewayIpv6Addr": "2a00:8a00:8000:136:10:57:171:8001",
            "preference": "1"}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRTV6-1",
        list_name="staticIpv6Routes",
        elements={
              "destIpv6Addr": "::",
              "destinationIpv6PrefixLength": "0",
              "gatewayIpv6Addr": "2a00:8a00:8000:136:10:57:171:8001",
              "preference": "1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRDU-1",
        list_name="f1Uplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV6-1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRDU-1",
        list_name="f1Cplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV6-1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRDU-1",
        list_name="f1Mplane",
        elements={
              "ipV6AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-3/IPADDRESSV6-1"}),
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
    ]

LIST_ELEMENT_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-5',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-6',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-7',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-8',
        list_name='fPdcchMonOccsnPo',
        elements=['1610'])
]

# parameters with value to add
PARAMS_TO_ADD = [
    dict(
        value='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-2',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2',
        p_name='interfaceDN'),
    dict(
        value='1500',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2',
        p_name='ipMtu'),
    dict(
        value='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-3',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-3',
        p_name='interfaceDN'),
    dict(
        value='1500',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-3',
        p_name='ipMtu'),
    dict(
        value='enabled',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1',
        p_name='serviceAccountSshStatus'),
    dict(
        value='f1om',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-5/ETHSVC-1/ETHLK-1',
        p_name='underLyingInterface'),
    dict(
        value='unlocked',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-2',
        p_name='administrativeState'),
    dict(
        value='S-RF1',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-2',
        p_name='connectorLabel'),
    dict(
        value='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-2',
        p_name='modDN'),
    dict(
        value='AUTODETECT',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-2',
        p_name='speedAndDuplex'),
    dict(
        value='unlocked',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-3',
        p_name='administrativeState'),
    dict(
        value='S-RF2',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-3',
        p_name='connectorLabel'),
    dict(
        value='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-3',
        p_name='modDN'),
    dict(
        value='AUTODETECT',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-3',
        p_name='speedAndDuplex'),
    dict(
        value='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-2',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-2',
        p_name='linkSelectorDN'),
    dict(
        value='false',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-2',
        p_name='txPriorityTagging'),
    dict(
        value='1',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-2/VLANIF-1',
        p_name='vlanId'),
    dict(
        value='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHLK-3',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-3',
        p_name='linkSelectorDN'),
    dict(
        value='false',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-3',
        p_name='txPriorityTagging'),
    dict(
        value='1',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-3/VLANIF-1',
        p_name='vlanId'),
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
        value='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/CERTHENT-1',
        p_name='sModDN'),
    dict(
        value='4460',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='configuredEpsTac'),
    dict(
        value='4460',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='configuredEpsTac'),
    dict(
        value='4460',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='configuredEpsTac'),
    dict(
        value='4460',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='configuredEpsTac'),
    dict(
        value='4460',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-5',
        p_name='configuredEpsTac'),
    dict(
        value='4460',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-6',
        p_name='configuredEpsTac'),
    dict(
        value='4460',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-7',
        p_name='configuredEpsTac'),
    dict(
        value='4460',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-8',
        p_name='configuredEpsTac'),
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
    dict(
        value='fc00::172:110:21:130',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-3/IPADDRESSV6-1',
        p_name='localIpAddr'),
    dict(
        value='112',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-3/IPADDRESSV6-1',
        p_name='localIpPrefixLength'),
    dict(
        value='MANUAL',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-3/IPADDRESSV6-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='fc00::172:110:23:130',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV6-1',
        p_name='localIpAddr'),
    dict(
        value='112',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV6-1',
        p_name='localIpPrefixLength'),
    dict(
        value='MANUAL',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV6-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='fc00::172:110:22:130',
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
        value='2248',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1',
        p_name='vlanId'),
    dict(
        value='2246',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-2',
        p_name='vlanId'),
    dict(
        value='2249',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-3',
        p_name='vlanId'),
]
