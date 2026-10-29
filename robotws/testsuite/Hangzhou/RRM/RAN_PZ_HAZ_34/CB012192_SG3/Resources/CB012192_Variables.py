from robot.libraries.BuiltIn import BuiltIn
import time
from datetime import datetime

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_bts_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-' + _global_bts_id
_NRBTSnames = 'NRBTS-' + _gnb_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id

_NRCELL11 = _NRBTSname + '/NRCELL-1'
_NRCELL12 = _NRBTSname + '/NRCELL-2'
_NRCELL13 = _NRBTSname + '/NRCELL-3'
_NRCELL36511 = _NRBTSname + '/NRCELL-36501'
_NRCELL36512 = _NRBTSname + '/NRCELL-36502'
_NRCELL37411 = _NRBTSname + '/NRCELL-37401'
_NRCELL37412 = _NRBTSname + '/NRCELL-37402'
_NRCELL37413 = _NRBTSname + '/NRCELL-37403'

_NRREL11 = _NRCELL11 + '/NRREL-1'

_CHANNELGROUP5 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-5'
_CHANNELGROUP6 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-6'
_CHANNELGROUP7 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-7'
_CHANNELGROUP8 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-8'

# ParamterToModify_12129_11160_F0_10175 = [
#     dict(value='150', dist_name=_NRCELL11, p_name='prachConfigurationIndex'),
#     dict(value='150', dist_name=_NRCELL12, p_name='prachConfigurationIndex'),
#     dict(value='15min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrRachUsage'),
#     dict(value='true', dist_name=_NRBTSname, p_name='actFdmScheduling'),
#     dict(value='true', dist_name=_NRCELL11, p_name='actFdmSchedulingInitialBWP'),
#     dict(value='6', dist_name=_NRCELL11, p_name='minRbReservedForNonSiPaging'),
#     dict(value='MCS0_SF0', dist_name=_NRCELL11, p_name='raMsg2TargetRate'),
#     dict(value='0', dist_name=_NRCELL11, p_name='pagingOffset'),
#     dict(value='0', dist_name=_NRCELL12, p_name='pagingOffset'),
# ]
#
# ParamterToModify_12129_11160_F0_10175_26R1 = [
#     dict(value='150', dist_name=_NRCELL11, p_name='prachConfigurationIndex'),
#     dict(value='150', dist_name=_NRCELL12, p_name='prachConfigurationIndex'),
#     dict(value='15min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrRachUsage'),
#     dict(value='true', dist_name=_NRBTSname, p_name='actFdmScheduling'),
#     dict(value='true', dist_name=_NRCELL11, p_name='actFdmSchedulingInitialBWP'),
#     dict(value='6', dist_name=_NRCELL11, p_name='minRbReservedForNonSiPaging'),
#     dict(value='MCS0_SF0', dist_name=_NRCELL11, p_name='raMsg2TargetRate'),
#     dict(value='0', dist_name=_NRCELL11, p_name='pagingOffset'),
#     dict(value='0', dist_name=_NRCELL12, p_name='pagingOffset'),
#     dict(value='16DL8UL', dist_name=_NRCELL11, p_name='nrCellType'),
#     dict(value='1', dist_name=_NRCELL11, p_name='pagingOffset'),
#     dict(value='1', dist_name=_NRCELL12, p_name='pagingOffset'),
# ]

LISTTOmodify_12192_F0_10175 = [
    dict(dist_name=_NRCELL11, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalPucch', value='-90', index=0),
                   dict(p_name='p0NominalPucchF1F3', value='-90', index=0),
                   dict(p_name='p0NominalPusch', value='-90', index=0),
                   dict(p_name='p0NominalSrs', value='-96', index=0)]),
    dict(dist_name=_NRCELL11, list_name='fPdcchMonOccsnPo',
         elements=[dict(p_name='', value='3', index=0)]),
    dict(dist_name=_NRCELL12, list_name='fPdcchMonOccsnPo',
         elements=[dict(p_name='', value='3', index=0)]),
]

