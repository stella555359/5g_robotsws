# -*- coding: utf-8 -*-
"""
Generic keywords for BTS.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
import os
import time
import logging
from taf.ul.alarms_watchdog import alarms_watchdog
from taf.ul.alarms_watchdog.exceptions import WatchdogNotStarted
from taf.internal.robot_typecasts import time_to_seconds
from taf.internal.sbts.admin.exceptions import \
    AdminApiConnectionClosedException, \
    AdminApiProcedureTimeoutException, \
    AdminApiProcedureFailureException
from testsuite.Bangalore.ORAN.resources.python.\
    Macro.Python.bts.generic_bts import GenericBts, login_logout
from testsuite.Bangalore.ORAN.resources.python.\
    Macro.Python.bts.common.log import GnbLog, EnbLog
from testsuite.Bangalore.ORAN.resources.python.\
    Macro.Python.exceptions import (AlarmIsActive, AlarmIsNotActive,
                                    UnallowedAlarms, AbsentMandatoryAlarms)
from testsuite.Bangalore.ORAN.resources.\
    python.Macro.Python.utilities import get_log_path


class GenericAlarm(GenericBts):
    """Alarm keywords for eNB and gNB"""

    def __init__(self, bts_type, log):
        """
        Constructor of GenericAlarm class.
        """
        super(GenericAlarm, self).__init__(bts_type=bts_type)
        self.log = log
        self.alarms_watcher = None
        self.alarms_log_dir = None
        self.alarm_log_path = None
        self.logs_collection_in_progress = False

    @login_logout
    def verify_alarm_is_active(self, fault_name, bts_id=0, du_id=0):
        """
        Verify alarm is active
        :param fault_name: name of fault
        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: None
        """
        alarms = self.admin.get_active_alarms(
            connection=self.rest_alias.format(bts_id, du_id))
        for alarm in alarms:
            if alarm['faultName'] == fault_name:
                logging.info("Alarm {} is active".format(fault_name))
                return
        raise AlarmIsNotActive("Alarm {} is not active".format(fault_name))

    @login_logout
    def verify_allowed_alarms(self, allowed_alarms, bts_id=0, du_id=0):
        """
        Verify is there unexpected alarms
        :param allowed_alarms: list of allowed alarms
        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: None
        """
        active_alarms = self.admin.get_active_alarms(
            connection=self.rest_alias.format(bts_id, du_id))
        allowed_alarms = [alarm for alarm in allowed_alarms]
        active_alarms = self._remove_and_log_warnings(active_alarms)
        unallowed_alarms = [alarm['faultName'] for alarm in active_alarms
                            if alarm['faultName'] not in allowed_alarms]
        if unallowed_alarms:
            raise UnallowedAlarms("There are not allowed alarms"
                                  " active: {}".
                                  format(unallowed_alarms))
        else:
            logging.info("No or only allowed alarms active")

    def _remove_and_log_warnings(self, active_alarms):
        warnings = [alarm['faultName'] for alarm in active_alarms if
                    alarm['severity'] == 'Warning']
        for warning in warnings:
            logging.warning("`{}` warning is active on BTS".format(warning))
        alarms_without_warnings = [alarm for alarm in active_alarms if
                                   alarm['faultName'] not in warnings]
        return alarms_without_warnings

    @login_logout
    def verify_alarm_is_not_active(self, fault_name, bts_id=0, du_id=0):
        """
        Verify alarm is not active
        :param fault_name: name of fault
        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :return: None
        """
        alarms = self.admin.get_active_alarms(
            connection=self.rest_alias.format(bts_id, du_id))
        for alarm in alarms:
            if alarm['faultName'] == fault_name:
                raise AlarmIsActive("Alarm {} is active".format(fault_name))
        logging.info("Alarm {} is not active".format(fault_name))

    @login_logout
    def verify_mandatory_alarms(self, mandatory_alarms, bts_id=0, du_id=0):
        """
        Verify is there unexpected alarms
        :param mandatory_alarms: list of mandatory alarms
        :param bts_id: ID of BTS
        :param du_id: DU id(Distributed Unit) - id related to Test
         Line configuration - gnb.dus[]
        :return: None
        """
        active_alarms = self.admin.get_active_alarms(
            connection=self.rest_alias.format(bts_id, du_id))
        active_mandatory_alarms = [alarm['faultName'] for alarm in
                                   active_alarms
                                   if alarm['faultName']
                                   in mandatory_alarms]
        absent_mandatory_alarms = [alarm for alarm in mandatory_alarms
                                   if alarm not in active_mandatory_alarms]

        if absent_mandatory_alarms:
            raise AbsentMandatoryAlarms(
                "Some mandatory alarms are not active: {}".format(
                    absent_mandatory_alarms))
        logging.info("All mandatory alarms are active")

    def start_watching_alarms(self, allowed_alarms=None, interval=2.0,
                              bts_id=0, du_id=0):
        """
        Start running alarms watcher.
        :param allowed_alarms: list of allowed faults' names
        :param interval: time interval between consecutive requests to BTS for
         active alarms;
        :param bts_id: ID of gNB. Default 0.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration
        - gnb.dus[]. Default 0.
        :return: None
        """
        self.alarms_watcher = alarms_watchdog()
        allowed_alarms_list = self._create_allowed_alarms(
            allowed_alarms_list=allowed_alarms)
        self.alarms_watcher.watch_alarms(
            allowed_alarms=allowed_alarms_list, interval=interval,
            bts_config=self.get_bts_config(bts_id=bts_id), du_id=du_id)
        self.alarms_log_dir = "{}/ALARMS".format(get_log_path())
        os.makedirs(self.alarms_log_dir)

    def stop_watching_alarms(self, bts_id=0, du_id=0):
        """
        Close watcher thread. Mandatory at the end of test where watcher
        was started.
        :param bts_id: ID of gNB. Default 0.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration
        - gnb.dus[]. Default 0.
        :return: None
        """
        if self.alarms_watcher is None:
            raise Exception(
                "Watching alarms not started - please call "
                "start_watching_alarms")
        try:
            self._create_alarms_log()
            if self.alarms_watcher.has_detected_alarms():
                logging.warning(
                    "Disallowed alarms detected during execution. Check {}".
                    format(self.alarm_log_path))
        except WatchdogNotStarted:
            logging.warning("Alarms watcher is not initialized! "
                            "Disallowed alarms "
                            "are NOT TRACKED! "
                            "Start watching alarms beforehand!")
        except Exception as e:
            logging.warning("Error '{}' occurred while "
                            "creating alarm.log".format(e))
        finally:
            logging.warning("Stop watching alarms")
            self.alarms_watcher.stop_watching_alarms()

    def allow_alarm(self, alarm, bts_id=0, du_id=0):
        """
        Add alarm to allowed alarms for alarms watcher. Run
        start_watching_alarms
         beforehand.
        :param alarm: alarm fault name
        :param bts_id: ID of gNB. Default 0.
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration
        - gnb.dus[]. Default 0.
        :return: None
        """
        self.alarms_watcher.allow_alarm(fault_name=alarm)

    def disallow_alarm(self, alarm, bts_id=0, du_id=0):
        """
        Remove alarm from allowed alarms for alarms watcher. Run
        start_watching_alarms
         beforehand.
        :param alarm: alarm fault name
        :param bts_id: ID of gNB. Default 0.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]. Default 0.
        :return: None
        """
        self.alarms_watcher.disallow_alarm(fault_name=alarm)

    def watch_active_alarms_and_collect_logs_on_unexpected(self,
                                                           trigger_alarms=None,
                                                           bts_id=0, du_id=0):
        """
        Start watcher running in background and collecting logs if
        trigger alarm alarm
         was detected.
        :param trigger_alarms: alarm that triggers logs collection.
                               If None then logs are collected on any
                               disallowed alarm.
                               Default None.
        :param bts_id: ID of gNB. Default 0.
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration
        - gnb.dus[]. Default 0.
        :return: None
        """
        logging.warning("Activate alarms watcher...")
        self.alarms_watcher.run_when_alarm_detected(
            trigger_alarms=trigger_alarms,
            callback=self._callback_for_alarm_watcher, bts_id=bts_id,
            du_id=du_id)

    @login_logout
    def check_if_sw_incompatible_alarm_occurred(self,
                                                awaiting_time=600,
                                                bts_id=0,
                                                du_id=0):
        """
        Check if 'Incompatible SW version detected' alarm occurred.
        :param awaiting_time: Time in seconds to wait for the alarm to occur
        :param bts_id: ID of gNB. Default 0.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration
        - gnb.dus[]. Default 0.
        :return: None
        """
        start_time = time.time()
        while time.time() < start_time + time_to_seconds(time=awaiting_time):
            alarms = self.admin.get_active_alarms(
                connection=self.rest_alias.format(bts_id, du_id))
            bts_statuses = self.admin.get_bts_statuses(
                connection=self.rest_alias.format(bts_id, du_id))
            for alarm in alarms:
                if alarm['faultName'] in ["Incompatible SW version detected",
                                          "No connection to unit"]:
                    logging.info('{} alarm occurred'.
                                 format(alarm['faultName']))
                    return True
            else:
                time.sleep(10)
            if bts_statuses["proceduralState"] == "OnAir":
                return False
        else:
            return False

    @login_logout
    def wait_for_alarm_activation(self, fault_id, awaiting_time=60, bts_id=0,
                                  du_id=0):
        """
        Check if 'Incompatible SW version detected' alarm occurred.
        :param fault_id: Alarm fault ID
        :param awaiting_time: Time in seconds to wait for the alarm activation
        :param bts_id: ID of gNB. Default 0.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
                    configuration - gnb.dus[]. Default 0.
        :return: None
        """

        self.admin.assert_alarm_active(faultId=fault_id, timeout=awaiting_time,
                                       connection=self.rest_alias.format(
                                           bts_id, du_id))

    @login_logout
    def wait_for_alarm_deactivation(self, fault_id, awaiting_time=60,
                                    bts_id=0, du_id=0):
        """
        Check if 'Incompatible SW version detected' alarm occurred.
        :param fault_id: Alarm fault ID
        :param awaiting_time: Time in seconds to wait for the alarm
        deactivation
        :param bts_id: ID of gNB. Default 0.
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration
                     - gnb.dus[]. Default 0.
        :return: None
        """

        self.admin.assert_alarm_inactive(faultId=fault_id,
                                         timeout=awaiting_time,
                                         connection=self.rest_alias.format(
                                             bts_id, du_id))

    @login_logout
    def verify_severity_of_given_alarm(self, alarm_id, alarm_severity,
                                       bts_id=0, du_id=0):
        """
        Checking if specified alarm exists on gNB
        :param alarm_id: ID of the alarm
        :param alarm_severity: severity of alarm
        :param bts_id: id of the BTS
        :param du_id: id of the DU
        :return: None
        """
        alarm_list = self.admin.get_active_alarms(
            connection=self.rest_alias.format(bts_id, du_id))
        alarm = {str(alarm['faultId']): str(alarm_severity)
                 for alarm in alarm_list if
                 alarm['severity'] == str(alarm_severity) and
                 alarm['faultId'] == int(alarm_id)}
        if not alarm:
            raise Exception("Alarm with id {} doesn't exists".format(alarm_id))
        else:
            logging.info("There are existing alarm: {}".format(alarm))

    @login_logout
    def check_if_critical_alarm_exist(self, bts_id=0, du_id=0):
        """
        Checking if any critical alarm exists on gNB
        :param bts_id: id of the BTS
        :param du_id: id of the DU
        :return: None
        """
        alarm_list = self.admin.get_active_alarms(
            connection=self.rest_alias.format(bts_id, du_id))
        critical_alarm_list = [alarm['faultId']
                               for alarm in alarm_list if
                               alarm['severity'] == 'Critical']
        if critical_alarm_list:
            raise Exception("Critical alarms: {}".format(critical_alarm_list))

    def _callback_for_alarm_watcher(self, bts_id=0, du_id=0,
                                    timeout=1200.0, rerun_step=10.0):
        """
        Collect logs when disallowed alarm detected.
        :param timeout: time in seconds callback tries to collect logs
        :param rerun_step: time in seconds between tries
        :param bts_id: ID of gNB. Default 0.
        :param du_id: DU id(Distributed Unit) - id related to Test
                      Line configuration - gnb.dus[]. Default 0.
        :return: None
        """
        if self.logs_collection_in_progress:
            self._write_to_debug_log("Collecting logs already started. "
                                     "Return...")
            return
        else:
            self.logs_collection_in_progress = True
        self._write_to_debug_log("Disallowed alarm is active. "
                                 "Starting callback...")

        start_time = round(time.time(), 1)
        callback_log_dir = "{}/unexpected_alarm{}".format(self.alarms_log_dir,
                                                          start_time)
        logs_collectors = [self.log.collect_ims_log,
                           self.log.collect_im_snapshot,
                           self.log.collect_snapshot]
        while logs_collectors:
            try:
                current_time = round(time.time(), 1)
                if current_time - start_time > timeout:
                    self._write_to_debug_log(
                        "Timeout for logs collection exceeded {}s > {}s".
                        format(current_time - start_time, timeout))
                    break
                self._collect_logs(logs_collectors=logs_collectors,
                                   log_dir=callback_log_dir,
                                   bts_id=bts_id, du_id=du_id)
                if logs_collectors:
                    continue
                self.logs_collection_in_progress = False
                self._write_to_debug_log("Callback was executed successfully")
                break
            except (AdminApiConnectionClosedException,
                    AdminApiProcedureTimeoutException,
                    AdminApiProcedureFailureException) as e:
                self._write_to_debug_log(
                    "Caught exception in callback: {}".format(e))
                time.sleep(rerun_step)

    def _collect_logs(self, logs_collectors, log_dir, bts_id=0, du_id=0):
        """
        Collect set of default logs
        :param log_dir: directory where logs are stored
        :param bts_id: ID of gNB. Default 0.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
                      configuration - gnb.dus[]. Default 0.
        :return: None
        """
        self._write_to_debug_log(
            "Collecting logs using {}".format(logs_collectors))
        for logs_collector in logs_collectors:
            self._write_to_debug_log("start collector {}".
                                     format(logs_collector))
            logs_collector(log_dir=log_dir, bts_id=bts_id, du_id=du_id)
            self._write_to_debug_log(
                "collector finished {}, removing...".format(logs_collector))
            logs_collectors.remove(logs_collector)
        self._write_to_debug_log("Logs collected to: {}".format(log_dir))

    def _create_alarms_log(self):
        """
        Create log file where detected alarms are stored
        :return: None
        """
        detected_alarms = self.alarms_watcher.get_detected_alarms()
        self.alarm_log_path = "{}/alarm.log".format(self.alarms_log_dir)
        with open(self.alarm_log_path, "a+") as f:
            f.writelines(["{}\n".format(repr(alarm))
                          for alarm in detected_alarms])

    def _write_to_debug_log(self, msg):
        """
        Write message to alarms debug log.
        :param msg: string to write into log
        :return: None
        """
        with open(self.alarms_log_dir + "/debug.log", "a+") as dbg:
            dbg.write("{}  |  {}\n".format(time.ctime(), msg))

    def _create_allowed_alarms(self, allowed_alarms_list=[]):
        """
        Create list of alarm objects from list of fault names
        :param allowed_alarms_list: list of allowed faults' names
        :return: None
        """
        return [self.alarms_watcher.create_alarm(fault_name=alarm)
                for alarm in allowed_alarms_list]


class EnbAlarm(GenericAlarm):
    """Class contains Alarm keywords for eNB"""

    bts_type = 'ENB'

    def __init__(self):
        """
        Constructor of Enb class.

        """

        super(EnbAlarm, self).__init__(bts_type=EnbAlarm.bts_type,
                                       log=EnbLog())


class GnbAlarm(GenericAlarm):
    """Class contains Alarm keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.

        """
        super(GnbAlarm, self).__init__(bts_type=GnbAlarm.bts_type,
                                       log=GnbLog())
