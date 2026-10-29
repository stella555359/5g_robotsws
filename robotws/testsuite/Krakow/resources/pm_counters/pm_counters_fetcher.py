# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: MN_RAN_PZ_KRK_TAG
:contact: I_MN_RAN_PZ_KRK_TAG@internal.nsn.com
:maintainer: I_MN_RAN_PZ_KRK_TAG@internal.nsn.com
"""
import logging
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter
from taf.rfrl.bts.devices.generic_bts import login_logout
from moler.util.moler_test import MolerTest
from taf.rfrl.utilities.logger import custom_logger as logger
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import AdminApiProcedureFailureException


class GnbPmCounterFetcher(GnbPmCounter):

    def __init__(self):
        super().__init__()
        self.interval = None
        self.counters = None
        self.previous_interval = None
        self.initial_timestamp = None

    def set_interval(self, interval):
        """
        Set interval parameter

        :param interval: str of the interval value (usually "15min")
        :return:         None
        """
        self.interval = interval

    def set_counters(self, counters):
        """
        Set counters parameter

        :param counters:   dict of  counters data
        :return:           None
        """
        self.counters = counters

    def set_initial_timestamp(self, initial_timestamp):
        """
        Set initial timestamp parameter - if defined will be used as reference to compare counters values

        :param initial_timestamp: int of the initial timestamp
        :return:                  None
        """
        self.initial_timestamp = initial_timestamp

    def _get_counter_parameters(self, counter_name, bts_id=0, du_id=0):
        """
        Get parameters (dist name, abbreviation) for counter
        to recommission the related parameters.

        :param counter_name:         counter ID (Mxxx...) for which we want to get parameters
        :param bts_id:               BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id:                int DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:                     tuple of parameter dist name and abbreviation
        """
        counter_params = self.counters[counter_name]
        counter_distname = self.adjust_dist_name(dist_name=counter_params["distName"], bts_id=bts_id, du_id=du_id)
        return counter_distname, counter_params["abbreviation"]

    @login_logout
    def _get_sensor_temp_info_via_oam(self, sensor_object_path, value_key, bts_id=0, du_id=0):
        """
        Function that retrieves a numeric-type value from a get_parameters()
        response, assuming that the value is accessible with a single key in get_parameters().keys()

        :param   sensor_object_path: str that points to the object InfoModel path
        :param   value_key:          str key to the returned data that points to the desired value
        :param   bts_id:             BTS(eNB/gNB) id - related to Test Line configuration.
        :param   du_id:              DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:                     a numeric type of the sensor temperature value
        """
        return self.admin.get_parameters(dist_name=sensor_object_path,
                                         connection=self.rest_alias.format(bts_id, du_id))[value_key]

    def wait_for_next_pm_period_for_default_interval(self, delay=30):
        """
        Wait for the next counter cycle, indicated by the default test interval

        :param   delay:              number of seconds to wait after the new period starts
        :return: None
        """
        logger.log_info_to_console("Wait for next measurement period")
        self.wait_for_next_pm_period(interval=self.interval, delay=int(delay))

    def wait_for_next_pm_period_for_previous_interval(self):
        """
        Wait for the next counter cycle, indicated by the previous interval

        :return: None
        """
        logger.log_info_to_console("Wait for next measurement period")
        self.wait_for_next_pm_period(interval=self.previous_interval)

    def set_counters_interval_to_default(self):
        """
        Set counters interval to default test value

        :return: None
        """
        self.set_counters_interval(interval=self.interval)

    def disable_counters_interval(self):
        """
        Disable counters interval

        :return: None
        """
        self.set_counters_interval(interval="disabled")

    def set_counters_interval(self, interval):
        """
        Set test-related commissioning parameters, defined by their
        entry in variables.counters

        :param interval: str of the interval value (usually 'disabled' or "15min")
        :return:         None, raises taf.sbts.oam.coam.admin.legacy.exceptions.
                         AdminApiProcedureFailureException if recommissioning failed
        """
        logger.log_info_to_console("Set counters interval to {}".format(interval))
        for counter in self.counters:
            info = self._get_counter_parameters(counter_name=counter)
            self.set_pm_interval(dist_name=info[0], abbr_group_name=info[1], interval=interval)

    def validate_counters_values_are_disabled(self):
        """
        Validate that previously values "disabled" is set on the BTS.
        Verification is done for every entry in variables.counters

        :return: None
        """
        return self.validate_counters_values(expected_value="disabled")

    def validate_counters_have_default_values(self):
        """
        Validate that previously default test values is set on the BTS.
        Verification is done for every entry in variables.counters

        :return: None
        """
        return self.validate_counters_values(expected_value=self.interval)

    def validate_counters_values(self, expected_value):
        """
        Validate that previously set interval values is set on the BTS.
        Verification is done for every entry in variables.counters

        :param expected_value: str of the expected interval value (usually 'disabled' or "15min")
        :return:               None, will print if values do not match as expected
        """
        logger.log_info_to_console("Validate that counters are set to {}".format(expected_value))
        for counter in self.counters.keys():
            info = self._get_counter_parameters(counter_name=counter)
            active_interval = self.get_pm_interval(dist_name=info[0], abbr_group_name=info[1])
            BuiltIn().run_keyword("Should Be Equal As Strings", expected_value, active_interval)

    def save_current_counters_values(self):
        """
        Validate for each test counter that counter is not in disable mode and save current counter value.
        :return: str, current counter interval
        """
        logger.log_info_to_console("Get current interval value")
        active_interval = None
        for counter in self.counters.keys():
            info = self._get_counter_parameters(counter_name=counter)
            active_interval = self.get_pm_interval(dist_name=info[0], abbr_group_name=info[1])
            BuiltIn().run_keyword("Should Not Be Equal As Strings", "disabled", active_interval)
        self.previous_interval = active_interval

    def validate_counters_inactive(self):
        """
        Validate for each test counter that it is not active (by waiting the 'waiting_period'
        after a new PM period starts and verifying no new values appeared)

        :return: None, raises MolerException if counter was active
        """
        logger.log_info_to_console("Wait until previously set interval passes and "
                                   + "verify no new measurements were reported")
        self.validate_counter_is_inactive(counters=list(self.counters.keys()),
                                          waiting_period=self.previous_interval)

    def validate_counters_intervals(self, timeout='default', delay=30):
        """
        For each counter in the test validate that the interval between reported values
        was the expected value

        :param   timeout:                  timeout in minutes, e.g. "15min",
                                           if the value is 'default', it will be set to twice the expected interval
        :param   delay:                    number of seconds to wait after the new period starts
        :return: last_timestamp_value, raises MolerException when intervals do not match
        """
        logger.log_info_to_console("Validate measurement appeared after given time")
        return self.validate_counter_interval(counter_id=list(self.counters.keys()),
                                              expected_interval=self.interval,
                                              timeout=timeout,
                                              delay=int(delay))

    def fetch_data_and_validate(self):
        """
        Gather data for 'interval' minutes every 60 seconds, calculate expected
        counter values and validate them against counter values reported in GUI

        :return: None, prints if values are not matching
        """
        logger.log_info_to_console("Validate counters")
        mapping = {}
        for counter in self.counters.keys():
            mapping[counter] = {}
            for sensor_info in self.counters[counter]["sensors"]:
                object_path = sensor_info["object_path"]
                if object_path.split("/")[-1].split("-")[0] == "UNIT_TEMPERATURE_REPORT":
                    mapping[counter][object_path] = self._get_ru_fetch_function(sensor_info["object_path"],
                                                                                sensor_info["sensor_type"],
                                                                                sensor_info["offset"])
                elif object_path.split("/")[-1].split("-")[0] == "SFP_PARAMS_L":
                    mapping[counter][object_path] = self._get_sfp_fetch_function(sensor_info["object_path"],
                                                                                 sensor_info["offset"])
                elif object_path.split("/")[-1].split("-")[0] == "TEMP_SENSOR":
                    mapping[counter][object_path] = self._get_xmod_fetch_function(sensor_info["object_path"],
                                                                                  sensor_info["offset"])
                else:
                    raise ValueError("Unexpected temperature sensor path -> {}: {}".format(counter, object_path))

        data = self._fetch_data(mapping)
        logger.log_info_to_console("Wait for counter availability")
        MolerTest.sleep(60)

        logger.log_info_to_console("Get values from GUI")
        counter_info = {}
        for counter in self.counters.keys():
            counter_info[counter] = self.get_pm_counter_info_via_gui(counter)

        processed = {}
        for counter in self.counters.keys():
            if self.counters[counter]["operation_type"] == "get_avg":
                processed[counter] = self._get_avg(list(data[counter].values())[0])
            elif self.counters[counter]["operation_type"] == "get_max":
                processed[counter] = self._get_max(*list(data[counter].values()))
            else:
                raise ValueError("Not supported operation type for counter {}".format(counter))

        logger.log_info_to_console("Validate calculated values against GUI")
        for counter in counter_info.keys():
            self._check_if_same_value(processed[counter], counter_info[counter], counter)

    @staticmethod
    def _check_if_same_value(temp_oam, temp_gui, name):
        temp_oam = int(temp_oam)
        temp_gui = int(temp_gui)
        if temp_oam == temp_gui or (temp_oam + 1) == temp_gui or (temp_oam - 1) == temp_gui:
            logger.log_info_to_console("Values are equal, temp of {0} is {1}".format(name, temp_oam))
        else:
            BuiltIn().run_keyword("Fail",
                                  "Values of {0} are not equal, oam:{1} gui:{2}".format(name, temp_oam, temp_gui))

    def _fetch_data(self, fetch_functions_map):
        """
        Call each data gathering function from fetch_function_map.values()
        and append each value to corresponding array, which is returned at the end

        :param fetch_functions_map: dict of (str, callable[[], float] pairs that
                                    will be used to create a dict entry of values fetched using the callable
        :return:                    dict of (str, list), where keys are strings from fetch_functions_map.keys(),
                                    and values are lists of values using the function from fetch_functions_map.values()
        """
        value_lists = {}
        for counter in fetch_functions_map.keys():
            value_lists[counter] = {}
            for sensor in fetch_functions_map[counter].keys():
                value_lists[counter][sensor] = []
        interval = int(''.join(filter(str.isdigit, self.interval)))

        for _ in range(interval):
            for counter in fetch_functions_map.keys():
                for sensor in fetch_functions_map[counter].keys():
                    value = fetch_functions_map[counter][sensor]()
                    value_lists[counter][sensor].append(value)
            MolerTest.sleep(60)
        return value_lists

    @login_logout
    def _get_ru_fetch_function(self, ru_object_path, sensor_type="AMBIENT", offset=0, bts_id=0, du_id=0):
        """
        Function that returns a callable to get a sensor value from a radio unit,
        according to the sensor_type parameter and given path to ru.

        :param ru_object_path:   str of InfoModel path to radio unit
        :param sensor_type:      str of sensor type on radid (AMBIENT, MODULE, or antennaXY:Z -
                                 see unitTemperatureReport in radio InfoModel for more information)
        :param offset:           offset which should be added to each measurement
        :param bts_id:           BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id:            DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:                 function that gets RMOD sensor value
        """

        def get_sensor_value():
            temperature_report = \
                self.admin.get_parameters(dist_name=ru_object_path,
                                          connection=self.rest_alias.format(bts_id, du_id))["temperatureReport"]
            try:
                module_temperature = \
                    next(filter(lambda dictionary: dictionary["sensorName"] == sensor_type,
                                temperature_report))["value"]
                return module_temperature + offset
            except StopIteration:
                raise ValueError(
                    "{} sensor value was not available in {} unitTemperatureReport".format(sensor_type, ru_object_path))

        return get_sensor_value

    def _get_xmod_fetch_function(self, xmod_sensor_object_path, offset=0):
        """
        Function that returns a a callable to get temperature for SMOD or BBMOD sensors.
        Representation of sensor data differs from device to device in InfoModel, therefore another function is needed
        to get data from RMOD.

        :param xmod_sensor_object_path: str of InfoModel path to SMOD or BBMOD objects
        :param offset:                  offset which should be added to each measurement
        :return:                        function that gets SMOD/BBMOD sensor temperature
        """
        return lambda: self._get_sensor_temp_info_via_oam(xmod_sensor_object_path, "temperature") + offset

    def _get_sfp_fetch_function(self, sfp_object_path, offset=0):
        """
        Function that returns a callable to get temperature of an SFP connector.
        Works the same for most devices like RMOD, SMOD or BBMOD, because representation of an SFP is usually the same
        in InfoModel

        :param sfp_object_path: path to SFP object in InfoModel
        :param offset:          offset which should be added to each measurement
        :return:                function that gets SFP sensor temperature
        """
        def get_modtemp_value():
            try:
                x = self._get_sensor_temp_info_via_oam(sfp_object_path, "modTemp")
            except AdminApiProcedureFailureException:
                string = sfp_object_path.replace("CONNECTOR_L-1", "CONNECTOR_L-201")
                x = self._get_sensor_temp_info_via_oam(string, "modTemp")
            return x + offset

        return get_modtemp_value

    @staticmethod
    def _get_max(*args):
        """
        Behaves like normal max() function for numeric arguments, but will extract the highest value
        from an iterable of iterables (max() would return a list)

        :param args: list of iterables or list of numeric types to find maximum from
        :return:     maximum value found in passed arguments
        """
        if isinstance(args[0], int) or isinstance(args[0], float):
            return round(max(*args))
        elif isinstance(args[0], list):
            maximum = -1
            for value_list in args:
                val = max(value_list)
                if val > maximum:
                    maximum = val
            return round(maximum)

    @staticmethod
    def _get_avg(values):
        """
        Get average value from an iterable of numbers

        :param values: iterable of numeric values
        :return:       average of all numeric values in passed argument
        """
        if len(values) == 0:
            raise ZeroDivisionError("Empty array was passed to get_avg")
        else:
            return round(sum(values) / len(values))

    @login_logout
    def wait_for_proper_statuses(self, timeout=5*60, bts_id=0, du_id=0):
        """
        Wait for proper statuses for counters defined in 'counters'
        :param timeout:          timeout in seconds
        :param bts_id:           BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id:            DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        """
        waiting_time = 0
        logger.log_info_to_console("Waiting for proper statuses defined in temperature counters data "
                                   "up to {0} seconds".format(timeout))
        while not self._validate_statuses_for_counters() and waiting_time <= timeout:
            MolerTest.sleep(10)
            waiting_time += 10
        if waiting_time > timeout:
            raise TimeoutError("Statuses defined in temperature counters data are not valid "
                               "after the waiting period of {0} seconds".format(timeout))
        else:
            logging.info("All statuses defined in temperature counters data have proper values")

    def _validate_statuses_for_counters(self, bts_id=0, du_id=0):
        """
        Validate statuses for counters defined in 'counters'
        :param bts_id:           BTS(eNB/gNB) id - related to Test Line configuration.
        :param du_id:            DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: True if SW all given counters have proper statuses else False
        """
        for counter in list(self.counters.keys()):
            if "validate_statuses" in self.counters[counter].keys():
                for model_object in self.counters[counter]["validate_statuses"]:
                    object_path = model_object["distName"]
                    object_info = self.admin.get_parameters(dist_name=object_path,
                                                            connection=self.rest_alias.format(bts_id, du_id))
                    for status, expected_value in model_object["proper_statuses"].items():
                        if status in object_info.keys():
                            if expected_value != object_info[status]:
                                logging.debug("Status {0} for the counter {1} is {2}, but should be {3}"
                                              .format(status, counter, object_info[status], expected_value))
                                return False
                        else:
                            logging.debug("Status {0} not found for the counter {1}".format(status, counter))
        return True

    def validate_counters_data_increased(self):
        """
        For each counter validate if actual value is greater than previous

        """
        counters_data = self._extract_last_counters_data(counters_data=self._get_counters_data())
        for counter in self.counters.keys():
            actual_data = counters_data[counter]["actual_data"]
            initial_data = counters_data[counter]["initial_data"]
            if int(actual_data) > int(initial_data):
                logging.debug("Counter {} value increased, previous: {}, actual: {}".format(
                    counter, initial_data, actual_data))
            else:
                BuiltIn().run_keyword("Fail", "Counter {} value NOT increased, previous: {}, actual: {}".format(
                    counter, initial_data, actual_data))

    def _get_counters_data(self):
        """
        For each counter get current data values

        :return: list of dict of counters with timestamp-value pairs
        """
        counters_id = list(self.counters.keys())
        counters_id = ",".join(counters_id)
        counters_data = self.get_counter(counters_id)
        extracted_data = self.extract_counter_data_from_response(response=counters_data, counter_id=counters_id)
        logging.debug("Extracted counters data: {}".format(extracted_data))
        return extracted_data

    def _extract_last_counters_data(self, counters_data):
        """
        For each counter get previous and actual data value

        :param   counters_data:   list of dict of counters with timestamp-value pairs
        :return: dict of counters with previous and actual data value
        """
        extracted_data = {}
        for counter in self.counters.keys():
            for counter_data in counters_data:
                if counter == counter_data["counter_name"]:
                    timestamps = list(counter_data["timestamps"][0].keys())
                    timestamps = [int(i) for i in timestamps]
                    timestamps.sort()
                    initial_timestamp = timestamps[-2] if self.initial_timestamp is None else self.initial_timestamp
                    extracted_data[counter] = {
                        "initial_data": counter_data["timestamps"][0][str(initial_timestamp)],
                        "actual_data": counter_data["timestamps"][0][str(timestamps[-1])]}
        return extracted_data
