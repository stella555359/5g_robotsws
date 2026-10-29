import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

SCF_MODIFY_COMMON = [
    dict(
        value='8',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ulMuMaxNumPairedUEs'),
    dict(
        value='8',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dlMuMaxNumPairedUEs'),
    dict(
        value='100MHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='chBw'),
    dict(
        value='false',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actDlMuMimo'),
    dict(
        value='false',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actUlMuMimo'),
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRDU-1',
        list_name='refNrCellGroup')
]

SCF_MODIFY_1541_A_2DL_2UL = SCF_MODIFY_COMMON + [
    dict(
        value='2x2 Closed Loop Spatial Multiplexing',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dlMimoMode'),
    dict(
        value='Closed loop Spatial Multiplexing (2x2)',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ulMimoMode'),
    dict(
        value='No additional DMRS',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dlDMRSAdditionalPosition'),
    dict(
        value='-120',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='initialPreambleReceivedTargetPower'),
    dict(
        value='2DL2UL',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='nrCellType'),
    dict(
        value='23',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='pMaxNROwnCell')

]

SCF_MODIFY_1541_C_4DL_2UL = SCF_MODIFY_COMMON + [
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dlMimoMode'),
    dict(
        value='Closed loop Spatial Multiplexing (2x2)',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ulMimoMode'),
    dict(
        value='One additional DMRS',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dlDMRSAdditionalPosition'),
    dict(
        value='-104',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='initialPreambleReceivedTargetPower'),
    dict(
        value='4DL2UL',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='nrCellType'),
    dict(
        value='20',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='pMaxNROwnCell')
]
