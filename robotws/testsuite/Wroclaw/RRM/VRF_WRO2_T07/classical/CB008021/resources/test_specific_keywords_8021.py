import re
import time
import math
import statistics
from taf.config.scf import scf
from datetime import datetime, timezone
from taf.sbts.oam.coam.admin import admin as coam
from ute_common_admin.exception import AdminApiProcedureFailureException
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.CB009333.resources.test_specific_keywords_9333 import SKIP_REL_ERR
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as rue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.uuf.checkpoints import verify_on_air
from testsuite.Wroclaw.RRM.resources.scf_verification.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common as common

taf_ue = rue_utils.get_library_instance('taf.ue')

l1l2 = L1L2()
tcpdump = TcpdumpSmod()
scf = scf()
atten = Attenuator(with_initialisation=False)
au = AdminUtils()
api = coam()

cell_id_8021_1 = 1
cell_id_8021_2 = 2
pm_interval_8021 = 5
num_of_cells_8021 = 3
num_of_ues_8021 = 2

first_valid_prb_in_list_8021 = 10
last_valid_prb_in_list_8021 = 96
sinr_range_start_8021 = -10
sinr_range_end_8021 = 35
rssi_range_start_8021 = -120
rssi_range_end_8021 = -75

tput_duration_8021 = '90s'
tput_dl_8021 = '5Mbits/sec'
tput_ul_8021 = '5Mbits/sec'
tput_protocol_8021 = 'tcp'
parallel_streams_ul_8021 = '1'
ue_capabilities_8021 = 'REAL_UE_SA'

first_counter_set_8021 = 'M55360C00007'
last_counter_set_8021 = 'M55360C00098'

first_counter_set_8021_range2 = 'M55360C01007'
last_counter_set_8021_range2 = 'M55360C01098'

CONDITIONAL_RELEASE_25R2 = int('SBTS25R2'[4:].replace('R', ''))
CONDITIONAL_RELEASE_25R3 = int('SBTS25R3'[4:].replace('R', ''))

try:
    cell_1_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[1].attenuation_ports
    cell_2_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[0].attenuation_ports
    cell_3_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[2].attenuation_ports
except AttributeError:
    assert False, 'No attenuator ports configured for separate cells!'

mrbts_id = tl.tl.gnbs[0].instance_id
nrbts_id = tl.tl.gnbs[0].global_bts_id

cell_to_lock = [u'/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-' + str(nrbts_id) + '/NRCELL_R-3']

bts_prefix_from_tl = 'MRBTS-{}/NRBTS-{}'.format(str(mrbts_id), str(nrbts_id))

prach_pucch_f1_params_revert = {'actNrUlRipMeasurement': 'enabledWithoutPRACH_PUCCH_F1', 'miNrRip': '15min',
                                'adjustPrachThresholdOffset': '0', 'pfaTargetPRACH': '0.0005',
                                'maxNumOfRrcSA': '275', 'maxNumOfRrcCGRPSA': '275', 'actInterFreqHoSA': 'false',
                                'actInterRatHoSA': 'true', 'actInterRatHoSADlDataForward': 'true',
                                f'{bts_prefix_from_tl}/NRPMRNL-1/NRPMCCP-1/actNrUlRipCounter':
                                ['Scheduled PUSCH PRBs', 'Other PUCCH formats', 'PUCCH F1']}


prach_pucch_f1_params = {'actNrUlRipMeasurement': 'enabledWithPRACH_PUCCH_F1', 'miNrRip': '5min',
                         'adjustPrachThresholdOffset': '-30', 'pfaTargetPRACH': '0.0001',
                         'actInterFreqHoSA': 'false',
                         'actInterRatHoSA': 'false', 'actInterRatHoSADlDataForward': 'false',
                         f'{bts_prefix_from_tl}/NRPMRNL-1/NRPMCCP-1/actNrUlRipCounter':
                         ['Scheduled PUSCH PRBs', 'Unscheduled PUSCH PRBs', 'Other PUCCH formats',
                          'PUCCH F1', 'PRACH with Preamble', 'PRACH without Preamble']}

