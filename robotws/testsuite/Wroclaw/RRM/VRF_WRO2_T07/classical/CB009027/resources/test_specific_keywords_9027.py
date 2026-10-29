import time
import math
import statistics
from taf.config.scf import scf
from datetime import datetime, timezone
from taf.sbts.oam.coam.admin import admin as coam
from ute_common_admin.exception import AdminApiProcedureFailureException
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as rue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod

taf_ue = rue_utils.get_library_instance('taf.ue')

tcpdump = TcpdumpSmod()
scf = scf()
atten = Attenuator(with_initialisation=False)
au = AdminUtils()
api = coam()

cell_id_9027_1 = 1
cell_id_9027_2 = 2
pm_interval_9027 = 5
num_of_cells_9027 = 2
num_of_ues_9027 = 1

first_valid_prb_in_list_9027 = 6
last_valid_prb_in_list_9027 = 96
sinr_range_start_9027 = -10
sinr_range_end_9027 = 35
rssi_range_start_9027 = -120
rssi_range_end_9027 = -75

tput_duration_9027 = '30s'
tput_dl_9027 = '20 Mbits/sec'
tput_ul_9027 = '10 Mbits/sec'
tput_protocol_9027 = 'tcp'
parallel_streams_ul_9027 = '1'
ue_capabilities_9027 = 'REAL_UE_SA'

first_counter_set_9027 = 'M55360C00006'
last_counter_set_9027 = 'M55360C00098'

first_counter_set_9027_range2 = 'M55360C01006'
last_counter_set_9027_range2 = 'M55360C01098'

try:
    rus = tl.tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus
    cell_1_attenuator_ports = rus[0].attenuation_ports
    cell_2_attenuator_ports = rus[1].attenuation_ports
except AttributeError:
    raise AttributeError('No attenuator ports configured for separate cells!')

mrbts_id = tl.tl.gnbs[0].instance_id
nrbts_id = tl.tl.gnbs[0].global_bts_id

cell_to_lock = [u'/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-' + str(nrbts_id) + '/NRCELL_R-3']

bts_prefix_from_tl = 'MRBTS-{}/NRBTS-{}'.format(str(mrbts_id), str(nrbts_id))

prach_pucch_f1_params = {'actNrUlRipMeasurement': 'enabledWithPRACH_PUCCH_F1', 'miNrRip': '5min',
                         'adjustPrachThresholdOffset': '-30', 'pfaTargetPRACH': '0.0001',
                         'maxNumOfRrcSA': '1', 'maxNumOfRrcCGRPSA': '1', 'actInterFreqHoSA': 'false',
                         'actInterRatHoSA': 'false', 'actInterRatHoSADlDataForward': 'false',
                         f'{bts_prefix_from_tl}/NRPMRNL-1/NRPMCCP-1/actNrUlRipCounter':
                         ['Scheduled PUSCH PRBs', 'Unscheduled PUSCH PRBs', 'Other PUCCH formats',
                          'PUCCH F1', 'PRACH with Preamble', 'PRACH without Preamble']}

without_prach_params = {'actNrUlRipMeasurement': 'enabledWithoutPRACH', 'miNrRip': '5min',
                        'adjustPrachThresholdOffset': '-30', 'pfaTargetPRACH': '0.0001',
                        'maxNumOfRrcSA': '1', 'maxNumOfRrcCGRPSA': '1', 'actInterFreqHoSA': 'false',
                        'actInterRatHoSA': 'false', 'actInterRatHoSADlDataForward': 'false',
                        f'{bts_prefix_from_tl}/NRPMRNL-1/NRPMCCP-1/actNrUlRipCounter':
                        ['Scheduled PUSCH PRBs', 'Unscheduled PUSCH PRBs', 'Other PUCCH formats', 'PUCCH F1']}

without_pucch_params = {'actNrUlRipMeasurement': 'enabledWithoutPUCCH_F1', 'miNrRip': '5min',
                        'adjustPrachThresholdOffset': '-30', 'pfaTargetPRACH': '0.0001',
                        'maxNumOfRrcSA': '1', 'maxNumOfRrcCGRPSA': '1', 'actInterFreqHoSA': 'false',
                        'actInterRatHoSA': 'false', 'actInterRatHoSADlDataForward': 'false',
                        f'{bts_prefix_from_tl}/NRPMRNL-1/NRPMCCP-1/actNrUlRipCounter':
                        ['Scheduled PUSCH PRBs', 'Unscheduled PUSCH PRBs', 'Other PUCCH formats', 'PRACH with Preamble',
                         'PRACH without Preamble']}

