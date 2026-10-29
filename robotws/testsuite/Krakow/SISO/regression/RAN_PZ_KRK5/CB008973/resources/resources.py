import os
import re
import time
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.exceptions import FileNotFound
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.parsers.snapshot_analyzer import find_mandatory_files_in_snapshot
from taf.rfrl.common_resources.python.report_to_rep import TputKPI
from taf.rfrl.utilities.test_config import get_log_path
from taf.hw.rf_attenuator import rf_attenuator as attenuator
from taf.ul.sc.asimgr import *
from asir_variables import ASIR_SNAPSHOT_FILES


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
    for file_name in ASIR_SNAPSHOT_FILES[files_type]:
        files.append('BTS_{}_RMOD_\\w_\\d{}'.format(asir_serial, file_name))
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


def prepare_cell_to_check(cell_ids):
    tmp = []
    for cell in cell_ids:
        tmp.append(cell[cell.index("-") + 1:])
    return tmp


def get_check_hub_status_via_gnb(list_hub_status, hub_id, dict_check_status):
    check_result = True
    dict_result = {}
    id_found = False
    for hub in list_hub_status:
        if hub.get('id').get('configuration').split('-')[-1] == str(hub_id):
            id_found = True
            dict_hub_status = hub.get('status')
            if 'availabilityStatus' not in dict_hub_status or dict_hub_status['availabilityStatus'] == '':
                dict_hub_status['availabilityStatus'] = 'online'
            for k, v in dict_check_status.items():
                if str(dict_hub_status.get(k)).lower().replace(" ", "") != str(v).lower().replace(" ", ""):
                    check_result = False
                    dict_result[k] = {'real_value': str(
                        dict_hub_status.get(k)), 'expected_val': str(v)}
            break
    if id_found:
        return {'check_result': check_result, 'check_info': 'Check successfully' if check_result else 'Check Failed',
                'dict_result': dict_result}
    return {'check_result': False, 'check_info': 'hub not found with id {}'.format(hub_id)}


def get_ant_mod_id_list(hub_id=None):
    hw_inventory_info = AsiMgr(
        autoconnect=True).get_asi_hw_data_based_on_commissioning()
    print("Hw Inventory Info is: {}".format(hw_inventory_info))
    ant_mod_id_list = []
    for hub in hw_inventory_info:
        if hub_id is None or hub['@id'] == str(hub_id):
            ant_mod_id_list = ant_mod_id_list + \
                              [ant['configDN'] for ant in hub['ANTMOD_R']]
    print("ant_mod_id_list is: {}".format(ant_mod_id_list))
    return ant_mod_id_list


def get_check_all_bbmods_status(list_bbmod_status, dict_check_status):
    check_result = True
    dict_result = {}
    if list_bbmod_status:
        for bbmod in list_bbmod_status:
            dict_bbmod_status = bbmod.get('status')
            if 'availabilityStatus' not in dict_bbmod_status or dict_bbmod_status['availabilityStatus'] == '':
                dict_bbmod_status['availabilityStatus'] = 'online'
            for k, v in dict_check_status.items():
                if str(dict_bbmod_status.get(k)).lower().replace(" ", "") != str(v).lower().replace(" ", ""):
                    check_result = False
                    bbmod_runtime_id = bbmod.get('id').get('runtime').split('-')[-1]
                    if not dict_result.get(bbmod_runtime_id):
                        dict_result[bbmod_runtime_id] = {'runtime_id': bbmod_runtime_id}
                    dict_result[bbmod_runtime_id][k] = \
                        {'real_value': str(dict_bbmod_status.get(k)), 'expected_val': str(v)}
    else:
        check_result = False

    return {'check_result': check_result, 'check_info': 'Check successfully' if check_result else 'Check Failed',
            'dict_result': dict_result}


def generate_list_of_bts_params_for_attach(cell_ids, attenuator_matrix):
    parameter_list = list()
    for cell in cell_ids:
        parameter_list.append({
            'distName': attenuator_matrix[cell]['dist_name'],
            'operation': 'update',
            'parameters': [{
                'operation': 'update',
                'value': attenuator_matrix[cell]['qrxlevmin_min'],
                'parameterName': attenuator_matrix[cell]['parameter']}
            ]}
        )
    return parameter_list