LISTTOmodify_12192_F0_10175_26R1 = [
    dict(dist_name=_NRCELL11, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalPucch', value='-90', index=0),
                   dict(p_name='p0NominalPucchF1F3', value='-90', index=0),
                   dict(p_name='p0NominalPusch', value='-90', index=0),
                   dict(p_name='p0NominalSrs', value='-96', index=0)]),
    dict(dist_name=_NRCELL11, list_name='fPdcchMonOccsnPo',
         elements=[dict(p_name='', value='0', index=0)]),
    dict(dist_name=_NRCELL12, list_name='fPdcchMonOccsnPo',
         elements=[dict(p_name='', value='0', index=0)]),
]

# PARAMS_TO_delete_11160_F0_10175 = [
#     dict(dist_name=_NRCELL11, list_name='tddFrameStructure'),
#     dict(dist_name=_NRCELL11, list_name='cellBwpList'),
#     dict(dist_name=_NRCELL12, list_name='tddFrameStructure'),
#     dict(dist_name=_NRCELL12, list_name='cellBwpList'),
#     dict(dist_name=_NRCELL11, list_name='beamSet'),
#     dict(dist_name=_NRCELL12, list_name='beamSet'),
# ]
#
# LIST_TO_ADD_11160_F0_10175 = [
#     dict(
#         dist_name=_NRCELL11,
#         list_name='tddFrameStructure',
#         elements=dict(
#             frameStructureType='tdLte',
#             guardPeriodLength='6Symbols',
#             lteToNrFrameShift='0ms',
#             tdLteUlDlConfig='tdLteConfig2')),
#     dict(
#         dist_name=_NRCELL12,
#         list_name='tddFrameStructure',
#         elements=dict(
#             frameStructureType='tdLte',
#             guardPeriodLength='6Symbols',
#             lteToNrFrameShift='0ms',
#             tdLteUlDlConfig='tdLteConfig2')),
#     dict(
#         dist_name=_NRCELL11,
#         list_name='cellBwpList',
#         elements=dict(
#             actUpperThrAckNackFiltering='false',
#             actUpperThrAckNackHrFiltering='false',
#             actPdcchCceFragmentControl='false',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-1007',
#             cellBwpId='0',
#             pdcchResourcePreference='peakRate')
#     ),
#     dict(
#         dist_name=_NRCELL11,
#         list_name='cellBwpList',
#         elements=dict(
#             actPdcchCceFragmentControl='false',
#             actUpperThrAckNackFiltering='true',
#             actUpperThrAckNackHrFiltering='true',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-77',
#             cellBwpId='1',
#             pdcchResourcePreference='peakRate')),
#     dict(
#         dist_name=_NRCELL11,
#         list_name='cellBwpList',
#         elements=dict(
#             actPdcchCceFragmentControl='false',
#             actUpperThrAckNackFiltering='true',
#             actUpperThrAckNackHrFiltering='true',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-10070',
#             cellBwpId='2',
#             pdcchResourcePreference='peakRate')),
#     dict(
#         dist_name=_NRCELL11,
#         list_name='cellBwpList',
#         elements=dict(
#             actPdcchCceFragmentControl='false',
#             actUpperThrAckNackFiltering='true',
#             actUpperThrAckNackHrFiltering='true',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-20072',
#             cellBwpId='3',
#             pdcchResourcePreference='peakRate')),
#     dict(
#         dist_name=_NRCELL12,
#         list_name='cellBwpList',
#         elements=dict(
#             actUpperThrAckNackFiltering='false',
#             actUpperThrAckNackHrFiltering='false',
#             actPdcchCceFragmentControl='false',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-8',
#             cellBwpId='0',
#             pdcchResourcePreference='peakRate')
#     ),
#     dict(
#         dist_name=_NRCELL12,
#         list_name='cellBwpList',
#         elements=dict(
#             actPdcchCceFragmentControl='false',
#             actUpperThrAckNackFiltering='true',
#             actUpperThrAckNackHrFiltering='true',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-81',
#             cellBwpId='1',
#             pdcchResourcePreference='peakRate')),
#     dict(
#         dist_name=_NRCELL11,
#         list_name='beamSet',
#         elements=dict(
#             basicBeamSet='beamSet_5_1',
#             leftEdgeAngle='60',
#             lowerEdgeAngle='120',
#             nrBtsBeamRefinementP2='false',
#             rightEdgeAngle='60',
#             tiltOffset='0',
#             upperEdgeAngle='60')),
#     dict(
#         dist_name=_NRCELL12,
#         list_name='beamSet',
#         elements=dict(
#             basicBeamSet='beamSet_5_1',
#             leftEdgeAngle='60',
#             lowerEdgeAngle='120',
#             nrBtsBeamRefinementP2='false',
#             rightEdgeAngle='60',
#             tiltOffset='0',
#             upperEdgeAngle='60')),
# ]
#
# LIST_TO_ADD_11160_F0_10175_26R1 = [
#     dict(
#         dist_name=_NRCELL11,
#         list_name='tddFrameStructure',
#         elements=dict(
#             frameStructureType='tdLte',
#             guardPeriodLength='6Symbols',
#             lteToNrFrameShift='0ms',
#             tdLteUlDlConfig='tdLteConfig2')),
#     dict(
#         dist_name=_NRCELL12,
#         list_name='tddFrameStructure',
#         elements=dict(
#             frameStructureType='tdLte',
#             guardPeriodLength='6Symbols',
#             lteToNrFrameShift='0ms',
#             tdLteUlDlConfig='tdLteConfig2')),
#     dict(
#         dist_name=_NRCELL11,
#         list_name='cellBwpList',
#         elements=dict(
#             actUpperThrAckNackFiltering='false',
#             actUpperThrAckNackHrFiltering='false',
#             actPdcchCceFragmentControl='false',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-1007',
#             cellBwpId='0',
#             pdcchResourcePreference='peakRate')
#     ),
#     dict(
#         dist_name=_NRCELL11,
#         list_name='cellBwpList',
#         elements=dict(
#             actPdcchCceFragmentControl='false',
#             actUpperThrAckNackFiltering='true',
#             actUpperThrAckNackHrFiltering='true',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-77',
#             cellBwpId='1',
#             pdcchResourcePreference='peakRate')),
#     dict(
#         dist_name=_NRCELL11,
#         list_name='cellBwpList',
#         elements=dict(
#             actPdcchCceFragmentControl='false',
#             actUpperThrAckNackFiltering='true',
#             actUpperThrAckNackHrFiltering='true',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-10070',
#             cellBwpId='2',
#             pdcchResourcePreference='peakRate')),
#     dict(
#         dist_name=_NRCELL11,
#         list_name='cellBwpList',
#         elements=dict(
#             actPdcchCceFragmentControl='false',
#             actUpperThrAckNackFiltering='true',
#             actUpperThrAckNackHrFiltering='true',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-20072',
#             cellBwpId='3',
#             pdcchResourcePreference='peakRate')),
#     dict(
#         dist_name=_NRCELL12,
#         list_name='cellBwpList',
#         elements=dict(
#             actUpperThrAckNackFiltering='false',
#             actUpperThrAckNackHrFiltering='false',
#             actPdcchCceFragmentControl='false',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-8',
#             cellBwpId='0',
#             pdcchResourcePreference='peakRate')
#     ),
#     dict(
#         dist_name=_NRCELL12,
#         list_name='cellBwpList',
#         elements=dict(
#             actPdcchCceFragmentControl='false',
#             actUpperThrAckNackFiltering='true',
#             actUpperThrAckNackHrFiltering='true',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-81',
#             cellBwpId='1',
#             pdcchResourcePreference='peakRate')),
#     dict(
#         dist_name=_NRCELL12,
#         list_name='cellBwpList',
#         elements=dict(
#             actPdcchCceFragmentControl='false',
#             actUpperThrAckNackFiltering='true',
#             actUpperThrAckNackHrFiltering='true',
#             bwpDN=_NRBTSname + '/BWP_PROFILE-10070',
#             cellBwpId='2',
#             pdcchResourcePreference='peakRate')),
#     dict(
#         dist_name=_NRCELL11,
#         list_name='beamSet',
#         elements=dict(
#             basicBeamSet='beamSet_5_1',
#             leftEdgeAngle='60',
#             lowerEdgeAngle='120',
#             nrBtsBeamRefinementP2='false',
#             rightEdgeAngle='60',
#             tiltOffset='0',
#             upperEdgeAngle='60')),
#     dict(
#         dist_name=_NRCELL12,
#         list_name='beamSet',
#         elements=dict(
#             basicBeamSet='beamSet_5_1',
#             leftEdgeAngle='60',
#             lowerEdgeAngle='120',
#             nrBtsBeamRefinementP2='false',
#             rightEdgeAngle='60',
#             tiltOffset='0',
#             upperEdgeAngle='60')),
# ]

