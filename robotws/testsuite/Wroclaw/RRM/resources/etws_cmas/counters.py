from robot.api import logger
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
import testsuite.Wroclaw.RRM.resources.pm_counters as pm_counters
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.counters import get_sum_of_n_last_pm_counters_values


@fixture.logged_keyword
def pws_fail_ind_sent_counter_incremented_successfully(expected_value, wait_for_interval=True):
    return counter_has_correct_value('M55119C02003', expected_value, wait_for_interval)


@fixture.logged_keyword
def wrwr_req_recd_counter_incremented_successfully(expected_value, wait_for_interval=True):
    return counter_has_correct_value('M55119C02001', expected_value, wait_for_interval)


@fixture.logged_keyword
def wrwr_resp_sent_counter_incremented_successfully(expected_value, wait_for_interval=True):
    return counter_has_correct_value('M55119C02002', expected_value, wait_for_interval)


def counter_has_correct_value(counter_id, expected_value, wait_for_interval=True):
    current_value = get_pm_counter_value(counter_id, wait_for_interval)
    assert current_value == int(expected_value), '{} value is {} which is different than expected: {} '.format(
        counter_id, current_value, expected_value)


def get_pm_counter_value(counter_id, wait_for_interval=True):
    if wait_for_interval:
        wait_for_pm_counters_interval()
    return get_sum_of_n_last_pm_counters_values([counter_id])[counter_id]


def wait_for_pm_counters_interval(offset=40, interval_m=5):
    logger.info("Waiting for next PM counter interval..", also_console=True)
    pm_counters.sync_to_reporting_interval(offset_s=offset, interval_m=interval_m)
