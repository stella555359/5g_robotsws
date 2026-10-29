from robot.api import logger
from taf.config.scf.interface import scf as config_scf


def add_populated_list_to_scf(scf_path, dist_name, list_name, list_elements: dict):
    """
    add a list to the scf, overriding if it exists already.
    Note: dist_name does not need to include the MRBTS part,
    as taf.config.scf will find the MRBTS number automatically.
    """
    scf = config_scf()
    scf.load_scf(file_path=scf_path)
    if scf.is_list_in_object(dist_name=dist_name, list_name=list_name):
        scf.remove_list_from_scf(dist_name=dist_name, list_name=list_name)
    scf.add_list_to_scf(dist_name=dist_name, list_name=list_name)
    scf.add_item_to_list(dist_name=dist_name, list_name=list_name, elements=list_elements)
    scf.save_scf("new_scf.xml")
    return "new_scf.xml"


def delete_list_from_scf(scf_path, dist_name, list_name):
    """
    remove a list from the scf.
    Note: dist_name does not need to include the MRBTS part,
    as taf.config.scf will find the MRBTS number automatically.
    """
    scf = config_scf()
    scf.load_scf(file_path=scf_path)
    scf.remove_list_from_scf(dist_name=dist_name, list_name=list_name)
    scf.save_scf("new_scf.xml")
    return "new_scf.xml"


def add_simple_list_to_scf(scf_path, dist_name, list_name, elements: list):
    """
    Add a simple list to the SCF, overriding if it exists already.
    Note: dist_name does not need to include the MRBTS part,
    as taf.config.scf will find the MRBTS number automatically.
    """
    scf = config_scf()
    scf.load_scf(file_path=scf_path)
    if scf.is_list_in_object(dist_name=dist_name, list_name=list_name):
        scf.remove_list_from_scf(dist_name=dist_name, list_name=list_name)
    scf.add_list_to_scf(dist_name=dist_name, list_name=list_name)
    scf.add_elements_to_list(dist_name=dist_name, list_name=list_name, elements=elements)
    scf.save_scf("new_scf.xml")
    return "new_scf.xml"