ParamterToModify_12129_11160_F0_11006 = [
    dict(value='150', dist_name=_NRCELL37411, p_name='prachConfigurationIndex'),
    dict(value='15min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrRachUsage'),
    dict(value='true', dist_name=_NRBTSname, p_name='actFdmScheduling'),
    dict(value='true', dist_name=_NRCELL37411, p_name='actFdmSchedulingInitialBWP'),
    dict(value='6', dist_name=_NRCELL37411, p_name='minRbReservedForNonSiPaging'),
    dict(value='MCS0_SF0', dist_name=_NRCELL37411, p_name='raMsg2TargetRate'),
    dict(value='false', dist_name=_NRCELL37411, p_name='actEnhancedPDSCHSchSplSlot'),
    dict(value='16DL8UL', dist_name=_NRCELL37411, p_name='nrCellType'),
]

LISTTOmodify_12192_F0_11006 = [
    dict(dist_name=_NRCELL37411, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalPucch', value='-90', index=0),
                   dict(p_name='p0NominalPucchF1F3', value='-90', index=0),
                   dict(p_name='p0NominalPusch', value='-90', index=0),
                   dict(p_name='p0NominalSrs', value='-96', index=0)]),
]

PARAMS_TO_delete_11160_F0_11006 = [
    dict(dist_name=_NRCELL37411, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL37411, list_name='cellBwpList'),
]

