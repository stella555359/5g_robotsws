import logging

from taf.rfrl.bts.devices.asir.generic_asir import login_logout
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.exceptions import AlarmIsActive, AlarmIsNotActive


class asir_keywords(GnbAsirHubOperations):

    @login_logout
    def verify_any_alarm_is_active(self, fault_ids, bts_id=0):
        """
        Verify if any of alarm is active via ASIR-WebEM

        :param List fault_ids: List of fault indexes to be checked
        :param int bts_id: BTS id - related to Test Line configuration, default: 0
        :return: None
        """
        confirmed_fault_ids = self._check_which_alarms_exist(fault_ids=fault_ids)
        if confirmed_fault_ids:
            logging.info("Alarms with id {} are active".format(confirmed_fault_ids))
        else:
            raise AlarmIsNotActive("Any of alarms with id {} are not active".format(fault_ids))

    @login_logout
    def verify_any_alarms_are_not_active(self, fault_ids, bts_id=0):
        """
        Verify if any of alarms are not active via ASIR-WebEM

        :param List fault_ids: List of fault indexes to be checked
        :param int bts_id: BTS id - related to Test Line configuration, default: 0
        :return: None
        """
        confirmed_fault_ids = self._check_which_alarms_exist(fault_ids=fault_ids)
        if not confirmed_fault_ids:
            logging.info("Any of alarms with id {} are not active".format(fault_ids))
        else:
            raise AlarmIsActive("Alarms with id {} are active".format(confirmed_fault_ids))

    def _check_which_alarms_exist(self, fault_ids, bts_id=0):
        """
        Compare active ASIR-WebEM alarms with delivered alarms by Id of fault.

        :param List fault_ids: List of fault indexes to be checked
        :param int bts_id: BTS id - related to Test Line configuration, default: 0
        :return: List confirmed_alarm_ids: list of those fault indexes from given, that are currently active
        """
        active_alarms = self._perform_asir_operation(self.asir.get_active_alarms)
        confirmed_alarm_ids = [alarm["fault_id"] for alarm in active_alarms if alarm["fault_id"] in fault_ids]
        return confirmed_alarm_ids
