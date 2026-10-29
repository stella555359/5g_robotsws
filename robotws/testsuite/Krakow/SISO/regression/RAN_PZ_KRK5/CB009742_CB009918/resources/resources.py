import json
import re
import time
import xml.etree.ElementTree as ET
from datetime import date, datetime
from math import ceil
from deepdiff import DeepDiff
from taf.hw.pdu import pdu
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from taf.rfrl.bts.commissioning import perform_commissioning_on_gnb_to_onair_state
from taf.rfrl.utilities.test_config import get_repository_path
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console, log_warn_to_console
from taf.sbts.oam.coam.admin.exceptions import IncorrectParameterValue, DataNotAvailable
from taf.hw.rf_attenuator import rf_attenuator as attenuator
from taf.selenium.sc import sc as selenium_sc
from selenium.common.exceptions import ElementClickInterceptedException
from robot.libraries.BuiltIn import BuiltIn

deltas_directory = 'testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB009742_CB009918/deltas/'


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


def adjust_attenuation(cell_ids, attenuation_level):
    from common_variables import ATTENUATOR_MATRIX, ATTENUATOR_PORT, ATTENUATOR_VALUES, VENDOR
    att = attenuator()
    for cell in cell_ids:
        attenuation_ports = ATTENUATOR_MATRIX[cell]['ports']
        for ATTENUATOR_IP in ATTENUATOR_MATRIX[cell]['ip_address']:
            att.setup_attenuator(ip_addr=ATTENUATOR_IP, port=ATTENUATOR_PORT,
                                 attenuation_port_numbers=attenuation_ports,
                                 max_attenuation=ATTENUATOR_VALUES[VENDOR]['max'], vendor=VENDOR)
            if attenuation_level == 'atten_ul':
                for atten_value in ATTENUATOR_MATRIX[cell]['atten_ul']:
                    for port in ATTENUATOR_MATRIX[cell]['atten_ul'][atten_value]:
                        att.set_attenuation(port=port, value=atten_value)
            elif attenuation_level == 'atten_dl':
                for atten_value in ATTENUATOR_MATRIX[cell]['atten_dl']:
                    for port in ATTENUATOR_MATRIX[cell]['atten_dl'][atten_value]:
                        att.set_attenuation(port=port, value=atten_value)
            else:
                attenuation_value = ATTENUATOR_VALUES[VENDOR][attenuation_level]
                for port in attenuation_ports:
                    att.set_attenuation(port=port, value=attenuation_value)
        time.sleep(5)


def load_gnb_delta(delta, bts_id):
    bts_id = int(bts_id)
    gnb_comm = GnbCommissioning(bts_id=bts_id)
    gnb_comm.perform_bts_delta_commissioning(delta=delta, bts_id=bts_id)


def set_lbpsdayofweek(pwr_saving_json):
    pattern = 'lbps_Day_Of_Week'
    day_of_week = date.today().strftime("%a")
    pwr_saving_json = str(pwr_saving_json).replace(pattern, day_of_week)
    return pwr_saving_json


def load_gnb_delta_from_file(delta_json_file, bts_id=0, set_lbpsday='false'):
    delta_json_path = '{}{}{}'.format(get_repository_path(), deltas_directory, delta_json_file)
    delta_file = open(delta_json_path)
    delta_json = delta_file.read()
    if set_lbpsday.lower() == 'true':
        delta_json = set_lbpsdayofweek(pwr_saving_json=delta_json)
    delta_json = json.loads(delta_json)
    load_gnb_delta(delta=delta_json, bts_id=bts_id)


def verify_cells_energy_saving_state(energy_saving_state, cells_id, bts_id=0):
    bts_id = int(bts_id)
    gnb_cell = GnbCellOperations(bts_id=bts_id)
    if not cells_id:
        cells_id = gnb_cell.get_all_cells_id(bts_id=bts_id)
    availability_status = 'offline'
    procedural_status = 'configured'
    operational_state = 'disabled'
    if str(energy_saving_state).lower() == 'notenergysaving':
        availability_status = 'online'
        operational_state = 'enabled'
    elif str(energy_saving_state).lower() == 'reducedenergysaving':
        availability_status = 'online'
        operational_state = 'enabled'
    for cell_id in cells_id:
        gnb_cell.verify_cell_energy_saving_state(bts_id=bts_id, cell_id=int(cell_id),
                                                 energy_saving_state=str(energy_saving_state).lower())
        gnb_cell.verify_cell_statuses(bts_id=bts_id, cell_id=int(cell_id), procedural_status=procedural_status,
                                      availability_status=availability_status, operational_state=operational_state)