LIST_TO_ADD_11160_F0_11006 = [
    dict(
        dist_name=_NRCELL37411,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='6Symbols',
            lteToNrFrameShift='0ms',
            tdLteUlDlConfig='tdLteConfig2')),
    dict(
        dist_name=_NRCELL37411,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-1007',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL37411,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-75',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL37411,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-10071',
            cellBwpId='2',
            pdcchResourcePreference='peakRate')),
]

LISTTOmodify_1208_F0_11006 = [
    dict(dist_name=_NRCELL37411, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalPucch', value='-90', index=0),
                   dict(p_name='p0NominalPucchF1F3', value='-90', index=0),
                   dict(p_name='p0NominalPusch', value='-90', index=0),
                   dict(p_name='p0NominalSrs', value='-96', index=0)]),
    dict(dist_name=_NRCELL37411, list_name='fPdcchMonOccsnPo',
         elements=[dict(p_name='', value='6', index=0)]),
]

ParamterToModify_12129_1208_C2_11006 = [
    dict(value='202', dist_name=_NRCELL37411, p_name='prachConfigurationIndex'),
    dict(value='15min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrRachUsage'),
    dict(value='6 beams', dist_name=_NRBTSname + '/NRCELLGRP-3060', p_name='numberOfTransmittedSsBlocks'),
    dict(value='8DL8UL', dist_name=_NRCELL37411, p_name='nrCellType'),
    dict(value='false', dist_name=_NRCELL37411, p_name='actIncUlPdcchCapacity'),
    dict(value='false', dist_name=_NRCELL37413, p_name='actIncUlPdcchCapacity'),
]

