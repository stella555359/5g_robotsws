import time


class ftp_data_transfer(object):
    def __init__(self, tcobject, uccall, set_obj):
        self.tcobject = tcobject()
        self.ucapi = uccall()
        self.obj = set_obj()
        self.ue_details = {}
        self.server_ip = ""

    def _start_datatransfer(self, ue_details, alias, call_type, dire, tputcheck, header):
        self.ue_details = ue_details
        self.server_ip = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['uc_server_Ip']
        iperf_option = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS'][
            'configuration']['data_transfer']['FTP']
        cmd_option = iperf_option.split(" ")
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        param = {}
        print("********", dire, call_type, tputcheck)
        param["address"] = cmd_option[0].split(":")[1]
        # param["port"] = 21
        param["filename"] = cmd_option[1].split(":")[1]
        param["login"] = cmd_option[2].split(":")[1]
        param["password"] = cmd_option[3].split(":")[1]
        param["updown"] = cmd_option[4].split(":")[1]

        if dire == "ul":
            param["fileSize"] = "50"

        self.ue_details[alias]['kill'] = ""
        uc_test_name = "uc_FTP_" + param["updown"] + "_" + str(alias)
        testid = self.tcobject._create_start_case(uc_test_name, call_type, param, imei, header)
        self.ue_details[alias]['testId'] = testid[imei]
        self.ue_details[alias]['count'] = int(time.time())

    def _stop_datatransfer(self, alias, header):
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        self.ucapi._UC_StopCall(self.ue_details[alias]['testId'], imei, header)

    def _calculate_throughtput(self, alias, dire, value, deviation, header):
        time.sleep(5)
        url = "https://" + self.server_ip + \
              "/api/results/single/result/" + self.ue_details[alias]['testId']
        response = self.ucapi._Get(url, header)
        response = response.json()
        tputvalue = None
        print(dire)
        for i in range(0, len(response['data'])):
            if response['data'][i]['phase'] == "completed":
                try:
                    tputvalue = response['data'][i]['result']['average']
                except Exception as e:
                    print(i)
                    print(response['data'][i]['result'])
                    print(e)
                break
        if tputvalue is not None:
            deviation_value = int(value) * (int(deviation)) / 100
            print("********************* Avg acheived " + str(dire) +
                  " throughput was: " + str(tputvalue) + "**********")
            min_value = int(value) - deviation_value
            max_value = int(value) + deviation_value
            if (int(tputvalue) <= max_value and int(tputvalue) >= min_value):
                print("thrughtput validation passed " + str(tputvalue))
                return (tputvalue, "", response)
            else:
                raise Exception("thrughput validation failed "
                                + str(tputvalue))
        else:
            raise Exception("data transfer is still running, can not calculate throughput")

    def _check_call_is_alive(self, alias, header):
        url = "https://" + self.server_ip + \
              "/api/results/single/result/" + self.ue_details[alias]['testId']
        response = self.ucapi._Get(url, header)
        print(response)
        phase = ""
        response = response.json()
        for i in range(0, len(response['data'])):
            phase = response['data'][i]['phase']
            status = response['data'][i]['status']
        return phase

    def _await_data_transfer_finish(self, alias, dire, timeout, header):
        print(dire)
        count = self.ue_details[alias]['count'] + timeout
        while int(time.time()) < count:
            result = self._check_call_is_alive(alias, header)
            if result == "completed":
                break
            time.sleep(30)
