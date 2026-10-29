# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'

ATTENUATION_VALUE_8955_02_01 = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
}

ATTENUATION_VALUE_8955_02_02 = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
}

ATTENUATION_VALUE_8955_02_03 = {
    'atten_value_of_port0': 40,
    'atten_value_of_port1': 40,
    'atten_value_of_port2': 40,
    'atten_value_of_port3': 40,
}

ATTENUATION_VALUE_cell2_8955 = {
    'atten_value_of_port0': 127,
    'atten_value_of_port1': 127,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
}
