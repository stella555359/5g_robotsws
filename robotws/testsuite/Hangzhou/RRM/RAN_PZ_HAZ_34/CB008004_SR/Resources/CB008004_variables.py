import os
import sys
from py_script import *
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
sys.path.append("${}/../../5GC001655/Resources")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
scf_file = BuiltIn().get_variable_value("${_scf_file_path}")
cell_t = get_item_from_scf(scf_file, "MRBTS-(\\d*)/NRBTS-(\\d*)/NRCELL-(\\d*)")
cellgrp_t = get_item_from_scf(scf_file, "MRBTS-(\\d*)/NRBTS-(\\d*)/NRCELLGRP-(\\d*)")
ltecell_t = get_item_from_scf(scf_file, "MRBTS-(\\d*)/LNBTS-(\\d*)/LNCEL-(\\d*)")
cell = list(set(cell_t))
cellgrp = list(set(cellgrp_t))
ltecell = remove_dup_value_in_list(ltecell_t)
cell_num = len(cell)
cellgrp_num = len(cellgrp)
ltecell_num = len(ltecell)
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
for index in range(ltecell_num):
    MR_LTE_CELL_NAME = (
        "MRBTS-"
        + ltecell[index][0]
        + "/LNBTS-"
        + ltecell[index][1]
        + "/LNCEL-"
        + ltecell[index][2]
    )
    exec("MR_LTE_CELL_NAME_{} = MR_LTE_CELL_NAME".format(index))

MR_MNL_FEAT = "MRBTS-" + cell[0][0] + "/MNL-1/MNLENT-1/FEATCADM-1"

MR_MNL_MNL_FEATCADM_NAME = (
    "MRBTS-" + str(tl.gnbs[0].global_bts_id) + "/MNL-1/MNLENT-1/FEATCADM-1"
    )

MODIFY_SCF_8004_case1_1 = [
    dict(
        abbr="actCellTimingOffset",
        dist_name=MR_MNL_MNL_FEATCADM_NAME,
        filter_param="Activate eCPRI cell timing offset",
        new_value="false",
    )
]

MODIFY_SCF_8004_case1_2 = [
    dict(
        abbr="actCellTimingOffset",
        dist_name=MR_MNL_MNL_FEATCADM_NAME,
        filter_param="Activate eCPRI cell timing offset",
        new_value="true",
    )
]

MODIFY_8004_STEP_1 = [
    dict(
        new_value="true",
        dist_name=MR_MNL_FEAT,
        filter_param="Activate eCPRI cell timing offset",
        abbr="actCellTimingOffset",
    ),
    dict(
        new_value="32767",
        dist_name=MR_NR_CELL_NAME_0,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="32767",
        dist_name=MR_LTE_CELL_NAME_0,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="32767",
        dist_name=MR_LTE_CELL_NAME_1,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="32767",
        dist_name=MR_LTE_CELL_NAME_2,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="9999.9995",
        dist_name=MR_NR_CELL_NAME_0,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="9999.9995",
        dist_name=MR_LTE_CELL_NAME_0,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="9999.9995",
        dist_name=MR_LTE_CELL_NAME_1,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="9999.9995",
        dist_name=MR_LTE_CELL_NAME_2,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
]

MODIFY_8004_STEP_2 = [
    dict(
        new_value="true",
        dist_name=MR_MNL_FEAT,
        filter_param="Activate eCPRI cell timing offset",
        abbr="actCellTimingOffset",
    ),
    dict(
        new_value="32767",
        dist_name=MR_NR_CELL_NAME_0,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="32767",
        dist_name=MR_LTE_CELL_NAME_0,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="32767",
        dist_name=MR_LTE_CELL_NAME_1,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="32767",
        dist_name=MR_LTE_CELL_NAME_2,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="0",
        dist_name=MR_NR_CELL_NAME_0,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="0",
        dist_name=MR_LTE_CELL_NAME_0,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="0",
        dist_name=MR_LTE_CELL_NAME_1,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="0",
        dist_name=MR_LTE_CELL_NAME_2,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
]

MODIFY_8004_STEP_3 = [
    dict(
        new_value="true",
        dist_name=MR_MNL_FEAT,
        filter_param="Activate eCPRI cell timing offset",
        abbr="actCellTimingOffset",
    ),
    dict(
        new_value="-32768",
        dist_name=MR_NR_CELL_NAME_0,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="-32768",
        dist_name=MR_LTE_CELL_NAME_0,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="-32768",
        dist_name=MR_LTE_CELL_NAME_1,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="-32768",
        dist_name=MR_LTE_CELL_NAME_2,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="0",
        dist_name=MR_NR_CELL_NAME_0,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="0",
        dist_name=MR_LTE_CELL_NAME_0,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="0",
        dist_name=MR_LTE_CELL_NAME_1,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="0",
        dist_name=MR_LTE_CELL_NAME_2,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
]

MODIFY_8004_STEP_4 = [
    dict(
        new_value="true",
        dist_name=MR_MNL_FEAT,
        filter_param="Activate eCPRI cell timing offset",
        abbr="actCellTimingOffset",
    ),
    dict(
        new_value="-32768",
        dist_name=MR_NR_CELL_NAME_0,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="-32768",
        dist_name=MR_LTE_CELL_NAME_0,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="-32768",
        dist_name=MR_LTE_CELL_NAME_1,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="-32768",
        dist_name=MR_LTE_CELL_NAME_2,
        filter_param="SFN offset",
        abbr="sfnOffset",
    ),
    dict(
        new_value="9999.9995",
        dist_name=MR_NR_CELL_NAME_0,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="9999.9995",
        dist_name=MR_LTE_CELL_NAME_0,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="9999.9995",
        dist_name=MR_LTE_CELL_NAME_1,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
    dict(
        new_value="9999.9995",
        dist_name=MR_LTE_CELL_NAME_2,
        filter_param="Frame start offset",
        abbr="frameStartOffset",
    ),
]
