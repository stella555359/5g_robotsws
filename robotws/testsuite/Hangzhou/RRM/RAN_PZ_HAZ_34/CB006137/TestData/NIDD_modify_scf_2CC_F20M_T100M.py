from NIDD_modify_scf import *
import logging

MODIFY_SCF_F20M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_F20M, list_cell_id=LIST_PCELL_ID,
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['FDD_20M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['FDD_20M']['dedicate'])

MODIFY_SCF_T100M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_T100M, list_cell_id=LIST_SCELL_ID,
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['TDD_1116_0_100M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['TDD_1116_0_100M']['dedicate'])

MODIFY_SCF_FRAME_STRUCTURE_1116_0 = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_1116_0, list_cell_id=LIST_SCELL_ID)

MODIFY_SCF_DEACT_UL256QAM = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_DEACT_UL256QAM, list_cell_id=ALL_CELLS)

MODIFY_SCF_DEFAULT = MODIFY_SCF_DEFAULT + MODIFY_SCF_F20M + MODIFY_SCF_T100M + \
                     MODIFY_SCF_FRAME_STRUCTURE_1116_0 + MODIFY_SCF_DEACT_UL256QAM
