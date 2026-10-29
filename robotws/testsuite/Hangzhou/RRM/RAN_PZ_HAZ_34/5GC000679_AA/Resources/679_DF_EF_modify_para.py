import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

PARAMS_TO_MODIFY_Korea_conf_B = [
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='beamSet_4', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
]

PARAMS_TO_MODIFY_Korea_conf_A = [
    dict(value='80MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='beamSet_4', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
]


def Remove_repetition_list(list1):
    list1 = set(list1)
    return list1
