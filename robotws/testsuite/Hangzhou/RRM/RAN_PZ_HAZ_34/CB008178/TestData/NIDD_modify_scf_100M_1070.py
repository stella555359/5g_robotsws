from NIDD_modify_scf_common import *
import NIDD_Modify_data_template as data_template
import logging

SCF_TEMPLATE_NRRIM_PROFILE = '''
[
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsPattern1Period",
            "value":"2.5ms"}},
    {{
            "dist_name":"{dist_name}",
            "p_name":"rsPattern2Period",
            "value":"2.5ms"}}
]
'''
LIST_CELL_ID_GNB0 = BuiltIn().get_variable_value("${CELL_LIST_GNB0}")

MODIFY_SCF_BASE = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_BASE_ALL_CELLS, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_T100M = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_T100M, value=DN_NRBTS, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_BEAMSET2 = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_BEAMSET2, value=DN_NRBTS, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_FRAME_STRUCTURE_1070 = param_modify_lib.get_parameter_list_for_update_for_cells_for_gNB(
    data_template=data_template.SCF_TEMPLATE_FRAME_STRUCTURE_1070_B4, list_cell_id=LIST_CELL_ID_GNB0)

MODIFY_SCF_NRRIM = param_modify_lib.get_parameter_nrrim_for_cells_for_gNB(
    data_template=SCF_TEMPLATE_NRRIM_PROFILE, list_cell_id=LIST_CELL_ID_GNB0)

PARAMS_TO_MODIFY_GNB0 = MODIFY_SCF_BASE + MODIFY_SCF_T100M + MODIFY_SCF_NRRIM + MODIFY_SCF_BEAMSET2 +\
                     MODIFY_SCF_FRAME_STRUCTURE_1070 + ACT_BBPOOLING + MODIFY_SCF_LOAD

PARAMS_TO_MODIFY_GNB1 = {}

PARAMS_TO_DELETE_GNB0 = {}
PARAMS_TO_ADD_GNB0 = {}

PARAMS_TO_DELETE_GNB1 = {}
PARAMS_TO_ADD_GNB1 = {}

PARAMS_TO_DELETE_DIC = [PARAMS_TO_DELETE_GNB0, PARAMS_TO_DELETE_GNB1]
PARAMS_TO_MODIFY_DIC = [PARAMS_TO_MODIFY_GNB0, PARAMS_TO_MODIFY_GNB1]
PARAMS_TO_ADD_DIC = [PARAMS_TO_ADD_GNB0, PARAMS_TO_ADD_GNB1]
