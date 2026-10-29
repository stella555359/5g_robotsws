from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
LNBTS1_NAME = 'LNBTS-' + str(tl.enbs[0].global_bts_id)


PARAMS_TO_MODIFY_COMMON = [
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='actDl256Qam'),
    dict(
        value='156',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='prachConfigurationIndex'),
    dict(
        value='tdLte',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='guardPeriodLength'),
    dict(
        value='1/4',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='ulDlDataSlotRatio'),
    dict(
        value='0ms',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='lteToNrFrameShift'),
    dict(
        value='tdLteConfig2',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='tdLteUlDlConfig')
]

PARAMS_TO_MODIFY_100M = [
    dict(
        value='100MHz',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='chBw')
]


PARAMS_TO_MODIFY_40M_40M = [
    dict(
        value='40MHz',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='chBw'),
    dict(
        value='40MHz',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='chBw')
]

PARAMS_TO_MODIFY_NRCELLTYPE_4x2_1113_A = [
    dict(
        value='4DL2UL',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='nrCellType'),
    dict(
        value='2Rx',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='numberOfRxBeamforming'),
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='dlMimoMode'),
    dict(
        value='Closed loop Spatial Multiplexing (2x2)',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='ulMimoMode'),
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='actBeamforming'),
    dict(
        value='beamSet_2',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        list_name='beamSet',
        p_name='basicBeamSet'),
    dict(
        value='60',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        list_name='beamSet',
        p_name='leftEdgeAngle'),
    dict(
        value='false',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        list_name='beamSet',
        p_name='nrBtsBeamRefinementP2'),
    dict(
        value='60',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        list_name='beamSet',
        p_name='rightEdgeAngle'),
    dict(
        value='2 beams',
        dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0',
        p_name='numberOfTransmittedSsBlocks')
]

PARAMS_TO_MODIFY_NRCELLTYPE_4x2_1113_B = [
    dict(
         value='4DL2UL',
         dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         p_name='nrCellType'),
    dict(
         value='2Rx',
         dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         p_name='numberOfRxBeamforming'),
    dict(
         value='4x4 or 4x2 Open Loop Spatial Multiplexing',
         dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         p_name='dlMimoMode'),
    dict(
         value='Closed loop Spatial Multiplexing (2x2)',
         dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         p_name='ulMimoMode'),
    dict(
         value='true',
         dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         p_name='actBeamforming'),
    dict(
         value='beamSet_2',
         dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         list_name='beamSet',
         p_name='basicBeamSet'),
    dict(
         value='45',
         dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         list_name='beamSet',
         p_name='leftEdgeAngle'),
    dict(
         value='false',
         dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         list_name='beamSet',
         p_name='nrBtsBeamRefinementP2'),
    dict(
         value='45',
         dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         list_name='beamSet',
         p_name='rightEdgeAngle'),
    dict(
         value='2 beams',
         dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0',
         p_name='numberOfTransmittedSsBlocks'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='nrCellType'),
    dict(
        value='2Rx',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='numberOfRxBeamforming'),
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='dlMimoMode'),
    dict(
        value='Closed loop Spatial Multiplexing (2x2)',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='ulMimoMode'),
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='actBeamforming'),
    dict(
        value='beamSet_2',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        list_name='beamSet',
        p_name='basicBeamSet'),
    dict(
        value='45',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        list_name='beamSet',
        p_name='leftEdgeAngle'),
    dict(
        value='false',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        list_name='beamSet',
        p_name='nrBtsBeamRefinementP2'),
    dict(
        value='45',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        list_name='beamSet',
        p_name='rightEdgeAngle'),
    dict(
        value='2 beams',
        dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1',
        p_name='numberOfTransmittedSsBlocks')
    ]

