from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter, ComparePmCounters
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK1.CB009467.resources.variables import ul_counters, dl_counters, \
    ul_counters_verification_rules, dl_counters_verification_rules


def get_ul_counters():
    return GnbPmCounter().get_simplified_cell_pm_counters_result(bts_id=0, counter_list=ul_counters)


def get_dl_counters():
    return GnbPmCounter().get_simplified_cell_pm_counters_result(bts_id=0, counter_list=dl_counters)


def verify_that_ul_3_scell_configration_counters_are_updated(counter_diff_dict, expected_diff=1):
    _verify_counter_diff(counter_diff_dict, ul_counters_verification_rules['step_4a'], expected_diff,
                         "Verify that UL 3 SCell configration counters are updated")


def verify_that_ul_scell_configration_counters_are_updated(counter_diff_dict, expected_diff):
    _verify_counter_diff(counter_diff_dict, ul_counters_verification_rules['step_4b1'], expected_diff,
                         "Verify that UL SCell configration counters are updated")
    _verify_counter_diff(counter_diff_dict, ul_counters_verification_rules['step_4b2'], expected_diff)


def verify_that_ul_pscell_act_counters_are_updated(counter_diff_dict, expected_diff):
    _verify_counter_diff(counter_diff_dict, ul_counters_verification_rules['step_4c'], expected_diff,
                         "Verify that UL PSCell act counters are updated")


def verify_that_ul_3_scells_act_counters_are_updated(counter_diff_dict, expected_diff):
    _verify_counter_diff(counter_diff_dict, ul_counters_verification_rules['step_4d'], expected_diff,
                         "Verify that UL 3 SCells activating counters are updated")


def verify_that_ul_3_scells_act_max_counter_is_updated(counter_diff_dict, expected_diff=1):
    _verify_counter_diff(counter_diff_dict, ul_counters_verification_rules['step_4e'], expected_diff,
                         "Verify that UL 3 SCells activating max counter is updated")


def verify_that_dl_7_scell_configration_counters_are_updated(counter_diff_dict, expected_diff=1):
    _verify_counter_diff(counter_diff_dict, dl_counters_verification_rules['step_4a'], expected_diff,
                         "Verify that DL 7 SCell Configration counters are updated")


def verify_that_dl_scell_configration_counters_are_updated(counter_diff_dict, expected_diff):
    _verify_counter_diff(counter_diff_dict, dl_counters_verification_rules['step_4b1'], expected_diff,
                         "Verify that DL SCell Configration counters are updated")
    _verify_counter_diff(counter_diff_dict, dl_counters_verification_rules['step_4b2'], expected_diff)


def verify_that_dl_pscell_act_counters_are_updated(counter_diff_dict, expected_diff):
    _verify_counter_diff(counter_diff_dict, dl_counters_verification_rules['step_4c'], expected_diff,
                         "Verify that DL PSCell act counters are updated")


def verify_that_dl_7_scells_act_counters_are_updated(counter_diff_dict, expected_diff):
    _verify_counter_diff(counter_diff_dict, dl_counters_verification_rules['step_4d'], expected_diff,
                         "Verify that DL 7 SCells activating counters are updated")


def verify_that_dl_7_scells_act_max_counter_is_updated(counter_diff_dict, expected_diff=1):
    _verify_counter_diff(counter_diff_dict, dl_counters_verification_rules['step_4e'], expected_diff,
                         "Verify that DL 7 SCells activating max counter is updated")


def _verify_counter_diff(counter_diff_dict, verification_rule, expected_diff, msg_to_print=None):
    if msg_to_print:
        log_info_to_console(msg_to_print, log_hierarchy=2)
    ComparePmCounters.verify_pm_counter_diff(
        counter_diff_dict=counter_diff_dict,
        counter_ids_to_check=verification_rule['counters'],
        cell_ids_to_check=verification_rule['cells'],
        expected_diff=expected_diff,
        tolerance=verification_rule.get('tolerance', 0))
