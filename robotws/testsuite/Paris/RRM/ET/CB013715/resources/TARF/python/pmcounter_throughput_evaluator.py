import re
import os
import glob
import logging
import os.path
import sys

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

from taf.analyzer.pmcounter import PMCounterLogReader

logging.basicConfig(filename='log_pmcounter_tput.log', level='DEBUG')

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

PREFIX_DISPLAY = "    "
logLevel = "INFO"
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


def logException(functionNameStr, e, silent=False):
    rbi.log("%s(): Exception = <%s>" % (functionNameStr, str(e)), "TRACE")
    if not silent:
        rbi.log_to_console("  %s: exception happened (see log.html)" % functionNameStr)


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        if "--dryrun" not in sys.argv:
            logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        if "--dryrun" not in sys.argv:
            logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


def logger_func(fn):
    def inner(*args, **kwargs):
        func_return = fn(*args, **kwargs)
        if "--dryrun" not in sys.argv:
            logging.debug("\n\tMethod: {0},  \n\t\tPositional Arguments: {1},  \n\t\tKeyword Arguments: {2},\
                           \n\tReturns: {3}".format(fn.__name__, args, kwargs, func_return))
        return func_return
    return inner


def get_directory(file_path):
    """ Returns a path without a fie name
        Args:
            file_path (str): full path to any file
        Returns:
            str: a path without a file name
    """
    split_path = file_path.split('/')
    return "/".join(split_path[:-1])


@log_begin_end_func_name
def get_pi_dict(pi_dir, latest_file, pi_list, ondir=True, pi_file_pattern="PM.BTS-*"):

    """
    Creates a dictionary with following structure:
    {b'2019-04-29 11:15:00+00:00':
        {'M55308C00001':
            {b'MRBTS-1900/NRBTS-1/NRCELL-1':
                b'5670605',
            b'MRBTS-1900/NRBTS-1/NRCELL-2':
                b'5670605'},
        'M55308C00002':
            {b'MRBTS-1900/NRBTS-1/NRCELL-1':
                b'1080114',
            b'MRBTS-1900/NRBTS-1/NRCELL-2':
                b'1080114'},
        'M55308C00003':
            {b'MRBTS-1900/NRBTS-1/NRCELL-1':
                b'90009',
            b'MRBTS-1900/NRBTS-1/NRCELL-2':
                b'90009'}},
    """
    if "[" or "]" in pi_dir:
        square_bracket_regex_pattern = r"[\[|\]]"
        pi_dir = re.sub(square_bracket_regex_pattern, r"[\g<0>]", pi_dir)

    # see https://taf-analyzer-pmcounter.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#
    if ondir:
        file_obj_iterator = (
            open(file_name, 'rb')
            for file_name in glob.glob(os.path.join(pi_dir, pi_file_pattern)))
        counter_results = {}
        for pm_log_entry in PMCounterLogReader(file_obj_iterator=file_obj_iterator):
            ts = str(pm_log_entry.timestamp)
            sample = {}
            for pi in pi_list:
                sample[pi] = pm_log_entry.pm_setup.pi_dict(pi)[pi]
            counter_results[ts] = sample
    else:
        with open(latest_file, 'rb') as file_obj_iterator:
            counter_results = {}
            for pm_log_entry in PMCounterLogReader(file_obj_iterator=[file_obj_iterator]):
                ts = str(pm_log_entry.timestamp)
                sample = {}
                for pi in pi_list:
                    sample[pi] = pm_log_entry.pm_setup.pi_dict(pi)[pi]
                counter_results[ts] = sample

    return counter_results


def get_counter_value_from_dict(pi_dict, pi, dist_name, index=0):
    """
    Gets counter value from given dict. Index is calculated from latest sample to previous.
    I.e. index=0 returns the last value, index=1 returns the one before that."""
    samples = sorted(pi_dict.keys(), reverse=True)
    if dist_name in pi_dict[samples[int(index)]][pi]:
        return int(pi_dict[samples[int(index)]][pi][dist_name])


