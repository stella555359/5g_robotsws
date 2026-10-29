import re
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
import yaml
import random
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.attenuators import get_attenuator_nr_cells


def get_ue_number():
    if tl.ues[0].__class__.__name__ == 'Android':
        ue_number = len(tl.ues)
    else:
        with open(tl.ues[0], 'r') as file:
            config = yaml.safe_load(file)
            if 'TafUeAndroidPool' in config['UE_POOLS']:
                ue_number = len(config['UE_POOLS']['TafUeAndroidPool']['inline_config'])
            else:
                ue_number = len(config['UE_POOLS']['AndroidUePool']['inline_config'])
    return ue_number


def get_affected_cells_and_choose_randomly_one(dependent_cells, l3_call_cells=None):
    if not l3_call_cells:
        l3_call_cells = get_attenuator_nr_cells()
    if dependent_cells:
        pci_list = get_affected_pci(dependent_cells, l3_call_cells)
    else:
        pci_list = get_all_pci()
    pci_list = pci_list if not l3_call_cells else list(set(pci_list).intersection(l3_call_cells))
    if not pci_list:
        logger.info("Affected cells are not on the L3_CALL_CELLS list. "
                    "Cell for L3 call was not selected!\n"
                    "L3_CALL_CELLS: {}".format(l3_call_cells),
                    also_console=True)
        return
    return random.choice(pci_list)


def get_all_pci():
    with AdminApi() as web_api:
        pci_list = []
        cells_info = web_api.get_cells_info()
        for i in range(len(cells_info)):
            pci_list.append(cells_info[i]["physicalCellId"])
        return pci_list


def get_affected_pci(dependent_cells, l3_call_cells):
    cell_list = [_extract_cell_id(cell) for cell in dependent_cells['NRCEL']]
    cells_dict = get_mapping_cell_id_to_pci()
    pci_list = []
    for cell in cell_list:
        pci_list.append(cells_dict[int(cell)])
    return pci_list


def _extract_cell_id(infomodel_path):
    return re.search(r'NRCELL_R-(\d+)', infomodel_path).group(1)


def get_mapping_cell_id_to_pci():
    with AdminApi() as web_api:
        cells_dict = {}
        cells_info = web_api.get_cells_info()
        for i in range(len(cells_info)):
            cells_dict.update(
                {cells_info[i]["globalCellId"]: cells_info[i]["physicalCellId"]}
            )
        return cells_dict
