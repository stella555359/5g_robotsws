import testsuite.Wroclaw.RRM.resources.webUI_operations as webUI_operations
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
import xml.etree.ElementTree as ET


MrBTS_id = tl.gnbs[0].instance_id
NrBTS_id = tl.gnbs[0].global_bts_id


def delete_cell_and_cell_dependencies(scf_path, output_path='SCF_Cells_deleted.xml'):
    tree = ET.parse(scf_path)
    root = tree.getroot()

    # DELETING CELLS OBJECTS AND DEPENDENCIES
    for node in root.iter():
        for child in node.findall("{raml21.xsd}managedObject"):
            if (
                    child.attrib['distName'] == "MRBTS-{}/NRBTS-{}/NRCELLGRP-0".format(MrBTS_id, NrBTS_id) or
                    child.attrib['distName'].startswith("MRBTS-{}/NRBTS-{}/NRCELL-1".format(MrBTS_id, NrBTS_id)) or
                    child.attrib['distName'].startswith("MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/"
                                                        "LCELNR-1".format(MrBTS_id))
            ):
                blog("Removed ", child)
                node.remove(child)

    # DELETING CELL GROUP REFERENCE FROM NRDU
    for node in root.iter("{raml21.xsd}managedObject"):
        if node.attrib['distName'] == "MRBTS-{}/NRBTS-{}/NRDU-1".format(MrBTS_id, NrBTS_id):
            for child in node.iter("{raml21.xsd}list"):
                if child.attrib['name'] == "refNrCellGroup":
                    blog("Removed ", child[0])
                    child.remove(child[0])

    ET.register_namespace('', 'raml21.xsd')
    tree.write(output_path)
    return output_path


# def unlock_all_cells():
#     cells_list = get_cells_list()
#     for cell_index in cells_list:
#         cell_unlock_after_shutdown(cell_index)


def lock_other_cells(non_locking_cell):
    cell_list = get_cells_list()
    for cell_index in cell_list:
        if cell_index != int(non_locking_cell):
            perform_shutting_down(cell_index)


def cell_unlock_after_shutdown(cell_nr):
    with webUI_operations.WebUIOperations() as coam:
        coam.perform_parameter_recommissioning(dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(MrBTS_id, NrBTS_id,
                                                                                              str(cell_nr)),
                                               parameter='administrativeState',
                                               operation='update',
                                               skip_parameter_relation_errors=True,
                                               value='Unlocked')


def perform_shutting_down(cell_nr):
    with webUI_operations.WebUIOperations() as coam:
        coam.perform_parameter_recommissioning(dist_name="MRBTS-{}/NRBTS-{}/NRCELL-{}".format(MrBTS_id, NrBTS_id,
                                                                                              str(cell_nr)),
                                               parameter='administrativeState',
                                               operation='update',
                                               skip_parameter_relation_errors=True,
                                               value='Shutting Down')


def get_cells_list():
    cells_list = []
    with AdminApi() as web_api:
        for cell in web_api.get_cells_info():
            cells_list.append(cell['globalCellId'])
    return cells_list
