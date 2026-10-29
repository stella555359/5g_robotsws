import os
import json
import re
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.commissioning import perform_commissioning_on_gnb_to_onair_state
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from taf.rfrl.bts.devices.exceptions import FileNotFound
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from asir_variables import ASIR_SNAPSHOT_FILES
from taf.rfrl.bts.parsers.snapshot_analyzer import find_mandatory_files_in_snapshot
from taf.rfrl.utilities.test_config import DefaultFileLocation
from taf.rfrl.utilities.wft_api import WftApi
from taf.rfrl.utilities.test_config import get_log_path, get_repository_path
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.helpers.sw_versions import SwVersionFactory


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
    os.environ["attenuator_matrix"] = json.dumps(attenuator_matrix)
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
        mrbts_id = GnbDuOperations().get_global_bts_id()
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


def combine_all_mandatory_files(files_per_hub):
    all_mandatory_files = []
    for asir_serial in files_per_hub:
        all_mandatory_files.extend(files_per_hub[asir_serial])
    return all_mandatory_files


def check_snapshot(directory='/home/ute/Downloads/snap.zip'):
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


def upload_swconfig_to_bts():
    gnb_du = GnbDuOperations()
    sw_config_path = '{}/commissionings/Krakow/swconfig/default_swconfig.txt'\
        .format(get_repository_path())
    gnb_du.upload_swconfig(sw_config_path=sw_config_path)


def get_sw_version():
    gnb_sw = GnbDuOperations()
    bts_version = gnb_sw.get_bts_sw_version()
    bts_version = SwVersionFactory().create_sw_version(bts_version)
    return bts_version.release + "_ENB_" + bts_version.simplified.replace(".", "_")


def get_sw_version_from_wft_upgrade_path(n, build_version=None):
    if not build_version:
        build_version = get_sw_version()
    logger.log_info_to_console("Getting Source Build from WFT for {}".format(build_version))
    wft_api = WftApi()
    upgrade_path = json.loads(wft_api.get_column_from_build_version(build_version=build_version,
                                                                    column="build_attributes")['upgrade_path'])
    build = upgrade_path['product_defaults'][n]
    return build


def delete_files_from_dir(dir_path, prefix):
    for filename in os.listdir(dir_path):
        if filename.startswith(prefix):
            file_path = os.path.join(dir_path, filename)
            os.remove(file_path)
            logger.log_info_to_console(f'Deleted file: {file_path}')
