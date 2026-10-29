from ta5g_pm_counters import ta5g_pm_counters
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


ta_5g_pm_lib = BuiltIn().get_library_instance('ta5g_pm_counters')


def verify_that_pm_counter_is_in_range(counter, localmoid, filepath, low, high, pmqap=None):
    counter_val = ta_5g_pm_lib.get_latest_pm_counter_value(counter, localmoid, filepath, pmqap=pmqap)
    logger.info(f"Counter: {counter} value = {counter_val}, Range: {low}-{high}")
    assert int(low) < int(counter_val) < int(high)
