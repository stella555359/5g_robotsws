import os
import re
import datetime
import zipfile
import lzma
import requests
import xml.etree.ElementTree as ET
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.rfrl.bts.devices.exceptions import AsirOperationFailed
from taf.sbts.oam.coam.admin.exceptions import IncorrectParameterValue, DataNotAvailable
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


class IncorrectValue(Exception):
    pass


class NoSuchLine(Exception):
    pass


def download_cert_file(path="/home/ute/", cert_name="private_key.p12"):
    from common_variables import Private_Key_Path
    path += cert_name
    response = requests.get(Private_Key_Path)
    if response.status_code == 200:
        with open(path, "wb") as file:
            file.write(response.content)
        print("Private key was downloaded succesfully")
        return path
    else:
        print("Cannot download private key file. Status: ", response.status_code)
        return None


def get_allowed_alarms(custom_alarms=None):
    from common_variables import DEFAULT_ALARMS
    allowed_alarms = DEFAULT_ALARMS
    if custom_alarms and allowed_alarms:
        for custom_alarm in custom_alarms:
            if custom_alarm not in allowed_alarms:
                allowed_alarms.append(custom_alarm)
    return allowed_alarms


def get_time_of_message(log_file_path, regexp):
    with open(log_file_path, "r") as log_file:
        for line in log_file.readlines():
            if regexp in line:
                line = line.split()
                return datetime.datetime.strptime(line[1][:line[1].index(".")], '%H:%M:%S')
    raise NoSuchLine("Cannot find regex: '{}' in file: {}".format(regexp, log_file_path))


def substract_time_from_two_messages(message_1, message_2):
    return (message_1 - message_2).total_seconds()


def generate_delta_file_to_check(dist_name, parameter,  param_value):
    return {
        dist_name: {
            parameter: param_value
        }
    }


def generate_delta_file_to_update(dist_name, parameter,  param_value):
    return [
        {
            "distName": dist_name,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": parameter,
                    "value": param_value,
                    "operation": "update"
                }
            ]
        }
    ]


def adjust_dist_name(dist_name, bts_id=0, du_id=0):
    bts = GenericBts()
    return bts.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id)


def get_ids_from_cell_list(cell):
    return cell[cell.index('-') + 1:]


def prepare_ru_id_for_checking_ip(ru_id):
    return int(ru_id) - 1


def get_file_from_snapshot(snapshot_file, path_to_unzip, unzip_type, file_regexp, second_file_regexp=None):
    path = unzip_snapshot(snapshot_file=snapshot_file, path_to_unzip=path_to_unzip, unzip_type=unzip_type,
                          file_regexp=file_regexp)
    if path is None and second_file_regexp is not None:
        path = unzip_snapshot(snapshot_file=snapshot_file, path_to_unzip=path_to_unzip, unzip_type=unzip_type,
                              file_regexp=second_file_regexp)
    return path


def unzip_snapshot(snapshot_file, path_to_unzip, unzip_type="all", file_regexp=None):
    if not os.path.isdir(path_to_unzip):
        os.mkdir(path_to_unzip)
    with zipfile.ZipFile(snapshot_file) as zip_file:
        if unzip_type == "all":
            zip_file.extractall(path_to_unzip)
            return path_to_unzip
        else:
            for file in zip_file.namelist():
                if file_regexp in file:
                    zip_file.extract(file, path_to_unzip)
                    return path_to_unzip + file_regexp


def find_logs_in_snapshot(snap_struct, mandatory_logs, logs_prefix):
    for log in mandatory_logs:
        finded = False
        for element in snap_struct:
            if snap_struct[element] is not None:
                for child in snap_struct[element]:
                    if logs_prefix + log == child:
                        finded = True
                        break
        if finded is False:
            raise FileNotFoundError("Cannot find file: {} in given snapshot".format(logs_prefix + log))


def get_snapshot_file_orgnization(file_folder):
    snapshot_file = os.path.join(file_folder, "snapshot_file_list.txt")
    file_tree = {}
    with open(snapshot_file, "r") as snapshot_files:
        file_structure = snapshot_files.read().split("\n\n")
        for file in file_structure:
            if file.count(".zip") > 0:
                zip_info = re.split(":.*\n", file)
                file_tree[zip_info[0]] = []
                file_list = zip_info[1].splitlines()
                for file_name in file_list:
                    file_tree[zip_info[0]].append(file_name.strip())
            else:
                file_tree[file] = None
    return file_tree


