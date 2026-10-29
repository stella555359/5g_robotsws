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
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


class UltraCallerServer(object):

    HEADER = {
        "User-Agent": ("Mozilla/5.0 (Windows NT 6.1; Win64; x64)"
                       "AppleWebKit/537.36 (KHTML, like Gecko)"
                       "Chrome/51.0.2704.103 Safari/537.36"),
        'Content-Type': 'application/json'
    }

    def __init__(self, host='10.21.41.22', logger=None):
        self.logger = logger or logging.getLogger(__file__)
        self.host = host
        self.token = ('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InJybSIsImFkbWluIjp0cnVlfQ'
                      '.bkKZiQblqcR1eICofRDSC6UB9_jSRHhnmG0l5dNSjHo')
        self.HEADER.update({'Authorization': f'Bearer {self.token}'})
        self.action_url = f'https://{self.host}/api/actions'

    def _deal_rn(self, rn):
        if rn.status_code == 200:
            resp = rn.json()
            self.logger.debug(resp)
            if resp['status'] == 'success':
                return resp
            else:
                raise Exception('Ulatracaller API failed {}'.format(resp))
        else:
            raise Exception('Ulatracaller API error, status code: {}'.format(rn.status_code))

    def _deal_ue_result(self, resp, imei):
        p = [x for x in resp['data'] if x['imei'] == imei]
        if p[0]['status'] == 'OK':
            pass
        else:
            raise Exception('Error {}'.format(p[0]['err']))
        return p[0]

    def get_ue_info(self, imei):
        # data example:  https://10.21.41.22/apidoc/#api-Ues-Device_Info
        url = 'https://{}/api/ues?imei={}'.format(self.host, imei)
        rn = requests.get(url, headers=self.HEADER, verify=False)
        return self._deal_rn(rn)

    def get_ue_status(self, imei):
        url = 'https://{}/api/ues/status?imei={}'.format(self.host, imei)
        rn = requests.get(url, headers=self.HEADER, verify=False)
        return [x for x in self._deal_rn(rn)['data'] if x['imei'] == imei][0]

    def is_idle(self, imei):
        status = self.get_ue_status(imei)
        self.logger.info(status)
        return status['status'] == 'idle'

    def _take_action(self, data):
        rn = requests.post(self.action_url, data=json.dumps(data), headers=self.HEADER, verify=False)
        return self._deal_rn(rn)

    def start_test_sequence(self, imei='', sequence=''):
        # help: https://10.21.41.22/apidoc/#api-Actions-StartTestSequenceAction
        data = {
            'imei': imei,
            'action': {
                'cmd': 'startTestSequence',
                'testSequences': [{'name': sequence}]
            }
        }
        return self._take_action(data)

    def stop_test_sequence(self, imei='', sequenceid=''):
        # help: https://10.21.41.22/apidoc/#api-Actions-StartTestSequenceAction
        data = {
            'imei': imei,
            'action': {
                'cmd': 'stopTestSequence',
                'testSequences': [sequenceid]
            }
        }
        return self._take_action(data)

    def start_test(self, imei='', test=''):
        # help: https://10.21.41.22/apidoc/#api-Actions-StartTestSequenceAction
        data = {
            'imei': imei,
            'action': {
                'cmd': 'startTest',
                'tests': [{'name': x.strip()} for x in test.split(',')]
            }
        }
        return self._take_action(data)

    def stop_test(self, imei='', test=''):
        data = {
            'imei': imei,
            'action': {
                'cmd': 'stopTest',
                'tests': [{'name': x.strip()} for x in test.split(',')]
            }
        }
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

    def set_preferred_apn(self, imei, apn):
        # only work for rooted ue
        data = {
            'imei': imei,
            'action': {
                'cmd': 'setPreferredApn',
                'name': apn,
            }
        }
        return self._deal_ue_result(self._take_action(data), imei)

    def enable_airplane(self, imei):
        # slowly and need verify for each ue type
        # response is immediately, and need to wait until by check again and again.
        data = {
            'imei': imei,
            'action': {
                'cmd': 'airplaneMode',
                'duration': 0,
            }
        }
        return self._deal_ue_result(self._take_action(data), imei)

    def disable_airplane(self, imei):
        # slowly and need verify for each ue type
        # response is immediately, and need to wait until by check again and again.
        data = {
            'imei': imei,
            'action': {
                'cmd': 'airplaneMode',
                'duration': 1,
            }
        }
        return self._deal_ue_result(self._take_action(data), imei)

    def is_airplane(self, imei):
        status = self.get_ue_info(imei)['data'][0]['airplaneMode']
        return status == 1

    def get_btsinfo(self, imei):
        signalInfo = self.get_ue_info(imei)['data'][0]['location']['signalInfo']
        return signalInfo

    def recreat_iperf_test(self, testname, testoption):
        self.delete_test(testname)
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

    def delete_test(self, testname):
        url = 'https://{}/api/tests/single-tests/{}'.format(self.host, testname)
        rn = requests.delete(url, headers=self.HEADER, verify=False)
        return self._deal_rn(rn)


if __name__ == '__main__':
    log_level = logging.DEBUG
    FORMAT = '%(name)s-%(asctime)s [%(levelname)s] %(message)s'
    logging.basicConfig(format=FORMAT, datefmt="%Y-%m-%d %H:%M:%S", level=log_level)

    ucs = UltraCallerServer()
    imei = '866164052814815'
    imei = '866440057691777'
    # resp = ucs.set_preferred_apn(imei, 'stmdrb1')
    # print(ucs.delete_test('test1'))
    # print(ucs.stop_all(imei))
    # print(ucs.recreat_iperf_test('test1', '-u -c 10.69.9.57 -t 300 -b 1M -i 1 -l 1024'))
    # print(ucs.recreat_iperf_test('test2', '-u -c 10.69.9.59 -t 300 -b 1M -i 1 -l 1024'))
    # print(ucs.start_test(imei, 'test1, test2'))
    print(ucs.is_idle(imei))
    ucs.start_test_sequence(imei, 'CB008662')
    # print(ucs.start_test(imei, 'test2'))
    # print(ucs.delete_test('test3'))
    # resp = ucs.enable_airplane(imei)
    # print(ucs.stop_all(imei))
    # print(resp)