without_prach_params = {'actNrUlRipMeasurement': 'enabledWithoutPRACH', 'miNrRip': '5min',
                        'adjustPrachThresholdOffset': '-30', 'pfaTargetPRACH': '0.0001',
                        'actInterFreqHoSA': 'false',
                        'actInterRatHoSA': 'false', 'actInterRatHoSADlDataForward': 'false',
                        f'{bts_prefix_from_tl}/NRPMRNL-1/NRPMCCP-1/actNrUlRipCounter':
                        ['Scheduled PUSCH PRBs', 'Unscheduled PUSCH PRBs', 'Other PUCCH formats', 'PUCCH F1']}

without_pucch_params = {'actNrUlRipMeasurement': 'enabledWithoutPUCCH_F1', 'miNrRip': '5min',
                        'adjustPrachThresholdOffset': '-30', 'pfaTargetPRACH': '0.0001',
                        'actInterFreqHoSA': 'false',
                        'actInterRatHoSA': 'false', 'actInterRatHoSADlDataForward': 'false',
                        f'{bts_prefix_from_tl}/NRPMRNL-1/NRPMCCP-1/actNrUlRipCounter':
                        ['Scheduled PUSCH PRBs', 'Unscheduled PUSCH PRBs', 'Other PUCCH formats', 'PRACH with Preamble',
                         'PRACH without Preamble']}

without_pucch_and_prach_params = {'actNrUlRipMeasurement': 'enabledWithoutPRACH_PUCCH_F1', 'miNrRip': '5min',
                                  'adjustPrachThresholdOffset': '-30', 'pfaTargetPRACH': '0.0001',
                                  'actInterFreqHoSA': 'false',
                                  'actInterRatHoSA': 'false', 'actInterRatHoSADlDataForward': 'false',
                                  f'{bts_prefix_from_tl}/NRPMRNL-1/NRPMCCP-1/actNrUlRipCounter':
                                  ['Scheduled PUSCH PRBs', 'Unscheduled PUSCH PRBs']}


@logged_keyword
def get_counters(counter_ids):
    counters_dict = {}
    connection = api.connect_to(name='counter_gathering')
    try:
        counters_dict = api.get_pm_counters(counter_ids=counter_ids, connection=connection)
    except AdminApiProcedureFailureException as e:
        blog(e, level='ERROR')
    finally:
        api.teardown(connection=connection)
    return counters_dict


@logged_keyword
def SCF_qrxlevmin_setup():
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-51994/NRBTS-51994/NRCELL-1',
                          'qRxLevMin', '-45')
    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    blog("------------------Preconditions for qrxlevmin fulfilled-------------------------")


@logged_keyword
def SCF_qrxlevmin_revert():
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-51994/NRBTS-51994/NRCELL-1',
                          'qRxLevMin', '-65')
    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    blog("------------------QRXlevmin reverted -------------------------")


@logged_keyword
def get_prbs_from_dict(counters_dict, name):
    prbs = []
    for counter_value in counters_dict.values():
        if counter_value:
            prbs.append(int(list(counter_value.values())[0]))

    blog("Median of {} prbs is {}".format(name, statistics.median(prbs)))
    return prbs


@logged_keyword
def check_prbs(prbs):
    assert all(prbs[first_valid_prb_in_list_8021:last_valid_prb_in_list_8021])


@logged_keyword
def start_logging(pcap_filename):
    l1l2.start_gnbmirroring(filename='CB008021_{}.pcap'.format(pcap_filename), capturing_time_seconds='2')


@logged_keyword
def stop_logging():
    l1l2.stop_gnbmirroring_and_download_logs()


def calculate_prb_values_to_dbm(prb, bts_sw_release):
    prb_value = int(float(prb))
    if bts_sw_release >= CONDITIONAL_RELEASE_25R2:
        prb_value = -prb_value
    if prb_value > 10:
        prb_dbm_value = round(10 * math.log10(1000 * prb_value * pow(10, -18)), 2)
    else:
        prb_dbm_value = 0
    return prb_dbm_value


