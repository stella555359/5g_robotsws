import logging
from NIDD_modify_scf import *

# Cell mapping relationship
# TDD Cell 0 <--> NRCELL-1 100MHz <--> AEHC
# TDD Cell 2 <--> NRCELL-5 60MHz <--> AEHC
# TDD Cell 1 <--> NRCELL-4 60MHz <--> AWHHH
# FDD Cell 0 <--> NRCELL-2  20MHz <--> AHLOA
# FDD Cell 1 <--> NRCELL-3  10MHz <--> AHLOA


MODIFY_SCF_T100M_1070 = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_T100M_1070, list_cell_id=[TDD_CELLS[0]],
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['TDD_1070_100M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['TDD_1070_100M']['dedicate'])

MODIFY_SCF_T60M_1070 = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_T60M_1070, list_cell_id=[TDD_CELLS[2]],
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['TDD_1070_60M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['TDD_1070_60M']['dedicate'])


MODIFY_SCF_FRAME_STRUCTURE_1070 = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_1070, list_cell_id=TDD_CELLS)

MODIFY_SCF_DEACT_UL256QAM = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_DEACT_UL256QAM, list_cell_id=ALL_CELLS)


MODIFY_SCF_DEFAULT_1070 = MODIFY_SCF_DEFAULT + MODIFY_SCF_T100M_1070 + \
                     MODIFY_SCF_FRAME_STRUCTURE_1070 + MODIFY_SCF_DEACT_UL256QAM + \
                     MODIFY_SCF_T60M_1070