class PMCounterThroughputCalculator:
    def __init__(self, pm_counter_dir, isclassical):
        self.prefix_dl = 'M55310C010'
        self.prefix_ul = 'M55310C030'
        self.pm_counters_qdu_volume_dl_all_qos = self.generate_pm_counter_id_list_for_all_qos(self.prefix_dl)
        self.pm_counters_qdu_volume_ul_all_qos = self.generate_pm_counter_id_list_for_all_qos(self.prefix_ul)
        self.pm_counters_to_be_extracted = self.pm_counters_qdu_volume_dl_all_qos +\
            self.pm_counters_qdu_volume_ul_all_qos
        pi_file_pattern = "PM.BTS-*" if isclassical else "A20*"
        self.retrieved_pm_counters = get_pi_dict(pi_dir=pm_counter_dir,
                                                 latest_file=pm_counter_dir,
                                                 pi_list=self.pm_counters_to_be_extracted,
                                                 ondir=True,
                                                 pi_file_pattern=pi_file_pattern)

    def generate_pm_counter_id_list_for_all_qos(self, prefix, num_of_qos=20):
        list_of_pm_counter_ids = []
        for qos in range(1, num_of_qos + 1):
            list_of_pm_counter_ids.append("{}{:02d}".format(prefix, qos))
        return list_of_pm_counter_ids

    def get_pdu_volume_low_rlc_by_cell_and_qos(self, cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
                                               interval=1):
        total_pdu_volume = {}
        total_pdu_volume["dl"] = self.get_sum_of_all_values_in_pm_ids(self.pm_counters_qdu_volume_dl_all_qos,
                                                                      cell_dist_name=cell_dist_name,
                                                                      interval=interval)
        total_pdu_volume["ul"] = self.get_sum_of_all_values_in_pm_ids(self.pm_counters_qdu_volume_ul_all_qos,
                                                                      cell_dist_name=cell_dist_name,
                                                                      interval=interval)
        return total_pdu_volume

    def get_sum_of_all_values_in_pm_ids(self, pm_ids, cell_dist_name, interval):
        all_values = []
        for pm_counter in pm_ids:
            try:
                all_values.append(get_counter_value_from_dict(pi_dict=self.retrieved_pm_counters,
                                                              pi=pm_counter,
                                                              dist_name=cell_dist_name,
                                                              index=interval) or 0)
            except KeyError:
                print("PM Counter ID not found in retrieved PM Dictionary")
        return sum(all_values)

    def get_divisor(self, unit):
        divisor = {'kbps': 1e3,
                   'mbps': 1e6,
                   'gbps': 1e9}
        return divisor[unit.lower()]

    def compute_cell_throughput(self, pm_value, traffic_duration_sec, unit='mbps'):
        if pm_value:
            """Convert Bytes to bits"""
            pm_value_in_bits = pm_value * 8
            pm_value_in_desired_units = pm_value_in_bits / self.get_divisor(unit)
            average_throughput_for_pm_interval = pm_value_in_desired_units / traffic_duration_sec
            return average_throughput_for_pm_interval
        else:
            logging.info("Throughput in given PM interval is 0")
            return 0

    def get_average_throughput(self, interval, traffic_duration_sec,
                               unit='Mbps', cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1'):
        throughput = {}
        throughput_volume = self.get_pdu_volume_low_rlc_by_cell_and_qos(cell_dist_name, interval)
        dl_throughput = self.compute_cell_throughput(pm_value=throughput_volume['dl'],
                                                     traffic_duration_sec=traffic_duration_sec,
                                                     unit=unit)
        ul_throughput = self.compute_cell_throughput(pm_value=throughput_volume['ul'],
                                                     traffic_duration_sec=traffic_duration_sec,
                                                     unit=unit)
        print("Observed Average Cell Throughput : \nDL: {} {}\nUL: {} {}".format(dl_throughput, unit,
                                                                                 ul_throughput, unit))
        throughput['throughput_ul'] = ul_throughput
        throughput['throughput_dl'] = dl_throughput
        throughput['unit_dl'] = unit
        throughput['unit_ul'] = unit
        return throughput


def initialize_pmc_throughput_calculator(path_to_pmc_dir, is_classical=True):
    throughput_calc_obj = PMCounterThroughputCalculator(path_to_pmc_dir, is_classical)
    return throughput_calc_obj


def get_average_cell_throughput_for_interval(object,
                                             interval,
                                             traffic_duration_sec,
                                             cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
                                             unit='Mbps'):
    return (object.get_average_throughput(interval=interval,
                                          traffic_duration_sec=traffic_duration_sec,
                                          cell_dist_name=cell_dist_name,
                                          unit=unit))


if __name__ == '__main__':
    ondir = True
    if not ondir:
        global LATEST_FILE
        LATEST_FILE = '/home/ute/csamson/TRACES/2SCE/PMC/gnb_pm_counters/PM.BTS-1.20241222.111000.ANY.xml'
        total_pdu_volume = get_pdu_volume_low_rlc_by_cell_and_qos(interval=1, ondir=ondir, debug=True)
        print(total_pdu_volume)
        dl_throughput = compute_cell_throughput(pm_value=total_pdu_volume['dl'],
                                                traffic_duration_sec=40,
                                                unit='mbps')
        ul_throughput = compute_cell_throughput(pm_value=total_pdu_volume['ul'],
                                                traffic_duration_sec=40,
                                                unit='mbps')
        print("Observed Average Cell Throughput : \nDL: {} {}\nUL: {} {}".format(dl_throughput, 'Mbps',
                                                                                 ul_throughput, 'Mbps'))
    else:
        global PM_COUNTERS_DIR
        # PM_COUNTERS_DIR = '/home/ute/csamson/TRACES/2SCE/PMC/gnb_pm_counters/PM.BTS-1.20241220.145000.ANY.xml'
        PM_COUNTERS_DIR = '/home/ute/csamson/TRACES/2SCE_2/PMC/gnb_pm_counters'
        throughput_calc_obj = initialize_pmc_throughput_calculator(PM_COUNTERS_DIR, True)
        for interval in range(0, 5):
            print("Interval: {}".format(interval))
            get_average_cell_throughput_for_interval(object=throughput_calc_obj, interval=interval,
                                                     traffic_duration_sec=40, unit='Mbps',
                                                     cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1')
            print('---------------')
