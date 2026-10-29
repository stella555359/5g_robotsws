import re
import os
import glob
import logging
import os.path
import sys
import traceback

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

from taf.analyzer.pmcounter import PMCounterLogReader

logging.basicConfig(filename='log_pmcounter_bler.log', level='DEBUG')

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


def bler_logException(functionNameStr, e, silent=False):
    rbi.log("%s(): Exception = <%s>" % (functionNameStr, str(e)), "TRACE")
    if not silent:
        rbi.log_to_console("  %s: exception happened (see log.html)" % functionNameStr)
        traceback.print_exc()  # Print detailed traceback for debugging


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


class PMCounterBlerCalculator:
    """
    M55300C00000: PDSCH initial transmissions with 64QAM MCS table using MCS 0
    M55300C01000: Successful PDSCH transmissions by initial transmission with 64QAM MCS table using MCS 0
    M55300C02000: Successful PDSCH transmissions by any transmission with 64QAM MCS table using MCS 0
    M55300C03000: Unsuccessful PDSCH transmissions by last HARQ reTx with 64QAM MCS table using MCS 0
    M55300C04000: PDSCH initial transmissions with 256QAM MCS table using MCS 0
    M55300C05000: Successful PDSCH transmissions by initial transmission with 256QAM MCS table using MCS 0
    M55300C06000: Successful PDSCH transmissions by any transmission with 256QAM MCS table using MCS 0
    M55300C07000: Unsuccessful PDSCH transmissions by last HARQ reTx with 256QAM MCS table using MCS 0

    M55302C11000 : PUSCH_CP_INI_256TBL_MCS_00
    M55302C13000 : PUSCH_CP_SUCC_INI_256TBL_MCS00
    M55302C12000 : PUSCH_CP_UNSUCC_256TBL_MCS_00
    M55302C14000 : PUSCH_CP_SUCC_ANY_256TBL_MCS00
    """

    def __init__(self, pm_counter_dir, isclassical):
        self.prefix_dl_tx_initial = 'M55300C040'
        self.prefix_dl_tx_initial_success = 'M55300C050'
        self.prefix_dl_tx_success = 'M55300C060'
        self.prefix_dl_tx_unsuccess = 'M55300C070'
        self.prefix_ul_tx_initial = 'M55302C110'
        self.prefix_ul_tx_initial_success = 'M55302C130'
        self.prefix_ul_tx_success = 'M55302C140'
        self.prefix_ul_tx_unsuccess = 'M55302C120'

        self.pm_counters_dl_all_initial = self.generate_pm_counter_id_list_for_allmcs(self.prefix_dl_tx_initial)
        self.pm_counters_dl_tx_success_initial =\
            self.generate_pm_counter_id_list_for_allmcs(self.prefix_dl_tx_initial_success)
        self.pm_counters_dl_tx_success =\
            self.generate_pm_counter_id_list_for_allmcs(self.prefix_dl_tx_success)
        self.pm_counters_dl_tx_unsuccess =\
            self.generate_pm_counter_id_list_for_allmcs(self.prefix_dl_tx_unsuccess)
        self.pm_counters_ul_all_initial = self.generate_pm_counter_id_list_for_allmcs(self.prefix_ul_tx_initial,
                                                                                      num_of_mcs=27)
        self.pm_counters_ul_tx_success_initial =\
            self.generate_pm_counter_id_list_for_allmcs(self.prefix_ul_tx_initial_success, num_of_mcs=27)
        self.pm_counters_ul_tx_success = self.generate_pm_counter_id_list_for_allmcs(self.prefix_ul_tx_success,
                                                                                     num_of_mcs=27)
        self.pm_counters_ul_tx_unsuccess =\
            self.generate_pm_counter_id_list_for_allmcs(self.prefix_ul_tx_unsuccess, num_of_mcs=27)
        local_pm_counters_to_be_extracted = self.pm_counters_dl_all_initial + self.pm_counters_dl_tx_success_initial
        local_pm_counters_to_be_extracted = local_pm_counters_to_be_extracted + self.pm_counters_ul_all_initial
        local_pm_counters_to_be_extracted = local_pm_counters_to_be_extracted + self.pm_counters_ul_tx_success_initial
        local_pm_counters_to_be_extracted = local_pm_counters_to_be_extracted + self.pm_counters_dl_tx_unsuccess
        local_pm_counters_to_be_extracted = local_pm_counters_to_be_extracted + self.pm_counters_dl_tx_success
        local_pm_counters_to_be_extracted = local_pm_counters_to_be_extracted + self.pm_counters_ul_tx_success
        local_pm_counters_to_be_extracted = local_pm_counters_to_be_extracted + self.pm_counters_ul_tx_unsuccess
        self.pm_counters_to_be_extracted = local_pm_counters_to_be_extracted
        pi_file_pattern = "PM.BTS-*" if isclassical else "A20*"
        self.retrieved_pm_counters = get_pi_dict(pi_dir=pm_counter_dir,
                                                 latest_file=pm_counter_dir,
                                                 pi_list=self.pm_counters_to_be_extracted,
                                                 ondir=True,
                                                 pi_file_pattern=pi_file_pattern)

    @staticmethod
    def generate_pm_counter_id_list_for_allmcs(prefix, num_of_mcs=28):
        list_of_pm_counter_ids = []
        for mcs in range(1, num_of_mcs + 1):
            list_of_pm_counter_ids.append("{}{:02d}".format(prefix, mcs))
        return list_of_pm_counter_ids

    def get_dl_ul_bler_by_cell_and_mcs(self, cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1', interval=1):
        total_bler = {"dl_tx_initial": self.get_sum_of_all_values_in_pm_ids(self.pm_counters_dl_all_initial,
                                                                            cell_dist_name=cell_dist_name,
                                                                            interval=interval),
                      "dl_tx_success_init": self.get_sum_of_all_values_in_pm_ids(self.pm_counters_dl_tx_success_initial,
                                                                                 cell_dist_name=cell_dist_name,
                                                                                 interval=interval),
                      "dl_tx_success": self.get_sum_of_all_values_in_pm_ids(self.pm_counters_dl_tx_success,
                                                                            cell_dist_name=cell_dist_name,
                                                                            interval=interval),
                      "dl_tx_unsuccess": self.get_sum_of_all_values_in_pm_ids(self.pm_counters_dl_tx_unsuccess,
                                                                              cell_dist_name=cell_dist_name,
                                                                              interval=interval),
                      "ul_tx_initial": self.get_sum_of_all_values_in_pm_ids(self.pm_counters_ul_all_initial,
                                                                            cell_dist_name=cell_dist_name,
                                                                            interval=interval),
                      "ul_tx_success_init": self.get_sum_of_all_values_in_pm_ids(self.pm_counters_ul_tx_success_initial,
                                                                                 cell_dist_name=cell_dist_name,
                                                                                 interval=interval),
                      "ul_tx_success": self.get_sum_of_all_values_in_pm_ids(self.pm_counters_ul_tx_success,
                                                                            cell_dist_name=cell_dist_name,
                                                                            interval=interval),
                      "ul_tx_unsuccess": self.get_sum_of_all_values_in_pm_ids(self.pm_counters_ul_tx_unsuccess,
                                                                              cell_dist_name=cell_dist_name,
                                                                              interval=interval),
                      }
        return total_bler

    def get_sum_of_all_values_in_pm_ids(self, pm_ids, cell_dist_name, interval):
        all_values = []
        for pm_counter in pm_ids:
            try:
                all_values.append(get_counter_value_from_dict(pi_dict=self.retrieved_pm_counters,
                                                              pi=pm_counter,
                                                              dist_name=cell_dist_name,
                                                              index=interval) or 0)
            except KeyError as e:
                print("PM Counter ID not found in retrieved PM Dictionary")
                bler_logException("get_sum_of_all_values_in_pm_ids", e)
        return sum(all_values)

    @staticmethod
    def compute_cell_bler(pm_value_init, pm_value_success_init):
        if pm_value_init:
            bler_for_pm_interval = 100 * (pm_value_init - pm_value_success_init) / pm_value_init
            return bler_for_pm_interval
        else:
            logging.info("Bler in given PM interval is 100")
            return 100

    @staticmethod
    def compute_cell_residual_bler(pm_value_success, pm_value_unsuccess):
        if (pm_value_success + pm_value_unsuccess) > 0:
            bler_for_pm_interval = 100 * pm_value_unsuccess / (pm_value_success + pm_value_unsuccess)
            return bler_for_pm_interval
        else:
            logging.info("Bler in given PM interval is 100")
            return 100

    def get_bler(self, interval, unit='%', cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1'):
        bler = {}
        total_bler = self.get_dl_ul_bler_by_cell_and_mcs(cell_dist_name, interval)
        dl_initial_bler = self.compute_cell_bler(pm_value_init=total_bler['dl_tx_initial'],
                                                 pm_value_success_init=total_bler['dl_tx_success_init'])
        ul_initial_bler = self.compute_cell_bler(pm_value_init=total_bler['ul_tx_initial'],
                                                 pm_value_success_init=total_bler['ul_tx_success_init'])
        dl_residual_bler = self.compute_cell_residual_bler(pm_value_success=total_bler['dl_tx_success'],
                                                           pm_value_unsuccess=total_bler['dl_tx_unsuccess'])
        ul_residual_bler = self.compute_cell_residual_bler(pm_value_success=total_bler['ul_tx_success'],
                                                           pm_value_unsuccess=total_bler['ul_tx_unsuccess'])
        print("Observed Initial BLER Cell Throughput : \nDL: {} {}\nUL: {} {}".format(dl_initial_bler, unit,
                                                                                      ul_initial_bler, unit))
        print("Observed Residual BLER Cell Throughput : \nDL: {} {}\nUL: {} {}".format(dl_residual_bler, unit,
                                                                                       ul_residual_bler, unit))
        bler['bler_dl'] = dl_initial_bler
        bler['bler_ul'] = ul_initial_bler
        bler['residual_bler_dl'] = dl_residual_bler
        bler['residual_bler_ul'] = ul_residual_bler
        bler['unit_dl'] = unit
        bler['unit_ul'] = unit
        return bler


def initialize_pmc_bler_calculator(path_to_pmc_dir, is_classical=True):
    bler_calc_obj = PMCounterBlerCalculator(path_to_pmc_dir, is_classical)
    return bler_calc_obj


def get_cell_bler_for_interval(object,
                               interval,
                               cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
                               unit='%'):
    return (object.get_bler(interval=interval,
                            cell_dist_name=cell_dist_name,
                            unit=unit))


if __name__ == '__main__':
    ondir = True
    if not ondir:
        global LATEST_FILE
        LATEST_FILE = '/home/ute/csamson/TRACES/2SCE/PMC/gnb_pm_counters/PM.BTS-1.20241222.111000.ANY.xml'
        PM_COUNTERS_DIR = '/home/ute/csamson/TRACES/2SCE_2/PMC/gnb_pm_counters'
        bler_calc_obj = initialize_pmc_bler_calculator(PM_COUNTERS_DIR, True)
        total_bler = bler_calc_obj.get_dl_ul_bler_by_cell_and_mcs(interval=1, ondir=ondir, debug=True)
        print(total_bler)
        dl_initial_bler = bler_calc_obj.compute_cell_bler(pm_value_init=total_bler['dl_tx_initial'],
                                                          pm_value_success_init=total_bler['dl_tx_success_init'])
        # ul_throughput = bler_calc_obj.compute_cell_throughput(pm_value=total_bler['dl_tx_success_init'],
        #                                                       unit='%')
        ul_initial_bler = 0
        print("Observed Bler Cell Throughput : \nDL: {} {}\nUL: {} {}".format(dl_initial_bler, '%',
                                                                              ul_initial_bler, '%'))
    else:
        # global PM_COUNTERS_DIR
        # PM_COUNTERS_DIR = '/home/ute/csamson/TRACES/2SCE_2/PMC/gnb_pm_counters'
        PM_COUNTERS_DIR = '/home/ute/csamson/7-20-UTE5GCLASSTL031/tools_for-vm-ute/TLConfig/' \
                          'CrtResults_20250625_183252/CB013715_C_template_test_NSA_F/PMC/gnb_pm_counters'

        bler_calc_obj = initialize_pmc_bler_calculator(PM_COUNTERS_DIR, True)
        for interval in range(0, 1):
            print("Interval: {}".format(interval))
            get_cell_bler_for_interval(object=bler_calc_obj, interval=interval,
                                       unit='%',
                                       cell_dist_name='MRBTS-1/NRBTS-2/NRCELL-1')
            print('---------------')
