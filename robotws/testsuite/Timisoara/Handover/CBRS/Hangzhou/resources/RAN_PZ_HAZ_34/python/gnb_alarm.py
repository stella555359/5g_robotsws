# -*- coding:utf-8 -*-
"""
:copyright: Nokia Networks
:author: Civen Chen
:contact: civen.chen@nokia-sbell.com
"""
import logging
import _thread
import signal
from taf.ul.alarms_watchdog.exceptions import DisallowedAlarmsDetected
from taf.ul.alarms_watchdog import alarms_watchdog
from robot.libraries.BuiltIn import BuiltIn

__all__ = [
    "GnbAlarmAnalyzer",
    "AlarmWatchdog",
    "CASE_SPECIFIC_ALLOWED_ALARMS",
    "ALLOWED_ACTIVE_ALARMS",
    "ALLOWED_HISTORY_ALARMS",
]


class AlarmWatchdog(alarms_watchdog):
    """
    Resources    /resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

    *** Variables ***

    *** Test Cases ***
    Example Case
        # Watchdog monitoring start from here to the teardown.
        [Setup]   Case Setup
        # If any alarm not in whitelist being detected when this step is executing, this keyword will fail.
        Case Step
        # Update whitelist before Step2
        AlarmWatchdog.add_allow_alarms    fault_id=10
        # If any alarm not in whitelist being detected when this step is executing, this keyword will fail.
        Case Step2
        # Remove added 10 from whitelist after Step2
        AlarmWatchdog.remove_allow_alarms    fault_id=10
        # If any alarm not in whitelist being detected when this step is executing, this keyword will fail.
        Case Step3
        # Watchdog monitoring stop here.
        [Teardown]    Case Teardown

    *** Keywords ***
    Case Setup
        [Arguments]    ${gnb_index}=0
        robot_common_operations.Common Case Setup
        ...    gnb_index=${gnb_index}
        ...    allowed_faults_ids=7107,7108
        # If there will be alarm before Watchdog initialization due to Testing requirement,
        # alarm can be init into allowed_faults_ids
        # And after this step executed, the watchdog will monitor the alarms once/5 sec.
        # Any alarm not in whitelist will be detected and logged,
        # Alarmwatchdog will automatically raise an Error at Robot Case executing step to try to fail case.

    Case Teardown
        [Arguments]
        robot_common_operations.Common Case Teardown
    """

    def __init__(self):
        super(AlarmWatchdog, self).__init__()
        self._default_white_list_ = [
            61652,
            4655,
            61524,
            4654,
            7313,
            61649,
            7300,
            7319,
            4459,
            4592,
            4334
        ]
        self.inited = False
        self.reportor = self.get_data_reportor()

    @staticmethod
    def get_data_reportor():
        try:
            return BuiltIn().get_library_instance("RobotCaseInfo")
        except RuntimeError:
            pass

    def init_watchdog(
        self,
        allowed_alarms=None,
        interval=2.0,
        bts_config=None,
        log_dir="",
        fail_with_alarms=False,
        **connection_kwargs
    ):
        if self.inited:
            logging.info(
                "Watchdog already started. If you want to restart, please execute teardown_watchdog first"
            )
        else:
            log_dir = log_dir or BuiltIn().get_variable_value("${OUTPUT_DIR}")
            alarm_list = []
            for alarm in self._default_white_list_:
                alarm_list.append(self.create_alarm(fault_id=str(alarm)))
            if isinstance(allowed_alarms, str):
                for alarm in allowed_alarms.split(","):
                    alarm_list.append(self.create_alarm(fault_id=alarm))
            elif isinstance(allowed_alarms, list):
                alarm_list += allowed_alarms
            elif not allowed_alarms:
                pass
            else:
                raise AttributeError(
                    "Wrong allowed_alarms, should be string of alarm ids or list of alarm object."
                )
            if bts_config.__class__.__name__ == "ClassicalBts":
                bts_config.cu.oam_http_connection_details.port = 443
            elif bts_config.__class__.__name__ == "CloudBts" and bts_config.dus:
                bts_config.dus[0].oam_http_connection_details.port = 443
            logging.info(
                "Fail with alarms: [{}] {}".format(type(fail_with_alarms), fail_with_alarms)
            )
            if fail_with_alarms is not False:
                self.run_when_alarm_detected(
                    trigger_alarms=None, callback=self.raise_detect_unexpected_alarms_error
                )
                self.run_when_alarm_detected(
                    trigger_alarms=None, callback=self.raise_error_log
                )
            signal.signal(signal.SIGINT, self._stop_case_execution)
            if bts_config.__class__.__name__ == "CloudBts":
                if "du_id" not in connection_kwargs:
                    connection_kwargs["du_id"] = 0
            logging.info(connection_kwargs)
            self.watch_alarms(
                alarm_list, interval, bts_config, log_dir, **connection_kwargs
            )
            self.inited = True
            if self.reportor:
                self.reportor.use_watchdog = True
                self.reportor.enable_watchdog = fail_with_alarms is not False

    def teardown_watchdog(self):
        try:
            self.log_detected_alarms()
        except Exception as err:
            logging.warning(err)
        try:
            self.stop_watching_alarms()
        except Exception as err:
            logging.warning(err)
        self.inited = False

    def add_allow_alarms(
        self,
        alarm_id=None,
        fault_id=None,
        fault_name=None,
        hw_path=None,
        severity=None,
        reason=None,
        unit_path=None,
        impacted_cells_count=None,
    ):
        if self.inited:
            if isinstance(alarm_id, list):
                for alarm in alarm_id:
                    self.allow_alarm(
                        alarm_id=alarm,
                        fault_id=fault_id,
                        fault_name=fault_name,
                        hw_path=hw_path,
                        severity=severity,
                        reason=reason,
                        unit_path=unit_path,
                        impacted_cells_count=impacted_cells_count,
                    )
            elif isinstance(fault_id, list):
                for fault in fault_id:
                    self.allow_alarm(
                        alarm_id=alarm_id,
                        fault_id=fault,
                        fault_name=fault_name,
                        hw_path=hw_path,
                        severity=severity,
                        reason=reason,
                        unit_path=unit_path,
                        impacted_cells_count=impacted_cells_count,
                    )
            else:
                self.allow_alarm(
                    alarm_id,
                    fault_id,
                    fault_name,
                    hw_path,
                    severity,
                    reason,
                    unit_path,
                    impacted_cells_count,
                )
        else:
            logging.info(
                "Alarm watchdog not inited, please execute init_watchdog first."
            )

    def remove_allow_alarms(
        self,
        alarm_id=None,
        fault_id=None,
        fault_name=None,
        hw_path=None,
        severity=None,
        reason=None,
        unit_path=None,
        impacted_cells_count=None,
    ):
        if self.inited:
            if isinstance(alarm_id, list):
                for alarm in alarm_id:
                    self.disallow_alarm(
                        alarm_id=alarm,
                        fault_id=fault_id,
                        fault_name=fault_name,
                        hw_path=hw_path,
                        severity=severity,
                        reason=reason,
                        unit_path=unit_path,
                        impacted_cells_count=impacted_cells_count,
                    )
            elif isinstance(fault_id, list):
                for fault in fault_id:
                    self.disallow_alarm(
                        alarm_id=alarm_id,
                        fault_id=fault,
                        fault_name=fault_name,
                        hw_path=hw_path,
                        severity=severity,
                        reason=reason,
                        unit_path=unit_path,
                        impacted_cells_count=impacted_cells_count,
                    )
            else:
                self.disallow_alarm(
                    alarm_id,
                    fault_id,
                    fault_name,
                    hw_path,
                    severity,
                    reason,
                    unit_path,
                    impacted_cells_count,
                )
        else:
            logging.info(
                "Alarm watchdog not inited, please execute init_watchdog first."
            )

    @staticmethod
    def raise_detect_unexpected_alarms_error():
        _thread.interrupt_main()

    def raise_error_log(self):
        alarms = self.get_detected_alarms()
        if alarms:
            raise DisallowedAlarmsDetected("Not allowed alarms: {}".format(alarms))

    def log_detected_alarms(self):
        alarms = self.get_detected_alarms()
        if alarms:
            logging.warning("Detected alarms: {}".format(alarms))
        if self.reportor:
            self.reportor.add_watchdog_alarms(alarms, self.get_allowed_alarms())

    def _stop_case_execution(self, signum, frame):
        alarms = self.get_detected_alarms()
        raise AssertionError("Fail case as unexpected alarm detected. {}".format(alarms))


