import os
import re
import ast
import json
import time
from datetime import datetime
from prrh_actions import action_with_prrhs
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from taf.rfrl.utilities.test_config import get_repository_path
from taf.rfrl.utilities.robot.general import get_builtin_value


deltas_directory = 'testsuite/Krakow/RRM/RAN_PZ/regression/KRK5/CB008285_CB008294/deltas/'


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


def load_gnb_delta(delta, bts_id):
    bts_id = int(bts_id)
    gnb_comm = GnbCommissioning()
    gnb_comm.perform_bts_delta_commissioning(delta=delta, bts_id=bts_id)


def load_gnb_delta_from_file(delta_json_file, bts_id=0):
    delta_json_path = '{}{}{}'.format(get_repository_path(), deltas_directory, delta_json_file)
    delta_file = open(delta_json_path)
    delta_json = delta_file.read()
    delta_json = json.loads(delta_json)
    load_gnb_delta(delta=delta_json, bts_id=bts_id)


def check_amf_nglink_status(status, only_default=False):
    gnb_comm = GnbCommissioning()
    for amf in gnb_comm.get_all_params_under_class_name(class_name='com.nokia.srbts.nrbts:SERVEDAMF'):
        amf_obj = re.search('SERVEDAMF-\\d+', amf['dist_name'])
        if only_default and amf['params']['defaultAMF'].lower() == 'true':
            if amf['params']['administrativeState'].lower() == status.lower():
                break
            else:
                raise Exception('Default NG link is in wrong `{}` state for {}, expected `{}` state.'
                                .format(amf['params']['administrativeState'].lower(), amf_obj.group(0), status.lower()))
        elif amf['params']['administrativeState'].lower() != status.lower():
            raise Exception('NG link is in wrong `{}` state for {}, expected `{}` state.'
                            .format(amf['params']['administrativeState'].lower(), amf_obj.group(0), status.lower()))


def create_dir_for_additional_logs():
    log_path = os.path.join(get_builtin_value('OUTPUT_DIR'), 'Additional_logs')
    os.system('rm -rf {}'.format(log_path))
    os.makedirs(log_path)
    return log_path


def clear_btslog_dir(btslog_dir_path='/tmp/btslog2'):
    if not os.path.exists(btslog_dir_path):
        os.makedirs(btslog_dir_path)
    else:
        for file_name in os.listdir(btslog_dir_path):
            os.remove(os.path.join(btslog_dir_path, file_name))


def get_5gm_file(fivegm_filename):
    extension = '.5gm'
    try:
        all_files = os.listdir(fivegm_filename)
        fivegm_files = [file for file in all_files if file.endswith(extension)]
        return fivegm_files[0]
    except OSError as e:
        raise Exception('Error: {}. Does .5gm file exist in that folder?'.format(e))


def dcap_save_to_json(decoded_content, filename):
    if isinstance(decoded_content, str):
        # evaluate str as dict to save properly as json
        decoded_content = ast.literal_eval(decoded_content)
    try:
        with open(filename, 'w', encoding='utf-8') as json_file:
            json.dump(decoded_content, json_file, indent=4)
        logger.log_info_to_console('Emil data has been saved to {} successfully'.format(filename))
    except Exception as e:
        raise Exception('Error during saving data to {}: {}'.format(filename, e))
    return filename


def check_call_flow(emil_json_file):
    from common_variables import CALL_FLOW_MESSAGE_PATTERNS
    with open(emil_json_file) as file_handler:
        file_content = file_handler.read()
        for message in CALL_FLOW_MESSAGE_PATTERNS:
            pattern = re.compile('{}'.format(message))
            find_ret = pattern.findall(file_content)
            if len(find_ret) >= 1:
                logger.log_info_to_console('Message `{}` found in Emil log'.format(message))
            else:
                raise Exception('Message `{}` NOT found in Emil log'.format(message))


