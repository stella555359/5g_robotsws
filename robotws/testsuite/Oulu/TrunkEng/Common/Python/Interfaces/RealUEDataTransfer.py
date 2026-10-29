"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import re
from traceback import format_exception
from requests.exceptions import ConnectionError
from robot.libraries.BuiltIn import BuiltIn
from ute_common_abstract_core.aliases_registry import aliases_registry
from taf.ue.android.exceptions import IperfStuckException
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import DataTransferFailed


class RealUEDataTransfer:

    utf = None
    _data_transfer_retries = 0

    def __init__(self):
        """
        Using RealUECalls requires having UltraCaller setup in the environment in use. In the setup,
        MN RAN Trunk OUL 2 SG -team can help.
        """
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.cells = BuiltIn().get_library_instance("CELLS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.taf_ue = BuiltIn().get_library_instance("UE")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.env_reservation = BuiltIn().get_library_instance("ENV_RESERVATION")
        self.utf = None

        self.ue_dt_aliases = {}

    def enable_and_disable_airplane_mode(self, first_ue):
        """
        Enable and disable airplane mode for all UEs in the environment.
        """
        info("Enable and disable airplane mode for all UEs in the environment")
        alias = "UESSH"
        ip = first_ue.ue_pc_address
        username = first_ue.ssh_connection_details.username
        password = first_ue.ssh_connection_details.password
        self.ssh.take_ssh_connection(ip, alias=alias, username=username, password=password)
        output = self.ssh.send_command_to_ip_return_output("adb devices", alias=alias)
        devices = re.findall(r"R\w+|H\w+\b(?=\s+device)", output, re.MULTILINE)  # Works only for Nokia and Samsung
        for device in devices:
            self.ssh.send_command_to_ip_return_output(f"adb -s {device} shell cmd connectivity airplane-mode enable",
                                                      alias=alias)
            BuiltIn().sleep("1s")
            self.ssh.send_command_to_ip_return_output(f"adb -s {device} shell cmd connectivity airplane-mode disable",
                                                      alias=alias)
            BuiltIn().sleep("1s")
        self.ssh.close_ssh_connection(alias=alias, close_ssh_log=True)

    def prepare_ues(self):
        """
        Uses init -file to find all UEs in the test environment and prepares them for the data transfer test.
        Run this KW before attempting a data transfer test.
        """
        self.ue_dt_aliases = {}
        existing_aliases = self._get_ue_alias_list()
        if existing_aliases:
            self.teardown_ue_aliases(existing_aliases)
        ue_list = self.bts.tl.ues
        if ue_list:
            self.enable_and_disable_airplane_mode(ue_list[0])
        for ue in ue_list:
            ue_capability = ue.capabilities[0]
            info(f"Preparing the following UE: {ue_capability}")
            ue_alias = f"UE{ue_capability[-1]}"
            if ue_alias in existing_aliases:
                info(f"{ue_alias} exists already, skip preparations.")
                self.ue_dt_aliases[ue_alias] = []
                continue
            # We might need to change from capabilities to starting cell when we start using bigger environments
            try:
                self.taf_ue.require_ue(ue_alias, capabilities=ue_capability)
                self.taf_ue.attach_ue(ue_alias)
                self.taf_ue.log_ue_info(ue_alias)
            except ConnectionError as e:
                error(f"Received ConnectionError, proxy might be down: {e}\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                raise DataTransferFailed("Cannot connect to proxy or UE, cannot prepare UE test.")
            self.ue_dt_aliases[ue_alias] = []

    def make_data_transfer_test(self, data_transfer="ul+dl", duration="5s"):
        """
        Makes a data transfer test using an Iperf server. Data transfer is started and stopped within this KW.

        :param str data_transfer: Options are 'ul', 'dl', 'ul+dl'.
        :param str duration: Duration of the data transfer test.
        """
        if not RealUEDataTransfer.utf:
            used_tags = self.env_reservation.get_tags_used_in_reservation()
            if "UPGRADE_UTF" in used_tags:
                from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.UTF import UTF
                RealUEDataTransfer.utf = UTF()
        if RealUEDataTransfer.utf:
            RealUEDataTransfer.utf.start_utf_logs()
        info("Starting a data transfer check to make sure there are no sleeping cells.")
        if data_transfer == "ul+dl":
            self._start_data_transfer("ul")
            self._start_data_transfer("dl")
        else:
            self._start_data_transfer(data_transfer)
        info("Wait 5s before making data transfer check.")
        BuiltIn().sleep(duration)
        success = self._make_data_transfer_check()
        self._stop_all_data_transfer()
        if RealUEDataTransfer.utf:
            RealUEDataTransfer.utf.stop_trace_and_get_logs()
            # RealUEDataTransfer.utf.finalize_utf()
        if not success:
            raise DataTransferFailed("Sleeping cell(s) found in the environment.")

    def teardown_ue_aliases(self, aliases):
        """
        Teardown aliases in the beginning of test if they are found before starting the preparations.
        """
        info(f"Found aliases: {aliases}. Teardown UL and DL aliases in the beginning of test.")
        for alias in aliases:
            if "dl" in alias or "ul" in alias:
                info(f"Teardown alias: {alias}")
                aliases_registry().release([alias])
        info(f"Found aliases after teardown: {self._get_ue_alias_list()}")

    def _start_data_transfer_with_retry(self, dt_alias, ue_alias, data_transfer):
        while RealUEDataTransfer._data_transfer_retries < 3:
            try:
                self.taf_ue.start_data_transfer(dt_alias, ue_alias, data_transfer, protocol="tcp")
                break
            except Exception as e:
                if "Iperf port" in str(e) and "is already in use" in str(e):
                    info(f"Iperf port is already in use for {ue_alias}, try again.")
                    RealUEDataTransfer._data_transfer_retries += 1
                else:
                    error(f"DataTransferNotRunningException for {ue_alias}: {e}. Continuing to next ue")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    break

    def _start_data_transfer(self, data_transfer):
        try:
            for ue_alias in self.ue_dt_aliases:
                if ue_alias in self._get_ue_alias_list():
                    dt_alias = f"DT{ue_alias[-1]}_{data_transfer}"
                    self.ue_dt_aliases[ue_alias].append(dt_alias)
                    info(f"Starting data transfer for {ue_alias} ({dt_alias}) and performing checks.")
                    self._start_data_transfer_with_retry(dt_alias, ue_alias, data_transfer)
                else:
                    warning(f"Skip data transfer test for {ue_alias}, it is not found from alias list.")
        except IperfStuckException as e:
            error(f"Loop {int(self.logger.loop) + 1}: IperfStuckException "
                  f"--> Problem with Iperf server, there might be a sleeping cell.\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise DataTransferFailed("Problem with Iperf server, there might be a sleeping cell.")

    def _make_data_transfer_check(self):
        success = True
        if not self.ue_dt_aliases:
            warning("Did not find any UEs to make data transfer test, cannot test for sleeping cells.")
            return
        for ue_alias in self.ue_dt_aliases:
            for dt_alias in self.ue_dt_aliases[ue_alias]:
                if dt_alias in self._get_ue_alias_list():
                    self.taf_ue.check_data_transfer_is_alive(dt_alias)
                    avg_throughput = self.taf_ue.get_average_throughput(dt_alias)
                    info("{}: average throughput: {} kb/s".format(dt_alias, avg_throughput))
                    if int(avg_throughput) == 0:
                        error("There is a sleeping cell in env ({}).".format(ue_alias))
                        success = False
                        BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                else:
                    warning(f"Skip data transfer test for {ue_alias}:{dt_alias}, it is not found from alias list.")
        if success:
            info("No sleeping cells found in data transfer check.")
        return success

    def _stop_all_data_transfer(self):
        for ue_alias, dt_aliases in self.ue_dt_aliases.items():
            for dt_alias in dt_aliases[:]:
                if dt_alias in self._get_ue_alias_list():
                    info(f"Stopping data transfer for {ue_alias}:{dt_alias}.")
                    self.taf_ue.stop_data_transfer(dt_alias)
                    self.ue_dt_aliases[ue_alias].remove(dt_alias)

    @staticmethod
    def _get_ue_alias_list():
        return list(aliases_registry().keys())