def set_actlbenergysaving(bts_id, value):
    bts_id = int(bts_id)
    gnb_asir = GnbAsirHubOperations()
    hub_ids = gnb_asir.get_all_hub_ids(bts_id=bts_id)
    for hub_id in hub_ids:
        delta = [{
            'distName': 'ASI-1/HUBMOD-{}'.format(hub_id),
            'operation': 'update',
            'parameters': [{
                'operation': 'update',
                'parameterName': 'actLbEnergySaving',
                'value': str(value)}]}]

        gnb_asir.perform_asir_recommissioning(delta=delta, bts_id=bts_id)


def verify_asirhub_parameter(bts_id, dist_name, parameter, expected_value):
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.get_current_scf_file(local_dir_path='/tmp', file_name='temp_asir_scf.xml', bts_id=bts_id)
    asir_scf = ET.parse("/tmp/temp_asir_scf.xml")

    if asir_scf.find(".//*[@distName='{}']".format(dist_name)) is not None:
        obj = asir_scf.find(".//*[@distName='{}']".format(dist_name))
        param = obj.find(".//*[@name='{}']".format(parameter))

        if param is not None:
            value = param.text
            if value != expected_value:
                raise IncorrectParameterValue("Parameter '{}' should be '{}' but is '{}' for '{}'".
                                              format(parameter, expected_value, value, dist_name))
            else:
                log_info_to_console("Parameter '{}' has correct '{}' value for '{}'".format(parameter,
                                                                                            value, dist_name))
        else:
            raise DataNotAvailable(
                "Parameter '{}' doesn't exist in ASiR configuration, check if parameter name is correct".format(
                    parameter))
    else:
        raise DataNotAvailable(
            "DistName '{}' doesn't exist in ASiR configuration, check if distName name is correct".format(dist_name))


def check_poe_status(bts_id, antenna_ports):
    bts_id = int(bts_id)
    for antenna_port in antenna_ports:
        verify_asirhub_parameter(bts_id=bts_id, dist_name=antenna_port, parameter='poeStatus',
                                 expected_value='disabled_energy_saving')


def get_hubs_average_power_consumption(bts_id, number_of_samples=3):
    gnb_asir = GnbAsirHubOperations()
    all_hubs_ids = gnb_asir.get_all_hub_ids(bts_id=bts_id)
    hubs_ids = [eval(i) for i in all_hubs_ids]
    power_samples = []
    power_on_hubs = {}
    log_info_to_console('Collecting power measurements')
    for i in range(int(number_of_samples)):
        power_samples.append(gnb_asir.get_power_consumption_of_all_antenna_ports(hubs_id=hubs_ids, bts_id=bts_id))
        time.sleep(5)

    for sample in power_samples:
        for hub_sample in sample:
            power_consumption = 0
            for port in hub_sample['ports']:
                power_consumption += float(port['mAmps']) * float(port['mVolts']) / 1000000
            if hub_sample['hub_id'] not in power_on_hubs.keys():
                power_on_hubs[hub_sample['hub_id']] = []
            power_on_hubs[hub_sample['hub_id']].append(power_consumption)
    log_info_to_console('Collected power samples: {}'.format(power_on_hubs), log_hierarchy=2)
    avg_power = {}
    for hub_id in power_on_hubs:
        avg_power[hub_id] = sum(power_on_hubs[hub_id])/len(power_on_hubs[hub_id])
        log_info_to_console('Average power on hub{} : {}'.format(hub_id, avg_power[hub_id]), log_hierarchy=2)
    return avg_power


def compare_power_consumption(measurements, reduction='10%', hub_id="all"):
    reduction = reduction.replace('%', '')
    if hub_id == "all":
        for hub in measurements['notEnergySaving'].keys():
            calculate_power_consumption(measurements, reduction, hub)
    else:
        calculate_power_consumption(measurements, reduction, hub_id)


