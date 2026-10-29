import pytz
from datetime import datetime, timedelta
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info


class IntervalChange:

    def __init__(self, pm_common_lib):
        self.pm_lib = pm_common_lib
        self.logger = BuiltIn().get_library_instance("LOG")

    def _calculate_repeat_times(self, stop_time, interval=60, local_time=True):
        time = datetime.now(pytz.utc)
        if local_time:
            time = time.astimezone(pytz.timezone('Europe/Helsinki'))
        repeat_times = 0
        info(f"Stop time: {stop_time}")
        info(f"Current time: {time}")
        while time < stop_time:
            time = time + timedelta(minutes=interval)
            repeat_times += 1
        self.logger.debug(f"Repeat times: {repeat_times}")
        return repeat_times - 1

    def find_nearest_end_time(self):
        nearest_complete_6h = self.pm_lib.utc_interval(360, local_time=True) + timedelta(hours=6)
        nearest_24h = self.pm_lib.utc_interval(1440, local_time=True)
        nearest_end_time = max(nearest_complete_6h, nearest_24h)
        info(f"Nearest end time is {nearest_end_time}")
        repeat_times = self._calculate_repeat_times(nearest_end_time, local_time=True)
        return repeat_times, nearest_end_time

    def _intervals_hours(self, interval_int, end_time, expiration_times, full_intervals):
        interval = self.pm_lib.utc_interval(interval_int*60, local_time=True)
        while interval <= end_time:
            expiration_times[f"{interval_int}h"].append(interval)
            interval = interval + timedelta(hours=interval_int)
            if interval <= end_time:
                full_intervals[f"{interval_int}h"].append(interval)

    def _intervals_minutes(self, interval_int, end_time, expiration_times, full_intervals,
                           incomplete_intervals_used=False):
        interval = self.pm_lib.utc_interval(interval_int, local_time=True)
        incomplete_intervals = {0: 30} if incomplete_intervals_used else None
        incomplete_interval = 30
        while interval <= end_time:
            if incomplete_intervals_used:
                incomplete_intervals[interval] = incomplete_interval
                incomplete_interval += 60
            expiration_times[f"{interval_int}min"].append(interval)
            full_intervals[f"{interval_int}min"].append(interval)
            interval = interval + timedelta(minutes=interval_int)
        return incomplete_intervals

    def find_expiration_times(self, end_time):
        full_intervals = {"15min": [], "30min": [], "60min": [], "6h": [], "12h": [], "24h": []}
        expiration_times = {"15min": [], "30min": [], "60min": [], "6h": [], "12h": [], "24h": []}
        self._intervals_minutes(15, end_time, expiration_times, full_intervals)
        self._intervals_minutes(30, end_time, expiration_times, full_intervals)
        incomplete_intervals = self._intervals_minutes(60, end_time, expiration_times, full_intervals,
                                                       incomplete_intervals_used=True)
        self._intervals_hours(6, end_time, expiration_times, full_intervals)
        self._intervals_hours(12, end_time, expiration_times, full_intervals)
        self._intervals_hours(24, end_time, expiration_times, full_intervals)
        self.logger.debug(f"Full intervals: {full_intervals}")
        self.logger.debug(f"Expiration times: {expiration_times}")
        self.logger.debug(f"Incomplete intervals: {incomplete_intervals}")
        return full_intervals, expiration_times, incomplete_intervals

    def _collect_expired_intervals(self, next_interval, expiration_times, incomplete_intervals=None):
        expired_intervals = []
        self.logger.debug(f"incomplete_intervals: {incomplete_intervals}")
        self.logger.debug(f"Next interval: {next_interval}")
        self.logger.debug(f"Expiration times: {expiration_times}")
        for dict_interval, dict_expiration_times in expiration_times.items():
            for expiration_time in dict_expiration_times:
                if expiration_time == next_interval:
                    # First check after interval change should have only 15min full intervals
                    self.logger.debug(f"Next interval: {next_interval}")
                    if (incomplete_intervals and next_interval in incomplete_intervals.keys()
                            and incomplete_intervals[next_interval] == 30):
                        expired_intervals.append("15min")
                        return expired_intervals
                    expired_intervals.append(dict_interval)
                    break
        return expired_intervals

    def get_current_expiration_times(self, expiration_times_tuple, interval=60, next_interval=True):
        interval_time = self.pm_lib.utc_interval(interval, next_interval=next_interval, local_time=True)
        full_intervals, expiration_times, incomplete_intervals = expiration_times_tuple
        expiration_times_list = self._collect_expired_intervals(interval_time, expiration_times)
        self.logger.debug(f"Expiration times list: {expiration_times_list}")
        full_intervals_list = self._collect_expired_intervals(interval_time, full_intervals, incomplete_intervals)
        self.logger.debug(f"Full intervals list: {full_intervals_list}")
        return full_intervals_list, expiration_times_list

    @staticmethod
    def _strip_time_unit(interval):
        if "min" in interval:
            return interval.replace("min", "")
        elif "h" in interval:
            return str(int(interval.strip("h")) * 60)
        else:
            return interval

    def find_expired_measurements(self, expiration_times_tuple, measurement_interval_config, next_interval):
        _, expired_intervals = self.get_current_expiration_times(expiration_times_tuple, next_interval=next_interval)
        expired_intervals = [self._strip_time_unit(interval) for interval in expired_intervals]
        expired_measurements = {}
        disabled_measurements = []
        transform_dict = self.pm_lib.find_baseline_measurement_names()
        for full_name, aomParameterId in transform_dict.items():
            expired_measurements[full_name] = "15"
            for measurement, interval in measurement_interval_config.items():
                if aomParameterId == measurement:
                    self.logger.debug(f"interval: {interval}")
                    if interval in expired_intervals:
                        expired_measurements[full_name] = interval
                    elif interval == "disabled":
                        disabled_measurements.append(full_name)
                        del expired_measurements[full_name]
                    else:
                        del expired_measurements[full_name]
        info(f"Expired measurements for next file: {expired_measurements}")
        info(f"Disabled measurements for next file: {disabled_measurements}")
        return expired_measurements, disabled_measurements
