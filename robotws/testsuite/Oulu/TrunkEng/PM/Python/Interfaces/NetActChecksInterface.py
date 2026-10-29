import time
import pytz
from datetime import datetime, timedelta
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.PM.Python.Resources.NetActChecks import NetActChecks
from testsuite.Oulu.TrunkEng.PM.Python.Resources.exceptions import Ne3sInterfaceException
from testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCommonLib import PmCommonLib
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error


class NetActChecksInterface:

    def __init__(self):
        self.netact_checks = NetActChecks()
        self.syslog_search = BuiltIn().get_library_instance("SYSLOGSEARCH")
        self.pmlib = PmCommonLib()

    def check_ne3s_if_establishment(self):
        """
        Checks that the NE3S interface is established correctly.

        :raise Ne3sInterfaceException: If NE3S interface is not established correctly
        """
        info("Checking NE3S interface establishment")
        syslog_regex = (
            r".*INF\/Ne3sAdapter\/Manager,\s+\[nmsservicefacade::Ne3sadaptContextUpdater\]\s+"
            r"update\s+Ne3sSession\s+to\s+OperationalState.*\):\s+\d+\s+proceduralState.*"
        )
        ne3s_messages = self.syslog_search.get_prints_from_syslogs(syslog_regex, print_eventlog=True, time_stamp=None)
        if not ne3s_messages:
            raise Ne3sInterfaceException("NE3S messages are missing. Check error messages")
        only_messages = [message for value in ne3s_messages.values() for messages in value.values() for message in
                         messages]
        success = self.netact_checks.check_amount_of_ne3s_messages(only_messages)
        success = self.netact_checks.check_correct_ne3s_procedure(only_messages) and success
        if not success:
            error("NE3S interface is not established correctly. Check error messages")
            raise Ne3sInterfaceException("NE3S interface is not established correctly. Check error messages")
        info("NE3S interface is established correctly")

    def check_pm_file_name_from_netact(self, latest_files=None, interval=15, start_time=None, add_time=None):
        """
        Checks that PM files are found from NetAct via syslog

        :param list latest_files: List of latest PM files (Can be derived via PMCommonInterface.all_downloaded_files).
                                  If not set, latest PM file is used.
        :param int interval: Measurement intervals
        :param datetime start_time: Start time for syslog search
        :param str/int add_time: Additional time for start_time in minutes
        :raise Ne3sInterfaceException: If PM file is not found from NetAct via syslog
        """
        info("Checking that PM files are found from NetAct via syslog")
        if not latest_files:
            latest_files = [self.pmlib.latest_file("PM", interval)]
        file_transfer_notification = (r".*INF\/Ne3sAdapter\/Pm,\s+\[manager::pm::PmHandler\]\s+\[PM\]Send\s+"
                                      r"notification\s+with\s+path:\s+\/rom\/uri\/PERFMON_FILES\/PM\.BTS-\d+.\d+.\d+\."
                                      r"ANY\.xml\.gz\s+to\s+COMA\s+successfully.*")
        file_transfer_result = (r".*INF\/Ne3sAdapter\/Pm,\s+\[manager::pm::PmHandler\]\s+\[PM\]Notification\s+of\s+"
                                r"pm\s+with\s+relative\s+path:\s+\/PERFMON_FILES/*PM\.BTS-\d+.\d+.\d+\.ANY\.xml\.gz\s+"
                                r"transfer\s+success.*")
        if add_time:
            start_time = start_time + timedelta(minutes=int(add_time))
        info(f"Finding prints after this point: {start_time}")
        notifications = self.syslog_search.get_prints_from_syslogs(file_transfer_notification, print_eventlog=True,
                                                                   time_stamp=start_time)
        results = self.syslog_search.get_prints_from_syslogs(file_transfer_result, print_eventlog=True,
                                                             time_stamp=start_time)
        if not notifications:
            error(f"NE3S file transfer notifications are missing from syslog for {latest_files}")
        if not results:
            error(f"NE3S file transfer results are missing from syslog for {latest_files}")
        if not notifications or not results:
            raise Ne3sInterfaceException("NE3S file transfer notifications or results are missing from syslog")
        notification_messages = [line for inner_dict in notifications.values() for line_list in inner_dict.values() for
                                 line in line_list]
        notification_pm_files = self.netact_checks.parse_ne3s_file_transfer_notification(notification_messages)
        results_messages = [line for inner_dict in results.values() for line_list in inner_dict.values() for
                            line in line_list]
        result_pm_files = self.netact_checks.parse_ne3s_file_transfer_result(results_messages, notification_pm_files)
        found_several_times = [(filename, result_pm_files.count(filename)) for index, filename in enumerate(
            result_pm_files) if result_pm_files.count(filename) > 1 and result_pm_files.index(filename) == index]
        if found_several_times:
            error(f"PM file(s) {found_several_times} found several times from NE3S interface from syslog")
            raise Ne3sInterfaceException(f"PM file(s) {found_several_times} found several times from NE3S interface"
                                         f" from syslog")
        if not self.netact_checks.check_pm_file_list(latest_files, result_pm_files):
            error("PM file names are not found from NetAct via syslog")
            raise Ne3sInterfaceException("PM file names are not found from NetAct via syslog")

    def verify_no_pm_files_in_syslog_from_netact(self, latest_files=None, interval=15):
        """
        Checks that PM files are not found from NetAct via syslog

        :param list latest_files: List of latest PM files (Can be derived via PMCommonInterface.all_downloaded_files).
                                  If not set, latest PM file is used.
        :param int interval: Measurement intervals
        :raise Ne3sInterfaceException: If PM file is found from NetAct via syslog
        """
        info("Checking that PM files are not found from NetAct via syslog")
        if not latest_files:
            latest_files = [self.pmlib.latest_file("PM", interval)]
        file_transfer_notification = (r".*INF\/Ne3sAdapter\/Pm,\s+\[manager::pm::PmHandler\]\s+\[PM\]Send\s+"
                                      r"notification\s+with\s+path:\s+\/rom\/uri\/PERFMON_FILES\/PM\.BTS-\d+.\d+.\d+\."
                                      r"ANY\.xml\.gz\s+to\s+COMA\s+successfully.*")
        file_transfer_result = (r".*INF\/Ne3sAdapter\/Pm,\s+\[manager::pm::PmHandler\]\s+\[PM\]Notification\s+of\s+"
                                r"pm\s+with\s+relative\s+path:\s+\/PERFMON_FILES/*PM\.BTS-\d+.\d+.\d+\.ANY\.xml\.gz\s+"
                                r"transfer\s+success.*")
        # Check from last interval. 2min after interval because previous PM file is still seen.
        previous_interval_start_time = self.pmlib.utc_interval(interval, next_interval=False, local_time=True)
        previous_interval_start_time = previous_interval_start_time.astimezone(pytz.UTC) - timedelta(
            minutes=interval) + timedelta(minutes=2)
        info(f"Finding prints after this point: {previous_interval_start_time}")
        notifications = self.syslog_search.get_prints_from_syslogs(file_transfer_notification, print_eventlog=True,
                                                                   time_stamp=previous_interval_start_time)
        results = self.syslog_search.get_prints_from_syslogs(file_transfer_result, print_eventlog=True,
                                                             time_stamp=previous_interval_start_time)
        if not notifications:
            info(f"NE3S file transfer notifications are missing from syslog for {latest_files}")
        if not results:
            info(f"NE3S file transfer results are missing from syslog for {latest_files}")
        if not notifications or not results:
            info("NE3S file transfer notifications or results are missing from syslog, OK")
        else:
            error(f"NE3S file transfer notifications or results are found from syslog, NOK")
            raise Ne3sInterfaceException("NE3S file transfer notifications or results are found from syslog, NOK")