PARAMS_TO_MODIFY_NRCELLTYPE_8x4_1113_C = [
    dict(
        value='8DL4UL',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='nrCellType'),
    dict(
        value='4Rx',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='numberOfRxBeamforming'),
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='dlMimoMode'),
    dict(
        value='Closed loop Spatial Multiplexing (2x2)',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='ulMimoMode'),
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='actBeamforming'),
    dict(
        value='beamSet_2',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        list_name='beamSet',
        p_name='basicBeamSet'),
    dict(
        value='60',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        list_name='beamSet',
        p_name='leftEdgeAngle'),
    dict(
        value='false',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        list_name='beamSet',
        p_name='nrBtsBeamRefinementP2'),
    dict(
        value='60',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        list_name='beamSet',
        p_name='rightEdgeAngle'),
    dict(
        value='2 beams',
        dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0',
        p_name='numberOfTransmittedSsBlocks')
]

PARAMS_TO_DELTE_CELL2 = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', elements=['-30'])
]


PARAMS_TO_DELETE_CHANNEL = [
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1')
]

PARAMS_TO_ADD_CHANNEL_A = [
    dict(class_name='com.nokia.srbts.mnl:CHANNELGROUP',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2',
         p_name='direction',
         value='RX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4',
         p_name='direction',
         value='RX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

]

PARAMS_TO_ADD_CHANNEL_B = [
    dict(class_name='com.nokia.srbts.mnl:CHANNELGROUP',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2',
         p_name='direction',
         value='RX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4',
         p_name='direction',
         value='RX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),
    ] + PARAMS_TO_ADD_CHANNEL_A

PARAMS_TO_ADD_CHANNEL_C = [
    dict(class_name='com.nokia.srbts.mnl:CHANNELGROUP',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5',
         p_name='direction',
         value='RX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6',
         p_name='direction',
         value='RX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL5GC21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7',
         p_name='direction',
         value='RX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL5GC21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8',
         p_name='direction',
         value='RX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNELGROUP',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL5GC21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL5GC21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL5GC21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         version='MNL5GC21B_2105_001', opertion='create',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4',
         p_name='direction',
         value='TX'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4',
         p_name='resourceDN',
         value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'),

]

PARAMS_TO_ADD_REFNRCELLGROUP = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1',
         list_name='refNrCellGroup', elements=[0]),
]

PARAMS_TO_MODIFY_BWP_PROFILE44_COMMON = [
    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='coresetId', list_name='searchSpaceCommon', index=0),
    dict(value='formats0-0-And-1-0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='dciFormat', list_name='searchSpaceCommon', index=0),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='duration', list_name='searchSpaceCommon', index=0),
    dict(value='symbol_0_1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='monitoringSymbolWithinSlot', list_name='searchSpaceCommon', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='numOfPdcchCandidatesInAL16', list_name='searchSpaceCommon', index=0),
    dict(value='n4',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='numOfPdcchCandidatesInAL2', list_name='searchSpaceCommon', index=0),
    dict(value='n2',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='numOfPdcchCandidatesInAL4', list_name='searchSpaceCommon', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='numOfPdcchCandidatesInAL8', list_name='searchSpaceCommon', index=0),
    dict(value='sl1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='periodicity', list_name='searchSpaceCommon', index=0),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='searchSpaceId', list_name='searchSpaceCommon', index=0),
    dict(value='Type1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='searchSpaceType', list_name='searchSpaceCommon', index=0),
    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='slotOffset', list_name='searchSpaceCommon', index=0),

    dict(value='nonInterleaved',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='cceToRegMapping', list_name='coresetDedicated', index=0),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='coresetId', list_name='coresetDedicated', index=0),
    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='cRbStart', list_name='coresetDedicated', index=0),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='duration', list_name='coresetDedicated', index=0),
    dict(value='none',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='interleaverSize', list_name='coresetDedicated', index=0),
    dict(value='n6',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='regBundleSize', list_name='coresetDedicated', index=0),
    dict(value='120',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='size', list_name='coresetDedicated', index=0),

    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='coresetId', list_name='searchSpaceDedicated', index=0),
    dict(value='formats0-0-And-1-0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='dciFormat', list_name='searchSpaceDedicated', index=0),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='duration', list_name='searchSpaceDedicated', index=0),
    dict(value='symbol_0_1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='monitoringSymbolWithinSlot', list_name='searchSpaceDedicated', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL1', list_name='searchSpaceDedicated', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL16', list_name='searchSpaceDedicated', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL2', list_name='searchSpaceDedicated', index=0),
    dict(value='n2',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL4', list_name='searchSpaceDedicated', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL8', list_name='searchSpaceDedicated', index=0),
    dict(value='sl1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='periodicity', list_name='searchSpaceDedicated', index=0),
    dict(value='2',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='searchSpaceId', list_name='searchSpaceDedicated', index=0),
    dict(value='Type3',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='searchSpaceType', list_name='searchSpaceDedicated', index=0),
    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='slotOffset', list_name='searchSpaceDedicated', index=0),

    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='coresetId', list_name='searchSpaceDedicated', index=1),
    dict(value='formats0-1-And-1-1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='dciFormat', list_name='searchSpaceDedicated', index=1),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='duration', list_name='searchSpaceDedicated', index=1),
    dict(value='symbol_0_1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='monitoringSymbolWithinSlot', list_name='searchSpaceDedicated', index=1),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL1', list_name='searchSpaceDedicated', index=1),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL16', list_name='searchSpaceDedicated', index=1),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL2', list_name='searchSpaceDedicated', index=1),
    dict(value='n5',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL4', list_name='searchSpaceDedicated', index=1),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL8', list_name='searchSpaceDedicated', index=1),
    dict(value='sl1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='periodicity', list_name='searchSpaceDedicated', index=1),
    dict(value='3',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='searchSpaceId', list_name='searchSpaceDedicated', index=1),
    dict(value='UE-Specific',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='searchSpaceType', list_name='searchSpaceDedicated', index=1),
    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='slotOffset', list_name='searchSpaceDedicated', index=1),
]

