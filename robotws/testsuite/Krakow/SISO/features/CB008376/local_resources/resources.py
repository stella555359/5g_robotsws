import json
import os
import psutil
import logging
import shlex
import subprocess
import time
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.helpers.sw_versions import SwVersionFactory
from taf.rfrl.common_resources.python.report_to_rep import TputKPI
from taf.rfrl.utilities.test_config import get_log_path, get_repository_path
from taf.rfrl.utilities.wft_api import WftApi
from taf.hw.rf_attenuator import rf_attenuator


def find_nested_key(data, target_key):
    if isinstance(data, dict):
        for key, value in data.items():
            if key == target_key:
                return value
            elif isinstance(value, (dict, list)):
                result = find_nested_key(value, target_key)
                if result is not None:
                    return result

    elif isinstance(data, list):
        for item in data:
            if isinstance(item, (dict, list)):
                result = find_nested_key(item, target_key)
                if result is not None:
                    return result

    return None


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
    att = rf_attenuator()
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
            if "model" in ATTENUATOR_MATRIX[cell]:
                att.setup_attenuator(ip_addr=ATTENUATOR_MATRIX[cell]['ip_address'],
                                     port=ATTENUATOR_MATRIX[cell]['att_port'],
                                     attenuation_port_numbers=attenuation_ports,
                                     max_attenuation=ATTENUATOR_VALUES[ATTENUATOR_MATRIX[cell]['vendor']]['max'],
                                     vendor=ATTENUATOR_MATRIX[cell]['vendor'], model=ATTENUATOR_MATRIX[cell]['model'])
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
            time.sleep(5)


def generate_tput_graph(tput_dl, tput_ul, dt_name, file_name):
    tput_kpi = TputKPI()
    tput_dl = tput_dl.replace(" ", "")
    tput_ul = tput_ul.replace(" ", "")
    tput_kpi._prepare_tput_kpi_data(protocol='TCP', tput_dl=tput_dl, tput_ul=tput_ul, data_transfer_name=dt_name)
    tput_kpi.generate_excel_report(excel_file_path=os.path.join(get_log_path(), "{}.xlsx".format(file_name)))


def exec_cmd(cmd):
    splitted_cmd = shlex.split(cmd)
    logging.info("Execute:({})".format(splitted_cmd))
    proc = subprocess.Popen(splitted_cmd, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, shell=False)
    stdout, stderr = proc.communicate()
    ret_code = proc.returncode
    assert ret_code == 0, \
        "Error on command {}:ERR CODE={} STDERR={}"\
        .format(cmd, ret_code, stderr)
    logging.info("Return:{}".format(stdout))
    return stdout.decode('utf-8')


def get_running_processes():
    running_processes = []
    for process in psutil.process_iter(['pid', 'name', 'username', 'cmdline']):
        cmdline = " ".join(process.info['cmdline']) if process.info['cmdline'] else None
        running_processes.append({
            'pid': process.info['pid'],
            'name': process.info['name'],
            'username': process.info['username'],
            'cmdline': cmdline
        })
    return running_processes


def find_process_is_running(name="python3 SAS_Sim.py"):
    running_processes = get_running_processes()
    found_process = []
    for process in running_processes:
        if process['cmdline'] and name in process['cmdline']:
            found_process.append(f"PID: {process['pid']}, "
                                 f"Name: {process['name']}, "
                                 f"User: {process['username']}, "
                                 f"CMD: {process['cmdline']}")
    return True if found_process else False


def check_sas_process_is_running():
    if "integration" not in os.uname()[1]:
        if find_process_is_running():
            logger.log_info_to_console("SASSim process is running, IT'S OK")
        else:
            logger.log_warn_to_console("SASsim process is not running!")
            return False
    else:
        return True


def upload_swconfig_to_bts(bts_id=0):
    gnb_du = GnbDuOperations()
    sw_config_path = '{}/testsuite/Krakow/SISO/features/CB008376/local_resources/configs/default_swconfig.txt'\
        .format(get_repository_path())
    gnb_du.upload_swconfig(bts_id=bts_id, sw_config_path=sw_config_path)


def report_problem_with_attach_to_wrong_cell(cell_id):
    cell_id = int(cell_id)
    if cell_id != -1:
        if cell_id > 1000000000:
            bts_id = int(cell_id / 16384)
        else:
            bts_id = int(cell_id / 256)
        warn_printout = "UE attached to cell with id: {}, this cell might be connected to BTS with id: {}"\
            .format(cell_id, bts_id)
        logger.log_warn_to_console(warn_printout)
    else:
        warn_printout = "UE didn't attach to any cell."
        logger.log_warn_to_console(warn_printout)


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


def tput_status(status, cell='LNCEL-10', direction='DL'):
    if str(status).lower() == 'true':
        logger.log_info_to_console('{} t-put for {} is on acceptable level'.format(direction, cell), log_hierarchy=2)
    else:
        logger.log_warn_to_console('{} t-put for {} isn`t on acceptable level'.format(direction, cell), log_hierarchy=2)
        raise Exception('{} t-put for {} is not on acceptable level'.format(direction, cell))
