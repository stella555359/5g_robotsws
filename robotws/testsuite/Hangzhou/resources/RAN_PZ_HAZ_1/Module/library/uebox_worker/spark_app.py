# -*- coding: utf-8 -*-

"""
:copyright: Nokia
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
:maintainer: fei.ju@nokia-sbell.com
"""

import os
import sys
import time
import json
import socket
import re
from types import SimpleNamespace
from pprint import pformat
import logging

from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem


CMD_TIMEOUT = 60

robot_obj = BuiltIn()
os_obj = OperatingSystem()


class SparkApp(object):

    AT_SIM_PLUGOUT = "AT+CFUN=0"
    AT_SIM_PLUGIN = "AT+CFUN=1"

    def __init__(self, hostname: str, port: int = 30999, logger: logging.Logger = None) -> None:
        self.hostname = hostname
        self.port = port
        self.logger = logger or logging.getLogger("UEBOX")
        self.provider = 'spark'

        curr_path = os.path.abspath(os.path.dirname(__file__))
        if curr_path not in sys.path:
            sys.path.append(curr_path)
        from uebox_pc import WinPc, PCS

        self.cpc: WinPc = None
        self.setuped = False
        self.ues = {}
        self.cmd_timeout = 60
        self._load_config()
        self.is_cygwin = self.config.ssh == 'cygwin'
        self.cpc = PCS.get(self.hostname, None)
        if self.cpc is None:
            self.cpc = WinPc(hostname, self.config.username, self.config.password, self.config.port, self.logger)
            PCS[hostname] = self.cpc

    def __repr__(self) -> str:
        return f'UeBoxApp(spark, {self.hostname}, {self.port})'

    def _get_app_server(self):
        tl = robot_obj.get_variable_value('${tl}')
        ssh = tl.appserver.iperf_details.ssh_connection_details
        return ssh.addr, ssh.username, ssh.password, ssh.port

    def _load_config(self) -> None:
        worker_path = os.path.dirname(os.path.abspath(__file__))
        fname = os.path.join(worker_path, '../../config/uebox.json')
        data = json.load(open(fname, encoding='utf-8'))
        self.config = SimpleNamespace(**data['control pc'][self.hostname])
        self.ues = self.config.uemap

    def _resp_state(self, resp: dict) -> int:
        return resp.get('Param', {}).get('State', -1)

    def _restart_app(self):
        self.cpc.execute('taskkill /f /im Spark.exe')
        self.cpc.exec_psexec(f' -s "{self.config.app_path}"')

    def _wait_until_app_is_ready(self, timeout: int = 180) -> None:
        for _ in range(timeout):
            if self.cpc.port_is_listening(self.port):
                return 0
            else:
                time.sleep(1)
        raise Exception(f'APP is not ready after {timeout} seconds')

    def wait(self, timeout: int, msg: str) -> None:
        self.logger.info(f'Wait {timeout}s for {msg}')
        time.sleep(timeout)

    def setup(self):
        if not self.setuped:
            self.logger.info(f'Setup for UEBox {self}')
            # if self.cpc.port_is_listening(self.port):
            #     try:
            #         self._disconnect_ue()
            #     except Exception:
            #         pass
            self.cpc.kill_process_by_keywords(['YHT'])
            self._restart_app()
            self._wait_until_app_is_ready()
            self.wait(30, 'AutoCheck...')
            # self.ue_count = self._auto_check()['Param']['Count']
            self.ue_count = self._auto_check_hard()
            self.wait(15, 'Connect UE...')
            self._connect_ue()
            self._poweroff()
            self.wait(10, 'PowerOn UE...')
            self._poweron()
            if len(self.ues) == 0:
                for ueindex in range(1, self.ue_count+1):
                    imsi = self._get_imsi(ueindex)
                    self.ues[imsi] = ueindex
            self.logger.info(f'Total {self.ue_count} UEs connected.')
            self.logger.debug(f'UEs:  {pformat(self.ues)}')
            self.setuped = True

    def imsi2eqindex(self, imsi: str) -> int:
        if len(imsi) == 1:
            return int(imsi)
        if imsi in self.ues:
            return self.ues.get(imsi)
        else:
            raise Exception(f'IMSI {imsi} not found in UEBox {self.hostname}')

    def _eqindex2imsi(self, index: int) -> str:
        reversed_dict = {v: k for k, v in self.ues.items()}
        return reversed_dict.get(index)

    def _exec_cmd(self, cmd: dict, timeout: int = CMD_TIMEOUT, raise_exception: bool = True) -> dict:
        def _read_cache():
            import errno
            try:
                # 一次非阻塞的读取, 假设每次读取 1024 字节
                client_socket.setblocking(False)
                while True:
                    data = client_socket.recv(1024)
                    if not data:  # 如果没有数据了，就停止读取
                        break
            except socket.error as e:
                if e.errno == errno.EWOULDBLOCK:  # 没有数据可读
                    pass
            else:
                # 清除残留数据完成
                self.logger.info("Cleared residual data from the server")
            finally:
                client_socket.setblocking(True)

        self.logger.info('')
        self.logger.debug(f"API SEND: ====> {pformat(cmd)}")
        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        for _ in range(10):
            try:
                client_socket.settimeout(2)
                client_socket.connect((self.hostname, self.port))
                break
            except Exception as e:
                self.logger.error(f"Failed to connect to {self.hostname}:{self.port}, {e} retrying...")
                time.sleep(1)
        client_socket.settimeout(timeout)  # 设置超时时间为120秒
        _read_cache()  # 清除缓存数据
        # self.logger.info('clear cache done')
        client_socket.sendall(json.dumps(cmd).encode('utf-8'))

        complete_data = b''  # 存储完整的数据
        try:
            while True:
                import select
                ready = select.select([client_socket], [], [], timeout)
                if ready[0]:
                    data = client_socket.recv(8192)
                    if not data:
                        break
                    complete_data += data
                    txt = complete_data.decode('utf-8')
                    if txt.count('{') == txt.count('}'):  # 完整的json数据
                        break
                else:
                    raise Exception(f"Command execution timeout: {timeout}s, No resp ")
        finally:
            client_socket.close()

        resp = json.loads(complete_data.decode('utf-8'))
        status_code = self._resp_state(resp)
        self.logger.debug('')
        self.logger.debug(f"API RECV: <==== {pformat(resp)}")
        if status_code != 0:
            if raise_exception:
                raise Exception(f"Command execution failed: state = {status_code}")
            else:
                self.logger.error(f"Command execution failed: state = {status_code}")
        self.logger.info('')
        return resp

    def exec_cmd(self, cmd: dict, timeout: int = 120, raise_exception: bool = True,
                 retry_times: int = 1) -> dict:
        """
        Executes a command on the UE box.

        Args:
            cmd (dict): The command to be executed.
            timeout (int, optional): The timeout value for the command execution. Defaults to 120.
            raise_exception (bool, optional): Whether to raise an exception if the command execution fails.
            Defaults to True.
            retry_times (int, optional): The number of times to retry the command execution. Defaults to 3.

        Returns:
            dict: The response from the command execution.

        Raises:
            Exception: If the command execution fails after the specified number of retries.
        """
        for _ in range(retry_times):
            # self.logger.info("loop...........")
            resp = self._exec_cmd(cmd, timeout, raise_exception=False)
            if self._resp_state(resp) == 0:
                return resp
            else:
                self.wait(30, 'Retry...')
        raise Exception(f"Command execution failed after {retry_times} retries: {pformat(cmd)}")

    def _disconnect_ue(self, EQIndex: int = -1) -> dict:
        if EQIndex == -1:
            self.logger.info('Disconnect All UE')
            return self.exec_cmd({"CMD": "DisConnectEQ"}, retry_times=3)
        else:
            self.logger.info(f'Disconnect UE {EQIndex}')
            return self.exec_cmd({"CMD": "DisConnectOneEQ", "EQIndex": EQIndex}, retry_times=3)

    def _connect_ue(self, EQIndex: int = -1) -> dict:
        if EQIndex == -1:
            self.logger.info('Connect All UE')
            return self.exec_cmd({"CMD": "ConnectEQ"}, retry_times=3)
        else:
            self.logger.info(f'Cconnect UE {EQIndex}')
            return self.exec_cmd({"CMD": "ConnectOneEQ", "EQIndex": EQIndex}, retry_times=3)

    def _auto_check(self, timeout: int = CMD_TIMEOUT) -> dict:
        self.logger.info(f'Autocheck, timeout: {timeout}...')
        return self.exec_cmd({"CMD": "AutoCheck"}, timeout=timeout)

    def _auto_check_hard(self):
        exp_ue_count = self.config.uecount
        if exp_ue_count:
            for _ in range(10):
                resp = self._auto_check()
                if resp.get('Param', {}).get('Count', 0) == exp_ue_count:
                    self.logger.info(f'Found {exp_ue_count} UEs as expected')
                    return exp_ue_count
                else:
                    self.wait(10, 'AutoCheck to meet ue count...')
        raise Exception('Could not find the expected numbers of ALL UE')

    def _split_log_by_size(self, size: int = 100) -> dict:
        """
        Splits the log file into smaller chunks based on the specified size, unit: M.

        Args:
            size (int, optional): The maximum size (in bytes) of each log chunk. Defaults to 100M.

        Returns:
            dict: A dictionary containing the result of the command execution.
        """
        self.logger.info(f'Set AutoDivide for log by size: {size}')
        return self.exec_cmd(
            {"CMD": "AutoDivideSet",
             "Param": {
                 "Enabled": 1,
                 "Type": 1,
                 "Size": size
                 }
             }
            )

    def _split_log_by_time(self, interval: int = 60) -> dict:
        """
        Splits the log by time into multiple parts.

        Args:
            interval (int): The time interval in seconds to split the log. Default is 60 mins.

        Returns:
            dict: A dictionary containing the result of the command execution.
        """
        self.logger.info(f'Set AutoDivide for log by time: {interval}mins')
        return self.exec_cmd(
            {"CMD": "AutoDivideSet",
             "Param": {
                 "Enabled": 1,
                 "Type": 0,
                 "Time": interval,
                 }
             }
        )

    def start_log(self,
                  EQIndex: int = -1,
                  LogPath: str = r'c:\\',
                  LogName: str = 'UEBox',
                  split_log_by: str = 'time',
                  spilt_log_size: int = 100,
                  split_log_time: int = 60) -> dict:

        # try:
        #     if split_log_by == 'time':
        #         self._split_log_by_time(split_log_time)
        #     else:
        #         self._split_log_by_size(spilt_log_size)
        # except Exception:
        #     pass
        # self.cpc.execute(f'del {LogPath}\\{LogName}*.raf')
        # self.cpc.execute(f'del {LogPath}\\{LogName}*.saf')

        if EQIndex == -1:
            self.logger.info('Start log for all UE')
            return self.exec_cmd({"CMD": "StartLog", "Param": {"LogPath": LogPath, "LogName": LogName}})
        else:
            self.logger.info(f'Start log for {self._eqindex2imsi(EQIndex)}')
            return self.exec_cmd({"CMD": "StartOneLog",
                                  "EQIndex": EQIndex,
                                  "Param": {"LogPath": LogPath, "LogName": LogName}})

    def stop_log(self, EQIndex: int = -1) -> dict:
        if EQIndex == -1:
            self.logger.info('Stop log for all UE')
            return self.exec_cmd({"CMD": "StopLog"})
        else:
            self.logger.info(f'Stop log for {self._eqindex2imsi(EQIndex)}')
            return self.exec_cmd({"CMD": "StopOneLog", "EQIndex": EQIndex})

    def exec_at_cmd(self, EQIndex: int, atcmd: str, timeout: int = CMD_TIMEOUT, SuccStr: str = '\r\n\r\nOK',
                    retry_times: int = 3) -> dict:
        """
        Executes an AT command on the specified EQIndex.

        Args:
            EQIndex (int): The index of the EQ (equipment) to send the AT command to.
            atcmd (str): The AT command to be executed.
            timeout (int, optional): The timeout value in seconds. Defaults to 120.
            SuccStr (str, optional): The success string to expect in the response. Defaults to 'OK'.

        Returns:
            dict: A dictionary containing the response from the command execution.
        """
        self.logger.info(f'AT CMD on {self._eqindex2imsi(EQIndex)} {atcmd}')
        return self.exec_cmd(
            {"CMD": "SendAT",
             "EQIndex": EQIndex,
             "Param": {
                 "Command": atcmd,
                 "Timeout": int(timeout) * 1000,
                 "SuccStr": SuccStr}}, retry_times=retry_times)

    def _get_imsi(self, EQIndex: int) -> dict:
        self.logger.info(f'Get IMSI for EQ {EQIndex}')
        resp = self.exec_at_cmd(EQIndex, 'AT+CIMI').get("Param", {})
        if resp.get("State") == 0:
            txt = re.findall(r'[\d]{7,20}', resp.get("Back", ''))
            return txt[0] if txt else ''
        else:
            raise Exception(f'Execute AT Command failed, {resp} ')

    def _poweroff(self, EQIndex: int = -1) -> dict:
        # self.logger.info(f'Poweroff {EQIndex}')
        return self.exec_cmd({"CMD": "PowerOff", "EQIndex": EQIndex}, retry_times=3)

    def _poweron(self, EQIndex: int = -1) -> dict:
        # self.logger.info(f'Poweron {EQIndex}')
        resp = self.exec_cmd({"CMD": "PowerOn", "EQIndex": EQIndex}, retry_times=3)
        time.sleep(15)
        return resp

    def _get_status(self, EQIndex: int) -> dict:
        return self.exec_cmd({"CMD": "GetParamValue", "EQIndex": EQIndex,
                              "Param": [
                                  "NR SSB RSRP[dBm]",
                                  "NR SSB SINR[dB]",
                                  "NR PCI"]})

    def _get_pci(self, EQIndex: int) -> int:
        return self._get_status(EQIndex)['Param']['Values'][2]

    def _wait_until_ue_detached(self, EQIndex: int, timeout: int = 60) -> bool:
        for _ in range(timeout // 5):
            if not self._attached(EQIndex):
                return True
            time.sleep(5)
        raise Exception(f'UE {self._eqindex2imsi(EQIndex)} is still attached after {timeout} seconds')

    def _wait_until_ue_attached(self, EQIndex: int, timeout: int = 60) -> bool:
        for _ in range(timeout // 5):
            if self._attached(EQIndex):
                return True
            time.sleep(5)
        raise Exception(f'UE {self._eqindex2imsi(EQIndex)} is still attached after {timeout} seconds')

    def _get_ueip(self, EQIndex: int, retry_times: int = 2) -> str:
        self.logger.info(f'Get IP for {self._eqindex2imsi(EQIndex)}')
        addrs = None
        for i in range(0, retry_times):
            resp = self.exec_at_cmd(EQIndex, 'AT+CGPADDR', SuccStr='+CGPADDR')
            ip_pattern = r'(?<![\d.])((?:(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d\d?))(?![\d.])'
            addrs = re.findall(ip_pattern, resp['Param']['Back'])
            if addrs:
                if addrs[0].strip() != "":
                    return addrs[0]
            time.sleep(3)
        return ""

    def _set_apn(self, EQIndex: int, apn: str, mcc: str = "", mnc: str = "") -> dict:
        return self.exec_cmd(
            {"CMD": "ConfigureAPN",
             "EQIndex": EQIndex,
             "Param": {
                 "APN": apn,
                 "MCC": mcc,
                 "MNC": mnc}})

    def exec_custom_cmd(self, jsoncmd: str) -> dict:
        return self.exec_cmd(json.loads(jsoncmd))

    def _start_test(self, EQIndex: int = -1) -> dict:
        self.logger.info(f'Start test for {self._eqindex2imsi(EQIndex)}')
        return self.exec_cmd({"CMD": "StartTest", "EQIndex": EQIndex})

    def _stop_test(self, EQIndex: int = -1) -> dict:
        self.logger.info(f'Stop test for {self._eqindex2imsi(EQIndex)}')
        return self.exec_cmd({"CMD": "StopTest", "EQIndex": EQIndex})

    def start_testplan(self, EQIndex: int = -1, TestPlans: list = None) -> dict:
        if TestPlans is None:
            TestPlans = []
        if isinstance(TestPlans, str):
            TestPlans = TestPlans.split(',')
        if self.is_testing(EQIndex):
            self.logger.info(f'UE is in a testing plan, stop it first')
            self.stop_testplan(EQIndex)
        self.logger.info(f'Start testplans for {self._eqindex2imsi(EQIndex)}, plans: {TestPlans}')
        return self.exec_cmd(
            {"CMD": "StartTestByName",
             "EQIndex": EQIndex,
             "Param": {
                 "TaskName": TestPlans}})

    def stop_testplan(self, EQIndex: int = -1) -> None:
        self.logger.info(f'Stop testplans for {self._eqindex2imsi(EQIndex)}')
        return self.exec_cmd({"CMD": "StopTest", "EQIndex": EQIndex})

    def start_dl_traffic(self,
                         EQIndex: int,
                         remote_hostname: str = "",
                         remote_username: str = "",
                         remote_password: str = "",
                         IperfOptions: str = " -i 1") -> None:
        if remote_hostname == '':
            remote_hostname, remote_username, remote_password, remote_port = self._get_app_server()

        ueip = self._get_ueip(EQIndex)

        iperf_port = re.findall(r'-p\s?(\d+)', IperfOptions)
        if iperf_port:
            iperf_port = int(iperf_port[0])
        else:
            raise Exception(f'IperfOptions {IperfOptions} does not contain -p option')
        is_udp = '-u' in IperfOptions
        self.cpc.auto_enable_firewall(iperf_port)
        self.start_local_iperf_server(ueip, iperf_port, is_udp, restart=True)

        from taf.transport.ssh import ssh
        # ueip = self._get_ueip(EQIndex)
        remote = ssh()
        remote.connect_to(hostname=remote_hostname, username=remote_username,
                          password=remote_password, alias=remote_hostname)

        if ueip.strip() != "":
            cmd = " ".join([f"ps -ef | grep iperf | grep \"{ueip}\" | grep \"{iperf_port}\" | grep -v grep",
                            "| awk \'{print $2}\' | xargs -r sudo kill -9"])
            self.logger.info(f'UE {EQIndex} IP is {ueip}, {cmd}')
            remote.execute(cmd, connection=remote_hostname)
            # to kill the same iperf_port server
            if iperf_port != "":
                cmd = " ".join([f"ps -ef | grep iperf | grep \"{iperf_port}\" | grep \"-s\"| grep -v grep",
                                "| awk \'{print $2}\' | xargs -r sudo kill -9"])
                self.logger.info(f'kill the same iperf ports server {iperf_port}, {cmd}')
                remote.execute(cmd, connection=remote_hostname)
        else:
            self.logger.error(f'UE {EQIndex} IP is empty, sudo pkill -f "{iperf_port}"')
            remote.execute(f'sudo pkill -f "{iperf_port}"', connection=remote_hostname)
        cmd = f'nohup iperf -c {ueip} {IperfOptions} &'
        self.logger.info(cmd)
        remote.send_command(cmd, connection=remote_hostname)
        remote.disconnect(connection=remote_hostname)

    def stop_ul_traffic(self,
                        EQIndex: int) -> None:
        ueip = self._get_ueip(EQIndex)
        self.cpc.kill_process_by_keywords(['iperf', ueip])

    def start_ul_traffic(self,
                         EQIndex: int,
                         remote_hostname: str = "",
                         remote_username: str = 'ute',
                         remote_password: str = 'ute',
                         remote_port: int = 22,
                         IperfOptions: str = '-i 1') -> None:
        self.logger.info(f'Start iperf out of app for {EQIndex} with {IperfOptions}')
        if remote_hostname == '':
            remote_hostname, remote_username, remote_password, remote_port = self._get_app_server()
        ueip = self._get_ueip(EQIndex)

        isudp = '-u' in IperfOptions
        iperf_port = re.findall(r'-p\s?(\d+)', IperfOptions)[0]

        self._kill_previous_local_iperf_client(ueip, iperf_port, isudp)

        # 启动 iperf 服务器
        self.start_remote_iperf_server(
            remote_hostname,
            remote_username,
            remote_password,
            remote_port,
            True, isudp, iperf_port=iperf_port)

        cmd = f'iperf -c {remote_hostname} -B {ueip} -p {iperf_port}'
        cmd += ' ' + IperfOptions.strip()
        cmd = f'cmd /c "{cmd}"'
        self.cpc.exec_psexec(cmd)

    def stop_dl_traffic(self, EQIndex: int, remote_hostname: str = "",
                        remote_username: str = "", remote_password: str = "") -> None:
        if remote_hostname == '':
            remote_hostname, remote_username, remote_password, remote_port = self._get_app_server()

        from taf.transport.ssh import ssh
        ueip = self._get_ueip(EQIndex)
        remote = ssh()
        remote.connect_to(hostname=remote_hostname, username=remote_username,
                          password=remote_password, alias=remote_hostname)
        cmd = f'kill -9 $(pgrep -f {ueip})'
        self.logger.info(cmd)
        remote.execute(cmd, connection=remote_hostname)
        remote.disconnect(connection=remote_hostname)

    def _attached(self, EQIndex: int) -> bool:
        self.logger.info(f'Check {self._eqindex2imsi(EQIndex)} Status')
        return '+COPS: 2' not in self.exec_at_cmd(EQIndex, 'AT+COPS?')['Param']['Back']
        # return self._get_ueip(EQIndex)  != ''

    def _attach(self, EQIndex: int) -> dict:
        self.logger.info(f'Attach UE: {self._eqindex2imsi(EQIndex)}')
        resp = self._poweron(EQIndex)
        self._wait_until_ue_attached(EQIndex)
        self.logger.info(f'UE {self._eqindex2imsi(EQIndex)} is attached')
        return resp

    def attach(self, EQIndex: int, forced: bool = False, expected_pci: int = -1) -> dict:
        attached = self._attached(EQIndex)
        resp = None
        if forced and attached:
            self.logger.info('UE is already attached, detach first.')
            self.detach(EQIndex)
            resp = self._attach(EQIndex)
        if not attached:
            resp = self._attach(EQIndex)
        return resp

    def detach(self, EQIndex: int) -> dict:
        self.logger.info(f'Detach UE: {self._eqindex2imsi(EQIndex)}')
        # resp =self.exec_at_cmd(EQIndex, 'AT+CFUN=4', SuccStr='\r\nOK\r\n')
        if self._attached(EQIndex):
            resp = self._poweroff(EQIndex)
            self._wait_until_ue_detached(EQIndex)
            self.logger.info(f'UE {self._eqindex2imsi(EQIndex)} is detached')
            return resp
        else:
            self.logger.info(f'UE {self._eqindex2imsi(EQIndex)} is already detached')

    def start_voice_call(self, EQIndex: int, Number: str = '006688') -> dict:
        return self.exec_at_cmd(EQIndex, f'ATD+{Number};', SuccStr='OK')

    def stop_voice_call(self, EQIndex: int) -> dict:
        return self.exec_at_cmd(EQIndex, 'ATH', SuccStr='OK')

    def get_throughput(self, EQIndex: int, direction: str) -> dict:
        self.logger.info(f'Get throughput for {EQIndex}')
        resp = self.exec_cmd(
            {
                "CMD": "GetParamMAC",
                "EQIndex": EQIndex
            })
        if self._resp_state(resp) == 0:
            if direction.upper() == 'UL':
                return resp['Param']['MACUL']/1000/1000
            elif direction.upper() == 'DL':
                return resp['Param']['MACDL']/1000/1000
            else:
                raise Exception(f'Invalid direction {direction}')

    def _convert_windows_to_cygwin_path(self, windows_path):
        # 将Windows路径转换为Cygwin路径，带有空格的目录用双引号包裹
        if ':' in windows_path:
            drive, path = windows_path.split(":", 1)
            dires = [f'"{x}"' if ' ' in x else x for x in path.split('\\')]
            cygwin_path = '/cygdrive/' + drive.lower() + '/'.join(dires)
            return cygwin_path
        else:
            return None  # 如果路径格式不正确，返回None或者抛出异常

    def fetch_log(self, EQIndex: int, LogPath: str, LogName: str, LocalDire: str) -> None:
        LocalDire = os.path.abspath(os.path.expanduser(LocalDire))
        os.makedirs(LocalDire, exist_ok=True)
        # self.cpc.execute(f'dir {LogPath}')
        LogPath = LogPath.replace('\\', '/')
        cmd = (f'sshpass -p {self.cpc.password} scp -P {self.cpc.port} -o StrictHostKeyChecking=no '
               '-o UserKnownHostsFile=/dev/null '
               f'{self.cpc.username}@{self.cpc.hostname}:{LogPath}/*{LogName}-{EQIndex}*.saf {LocalDire}/')
        os_obj.run(cmd)
        cmd = (f'sshpass -p {self.cpc.password} scp -P {self.cpc.port} -o StrictHostKeyChecking=no '
               '-o UserKnownHostsFile=/dev/null '
               f'{self.cpc.username}@{self.cpc.hostname}:{LogPath}/*{LogName}-{EQIndex}*.raf {LocalDire}/')
        os_obj.run(cmd)

    def start_remote_iperf_server(self,
                                  hostname: str,
                                  username: str,
                                  password: str,
                                  port: int = 22,
                                  is_iperf2: bool = True,
                                  is_udp: bool = True,
                                  iperf_port: int = 5001,
                                  restart: bool = False) -> None:
        self.logger.info(f'Start iperf server on {hostname}:{port}')
        from taf.transport.ssh import ssh
        remote = ssh()
        remote.connect_to(hostname=hostname, username=username, password=password, port=port, alias=hostname)
        cmd = 'ps -ef|grep iperf|grep -v grep'
        self.logger.info(cmd)
        lines = [x for x in remote.execute(cmd, connection=hostname).splitlines() if x.strip()]
        lines = [x for x in lines if str(iperf_port) in x and '-s' in x]
        if is_udp:
            lines = [x for x in lines if '-u' in x]
        else:
            lines = [x for x in lines if '-u' not in x]
        if not is_iperf2:
            lines = [x for x in lines if 'iperf3' in x]

        for line in lines:
            print(line)

        if lines:
            pid = lines[0].split()[1]
            self.logger.info(f'iperf server already started, pid: {pid}')
            if restart:
                self.logger.info(f'Kill iperf server {pid} because restart is needed')
                remote.execute(f'sudo kill -9 {pid}', connection=hostname)
            else:
                self.logger.info('iperf server does not need to restart because restart is not needed')
                remote.disconnect(connection=hostname)
                return 0

        cmd = '{} -s -p {} -D '.format('iperf' if is_iperf2 else 'iperf3', iperf_port)
        cmd += ' -u' if is_udp else ''
        self.logger.info(cmd)
        remote.execute(cmd, connection=hostname)
        self.logger.info(remote.execute(f'ps -ef|grep iperf|grep {iperf_port}|grep -v grep', connection=hostname))
        remote.disconnect(connection=hostname)

    def start_local_iperf_server(self, ueip: str, iperf_port: int = 5001,
                                 is_udp: bool = True, restart: bool = False) -> None:
        keywords = ['iperf', ueip, str(iperf_port), '-s']
        if is_udp:
            keywords.append('-u')
        existed_process = self.cpc.find_process(keywords)
        if existed_process:
            if restart:
                self.logger.info(f'Kill local iperf server {iperf_port}')
                self.cpc.kill_process_by_keywords(keywords)
            else:
                self.logger.info('Local iperf server already started')
                return
        self.logger.info(f'Start local iperf server {iperf_port}')
        cmd = f' -s iperf -s -p {iperf_port} -i 1 -B {ueip}'
        cmd += ' -u' if is_udp else ''
        self.logger.info(cmd)
        self.cpc.exec_psexec(cmd)

    def is_testing(self, EQIndex: int) -> str:
        return self.exec_cmd({"CMD": "GetTestStatus", "EQIndex": EQIndex}, retry_times=3)['Param']['IsTesting'] == 1

    def wait_until_testplan_done(self, EQIndex: int, timeout: str = '180s') -> None:
        from robot.utils.robottime import timestr_to_secs
        timeout = timestr_to_secs(str(timeout))
        for _ in range(int(timeout) // 5):
            if not self.is_testing(EQIndex):
                return
            time.sleep(5)
        raise Exception(f'Testplan is still running after {timeout} seconds')

    def _kill_previous_local_iperf_client(self, ueip: str, iperf_port: int, isudp: bool = True):
        cmd = 'wmic process get Processid, commandline|findstr iperf|findstr -v "find"'
        lines = self.cpc.execute(cmd)
        lines = [x.strip() for x in lines.splitlines() if x.strip() if 'wmic' not in x]
        for line in lines:
            if ueip in line and str(iperf_port) in line and '-c' in line:
                if isudp and '-u' in line:
                    pid = line.split()[-1]
                    self.cpc.execute(f'taskkill /f /pid {pid}')
                if not isudp and '-u' not in line:
                    pid = line.split()[-1]
                    self.cpc.execute(f'taskkill /f /pid {pid}')

    def _kill_previous_local_iperf_server(self, ueip: str, iperf_port: int, isudp: bool = True):
        cmd = 'wmic process get Processid, commandline|findstr iperf|findstr -v "find"'
        lines = self.cpc.execute(cmd)
        lines = [x.strip() for x in lines.splitlines() if x.strip() if 'wmic' not in x]
        for line in lines:
            if ueip in line and str(iperf_port) in line and '-s' in line:
                if isudp and '-u' in line:
                    pid = line.split()[-1]
                    self.cpc.execute(f'taskkill /f /pid {pid}')
                if not isudp and '-u' not in line:
                    pid = line.split()[-1]
                    self.cpc.execute(f'taskkill /f /pid {pid}')

    def mtu_poweroff(self, EQIndex: int = -1) -> dict:
        resp = self.exec_cmd({"CMD": "MTUPowerOff", "EQIndex": EQIndex}, retry_times=3)
        time.sleep(10)
        return resp

    def mtu_poweron(self, EQIndex: int = -1) -> dict:
        resp = self.exec_cmd({"CMD": "MTUPowerOn", "EQIndex": EQIndex}, retry_times=3)
        time.sleep(10)
        return resp

    def _ueip_mapping_check(self, invalid_ip_match_str: str = "169.254.") -> bool:
        rep = self.cpc.execute(f"ipconfig")
        lines = rep.splitlines()
        capture = False
        ipv4 = None
        for line in lines:
            if "IPv4" in line:
                ipv4 = line.split(":")[-1].strip()
                if invalid_ip_match_str in ipv4:
                    return False
        return True

    def ueip_mapping(self,
                     retry_times: int = 2,
                     poweron_waittime: int = 50,
                     invalid_ip_match_str: str = "169.254."):
        ret = False
        for _ in range(retry_times):
            if not self._ueip_mapping_check(invalid_ip_match_str):
                self.logger.info(f'UE IP is invalid, poweroff and poweron')
                for ueindex in range(1, self.ue_count+1):
                    self.mtu_poweroff(ueindex)
                    self.mtu_poweron(ueindex)
                time.sleep(poweron_waittime)
            else:
                self.logger.info(f'UE IP is valid')
                ret = True
                break
        if ret is False:
            raise BaseException(f'UE IP is invalid for {retry_times}, please check your ue pc')
