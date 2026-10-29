import os
import time
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from taf.hw.rf_attenuator import rf_attenuator as attenuator
from taf.rfrl.common_resources.python.report_to_rep import TputKPI
from taf.rfrl.utilities.test_config import get_log_path


def generate_list_of_bts_params_for_attach(cell_ids, attenuator_matrix):
    parameter_list = list()
    for cell in cell_ids:
        parameter_list.append({
            'dist_name': attenuator_matrix[cell]['dist_name'],
            'value': attenuator_matrix[cell]['qrxlevmin_min'],
            'parameter': attenuator_matrix[cell]['parameter']}
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


def adjust_radiorack_attenuation(cell_ids, attenuation_value):
    from common_variables import ATTENUATOR_MATRIX, ATTENUATOR_IPS, ATTENUATOR_PORT, MAX_ATTENUATION_VALUE, VENDOR
    att = attenuator()
    for cell in cell_ids:
        attenuation_ports = ATTENUATOR_MATRIX[cell]['ports']
        for ATTENUATOR_IP in ATTENUATOR_IPS:
            att.setup_attenuator(ip_addr=ATTENUATOR_IP, port=ATTENUATOR_PORT,
                                 attenuation_port_numbers=attenuation_ports,
                                 max_attenuation=MAX_ATTENUATION_VALUE, vendor=VENDOR)
            for port in attenuation_ports:
                att.set_attenuation(port=port, value=attenuation_value)
                time.sleep(1)
                value_port = att.read_attenuation(port=port)
                if int(value_port) != int(attenuation_value):
                    logger.log_warn_to_console("\tDifferent value of attenuation. Expected value: {}, actual value: {}"
                                               .format(attenuation_value, value_port))
                time.sleep(5)


def generate_tput_graph(tput_dl, tput_ul, dt_name, file_name):
    tput_kpi = TputKPI()
    tput_dl = tput_dl.replace(" ", "")
    tput_ul = tput_ul.replace(" ", "")
    tput_kpi._prepare_tput_kpi_data(protocol='TCP', tput_dl=tput_dl, tput_ul=tput_ul, data_transfer_name=dt_name)
    tput_kpi.generate_excel_report(excel_file_path=os.path.join(get_log_path(), "{}.xlsx".format(file_name)))
