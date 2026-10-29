# -*- coding: utf-8 -*-
"""
:created on: 25-04-2021

:copyright: Nokia
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import datetime
import yaml
import time
import os
import re
from .logger import Logger
from .util import RemoteLib, SshExecutor
from robot.libraries.BuiltIn import BuiltIn
from SSHLibrary import SSHLibrary
from tak_core.sshconnection import SshConnection


CMD_AIRPLANE_SETTINGS = "settings put global airplane_mode_on"
CMD_AIRPLANE_BROADCAST = "am broadcast -a android.intent.action.AIRPLANE_MODE --ez state"
SU_CMD = 'su 0'
LOG_PATH = "C:\\tmp\\Qualcomm"


class QualcommUe(object):

    def __init__(self):
        self._log = Logger()
        self.qualcomm_info = None
        self.conn = None

    def setup(self, domain, reboot, config_file):
        self._get_qualcomm_info_from_config_file(config_file)
        self.uepc_ip = self.qualcomm_info.get('uepc_ip', None)
        self.uepc_port = self.qualcomm_info.get('remote_port', 8270)
        self.uepc_username = self.qualcomm_info.get('uepc_username', None)
        self.uepc_pwd = self.qualcomm_info.get('uepc_pwd', None)
        self.uepc_dir = self.qualcomm_info.get('server_dir', None)
        self.iperfpc_ip = self.qualcomm_info.get('iperfpc_ip', None)
        self.iperfpc_username = self.qualcomm_info.get('iperfpc_username', None)
        self.iperfpc_pwd = self.qualcomm_info.get('iperfpc_pwd', None)

        self._log.debug('starting connect to ue pc')

        loop = 2 if reboot else 1
        self.conn = SSHLibrary()
        self.conn.open_connection(self.uepc_ip)
        self.conn.login(self.uepc_username, self.uepc_pwd)

        for count in range(loop):
            remote_lib_path = self._get_lib_path_with_cmd().replace('\\', '\\\\')
            psexec_path = os.path.join(remote_lib_path, "psexec.exe")
            server_path = os.path.join(remote_lib_path, "remote.py")
            session_id = 2

            cmd = "%s -i %s -d -u %s%s -p %s python %s -l tak_qualcomm_local -i %s -p 0 -s True" \
                  % (psexec_path,
                     session_id,
                     domain,
                     self.uepc_username,
                     self.uepc_pwd,
                     server_path,
                     self.uepc_ip)
            ret = self.conn.execute_command(cmd, return_stderr=True, return_rc=True)
            self._log.debug(ret[1])
            pid_con = re.search("python started on .* with process ID (\\d+)", ret[1])
            if not pid_con and count < 1:
                cmd = "import os;os.system('C:\\Windows\\PSEXESVC.EXE')"
                ret, err, rec = self.conn.execute_command('python -c "%s"' % cmd, return_stderr=True, return_rc=True)
                self._log.debug("ret:{},err:{},rec:{}".format(ret, err, rec))
            else:
                break
        self.remote_pid = pid_con.groups()[0]
        time.sleep(5)
        self._ue_remote_inst = RemoteLib(uri="%s:%s" % (self.uepc_ip, self.uepc_port), timeout="50min")
        self._log.debug("start remote lib succeed")

    def attach_with_adb(self, device_id):
        airplane_setting_cmd = 'shell {} {} 0'.format(SU_CMD, CMD_AIRPLANE_SETTINGS)
        airplane_broadcast_cmd = 'shell {} {} 0'.format(SU_CMD, CMD_AIRPLANE_BROADCAST)
        cmd1 = 'adb -s {} {}'.format(device_id, airplane_setting_cmd)
        self._log.debug(cmd1)
        cmd2 = 'adb -s {} {}'.format(device_id, airplane_broadcast_cmd)
        self._log.debug(cmd2)
        return self._ue_remote_inst.attach_with_adb(device_id)

    def exec_adb_cmd(self, device_id, cmd):
        return self._ue_remote_inst.exec_adb_cmd(device_id, cmd)

    def get_ip_with_adb(self, device_id):
        cmd = 'adb -s {} shell ifconfig'.format(device_id)
        self._log.debug(cmd)
        return self._ue_remote_inst.get_ip_with_adb(device_id)

    def start_iperf_server_on_ue(self, device_id, port, iperf_path, log_path, extra_cmd):
        log_path = '{}\\{}'.format(LOG_PATH, log_path.split('/')[-1])
        cmd = 'adb -s {} shell {} {} -s -p {} {} > {}&'.format(device_id, SU_CMD, iperf_path, port,
                                                               extra_cmd, log_path)
        self._log.debug(cmd)
        self._ue_remote_inst.start_iperf_server_on_ue(device_id, port, iperf_path, log_path, extra_cmd)

    def start_iperf_server_on_pc(self, port, log_path, extra_cmd):
        sshobj = SshExecutor(self.iperfpc_ip, self.iperfpc_username, self.iperfpc_pwd)
        self._kill_iperf_process_on_pc(sshobj, '-s', port)
        iperf_cmd = 'iperf -s -p {} {} > {}'.format(port, extra_cmd, log_path)
        self._log.debug("iperf command:{}".format(iperf_cmd))
        sshobj.exec_cmd(iperf_cmd, 'start_cmd')
        sshobj.close_connection()

    def stop_iperf_server_on_ue(self, device_id, port):
        cmd = 'adb -s {} shell "ps -ef | grep iperf -s"'.format(device_id)
        self._log.debug(cmd)
        self._ue_remote_inst.stop_iperf_server_on_ue(device_id, port)

    def stop_iperf_server_on_pc(self, port):
        sshobj = SshExecutor(self.iperfpc_ip, self.iperfpc_username, self.iperfpc_pwd)
        self._kill_iperf_process_on_pc(sshobj, '-s', port)
        sshobj.close_connection()

    def start_iperf_client_on_pc(self, port, ue_ip, extra_cmd, iperfpc_ip, iperfpc_username, iperfpc_pwd):
        if not iperfpc_ip:
            iperfpc_ip = self.iperfpc_ip
            iperfpc_username = self.iperfpc_username
            iperfpc_pwd = self.iperfpc_pwd
        sshobj = SshExecutor(iperfpc_ip, iperfpc_username, iperfpc_pwd)
        self._kill_iperf_process_on_pc(sshobj, '-c', port)
        iperf_cmd = 'iperf -c {} -p {} {}'.format(ue_ip, port, extra_cmd)
        self._log.debug("iperf command:{}".format(iperf_cmd))
        sshobj.exec_cmd(iperf_cmd, 'start_cmd')
        sshobj.close_connection()

    def start_iperf_client_on_ue(self, device_id, port, iperf_path, extra_cmd):
        cmd = 'adb -s {} shell {} {} -c {} -p {} {}'.format(device_id, SU_CMD, iperf_path, self.iperfpc_ip,
                                                            port, extra_cmd)
        self._log.debug(cmd)
        self._ue_remote_inst.start_iperf_client_on_ue(device_id, port, self.iperfpc_ip, iperf_path, extra_cmd)

    def stop_iperf_client_on_pc(self, port, iperfpc_ip, iperfpc_username, iperfpc_pwd):
        if not iperfpc_ip:
            iperfpc_ip = self.iperfpc_ip
            iperfpc_username = self.iperfpc_username
            iperfpc_pwd = self.iperfpc_pwd
        sshobj = SshExecutor(iperfpc_ip, iperfpc_username, iperfpc_pwd)
        self._kill_iperf_process_on_pc(sshobj, '-c', port)
        sshobj.close_connection()

    def stop_iperf_client_on_ue(self, device_id, port):
        cmd = 'adb -s {} shell "ps -ef | grep iperf -c"'.format(device_id)
        self._log.debug(cmd)
        self._ue_remote_inst.stop_iperf_client_on_ue(device_id, port)

    def get_throughput(self, server, log_path):
        if server == 'ue':
            remote_log_path = '{}\\{}'.format(self.uepc_dir, log_path.split('/')[-1]).replace('/', '\\')
            sshobj = SshExecutor(self.uepc_ip, self.uepc_username, self.uepc_pwd, '>')
            sshobj.get_file(remote_log_path, log_path)
            sshobj.close_connection()
        else:
            sshobj = SshExecutor(self.iperfpc_ip, self.iperfpc_username, self.iperfpc_pwd)
            sshobj.get_file(log_path, log_path)
            sshobj.close_connection()
        return self._calculate_throughput(log_path)

    def detach_with_adb(self, device_id):
        airplane_setting_cmd = 'shell {} {} 1'.format(SU_CMD, CMD_AIRPLANE_SETTINGS)
        airplane_broadcast_cmd = 'shell {} {} 1'.format(SU_CMD, CMD_AIRPLANE_BROADCAST)
        cmd1 = 'adb -s {} {}'.format(device_id, airplane_setting_cmd)
        self._log.debug(cmd1)
        cmd2 = 'adb -s {} {}'.format(device_id, airplane_broadcast_cmd)
        self._log.debug(cmd2)
        self._ue_remote_inst.detach_with_adb(device_id)

    def start_qxdm_trace(self, device_id, dmc_file):
        if dmc_file:
            sshobj = SshExecutor(self.uepc_ip, self.uepc_username, self.uepc_pwd, '>')
            sshobj.put_file(dmc_file, '{}\\'.format(LOG_PATH))
            sshobj.close_connection()
            remote_dmc = "{}\\{}".format(LOG_PATH, os.path.basename(dmc_file))
        else:
            remote_dmc = dmc_file
        return self._ue_remote_inst.start_qxdm_trace(device_id, remote_dmc)

    def stop_qxdm_trace(self, device_id, save_pth, quit_app):
        return self._ue_remote_inst.stop_qxdm_trace(device_id, save_pth, quit_app)

    def get_field_value(self, field_name, trace_file, index, timeout):
        return self._ue_remote_inst.get_field_value(field_name, trace_file, index, timeout)

    def export_to_txt(self, input_file, output_path, filter):
        return self._ue_remote_inst.export_to_txt(input_file, output_path, filter)

    def get_software_version(self, device_id):
        cmd = 'adb -s {} shell getprop ro.build.description'.format(device_id)
        self._log.debug(cmd)
        return self._ue_remote_inst.get_software_version(device_id)

    def get_physical_cell_id(self, device_id):
        cmd = 'adb -s {} shell dumpsys telephony.registry'.format(device_id)
        self._log.debug(cmd)
        return self._ue_remote_inst.get_physical_cell_id(device_id)

    def read_nvitem(self, device_id, item_name_or_id, subscription_id, index):
        return self._ue_remote_inst.read_nvitem(device_id, item_name_or_id, subscription_id, index)

    def write_nvitem(self, device_id, item_name_or_id, value_list, subscription_id):
        self._ue_remote_inst.write_nvitem(device_id, item_name_or_id, value_list, subscription_id)

    def set_apn(self, device_id, name, apn, mcc, mnc):
        return self._ue_remote_inst.set_apn(device_id, name, apn, mcc, mnc)

    def send_qxdm_command(self, device_id, cmd):
        return self._ue_remote_inst.send_qxdm_command(device_id, cmd)

    def teardown(self):
        self.conn.execute_command("TASKKILL /F /PID {}".format(self.remote_pid), return_stderr=True, return_rc=True)
        self.conn.close_connection()

    def _get_lib_path_with_cmd(self):
        seper = "*SEP*"
        lib_name = 'tak_qualcomm_local'
        cmd = "import {},os;print('{}'+os.path.dirname({}.__file__))".format(lib_name, seper, lib_name)
        ret, err, rec = self.conn.execute_command('python -c "%s"' % cmd, return_stderr=True, return_rc=True)
        if seper not in ret:
            return ""
        else:
            for ln in ret.splitlines():
                if seper in ln:
                    self.lib_path = ln.split(seper, 3)[-1].strip()
                    self._log.debug(self.lib_path)
                    return self.lib_path

    def _kill_iperf_process_on_pc(self, sshobj, s_or_c, port, os='linux'):
        if os == 'linux':
            find_cmd = 'ps -ef | grep "iperf {}"'.format(s_or_c)
            content = sshobj.exec_cmd(find_cmd, 'execute_cmd')
            self._log.debug("content:{}".format(content))
            pid = self._find_to_kill_pid(content, "iperf.*%s.*-p %s" % (s_or_c, port))
            if pid:
                kill_cmd = 'kill -9 {}'.format(pid)
                sshobj.exec_cmd(kill_cmd, 'execute_cmd')

    def _find_to_kill_pid(self, content, regex):
        pid = None
        for con in content.splitlines():
            if re.search(regex, con):
                pid = con.split()[1]
                self._log.debug(
                    "find client process pid is %s \nin '%s'\nExecute 'kill -9 %s'" %
                    (pid, con, pid))
                break
        return pid

    def _get_qualcomm_info_from_config_file(self, config_file):
        if not config_file:
            config_file = self._get_robot_runtime_variable('UE_CONFIG')
        with open(config_file) as f:
            self.qualcomm_info = yaml.safe_load(f)

    def _get_robot_runtime_variable(self, varname):
        """get robot runtime variable use Builtin libraries replace_variables"""
        try:
            if not varname.startswith("${"):
                varname = "${%s}" % varname
            return BuiltIn().replace_variables(varname)
        except Exception as error:
            self._log.info("Can't get variable '%s' ! details: '%s'" % (varname, error))

    def _calculate_throughput(self, log_path):
        f_op = open(log_path, 'r')
        content = f_op.read()
        f_op.close()
        pattern = '\\[\\s*(\\d+)\\]\\s+([0-9.]+\\s*-\\s*[0-9.]+)\\s+sec\\s+[0-9.]+\\s+\\w+\\s+([0-9.]+)\\s+\\w+/sec'
        throughput_list = []
        match_lines = re.compile(pattern, re.M).findall(content)
        for match in match_lines:
            second_space = [float(item.strip())
                            for item in match[1].split('-')]
            if second_space[1] - second_space[0] != 1.0:
                continue
            else:
                throughput_list.append(float(match[2]))
        self._log.info("throughput_list:{}".format(throughput_list))
        if len(throughput_list) > 0:
            return '%.2f' % float(sum(throughput_list) / len(throughput_list))

    def _wait_until_ue_pc_reboot_finish(self, timeout):
        start_time = datetime.datetime.now()
        ping_nok = self._host_ping(self.uepc_ip, timeout, False)
        now_time = datetime.datetime.now()
        new_timeout = timeout - (now_time - start_time).seconds
        self._log.debug("new timeout after ping not ok:{}".format(new_timeout))
        ping_ok = self._host_ping(self.uepc_ip, new_timeout)
        if not ping_ok or not ping_nok:
            raise Exception("Failed to restart UE PC")

    def _host_ping(self, host, timeout, is_ok=True, host_ip='127.0.0.1', **kwargs):
        ssh_client = SshConnection(host_ip, kwargs.get("ssh_username", "ute"), kwargs.get("ssh_password", "ute"),
                                   kwargs.get("ssh_port", int(22)), kwargs.get("ssh_prompt", "$ "))
        ret_value = False
        ping_result = 0 if is_ok else 1
        try:
            ssh_client._setup()
            start_time = datetime.datetime.now()
            while(timeout):
                now_time = datetime.datetime.now()
                ret = ssh_client.execute("ping -c 4 {}".format(host))
                if ret is None:
                    raise Exception("Ping cmd not sent to board")
                self._log.info(ret)
                if ret[2] == ping_result:
                    ret_value = True
                    break
                elif int((now_time - start_time).seconds) > int(timeout):
                    ret_value = False
                    break
                else:
                    time.sleep(1)
        finally:
            ssh_client._teardown()
            return ret_value
