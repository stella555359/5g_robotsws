import os

__team__ = 'MN 5G RAN I&V 4 Pz HZG SG1'
__email__ = 'I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com'


PARAMS_TO_DELETE_barred = [
    dict(dist_name='MRBTS-1909/NRBTS-1201/NRCELL-1', p_name='configuredEpsTac'),
]

PARAMS_TO_MODIFY_barred = [
    dict(value='barred', dist_name='MRBTS-1909/NRBTS-1201/NRCELL-1', p_name='cellBarred'),
    dict(value='5GC000742_caseB05_TA_cOAM_SA', dist_name='MRBTS-1909', p_name='btsName'),
    dict(value='SA', dist_name='MRBTS-1909/NRBTS-1201', p_name='gNbCuType'),
    dict(value='SA', dist_name='MRBTS-1909/NRBTS-1201/NRCELL-1', p_name='cellDepType'),
    dict(value='0', dist_name='MRBTS-1909/NRBTS-1201', p_name='x2LinkSupervisionTmr')
]

PARAMS_TO_MODIFY_742C = [
    dict(value='5GC000742_caseC023_TA_SA', dist_name='MRBTS-1914', p_name='btsName'),
    dict(value='SA', dist_name='MRBTS-1909/NRBTS-1201', p_name='gNbCuType'),
    dict(value='SA', dist_name='MRBTS-1909/NRBTS-1201/NRCELL-1', p_name='cellDepType'),
    # sib2
    dict(value='dB0', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='addHystSfHigh'),
    dict(value='dB0', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='addHystSfMedium'),
    dict(value='16', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='nCellChangeHigh'),
    dict(value='15', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='nCellChangeMedium'),
    dict(value='c', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='plmnCommonSelAssisInfo'),
    dict(value='dB24', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='qHyst'),
    dict(value='-12', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='qQualMin'),
    dict(value='dB24', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='rangeToBestCell'),
    dict(value='31', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='sNonIntraSearchP'),
    dict(value='31', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='sNonIntraSearchQ'),
    dict(value='1Dot0', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='sfHighEutra'),
    dict(value='1Dot0', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='sfMediumEutra'),
    dict(value='s40', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='siWindowLength'),
    dict(value='679', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='systemInformationTargetRate'),
    dict(value='s30', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='tEvaluation'),
    dict(value='s30', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='tHystNormal'),
    dict(value='0', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='tReselectionEutra'),
    dict(value='0', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='threshServingLowP'),
    dict(value='0', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1', p_name='threshServingLowQ'),
    # sib3
    dict(value='30', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='pMaxIntraFreq'),
    dict(value='-12', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='qQualMin'),
    dict(value='-22', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='qRxLevMin'),
    dict(value='31', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='sIntraSearchP'),
    dict(value='31', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='sIntraSearchQ'),
    dict(value='1Dot0', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='sfHigh'),
    dict(value='oDot75', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='sfMedium'),
    dict(value='7', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIAFIM-1', p_name='tReselectionNr'),
    # sib4
    dict(value='7', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='cellReselectionPriority'),
    dict(value='oDot8', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1',
         p_name='cellReselectionSubPriority'),
    dict(value='false', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1',
         p_name='deriveSsbIndexFromCell'),
    dict(value='6480', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='dlCarrierFreq'),
    dict(value='41', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='freqBandIndicatorNR'),
    dict(value='16', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='numOfSsBlocksToAverage'),
    dict(value='32 beams', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1',
         p_name='numberOfTransmittedSsBlocks'),
    dict(value='30', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='pMaxInterFreq'),
    dict(value='24dB', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='qOffsetFreq'),
    dict(value='-12', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='qQualMin'),
    dict(value='-22', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='qRxLevMin'),
    dict(value='1Dot0', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='sfHigh'),
    dict(value='oDot75', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='sfMedium'),
    dict(value='sf4', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='ssbMtcDuration'),
    dict(value='159', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='ssbMtcOffset'),
    dict(value='sf160', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='ssbMtcPeriodicity'),
    dict(value='30 KHz', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='ssbScs'),
    dict(value='7', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='tReselectionNr'),
    dict(value='31', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='threshXHighP'),
    dict(value='31', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='threshXHighQ'),
    dict(value='31', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='threshXLowP'),
    dict(value='31', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='threshXLowQ'),
    dict(value='127', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='thresholdRsrp'),
    dict(value='127', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', p_name='thresholdRsrq'),
    # sib5
    dict(value='mbw100', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRLIM-1', p_name='allowedMeasBw'),
    dict(value='40890', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRLIM-1', p_name='carrierFreq'),
    dict(value='3', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRLIM-1', p_name='cellReselectionPriority'),
    dict(value='oDot6', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRLIM-1',
         p_name='cellReselectionSubPriority'),
    dict(value='24', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRLIM-1', p_name='pMaxEutra'),
    dict(value='false', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRLIM-1', p_name='presenceAntPort1'),
    dict(value='-34', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRLIM-1', p_name='qQualMin'),
    dict(value='-22', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRLIM-1', p_name='qRxLevMin'),
    dict(value='2', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRLIM-1', p_name='threshXHigh'),
    dict(value='0', dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRLIM-1', p_name='threshXLow')
]
PARAMS_TO_DELETE_742C = [
    dict(dist_name='MRBTS-1909/NRBTS-1201/NRCELL-1', p_name='configuredEpsTac'),
    dict(dist_name='MRBTS-1914/NRBTS-14/NRCELL-1', list_name='uacAcContParSetList'),
    dict(dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIAFIM-1', list_name='intraFreqNCellList'),
    dict(dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIAFIM-1', list_name='pciBlackList'),
    dict(dist_name='MRBTS-1914/NRBTS-14/NRSYSINFO_PROFILE-1/NRIRFIM-1', list_name='interFreqNCellList')
]
LIST_TO_ADD_742C = [
    dict(dist_name='MRBTS-1909/NRBTS-1201/NRCELL-1', list_name='uacAcContParSetList',
         elements=dict(uacBarringFactor='p00', uacBarringForAccessIdentity='1', uacBarringTime='s32')),
    dict(dist_name='MRBTS-1909/NRBTS-1201/NRSYSINFO_PROFILE-1/NRIAFIM-1', list_name='intraFreqNCellList',
         elements=dict(physCellId='51', qOffsetCell='24dB', qQualMinOffsetCell='8', qRxLevMinOffsetCell='8')),
    dict(dist_name='MRBTS-1909/NRBTS-1201/NRSYSINFO_PROFILE-1/NRIAFIM-1', list_name='pciExcludeList',
         elements=dict(physCellId='60', range='n8')),
    dict(dist_name='MRBTS-1909/NRBTS-1201/NRSYSINFO_PROFILE-1/NRIRFIM-1', list_name='interFreqNCellList',
         elements=dict(physCellId='72', qOffsetCell='24dB', qQualMinOffsetCell='8', qRxLevMinOffsetCell='8')),
    dict(dist_name='MRBTS-1909/NRBTS-1201/NRSYSINFO_PROFILE-1/NRIRFIM-1', list_name='pciExcludeList',
         elements=dict(physCellId='100', range='n1008')),
]

PARAMS_TO_MODIFY_SemiStatic_U1_D4 = [
    dict(value='5GC000742_TA_SemiStatic_U1_D4_caseB017', dist_name='MRBTS-1914', p_name='btsName'),
    dict(value='SA', dist_name='MRBTS-1101/NRBTS-1101', p_name='gNbCuType'),
    dict(value='0', dist_name='MRBTS-1101/NRBTS-1101', p_name='x2LinkSupervisionTmr'),
    dict(value='SA', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-201', p_name='cellDepType'),
    dict(value='98', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-201', p_name='prachConfigurationIndex'),
    dict(value='one', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-201', p_name='numPagingOccsnPagingFrame'),
    dict(value='quaterT', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-201', p_name='numOfPagingFrames'),
    dict(value='1', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-201', p_name='pagingOffset'),
    dict(value='SA', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-202', p_name='cellDepType'),
    dict(value='98', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-202', p_name='prachConfigurationIndex'),
    dict(value='one', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-202', p_name='numPagingOccsnPagingFrame'),
    dict(value='quaterT', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-202', p_name='numOfPagingFrames'),
    dict(value='1', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-202', p_name='pagingOffset'),
    dict(value='SA', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-203', p_name='cellDepType'),
    dict(value='98', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-203', p_name='prachConfigurationIndex'),
    dict(value='one', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-203', p_name='numPagingOccsnPagingFrame'),
    dict(value='quaterT', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-203', p_name='numOfPagingFrames'),
    dict(value='1', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-203', p_name='pagingOffset'),
    dict(value='SA', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-204', p_name='cellDepType'),
    dict(value='98', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-204', p_name='prachConfigurationIndex'),
    dict(value='one', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-204', p_name='numPagingOccsnPagingFrame'),
    dict(value='quaterT', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-204', p_name='numOfPagingFrames'),
    dict(value='1', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-204', p_name='pagingOffset'),
    dict(value='SA', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-205', p_name='cellDepType'),
    dict(value='98', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-205', p_name='prachConfigurationIndex'),
    dict(value='one', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-205', p_name='numPagingOccsnPagingFrame'),
    dict(value='quaterT', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-205', p_name='numOfPagingFrames'),
    dict(value='1', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-205', p_name='pagingOffset'),
    dict(value='SA', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-206', p_name='cellDepType'),
    dict(value='98', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-206', p_name='prachConfigurationIndex'),
    dict(value='one', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-206', p_name='numPagingOccsnPagingFrame'),
    dict(value='quaterT', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-206', p_name='numOfPagingFrames'),
    dict(value='1', dist_name='MRBTS-1101/NRBTS-1101/NRCELL-206', p_name='pagingOffset'),

]

MO_DELETE_SemiStatic_U1_D4 = [
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-201', list_name='fPdcchMonOccsnPo'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-201', list_name='tddFrameStructure'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-201', p_name='configuredEpsTac'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-202', list_name='fPdcchMonOccsnPo'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-202', list_name='tddFrameStructure'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-202', p_name='configuredEpsTac'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-203', list_name='fPdcchMonOccsnPo'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-203', list_name='tddFrameStructure'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-203', p_name='configuredEpsTac'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-204', list_name='fPdcchMonOccsnPo'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-204', list_name='tddFrameStructure'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-204', p_name='configuredEpsTac'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-205', list_name='fPdcchMonOccsnPo'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-205', list_name='tddFrameStructure'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-205', p_name='configuredEpsTac'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-206', list_name='fPdcchMonOccsnPo'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-206', list_name='tddFrameStructure'),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-206', p_name='configuredEpsTac'),
]
MO_ADD_SemiStatic_U1_D4 = [
]
LIST_ADD_SemiStatic_U1_D4 = [
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-201', list_name='fPdcchMonOccsnPo', elements=['0']),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-201', list_name='tddFrameStructure',
         elements=dict(frameStructureType='semiStatic', guardPeriodLength='2Symbols',
                       tdLteUlDlConfig='tdLteConfig2', ulDlDataSlotRatio='1/4')),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-202', list_name='fPdcchMonOccsnPo', elements=['0']),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-202', list_name='tddFrameStructure',
         elements=dict(frameStructureType='semiStatic', guardPeriodLength='2Symbols',
                       tdLteUlDlConfig='tdLteConfig2', ulDlDataSlotRatio='1/4')),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-203', list_name='fPdcchMonOccsnPo', elements=['0']),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-203', list_name='tddFrameStructure',
         elements=dict(frameStructureType='semiStatic', guardPeriodLength='2Symbols',
                       tdLteUlDlConfig='tdLteConfig2', ulDlDataSlotRatio='1/4')),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-204', list_name='fPdcchMonOccsnPo', elements=['0']),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-204', list_name='tddFrameStructure',
         elements=dict(frameStructureType='semiStatic', guardPeriodLength='2Symbols',
                       tdLteUlDlConfig='tdLteConfig2', ulDlDataSlotRatio='1/4')),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-205', list_name='fPdcchMonOccsnPo', elements=['0']),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-205', list_name='tddFrameStructure',
         elements=dict(frameStructureType='semiStatic', guardPeriodLength='2Symbols',
                       tdLteUlDlConfig='tdLteConfig2', ulDlDataSlotRatio='1/4')),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-206', list_name='fPdcchMonOccsnPo', elements=['0']),
    dict(dist_name='MRBTS-1101/NRBTS-1101/NRCELL-206', list_name='tddFrameStructure',
         elements=dict(frameStructureType='semiStatic', guardPeriodLength='2Symbols',
                       tdLteUlDlConfig='tdLteConfig2', ulDlDataSlotRatio='1/4')),
]
LIST_PARAMETER_MODIFY_SemiStatic_U1_D4 = [

]

PARAMS_TO_MODIFY_band = [
    dict(value='77', dist_name='MRBTS-1102/NRBTS-1102/NRCELL-1', p_name='freqBandIndicatorNR')
]

PARAMS_TO_MODIFY_742_H56 = [
    dict(value='5GC000742_caseH56_TA', dist_name='MRBTS-1107', p_name='btsName'),
    dict(value='80MHz', dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='chBw'),
    dict(value='SA', dist_name='MRBTS-1107/NRBTS-1107', p_name='gNbCuType'),
    dict(value='SA', dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='cellDepType'),
]

MOs_TO_Add_742_H56 = [
 # Adapt to keyword of gNB.ModifySCF
]

PARAMS_TO_DELETE_742_H56 = [
    dict(dist_name='MRBTS-1107/NRBTS-1107/NRCELL-1', p_name='configuredEpsTac'),
]

LIST_PARAMS_TO_MODIFY_742_H56 = [
 # Adapt to keyword of gNB.ModifySCF
]

LIST_TO_ADD_742_H56 = [
 # Adapt to keyword of gNB.ModifySCF
]