PARAMS_TO_delete_1208_C2_11006 = [
    dict(dist_name=_NRCELL37411, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL37411, list_name='cellBwpList'),
    dict(dist_name=_NRCELL37411, list_name='beamSet'),
]

LIST_TO_ADD_1208_C2_11006_TRUNK = [
    dict(
        dist_name=_NRCELL37411,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='3/7')),
    dict(
        dist_name=_NRCELL37411,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-1006',
            cellBwpId='0',
            pdcchBlockingThresholdDL='30',
            pdcchBlockingThresholdUL='30',
            pdcchFreeThresholdDL='50',
            pdcchFreeThresholdUL='50',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL37411,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-65',
            cellBwpId='1',
            pdcchBlockingThresholdDL='30',
            pdcchBlockingThresholdUL='30',
            pdcchFreeThresholdDL='50',
            pdcchFreeThresholdUL='50',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL37411,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-10061',
            cellBwpId='2',
            pdcchBlockingThresholdDL='30',
            pdcchBlockingThresholdUL='30',
            pdcchFreeThresholdDL='50',
            pdcchFreeThresholdUL='50',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL37411,
        list_name='beamSet',
        elements=dict(
            basicBeamSet='beamSet_5_1',
            leftEdgeAngle='60',
            lowerEdgeAngle='120',
            nrBtsBeamRefinementP2='false',
            rightEdgeAngle='60',
            tiltOffset='0',
            upperEdgeAngle='60')),
]

# LISTTOmodify_1208_F0_10175 = [
#     dict(dist_name=_NRCELL11, list_name='ulPowerControlCommon',
#          elements=[dict(p_name='p0NominalPucch', value='-90', index=0),
#                    dict(p_name='p0NominalPucchF1F3', value='-90', index=0),
#                    dict(p_name='p0NominalPusch', value='-90', index=0),
#                    dict(p_name='p0NominalSrs', value='-96', index=0)]),
#     dict(dist_name=_NRCELL11, list_name='fPdcchMonOccsnPo',
#          elements=[dict(p_name='', value='6', index=0)]),
#     dict(dist_name=_NRCELL12, list_name='fPdcchMonOccsnPo',
#          elements=[dict(p_name='', value='6', index=0)]),
# ]

LISTTOmodify_1208_F0_10175_26R1 = [
    dict(dist_name=_NRCELL36511, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalPucch', value='-90', index=0),
                   dict(p_name='p0NominalPucchF1F3', value='-90', index=0),
                   dict(p_name='p0NominalPusch', value='-90', index=0),
                   dict(p_name='p0NominalSrs', value='-96', index=0)]),
    dict(dist_name=_NRCELL36511, list_name='fPdcchMonOccsnPo',
         elements=[dict(p_name='', value='6', index=0)]),
    dict(dist_name=_NRCELL36512, list_name='fPdcchMonOccsnPo',
         elements=[dict(p_name='', value='6', index=0)]),
]

# ParamterToModify_12129_1208_C2_10175 = [
#     dict(value='202', dist_name=_NRCELL11, p_name='prachConfigurationIndex'),
#     dict(value='202', dist_name=_NRCELL12, p_name='prachConfigurationIndex'),
#     dict(value='15min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrRachUsage'),
#     dict(value='6 beams', dist_name=_NRBTSname + '/NRCELLGRP-3070', p_name='numberOfTransmittedSsBlocks'),
#     dict(value='8DL4UL', dist_name=_NRCELL11, p_name='nrCellType'),
#     dict(value='oneEighthT', dist_name=_NRCELL11, p_name='numOfPagingFrames'),
#     dict(value='oneEighthT', dist_name=_NRCELL12, p_name='numOfPagingFrames'),
#     dict(value='2', dist_name=_NRCELL11, p_name='pagingOffset'),
#     dict(value='2', dist_name=_NRCELL12, p_name='pagingOffset'),
# ]

