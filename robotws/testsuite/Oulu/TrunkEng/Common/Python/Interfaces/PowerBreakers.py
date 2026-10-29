import re
import pytz
import threading
from datetime import datetime
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.hw.pdu import pdu
from taf.hw.pdu.exceptions import (Timeout, InvalidHost, InvalidInputParameter, BadResponse, BadDeviceStatus,
                                   BadPortNumber, PduConnectionError, DeviceNotSupported)
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (EnvironmentIssue, UnableToGetTimesFromSyslog)
# BtsAndPcTimeDiffereceTooBig)


class PowerBreakers:
    """
    Find and control UTE/local env power breakers.
    Import in robot file:
    >> Library     testsuite.Oulu.TrunkEng.Common.Python.Interfaces.PowerBreakers  WITH NAME  PowerBreakers
    """
    units_and_power_breakers = {}
    power_on_timestamp = None
    ip_and_alias_name = {}
    alias_number = 1

    def __init__(self):
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.pdu = pdu()
        self.syslog_search = BuiltIn().get_library_instance("SYSLOGSEARCH")

    def setup_power_breaker_controller(self, unit_type="rmod"):
        """
        Setup power breakers for unit type RMOD or SMOD.

        :param str unit_type: Set to 'rmod' if not given. Other option is 'smod'.
        """
        info("Setting up power breakers for {}s".format(unit_type))
        self._find_all_pdus_for_unit_type(unit_type)
        info("Found Power Breakers: {}".format(PowerBreakers.units_and_power_breakers))
        for unit in PowerBreakers.units_and_power_breakers:
            model = PowerBreakers.units_and_power_breakers[unit]["model"]
            ip = PowerBreakers.units_and_power_breakers[unit]["IP"]
            if ip not in PowerBreakers.ip_and_alias_name:
                if ("snmp_user" in PowerBreakers.units_and_power_breakers[unit]
                        and PowerBreakers.units_and_power_breakers[unit]["snmp_user"] is not None):
                    snmp_user = PowerBreakers.units_and_power_breakers[unit]["snmp_user"]
                    self.logger.debug(f"Setup snmp_user: {snmp_user}")
                    self.pdu.setup_pdu(model, host=ip, alias=f"pdu_{PowerBreakers.alias_number}", snmp_user=snmp_user)
                else:
                    self.pdu.setup_pdu(model, host=ip, alias=f"pdu_{PowerBreakers.alias_number}")
                PowerBreakers.ip_and_alias_name[ip] = f"pdu_{PowerBreakers.alias_number}"
                PowerBreakers.alias_number += 1
        self.logger.debug(f"PowerBreakers.ip_and_alias_name: {PowerBreakers.ip_and_alias_name}")

    def find_ports_for_chosen_units(self, units):
        """
        Radios should be given in a form 'r1' or as 'FXEA(1.1.1.1)' .
        SMOD should be given in a form 's1'.
        Multiple units are given separated by commas: 'r1,r2' or 'FXEA(1.1.1.1),FRHA(1.2.1.1)'
        """
        ports = []
        if isinstance(units, str):
            units = self._safe_split(units, ",")
        for unit in units:
            for rmod in PowerBreakers.units_and_power_breakers:
                if rmod not in PowerBreakers.units_and_power_breakers:
                    error("No power breaker found for {}. Check init file and take contact to CM.".format(rmod))
                    raise EnvironmentIssue
                if len(unit) < 7:
                    print("User has given {} that is unit_identifier".format(unit))
                    if PowerBreakers.units_and_power_breakers[rmod]["unit_identifier"] == str(unit):
                        ports.append(PowerBreakers.units_and_power_breakers[rmod]["port"])
                        break
                else:
                    print("User has given {} that is unit_name".format(unit))
                    if rmod == str(unit):
                        ports.append(PowerBreakers.units_and_power_breakers[rmod]["port"])
                        break
        return ports

    def _check_status(self, unit, counter, status):
        print_error = False
        if counter == 2:
            print_error = True
        success = self.check_if_power_breaker_in_wanted_state(unit, wanted_status=status, print_error=print_error)
        if not success:
            BuiltIn().sleep("1s")
            counter += 1
        self._make_success_prints(status.upper(), success, counter, unit)
        return success, counter

    @staticmethod
    def _wait_after_pb_action():
        time_to_wait = "0"
        if "${PB_WAIT}" in BuiltIn().get_variables():
            time_to_wait = BuiltIn().get_variable_value("${PB_WAIT}")
        if time_to_wait != "0":
            info(f"Wait extra {time_to_wait}s from PB_WAIT-variable.")
            BuiltIn().sleep(f"{time_to_wait}s")

    def turn_power_off_from_chosen_units(self, units, wait_after=True):
        """
        Turn Power OFF from all ports of given units. Checks if the attempt was successful and tries again max 3 times.

        :param list[str]/str units: List of units or unit as a string.
        :param bool wait_after: If True, wait extra time after power off action.
        """
        counter = 0
        success = ""
        if isinstance(units, list):
            for unit in units:
                while counter < 3 and not success:
                    self._switch_power_on_or_off("off", unit)
                    BuiltIn().sleep("500ms")
                    success, counter = self._check_status(unit, counter, status="off")
        elif isinstance(units, str):
            while counter < 3 and not success:
                self._switch_power_on_or_off("off", units)
                BuiltIn().sleep("500ms")
                success, counter = self._check_status(units, counter, status="off")
        if wait_after:
            self._wait_after_pb_action()

    def turn_power_on_to_chosen_units(self, units, wait_after=True):
        """
        Turn Power ON to all ports of given units. Checks if the attempt was successful and tries again max 3 times.

        :param list[str]/str units: List of units or unit as a string.
        :param bool wait_after: If True, wait extra time after power off action.
        """
        counter = 0
        success = ""
        if isinstance(units, list):
            for unit in units:
                while counter < 3 and not success:
                    self._switch_power_on_or_off("on", unit)
                    BuiltIn().sleep("500ms")
                    success, counter = self._check_status(unit, counter, status="on")
        elif isinstance(units, str):
            while counter < 3 and not success:
                self._switch_power_on_or_off("on", units)
                BuiltIn().sleep("500ms")
                success, counter = self._check_status(units, counter, status="on")
        if wait_after:
            self._wait_after_pb_action()

    def get_power_on_timestamp(self):
        """
        Get time when power was turned on to the unit and get PC and BTS time from syslog and add delta time to time.
        """
        try:
            return self.syslog_search.add_delta_time_to_pc_timestamp(self.power_on_timestamp)
        except UnableToGetTimesFromSyslog:
            BuiltIn().set_suite_variable("${CALCULATE_KPI}", "${False}")

    def get_unit_info_from_init_to_dict(self, unit):
        """
        Fetches information about given unit through local environment's __init__.py file with tl-variable and
        saves the information to PowerBreakers' units_and_power_breakers dictionary

        :param string unit: smod or rmod
        """
        if unit == "smod":
            info("Adding SMOD: {} IP: {}, model: {} and port {} to units_and_power_breakers".format(
                self.bts.tl.smod.smod_type, self.bts.tl.smod.power_breaker_ip,
                self.bts.tl.smod.power_breaker_type, self.bts.tl.smod.power_breaker_port))
            if self.bts.tl.smod.smod_type not in PowerBreakers.units_and_power_breakers:
                PowerBreakers.units_and_power_breakers[self.bts.tl.smod.smod_type] = {
                    "IP": self.bts.tl.smod.power_breaker_ip, "model": self.bts.tl.smod.power_breaker_type,
                    "port": self.bts.tl.smod.power_breaker_port}
        if unit == "rmod":
            for radio in self.bts.tl.radios:
                if radio.radio_type not in PowerBreakers.units_and_power_breakers:
                    PowerBreakers.units_and_power_breakers[radio.radio_type] = {
                        "IP": radio.power_breaker_ip, "model": radio.power_breaker_type,
                        "port": radio.power_breaker_port}
                    info("Adding RMOD: {}, IP: {}, model: {} and port {} to units_and_power_breakers".format(
                             radio.radio_type, radio.power_breaker_ip, radio.power_breaker_type,
                             radio.power_breaker_port))

    def switch_power_off_from_all_local_units(self, also_rmod=False):
        """
        Switches power off from local environments radios and smod
        """
        self.setup_power_breaker_controller(unit_type="smod")
        if also_rmod:
            self.setup_power_breaker_controller(unit_type="rmod")
        threads = []
        for unit in PowerBreakers.units_and_power_breakers:
            thread = threading.Thread(target=self.turn_power_off_from_chosen_units, args=(unit, False))
            threads.append(thread)
            thread.start()
        for thread in threads:
            thread.join()
        self._wait_after_pb_action()

    def switch_power_on_to_all_local_units(self, also_rmod=False):
        """
        Switches power on to local environment's radios and smod simultaneously.
        """
        self.setup_power_breaker_controller(unit_type="smod")
        if also_rmod:
            self.setup_power_breaker_controller(unit_type="rmod")
        threads = []
        for unit in PowerBreakers.units_and_power_breakers:
            thread = threading.Thread(target=self.turn_power_on_to_chosen_units, args=(unit, False))
            threads.append(thread)
            thread.start()
        for thread in threads:
            thread.join()
        self._wait_after_pb_action()

    def print_power_breaker_port_statuses(self):
        info("Check power breaker port statuses.")
        if not PowerBreakers.units_and_power_breakers:
            info("Power breakers have not been setup yet, no way to check their statuses.")
        for unit in PowerBreakers.units_and_power_breakers:
            status, port = self.get_power_breaker_status(unit)
            info("Status for power breaker port {} is {}. Port is attached to unit {}".format(
                port, status, unit))

    def check_if_power_breaker_in_wanted_state(self, unit, wanted_status="on", print_error=False):
        status, _ = self.get_power_breaker_status(unit, print_error=print_error)
        self.logger.debug(f"Checking power breaker status for {unit}: {status}, wanted status is "
                          f"{wanted_status}")
        if wanted_status == status:
            return True
        else:
            return False

    def get_power_breaker_status(self, unit, print_error=False):
        unit = self._check_if_unit_name_update_needed(unit)
        if unit not in PowerBreakers.units_and_power_breakers:
            error(f"Unit {unit} is not found from units_and_power_breakers dictionary "
                  f"({PowerBreakers.units_and_power_breakers}). Cannot check port status.")
            raise EnvironmentIssue("Unit not found from units_and_power_breakers dictionary. Check init file.")
        port = PowerBreakers.units_and_power_breakers[unit]["port"]
        ip = PowerBreakers.units_and_power_breakers[unit]["IP"]
        self.logger.debug(f"Searching pdu_alias for unit {unit} with port {port} and IP: {ip}")
        status = False
        if not ip:
            error(f"IP address is missing for unit {unit}, cannot check port status because alias is unknown. "
                  f"Assume status=False. (port={port}")
            return status, port
        if not port:
            error(f"Port information is missing for unit {unit}, cannot check port status. Assume status=False.")
            return status, port
        pdu_alias = PowerBreakers.ip_and_alias_name[ip]
        if not pdu_alias:
            error(f"Could not find pdu_alias with IP {ip}, cannot check port status. Assume status=False.")
            return status, port
        self.logger.debug(f"Found pdu_alias {pdu_alias} for unit {unit} with port {port} and IP: {ip}")
        try:
            status = self.pdu.get_port_status(port=port, pdu_device=pdu_alias)
        except (KeyError, Timeout, InvalidHost, InvalidInputParameter, BadResponse, BadDeviceStatus, BadPortNumber,
                PduConnectionError, DeviceNotSupported) as e:
            if print_error:
                error(f"Could not get status for power breaker port {port} with pdu_alias {pdu_alias} (unit {unit}). "
                      f"Error {e.__class__.__name__}:{e}. Assume status=False.")
            else:
                info(f"Could not get status for power breaker port {port} with pdu_alias {pdu_alias} (unit {unit}). "
                     f"Error {e.__class__.__name__}:{e}. Assume status=False.")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return False, port
        return status, port

    def get_names_of_all_setup_pb(self):
        """
        Get names of all units that are set up for Power Breaker. For example all smods or all radios.

        :return list: List of unit names.
        """
        self.logger.debug("Return all units that are setup for pb: {}".format(
            list(PowerBreakers.units_and_power_breakers.keys())))
        return list(PowerBreakers.units_and_power_breakers.keys())

    def _check_if_unit_name_update_needed(self, unit_name):
        if unit_name not in PowerBreakers.units_and_power_breakers:
            self.logger.debug(f"Unit_name {unit_name} is not found from units_and_power_breakers dictionary, try to "
                              f"remove number from the end.")
            if unit_name[-1].isdigit():
                unit_name = unit_name[:-1]
        if unit_name not in PowerBreakers.units_and_power_breakers:
            self.logger.debug(f"Unit_name {unit_name} is not found from init-file "
                              f"{PowerBreakers.units_and_power_breakers}. Check if ASIAA, ASIBA, ASIAL...")
            unit_name = self._update_unit_name(unit_name)
        return unit_name

    def _switch_power_on_or_off(self, on_or_off, unit_name):
        """
        Turns Power ON or OFF from given port. Does NOT check whether the power OFF was successful or not.

        :param str on_or_off: Has value 'on' or 'off'.
        :param str unit_name: Name of unit for example FRHA(1.1.1.1), ASIA...
        :return boolean: True if power off was successful, False if not.
        """
        # if unit_name not in PowerBreakers.units_and_power_breakers:
        #     self.logger.debug(f"Unit_name {unit_name} is not found from units_and_power_breakers dictionary, try to "
        #                       f"remove number from the end.")
        #     if unit_name[-1].isdigit():
        #         unit_name = unit_name[:-1]
        # if unit_name not in PowerBreakers.units_and_power_breakers:
        #     self.logger.debug(f"Unit_name {unit_name} is not found from init-file "
        #                       f"{PowerBreakers.units_and_power_breakers}. Check if ASIAA, ASIBA, ASIAL...")
        #     unit_name = self._update_unit_name(unit_name)
        unit_name = self._check_if_unit_name_update_needed(unit_name)
        if unit_name not in PowerBreakers.units_and_power_breakers:
            error(f"Unit name {unit_name} is not found from init-file {PowerBreakers.units_and_power_breakers} "
                  f"(and it wasn't ASIAA, ASIBA, ASIAL...) Check if serial numbers are correct in init -file")
            raise EnvironmentIssue
        info(f"Powering {on_or_off} unit {unit_name} "
             f"(port {PowerBreakers.units_and_power_breakers[unit_name]['port']}).")
        ip_in_dict = PowerBreakers.units_and_power_breakers[unit_name]["IP"]
        device_alias = PowerBreakers.ip_and_alias_name[ip_in_dict]
        port = PowerBreakers.units_and_power_breakers[unit_name]["port"]
        self.logger.debug(f"Alias for power breaker {ip_in_dict} is {device_alias}")
        if on_or_off == "off":
            try:
                self.pdu.power_off(port=port, pdu_device=device_alias)
            except Timeout as e:
                info("Received error 'Timeout' when powering Off power breaker. Continue.")
                self.logger.debug(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        else:
            try:
                self.power_on_timestamp = datetime.now(pytz.utc)
                info(f"Power ON start timestamp on PC time: {self.power_on_timestamp}")
                self.pdu.power_on(port=port, pdu_device=device_alias)
            except Timeout as e:
                info("Received error 'Timeout' when powering On power breaker. Continue.")
                self.logger.debug(f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def _update_unit_name(self, unit_name):
        for unit in PowerBreakers.units_and_power_breakers:
            if unit[:-1] in unit_name:  # if ASIA in ASIAA, ASIA in ASIAL. Remove number f.ex. ASIA1 -> ASIA
                self.logger.debug("Switch {} to {}".format(unit_name, unit))
                unit_name = unit
                break
            elif ("FSMF" in unit and "FSMr3" in unit_name) or ("FSMr3" in unit and "FSMF" in unit_name):
                self.logger.debug("Switch {} to {}".format(unit_name, unit))
                unit_name = unit
                break
        if unit_name == "FSMr3":
            unit_name = "FSMF"
        return unit_name

    def _find_all_pdus_for_unit_type(self, unit_type):
        """
        Find all PDUs for unit_type 'rmod' or 'smod' and add them to the units_and_power_breakers -dict.
        Only usable with UTE environments with init-file.

        :param str unit_type: 'rmod' or 'smod'.
        """
        unit_nro = 1
        if hasattr(self.bts.tl, "smod") and hasattr(self.bts.tl, "radios"):
            self.get_unit_info_from_init_to_dict("smod")
            self.get_unit_info_from_init_to_dict("rmod")
        if hasattr(self.bts.tl, "gnbs") or hasattr(self.bts.tl, "enbs"):
            if self.bts.tl.gnbs:
                for unit_obj in self.bts.tl.gnbs:
                    self.logger.debug(f"Unit object to be parsed to find {unit_type} port: {vars(unit_obj)}")
                    if unit_type == "smod":
                        unit_nro = self._get_smod_port_from_gnbs_tl(unit_nro, unit_obj)
                    if unit_type == "rmod":
                        unit_nro = self._get_radio_port_from_gnbs_tl(unit_nro, unit_obj)
            if self.bts.tl.enbs:
                for unit_obj in self.bts.tl.enbs:
                    self.logger.debug(f"Unit object to be parsed to find {unit_type} port: {vars(unit_obj)}")
                    if unit_type == "smod":
                        unit_nro = self._find_smod_port_from_enbs_tl(unit_nro, unit_obj)
                    if unit_type == "rmod":
                        unit_nro = self._get_radio_port_from_enbs_tl(unit_nro, unit_obj)

    def _get_smod_port_from_gnbs_tl(self, unit_nro, unit_obj):
        if hasattr(unit_obj, "dus"):  # confirm tl is constructed correctly
            for du in unit_obj.dus:
                if hasattr(du.airscale, "common_units") and du.airscale.common_units:
                    for smod in du.airscale.common_units:
                        self._add_unit_pdu_to_dict(smod, smod.hardware_type + str(unit_nro), "s" + str(unit_nro))
                        unit_nro += 1
                if hasattr(du.airscale, "core_units") and du.airscale.core_units:
                    for smod in du.airscale.core_units:
                        self._add_unit_pdu_to_dict(smod, smod.hardware_type + str(unit_nro), "s" + str(unit_nro))
                        unit_nro += 1
        else:
            error("Cannot find 'dus' attribute from unit object, take contact to script developer.")
        return unit_nro

    def _get_radio_port_from_gnbs_tl(self, unit_nro, unit_obj):
        if hasattr(unit_obj, "dus"):  # confirm tl is constructed correctly
            for du in unit_obj.dus:
                for radio in du.rus:
                    radio_name = self.bts.find_name_with_serial_number(self.bts.radios, radio.serial_number)
                    info("Trying to find PDU for radio {}".format(radio_name))
                    self._add_unit_pdu_to_dict(radio, radio_name, "r" + str(unit_nro))
                    unit_nro += 1
        else:
            error("Cannot find 'dus' attribute from unit object, take contact to script developer.")
        return unit_nro

    def _find_smod_port_from_enbs_tl(self, unit_nro, unit_obj):
        if hasattr(unit_obj, "system_module"):  # confirm tl is constructed correctly
            if hasattr(unit_obj.system_module, "common_units") and unit_obj.system_module.common_units:
                for smod in unit_obj.system_module.common_units:
                    self._add_unit_pdu_to_dict(smod, smod.hardware_type + str(unit_nro), "s" + str(unit_nro))
                    unit_nro += 1
            if hasattr(unit_obj.system_module, "core_units") and unit_obj.system_module.core_units:
                # at least ASOE has sometimes core_units instead of common_units
                for smod in unit_obj.system_module.core_units:
                    self._add_unit_pdu_to_dict(smod, smod.hardware_type + str(unit_nro), "s" + str(unit_nro))
                    unit_nro += 1
        else:
            error("Cannot find 'system_module' attribute from unit object, take contact to script developer.")
        return unit_nro

    def _get_radio_port_from_enbs_tl(self, unit_nro, unit_obj):
        if hasattr(unit_obj, "rms") and unit_obj.rms is not None:  # confirm tl is constructed correctly
            for radio in unit_obj.rms:
                radio_name = self.bts.find_name_with_serial_number(self.bts.radios, radio.serial_number)
                info("Trying to find PDU for radio {}".format(radio_name))
                self._add_unit_pdu_to_dict(radio, radio_name, "r" + str(unit_nro))
                unit_nro += 1
        else:
            if not hasattr(unit_obj, "rms"):
                error("Cannot find 'rms' attribute from unit object, take contact to script developer.")
            else:
                self.logger.debug(f"Unit object has 'rms' attribute but it is None, skipping radio iteration")
        return unit_nro

    def _add_unit_pdu_to_dict(self, unit, unit_name, unit_id):
        """
        Add unit PDU to units_and_power_breakers -dict.
        Only usable with UTE environments with init-file.

        :param obj unit: Unit object.
        :param str unit_name: Unit name, e.g. FRHA(1.1.1.1), ASIA1.
        :param str unit_id: 'sx' (SMOD) or 'rx' (RMOD), where x is unit_nro.
                            unit_id is used only within PowerBreakers -class.
        """
        pdu_port_obj = unit.pdu_port
        pdu = pdu_port_obj.pdu
        if "s" in unit_id:  # Check if SMOD unit_name has correct number when compared to bts.smods -list
            if not any(unit_name in smod.name for smod in self.bts.smods):
                for smod in self.bts.smods:
                    if unit_name[:-1] in smod.name:
                        unit_name = smod.name
        if pdu.model:
            PowerBreakers.units_and_power_breakers[unit_name] = {
                "IP": pdu.addr, "port": pdu_port_obj.port_no, "model": pdu.model, "unit_identifier": unit_id}
        else:
            info("PDU Model information is not given as object attribute in __init__, "
                 "parse model information from text of init file")
            pdu_styles = (r"pdu_port|_pdu_du|_pdu_ru|_pdu_sm|_pdu_ru_gnb_\d+|_pdu_ru_gnb|_fsmf_pdu|_radio_pdu|_pdu|"
                          r"delta_pdu_\d+")
            pattern_string = (r".*({pdu_styles})\s*=\s*(?P<model>\w+)\(?\s*((port_numbers=.*{port}.*,.*addr=.*{addr}.*)"
                              r"|(addr=.*{addr}.*,.*port_numbers=.*{port}.*)).*").format(pdu_styles=pdu_styles,
                                                                                         addr=re.escape(pdu.addr),
                                                                                         port=re.escape(str(
                                                                                            pdu_port_obj.port_no)))
            self.logger.debug(f"regex: {pattern_string}")
            regex_pattern = re.compile(pattern_string)
            with open(self.bts.path_to_ute_env_init, "r") as f:
                file = f.read()
                file = file.replace("\n", "")
                match = regex_pattern.match(file)
                if match:
                    pdu_model = match.group("model")
                    PowerBreakers.units_and_power_breakers[unit_name] = {
                        "IP": pdu.addr, "port": pdu_port_obj.port_no, "model": pdu_model,
                        "unit_identifier": unit_id}
                else:
                    error("Model for PDU is not get. Check regex for PDUs")
        if unit_name in PowerBreakers.units_and_power_breakers:
            if hasattr(pdu, "snmp_user") and pdu.snmp_user is not None:
                PowerBreakers.units_and_power_breakers[unit_name]["snmp_user"] = pdu.snmp_user
            info("Power breaker of unit {} information: {}".format(unit_name,
                                                                   PowerBreakers.units_and_power_breakers[unit_name]))
        else:
            error(f"Could not find PDU for unit {unit_name} with unit_id {unit_id}. Check if init file is correct.")
            raise EnvironmentIssue

    @staticmethod
    def _make_success_prints(off_or_on, success, counter, unit):
        if not success and counter < 3:
            info(f"Power {off_or_on} was not successful for {unit}, try again.")
        if not success and counter == 3:
            error(f"Power {off_or_on} was not successful for {unit} and 3 attempts have already been made. "
                  f"Do not try again.")
        if success:
            info(f"Power {off_or_on} was successful for {unit}. Continue.")

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)