CASE_SPECIFIC_ALLOWED_ALARMS = {
    # "TA case name": [fault_id],
    "5GC001576-AA_5GC000158_006_Multiple_QSFP_CABLINKs_And_Check_Rate": [4340],
    "5GC002361_A_AZNA_General_SiSo_RF_alarms_without_recovery": [6450],
    "5GC002361_A_AZNA_General_SiSo_RF_alarms_with_recovery": [6450],
    "5GC000430-A_01_05_Kylin_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise": [
        6450
    ],
    "5GC000430-B_01_05_Amber_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise": [
        6450
    ],
    "CB006081-5G-BB_AEQY_Auto_Automatic_RAT_SW_upgrade": [6450],
    "5GC001752_007_Startup_View_is_Auto-opening_by_the_BTS_EM_Application": [7300],
}

ALLOWED_ACTIVE_ALARMS = [
    61652,
    61524,
    61649,
    9000,
    4592,
    4527,
    1932,
    4334,
    61074,
    61618,
    4654,
    4687,
    4655,
]

ALLOWED_HISTORY_ALARMS = [
    61652,
    61524,
    61649,
    9000,
    4592,
    4527,
    1932,
    4334,
    61074,
    61618,
    7319,
    7300,
] + ALLOWED_ACTIVE_ALARMS


