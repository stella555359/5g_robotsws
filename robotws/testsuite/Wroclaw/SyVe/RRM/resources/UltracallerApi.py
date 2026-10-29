import requests
from time import time, sleep
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger

TIME_TO_REBOOT = 10
TIMEOUT_FOR_UE_AVAILABILITY_AFTER_REBOOT = 180


class UltracallerApi(object):

    def __init__(self, url, login, password):
        self.uc_url = url
        self.uc_api_actions = '/api/actions'
        self.uc_api_login = '/api/users/login'
        self.uc_api_test_sequence_status = '/api/results/sequence/status'
        self.uc_api_search_ues = '/api/ues/search'
        self.uc_api_status_ues = '/api/ues/status'
        self.uc_api_get_headgroups = '/api/headgroups'
        self.uc_login = login
        self.uc_password = password
        self.token = None

    def login_to_ultracaller(self):
        login_json = {'username': f'{self.uc_login}',
                      'password': f'{self.uc_password}'}
        try:
            response = requests.post(f'{self.uc_url}{self.uc_api_login}', login_json, verify=False).json()
            if 'success' in response['status']:
                self.token = response['data'][0]['token']
                Logger.info('UltraCaller: Login successful. Token has been obtained.')
                return
            assert False, 'UltraCaller: Login unsuccessful. Please verify provided credentials.'
        except ConnectionError:
            assert False, 'UltraCaller: Failure while connecting to UltraCaller server.'

    def get_ues_imei(self):
        return [ue['imei'] for ue in self._get_all_ues()['data']]

    def get_headergroups(self):
        return self._get_api_request(self.uc_api_get_headgroups)

    def get_ue_status(self, imei):
        return self._get_api_request(f'{self.uc_api_status_ues}/?imei={imei}')['data'][0]

    def set_ue_airplane_mode_on(self, imei):
        cmd = {
            'imei': [imei],
            'action': {
                'cmd': 'airplaneMode',
                'duration': 0
            }
        }
        if 'OK' in self._post_api_request(self.uc_api_actions, cmd)['data'][0]['status']:
            Logger.info(f'UE {imei}: Airplane mode turned on')
            return
        assert False, f'UE {imei}: Failure while turning airplane mode on'

    def set_ue_airplane_mode_off(self, imei):
        cmd = {
            'imei': [imei],
            'action': {
                'cmd': 'airplaneMode',
                'duration': -1
            }
        }
        if 'OK' in self._post_api_request(self.uc_api_actions, cmd)['data'][0]['status']:
            Logger.info(f'UE {imei}: Airplane mode turned off')
            return
        assert False, f'UE {imei}: Failure while turning airplane mode off'

    def reboot_ue_and_wait_to_be_available(self, imei):
        lastseen_before_reboot = self.get_ue_status(imei)['lastSeen']
        self._reboot_ue(imei)
        sleep(TIME_TO_REBOOT)
        Logger.info(f'Reboot command has been sent to UE {imei}. Checking for '
                    f'{TIMEOUT_FOR_UE_AVAILABILITY_AFTER_REBOOT} seconds to be available again in UltraCaller')
        start_time = time()
        sleep_time = 10
        while start_time + TIMEOUT_FOR_UE_AVAILABILITY_AFTER_REBOOT > time():
            sleep(sleep_time)
            if self.get_ue_status(imei)['lastSeen'] > lastseen_before_reboot:
                Logger.info(f'UE {imei} available in UltraCaller')
                return
        assert False, f'Timeout exceeded, UE {imei} lost'

    def get_ue_full_info(self, imei):
        response = self._get_all_ues()
        for ue in response['data']:
            if imei in ue['imei']:
                return ue

    def start_assigned_tests(self, imei):
        cmd = {
            'imei': [imei],
            'action': {
                'cmd': 'startAssignedTests',
            }
        }
        response = self._post_api_request(self.uc_api_actions, cmd)
        if 'OK' in response['data'][0]['status']:
            Logger.info(f'UE {imei}: All assigned tests has been started')
            return response['data'][0]['testId']
        assert False, f'UE {imei}: Failure while starting assigned tests'

    def start_assigned_test_sequences(self, imei):
        cmd = {
            'imei': [imei],
            'action': {
                'cmd': 'startAssignedTestSequences',
            }
        }
        response = self._post_api_request(self.uc_api_actions, cmd)
        if 'OK' in response['data'][0]['status']:
            Logger.info(f'UE {imei}: All assigned test sequences has been started')
            return response['data'][0]['testSequenceId']
        assert False, f'UE {imei}: Failure while starting assigned test sequences'

    def stop_all_assigned_tests_and_sequences(self, imei):
        cmd = {
            'imei': [imei],
            'action': {
                'cmd': 'stopAll',
            }
        }
        if 'OK' in self._post_api_request(self.uc_api_actions, cmd)['data'][0]['status']:
            Logger.info(f'UE {imei}: All assigned tests and sequences has been stopped')
            return
        assert False, f'UE {imei}: Failure while stopping assigned tests and sequences'

    def is_test_sequence_ongoing(self, test_sequence_id):
        if 'running' in self._get_test_sequence_status(test_sequence_id)['data']['phase']:
            return True
        return False

    def get_test_sequence_verdict(self, test_sequence_id):
        return self._get_test_sequence_status(test_sequence_id)['data']['verdict']

    def _get_api_request(self, api_method):
        headers = {'Authorization': f'Bearer {self.token}', 'Content-Type': 'application/json', 'Accept': '*/*'}
        return requests.get(f'{self.uc_url}{api_method}', verify=False, headers=headers).json()

    def _post_api_request(self, api_method, payload):
        headers = {'Authorization': f'Bearer {self.token}', 'Content-Type': 'application/json', 'Accept': '*/*'}
        return requests.post(f'{self.uc_url}{api_method}', json=payload, verify=False, headers=headers).json()

    def _reboot_ue(self, imei):
        cmd = {
            'imei': [imei],
            'action': {
                'cmd': 'resetDevice',
            }
        }
        return self._post_api_request(self.uc_api_actions, cmd)

    def _get_all_ues(self):
        cmd = {
            'query': {
                'imei': ['']
            }
        }
        return self._post_api_request(self.uc_api_search_ues, cmd)

    def _get_test_sequence_status(self, test_sequence_id):
        return self._get_api_request(f'{self.uc_api_test_sequence_status}/{test_sequence_id}')
