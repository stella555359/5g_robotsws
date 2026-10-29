"""
Keywords related to alarms handling.

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""
from typing import List, Any

from taf.rfrl.bts.alarms.classical_alarms_definition import CLASSICAL_FAULT_7311, CLASSICAL_FAULT_7307
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.procedures.resources.python.common_allowed_alarms import get_variables
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword
from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_suite_variable
from taf.rfrl.utilities.logger import custom_logger as logger

from .variables.common import NUM_BTS_DEVICES


class Alarms:

    def __init__(self):
        self.prep_log_dir = get_builtin_value("LOG_PATH") + '/preparation'
        self.test_log_dir = get_builtin_value("LOG_PATH") + '/test_exe_alarms'

    @log_as_robot_keyword
    def watch_alarms_during_test(self):
        alarm_variables = get_and_set_alarm_variables()
        self.start_watching_alarms_for_all_btses(allowed_alarms=alarm_variables['allowed_alarms'],
                                                 log_dir=self.test_log_dir)

    @log_as_robot_keyword
    def watch_alarms_during_tl_prep(self):
        alarm_variables = get_and_set_alarm_variables()
        nrdc_prep_allowed_alarms = [CLASSICAL_FAULT_7311, CLASSICAL_FAULT_7307]
        prep_allowed_alarms = alarm_variables['ALLOWED_ALARMS_DURING_TL_PREPARATION'] + nrdc_prep_allowed_alarms
        self.start_watching_alarms_for_all_btses(allowed_alarms=prep_allowed_alarms,
                                                 log_dir=self.prep_log_dir)

    @log_as_robot_keyword
    def start_watching_alarms_for_all_btses(self, allowed_alarms: List[Any] = None,
                                            interface: str = 'mplane',
                                            log_dir: str = None):
        logger.log_info_to_console(f"Starting to watch alarms on all BTSes")
        for bts_id in range(NUM_BTS_DEVICES):
            GnbAlarmVerification().start_watching_alarms(
                allowed_alarms=allowed_alarms,
                interface=interface,
                bts_id=bts_id,
                log_dir=log_dir
            )

    @log_as_robot_keyword
    def stop_watching_alarms_for_all_btses(self):
        logger.log_info_to_console(f"Stopping to watch alarms on all BTSes")
        for bts_id in range(NUM_BTS_DEVICES):
            GnbAlarmVerification().stop_watching_alarms(bts_id=bts_id)


@log_as_robot_keyword
def get_and_set_alarm_variables(custom_allowed_alarms: List[Any] | None = None) -> dict[Any, Any]:
    """
    Retrieves alarm-related variables and sets them as suite variables.

    :param custom_allowed_alarms: list of custom allowed alarms
    :return: Dictionary containing alarm configuration variables.
    """
    alarm_variables = get_variables()
    set_robot_suite_variable('CUSTOM_ALLOWED_ALARMS', custom_allowed_alarms)
    set_robot_suite_variable('allowed_alarms', alarm_variables['allowed_alarms'])
    set_robot_suite_variable('ASIR_ALLOWED_ALARMS', alarm_variables['ASIR_ALLOWED_ALARMS'])
    return alarm_variables
