import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = 'MRBTS-' + \
    str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

PARAMS_TO_MODIFY_L_01 = [
    dict(value='true', dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1' + '/MNLENT-1' +
         '/SYNC-1' + '/CLOCK-1', p_name='syncMaster'),
]

scell_id_list0 = ['50', '51', '52']
scell_id_list1 = ['50', '52', '53']
