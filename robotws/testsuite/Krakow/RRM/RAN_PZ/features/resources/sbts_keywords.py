import os
import random
import time

from robot.api import logger
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.test_config import DefaultFileLocation
import re
from taf.rfrl.bts.commissioning import perform_full_commissioning_on_classical_gnb, \
     perform_full_commissioning_on_gnb_asir_hub
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.commissioning import GenericCommissioning
import json
from functools import wraps
from taf.sbts.oam.coam.admin import admin


def admin_connect(web_fun):
    @wraps(web_fun)
    def wrapper(*args, **kwargs):
        try:
            api = admin()
            api.teardown_all_aliases_for_admin()
            api.connect_to(name='REST_GNB0_DU0')
            return web_fun(*args, **kwargs)
        finally:
            api.teardown_all_aliases_for_admin()

    return wrapper


def get_mrbts_id():
    tl = get_builtin_value("tl")
    return tl.gnbs[0].instance_id


def get_cells_info(cell_type):
    return GnbCellOperations()._get_all_cells_info(cell_type=cell_type)


def get_all_cell_num(cell_type='nr'):
    info = get_cells_info(cell_type=cell_type)
    nr_cell = [cell['globalCellId'] for cell in info]
    if nr_cell:
        return nr_cell
    raise Exception('Not found cell num in {}'.format(info))


def get_all_cell_num_for_dedicated_band(band, cell_type):
    cell_distname_list = None
    cell_info = get_cells_info(cell_type)
    if cell_type == 'nr':
        cell_distname_list = [cell['id']['internal'] for cell in cell_info if cell['chBwDl'] == band]
    if cell_type == 'lte':
        band = re.search(r'\d+', band).group(0)
        cell_distname_list = [cell['id']['internal'] for cell in cell_info
                              if band in cell['downlinkChannelBandwidth']]
    cell_num_list = sorted(get_cell_num_based_on_distname(cell_distname_list))
    logger.info(f'All cell for {cell_type} {cell_num_list}')
    return cell_num_list


def block_cell_for_dedicated_band(band, cell_type):
    cells_num = get_all_cell_num_for_dedicated_band(band, cell_type)
    for cell in cells_num:
        GnbCellOperations().block_cell(cell_id=int(cell))


def unblock_cell_for_dedicated_band(band, cell_type):
    cells_num = get_all_cell_num_for_dedicated_band(band, cell_type)
    for cell in cells_num:
        GnbCellOperations().unblock_cell(cell_id=int(cell))


def lock_cell_for_dedicated_band(band, cell_type):
    cells_num = get_all_cell_num_for_dedicated_band(band, cell_type)
    for cell in cells_num:
        GnbCellOperations().lock_cell(cell_id=int(cell))


def unlock_cell_for_dedicated_band(band, cell_type):
    cells_num = get_all_cell_num_for_dedicated_band(band, cell_type)
    for cell in cells_num:
        GnbCellOperations().unlock_cell(cell_id=int(cell))


def get_cell_num_based_on_distname(distname_list):
    cell_num = [cell.split('-')[-1] for cell in distname_list]
    logger.info(f'Cell num: {cell_num}')
    return cell_num


def verify_cell_is_locked_based_on_band(band, cell_type, bts_id=0, du_id=0):
    cells_num = get_all_cell_num_for_dedicated_band(band, cell_type)
    for cell in cells_num:
        GnbCellOperations().verify_cell_is_locked(bts_id=bts_id, cell_id=cell, du_id=du_id)


def verify_cell_is_unlocked_based_on_band(band, cell_type, bts_id=0, du_id=0):
    cells_num = get_all_cell_num_for_dedicated_band(band, cell_type)
    for cell in cells_num:
        GnbCellOperations().verify_cell_is_unlocked(bts_id=bts_id, cell_id=cell, du_id=du_id)


def verify_cell_is_blocked_based_on_band(band, cell_type, bts_id=0, du_id=0):
    cells_num = get_all_cell_num_for_dedicated_band(band, cell_type)
    for cell in cells_num:
        GnbCellOperations().verify_cell_is_blocked(bts_id=bts_id, cell_id=cell, du_id=du_id)


def verify_cell_is_unblocked_based_on_band(band, cell_type, bts_id=0, du_id=0):
    cells_num = get_all_cell_num_for_dedicated_band(band, cell_type)
    for cell in cells_num:
        GnbCellOperations().verify_cell_is_unblocked(bts_id=bts_id, cell_id=cell, du_id=du_id)


