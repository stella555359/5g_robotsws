import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

PARAMS_TO_MODIFY_case1 = [
    dict(value='7200', dist_name=MR_NR_NAME, p_name='drbInactivityTimerSA'),
]

PARAMS_TO_MODIFY_case2 = [
    dict(value='7200', dist_name=MR_NR_NAME, p_name='drbInactivityTimerSA'),
]


def Remove_repetition_list(list1):
    list1 = set(list1)
    return list1
