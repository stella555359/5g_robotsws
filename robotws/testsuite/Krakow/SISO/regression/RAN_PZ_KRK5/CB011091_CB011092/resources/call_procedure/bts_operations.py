import os
import json
from call_exceptions import RatNotKnown
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning


def prepare_bts_before_call():
    attenuator_matrix = json.loads(os.environ.get("attenuator_matrix"))
    all_cell_list = get_cells(vars="cell_name")
    perform_parameter_recommisioning(cell_list=all_cell_list, attenuator_matrix=attenuator_matrix)


def perform_parameter_recommisioning(cell_list, attenuator_matrix=None, param_level="max"):
    if attenuator_matrix is None:
        attenuator_matrix = json.loads(os.environ.get("attenuator_matrix"))
    logger.log_info_to_console(f"Performing parameter recommisioning on cells {cell_list}, to {param_level} "
                               f"attenuation", log_hierarchy=2)
    gnb_commisioning = GnbCommissioning()
    delta = prepare_delta_for_recommisioning(cell_list, param_level)
    gnb_commisioning.perform_bts_delta_commissioning(delta=delta)


def prepare_delta_for_recommisioning(cell_list, param_level, operation="update"):
    attenuator_matrix = json.loads(os.environ.get("attenuator_matrix"))
    parameter_list = list()
    for cell in cell_list:
        is_in_list = any(d.get('distName') == attenuator_matrix[cell]["dist_name"] for d in parameter_list)
        if is_in_list is False:
            parameter_list.append({
                'distName': attenuator_matrix[cell]['dist_name'],
                'operation': 'update',
                'parameters': [{
                    'operation': operation,
                    'value': attenuator_matrix[cell]['qrxlevmin_' + param_level],
                    'parameterName': attenuator_matrix[cell]['parameter']}
                ]}
            )
    return parameter_list


def get_cells(vars="all"):
    du_operations = GnbDuOperations()
    cells_info = du_operations.get_bts_info()["cells"]
    cell_list = []
    for rat in cells_info:
        for cell in cells_info[rat]:
            prefix = get_prefix_for_specific_rat(rat=rat)
            if vars == "cell_name":
                cell_list.append(prefix + str(cell["globalCellId"]))
            elif vars == "globalCellId":
                cell_list.append(cell["globalCellId"])
            else:
                cell_list.append({
                    'cell_name': prefix + str(cell["globalCellId"]),
                    "global_cell_id": cell["globalCellId"]
                })
    return cell_list


def get_prefix_for_specific_rat(rat):
    if rat == "lte":
        return "LNCEL-"
    elif rat == "nr":
        return "NRCELL-"
    else:
        raise RatNotKnown(f"RAT {rat} is not known by this function. Please contact with autor")
