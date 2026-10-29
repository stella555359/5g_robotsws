from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.generic_bts import GenericBts
from robot.api import logger
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.test_config import DefaultFileLocation
import os
import random
import json


def verify_hubmod_lock_status():
    expected_statuses = {'operationalState': 'enabled', 'localState': 'blocked'}
    GnbAsirHubOperations().verify_hubmod_status(expected_statuses=expected_statuses)


def block_all_antennas():
    ant_ids = GnbAsirHubOperations().get_all_antenna_ids()
    for id in ant_ids:
        logger.info(f'Block antennas id {id}')
        GnbAsirHubOperations().block_antenna(ant_id=id)


def unblock_all_antennas():
    ant_ids = GnbAsirHubOperations().get_all_antenna_ids()
    for id in ant_ids:
        logger.info(f'Unblock antennas id {id}')
        GnbAsirHubOperations().unblock_antenna(ant_id=id)


def get_wem_cell_id_of_ant(ant_id=1):
    gnb_asir = GnbAsirHubOperations()
    antmods_and_cells = gnb_asir.get_all_cells_with_antenna_mapping()
    cells_uids = []
    for ele in antmods_and_cells:
        for ant in ele['antennas']:
            if ant['id'] == ant_id:
                cells_uids.append(ele['uid'])

    mrbts_id = GenericBts().get_global_bts_id()
    info = gnb_asir.get_site_logical_info()
    cells_ids = []
    for ele in info:
        if ele['description'] and ele['uid'] in cells_uids and 'BTS{}'.format(mrbts_id) in ele['description']['label']:
            cells_ids.append(int(ele['description']['label'].split(".")[1]))
    return cells_ids


def reset_all_antennas():
    ant_ids = GnbAsirHubOperations().get_all_antenna_ids()
    logger.console(f'all id antenas {ant_ids}')
    for id in ant_ids:
        logger.info(f'Reset antennas id {id}')
        GnbAsirHubOperations().reset_antenna(ant_id=id)


def get_cells_info(cell_type):
    return GnbCellOperations()._get_all_cells_info(cell_type=cell_type)


def get_cell_num_based_on_distname(distname_list):
    cell_num = [cell.split('-')[-1] for cell in distname_list]
    logger.info(f'Cell num: {cell_num}')
    return cell_num


def get_default_scf_path(file_name):
    commission_dir = DefaultFileLocation().get_commissioning_dir()
    scf_path = os.path.join(commission_dir, file_name)
    return scf_path


def get_mrbts_id():
    tl = get_builtin_value("tl")
    return tl.gnbs[0].instance_id


def get_all_cell_num(cell_type='nr'):
    info = get_cells_info(cell_type=cell_type)
    nr_cell = [cell['globalCellId'] for cell in info]
    if nr_cell:
        return nr_cell
    raise Exception('Not found cell num in {}'.format(info))


def prepare_random_nrcell_dist_name(cell_type='nr'):
    mrbts_id = get_mrbts_id()
    cell_ids = get_all_cell_num(cell_type)
    random_cell_id = random.choice(cell_ids)
    return f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/NRCELL-{random_cell_id}"


def get_rat_reset_delta():
    distname = prepare_random_nrcell_dist_name()
    RAT_RESET = [
        {
            "distName": distname,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "enDcSyncStatus",
                    "value": "synchronous",
                    "operation": "update"
                }
            ]
        }
    ]

    return json.dumps(RAT_RESET)
