import os
import time
import yaml
from .data_transfer.ftp_data import ftp_data_transfer
from .data_transfer.iperf_data import iperf_data_transfer
from .data_transfer.ping_data import ping
from .setting import *
from .uccalls import *


global port


class Requireue(setting):
    def __init__(self):
        self.ue_details = {}
        self.kill_cmd = 'iperf'
        self.header = ""
        self.server_ip = ""
        self.token = ""
        self.uc_test_name = ""

    def _require_ue(self, ue_alias, ue_characteristics):
        ue_config_path = self._get_config_from_environment_variable()
        # ue_config_path = "C:\\Users\\cthati\\Downloads\\ta_ue_config (1).yaml"
        if len(ue_alias) != len(ue_characteristics):
            raise Exception("there is a length mismatch "
                            "between alias and ue_charesteristics")
        if not os.path.exists(ue_config_path):
            raise Exception('ue configuration path not exist')
        with open(ue_config_path, 'r') as config_file:
            ue_config = yaml.safe_load(config_file)
        try:
            for i in range(len(ue_alias)):
                self.ue_details[ue_alias[i]] = \
                    (create_constructor(ue_alias[i], ue_config,
                                        ue_characteristics[i]).__dict__)['ue_details'][ue_alias[i]]
            print(self.ue_details)
            try:
                BuiltIn().set_suite_variable('${ue_details}', self.ue_details)
                self.ue_details = BuiltIn().get_variable_value('${ue_details}')
            except Exception as e:
                print("$$$$$$$$$$$$$$$"+str(e))
                pass
            return self.ue_details
        except Exception as e:
            raise Exception("please check the ue configuration "
                            "file and the CAPABILITIES defined " + str(e))

    def _createHeaders(self):
        headers = {"Host": self.server_ip, "Content-Type": "application/json",
                   "Authorization": "Bearer " + self.token}
        return headers

    def _voice_call_start(self, alias, testcasename):
        self.server_ip = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['uc_server_Ip']
        self.token = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['token']
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        self.header = self._createHeaders()
        self.test_id = uccalls()._UC_StartCall(testcasename, imei,
                                               "Voice Call", self.header)

    def _voice_call_stop(self, alias):
        self.server_ip = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['uc_server_Ip']
        self.token = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['token']
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        self.header = self._createHeaders()
        uccalls()._UC_StopCall(self.test_id[imei], imei, self.header)

    def _voice_CallStopAll(self, alias):
        self.server_ip = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['uc_server_Ip']
        self.token = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['token']
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        self.header = self._createHeaders()
        uccalls()._UC_CallStopAll(imei, self.header)

    def _attach_ue(self, alias):
        self.server_ip = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['uc_server_Ip']
        self.token = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['token']
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        self.header = self._createHeaders()
        param = {"onOff": "enable", "duration": "40"}
        create_tc()._create_start_case("uc_Airplane_Mode_Onofff_"+alias, "Airplane mode", param, imei, self.header)
        time.sleep(50)
        url = "https://" + self.server_ip + "/api/ues?imei=" + imei
        start_time = time.time()
        while (True):
            cellid = self._get_cellid(url, imei, alias)
            if cellid is not None:
                break
            else:
                remaining = time.time() - start_time
                if remaining > 180:
                    raise Exception("device ID is notavailale")
                    break

    def _get_cellid(self, url, imei, alias):
        time.sleep(10)
        response = uccalls()._UC_General(url, imei,
                                         url_type='GET', header=self.header)
        print(response)
        for i in range(0, len(response)):
            try:
                if 'CID' in response[i]['location']['signalInfo']:
                    rmnet = response[0]["currentNetworkInterface"]
                    self.ue_details[alias]["ueip"] = [
                        ip for ip in response[0]["interfaceList"][rmnet]
                        if ip.startswith("10.")][0]
                    return response[0]['location']['signalInfo']['CID']
                else:
                    return None
            except Exception as e:
                print("Exception", e)

    def _kill_iperf(self, cmd, alias):
        self._ssh_connect(self.ue_details[alias]['host'],
                          self.ue_details[alias]['user'],
                          self.ue_details[alias]['pwd'],
                          cmd)

    def _delete_test(self, test, header):
        try:
            res = uccalls()._UC_delete_test(test, header)
        except Exception as e:
            print(e)
        time.sleep(1)

    def _detach_ue(self, alias):
        self.server_ip = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['uc_server_Ip']
        self.token = self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['configuration']['token']
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        self.header = self._createHeaders()
        time.sleep(5)
        uccalls()._UC_CallStopAll(imei, self.header)
        try:
            cmd_kill = "pkill -9 -f -x " + "\"" + \
                       self.ue_details[alias]['kill'] + "\""
            self._kill_iperf(cmd_kill, alias)
        except Exception as e:
            print(e)
            pass
        self._delete_uctest("uc_Airplane_Mode_Onofff_" + str(alias), self.header)
        self._delete_uctest("uc_device_tput_ul_" + str(alias), self.header)
        self._delete_uctest("uc_device_tput_dl_" + str(alias), self.header)
        self._delete_uctest("uc_iperf_ultest_" + str(alias), self.header)
        self._delete_uctest("uc_iperf_dltest_" + str(alias), self.header)
        self._delete_uctest("uc_FTP_download_" + str(alias), self.header)
        self._delete_uctest("uc_FTP_upload_" + str(alias), self.header)
        self._delete_uctest("uc_ICMP_PING_" + str(alias), self.header)
        self._delete_uctest("uc_TCP_PING_" + str(alias), self.header)

    def _delete_uctest(self, tc_name, header):
        try:
            self._delete_test(tc_name, header)
        except Exception as e:
            print(e)
            pass

    def _start_datatransfer(self, alias, call_type, dire=None, tputcheck="yes"):
        print(call_type)
        protocol = {"TCP": iperf_data_transfer,
                    "UDP": iperf_data_transfer,
                    "FTP": ftp_data_transfer,
                    "ICMP ping": ping,
                    "TCP ping": ping,
                    "UDP ping": ping}
        self.data_transfer = protocol[call_type](create_tc, uccalls, setting)
        return (self.data_transfer._start_datatransfer(self.ue_details, alias, call_type, dire, tputcheck, self.header))

    def _stop_datatransfer(self, alias):
        return (self.data_transfer._stop_datatransfer(alias, self.header))

    def _uc_thrughtput(self, ue_alias, direction, thrughtput, deviation):
        return (self.data_transfer._calculate_throughtput(ue_alias, direction, thrughtput, deviation, self.header))

    def _await_data_transfer_finish(self, alias, direction, timeout=300):
        self.data_transfer._await_data_transfer_finish(alias, direction, timeout, self.header)

    def _reboot_ue(self, alias):
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        self.header = self._createHeaders()
        response = uccalls()._UC_Reboot(imei, self.header)
        response = response.json()
        if response["status"] == "success":
            print("reset request successfull")
        else:
            print("reset rerquest not successfull")
        time.sleep(120)

    def _run_adbcommand(self, alias, adb_command):
        ip = self.ue_details[alias]['ue_pc_ip']
        output = self._ssh_connect(ip, "inbabtslabuser", "BT5l@bus3rl0g1n",
                                   adb_command)
        time.sleep(10)
        return output

    def _validate_ue_info(self, alias, info, expected_value=""):
        imei = str(self.ue_details[alias]['CONSTRUCTOR_PARAMETERS']['imei'])
        url = "https://" + self.server_ip + "/api/ues?imei=" + imei
        self.header = self._createHeaders()
        time.sleep(5)
        response = uccalls()._UC_General(url, imei,
                                         url_type='GET', header=self.header)
        ue_info = {"CELL_ID": "['location']['signalInfo']['CID']",
                   "MCC": "['location']['signalInfo']['MCC']",
                   "MNC": "['location']['signalInfo']['MNC']",
                   "LAC": "['location']['signalInfo']['LAC']",
                   "PCI": "['location']['signalInfo']['PSC']",
                   "SIGNAL_STRENGTH": "['location']['signalInfo']['SS']",
                   "UE_OS_VER": "androidRelease", "DEVICE_MODEL": "deviceModel"}
        if expected_value == "":
            return response[0]
        for i in range(0, len(response)):
            if info == "IP":
                try:
                    actual_value = response[0]['clientIpAddr'][0]
                except IndexError:
                    actual_value = response[0]['clientIpAddr'][1]
            else:
                actual_value = eval("response[i]" + ue_info[info])
            if str(actual_value) != str(expected_value):
                raise Exception("actaul value " + str(actual_value) +
                                " not matching with expected value " +
                                str(expected_value))


