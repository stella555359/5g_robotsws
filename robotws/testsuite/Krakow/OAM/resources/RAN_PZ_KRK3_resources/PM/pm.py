"""
Keywords for PM automation scripts for CU and DU performance tests.

:copyright: Nokia Networks
:author: Marek Bodziony
:contact: marek.bodziony@nokia.com
:maintainer: Marek Bodziony
:contact: marek.bodziony@nokia.com

"""
import time
import re
import logging
import json
import os
from moler.device import DeviceFactory
from moler.exceptions import CommandFailure
from taf.rfrl.bts.connections import device_aliases as connection_names
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations, login_logout


class GeneralPm(GenericDuOperations):

    bts_type = 'GNB'

    def __init__(self, device, device_state):
        super(GeneralPm, self).__init__(bts_type=GeneralPm.bts_type)
        self.device = device
        self.device_state = device_state

    @load_moler_configuration_from_tl()
    def wait_for_next_pm_measurement(self, measurement_interval=15, save_measurement_time=3,
                                     ignore_current_pm_measurement=False):
        """
        Wait for next PM measurement, ignore current if needed.
        :param int measurement_interval: PM measurement collecting interval in minutes
        :param int save_measurement_time: waiting time for PM measurement to save
        :param bool ignore_current_pm_measurement: ignore current PM collecting interval and start waiting from next
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        date = gnb.get_cmd(cmd_name="date")
        output = date()
        current_time = output['TIME']['FULL']
        minutes = int(current_time.split(":")[1])
        wait_measurement_interval = measurement_interval
        if not ignore_current_pm_measurement:
            wait_measurement_interval = 0
        if minutes < 15:
            wait_for_next_measurement = 15 - minutes
        elif minutes < 30:
            wait_for_next_measurement = 30 - minutes
        elif minutes < 45:
            wait_for_next_measurement = 45 - minutes
        else:
            wait_for_next_measurement = 60 - minutes
        wait = wait_for_next_measurement + wait_measurement_interval + save_measurement_time
        logging.warning("Waiting for new PM measurement files: {} min".format(wait))
        time.sleep(wait * 60)

    @load_moler_configuration_from_tl()
    def create_temp_dir_for_pm_verification(self, tmp_path="/tmp"):
        """
        Create temporary directory on CU/DU for PM measurement verification.
        :param str tmp_path: temporary path where TEMP_DIR will be created
        :return str: full path of created temporary directory
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        date = gnb.get_cmd(cmd_name="date")
        date_tag = date()
        date_tag = "{}{}{}".format(date_tag['DATE']['YEAR'], date_tag['DATE']['MONTH'], date_tag['DATE']['DAY'])
        temp_dir = '{}/PM_counters_DU_{}'.format(tmp_path, date_tag)
        mkdir = gnb.get_cmd(cmd_name="mkdir", cmd_params={"path": "{}".format(temp_dir)})
        try:
            mkdir()
        except CommandFailure as error:
            if "File exists" in str(error):
                logging.debug("TEMP_DIR: '{}' already exists. It will be DELETED".format(temp_dir))
                self.remove_temp_dir(temp_dir=temp_dir)
                self.create_temp_dir_for_pm_verification(tmp_path=tmp_path)
            else:
                raise Exception(error)
        logging.info("Created TEMP_DIR: '{}'".format(temp_dir))
        return temp_dir

    @load_moler_configuration_from_tl()
    def remove_temp_dir(self, temp_dir):
        """
        Delete temporary directory from CU/DU used for PM measurement verification.
        :param str temp_dir: path where TEMP_DIR was created
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        rm = gnb.get_cmd(cmd_name="rm", cmd_params={"options": "-r", "file": "{}".format(temp_dir)})
        rm()
        logging.info("TEMP_DIR: '{}' was deleted".format(temp_dir))

    def get_compressed_pm_measurement_size(self, temp_dir):
        """
        Get size of compressed PM measurements.
        :param str temp_dir: temporary directory with PM measurements
        :return int: size of compressed PM measurements (in KB)
        """
        size = self._get_pm_measurement_files_size(temp_dir=temp_dir)
        logging.warning("PM measurement compressed size: {} KB".format(size))
        return size

    def get_uncompressed_pm_measurement_size(self, temp_dir):
        """
        Get size of uncompressed PM measurements.
        :param str temp_dir: temporary directory with PM measurements
        :return int: size of uncompressed PM measurements (in KB)
        """
        size = self._get_pm_measurement_files_size(temp_dir=temp_dir)
        logging.warning("PM measurement uncompressed size: {} KB".format(size))
        return size

    @load_moler_configuration_from_tl()
    def _get_pm_measurement_files_size(self, temp_dir):
        """
        Get total size of PM files in temporary directory.
        :param str temp_dir: temporary directory with PM measurements
        :return: int total size of PM files
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        du = gnb.get_cmd(cmd_name="du", cmd_params={"options": "-s {}".format(temp_dir)})
        output = du()
        size = output["{}".format(temp_dir)]["size_raw"]
        return size

    @load_moler_configuration_from_tl()
    def uncompress_pm_measurement_files(self, temp_dir):
        """
        Unzip PM measurement files in temporary directory.
        :param str temp_dir: temporary directory with PM measurements
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        gunzip = gnb.get_cmd(cmd_name="gunzip", cmd_params={"options": "{}/*".format(temp_dir), "archive_name": ""})
        gunzip()
        logging.info("PM measurements were uncompressed in: {}".format(temp_dir))

    @staticmethod
    def check_compression_factor(pm_uncompressed_size, pm_compressed_size, max_compression_factor=0.2):
        """
        Check compression factor of PM measurement.
        :param int pm_uncompressed_size: size of uncompressed PM measurement
        :param int pm_compressed_size: size of compressed PM measurement
        :param float max_compression_factor: maximum of allowed compression factor
        :return float: compression factor
        """
        compression_factor = float(pm_compressed_size) / float(pm_uncompressed_size)
        logging.debug("PM compression factor = {}. Should be less than {}".format(compression_factor,
                                                                                  max_compression_factor))
        assert_failed_msg = "PM measurement compression factor={} is above the limit! It should be lower than {}" \
            .format(compression_factor, max_compression_factor)
        assert compression_factor < max_compression_factor, assert_failed_msg
        logging.warning("Compression factor = {}".format(compression_factor))
        return compression_factor

    @load_moler_configuration_from_tl()
    def _get_pm_creation_time(self, path, file_name):
        """
        Get exact time of PM file creation on CU/DU.
        :param str path: path where PM measurements are stored
        :param str file_name: name of PM file
        :return int, int, int: time of file creation (hours, minutes, seconds)
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        ls = gnb.get_cmd(cmd_name="ls", cmd_params={"path": "{}/{}".format(path, file_name), "options": "{}"
                         .format("-la --time-style=full-iso")})
        output = ls()
        file_creation_info = output['files']['{}/{}'.format(path, file_name)]['date']
        file_creation_time = re.findall("[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]*", file_creation_info).pop()
        hours = int(file_creation_time[0:2])
        minutes = int(file_creation_time[3:5])
        seconds = int(file_creation_time[6:8])
        milliseconds = int(file_creation_time[9:])
        logging.debug("File '{}' was created at {}".format(file_name, file_creation_time))
        return hours, minutes, seconds, milliseconds


