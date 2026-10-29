from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB009543.resources.variables_9543 import (
    EXPECTED_INCREASE, EXPECTED_ZERO, EXPECTED_HIGHER_THAN_ZERO
)


def compare_counters(base_counters: dict, current_counters: dict):
    failed_counters = {}
    for key in EXPECTED_INCREASE:
        logger.info(f"{current_counters[key]} vs {base_counters[key]}", also_console=True)
        if current_counters[key] > base_counters[key]:
            logger.info(f"   {key}: OK", also_console=True)
        else:
            logger.info(f"   {key}: NOT OK", also_console=True)
            failed_counters[key] = {f"{key}: {current_counters[key]}, should be > {base_counters[key]}"}

    for key in EXPECTED_ZERO:
        logger.info(f"{current_counters[key]} vs {base_counters[key]}", also_console=True)
        if current_counters[key] == 0:
            logger.info(f"   {key}: OK", also_console=True)
        else:
            logger.info(f"   {key}: NOT OK", also_console=True)
            failed_counters[key] = {f"{key}: {current_counters[key]}, should be 0"}

    for key in EXPECTED_HIGHER_THAN_ZERO:
        logger.info(f"{current_counters[key]} vs 0", also_console=True)
        if current_counters[key] > 0:
            logger.info(f"   {key}: OK", also_console=True)
        else:
            logger.info(f"   {key}: NOT OK", also_console=True)
            failed_counters[key] = {f"{key}: {current_counters[key]}, should be > 0"}
    return failed_counters
