from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)


MODIFY_ENB_VIA_API_P1 = [
    dict(
        value='1',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/LNBTS-' + str(tl.gnbs[0].global_bts_id) + '/LNCEL-1',
        parameter='defaultLnRelGnbCellId')
]

MODIFY_ENB_VIA_API_P2 = [
    dict(
        value='2',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/LNBTS-' + str(tl.gnbs[0].global_bts_id) + '/LNCEL-1',
        parameter='defaultLnRelGnbCellId')
]

MODIFY_ENB_VIA_API_P2_enb = [
    dict(
        value='2',
        dist_name='MRBTS-' + str(tl.enbs[0].instance_id) + '/LNBTS-' + str(tl.enbs[0].instance_id) + '/LNCEL-1',
        parameter='defaultLnRelGnbCellId')
]

MODIFY_ENB_VIA_API_P1_enb = [
    dict(
        value='1',
        dist_name='MRBTS-' + str(tl.enbs[0].instance_id) + '/LNBTS-' + str(tl.enbs[0].instance_id) + '/LNCEL-1',
        parameter='defaultLnRelGnbCellId')
]

MODIFY_tmp = [
    # dict(
    #     value='2',
    #     dist_name='MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id) + '/NRCELL-1',
    #     p_name='maxNumOfUsersPercell'),
    # dict(
    #     value='2',
    #     dist_name='MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id) + '/NRCELL-2',
    #     p_name='maxNumOfUsersPercell'),
    # dict(
    #     value='50',
    #     dist_name='MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id) + '/NRCELL-1',
    #     p_name='ccLoadThreshold'),
    # dict(
    #     value='50',
    #     dist_name='MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id) + '/NRCELL-2',
    #     p_name='ccLoadThreshold'),
    # dict(
    #     value='2',
    #     dist_name='MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id) + '/NRCELL-1',
    #     p_name='maxNumOfSCellAlloc'),
    # dict(
    #     value='2',
    #     dist_name='MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id) + '/NRCELL-2',
    #     p_name='maxNumOfSCellAlloc')
]
