"""
Keywords to be used by more than 1 feature in VRF_KRK T06

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""

import logging
import traceback
from datetime import datetime
from typing import Any, Tuple
from tzlocal import get_localzone
from taf.config.testline.attenuator import Attenuator
from taf.config.testline.radio import RU
from taf.hw.rf_attenuator import rf_attenuator
from taf.hw.rf_attenuator.attenuator_class import Attenuator as AttenuatorClass
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword
from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_suite_variable


class Misc:
    """Class for miscellaneous helper methods."""

    @staticmethod
    @log_as_robot_keyword
    def get_nr_cell_id_in_hex(nr_cell_id: str, hex_len: int = 11) -> str:
        """Dump nrcellid to hex format.

        :param nr_cell_id: cell's nrcellid in dec format
        :param hex_len: length of hex string after '0x'
        :return: cell's nrcellid in hex format
        """
        return "{0:#0{1}x}".format(int(nr_cell_id), hex_len)

    @staticmethod
    def list_contains_same_values(list_obj: list[Any], value: Any, length: int) -> bool:
        return list_obj.count(value) == length

    @log_as_robot_keyword
    def get_now_datetime(self) -> datetime:
        """Get current timestamp localized for Scout usage."""
        now = datetime.now()
        logging.debug(f'Date time now: {now}')
        return now.astimezone(get_localzone())

    @log_as_robot_keyword
    def wait_for_all_cells_to_be_onair(self, bts_id: int = 0, timeout: int = 900) -> None:
        """Wait until all BTS cells reach onAir state."""
        logger.log_info_to_console(f'Wait for all cells to be on air on bts_id={bts_id}')
        GnbCellOperations().wait_for_all_cells_statuses(
            bts_id=bts_id,
            availability_status='online',
            operational_state='enabled',
            administrative_state='Unlocked',
            blocking_state='Unblocked',
            procedural_status='configured',
            barring_status='unbarred',
            timeout=timeout,
        )

    @staticmethod
    def to_bool(val: Any, default: bool = True) -> bool:
        """Convert a value to boolean based on its string representation.

        :param val: Any value to convert.
        :param default: Default boolean value.
        :return: True if the value represents boolean true,
                 False if it represents boolean false
        """
        logging.info(f"Casting Robot variable: {val=} = {val} to Python bool")
        str_val = str(val).strip().lower()
        if str_val == "true":
            return True
        if str_val == "false":
            return False
        return default

    @staticmethod
    def is_not_defined(val: Any) -> bool:
        """
        Treat '', 'NONE', 'None', 'False', None and False as undefined value
        :param val: Any value to evaluate.
        :return: True if the value is considered undefined, else False.
        """
        logging.info(f"Checking if variable: {val=} = {val} is not defined")
        return str(val).strip().lower() in ('', 'none', 'false')

    @log_as_robot_keyword
    def remove_problematic_lmi_from_tl_variable(self):
        """Remove problematic LMI(s) from TL variable that Random OAM operation test not cause problems

        :return: None
        """

        tl_var = get_builtin_value('tl')
        logging.info(f'Initial tl variable: {tl_var}')
        tl_var.gnbs[0].dus[0].airscale.common_units[0].capacity_units[2].rus[0].lmi = None
        logging.info(f'Modified tl variable: {tl_var}')
        set_robot_suite_variable('tl', tl_var)


class RfAttenuator:
    """Class-based version of common keywords to be used by more than one feature.

    Robot Framework can import this class as a library to expose decorated methods as keywords.
    """

    def __init__(self):
        self.tl = get_builtin_value(param_name="tl")

    def setup_attenuator(self, tl_attenuator_index: int = 0) -> None:
        """Setup RF attenuator from testline configuration file (__init__.py__)."""
        rf_attenuator().setup_attenuator(
            attenuator=self.tl.attenuators[tl_attenuator_index],
            alias=self.tl.attenuators[tl_attenuator_index].serial_number,
        )

    @log_as_robot_keyword
    def setup_all_attenuators(self) -> None:
        """Setup all RF attenuators from testline configuration file (__init__.py__)."""
        for idx, _ in enumerate(self.tl.attenuators):
            self.setup_attenuator(tl_attenuator_index=idx)
        self.set_maximum_attenuation_for_all_attenuators()

    def set_maximum_attenuation_for_all_ports(self, tl_attenuator_index: int = 0) -> None:
        """Set maximum attenuation for all ports of RF attenuator."""
        att, attenuator_device = self._get_attenuator_artifacts(tl_attenuator_index)
        value = getattr(attenuator_device, 'max_attenuation', 110)
        values = [value for _ in att.attenuation_port_numbers]
        logging.info(f"Setting {value} attenuation for ports: {att.attenuation_port_numbers}")
        rf_attenuator().set_ports_attenuation(
            ports=att.attenuation_port_numbers,
            values=values,
            attenuator_device=attenuator_device,
        )

    @log_as_robot_keyword
    def set_maximum_attenuation_for_all_attenuators(self) -> None:
        """Set maximum attenuation for all ports of all RF attenuators from testline configuration file
        (__init__.py__)."""
        for idx, _ in enumerate(self.tl.attenuators):
            self.set_maximum_attenuation_for_all_ports(tl_attenuator_index=idx)

    @log_as_robot_keyword
    def set_attenuation_for_ru(self, radio_type: str, value: str) -> None:
        """Set desired attenuation for all ports listed under RU.attenuation_ports for first RU of given type."""
        ru = self._find_ru_in_testline(radio_type)
        ports = [port.port_no for port in ru.attenuation_ports]
        values = [value for _ in ru.attenuation_ports]
        taf_attenuator_device = rf_attenuator.configured_attenuators.get(
            ru.attenuation_ports[0].attenuator.serial_number
        )
        rf_attenuator().set_ports_attenuation(
            ports=ports,
            values=values,
            attenuator_device=taf_attenuator_device,
        )

    @log_as_robot_keyword
    def set_maximum_attenuation_for_all_ports(self, tl_attenuator_index: int = 0) -> None:
        """
        Sets maximum attenuation for all ports of RF attenuator.

        :param tl_attenuator_index: number on list in __init.py__
        :return: None
        """
        att, attenuator_device = self._get_attenuator_artifacts(tl_attenuator_index)
        value = getattr(attenuator_device, 'max_attenuation', 110)
        values = [value for _ in att.attenuation_port_numbers]
        logging.info(f"Setting {value} attenuation for ports: {att.attenuation_port_numbers}")
        rf_attenuator().set_ports_attenuation(ports=att.attenuation_port_numbers,
                                              values=values,
                                              attenuator_device=attenuator_device)

    def _get_attenuator_artifacts(self, tl_attenuator_index: int) -> Tuple[Attenuator, type[AttenuatorClass]]:
        tl_attenuator = self.tl.attenuators[tl_attenuator_index]
        att_alias = tl_attenuator.serial_number
        taf_attenuator_device = rf_attenuator.configured_attenuators.get(att_alias)
        return tl_attenuator, taf_attenuator_device

    def _find_ru_in_testline(self, radio_type: str) -> RU:
        for gnb in self.tl.gnbs:
            for capacity_unit in gnb.dus[0].airscale.common_units[0].capacity_units:
                for ru in capacity_unit.rus:
                    if radio_type.upper() == ru.radio_type.upper():
                        logging.info(f"Found RU: {ru}")
                        return ru
        raise ValueError(f"RU with radio type = {radio_type} not found in testline configuration file")


def run_and_warn_on_exception(func):
    def _inner(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            tb = "".join(traceback.format_exception(type(e), e, e.__traceback__))
            logger.log_warn_to_console(
                f"Function {func.__name__} failed with {type(e).__name__}: {e}. args={args}, kwargs={kwargs}"
            )
            logging.warning(tb)
    return _inner
