import os
import re
import time
import taf.rfrl.utilities.logger.custom_logger as logger
import taf.rfrl.bts.commissioning as comm
from taf.ul.sc.asimgr import *
from taf.hw.rf_attenuator import rf_attenuator as attenuator
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.utilities.logger.custom_logger import log_warn_to_console, log_info_to_console
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.test_config import get_log_path
from taf.ul.sc.gnb.oam.rest.common_oam import CommonOAM
from robot.libraries.BuiltIn import BuiltIn


gnb_oam_ip = BuiltIn().get_variable_value('${tl.gnbs[0].cu.oam_http_connection_details.addr}')
mrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')
nrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')


def check_if_action_should_be_run_before_call(act_action):
    if act_action in ['Lock BBMODs']:
        return True
    return False


def set_sec_additional_action(act_action):
    if act_action == 'Lock BBMODs':
        return 'Unlock BBMODs'
    elif act_action == 'Lock Cell':
        return 'Unlock Cell'
    elif act_action == 'Block Ant':
        return 'Unblock Ant'
    return 'none'


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


def check_scout_scf_id_is_present():
    debug_file_path = os.path.join(get_builtin_value('OUTPUT_DIR'), "debug.log")
    scout_scf_id_pattern = r'\-\s+INFO\s+-\s+SCOUT_SCF_ID\:\s\d+'
    test_start_pattern = r'\-\s+INFO\s+-\s+\+\-\s+START\sTEST'
    with open(debug_file_path, 'r') as debug_file:
        file_content = debug_file.read()
        nr_of_tests = len(re.findall(test_start_pattern, file_content))
        scout_scf_ids = len(re.findall(scout_scf_id_pattern, file_content))
        if nr_of_tests != scout_scf_ids:
            log_warn_to_console("Not all tests get SCOUT_SCF_ID, verify it in debug.log")


def action_with_cells_using_delta(action):
    gnb_cell = GnbCellOperations()
    all_cells_ids = gnb_cell.get_all_cells_id()
    for cell_id in all_cells_ids:
        if action == 'Lock':
            logger.log_info_to_console('Lock cell_id: {}'.format(cell_id))
            gnb_cell.lock_cell(cell_id=cell_id)
            time.sleep(10)
            gnb_cell.verify_cell_statuses(cell_id=cell_id, operational_state='disabled',
                                          procedural_status='initialization required',
                                          availability_status='offline', administrative_state='locked')
        elif action == 'Unlock':
            logger.log_info_to_console('Unlock cell_id: {}'.format(cell_id))
            gnb_cell.unlock_cell(cell_id=cell_id)
        elif action == 'Block':
            logger.log_info_to_console('Block cell_id: {}'.format(cell_id))
            gnb_cell.block_cell(cell_id=cell_id)
            time.sleep(10)
            gnb_cell.verify_cell_is_blocked(cell_id=cell_id)
        elif action == 'Unblock':
            logger.log_info_to_console('Unblock cell_id: {}'.format(cell_id))
            gnb_cell.unblock_cell(cell_id=cell_id)
            time.sleep(10)
            gnb_cell.verify_cell_is_unblocked(cell_id=cell_id)
        else:
            logger.log_warn_to_console('Wrong action type: {}'.format(action))


def action_with_prrhs(action, prrh_id=None):
    gnb_asir = GnbAsirHubOperations()
    if prrh_id is None:
        all_antennas_ids = gnb_asir.get_all_antenna_ids()
    else:
        all_antennas_ids = [int(prrh_id)]
    if action == 'Block':
        for antennas_id in all_antennas_ids:
            gnb_asir.block_antenna(ant_id=antennas_id)
            logger.log_info_to_console('Block pRRH_id: {}'.format(antennas_id))
        gnb_asir.verify_antennas_are_blocked(ant_ids=all_antennas_ids)
        logger.log_info_to_console('All antennas are blocked.')
    elif action == 'Unblock':
        for antennas_id in all_antennas_ids:
            gnb_asir.unblock_antenna(ant_id=antennas_id)
            logger.log_info_to_console('Unblock pRRH_id: {}'.format(antennas_id))
        gnb_asir.verify_all_antennas_are_enabled()
        logger.log_info_to_console('All pRRHs are unblocked')
    elif action == 'Reset':
        for antennas_id in all_antennas_ids:
            logger.log_info_to_console('Reset pRRH_id: {}'.format(antennas_id))
            gnb_asir.reset_antenna(ant_id=antennas_id)
            time.sleep(60)
            last_cleared_alarm = gnb_asir.get_historical_asir_webem_alarms()[-1]
            if not (last_cleared_alarm['fault_id'] == 4480
                    and last_cleared_alarm['source_object'] == 'ASI-1/ASI_R-1/ANTMOD_R-{}'.format(antennas_id)):
                raise Exception('Last cleared fault id alarm is not 4480')
            logger.log_info_to_console('pRRH_id: {} was restarted'.format(antennas_id))


