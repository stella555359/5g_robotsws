from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'liujia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_bts_id = str(tl.gnbs[0].global_bts_id)
_MRBTS1_name = 'MRBTS-' + _global_bts_id
_NRBTS1_name = _MRBTS1_name + '/NRBTS-' + _gnb_id
_NRCELL1_name = _NRBTS1_name + '/NRCELL-1'
_NRCELL2_name = _NRBTS1_name + '/NRCELL-2'
_NRCELL3_name = _NRBTS1_name + '/NRCELL-3'
_NRCELL3_NRREL1 = _NRCELL3_name + '/NRREL-256'
_NRCELL3_NRREL2 = _NRCELL3_name + '/NRREL-255'
_NRCELL1_NRREL1 = _NRCELL1_name + '/NRREL-255'
_NRCELL1_NRREL2 = _NRCELL1_name + '/NRREL-256'
_NRCELL2_NRREL1 = _NRCELL2_name + '/NRREL-256'
_NRCELL2_NRREL2 = _NRCELL2_name + '/NRREL-255'
_SERVEDAMF_1 = _NRBTS1_name + '/SERVEDAMF-1'
_bwpDN5 = _NRBTS1_name + '/BWP_PROFILE-5'
_bwpDN53 = _NRBTS1_name + '/BWP_PROFILE-53'
_bwpDN52 = _NRBTS1_name + '/BWP_PROFILE-52'
_bwpDN57 = _NRBTS1_name + '/BWP_PROFILE-57'
_NRPMRNL_1 = _NRBTS1_name + '/NRPMRNL-1'
_NRCELL3Group = _MRBTS1_name + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3'
_NRCELL37401_name = _NRBTS1_name + '/NRCELL-37401'
_NRCELL37402_name = _NRBTS1_name + '/NRCELL-37402'
_NRCELL37403_name = _NRBTS1_name + '/NRCELL-37403'
_NRCELL37401_NRREL255 = _NRCELL37401_name + '/NRREL-255'
_NRCELL37401_NRREL256 = _NRCELL37401_name + '/NRREL-256'
_NRCELL36501_name = _NRBTS1_name + '/NRCELL-36501'
_NRCELL36502_name = _NRBTS1_name + '/NRCELL-36502'

PATH_TO_SCF = ''

# ----------------------swconfig----------------- #
CB009936_flag = [
    '0x450027 = 1',
    '0x42009d = 31',
]

CB009936_recovery = [
    '0x450027 = 1',
]
# ----------------------counter----------------- #
CB009936_B32_counter_path = [
    'BTS/{}/NRCELL-37401/NRACH'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37401/NRRCC'.format(_NRBTS1_name),
]

CB009936_B32_counter_id = [
    'M55306C09013', 'M55124C01001',
]
# ------------------------------enable 72e-----------------------------------#
Enable_72e_on_WEBEM = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actEcpri72e'),
]

# -------------------------CB009936_CB008158-B_12--------------------------- #
Online_Modify_8158_B12_11006 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actFdmSchedulingInitialBWP'),
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='minRbReservedForNonSiPaging'),
    dict(
        value='dciRaMsg2AggregationLevel',
        dist_name=_NRCELL1_name,
        parameter='raMsg2TargetRate'),
]