class create_constructor():
    def __init__(self, ue_alias, ue_config, ue_characteristics):
        self.ue_details = {}
        for key, value in (ue_config['UE_POOLS']['AndroidUePool']['inline_config']).items():
            if ue_characteristics in \
                    ue_config['UE_POOLS']['AndroidUePool']['inline_config'][key]['CAPABILITIES']:
                server_ip = value['CONSTRUCTOR_PARAMETERS']['configuration']['uc_server_Ip']
                token = value['CONSTRUCTOR_PARAMETERS']['configuration']['token']
                alias = ucapi()._addingtoken(server_ip, token)
                value[ue_alias] = alias
                self.ue_details[ue_alias] = value.copy()
                self.ue_details[ue_alias]['host'] = \
                    self.ue_details[ue_alias][
                        'CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['ssh']['host']
                self.ue_details[ue_alias]['user'] = \
                    self.ue_details[ue_alias][
                        'CONSTRUCTOR_PARAMETERS'][
                        'configuration']['data_transfer']['ssh']['user']
                self.ue_details[ue_alias]['pwd'] = \
                    self.ue_details[ue_alias][
                        'CONSTRUCTOR_PARAMETERS']['configuration']['data_transfer']['ssh']['password']
                self.ue_details[ue_alias]['kill'] = 'iperf'
                self.ue_details[ue_alias]['ue_pc_ip'] = \
                    self.ue_details[ue_alias]['CONSTRUCTOR_PARAMETERS']['configuration']['ue_pc_ip']
                break


class create_tc(object):
    def _create_start_case(self, testcasename, test, param, imei, header):
        # header = Requireue()._createHeaders()
        try:
            uccalls()._UC_create_test(testcasename,
                                      test, param, header)
        except Exception as e:
            print(str(e))
            pass
        uc_testid = uccalls()._UC_StartCall(testcasename, imei,
                                            test, header)
        return uc_testid