@logged_keyword
def check_if_value_in_range(value, range_start, range_end):
    assert round(int(float(value))) in range(range_start, range_end)


@logged_keyword
def check_if_l1l2_prbs_and_counter_prbs_values_are_in_range(counter_prbs_1, counter_prbs_2, l1l2_prbs):
    min_prbs_counter_value, max_prbs_counter_value = -130, -60
    min_prbs_counter_value_2, max_prbs_counter_value_2 = -130, -60
    min_prbs_l1l2_value, max_prbs_l1l2_value = -130, -60

    assert check_if_all_values_are_in_range(counter_prbs_1, min_prbs_counter_value, max_prbs_counter_value), "cell1"
    assert check_if_all_values_are_in_range_2(counter_prbs_2, min_prbs_counter_value_2, max_prbs_counter_value_2), \
        "cell2"
    assert check_if_all_values_are_in_range_2(l1l2_prbs, min_prbs_l1l2_value, max_prbs_l1l2_value), "L1L2"


@logged_keyword
def check_if_l1l2_prbs_and_counter_prbs_values_are_in_range_with_additional_counters(counter_prbs_cell1_range1,
                                                                                     counter_prbs_cell2_range1,
                                                                                     counter_prbs_cell1_range2,
                                                                                     counter_prbs_cell2_range2,
                                                                                     l1l2_prbs):
    min_counter_value_1, max_counter_value_1 = -130, -60
    min_counter_value_2, max_counter_value_2 = -130, -60
    min_l1l2_value, max_l1l2_value = -130, -60

    assert check_if_all_values_are_in_range(counter_prbs_cell1_range1, min_counter_value_1, max_counter_value_1), \
        "cell1 - first counter range"
    assert check_if_all_values_are_in_range_2(counter_prbs_cell2_range1, min_counter_value_2, max_counter_value_2), \
        "cell2 - first counter range"
    assert check_if_all_values_are_in_range(counter_prbs_cell1_range2, min_counter_value_1, max_counter_value_1), \
        "cell1 - second counter range"
    assert check_if_all_values_are_in_range_2(counter_prbs_cell2_range2, min_counter_value_2, max_counter_value_2), \
        "cell2 - second counter range"
    assert check_if_all_values_are_in_range_2(l1l2_prbs, min_l1l2_value, max_l1l2_value), "L1L2"


@logged_keyword
def check_if_all_values_are_in_range(input_list, min_value, max_value):
    return all(max_value > x > min_value and x != 0 for x in input_list)


@logged_keyword
def check_if_all_values_are_in_range_2(input_list, min_value, max_value):
    return all(max_value > x > min_value and x < 1 for x in input_list)


@logged_keyword
def get_prb_values_for_pusch(pcap_file):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    frames = log_finder(pcap_file, 'uldata_puschreceiverespps', 'UlData_PuschReceiveRespPs_t',
                        message_type_pattern='empty')
    result = []
    prbs = {}

    for prb in range(first_valid_prb_in_list_8021, last_valid_prb_in_list_8021):
        prbs['list' + str(prb)] = []

    for msg in frames:
        for prb in range(first_valid_prb_in_list_8021, last_valid_prb_in_list_8021):
            prb_value = calculate_prb_values_to_dbm(msg.find('noisePerPrb_item_{}*'.format(prb)).first()['val'],
                                                    bts_sw_release)
            if prb_value:
                prbs['list' + str(prb)].append(prb_value)
    for prb in range(first_valid_prb_in_list_8021, last_valid_prb_in_list_8021):
        if prbs['list' + str(prb)]:
            result.append(statistics.median(prbs['list' + str(prb)]))
    if result:
        return result
    else:
        blog("Cannot find all PRBs! Result: {}".format(result), level='ERROR')
        assert False