class GnbAlarmAnalyzer(object):
    def __init__(self):
        self.allowed_alarms = []
        self.case_specific_allowed = []
        self.unexpected_alarms = []

    def analysis_active_alarms(self, alarms, case_name):
        logging.info("Analyze Alarms from case: {}".format(case_name))
        for alarm in alarms:
            alarm_id = alarm["faultId"]
            if alarm_id in ALLOWED_ACTIVE_ALARMS:
                self.allowed_alarms.append(alarm_id)
                logging.info("Add alarm {} into allowed alarms list.".format(alarm_id))
            elif case_name.split(r"]")[-1] in CASE_SPECIFIC_ALLOWED_ALARMS:
                if alarm_id in CASE_SPECIFIC_ALLOWED_ALARMS[case_name]:
                    self.case_specific_allowed.append(alarm_id)
                    logging.info(
                        "Add alarm {} into case allowed alarms list.".format(alarm_id)
                    )
                else:
                    self.unexpected_alarms.append(alarm_id)
                    logging.info(
                        "Add alarm {} into unexpected alarms list.".format(alarm_id)
                    )
            else:
                self.unexpected_alarms.append(alarm_id)
                logging.info(
                    "Add alarm {} into unexpected alarms list.".format(alarm_id)
                )
        return self.allowed_alarms, self.case_specific_allowed, self.unexpected_alarms

    def analysis_history_alarms(self, alarms, case_name):
        logging.info("Analyze History Alarms from case: {}".format(case_name))
        for alarm in alarms:
            alarm_id = alarm["faultId"]
            if alarm_id in ALLOWED_HISTORY_ALARMS:
                self.allowed_alarms.append(alarm_id)
                logging.info("Add alarm {} into allowed alarms list.".format(alarm_id))
            elif case_name.split(r"]")[-1] in CASE_SPECIFIC_ALLOWED_ALARMS:
                if alarm_id in CASE_SPECIFIC_ALLOWED_ALARMS[case_name]:
                    self.case_specific_allowed.append(alarm_id)
                    logging.info(
                        "Add alarm {} into case allowed alarms list.".format(alarm_id)
                    )
                else:
                    self.unexpected_alarms.append(alarm_id)
                    logging.info(
                        "Add alarm {} into unexpected alarms list.".format(alarm_id)
                    )
            else:
                self.unexpected_alarms.append(alarm_id)
                logging.info(
                    "Add alarm {} into unexpected alarms list.".format(alarm_id)
                )
        return self.allowed_alarms, self.case_specific_allowed, self.unexpected_alarms
