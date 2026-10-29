from robot.libraries.BuiltIn import BuiltIn
import NIDD_Modify_data_template as data_template
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
from NIDD_modify_scf import ALL_CELLS, FDD_CELLS, TDD_CELLS, LIST_SCELL_ID, BWP_ID_MAPPING

MODIFY_SCF_DEFAULT = BuiltIn().get_variable_value('${MODIFY_SCF_DEFAULT}')

# used for scell swap
SOURCE_TARGET_SCELLS = BuiltIn().get_variable_value('${SOURCE_TARGET_SCELLS}')

# Cell mapping relationship (use TL255 for example)
# FDD Cell 0 <--> NRCELL-2  20MHz <--> AHLOA <--> ABIN
# FDD Cell 1 <--> NRCELL-3  10MHz <--> AHLOA <--> ABIO
# TDD Cell 0 <--> NRCELL-1 100MHz <--> AEHC  <--> ABIL
# TDD Cell 2 <--> NRCELL-5  60MHz <--> AEHC  <--> ABIL

MODIFY_SCF_F20M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_F20M, list_cell_id=[FDD_CELLS[0]],
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

MODIFY_SCF_T60M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_T60M, list_cell_id=[TDD_CELLS[2]],
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['TDD_1116_0_60M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['TDD_1116_0_60M']['dedicate'])

MODIFY_SCF_FRAME_STRUCTURE_1116_0 = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_1116_0, list_cell_id=TDD_CELLS)

MODIFY_SCF_DEACT_UL256QAM = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_DEACT_UL256QAM, list_cell_id=ALL_CELLS)

MODIFY_SCF_INTRA_FREQUENCY_SCELL_SWAP = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_INTRA_FREQUENCY_SCELL_SWAP, list_cell_id=SOURCE_TARGET_SCELLS)

MODIFY_SCF_DEFAULT = MODIFY_SCF_DEFAULT + MODIFY_SCF_F20M + MODIFY_SCF_F10M + MODIFY_SCF_T100M + MODIFY_SCF_T60M + \
                     MODIFY_SCF_FRAME_STRUCTURE_1116_0 + MODIFY_SCF_DEACT_UL256QAM + \
                     MODIFY_SCF_INTRA_FREQUENCY_SCELL_SWAP
