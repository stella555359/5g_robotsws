# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MRBTS_ID = 'MRBTS-' + str(tl.gnbs[0].instance_id)
ENB_LNBTS_ID = MRBTS_ID + '/LNBTS-' + str(tl.enbs[0].instance_id)
ENB_CELL_ID = ENB_LNBTS_ID + '/LNCEL-'
FDD_NAME = '/LNCEL_FDD-0'

# modify parameter
gnb_para1 = [dict(dist_name=ENB_CELL_ID + '1' + FDD_NAME, parameter='dlChBw', value='10 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '1' + FDD_NAME, parameter='ulChBw', value='10 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '2' + FDD_NAME, parameter='dlChBw', value='10 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '2' + FDD_NAME, parameter='ulChBw', value='10 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '3' + FDD_NAME, parameter='dlChBw', value='10 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '3' + FDD_NAME, parameter='ulChBw', value='10 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '4' + FDD_NAME, parameter='dlChBw', value='10 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '4' + FDD_NAME, parameter='ulChBw', value='10 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '5' + FDD_NAME, parameter='dlChBw', value='15 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '5' + FDD_NAME, parameter='ulChBw', value='15 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '6' + FDD_NAME, parameter='dlChBw', value='15 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '6' + FDD_NAME, parameter='ulChBw', value='15 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '7' + FDD_NAME, parameter='dlChBw', value='15 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '7' + FDD_NAME, parameter='ulChBw', value='15 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '8' + FDD_NAME, parameter='dlChBw', value='15 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '8' + FDD_NAME, parameter='ulChBw', value='15 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '1', parameter='actDownSampling', value='false', operation='update'),
             dict(dist_name=ENB_CELL_ID + '2', parameter='actDownSampling', value='false', operation='update'),
             dict(dist_name=ENB_CELL_ID + '3', parameter='actDownSampling', value='false', operation='update'),
             dict(dist_name=ENB_CELL_ID + '4', parameter='actDownSampling', value='false', operation='update'),
             dict(dist_name=ENB_CELL_ID + '5', parameter='actDownSampling', value='false', operation='update'),
             dict(dist_name=ENB_CELL_ID + '6', parameter='actDownSampling', value='false', operation='update'),
             dict(dist_name=ENB_CELL_ID + '7', parameter='actDownSampling', value='false', operation='update'),
             dict(dist_name=ENB_CELL_ID + '8', parameter='actDownSampling', value='false', operation='update')
             ]

gnb_para2 = [dict(dist_name=ENB_CELL_ID + '1' + FDD_NAME, parameter='dlChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '1' + FDD_NAME, parameter='ulChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '2' + FDD_NAME, parameter='dlChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '2' + FDD_NAME, parameter='ulChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '3' + FDD_NAME, parameter='dlChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '3' + FDD_NAME, parameter='ulChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '4' + FDD_NAME, parameter='dlChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '4' + FDD_NAME, parameter='ulChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '5' + FDD_NAME, parameter='dlChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '5' + FDD_NAME, parameter='ulChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '6' + FDD_NAME, parameter='dlChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '6' + FDD_NAME, parameter='ulChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '7' + FDD_NAME, parameter='dlChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '7' + FDD_NAME, parameter='ulChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '8' + FDD_NAME, parameter='dlChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '8' + FDD_NAME, parameter='ulChBw', value='20 MHz', operation='update'),
             dict(dist_name=ENB_CELL_ID + '1', parameter='actDownSampling', value='true', operation='update'),
             dict(dist_name=ENB_CELL_ID + '2', parameter='actDownSampling', value='true', operation='update'),
             dict(dist_name=ENB_CELL_ID + '3', parameter='actDownSampling', value='true', operation='update'),
             dict(dist_name=ENB_CELL_ID + '4', parameter='actDownSampling', value='true', operation='update'),
             dict(dist_name=ENB_CELL_ID + '5', parameter='actDownSampling', value='true', operation='update'),
             dict(dist_name=ENB_CELL_ID + '6', parameter='actDownSampling', value='true', operation='update'),
             dict(dist_name=ENB_CELL_ID + '7', parameter='actDownSampling', value='true', operation='update'),
             dict(dist_name=ENB_CELL_ID + '8', parameter='actDownSampling', value='true', operation='update')
             ]
