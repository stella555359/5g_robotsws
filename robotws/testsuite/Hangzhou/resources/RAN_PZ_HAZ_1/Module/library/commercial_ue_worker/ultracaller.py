# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import time
import logging
import requests
import json
import urllib3
from pprint import pprint
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

try:
    from .ucdb import UcDB
except Exception as E:
    from ucdb import UcDB


class UltraCallerServer(object):

    HEADER = {
        "User-Agent": ("Mozilla/5.0 (Windows NT 6.1; Win64; x64)"
                       "AppleWebKit/537.36 (KHTML, like Gecko)"
                       "Chrome/51.0.2704.103 Safari/537.36"),
        'Content-Type': 'application/json'
    }

    def __init__(self, host: str, token: str, logger=None) -> None:
        self.logger = logger or logging.getLogger(__file__)
        self.host = host
        self.token = (token)
        self.HEADER.update({'Authorization': f'Bearer {self.token}'})
        self.action_url = f'https://{self.host}/api/actions'
        self.db = UcDB(host=host, logger=self.logger)
        self.imei = ''
        self.usedb = True

    def _deal_rn(self, rn: object) -> dict:
        if rn.status_code == 200:
            resp = rn.json()
            self.logger.debug(resp)
            if resp['status'] == 'success':
                return resp
            else:
                raise Exception('Ulatracaller API failed {}'.format(resp))
        else:
            raise Exception('Ulatracaller API error, status code: {}'.format(rn.status_code))

    def _deal_ue_result(self, resp: dict, imei: str) -> dict:
        p = [x for x in resp['data'] if x['imei'] == imei]
        if p[0]['status'] == 'OK':
            pass
        else:
            raise Exception('Error {}'.format(p[0]['err']))
        return p[0]

    def get_ue_info(self, imei: str) -> dict:
        # data example:  https://10.69.81.232/apidoc/#api-Ues-Device_Info
        url = 'https://{}/api/ues?imei={}'.format(self.host, imei)
        rn = requests.get(url, headers=self.HEADER, verify=False)
        return self._deal_rn(rn)

    def get_ue_status(self, imei: str) -> dict:
        url = 'https://{}/api/ues/status?imei={}'.format(self.host, imei)
        rn = requests.get(url, headers=self.HEADER, verify=False)
        return [x for x in self._deal_rn(rn)['data'] if x['imei'] == imei][0]

    def is_idle(self, imei: str) -> bool:
        status = self.get_ue_status(imei)
        self.logger.info(status)
        return status['status'] == 'idle'

    def _take_action(self, data: dict) -> dict:
        rn = requests.post(self.action_url, data=json.dumps(data), headers=self.HEADER, verify=False)
        return self._deal_rn(rn)

    def start_test_sequence(self, imei: str = '', sequence: str = '') -> dict:
        # help: https://10.69.81.232/apidoc/#api-Actions-StartTestSequenceAction
        data = {
            'imei': imei,
            'action': {
                'cmd': 'startTestSequence',
                'testSequences': [{'name': sequence}]
            }
        }
        return self._take_action(data)['data'][0]['testSequenceId']

    def stop_test_sequence(self, imei: str = '', sequenceid: str = '') -> dict:
        # help: https://10.69.81.232/apidoc/#api-Actions-StartTestSequenceAction
        data = {
            'imei': imei,
            'action': {
                'cmd': 'stopTestSequence',
                'testSequences': [sequenceid]
            }
        }
        return self._take_action(data)

    def start_test(self, imei: str = '', test: str = '') -> dict:
        # help: https://10.69.81.232/apidoc/#api-Actions-StartTestSequenceAction
        data = {
            'imei': imei,
            'action': {
                'cmd': 'startTest',
                'tests': [{'name': x.strip()} for x in test.split(',')]
            }
        }
        return self._take_action(data)['data'][0]['testId']

    def stop_test(self, imei: str = '', testId: str = '') -> dict:
        data = {
            'imei': imei,
            'action': {
                'cmd': 'stopTest',
                'tests': [testId]
            }
        }
        pprint(data)
        return self._take_action(data)

    def stop_assigined_sequence(self, imei_list=[]):
        data = {
            'imei': imei_list,
            'action': {
                'cmd': 'stopAssignedTestSequences',
            }
        }
        return self._take_action(data)

    def stop_all(self, imei):
        logging.info('stop all for {}'.format(imei))
        data = {
            'imei': imei,
            'action': {
                'cmd': 'stopAll',
            }
        }
        return self._deal_ue_result(self._take_action(data), imei)

    def set_preferred_apn(self, imei: str, apn: str) -> dict:
        # only work for rooted ue
        data = {
            'imei': imei,
            'action': {
                'cmd': 'setPreferredApn',
                'name': apn,
            }
        }
        return self._deal_ue_result(self._take_action(data), imei)

    def get_btsinfo(self, imei: str) -> dict:
        signalInfo = self.get_ue_info(imei)['data'][0]['location']['signalInfo']
        return signalInfo

    def recreat_iperf_test(self, testname: str, testoption: str) -> dict:
        try:
            self.delete_test(testname)
        except Exception as E:
            pass

        data = {
            "singleTest": {
                "name": testname,
                "parameters": {
                    "command": testoption
                },
                "type": "Iperf"
            }
        }
        url = 'https://{}/api/tests'.format(self.host)
        rn = requests.post(url, data=json.dumps(data), headers=self.HEADER, verify=False)
        return self._deal_rn(rn)

    def delete_test(self, testname: str) -> dict:
        url = 'https://{}/api/tests/single-tests/{}'.format(self.host, testname)
        rn = requests.delete(url, headers=self.HEADER, verify=False)
        return self._deal_rn(rn)

    def search_ue_by_serialno(self, serialno: str) -> str:
        url = f'https://{self.host}/api/ues/search'
        data = {
            "query": {
                "deviceId": [serialno]
            }
        }
        rn = requests.post(url, headers=self.HEADER, verify=False, data=json.dumps(data))
        return self._deal_rn(rn)

    def get_test_status(self, testid: str) -> dict:
        url = f'https://{self.host}/api/results/single/status/{testid}'
        rn = requests.get(url, headers=self.HEADER, verify=False)
        resp = self._deal_rn(rn)['data']
        return resp

    def wait_until_test_started(self, testid: str, timeout: int = 120) -> bool:
        return self.db.wait_until_test_started(testid, timeout)
        # start_pending, start, running, completed
        start_time = time.time()
        while time.time() - start_time < timeout:
            try:
                info = self.get_test_status(testid)
                self.logger.info(f'Test {info["name"]}, Phase: {info["phase"]}')
                if info["phase"] not in ['start_pending', 'start']:
                    return True
            except Exception as E:
                self.logger.error(E)
            time.sleep(3)
        raise Exception('Test not started in {} seconds'.format(timeout))

    def wait_until_sequence_started(self, sequenceid: str, timeout: int = 120) -> bool:
        # start_pending, start, running, completed
        start_time = time.time()
        while time.time() - start_time < timeout:
            seqinfo = self.get_sequence_status(sequenceid)
            self.logger.info(f'Sequence Phase: {seqinfo["phase"]}')
            if seqinfo["phase"] in ['running']:
                return True
            time.sleep(3)
        raise Exception('Sequence not started in {} seconds'.format(timeout))

    def get_sequence_status(self, sequenceid: str) -> dict:
        url = f'https://{self.host}/api/results/sequence/status/{sequenceid}'
        rn = requests.get(url, headers=self.HEADER, verify=False)
        data = self._deal_rn(rn).get('data', [])
        return data

    def wait_until_sequence_stoped(self, sequenceid: str, timeout: int = 120) -> bool:
        # start_pending, start, running, completed
        start_time = time.time()
        while time.time() - start_time < timeout:
            seqinfo = self.get_sequence_status(sequenceid)
            self.logger.info(f'Sequence {seqinfo["name"]}, Phase: {seqinfo["phase"]}')
            if seqinfo["phase"] in ['stop', 'completed', 'failed']:
                return True
            time.sleep(3)
        raise Exception('Sequence not stopped in {} seconds'.format(timeout))

    def wait_until_test_stopped(self, testId: str, timeout: int = 120) -> bool:
        return self.db.wait_until_test_stopped(testId, timeout)
        # start_pending, start, running, completed
        start_time = time.time()
        while time.time() - start_time < timeout:
            info = self.get_test_status(testId)
            self.logger.info(f'Test {info["name"]}, Phase: {info["phase"]}')
            if info["phase"] in ['stop', 'completed', 'failed']:
                return True
            time.sleep(3)
        raise Exception('Test not stopped in {} seconds'.format(timeout))

    def wait_until_idle(self, imei: str) -> bool:
        start_time = time.time()
        while time.time() - start_time < 120:
            if self.is_idle(imei):
                return True
            time.sleep(3)
        raise Exception('UE not idle in 120 seconds')

    def get_user_sequence(self, imei: str) -> list:
        subGroupId = self.get_ue_info(imei)['data'][0]['subGroupId']
        url = f'https://{self.host}/api/results/sequence/status/group/{subGroupId}'
        try:
            rn = requests.get(url, headers=self.HEADER, verify=False)
            data = self._deal_rn(rn).get('data', [])
            tests = [x for x in data if x['ue']['imei'] == imei]
            return tests
        except Exception:
            return []

    def get_user_test(self, imei: str) -> list:
        return self.db.test_status(imei=imei)
        subGroupId = self.get_ue_info(imei)['data'][0]['subGroupId']
        url = f'https://{self.host}/api/results/single/status/group/{subGroupId}'
        try:
            rn = requests.get(url, headers=self.HEADER, verify=False)
            data = self._deal_rn(rn).get('data', [])
            tests = [x for x in data if x['ue']['imei'] == imei]
            return tests
        except Exception:
            return []

    def get_running_test(self, imei) -> list:
        running = [x for x in self.get_user_test(imei) if x['phase'] not in ['completed', 'failed']]
        return running

    def get_running_sequence(self, imei: str) -> list:
        running = [x for x in self.get_user_sequence(imei) if x['phase'] not in ['completed', 'failed']]
        return running

    def wait_until_all_stoped(self, imei: str, timeout: int = 120) -> bool:
        start_time = time.time()
        for test in self.get_running_test(imei):
            self.wait_until_test_stopped(test['testId'], timeout)
        for seq in self.get_running_sequence(imei):
            self.wait_until_sequence_stoped(seq['testSequenceId'], timeout)

    def get_all_sequences(self):
        url = f'https://{self.host}/api/tests/test-sequences'
        rn = requests.get(url, headers=self.HEADER, verify=False)
        return [x['name'] for x in self._deal_rn(rn)['data']]

    def delete_sequence(self, sequence_name: str) -> dict:
        url = f'https://{self.host}/api/tests/test-sequences/{sequence_name}'
        rn = requests.delete(url, headers=self.HEADER, verify=False)
        return self._deal_rn(rn)

    def import_sequence_from_file(self, sequence_file: str, sequence_name: str = '', replace: bool = False) -> None:
        url = f'https://{self.host}/api/tests'
        with open(sequence_file, 'r') as f:
            data = json.load(f)
        value = data.pop('sequence')
        data['testSequence'] = value
        if sequence_name:
            data['testSequence']['name'] = sequence_name
        if sequence_name in self.get_all_sequences():
            self.logger.info(f'Sequence {sequence_name} already exist')
            if replace:
                self.logger.info(f'Remove Sequence {sequence_name} first.')
                self.delete_sequence(sequence_name)
            else:
                return
        self.logger.info(f'Import Sequnce: {sequence_name}')
        url = f'https://{self.host}/api/tests'
        rn = requests.post(url, data=json.dumps(data), headers=self.HEADER, verify=False)
        return self._deal_rn(rn)

    def import_test_from_file(self, test_file: str, test_name: str = '', replace: bool = False) -> None:
        url = f'https://{self.host}/api/tests'
        with open(test_file, 'r') as f:
            data = json.load(f)
        value = data.pop('test')
        data['singleTest'] = value
        if test_name:
            data['singleTest']['name'] = test_name
        tests = self.get_tests_of_type(data['singleTest']['type'])
        if test_name in tests:
            self.logger.info(f'Test {test_name} already exist')
            if replace:
                self.logger.info(f'Remote Test {test_name} first')
                self.delete_test(test_name)
            else:
                return 0
        self.logger.info(f'Import Test: {test_name}')
        url = f'https://{self.host}/api/tests'
        rn = requests.post(url, data=json.dumps(data), headers=self.HEADER, verify=False)
        return self._deal_rn(rn)

    def get_tests_of_type(self, type: str):
        url = f'https://{self.host}/api/tests/single-tests/{type}'
        rn = requests.get(url, headers=self.HEADER, verify=False)
        return [x['name'] for x in self._deal_rn(rn)['data']]


if __name__ == '__main__':
    log_level = logging.DEBUG
    FORMAT = '%(name)s-%(asctime)s [%(levelname)s] %(message)s'
    logging.basicConfig(format=FORMAT, datefmt="%Y-%m-%d %H:%M:%S", level=log_level)
