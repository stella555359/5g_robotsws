"""
Operations on gNB alarm.

:copyright: Nokia Networks
:author: Rafal Kawa
:contact: rafal.kawa@nokia.com
:maintainer: rafal.kawa@nokia.com
"""

import logging
import re
from typing import List, Literal

from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.devices.exceptions import AlarmIsNotActive
from taf.rfrl.bts.devices.generic_bts import login_logout
from taf.ul.alarms_watchdog import Alarm


class AlarmKeywords(GnbAlarmVerification):
    """
    Keywords for gNB alarm verification.

    This class extends the GnbAlarmVerification class to provide additional functionalities.
    """

    def __init__(self):
        """
        Initializes the AlarmKeywords class.
        """
        super(AlarmKeywords, self).__init__()

    @login_logout
    def check_fault_alarming_object(self, fault_name, re_object_pattern, object_type='runtime', bts_id=0, du_id=0):
        """
        Checks for a fault alarming object.

        This method verifies if a specific fault is active and matches the given alarming object pattern.

        Args:
            fault_name (str): The name of the fault to check.
            re_object_pattern (str): The regex pattern to match the alarming object.
            object_type (str, optional): The type of the object. One of ["internal", "configuration", "runtime"].
            Defaults to "runtime".
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.

        Raises:
            AlarmIsNotActive: If the fault is not found among active alarms.
        """
        _re_alarm = re.compile(fault_name, re.I)
        expected_alarms = [alarm for alarm in
                           self.admin.get_active_alarms(connection=self.rest_alias.format(bts_id, du_id)) if
                           _re_alarm.search(alarm['faultName'])]
        if expected_alarms:
            self._verify_alarming_object(expected_alarms, re_object_pattern, object_type)
        else:
            raise AlarmIsNotActive(f"Not found '{fault_name}' among 'GNB{bts_id}' active alarms.")

    @login_logout
    def verify_if_expected_faults_exist(self, fault_names: List[str], mode: Literal["all", "any"] = "all",
                                        bts_id: int = 0, du_id: int = 0, timeout: int = 30) -> List[Alarm]:
        """
        Verifies if expected faults exist among active alarms. Two modes of verification are supported:
        "all" - all expected faults from fault_names list must be found among active alarms,
        "any" - at least one expected fault from fault_names list must be found among active alarms.

        Args:
            fault_names (List[str]): A list of fault names to check, e.g. ["TX out of order"]
            mode (Literal["all", "any"], optional): The verification mode. Defaults to "all".
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            timeout (int, optional): The timeout for the operation. Defaults to 30.

        Returns:
            List[Alarm]: A list of detected alarms that match the expected fault names,
                         e.g., [Alarm(fault_name=TX out of order, ...)].

        Raises:
            AlarmIsNotActive: If the expected faults are not found among active alarms.
        """
        active_alarms_converted = self._convert_to_alarms_objects(
            self.admin.get_active_alarms(connection=self.rest_alias.format(bts_id, du_id), timeout=timeout)
        )
        detected_alarms = [
            alarm for alarm in self._convert_to_alarms_objects(fault_names) if alarm in active_alarms_converted
        ]

        if mode == "all" and len(detected_alarms) != len(fault_names):
            raise AlarmIsNotActive(
                f"Not found all of the expected faults '{fault_names}' among 'GNB{bts_id}' active alarms: "
                f"'{active_alarms_converted}'"
            )
        elif mode == "any" and not detected_alarms:
            raise AlarmIsNotActive(
                f"Not found any of expected faults '{fault_names}' among 'GNB{bts_id}' active alarms: "
                f"'{active_alarms_converted}'"
            )
        return detected_alarms

    @staticmethod
    def _verify_alarming_object(alarms, object_pattern, object_type):
        """
        Verifies the alarming object.

        This method checks if the alarming object matches the given pattern.

        Args:
            alarms (list): The list of active alarms.
            object_pattern (str): The regex pattern to match the alarming object.
            object_type (str): The type of the object.

        Raises:
            AlarmIsNotActive: If the alarming object pattern does not match any active alarms.
        """
        _re_obj = re.compile(object_pattern, re.I)
        alarming_object = [alarm['alarmingObjectIds'][0][object_type] for alarm in alarms if
                           _re_obj.search(alarm['alarmingObjectIds'][0][object_type])]
        if alarming_object:
            logging.info(f"Found '{object_type}' alarming object pattern '{object_pattern}' "
                         f"in '{len(alarming_object)}' alarmingObjectIds: '{alarming_object}' "
                         f"of active alarms:\n'{alarms}'.")
        else:
            raise AlarmIsNotActive(f"Not matched given '{object_type}' alarming object pattern '{object_pattern}' "
                                   f"among alarmingObjectIds of active alarms:\n'{alarms}'.")
