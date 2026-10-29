import time


class ping(object):
    def __init__(self, tcobject, uccall, set_obj):
        self.tcobject = tcobject()
        self.ucapi = uccall()
        self.ue_details = {}
        self.server_ip = ""
        self.obj = set_obj()

    def _start_datatransfer(self, ue_details, alias, call_type, dire, tputcheck, header):
        self.ue_details = ue_details
        test_type = (call_type.upper()).replace(" ", "_")
        print(test_type)
        iperf_option = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS'][
            'configuration']['data_transfer'][test_type]
        self.server_ip = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['uc_server_Ip']
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])

        self.ue_details[alias]['kill'] = ""
        uc_test_name = "uc_" + test_type + "_" + str(alias)
        uc_testid = self.tcobject._create_start_case(uc_test_name, call_type, iperf_option, imei, header)
        self.ue_details[alias]['testId'] = uc_testid[imei]
        self.ue_details[alias]['count'] = int(time.time())

    def _stop_datatransfer(self, alias, header):
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        self.ucapi._UC_StopCall(self.ue_details[alias]['testId'], imei, header)
        time.sleep(5)

    def _check_call_is_alive(self, alias, header):
        url = "https://" + self.server_ip + \
              "/api/results/single/result/" + self.ue_details[alias]['testId']
        response = self.ucapi._Get(url, header)
        response = response.json()
        phase = ""
        for i in range(0, len(response['data'])):
            phase = response['data'][i]['phase']
            status = response['data'][i]['status']
        return phase, response

    def _await_data_transfer_finish(self, alias, dire, timeout, header):
        print(dire)
        count = self.ue_details[alias]['count'] + timeout
        while int(time.time()) < count:
            result, response = self._check_call_is_alive(alias, header)
            if result == "completed":
                break
            time.sleep(30)
        return response
