import requests
import json
import logging
import time


log = logging.getLogger(__name__)


MY_TOKEN_DEV_2 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6IktsZWluIEpha3ViIDYyMDQ1MTQ2IiwiZXhwIjoxNzczOT" \
                 "I0MTgzLCJpc3MiOiJTLUN1cnZlLURFVjIifQ.az9e3UNHpXbT2ipMbvwRtVfmUpW_qq2_ah7QOKgyh7Q"
MY_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6IktsZWluIEpha3ViIDYyMDQ1MTQ2IiwiZXhwIjoxNzY1NDUzNjc0" \
           "LCJpc3MiOiJTLUN1cnZlLURFVjEifQ.GEAdVg8x6RrhtP0qMK6NtBxMJw02BEOqWnU1g-FfPoA"


class ScurveTestTimeout(Exception):
    def __str__(self):
        return 'Scurve test excited given timeout\nTEST HAS BEEN BROKEN, CHECK SCURVE TEST INSTANCE'


class ScurveExecutionFailed(Exception):
    def __str__(self):
        return 'Scurve execution failed'


class ScurveGetStatusFailed(Exception):
    def __str__(self):
        return 'Getting scurve test status finished failed'


class scurve:
    def __init__(self):
        self.domain = 'https://scurve-dev.wroclaw.nsn-rdnet.net/'
        self.url_post = f'{self.domain}/run_scurve_test_from_cli'
        self.url_get = f'{self.domain}/test_status'
        self.token = MY_TOKEN
        self.headers = {"Authorization": f"Bearer {self.token}", "Content-Type": "application/json"}
        self.json_config = None
        self.scurve_test_name = None
        self.test_status = None

    def start_scurve_test(self, config_json_file, scurve_test_name, tool, syslog, vm_password, global_cell_id,
                          test_scenario, timeout):
        self.json_config = config_json_file
        self.scurve_test_name = scurve_test_name
        self.tool = tool
        self.syslog = syslog
        self.vm_password = vm_password
        self.global_cell_id = global_cell_id
        self.test_scenario = test_scenario
        self.timeout = float(timeout)
        self._read_json_config()
        self._wait_until_scurve_test_finished()

    def _read_json_config(self):
        with open(self.json_config, 'r') as config:
            scurve_config = config.read()
        data = {"scurve_config": json.loads(scurve_config)}
        data["scurve_config"]["tool"] = self.tool
        data["scurve_config"]["test_name"] = self.scurve_test_name
        data["scurve_config"]["report_generator"]["sys_log"] = self.syslog
        data["scurve_config"]["bts"]["bts_vm_password"] = self.vm_password
        data["scurve_config"]["tti"]["global_cell_id"] = [int(self.global_cell_id)]
        if self.test_scenario != "default":
            data["scurve_config"]["wall_control"]["wall_data_json_content"] = self.test_scenario
        try:
            response = requests.post(self.url_post, headers=self.headers, json=data, verify=False)
            log.info(f'Scurve test started with status: {response.status_code}, inf: {response.json()}')
        except ScurveExecutionFailed as e:
            raise e
        log.info(data)

    def _wait_until_scurve_test_finished(self):
        self._return_scurve_test_status()
        log.info(f'initial test status: {self.test_status}')
        start_time = time.time()
        timeout_time = start_time + self.timeout
        current_time = time.time()
        while self.test_status == 200:
            self._return_scurve_test_status()
            time.sleep(2)
            current_time = time.time()
            if current_time > timeout_time:
                raise ScurveTestTimeout
        else:
            log.info(f'Scurve test finished after:{current_time-start_time}')

    def _return_scurve_test_status(self):
        data = {"test": self.scurve_test_name}
        try:
            response = requests.get(self.url_get, headers=self.headers, json=data, verify=False)
            self.test_status = response.status_code
        except requests.exceptions.ConnectionError as e:
            raise e
        else:
            response.connection.close()
