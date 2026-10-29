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
LCELNR1 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1'
LCELNR2 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'
LCELNR3 = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3'


frame_structure_list_100MHz_40MHz_40MHz = [
    {
        'cellid': 1,
        'band': '100',
        'prach_index': '98',
        'dl_ul_layer': '16DL8UL',
        'dl_data_transfer': '1600M',
        'expect_dl_tput': '1400',
        'ul_data_transfer': '240M',
        'expect_ul_tput': '189'
    },
    {
        'cellid': 2,
        'band': '40',
        'prach_index': '98',
        'dl_ul_layer': '8DL4UL',
        'dl_data_transfer': '600M',
        'expect_dl_tput': '510',
        'ul_data_transfer': '95M',
        'expect_ul_tput': '75'
    },
    {
        'cellid': 3,
        'band': '40',
        'prach_index': '98',
        'dl_ul_layer': '8DL4UL',
        'dl_data_transfer': '600M',
        'expect_dl_tput': '510',
        'ul_data_transfer': '95M',
        'expect_ul_tput': '70'
    }
]

frame_structure_list_100MHz_50MHz_40MHz = [
    {
        'cellid': 1,
        'band': '100',
        'prach_index': '98',
        'dl_ul_layer': '16DL8UL',
        'dl_data_transfer': '1600M',
        'expect_dl_tput': '1400',
        'ul_data_transfer': '240M',
        'expect_ul_tput': '189'
    },
    {
        'cellid': 2,
        'band': '50',
        'prach_index': '98',
        'dl_ul_layer': '16DL8UL',
        'dl_data_transfer': '600M',
        'expect_dl_tput': '510',
        'ul_data_transfer': '95M',
        'expect_ul_tput': '85'
    },
    {
        'cellid': 3,
        'band': '40',
        'prach_index': '98',
        'dl_ul_layer': '16DL8UL',
        'dl_data_transfer': '600M',
        'expect_dl_tput': '510',
        'ul_data_transfer': '95M',
        'expect_ul_tput': '68'
    }
]

frame_structure_list_100MHz_20MHz = [
    {
        'cellid': 1,
        'band': '100',
        'prach_index': '98',
        'dl_ul_layer': '8DL8UL',
        'dl_data_transfer': '1600M',
        'expect_dl_tput': '1400',
        'ul_data_transfer': '240M',
        'expect_ul_tput': '189'
    },
    {
        'cellid': 2,
        'band': '20',
        'prach_index': '98',
        'dl_ul_layer': '8DL8UL',
        'dl_data_transfer': '600M',
        'expect_dl_tput': '510',
        'ul_data_transfer': '95M',
        'expect_ul_tput': '85'
    }
]

PARAMS_TO_DELETE_FOR_3SECTOR_3CC_8DL_8UL = [
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-3/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-3/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-3/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-3/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-4/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-4/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-4/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-4/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-3/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-3/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-3/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-3/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-4/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-4/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-4/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-4/CHANNEL-4')
]

PARAMS_TO_MODIFY_FOR_3SECTOR_3CC_8DL_8UL = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrCellType',
        value='8DL8UL'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrCellType',
        value='8DL8UL'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrCellType',
        value='8DL8UL'),
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        p_name='nrCellType',
        value='8DL8UL'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrCellType',
        value='8DL8UL'),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        p_name='nrCellType',
        value='8DL8UL'),
    dict(
        dist_name=MR_NR_CELL_7_NAME,
        p_name='nrCellType',
        value='8DL8UL'),
    dict(
        dist_name=MR_NR_CELL_8_NAME,
        p_name='nrCellType',
        value='8DL8UL'),
    dict(
        dist_name=MR_NR_CELL_9_NAME,
        p_name='nrCellType',
        value='8DL8UL')
]