def calculate_power_consumption(measurements, reduction, hub):
    if ((100.0 - float(reduction)) * float(measurements['notEnergySaving'][hub])) / 100.0 \
            > float(measurements['EnergySaving'][hub]):
        log_info_to_console("Power consumption is as expected for hub: {}".format(hub))
        log_info_to_console("notEnergySaving: {}\tEnergySaving: {}"
                            .format(measurements['notEnergySaving'][hub], measurements['EnergySaving'][hub]),
                            log_hierarchy=2)
    else:
        warn_printout = "Power consumption is NOT as expected for hub: {}, bigger reduction is expected".format(hub)
        log_warn_to_console(warn_printout)
        log_warn_to_console("notEnergySaving: {}\tEnergySaving: {}"
                            .format(measurements['notEnergySaving'][hub], measurements['EnergySaving'][hub]),
                            log_hierarchy=2)
        raise Exception(warn_printout)


def report_problem_with_attach_to_wrong_cell(cell_id):
    cell_id = int(cell_id)
    if cell_id != -1:
        if cell_id > 1000000000:
            bts_id = int(cell_id / 16384)
        else:
            bts_id = int(cell_id / 256)
        warn_printout = "UE attached to cell with id: {}, this cell might be connected to BTS with id: {}"\
            .format(cell_id, bts_id)
        log_warn_to_console(warn_printout)
        raise Exception(warn_printout)
    else:
        warn_printout = "UE didn't attach to any cell."
        log_warn_to_console(warn_printout)
        raise Exception(warn_printout)


def asir_power(pdu_index, action, pdu_model='HPE'):
    action = str(action).lower()
    pdu_ports = list(BuiltIn().get_variable_value('${tl.pdus['+'{}'.format(pdu_index)+'].pdu_ports}').keys())
    pdu_host = BuiltIn().get_variable_value('${tl.pdus['+'{}'.format(pdu_index)+'].addr}')
    pdu_snmp_user = BuiltIn().get_variable_value('${tl.pdus['+'{}'.format(pdu_index)+'].snmp_user}')
    pdu_alias = 'pdu_alias'
    asir_pdu = pdu()
    asir_pdu.setup_pdu(host=pdu_host, model=pdu_model, snmp_user=pdu_snmp_user, alias=pdu_alias)
    for port in pdu_ports:
        if action == 'off':
            asir_pdu.power_off(port=port, pdu_device=pdu_alias)
        else:
            asir_pdu.power_on(port=port, pdu_device=pdu_alias)
        time.sleep(5)
        port_status = asir_pdu.get_port_status(port=port, pdu_device=pdu_alias)
        if port_status.lower() != action:
            raise Exception("Port {} in {} PDU is in wrong state".format(port, pdu_model))


def verify_cell_id_after_ps_activation(actual_cell_id, origin_cell_id):
    actual_cell_id = int(actual_cell_id)
    origin_cell_id = int(origin_cell_id)
    if actual_cell_id == -1:
        log_info_to_console("UE was detached what is expected.")
    elif actual_cell_id == origin_cell_id:
        raise Exception("UE is still attached to cell {}".format(actual_cell_id))
    else:
        log_warn_to_console("UE is now attached to {}, it should be detached. "
                            "Check this cell id.".format(actual_cell_id))


def get_number_of_rfc_cells_from_asir():
    gnb_asir = GnbAsirHubOperations()
    rfc_cells = gnb_asir.get_rfc_cells()
    if rfc_cells:
        rfc_cells = len(rfc_cells)
    else:
        rfc_cells = 0
    return rfc_cells


def change_and_activate_asirhub_parameter(bts_id, dn, name, value):
    gnb_asir_hub = GnbAsirHubOperations()
    delta = [{
        'distName': dn,
        'parameters': [{
            'operation': 'update',
            'parameterName': name,
            'value': value
        }]
    }]
    gnb_asir_hub.perform_asir_recommissioning(delta=delta, bts_id=bts_id)


def asir_power_saving_action(action, bts_id):
    if action == 'activate':
        value = 'true'
    else:
        value = 'false'
    change_and_activate_asirhub_parameter(bts_id=bts_id, dn='ASI-1', name='actTbEnergySaving', value=value)


def get_nidd_version(xml_file):
    nidd_pattern = r"managedObject.*\sversion=\"(.*)\""
    with open(xml_file, 'r') as scf:
        line = scf.readline()
        while line:
            line = scf.readline()
            if re.search(nidd_pattern, line):
                nidd_version = re.search(nidd_pattern, line).group(1)
                return nidd_version
    raise Exception("Cannot find nidd version in ASIR scf.")


