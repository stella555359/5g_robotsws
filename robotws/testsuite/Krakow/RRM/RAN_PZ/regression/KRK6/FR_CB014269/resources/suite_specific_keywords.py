import logging
from typing import Callable, Any, Dict, Optional, Union, Tuple
from functools import wraps
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.test_config import DefaultFileLocation
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.cloud_manager.artifacts import get_cm_build_artifacts, get_cm_source_build
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.du_operations import EnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


class PowerChangeRequirementsNotMet(Exception):
    """Raised when power change requirements are not met."""


def admin_connect(func: Callable) -> Callable:
    """Decorator to manage admin connection lifecycle for a function."""

    @wraps(func)
    def inner(*args, **kwargs) -> Any:
        api = admin()
        try:
            connection = api.connect_to()
            return func(connection=connection, *args, **kwargs)
        finally:
            api.teardown_admin()
    return inner


@admin_connect
def get_rus_power_usage(**kwargs) -> Dict[str, float]:
    """
    Retrieve power usage for all Radio Units (RUs).
    Returns a dictionary with RMOD IDs as keys and power usage as float values.
    """
    connection = kwargs.get('connection')
    rus_info = connection.get_frm()
    runtime_ru_dist_names = [element['id']['runtime'] for element in rus_info]
    real_time_measurements = connection.get_measurements(
        measurement_type="realTime")
    power_usage: Dict[str, float] = {}
    for device_measurement in real_time_measurements:
        for dist_name in runtime_ru_dist_names:
            ru_id = dist_name.split("/")[-1]
            device_key = f"ENERGY_EFFICIENCY/RMOD/{ru_id}"
            if device_key in device_measurement:
                try:
                    power_usage[ru_id] = float(
                        device_measurement[device_key]["power"])
                except (KeyError, ValueError, TypeError):
                    logging.warning(f"Could not parse power value for {ru_id}")
    return power_usage


def get_source_sw() -> str:
    """
    Retrieve the source software version from UTE Cloud test execution for UUF and adjust as UUF Source Build.
    :return: software version
    """
    sw_version, sw_release = adjust_sw_release(get_cm_source_build())
    logger.log_info_to_console(msg=f"Source SW got from CM: {sw_version}. Release: {sw_release}", log_hierarchy=1)
    return sw_version


def get_target_sw(bts_id: int = 0, du_id: int = 0, bts_type: str = 'GNB') -> Tuple[str, str]:
    """
    Retrieve the target software version from UTE Cloud test execution or directly from the BTS.
    and adjust as UUF Target Build.
    :param bts_id: ID of the BTS
    :param du_id: ID of the DU
    :param bts_type: Type of the BTS ('ENB' or 'GNB')
    :return: Tuple of (software version, software release)
    """
    build_artifacts = get_cm_build_artifacts()
    if build_artifacts:
        sw_version = build_artifacts.get('name')
    elif get_builtin_value('ENB_BUILD'):
        sw_version = get_builtin_value('ENB_BUILD')
    else:
        if bts_type.upper() == 'ENB':
            sw_version = EnbDuOperations().get_bts_sw_version(bts_id=bts_id, du_id=du_id)
        else:
            sw_version = GnbDuOperations().get_bts_sw_version(bts_id=bts_id, du_id=du_id)

    sw_version, sw_release = adjust_sw_release(sw_version)
    logger.log_info_to_console(msg=f"Target SW got from CM: {sw_version}. Release: {sw_release}", log_hierarchy=1)
    return sw_version, sw_release


def adjust_sw_release(sw_version: str) -> Tuple[str, str]:
    """
    Adjust software version to UUF format if necessary.
    :param sw_version: Original software version
    :return: Tuple of (adjusted software version, software release)
    """
    if sw_version.startswith('SBTS00'):
        return sw_version, 'SBTS00'
    sw_release = SbtsSwVersion(sw_version).release
    if sw_release == 'SBTS00':
        trunk_release = sw_version[0:8]
        sw_version = sw_version.replace(trunk_release, 'SBTS00')
    return sw_version, sw_release


def _calculate_power_change(start_power: float, end_power: float, change_type: str) -> float:
    """
    Calculate the percentage power change.

    Args:
        start_power: Starting power value
        end_power: Ending power value
        change_type: Type of change ('reduction' or 'increase')

    Returns:
        Percentage change as a float
    """
    if change_type == 'reduction':
        return ((start_power - end_power) / start_power) * 100
    else:
        return ((end_power - start_power) / start_power) * 100


