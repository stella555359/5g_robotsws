import regex as re
import logging

from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as GnbRu
from taf.rfrl.bts.devices.du.cell_operations import GenericCellOperations as GnbCell
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations as AsirCell
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion, SwVersionFactory


def _get_ru_object_name_from_dist_name(dist_name, radio_type='RMOD'):
    ru_id = re.search(rf'(?<={radio_type}-).*', dist_name)
    return ru_id.group(0)


def _get_cell_id_from_ru_info(dist_name):
    ru_cells = []
    for cell in dist_name:
        cell_pattern = re.search(r'(?<=(LNCEL|NRCELL)-)(\d+)', cell['id']['configuration'])
        if cell_pattern.group(0) not in ru_cells:
            ru_cells.append(cell_pattern.group(0))
    return ru_cells


def get_not_predefined_rus_and_cells(predefined_id, radio_type='rmod'):
    rus = GnbRu().get_all_radio_unit_info()
    predefined_rus = {}
    for _ru_info in rus:
        ru = _get_ru_object_name_from_dist_name(dist_name=_ru_info['id']['configuration'], radio_type=radio_type)
        if int(ru) != int(predefined_id):
            ru_info = _ru_info
            predefined_rus[ru] = _get_cell_id_from_ru_info(dist_name=_ru_info['carrierList'])
    return predefined_rus


def verify_not_predefined_rus_and_cells(predefined_id, radio_type='rmod'):
    not_predefined_dict = get_not_predefined_rus_and_cells(predefined_id, radio_type=radio_type)
    for ru in not_predefined_dict:
        GnbRu().wait_for_radio_unit_to_be_online(ru_id=ru, radio_type=radio_type.lower())
        for cell in not_predefined_dict[ru]:
            logging.info(f'Checking cell {cell}')
            GnbCell().wait_for_cell_to_be_onair(cell_id=cell)


def group_cells_by_predefined(ant_id):
    predefined_cells_uids = []
    not_predefined_cells_uids = []
    antmods_and_cells = AsirCell().get_all_cells_with_antenna_mapping()
    for item in antmods_and_cells:
        for ant in item['antennas']:
            if ant['id'] == int(ant_id):
                predefined_cells_uids.append(item['uid'])
            else:
                not_predefined_cells_uids.append(item['uid'])
    return predefined_cells_uids, not_predefined_cells_uids


def get_cell_labels_from_uids(cell_uid_list):
    cells_ids = []
    mrbts_id = GenericBts().get_global_bts_id()
    info = AsirCell().get_site_logical_info()
    for item in info:
        if (item['description'] and
                item['uid'] in cell_uid_list and 'BTS{}'.format(mrbts_id) in item['description']['label']):
            cells_ids.append(int(item['description']['label'].split(".")[1]))
    return cells_ids


def verify_predefined_asir_cells_status(ant_id):
    cells = group_cells_by_predefined(ant_id)
    cells = get_cell_labels_from_uids(cells[0])
    if cells is not None:
        AsirCell().verify_status_of_asir_cells(cells, 'failed')
    else:
        raise CellListEmpty("Predefined cell list is empty")


def verify_not_predefined_asir_cells_status(ant_id):
    cells = group_cells_by_predefined(ant_id)
    cells = get_cell_labels_from_uids(cells[1])
    if cells is not None:
        AsirCell().verify_status_of_asir_cells(cells, 'operational')
    else:
        raise CellListEmpty("Not predefined cell list is empty")


def set_procedural_status(procedural_status):
    """
    From SBTS26R2 Procedural status for a cell belonging to a predefined radio
    has been changed from 'configured' to 'not initialized'
    """
    gnb_obj = GnbDuOperations()
    active_sw = gnb_obj.get_bts_sw_version()
    active_sw_version = SwVersionFactory.create_sw_version(active_sw)
    if procedural_status == "configured":
        if active_sw_version >= SbtsSwVersion('SBTS26R2_ENB_0000_000000_000000'):
            procedural_status = "not initialized"
        return procedural_status


class CellListEmpty(Exception):
    pass
