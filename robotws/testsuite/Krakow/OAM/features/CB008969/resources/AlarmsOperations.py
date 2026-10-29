"""
Keywords for Feature CB008969: Handle alarms related to the feature.

:author: Jaroslaw Lezon, Arkadiusz Kowalczyk
:contact: jaroslaw.lezon@nokia.com

"""
import logging
import time
from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout
from test_specific_keywords import strip_date
from test_specific_keywords import get_availability_status_of_cell


class AlarmNotFound(Exception):
    pass


class WrongAlarmDescription(Exception):
    pass


class WrongAlarmTimestamp(Exception):
    pass


class AlarmsOperations(GenericBts):
    dl_first = "DL: link down; UL: link down"
    ul_first = "UL: link down; DL: link down"

    def _get_alarm_timestamp(self, actual_alarm_description):
        first_side_alarm_timestamp, second_side_alarm_timestamp = None, None
        ul_timestamp, dl_timestamp = None, None
        for key in actual_alarm_description.keys():
            if key == "btsObservationTime":
                first_side_alarm_timestamp = actual_alarm_description[key]
            if key == "btsLastUpdateTime":
                second_side_alarm_timestamp = actual_alarm_description[key]
            elif key == "supplAlarmInfo":
                logging.info("Supplementary info of the alarm: {}".format(actual_alarm_description[key]))
                if self.dl_first == actual_alarm_description[key]:
                    dl_timestamp = first_side_alarm_timestamp
                    ul_timestamp = second_side_alarm_timestamp
                elif self.ul_first == actual_alarm_description[key]:
                    ul_timestamp = first_side_alarm_timestamp
                    dl_timestamp = second_side_alarm_timestamp
                else:
                    raise WrongAlarmDescription("Got {} in {} parameter of alarm description.".format(
                        actual_alarm_description[key], key))
        logging.info("DL timestamp: {} UL timestamp: {}".format(dl_timestamp, ul_timestamp))
        return dl_timestamp, ul_timestamp

    def _is_fault_in_list(self, fault_id, alarm_list, check_suppl_info=True):
        """
        Checks if specified fault_id entry is present in alarms list
        :param fault_id: faultId expected in list, type: int
        :param alarm_list: alarm list which can be retrieved using admin api, type: list
        :return alarm_def: description of found alarm, type: dict
        """

        for alarm_def in alarm_list:
            if check_suppl_info:
                condition = alarm_def.get('faultId') == int(fault_id) \
                            and (alarm_def.get('supplAlarmInfo') == self.dl_first
                                 or alarm_def.get('supplAlarmInfo') == self.ul_first)
            else:
                condition = alarm_def.get('faultId') == int(fault_id)
            if condition:
                logging.info("Alarm found! Description: {}".format(alarm_def))
                return alarm_def
        raise AlarmNotFound("Fault {} not found on BTS!".format(fault_id))

    def _validate_alarm_description(self, alarm_description, link_id, cell_availability_status):
        """
        Check if triggered alarm description matches the expected one.
        :param alarm_description: description of found alarm, type: dict
        :param link_id: ID of the broken link, type: int
        :param cell_availability_status: indication availability status of cell, type: string
        """
        if cell_availability_status.lower() == "degraded":
            alarm_id = 7100
            severity = "Major"
        else:
            alarm_id = 7115
            severity = "Minor"
        expected_alarm_info = {
            "faultId": 4741,
            "alarmId": int("{}".format(alarm_id)),
            "severity": "{}".format(severity),
            'hwPath': '/SMOD_R-1/BBMOD_R-1(Left_Bottom)/s_rf{}'.format(link_id),
        }
        for key in alarm_description.keys():
            if key in expected_alarm_info.keys():
                if not alarm_description[key] == expected_alarm_info[key]:
                    raise WrongAlarmDescription("Expected {}, got {} in {} parameter of alarm description.".format(
                        expected_alarm_info[key], alarm_description[key], key))
                else:
                    logging.info("Actual and expected alarm description match!: {} - {}".format(
                        key, expected_alarm_info[key]))

    @login_logout
    def verify_that_fault_is_present_in_alarms_history(self, dl_timestamp=None, ul_timestamp=None,
                                                       interval=10, fault_id=4741, bts_id=0, du_id=0):
        """
        Verifies if specified alarmId faultId pair is present in active alarms set
        :param dl_timestamp: timestamp of triggered alarm in DL.
        :param ul_timestamp: timestamp of triggered alarm in UL.
        :param interval: defined measurement window. type: int
        :param fault_id: faultId expected not to appear in activate alarms, type: int
        :param bts_id: default BTS id, type: int
        :param du_id: default DU id, type: int
        """
        historic_alarms = self.admin.get_historic_alarms(connection=self.rest_alias.format(bts_id, du_id), timeout=120)
        logging.info("Historic alarms: {}".format(historic_alarms))
        self._is_fault_in_list(fault_id, historic_alarms, check_suppl_info=False)
        latest_alarm_timestamp = max(strip_date(dl_timestamp), strip_date(ul_timestamp))
        latest_alarm_clear_timestamp = historic_alarms[-1].get('clearedTime')
        latest_alarm_clear_timestamp = strip_date(latest_alarm_clear_timestamp)
        difference = divmod((latest_alarm_clear_timestamp - latest_alarm_timestamp).total_seconds(), 60)
        difference_minutes = int(difference[0])
        difference_seconds = int(difference[1])
        logging.info("Fault was triggered at {} minute. Fault was cleared at {} minute".format(
            latest_alarm_timestamp.minute, latest_alarm_clear_timestamp.minute))
        if (difference_minutes == interval and difference_seconds < 30) or (difference_minutes == interval - 1 and
                                                                            difference_seconds > 30):
            logging.info("DL fault triggered at {} and UL fault triggered at {} were correctly cleared. "
                         "Fault was cleared at {}. Difference is {} minutes and {} seconds".format(
                          dl_timestamp, ul_timestamp, latest_alarm_clear_timestamp, difference_minutes,
                          difference_seconds))
        else:
            raise WrongAlarmTimestamp("DL fault triggered at {} and UL fault triggered at {} were wrongly cleared. "
                                      "Fault was cleared at {}. Difference is {} minutes and {} seconds".format(
                                       dl_timestamp, ul_timestamp, latest_alarm_clear_timestamp, difference_minutes,
                                       difference_seconds))

    @login_logout
    def verify_that_fault_is_not_present_in_active_alarms(self, fault_id=4741, bts_id=0, du_id=0):
        """
        Verifies if specified alarmId faultId pair is present in active alarms set
        :param fault_id: faultId expected not to appear in activate alarms, type: int
        :param bts_id: default BTS id, type: int
        :param du_id: default DU id, type: int
        """
        try:
            self._is_fault_in_list(fault_id, self.admin.get_active_alarms(connection=self.rest_alias.
                                                                          format(bts_id, du_id)))
        except AlarmNotFound:
            logging.info("Fault {} is not found on BTS!".format(fault_id))

    @login_logout
    def wait_for_fault(self, link_id, fault_id=4741, get_timestamp=True, poll_interval=3, timeout=10,
                       bts_id=0, du_id=0, cell_id=1):
        """
        Waits until given alarm is raised or timeout occurs
        :param link_id: ID of the broken link, type: int
        :param fault_id: awaited faultId, type: int
        :param get_timestamp: indication if in this run it is necessary to  collect alarms timestamp, type: bool
        :param poll_interval: time intervals for checking if alarm is present, type: int
        :param timeout: time in minutes after which waiting will stop, type: int
        :param bts_id: default BTS id, type: int
        :param du_id: default DU id, type: int
        :param cell_id: default cell id, type: int
        :return: dl_timestamp, ul_timestamp: timestamps of triggered alarms
        """
        timeout = timeout * 60
        start = time.time()
        while True:
            alarms_list = self.admin.get_active_alarms(connection=self.rest_alias.format(bts_id, du_id))
            if time.time() - start > timeout:
                raise AlarmNotFound("Fault {} not found on BTS during {}s timeout!".format(
                    fault_id, timeout))
            try:
                alarm_description = self._is_fault_in_list(fault_id, alarms_list)
                cell_availability_status = get_availability_status_of_cell(bts_id, du_id, cell_id)
                self._validate_alarm_description(alarm_description, link_id, cell_availability_status)
                if not get_timestamp:
                    break
                else:
                    dl_timestamp, ul_timestamp = self._get_alarm_timestamp(alarm_description)
                    return dl_timestamp, ul_timestamp
            except AlarmNotFound:
                logging.info("Fault not found. Still waiting...")
            time.sleep(poll_interval)
