import re
import subprocess
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ScriptIssue, BTSConnectionFailure)


class HaltTest:

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.collect_logs = None
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        self.admin = BuiltIn().get_library_instance("ADMIN")

    @staticmethod
    def prevent_resets():
        swconfig = BuiltIn().get_library_instance("SWCONFIG")
        if ("${PREVENT_RESETS}" in BuiltIn().get_variables() and
                BuiltIn().get_variable_value("${PREVENT_RESETS}")):
            info("${PREVENT_RESETS} is set to True, set flag to prevent resets before killing robot test.")
            swconfig.add_flags_via_telnet({"0x10077": "1"}, ip="192.168.255.129")

    @staticmethod
    def wait_before_halt():
        if "${WAIT_BEFORE_HALT}" in BuiltIn().get_variables():
            wait_halt = BuiltIn().get_variable_value("${WAIT_BEFORE_HALT}")
            if wait_halt:
                info(f"Wait halt time {wait_halt} before killing getting snapshot and killing robot test.")
                BuiltIn().sleep(wait_halt)

    def _get_snapshot(self, extra_name, step_print):
        try:
            self.collect_logs.collect_special_snapshot(extra_name=extra_name)
            info(step_print)
            return True
        except (TypeError, AttributeError, ScriptIssue, BTSConnectionFailure) as e:
            info(f"Snapshot collection failed. {e.__class__.__name__} {e}\n"
                 f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        return False

    def get_snapshot_reset_get_snapshot(self):
        if "${SNAPSHOT_RESET_SNAPSHOT_HALT}" in BuiltIn().get_variables():
            get_snapshot = BuiltIn().get_variable_value("${SNAPSHOT_RESET_SNAPSHOT_HALT}")
            if get_snapshot and (isinstance(get_snapshot, bool) or (
                    isinstance(get_snapshot, str) and get_snapshot.lower() == "true")):
                info("When halt is found snapshot, after that reset site and take new  before snapshot killing "
                     "robot test. NOTE test is not paused so if BTS will do site reset etc. during snapshot "
                     "collection snapshot may not be possible to get")
                sn_ok = self._get_snapshot("halt", "Snapshot collected after halt noticed")
                if not sn_ok:
                    info("Snapshot could not be collected after halt was found. Because of this we will not do site "
                         "reset so testing personnel can do it manually and collect manually another snapshot.")
                    return
                info("Do HALT site reset")
                self._site_reset(timeout=300, wait_for_reconnection=True)
                self._get_snapshot("after_reset", "Snapshot collected after reset")
            else:
                info("Snapshot-reset-snapshot will NOT be done before killing robot test. Value of "
                     "SNAPSHOT_RESET_SNAPSHOT_HALT is not true or True or boolean True")

    # def _ping_bts(self, time_to_wait, ip="192.168.255.129", disconnect=False):
    #     try:
    #         command = f"ping -c 1 {ip}"
    #         print_found = 0
    #         expected_strings = ['1 packets transmitted, 1 received,', ', 0% packet loss']
    #         if disconnect:
    #             expected_strings = ['1 packets transmitted, 0 received,', '100% packet loss',
    #                                 'Destination Host Unreachable']
    #         if not os.path.exists(self.logger.log_dir):
    #             save_path = self.logger.suite_folder
    #             info(f"Folder {self.logger.log_dir} doesn't exists anymore, use suite folder path to save the ping "
    #                  f"file: {save_path}")
    #         start_time = datetime.datetime.now()
    #         while (datetime.datetime.now() - start_time).total_seconds() < int(time_to_wait):
    #             handle = os.popen(command)
    #             output = ''.join(handle.readlines())
    #             handle.close()
    #             if output and any(expected for expected in expected_strings if expected in output):
    #                 print_found += 1
    #             if not output:
    #                 info("No output gotten when pinging {} Time: {}.".format(
    #                     ip, datetime.datetime.now().strftime("%Y%m%d_%H%M%S")))
    #             if print_found == 3:
    #                 info(f"Disconnection of {ip} is noticed" if disconnect else f"Reconnection of {ip} is noticed" )
    #                 return print_found
    #             BuiltIn().sleep("1s")
    #         return print_found
    #     except (OSError, AttributeError, TypeError) as e:
    #         info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def _site_reset(self, timeout=300, wait_for_reconnection=True):
        """
        Perform site reset methods does site reset

        :param int timeout: Timeout for site reset. Default is 300 seconds.
        :param bool wait_for_reconnection: If True, wait for reconnection after site reset. Default is True.
        """
        try:
            result = self.admin.reset_site(timeout=timeout, wait_for_reconnection=wait_for_reconnection,
                                           detailed_output=True)
            print(f"Admin response for reset_site: {result}")
            return True
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            info(f"Problems when resetting site. {admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
        return False

    def get_extra_halt_snapshot(self):
        if "${GET_SNAPSHOT_HALT}" in BuiltIn().get_variables():
            get_snapshot = BuiltIn().get_variable_value("${GET_SNAPSHOT_HALT}")
            if get_snapshot and (isinstance(get_snapshot, bool) or (
                    isinstance(get_snapshot, str) and get_snapshot.lower() == "true")):
                try:
                    info("Get HALT snapshot before killing robot test. NOTE test is not paused so if BTS will "
                         "do site reset etc. during snapshot collection snapshot may not be possible to get")
                    # os.kill(self.collect_logs.main_pid, 19)  # pause the test cannot be done, pauses all
                    self.collect_logs.collect_special_snapshot(extra_name="halt")
                    info("HALT_TEST Snapshot collected.")
                except (TypeError, AttributeError, ScriptIssue, BTSConnectionFailure) as e:
                    info(f"Snapshot collection failed. {e.__class__.__name__} {e}\n"
                         f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            else:
                info("Snapshot will NOT be collected before killing robot test. Value of GET_SNAPSHOT_HALT is "
                     f"not true or True or boolean True (it is {get_snapshot}: {type(get_snapshot)}).")

    def kill_robot_process(self):
        info(f"Killing robot...")
        robot_pattern = re.compile(
            r".*ute\s+(?P<pid>\d+)\s+.*/home/ute/.pyenv/versions/test_repo/bin/python /"
            r"home/ute/.pyenv/versions.*test_repo/bin/robot.*")
        output = subprocess.check_output(r"ps auxf -w -w | grep robot", shell=True)
        self.logger.debug(f"All robot processes: \n{output}")
        output = output.decode("utf-8").split("\n")
        for op in output:
            kill_match = robot_pattern.match(op)
            if kill_match:
                info(f"Robot test run PID found, {kill_match.group('pid')} kill the robot test run.")
                subprocess.check_output(f"kill -15 {kill_match.group('pid')}", shell=True)
        if self.collect_logs.main_pid and self.collect_logs.main_pid > 0:
            info(f"Main PID found, test is still not terminated {self.collect_logs.main_pid} kill the main PID "
                 f"with SIGKILL.")
            subprocess.check_output(f"kill -9 {self.collect_logs.main_pid}", shell=True)

    def halt_test(self):
        self.prevent_resets()
        self.wait_before_halt()
        self.get_snapshot_reset_get_snapshot()
        self.get_extra_halt_snapshot()
        self.kill_robot_process()
        info("HALT_TEST: Robot test killed.")
