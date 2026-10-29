__maintainer__ = 'Wu Charlotte'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02_GMS'
__email__ = 'charlotte.wu@nokia-sbell.com'

PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19A/SBTS5G19A_5g_1427_6_AEUE.xml'


PARAMS_TO_MODIFY = [
    dict(value='Nokia HGZ TL325', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='ASOD', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProductVariantPlanned'),
    dict(value='10.57.247.62', dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', p_name='amfIPAddress'),
    dict(value='172.16.5.161',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(value='172.16.5.162',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name='localIpAddr'),
    dict(value='172.16.5.160',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name='localIpAddr'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1', p_name='interfaceDN'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-2/FEATCADM-1', p_name='systemAcctPermEnable'),
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
    dict(value='22446', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='gscn'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='actDynUlDataSplitMode'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1', p_name='actCarrierAggregation'),
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
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1', p_name='sCCNumber'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL',
         p_name='nea1_128'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL',
         p_name='nea2_128'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL',
         p_name='nea3_128'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='actBeamforming'),
    dict(value='No additional DMRS', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='dlDMRSAdditionalPosition'),
    dict(value='No additional DMRS', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ulDMRSAdditionalPosition'),
    dict(value='16372', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='lcrId'),
    dict(value='2071675', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='12', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrofHARQProcessesForPDSCH'),
    dict(value='190', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMax'),
    dict(value='19', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMaxNROwnCell'),
    dict(value='-10', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssPbchBlockPower'),
    dict(value='50', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='physCellId'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='-78', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='ulPowerControlCommon',
         p_name='p0NominalPusch'),
    dict(value='-90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='ulPowerControlCommon',
         p_name='p0NominalPucch'),
    dict(value='-80', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='ulPowerControlCommon',
         p_name='p0NominalSrs'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='actDynUlDataSplitMode'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='freqBandIndicatorNR'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='actBeamforming'),
    dict(value='No additional DMRS', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='dlDMRSAdditionalPosition'),
    dict(value='No additional DMRS', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='ulDMRSAdditionalPosition'),
    dict(value='22452', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='gscn'),
    dict(value='16373', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='lcrId'),
    dict(value='2073339', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='nrarfcn'),
    dict(value='12', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='nrofHARQProcessesForPDSCH'),
    dict(value='190', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='pMax'),
    dict(value='19', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='pMaxNROwnCell'),
    dict(value='-10', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='ssPbchBlockPower'),
    dict(value='50', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='physCellId'),
    dict(value='-78', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='ulPowerControlCommon',
         p_name='p0NominalPusch'),
    dict(value='-90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='ulPowerControlCommon',
         p_name='p0NominalPucch'),
    dict(value='-80', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='ulPowerControlCommon',
         p_name='p0NominalSrs'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='barred', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='cellBarred'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='actDynUlDataSplitMode'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='freqBandIndicatorNR'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='actBeamforming'),
    dict(value='No additional DMRS', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='dlDMRSAdditionalPosition'),
    dict(value='No additional DMRS', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='ulDMRSAdditionalPosition'),
    dict(value='22458', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='gscn'),
    dict(value='16374', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='lcrId'),
    dict(value='2075003', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='nrarfcn'),
    dict(value='12', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='nrofHARQProcessesForPDSCH'),
    dict(value='190', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='pMax'),
    dict(value='-10', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='ssPbchBlockPower'),
    dict(value='19', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='pMaxNROwnCell'),
    dict(value='-78', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='ulPowerControlCommon',
         p_name='p0NominalPusch'),
    dict(value='-90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='ulPowerControlCommon',
         p_name='p0NominalPucch'),
    dict(value='-80', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='ulPowerControlCommon',
         p_name='p0NominalSrs'),
    dict(value='50', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='physCellId'),
    dict(value='barred', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='cellBarred'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='actDynUlDataSplitMode'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='actBeamforming'),
    dict(value='No additional DMRS', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='dlDMRSAdditionalPosition'),
    dict(value='No additional DMRS', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='ulDMRSAdditionalPosition'),
    dict(value='261', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='freqBandIndicatorNR'),
    dict(value='22464', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='gscn'),
    dict(value='16375', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='lcrId'),
    dict(value='2076667', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='nrarfcn'),
    dict(value='12', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='nrofHARQProcessesForPDSCH'),
    dict(value='190', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='pMax'),
    dict(value='19', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='pMaxNROwnCell'),
    dict(value='-10', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='ssPbchBlockPower'),
    dict(value='-78', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='ulPowerControlCommon',
         p_name='p0NominalPusch'),
    dict(value='-90', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='ulPowerControlCommon',
         p_name='p0NominalPucch'),
    dict(value='-80', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='ulPowerControlCommon',
         p_name='p0NominalSrs'),
    dict(value='barred', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='cellBarred'),
    dict(value='50', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='physCellId'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='8', dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', p_name='maxDlHarqTx'),
    dict(value='8', dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', p_name='maxUlHarqTx'),
    dict(value='8', dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', p_name='maxHarqMsg3Tx'),
    dict(value='32 beams', dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', p_name='numberOfTransmittedSsBlocks'),
    dict(value='20', dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', p_name='ssBurstSetPeriod'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1', p_name='actPdlRuleValidation')
]

PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1"),
    dict(dist_name="MRBTS-1900/NRBTS-1/SERVEDAMF-1", p_name='ngLinkStatus'),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1")
]

PARAMS_LIST_TO_DELETE = [
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name="beamSet"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-2",
        list_name="beamSet"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-3",
        list_name="beamSet"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-4",
        list_name="beamSet")
]

OBJECTS_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/TIME-1',
        class_name="com.nokia.srbts.mnl:TIME",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        class_name="com.nokia.srbts.mnl:TOPP",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
        class_name="com.nokia.srbts.mnl:TOP",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1',
        class_name="com.nokia.srbts.mnl:CLOCK",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        class_name="com.nokia.srbts.mnl:SYNC",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        class_name="com.nokia.srbts.mnl:NTP",
        version="MNL5G19A_1904_200"),

    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        class_name="com.nokia.srbts.tnl:IPRT",
        version="TNL5G19A_1904_200"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1",
        class_name="com.nokia.srbts.tnl:IPRT",
        version="TNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1',
        class_name="com.nokia.srbts.tnl:VLANIF",
        version="TNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2',
        class_name="com.nokia.srbts.tnl:IPIF",
        version="TNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV4-1',
        class_name="com.nokia.srbts.tnl:IPADDRESSV4",
        version="TNL5G19A_1904_200")
]

LIST_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        list_name="targetDNList"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name="acceptedClockClass"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name="topMasterList"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name="ntpServerList"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name="frRefList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name="modDNList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-2",
        list_name="frRefList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-2",
        list_name="modDNList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-3",
        list_name="frRefList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-3",
        list_name="modDNList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-4",
        list_name="frRefList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-4",
        list_name="modDNList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/LTEENB-1",
        list_name="enbPlmn"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="discoveredF1Cplane"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="discoveredF1Mplane"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="discoveredF1Uplane"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="discoveredS1Uplane"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="discoveredX2Cplane"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1",
        list_name="discoveredX2Uplane"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name="beamSet"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-2",
        list_name="beamSet"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-3",
        list_name="beamSet"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-4",
        list_name="beamSet")
]

LIST_ITEM_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='beamSet',
        elements={
            'basicBeamSet': 'beamSetFR2_6_6_4_2P',
            'nrBtsBeamRefinementP2': 'false',
            'leftEdgeAngle': '90',
            'rightEdgeAngle': '90',
            'lowerEdgeAngle': '127',
            'upperEdgeAngle': '87'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='beamSet',
        elements={
            'basicBeamSet': 'beamSetFR2_6_6_4_2P',
            'nrBtsBeamRefinementP2': 'false',
            'leftEdgeAngle': '90',
            'rightEdgeAngle': '90',
            'lowerEdgeAngle': '127',
            'upperEdgeAngle': '87'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='beamSet',
        elements={
            'basicBeamSet': 'beamSetFR2_6_6_4_2P',
            'nrBtsBeamRefinementP2': 'false',
            'leftEdgeAngle': '90',
            'rightEdgeAngle': '90',
            'lowerEdgeAngle': '127',
            'upperEdgeAngle': '87'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='beamSet',
        elements={
            'basicBeamSet': 'beamSetFR2_6_6_4_2P',
            'nrBtsBeamRefinementP2': 'false',
            'leftEdgeAngle': '90',
            'rightEdgeAngle': '90',
            'lowerEdgeAngle': '127',
            'upperEdgeAngle': '87'}),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name='topMasterList',
        elements={
            'phaseErrorComp': '0'}),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name='ntpServerList',
        elements={
            'ntpServerIpAddr': '10.171.8.4'}),

    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements={
            "destIpAddr": "0.0.0.0",
            "destinationIpPrefixLength": "0",
            "gateway": "10.57.250.129",
            "preference": "1"}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements={
              "destIpAddr": "0.0.0.0",
              "destinationIpPrefixLength": "0",
              "gateway": "10.57.250.129",
              "preference": "1"}),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/LTEENB-1",
        list_name='enbPlmn',
        elements={
            'mcc': '262',
            'mnc': '3',
            'mncLength': '2'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='discoveredF1Cplane',
        elements={"ipV4AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-6/IPNO-1/IPIF-2/IPADDRESSV4-1"}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='discoveredF1Mplane',
        elements={"ipV4AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-5/IPNO-1/IPIF-1/IPADDRESSV4-1"}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='discoveredF1Uplane',
        elements={"ipV4AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-7/IPNO-1/IPIF-2/IPADDRESSV4-1"}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='discoveredS1Uplane',
        elements={"ipV4AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-7/IPNO-1/IPIF-1/IPADDRESSV4-1"}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='discoveredX2Cplane',
        elements={"ipV4AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-6/IPNO-1/IPIF-1/IPADDRESSV4-1"}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='discoveredX2Uplane',
        elements={"ipV4AddressDN1": "MRBTS-1900/TNLSVC-1/TNL-7/IPNO-1/IPIF-1/IPADDRESSV4-1"})
    ]

LIST_ELEMENT_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name='acceptedClockClass',
        elements=[
            6,
            7]),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        list_name='targetDNList',
        elements=['MRBTS-1900/EQM-1/APEQM-1/RMOD-1']),
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
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name="frRefList",
        elements=['FR-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name="modDNList",
        elements=['MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-2",
        list_name="frRefList",
        elements=['FR-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-2",
        list_name="modDNList",
        elements=['MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-3",
        list_name="frRefList",
        elements=['FR-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-3",
        list_name="modDNList",
        elements=['MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-4",
        list_name="frRefList",
        elements=['FR-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-4",
        list_name="modDNList",
        elements=['MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1'])
]

# parameters with value to add
PARAMS_TO_ADD = [
    dict(
        value='G.8275.1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        p_name='topStandardProfile'),
    dict(
        value='01-80-C2-00-00-0E',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        p_name='topEthMulticastAddress'),
    dict(
        value=24,
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
        p_name='topDomainNumber'),
    dict(
        value='RU',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        p_name='profileType'),
    dict(
        value='F1-M',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='X2-C',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='F1-C',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='X2-U S1-U',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='F1-U',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='3',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='maxNumScellsDl'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='maxNumScellsUl'),
    dict(
        value='blind',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='sCellActivationMethod'),
    dict(
        value='2461',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-1/VLANIF-1',
        p_name='vlanId'),
    dict(
        value='MRBTS-1900/TNLSVC-1/TNL-4/ETHSVC-1/ETHIF-2',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2',
        p_name='interfaceDN'),
    dict(
        value='1500',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2',
        p_name='ipMtu'),
    dict(
        value='MANUAL',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/CERTHENT-1',
        p_name='sModDN'),
    dict(
        value='325',
        dist_name='MRBTS-1900/NRBTS-1/LTEENB-1',
        p_name='eNodeBId'),
    dict(
        value='10.57.247.62',
        dist_name='MRBTS-1900/NRBTS-1/LTEENB-1',
        p_name='ipAddr'),
    dict(
        value='VNF',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1',
        p_name='tnlType'),
    dict(
        value='VNF',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2',
        p_name='tnlType'),
    dict(
        value='VNF',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3',
        p_name='tnlType'),
    dict(
        value='DU',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4',
        p_name='tnlType'),
    dict(
        value='32756',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='nrCellIdentity'),
    dict(
        value='32757',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='nrCellIdentity'),
    dict(
        value='32758',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='nrCellIdentity'),
    dict(
        value='32759',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='nrCellIdentity')
]
