from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NRCELL_ID = MR_NR_BTS_NAME + '/NRCELL'


MODIFY_721_SCF = [
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

cell_id_list = [1, 2, 3, 4, 5, 6, 7, 8]

value_list1 = [2, 2, 2, 2, 2, 2, 2, 2]

value_list2 = [30, 50, 30, 30, 30, 30, 30, 30]