PARAMS_TO_MODIFY_BWP_FOR_1113_B = [
    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='coresetId', list_name='searchSpaceCommon', index=0),
    dict(value='formats0-0-And-1-0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='dciFormat', list_name='searchSpaceCommon', index=0),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='duration', list_name='searchSpaceCommon', index=0),
    dict(value='symbol_0_1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='monitoringSymbolWithinSlot', list_name='searchSpaceCommon', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='numOfPdcchCandidatesInAL16', list_name='searchSpaceCommon', index=0),
    dict(value='n4',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='numOfPdcchCandidatesInAL2', list_name='searchSpaceCommon', index=0),
    dict(value='n2',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='numOfPdcchCandidatesInAL4', list_name='searchSpaceCommon', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='numOfPdcchCandidatesInAL8', list_name='searchSpaceCommon', index=0),
    dict(value='sl1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='periodicity', list_name='searchSpaceCommon', index=0),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='searchSpaceId', list_name='searchSpaceCommon', index=0),
    dict(value='Type1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='searchSpaceType', list_name='searchSpaceCommon', index=0),
    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         p_name='slotOffset', list_name='searchSpaceCommon', index=0),

    dict(value='nonInterleaved',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='cceToRegMapping', list_name='coresetDedicated', index=0),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='coresetId', list_name='coresetDedicated', index=0),
    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='cRbStart', list_name='coresetDedicated', index=0),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='duration', list_name='coresetDedicated', index=0),
    dict(value='none',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='interleaverSize', list_name='coresetDedicated', index=0),
    dict(value='n6',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='regBundleSize', list_name='coresetDedicated', index=0),
    dict(value='96',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='size', list_name='coresetDedicated', index=0),

    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='coresetId', list_name='searchSpaceDedicated', index=0),
    dict(value='formats0-0-And-1-0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='dciFormat', list_name='searchSpaceDedicated', index=0),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='duration', list_name='searchSpaceDedicated', index=0),
    dict(value='symbol_0_1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='monitoringSymbolWithinSlot', list_name='searchSpaceDedicated', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL1', list_name='searchSpaceDedicated', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL16', list_name='searchSpaceDedicated', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL2', list_name='searchSpaceDedicated', index=0),
    dict(value='n2',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL4', list_name='searchSpaceDedicated', index=0),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL8', list_name='searchSpaceDedicated', index=0),
    dict(value='sl1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='periodicity', list_name='searchSpaceDedicated', index=0),
    dict(value='2',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='searchSpaceId', list_name='searchSpaceDedicated', index=0),
    dict(value='Type3',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='searchSpaceType', list_name='searchSpaceDedicated', index=0),
    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='slotOffset', list_name='searchSpaceDedicated', index=0),

    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='coresetId', list_name='searchSpaceDedicated', index=1),
    dict(value='formats0-1-And-1-1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='dciFormat', list_name='searchSpaceDedicated', index=1),
    dict(value='1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='duration', list_name='searchSpaceDedicated', index=1),
    dict(value='symbol_0_1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='monitoringSymbolWithinSlot', list_name='searchSpaceDedicated', index=1),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL1', list_name='searchSpaceDedicated', index=1),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL16', list_name='searchSpaceDedicated', index=1),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL2', list_name='searchSpaceDedicated', index=1),
    dict(value='n4',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL4', list_name='searchSpaceDedicated', index=1),
    dict(value='n0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='numOfPdcchCandidatesInAL8', list_name='searchSpaceDedicated', index=1),
    dict(value='sl1',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='periodicity', list_name='searchSpaceDedicated', index=1),
    dict(value='3',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='searchSpaceId', list_name='searchSpaceDedicated', index=1),
    dict(value='UE-Specific',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='searchSpaceType', list_name='searchSpaceDedicated', index=1),
    dict(value='0',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         p_name='slotOffset', list_name='searchSpaceDedicated', index=1)
]

PARAMS_TO_MODIFY_PEAK_A_OR_C = [
    dict(
        value='630000',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='nrarfcn'),
    dict(
        value='7811',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='gscn'),
    dict(
        value='78',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='freqBandIndicatorNR'),
    dict(
        value='12',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='type0CoresetConfigurationIndex'),
    dict(
        value='349',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='pMax'),
    dict(
        value='14',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='ssPbchBlockPower'),
    dict(
        value='-76',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='p0NominalPucch'),
    dict(
        value='-82',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='p0NominalPusch'),
    dict(
        value='-76',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='p0NominalSrs'),
    dict(
        value='249',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='physCellId')
]

PARAMS_TO_MODIFY_PEAK_B = [
    dict(
        value='633356',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='nrarfcn'),
    dict(
        value='1',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='gscn'),
    dict(
        value='10',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='type0CoresetConfigurationIndex'),
    dict(
        value='260',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='pMax'),
    dict(
        value='0',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='ssPbchBlockPower'),
    dict(
        value='-96',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='p0NominalPucch'),
    dict(
        value='-98',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='p0NominalPusch'),
    dict(
        value='249',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='physCellId'),
    dict(
        value='630000',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='nrarfcn'),
    dict(
        value='1',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='gscn'),
    dict(
        value='10',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='type0CoresetConfigurationIndex'),
    dict(
        value='260',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='pMax'),
    dict(
        value='0',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='ssPbchBlockPower'),
    dict(
        value='-96',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='p0NominalPucch'),
    dict(
        value='-98',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='p0NominalPusch'),
    dict(
        value='250',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='physCellId')
]

PARAMS_TO_MODIFY_FOR_4RX = [
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actFdmScheduling'),
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actFdmEnhancedScheduling'),
]

PARAMS_TO_MODIFY_FOR_FAULT_7300 = [
    dict(
        value='1',
        dist_name=MR_NR_BTS_NAME,
        p_name='shutdownNogNBCellTmr'),
]

# will use 1113-B as basic SCF. Need to pay attation to nrcellType and channel group configuration.
# so need delete and add channel in scf operation to make sure the channel configuration is correct.
# PARAM_TO_DELETE_CHANNEL, PARAM_TO_ADD_CHANNEL_A, PARAM_TO_ADD_CHANNEL_B, PARAM_TO_ADD_CHANNEL_C
# are for channel configuration.
# there are two cells in 1113-B, 1 cell in 1113-A and 1113-C,
# so PARAMS_TO_DELTE_CELL2 is needed for 1113-A 1113-C.

PARAMS_TO_DELETE_FOR_1113_A_OR_C = PARAMS_TO_DELTE_CELL2 + PARAMS_TO_DELETE_CHANNEL
PARAMS_TO_DELETE_FOR_1113_B = PARAMS_TO_DELETE_CHANNEL

PARAMS_TO_ADD_FOR_1113_A = PARAMS_TO_ADD_CHANNEL_A + PARAMS_TO_ADD_REFNRCELLGROUP
PARAMS_TO_ADD_FOR_1113_B = PARAMS_TO_ADD_CHANNEL_B
PARAMS_TO_ADD_FOR_1113_C = PARAMS_TO_ADD_CHANNEL_C + PARAMS_TO_ADD_REFNRCELLGROUP

PARAMS_TO_MODIFY_FOR_1113_A = PARAMS_TO_MODIFY_COMMON + PARAMS_TO_MODIFY_100M + \
                          PARAMS_TO_MODIFY_NRCELLTYPE_4x2_1113_A + PARAMS_TO_MODIFY_BWP_PROFILE44_COMMON + \
                          PARAMS_TO_MODIFY_PEAK_A_OR_C + PARAMS_TO_MODIFY_FOR_FAULT_7300

PARAMS_TO_MODIFY_FOR_1113_B = PARAMS_TO_MODIFY_COMMON + PARAMS_TO_MODIFY_40M_40M +\
                          PARAMS_TO_MODIFY_NRCELLTYPE_4x2_1113_B + PARAMS_TO_MODIFY_BWP_FOR_1113_B + \
                          PARAMS_TO_MODIFY_PEAK_B + PARAMS_TO_MODIFY_FOR_FAULT_7300

PARAMS_TO_MODIFY_FOR_1113_C = PARAMS_TO_MODIFY_COMMON + PARAMS_TO_MODIFY_100M + \
                          PARAMS_TO_MODIFY_NRCELLTYPE_8x4_1113_C + PARAMS_TO_MODIFY_BWP_PROFILE44_COMMON + \
                          PARAMS_TO_MODIFY_PEAK_A_OR_C + PARAMS_TO_MODIFY_FOR_4RX + PARAMS_TO_MODIFY_FOR_FAULT_7300

PARAMS_TO_DELETE_BWP_PROFILE44_FOR_7464 = [
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-44'),
]

PARAMS_TO_ADD_BWP_PROFILE41_FOR_7464 = [
    dict(class_name='com.nokia.srbts.nrbts:BWP_PROFILE',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41',
         p_name='bwpType', value='dedicated'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41',
         list_name='locationAndBandwidthDl', elements={
                "cRbSizeDl": 'allRb',
                "cRbStartDl": 'crb0'}),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41',
         list_name='locationAndBandwidthUl', elements={
                "cRbSizeUl": 'sameAsDl',
                "cRbStartUl": 'sameAsDl'}),

    dict(class_name='com.nokia.srbts.nrbts:PDCCH',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1',
         p_name='alSelection', value='static'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1',
         p_name='dciDedicatedAggregationLevel', value='AL4'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1',
         p_name='dciPagingAggregationLevel', value='AL4'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1',
         p_name='dciRaCompletionAggregationLevel', value='AL4'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1',
         p_name='dciRaMsg2AggregationLevel', value='AL4'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1',
         p_name='dciSiAggregationLevel', value='AL4'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1',
         p_name='downgradeAL16toAL8', value='notAllowed'),

    dict(class_name='com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1/PDCCH_CONFIG_COMMON-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         list_name='searchSpaceCommon', elements={
            "coresetId": '0',
            "dciFormat": 'formats0-0-And-1-0',
            "duration": '1',
            "monitoringSymbolWithinSlot": 'symbol_0_1',
            "numOfPdcchCandidatesInAL16": 'n0',
            "numOfPdcchCandidatesInAL2": 'n4',
            "numOfPdcchCandidatesInAL4": 'n2',
            "numOfPdcchCandidatesInAL8": 'n0',
            "periodicity": 'sl1',
            "searchSpaceId": '1',
            "searchSpaceType": 'Type1',
            "slotOffset": '0'}),

    dict(class_name='com.nokia.srbts.nrbts:PDCCH_CONFIG_DEDICATED',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1/PDCCH_CONFIG_DEDICATED-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         list_name='coresetDedicated',
         elements={"cceToRegMapping": 'nonInterleaved',
                   "coresetId": '1',
                   "cRbStart": '0',
                   "duration": '1',
                   "interleaverSize": 'none',
                   "regBundleSize": 'n6',
                   "size": '96'}),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         list_name='searchSpaceDedicated',
         elements={"coresetId": '0',
                   "dciFormat": 'formats0-0-And-1-0',
                   "duration": '1',
                   "monitoringSymbolWithinSlot": 'symbol_0_1',
                   "numOfPdcchCandidatesInAL1": 'n0',
                   "numOfPdcchCandidatesInAL16": 'n0',
                   "numOfPdcchCandidatesInAL2": 'n0',
                   "numOfPdcchCandidatesInAL4": 'n2',
                   "numOfPdcchCandidatesInAL8": 'n0',
                   "periodicity": 'sl1',
                   "searchSpaceId": '2',
                   "searchSpaceType": 'Type3',
                   "slotOffset": '0'}),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-41/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         list_name='searchSpaceDedicated',
         elements={"coresetId": '1',
                   "dciFormat": 'formats0-1-And-1-1',
                   "duration": '1',
                   "monitoringSymbolWithinSlot": 'symbol_0_1',
                   "numOfPdcchCandidatesInAL1": 'n0',
                   "numOfPdcchCandidatesInAL16": 'n0',
                   "numOfPdcchCandidatesInAL2": 'n0',
                   "numOfPdcchCandidatesInAL4": 'n4',
                   "numOfPdcchCandidatesInAL8": 'n0',
                   "periodicity": 'sl1',
                   "searchSpaceId": '3',
                   "searchSpaceType": 'UE-Specific',
                   "slotOffset": '0'}),
]