@logged_keyword
def get_average_prb_values_for_pusch(pcap_file):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    frames = log_finder(pcap_file, 'uldata_puschreceiverespps', 'UlData_PuschReceiveRespPs_t',
                        message_type_pattern='empty')
    prbs = 0
    prb_counter = 0
    number_of_prbs = 105
    for msg in frames:
        for prb in range(number_of_prbs):
            calculated_prb = calculate_prb_values_to_dbm(msg.find('noisePerPrb_item_{}*'.format(prb)).first()['val'],
                                                         bts_sw_release)
            if calculated_prb:
                prbs += calculated_prb
                prb_counter += 1
    result = prbs / prb_counter
    blog("Result: {}".format(result), level='ERROR')
    return result


@logged_keyword
def get_sinr(pcap_file):
    frames = log_finder(pcap_file, 'uldata_puschreceiverespps', 'UlData_PuschReceiveRespPs_t',
                        message_type_pattern='empty')
    sinr_list = []
    for msg in frames:
        try:
            sinr = msg.find('sinr_item_0*').first()['val']
            if sinr and int(float(sinr)) != -255:
                sinr_list.append(float(sinr))
        except IndexError:
            pass
    blog("SINR median:{}".format(statistics.median(sinr_list)))
    return statistics.median(sinr_list)


@logged_keyword
def get_rssi(pcap_file):
    frames = log_finder(pcap_file, 'uldata_puschreceiverespps', 'UlData_PuschReceiveRespPs_t',
                        message_type_pattern='empty')
    rssi_list = []
    for msg in frames:
        try:
            rssi = msg.find('rssi*').first()['val']
            if rssi:
                rssi_list.append(float(rssi))
        except IndexError:
            pass
    blog("RSSI median:{}".format(statistics.median(rssi_list)))
    return statistics.median(rssi_list)


@logged_keyword
def get_peak_metric(pcap_file, peak_metric_max_value=1e-9):
    frames = log_finder(pcap_file, 'uldata_prachreceiveind', 'UlData_PrachReceiveInd_t',
                        message_type_pattern='empty')
    for msg in frames:
        peak_metric = msg.find('peakMetric*')
        if peak_metric:
            peak_metric_value = float(peak_metric[0]['val'])
            blog("peakMetric found: {}".format(peak_metric_value))
            assert peak_metric_value < peak_metric_max_value, \
                "peak_metric value should be lower than {}".format(peak_metric_max_value)
            return peak_metric_value
    blog("Cannot find peakMetric in PrachReceiveInd!", level='ERROR')
    assert False


@logged_keyword
def uplink_interference_and_noise_measurement(pcap_filename, reserve_ue=True):
    time_sleep = 30
    try:
        atten.initialise_attenuator()
        if reserve_ue:
            rue_utils.require_ues(num_of_ues_8021, capabilities=ue_capabilities_8021)
        atten.set_attenuation(value_string='90', ports=cell_1_attenuator_ports)
        atten.set_attenuation(value_string='0', ports=cell_2_attenuator_ports)
        atten.set_attenuation(value_string='90', ports=cell_3_attenuator_ports)
        rue_utils.attach_one_ue('2')
        blog("UE2 - attached")
        time.sleep(5)
        atten.set_attenuation(value_string='0', ports=cell_1_attenuator_ports)
        atten.set_attenuation(value_string='10', ports=cell_2_attenuator_ports)
        rue_utils.attach_one_ue('1')
        blog("UE1 - attached")
        time.sleep(time_sleep)
        rue_utils.start_ul_data_transfer_on_ues(duration=tput_duration_8021, throughput=tput_ul_8021,
                                                protocol=tput_protocol_8021, parallel_streams=parallel_streams_ul_8021,
                                                num_of_ues=num_of_ues_8021)
        rue_utils.start_dl_data_transfer_on_ues(duration=tput_duration_8021, throughput=tput_ul_8021,
                                                protocol=tput_protocol_8021, parallel_streams=parallel_streams_ul_8021,
                                                num_of_ues=num_of_ues_8021)
        time.sleep(time_sleep)
        start_logging(pcap_filename)
        time.sleep(time_sleep)
        stop_logging()
        atten.set_attenuation(value_string='0', ports=cell_1_attenuator_ports)
        atten.set_attenuation(value_string='0', ports=cell_2_attenuator_ports)
        atten.set_attenuation(value_string='0', ports=cell_3_attenuator_ports)
        rue_utils.detach_ues(num_of_ues_8021)
    except BaseException as e:
        try:
            rue_utils.detach_ues(num_of_ues_8021)
            stop_logging()
        except BaseException as e2:
            pass
        raise e


