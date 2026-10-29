import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# SCF parameters to modify
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_1_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELL_2_NAME = MR_NR_BTS_NAME + '/NRCELL-2'
MR_NR_CELL_3_NAME = MR_NR_BTS_NAME + '/NRCELL-3'
MR_NR_CELL_4_NAME = MR_NR_BTS_NAME + '/NRCELL-4'
MR_NR_CELL_5_NAME = MR_NR_BTS_NAME + '/NRCELL-5'
MR_NR_CELL_6_NAME = MR_NR_BTS_NAME + '/NRCELL-6'
MR_NR_CELL_7_NAME = MR_NR_BTS_NAME + '/NRCELL-7'
MR_NR_CELL_8_NAME = MR_NR_BTS_NAME + '/NRCELL-8'
MR_NR_CELL_9_NAME = MR_NR_BTS_NAME + '/NRCELL-9'
HWTOP_DIR = MR_BTS_NAME + '/EQM-1/HWTOP-1'
TNL_2_SVC_DIR = MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1'
TNL_3_SVC_DIR = MR_BTS_NAME + '/TNLSVC-1/TNL-3/ETHSVC-1'
TNL_4_SVC_DIR = MR_BTS_NAME + '/TNLSVC-1/TNL-4/ETHSVC-1'
TNL_5_SVC_DIR = MR_BTS_NAME + '/TNLSVC-1/TNL-5/ETHSVC-1'
TNL_6_SVC_DIR = MR_BTS_NAME + '/TNLSVC-1/TNL-6/ETHSVC-1'
TNL_7_SVC_DIR = MR_BTS_NAME + '/TNLSVC-1/TNL-7/ETHSVC-1'

TNL_5_TNL_DIR = MR_BTS_NAME + '/TNLSVC-1/TNL-5'
TNL_6_TNL_DIR = MR_BTS_NAME + '/TNLSVC-1/TNL-6'
TNL_7_TNL_DIR = MR_BTS_NAME + '/TNLSVC-1/TNL-7'

TNL_3_DIR = MR_BTS_NAME + '/TNLSVC-1/TNL-3'
TNL_4_DIR = MR_BTS_NAME + '/TNLSVC-1/TNL-4'
HWTOP_EQP_DIR = MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1'
HWTOP_EQP_RF_DIR = MR_BTS_NAME + '/EQM-1/APEQM-1'
SYNC_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/SYNC-2'
LCELNR1_CHANNELGROUP1_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1'
LCELNR1_CHANNELGROUP2_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2'
LCELNR2_CHANNELGROUP1_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1'
LCELNR2_CHANNELGROUP2_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2'
LCELNR3_CHANNELGROUP2_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2'
LCELNR4_CHANNELGROUP2_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2'
LCELNR5_CHANNELGROUP2_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5/CHANNELGROUP-2'
LCELNR6_CHANNELGROUP2_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6/CHANNELGROUP-2'
LCELNR7_CHANNELGROUP2_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-2'
LCELNR8_CHANNELGROUP2_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-2'
LCELNR9_CHANNELGROUP2_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-9/CHANNELGROUP-2'
LCELNR1 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1'
LCELNR2 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'
LCELNR3 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3'
LCELNR4 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4'
LCELNR5 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5'
LCELNR6 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6'
LCELNR7 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7'
LCELNR8 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8'
LCELNR9 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-9'


PARAMS_TO_DELETE_FOR_3SECTOR_2CC_8DL_4UL = [
    dict(dist_name=HWTOP_EQP_DIR + '/BBMOD-2'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-2'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-12'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-13'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-14'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-15'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-16'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-17'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-18'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-19'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-20'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHIF-3'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHLK-3'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHIF-3'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHLK-3'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=TNL_4_SVC_DIR + '/ETHIF-3'),
    dict(dist_name=TNL_4_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_4_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_4_SVC_DIR + '/ETHLK-3'),
    dict(dist_name=TNL_4_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_4_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR7),
    dict(dist_name=LCELNR8),
    dict(dist_name=LCELNR9),
    dict(dist_name=MR_NR_CELL_7_NAME),
    dict(dist_name=MR_NR_CELL_8_NAME),
    dict(dist_name=MR_NR_CELL_9_NAME),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-7'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-8'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', elements=['7', '8'])
]

PARAMS_TO_DELETE_FOR_3SECTOR_2CC_8DL_4UL_2_CAB = [
    dict(dist_name=HWTOP_EQP_DIR + '/BBMOD-2'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-2'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-15'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-16'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-17'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-18'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-19'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-20'),

    dict(dist_name=TNL_5_TNL_DIR),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHIF-4/VLANIF-1'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHIF-5/VLANIF-1'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=TNL_5_TNL_DIR + '/IPNO-1'),
    dict(dist_name=TNL_6_TNL_DIR),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHIF-4/VLANIF-1'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHIF-5/VLANIF-1'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=TNL_6_TNL_DIR + '/IPNO-1'),
    dict(dist_name=TNL_7_TNL_DIR),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHIF-4/VLANIF-1'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHIF-5/VLANIF-1'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=TNL_7_TNL_DIR + '/IPNO-1'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR7),
    dict(dist_name=LCELNR8),
    dict(dist_name=LCELNR9),
    dict(dist_name=MR_NR_CELL_7_NAME),
    dict(dist_name=MR_NR_CELL_8_NAME),
    dict(dist_name=MR_NR_CELL_9_NAME),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-7'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-8'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', elements=['7', '8'])
]

