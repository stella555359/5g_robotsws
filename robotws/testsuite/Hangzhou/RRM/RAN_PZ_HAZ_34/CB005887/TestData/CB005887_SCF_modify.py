from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
CHANNEL_NAME = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1'


Deactive_1120_NIDD_para_disabled_CA = [
    dict(
        value='false',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        parameter='actTddPrePooling'),
    dict(
        value='false',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        parameter='actCarrierAggregation'),
    dict(
        value='none',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        parameter='caConfigurationSupport'),
]
Active_1120_NIDD_para = [
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        parameter='actTddPrePooling'),
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        parameter='actCarrierAggregation'),
    dict(
        value='8CCDL_4CC UL',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        parameter='caConfigurationSupport'),
]

modify_set_maxNumScellsUl_2 = [
    dict(
        value='2',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        parameter='maxNumScellsUl')
]

modify_set_maxNumScellsUl_3 = [
    dict(
        value='3',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        parameter='maxNumScellsUl')
]

PARAMS_TO_MODIFY_FOR_CA = [
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        p_name='actCarrierAggregation'),
    dict(
        value='8CCDL_4CC UL',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        p_name='caConfigurationSupport'),
    dict(
        value='5min',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRPMRNL-1',
        p_name='miNrCaCu'),
    dict(
        value='5min',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1' + '/MNLENT-1' + '/PMCADM-1',
        p_name='reportingIntervalPm')
]


ABIO_DEL = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-11'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-12'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-13'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-14'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', index='-1')
]
ABIL_4CELL_DEL = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-7'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-8'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-1/CHANNEL-2')

]

CASE_ABIL_4CC = ABIO_DEL + ABIL_4CELL_DEL