def find_value_inside_brackets(string):
    return re.search(r'\((.*?)\)', string).group(1)


def log_finder(pcap_file, tfilter, message_name_pattern, message_type_pattern):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=pcap_file, tshark_filter=tfilter, lua=None)
        return finder.find_all(PcapMessageMatcher(message_name_pattern, message_type_pattern=message_type_pattern))


def check_if_counter_incremented(counter_value_list, target_counter_value):
    return any(counter_value >= target_counter_value for counter_value in counter_value_list)


@logged_keyword
def verify_pm_counters(pm_counters_list, target_counter_value=1):
    pm_counters_path = pm.collect_counters()
    pm_counters = pm.get_relevant_pm_counters(pi_dir=pm_counters_path, counter_ids=pm_counters_list)
    blog('Test revelant counters:{}'.format(str(pm_counters)))
    if not pm_counters:
        raise Exception('PM counter dict is empty, there are no {} counters collected on BTS'.format(pm_counters_list))
    for counter in pm_counters.values():
        incremented = False
        for cell, counter_value_list in iter(counter.items()):
            incremented = check_if_counter_incremented(counter_value_list, target_counter_value)
            if incremented:
                break
        assert incremented, 'PM Counters not incremented'


@logged_keyword
def generate_counters_string(first_counter, last_counter):
    prefix_counter_length = 7
    postfix_counter_length = 5
    prefix = first_counter[:prefix_counter_length]
    first_counter_postfix = int(first_counter[prefix_counter_length:])
    last_counter_postfix = int(last_counter[prefix_counter_length:])

    counter_list = []

    if not prefix == last_counter[:prefix_counter_length]:
        blog("Prefix from first counter: {0} is not equal to prefix from second counter: {1}"
             .format(prefix, last_counter[:prefix_counter_length]), level='ERROR')
        raise UserWarning

    for counter_iterator in range((last_counter_postfix - first_counter_postfix) + 1):
        counter_value = str(first_counter_postfix + counter_iterator).zfill(postfix_counter_length)
        counter_list.append(prefix + counter_value)
    counters_string = ",".join(counter_list)
    return counters_string


def remove_whitespaces_from_list(list_with_whitespaces):
    new_list = []
    for entry in list_with_whitespaces:
        new_list.append(entry.replace(" ", "_"))
    return new_list


def get_pm_counters_for_cell(raw_pm_counters, cell_id, pm_periods):
    if 'CELLS' in raw_pm_counters['BTS']:
        pm_counters = raw_pm_counters['BTS']['CELLS'][cell_id]['NRRIP']
    else:
        pm_counters = raw_pm_counters['BTS']['MRBTS-{}'.format(mrbts_id)]['NRBTS-{}'.format(nrbts_id)][cell_id]['NRRIP']
    return generate_counter_dictionary(pm_counters, pm_periods)


def merge_dictionaries(first_dict, second_dict):
    return dict(list(first_dict.items()) + list(second_dict.items()))


