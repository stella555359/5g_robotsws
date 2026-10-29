import os
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCheckMeasurements import PmCheckMeasurements
from testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCommonLib import PmCommonLib
from testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCommissioning import PmCommissioning
from testsuite.Oulu.TrunkEng.PM.Python.Resources.exceptions import PMFileCheckFailed, GcsTimeException
from testsuite.Oulu.TrunkEng.PM.Python.Resources.PmSfp import PmSfp
from testsuite.Oulu.TrunkEng.PM.Python.Resources.IntervalChange import IntervalChange
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info


class PMCommonInterface(object):

    _all_downloaded_files = []

    def __init__(self):
        self.check_measurements = None
        self.pm_lib = PmCommonLib()
        self.pm_commissioning = PmCommissioning()
        self.logger = BuiltIn().get_library_instance("LOG")
        self.pm_sfp = PmSfp()
        self.interval_change = IntervalChange(self.pm_lib)
        self.bts = BuiltIn().get_library_instance("BTS")

    @property
    def all_downloaded_files(self):
        return PMCommonInterface._all_downloaded_files

    def commission_ntp_ip(self, ip):
        """
        Commission NTP ip

        param str ip:  IP address for NTP
        """
        self.pm_commissioning.commission_ntp_ip(ip)
        self.pm_commissioning.wait_after_commissioning()

    def init_pm_file_check(self, baseline_file, ignored_meas, ignored_counters):
        """
        Initializes PM file check class

        :param str baseline_file: Path to baseline file
        :param str ignored_meas: Path to ignored measurements file
        :param str ignored_counters: Path to ignored counters file
        """
        info("Used files for PM file checks:")
        info("Baseline: {}".format(baseline_file))
        info("Ignored measurements: {}".format(ignored_meas))
        info("Ignored counters: {}".format(ignored_counters))
        baseline_root = self.pm_lib.parse_file(baseline_file)
        self.check_measurements = PmCheckMeasurements(baseline_root, ignored_meas, ignored_counters)

    def check_pm_file(self, pm_file="", interval=15, upload_interval=15, intermediate=False, incomplete_intervals=None,
                      measurements_disabled=None, upload_period_change=False, counter_values=None,
                      expired_measurements=None, disabled_measurements=None, time=None, m8020_counters=None,
                      ntp_faulty=False):
        """
        PM file check

        :param str pm_file: Path to PM file
        :param int interval: Measurement intervals
        :param int upload_interval: Upload interval for PM file
        :param bool intermediate: True if first intermediate period -case is used
        :param bool incomplete_intervals: True if incomplete intervals are used
        :param bool measurements_disabled: True if measurements are disabled
        :param bool upload_period_change: True if case is upload period 15min to 60min
        :param dict counter_values: Dictionary containing counter values
        :param list expired_measurements: List containing expired measurements
        :param list disabled_measurements: List containing disabled measurements
        :param str time: Time for PM file check
        :param dict m8020_counters: Dictionary containing M8020 counters
        :param ntp_faulty: Used only in NTP case

        :raise PMFileCheckFailed: If PM file check fails
        """
        if not pm_file:
            pm_file = self.pm_lib.download_latest_file(interval=upload_interval)
            PMCommonInterface._all_downloaded_files.append(pm_file)
        pm_root = self.pm_lib.parse_file(pm_file)
        if isinstance(interval, int) or isinstance(interval, str):
            interval = f"{interval}min"
        pm_file_check_success = self.check_measurements.check_pm_file(
            pm_root, interval=interval, upload_period=upload_interval, intermediate=intermediate,
            incomplete_intervals=incomplete_intervals, measurements_disabled=measurements_disabled,
            upload_period_change=upload_period_change, counter_values=counter_values,
            expired_measurements=expired_measurements, disabled_measurements=disabled_measurements, time=time,
            m8020_counters=m8020_counters, ntp_faulty=ntp_faulty)
        pm_file_name_success = self.pm_lib.check_latest_file_name(os.path.basename(pm_file), "PM",
                                                                  interval=upload_interval, bool_return=True)
        self.logger.debug(f"PM file check success: {pm_file_check_success}")
        self.logger.debug(f"PM file name success: {pm_file_name_success}")
        if not pm_file_check_success or not pm_file_name_success:
            raise PMFileCheckFailed

    def set_ignored_measurements_and_counters(self, ignored_meas, ignored_counters):
        """
        Set ignored measurements and counters

        :param str ignored_meas: Path to ignored measurements file
        :param str ignored_counters: Path to ignored counters file
        """
        info(f"Setting ignored measurements to {ignored_meas} and ignored counters to {ignored_counters}")
        self.check_measurements.set_ignored_measurements_and_counters(ignored_meas, ignored_counters)

    def check_latest_file_existence(self, filetype, exist=True):
        """
        Check PM/RD file existence on BTS

        :param str filetype: RD or PM
        :param bool exist: Should file exist or not
        :raise PMFileDoesntExist/PMFileExist: Raises error if file exist/doesn't exist
        """
        self.pm_lib.check_latest_file_existence(filetype, exist)

    def check_ntp_availability(self, status="InSync"):
        """
        Check NTP availability via admin cli

        :param str status:  Operational state (InSync/Unavailable/Unknown/Available)
        :raise StateException: Raises error if operational state is different that wanted
        """
        self.pm_lib.check_ntp_availability(status)

    def wait_for_interval(self, interval=15, next_interval=True, delta=0, wait_after="120s", only_return=False):
        """
        Wait for next/previous interval

        :param int interval: Interval for waiting
        :param bool next_interval: Next or previous interval
        :param int delta: Added time to next interval (in seconds). Can be positive or negative.
        :param bool wait_after: Wait after commissioning (in seconds) E.g. "120s". Default is 120s
        :param bool only_return: True if only return of the interval time is needed
        :return datetime: Next interval time
        """
        return self.pm_lib.wait_for_interval(interval, next_interval, delta, wait_after, only_return)

    def check_sfp_dynamic_data(self):
        """
        Get and check SFP dynamic data from BTS and PM files
        """
        self.pm_sfp.get_and_check_sfp_dynamic_data()

    def calculate_m8020x_counters(self, selected_cell, used_rat="LN", cell_locked=False):
        """
        Calculate M8020X counters via infomodel
        :param str selected_cell: Selected cell  e.g. 1 or All cells
        :param str used_rat: Used RAT: LN/NR. Default is LN
        :param bool cell_locked: True if cell is locked otherwise script assumes cell to be blocked
        :return dict: Dictionary containing cells as keys and counter tuple as values
        """
        return self.pm_lib.calculate_m8020x_counters(selected_cell, used_rat, cell_locked)

    def calculate_m8020x_mme_counters(self, occasion):
        """
        Calculate M8020X counters via infomodel for case MME Connection Outage
        :param str occasion: Occasion time happened in script e.g. 1
        :return dict: Dictionary containing cells as keys and counter tuple as values
        """
        return self.pm_lib.calculate_m8020x_mme_counters(occasion)

    def check_gcs_time(self, selected_cell, rat="LN", limits=(180, 210)):
        """
        Check GCS time. Used after calculate_m8020x_counters

        :param str selected_cell: Selected cell
        :param str rat: Used RAT: LN/NR. Default is LN
        :param tuple limits: Tuple containing lower and upper limits for GCS time. Default is (180, 210)
        """
        for cell_name, cell_info in self.bts.cells.items():
            if rat in cell_name and selected_cell == cell_name[7:] or selected_cell == "All cells":
                cell_dn = cell_info["id"]["internal"]
                gcs_start_time, locked_time = self.pm_lib.get_shutting_down_cell(selected_cell, cell_dn)
                if gcs_start_time and locked_time:
                    gcs_time = round(float((locked_time - gcs_start_time).total_seconds()))
                    if len(limits) == 2 and limits[0] < gcs_time < limits[1]:
                        info(f"Graceful cell shutdown time ({gcs_time}s) for cell-{selected_cell} is within limits")
                    else:
                        raise GcsTimeException(f"Graceful cell shutdown time ({gcs_time} for cell-{selected_cell} is "
                                               f"not within limits: {limits}s")
                else:
                    raise GcsTimeException("GCS time could not be calculated")

    def collect_snapshot(self, file_name="", remove_snapshot=False):
        """
        Collect snapshot from BTS
        :param str file_name: Name of the snapshot file
        :param bool remove_snapshot: True if snapshot should be removed after collection
        :raises SnapshotException: Raises error if snapshot collection fails
        :return str: Path to the snapshot file
        """
        return self.pm_lib.collect_snapshot(file_name, remove_snapshot)

    def check_pm_file_creation_time(self, max_time=60):
        """
        Check PM file creation time
        :param int max_time: Maximum time for PM file creation
        :raises PMFileCheckFailed: Raises error if PM file creation time is too long
        """
        self.pm_lib.check_pm_file_creation_time(max_time)

    def find_nearest_end_time(self):
        """
        Find nearest end time for interval change case
        :return datetime: Nearest end time or repeat times
        """
        return self.interval_change.find_nearest_end_time()

    def find_expiration_times(self, end_time):
        """
        Find expiration times for interval change case
        :return tuple: dict: Full intervals, dict: Expiration times, dict: Incomplete intervals
        """
        return self.interval_change.find_expiration_times(end_time)

    def get_current_expiration_times(self, expiration_times_tuple, interval=60, next_interval=True):
        """
        Get current expiration times for interval change case
        :param tuple expiration_times_tuple: Tuple from find_expiration_times -method
        :param int interval: Interval for expiration time
        :param bool next_interval: True if last interval is needed
        :return list: List containing current expiration times
        """
        return self.interval_change.get_current_expiration_times(expiration_times_tuple, interval, next_interval)

    def find_expired_measurements(self, expiration_times_tuple, meas_config, next_interval=True):
        """
        Find expired measurements for interval change case
        :param tuple expiration_times_tuple: Tuple containing full intervals and expiration times
        :param dict meas_config: Dictionary containing measurement configuration
        :param bool next_interval: True if last interval is needed
        :return list: List containing expired measurements
        """
        return self.interval_change.find_expired_measurements(expiration_times_tuple, meas_config, next_interval)

    def check_cells_and_clear_fault_1907(self, radio_name):
        """
        Check cells and clear fault 1907

        :param str radio_name: Name of the radio, in short form e.g. "r1".
        :raises PMFileCheckFailed: Raises error if affected cells are not reset.
        """
        self.pm_lib.check_cells_and_clear_fault_1907(radio_name)

    def calculate_1907_m8020x_counters(self, selected_cell, used_rat="LN"):
        """
        Calculate M8020X counters in 1907 resource fault test case.

        :param int selected_cell: Selected cell  e.g. 1
        :param str used_rat: Used RAT: LN/NR. Default is LN
        :return dict: Dictionary containing cells as keys and counter tuple as values
        """
        return self.pm_lib.calculate_1907_m8020x_counters(selected_cell, used_rat)

    def add_expected_alarm_based_on_number_of_cells(self, rmod):
        """
        Add expected alarm based on number of cells

        :param str rmod: RMOD name
        """
        self.pm_lib.add_expected_alarm_based_on_number_of_cells(rmod)
