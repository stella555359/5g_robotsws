# -*- coding: utf-8 -*-
"""
Generic keywords for BTS.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""

import logging
import re
import time
from datetime import timedelta
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.generic_bts import GenericBts, login_logout
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    exceptions import InvalidIntervalsOrValuesCounter
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.utilities\
    import load_moler_configuration_from_tl
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
from datetime import datetime


class GenericCounter(GenericBts):
    """Counter keywords for eNB and gNB"""

    def __init__(self, bts_type):
        super(GenericCounter, self).__init__(bts_type=bts_type)

    @login_logout
    def get_pm_interval(self, dist_name, abbr_group_name, bts_id=0,
                        du_id=0):
        """
        Get the current parameter value for abbr
        :param dist_name: Destination name
        :param abbr_group_name: Abbreviation
        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        :return: value for abbr
        """
        dist_name = dist_name.format(self.get_bts_instance_id(bts_id, du_id))
        parameters = self._get_object_parameters_dict(dist_name=dist_name,
                                                      bts_id=bts_id,
                                                      du_id=du_id)
        logging.debug(parameters)
        pm_interval = parameters[abbr_group_name]
        return pm_interval

    @login_logout
    def set_pm_interval(self, dist_name, abbr_group_name, interval,
                        bts_id=0, du_id=0):
        """
        Set PM interval
        :param dist_name: Destination name
        :param abbr_group_name: Abbreviation
        :param interval: Interval for PM counters
        :param bts_id: ID for BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: None
        """
        dist_name = dist_name.format(self.get_bts_instance_id(bts_id, du_id))
        self.admin.perform_parameter_recommissioning(
            dist_name=dist_name, parameter=abbr_group_name,
            operation='update', value=interval, should_activate=True,
            connection=self.rest_alias.format(bts_id, du_id),
            skip_parameter_relation_errors=True)

    def wait_for_pm_measurements(self, interval, measurements,
                                 measurements_refresh_time=120):
        """
        Wait for several intervals PM counters
        :param interval: Interval for PM counters
        :param measurements: Numbers of intervals, to wait one more
        intervals then specified
        :param measurements_refresh_time: Measurement refresh time
        :return: None
        """
        interval_minutes_value = self.__parse_minute(interval)
        interval_seconds_value = interval_minutes_value * 60
        self.wait_for_next_pm_period()
        for measurement in range(int(measurements) + 2):
            logging.debug('Waiting for PM interval of {} min to '
                          'pass'.format(interval_minutes_value))
            time.sleep(interval_seconds_value)
        logging.debug('Waiting for refreshing the measurements')
        time.sleep(measurements_refresh_time)

    def validate_intervals_and_value_counter_ecpri_group(self,
                                                         interval,
                                                         measurements,
                                                         bts_id=0,
                                                         du_id=0):
        """
        Validate intervals and value counters for eCPRI
        :param interval: Interval for PM counters
        :param measurements: Numbers of intervals
        :param bts_id: ID for BTS
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :return: None
        """
        counters_ecpri = {
            'M40102C0': 16,
            'M40102C1': 8,
            'M40102C2': 16,
            'M40102C3': 16,
            'M40102C4': 1,
        }
        value_minute = self.__parse_minute(interval)
        value_second = value_minute * 60
        error_counters = {}
        for counter_id in counters_ecpri:
            error_id = self.__verify_counter(counter_id,
                                             counters_ecpri[counter_id],
                                             value_second,
                                             measurements,
                                             bts_id, du_id)
            if len(error_id) != 0:
                error_counters[counter_id] = error_id

        if len(error_counters) != 0:
            raise InvalidIntervalsOrValuesCounter(
                'Errors: {}'.format(error_counters))

    def __verify_counter(
            self, counter_ids, value_per_second, value_second,
            measurements, bts_id=0, du_id=0):
        """
        Verify intervals and value counter
        :param counter_ids: Counter ID M...
        :param value_per_second: Expected value per second
        :param value_second: Duration of interval
        :param measurements: Numbers of intervals
        :param bts_id: ID for BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :return: Error messages
        """
        error_msg = []
        measurements = int(measurements)
        data_counter = self.get_counter(counter_ids, bts_id, du_id)
        for tnl in data_counter['TRS']:
            ethlk_objects = data_counter['TRS'][tnl]['ETHLK']
            secondary_link = False
            for ethlk in ethlk_objects:
                raw_time_value = \
                    data_counter['TRS'][tnl]['ETHLK'][ethlk]['SBTS_NCPRI']
                [counter_ids]
                list_time = sorted(raw_time_value)
                for measurement in range(1, measurements + 1):
                    key_value = list_time[-measurements - 1]
                    value = raw_time_value[key_value]
                    interval_result = int(list_time[-measurement]) - int(
                        list_time[-measurement - 1])
                    target_value = value_per_second * value_second
                    if interval_result != value_second:
                        error_msg.append(
                            'Bad interval counter {}, expected: {}, '
                            'value: {} for ETHLK: {}'.
                            format(counter_ids, value_second,
                                   interval_result, ethlk))
                    elif not target_value - 10 <= value <= target_value + 10:
                        if value == 0 and (
                                counter_ids == 'M40102C2' or
                                counter_ids == 'M40102C3') \
                                and secondary_link is False:
                            secondary_link = True
                            break
                        error_msg.append(
                            'Bad value counter {}, expected:'
                            ' {}, value {} for ETHLK {}'.
                            format(counter_ids,
                                   value_per_second * value_second, value,
                                   ethlk))
        return error_msg

    @login_logout
    def get_counter(self, counter_ids, bts_id=0, du_id=0):
        """
        Get dict with data counter
        :param counter_ids: Counter ID, M..
        :param bts_id: ID for BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: Data for counter
        """
        bts_id = int(bts_id)
        counter = self.admin.get_pm_counters(
            couter_ids=counter_ids, timeout=120,
            connection=self.rest_alias.format(bts_id, du_id))
        return counter

    @staticmethod
    def __parse_minute(interval):
        result = re.search(r'^(?P<INTERVAL>\d+)', str(interval))
        value_minute = int(result.group('INTERVAL'))
        return value_minute

    @login_logout
    def get_pm_counters_file(self, local_path, bts_id=0, du_id=0):
        """
        Download PM file to the local directory if the PM files list
        is not empty
        :param local_path:      Path to save the file
        :type local_path:       str
        :param bts_id:          BTS id - related to Test Line
        configuration. Default: 0
        :type bts_id:           int
        :param du_id:           ID of Distribution Unit. Default: 0
        :type du_id:            int
        """

        self.admin.get_pm_files(local_file_path=local_path, timeout=120,
                                connection=self.rest_alias.format(
                                    bts_id, du_id))

    def wait_for_next_pm_period(self, interval=15, delay=30):
        """
        Wait for the next counter cycle, indicated by the interval
        :param interval:                    Interval of the counter
        in minutes
        :type  interval:                    int
        :param delay:                       Number of seconds to wait
        after the new period starts
        :type  delay:                       int
        :return: pm_period_start_time, pm_period_end_time
        """
        interval_minute_value = self.__parse_minute(interval)
        interval_seconds_value = interval_minute_value * 60
        waiting_time = interval_seconds_value - int(
            time.time()) % interval_seconds_value + delay
        logging.debug('Waiting for new PM period : {}'.format(
            timedelta(seconds=waiting_time)))
        time.sleep(waiting_time)

        current_timestamp = int(time.time())
        pm_period_start_time = current_timestamp - current_timestamp % 60
        pm_period_end_time = pm_period_start_time + interval_seconds_value

        return pm_period_start_time, pm_period_end_time

    def validate_counter_interval(self, counter_id, expected_interval,
                                  timeout, bts_id=0, du_id=0):
        """
        Validate if interval value of specify PM counter.

        :param counter_id:               Counter ID M...
        :type  counter_id:               str
        :param expected_interval:        Expected interval in minutes
        :type  expected_interval:        str
        :param timeout:                  timeout in minutes
        :type  timeout:                  str
        :param bts_id:                   ID for BTS
        :type  bts_id:                   int
        :param du_id:                    DU id(Distributed Unit) - id
        related to Test Line configuration - gnb.dus[]
        :type  du_id:                    int
        """
        waiting_time = 0
        incorrect_interval = True
        while incorrect_interval:
            MolerTest.sleep(300)
            counter_data = self.get_counter(counter_id)
            interval_list = []
            instance_id = self.get_bts_instance_id(bts_id, du_id)
            for timestamp in counter_data["BTS"]["BTS"]['NRBTS-{}'.format(
                    instance_id)]["NX2CB"][counter_id].keys():
                interval_list.append(int(timestamp))
            interval_list.sort(reverse=True)
            if len(interval_list) < 2:
                MolerTest.info("Not enough reports generated")
                continue
            else:
                actual_interval = interval_list[0] - interval_list[1]
                if self.__parse_minute(expected_interval) == int(
                        actual_interval / 60):
                    incorrect_interval = False
                    MolerTest.info("Proper value of PM counter interval")
                    continue
                else:
                    waiting_time += 5
                if waiting_time > self.__parse_minute(timeout):
                    incorrect_interval = False
                    MolerTest.error("PM counter interval have NOT change"
                                    " to correct value in last {}"
                                    " minute".format(timeout),
                                    raise_exception=True)

    @load_moler_configuration_from_tl()
    def validate_pm_reports_generation_interval(self, expected_interval,
                                                bts_id=0):
        """
        Validate if interval of generating PM reports is set according to
        'reportingIntervalPm' parameter value.

        :param expected_interval:             Expected interval in minutes
        :type  expected_interval:             str
        :param bts_id: ID for BTS
        :type  bts_id:                        int
        :return:                              True/False
        """
        device_name = "GNB{}".format(bts_id)
        bts = DeviceFactory.get_device(device_name)
        bts.goto_state("FCT")
        cmd_ls_la = bts.get_cmd(cmd_name="ls", cmd_params={
            "path": "/tmp"})
        tmp_files = cmd_ls_la()
        reports_timestamps = []
        for filename in tmp_files["files"].keys():
            if "PM.BTS" in filename and "ANY.xml.gz" in filename:
                sec = datetime.strptime(filename.split(".")[2] +
                                        filename.split(".")[3],
                                        '%Y%m%d%H%M%S') - datetime(
                    1900, 1, 1)
                reports_timestamps.append(int(sec.total_seconds() / 60))
        if len(reports_timestamps) > 2:
            reports_timestamps.sort(reverse=True)
            actual_interval = reports_timestamps[0] - reports_timestamps[1]
            if self.__parse_minute(expected_interval) == actual_interval:
                MolerTest.info("Reporting interval PM is set correctly")
                return True
            else:
                MolerTest.info(
                    "Expected value of reporting interval PM is {} min"
                    " but reports are generated with {} min "
                    "interval".format(expected_interval, actual_interval))
                return False
        else:
            return False

    def wait_for_pm_reports_generation_interval_change(self,
                                                       expected_interval,
                                                       timeout):
        """
        Wait for interval of generating PM reports change according to
         'reportingIntervalPm' parameter value.

        :param expected_interval:             Expected interval in minutes
        :type  expected_interval:             str
        :param timeout:                       timeout in minutes
        :type  timeout:                       str
        :return:                              True/False
        """
        waiting_time = 0
        incorrect_interval = True
        while incorrect_interval:
            MolerTest.sleep(300)
            if self.validate_pm_reports_generation_interval(
                    expected_interval):
                incorrect_interval = False
                MolerTest.info("Interval of generating PM reports has "
                               "changed to correct value in {}"
                               " minutes".format(waiting_time))
            else:
                waiting_time += 5
            if waiting_time > self.__parse_minute(timeout):
                incorrect_interval = False
                MolerTest.error(
                    "Interval of generating PM reports have NOT change "
                    "to correct value in last {} minute".format(
                        timeout), raise_exception=True)


class EnbCounter(GenericCounter):
    """Class contains Counter keywords for eNB"""

    bts_type = 'ENB'

    def __init__(self):
        """
        Constructor of Enb class.

        """

        super(EnbCounter, self).__init__(bts_type=EnbCounter.bts_type)


class GnbCounter(GenericCounter):
    """Class contains Counter keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.

        """

        super(GnbCounter, self).__init__(bts_type=GnbCounter.bts_type)