def generate_counter_dictionary(pm_counters, pm_periods):
    sorted_counter_names = sorted(list(pm_counters.keys()))
    output_counters_dictionary = {}
    for counter_name in sorted_counter_names:
        counter_values = pm_counters[counter_name]
        counter_content_dict = {}
        for counter_timestamp, counter_value in counter_values.items():
            if counter_timestamp == str(pm_periods[0]):
                date = utc_to_local(datetime.fromtimestamp(int(counter_timestamp)))
                dict_template = {date: counter_value}
                if not counter_content_dict:
                    counter_content_dict.update(dict_template)
                else:
                    counter_content_dict = merge_dictionaries(counter_content_dict, dict_template)
        output_counters_dictionary.update({counter_name: counter_content_dict})

    if not output_counters_dictionary:
        blog("There are no counters for provided timestamp!"
             " Did you set correct timestamp?", level='ERROR')

    return output_counters_dictionary


def find_pm_counters_for_cell(pm_counters_dict, cell_id, pm_periods):
    return get_pm_counters_for_cell(pm_counters_dict, "NRCELL-" + str(cell_id), pm_periods)


def utc_to_local(utc_dt):
    return utc_dt.replace(tzinfo=timezone.utc).strftime('%Y-%m-%d %H:%M:%S')


def check_preconditions_8021_A1():
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRPMRNL-1', 'miNrRip', '5min')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-1', 'adjustPrachThresholdOffset', '-30')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-2', 'adjustPrachThresholdOffset', '-30')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-3', 'adjustPrachThresholdOffset', '-30')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-4', 'adjustPrachThresholdOffset', '-30')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-1', 'pfaTargetPRACH', '0.0001')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-2', 'pfaTargetPRACH', '0.0001')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-3', 'pfaTargetPRACH', '0.0001')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-4', 'pfaTargetPRACH', '0.0001')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109', 'actInterFreqHoSA', 'false')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109', 'actInterRatHoSA', 'false')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109', 'actInterRatHoSADlDataForward', 'false')
    if bts_sw_release >= CONDITIONAL_RELEASE_25R3:
        ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRPMRNL-1/NRPMCCP-1',
                              'actNrUlRipCounter',
                              ['PUCCH F1', 'PRACH with Preamble', 'PRACH without Preamble', 'Unscheduled PUSCH PRBs',
                               'Scheduled PUSCH PRBs', 'Other PUCCH formats'])
    else:
        ds.add_param_to_delta('MRBTS-55109/NRBTS-55109', 'actNrUlRipMeasurement', 'enabledWithPRACH_PUCCH_F1')
    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    blog("Preconditions fulfilled")


def check_preconditions_8021_A4():
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRPMRNL-1', 'miNrRip', '5min')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-1', 'adjustPrachThresholdOffset', '-30')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-2', 'adjustPrachThresholdOffset', '-30')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-3', 'adjustPrachThresholdOffset', '-30')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-4', 'adjustPrachThresholdOffset', '-30')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-1', 'pfaTargetPRACH', '0.0001')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-2', 'pfaTargetPRACH', '0.0001')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-3', 'pfaTargetPRACH', '0.0001')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRCELL-4', 'pfaTargetPRACH', '0.0001')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109', 'actInterFreqHoSA', 'false')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109', 'actInterRatHoSA', 'false')
    ds.add_param_to_delta('MRBTS-55109/NRBTS-55109', 'actInterRatHoSADlDataForward', 'false')
    if bts_sw_release >= CONDITIONAL_RELEASE_25R3:
        ds.add_param_to_delta('MRBTS-55109/NRBTS-55109/NRPMRNL-1/NRPMCCP-1',
                              'actNrUlRipCounter',
                              ['Unscheduled PUSCH PRBs', 'Scheduled PUSCH PRBs', 'Other PUCCH formats'])
    else:
        ds.add_param_to_delta('MRBTS-55109/NRBTS-55109', 'actNrUlRipMeasurement', 'enabledWithoutPRACH_PUCCH_F1')
    ds.validate_scf(skip_parameter_relation_errors=SKIP_REL_ERR)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=SKIP_REL_ERR)
    verify_on_air()
    blog("Preconditions fulfilled")


def backup_current_scf_8021():
    return common.backup_current_scf()


def revert_scf_8021(scf_to_revert):
    return common.revert_scf(scf_to_revert)