def _validate_change_type(expected_change_type: str) -> str:
    expected_change_type = expected_change_type.lower()
    if expected_change_type not in {"increase", "reduction"}:
        logging.error(f"Invalid expected_change_type: {expected_change_type}")
        raise ValueError(
            "expected_change_type must be 'increase' or 'reduction'")
    return expected_change_type


def _validate_power_dicts(start_power_usage: Dict[str, float], end_power_usage: Dict[str, float]):
    if not start_power_usage or not end_power_usage:
        logging.error("Input power usage dictionaries must not be empty.")
        raise ValueError("Input power usage dictionaries must not be empty.")


def _get_rmod_ids(start_power_usage: Dict[str, float], end_power_usage: Dict[str, float], rmod_id: Optional[str]):
    rmod_ids = [rmod_id] if rmod_id else list(start_power_usage.keys())
    missing_ids = [
        rid for rid in rmod_ids
        if rid not in start_power_usage or rid not in end_power_usage
    ]
    if missing_ids:
        logging.error(
            f"Missing power usage data for RMOD(s): {', '.join(missing_ids)}"
        )
        raise PowerChangeRequirementsNotMet(
            f"Missing power usage data for RMOD(s): {', '.join(missing_ids)}"
        )
    return rmod_ids


def _validate_and_log_power_change(
    current_rmod: str,
    start_power: float,
    end_power: float,
    expected_change_type: str,
    expected_change_percent: float
):
    if start_power == 0:
        logging.error(
            f"start_power for RMOD {current_rmod} cannot be zero when calculating percent change. "
            f"start={start_power}, end={end_power}"
        )
        raise ValueError(
            f"start_power for RMOD {current_rmod} cannot be zero when calculating percent change."
        )
    actual_change = _calculate_power_change(
        start_power, end_power, expected_change_type
    )
    logging.info(
        f"RMOD {current_rmod}: start={start_power}, end={end_power}, "
        f"Actual {expected_change_type} = {actual_change:.2f}%, "
        f"Expected = {expected_change_percent}%"
    )
    if actual_change < expected_change_percent:
        logging.error(
            f"RMOD {current_rmod}: Expected {expected_change_type} of at least "
            f"{expected_change_percent}%, but got {actual_change:.2f}%"
        )
        raise PowerChangeRequirementsNotMet(
            f"RMOD {current_rmod}: Expected {expected_change_type} of at least "
            f"{expected_change_percent}%, but got {actual_change:.2f}%"
        )


def validate_power_change(
    start_power_usage: Dict[str, float],
    end_power_usage: Dict[str, float],
    expected_change_type: str,
    expected_change_percent: Union[float, int],
    rmod_id: Optional[str] = None
) -> None:
    """
    Validate that power usage changed as expected for one or all RMODs.

    Args:
        start_power_usage: Dict of RMOD rid to start power value.
        end_power_usage: Dict of RMOD rid to end power value.
        expected_change_type: 'reduction' or 'increase'.
        expected_change_percent: Minimum expected percent change.
        rmod_id: If set, only check this RMOD rid. If None, check all RUs.

    Raises:
        PowerChangeRequirementsNotMet: If the change does not match the expectation for any RMOD.
        ValueError: If start_power is zero, change type is invalid, or input is empty.

    Example:
        >>> start_power = {"RMOD-1": 100.0, "RMOD-2": 120.0}
        >>> end_power = {"RMOD-1": 50.0, "RMOD-2": 60.0}
        >>> validate_power_change(start_power, end_power, "reduction", 50)
    """
    expected_change_type = _validate_change_type(expected_change_type)
    expected_change_percent = float(expected_change_percent)
    _validate_power_dicts(start_power_usage, end_power_usage)
    rmod_ids = _get_rmod_ids(start_power_usage, end_power_usage, rmod_id)
    for current_rmod in rmod_ids:
        start_power = start_power_usage[current_rmod]
        end_power = end_power_usage[current_rmod]
        _validate_and_log_power_change(
            current_rmod, start_power, end_power, expected_change_type, expected_change_percent)


def get_commissioning_branch():
    return DefaultFileLocation().get_commissioning_branch()
