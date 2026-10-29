"""
This module is containing keywords for verifying voltage on RUs, changing voltage values on RUs and also validating if
the change happened succesfully.

:author: Dawid Dabrowski
:contact: dawid.dabrowski@nokia.com
:maintainer: dawid.dabrowski@nokia.com
"""
import logging
from typing import Callable, Any, Dict
from robot.api.deco import keyword
from functools import wraps
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout, login_logout_GUI


@keyword()
@load_moler_configuration_from_tl()
def change_voltage(voltage, bts_id=0, du_id=0, ru_id=0):
    """
    Change voltage value of a chosen RMOD
    Returns a command used to changing voltage on RMOD side
    :param voltage:  RU voltage in mV
    :param bts_id:  ID of the bts, by default 0(main gnb)
    :du_id: Id of the DU, by default 0
    :ru_id: Id of the RU, by default 0, dependent on order in init.py files
    """
    device = GnbRuOperations().get_ru_device(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
    cmd = device.get_cmd(
        cmd_name="run_script",
        cmd_params={
            "script_command": f"ccsShell.sh rad -mw 0x110032 {voltage}"})
    return cmd()


def admin_connect(func: Callable) -> Callable:
    """
    Decorator to manage admin connection lifecycle for a function.
    """
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
def get_rus_voltage(**kwargs) -> Dict[str, float]:
    """
    Retrieve voltage for all Radio Units (RUs).
    Returns a dictionary with RMOD IDs as keys and voltage as float values.
    """
    connection = kwargs.get('connection')
    rus_info = connection.get_frm()
    runtime_ru_dist_names = [element['id']['runtime'] for element in rus_info]
    real_time_measurements = connection.get_measurements(
        measurement_type="realTime")
    voltage_usage: Dict[str, float] = {}
    for device_measurement in real_time_measurements:
        for dist_name in runtime_ru_dist_names:
            ru_id = dist_name.split("/")[-1]
            device_key = f"ENERGY_EFFICIENCY/RMOD/{ru_id}"
            if device_key in device_measurement:
                try:
                    voltage = float(device_measurement[device_key]["voltage"])
                    voltage_usage[ru_id] = voltage
                    logging.info(f"{ru_id} voltage: {voltage}")
                except (KeyError, ValueError, TypeError):
                    logging.warning(f"Could not parse voltage value for {ru_id}")
    return voltage_usage


@keyword()
def validate_voltage_change(desired_voltage: float, ru_id: int = 1):
    """
    Validate if the voltage for the given RU has been changed to the desired value.
    Raises AssertionError if voltage does not match.
    :param desired_voltage: RU voltage in mV
    :param ru_id:  Id of the RU, by default 1, dependent on name in Webem
    """
    voltages = get_rus_voltage()
    rmod_key = f"RMOD_R-{ru_id}"
    actual_voltage = voltages.get(rmod_key)
    actual_voltage = actual_voltage * 1000
    if actual_voltage is None:
        raise AssertionError(f"No voltage found for RU {rmod_key}")
    if actual_voltage == desired_voltage:
        logging.info(f"RU {rmod_key} voltage matches desired value: {desired_voltage}")
    else:
        raise AssertionError(f"RU {rmod_key} voltage {actual_voltage} does not match desired {desired_voltage}")