def verify_cell_is_onair_except_for_cell_on_band(band, cell_type):
    all_cells = [*get_all_cell_num(cell_type='nr'), *get_all_cell_num(cell_type='lte')]
    cell_band = get_all_cell_num_for_dedicated_band(band, cell_type)
    cell_to_check = [cell for cell in all_cells if str(cell) not in cell_band]
    logger.info(f"Cell to check onAir {cell_to_check}")
    for cell in cell_to_check:
        GnbCellOperations().verify_cell_is_onair(cell_id=int(cell))


def prepare_random_nrcell_dist_name(cell_type='nr'):
    mrbts_id = get_mrbts_id()
    cell_ids = get_all_cell_num(cell_type)
    random_cell_id = random.choice(cell_ids)
    return f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/NRCELL-{random_cell_id}"


def get_cell_number(distname):
    return distname.split('-')[-1]


def prepare_prach_value_index(current_prach_index):
    PRACH_INDEX_LIST = [8, 9, 10, 11, 12, 13, 14, 15, 36, 37, 38, 39, 40, 41, 42, 43]
    prach_index = [idx for idx in PRACH_INDEX_LIST if idx != int(current_prach_index)][0]
    return prach_index


def change_prach_configuration_index(dist_name, value):
    prach_value = prepare_prach_value_index(value)
    delta_plan = [
        {
            "distName": dist_name,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "prachConfigurationIndex",
                    "value": str(prach_value),
                    "operation": "update"
                }
            ]
        },
    ]
    GenericCommissioning().perform_bts_delta_commissioning(delta=delta_plan)


def change_manual_frame_timing(frame_timing):
    mrbts_id = get_mrbts_id()
    dist_name = f'MRBTS-{mrbts_id}/MNL-1/MNLENT-1/SYNC-1'
    delta_plan = [
        {
            "distName": dist_name,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "manualFrameTimingAdjustment",
                    "value": str(frame_timing),
                    "operation": "update"
                }
            ]
        }
    ]
    logger.info(delta_plan)
    GenericCommissioning().perform_bts_delta_commissioning(delta=delta_plan)


def prepare_gnb_with_config_reset_and_full_commissioning(scf_path):
    sw = GnbSwUpdate()
    du = GnbDuOperations()

    logger.info('Reset Configuration')
    sw.reset_configuration()
    logger.info('Wait until du will be onAir')
    du.wait_unitl_connection_via_admin_is_possible(timeout=600, interval=10)
    du.wait_until_smod_is_online(timeout=600, interval=10)
    time.sleep(120)
    logger.info('Full Commissioning')
    perform_full_commissioning_on_classical_gnb(scf_path=scf_path)
    time.sleep(120)
    du.wait_unitl_connection_via_admin_is_possible(timeout=360, interval=5)
    du.wait_for_site_to_be_available(timeout=400, interval=10)
    du.wait_for_site_to_be_onair(timeout=900, interval=10)


def get_default_scf_path(file_name):
    commission_dir = DefaultFileLocation().get_commissioning_dir()
    scf_path = os.path.join(commission_dir, file_name)
    return scf_path


@admin_connect
def get_online_parameters_delta():
    distname = prepare_random_nrcell_dist_name()
    ONLINE_PARAMETERS = [
        {
            "distName": distname,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actProactUlScheduling",
                    "value": "true",
                    "operation": "update"
                }
            ]
        }
    ]
    return json.dumps(ONLINE_PARAMETERS)


@admin_connect
def get_site_reset_delta():
    mrbts_id = get_mrbts_id()
    SITE_RESET = [
        {
            "distName": f'MRBTS-{mrbts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "holdOverModeUsed",
                    "value": "true",
                    "operation": "update"
                }
            ]
        }
    ]

    return json.dumps(SITE_RESET)


@admin_connect
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


def loading_commissioning_for_release(scf_gnb_path, scf_asir_path):
    """
    Loading commissioning with special flags for related releases
    :param sw_package: software version for gNB in str format, eg: 'SBTS00_ENB_9999_210318_000011'
    :param release_list: list of release for which commissioning commisionig is needed, eg: ['SBTS00']
    :return:
    """
    perform_full_commissioning_on_classical_gnb(scf_path=scf_gnb_path)
    perform_full_commissioning_on_gnb_asir_hub(scf_path=scf_asir_path)
    GnbCellOperations().wait_for_setup_of_all_cells(timeout=1000, interval=10)