LISTS_TO_ADD_FOR_3SECTOR_2CC_8DL_4UL = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', elements=['0', '1', '2', '3', '4', '5'])
]

PARAMS_TO_MODIFY_FOR_3SECTOR_2CC_8DL_4UL = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrCellType',
        value='8DL4UL'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrCellType',
        value='8DL4UL'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrCellType',
        value='8DL4UL'),
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        p_name='nrCellType',
        value='8DL4UL'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrCellType',
        value='8DL4UL'),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        p_name='nrCellType',
        value='8DL4UL'),
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrarfcn',
        value='528000'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrarfcn',
        value='528000'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrarfcn',
        value='528000'),
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        p_name='nrarfcn',
        value='509202'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrarfcn',
        value='509202'),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        p_name='nrarfcn',
        value='509202'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        p_name='allowSlowPrbPoolingStatNdmSrs',
        value='false'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        p_name='actSpatialStreamPooling',
        value='true'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        p_name='actTddPrePooling',
        value='true')
]

PARAMS_TO_DELETE_FOR_3SECTOR_1CC_8DL_4UL = [
    dict(dist_name=HWTOP_EQP_DIR + '/BBMOD-2'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-2'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-12'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-13'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-14'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-15'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-16'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-17'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-18'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-19'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-20'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHIF-3'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHLK-3'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHIF-3'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHLK-3'),
    dict(dist_name=TNL_4_SVC_DIR + '/ETHIF-3'),
    dict(dist_name=TNL_4_SVC_DIR + '/ETHLK-3'),
    dict(dist_name=TNL_5_TNL_DIR),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHIF-4/VLANIF-1'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHIF-5/VLANIF-1'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_5_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=TNL_5_TNL_DIR + '/IPNO-1'),
    dict(dist_name=TNL_6_TNL_DIR),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHIF-4/VLANIF-1'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHIF-5/VLANIF-1'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_6_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=TNL_6_TNL_DIR + '/IPNO-1'),
    dict(dist_name=TNL_7_TNL_DIR),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHIF-4/VLANIF-1'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHIF-5/VLANIF-1'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_7_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=TNL_7_TNL_DIR + '/IPNO-1'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR4),
    dict(dist_name=LCELNR5),
    dict(dist_name=LCELNR6),
    dict(dist_name=LCELNR7),
    dict(dist_name=LCELNR8),
    dict(dist_name=LCELNR9),
    dict(dist_name=MR_NR_CELL_4_NAME),
    dict(dist_name=MR_NR_CELL_5_NAME),
    dict(dist_name=MR_NR_CELL_6_NAME),
    dict(dist_name=MR_NR_CELL_7_NAME),
    dict(dist_name=MR_NR_CELL_8_NAME),
    dict(dist_name=MR_NR_CELL_9_NAME),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-3'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-4'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-5'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-7'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-8'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', elements=['7', '8'])
]

LISTS_TO_ADD_FOR_3SECTOR_1CC_8DL_4UL = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', elements=['0', '1', '2'])
]

PARAMS_TO_MODIFY_FOR_3SECTOR_1CC_8DL_4UL = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrCellType',
        value='8DL4UL'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrCellType',
        value='8DL4UL'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrCellType',
        value='8DL4UL'),
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrarfcn',
        value='528000'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrarfcn',
        value='528000'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrarfcn',
        value='528000'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        p_name='allowSlowPrbPoolingStatNdmSrs',
        value='false')
]

PARAMS_TO_DELETE_FOR_2SECTOR_1CC_8DL_4UL = [
    dict(dist_name=HWTOP_EQP_DIR + '/BBMOD-2'),
    dict(dist_name=HWTOP_EQP_RF_DIR + '/RMOD-3'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-2'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-11'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-12'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-13'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-14'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-15'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-16'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-17'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-18'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-19'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-20'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHIF-3'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHLK-3'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHIF-3'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHLK-3'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_3_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=TNL_4_DIR),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR3),
    dict(dist_name=LCELNR4),
    dict(dist_name=LCELNR5),
    dict(dist_name=LCELNR6),
    dict(dist_name=LCELNR7),
    dict(dist_name=LCELNR8),
    dict(dist_name=LCELNR9),
    dict(dist_name=MR_NR_CELL_3_NAME),
    dict(dist_name=MR_NR_CELL_4_NAME),
    dict(dist_name=MR_NR_CELL_5_NAME),
    dict(dist_name=MR_NR_CELL_6_NAME),
    dict(dist_name=MR_NR_CELL_7_NAME),
    dict(dist_name=MR_NR_CELL_8_NAME),
    dict(dist_name=MR_NR_CELL_9_NAME),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-2'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-3'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-4'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-5'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-7'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-8'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', elements=['7', '8']),
    dict(dist_name=SYNC_DIR, list_name='targetDNList', elements=['MRBTS-10107/EQM-1/APEQM-1/RMOD-3']),
]

LISTS_TO_ADD_FOR_2SECTOR_1CC_8DL_4UL = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', elements=['0', '1']),
    dict(dist_name=SYNC_DIR, list_name='targetDNList', elements=['MRBTS-10107/EQM-1/APEQM-1/RMOD-1']),
    dict(dist_name=SYNC_DIR, list_name='targetDNList', elements=['MRBTS-10107/EQM-1/APEQM-1/RMOD-2']),
]