Online_Modify_8830_A1001_11006 = [
    dict(
        value='Type2',
        dist_name=_NRCELL37401_name,
        parameter='dlDmrsType'),
    dict(value=[dict(actDlDataDmrsFdm='true')],
         dist_name=_NRCELL37401_name, parameter='dlDataDmrsFdm'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actPdschAtSsbSlots'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actDl256Qam'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actPdschRmCsirsForTracking'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actEnhancedPDSCHSchSplSlot'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actDlMuMimoEnh'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actVoNR'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actEnhancedVoNR'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actPriorityAccess'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actEmergencyCall'),
    dict(
        value='dlSrbPowerBoost',
        dist_name=_NRCELL37401_name,
        parameter='actDlPowerBoost'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actLAForHiReliab'),
]

Online_Modify_8830_A1001_type1_11006 = [
    dict(
        value='Type1',
        dist_name=_NRCELL37401_name,
        parameter='dlDmrsType'),
]

Online_Modify_8830_A2011_11006 = [
    dict(
        value='Type1',
        dist_name=_NRCELL37401_name,
        parameter='dlDmrsType'),
    dict(value=[dict(dlDataDmrsFdmThres256QamMcs='1', dlDataDmrsFdmThres64QamMcs='1')],
         dist_name=_NRCELL37401_name, parameter='dlDataDmrsFdm')
]

Online_Modify_8830_A2011_type2_11006 = [
    dict(
        value='Type2',
        dist_name=_NRCELL37401_name,
        parameter='dlDmrsType'),
]

Online_Modify_8830_A2011_type2_mcs_11006 = [
    dict(value=[dict(dlDataDmrsFdmThres256QamMcs='27', dlDataDmrsFdmThres64QamMcs='27')],
         dist_name=_NRCELL37401_name, parameter='dlDataDmrsFdm')
]

Online_Recovery_8830_A1001_11006 = [
    dict(
        value='Type2',
        dist_name=_NRCELL37401_name,
        parameter='dlDmrsType'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actDlMuMimoEnh'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actVoNR'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actEnhancedVoNR'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actPriorityAccess'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actEmergencyCall'),
    dict(
        value='dlVoNRAndSrbPowerBoost',
        dist_name=_NRCELL37401_name,
        parameter='actDlPowerBoost'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actLAForHiReliab'),
]

Online_Modify_8158_B12_10175 = [
    dict(
        value='1',
        dist_name=_NRCELL1_name,
        parameter='minRbReservedForNonSiPaging'),
    dict(
        value='dciRaMsg2AggregationLevel',
        dist_name=_NRCELL1_name,
        parameter='raMsg2TargetRate'),
    dict(
        value='1',
        dist_name=_NRCELL2_name,
        parameter='minRbReservedForNonSiPaging'),
    dict(
        value='dciRaMsg2AggregationLevel',
        dist_name=_NRCELL2_name,
        parameter='raMsg2TargetRate'),
]

Online_Modify_8830_A1001_10175 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPdschRmCsirsForTracking'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEnhancedPDSCHSchSplSlot'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actEnhancedPDSCHSchSplSlot'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actDlMuMimoEnh'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actDlMuMimoEnh'),
    # dict(
    #     value='false',
    #     dist_name=_NRCELL1_name,
    #     parameter='actVoNR'),
    # dict(
    #     value='false',
    #     dist_name=_NRCELL1_name,
    #     parameter='actEnhancedVoNR'),
    # dict(
    #     value='false',
    #     dist_name=_NRCELL1_name,
    #     parameter='actPriorityAccess'),
    # dict(
    #     value='false',
    #     dist_name=_NRCELL1_name,
    #     parameter='actEmergencyCall'),
    # dict(
    #     value='dlSrbPowerBoost',
    #     dist_name=_NRCELL1_name,
    #     parameter='actDlPowerBoost'),
    # dict(
    #     value='off',
    #     dist_name=_NRCELL1_name,
    #     parameter='actGBRAdmissionControl'),
    # dict(
    #     value='false',
    #     dist_name=_NRCELL1_name,
    #     parameter='actLAForHiReliab'),
    # dict(
    #     value='31',
    #     dist_name=_NRCELL1_name,
    #     parameter='pMax'),
    dict(value=[dict(guardPeriodLength='4Symbols')],
         dist_name=_NRCELL1_name, parameter='tddFrameStructure'),
    dict(value=[dict(guardPeriodLength='4Symbols')],
         dist_name=_NRCELL2_name, parameter='tddFrameStructure'),
    # dict(value=[dict(bwpDN=_NRBTS1_name + '/BWP_PROFILE-1', cellBwpId='0'),
    #             dict(bwpDN=_NRBTS1_name + '/BWP_PROFILE-11',
    #                  actUpperThrAckNackHrFiltering='false', cellBwpId='1'),
    #             dict(bwpDN=_NRBTS1_name + '/BWP_PROFILE-111',
    #                  actUpperThrAckNackHrFiltering='false', cellBwpId='2'),
    #             dict(bwpDN=_NRBTS1_name + '/BWP_PROFILE-1111',
    #                  actUpperThrAckNackHrFiltering='false', cellBwpId='3')],
    #      dist_name=_NRCELL1_name, parameter='cellBwpList'),
]

Online_Modify_8830_A1001_type1_10175 = [
    dict(
        value='Type1',
        dist_name=_NRCELL1_name,
        parameter='dlDmrsType'),
]

Online_Modify_8830_A2011_10175 = [
    dict(
        value='Type1',
        dist_name=_NRCELL1_name,
        parameter='dlDmrsType'),
    dict(value=[dict(dlDataDmrsFdmThres256QamMcs='1', dlDataDmrsFdmThres64QamMcs='1')],
         dist_name=_NRCELL1_name, parameter='dlDataDmrsFdm'),
    dict(
        value='-55',
        dist_name=_NRCELL1_name,
        parameter='qRxLevMin'),
]

Online_Modify_8830_A2011_type2_10175 = [
    dict(
        value='Type2',
        dist_name=_NRCELL1_name,
        parameter='dlDmrsType'),
    dict(
        value='Type2',
        dist_name=_NRCELL2_name,
        parameter='dlDmrsType'),
]

Online_Modify_8830_A2011_type2_mcs_10175 = [
    dict(value=[dict(dlDataDmrsFdmThres256QamMcs='27', dlDataDmrsFdmThres64QamMcs='27')],
         dist_name=_NRCELL1_name, parameter='dlDataDmrsFdm'),
    dict(value=[dict(dlDataDmrsFdmThres256QamMcs='27', dlDataDmrsFdmThres64QamMcs='27')],
         dist_name=_NRCELL2_name, parameter='dlDataDmrsFdm'),
]

Online_Recovery_8830_A1001_10175 = [
    dict(
        value='6',
        dist_name=_NRCELL1_name,
        parameter='minRbReservedForNonSiPaging'),
    dict(
        value='MCS0_SF0',
        dist_name=_NRCELL1_name,
        parameter='raMsg2TargetRate'),
    dict(
        value='6',
        dist_name=_NRCELL2_name,
        parameter='minRbReservedForNonSiPaging'),
    dict(
        value='MCS0_SF0',
        dist_name=_NRCELL2_name,
        parameter='raMsg2TargetRate'),
    dict(value=[dict(dlDataDmrsFdmThres256QamMcs='5', dlDataDmrsFdmThres64QamMcs='5')],
         dist_name=_NRCELL1_name, parameter='dlDataDmrsFdm'),
    dict(
        value='Type2',
        dist_name=_NRCELL1_name,
        parameter='dlDmrsType'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actPdschRmCsirsForTracking'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actEnhancedPDSCHSchSplSlot'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actEnhancedPDSCHSchSplSlot'),
    # dict(
    #     value='true',
    #     dist_name=_NRCELL1_name,
    #     parameter='actVoNR'),
    # dict(
    #     value='true',
    #     dist_name=_NRCELL1_name,
    #     parameter='actEnhancedVoNR'),
    # dict(
    #     value='dlVoNRAndSrbPowerBoost',
    #     dist_name=_NRCELL1_name,
    #     parameter='actDlPowerBoost'),
    # dict(
    #     value='true',
    #     dist_name=_NRCELL1_name,
    #     parameter='actPriorityAccess'),
    # dict(
    #     value='true',
    #     dist_name=_NRCELL1_name,
    #     parameter='actEmergencyCall'),
    # dict(
    #     value='EnhancedVoNR',
    #     dist_name=_NRCELL1_name,
    #     parameter='actGBRAdmissionControl'),
    # dict(
    #     value='true',
    #     dist_name=_NRCELL1_name,
    #     parameter='actLAForHiReliab'),
    dict(
        value='-40',
        dist_name=_NRCELL1_name,
        parameter='qRxLevMin'),
    # dict(
    #     value='30',
    #     dist_name=_NRCELL1_name,
    #     parameter='pMax'),
    dict(value=[dict(guardPeriodLength='6Symbols')],
         dist_name=_NRCELL1_name, parameter='tddFrameStructure'),
    dict(value=[dict(guardPeriodLength='6Symbols')],
         dist_name=_NRCELL2_name, parameter='tddFrameStructure'),
    # dict(value=[dict(bwpDN=_NRBTS1_name + '/BWP_PROFILE-1008', cellBwpId='0'),
    #             dict(bwpDN=_NRBTS1_name + '/BWP_PROFILE-87',
    #                  actUpperThrAckNackHrFiltering='true', cellBwpId='1'),
    #             dict(bwpDN=_NRBTS1_name + '/BWP_PROFILE-10080',
    #                  actUpperThrAckNackHrFiltering='true', cellBwpId='2'),
    #             dict(bwpDN=_NRBTS1_name + '/BWP_PROFILE-20080',
    #                  actUpperThrAckNackHrFiltering='true', cellBwpId='3')],
    #      dist_name=_NRCELL1_name, parameter='cellBwpList'),
]

# -------------------------CB009936_CB009550-B_32--------------------------- #
Online_Modify_B32_true = [
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actFdmSchedulingInitialBWP'),
    dict(
        value='1',
        dist_name=_NRCELL37401_name,
        parameter='minRbReservedForNonSiPaging'),
    dict(
        value='dciRaMsg2AggregationLevel',
        dist_name=_NRCELL37401_name,
        parameter='raMsg2TargetRate'),
]

Online_Modify_B32_false = [
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actFdmSchedulingInitialBWP'),

]

# -------------------------CB009936_CB008830_SR_C1_001--------------------------- #
Online_Modify_8830_C1001_type2 = [
    dict(
        value='Type2',
        dist_name=_NRCELL37401_name,
        parameter='dlDmrsType'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actVoNR'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actForcedDftSOfdmVonrUl'),
]
# -------------------------8322--------------------------- #
PARAMETERS_TO_MODIFY_GNB1_8322 = [
    dict(value='notBarred', dist_name=_NRCELL3_name, p_name='cellBarred'),
    dict(value='true', dist_name=_NRCELL3_name, p_name='actEcpri72e'),
    dict(value='16Rx', dist_name=_NRCELL3_name, p_name='numberOfRxBeamforming'),
    dict(value='8Rx', dist_name=_NRCELL3_name, p_name='numberOfRxPucch'),
    dict(value='true', dist_name=_NRCELL3Group, p_name='actSimplChConfMAA'),
    dict(value='194', dist_name=_NRCELL3_name, p_name='prachConfigurationIndex'),
    dict(value='8DL2UL', dist_name=_NRCELL3_name, p_name='nrCellType'),
    dict(value='false', dist_name=_NRCELL3_name, p_name='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL3_name, p_name='actUlMuMimo'),
    dict(value='2', dist_name=_NRCELL3_name, p_name='tmpParam4'),
]

LIST_TO_ADD_GNB1_8322 = [
    dict(
        dist_name=_NRCELL3_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='4Symbols',
            lteToNrFrameShift='0ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=_NRCELL3_name,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-10',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL3_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-76',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL3_name,
        list_name='fPdcchMonOccsnPo',
        elements=['2']
    ),
]

LIST_TO_modify_GNB1_8322 = [
    dict(dist_name=_NRCELL3_name, list_name='srsForBeamMgmt',
         elements=[dict(p_name='comb', value='comb4', index=0),
                   dict(p_name='bSRS', value='1', index=0)]),
    dict(dist_name=_NRCELL3_name, list_name='ulPtrs',
         elements=[dict(p_name='actUlPtrs', value='false', index=0)]),
    dict(dist_name=_NRCELL3_name, list_name='pdcchAutoConfig',
         elements=[dict(p_name='pucchSize', value='28', index=0)]),
    dict(dist_name=_NRCELL3_name, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalPucch', value='-90', index=0),
                   dict(p_name='p0NominalPucchF1F3', value='-100', index=0),
                   dict(p_name='p0NominalPusch', value='-90', index=0),
                   dict(p_name='p0NominalSrs', value='-80', index=0)])
]

PARAMS_TO_delete_GNB1_8322 = [
    dict(dist_name=_NRCELL3_name, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL3_name, list_name='cellBwpList'),
    dict(dist_name=_NRCELL3_name, list_name='fPdcchMonOccsnPo'),
    dict(dist_name=_NRCELL3Group + '/CHANNELGROUP-2'),
    dict(dist_name=_NRCELL3Group + '/CHANNELGROUP-3'),
    dict(dist_name=_NRCELL3Group + '/CHANNELGROUP-4'),
    dict(dist_name=_NRCELL3Group + '/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=_NRCELL3Group + '/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=_NRCELL3Group + '/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=_NRCELL3Group + '/CHANNELGROUP-1/CHANNEL-5'),
    dict(dist_name=_NRCELL3Group + '/CHANNELGROUP-1/CHANNEL-6'),
    dict(dist_name=_NRCELL3Group + '/CHANNELGROUP-1/CHANNEL-7'),
    dict(dist_name=_NRCELL3Group + '/CHANNELGROUP-1/CHANNEL-8'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_8322_20M = [
    dict(value=[dict(bwpDN=_NRBTS1_name + '/BWP_PROFILE-9', cellBwpId='0'),
                dict(bwpDN=_NRBTS1_name + '/BWP_PROFILE-75', cellBwpId='1')],
         dist_name=_NRCELL3_name, parameter='cellBwpList'),
    dict(value=[dict(cSRS='13')],
         dist_name=_NRCELL3_name, parameter='srsForBeamMgmt'),
    dict(value='5', dist_name=_NRCELL3_name, parameter='msg1FrequencyStart'),
    dict(value='20MHz', dist_name=_NRCELL3_name, parameter='chBw'),
]

# -------------------------9169--------------------------- #
PARAMS_TO_delete_9169 = [
    dict(dist_name=_NRCELL37401_name, list_name='cellBwpList'),
]

LIST_TO_ADD_9169 = [
    dict(
        dist_name=_NRCELL37401_name,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-1008',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL37401_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-87',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL37401_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-10087',
            cellBwpId='2',
            pdcchResourcePreference='peakRate')),
]

PARAMETERS_TO_MODIFY_9169 = [
    dict(value='100MHz', dist_name=_NRCELL37401_name, p_name='chBw'),
]

PARAMETERS_TO_ONLINE_ADD_9169 = [
    dict(value='blind', dist_name=_NRCELL37401_NRREL256, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRCELL37401_NRREL256, parameter='sCellOperationalMode'),
    dict(value='ulCaPreferred', dist_name=_NRBTS1_name + '/NRDU-9999', parameter='fr1UlCaPreferred'),
]

PARAMETERS_TO_ONLINE_MODIFY_9169 = [
    dict(value='true', dist_name=_NRCELL37401_name, parameter='increasePUSCHPrepTimeULCA'),
    dict(value='true', dist_name=_NRCELL37401_name, parameter='actEcpri72e'),
    dict(value='false', dist_name=_NRCELL37401_name, parameter='actDlSrsBm'),
    dict(value='false', dist_name=_NRCELL37401_name, parameter='actUlSrsBm'),
    dict(value='false', dist_name=_NRCELL37401_name, parameter='actCsirsBeamPowerBalance'),
    dict(value='false', dist_name=_NRCELL37401_name, parameter='actDlRankProbing'),
    dict(value='false', dist_name=_NRCELL37401_name, parameter='actPdschBeamPowerBalance'),
    dict(value='false', dist_name=_NRCELL37401_name, parameter='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELL37401_name, parameter='actAdaptiveReTxResMcsEnh'),
    dict(value='true', dist_name=_NRCELL37401_name, parameter='actDynUlResAlloc'),

    dict(value='barred', dist_name=_NRCELL37402_name, parameter='cellBarred'),
    dict(value='50', dist_name=_NRBTS1_name + '/NRDU-9999', parameter='dlToUlContributionRatio'),
    dict(value=[dict(p0NominalPusch='-82', p0NominalSrs='-80')],
         dist_name=_NRCELL37401_name, parameter='ulPowerControlCommon'),
    dict(value=[dict(p0NominalPusch='-82', p0NominalSrs='-80')],
         dist_name=_NRCELL37402_name, parameter='ulPowerControlCommon'),
    dict(value='false', dist_name=_NRCELL37402_name, parameter='actHighSpeedCell'),
    dict(value='One additional DMRS', dist_name=_NRCELL37402_name, parameter='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL37402_name, parameter='ulDMRSAdditionalPosition'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL37402_name, parameter='prachSequenceType'),
]

PARAMETERS_TO_ONLINE_MODIFY_9169_enable_SRS = [
    dict(value='true', dist_name=_NRCELL37401_name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL37401_name, parameter='actUlSrsBm'),
]

# -------------------------12261--------------------------- #
PARAMS_TO_delete_GNB1_12261 = [
    dict(dist_name=_NRCELL37401_name, list_name='cellBwpList'),
    # dict(dist_name=_NRCELL1_name, list_name='srsForBeamMgmt'),
]

PARAMETERS_TO_MODIFY_GNB1_12261 = [
    dict(value='notBarred', dist_name=_NRCELL37401_name, p_name='cellBarred'),
    dict(value='barred', dist_name=_NRCELL37402_name, p_name='cellBarred'),
    dict(value='barred', dist_name=_NRCELL37403_name, p_name='cellBarred'),
    dict(value='barred', dist_name=_NRCELL1_name, p_name='cellBarred'),
    dict(value='true', dist_name=_NRCELL37401_name, p_name='actEcpri72e'),
    dict(value='60MHz', dist_name=_NRCELL37401_name, p_name='chBw'),
    dict(value='enabled_Level1', dist_name=_NRCELL37401_name, p_name='actPrachMultiplexingLevel'),
    dict(value='disabled', dist_name=_NRCELL37402_name, p_name='actPrachMultiplexingLevel'),
    dict(value='disabled', dist_name=_NRCELL37403_name, p_name='actPrachMultiplexingLevel'),
    dict(value='false', dist_name=_NRCELL37401_name, p_name='actHighSpeedCell'),
    dict(value='One additional DMRS', dist_name=_NRCELL37401_name, p_name='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL37401_name, p_name='ulDMRSAdditionalPosition'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL37401_name, p_name='prachSequenceType'),
    dict(value='191', dist_name=_NRCELL37401_name, p_name='prachConfigurationIndex'),
    dict(value='false', dist_name=_NRCELL37401_name, p_name='actPowerSavingBWP'),
    dict(value='false', dist_name=_NRCELL37401_name, p_name='actInitialBWPFlexibility'),

]

LIST_TO_ADD_GNB1_12261 = [
    dict(
        dist_name=_NRCELL37401_name,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-1009',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL37401_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-86',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')
    ),
]

LIST_TO_modify_GNB1_12261 = [
    dict(dist_name=_NRCELL37401_name, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalPucch', value='-90', index=0),
                   dict(p_name='p0NominalPucchF1F3', value='-90', index=0),
                   dict(p_name='p0NominalPusch', value='-80', index=0),
                   dict(p_name='p0NominalSrs', value='-80', index=0)]),
    dict(dist_name=_NRCELL37401_name, list_name='srsForBeamMgmt',
         elements=[dict(p_name='cSRS', value='42', index=0)]),
]

# -------------------------9915--------------------------- #
PARAMETERS_TO_ONLINE_MODIFY_GNB1_9915 = [
    dict(value='2 beams', dist_name=_NRBTS1_name + '/NRCELLGRP-3071', p_name='numberOfTransmittedSsBlocks'),
    dict(value='disabled', dist_name=_NRBTS1_name, p_name='actFlexibleBISlotDurationMode'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actTddCsiRsOpt'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actTddCsiImRm'),
    dict(value='false', dist_name=_NRCELL36501_name, p_name='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL36501_name, p_name='actSubTRSRateMatch'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actSubTRSRateMatch'),
    dict(value='false', dist_name=_NRCELL36501_name, p_name='actIncUlPdcchCapacity'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actIncUlPdcchCapacity'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actPRBBlanking'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actPRBBlanking'),
    dict(value='notBarred', dist_name=_NRCELL36501_name, p_name='cellBarred'),
    dict(value='barred', dist_name=_NRCELL36502_name, p_name='cellBarred'),
    dict(value='true', dist_name=_NRCELL36502_name, p_name='actCceSplit'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actCceSplit'),
    dict(value='true', dist_name=_NRCELL36502_name, p_name='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actRat1Alloc'),
    dict(value='3', dist_name=_NRCELL36501_name, p_name='nbrOfBlankedPRBsHighEdgeDL'),
    dict(value='3', dist_name=_NRCELL36501_name, p_name='nbrOfBlankedPRBsHighEdgeUL'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actDynUlResAlloc'),
    dict(value='true', dist_name=_NRCELL36502_name, p_name='actDynUlResAlloc'),
    dict(value='511200', dist_name=_NRCELL36502_name, p_name='nrarfcn'),
    dict(value='6390', dist_name=_NRCELL36502_name, p_name='gscnOrSsPbchArfcn'),

    dict(value='10MHz', dist_name=_NRCELL36502_name, p_name='chBw'),
    dict(value='7', dist_name=_NRCELL36502_name, p_name='type0CoresetConfigurationIndex'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actPdcchSharingWithPdsch'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actUlCgType2'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actPowerSavingBWP'),
    dict(value='disabled', dist_name=_NRCELL36502_name, p_name='actNrRim'),
    dict(value='disabled', dist_name=_NRCELL36502_name, p_name='actBadUplinkRadioRedirect'),
    dict(value='4', dist_name=_NRCELL36502_name, p_name='type0SearchSpaceConfigurationIndex'),
    dict(value='disabled', dist_name=_NRCELL36502_name, p_name='actDynPdcchTdMode'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actInitialBWPFlexibility'),
    dict(value='5', dist_name=_NRCELL36502_name, p_name='msg1FrequencyStart'),
    dict(value='5000', dist_name=_NRCELL36502_name, p_name='nUeCtxForCceSplitDeactivation'),
    dict(value='pos3', dist_name=_NRCELL36501_name, p_name='dmrsTypeAPosition'),
    dict(value='pos3', dist_name=_NRCELL36502_name, p_name='dmrsTypeAPosition'),
    dict(value='14', dist_name=_NRCELL36502_name, p_name='reqMinNumPuschPrb'),
    dict(value='1', dist_name=_NRCELL36501_name, p_name='pagingOffset'),
    dict(value='0', dist_name=_NRCELL36502_name, p_name='pagingOffset'),
    dict(value='4', dist_name=_NRCELL36502_name, p_name='maxNumOfCaUsersNRCell'),

    dict(value='false', dist_name=_NRCELL36501_name, p_name='actHighSpeedCell'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actHighSpeedCell'),
    dict(value='One additional DMRS', dist_name=_NRCELL36501_name, p_name='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL36502_name, p_name='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL36501_name, p_name='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL36502_name, p_name='ulDMRSAdditionalPosition'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL36501_name, p_name='prachSequenceType'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL36502_name, p_name='prachSequenceType'),

    # dict(value='6', dist_name=_NRCELL36502_name, p_name='maxNumPagingRecords'),

]

# PARAMETERS_TO_ONLINE_ADD_9915 = [
#     dict(value='3', dist_name=_NRCELL1_name, parameter='nbrOfBlankedPRBsHighEdgeDL'),
#     dict(value='3', dist_name=_NRCELL1_name, parameter='nbrOfBlankedPRBsHighEdgeUL'),
# ]

LIST_TO_modify_9915 = [
    dict(dist_name=_NRCELL36502_name, list_name='fPdcchMonOccsnPo',
         elements=[dict(p_name='', value='1', index=0)]),
    dict(dist_name=_NRCELL36501_name, list_name='fPdcchMonOccsnPo',
         elements=[dict(p_name='', value='3', index=0)]),
]

PARAMS_TO_delete_9915 = [
    dict(dist_name=_NRCELL36502_name, list_name='pdcchAutoConfig'),
    dict(dist_name=_NRCELL36502_name, list_name='cellBwpList'),
    # dict(dist_name=_NRCELL36501_name, list_name='cellBwpList'),
    dict(dist_name=_NRCELL36502_name, list_name='beamSet'),
    dict(dist_name=_NRCELL36502_name, list_name='srsForBeamMgmt'),
]

PARAMS_TO_add_9915 = [
    # dict(
    #     dist_name=_NRCELL36501_name,
    #     list_name='cellBwpList',
    #     elements=dict(
    #         actUpperThrAckNackFiltering='false',
    #         actUpperThrAckNackHrFiltering='false',
    #         actPdcchCceFragmentControl='false',
    #         bwpDN=_NRBTS1_name + '/BWP_PROFILE-9001',
    #         cellBwpId='0',
    #         pdcchResourcePreference='peakRate')
    # ),
    # dict(
    #     dist_name=_NRCELL36501_name,
    #     list_name='cellBwpList',
    #     elements=dict(
    #         actPdcchCceFragmentControl='false',
    #         actUpperThrAckNackFiltering='true',
    #         actUpperThrAckNackHrFiltering='true',
    #         bwpDN=_NRBTS1_name + '/BWP_PROFILE-9002',
    #         cellBwpId='1',
    #         pdcchResourcePreference='peakRate')),
    # dict(
    #     dist_name=_NRCELL36501_name,
    #     list_name='cellBwpList',
    #     elements=dict(
    #         actPdcchCceFragmentControl='false',
    #         actUpperThrAckNackFiltering='true',
    #         actUpperThrAckNackHrFiltering='true',
    #         bwpDN=_NRBTS1_name + '/BWP_PROFILE-9003',
    #         cellBwpId='2',
    #         pdcchResourcePreference='peakRate')),
    # dict(
    #     dist_name=_NRCELL36501_name,
    #     list_name='cellBwpList',
    #     elements=dict(
    #         actPdcchCceFragmentControl='false',
    #         actUpperThrAckNackFiltering='true',
    #         actUpperThrAckNackHrFiltering='true',
    #         bwpDN=_NRBTS1_name + '/BWP_PROFILE-9004',
    #         cellBwpId='3',
    #         pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='pdcchAutoConfig',
        elements=dict(
            fineTuneMode='disabled',
            initialBWPMode='sameAsCoreset0')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-9',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-87',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='srsForBeamMgmt',
        elements=dict(
            bSRS='1',
            comb='comb4',
            cSRS='7',
            srsPowerThresholdForDlBm='-1080',
            srsPowerThresholdForUlBm='-1320',)
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='beamSet',
        elements=dict(
            basicBeamSet='beamSet_2',
            lowerEdgeAngle='120',
            nrBtsBeamRefinementP2='false',
            tiltOffset='0',
            upperEdgeAngle='60',)
    ),
]

PARAMETERS_TO_MODIFY_GNB1_1208 = [
    dict(value='192', dist_name=_NRCELL36501_name, p_name='prachConfigurationIndex'),
    dict(value='192', dist_name=_NRCELL36502_name, p_name='prachConfigurationIndex'),
    dict(value='2.5ms', dist_name=_NRCELL36501_name + '/NRRIM_PROFILE-1', p_name='rsPattern1Period'),

    dict(value='2 beams', dist_name=_NRBTS1_name + '/NRCELLGRP-3071', p_name='numberOfTransmittedSsBlocks'),
    dict(value='disabled', dist_name=_NRBTS1_name, p_name='actFlexibleBISlotDurationMode'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actTddCsiRsOpt'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actTddCsiImRm'),
    dict(value='false', dist_name=_NRCELL36501_name, p_name='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL36501_name, p_name='actSubTRSRateMatch'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actSubTRSRateMatch'),
    dict(value='false', dist_name=_NRCELL36501_name, p_name='actIncUlPdcchCapacity'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actIncUlPdcchCapacity'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actPRBBlanking'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actPRBBlanking'),
    dict(value='barred', dist_name=_NRCELL36501_name, p_name='cellBarred'),
    dict(value='notBarred', dist_name=_NRCELL36502_name, p_name='cellBarred'),

    dict(value='true', dist_name=_NRCELL36502_name, p_name='actCceSplit'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actCceSplit'),
    dict(value='true', dist_name=_NRCELL36502_name, p_name='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actRat1Alloc'),
    dict(value='3', dist_name=_NRCELL36501_name, p_name='nbrOfBlankedPRBsHighEdgeDL'),
    dict(value='3', dist_name=_NRCELL36501_name, p_name='nbrOfBlankedPRBsHighEdgeUL'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actDynUlResAlloc'),
    dict(value='true', dist_name=_NRCELL36502_name, p_name='actDynUlResAlloc'),
    dict(value='511200', dist_name=_NRCELL36502_name, p_name='nrarfcn'),
    dict(value='6390', dist_name=_NRCELL36502_name, p_name='gscnOrSsPbchArfcn'),

    dict(value='10MHz', dist_name=_NRCELL36502_name, p_name='chBw'),
    dict(value='7', dist_name=_NRCELL36502_name, p_name='type0CoresetConfigurationIndex'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actPdcchSharingWithPdsch'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actUlCgType2'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actPowerSavingBWP'),
    dict(value='disabled', dist_name=_NRCELL36502_name, p_name='actNrRim'),
    dict(value='disabled', dist_name=_NRCELL36502_name, p_name='actBadUplinkRadioRedirect'),
    dict(value='4', dist_name=_NRCELL36502_name, p_name='type0SearchSpaceConfigurationIndex'),
    dict(value='disabled', dist_name=_NRCELL36502_name, p_name='actDynPdcchTdMode'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actInitialBWPFlexibility'),
    dict(value='5', dist_name=_NRCELL36502_name, p_name='msg1FrequencyStart'),
    dict(value='5000', dist_name=_NRCELL36502_name, p_name='nUeCtxForCceSplitDeactivation'),
    dict(value='pos3', dist_name=_NRCELL36501_name, p_name='dmrsTypeAPosition'),
    dict(value='pos3', dist_name=_NRCELL36502_name, p_name='dmrsTypeAPosition'),
    dict(value='14', dist_name=_NRCELL36502_name, p_name='reqMinNumPuschPrb'),
    dict(value='2', dist_name=_NRCELL36501_name, p_name='pagingOffset'),
    dict(value='0', dist_name=_NRCELL36502_name, p_name='pagingOffset'),
    dict(value='4', dist_name=_NRCELL36502_name, p_name='maxNumOfCaUsersNRCell'),
    dict(value='oneEighthT', dist_name=_NRCELL36501_name, p_name='numOfPagingFrames'),

    dict(value='false', dist_name=_NRCELL36501_name, p_name='actHighSpeedCell'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actHighSpeedCell'),
    dict(value='One additional DMRS', dist_name=_NRCELL36501_name, p_name='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL36502_name, p_name='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL36501_name, p_name='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL36502_name, p_name='ulDMRSAdditionalPosition'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL36501_name, p_name='prachSequenceType'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL36502_name, p_name='prachSequenceType'),

    # # dict(value='5', dist_name=_NRCELL36502_name, p_name='msg1FrequencyStart'),
    # # dict(value='10MHz', dist_name=_NRCELL36502_name, p_name='chBw'),
    # # dict(value='4', dist_name=_NRCELL36502_name, p_name='type0SearchSpaceConfigurationIndex'),
    # # dict(value='0', dist_name=_NRCELL36502_name, p_name='type0CoresetConfigurationIndex'),
    # dict(value='false', dist_name=_NRCELL36502_name, p_name='actPRBBlanking'),
    # dict(value='disabled', dist_name=_NRCELL36502_name, p_name='actNrRim'),
    # dict(value='disabled', dist_name=_NRCELL36502_name, p_name='actBadUplinkRadioRedirect'),
    # # dict(value='633820', dist_name=_NRCELL2_name, p_name='nrarfcn'),
    # dict(value='pos3', dist_name=_NRCELL36502_name, p_name='dmrsTypeAPosition'),
    # dict(value='2 beams', dist_name=_NRBTS36501_name + '/NRCELLGRP-3071', p_name='numberOfTransmittedSsBlocks'),

    # dict(value='false', dist_name=_NRCELL36502_name, p_name='actPowerSavingBWP'),
    # dict(value='disabled', dist_name=_NRCELL36502_name, p_name='actDynPdcchTdMode'),
    # dict(value='false', dist_name=_NRCELL36502_name, p_name='actInitialBWPFlexibility'),
    # dict(value='14', dist_name=_NRCELL36502_name, p_name='reqMinNumPuschPrb'),
    # dict(value='false', dist_name=_NRCELL36502_name, p_name='actUlCgType2'),
    # dict(value='false', dist_name=_NRCELL36502_name, p_name='actPdcchSharingWithPdsch'),
    # dict(value='pos3', dist_name=_NRCELL36502_name, p_name='dmrsTypeAPosition'),
    # dict(value='6', dist_name=_NRCELL36502_name, p_name='maxNumPagingRecords'),
    # dict(value='40', dist_name=_NRCELL36502_name, p_name='maxNumOfCaUsersNRCell'),
    # dict(value='5', dist_name=_NRCELL36502_name, p_name='msg1FrequencyStart'),
    # dict(value='4', dist_name=_NRCELL36502_name, p_name='maxNumOfCaUsersNRCell'),
    # # dict(value='16', dist_name=_NRCELL2_name, p_name='reqMinNumPuschPrb'),
    # # dict(value='0', dist_name=_NRCELL2_name, p_name='type0CoresetConfigurationIndex'),
    # # dict(value='4', dist_name=_NRCELL2_name, p_name='type0SearchSpaceConfigurationIndex'),
    # dict(value='false', dist_name=_NRCELL36501_name, p_name='actIncUlPdcchCapacity'),
    # dict(value='false', dist_name=_NRCELL36502_name, p_name='actIncUlPdcchCapacity'),
    # dict(value='disabled', dist_name=_NRBTS1_name, p_name='actFlexibleBISlotDurationMode'),
    # dict(value='false', dist_name=_NRBTS1_name, p_name='actTddCsiRsOpt'),
    # dict(value='false', dist_name=_NRBTS1_name, p_name='actTddCsiImRm'),
    # dict(value='false', dist_name=_NRCELL36501_name, p_name='actSubTRSRateMatch'),
    # dict(value='false', dist_name=_NRCELL36502_name, p_name='actSubTRSRateMatch'),
]

LIST_TO_modify_1208 = [
    dict(dist_name=_NRCELL36502_name, list_name='fPdcchMonOccsnPo',
         elements=[dict(p_name='', value='4', index=0)]),
    dict(dist_name=_NRCELL36501_name, list_name='fPdcchMonOccsnPo',
         elements=[dict(p_name='', value='9', index=0)]),
]

# PARAMETERS_TO_ONLINE_MODIFY_GNB1_1208 = [
#     dict(value='barred', dist_name=_NRCELL1_name, parameter='cellBarred'),
#     dict(value='notBarred', dist_name=_NRCELL2_name, parameter='cellBarred'),
#     dict(value='true', dist_name=_NRCELL2_name, parameter='actPowerSavingBWP'),
#     dict(value='16', dist_name=_NRCELL2_name, parameter='reqMinNumPuschPrb'),
# ]

PARAMS_TO_delete_framestructure_1208 = [
    dict(dist_name=_NRCELL36501_name, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL36502_name, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL36502_name, list_name='pdcchAutoConfig'),
    dict(dist_name=_NRCELL36501_name, list_name='cellBwpList'),
    dict(dist_name=_NRCELL36502_name, list_name='cellBwpList'),
    dict(dist_name=_NRCELL36502_name, list_name='beamSet'),
    dict(dist_name=_NRCELL36502_name, list_name='srsForBeamMgmt'),
]

PARAMS_TO_add_framestructure_1208 = [
    dict(
        dist_name=_NRCELL36501_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='pdcchAutoConfig',
        elements=dict(
            fineTuneMode='disabled',
            initialBWPMode='sameAsCoreset0',)
    ),
    dict(
        dist_name=_NRCELL36501_name,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-5001',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36501_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-5002',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36501_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-5003',
            cellBwpId='2',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36501_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-5004',
            cellBwpId='3',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-2001',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-2002',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='srsForBeamMgmt',
        elements=dict(
            bSRS='1',
            comb='comb2',
            cSRS='7',
            srsPowerThresholdForDlBm='-1200',
            srsPowerThresholdForUlBm='-1320',)
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='beamSet',
        elements=dict(
            basicBeamSet='beamSet_2',
            lowerEdgeAngle='120',
            nrBtsBeamRefinementP2='false',
            tiltOffset='0',
            upperEdgeAngle='60',)
    ),
]

# -------------------------8898--------------------------- #
ParamterToModify_9936_8898 = [
    dict(value='Locked', dist_name=_NRBTS1_name + '/NRCELL-250', p_name='administrativeState'),
    dict(value='Locked', dist_name=_NRBTS1_name + '/NRCELL-251', p_name='administrativeState'),
    dict(value='Locked', dist_name=_NRBTS1_name + '/NRCELL-660', p_name='administrativeState'),
    dict(value='Locked', dist_name=_NRBTS1_name + '/NRCELL-661', p_name='administrativeState'),
    dict(value='Locked', dist_name=_NRBTS1_name + '/NRCELL-710', p_name='administrativeState'),
    dict(value='Locked', dist_name=_NRBTS1_name + '/NRCELL-711', p_name='administrativeState'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL36502_name, p_name='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL36502_name, p_name='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELL36501_name, p_name='actDlMuMimo'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actDlMuMimo'),
    dict(value='false', dist_name=_NRCELL36501_name, p_name='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actLAForHiReliab'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actDlSrsForCA'),
    dict(value='true', dist_name=_NRCELL36502_name, p_name='actDlSrsForCA'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNrExtCellSOMethod'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNrLBmMimoRTXPowerSaving'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNrMixedSOMethod'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actNrLBPowerSaving'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actLbpsCtrlLogicEnh'),
    dict(value='false', dist_name=_NRCELL36501_name, p_name='actUeCsirsCoexistCellCsirs'),
    dict(value='false', dist_name=_NRCELL36502_name, p_name='actUeCsirsCoexistCellCsirs'),
    dict(value='disabled', dist_name=_NRBTS1_name, p_name='actCoordinated4g5gPowerSaving'),
    dict(value='TX switch off', dist_name=_NRBTS1_name + '/NRPGRP-1', p_name='lbpsSOMethod'),
    dict(value='TX switch off', dist_name=_NRBTS1_name + '/NRPGRP-0', p_name='lbpsSOMethod'),
    dict(value='SlidingAverageMethod', dist_name=_NRBTS1_name + '/NRPGRP-1', p_name='lbpsSOffTrRule'),
    dict(value='SlidingAverageMethod', dist_name=_NRBTS1_name + '/NRPGRP-2', p_name='lbpsSOffTrRule'),
    dict(value='MinValueMethod', dist_name=_NRBTS1_name + '/NRPGRP-1', p_name='lbpsSOnTrRule'),
    dict(value='MinValueMethod', dist_name=_NRBTS1_name + '/NRPGRP-2', p_name='lbpsSOnTrRule'),
    dict(value='intra-gNB', dist_name=_NRCELL36501_name, p_name='actK1Opt'),
    dict(value='intra-gNB', dist_name=_NRCELL36502_name, p_name='actK1Opt'),
    dict(value='bufferBased', dist_name=_NRBTS1_name, p_name='sCellActivationMethod'),
    dict(value='true', dist_name=_NRBTS1_name + '/NRDU-9999', p_name='actConnectedModeMobilityCA'),
    # dict(value='ConfigurationIndependent', dist_name=_NRBTS1_name + '/NRDU-9999', p_name='flexibleCAMode'),
    dict(value='true', dist_name=_NRBTS1_name + '/NRDU-9999', p_name='actInterNumerologyCa'),
    dict(value='5min', dist_name=_NRBTS1_name + '/NRPMRNL-1', p_name='miNrCellUtilization'),
    dict(value='barred', dist_name=_NRCELL36502_name, p_name='cellBarred'),
    dict(value='false', dist_name=_NRBTS1_name, p_name='actSSBBoostInmMIMOMuting'),
    dict(value='PA avoidance disabled', dist_name=_NRBTS1_name, p_name='powerSavingAvoidanceForPACalls'),
    dict(value='true', dist_name=_NRCELL36502_name, p_name='actUeCsirsCoexistCellCsirs'),
    dict(value='true', dist_name=_NRCELL36501_name, p_name='actUeCsirsCoexistCellCsirs'),
]

PARAMS_TO_delete_bwpdn_8898 = [
    dict(dist_name=_NRCELL36501_name, list_name='cellBwpList'),
    dict(dist_name=_NRCELL36502_name, list_name='cellBwpList'),
]

LIST_TO_add_bwpdn_8898 = [
    dict(
        dist_name=_NRCELL36501_name,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-8001',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36501_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-8002',
            cellBwpId='1',
            pdcchBlockingThresholdDL='30',
            pdcchBlockingThresholdUL='30',
            pdcchFreeThresholdDL='50',
            pdcchFreeThresholdUL='50',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36501_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-8003',
            cellBwpId='2',
            pdcchBlockingThresholdDL='30',
            pdcchBlockingThresholdUL='30',
            pdcchFreeThresholdDL='50',
            pdcchFreeThresholdUL='50',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36501_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-8004',
            cellBwpId='3',
            pdcchBlockingThresholdDL='30',
            pdcchBlockingThresholdUL='30',
            pdcchFreeThresholdDL='50',
            pdcchFreeThresholdUL='50',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-8011',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-8012',
            cellBwpId='1',
            pdcchBlockingThresholdDL='30',
            pdcchBlockingThresholdUL='30',
            pdcchFreeThresholdDL='50',
            pdcchFreeThresholdUL='50',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-8013',
            cellBwpId='2',
            pdcchBlockingThresholdDL='30',
            pdcchBlockingThresholdUL='30',
            pdcchFreeThresholdDL='50',
            pdcchFreeThresholdUL='50',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36502_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-8014',
            cellBwpId='3',
            pdcchBlockingThresholdDL='30',
            pdcchBlockingThresholdUL='30',
            pdcchFreeThresholdDL='50',
            pdcchFreeThresholdUL='50',
            pdcchResourcePreference='peakRate')
    ),
]

Modify_Para_Online_8898_10175 = [
    dict(value='barred', dist_name=_NRCELL36502_name, parameter='cellBarred'),
    dict(value='false', dist_name=_NRCELL36501_name, parameter='actUeCsirsCoexistCellCsirs'),
    dict(value='false', dist_name=_NRCELL36502_name, parameter='actUeCsirsCoexistCellCsirs'),
    dict(value='false', dist_name=_NRCELL36502_name, parameter='actCsirsBeamPowerBalance'),
    dict(value='false', dist_name=_NRCELL36501_name, parameter='actCsirsBeamPowerBalance'),
    dict(value=[dict(srsPowerThresholdForDlBm='-1080')],
         dist_name=_NRCELL36501_name, parameter='srsForBeamMgmt'),
    dict(value=[dict(srsPowerThresholdForDlBm='-1080')],
         dist_name=_NRCELL36502_name, parameter='srsForBeamMgmt')
]

Modify_Para_Online_attach_9936_8898_10175 = [
    dict(value='-31', dist_name=_NRCELL36501_name, parameter='qRxLevMin'),
    dict(value='-52', dist_name=_NRCELL36502_name, parameter='qRxLevMin'),
    dict(value='notBarred', dist_name=_NRCELL36502_name, parameter='cellBarred'),
    dict(value='notBarred', dist_name=_NRCELL36501_name, parameter='cellBarred'),
    dict(value='blind', dist_name=_NRCELL36502_name + '/NRREL-256', parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRCELL36502_name + '/NRREL-256', parameter='sCellOperationalMode'),

]

ListParamterToModify_8898 = [
    dict(dist_name=_NRBTS1_name + '/NRPGRP-0', list_name='lbpsCellList',
         elements=[dict(p_name='lbpsUseExtConfig', value='false', index=0)]),
    dict(dist_name=_NRBTS1_name + '/NRPGRP-0', list_name='lbpsCellPeriodList',
         elements=[dict(p_name='lbpsCellSOMethod', value='cell switch off', index=0)]),
]
