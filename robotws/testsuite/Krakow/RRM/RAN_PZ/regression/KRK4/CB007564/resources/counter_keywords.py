from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter, ComparePmCounters
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB007564.resources.variables import CBRA_COUNTERS, CFRA_COUNTERS


def get_cbra_counters(bts_id=0):
    return GnbPmCounter().get_simplified_cell_pm_counters_result(bts_id=bts_id, counter_list=CBRA_COUNTERS)


def get_cfra_counters(bts_id=0):
    return GnbPmCounter().get_simplified_cell_pm_counters_result(bts_id=bts_id, counter_list=CFRA_COUNTERS)


def verify_that_cbra_counters_are_updated(counter_diff_dict, cell_ids_to_check, expected_diff=1):
    ComparePmCounters.verify_pm_counter_diff(
        counter_diff_dict=counter_diff_dict,
        counter_ids_to_check=CBRA_COUNTERS,
        cell_ids_to_check=cell_ids_to_check,
        expected_diff=expected_diff)


def verify_that_cfra_counters_are_updated(counter_diff_dict, cell_ids_to_check, expected_diff=1):
    ComparePmCounters.verify_pm_counter_diff(
        counter_diff_dict=counter_diff_dict,
        counter_ids_to_check=CFRA_COUNTERS,
        cell_ids_to_check=cell_ids_to_check,
        expected_diff=expected_diff)
