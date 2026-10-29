from taf.gnb.oam.coam.vdu.interface import Vdu
from datetime import datetime
import paramiko
import fileinput
import pexpect
import sys
import os
import string
import time
import re
import yaml
from CommonClass import sFTP_Logs
from CommonClass import Cmd_Executor
from yaml.loader import SafeLoader
import xml.etree.ElementTree as ET


class CprtMonitoring(sFTP_Logs, Cmd_Executor):
    def __init__(self, envtype, SMOD, localpath=None):
        self.EnvType = envtype
        self.smod = SMOD
        self.object = self._getinfo()
        self.ip = self.object.get('Ipaddress')
        self.Uname = self.object.get('UserName')
        self.passw = self.object.get('PassWord')
        self.remotepath = self.object.get(self.smod).get('remote_path')
        self.localpath = localpath
        sFTP_Logs.__init__(self, self.remotepath, self.localpath)
        Cmd_Executor.__init__(self, self.ip, self.Uname, self.passw)

    def cprt_monitoring_start_asoe(self):
        # CprtLogincmd = self.object.get(self.smod).get("cprtlogincmd")
        # self.exec_cmd(CprtLogincmd,"GNB")
        cmd_lst = self.object.get(self.smod).get("Cmd_enable_Asoe")
        self.expect_list(cmd_lst, "GNB")

    def cprt_monitoring_stop_collect_asoe(self):
        cmd_lst = self.object.get(self.smod).get("Cmd_disable_Asoe")
        self.exec_cmd_list(cmd_lst, "GNB")
        self.sFTP_Files()

    def cprt_monitoring_start_asoh(self):
        cmd_lst = self.object.get(self.smod).get("Cmd_enable_Asoh")
        self.expect_list(cmd_lst, "GNB")

    def cprt_monitoring_stop_collect_asoh(self):
        cmd_lst = self.object.get(self.smod).get("Cmd_disable_Asoh")
        self.exec_cmd_list(cmd_lst, "GNB")
        self.sFTP_Files()

    def cprt_monitoring_start_asik(self):
        cmd_lst = self.object.get(self.smod).get("Cmd_enable_Asik")
        # self.exec_cmd("sshenb","GNB")
        self.expect_list(cmd_lst, "GNB")

    def cprt_monitoring_stop_collect_asik(self):
        cmd_lst = self.object.get(self.smod).get("Cmd_disable_Asik")
        # self.exec_cmd("sshenb","GNB")
        self.expect_list(cmd_lst, "GNB")
        self.sFTP_Files()

    def cprt_monitoring_start_asib(self):
        cmd_lst = self.object.get(self.smod).get("Cmd_enable_Asib")
        for _ in cmd_lst:
            self.exec_cmd_bg(_, "GNB")
        # self.exec_cmd_bg(cmd_lst, "GNB")

    def cprt_monitoring_stop_collect_asib(self):
        Killcmd = self.object.get(self.smod).get("killTcpcmd")
        self.exec_cmd(Killcmd, "GNB")
        self.sFTP_Files()

    def _getinfo(self):
        dir_path = os.path.dirname(os.path.realpath(__file__))
        with open(dir_path + '/' + 'abstract.yaml') as f:
            data = yaml.load(f, Loader=SafeLoader)
            return data['CPRTMon'][self.EnvType]


#######################################################################################################################


def CPRT_Monitoring_Start_ASOE():
    x = CprtMonitoring("gNB", "ASOE")
    x.cprt_monitoring_start_asoe()
    del x


def CPRT_Monitoring_Stop_Collect_ASOE(local_path):
    y = CprtMonitoring("gNB", "ASOE", localpath=local_path)
    y.cprt_monitoring_stop_collect_asoe()
    del y


#######################################################################################################################


def CPRT_Monitoring_Start_ASOH():
    x = CprtMonitoring("gNB", "ASOH")
    x.cprt_monitoring_start_asoh()
    del x


def CPRT_Monitoring_Stop_Collect_ASOH(local_path):
    y = CprtMonitoring("gNB", "ASOH", localpath=local_path)
    y.cprt_monitoring_stop_collect_asoh()
    del y