def adjust_dist_name(dist_name, bts_id=0, du_id=0):
    bts = GenericBts()
    return bts.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id)


def generate_attenuator_matrix(attenuator_map, qrxlev):
    attenuator_matrix = {}
    for rat in attenuator_map:
        for cell_id in attenuator_map[rat]:
            bts_patterns = GnbDistNamePatterns if rat == 'NR' else EnbDistNamePatterns
            cell_name = 'NRCELL-{}'.format(cell_id) if rat == 'NR' else 'LNCEL-{}'.format(cell_id)
            dist_name = adjust_dist_name(bts_patterns.cell_dist_name.format({}, {}, cell_id))
            if rat == 'LTE':
                dist_name = '{}/SIB-0'.format(dist_name)
            attenuator_matrix.update({cell_name: attenuator_map[rat][cell_id]})
            attenuator_matrix[cell_name].update({'dist_name': dist_name})
            attenuator_matrix[cell_name].update({'parameter': qrxlev[rat]['parameter_name']})
            attenuator_matrix[cell_name].update({'qrxlevmin_min': qrxlev[rat]['min']})
            attenuator_matrix[cell_name].update({'qrxlevmin_max': qrxlev[rat]['max']})
    return attenuator_matrix


def adjust_attenuation(cell_ids, attenuation_level):
    from common_variables import ATTENUATOR_MATRIX, ATTENUATOR_VALUES
    att = attenuator()
    for cell in cell_ids:
        attenuation_ports = ATTENUATOR_MATRIX[cell]['ports']
        if ATTENUATOR_MATRIX[cell]['vendor'] == "TOPYOUNG":
            att.setup_attenuator(ip_addr=ATTENUATOR_MATRIX[cell]['ip_address'],
                                 port=ATTENUATOR_MATRIX[cell]['att_port'],
                                 attenuation_port_numbers=attenuation_ports,
                                 max_attenuation=ATTENUATOR_VALUES[ATTENUATOR_MATRIX[cell]['vendor']]['max'],
                                 vendor=ATTENUATOR_MATRIX[cell]['vendor'],
                                 model=ATTENUATOR_MATRIX[cell]['model'])
        else:
            att.setup_attenuator(ip_addr=ATTENUATOR_MATRIX[cell]['ip_address'],
                                 port=ATTENUATOR_MATRIX[cell]['att_port'],
                                 attenuation_port_numbers=attenuation_ports,
                                 max_attenuation=ATTENUATOR_VALUES[ATTENUATOR_MATRIX[cell]['vendor']]['max'],
                                 vendor=ATTENUATOR_MATRIX[cell]['vendor'])
        for port in attenuation_ports:
            atten = ATTENUATOR_VALUES[ATTENUATOR_MATRIX[cell]['vendor']][attenuation_level]
            attenuation = atten if ATTENUATOR_MATRIX[cell]['vendor'] == "RADIORACK" else '{}db'.format(atten)
            att.set_attenuation(port=port, value=attenuation)
            time.sleep(1)
            value_port = att.read_attenuation(port=port)
            if int(value_port) != int(atten):
                logger.log_warn_to_console("\tDifferent value of attenuation. Expected value: {}, actual value: {}"
                                           .format(atten, value_port))
            time.sleep(5)


def generate_tput_graph(tput_dl, tput_ul, dt_name, file_name):
    tput_kpi = TputKPI()
    tput_dl = tput_dl.replace(" ", "")
    tput_ul = tput_ul.replace(" ", "")
    tput_kpi._prepare_tput_kpi_data(protocol='TCP', tput_dl=tput_dl, tput_ul=tput_ul, data_transfer_name=dt_name)
    tput_kpi.generate_excel_report(excel_file_path=os.path.join(get_log_path(), "{}.xlsx".format(file_name)))