ParamterToModify_12129_1208_C2_10175_26R1 = [
    dict(value='202', dist_name=_NRCELL36511, p_name='prachConfigurationIndex'),
    dict(value='202', dist_name=_NRCELL36512, p_name='prachConfigurationIndex'),
    dict(value='15min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrRachUsage'),
    # dict(value='6 beams', dist_name=_NRBTSname + '/NRCELLGRP-3070', p_name='numberOfTransmittedSsBlocks'),
    # dict(value='8DL8UL', dist_name=_NRCELL11, p_name='nrCellType'),
    dict(value='2', dist_name=_NRCELL36511, p_name='pagingOffset'),
    dict(value='2', dist_name=_NRCELL36512, p_name='pagingOffset'),
    dict(value='false', dist_name=_NRCELL36511, p_name='actIncUlPdcchCapacity'),
    dict(value='false', dist_name=_NRCELL36512, p_name='actIncUlPdcchCapacity'),
    dict(value='2.5ms', dist_name=_NRCELL36511 + '/NRRIM_PROFILE-1', p_name='rsPattern1Period'),
    dict(value='2.5ms', dist_name=_NRCELL36511 + '/NRRIM_PROFILE-1', p_name='rsPattern2Period'),
    dict(value='2.5ms', dist_name=_NRCELL36512 + '/NRRIM_PROFILE-1', p_name='rsPattern1Period'),
    dict(value='2.5ms', dist_name=_NRCELL36512 + '/NRRIM_PROFILE-1', p_name='rsPattern2Period'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actFlexibleBISlotDurationMode'),
]

PARAMS_TO_delete_1208_C2_10175 = [
    dict(dist_name=_NRCELL36511, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL36512, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL36511, list_name='cellBwpList'),
    dict(dist_name=_NRCELL36512, list_name='cellBwpList'),
    # dict(dist_name=_NRCELL11, list_name='beamSet'),
    # dict(dist_name=_NRCELL11, list_name='pdcchAutoConfig'),
    # dict(dist_name=_NRCELL12, list_name='pdcchAutoConfig'),
]

LIST_TO_ADD_1208_C2_10175_26R1 = [
    dict(
        dist_name=_NRCELL36511,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='3/7')),
    dict(
        dist_name=_NRCELL36512,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='3/7')),
    dict(
        dist_name=_NRCELL36511,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-1006',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36511,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-67',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL36511,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-10060',
            cellBwpId='2',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL36511,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-20062',
            cellBwpId='3',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL36512,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-6',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL36512,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-61',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL36512,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-10061',
            cellBwpId='2',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL36512,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTSname + '/BWP_PROFILE-20061',
            cellBwpId='3',
            pdcchResourcePreference='peakRate')),
]

Modify_Para_Online_nbrOfSsbPerRachOccasion_four_11006 = [
    dict(value='four', dist_name=_NRCELL11, parameter='nbrOfSsbPerRachOccasion'),
    dict(value='n14', dist_name=_NRCELL11, parameter='cbraPreamblesPerSsb'),
]

Modify_Para_Online_nbrOfSsbPerRachOccasion_four_10175 = [
    dict(value='four', dist_name=_NRCELL36511, parameter='nbrOfSsbPerRachOccasion'),
    dict(value='n14', dist_name=_NRCELL36511, parameter='cbraPreamblesPerSsb'),
    dict(value='four', dist_name=_NRCELL36512, parameter='nbrOfSsbPerRachOccasion'),
    dict(value='n14', dist_name=_NRCELL36512, parameter='cbraPreamblesPerSsb'),
]

