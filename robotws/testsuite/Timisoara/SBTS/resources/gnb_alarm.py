# gnb_alarm.py
# gnb_alarm.py

from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
import logging
import signal

# State global pentru Watchdog
_watchdog_state = {
    "inited": False,
    "reportor": None,
    "default_white_list": [
        61652, 4655, 61524, 4654, 7313,
        61649, 7300, 7319, 4459, 4592, 4334
    ]
}


def create_alarm(fault_id):
    """Func?ie helper pentru a crea alarma"""
    return {"fault_id": fault_id}


def run_when_alarm_detected(trigger_alarms=None, callback=None):
    """Func?ie stub pentru callback la alarma"""
    if callback:
        callback()


def raise_detect_unexpected_alarms_error():
    logging.info("Unexpected alarms detected!")


def raise_error_log():
    logging.info("Error log callback!")


def watch_alarms(alarm_list, interval, bts_config, log_dir, **kwargs):
    logging.info(f"Watching alarms: {alarm_list} every {interval} sec on BTS {bts_config}")


def stop_case_execution(sig, frame):
    logging.info("SIGINT received - stopping execution")


def get_data_reportor():
    try:
        return BuiltIn().get_library_instance("RobotCaseInfo")
    except RuntimeError:
        return None


# Initialize reportor
_watchdog_state["reportor"] = get_data_reportor()


@keyword
def init_watchdog(
    allowed_alarms=None,
    interval=2.0,
    bts_config=None,
    log_dir="",
    fail_with_alarms=False,
    **connection_kwargs
):
    if _watchdog_state["inited"]:
        logging.info(
            "Watchdog already started. If you want to restart, please execute teardown_watchdog first"
        )
        return

    log_dir = log_dir or BuiltIn().get_variable_value("${OUTPUT_DIR}")
    alarm_list = []

    # Listeaza alarmele implicite
    for alarm in _watchdog_state["default_white_list"]:
        alarm_list.append(create_alarm(fault_id=str(alarm)))

    # Alarme permise
    if isinstance(allowed_alarms, str):
        for alarm in allowed_alarms.split(","):
            alarm_list.append(create_alarm(fault_id=alarm))
    elif isinstance(allowed_alarms, list):
        alarm_list += allowed_alarms
    elif not allowed_alarms:
        pass
    else:
        raise AttributeError(
            "Wrong allowed_alarms, should be string of alarm ids or list of alarm object."
        )

    # Set port pentru BTS
    if bts_config:
        if bts_config.__class__.__name__ == "ClassicalBts":
            bts_config.cu.oam_http_connection_details.port = 443
        elif bts_config.__class__.__name__ == "CloudBts" and bts_config.dus:
            bts_config.dus[0].oam_http_connection_details.port = 443

    logging.info("Fail with alarms: [{}] {}".format(type(fail_with_alarms), fail_with_alarms))

    if fail_with_alarms is not False:
        run_when_alarm_detected(trigger_alarms=None, callback=raise_detect_unexpected_alarms_error)
        run_when_alarm_detected(trigger_alarms=None, callback=raise_error_log)

    signal.signal(signal.SIGINT, stop_case_execution)

    if bts_config and bts_config.__class__.__name__ == "CloudBts":
        if "du_id" not in connection_kwargs:
            connection_kwargs["du_id"] = 0

    logging.info(connection_kwargs)

    watch_alarms(alarm_list, interval, bts_config, log_dir, **connection_kwargs)

    _watchdog_state["inited"] = True
    if _watchdog_state["reportor"]:
        _watchdog_state["reportor"].use_watchdog = True
        _watchdog_state["reportor"].enable_watchdog = fail_with_alarms is not False


@keyword
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


def allow_alarm(
    alarm_id=None,
    fault_id=None,
    fault_name=None,
    hw_path=None,
    severity=None,
    reason=None,
    unit_path=None,
    impacted_cells_count=None,
):
    logging.info(f"Allowed alarm: {alarm_id}, fault: {fault_id}")