#######################################################################################################################


def CPRT_Monitoring_Start_ASIK():
    a = CprtMonitoring("gNB", "ASIK")
    a.cprt_monitoring_start_asik()
    del a


def CPRT_Monitoring_Stop_Collect_ASIK(local_path):
    b = CprtMonitoring("gNB", "ASIK", localpath=local_path)
    b.cprt_monitoring_stop_collect_asik()
    del b


#######################################################################################################################


def CPRT_Monitoring_Start_ASIB():
    p = CprtMonitoring("gNB", "ASIB")
    p.cprt_monitoring_start_asib()
    del p


def CPRT_Monitoring_Stop_Collect_ASIB(local_path):
    q = CprtMonitoring("gNB", "ASIB", localpath=local_path)
    q.cprt_monitoring_stop_collect_asib()
    del q


def WTS_Clear(wts_path):
    # Author: Vivek.gv@nokia.com
    # This function kills WTS On VM
    cmd_list = [
        "sudo pkill -9 egate",
        "sudo pkill -9 edaemon",
        "rm -f " + os.path.join(wts_path, '', '') + "*log*"
    ]
    for cmd in cmd_list:
        print(cmd)
        os.system(cmd)


def Create_Folder(path):
    # Author: Vivek.gv@nokia.com
    # This function creat's folder
    try:
        os.makedirs(path)
    except Exception as e:
        print("Exception ", e, "occured.")


def Get_SOS_Report(wts_path):
    # Author: Bhuvaneshwari.sikkargol@nokia.com
    # This function generates sos report on WTS
    wts_path = os.path.join(wts_path, "")
    for line in fileinput.input(wts_path + 'sosReport.cfg', inplace=True):
        if line.startswith('LONER_VERSION'):
            print('LONER_VERSION=E')
        elif line.startswith('PHONER_VERSION'):
            print('PHONER_VERSION=PH7')
        elif line.startswith('L1_MODE'):
            print('L1_MODE=fullstack')
        else:
            print(line.strip())
    cmd = wts_path + 'sosReport.sh -c -s -nr'
    os.system(cmd)


def AP_Reboot_Wait_For_Connection(WaitTimeInSecs):
    ap_ip = '192.168.200.1'
    p = paramiko.SSHClient()
    p.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    p.connect(ap_ip, port=22, username='toor4nsn', password='oZPS0POrRieRtu')
    stdin, stdout, stderr = p.exec_command('reboot')
    opt = stdout.readlines()
    opt = "".join(opt)
    print(opt)
    RebootTime = datetime.now()
    TimeLapsed = 0
    time.sleep(60)
    while TimeLapsed <= int(WaitTimeInSecs):
        response = os.system("ping -c 1 " + ap_ip)
        if response == 0:
            print("AirPhone Reachable")
            break
        time.sleep(10)
        TimeLapsed = (datetime.now() - RebootTime).total_seconds()
        print("TimeLapsed " + str(TimeLapsed))
    if response != 0 and TimeLapsed > WaitTimeInSecs:
        raise Exception("AirPhone is not reachable after reboot")


def Verify_RMODs_Are_Enabled(oam_ip, WaitTimeInSecs):
    vdu = Vdu()
    RebootTime = datetime.now()
    TimeLapsed = 0
    while TimeLapsed <= int(WaitTimeInSecs):
        vdu.connect_to(host=oam_ip, port='', username='Nemuadmin', password='nemuuser', secure=True)
        info = vdu.get_rmods_status()
#        print(info)
        vdu.disconnect()
        Num_Rmod = len(info)
        NumOfEnabled = 0
        for RMOD in info:
            if RMOD['operational_state'] == 'enabled' and RMOD['procedural_status'] == 'configured':
                NumOfEnabled += 1
        if Num_Rmod == NumOfEnabled:
            break
        time.sleep(10)
        TimeLapsed = (datetime.now() - RebootTime).total_seconds()
        print("TimeLapsed " + str(TimeLapsed))
    if Num_Rmod == NumOfEnabled and TimeLapsed > WaitTimeInSecs:
        print(info)
        raise Exception("=== RMODs not in operational state ===")
    else:
        print("=== RMODs Are In Enabled State ===")


