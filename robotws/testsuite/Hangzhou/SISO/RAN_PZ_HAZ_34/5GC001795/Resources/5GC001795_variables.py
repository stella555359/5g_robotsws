import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# SCF parameters to modify
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
HWTOP_DIR = MR_BTS_NAME + '/EQM-1/HWTOP-1'
MR_NR_CELL_1_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELL_2_NAME = MR_NR_BTS_NAME + '/NRCELL-2'
LCELNR1_CHANNELGROUP2_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2'
LCELNR2_CHANNELGROUP2_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2'
LCELNR1_CHANNELGROUP1_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1'
LCELNR2_CHANNELGROUP1_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1'
CHANNELGROUP2_ETHSVC_ETHIF = MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-4'
CHANNELGROUP2_ETHSVC_ETHIF_VLAN = MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-4/VLANIF-1'
CHANNELGROUP2_ETHSVC_ETHLK = MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-3'

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
LIST_TO_ADD_2_CEll_1116_3MS_FOR_AWHQE = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='6Symbols',
            lteToNrFrameShift='3ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='2/8')),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='6Symbols',
            lteToNrFrameShift='3ms',
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

PARAMS_TO_MODIFY_2_CEll_1116_3MS_FOR_AWHQE = [
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='prachConfigurationIndex',
        value='98'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='prachConfigurationIndex',
        value='98'),
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='lteToNrTimeOffset',
        value='80'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='lteToNrTimeOffset',
        value='80')
]

PARAMS_TO_DELETE_FOR_4x2_2CC = [
    dict(dist_name=HWTOP_DIR + '/CABLINK-3'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-5'),
    dict(dist_name=LCELNR1_CHANNELGROUP2_DIR + '/CHANNEL-6'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-1'),
    dict(dist_name=LCELNR2_CHANNELGROUP1_DIR + '/CHANNEL-7'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-3'),
    dict(dist_name=LCELNR2_CHANNELGROUP1_DIR + '/CHANNEL-8'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-5'),
    dict(dist_name=LCELNR2_CHANNELGROUP2_DIR + '/CHANNEL-6'),
    dict(dist_name=CHANNELGROUP2_ETHSVC_ETHIF),
    dict(dist_name=CHANNELGROUP2_ETHSVC_ETHIF_VLAN),
    dict(dist_name=CHANNELGROUP2_ETHSVC_ETHLK),
]

PARAMS_TO_MODIFY_FOR_4x2_2CC = [
    dict(
        value='2Rx',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='2Rx',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrCellType',
        value='4DL2UL'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrCellType',
        value='4DL2UL')
]
