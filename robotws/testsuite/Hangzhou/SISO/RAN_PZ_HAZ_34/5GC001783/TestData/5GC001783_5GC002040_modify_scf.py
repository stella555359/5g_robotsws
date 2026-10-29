from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

OBJECTS_ADD_4X4 = [
    dict(
        object_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1',
        object_class_name='CHANNEL',
        id_value='5'),
    dict(
        object_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1',
        object_class_name='CHANNEL',
        id_value='6')
]

PARAMS_MODIFY_4X4 = [
    dict(
        new_value='TX',
        filter_param='Direction of the channel',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5',
        abbr='direction'),
    dict(
        new_value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        filter_param='Distinguished Name of resource',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5',
        abbr='resourceDN'),
    dict(
        new_value='TX',
        filter_param='Direction of the channel',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6',
        abbr='direction'),
    dict(
        new_value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        filter_param='Distinguished Name of resource',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6',
        abbr='resourceDN'),
    dict(
        new_value='4DL2UL',
        filter_param='NR Cell type',
        dist_name=NR_BTS_NAME + '/NRCELL-1',
        abbr='nrCellType'),
    dict(
        new_value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        filter_param='Downlink MIMO Mode',
        dist_name=NR_BTS_NAME + '/NRCELL-1',
        abbr='dlMimoMode'),
    dict(
        new_value='true',
        filter_param='Activate Beamforming',
        dist_name=NR_BTS_NAME + '/NRCELL-1',
        abbr='actBeamforming'),
    dict(
        new_value='beamSet_2',
        filter_param='Basic Beam Set',
        dist_name=NR_BTS_NAME + '/NRCELL-1',
        abbr='basicBeamSet'),
    dict(
        new_value='2 beams',
        filter_param='Number of transmitted Synchronization Signal Blocks',
        dist_name=NR_BTS_NAME + '/NRCELLGRP-0',
        abbr='numberOfTransmittedSsBlocks')
]
