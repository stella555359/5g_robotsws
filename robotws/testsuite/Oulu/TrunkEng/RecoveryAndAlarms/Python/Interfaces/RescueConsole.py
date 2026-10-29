"""
:author: Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
import os
import datetime
from robot.libraries.BuiltIn import BuiltIn
from traceback import format_exception
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from taf.fdsw.rc.clients.exceptions import (TimeoutExceeded, UnexpectedFrameReceived, OutgoingFrameRejected,
                                            FrameDecodingError, ClientAuthenticationFailed, ClientConnectionFailed,
                                            ClientRequestFailed, ClientNotConnected)
from taf.fdsw.rc.interfaces.exceptions import (OperationFailure, RootDirNotFound, FunctionalityNotImplemented)
from jsilib.jsonrpc.exc import ClientClosedError
from jsilib.jsi.exc import (ConnectionClosedByTransport, ConnectionClosedByPingLoss, MessageCacheClosedError,
                            ConnectionClosedError)
import asyncio
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FDSW import FDSW
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (
    UnallowedAlarmFound, ExpectedAlarmNotFound, EnvironmentIssue, PingToIpNotLost, ExpectedLogsNotFound,
    ErrorFromRescueConsole)
from testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Resources.exceptions import (
    WrongSWActive, UnexpectedPartitionActive, ParsingIssue, FilePathIssue)


class RescueConsole:
    """
        RescueConsole is a collection of methods that uses Rescue Console in tests.

        RescueConsole is NOT called in common_resources.robot. In test case you have to import taf.fdws.rc,
        FDSW library and this library for example like this:
            >> Library      taf.fdsw.rc  WITH NAME  RC
            >> Library      testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FDSW  WITH NAME  FDSW
            >> Library      testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.RescueConsole
        """

    press_button_time = None
    sw_inventory = None

    def __init__(self):
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.rc = BuiltIn().get_library_instance("RC")
        self.fd_sw = FDSW()

    def open_bts_ssh_connection(self):
        """ Open ssh connection to BTS. """
        self.ssh.take_ssh_connection("192.168.255.129", alias="BTS")

    def close_bts_ssh_connection(self):
        """ Close ssh connection to BTS. """
        if self.ssh:
            self.ssh.close_ssh_connection("BTS")
        else:
            self.logger.debug("Ssh is None, cannot close")

    def press_service_button(self, unit, length):
        """
        Emulate pressing of service button in BTS.

        :param str unit: Unit of the BTS. For example ASIA, ASIB, ASOG, ASOH or ASOE.
        :param str length: Length of the service button press. Short or long.
        """
        info(self.bts.active_sw)
        info(self.bts.passive_sw)
        command = ""
        if "ASIA" in unit or "ASIB" in unit:
            if "ASIB" in unit:
                if length.lower() == "short":
                    info("Emulate short service button press. (Command: /usr/bin/memdump -d d0040020D8 0xBA)")
                    command = "/usr/bin/memdump -d d0040020D8 0xBA"
                if length.lower() == "long":
                    info("Emulate long service button press. (Command: /usr/bin/memdump -d d0040020D8 0xBA)")
                    command = "/usr/bin/memdump -d d0040020D8 0xBA"
            else:
                self.ssh.send_command_to_ip_return_output("cd /usr/bin", "BTS")
                if length.lower() == "short":
                    info("Emulate short service button press. (Command: memdump -d 30800020d8 0xba)")
                    command = "memdump -d 30800020d8 0xba"
                if length.lower() == "long":
                    info("Emulate long service button press. (Command: memdump -d 30800020d8 0xbe)")
                    command = "memdump -d 30800020d8 0xbe"
            RescueConsole.press_button_time = datetime.datetime.now()
            output = self.ssh.send_command_to_ip_return_output(command, "BTS")
        else:  # if "ASOE" in unit:
            if length.lower() == "short":
                info("Emulate short service button press. (Command: pcotool -s -r 0x20D8 0xBA)")
                command = "pcotool -s -r 0x20D8 0xBA"
            if length.lower() == "long":
                info("Emulate long service button press. (Command: pcotool -s -r 0x20D8 0xBE)")
                command = "pcotool -s -r 0x20D8 0xBE"
            RescueConsole.press_button_time = datetime.datetime.now()
            output = self.ssh.connection_command_and_output(command, alias="EMULATE")
        if command:
            self.logger.debug("Output from emulating was: {}".format(output))
            info("Service button was pressed {}".format(RescueConsole.press_button_time))
        else:
            error("Could not find the command for pressing the service button.")
            raise EnvironmentIssue

    def check_that_ping_is_lost_after_service_button_press(self, unit, length):
        """
        Verify that ping to BTS doesn't reply after service button press. If ping is not lost, press button again.

        :param str unit: Unit of the BTS. For example ASIA, ASIB, ASOG, ASOH or ASOE.
        :param str length: Length of the service button press. Short or long.
        """
        info("Wait for ping to be lost max 300s.")
        ping_lost = self.bts.ping_ip_until_disconnection_or_reconnection(ip_to_ping="192.168.255.129",
                                                                         disconnection=True, boolean_return=True)
        if not ping_lost:
            info("Ping was not lost during 300s wait time after emulating {} service button press. "
                 "Emulate service button press again and wait max 300s for disconnection.".format(length))
            self.press_service_button(unit, length)
            ping_lost = self.bts.ping_ip_until_disconnection_or_reconnection(ip_to_ping="192.168.255.129",
                                                                             disconnection=True, boolean_return=True)
            if not ping_lost:
                error(f"Ping was not lost during 300s wait time after emulating {length} service button, press again."
                      f"Check that you have given correct unit for the emulate command.")
                raise PingToIpNotLost(f"Ping was not lost during 300s wait time "
                                      f"after emulating {length} service button.")
            else:
                info("Ping to BTS is lost. Disconnection of BTS is noticed after second time to press button.")
        else:
            info("Ping to BTS is lost. Disconnection of BTS is noticed.")

    def connect_to_rc(self):
        """Tries to create connection Rescue Console and if exception is noticed raises error."""
        info("Connecting to Rescue Console...")
        try:
            d_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            file_path = os.path.join(self.logger.log_dir, f"jsilib_{d_time}.log")
            self.rc.connect_to("192.168.255.129", 443, "Nemuadmin", "nemuuser", name="rc_connection",
                               log_level="DEBUG", file_path=file_path)
        except (TimeoutExceeded, UnexpectedFrameReceived, OutgoingFrameRejected, FrameDecodingError,
                ClientAuthenticationFailed, ClientConnectionFailed, ClientRequestFailed, ClientNotConnected,
                OperationFailure, RootDirNotFound, FunctionalityNotImplemented,
                AliasLookupError, AliasInUse, ClientClosedError) as rc_error:
            tb = ''.join(format_exception(type(rc_error), rc_error, rc_error.__traceback__))
            extra_info = ""
            if "TimeoutExceeded" in tb:
                extra_info = "Because of TimeoutExceeded error, most likely activation of RescueConsole has failed. "
            error(f"{extra_info}Connection to Rescue Console failed: {rc_error.__class__.__name__}: {rc_error}\n{tb}")
            raise ErrorFromRescueConsole(f"Connection to Rescue Console raised {rc_error.__class__.__name__}")
        info("Rescue Console connection successful.")

    def check_partition_and_sw(self):
        """Check software partition and version from Rescue Console."""
        partition = ""
        try:
            sw_inventory = self.rc.get_all_software_inventory(connection="rc_connection")
        except (TimeoutExceeded, UnexpectedFrameReceived, OutgoingFrameRejected, FrameDecodingError,
                ClientAuthenticationFailed, ClientConnectionFailed, ClientRequestFailed, ClientNotConnected,
                OperationFailure, RootDirNotFound, FunctionalityNotImplemented,
                AliasLookupError, AliasInUse, ClientClosedError) as rc_error:
            error("Getting all software inventory from RescueConsole failed: {}:{}\n{}".format(
                rc_error.__class__.__name__, rc_error,
                ''.join(format_exception(type(rc_error), rc_error, rc_error.__traceback__))))
            raise ErrorFromRescueConsole(f"Getting software inventory from RescueConsole raised "
                                         f"{rc_error.__class__.__name__}")
        self.logger.debug("SW Inventory from RC: {}".format(sw_inventory))
        RescueConsole.sw_inventory = sw_inventory
        for sw in sw_inventory["slots"]:
            if sw["running"]:
                partition = sw["id"]
        if partition == "3":
            info("Partition is fs3 as expected.")
        elif partition == "":
            error("Partition not found, take contact to script developer.")
            raise UnexpectedPartitionActive
        else:
            error("Partition is fs{} instead of fs3.".format(partition))
            raise UnexpectedPartitionActive
        try:
            active_sw = self.rc.get_running_sw_version_name(connection="rc_connection")
        except (TimeoutExceeded, UnexpectedFrameReceived, OutgoingFrameRejected, FrameDecodingError,
                ClientAuthenticationFailed, ClientConnectionFailed, ClientRequestFailed, ClientNotConnected,
                OperationFailure, RootDirNotFound, FunctionalityNotImplemented,
                AliasLookupError, AliasInUse, ClientClosedError) as rc_error:
            error("Getting running sw version from RescueConsole failed: {}: {}\n{}".format(
                rc_error.__class__.__name__, rc_error,
                ''.join(format_exception(type(rc_error), rc_error, rc_error.__traceback__))))
            raise ErrorFromRescueConsole(f"Getting running sw version from RescueConsole raised "
                                         f"{rc_error.__class__.__name__}")
        if "FDSW" in active_sw:
            info("Rescue console is opened and FD SW is running ({}).".format(active_sw))
            if not self.fd_sw.fdsw_meta_set:
                fd_sw = "FDSW" + active_sw.split("FDSW")[1]
                BuiltIn().set_suite_metadata("FD SW Version", fd_sw, top=True)
        else:
            error("Rescue console is opened but FD SW is NOT running (active SW: {}).".format(active_sw))
            raise WrongSWActive

    def check_alarms_from_rescue_console(self, allowed_alarms=None, expected_alarms=None):
        """
        Check alarms from Rescue Console.
        :param dict allowed_alarms: Allowed alarms in Rescue Console.
        :param dict expected_alarms: Expected alarms in Rescue Console.
        """
        self.bts.wait_time_and_reason(sleep_time="60", wait_reason="before checking alarms from RescueConsole")
        if not allowed_alarms:
            allowed_alarms = []
        else:
            info("As a result of PR717100 faults 4297 and 4405 are added to allowed alarms.")
            allowed_alarms["fa_id"] = 4297
            allowed_alarms["f_id"] = 4405
        try:
            alarms = self.rc.get_alarms(connection="rc_connection")
        except (TimeoutExceeded, UnexpectedFrameReceived, OutgoingFrameRejected, FrameDecodingError,
                ClientAuthenticationFailed, ClientConnectionFailed, ClientRequestFailed, ClientNotConnected,
                OperationFailure, RootDirNotFound, FunctionalityNotImplemented,
                AliasLookupError, AliasInUse, ClientClosedError) as rc_error:
            error("Getting alarms from RescueConsole failed: {}: {}\n{}".format(
                rc_error.__class__.__name__, rc_error,
                ''.join(format_exception(type(rc_error), rc_error, rc_error.__traceback__))))
            raise ErrorFromRescueConsole(f"Getting alarms from RescueConsole raised {rc_error.__class__.__name__}")
        info("RC allowed alarms are: {}".format(allowed_alarms))
        info("RC expected alarms are: {}".format(expected_alarms))
        info("Alarms from RC: {}".format(alarms))
        expected_alarm_found = False
        for alarm in alarms:
            if expected_alarms and all(expected in alarm.values() for expected in expected_alarms.values()):
                info("Expected alarm {} is found from RC, OK".format(expected_alarms))
                expected_alarm_found = True
            elif expected_alarms is None:
                info("There are no expected alarms listed.")
            alarm_name = alarm.get("name", "")
            if not alarm_name:
                self.logger.debug("Possible old software under testing. Text field changed to name in new ones")
                alarm_name = alarm.get("text", "")
            alarm_id = alarm.get("fault_id", "")
            if not alarm_id:
                self.logger.debug("Fault_id field was not found try to get faultId instead")
                alarm_id = alarm.get("faultId", "")
            if not any(j for j in [alarm_id, alarm_name] if
                       expected_alarms and j in expected_alarms.values() or
                       allowed_alarms and j in allowed_alarms.values()):
                error("Unallowed alarms found from RC:\n{}".format(alarm))
                raise UnallowedAlarmFound
        if expected_alarms and not expected_alarm_found:
            error("Expected alarm {} not found from the RC {}, NOK".format(expected_alarms, alarms))
            raise ExpectedAlarmNotFound
        info("Unallowed alarms not found, OK")
        info("Alarm check done.")

    def stop_rc_log_collecting(self, when_called=""):
        """
        Call stop_collecting_logs from Rescue Console.

        :param str when_called: When this method is called.
        """
        try:
            info(f"Stop collecting of technical logs{when_called}.")
            self.rc.stop_collecting_logs(connection="rc_connection")
            info("Stop collecting of technical logs is done.")
        except (TimeoutError, TimeoutExceeded, asyncio.CancelledError, asyncio.TimeoutError, ClientClosedError) as et:
            error("Stopping of collecting technical logs failed: {}: {}\n{}".format(
                et.__class__.__name__, et, ''.join(format_exception(type(et), et, et.__traceback__))))
            if et.__class__.__name__ == "ClientClosedError":
                info("Connection to Rescue Console was closed during stop_collecting_logs. Reconnect RescueConsole.")
                self.connect_to_rc()
            return False
        return True

    def get_logs_from_rescue_console(self, try_time=0, log_timeout=900):
        """
        Get technical logs from the Rescue Console

        :param int try_time: How many times to try to get technical logs.
        :param int log_timeout: Timeout for downloading technical logs. Default is 900s (15 minutes)
        """
        info("Get technical logs from the Rescue Console")
        log_success = True
        before = datetime.datetime.now()
        try:
            log_name = "rc_technical_logs.zip" if try_time == 0 else "rc_technical_logs_retry.zip"
            self.rc.download_technical_logs(self.logger.log_dir, timeout=log_timeout, connection="rc_connection",
                                            log_filename=log_name)
            after = datetime.datetime.now()
            delta = after - before
            info(f"Time to download technical logs took {delta.total_seconds()} seconds.")
        except (TimeoutError, TimeoutExceeded, asyncio.CancelledError, asyncio.TimeoutError) as et:
            info(f"There were {et.__class__.__name__} exception when trying to collect technical logs.")
            after = datetime.datetime.now()
            delta = after - before
            info(f"Time used to downloading technical logs before the exception was {delta.total_seconds()} seconds.")
            log_success = False
            if try_time == 0:
                warning(f"Timeout error when collecting technical logs:\n"
                        f"{''.join(format_exception(type(et), et, et.__traceback__))}")
                self.stop_rc_log_collecting(when_called=" after timeout error")
                self.bts.wait_time_and_reason(sleep_time="30", wait_reason="before retrying to download logs")
                try_time += 1
                self.get_logs_from_rescue_console(try_time=try_time)
            else:
                error("Timeout error when Downloading technical logs from RescueConsole: {}: {}\n{}".format(
                    et.__class__.__name__, et, ''.join(format_exception(type(et), et, et.__traceback__))))
                self.stop_rc_log_collecting(when_called=" after timeout error from log collection retry")
        except (ConnectionClosedByTransport, ConnectionClosedByPingLoss, MessageCacheClosedError,
                ConnectionClosedError, ClientClosedError, ClientNotConnected, ClientConnectionFailed) as e:
            info(f"There were {e.__class__.__name__} exception when trying to collect technical logs.")
            after = datetime.datetime.now()
            delta = after - before
            info(f"Time used to downloading technical logs before the exception was {delta.total_seconds()} seconds.")
            error(f"Connection to Rescue Console was closed during download_technical_logs. Error: "
                  f"{e.__class__.__name__}: {e} was raised. Try to reconnect to Rescue Console and try "
                  f"to download_technical_logs again.\nNOTE this will set KW_SUCCESS False and fail the test even "
                  f"thought if the reconnection is successful, so we will have logs to investigate.\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            log_success = False
            self.stop_rc_log_collecting(when_called=" after connection error")
            if try_time == 0:
                self.connect_to_rc()
                try_time += 1
                self.get_logs_from_rescue_console(try_time=try_time)
            else:
                self.stop_rc_log_collecting(when_called=" after connection error from log collection retry")
        except (UnexpectedFrameReceived, OutgoingFrameRejected, FrameDecodingError,
                ClientAuthenticationFailed, ClientRequestFailed, OperationFailure, RootDirNotFound,
                FunctionalityNotImplemented, AliasLookupError, AliasInUse) as rc_error:
            error("Downloading technical logs from RescueConsole failed: {}: {}\n{}".format(
                rc_error.__class__.__name__, rc_error,
                ''.join(format_exception(type(rc_error), rc_error, rc_error.__traceback__))))
            log_success = False
            self.stop_rc_log_collecting(when_called=" after unexpected error")
        if not log_success:
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise ErrorFromRescueConsole(f"Downloading technical logs from RescueConsole was not totally successful.")
        info("Technical logs collected to {}".format(self.logger.log_dir))

    def check_sw_inventory_content(self, sw):
        """
        Verifies that there is no changes in SW inventory keys.
        """
        self.logger.debug("SW inventory: {}".format(sw))
        if "mode" not in sw:
            error("Content of SW inventory has changed, no mode key.")
            raise EnvironmentIssue
        if "version" not in sw:
            error("Content of SW inventory has changed, no version key.")
            raise EnvironmentIssue

    def activate_previous_sw(self):
        """
        This method performs software rollback with Rescue Console
        """
        info("Get SW partition of SW to which rollback is made. Target SW is {}.".format(
            self.bts.active_sw))
        sw_inventory = RescueConsole.sw_inventory
        # self.rc.get_all_software_inventory(timeout=60, connection="rc_connection")
        self.logger.debug("SW Inventory from RC: {}".format(sw_inventory))
        if not sw_inventory:
            info("Method get_all_software_inventory of taf.fdsw.rc didn't return anything. Re-try.")
            try:
                sw_inventory = self.rc.get_all_software_inventory(timeout=60, connection="rc_connection")
            except (TimeoutExceeded, UnexpectedFrameReceived, OutgoingFrameRejected, FrameDecodingError,
                    ClientAuthenticationFailed, ClientConnectionFailed, ClientRequestFailed, ClientNotConnected,
                    OperationFailure, RootDirNotFound, FunctionalityNotImplemented,
                    AliasLookupError, AliasInUse, ClientClosedError) as rc_error:
                error("Getting all software inventory from RescueConsole failed: {}: {}\n{}".format(
                    rc_error.__class__.__name__, rc_error,
                    ''.join(format_exception(type(rc_error), rc_error, rc_error.__traceback__))))
                raise ErrorFromRescueConsole(f"Getting software inventory from RescueConsole raised "
                                             f"{rc_error.__class__.__name__}")
        if sw_inventory:
            for sw in sw_inventory["slots"]:
                self.check_sw_inventory_content(sw)
                if sw["version"]:
                    info("Found SW version: {}".format(sw["version"]))
                if self.bts.active_sw in sw["version"] and sw["mode"] == "Active":
                    partition = sw["id"]
                    if partition:
                        info("Target partition found: fs{}\nPerform rollback to the partition and wait "
                             "for WebEM connection.".format(partition))
                        try:
                            self.rc.software_rollback(partition, timeout=300, connection="rc_connection")
                        except (TimeoutExceeded, UnexpectedFrameReceived, OutgoingFrameRejected, FrameDecodingError,
                                ClientAuthenticationFailed, ClientConnectionFailed, ClientRequestFailed,
                                ClientNotConnected, OperationFailure, RootDirNotFound, FunctionalityNotImplemented,
                                AliasLookupError, AliasInUse, ClientClosedError) as rc_error:
                            error("Software rollback failed: {}: {}\n{}".format(
                                rc_error.__class__.__name__, rc_error,
                                ''.join(format_exception(type(rc_error), rc_error, rc_error.__traceback__))))
                            raise ErrorFromRescueConsole(f"Software rollback raised {rc_error.__class__.__name__}")
                        info("Software rollback request done.")
                        break  # break out from sw inventory loop
                    else:
                        error("Could not find partition, cannot perform rollback.")
                        self.teardown_rc_connection()
                        raise ParsingIssue
        else:
            error("Unable to get information from RescueConsole with method: get_all_software_inventory")
            raise EnvironmentIssue

    def teardown_rc_connection(self):
        """
        Teardown the RC connection. NOTE that doesn't fail the test even if there are problems with teardown.
        """
        try:
            # Run Keyword And Continue On Failure     RC.Teardown  connection=rc_connection
            self.logger.debug("Teardown RescueConsole connection.")
            self.rc.teardown(connection="rc_connection")
        # raise RuntimeError('Event loop is closed')
        except (RuntimeError, RuntimeWarning, AliasLookupError, AliasInUse, TimeoutExceeded, UnexpectedFrameReceived,
                OutgoingFrameRejected, FrameDecodingError, ClientAuthenticationFailed, ClientConnectionFailed,
                ClientRequestFailed, ClientNotConnected, OperationFailure, RootDirNotFound,
                FunctionalityNotImplemented, ClientClosedError) as e:
            self.logger.debug("Rescue Console teardown failed: {}: {}\n{}".format(e.__class__.__name__, e, ''.join(
                format_exception(type(e), e, e.__traceback__))))
        finally:
            print("Teardown of RescueConsole is done.")

    @staticmethod
    def check_filepath(path_to_sw_build):
        """
        Check that path to sw build is valid.

        :param str path_to_sw_build: Path to sw build.
        """
        if not path_to_sw_build:
            error("Path to sw build is not given, cannot perform sw upload and activation without path to sw build.")
            raise FilePathIssue
        elif '.zip' not in path_to_sw_build:
            error("Sw build in path is invalid, no zip in the sw build name found.")
            raise FilePathIssue
        elif not os.path.exists(path_to_sw_build):
            error("Sw build path doesn't exists.")
            raise FilePathIssue

    def _get_partition(self, target_bd_name):
        """
        Print sw inventory to eventlog and get partition of active slot from RescueConsole.

        :param str target_bd_name: Name of the target BD.
        :return: Partition of active slot.
        """
        partition = ""
        sw_inventory = RescueConsole.sw_inventory  # self.rc.get_all_software_inventory(connection="rc_connection")
        info("sw_inventory:  {}".format(sw_inventory))
        for sw in sw_inventory["slots"]:
            self.check_sw_inventory_content(sw)
            if not sw["version"]:
                warning(
                    "Slot {} doesn't have any sw version in RescueConsole. This might be caused by that sw is \n"
                    "corrupted and sw fallback has been made or that there just are some issues in showing sw \n"
                    "builds in RescueConsole. This missing sw build information will not fail the test.".format(
                        sw["id"]))
            if sw["mode"] == "Active":
                info("Slot {} had Active sw {} before failsafe boot.".format(sw["id"], sw["version"]))
                partition = sw["id"]
                if target_bd_name and sw["version"]:
                    swversion = sw["version"]
                    if target_bd_name.split("ENB")[1] == swversion.split("ENB")[1]:
                        info("Build to be downloaded is the same that was active before failsafe boot.")
                break
        if not partition:
            warning("Unable to get partition of active slot from RescueConsole.")
            if self.bts.active_partition:
                partition = self.bts.active_partition[-1]
        elif not partition:
            warning("Active partition was not get in the beginning of test nor from the RescueConsole. "
                    "Using fs1 as a default")
            partition = '1'
        if partition:
            info("Target partition fs{} was Active before fail safe boot, so it is Primary partition\n"
                 "Perform sw upload and activation to the partition and wait for WebEM connection.\n"
                 "Timeout for software upload and activation is set to 30min.".format(partition))
        return int(partition)

    def upload_and_activate_new_sw(self, path_to_sw_build=None, target_bd_name=None, try_time=0):
        """
        This method uploads and activates software to bts after failsafe boot.

        :param str path_to_sw_build: Path to sw build.
        :param str target_bd_name: Name of the target BD.
        :param int try_time: How many times to try to upload and activate SW.
        """
        if not path_to_sw_build:
            if self.bts.path_to_bts_sw_zip:
                path_to_sw_build = self.bts.path_to_bts_sw_zip
            elif self.bts.cloud_env:  # TargetBD is not printed and therefor ute cloud path not yet parsed
                path_to_sw_build = self.bts.get_path_to_bts_sw_zip_in_ute_cloud()
        self.check_filepath(path_to_sw_build)
        info("Upload and activate new SW to BTS.")
        try:
            self.rc.software_update(sw_pkg_path=path_to_sw_build, timeout=1800, activate=True,
                                    connection="rc_connection")
            info("Software update done from RescueConsole. Wait for WebEM connection.")
        except TypeError as e:
            error(f"Software update request of RescueConsole failed because: {e.__class__.__name__} was raised. \n{e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}\nCheck library version and take contact to"
                  f" TAF team.")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            info("Test will fail and logs will be collected")
            if ("missing a required argument: 'sw_slot_id'" in str(e) or
                    "missing 1 required positional argument" in str(e)):
                sw_slot_id = self._get_partition(target_bd_name)
                info("Try to update software by giving the old sw_slot_id to software_update method.")
                self.rc.software_update(sw_slot_id=sw_slot_id, sw_pkg_path=path_to_sw_build, timeout=1800,
                                        activate=True, connection="rc_connection")
        except ClientClosedError as e:
            if try_time == 0:
                error(
                    f"Software update request from RescueConsole failed because: {e.__class__.__name__}: {e} happens.\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                info(r"Try to reconnect to RescueConsole and try again.\nNOTE this will set KW_SUCCESS False and fail"
                     r" the test even thought if the reconnection is successful, so we will have logs to investigate.")
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                self.connect_to_rc()
                try_time += 1
                self.upload_and_activate_new_sw(path_to_sw_build=path_to_sw_build, target_bd_name=target_bd_name,
                                                try_time=try_time)
            else:
                error(
                    f"Software update request from RescueConsole failed because: {e.__class__.__name__}: {e}. We "
                    f"have already tried to reconnect the RescueConsole and try software update again without success."
                    f"\n{''.join(format_exception(type(e), e, e.__traceback__))}")
                raise ErrorFromRescueConsole(f"Software update from RescueConsole raised {e.__class__.__name__}")
        except (TimeoutExceeded, UnexpectedFrameReceived, OutgoingFrameRejected, FrameDecodingError,
                ClientAuthenticationFailed, ClientConnectionFailed, ClientRequestFailed,
                ClientNotConnected, OperationFailure, RootDirNotFound, FunctionalityNotImplemented,
                AliasLookupError, AliasInUse, TypeError) as rc_error:
            error("Software update from RescueConsole failed: {}: {} was raised. \n{}".format(
                rc_error.__class__.__name__, rc_error,
                ''.join(format_exception(type(rc_error), rc_error, rc_error.__traceback__))))
            raise ErrorFromRescueConsole(f"Software update from RescueConsole raised {rc_error.__class__.__name__}")
        finally:  # this should not be needed, added just in case
            self.teardown_rc_connection()

    def get_time_from_fdsw_log(self, output):
        """
        Get time from FDSW log_collection_status.log file.

        :param str output: Output of the command cat /ffs/run/logs/lfs/reset/log_collection_status.log
        :return: Time from the log as datetime object.
        """
        time_str = ""
        if not output:
            error("Output of SSH command: cat /ffs/run/logs/lfs/reset/log_collection_status.log is empty. NOK.")
            raise ExpectedLogsNotFound("No output got with command: cat /ffs/run/logs/lfs/reset/log_collection_status."
                                       "log.")
        try:
            info("Content of file log_collection_status.log: {}".format(output))
            output = output.replace("\r", "")
            output = output.split("\n")
            self.logger.debug("List in get_time_from_fdsw_log: {}".format(output))
            for line in output:
                if "Collection of FCT log succeed! Log stored to: /ffs/" in line:
                    time_str = line.split(" Collection of FCT log succeed!")[0]
                    break
            if not time_str:
                error("Could not parse time from log /ffs/run/logs/lfs/reset/log_collection_status.log "
                      "(content of the log {output}).")
                raise ParsingIssue
            self.logger.debug("Create datetime object from string '{}'.".format(time_str))
            datetime_object = datetime.datetime.strptime(time_str, '%Y-%m-%d %H:%M:%S')
            return datetime_object
        except (ValueError, AttributeError) as e:
            error("Exception happens when checking time stamps from FDSW logs: {}: {}. "
                  "Will not fail the test\n{}".format(e.__class__.__name__, e,
                                                      ''.join(format_exception(type(e), e, e.__traceback__))))
        return None

    @staticmethod
    def check_timestamp_of_log(time_of_file):
        """
        This method checks that timestamp of file /ffs/run/logs/lfs/reset/log_collection_status.log is about same as
        time when service button was pressed.

        :param time_of_file: Time of file that is to compared to the timestamp.
        """
        # m_time = os.path.getmtime(file_to_check)
        # modification_time = datetime.datetime.fromtimestamp(m_time)

        modification_time = time_of_file  # this is done
        difference = 9999
        # info("Modification time of the file is: {} and Service Button was pressed: {}".format(
        #     modification_time, RescueConsole.press_button_time))
        info("Time when collection of FCT log succeed is: {} and Service Button was pressed: {}".format(
            modification_time, RescueConsole.press_button_time))
        if modification_time.time() < RescueConsole.press_button_time.time():
            difference = RescueConsole.press_button_time - modification_time
            difference = int(difference.total_seconds())
        elif RescueConsole.press_button_time.time() < modification_time.time():
            difference = modification_time - RescueConsole.press_button_time
            difference = int(difference.total_seconds())
        elif RescueConsole.press_button_time.time() == modification_time.time():
            difference = 0
        if difference < 300:
            info("File log_collection_status.log is created during this test run, OK")
        else:
            error("Difference between pressing the button and creating the file is more than 300s -> "
                  "file may be from previous tests. NOK.")
            raise ExpectedLogsNotFound("FDSW FCT logs not collected (CNI-93761)")

    def check_if_log_collection_status_exists(self):
        """
        This method to verify CNI-93761. More information in you can find from:
        https://jiradc.ext.net.nokia.com/browse/FCA_TATSCRIPTS-181864
        """
        dgb_print = self.ssh.connection_command_and_output(
            r"ls /ffs/run/logs/lfs/ && ls /ffs/run/logs/lfs/reset/", alias="DBG")
        info("Found lfs logs (for debug): {}".format(dgb_print))
        log_collection_output = self.ssh.connection_command_and_output(
            "cat /ffs/run/logs/lfs/reset/log_collection_status.log", alias="FDSW_LOGS")
        if "No such file" in log_collection_output:
            error("File /ffs/run/logs/lfs/reset/log_collection_status.log doesn't exits")
            raise ExpectedLogsNotFound("FDSW FCT logs not collected (CNI-93761)")
        time_object = self.get_time_from_fdsw_log(log_collection_output)
        self.check_timestamp_of_log(time_object)  # "/ffs/run/logs/lfs/reset/log_collection_status.log")
        if "Collection of FCT log succeed! Log stored to: /ffs/run/logs/lfs/reset" in log_collection_output:
            info("Text 'Collection of FCT log succeed! Log stored to: /ffs/run/logs/lfs/reset' was found "
                 "from log_collection_status.log, OK.")

    def check_if_rescue_console_logs_variable_is_set(self, set_the_variable_to_true=False):
        """
        Check if RESCUE_CONSOLE_LOGS variable is set from test suite, commandline or by environment reservation TAG.
        If there aren't any value in RESCUE_CONSOLE_LOGS and set_the_variable_to_true is True set the variable to True,
        otherwise set the variable to False.

        :param bool set_the_variable_to_true: Default is False. If True sets the RESCUE_CONSOLE_LOGS variable to True.
        :return bool: True/False, value of RESCUE_CONSOLE_LOGS variable
        """
        suite_variables = BuiltIn().get_variables()
        if "${RESCUE_CONSOLE_LOGS}" in suite_variables:
            rc_logs = BuiltIn().get_variable_value("${RESCUE_CONSOLE_LOGS}")
            if rc_logs is None:
                self.logger.debug("RESCUE_CONSOLE_LOGS suite variable was set to None. Set it to False.")
                BuiltIn().set_suite_variable("${RESCUE_CONSOLE_LOGS}", "${False}")
            if isinstance(rc_logs, str):
                if not rc_logs:
                    self.logger.debug("RESCUE_CONSOLE_LOGS suite variable was set to empty string.. Set it to False.")
                    BuiltIn().set_suite_variable("${RESCUE_CONSOLE_LOGS}", "${False}")
                elif rc_logs.lower() == "true":
                    info("RESCUE_CONSOLE_LOGS suite variable is set to True.")
                    BuiltIn().set_suite_variable("${RESCUE_CONSOLE_LOGS}", "${True}")
                elif rc_logs.lower() == "false":
                    info("RESCUE_CONSOLE_LOGS suite variable is set to False.")
                    BuiltIn().set_suite_variable("${RESCUE_CONSOLE_LOGS}", "${False}")
                else:
                    error(f"Value for RESCUE_CONSOLE_LOGS suite variable is not true, True, false or False. Value is "
                          f"{rc_logs}. Logs are not collected.")
                    BuiltIn().set_suite_variable("${RESCUE_CONSOLE_LOGS}", "${False}")
        else:
            self.logger.debug("RESCUE_CONSOLE_LOGS suite variable was not set by test suite/commandline/tag.")
            if set_the_variable_to_true:
                BuiltIn().set_suite_variable("${RESCUE_CONSOLE_LOGS}", "${True}")
                info("Variable RESCUE_CONSOLE_LOGS is set to True.")
            else:
                BuiltIn().set_suite_variable("${RESCUE_CONSOLE_LOGS}", "${False}")
                self.logger.debug("Variable RESCUE_CONSOLE_LOGS is set to False.")
        return BuiltIn().get_variable_value("${RESCUE_CONSOLE_LOGS}")
