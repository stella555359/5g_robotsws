import os.path
import re
import json
import time
from taf.rfrl.utilities.wft_api import WftApi
from taf.rfrl.bts.devices.generic_bts import GenericBts
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.exceptions import FileNotFound
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.helpers.sw_versions import SwVersionFactory
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.commissioning import perform_commissioning_on_gnb_to_onair_state
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from taf.rfrl.utilities.test_config import DefaultFileLocation


class BadConfiguration(Exception):
    pass


def verify_is_correct_config(correct_config):
    du_operations = GnbDuOperations()
    bts_info = du_operations.get_bts_info()
    if bts_info["name"] != correct_config:
        raise BadConfiguration(f'Wrong configuration detected. Actual Configuration: {bts_info["name"]}, '
                               f'should be {correct_config}')
    return True


def verify_is_correct_config_and_change_it_if_needed(correct_config, prefix_tag):
    du_operations = GnbDuOperations()
    bts_info = du_operations.get_bts_info()
    if bts_info["name"] != correct_config:
        perform_setup_reconfiguration(prefix_tag=prefix_tag)
        bts_info = du_operations.get_bts_info()
        if bts_info["name"] != correct_config:
            raise BadConfiguration(f'Wrong configuration detected. Actual Configuration: {bts_info["name"]}, '
                                   f'should be {correct_config}')
    return True


def perform_setup_reconfiguration(prefix_tag=None):
    perform_commissioning_on_gnb_to_onair_state(prefix_tag=prefix_tag, asir_hub=True)


def adjust_dist_name(dist_name, bts_id=0, du_id=0):
    bts = GenericBts()
    return bts.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id)


def generate_attenuator_matrix(attenuator_map, qrxlev):
    attenuator_matrix = {}
    for rat in attenuator_map:
        for cell in attenuator_map[rat]:
            real_cell_id = attenuator_map[rat][cell]['cell_id']
            bts_patterns = GnbDistNamePatterns if rat == 'NR' else EnbDistNamePatterns
            cell_name = 'NRCELL-{}'.format(cell) if rat == 'NR' else 'LNCEL-{}'.format(cell)
            dist_name = adjust_dist_name(bts_patterns.cell_dist_name.format({}, {}, real_cell_id))
            if rat == 'LTE':
                dist_name = '{}/SIB-0'.format(dist_name)
            attenuator_matrix.update({cell_name: attenuator_map[rat][cell]})
            attenuator_matrix[cell_name].update({'dist_name': dist_name})
            attenuator_matrix[cell_name].update({'parameter': qrxlev[rat]['parameter_name']})
            attenuator_matrix[cell_name].update({'qrxlevmin_min': qrxlev[rat]['min']})
            attenuator_matrix[cell_name].update({'qrxlevmin_max': qrxlev[rat]['max']})
    return attenuator_matrix


def get_additional_action_during_call(action_name):
    if action_name is None:
        return None
    else:
        if action_name.lower() == "lock prrh":
            return action_with_prrhs
        elif action_name.lower() == "reset prrh":
            return action_with_prrhs
        else:
            logger.log_warn_to_console("Cannot recognize additional action during call. Please contact with KW author")
            return None


def get_sw_version():
    gnb_sw = GnbDuOperations()
    bts_version = gnb_sw.get_bts_sw_version()
    bts_version = SwVersionFactory().create_sw_version(bts_version)
    return bts_version.release + "_ENB_" + bts_version.simplified.replace(".", "_")


def get_sw_version_from_wft_upgrade_path(n):
    logger.log_info_to_console("Getting Source Build from WFT")
    wft_api = WftApi()
    upgrade_path = json.loads(wft_api.get_column_from_build_version(build_version=get_sw_version(),
                                                                    column="build_attributes")['upgrade_path'])
    build = upgrade_path['product_defaults'][n]
    logger.log_info_to_console(f"Found build {n}: {build}", log_hierarchy=2)
    return build


def prepare_bts_before_test(sw_to_load=None, path_to_download="/home/ute/preparation_build"):
    logger.log_info_to_console(f"Performing download SW Build {sw_to_load}")
    gnb_sw_update = GnbSwUpdate()
    path_to_download = create_dir_to_download_sw_build(path_to_download)
    logger.log_info_to_console(f"Downloading build {sw_to_load} to {path_to_download} ...", log_hierarchy=2)
    path_to_build = gnb_sw_update.download_sw_package(sw_version=sw_to_load, target_dir=path_to_download)
    logger.log_info_to_console(f"Performing configuration reset before downgrade to build {sw_to_load}",
                               log_hierarchy=3)
    perform_config_reset()
    logger.log_info_to_console("Performing update software", log_hierarchy=2)
    gnb_sw_update.update_software(path_to_build, timeout=3600)
    logger.log_info_to_console("Software update end", log_hierarchy=2)
    logger.log_info_to_console("Waiting 120s for BTS reboot", log_hierarchy=2)
    time.sleep(120)
    return path_to_download


def create_dir_to_download_sw_build(path_to_dir):
    if not os.path.exists(path_to_dir):
        os.makedirs(path_to_dir)
    return path_to_dir


def perform_config_reset():
    logger.log_info_to_console("Start Config reset", log_hierarchy=4)
    gnb_sw_update = GnbSwUpdate()
    gnb_comm = GnbCommissioning()
    gnb_comm.reset_configuration()
    logger.log_info_to_console("Wait SW update is possible", log_hierarchy=4)
    gnb_sw_update.wait_sw_update_possible(900)