without_pucch_and_prach_params = {'actNrUlRipMeasurement': 'enabledWithoutPRACH_PUCCH_F1', 'miNrRip': '5min',
                                  'adjustPrachThresholdOffset': '-30', 'pfaTargetPRACH': '0.0001',
                                  'maxNumOfRrcSA': '1', 'maxNumOfRrcCGRPSA': '1', 'actInterFreqHoSA': 'false',
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
def get_prbs_from_dict(counters_dict, name):
    prbs = []
    for counter_value in counters_dict.values():
        if counter_value:
            prbs.append(int(list(counter_value.values())[-1]))

    blog("Median of {} prbs is {}".format(name, statistics.median(prbs)))
    return prbs


def calculate_prb_values_to_dbm(prb):
    prb_value = int(prb)
    return round(10 * math.log10(1000 * prb_value * pow(10, -18)), 2) if prb_value > 10 else 0


@logged_keyword
def check_if_counter_prbs_values_are_in_range(counter_prbs_cell1_range1,
                                              counter_prbs_cell2_range1,
                                              counter_prbs_cell1_range2,
                                              counter_prbs_cell2_range2):

    min_counter_value_1, max_counter_value_1 = -122, -60
    min_counter_value_2, max_counter_value_2 = -122, -60

    assert check_if_all_values_are_in_range(counter_prbs_cell1_range1, min_counter_value_1, max_counter_value_1), \
        "Counter value assertion failed for cell1 - first counter range"
    assert check_if_all_values_are_in_range_2(counter_prbs_cell2_range1, min_counter_value_2, max_counter_value_2), \
        "Counter value assertion failed for cell2 - first counter range"

    #                            Commented out until we get a second UE back on the line
    # assert check_if_all_values_are_in_range(counter_prbs_cell1_range2, min_counter_value_1, max_counter_value_1), \
    #     "Counter value assertion failed for cell1 - second counter range"
    # assert check_if_all_values_are_in_range_2(counter_prbs_cell2_range2, min_counter_value_2, max_counter_value_2), \
    #     "Counter value assertion failed for cell2 - second counter range"


@logged_keyword
def check_if_all_values_are_in_range(input_list, min_value, max_value):
    return all(max_value > x > min_value and x != 0 for x in input_list)


@logged_keyword
def check_if_all_values_are_in_range_2(input_list, min_value, max_value):
    return all(max_value > x > min_value and x < 1 for x in input_list)


@logged_keyword
def attach_to_cell_at_ports(attenuation_ports):
    atten.initialise_attenuator()
    rue_utils.attach_one_ue('1')
    time.sleep(2)
    atten.set_attenuation(value_string='25', ports=attenuation_ports)
    time.sleep(2)
    atten.set_attenuation(value_string='0', ports=attenuation_ports)


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


@logged_keyword
def generate_cb009027_counter_list():
    return generate_counters_string(first_counter_set_9027, last_counter_set_9027)


def get_pm_counters_for_cell(raw_pm_counters, cell_id, pm_periods):
    if 'CELLS' in raw_pm_counters['BTS']:
        pm_counters = raw_pm_counters['BTS']['CELLS'][cell_id]['NRRIP']
    else:
        pm_counters = raw_pm_counters['BTS']['MRBTS-{}'.format(mrbts_id)]['NRBTS-{}'.format(nrbts_id)][cell_id]['NRRIP']
    return generate_counter_dictionary(pm_counters, pm_periods)


def generate_counter_dictionary(pm_counters, pm_periods):
    sorted_counter_names = sorted(list(pm_counters.keys()))
    output_counters_dictionary = {}

    for counter_name in sorted_counter_names:
        counter_content_dict = get_counter_contents_at_timestamp(pm_counters[counter_name], pm_periods[0])
        output_counters_dictionary.update({counter_name: counter_content_dict})

    assert output_counters_dictionary, "There are no counters for provided timestamp! Did you set correct timestamp?"
    return output_counters_dictionary


def get_counter_contents_at_timestamp(counter_values, timestamp):
    counter_content_dict = {}

    for counter_timestamp, value in counter_values.items():
        if counter_timestamp == str(timestamp):
            date = timestamp_to_local_time(counter_timestamp)
            counter_content_dict.update({date: value})
            return counter_content_dict


def find_pm_counters_for_cell(pm_counters_dict, cell_id, pm_periods):
    return get_pm_counters_for_cell(pm_counters_dict, "NRCELL-" + str(cell_id), pm_periods)


def utc_to_local(utc_dt):
    return utc_dt.replace(tzinfo=timezone.utc).strftime('%Y-%m-%d %H:%M:%S')


def timestamp_to_local_time(timestamp):
    return utc_to_local(datetime.fromtimestamp(int(timestamp)))
