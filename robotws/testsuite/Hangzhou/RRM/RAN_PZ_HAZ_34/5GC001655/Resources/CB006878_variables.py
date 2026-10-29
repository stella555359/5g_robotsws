import os
import sys
from py_script import *
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
sys.path.append("${}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
scf_file = BuiltIn().get_variable_value("${_scf_file_path}")
cell_t = get_item_from_scf(scf_file, "MRBTS-(\\d*)/NRBTS-(\\d*)/NRCELL-(\\d*)")
cellgrp_t = get_item_from_scf(scf_file, "MRBTS-(\\d*)/NRBTS-(\\d*)/NRCELLGRP-(\\d*)")
cell = remove_dup_value_in_list(cell_t)
cellgrp = remove_dup_value_in_list(cellgrp_t)
cell_num = len(cell)
cellgrp_num = len(cellgrp)
for index in range(cell_num):
    MR_NR_CELL_NAME = (
        "MRBTS-"
        + cell[index][0]
        + "/NRBTS-"
        + cell[index][1]
        + "/NRCELL-"
        + cell[index][2]
    )
    exec("MR_NR_CELL_NAME_{} = MR_NR_CELL_NAME".format(index))
for index in range(cellgrp_num):
    MR_NR_CELLGRP_NAME = (
        "MRBTS-"
        + cellgrp[index][0]
        + "/NRBTS-"
        + cellgrp[index][1]
        + "/NRCELL-"
        + cellgrp[index][2]
    )
    exec("MR_NR_CELLGRP_NAME_{} = MR_NR_CELLGRP_NAME".format(index))

MODIFY_6878_TRUE = [
    dict(
        new_value="true",
        dist_name=MR_NR_CELL_NAME_0,
        filter_param="Activate dynamic UL resource allocation",
        abbr="actDynUlResAlloc",
    ),
    dict(
        new_value="true",
        dist_name=MR_NR_CELL_NAME_1,
        filter_param="Activate dynamic UL resource allocation",
        abbr="actDynUlResAlloc",
    ),
]