Modify_Para_Online_PR828434_11006 = [
    dict(value='RestrictedTypeA', dist_name=_NRCELL11, parameter='prachSequenceType'),
    dict(value='11', dist_name=_NRCELL11, parameter='zeroCorrelationZoneConfig'),
]

Modify_Para_Online_PR828434_10175 = [
    dict(value='RestrictedTypeA', dist_name=_NRCELL36511, parameter='prachSequenceType'),
    dict(value='11', dist_name=_NRCELL36511, parameter='zeroCorrelationZoneConfig'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL36512, parameter='prachSequenceType'),
    dict(value='11', dist_name=_NRCELL36512, parameter='zeroCorrelationZoneConfig'),
]

Modify_Para_Online_nbrOfSsbPerRachOccasion_two_11006 = [
    dict(value='two', dist_name=_NRCELL11, parameter='nbrOfSsbPerRachOccasion'),
    dict(value='n16', dist_name=_NRCELL11, parameter='cbraPreamblesPerSsb'),
]

Modify_Para_Online_nbrOfSsbPerRachOccasion_two_10175 = [
    dict(value='two', dist_name=_NRCELL36511, parameter='nbrOfSsbPerRachOccasion'),
    dict(value='n16', dist_name=_NRCELL36511, parameter='cbraPreamblesPerSsb'),
    dict(value='two', dist_name=_NRCELL36512, parameter='nbrOfSsbPerRachOccasion'),
    dict(value='n16', dist_name=_NRCELL36512, parameter='cbraPreamblesPerSsb'),
]

Modify_online_05432191_on = [
    dict(value='two', dist_name=_NRCELL11, parameter='nbrOfSsbPerRachOccasion'),
    dict(value='n16', dist_name=_NRCELL11, parameter='cbraPreamblesPerSsb'),
    dict(value='two', dist_name=_NRCELL13, parameter='nbrOfSsbPerRachOccasion'),
    dict(value='n16', dist_name=_NRCELL13, parameter='cbraPreamblesPerSsb'),
]

Modify_online_05432191_off = [
    dict(value='one', dist_name=_NRCELL11, parameter='nbrOfSsbPerRachOccasion'),
    dict(value='n64', dist_name=_NRCELL11, parameter='cbraPreamblesPerSsb'),
    dict(value='one', dist_name=_NRCELL13, parameter='nbrOfSsbPerRachOccasion'),
    dict(value='n64', dist_name=_NRCELL13, parameter='cbraPreamblesPerSsb'),
]

counter_id_CBRA = [
    'M55306C00001', 'M55306C00002', 'M55306C00003', 'M55306C00004', 'M55306C00005', 'M55306C00006'

]

dic_path_CBRA_beam_11006 = [
    'BTS/' + _NRBTSname + '/NRCELL-37401/NRACH',
    'BTS/' + _NRBTSname + '/NRCELL-37401/NRACH',
    'BTS/' + _NRBTSname + '/NRCELL-37401/NRACH',
    'BTS/' + _NRBTSname + '/NRCELL-37401/NRACH',
    'BTS/' + _NRBTSname + '/NRCELL-37401/NRACH',
    'BTS/' + _NRBTSname + '/NRCELL-37401/NRACH',
]

counter_id_CFRA = [
    'M55306C02001', 'M55306C02002', 'M55306C02003', 'M55306C02004', 'M55306C02005', 'M55306C02006'
]

dic_path_CBRA_beam_10175 = [
    'BTS/' + _NRBTSname + '/NRCELL-36501/NRACH',
    'BTS/' + _NRBTSname + '/NRCELL-36501/NRACH',
    'BTS/' + _NRBTSname + '/NRCELL-36501/NRACH',
    'BTS/' + _NRBTSname + '/NRCELL-36501/NRACH',
    'BTS/' + _NRBTSname + '/NRCELL-36501/NRACH',
    'BTS/' + _NRBTSname + '/NRCELL-36501/NRACH',
]