PARAMS_TO_MODIFY_FOR_2SECTOR_1CC_8DL_4UL = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrCellType',
        value='8DL4UL'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrCellType',
        value='8DL4UL'),
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrarfcn',
        value='528000'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrarfcn',
        value='528000'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        p_name='allowSlowPrbPoolingStatNdmSrs',
        value='false')
]

PARAMS_TO_DELETE_FOR_1SECTOR_2CC_8DL_8UL = [
    dict(dist_name=HWTOP_EQP_DIR + '/BBMOD-2'),
    dict(dist_name=HWTOP_EQP_RF_DIR + '/RMOD-2'),
    dict(dist_name=HWTOP_EQP_RF_DIR + '/RMOD-3'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-2'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-7'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-11'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-12'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-13'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-14'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-15'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-16'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-17'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-18'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-19'),
    dict(dist_name=HWTOP_DIR + '/CABLINK-20'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHIF-3'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHIF-4'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHIF-5'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHLK-3'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHLK-4'),
    dict(dist_name=TNL_2_SVC_DIR + '/ETHLK-5'),
    dict(dist_name=TNL_3_DIR),
    dict(dist_name=TNL_4_DIR),
    dict(dist_name=LCELNR2),
    dict(dist_name=LCELNR3),
    dict(dist_name=LCELNR5),
    dict(dist_name=LCELNR6),
    dict(dist_name=LCELNR7),
    dict(dist_name=LCELNR8),
    dict(dist_name=LCELNR9),
    dict(dist_name=MR_NR_CELL_2_NAME),
    dict(dist_name=MR_NR_CELL_3_NAME),
    dict(dist_name=MR_NR_CELL_5_NAME),
    dict(dist_name=MR_NR_CELL_6_NAME),
    dict(dist_name=MR_NR_CELL_7_NAME),
    dict(dist_name=MR_NR_CELL_8_NAME),
    dict(dist_name=MR_NR_CELL_9_NAME),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-2'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-4'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-5'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-7'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-8'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', elements=['7', '8']),
    dict(dist_name=SYNC_DIR, list_name='targetDNList', elements=['MRBTS-10107/EQM-1/APEQM-1/RMOD-3']),
]

LISTS_TO_ADD_FOR_1SECTOR_2CC_8DL_8UL = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', elements=['0', '3']),
    dict(dist_name=SYNC_DIR, list_name='targetDNList', elements=['MRBTS-10107/EQM-1/APEQM-1/RMOD-1']),
]

PARAMS_TO_MODIFY_FOR_1SECTOR_2CC_8DL_8UL = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrarfcn',
        value='528000'),
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        p_name='nrarfcn',
        value='513600'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        p_name='allowSlowPrbPoolingStatNdmSrs',
        value='false')
]

PARAMS_TO_DELETE_2_CEll_FRAME_STRYECTURE = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        list_name='tddFrameStructure')]

LIST_TO_ADD_2_CEll_1116_0MS_FOR_AZGX = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='4Symbols',
            lteToNrFrameShift='0ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='2/8')),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='4Symbols',
            lteToNrFrameShift='0ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='2/8'))
]

PARAMS_TO_MODIFY_2_CEll_1116_0MS_FOR_AZGX = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='prachConfigurationIndex',
        value='96'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='prachConfigurationIndex',
        value='96')
]

PARAMS_TO_DELETE_FOR_2056 = [
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-4'),
]

PARAMS_TO_MODIFY_FOR_2056 = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrCellType',
        value='4DL4UL'),
]

UPDATE_ACTDL256QAM_PARAM = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        parameter='actDl256Qam',
        value='true'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        parameter='actDl256Qam',
        value='true'),
]

