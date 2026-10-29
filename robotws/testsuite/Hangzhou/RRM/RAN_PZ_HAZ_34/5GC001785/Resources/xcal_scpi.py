# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2023/1/16 17:59
import logging
import os
import time

from robot.libraries.BuiltIn import BuiltIn
import taf.transport.ssh as ssh


class XcalClient:
    def __init__(self, index=0, **kwargs):
        """
        Init ue config from ROBOTFRAMEWORK BuiltIn
        :param index: ue index of ${tl.ues} , count from 0
        :param **kwargs: ue config from input
               :config port: socket port default 5025
               :config host: controlpc host ip
               :config username: controlpc ssh username
               :config password: controlpc ssh password
               :config apppath: software install path on controlpc
               :config imsi: ue imsi
               :config appserver: DL/UL appserver
        :return: None
        """
        try:
            varstr = "${tl.ues[" + str(index) + "]}"
            ueobj = BuiltIn().get_variable_value(varstr)
            self.ue_config = {
                "port": 5025,
                "host": ueobj.ssh_connection_details.addr,
                "username": ueobj.ssh_connection_details.username,
                "password": ueobj.ssh_connection_details.password,
                "apppath": ueobj.server_dir,
                "imsi": ueobj.imsi,
                "sn": ueobj.serial_number,
                "appserver": ueobj.iperf_details,
            }
        except BaseException as error:
            logging.info(
                "init config from robot testline failed : {}".format(
                    str(error)))
            self.ue_config = kwargs
        logging.info(self.ue_config)

    def startapp(self, dur=10, timeout=300):
        """
        Start App by schtasks cmd
        :param dur: check TA port setup interval time (s)
        :param timeout: check TA port setup timeout (s)
        """
        dur = int(dur)
        timeout = int(timeout)
        sshconn = ssh.ssh()
        ta_status_cmd = "netstat -ano|findstr :{}".format(
            self.ue_config['port'])
        check_app_status = "tasklist | findstr XCAL5.exe"
        restart_cmds = [
            "taskkill /f /im XCAL5.exe",
            "schtasks /end /tn XCAL5",
            "schtasks /delete /tn XCAL5 /f",
            "schtasks /create /tn XCAL5 /sc once /tr '{}' /st 17:36 /RL highest /f".format(
                self.ue_config['apppath']),
            "schtasks /run /tn XCAL5"]
        print(self.ue_config['apppath'])
        try:
            res = sshconn.connect_to(
                self.ue_config['host'],
                self.ue_config['username'],
                self.ue_config['password'],
                alias='XCAL')
            print("SSH to Control PC success:{}".format(str(res)))
        except BaseException as error:
            print("SSH to Control PC Error : {}".format(str(error)))
            pingcmd = "ping -c 4 {} >ping.txt".format(self.ue_config['host'])
            print(pingcmd)
            os.system(pingcmd)
            with open('ping.txt', 'r') as f:
                print(f.read())
        else:
            xcal_port = sshconn.execute(command=ta_status_cmd, connection='XCAL')
            if ":{}".format(self.ue_config['port']) in xcal_port:
                app_status = sshconn.execute(command=check_app_status, connection='XCAL')
                if "XCAL5.exe" in app_status:
                    print("XCAL5.exe is already opened!")
                else:
                    for cmd in restart_cmds:
                        sshconn.execute(command=cmd, connection='XCAL')
                        time.sleep(2)
                    while timeout >= 0:
                        res = sshconn.execute(
                            command=ta_status_cmd, connection='XCAL')
                        if ":{}".format(self.ue_config['port']) in res:
                            break
                        else:
                            time.sleep(dur)
                            timeout = timeout - dur
                            if timeout <= 0:
                                raise Exception(
                                    "Check TA port {} timeout".format(
                                        self.ue_config['port']))
        finally:
            sshconn.disconnect(connection='XCAL')

    def close_app(self):
        close_cmd = "taskkill /f /im XCAL5.exe"
        check_app_status = "tasklist | findstr XCAL5.exe"
        sshconn = ssh.ssh()
        try:
            res = sshconn.connect_to(
                self.ue_config['host'],
                self.ue_config['username'],
                self.ue_config['password'],
                alias='XCAL')
            print("SSH to Control PC success:{}".format(str(res)))
        except BaseException as error:
            print("SSH to Control PC Error : {}".format(str(error)))
            pingcmd = "ping -c 4 {} >ping.txt".format(self.ue_config['host'])
            print(pingcmd)
            os.system(pingcmd)
            with open('ping.txt', 'r') as f:
                print(f.read())
        else:
            sshconn.send_command(command=close_cmd, connection='XCAL')
            for t in range(20):
                time.sleep(1)
                app_status = sshconn.execute(command=check_app_status, connection='XCAL')
                if "XCAL5.exe" not in app_status:
                    print("XCAL5.exe is already closed!")
                    break
        finally:
            sshconn.disconnect(connection='XCAL')


class XcalCommon:
    def __init__(self):
        pass

    @staticmethod
    def get_mos_value(output):
        list_mos_value = []
        print(output)
        list_mos_line = output.split("\n")
        print(list_mos_line)
        for mos_line in list_mos_line:
            if mos_line.__contains__("_mos"):
                list_mos_value.append(float(mos_line.split(":")[1].strip()))
        return list_mos_value

    @staticmethod
    def get_min_mos_value(output):
        list_min_mos_value = []
        print(output)
        list_mos_line = output.split("\n")
        print(list_mos_line)
        for mos_line in list_mos_line:
            if mos_line.__contains__("_minmos"):
                list_min_mos_value.append(float(mos_line.split(":")[1].strip()))
        return list_min_mos_value
