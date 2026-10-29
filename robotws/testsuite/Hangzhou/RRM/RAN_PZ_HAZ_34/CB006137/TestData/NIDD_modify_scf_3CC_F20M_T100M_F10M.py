from NIDD_modify_scf import *
import logging

# Cell mapping relationship
# FDD Cell 0 <--> NRCELL-2  20MHz <--> AHLOA
# TDD Cell 0 <--> NRCELL-1 100MHz <--> AEHC
# FDD Cell 1 <--> NRCELL-3  10MHz <--> AWHHG

MODIFY_SCF_F20M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_F20M, list_cell_id=LIST_PCELL_ID,
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['FDD_20M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['FDD_20M']['dedicate'])

MODIFY_SCF_F10M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_F10M, list_cell_id=[FDD_CELLS[1]],
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['FDD_10M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['FDD_10M']['dedicate'])

MODIFY_SCF_T100M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_T100M, list_cell_id=[TDD_CELLS[0]],
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['TDD_1116_0_100M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['TDD_1116_0_100M']['dedicate'])

MODIFY_SCF_FRAME_STRUCTURE_1116_0 = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_1116_0, list_cell_id=TDD_CELLS)
MODIFY_SCF_FRAME_STRUCTURE_1070 = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_1070, list_cell_id=TDD_CELLS)

MODIFY_SCF_DEACT_UL256QAM = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_DEACT_UL256QAM, list_cell_id=ALL_CELLS)

MODIFY_SCF_DEFAULT = MODIFY_SCF_DEFAULT_CAMODE_NUM + MODIFY_SCF_F20M + MODIFY_SCF_T100M + \
                     MODIFY_SCF_FRAME_STRUCTURE_1116_0 + MODIFY_SCF_DEACT_UL256QAM + \
                     MODIFY_SCF_F10M