FRAME_TO_1208_80MHz_2Symbols = {
    'framestructure': '1208',
    'cell_chbw': {
        '1': '80MHz',
        '2': '80MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=98',
         'modify:NRCELL-2:prachConfigurationIndex=98',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_1208_20MHz_2Symbols = {
    'framestructure': '1208',
    'cell_chbw': {
        '1': '20MHz',
        '2': '20MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=98',
         'modify:NRCELL-2:prachConfigurationIndex=98',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=10',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=10',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_1208_50MHz_2Symbols = {
    'framestructure': '1208',
    'cell_chbw': {
        '1': '50MHz',
        '2': '50MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=98',
         'modify:NRCELL-2:prachConfigurationIndex=98',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_11163ms_80MHz_4Symbols = {
    'framestructure': '11163ms',
    'cell_chbw': {
        '1': '80MHz',
        '2': '80MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=98',
         'modify:NRCELL-2:prachConfigurationIndex=98',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_11163ms_20MHz_4Symbols = {
    'framestructure': '11163ms',
    'cell_chbw': {
        '1': '20MHz',
        '2': '20MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=98',
         'modify:NRCELL-2:prachConfigurationIndex=98',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=10',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=10',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_1070_80MHz_2Symbols = {
    'framestructure': '1070',
    'cell_chbw': {
        '1': '80MHz',
        '2': '80MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=98',
         'modify:NRCELL-2:prachConfigurationIndex=98',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=3/7']
}

FRAME_TO_1070_50MHz_2Symbols = {
    'framestructure': '1070',
    'cell_chbw': {
        '1': '50MHz',
        '2': '50MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=98',
         'modify:NRCELL-2:prachConfigurationIndex=98',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=3/7']
}

FRAME_TO_11160ms_40MHz_4Symbols = {
    'framestructure': '11160ms',
    'cell_chbw': {
        '1': '40MHz',
        '2': '40MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=96',
         'modify:NRCELL-2:prachConfigurationIndex=96',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_11160ms_60MHz_6Symbols_AAHF = {
    'framestructure': '11160ms',
    'cell_chbw': {
        '1': '60MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=158',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=2/8']
}

FRAME_TO_11160ms_60MHz_4Symbols = {
    'framestructure': '11160ms',
    'cell_chbw': {
        '1': '60MHz',
        '2': '60MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=96',
         'modify:NRCELL-2:prachConfigurationIndex=96',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_11160ms_60MHz_4Symbols_1CC = {
    'framestructure': {
        '1': '11160ms'},
    'cell_chbw': {
        '1': '60MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=156',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_11160ms_100MHz_4Symbols = {
    'framestructure': {
        '1': '11160ms'},
    'cell_chbw': {
        '1': '100MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=156',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_11160ms_40MHz_4Symbols_AEHC = {
    'framestructure': {
        '1': '11160ms'},
    'cell_chbw': {
        '1': '40MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=156',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_11160ms_20MHz_4Symbols_AEHC = {
    'framestructure': {
        '1': '11160ms'},
    'cell_chbw': {
        '1': '20MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=156',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=10',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_11160ms_60MHz_4Symbols_cell3 = {
    'framestructure': '11160ms',
    'cell_chbw': {
        '3': '60MHz',
        '4': '40MHz'},
    'case_level_params':
        ['modify:NRCELL-3:prachConfigurationIndex=156',
         'modify:NRCELL-4:prachConfigurationIndex=156',
         'modify:NRCELL-3:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-4:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-3:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-4:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-3:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_11160ms_60MHz_100MHz_4Symbols_AEHC_2CC = {
    'framestructure': {
        '1': '11160ms',
        '4': '11160ms'},
    'cell_chbw': {
        '1': '60MHz',
        '4': '100MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=156',
         'modify:NRCELL-4:prachConfigurationIndex=156',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-4:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-4:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-4:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

Mos_TO_ADD_Two_Channels = [
    dict(
        class_name='com.nokia.srbts.mnl:CHANNEL',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-9',
        version='MNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.mnl:CHANNEL',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-10',
        version='MNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.mnl:CHANNEL',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-11',
        version='MNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.mnl:CHANNEL',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-12',
        version='MNL22R4_2210_100')
]

PARAMS_TO_MODIFY_Two_Channels_actChannelMapVal_Warning = [
    dict(
        value='ShowAsWarning',
        dist_name=MR_NR_BTS_NAME,
        p_name='actChannelMapVal'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-9',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-9',
         p_name='resourceDN'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-10',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-10',
         p_name='resourceDN'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-11',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-11',
         p_name='resourceDN'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-12',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-12',
         p_name='resourceDN')
]

CNI81699_PARAMS_TO_DELETE_1CELL_ChannelGroup2 = [
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-4')
]

PARAMS_TO_MODIFY_Two_Channels_actChannelMapVal_Error = [
    dict(
        value='ShowAsError',
        dist_name=MR_NR_BTS_NAME,
        p_name='actChannelMapVal'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-9',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-9',
         p_name='resourceDN'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-10',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-10',
         p_name='resourceDN'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-11',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-11',
         p_name='resourceDN'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-12',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-12',
         p_name='resourceDN')
]

PARAMS_TO_MODIFY_Two_Channels_actChannelMapVal_Disabled = [
    dict(
        value='Disabled',
        dist_name=MR_NR_BTS_NAME,
        p_name='actChannelMapVal'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-9',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-9',
         p_name='resourceDN'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-10',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-10',
         p_name='resourceDN'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-11',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-11',
         p_name='resourceDN'),
    dict(
        value='TX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-12',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-12',
         p_name='resourceDN')
]

Mos_TO_ADD_FOR_100_90 = [
    dict(
        class_name='com.nokia.srbts.eqm:CABLINK',
        dist_name=MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-13',
        version='EQM22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:ETHIF',
        dist_name=MR_BTS_NAME+'/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5',
        version='TNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:VLANIF',
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5/VLANIF-1',
        version='TNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:ETHLK',
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        version='TNL22R4_2210_100'),
]

PARAMS_TO_MODIFY_FOR_100_90 = [
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='chBw',
        value='100MHz'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrarfcn',
        value='509400'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='chBw',
        value='90MHz'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrarfcn',
        value='528390'),
    dict(
        dist_name=MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-2'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointLabel',
        value='SFP'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointPortId',
        value='2'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='iqCompression',
        value='eCPRI IQ9_E7'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='linkSpeed',
        value='eCpri25'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='radioProtocolType',
        value='eCPRI'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-4'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointLabel',
        value='SFP'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointPortId',
        value='2'),
    dict(
        dist_name=MR_BTS_NAME+'/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5',
        p_name='linkSelectorDN',
        value=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5/VLANIF-1',
        p_name='vlanId',
        value='3'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        p_name='connectorLabel',
        value='S-RF2'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        p_name='modDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-2')
]

LIST_PARAMS_TO_MODIFY_FOR_100_90 = [
    dict(dist_name=MR_NR_CELL_3_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-76', index=1)]),
    dict(dist_name=MR_NR_CELL_5_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-76', index=1)])
]

PARAMS_TO_DELETE_FOR_1SECTOR_3CC_4DL_4UL = [
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR3_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-4'),
]

PARAMS_TO_MODIFY_FOR_1SECTOR_3CC_4DL_4UL = [
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        p_name='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrarfcn',
        value='522978'),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        p_name='nrarfcn',
        value='528546'),
]

Mos_TO_ADD_FOR_100_90SBTS22R4 = [
    dict(
        class_name='com.nokia.srbts.eqm:CABLINK',
        dist_name=MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-13',
        version='EQM22R4_2214_102'),
    dict(
        class_name='com.nokia.srbts.tnl:ETHIF',
        dist_name=MR_BTS_NAME+'/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5',
        version='TNL22R4_2214_102'),
    dict(
        class_name='com.nokia.srbts.tnl:VLANIF',
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5/VLANIF-3',
        version='TNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:ETHLK',
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        version='TNL22R4_2214_102'),
]

PARAMS_TO_MODIFY_FOR_100_90_SBTS22R4 = [
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='chBw',
        value='100MHz'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrarfcn',
        value='509400'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='chBw',
        value='90MHz'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrarfcn',
        value='528390'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        p_name='actSpatialStreamPooling',
        value='true'),
    dict(
        dist_name=MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-4'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointLabel',
        value='SFP'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointPortId',
        value='7'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='iqCompression',
        value='eCPRI IQ9_E7'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='linkSpeed',
        value='eCpri25'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='radioProtocolType',
        value='eCPRI'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-4'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointLabel',
        value='SFP'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointPortId',
        value='2'),
    dict(
        dist_name=MR_BTS_NAME+'/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5',
        p_name='linkSelectorDN',
        value=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5/VLANIF-3',
        p_name='vlanId',
        value='5'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        p_name='connectorLabel',
        value='S-RF7'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        p_name='modDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-4')
]

LIST_PARAMS_TO_MODIFY_FOR_100_90_SBTS22R4 = [
    dict(dist_name=MR_NR_CELL_3_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-75', index=1)]),
    dict(dist_name=MR_NR_CELL_5_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-75', index=1)])
]

Mos_TO_ADD_FOR_80_70 = [
    dict(
        class_name='com.nokia.srbts.eqm:CABLINK',
        dist_name=MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-13',
        version='EQM22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:ETHIF',
        dist_name=MR_BTS_NAME+'/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5',
        version='TNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:VLANIF',
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5/VLANIF-1',
        version='TNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:ETHLK',
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        version='TNL22R4_2210_100'),
]

PARAMS_TO_MODIFY_FOR_80_70 = [
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='chBw',
        value='80MHz'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrarfcn',
        value='509400'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='chBw',
        value='70 MHz'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrarfcn',
        value='528390'),
    dict(
        dist_name=MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-2'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointLabel',
        value='SFP'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointPortId',
        value='2'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='iqCompression',
        value='eCPRI IQ9_E7'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='linkSpeed',
        value='eCpri25'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='radioProtocolType',
        value='eCPRI'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-4'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointLabel',
        value='SFP'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointPortId',
        value='2'),
    dict(
        dist_name=MR_BTS_NAME+'/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5',
        p_name='linkSelectorDN',
        value=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5/VLANIF-1',
        p_name='vlanId',
        value='3'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        p_name='connectorLabel',
        value='S-RF2'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        p_name='modDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-2')
]

LIST_PARAMS_TO_MODIFY_FOR_80_70 = [
    dict(dist_name=MR_NR_CELL_3_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-76', index=1)]),
    dict(dist_name=MR_NR_CELL_5_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-76', index=1)])
]

PARAMS_TO_MODIFY_FOR_60_60 = [
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='chBw',
        value='60MHz'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='chBw',
        value='60MHz'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrarfcn',
        value='509400'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrarfcn',
        value='528390'),
]

LIST_PARAMS_TO_MODIFY_FOR_60_60 = [
    dict(dist_name=MR_NR_CELL_3_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-73', index=1)]),
    dict(dist_name=MR_NR_CELL_5_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-73', index=1)])
]

PARAMS_TO_MODIFY_FOR_60_60_60 = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='chBw',
        value='60MHz'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='chBw',
        value='60MHz'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='chBw',
        value='60MHz'),
]

LIST_PARAMS_TO_MODIFY_FOR_60_60_60 = [
    dict(dist_name=MR_NR_CELL_1_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-73', index=1)]),
    dict(dist_name=MR_NR_CELL_2_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-73', index=1)]),
    dict(dist_name=MR_NR_CELL_3_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-73', index=1)]),
    dict(dist_name=MR_NR_CELL_1_NAME, list_name='srsForBeamMgmt',
         elements=[dict(p_name='cSRS', value='42', index=0)]),
    dict(dist_name=MR_NR_CELL_2_NAME, list_name='srsForBeamMgmt',
         elements=[dict(p_name='cSRS', value='42', index=0)]),
    dict(dist_name=MR_NR_CELL_3_NAME, list_name='srsForBeamMgmt',
         elements=[dict(p_name='cSRS', value='42', index=0)])
]

FRAME_TO_1208_90MHz_2Symbols = {
    'framestructure': '1208',
    'cell_chbw': {
        '1': '90MHz',
        '2': '90MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=98',
         'modify:NRCELL-2:prachConfigurationIndex=98',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_11160ms_100MHz_4Symbols_AWHQE = {
    'framestructure': '11160ms',
    'cell_chbw': '100MHz',
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=156',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-2:prachConfigurationIndex=156',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_11160ms_60MHz_4Symbols_AWHQE = {
    'framestructure': '11160ms',
    'cell_chbw': '60MHz',
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=156',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-2:prachConfigurationIndex=156',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4']
}

FRAME_TO_1070_40MHz_2Symbols = {
    'framestructure': '1070',
    'cell_chbw': {
        '1': '40MHz',
        '2': '40MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=98',
         'modify:NRCELL-2:prachConfigurationIndex=98',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=2Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=3/7',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=3/7']
}

Mos_TO_ADD_FOR_80_70_23R1 = [
    dict(
        class_name='com.nokia.srbts.eqm:CABLINK',
        dist_name=MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-13',
        version='EQM22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:ETHIF',
        dist_name=MR_BTS_NAME+'/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5',
        version='TNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:VLANIF',
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5/VLANIF-3',
        version='TNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:ETHLK',
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        version='TNL22R4_2210_100'),
]

PARAMS_TO_MODIFY_FOR_80_70_23R1 = [
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='chBw',
        value='80MHz'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrarfcn',
        value='509400'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='chBw',
        value='70 MHz'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrarfcn',
        value='528390'),
    dict(
        dist_name=MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-4'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointLabel',
        value='SFP'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointPortId',
        value='7'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='iqCompression',
        value='eCPRI IQ9_E7'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='linkSpeed',
        value='eCpri25'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='radioProtocolType',
        value='eCPRI'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-4'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointLabel',
        value='SFP'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointPortId',
        value='2'),
    dict(
        dist_name=MR_BTS_NAME+'/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5',
        p_name='linkSelectorDN',
        value=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5/VLANIF-3',
        p_name='vlanId',
        value='5'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        p_name='connectorLabel',
        value='S-RF7'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        p_name='modDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-4')
]

LIST_PARAMS_TO_MODIFY_FOR_80_70_23R1 = [
    dict(dist_name=MR_NR_CELL_3_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-76', index=1)]),
    dict(dist_name=MR_NR_CELL_5_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-76', index=1)])
]

Mos_TO_ADD_Two_Channels_FOR_4D4U = [
    dict(
        class_name='com.nokia.srbts.mnl:CHANNEL',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-7',
        version='MNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.mnl:CHANNEL',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-8',
        version='MNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.mnl:CHANNEL',
        dist_name=LCELNR2_CHANNELGROUP1_DIR + '/CHANNEL-7',
        version='MNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.mnl:CHANNEL',
        dist_name=LCELNR2_CHANNELGROUP1_DIR + '/CHANNEL-8',
        version='MNL22R4_2210_100')
]

PARAMS_TO_MODIFY_Two_Channels_FOR_4D4U = [
    dict(value='true',
         dist_name=MR_NR_BTS_NAME,
         p_name='actTddPrePooling'),
    dict(value='4DL4UL',
         dist_name=MR_NR_CELL_1_NAME,
         p_name='nrCellType'),
    dict(value='4DL4UL',
         dist_name=MR_NR_CELL_2_NAME,
         p_name='nrCellType'),
    dict(
        value='RX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-7',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/ANTL-3',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-7',
         p_name='antlDN'),
    dict(
        value='RX',
        dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-8',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/ANTL-4',
         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-8',
         p_name='antlDN'),
    dict(
        value='RX',
        dist_name=LCELNR2_CHANNELGROUP1_DIR + '/CHANNEL-7',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-2/ANTL-3',
         dist_name=LCELNR2_CHANNELGROUP1_DIR + '/CHANNEL-7',
         p_name='antlDN'),
    dict(
        value='RX',
        dist_name=LCELNR2_CHANNELGROUP1_DIR + '/CHANNEL-8',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-2/ANTL-4',
         dist_name=LCELNR2_CHANNELGROUP1_DIR + '/CHANNEL-8',
         p_name='antlDN')
]

PARAMS_TO_DELETE_ALL_CEll_FRAME_STRYECTURE = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_7_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_8_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_9_NAME,
        list_name='tddFrameStructure')]

LIST_TO_ADD_ALL_CEll_1208_FRAME = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=MR_NR_CELL_7_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=MR_NR_CELL_8_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=MR_NR_CELL_9_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4'))
]

PARAMS_TO_MODIFY_ALL_1208_FRAME = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='prachConfigurationIndex',
        value='157'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='prachConfigurationIndex',
        value='157'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='prachConfigurationIndex',
        value='157'),
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        p_name='prachConfigurationIndex',
        value='157'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='prachConfigurationIndex',
        value='157'),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        p_name='prachConfigurationIndex',
        value='157'),
    dict(
        dist_name=MR_NR_CELL_7_NAME,
        p_name='prachConfigurationIndex',
        value='157'),
    dict(
        dist_name=MR_NR_CELL_8_NAME,
        p_name='prachConfigurationIndex',
        value='157'),
    dict(
        dist_name=MR_NR_CELL_9_NAME,
        p_name='prachConfigurationIndex',
        value='157')
]

LIST_PARAMS_TO_MODIFY_1208_FRAME = [
    dict(dist_name=MR_NR_CELL_1_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-5', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-57', index=1)]),
    dict(dist_name=MR_NR_CELL_2_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-5', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-56', index=1)]),
    dict(dist_name=MR_NR_CELL_3_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-5', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-55', index=1)]),
    dict(dist_name=MR_NR_CELL_4_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-5', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-51', index=1)]),
    dict(dist_name=MR_NR_CELL_5_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-5', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-52', index=1)]),
    dict(dist_name=MR_NR_CELL_6_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-5', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-58', index=1)]),
    dict(dist_name=MR_NR_CELL_7_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-5', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-50', index=1)]),
    dict(dist_name=MR_NR_CELL_8_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-2', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-20', index=1)]),
    dict(dist_name=MR_NR_CELL_9_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-5', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-50', index=1)]),
]

frame_structure_list_100MHz_40MHz_20MHz = [
    {
        'cellid': 1,
        'frame': '1116_0ms_GP1_A7',
        'band': '100',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL8UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '160M',
        'dl_data_transfer': '1650M',
        'expect_ul_tput': '125',
        'expect_dl_tput': '1400',
        'ul_data_transfer_SBTS00': '240M',
        'ul_data_transfer_SBTS25R1': '240M',
        'expect_ul_tput_SBTS00': '220',
        'expect_ul_tput_SBTS25R1': '220',
        'expect_dl_tput_SBTS00': '1543',
        'expect_dl_tput_SBTS25R1': '1543'
    },
    {
        'cellid': 4,
        'frame': '1116_0ms_GP1_A7',
        'band': '40',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL8UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '70M',
        'dl_data_transfer': '600M',
        'expect_ul_tput': '45',
        'expect_dl_tput': '510',
        'ul_data_transfer_SBTS00': '95M',
        'ul_data_transfer_SBTS25R1': '95M',
        'expect_ul_tput_SBTS00': '85',
        'expect_ul_tput_SBTS25R1': '85',
        'expect_dl_tput_SBTS00': '575',
        'expect_dl_tput_SBTS25R1': '575'
    },
    {
        'cellid': 7,
        'frame': '1116_0ms_GP1_A7',
        'band': '20',
        'prach_index': '156',
        'beamset': '4 beams',
        'dl_ul_layer': '8DL8UL',
        'dl_modulation': 'dl_256QAM',
        'ul_data_transfer': '50M',
        'dl_data_transfer': '500M',
        'expect_ul_tput': '20',
        'expect_dl_tput': '246',
        'ul_data_transfer_SBTS00': '50M',
        'ul_data_transfer_SBTS25R1': '50M',
        'expect_ul_tput_SBTS00': '37',
        'expect_ul_tput_SBTS25R1': '37',
        'expect_dl_tput_SBTS00': '257',
        'expect_dl_tput_SBTS25R1': '257'
    }
]

PARAMS_TO_MODIFY_FOR_100_80_80 = [
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        p_name='chBw',
        value='100MHz'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='chBw',
        value='80MHz'),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        p_name='chBw',
        value='80MHz'),
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        p_name='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        p_name='nrCellType',
        value='4DL4UL')
]

PARAMS_TO_DELETE_FOR_100_80_80 = [
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR5_CHANNELGROUP2_DIR + '/CHANNEL-4'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-2'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR6_CHANNELGROUP2_DIR + '/CHANNEL-4')
]

LIST_PARAMS_TO_MODIFY_FOR_100_80_80 = [
    dict(dist_name=MR_NR_CELL_4_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-75', index=1)]),
    dict(dist_name=MR_NR_CELL_5_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-75', index=1)]),
    dict(dist_name=MR_NR_CELL_6_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-75', index=1)])
]

Mos_TO_ADD_FOR_100_90_SBTS23R4 = [
    dict(
        class_name='com.nokia.srbts.eqm:CABLINK',
        dist_name=MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-13',
        version='EQM22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:ETHIF',
        dist_name=MR_BTS_NAME+'/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5',
        version='TNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:VLANIF',
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5/VLANIF-1',
        version='TNL22R4_2210_100'),
    dict(
        class_name='com.nokia.srbts.tnl:ETHLK',
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        version='TNL22R4_2210_100'),
]

PARAMS_TO_MODIFY_FOR_100_90_SBTS23R4 = [
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='chBw',
        value='100MHz'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrarfcn',
        value='509400'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='chBw',
        value='90MHz'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrarfcn',
        value='528390'),
    dict(
        dist_name=MR_BTS_NAME+'/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-5'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointLabel',
        value='SFP'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='firstEndpointPortId',
        value='2'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='iqCompression',
        value='eCPRI IQ9_E7'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='linkSpeed',
        value='eCpri25'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='radioProtocolType',
        value='eCPRI'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-4'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointLabel',
        value='SFP'),
    dict(
        dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-13',
        p_name='secondEndpointPortId',
        value='2'),
    dict(
        dist_name=MR_BTS_NAME+'/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5',
        p_name='linkSelectorDN',
        value=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-5/VLANIF-1',
        p_name='vlanId',
        value='3'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        p_name='connectorLabel',
        value='S-RF2'),
    dict(
        dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4',
        p_name='modDN',
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-5')
]

LIST_PARAMS_TO_MODIFY_FOR_100_90_SBTS23R4 = [
    dict(dist_name=MR_NR_CELL_3_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-76', index=1)]),
    dict(dist_name=MR_NR_CELL_5_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-7', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-76', index=1)])
]

UPDATE_PARAMS_1208_90M = [
    {'abbr': 'bwpDN',
     'dist_name': MR_NR_CELL_1_NAME,
     'filter_param': 'Bandwidth Part Profile distinguished name',
     'new_value': MR_NR_BTS_NAME+'/BWP_PROFILE-5',
     'node_index': 0},
    {'abbr': 'bwpDN',
     'dist_name': MR_NR_CELL_1_NAME,
     'filter_param': 'Bandwidth Part Profile distinguished name',
     'new_value': MR_NR_BTS_NAME+'/BWP_PROFILE-56',
     'node_index': 1},
    {'abbr': 'bwpDN',
     'dist_name': MR_NR_CELL_2_NAME,
     'filter_param': 'Bandwidth Part Profile distinguished name',
     'new_value': MR_NR_BTS_NAME+'/BWP_PROFILE-5',
     'node_index': 0},
    {'abbr': 'bwpDN',
     'dist_name': MR_NR_CELL_2_NAME,
     'filter_param': 'Bandwidth Part Profile distinguished name',
     'new_value': MR_NR_BTS_NAME+'/BWP_PROFILE-56',
     'node_index': 1},
    {'abbr': 'chBw',
     'dist_name': MR_NR_CELL_1_NAME,
     'filter_param': 'Channel bandwidth',
     'new_value': '90MHz'},
    {'abbr': 'chBw',
     'dist_name': MR_NR_CELL_2_NAME,
     'filter_param': 'Channel bandwidth',
     'new_value': '90MHz'},
    {'abbr': 'prachConfigurationIndex',
     'dist_name': MR_NR_CELL_1_NAME,
     'filter_param': 'PRACH configuration index',
     'new_value': '98'},
    {'abbr': 'prachConfigurationIndex',
     'dist_name': MR_NR_CELL_2_NAME,
     'filter_param': 'PRACH configuration index',
     'new_value': '98'},
    {'abbr': 'frameStructureType',
     'dist_name': MR_NR_CELL_1_NAME,
     'filter_param': 'Frame Structure Type',
     'new_value': 'semiStatic'},
    {'abbr': 'guardPeriodLength',
     'dist_name': MR_NR_CELL_1_NAME,
     'filter_param': 'Guard Period length',
     'new_value': '2Symbols'},
    {'abbr': 'ulDlDataSlotRatio',
     'dist_name': MR_NR_CELL_1_NAME,
     'filter_param': 'UL to DL logical data slot ratio',
     'new_value': '1/4'},
    {'abbr': 'lteToNrFrameShift',
     'dist_name': MR_NR_CELL_1_NAME,
     'filter_param': 'LTE to NR frame shift'},
    {'abbr': 'tdLteUlDlConfig',
     'dist_name': MR_NR_CELL_1_NAME,
     'filter_param': 'TDLTE UL-DL configuration'},
    {'abbr': 'frameStructureType',
     'dist_name': MR_NR_CELL_2_NAME,
     'filter_param': 'Frame Structure Type',
     'new_value': 'semiStatic'},
    {'abbr': 'guardPeriodLength',
     'dist_name': MR_NR_CELL_2_NAME,
     'filter_param': 'Guard Period length',
     'new_value': '2Symbols'},
    {'abbr': 'ulDlDataSlotRatio',
     'dist_name': MR_NR_CELL_2_NAME,
     'filter_param': 'UL to DL logical data slot ratio',
     'new_value': '1/4'},
    {'abbr': 'lteToNrFrameShift',
     'dist_name': MR_NR_CELL_2_NAME,
     'filter_param': 'LTE to NR frame shift'},
    {'abbr': 'tdLteUlDlConfig',
     'dist_name': MR_NR_CELL_2_NAME,
     'filter_param': 'TDLTE UL-DL configuration'},
    {'abbr': 'actFlexibleBISlotDurationMode',
     'dist_name': MR_NR_BTS_NAME,
     'filter_param': 'Activate flexible bidirectional slot duration mode',
     'new_value': 'disabled'},
    {'abbr': 'actIncUlPdcchCapacity',
     'dist_name': MR_NR_CELL_1_NAME,
     'filter_param': 'Activate PDCCH increased uplink capacity',
     'new_value': 'false'},
    {'abbr': 'actIncUlPdcchCapacity',
     'dist_name': MR_NR_CELL_2_NAME,
     'filter_param': 'Activate PDCCH increased uplink capacity',
     'new_value': 'false'}
]

PARAMS_TO_DELETE_FOR_CELL1_CELL4_16DL_4UL = [
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-5'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-6'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-5'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-6'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR4_CHANNELGROUP2_DIR + '/CHANNEL-8'),
]

PARAMS_TO_MODIFY_FOR_CELL1_CELL4_16DL_4UL = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrCellType',
        value='16DL4UL'),
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        p_name='nrCellType',
        value='16DL4UL'),
    dict(
        dist_name=MR_NR_CELL_1_NAME + '/NRULMUMIMO-0',
        p_name='ulMaxMuMimoLayer',
        value='2'),
    dict(
        dist_name=MR_NR_CELL_4_NAME + '/NRULMUMIMO-0',
        p_name='ulMaxMuMimoLayer',
        value='2'),
]

FRAME_TO_11160ms_60MHz_100MHz_4Symbols_AEHC_2CC_spark = {
    'framestructure': {
        '2': '11160ms',
        '5': '11160ms'},
    'cell_chbw': {
        '2': '60MHz',
        '5': '100MHz'},
    'case_level_params':
        ['modify:NRCELL-2:prachConfigurationIndex=156',
         'modify:NRCELL-5:prachConfigurationIndex=156',
         'modify:NRCELL-2:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-5:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-2:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-5:tddFrameStructure:guardPeriodLength=4Symbols',
         'modify:NRCELL-2:tddFrameStructure:ulDlDataSlotRatio=1/4',
         'modify:NRCELL-5:tddFrameStructure:ulDlDataSlotRatio=1/4']
}
