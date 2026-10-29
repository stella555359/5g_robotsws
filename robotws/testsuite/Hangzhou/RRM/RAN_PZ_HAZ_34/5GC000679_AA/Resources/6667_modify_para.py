import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

MR_NR_BWP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/BWP_PROFILE-64' + '/PDCCH-1' + '/PDCCH_CONFIG_DEDICATED-1'

PARAMS_TO_MODIFY_100MHz = [
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='config1', dist_name=MR_NR_NAME, p_name='pdschRat0RbgConfig'),
    dict(value='225', dist_name=MR_NR_CELL_NAME, p_name='reqMinNumPuschPrb'),
    dict(value='270', dist_name=MR_NR_BWP_NAME, p_name='size'),
]

PARAMS_TO_MODIFY_90MHz = [
    dict(value='90MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='config2', dist_name=MR_NR_NAME, p_name='pdschRat0RbgConfig'),
    dict(value='197', dist_name=MR_NR_CELL_NAME, p_name='reqMinNumPuschPrb'),
    dict(value='240', dist_name=MR_NR_BWP_NAME, p_name='size'),
]

PARAMS_TO_MODIFY_80MHz = [
    dict(value='80MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='config2', dist_name=MR_NR_NAME, p_name='pdschRat0RbgConfig'),
    dict(value='169', dist_name=MR_NR_CELL_NAME, p_name='reqMinNumPuschPrb'),
    dict(value='216', dist_name=MR_NR_BWP_NAME, p_name='size'),
]

PARAMS_TO_MODIFY_60MHz = [
    dict(value='60MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='config2', dist_name=MR_NR_NAME, p_name='pdschRat0RbgConfig'),
    dict(value='124', dist_name=MR_NR_CELL_NAME, p_name='reqMinNumPuschPrb'),
    dict(value='162', dist_name=MR_NR_BWP_NAME, p_name='size'),
]

PARAMS_TO_MODIFY_50MHz = [
    dict(value='50MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='config2', dist_name=MR_NR_NAME, p_name='pdschRat0RbgConfig'),
    dict(value='101', dist_name=MR_NR_CELL_NAME, p_name='reqMinNumPuschPrb'),
    dict(value='132', dist_name=MR_NR_BWP_NAME, p_name='size'),
]

PARAMS_TO_MODIFY_40MHz = [
    dict(value='40MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='config2', dist_name=MR_NR_NAME, p_name='pdschRat0RbgConfig'),
    dict(value='82', dist_name=MR_NR_CELL_NAME, p_name='reqMinNumPuschPrb'),
    dict(value='102', dist_name=MR_NR_BWP_NAME, p_name='size'),
]

PARAMS_TO_MODIFY_20MHz = [
    dict(value='20MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='config2', dist_name=MR_NR_NAME, p_name='pdschRat0RbgConfig'),
    dict(value='37', dist_name=MR_NR_CELL_NAME, p_name='reqMinNumPuschPrb'),
    dict(value='48', dist_name=MR_NR_BWP_NAME, p_name='size'),
]


def Remove_repetition_list(list1):
    list1 = set(list1)
    return list1