def Get_AMF_Local_Ip_Status():
    lst = ["10.0.1.1", "10.0.1.2"]
    cmd = "sudo ip addr show eth3"
    resp = os.system(cmd)
    print(resp)
    dump = os.popen(cmd).read()
    print(dump)
    for ip in lst:
        response = os.system("ping -c 1 " + ip)
        if response == 0:
            print(ip, "Reachable")
        else:
            print(ip, "Not Reachable")


def Get_cGNB_System_Status():
    # Author: 		Vivek GV (vivek.gv@nokia.com)
    # Description: 	This classical gNB script dumps the status of all
    # RMOD,BBPOOL,NRBTS and NRCELLs
    tree = ET.parse('RuntimeStatus.xml')
    myroot = tree.getroot()
    count = 0
    PatternClassList = ["com.nokia.srbts.nrbts:NRBTS",
                        "com.nokia.srbts.nrbts:NRCELL",
                        "com.nokia.srbts.eqmr:RMOD_R",
                        "com.nokia.srbts.mnl:BBPOOL"]
    for level1 in myroot[0]:
        distname = level1.attrib.get('distName', None)
        classname = level1.attrib.get('class', None)
        for pattern in PatternClassList:
            if classname == pattern:
                print('\n' + '-'*30)
                print(classname)
                print(distname)
                print('-'*30)
                for level2 in myroot[0][count]:
                    # print(level2.tag, level2.attrib, level2.text)
                    name = level2.attrib.get('name', None)
                    value = level2.text
                    print('   ' + name + ' = ' + value)
        count = count + 1
#   print('-'*60)
#   print(ET.dump(myroot))


def Add_WTS_Ipaddr_At_VM():
    # Author:       Vivek GV (vivek.gv@nokia.com)
    # Description:  This keyword add's ipaddress at VM.
    IpList = ["sudo ip addr add 10.0.1.131/24 dev eth3",
              "sudo ip addr add 10.0.1.132/24 dev eth3",
              "sudo ip addr add 10.0.1.133/24 dev eth3",
              "sudo ip addr add 10.0.1.134/24 dev eth3",
              "sudo ip addr add 10.0.1.135/24 dev eth3",
              "sudo ip addr add 10.0.1.136/24 dev eth3",
              "sudo ip addr add 10.0.1.137/24 dev eth3",
              "sudo ip addr add 10.0.11.1/24 dev eth8"]
    for element in IpList:
        os.system(element)


def Get_gNB_Type():
    WaitTimeInSecs = 3
    aic_ip = '192.168.100.129'
    CurTime = datetime.now()
    TimeLapsed = 0
    num_reachable = 0
    while TimeLapsed <= int(WaitTimeInSecs):
        Reachable = False
        response = os.system("ping -c 1 " + aic_ip)
        if response == 0:
            num_reachable = num_reachable + 1
            Reachable = True
        time.sleep(1)
        TimeLapsed = (datetime.now() - CurTime).total_seconds()
        print("TimeLapsed " + str(TimeLapsed) + " Reachable " + str(Reachable))
    if num_reachable > 0:
        return 'AIC-TL'
    else:
        return 'Classical-TL'


# if __name__ == "__main__":
#    CPRT_Monitoring_Start_ASOE()
#    print('SysComDumpPid = ' +  str(SysComDumpPid))
#    print('TcpDumpPid = ' + str(TcpDumpPid))
#    time.sleep(20)
#    CPRT_Monitoring_Stop_Collect_ASOE("/home/ute/robotlte/")
#    WTS_Clear("/opt/iphy/latest/")
#    Verify_RMODs_Are_Enabled('192.168.255.129', 120)
#    Verify_RMODs_Are_Enabled('192.168.255.129', 120)
#    AP_Reboot_Wait_For_Connection(120)
#    CPRT_Monitoring_Start_ASIB()
#    x = Get_gNB_Type()
#    print("return value=" + x)
