import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-1/NRCELL-1'


PARAMS_TO_MODIFY_SCF = [
    dict(value='522084', dist_name=MR_NR_CELL_NAME, p_name='nrarfcn')
]

PARAMS_TO_MODIFY_SCF_100MHZ = [
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw')
]

PARAMS_TO_MODIFY_SCF_80MHZ = [
    dict(value='80MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw')
]

PARAMS_TO_MODIFY_SCF_60MHZ = [
    dict(value='60MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw')
]