def replace_in_file(file_path, old_text, new_text):
    with open(file_path, 'r+') as file_handler:
        file_content = file_handler.read()
        file_content = re.sub(old_text, new_text, file_content)
        file_handler.seek(0)
        file_handler.truncate()
        file_handler.write(file_content)


def replace_nidd_version(bts_id, xml_file):
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.get_current_scf_file(local_dir_path='/tmp', file_name='temp_asir_scf.xml', bts_id=bts_id)
    new_nidd_version = get_nidd_version(xml_file='/tmp/temp_asir_scf.xml')
    old_nidd_version = get_nidd_version(xml_file=xml_file)
    replace_in_file(file_path=xml_file, old_text=old_nidd_version, new_text=new_nidd_version)


def get_file_path_from_deltas_directory(file_name):
    return '{}{}{}'.format(get_repository_path(), deltas_directory, file_name)


def load_asir_delta_from_file(bts_id, delta_xml_file):
    delta_xml_path = get_file_path_from_deltas_directory(file_name=delta_xml_file)
    replace_nidd_version(bts_id=bts_id, xml_file=delta_xml_path)
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.perform_asir_commissioning(scf_path=delta_xml_path, bts_id=bts_id)


def verify_rfc_cells_energy_saving_state(bts_id, energy_saving_state):
    gnb_asir_hub = GnbAsirHubOperations()
    asir_scf_file = gnb_asir_hub.get_current_scf_file(local_dir_path='/tmp', file_name='temp_asir_scf.xml',
                                                      bts_id=bts_id)
    rfc_cells = gnb_asir_hub.get_all_params_under_class_name(class_name='com.nokia.asi:RFCCELL_R',
                                                             scf_file_path=asir_scf_file)
    for rfc_cell in rfc_cells:
        actual_state = rfc_cell['params']['energySavingState']
        if actual_state != energy_saving_state:
            cell = rfc_cell['params']['configDN']
            raise IncorrectParameterValue("energySavingState for rfc cell '{}' should be {} but is '{}'".
                                          format(cell, energy_saving_state, actual_state))


def update_power_saving_day_of_week_in_asir(delta_xml_file):
    day_of_week = date.today().strftime("%a")
    delta_xml_path = get_file_path_from_deltas_directory(file_name=delta_xml_file)
    delta_xml = ET.parse(delta_xml_path)
    ET.register_namespace('', 'raml21.xsd')
    psgrp = delta_xml.find(".//*[@name='dayOfWeek']")
    psgrp.text = day_of_week
    delta_xml.write(delta_xml_path, default_namespace='')


def get_number_of_rfc_cells(bts_id):
    gnb_asir_hub = GnbAsirHubOperations()
    asir_scf_file = gnb_asir_hub.get_current_scf_file(local_dir_path='/tmp', file_name='temp_asir_scf.xml',
                                                      bts_id=bts_id)
    rfc_cells = gnb_asir_hub.get_all_params_under_class_name(class_name='com.nokia.asi:RFCCELL',
                                                             scf_file_path=asir_scf_file)
    rfc_cells_count = {
        'configuredRfcSccCount': 0,
        'configuredTddRfcCellCount': 0,
        'configuredFddRfcCellCount': 0
    }
    for rfc_cell in rfc_cells:
        if rfc_cell['params']['technology'] == 'LTE':
            if rfc_cell['params']['dlCenterFreq'] == rfc_cell['params']['ulCenterFreq']:
                rfc_cells_count['configuredTddRfcCellCount'] += 1
            else:
                rfc_cells_count['configuredFddRfcCellCount'] += 1
        elif '5G' in rfc_cell['params']['technology']:
            if float(rfc_cell['params']['dlCenterFreq']) < 1e+6:
                rfc_cells_count['configuredRfcSccCount'] += ceil(int(rfc_cell['params']['dlBandwidth'][:-3]) / 5)
            elif float(rfc_cell['params']['dlCenterFreq']) < 3e+6:
                rfc_cells_count['configuredRfcSccCount'] += ceil(int(rfc_cell['params']['dlBandwidth'][:-3]) / 10)
            elif float(rfc_cell['params']['dlCenterFreq']) < 6e+6:
                rfc_cells_count['configuredRfcSccCount'] += ceil(int(rfc_cell['params']['dlBandwidth'][:-3]) / 20)
            elif float(rfc_cell['params']['dlCenterFreq']) > 20e+6:
                rfc_cells_count['configuredRfcSccCount'] += ceil(int(rfc_cell['params']['dlBandwidth'][:-3]) / 200)
    return rfc_cells_count


