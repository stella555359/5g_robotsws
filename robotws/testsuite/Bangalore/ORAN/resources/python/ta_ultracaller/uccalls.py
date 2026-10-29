import json
import time
from .ucsession import *
import requests

global testId
testId = {}
global testseqId
global urls
urls = {}
testseqId = {}


class ucapi(ucsession):
    def __init__(self):
        pass

    def _addingtoken(self, ip, token):
        urls["Actions"] = "https://" + ip + "/api/actions"
        urls["Results"] = "https://" + ip + "/api/results/single/result/"
        urls["Unassign"] = "https://" + ip + "/api/ues/single-test/ue/:"
        urls["create_test"] = "https://" + ip + "/api/tests"
        urls["delete_test"] = "https://" + ip + "/api/tests/single-tests/"
        urls["assign"] = "https://" + ip + "/api/ues/test"

    def _Post(self, url, data, header):
        response = ucsession.creation(option="POST", url=url,
                                      headers=header, data=data)
        return response

    def _Get(self, url, header):
        response = ucsession.creation(option="GET", url=url, headers=header)
        return response

    def _Put(self, url, data, header):
        response = ucsession.creation(option="PUT", url=url,
                                      headers=header, data=data)
        return response

    def _Delete(self, url, header):
        response = ucsession.creation(option="DELETE", url=url,
                                      headers=header)
        return response


class uccalls(ucapi):
    def __init__(self):
        pass

    def _UC_CallStopAll(self, imei, Header=None):
        payload = {"imei": imei, "action": {"cmd": "stopAll"}}
        url = urls["Actions"]
        response = self._Post(url, json.dumps(payload), Header)
        return response

    def _UC_StopCall(self, testcaseid, imei, Header=None):
        payload = {"imei": imei, "action": {"cmd": "stopTest", "tests": [testcaseid]}}
        url = urls["Actions"]
        response = self._Post(url, json.dumps(payload), Header)
        return response

    def _UC_StartCall(self, testcasename, imei, testType, Header=None):
        imei = str(imei)
        self._UnassignAll(imei, Header)
        self._assignTest(imei, testcasename, testType, Header)
        time.sleep(1)
        response = self._startTest(imei, testcasename, Header)
        result = response.json()
        try:
            testId[imei] = result['data'][0]['testId']
        except Exception as e:
            print(str(e))
        time.sleep(1)
        for i in range(0, len(result['data'])):
            if result['data'][i]['status'] != "OK":
                raise Exception(
                    "******* Operation for IMEI: " + imei +
                    " is failed with reason " +
                    result['data'][i]["err"] + "********")
        return (testId)

    def UC_StopAll(self, imei, timeout=300, Header=None):
        self._UC_CallStopAll(imei, Header)

    def _assignTest(self, imei, testcasename, testType, Header):
        url = urls["Actions"]
        payload = {"imei": imei, "name": testcasename, "type": testType}
        response = self._Put(url, json.dumps(payload), Header)
        return response

    def _startTest(self, imei, testcasename, Header):
        payload = {"imei": imei, "action": {"cmd": "startTest",
                                            "tests": [{"name": testcasename}]}}
        url = urls["Actions"]
        response = self._Post(url, json.dumps(payload), Header)
        return response

    def _UnassignAll(self, imei, Header):
        url = urls["Unassign"] + imei
        response = self._Delete(url, Header)
        return response

    def _UC_Reboot(self, imei, Header):
        payload = {"imei": imei, "action": {"cmd": "resetDevice"}}
        url = urls["Actions"]
        response = self._Post(url, json.dumps(payload), Header)
        return response

    def _UC_General(self, url, imei, payload='', url_type="POST", header=''):
        for i in imei.split(","):
            if url_type == "POST":
                response = self._Post(url, json.dumps(payload), header)
                result = response.json()
            else:
                response = self._Get(url, header)
                result = response.json()
        for i in range(0, len(result['data'])):
            if result['data'][i]['status'] == 'success':
                return (result['data'][i])
        for i in range(0, len(result['data'])):
            if result["status"] == 'success':
                return result['data']

    def _UC_create_test(self, test_name, test_type, param, Header):
        url = urls["create_test"]
        param_list = ['"{param}":"{value}"'.format(
            param=par,
            value=value,
        ) for par, value in param.items()]
        param_string = ','.join(param_list)
        payload = '{"singleTest": {'
        payload = '{{"singleTest": {{"name": "{test_name}",' \
                  '"parameters":{{{param_list}}},' \
                  '"type":"{test_type}"}}}}'.format(test_name=test_name,
                                                    param_list=param_string,
                                                    test_type=test_type)
        response = self._Post(url, payload, Header)
        time.sleep(2)
        result = response.json()
        if result['status'] != "success" or result['data']['inserted'] != 1:
            if "Duplictation" not in result['data']:
                raise Exception(
                    "******* create Operation was failed with reason " + str(result) + "********")

    def _UC_delete_test(self, test_name, Header):
        url = urls["delete_test"] + test_name
        response = requests.delete(url, headers=Header, verify=False)
        result = response.json()
        if result['status'] != "success" or result['data']['deleted'] != 1:
            raise Exception(
                "******* delete Operation was failed with reason " + str(result) + "********")
