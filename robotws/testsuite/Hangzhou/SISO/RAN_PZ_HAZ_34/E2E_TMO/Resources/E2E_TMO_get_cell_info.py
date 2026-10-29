import re

from taf.rfrl.uuf4all.resources.python.uuf_rfrl_utilities import robot_kw, robot_logger, robot_var
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.uuf4all.resources.python.uuf_rfrl_common import get_admin_connection, admin, get_dependent_cells
from taf.rfrl.uuf4all.resources.python.uuf_rfrl_variables import CELL_TYPES


def get_cells_global_id(dict_of_cell_distnames_per_type):
    admin_connection = get_admin_connection()
    global_cell_id_list = [admin.get_cell_specific_info(cell, connection=admin_connection)["globalCellId"]
                           for cell_type in dict_of_cell_distnames_per_type.keys()
                           for cell in dict_of_cell_distnames_per_type[cell_type]
                           if cell_type == "NRCEL" or cell_type == "LNCEL"]
    return global_cell_id_list


def get_eutran_cell_id_per_pci(lncels_info_dict, pci):
    for cell in lncels_info_dict:
        if cell['physicalCellId'] == str(pci):
            return cell['eutranCellId']


def get_cells_info_for_attach_verification(cell_mapping_per_att_port, remote=False):
    admin_connection = get_admin_connection(remote)
    cells_per_rat_list = admin.get_cell_list(connection=admin_connection)["cells"]
    cells_parameters_list = [cell for cell_type in CELL_TYPES.values() for cell in
                             admin.get_parameters_for_all(cell_type, connection=admin_connection)]
    cells = {cell["globalCellId"]: {"physicalCellId": str(cell["physicalCellId"]),
                                    "cell_rat": rat,
                                    **get_rat_identity(cell, cells_parameters_list),
                                    "internalId": cell["id"]["internal"]}
             for rat in cells_per_rat_list.keys() for cell in cells_per_rat_list[rat]}
    mapped_cells = {cell: cell_info for cell, cell_info in cells.items()
                    if any(int(cell) in cell_list for cell_list in cell_mapping_per_att_port.values())}
    return mapped_cells


def get_cells_info_for_attach_verification_by_ue_capability(remote=False):
    ue_cell_list = {}
    tl = BuiltIn().get_variable_value("${tl}")
    admin_connection = get_admin_connection(remote)
    cells_per_rat_list = admin.get_cell_list(connection=admin_connection)["cells"]
    cells_parameters_list = [cell for cell_type in CELL_TYPES.values() for cell in
                             admin.get_parameters_for_all(cell_type, connection=admin_connection)]
    cells = {cell["globalCellId"]: {"physicalCellId": str(cell["physicalCellId"]),
                                    "cell_rat": rat,
                                    **get_rat_identity(cell, cells_parameters_list),
                                    "internalId": cell["id"]["internal"]}
             for rat in cells_per_rat_list.keys() for cell in cells_per_rat_list[rat]}
    ue_num = len(tl.ues)
    for ue_idx in range(ue_num):
        ue_capabilities = str(tl.ues[ue_idx].capabilities)
        if re.search("cell_Mapping", ue_capabilities):
            cell_capabilities = tl.ues[ue_idx].capabilities[0]
            ue_cell = re.findall(r"\d+", cell_capabilities)
            for ue_cell_id in ue_cell:
                ue_cell_list.update({ue_cell_id: ue_idx})
    mapped_cells = {cell: cell_info for cell, cell_info in cells.items()
                    if any(str(cell) in cell_list for cell_list in ue_cell_list.keys())}
    return mapped_cells, ue_cell_list


def get_rat_identity(cell_info, cells_parameters_list):
    for cell_params in cells_parameters_list:
        if cell_params["id"] == cell_info["id"]["internal"]:
            cell_parameters = cell_params
    if cell_parameters.get("nrCellIdentity") is not None:
        return {"nrCellIdentity": str(cell_parameters.get("nrCellIdentity"))}
    elif cell_parameters.get("eutraCelId") is not None:
        return {"eutraCelId": str(cell_parameters.get("eutraCelId"))}
    raise Exception


@robot_kw
def remove_not_dependent_cells(cells_dict, dependent_cells_list):
    dependent_cells_list = [str(cell) for cell in dependent_cells_list]
    return {cell: cell_info for cell, cell_info in cells_dict.items() if str(cell) in dependent_cells_list}


@robot_kw
def get_cells_info_for_attach(dependent_cells=None, remote=False):
    ue_idx_nrCellIdentity = {}
    cells_dict, ue_cell_list = get_cells_info_for_attach_verification_by_ue_capability(remote)
    robot_logger("cells_dict: {}, ue_cell_list: {}".format(cells_dict, ue_cell_list), "info")
    robot_logger("dependent_cells: {}".format(dependent_cells), "info")
    if dependent_cells is not None:
        cells_dict = remove_not_dependent_cells(cells_dict, get_cells_global_id(dependent_cells))
    if not cells_dict:
        robot_logger("None of dependent cells have been mapped to attenuator port", "warn")
        return None
    robot_logger("cells_dict: {}, ue_cell_list: {}".format(cells_dict, ue_cell_list), "info")
    for cell in cells_dict.keys():
        ue_idx_nrCellIdentity.update({cells_dict[cell]['nrCellIdentity']: ue_cell_list[str(cell)]})
    return ue_idx_nrCellIdentity