def action_with_asir_hub(action):
    gnb_asir = GnbAsirHubOperations()
    all_hub_ids = gnb_asir.get_all_hub_ids()
    if action == 'Reset':
        for hub_id in all_hub_ids:
            logger.log_info_to_console('Reset hub{}'.format(hub_id))
            gnb_asir.reset_hub(hub_id=hub_id, timeout=360)
            time.sleep(180)
            logger.log_info_to_console('Hub{} was restarted'.format(hub_id))
    elif action == 'Lock':
        expected_statuses = {'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'blocked',
                             'hardwareState': 'working', 'softwareState': 'configured',
                             'activeStatusLEDColor': 'Yellow',
                             'faultStatusLEDColor': 'Off', 'powerStatusLEDColor': 'Green'}
        oam = CommonOAM(oam_ip=gnb_oam_ip, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
        for hub_id in all_hub_ids:
            logger.log_info_to_console('Locking hub{}'.format(hub_id))
            oam.lock_hub(hub_id=hub_id)
        gnb_asir.verify_hubmod_status(hub_ids=[eval(i) for i in all_hub_ids], expected_statuses=expected_statuses)
    elif action == 'Unlock':
        expected_statuses = {'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'unblocked',
                             'hardwareState': 'working', 'softwareState': 'configured', 'activeStatusLEDColor': 'Green',
                             'faultStatusLEDColor': 'Off', 'powerStatusLEDColor': 'Green'}
        oam = CommonOAM(oam_ip=gnb_oam_ip, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
        for hub_id in all_hub_ids:
            logger.log_info_to_console('Unlocking hub{}'.format(hub_id))
            oam.unlock_hub(hub_id=hub_id)
        gnb_asir.verify_hubmod_status(hub_ids=[eval(i) for i in all_hub_ids], expected_statuses=expected_statuses)


def action_with_bbmod(action, bbmod_id):
    runtime_bbmod_id = get_bbmod_runtime_id(bbmod_id=bbmod_id)
    gnb_du = GnbDuOperations()
    if action == 'Lock':
        gnb_du.lock_bbmod(bbmod_id=int(runtime_bbmod_id), timeout=60)
    elif action == 'Unlock':
        gnb_du.unlock_bbmod(bbmod_id=int(runtime_bbmod_id), timeout=60)


def get_all_bbmod_ids():
    gnb_du = GnbDuOperations()
    bts_info = gnb_du.get_bts_info()
    bbmod_ids = []
    for bbmod_info in bts_info['basebandModules']:
        dist_name = bbmod_info['id']['configuration']
        match = re.search(r'BBMOD-(\d+)$', dist_name)
        if match:
            bbmod_id = match.group(1)
            bbmod_ids.append(int(bbmod_id))
    bbmod_ids.sort()
    return bbmod_ids


def get_bbmod_runtime_id(bbmod_id):
    gnb_du = GnbDuOperations()
    bts_info = gnb_du.get_bts_info()
    for bbmod_info in bts_info['basebandModules']:
        dist_name = bbmod_info['id']['configuration']
        match = re.search(r'BBMOD-{}$'.format(bbmod_id), dist_name)
        if match:
            runtime_dist_name = bbmod_info['id']['internal']
            runtime_id = re.search(r'BBMOD_R-(\d+)$', runtime_dist_name).group(1)
            return runtime_id


def get_bbmods_list(str_bbmods_list=None):
    return get_all_bbmod_ids() if str_bbmods_list == 'null' else str_bbmods_list.split()


def remove_eol_from_line(line):
    return str(line)[:-2]


def perform_bts_recommissioning(prefix_tag=None):
    prefix_tag = prefix_tag if prefix_tag != 'null' else None
    comm.perform_full_commissioning_on_classical_gnb(prefix_tag=prefix_tag)
    time.sleep(300)
    comm.perform_full_commissioning_on_gnb_asir_hub(prefix_tag=prefix_tag)
    time.sleep(60)


def generate_tput_graph(tput_dl, tput_ul, dt_name, file_name):
    tput_kpi = TputKPI()
    tput_dl = tput_dl.replace(" ", "")
    tput_ul = tput_ul.replace(" ", "")
    tput_kpi._prepare_tput_kpi_data(protocol='TCP', tput_dl=tput_dl, tput_ul=tput_ul, data_transfer_name=dt_name)
    tput_kpi.generate_excel_report(excel_file_path=os.path.join(get_log_path(), "{}.xlsx".format(file_name)))
