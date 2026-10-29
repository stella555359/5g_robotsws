import time
import paramiko


class iperf_data_transfer(object):
    def __init__(self, tcobject,  uccall, set_obj):
        self.tcobject = tcobject()
        self.ucapi = uccall()
        self.ue_details = {}
        self.obj = set_obj()
        self.server_ip = ""

    def _check_port(self, alias, port_value, port, max_port):
        cmd = "netstat -alnp"
        output = self.obj._ssh_connect(self.ue_details[alias]['host'],
                                       self.ue_details[alias]['user'],
                                       self.ue_details[alias]['pwd'], cmd)
        if str(port_value) not in output:
            print(str(port_value) + " is avaialble")
            return port_value
        else:
            print(str(port_value) + " is  not avaialble")

        for port in range(port, max_port):
            if str(port) not in output:
                print(str(port) + " is avaialble")
                break
            else:
                print(str(port) + " cannot be used")
        return port

    def _commandexecution(self, param, alias, client_cmd1, server_cmd, time_value, imei, tputcheck, header, dire):
        if dire == "dl":
            param["command"] = server_cmd
            uc_test_name = "uc_iperf_"+dire+"test_" + str(alias)
            self.kill_cmd = client_cmd1
            cmd = "nohup " + self.kill_cmd + " & tail -f nohup.out"
            print("***********************", server_cmd, cmd)
            self.ue_details[alias]['count'] = int(time.time())
            uc_testid = self.tcobject._create_start_case(uc_test_name, "Iperf", param, imei, header)
            self.ue_details[alias]['uc_testid'] = uc_testid[imei]
            time.sleep(15)
            self.ue_details[alias]['kill'] = self.kill_cmd
            client_status = False
            for i in range(2):
                output = self.obj._ssh_connect(self.ue_details[alias]['host'],
                                               self.ue_details[alias]['user'],
                                               self.ue_details[alias]['pwd'], cmd)
                if "connect failed" in output:
                    time.sleep(5)
                    print("retrying again to start iperf client")
                else:
                    client_status = True
                    break
            if not client_status:
                raise Exception("failed to start iperf client")
        else:
            param["command"] = client_cmd1
            uc_test_name = "uc_iperf_"+dire+"test_" + str(alias)
            self.kill_cmd = server_cmd
            cmd = "nohup "+self.kill_cmd + " &"
            print("***********************", client_cmd1, cmd)
            self.ue_details[alias]['kill'] = self.kill_cmd
            self.obj._ssh_connect(self.ue_details[alias]['host'],
                                  self.ue_details[alias]['user'],
                                  self.ue_details[alias]['pwd'], cmd)
            self.ue_details[alias]['count'] = int(time.time())
            uc_testid = self.tcobject._create_start_case(uc_test_name, "Iperf", param, imei, header)
            self.ue_details[alias]['uc_testid'] = uc_testid[imei]
        if (tputcheck == "yes"):
            param = {}
            param["duration"] = int(time_value)
            tc_thruput = "uc_device_tput_"+dire+"_"+str(alias)
            testid = self.tcobject._create_start_case(tc_thruput, "Device throughput", param, imei, header)
            self.ue_details[alias]['testId'] = testid[imei]
            print("%%%%%%%%%%%%%%%%%"+dire+str(self.ue_details[alias]['testId']))

    def _start_datatransfer(self, ue_details, alias, call_type, dire, tputcheck, header):
        self.ue_details = ue_details
        self.server_ip = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['uc_server_Ip']
        iperf_inputs = [i for i in self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']
                        ['configuration']
                        ['data_transfer'].keys() if "iperf" in i]
        iperf_command = iperf_inputs[0].split("_")[0]
        iperf_details = iperf_inputs[0].split("_")[0]+"_"+call_type.lower()
        if call_type == "TCP":
            iperf_option = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS'][
                'configuration']['data_transfer'][iperf_details]
            cmd_option = iperf_option.split(" ")
            time_value = cmd_option[1].split(":")[1]
            port_value = cmd_option[0].split(":")[1]
        elif call_type == "UDP":
            iperf_option = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS'][
                'configuration']['data_transfer'][iperf_details]
            cmd_option = iperf_option.split(" ")
            time_value = cmd_option[3].split(":")[1]
            port_value = cmd_option[0].split(":")[1]

        global port
        pp = self._check_port(alias, port_value, port=53001, max_port=53900)
        iperf_option = (iperf_option.replace(time_value, str(int(time_value) + 30))).replace("'", "")
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        iperf_option = iperf_option.replace(port_value, str(pp))
        command_option = iperf_option.replace(":", " ")
        param = {}
        # param["duration"] = int(time_value) - 30
        print("********", dire, call_type)
        client_cmd = ''
        if dire == "ul":
            if call_type == "UDP":
                client_cmd = iperf_command+" -u -c " + self.ue_details[alias]["host"] + \
                             " " + command_option + " -fm"
                server_cmd = iperf_command+" -s -p " + str(pp)
            else:
                client_cmd = iperf_command+" -c " + self.ue_details[alias]["host"] + \
                             " " + command_option
                server_cmd = iperf_command+" -s -i 1 -p " + str(pp)
        if dire == "dl":
            if call_type == "UDP":
                client_cmd = iperf_command+" -u -c " + self.ue_details[alias]["ueip"] + \
                             " " + command_option + " -fm"
                server_cmd = iperf_command+" -s -p " + str(pp)
            else:
                client_cmd = iperf_command+" -c " + self.ue_details[alias]["ueip"] + \
                             " " + command_option
                server_cmd = iperf_command+" -s -i 1 -p " + str(pp)
        self._commandexecution(param, alias, client_cmd, server_cmd, time_value, imei, tputcheck, header, dire)

    def _stop_datatransfer(self, alias, header):
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        self.ucapi._UC_StopCall(self.ue_details[alias]['testId'], imei, header)
        time.sleep(5)
        self.ucapi._UC_StopCall(self.ue_details[alias]['uc_testid'], imei, header)
        try:
            cmd_kill = "pkill -9 -f -x " + "\"" + \
                       self.ue_details[alias]['kill'] + "\""
            self.obj._ssh_connect(self.ue_details[alias]['host'],
                                  self.ue_details[alias]['user'],
                                  self.ue_details[alias]['pwd'],
                                  cmd_kill)
        except Exception as e:
            print(e)
            pass

    def _calculate_throughtput(self, alias, dire, value, deviation, header):
        time.sleep(10)
        print("slept 40")
        url = "https://" + self.server_ip + \
              "/api/results/single/result/" + self.ue_details[alias]['testId']
        response = self.ucapi._Get(url, header)
        response = response.json()
        tputvalue = None
        maxtput = 0
        self.obj._ssh_close()
        print(response)
        for i in range(0, len(response['data'])):
            if response['data'][i]['phase'] == "completed":
                try:
                    if dire == "ul":
                        tputvalue = response['data'][i]['result']['averageUL']
                        maxtput = response['data'][i]['result']['maxUL']
                    elif dire == "dl":
                        tputvalue = response['data'][i]['result']['averageDL']
                        maxtput = response['data'][i]['result']['maxDL']
                except Exception as e:
                    print(i)
                    print(response['data'][i]['result'])
                    print(e)
                break
        if tputvalue is not None:
            deviation_value = int(value) * (int(deviation)) / 100
            print("********************* max acheived " + str(dire) +
                  " throughput was: " + str(maxtput) + "**********")
            min_value = int(value) - deviation_value
            max_value = int(value) + deviation_value
            if (int(tputvalue) <= max_value and int(tputvalue) >= min_value):
                print("thrughtput validation passed " + str(tputvalue))
                return (tputvalue, maxtput, response)
            else:
                print(tputvalue)
                raise Exception("thrughput validation failed "
                                + str(tputvalue))
        else:
            raise Exception("data transfer is still running, can not calculate throughput")

    def _check_data_transfer_is_alive(self, alias):
        cmd_check = "ps -ef | grep \"" + self.ue_details[alias]['kill'] + "\""

        output = self.obj._ssh_connect(self.ue_details[alias]['host'],
                                       self.ue_details[alias]['user'],
                                       self.ue_details[alias]['pwd'], cmd_check)
        if len(output) > 2:
            return True
        else:
            return False

    def _check_call_is_alive(self, alias, header):
        url = "https://" + self.server_ip + \
              "/api/results/single/result/" + self.ue_details[alias]['testId']
        response = self.ucapi._Get(url, header)
        response = response.json()
        print(response)
        phase = ""
        for i in range(0, len(response['data'])):
            phase = response['data'][i]['phase']
            status = response['data'][i]['status']
        return phase

    def _await_data_transfer_finish(self, alias, dire, timeout, header):
        count = self.ue_details[alias]['count'] + timeout
        while int(time.time()) < count + 30:
            if dire == "dl":
                result = self._check_data_transfer_is_alive(alias)
                if not result:
                    if int(time.time()) < count:
                        raise Exception("data transfer is not running")
            else:
                result = self._check_call_is_alive(alias, header)
                if result == "completed":
                    if int(time.time()) < count:
                        raise Exception("data transfer is not running")
            time.sleep(30)
