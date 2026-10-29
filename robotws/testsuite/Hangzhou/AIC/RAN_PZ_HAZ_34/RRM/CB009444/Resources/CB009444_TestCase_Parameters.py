# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_GRP = MR_BTS_NAME + '/NRCELLGRP-1'
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELL_NAME_FDD = MR_NR_CELL_NAME + '/NRCELL_FDD-1'


MODIFY_SCF_CB009444_CU_01 = [
    dict(
        value='100MHz',
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw'),
]


MODIFY_SCF_CB009444_DU_01 = [
    dict(
        value='20MHz',
        dist_name=MR_NR_CELL_NAME_FDD,
        p_name='chBwDl'),
    dict(
        value='20MHz',
        dist_name=MR_NR_CELL_NAME_FDD,
        p_name='chBwUl'),
    dict(
        value='12',
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='pos3',
        dist_name=MR_NR_CELL_NAME,
        p_name='dmrsTypeAPosition'),
    dict(
        value='n64 ',
        dist_name=MR_NR_CELL_NAME,
        p_name='cbraPreamblesPerSsb'),
]