def get_file_from_snapshot_by_key(key_name, snapshot_structure):
    for key, value in snapshot_structure.items():
        if key != key_name:
            if key.count(".zip") > 0:
                for name in value:
                    if name.count(key_name) > 0:
                        return key
            else:
                if key.count(key_name) > 0:
                    return file_folder, key
        else:
            print(key, value)
            return key


def extract_message_from_file(file_path, regexp):
    try:
        file = lzma.open(file_path).readlines()
    except lzma.LZMAError:
        with zipfile.ZipFile(file_path) as zip_file:
            f = zip_file.infolist()[0]
            with zip_file.open(f, "r") as z_f:
                file = lzma.open(z_f).readlines()
    for line in file[::-1]:
        line = str(line)
        if regexp in line:
            line = line.split()
            try:
                return datetime.datetime.strptime(line[2][line[2].index("T") + 1:line[2].index(".")], '%H:%M:%S')
            except ValueError:
                return datetime.datetime.strptime(line[1][:line[1].rindex(":")], '%H:%M:%S')
    raise NoSuchLine("Cannot find regex: '{}' in file: {}".format(regexp, file_path))


def compare_power_consumption(command_output, ant_id, action):
    ant_powers = command_output.strip().split()
    ant_powers = ant_powers[:len(ant_powers) - 1]
    for num_of_antena, ant_val in enumerate(ant_powers):
        if str(num_of_antena) == ant_id:
            if action == 'off':
                if str(ant_val) == '0':
                    return
                raise IncorrectValue("Wrong value of ant power. Is {}, but should be {}", ant_val, '0')
            else:
                if str(ant_val) != '0':
                    return
                raise IncorrectValue("Wrong value of ant power. Is {}, but should be {}", ant_val, 'not 0')


def change_and_activate_asirhub_parameter(dn, name, value):
    gnb_asir_hub = GnbAsirHubOperations()
    delta = [{
        'distName': dn,
        'parameters': [{
            'operation': 'update',
            'parameterName': name,
            'value': value
        }]
    }]
    gnb_asir_hub.perform_asir_recommissioning(delta=delta)


def verify_asirhub_parameter(dist_name, parameter, expected_value):
    value = get_asirhub_parameter(dist_name, parameter)
    if value != expected_value:
        raise IncorrectParameterValue("Parameter '{}' should be '{}' but is '{}'".format(parameter, expected_value,
                                                                                         value))


def get_asirhub_parameter(dist_name, parameter):
    enb_asir_hub = GnbAsirHubOperations()
    enb_asir_hub.get_current_scf_file(local_dir_path='/tmp', file_name='temp_asir_scf.xml')
    asir_scf = ET.parse("/tmp/temp_asir_scf.xml")

    if asir_scf.find(".//*[@distName='{}']".format(dist_name)) is not None:
        obj = asir_scf.find(".//*[@distName='{}']".format(dist_name))
        if obj.find(".//*[@name='{}']".format(parameter)) is not None:
            log_info_to_console(asir_scf.find(".//*[@name='{}']".format(parameter)))
            return asir_scf.find(".//*[@name='{}']".format(parameter)).text
        else:
            raise DataNotAvailable(
                "Parameter '{}' doesn't exist in ASiR configuration, "
                "check if parameter name is correct".format(parameter))
    else:
        raise DataNotAvailable(
            "Parameter '{}' doesn't exist in ASiR configuration, check if parameter name is correct".format(parameter))


def get_cable_link_types_for_hubs():
    asir_pattern = r".*(ASIRMOD_\w-\d)"
    gnb_du = GnbDuOperations()
    temp_info = {}
    for asir_module in gnb_du.get_bts_info()['radioModules']['asirmod']:
        hub_serial = asir_module['serialNumber']
        asir_mod = re.match(asir_pattern, str(asir_module['id']['internal']))
        asir_name = asir_mod.group(1)
        temp_info[asir_name] = hub_serial
    log_info_to_console(temp_info)
    hubs_info = {}
    for cable in gnb_du.get_bts_info()['cables']:
        internal = cable['secondEndPointId']['internal']
        asir_mod = re.match(asir_pattern, str(internal))
        asir_name = asir_mod.group(1)
        hubs_info[temp_info[asir_name]] = {}
        hubs_info[temp_info[asir_name]]['cablinkType'] = cable['cablinkType']
        hubs_info[temp_info[asir_name]]['name'] = asir_name
    log_info_to_console(hubs_info)
    return hubs_info
