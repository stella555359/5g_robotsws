import re
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.bbmods_and_socs import get_bbmod_hex_position
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (InvalidUserInput, ErrorFromAdmin, ScriptIssue)
from testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.DSPCrash import DSPCrash
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import SSHConnectionFailure
from testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Resources.exceptions import AlarmWasNotSent
from testsuite.Oulu.TrunkEng.Common.Python.Resources.HpdDebugConfigFile import HpdDebugConfigFile


class FaultingBBMOD:
    """This class includes methods that are affecting BBMODs/SoCs"""

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.alarms = BuiltIn().get_library_instance("ALARMS")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.sent_fault = False
        self.cell_resources = BuiltIn().get_library_instance("CELL_RESOURCES")
        self.cells = BuiltIn().get_library_instance("CELLS")
        self.pb = BuiltIn().get_library_instance("PowerBreakers")

    def send_lom_fault(self, fsp_unit, k2_unit):
        """Send LOM fault to BBMOD unit"""
        send_amount = 180
        self.sent_fault = False
        # self.alarms.add_expected_alarm(fault_id="476")

        asia_side = self.bts.side
        smod_number = "2" if asia_side == "4" else "1"
        bbmod_hex = get_bbmod_hex_position(fsp_unit, asia_side, k2_unit)
        send_string = f"0x{bbmod_hex}10240"
        receive_string = f"0x{smod_number}0111202"
        sen = int(send_string, 16)
        rec = int(receive_string, 16)

        info("Sending: {}".format(send_string))
        self.send_fault_and_expect_alarm(send_amount, rec, sen, bbmod_hex)

        # self.alarms.remove_expected_alarms(fault_id="476")
        if not self.sent_fault:
            raise AlarmWasNotSent

    def send_fault_and_expect_alarm(self, send_amount, rec, sen, bbmod_hex):
        alarm = self.alarms.create_alarm(fault_id=476)
        for i in range(send_amount):
            if not self.sent_fault:
                info("loop:{}".format(i))
                self.admin.send_lom_fault_ind_msg(sen, rec, 476, 1, 1, 0, f"0x0000{bbmod_hex}1")
                BuiltIn().sleep("5s")
                alarm_found = self.alarms.check_if_alarm_in_rt_alarms(alarm)
                if not alarm_found:
                    continue
                else:
                    self.sent_fault = True
                    info("Alarm was found")
            else:
                break

    def generate_fault_to_fsp(self, bci, primary=True, secondary_soc="", graceful_reboot=False, during_startup=False):
        """
        Crash is caused to different BBMOD SoCs as follows:

        Primary:
        ABIA: FaultServiceExe is killed from K2A
        ABIN/ABIO: CCSEmDispatcherExe is killed from Snowfish
        ABIP/ABIQ: CCSEmDispatcherExe is killed from Marlin

        Secondary:
        ABIA: FaultServiceExe is killed from K2B, K2C or K2D
        ABIN: sfpd-application is killed from Loki
        ABIO: nrt-application is killed from Loki
        ABIP/Q: rt-application is killed from Thor

        :param obj bci: BCI object
        :param bool primary: If True then primary SoC is crashed, otherwise secondary, default is True.
        :param str secondary_soc: Secondary SoC name, if empty and primary is False then crash is caused to first
                                  secondary SoC found in SoC list.
        :param bool graceful_reboot: If True then graceful reboot is generated to ABIx primary SoC, default is False.
        :param bool during_startup: If True then fault is generated during startup, default is False.
        """
        applications = BuiltIn().get_library_instance("APPLICATIONS")

        if not any(bbmod for bbmod in ["ABIA", "ABIN", "ABIO", "ABIP", "ABIQ"] if bbmod in bci.name):
            warning(f"Generate Fault To FSP -KW supports only ABIA/ABIN/ABIO/ABIP/ABIQ. You are "
                    f"running test with {bci.name} so functionality is not guaranteed.")
        soc = bci.primary_soc if primary else (secondary_soc if secondary_soc else bci.secondary_socs[0])
        if "ABIA" in bci.name:
            applications.kill_faultserviceexe_from_abia(bci, soc)
            if primary:
                if during_startup:
                    # alarms are allowed during startup, else mandatory
                    self.alarms.add_allowed_alarm(
                        fault_id="4341 / 4663 / 2087 / 1806",
                        fault_name="Baseband card autonomous reset as recovery action / "
                                   "Baseband card crash has been detected", hw_path=bci.hw_path)
                else:
                    self.alarms.add_expected_alarm(
                        fault_id="4341 / 4663 / 2087 / 1806",
                        fault_name="Baseband card autonomous reset as recovery action / "
                                   "Baseband card crash has been detected", hw_path=bci.hw_path)
                # this is allowed to be seen also, agreed during pronto PR780992 CNN phase
                self.alarms.add_allowed_alarm(
                    fault_id="1811",
                    fault_name="Baseband card autonomous reset as recovery action", hw_path=bci.hw_path)
            else:
                self.alarms.add_expected_alarm(
                    fault_id="2087", fault_name="SoC autonomous reset as recovery action", hw_path=bci.hw_path)
                self.alarms.add_expected_alarm(
                    fault_id="4341", fault_name="DSP group autonomous reset as recovery action",
                    hw_path=bci.hw_path)
        else:
            if primary and graceful_reboot:
                self.generate_graceful_reboot_to_abix(bci)
                self.alarms.add_allowed_alarm(
                    fault_id="4019 / 6292 / 4335 / 1806 / 4341",
                    fault_name="Baseband card autonomous reset as recovery action / "
                               "Baseband card crash has been detected", hw_path=bci.hw_path)
            elif primary:
                applications.kill_real_application_from_soc(bci, soc, "CCSDaemonExe")
                if during_startup:
                    self.alarms.add_allowed_alarm(
                        fault_id="4663 / 4019 / 4341",
                        fault_name="Baseband card autonomous reset as recovery action / "
                                   "Baseband card crash has been detected", hw_path=bci.hw_path)
                    self.alarms.add_allowed_alarm(
                        fault_id="4663 / 4019 / 4341",
                        fault_name="SoC autonomous reset as recovery action", hw_path=bci.hw_path)
                else:
                    self.alarms.add_expected_alarm(
                        fault_id="4663 / 4019 / 4341",
                        fault_name="Baseband card autonomous reset as recovery action / "
                                   "Baseband card crash has been detected / "
                                   "SoC autonomous reset as recovery action", hw_path=bci.hw_path)
                    self.alarms.add_allowed_alarm(
                        fault_id="4663 / 4019 / 4341",
                        fault_name="Baseband card autonomous reset as recovery action / "
                                   "Baseband card crash has been detected / "
                                   "SoC autonomous reset as recovery action", hw_path=bci.hw_path)
            else:
                if during_startup:
                    self.alarms.add_allowed_alarm(
                        fault_id="2087", fault_name="SoC autonomous reset as recovery action", hw_path=bci.hw_path)
                else:
                    self.alarms.add_expected_alarm(
                        fault_id="2087", fault_name="SoC autonomous reset as recovery action", hw_path=bci.hw_path)
                if "ABIN" in bci.name:
                    application = "sfpd"
                elif "ABIO" in bci.name:
                    application = "l1_application_nrt"
                else:
                    application = "l1_application_rt"
                applications.kill_application_from_secondary_soc(bci, soc, application)

    def generate_graceful_reboot_to_abix(self, bci):
        fsp_ips = BuiltIn().get_library_instance("FSP")

        if not any(bbmod for bbmod in ["ABIP", "ABIN", "ABIO", "ABIQ"] if bbmod in bci.name):
            warning(f"Generating graceful reboot -test is planned for primary SoC of ABIP/ABIN/ABIO/ABIQ. You are "
                    f"running test with {bci.name} so functionality is not guaranteed.")
        fsp_ip = fsp_ips.get_ip_of_selected_fsp(bci.name, bci.primary_soc)
        info("Check if FSP pings before trying to send commands.")
        enb_ssh = self.bts.ping_ip_from_smod(fsp_ip, disconnect_ssh=False, return_ssh_object=True)
        if not enb_ssh:
            enb_ssh = self.ssh.ssh_connection_to_smod()
        time_to_wait = BuiltIn().get_variable_value("${WAIT_AFTER_BBMOD_PING}", default="7")
        info(f"Wait {time_to_wait}s before connecting to {bci.name}/{bci.primary_soc} and sending graceful reboot "
             f"-command.")
        BuiltIn().sleep(f"{time_to_wait}s")
        fsp_ssh = self.ssh.connect_to_fsp(enb_ssh, fsp_ip, "toor4nsn")
        command = r"ddal -s ddal_reboot_graceful"
        info(f"Generating graceful reboot with command '{command}'")
        self.ssh.send_command_to_fsp_by_ssh(fsp_ssh, command, ssh_timeout=60)
        self.ssh.disconnect_ssh_connection(fsp_ssh)

    @staticmethod
    def generate_dsp_crash_to_abia(bci, kepler):
        dsp_crash = DSPCrash()
        dsp_crash.open_connection()
        dsp_crash.send_silent_crash_to_kepler(bci, kepler)
        dsp_crash.close_connection()

    def generate_fault_to_abio_loki_ab(self, bbmod_name, soc, check_ping=True):
        """
        Generate fault to ABIO Loki A/B. Uses command "bmutool -s <slot> -r 0x10 0xA0" for LOKI#A and
        "bmutool -s <slot> -r 0x11 0xA0" for LOKI#B.
        Slot 1 is for BBMOD1, 2 for BBMOD2, and 3 for BBMOD3.

        :param str bbmod_name: BBMOD name to generate fault to (ABIO1, ABIO2, ...).
        :param str soc: SoC to generate fault to, can be either "LokiA" or "LokiB".
        :param bool check_ping: If True then check if FSP pings before trying to send commands, default is True.
        """
        fsp_ips = BuiltIn().get_library_instance("FSP")

        if "ABIO" not in bbmod_name or "LOKI" not in soc:
            warning(f"Generate Fault To ABIO LOKI#A/B -KW supports only ABIO. "
                    f"You are running test with {bbmod_name} - {soc} so functionality is not guaranteed.")
        if check_ping:
            fsp_ip = fsp_ips.get_ip_of_selected_fsp(bbmod_name, soc)
            info("Check if FSP pings before trying to send commands.")
            self.bts.ping_ip_from_smod(fsp_ip)
        loki_id = 0 if "A" in soc else 1
        command = rf"bmutool -s {bbmod_name[-1]} -r 0x1{loki_id} 0xA0"
        info(f"Wait 5s before sending '{command}' -command.")
        BuiltIn().sleep("5s")
        info(f"Generating fault to BBMOD SoC ({bbmod_name}/{soc}) with command: '{command}'")
        self.ssh.send_command_to_smod_by_ssh(command, print_to_eventlog=True, name_for_log="fault_to_abio",
                                             ip_to_connect="192.168.255.129", raise_error=True, disconnect_ssh=True)

    def check_user_input(self, soc):
        """
        Check user input. Check that SOC is given and it is in correct format. If not raise InvalidUserInput error.

        :param str soc: Soc (LOKI) to be break, for example ABIO1/LOKI#A, ABIO1/LOKI#B, ABIO2/LOKI#A, BBMOD1/LOKI#A...
        """
        self.logger.debug(f"Check user input. SOC: {soc}")
        if not soc:
            if "${LOKI_TO_BREAK}" not in BuiltIn().get_variables():
                error("SOC is not given. Give SOC as parameter to break_another_loki method or set value to "
                      "suite variable LOKI_TO_BREAK.")
                raise InvalidUserInput("SoC to be faulted in test setup is not given.")
            soc = BuiltIn().get_variable_value("${LOKI_TO_BREAK}")
        if "/" not in soc or (soc[soc.rfind("/") + 1:] not in ["LOKI#A", "LOKI#B"]):
            error(f"Given SOC {soc} is not valid for this method. SOC should be in format:"
                  f"ABIO<position>/LOKI#A or ABIO<position>/LOKI#B or BBMOD<position>/LOKI#A or "
                  f"SMOD<side>/BBMOD<position>/LOKI#B ...")
            raise InvalidUserInput(f"Given SOC {soc} is not valid for this method.")
        bbmod_object = self.bts.get_bbmod_object_from_user_given_values(soc[:soc.rfind("/")])
        return bbmod_object, soc[soc.rfind("/") + 1:]

    def check_environment_suitability(self):
        """
        Check if there is ABIO in environment, if not raise InvalidUserInput error and don't run the test at all.
        ABIO has two Loki in the environment and test cannot be run with HW that doesn't have Loki or there are less
        than two Loki. For example ABIN is not suitable because there is just one Loki. If no ABIO raise error that used
         hardware is not suitable for the test and don't run the test.
        """
        self.logger.debug("Check environment suitability.")
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if not self.bts.bbmods:
            error("There is no BBMODs in the environment. Test can't be run.")
            raise InvalidUserInput("There is no BBMODs in the selected environment.")
        if not any("ABIO" in bbmod.name for bbmod in self.bts.bbmods):
            error("There is no ABIO in the selected environment. Hardware is not suitable for this test. Test can't be"
                  " run.")
            raise InvalidUserInput("There is no ABIO in the selected environment. Hardware is not suitable for this "
                                   "test.")
        else:
            info("There is ABIO in the environment. ")

    def set_loki_suite_alarms(self, bbmod_object, soc_name, affected_cells, affected_radios):
        """
        Set LOKI suite alarms to be used in the test suites.

        :param obj bbmod_object: BBMOD object.
        :param str soc_name: SOC name for example LOKI#A
        :param list affected_cells: List of affected cells.
        :param list affected_radios: List of affected radios.
        """
        faulty_loki_alarm = []
        if affected_cells:  # will be degraded cells
            # alarming_cells = self.cells.get_cells_to_alarm_format(affected_cells, lte441a_active=True)
            # alarming_cells_faulty = self.cells.get_cells_to_alarm_format(affected_cells, lte441a_active=False)
            # remove from severity and cells from 252 alarm
            # severity="Major", cells_cli_info=alarming_cells
            reason_soc = self.get_soc_reason(soc_name)
            self.logger.debug(f"This LOKI is {reason_soc}")
            faulty_loki_alarm.append(self.alarms.create_alarm(
                alarm_id="7100 / 7115", fault_id="252", fault_name="Baseband Module Hardware Failure",
                hw_path=bbmod_object.hw_path, unit_path=bbmod_object.unit_path))
            faulty_loki_alarm.append(self.alarms.create_alarm(
                alarm_id="7116 / 7101", fault_id="4019 / 2087",
                fault_name="Master unit has lost connection to the slave unit / "
                           "Baseband card autonomous reset as recovery action / "
                           "Critical SW Component failure",
                hw_path=bbmod_object.hw_path, unit_path=bbmod_object.unit_path))
            faulty_loki_alarm.append(self.alarms.create_alarm(
                alarm_id="7114", fault_id="1868", fault_name="BTS configuration error (not enough HW for LCR)",
                reason="Not enough DSP or baseband pool resources for cell detected / Uplane calculation failure due to"
                       " not enough cablink throughput."))
        if affected_radios:
            for rmod in affected_radios:
                for rm in self.bts.radios:
                    if rm.name == rmod:
                        faulty_loki_alarm.append(self.alarms.create_alarm(
                            fault_id="10", fault_name="No connection to unit", hw_path=rm.hw_path,
                            unit_path=rm.unit_path))
                        break
        info(f"Set suite variable F_LOKI_ALARMS with values:")
        info(self.alarms.pretty_alarm_print(faulty_loki_alarm))
        BuiltIn().set_suite_variable("${F_LOKI_ALARMS}", faulty_loki_alarm)

    def get_radio_cell_information(self):
        """Get radio and cell information"""
        radio_cell_information = {}
        if self.bts.radios:
            for radio in self.bts.radios:
                if radio.name not in radio_cell_information:
                    radio_cell_information[radio.name] = {}
                for cell in self.bts.cells:
                    for link in self.bts.cells[cell]["carrierList"]:
                        if f"{radio.scf_dist_name}/" in link["antennaLineId"]["configuration"]:
                            if cell not in radio_cell_information[radio.name]:
                                radio_cell_information[radio.name][cell] = {}
                            antenna = link["antennaLineId"]["configuration"]
                            if antenna not in radio_cell_information[radio.name][cell]:  # only TX or RX
                                radio_cell_information[radio.name][cell][antenna] = link["direction"]
                            else:  # TX and RX between cell and radio
                                radio_cell_information[radio.name][cell][antenna] = "TXRX"
        info(f"Radio and affected cells: {radio_cell_information}")
        return radio_cell_information

    def set_loki_suite_variables(self, bbmod_object, soc_name):
        """
        Set LOKI suite variables to be used in the test suites.

        :param bbmod_object: BBMOD object.
        :param soc_name: SOC name for example LOKI#A
        """
        info("Get and set F_LOKI_* suite variables")
        cells_of_soc = self.cell_resources.get_cells_of_soc(bbmod_object.name, soc_name)
        info(f"Set suite variable F_LOKI_BBMOD with values: {bbmod_object.name}")
        BuiltIn().set_suite_variable("${F_LOKI_BBMOD}", bbmod_object.name)
        info(f"Set suite variable F_LOKI with values: {soc_name}")
        BuiltIn().set_suite_variable("${F_LOKI}", soc_name)
        radios_on_bbmod = self.bts.get_rmods_connected_to_bbmod(bbmod_object.name)
        radios_and_cells_info = self.get_radio_cell_information()
        affected_radios = []
        affected_cells = []
        cells_of_rmod = []
        if radios_on_bbmod:
            for radio in radios_on_bbmod:
                # cells_of_rmod = self.bts.get_cells_of_radio(radio)
                if radio in radios_and_cells_info:
                    cells_of_rmod = radios_and_cells_info[radio]
                else:
                    error("Radio {} is not found in radio_cell_information.".format(radio))
                for soc_cell in cells_of_soc:
                    for radio_cell in cells_of_rmod:  # cells in radion are named as lncell-number of nrcell-number
                        if soc_cell in radio_cell and soc_cell == radio_cell.split("-")[1]:
                            affected_radios.append(radio)
                            affected_cells.append(radio_cell)
        info(f"Set suite variable F_LOKI_RMODS with values: {affected_radios}")
        BuiltIn().set_suite_variable("${F_LOKI_RMODS}", affected_radios)
        info(f"Set suite variable F_LOKI_CELLS with values: {affected_cells}")
        BuiltIn().set_suite_variable("${F_LOKI_CELLS}", affected_cells)
        self.set_loki_suite_alarms(bbmod_object, soc_name, affected_cells, affected_radios)

    def break_another_loki(self, soc=None):
        """
        Break another loki method first checks if there is suite variable/tag BREAK_LOKI, and it is set True, if it
        doesn't exist or has value False, it doesn't do anything. Then it checks if there is Loki in environment, if
        not raise InvalidUserInput error and don't run the test at all. Then it checks if there is more than one Loki in
        the environment if not raise error that used hardware is not suitable for the test. Don't run the test.

        :param str soc: Soc (LOKI) to be break, for example ABIO1/LOKI#A, ABIO1/LOKI#B, ABIO2/LOKI#A, BBMOD3/LOKI#B...
        """
        if BuiltIn().get_variable_value("${BREAK_LOKI}"):
            info("BREAK_LOKI is set to True.")
            if not soc:
                if "${LOKI_TO_BREAK}" not in BuiltIn().get_variables():
                    error("SOC is not given. Give SOC as parameter to break_another_loki method or set value to "
                          "suite variable LOKI_TO_BREAK.")
                    raise InvalidUserInput("SoC to be faulted in test setup is not given.")
                soc = BuiltIn().get_variable_value("${LOKI_TO_BREAK}")
            self.check_environment_suitability()
            bbmod_object, soc_name = self.check_user_input(soc)
            self.set_loki_suite_variables(bbmod_object, soc_name)
            # info(f"Generate fault to {soc} ({bbmod_object.name} - {soc_name})")
            self.check_if_bbmod_version_is_suitable(bbmod_object.name)
            self.generate_fault_to_abio_loki_ab(bbmod_object.name, soc_name, check_ping=False)
            self.bts.wait_time_and_reason(sleep_time="120", wait_reason="after faulting LOKI.")
        else:
            info("BREAK_LOKI is set to False, don't break any Loki.")

    def check_if_bbmod_version_is_suitable(self, bbmod_name):
        """
        Check if BBMOD version is suitable for the test. Only versions 102, 103 and 104 are suitable.

        :param str bbmod_name: BBMOD name to be checked. For example ABIO1, ABIO2, ABIO2.1, ABIO2.3...
        """
        # command = self.check_sanity_of_bbmod_name_return_command(bbmod_name)
        # commands = [command, "chk ver"]
        commands = "chk ver"
        fsp_ips = BuiltIn().get_library_instance("FSP")
        fsp_ip = fsp_ips.get_ip_of_selected_fsp(bbmod_name)
        enb_ssh = self.ssh.ssh_connection_to_smod()
        fsp_ssh = self.ssh.connect_to_fsp(enb_ssh, fsp_ip, "toor4nsn")
        info(f"Check if BBMOD version is suitable for the test. BBMOD: {bbmod_name}")
        output = self.ssh.send_command_to_smod_by_ssh(commands, enb_ssh=fsp_ssh, print_to_eventlog=True,
                                                      return_output=True, name_for_log="check_bbmod_version")
        if output:
            outp = output.split("\n")
            pattern = re.compile(r".*board\s+product-code\s+=\s+(?P<version>.*)\s+-.*")
            for out in outp:
                match = pattern.match(out)
                if match:
                    version = match.group("version")
                    info(f"BBMOD version: {version}")
                    if not version or "." not in version:
                        error("BBMOD version is in unknown format. Version is not not suitable for the test. Check if"
                              " BBMOD version is valid.")
                        raise ScriptIssue(f"BBMOD version {version} is not suitable for the test.")
                    if version.split(".")[1] not in ("102", "103", "104"):
                        error(f"BBMOD {bbmod_name} version {version} is not suitable for the test with BREAK_LOKI. "
                              f"Only versions 102, 103 and 104 are suitable.")
                        raise InvalidUserInput(f"BBMOD {bbmod_name} version {version} is not suitable for the test")
                    else:
                        info(f"BBMOD {bbmod_name} version {version} is suitable for the test with BREAK_LOKI.")
        else:
            error("Output is empty. Cannot check if BBMOD version is valid.")
            raise SSHConnectionFailure("Output is empty. Cannot check if BBMOD version is valid.")

    # def check_sanity_of_bbmod_name_return_command(self, bbmod_name):
    #     """
    #     Check sanity of BBMOD name return command checks sanity and returns command to be used in the test.
    #     """
    #     if not bbmod_name:
    #         error("BBMOD name is not given. Give BBMOD name as parameter to check_if_bbmod_version_is_suitable.")
    #         raise ScriptIssue("BBMOD name is not given to check_if_bbmod_version_is_suitable.")
    #     self.logger.debug(f"Check sanity of BBMOD name. BBMOD: {bbmod_name}")
    #     if bbmod_name[-1] == '1':
    #         return "bsh 1:0"
    #     elif bbmod_name[-1] == '2':
    #         return "bsh 2:0"
    #     elif bbmod_name[-1] == '3':
    #         return "bsh 3:0"
    #     else:
    #         error("BBMOD name is not valid. Give BBMOD name as parameter to check_if_bbmod_version_is_suitable.")
    #         raise InvalidUserInput("BBMOD name is not valid to check_if_bbmod_version_is_suitable.")

    def get_soc_reason(self, soc):
        """
        Get soc reason for alarm.

        :param str soc: Name of SoC for example LOKI#A, LOKI#B
        :return: SoC_B or SoC_C
        """
        self.logger.debug(f"Get reason SoC to alarm. SoC: {soc}")
        if soc == "LOKI#A":
            return "SoC_B"
        elif soc == "LOKI#B":
            return "SoC_C"
        return None

    def restore_another_loki(self, remote_power_reset=False):
        """
        Restore another loki method first checks if there is suite variable/tag BREAK_LOKI, and it is set True, if it is
        False, it doesn't do anything. Then it checks if there is F_LOKI suite variable in environment, if not then does
         nothing because then the restore has been done in some other test etc. and values are already cleaned.

        :param bool remote_power_reset: If True then remote power reset is performed to SMOD, default is False.
        """
        if (BuiltIn().get_variable_value("${BREAK_LOKI}") and BuiltIn().get_variable_value("${RESTORE_LOKI}") and
                BuiltIn().get_variable_value("${F_LOKI}")):
            info("BREAK_LOKI and RESTORE_LOKI are set to True. Restoring LOKI by power reset.")
            if remote_power_reset:
                info("Perform remote power reset to SMOD.")
                self.perform_remote_power_reset()
            else:
                self.perform_power_reset()
            self.bts.wait_time_and_reason(sleep_time="300", wait_reason="after restoring LOKI.")

    def perform_remote_power_reset(self, reset_with_snapshot=False, wait_for_reconnection=True):
        """
        Perform remote power reset to SMOD.
        """
        try:
            response = self.admin.power_reset(
                reset_with_snapshot=reset_with_snapshot, wait_for_reconnection=wait_for_reconnection)
            print(response)
            if BuiltIn().get_variable_value("${RESTORE_LOKI}"):
                for variable in ["${F_LOKI_BBMOD}", "${F_LOKI}", "${F_LOKI_RMODS}", "${F_LOKI_CELLS}",
                                 "${F_LOKI_ALARMS}"]:
                    info(f"Set suite variable {variable} to None")
                    BuiltIn().set_suite_variable(variable, None)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            error(f"Unable to perform power reset from admin. {admin_error.__class__.__name__}:"
                  f"{admin_error} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            raise ErrorFromAdmin(f"Unable to do power reset from admin, {admin_error.__class__.__name__} was raised.")

    def perform_power_reset(self):
        """
        Perform power reset to SMOD.
        """
        try:
            self.pb.switch_power_off_from_all_local_units()
            self.bts.wait_time_and_reason(sleep_time="5", wait_reason="after SMOD power OFF.")
            self.pb.switch_power_on_to_all_local_units()
            if "${RESTORE_LOKI}" in BuiltIn().get_variables() and BuiltIn().get_variable_value("${RESTORE_LOKI}"):
                for variable in ["${F_LOKI_BBMOD}", "${F_LOKI}", "${F_LOKI_RMODS}", "${F_LOKI_CELLS}",
                                 "${F_LOKI_ALARMS}"]:
                    info(f"Set suite variable {variable} to None")
                    BuiltIn().set_suite_variable(variable, None)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException, KeyError, ValueError) as admin_error:
            error(f"Problems when performing power reset (ON-OFF). {admin_error.__class__.__name__}:"
                  f"{admin_error} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            raise ErrorFromAdmin(f"Problems with power reset {admin_error.__class__.__name__} was raised.")

    def _set_faulty_bbmods_suite_variables(self, bbmod_objects):
        """
        Set FAULTY_BBMODS suite variables to be used in the test suites.

        :param bbmod_object: BBMOD objects.
        """
        info("Get and set FAULTY_BBMODS* suite variables")
        faulty_bbmods_cells = []
        affected_radios = []
        faulty_bbmods_alarms = []
        faulty_bbmods = []
        radios_and_cells_info = self.get_radio_cell_information()
        for bbmod in bbmod_objects:
            # ignore multifibre radios, because they are not included in radio_cell_information
            radios_on_bbmod = self.bts.get_rmods_connected_to_bbmod(bbmod.name, remove_multifibre=True)
            for radio in radios_on_bbmod:
                if radio not in affected_radios:
                    affected_radios.append(radio)
                if radio in radios_and_cells_info:
                    cells_of_rmod = radios_and_cells_info[radio]
                    for cell in cells_of_rmod:
                        if cell not in faulty_bbmods_cells:
                            faulty_bbmods_cells.append(cell)
                else:
                    error(f"Radio {radio} is not found in radio_cell_information:\n{radios_and_cells_info}.")
            faulty_bbmods.append(bbmod.name)
            faulty_bbmods_alarms.append(self.alarms.create_alarm(
                fault_id="10", fault_name="No connection to unit", unit_path=bbmod.unit_path))
            faulty_bbmods_alarms.append(self.alarms.create_alarm(
                fault_id="10", fault_name="Baseband card power autonomous reset as recovery action",
                unit_path=bbmod.unit_path))
        if faulty_bbmods:
            info(f"Set suite variable FAULTY_BBMODS with values: {faulty_bbmods}")
            BuiltIn().set_suite_variable("${FAULTY_BBMODS}", faulty_bbmods)
        else:
            info("No faulty BBMODs found.")
        if faulty_bbmods_cells:
            info(f"Set suite variable FAULTY_BBMODS_CELLS with values: {faulty_bbmods_cells}")
            BuiltIn().set_suite_variable("${FAULTY_BBMODS_CELLS}", faulty_bbmods_cells)
        else:
            info("No cells affected by faulty BBMODs found.")
        if affected_radios:
            for rmod in affected_radios:
                for rm in self.bts.radios:
                    if rm.name == rmod:
                        faulty_bbmods_alarms.append(self.alarms.create_alarm(
                            fault_id="10", fault_name="No connection to unit", unit_path=rm.unit_path))
                        break
            info(f"Set suite variable FAULTY_BBMODS_RMODS with values: {affected_radios}")
            BuiltIn().set_suite_variable("${FAULTY_BBMODS_RMODS}", affected_radios)
            info(f"Set suite variable FAULTY_BBMODS_ALARMS with values:")
            info(self.alarms.pretty_alarm_print(faulty_bbmods_alarms))
            BuiltIn().set_suite_variable("${FAULTY_BBMODS_ALARMS}", faulty_bbmods_alarms)
        else:
            info(f"Radios affected by {BuiltIn().get_variable_value('${BBMODS_MASK}')} not found.")

    def faulty_bbmods_with_hpd_debug_config_file(self, mask_value):
        """
        Faulty BBMODs with HPD debug configuration file. HPD debug configuration file is used to disable BBMODs. More
        info in https://jiradc.ext.net.nokia.com/browse/FCA_TATSCRIPTS-182810?filter=-1
        You may change the wait time after faulting BBMODs with suite variable ${WAIT_AFTER_FAULTING_BBMOD}, default
         value is 1500 seconds (default is 25 minutes).

        :param str mask_value: Mask value to disable BBMODs.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        try:
            wait_after_faulting_bbmod = BuiltIn().get_variable_value("${WAIT_AFTER_FAULTING_BBMOD}", default="1500")
            hdp_debug_config = HpdDebugConfigFile()
            mask_value = hdp_debug_config.check_mask_value_user_input(self.bts.bts_side_is_right, self.bts.fullrack,
                                                                      self.bts.bbmods)
            faulty_bbmods = hdp_debug_config.mask_value_fsp_slot[mask_value]
            # if self.bts.fullrack and mask_value[-1] == '0':  # Command is to right side BBMODs
            #     print("Environment is fullrack and command has been given to right side. Change BBMOD names.")
            #     faulty_bbmods = [f"{i[:-1]}2.{i[-1]}" for i in faulty_bbmods]
            faulty_bbmods_list = []
            for bbmod in faulty_bbmods:
                faulty_bbmods_list.append(self.bts.get_bbmod_object_from_user_given_values(bbmod))
            self._set_faulty_bbmods_suite_variables(faulty_bbmods_list)
            hdp_debug_config.write_mask_value_to_file_and_reboot()
            self.bts.ping_ip_until_disconnection_or_reconnection(disconnection=True, time_to_wait=300)
            self.bts.ping_ip_until_disconnection_or_reconnection(time_to_wait=600)
            # info("There are 10min timer, timer1, for detecting BBMODs and 10min timer, timer2, for checking if BBMOD "
            #      "enabled. Wait min before continuing test.")
            self.bts.wait_time_and_reason(sleep_time=wait_after_faulting_bbmod, wait_reason="after faulting BBMODs.")
        except Exception as e:
            error(f"Problems while faulting bbmods with hpd_debug_config_file {e.__class__.__name__}:{e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise ScriptIssue(f"Problems while faulting bbmods with hpd_debug_config_file "
                              f"/ffs/run/config/hpd_debug_config.txt. {e.__class__.__name__}:{e}")

    def restore_mask_and_suite_variables(self):
        """
        Restore BBMODs mask and variables. Set suite variables to None.
        """
        try:
            info("Restore BBMODs mask and variables.")
            hdp_debug_config = HpdDebugConfigFile()
            hdp_debug_config.remove_mask_value_from_file_and_reboot()
            self.bts.ping_ip_until_disconnection_or_reconnection(disconnection=True, time_to_wait=300)
            self.bts.ping_ip_until_disconnection_or_reconnection(time_to_wait=600)
            self.bts.check_if_admin_connection_available(wait_for_connection=300, create_connection=False)
            self.bts.wait_time_and_reason(sleep_time="300", wait_reason="seconds before continuing")
        except Exception as e:
            error(f"Problems while restoring bbmods mask {e.__class__.__name__}:{e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise ScriptIssue(f"Problems while removing /ffs/run/config/hpd_debug_config*. {e.__class__.__name__}:{e}")
        for variable in ["${BBMODS_MASK}", "${FAULTY_BBMODS}", "${FAULTY_BBMODS_CELLS}", "${FAULTY_BBMODS_RMODS}",
                         "${FAULTY_BBMODS_ALARMS}"]:
            info(f"Set suite variable {variable} to None")
            BuiltIn().set_suite_variable(variable, None)