def verify_number_of_rfc_cells(bts_id):
    gnb_du = GnbCommissioning(bts_id=bts_id)
    asirmod_r_params = gnb_du.get_all_params_under_class_name(class_name='com.nokia.srbts.eqmr:ASIRMOD_R',
                                                              scf_export_type='runtimeObjects', bts_id=bts_id)
    expected_rfc_cells_count = get_number_of_rfc_cells(bts_id=bts_id)
    rfc_cells_count = {
        'configuredRfcSccCount': 0,
        'configuredTddRfcCellCount': 0,
        'configuredFddRfcCellCount': 0
    }
    for asirmod_r in asirmod_r_params:
        for cell_count in rfc_cells_count:
            rfc_cells_count[cell_count] += int(asirmod_r['params'][cell_count])
    if DeepDiff(rfc_cells_count, expected_rfc_cells_count):
        raise Exception("Fetched RFC cell count: {} differs from expected RFC count: {}"
                        .format(rfc_cells_count, expected_rfc_cells_count))


def verify_tb_energy_saving_enabled(bts_id, state='true'):
    gnb_du = GnbCommissioning(bts_id=bts_id)
    asirmod_r_params = gnb_du.get_all_params_under_class_name(class_name='com.nokia.srbts.eqmr:ASIRMOD_R',
                                                              scf_export_type='runtimeObjects', bts_id=bts_id)
    for asirmod_r in asirmod_r_params:
        actual_state = asirmod_r['params']['tbEnergySavingEnabled']
        if actual_state != state.lower():
            raise Exception("tbEnergySavingEnabled should be {} but is {}".format(state.lower(), actual_state))


def reset_all_asir_hubs(bts_id):
    gnb_asir_hub = GnbAsirHubOperations()
    all_hub_ids = gnb_asir_hub.get_all_hub_ids(bts_id=bts_id)
    for hub_id in all_hub_ids:
        log_info_to_console('Reset hub{} in bts{}'.format(hub_id, bts_id))
        gnb_asir_hub.reset_hub(hub_id=hub_id, bts_id=bts_id)
        log_info_to_console('Hub{} was restarted in bts_id{}'.format(hub_id, bts_id))


def verify_all_rfc_cells_are_operational(bts_id):
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.verify_all_rfccell_channels_are_enabled(bts_id=bts_id)


def change_bts_configuration(bts_id=0, prefix_tag=None, wait_for_cells=True):
    gnb_du = GnbDuOperations()
    gnb_cell = GnbCellOperations()
    sw_config_path = get_repository_path() + '/commissionings/Krakow/swconfig/default_swconfig.txt'
    gnb_du.upload_swconfig(sw_config_path=sw_config_path, bts_id=bts_id)
    perform_commissioning_on_gnb_to_onair_state(bts_id=bts_id, asir_hub=True, prefix_tag=prefix_tag)
    gnb_du.wait_for_site_to_be_onair(bts_id=bts_id)
    if wait_for_cells:
        gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, timeout=900)


def tput_status(status, cell='a', direction='DL'):
    if str(status).lower() == 'true':
        log_info_to_console('{} t-put for {} is on acceptable level'.format(direction, cell), log_hierarchy=2)
    else:
        log_warn_to_console('{} t-put for {} is not on acceptable level'.format(direction, cell), log_hierarchy=2)
        raise Exception('{} t-put for {} is not on acceptable level'.format(direction, cell))