@keyword
def add_allow_alarms(
    alarm_id=None,
    fault_id=None,
    fault_name=None,
    hw_path=None,
    severity=None,
    reason=None,
    unit_path=None,
    impacted_cells_count=None,
):
    if not _watchdog_state["inited"]:
        logging.info("Alarm watchdog not inited, please execute init_watchdog first.")
        return

    if isinstance(alarm_id, list):
        for alarm in alarm_id:
            allow_alarm(
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
            allow_alarm(
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
        allow_alarm(
            alarm_id=alarm_id,
            fault_id=fault_id,
            fault_name=fault_name,
            hw_path=hw_path,
            severity=severity,
            reason=reason,
            unit_path=unit_path,
            impacted_cells_count=impacted_cells_count,
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
# @staticmethod
# def raise_detect_unexpected_alarms_error():
#     _thread.interrupt_main()
# @keyword
# def raise_error_log(self):
#     alarms = self.get_detected_alarms()
#     if alarms:
#         raise DisallowedAlarmsDetected("Not allowed alarms: {}".format(alarms))


@keyword
def log_detected_alarms(self):
    alarms = self.get_detected_alarms()
    if alarms:
        logging.warning("Detected alarms: {}".format(alarms))
    if self.reportor:
        self.reportor.add_watchdog_alarms(alarms, self.get_allowed_alarms())
# @keyword
# def _stop_case_execution(self, signum, frame):
#     alarms = self.get_detected_alarms()
#     raise AssertionError("Fail case as unexpected alarm detected. {}".format(alarms))
# CASE_SPECIFIC_ALLOWED_ALARMS = {
#     # "TA case name": [fault_id],
#     "5GC001576-AA_5GC000158_006_Multiple_QSFP_CABLINKs_And_Check_Rate": [4340],
#     "5GC002361_A_AZNA_General_SiSo_RF_alarms_without_recovery": [6450],
#     "5GC002361_A_AZNA_General_SiSo_RF_alarms_with_recovery": [6450],
#     "5GC000430-A_01_05_Kylin_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise": [
#         6450
#     ],
#     "5GC000430-B_01_05_Amber_Fault_4308_EFaultId_MdtxConfigurationFailureAl_raise": [
#         6450
#     ],
#     "CB006081-5G-BB_AEQY_Auto_Automatic_RAT_SW_upgrade": [6450],
#     "5GC001752_007_Startup_View_is_Auto-opening_by_the_BTS_EM_Application": [7300],
# }
#
# ALLOWED_ACTIVE_ALARMS = [
#     61652,
#     61524,
#     61649,
#     9000,
#     4592,
#     4527,
#     1932,
#     4334,
#     61074,
#     61618,
#     4654,
#     4687,
#     4655,
# ]
#
# ALLOWED_HISTORY_ALARMS = [
#     61652,
#     61524,
#     61649,
#     9000,
#     4592,
#     4527,
#     1932,
#     4334,
#     61074,
#     61618,
#     7319,
#     7300,
# ] + ALLOWED_ACTIVE_ALARMS


@keyword
class GnbAlarmAnalyzer(object):
    def __init__():
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


def check_pm_counters(self, counter_name):
    """
    Exemplu de keyword pentru verificarea PM counters.
    :param counter_name: numele counterului de verificat
    :return: mesaj de confirmare
    """
    # Aici po?i pune logica reala de verificare
    if counter_name in self.bts_config:
        return f"Counter {counter_name} exista ?i are valoarea {self.bts_config[counter_name]}"
    else:
        return f"Counter {counter_name} nu a fost gasit în configurare."


@keyword
def check_pm_counters(counter_name):
    """
    Verifica PM counters.
    """
    bts_config = _watchdog_state.get("bts_config") or {}
    if bts_config and counter_name in bts_config:
        return f"Counter {counter_name} exista ?i are valoarea {bts_config[counter_name]}"
    return f"Counter {counter_name} nu a fost gasit."


@keyword
def list_all_counters():
    """
    Returneaza lista tuturor counter-elor din configurare.
    """
    bts_config = _watchdog_state.get("bts_config") or {}
    return list(bts_config.keys())


@keyword
def list_all_counters(self):
    """
    Returneaza lista tuturor counter-elor din configurare.
    """
    return list(self.bts_config.keys())