PARAMS_TO_ADD_BWP_PROFILE42_FOR_7464 = [
    dict(class_name='com.nokia.srbts.nrbts:BWP_PROFILE',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42'),

    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42',
         p_name='bwpType', value='dedicated'),

    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42',
         list_name='locationAndBandwidthDl',
         elements={
            "cRbSizeDl": 'allRb',
            "cRbStartDl": 'crb0'}),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42',
         list_name='locationAndBandwidthUl', elements={
            "cRbSizeUl": 'sameAsDl',
            "cRbStartUl": 'sameAsDl'}),

    dict(class_name='com.nokia.srbts.nrbts:PDCCH',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1',
         p_name='alSelection', value='static'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1',
         p_name='dciDedicatedAggregationLevel', value='AL4'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1',
         p_name='dciPagingAggregationLevel', value='AL4'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1',
         p_name='dciRaCompletionAggregationLevel', value='AL4'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1',
         p_name='dciRaMsg2AggregationLevel', value='AL4'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1',
         p_name='dciSiAggregationLevel', value='AL4'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1',
         p_name='downgradeAL16toAL8', value='notAllowed'),

    dict(class_name='com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1/PDCCH_CONFIG_COMMON-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         list_name='searchSpaceCommon', elements={
            "coresetId": '0',
            "dciFormat": 'formats0-0-And-1-0',
            "duration": '1',
            "monitoringSymbolWithinSlot": 'symbol_0_1',
            "numOfPdcchCandidatesInAL16": 'n0',
            "numOfPdcchCandidatesInAL2": 'n4',
            "numOfPdcchCandidatesInAL4": 'n2',
            "numOfPdcchCandidatesInAL8": 'n0',
            "periodicity": 'sl1',
            "searchSpaceId": '1',
            "searchSpaceType": 'Type1',
            "slotOffset": '0'}),

    dict(class_name='com.nokia.srbts.nrbts:PDCCH_CONFIG_DEDICATED',
         version='NRBTSCL5G21B_2105_101', opertion='create',
         dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1/PDCCH_CONFIG_DEDICATED-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         list_name='coresetDedicated',
         elements={"cceToRegMapping": 'nonInterleaved',
                   "coresetId": '1',
                   "cRbStart": '0',
                   "duration": '1',
                   "interleaverSize": 'none',
                   "regBundleSize": 'n6',
                   "size": '120'}),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         list_name='searchSpaceDedicated',
         elements={"coresetId": '0',
                   "dciFormat": 'formats0-0-And-1-0',
                   "duration": '1',
                   "monitoringSymbolWithinSlot": 'symbol_0_1',
                   "numOfPdcchCandidatesInAL1": 'n0',
                   "numOfPdcchCandidatesInAL16": 'n0',
                   "numOfPdcchCandidatesInAL2": 'n0',
                   "numOfPdcchCandidatesInAL4": 'n2',
                   "numOfPdcchCandidatesInAL8": 'n0',
                   "periodicity": 'sl1',
                   "searchSpaceId": '2',
                   "searchSpaceType": 'Type3',
                   "slotOffset": '0'}),
    dict(dist_name=MR_NR_BTS_NAME + '/BWP_PROFILE-42/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         list_name='searchSpaceDedicated',
         elements={"coresetId": '1',
                   "dciFormat": 'formats0-1-And-1-1',
                   "duration": '1',
                   "monitoringSymbolWithinSlot": 'symbol_0_1',
                   "numOfPdcchCandidatesInAL1": 'n0',
                   "numOfPdcchCandidatesInAL16": 'n0',
                   "numOfPdcchCandidatesInAL2": 'n0',
                   "numOfPdcchCandidatesInAL4": 'n5',
                   "numOfPdcchCandidatesInAL8": 'n0',
                   "periodicity": 'sl1',
                   "searchSpaceId": '3',
                   "searchSpaceType": 'UE-Specific',
                   "slotOffset": '0'}),
]
PARAMS_TO_MODIFY_40M_50M = [
    dict(
        value='40MHz',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        p_name='chBw'),
    dict(
        value='50MHz',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        p_name='chBw')
]

PARAMS_TO_ADD_FOR_7464 = PARAMS_TO_ADD_CHANNEL_B + PARAMS_TO_ADD_BWP_PROFILE41_FOR_7464 +\
                         PARAMS_TO_ADD_BWP_PROFILE42_FOR_7464

PARAMS_TO_MODIFY_FOR_7464 = [

    dict(value=MR_NR_BTS_NAME + '/BWP_PROFILE-41', dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
         p_name='bwpDN', list_name='cellBwpList', index=1),

    dict(value=MR_NR_BTS_NAME + '/BWP_PROFILE-42', dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
         p_name='bwpDN', list_name='cellBwpList', index=1)
    ] + PARAMS_TO_MODIFY_40M_50M

PARAMS_TO_DELETE_FOR_7464 = PARAMS_TO_DELETE_CHANNEL + PARAMS_TO_DELETE_BWP_PROFILE44_FOR_7464