def get_counter(counter='M40020C2', counter_group_name='SBTS_ASIRMOD_Energy_Monitoring', bts_id=0):
    gnb_pm = GnbPmCounter()
    response = gnb_pm.get_counter(counter_ids=counter, bts_id=bts_id)
    mrbts = adjust_dist_name(dist_name='MRBTS-{}', bts_id=bts_id)
    counter_values = dict()
    if get_sw_release_name() in ["SBTS24R1"]:
        for asirmod in response['BTS']['BTS'][mrbts]:
            last_timestamp = sorted(response['BTS']['BTS'][mrbts][asirmod][counter_group_name][counter].keys())[-1]
            last_counter_value = response['BTS']['BTS'][mrbts][asirmod][counter_group_name][counter][last_timestamp]
            counter_values[asirmod] = last_counter_value
            ts = time.time()
            log_info_to_console('Counter {} collected from PM {} for {}'
                                .format(counter, datetime.fromtimestamp(int(last_timestamp)), asirmod))
            if (int(ts) - int(last_timestamp) - 900) > 900:
                raise Exception('PM timestamp {} is too old'.format(datetime.fromtimestamp(int(last_timestamp))))
    else:
        for asirmod in response['BTS'][mrbts]['EQM-1']['APEQM-1']:
            last_timestamp = \
                sorted(response['BTS'][mrbts]['EQM-1']['APEQM-1'][asirmod][counter_group_name][counter].keys())[-1]
            last_counter_value = response['BTS'][mrbts]['EQM-1']['APEQM-1'][asirmod][counter_group_name][counter][
                last_timestamp]
            counter_values[asirmod] = last_counter_value
            ts = time.time()
            log_info_to_console('Counter {} collected from PM {} for {}'
                                .format(counter, datetime.fromtimestamp(int(last_timestamp)), asirmod))
            if (int(ts)-int(last_timestamp)-900) > 900:
                raise Exception('PM timestamp {} is too old'.format(datetime.fromtimestamp(int(last_timestamp))))
    return counter_values


def get_sw_release_name():
    gnb_du = GnbDuOperations()
    return gnb_du.get_bts_sw_release_name()


def get_asir_web_info(bts_id):
    oam_addr = \
        BuiltIn().get_variable_value('${tl.gnbs[' + '{}'.format(bts_id) + '].cu.oam_http_connection_details.addr}')
    username = \
        BuiltIn().get_variable_value('${tl.gnbs[' + '{}'.format(bts_id) + '].cu.oam_http_connection_details.username}')
    password = \
        BuiltIn().get_variable_value('${tl.gnbs[' + '{}'.format(bts_id) + '].cu.oam_http_connection_details.password}')
    url = 'https://{}:3601/#/login'.format(oam_addr)
    return url, username, password


def set_asir_parameter_via_gui(bts_id, dist_name, abbreviation, new_value, prevalidate=True):
    alias = 'Firefox'
    url, username, password = get_asir_web_info(bts_id=bts_id)
    web_selenium_sc = selenium_sc()
    web_selenium_sc.login(url=url, username=username, password=password, browser='Firefox', alias=alias)
    try:
        web_selenium_sc.set_parameter(dist_name=dist_name, abbreviation=abbreviation, new_value=new_value,
                                      prevalidate=prevalidate, sc=alias)
    except ElementClickInterceptedException as e:
        log_warn_to_console('ElementClickInterceptedException occurred, might occur because of wrong validation pop-up')
    web_selenium_sc.logout(sc=alias)
    web_selenium_sc.close_browser(sc=alias)


def get_asir_parameter_via_gui(bts_id, dist_name, abbreviation):
    alias = 'Firefox'
    url, username, password = get_asir_web_info(bts_id=bts_id)
    web_selenium_sc = selenium_sc()
    web_selenium_sc.login(url=url, username=username, password=password, browser='Firefox', alias=alias)
    value = web_selenium_sc.get_parameter(dist_name=dist_name, abbreviation=abbreviation, sc=alias)
    web_selenium_sc.logout(sc=alias)
    web_selenium_sc.close_browser(sc=alias)
    return value


def verify_that_no_asir_crash_occured(bts_id, timeout):
    asir_hub = GnbAsirHubOperations()
    gnb_cell = GnbCellOperations()
    while timeout > 0:
        gnb_cell.verify_all_cells_are_onair(bts_id=bts_id)
        asir_hub.verify_only_allowed_alarms_are_active(allowed_alarms=None, bts_id=bts_id)
        asir_hub.verify_status_of_all_asir_cells_is_operational(bts_id=bts_id)
        time.sleep(10)
        timeout -= 10
        log_info_to_console('So far all cells are up, no unexpected ASIR alarms, waiting for next check')
    time.sleep(10)


def change_bts_parameter_via_gui(dist_name, parameter, value, bts_id=0):
    bts_comm = GnbCommissioning()
    try:
        bts_comm.change_parameter_via_gui(dist_name=dist_name, parameter=parameter, value=value, bts_id=bts_id)
        log_info_to_console('Parameter {} changed.'.format(parameter))
        return 'Parameter {} changed via Webem.'.format(parameter)
    except IndexError:
        msg = 'Parameter {} was not found via Webem.'.format(parameter)
        log_info_to_console(msg)
        return msg