class CU(GeneralPm):
    def __init__(self):
        self.bts_id = 0
        super(CU, self).__init__(device=format(connection_names.ssh_gnb_cu.format(self.bts_id)), device_state="OAM")

    @load_moler_configuration_from_tl()
    def _get_latest_pm_measurement_file_name_for_cu(self, path):
        """
        Get latest PM measurement file name on CU.
        :param str path: path where PM measurements are stored on CU
        :return str: name of latest PM measurement file
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        ls = gnb.get_cmd(cmd_name="ls", cmd_params={"path": "{}/A*".format(path), "options": "-t"})
        pm_files = ls()
        if len(pm_files) == 0:
            raise Exception("No PM files available, check if PM measurements are activated on CU. It should be stored"
                            " at: {}".format(path))
        pm_files = list(pm_files['files'].keys())
        pm_files.sort()
        latest_pm_file = pm_files[-1:][0]
        latest_pm_measurement_file_name = latest_pm_file.split('/')[-1].split(':')[0].rstrip()
        return latest_pm_measurement_file_name

    @load_moler_configuration_from_tl()
    def get_latest_pm_measurement_files_from_cu(self, path, temp_dir):
        """
        Copy latest PM measurement files from CU to temporary directory.
        :param str path: path where PM measurements are stored on CU
        :param str temp_dir: temporary directory where PM measurements should be copied
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        latest_pm_file = self._get_latest_pm_measurement_file_name_for_cu(path=path)
        logging.info("Latest PM measurement file name={}".format(latest_pm_file))
        cp = gnb.get_cmd(cmd_name="cp", cmd_params={"src": "{}/{}*".format(path, latest_pm_file), "dst": "{}"
                         .format(temp_dir)})
        cp()
        logging.info("Latest PM measurement files were copied to: {}".format(temp_dir))

    @load_moler_configuration_from_tl()
    def check_total_number_of_pm_measurement_files(self, temp_dir, expected):
        """
        Check total number of PM measurement files in temporary directory.
        :param str temp_dir: temporary directory where PM measurements from CU are copied
        :param str expected: expected number of PM measurement files
        :return: total number of PM measurement files
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        ls = gnb.get_cmd(cmd_name="ls", cmd_params={"path": "{}".format(temp_dir)})
        output = ls()
        number_of_pm_files = len(output["files"])
        logging.warning("Total number of PM measurement files = {}".format(number_of_pm_files))
        assert_failed_msg = 'Number of PM files = {}, but was expecting >= {}'.format(number_of_pm_files, expected)
        assert number_of_pm_files >= int(expected), assert_failed_msg
        return number_of_pm_files

    @load_moler_configuration_from_tl()
    def _get_pm_measurement_list(self, temp_dir):
        """
        Get list of PM files stored in directory.
        :param str temp_dir: temporary directory where PM measurements from CU are copied
        :return list[str] : list of PM measurement files
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        ls = gnb.get_cmd(cmd_name="ls", cmd_params={"path": "{}".format(temp_dir)})
        output = ls()
        pm_measurement_list = list(output['files'].keys())
        pm_measurement_list.sort()
        logging.info(pm_measurement_list)
        return pm_measurement_list

    @load_moler_configuration_from_tl()
    def _get_pm_counters_count_from_pm_measurement_file(self, file_path):
        """
        Get list of PM counters from PM measurement file.
        :param str file_path: path for PM measurement file
        :return int: number of PM counters in PM measurement file
        """
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        cat = gnb.get_cmd(cmd_name="cat", cmd_params={"path": "{}".format(file_path)})
        output = cat(timeout=60)
        file_content_list = output['LINES']
        pm_counters = [re.findall("<M[0-9A-Z]+>", line) for line in file_content_list]
        pm_counters = [pm.pop() for pm in pm_counters if pm]
        pm_counters = set(pm_counters)
        return len(pm_counters)

    def check_total_number_of_pm_counters(self, temp_dir, expected):
        """
        Check total number of PM counters in PM measurement files.
        :param str temp_dir: temporary directory where PM measurements from CU are copied
        :param int expected: expected number of total PM counters in PM measurements
        :return: total number of PM counters
        """
        total_pm_counters = 0
        pm_measurement_files_list = self._get_pm_measurement_list(temp_dir=temp_dir)
        for pm_measurement_file in pm_measurement_files_list:
            pm_counters_count = self._get_pm_counters_count_from_pm_measurement_file(
                file_path="{}/{}".format(temp_dir, pm_measurement_file))
            logging.info("Number of PM counters in '{}' = {}".format(pm_measurement_file, pm_counters_count))
            total_pm_counters += pm_counters_count
        logging.warning("Total number of PM counters = {}".format(total_pm_counters))
        assert_failed_msg = 'Number of PM counters = {}, but was expecting >= {}'.format(total_pm_counters, expected)
        assert total_pm_counters >= int(expected), assert_failed_msg
        return total_pm_counters

    def check_duration_of_pm_data_creation_time(self, path, max_pm_creation_time=1):
        """
        Check if time of creation of every PM measurement file on CU is lower than allowed creation time.
        :param str path: path where PM measurement files are stored on CU
        :param int max_pm_creation_time: maximum allowed time for PM files creation
        :return: maximum time of PM file creation
        """
        latest_pm_measurements = self._get_latest_pm_measurement_list(path=path)
        duration_of_pm_data_creation = []
        for pm in latest_pm_measurements:
            pm_creation_hours, pm_creation_minutes, pm_creation_seconds, pm_creation_millisec \
                = self._get_pm_creation_time(path=path, file_name=pm)
            duration_of_pm_data_creation.append("{}.{}".format(str(pm_creation_seconds), str(pm_creation_millisec)))
            pm_period_end_hours, pm_period_end_minutes = self._get_end_of_pm_reporting_time(file_name=pm)
            assert_failed_msg = "Duration for the PM result file ({}) creation is higher or equal to {} min." \
                .format(pm, max_pm_creation_time)
            assert pm_creation_hours == pm_period_end_hours and pm_creation_minutes == pm_period_end_minutes and \
                   pm_creation_seconds < max_pm_creation_time * 60, assert_failed_msg
        max_duration_of_pm_data_creation = max(duration_of_pm_data_creation)
        logging.debug("PASS: Duration of PM files creation is as expected (below {} min)".format(max_pm_creation_time))
        logging.warning("PM data saved in: {}s".format(max_duration_of_pm_data_creation))
        return max_duration_of_pm_data_creation

    @load_moler_configuration_from_tl()
    def _get_latest_pm_measurement_list(self, path):
        """
        Get list of latest PM measurements created on CU.
        :param str path: path where PM measurement files are stored on CU
        :return list[str]: list of latest PM measurement files from CU
        """
        latest_pm = self._get_latest_pm_measurement_file_name_for_cu(path=path)
        gnb = DeviceFactory.get_device(self.device)
        gnb.goto_state(self.device_state)
        ls = gnb.get_cmd(cmd_name="ls", cmd_params={"path": "{}/{}*".format(path, latest_pm)})
        output = ls()
        pm_measurements = output['files']
        pm_measurements = [re.findall("[A-Za-z0-9.+\\-_:]+xml.gz", pm) for pm in pm_measurements]
        pm_measurements = [pm.pop() for pm in pm_measurements]
        logging.info("Latest PM measurements:\n{}".format(pm_measurements))
        return pm_measurements

    @staticmethod
    def _get_end_of_pm_reporting_time(file_name):
        """
        Get end of interval for collecting PM measurement file on CU.
        :param str file_name: name of PM measurement file
        :return int, int: end of collecting PM interval (hours and minutes)
        """
        reporting_time = re.findall(".[0-9]{4}\\+", file_name)
        end_of_reporting_time = reporting_time[1][1:-1]
        hours = end_of_reporting_time[0:2]
        minutes = end_of_reporting_time[2:]
        logging.info("PM measurement periods for '{}' ends at: {}:{}:00".format(file_name, hours, minutes))
        return int(hours), int(minutes)


