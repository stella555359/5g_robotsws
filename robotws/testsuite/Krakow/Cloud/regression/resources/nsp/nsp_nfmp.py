"""
NSP NFM-P operations

:copyright: Nokia Networks
:author: Lukasz Skoczylas, Grzegorz Hajto
:contact: lukasz.skoczylas@nokia.com, grzegorz.hajto@nokia.com
"""

import time
import os
import logging
from nsp_xml_api import NspXmlApi
from pprint import pformat


class NspNfmpException(Exception):
    """Exception class for problems during NSP NFM-P operations"""


class NspNfmp(object):
    """NSP NFM-P operations"""
    def __init__(self, ip, username, password, port=8443):
        """
        NSP NFM-P constructor
        :param ip: (str) NSP server ip address
        :param username: (str) username with XML-Api rights
        :param password: (str) password
        :param port: (int) XML-Api port, default 8443
        """
        self.nsp_api = NspXmlApi(ip, username, password, port)

    def activate_workorder(self, work_order_filename):
        """
        Activate workorder file with configuration changes in managed network
        :param work_order_filename: (str) Workorder file name
        """
        logging.info("Activating workorder: {0}".format(work_order_filename))
        session_fdn = None
        try:
            session_fdn = self.nsp_api.create_activation_session()
            logging.debug("Activation session: {0}".format(session_fdn))
            self.nsp_api.scan_workorder_repo()
            wait_for_synchronization()
            work_order_id = self._get_work_order_id(work_order_filename)
            self.nsp_api.add_wo_to_session(work_order_id, session_fdn)
            wait_for_synchronization()
            self.nsp_api.start_activation_session(session_fdn)
            self._wait_for_completed('initialization', session_fdn)
            self.nsp_api.validate_session(session_fdn)
            self._wait_for_completed('validation', session_fdn)
            validation_results = self.nsp_api.get_validation_result(session_fdn)
            self._check_validation_results(validation_results)
            logging.info("Validation_msg: {0}".format(pformat(validation_results)))
            self.nsp_api.session_activate_all_wo(session_fdn)
            self._wait_for_completed('activation', session_fdn)
            session_status = self.nsp_api.get_session_status(session_fdn)
            self._check_session_status(session_status)
            logging.info("Session_status: {0}".format(pformat(session_status)))
        finally:
            if session_fdn is not None:
                self.nsp_api.close_activation_session(session_fdn)

    def verify_parameter_value(self, managed_object, parameter, expected_value):
        """
        Check if managed object parameter has expected value
        :param managed_object: (str) object path (eg. MRBTS-2464:MRBTS-2464:NRBTS-464:NRDU-14)
        :param parameter: (str) parameter name
        :param expected_value: (str) expected value
        """
        response = self.nsp_api.get_instance("network:" + managed_object)
        mo_status = self.nsp_api.find_in_response(response, parameter)
        if mo_status is None:
            raise NspNfmpException("{0} is not available in NSP".format(managed_object))

        actual_value = mo_status.text
        if actual_value != expected_value:
            raise NspNfmpException(
                "{0} {1} is not {2}: {3} ".format(
                    managed_object,
                    parameter,
                    expected_value,
                    actual_value))

    def verify_managed_object_not_present(self, managed_object):
        """
        Check that given object not exist on NSP
        :param managed_object: (str) objet path (eg. MRBTS-2464:MRBTS-2464:NRBTS-464:NRDU-14)
        """
        response = self.nsp_api.get_instance("network:" + managed_object)
        exception = self.nsp_api.get_find_instance_exception(response)
        if exception is None:
            raise NspNfmpException("{0} is available in NSP while it shouldn't".format(managed_object))

    def verify_alarm_is_active(self, managed_object, fault_name=None, fault_id=None):
        """
        Verify that given fault (name or id) is active on specified object
        :param managed_object: (str) obj path (eg. MRBTS-2464:MRBTS-2464:NRBTS-464)
        :param fault_name: (str) Fault name
        :param fault_id: (int) Fault id
        """
        alarms_list = self.get_aggregated_alarms(managed_object)
        for alarm in alarms_list:
            if fault_name and alarm['fault_name'] == fault_name:
                logging.info("Alarm: {0} '{1}' is active on {2}".format(alarm['fault_id'],
                                                                        alarm['fault_name'],
                                                                        managed_object))
                return
            elif fault_id and alarm['fault_id'] == str(fault_id):
                logging.info("Alarm: {0} '{1}' is active on {2}".format(alarm['fault_id'],
                                                                        alarm['fault_name'],
                                                                        managed_object))
                return
        if fault_name:
            raise NspNfmpException("Alarm: '{0}' is not active on {1}".format(fault_name, managed_object))
        elif fault_id:
            raise NspNfmpException("Alarm: {0} is not active on {1}".format(fault_id, managed_object))
        else:
            assert "Fault to verify not specified"

    def verify_alarm_is_not_active(self, managed_object, fault_name=None, fault_id=None):
        """
        Verify that given fault (name or id) isn't active on specified object
        :param managed_object: (str) obj path (eg. MRBTS-2464:MRBTS-2464:NRBTS-464)
        :param fault_name: (str) Fault name
        :param fault_id: (int) Fault id
        """
        alarms_list = self.get_aggregated_alarms(managed_object)
        for alarm in alarms_list:
            if fault_name and alarm['fault_name'] == fault_name:
                raise NspNfmpException("Alarm: '{0} {1}' is active on {2}".format(alarm['fault_id'],
                                                                                  alarm['fault_name'],
                                                                                  managed_object))
            elif fault_id and alarm['fault_id'] == str(fault_id):
                raise NspNfmpException("Alarm: '{0} {1}' is active on {2}".format(alarm['fault_id'],
                                                                                  alarm['fault_name'],
                                                                                  managed_object))
        if fault_name:
            logging.info("Alarm: '{0}' is not active on {1}".format(fault_name, managed_object))
        elif fault_id:
            logging.info("Alarm: {0} is not active on {1}".format(fault_id, managed_object))
        else:
            assert "Fault to verify not specified"

    def get_aggregated_alarms(self, managed_object):
        """
        Get aggregated alarms form managed object
        :param managed_object: (str) obj path (eg. MRBTS-2464:MRBTS-2464:NRBTS-464)
        :return: (list) List of dict with fault_id, fault_name, affected_object and class_tag
        """
        agg_alarms = self.nsp_api.get_all_alarms_for_object("network:" + managed_object)['aggregatedAlarms']
        alarms_list = []
        for alarm in agg_alarms:
            additional_info = self._parse_alarm_text(alarm['additionalText'])
            alarms_list.append({'fault_id': additional_info['fault_id'],
                                'fault_name': additional_info['fault_name'],
                                'affected_object': alarm['affectedObjectFullName'],
                                'class_tag': alarm['alarmClassTag']})
        return alarms_list

    def reset_bts(self, managed_object):
        """
        Perform BTS Software Reset
        :param managed_object: (str) Managed BTS path (eg. MRBTS-464:MRBTS-464)
        :return: None
        """
        logging.debug("Reset BTS: {0}".format(managed_object))
        self.nsp_api.bts_sw_reset('network:' + managed_object)

    def lock_cell(self, nrcell_path):
        """
        Set NRCELL administrativeState to Locked
        :param nrcell_path: (str) nrcell obj path (eg. MRBTS-2464:MRBTS-2464:NRBTS-464:NRCELL-1)
        """
        logging.debug("Lock cell: {0}".format(nrcell_path))
        self.nsp_api.configure_instance('network:' + nrcell_path, 'racgnb.NRCELL', 'administrativeState', 'Locked')

    def unlock_cell(self, nrcell_path):
        """
        Set NRCELL administrativeState to Unlocked
        :param nrcell_path: (str) nrcell obj path (eg. MRBTS-2464:MRBTS-2464:NRBTS-464:NRCELL-1)
        """
        logging.debug("Unlock cell: {0}".format(nrcell_path))
        self.nsp_api.configure_instance('network:' + nrcell_path, 'racgnb.NRCELL', 'administrativeState', 'Unlocked')

    def lock_du(self, nrdu_path):
        """
        Set NRDU administrativeState to Locked
        :param nrdu_path: (str) nrdu obj path (eg. MRBTS-2464:MRBTS-2464:NRBTS-464:NRDU-1)
        """
        logging.debug("Lock DU: {0}".format(nrdu_path))
        self.nsp_api.configure_instance('network:' + nrdu_path, 'racgnb.NRDU', 'administrativeState', 'Locked')

    def unlock_du(self, nrdu_path):
        """
        Set NRDU administrativeState to Unlocked
        :param nrdu_path: (str) nrdu obj path (eg. MRBTS-2464:MRBTS-2464:NRBTS-464:NRDU-1)
        """
        logging.debug("Unlock DU: {0}".format(nrdu_path))
        self.nsp_api.configure_instance('network:' + nrdu_path, 'racgnb.NRDU', 'administrativeState', 'Unlocked')

    def _get_work_order_id(self, work_order_filename):
        """
        Gets id of work order file identified by name
        :param work_order_filename: work order file name stored by NSP
        :return: (int) id of work order file stored by NSP
        """
        wo_list = self.nsp_api.get_workorders()
        for work_order in wo_list:
            if work_order['filename'] == os.path.basename(work_order_filename):
                return work_order['id']
        raise NspNfmpException(
            "Work order {} is not present or has errors!".format(work_order_filename))

    @staticmethod
    def _check_validation_results(results):
        """
        Checks Validation result obtained from NSP
        :param results: (list of dict) List of ValidationResults obtained from NSP
        :return: None
        """
        for result in results:
            if result['severity'] in ('error', 'warning'):
                raise NspNfmpException(
                    "Validation failed\nResults:{0}".format(pformat(results)))

    @staticmethod
    def _check_session_status(session_status):
        """
        Checks session status obtained from NSP
        :param session_status: (list of dict) List of NeWorkOrderStatus obtained from NSP
        :return: None
        """
        for ne_wo_status in session_status:
            if ne_wo_status['stageProgress'] in ('failed', 'waiting', 'inProgress'):
                raise NspNfmpException(
                    "Session activation failed\n"
                    "  Stage: {0}\n"
                    "  StageAction: {1}\n"
                    "  Validity: {2}\n"
                    "  Details: {3}".format(ne_wo_status['stage'],
                                            ne_wo_status['stageAction'],
                                            ne_wo_status['validity'],
                                            ne_wo_status['stageDetail']))

    def _parse_alarm_text(self, additional_text):
        """
        Parses alarm text from NSP
        :param additional_text: (str) additionalText obtained from NSP
        :return: (dict) fault_id and fault_name
        """
        alarm_info = {'fault_id': None,
                      'fault_name': None}
        for line in additional_text.splitlines():
            if "Additional Information1" in line:
                alarm_info['fault_name'] = line.split(" = ")[1].rstrip()
            elif "Additional Information3" in line:
                alarm_info['fault_id'] = (line.split(" = ")[1]).split(" ")[0]
        return alarm_info

    def _wait_for_completed(self, stage, session_fdn, timeout=300, interval=1):
        """
        Waits for a given stage to be completed
        :param stage: (str) initialization, validation, activation
        :param session_fdn: (str) session full domain name (eg. actv-mgr:session-110)
        :param timeout: (int) max wait time
        :param interval: (int) interval of verification operations
        :return: None
        """
        logging.debug("Waiting for Completed {0}".format(stage))
        expected_stage = {'initialization': 'initDone',
                          'validation': 'validationDone',
                          'activation': 'done'}
        i = 0
        statuses = ''
        while i < timeout:
            statuses = self.nsp_api.get_session_status(session_fdn)
            stages = [status['stage'] for status in statuses]
            if expected_stage[stage] in stages:
                return
            stages_progress = [status['stageProgress'] for status in statuses]
            if 'failed' in stages_progress:
                logging.debug("Stage: {0} failed".format(stage))
                return
            time.sleep(interval)
            i += interval
        raise NspNfmpException("Timeout on waiting for Completed {0}.\nLast session status:\n{1}".format(
            stage, pformat(statuses)))


def wait_for_synchronization(delay=3):
    """
    Sleeps for a given time
    :param delay: (int) how long should we wait
    :return: None
    """
    time.sleep(delay)
