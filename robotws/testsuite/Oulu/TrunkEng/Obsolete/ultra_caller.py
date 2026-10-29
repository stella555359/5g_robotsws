# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: 'Ilkka Pinola'
:contact: I_ABSTRACT_LIBRARY_DEV@internal.nsn.com
:maintainer: None
:contact: None
"""
import time

import requests
import six
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error


class UltraCallerActionFailed(Exception):
    """Ultra Caller Command Failed Exception"""

    def __init__(self, action):
        """
        Basic initialization.
        :param action:
        """
        super(UltraCallerActionFailed, self).__init__()
        self.msg = action

    def __str__(self):
        return "UltraCaller action {} was not successful".format(self.msg)


class UltraCallerError(Exception):
    """Ultra Caller Error Exception"""
    pass


class UcPhase(object):
    """UcPhase enum class"""
    PENDING = 'start_pending'
    RUNNING = 'running'
    COMPLETED = 'completed'


class UcStatus(object):
    """UcStatus enum class"""
    ERROR = 'error'


class UcApiEndpoints(object):
    """Ultra Caller API"""
    _BASE = 'api'

    _ACTIONS = 'actions'
    _HEAD_GROUPS = 'headgroups'
    _RESULTS = 'results'
    _SUB_GROUPS = 'subgroups'
    _TESTS = 'tests'
    _UES = 'ues'

    def __init__(self, address):
        """
        Init
        :param address:
        """
        self._address = 'https://{}'.format(address)

    def __getattr__(self, item):
        try:
            a = self.__getattribute__('_{}'.format(item))
        except AttributeError:
            raise AttributeError("'UcApiEndpoints' object has no attribute '{}'".format(item))
        return '/'.join([self._address, self._BASE, a])


class UcApi(object):
    """Ultra Caller API"""

    def __init__(self, address, token):
        """
        Basic initialization.
        :param address:
        :param token:
        """
        self.logger = BuiltIn().get_library_instance("LOG")
        self.address = address
        self.api = UcApiEndpoints(self.address)
        self._token = token
        self.logger.debug('UcApi initialized with address: {}, token: {}'.format(address, token))

    # <=><=><=><=><=><=><=><=><=><=><=><=><=><=> ACTIONS <=><=><=><=><=><=><=><=><=><=><=><=><=><=>

    def start_test(self, imei, test_name):
        """
        Start test
        :param imei:
        :param test_name:
        :return:
        """
        r = self._send_action(imei, 'startTest', tests=self._listify_tests(test_name))
        if not self._check_action_successful(r):
            raise UltraCallerActionFailed('startTest')
        return r

    def stop_test(self, imei, test_id):
        """
        Stop test
        :param imei:
        :param test_id:
        :return:
        """
        r = self._send_action(imei, 'stopTest', tests=self._listify(test_id))
        if not self._check_action_successful(r):
            raise UltraCallerActionFailed('stopTest')
        return r

    def start_test_sequence(self, imei, test_sequence_name):
        """
        Start test sequence
        :param imei:
        :param test_sequence_name:
        :return:
        """
        r = self._send_action(imei, 'startTestSequence', testSequences=self._listify_tests(test_sequence_name))
        if not self._check_action_successful(r):
            raise UltraCallerActionFailed('startTestSequence')
        return r

    def stop_test_sequence(self, imei, test_sequence_id):
        """
        Stop test sequence
        :param imei:
        :param test_sequence_id:
        :return:
        """
        r = self._send_action(imei, 'stopTestSequence', tests=self._listify(test_sequence_id))
        if not self._check_action_successful(r):
            raise UltraCallerActionFailed('stopTestSequence')
        return r

    def stop_all(self, imei):
        """
        Stop all tests and test sequences
        :param imei:
        :return:
        """
        r = self._send_action(imei, 'stopAll')
        if not self._check_action_successful(r):
            raise UltraCallerActionFailed('stopAll')
        return r

    def airplane_mode(self, imei, duration):
        """
        Enable/disable airplane mode
        :param imei:
        :param duration:
        :return:
        """
        r = self._send_action(imei, 'airplaneMode', duration=duration)
        if not self._check_action_successful(r):
            raise UltraCallerActionFailed('airplaneMode')
        return r

    def mobile_data(self, imei, duration):
        """
        Enable/disable mobile data
        :param imei:
        :param duration:
        :return:
        """
        r = self._send_action(imei, 'mobiledata', duration=duration)
        if not self._check_action_successful(r):
            raise UltraCallerActionFailed('mobiledata')
        return r

    def cell_lock(self):
        """
        Enable/disable cell lock
        :return:
        """
        # TODO: Implement when endpoint available
        raise NotImplementedError()

    def get_device_log(self, imei):
        """
        Get device log
        :param imei:
        :return:
        """
        r = self._send_action(imei, 'getDeviceLog')
        return r

    def reset(self, imei):
        """
        Reset UE
        :param imei:
        :return:
        """
        r = self._send_action(imei, 'resetDevice')
        if not self._check_action_successful(r):
            raise UltraCallerActionFailed('resetDevice')
        return r

    def _send_action(self, imei, command, **kwargs):
        parameters = {'imei': self._listify(imei),
                      'action': {'cmd': command}
                      }
        if kwargs:
            for key, value in six.iteritems(kwargs):
                parameters['action'][key] = value

        return self._send_request('post', self.api.ACTIONS, parameters)

    # @staticmethod
    def _check_action_successful(self, response):
        for action in response['data']:
            info("Action response: {}".format(action))
            if not action['status'] == 'OK':
                return False
        return True

    # <=><=><=><=><=><=><=><=><=><=><=><=><=><=> RESULTS <=><=><=><=><=><=><=><=><=><=><=><=><=><=>

    def get_test_result(self, test_id):
        """
        Get test result
        :param test_id:
        :return:
        """
        url = '{results_base}/single/result/{test_id}'.format(results_base=self.api.RESULTS,
                                                              test_id=test_id)
        return self._send_request('get', url)

    def get_test_sequence_result(self, test_sequence_id):
        """
        Get test sequence result
        :param test_sequence_id:
        :return:
        """
        url = '{results_base}/sequence/results/{sequence_id}'.format(results_base=self.api.RESULTS,
                                                                     sequence_id=test_sequence_id)
        return self._send_request('get', url)

    def test_status(self, test_id):
        """
        Get test status
        :param test_id:
        :return:
        """
        url = '{results_base}/single/status/{test_id}'.format(results_base=self.api.RESULTS,
                                                              test_id=test_id)
        return self._send_request('get', url)

    def test_sequence_status(self, test_sequence_id):
        """
        Get test sequence status
        :param test_sequence_id:
        :return:
        """
        url = '{results_base}/sequence/status/{sequence_id}'.format(results_base=self.api.RESULTS,
                                                                    sequence_id=test_sequence_id)
        return self._send_request('get', url)

    # <=><=><=><=><=><=><=><=><=><=><=><=><=><=> TESTS <=><=><=><=><=><=><=><=><=><=><=><=><=><=>

    def new_test(self, name, test_type, test_params):
        """
        Create new test
        :param name:
        :param test_type:
        :param test_params:
        :return:
        """
        payload = {'singleTest': {'name': name, 'type': test_type, 'parameters': test_params}}
        return self._send_request('post', self.api.TESTS, payload)

    def get_test_info(self, test_name):
        """
        Get test info
        :param test_name:
        :return:
        """
        url = '{tests_base}/single-test/{test_name}'.format(tests_base=self.api.TESTS, test_name=test_name)
        return self._send_request('get', url, expected_status_codes=(200, 404))

    def delete_test(self, test_name):
        """
        Delete existing test
        :param test_name:
        :return:
        """
        url = '{tests_base}/single-tests/{test_name}'.format(tests_base=self.api.TESTS, test_name=test_name)
        return self._send_request('delete', url)

    # <=><=><=><=><=><=><=><=><=><=><=><=><=><=> UES <=><=><=><=><=><=><=><=><=><=><=><=><=><=>

    def search_ues_by_group(self, head_group, sub_group=None):
        """
        Search UEs by group
        :param head_group:
        :param sub_group:
        :return:
        """
        if not sub_group:
            return self.search_ues(headGroup=self._listify(head_group))
        return self.search_ues(headGroup=self._listify(head_group), subGroup=self._listify(sub_group))

    def search_ues_by_imei(self, imei):
        """
        Search UEs by imei
        :param imei:
        :return:
        """
        return self.search_ues(imei=self._listify(imei))

    def search_ues(self, **params):
        """
        Search UEs by parameters (See UC API)
        :param params:
        :return:
        """
        url = '{base_ues}/search'.format(base_ues=self.api.UES)
        payload = {'query': params}
        return self._send_request('post', url, payload)

    def unassign_all_tests(self, imei):
        """
        Unassign all tests
        :param imei:
        :return:
        """
        url = '{results_base}/single-test/ue/{imei}'.format(results_base=self.api.UES, imei=imei)
        return self._send_request('delete', url, expected_status_codes=(200, 404))

    # <=><=><=><=><=><=><=><=><=><=><=><=><=><=> UTILITIES <=><=><=><=><=><=><=><=><=><=><=><=><=><=>

    def wait_until_test_phase(self, test_id, phase, wait_time=40):
        """
        Wait until UC test phase matches given phase or until timeout.

        :param test_id: unique test id assigned by Ultracaller server when test is started
        :param phase: Phase that UC test needs to be in.
        :param wait_time: Maximum time to wait in seconds before raising exception
        :return: True if phase triggered, False if timeout
        """
        phase_list = self._listify(phase)
        started_waiting = time.time()
        while time.time() < started_waiting + wait_time:
            time.sleep(5)
            response = self.test_status(test_id)
            if response['data']['phase'] in phase_list:
                break
        return response['data']['phase']

    def wait_until_test_sequence_phase(self, test_sequence_id, phase, wait_time=40):
        """
        Wait until UC test phase matches given phase or until timeout.

        :param test_sequence_id: unique test sequence id assigned by Ultracaller server when test is started
        :param phase: Phase that UC test needs to be in.
        :param wait_time: Maximum time to wait in seconds before raising exception
        :return: True if phase triggered, False if timeout
        """
        started_waiting = time.time()
        while time.time() < started_waiting + wait_time:
            time.sleep(5)
            response = self.test_sequence_status(test_sequence_id)
            if response['data']['phase'] == phase:
                return True
        return False

    def _send_request(self, method, url, body=None, expected_status_codes=(200,)):
        """
        Send HTTP request to Ultra Caller server.
        :param method: HTTP method
        :param url: URL
        :param body: (optional) JSON body to send
        :param expected_status_codes: (optional) Tuple of expected status codes
        :return: Dictionary of server's response
        """
        http_methods = {
            'get': requests.get,
            'post': requests.post,
            'put': requests.put,
            'delete': requests.delete,
        }
        headers = {'Authorization': 'Bearer {}'.format(self._token),
                   'Content-Type': 'application/json'}
        self.logger.debug('sending: {method} {url}'.format(method=method.upper(), url=url))
        self.logger.debug('body: {}'.format(body))
        self.logger.debug('headers: {}'.format(headers))
        if body:
            r = http_methods[method](url, json=body, headers=headers, verify=False)
        else:
            r = http_methods[method](url, headers=headers, verify=False)
        try:
            response = r.json()
        except ValueError:
            err_msg = 'Not valid JSON response from server: {} {}'.format(r.status_code, r.text)
            error(err_msg)
            raise UltraCallerError(err_msg)

        self.logger.debug('response: {status} {response}'.format(status=r.status_code, response=response))
        if r.status_code not in expected_status_codes:
            err_msg = 'Unexpected status code from server: {} {}'.format(r.status_code, response)
            error(err_msg)
            raise UltraCallerError(err_msg)

        return response

    @staticmethod
    def _listify(data):
        """
        Returns data if it is list, otherwise returns list with one data item.

        :param data:
        :return: list
        """
        return data if isinstance(data, list) else [data]

    @staticmethod
    def _listify_tests(data):
        """
        Returns data if it is list, otherwise returns list with one data item.

        :param data:
        :return: list
        """
        tests_list = []
        if isinstance(data, list):
            for test in data:
                tests_list.append({'name': test})
        else:
            tests_list.append({'name': data})
        return tests_list