class DU(GeneralPm):
    def __init__(self):
        super(DU, self).__init__(device="GNB0", device_state="FCT")

    @load_moler_configuration_from_tl()
    def get_latest_pm_measurement_file_from_du(self, path, temp_dir):
        """
        Copy latest PM measurement file from DU to temporary directory.
        :param str path: path where PM measurements are stored on DU
        :param str temp_dir: temporary directory where PM measurements should be copied
        """
        du = DeviceFactory.get_device(self.device)
        du.goto_state(self.device_state)
        ls = du.get_cmd(cmd_name="ls", cmd_params={"path": "{}".format(path)})
        pm_files = ls()
        if len(pm_files) == 0:
            assert False, "No PM files available, check if PM measurements are activated on DU. It should be stored" \
                          " at: {}".format(path)
        pm_files = list(pm_files['files'].keys())
        pm_files.sort()
        latest_pm_file = pm_files[-1:][0]
        logging.info("Latest PM measurement file name={}".format(latest_pm_file))
        cp = du.get_cmd(cmd_name="cp", cmd_params={"src": "{}/{}".format(path, latest_pm_file), "dst": "{}"
                        .format(temp_dir)})
        cp()
        logging.info("Latest PM measurement files were copied to: {}".format(temp_dir))

    @load_moler_configuration_from_tl()
    def check_duration_of_pm_data_creation_time(self, path, max_pm_creation_time=1):
        """
        Check if time of creation of PM measurement file on DU is lower than allowed creation time.
        :param str path: path where PM measurement file is stored on DU
        :param int max_pm_creation_time: maximum allowed time for PM file creation
        """
        max_pm_creation_time_in_sec = max_pm_creation_time * 60
        du = DeviceFactory.get_device(self.device)
        du.goto_state(self.device_state)
        ls = du.get_cmd(cmd_name="ls", cmd_params={"path": "{}".format(path), "options": "-t"})
        output = ls()
        pm_files = output['files'].keys()
        if len(pm_files) == 0:
            raise Exception("No PM files available, check if PM measurements are activated on DU. It should be stored"
                            " at: {}".format(path))
        pm_file_name = list(pm_files)[0]
        pm_creation_hours, pm_creation_minutes, pm_creation_seconds, pm_creation_millisec = self._get_pm_creation_time(
            path=path, file_name=pm_file_name)
        pm_period_end_hours, pm_period_end_minutes = self._get_end_of_pm_reporting_interval_for_du(
            file_name=pm_file_name)
        assert pm_creation_minutes == pm_period_end_minutes and pm_creation_seconds < max_pm_creation_time_in_sec, \
            "Duration for the PM result file ({}) creation is higher or equal to {} min.".format(pm_file_name,
                                                                                                 max_pm_creation_time)
        logging.info("PM measurement was created in {}.{}s, it's below threshold ({}s)"
                     .format(pm_creation_seconds, pm_creation_millisec, max_pm_creation_time_in_sec))
        logging.warning("PM data saved in: {}.{}s".format(pm_creation_seconds, pm_creation_millisec))

    @staticmethod
    def _get_end_of_pm_reporting_interval_for_du(file_name):
        """
        Get end of interval for collecting PM measurement file on DU, be aware of time zone shift.
        :param str file_name: name of PM measurement file
        :return int, int: end of collecting PM interval (hours and minutes)
        """
        utc_time_zone = 2
        end_of_reporting_time = re.findall("[0-9]{6}", file_name)[1]
        hours = end_of_reporting_time[0:2]
        if hours == "22":
            final_hours = int("00")
        elif hours == "23":
            final_hours = int("01")
        else:
            final_hours = int(hours) + utc_time_zone
        minutes = end_of_reporting_time[2:4]
        seconds = end_of_reporting_time[4:]
        logging.debug("PM measurement periods for '{}' ends at: {}:{}:{}".format(file_name, final_hours, minutes,
                                                                                 seconds))
        return int(final_hours), int(minutes)

    @load_moler_configuration_from_tl()
    def get_cpu_load(self, repeat=1000):
        """
        Get value of average CPU load of DU.
        :param int repeat: how many times CPU load should be checked
        :return float: CPU load in %
        """
        du = DeviceFactory.get_device(self.device)
        du.goto_state(self.device_state)
        cpu_loads = list()
        for i in range(repeat):
            top = du.get_cmd(cmd_name="top", cmd_params={"options": "-b", "n": 2})
            output = top()
            cpu_load = ((100.00 - float(output['%Cpu']['not used'])) + 700)/8
            cpu_loads.append(cpu_load)
        cpu_load_average = sum(cpu_loads) / len(cpu_loads)
        logging.info('CPU loads ({} iterations):\n{}'.format(repeat, cpu_loads))
        logging.warning('Average CPU load = {}%'.format(cpu_load_average))
        return cpu_load_average

    @staticmethod
    def verify_cpu_load(with_pm_enabled, with_pm_disabled, cpu_load_max_diff=4.0):
        """
        Verify CPU load impact on DU with PM measurements enabled/disabled.
        :param float with_pm_enabled: value of CPU load with PM enabled
        :param float with_pm_disabled: value of CPU load with PM disabled
        :param float cpu_load_max_diff: maximum allowed value of CPU load
        :return float: value of impact on CPU load
        """
        cpu_load_diff = float(with_pm_enabled) - float(with_pm_disabled)
        assert_failed_msg = "CPU load with PM measurements ENABLED is: {}%, it's higher than allowed threshold ({}%)" \
            .format(cpu_load_diff, cpu_load_max_diff)
        assert cpu_load_diff <= cpu_load_max_diff, assert_failed_msg
        logging.warning("CPU load with PM measurements enabled increase = {}%, it's below threshold ({}%)"
                        .format(cpu_load_diff, cpu_load_max_diff))
        return cpu_load_diff

    @login_logout
    def check_pm_counters_on_du(self, bts_id=0, du_id=0):
        """
        Check and print total number of PM counters from PM file on DU.
        :return int, int: number of total and unique PM counters stored in PM file
        """
        pm_counters = self.admin.get_counters_info(connection=self.rest_alias.format(bts_id, du_id), timeout=60)
        pm_counters_all = re.findall("M[0-9A-Z]*", str(pm_counters))
        pm_counters_unique = set(pm_counters_all)
        logging.warning("Total number of PM counters: {}".format(len(pm_counters_all)))
        logging.warning("Number of unique PM counters: {}".format(len(pm_counters_unique)))
        return pm_counters_all, pm_counters_unique

    def prepare_delta_plan_for_testline(self, delta_plan, mrbts_id, nrbts_id):
        """
        Prepare DELTA_PLAN for specific testline configuration (using MRBTS, NRBTS and software release version), it
        will be used to enable/disable PM measurements on DU.
        :param str delta_plan: path to generic DELTA_PLAN file (.json)
        :param int mrbts_id: MRBTS id of DU
        :param int nrbts_id: NRBTS id of DU
        :return json: prepared DELTA_PLAN
        """
        script_dir = os.path.dirname(__file__)
        abs_path = os.path.join(script_dir, delta_plan)
        delta_file = open(abs_path, "r")
        delta_str = delta_file.read()
        if self._is_release_21b():
            delta_str = delta_str.replace('PMTNLINT-1', 'TNL-1/PMTNL-1')
        delta_str = delta_str.replace('MRBTS-{}', 'MRBTS-{}'.format(mrbts_id))
        delta_str = delta_str.replace('NRBTS-{}', 'NRBTS-{}'.format(nrbts_id))
        delta_file.close()
        delta = json.loads(delta_str)
        logging.debug("DELTA_PLAN for DU prepared (include MRBTS={}, NRBTS={} and software release".format(mrbts_id,
                                                                                                           nrbts_id))
        return delta

    @login_logout
    def _is_release_21b(self, bts_id=0, du_id=0):
        """
        Check if current software release version is '21B'.
        :return bool: is software release version '21B'
        """
        sw_release = self.admin.get_sw_release_name(connection=self.rest_alias.format(bts_id, du_id))
        logging.info("Software release version on DU: {}".format(sw_release))
        return sw_release == '5G21B'
