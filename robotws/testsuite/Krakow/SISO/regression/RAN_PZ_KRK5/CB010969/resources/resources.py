import re
import os
import json
import time
from asir_variables import ASIR_SNAPSHOT_FILES
from taf.rfrl.bts.parsers.snapshot_analyzer import find_mandatory_files_in_snapshot
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.exceptions import FileNotFound
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.commissioning import perform_commissioning_on_gnb_to_onair_state
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.utilities.logger.custom_logger import log_warn_to_console, log_info_to_console
from taf.ul.sc.gnb.oam.rest.common_oam import CommonOAM
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.wft_api import WftApi
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.helpers.sw_versions import SwVersionFactory
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.utilities.test_config import DefaultFileLocation
from taf.hw.pdu.interface import pdu

gnb_oam_ip = BuiltIn().get_variable_value('${tl.gnbs[0].cu.oam_http_connection_details.addr}')
mrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')
nrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')
SNMP_USER = BuiltIn().get_variable_value('${tl.pdus[0].snmp_user}')


class BadConfiguration(Exception):
    pass


def perform_setup_reconfiguration(prefix_tag=None):
    perform_commissioning_on_gnb_to_onair_state(prefix_tag=prefix_tag, asir_hub=True)


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


def get_info_about_asir_hubs():
    asir_hubs_info = get_cable_link_types_for_hubs()
    asir_hub_operation = GnbAsirHubOperations()
    additional_hubs_info = asir_hub_operation.get_all_hubs_with_cell_and_antenna_mapping()
    for hub in additional_hubs_info:
        asir_hubs_info[hub]['type'] = additional_hubs_info[hub]['type']
        asir_hubs_info[hub]['pico'] = []
        for antenna in additional_hubs_info[hub]['antennas']:
            asir_hubs_info[hub]['pico'].append(additional_hubs_info[hub]['antennas'][antenna]['type'])
        asir_hubs_info[hub]['pico'] = set(asir_hubs_info[hub]['pico'])
    return asir_hubs_info


def get_cable_link_types_for_hubs():
    asir_pattern = r".*(ASIRMOD-\d)"
    gnb_du = GnbDuOperations()
    temp_info = {}
    for asir_module in gnb_du.get_bts_info()['radioModules']['asirmod']:
        hub_serial = asir_module['serialNumber']
        asir_mod = re.match(asir_pattern, str(asir_module['id']['configuration']))
        asir_name = asir_mod.group(1)
        temp_info[asir_name] = hub_serial
    hubs_info = {}
    for cable in gnb_du.get_bts_info()['cables']:
        configuration = cable['secondEndPointId']['configuration']
        if re.match(asir_pattern, str(configuration)):
            asir_mod = re.match(asir_pattern, str(configuration))
            asir_name = asir_mod.group(1)
            hubs_info[temp_info[asir_name]] = {}
            hubs_info[temp_info[asir_name]]['cablinkType'] = cable['cablinkType']
            hubs_info[temp_info[asir_name]]['name'] = asir_name
    return hubs_info


def get_asir_files(asir_serial, files_type='COMMON'):
    files = []
    sw_release = DefaultFileLocation().get_commissioning_branch()
    for file_name in ASIR_SNAPSHOT_FILES[files_type]:
        if sw_release in ['SBTS25R1', 'SBTS24R3']:
            files.append('BTS_{}_RMOD_\\w_\\d{}'.format(asir_serial, file_name))
        else:
            files.append('BTS{}_{}_RMOD_\\w_\\d{}'.format(mrbts_id, asir_serial, file_name))
        return files


def get_mandatory_asir_files():
    from asir_variables import ASIR_RRH_VERSION, AASIR_HUB_VERSION
    asir_hubs_info = get_info_about_asir_hubs()
    print(asir_hubs_info)
    all_files = {}
    for asir_serial in asir_hubs_info:
        all_files[asir_serial] = get_asir_files(asir_serial=asir_serial)
        if AASIR_HUB_VERSION[asir_hubs_info[asir_serial]['type']] == 'HUB_VER2':
            all_files[asir_serial].extend(get_asir_files(asir_serial=asir_serial, files_type='HUB_VER2'))
        for pico in asir_hubs_info[asir_serial]['pico']:
            if ASIR_RRH_VERSION[pico] == 'PICO_VER1':
                all_files[asir_serial].extend(get_asir_files(asir_serial=asir_serial, files_type='PICO_VER1'))
            if ASIR_RRH_VERSION[pico] == 'PICO_VER2':
                all_files[asir_serial].extend(get_asir_files(asir_serial=asir_serial, files_type='PICO_VER2'))
            if ASIR_RRH_VERSION[pico] == 'PICO_VER3':
                all_files[asir_serial].extend(get_asir_files(asir_serial=asir_serial, files_type='PICO_VER3'))
        if asir_hubs_info[asir_serial]['cablinkType'] == 'eCPRI':
            all_files[asir_serial].extend(get_asir_files(asir_serial=asir_serial, files_type='eCPRI'))
    print(all_files)
    return all_files


def check_snapshot(directory):
    files_in_snapshot, files_dict = find_mandatory_files_in_snapshot(directory=directory, return_extended_info=True)
    files_in_snapshot.extend(files_dict)

    mandatory_files = get_mandatory_asir_files()
    with open("my_file.txt", "w") as file1:
        file1.write(str(mandatory_files))
    for asir in mandatory_files:
        print('ASIR_SERIAL: {}'.format(asir))
        asir_mandatory_files = mandatory_files[asir]
        for mandatory_file in asir_mandatory_files:
            regex = re.compile(r'{}'.format(mandatory_file))
            founded_file = list(filter(regex.match, files_in_snapshot))
            if not founded_file:
                raise FileNotFound("Mandatory RFSW file containing name {} "
                                   "not found in snapshot".format(mandatory_file))
            else:
                print('FILE PATTERN: {}'.format(mandatory_file))
                print('FILE FOUND: {}\n'.format(set(founded_file)))


def change_bts_configuration(bts_id=0, prefix_tag=None):
    # gnb_du = GnbDuOperations(bts_id=bts_id)
    perform_commissioning_on_gnb_to_onair_state(bts_id=bts_id, asir_hub=True, prefix_tag=prefix_tag)
    # gnb_du.wait_for_site_to_be_onair(bts_id=bts_id)


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


def power_off_on(host, port, alias, model):
    pdu_obj = pdu()
    if model == "HPE":
        pdu_obj.setup_pdu(host=host, alias=alias, model=model, snmp_user=SNMP_USER)
    elif model == "FPFH":
        pdu_obj.setup_pdu(host=host, alias=alias, model=model)
    logger.log_info_to_console(f"Power off {port} for {alias}", log_hierarchy=2)
    pdu_obj.power_off(port=port, pdu_device=alias)
    time.sleep(5)
    logger.log_info_to_console(f"Power off {port} for {alias}", log_hierarchy=2)
    pdu_obj.power_on(port=port, pdu_device=alias)
    time.sleep(10)
    port_status = pdu_obj.get_port_status(port=port, pdu_device=alias)
    logger.log_info_to_console(f"Port status {port_status}", log_hierarchy=2)