def get_counters(test_case, bts_id=0):
    from common_variables import COUNTERS
    mrbts = adjust_dist_name(dist_name='MRBTS-{}', bts_id=bts_id)
    gnb_pm = GnbPmCounter()
    counters_values = dict()
    # last_timestamp = None
    for counter in COUNTERS[test_case].keys():
        counter_key = counter
        pattern = r'([M|C|\d+]+)_\d+'
        search_result = re.search(pattern, counter)
        if search_result:
            counter = search_result.group(1)
        response = gnb_pm.get_counter(counter_ids=counter, bts_id=bts_id)
        counter_values_for_pm = eval(COUNTERS[test_case][counter_key]['formula'])
        last_timestamp = sorted(counter_values_for_pm.keys())[-1]
        last_counter_value = counter_values_for_pm[last_timestamp]
        last_timestamp = str(datetime.fromtimestamp(int(last_timestamp)))
        if last_timestamp not in counters_values.keys():
            counters_values[last_timestamp] = dict()
        counters_values[last_timestamp][counter_key] = last_counter_value
    logger.log_info_to_console('Counters for {} collected in PM period:\t{}'.format(mrbts, counters_values),
                               log_hierarchy=3)
    return counters_values


def verify_counters(test_case, bts_id=0):
    from common_variables import COUNTERS
    gnb_counters = get_counters(test_case=test_case, bts_id=bts_id)
    for timestamp in gnb_counters.keys():
        for counter in COUNTERS[test_case].keys():
            condition = '{} {} {}'.format(gnb_counters[timestamp][counter], COUNTERS[test_case][counter]['condition'],
                                          COUNTERS[test_case][counter]['value'])
            if eval(condition):
                logger.log_info_to_console('Counter {} is ok, `{}`'.format(counter, condition))
            else:
                raise Exception('Counter {} is NOT ok, `{}`'.format(counter, condition))
    return gnb_counters


def verify_error_slogan(error):
    error = "".join(str(error).split())
    slogans = [
        'ModificationofrestrictedparameterNRCELL-251-\\[sCellOnlyFr2Sa\\]isnotallowed',
        'ModificationofrestrictedparameterNRCELL-252-\\[sCellOnlyFr2Sa\\]isnotallowed'
    ]
    for slogan in slogans:
        pattern = re.compile('{}'.format(slogan))
        find_ret = pattern.findall(error)
        if len(find_ret) >= 1:
            logger.log_info_to_console('Error `{}` found in reported fault'.format(slogan))
        else:
            raise Exception('Error `{}` NOT found in reported {} fault'.format(slogan, error))


def check_time_to_next_pm_period(time_buffer=300, interval=15):
    timestamp_now = int(time.time())
    time_to_pm = int(interval) * 60 - (timestamp_now % (int(interval) * 60))
    if time_to_pm < time_buffer:
        logger.log_info_to_console('It\'s only {}s to next PM period, so waiting for next one'.format(time_to_pm),
                                   log_hierarchy=2)
        time.sleep(time_to_pm)
    else:
        logger.log_info_to_console('It\'s {}s to next PM period, so more than needed buffer {}s, no waiting is needed'.
                                   format(time_to_pm, time_buffer), log_hierarchy=2)


def verify_pmi(counters):
    for pm_period in counters.keys():
        sum_of_pmi = counters[pm_period]['M55303C03001'] + counters[pm_period]['M55303C03000']
        if sum_of_pmi >= 1:
            logger.log_info_to_console('Sum of PMI={} is acceptable'.format(sum_of_pmi))
        else:
            raise Exception('Sum of PMI={} is not correct. Verify counters: M55303C03001 and M55303C03000'
                            .format(sum_of_pmi))


def upload_swconfig_to_bts():
    gnb_du = GnbDuOperations()
    sw_config_path = '{}/commissionings/Krakow/swconfig/default_swconfig.txt'.format(get_repository_path())
    gnb_du.upload_swconfig(sw_config_path=sw_config_path)
