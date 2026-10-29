# Version: 1.0.16
from .require_ue import Requireue
from .uccalls import ucapi
from time import sleep
import paramiko


class ta_ultracaller(Requireue):
    def __init__(self):
        self._ucapi = ucapi()
        self._ue = Requireue()

    def require_ue(self, ue_alias, capabilities):
        return self._ue._require_ue(ue_alias, capabilities)

    def start_datatransfer(self, ue_alias, protocoltype, direction=None, tputcheck="yes"):
        for i in range(len(ue_alias)):
            print(protocoltype[i])
            if protocoltype[i] not in ["TCP", "UDP", "FTP", "ICMP ping", "TCP ping", "UDP ping"]:
                raise Exception("Test case name argument has been removed from "
                                "start datatranfer kyword, provide call type "
                                "TCP/UDP instead")
            self._ue._start_datatransfer(ue_alias[i], protocoltype[i], direction[i], tputcheck)

    def stop_datatransfer(self, ue_alias):
        for i in range(len(ue_alias)):
            self._ue._stop_datatransfer(ue_alias[i])

    def attach_ue(self, ue_alias):
        for alias in ue_alias:
            self._ue._attach_ue(alias)

    def detach_ue(self, ue_alias):
        for alias in ue_alias:
            self._ue._detach_ue(alias)

    def await_data_transfer_finish(self, ue_alias, direction, timeout=[300]):
        for i in range(len(ue_alias)):
            self._ue._await_data_transfer_finish(ue_alias[i], direction[i], int(timeout[i]))

    def calculate_thrughtput(self, ue_alias, direction, thrughtput, deviation):
        out_put = {}
        for i in range(len(ue_alias)):
            out_put[ue_alias[i]] = {}
            out_put[ue_alias[i]]["tputvalue"], out_put[ue_alias[i]]["maxtput"], out_put[ue_alias[i]]["response"] = \
                self._ue._uc_thrughtput(ue_alias[i], direction[i], thrughtput[i], deviation[i])
        return out_put

    def Reboot_UE(self, ue_alias):
        for alias in ue_alias:
            self._ue._reboot_ue(alias)

    def start_voice_call(self, ue_alias, testcasename):
        for i in range(len(ue_alias)):
            self._ue._voice_call_start(ue_alias[i], testcasename)

    def stop_voice_call(self, ue_alias):
        for i in range(len(ue_alias)):
            self._ue._voice_call_stop(ue_alias[i])

    def stop_allvoicecall(self, ue_alias):
        for i in range(len(ue_alias)):
            self._ue._voice_CallStopAll(ue_alias[i])

    def run_adb_command(self, ue_alias, adb_command):
        out_put = {}
        for i in range(len(ue_alias)):
            print(adb_command[i])
            out_put[ue_alias[i]] = self._ue._run_adbcommand(ue_alias[i], adb_command[i])
        return out_put

    def emergency_call(self, ue_alias, ip, username, password, adb_command):
        out_put = {}
        adb_command = ((adb_command.split("[")[-1]).split("]")[0]).split(",")
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        # ip = "10.53.164.243"
        ssh.connect(ip, port=22, username=username, password=password)
        for i in adb_command:
            print(i)
            # out_put[ue_alias] = self._ue._run_adbcommand(ue_alias, i)
            if "2241" in i:
                sleep(6)
            ssh.exec_command(i)
            sleep(2)
        # return out_put

    def validate_ue_info(self, ue_alias, info, expected_value):
        out_put = {}
        for i in range(len(ue_alias)):
            out_put[ue_alias[i]] = self._ue._validate_ue_info(ue_alias[i], info, expected_value)
        return out_put
