# -*- coding: utf-8 -*-
"""
:created on: 25-04-2021

:copyright: Nokia
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""

from .logger import Logger
from .util import RemoteLib, SshExecutor
from robot.libraries.BuiltIn import BuiltIn
import yaml
from SSHLibrary import SSHLibrary
import time
import os
import re

LOG_PATH = "C:\\tmp\\Qualcomm"


class QualcommUe(object):

    def __init__(self):
        self._log = Logger()
        self.qualcomm_info = None
        self._get_qualcomm_info_from_config_file()
        self.uepc_ip = self.qualcomm_info.get('uepc_ip', None)
        self.uepc_port = self.qualcomm_info.get('remote_port', 8270)
        self.uepc_username = self.qualcomm_info.get('uepc_username', None)
        self.uepc_pwd = self.qualcomm_info.get('uepc_pwd', None)
        self.uepc_dir = self.qualcomm_info.get('server_dir', None)
        self.uepc_python = self.qualcomm_info.get('server_python', None)
        self.iperfpc_ip = self.qualcomm_info.get('iperfpc_ip', None)
        self.iperfpc_username = self.qualcomm_info.get('iperfpc_username', None)
        self.iperfpc_pwd = self.qualcomm_info.get('iperfpc_pwd', None)

    def setup(self, domain, reboot, prompt):
        self._log.debug('starting connect to ue pc')

        loop = 2 if reboot else 1

        for count in range(loop):
            self.conn = SSHLibrary()
            self.conn.open_connection(self.uepc_ip)
            self.conn.login(self.uepc_username, self.uepc_pwd)
            remote_lib_path = self._get_lib_path_with_cmd().replace('\\', '\\\\')
            psexec_path = os.path.join(remote_lib_path, "psexec.exe")
            server_path = os.path.join(remote_lib_path, "remote.py")
            session_id = 2

            cmd = "%s -i %s -d -u %s%s -p %s python %s -l ta_kiss_qualcomm_local -i %s -p 0 -s True" \
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
                sshobj = SshExecutor(self.uepc_ip, self.uepc_username, self.uepc_pwd, prompt)
                sshobj.exec_cmd("shutdown -r -t 0", "start_cmd")
                sshobj.close_connection()
                time.sleep(360)
            else:
                break
        self.remote_pid = pid_con.groups()[0]
        time.sleep(5)
        self._ue_remote_inst = RemoteLib(uri="%s:%s" % (self.uepc_ip, self.uepc_port), timeout="50min")
        self._log.debug("start remote lib succeed")

    def attach_with_adb(self, device_id):
        return self._ue_remote_inst.attach_with_adb(device_id)

    def exec_adb_cmd(self, device_id, cmd):
        return self._ue_remote_inst.exec_adb_cmd(device_id, cmd)

    def get_ip_with_adb(self, device_id):
        return self._ue_remote_inst.get_ip_with_adb(device_id)

    def start_iperf_server_on_ue(self, device_id, port, iperf_path, log_path, extra_cmd):
        self._ue_remote_inst.start_iperf_server_on_ue(device_id, port, iperf_path, log_path, extra_cmd)

    def start_iperf_server_on_pc(self, port, log_path, extra_cmd):
        sshobj = SshExecutor(self.iperfpc_ip, self.iperfpc_username, self.iperfpc_pwd)
        self._kill_iperf_process_on_pc(sshobj, '-s', port)
        iperf_cmd = 'iperf -s -p {} {} > {}'.format(port, extra_cmd, log_path)
        self._log.debug("iperf command:{}".format(iperf_cmd))
        sshobj.exec_cmd(iperf_cmd, 'start_cmd')
        sshobj.close_connection()

    def stop_iperf_server_on_ue(self, device_id, port):
        self._ue_remote_inst.stop_iperf_server_on_ue(device_id, port)

    def stop_iperf_server_on_pc(self, port):
        sshobj = SshExecutor(self.iperfpc_ip, self.iperfpc_username, self.iperfpc_pwd)
        self._kill_iperf_process_on_pc(sshobj, '-s', port)
        sshobj.close_connection()

    def start_iperf_client_on_pc(self, port, ue_ip, extra_cmd):
        sshobj = SshExecutor(self.iperfpc_ip, self.iperfpc_username, self.iperfpc_pwd)
        self._kill_iperf_process_on_pc(sshobj, '-c', port)
        iperf_cmd = 'iperf -c {} -p {} {}'.format(ue_ip, port, extra_cmd)
        self._log.debug("iperf command:{}".format(iperf_cmd))
        sshobj.exec_cmd(iperf_cmd, 'start_cmd')
        sshobj.close_connection()

    def start_iperf_client_on_ue(self, device_id, port, pc_ip, iperf_path, extra_cmd):
        self._ue_remote_inst.start_iperf_client_on_ue(device_id, port, pc_ip, iperf_path, extra_cmd)

    def stop_iperf_client_on_pc(self, port):
        sshobj = SshExecutor(self.iperfpc_ip, self.iperfpc_username, self.iperfpc_pwd)
        self._kill_iperf_process_on_pc(sshobj, '-c', port)
        sshobj.close_connection()

    def stop_iperf_client_on_ue(self, device_id, port):
        self._ue_remote_inst.stop_iperf_client_on_ue(device_id, port)

    # def get_throughput(self, server, log_path):
    #     if server == 'ue':
    #         remote_log_path = '{}\{}'.format(self.uepc_dir, log_path.split('/')[-1]).replace('/','\\')
    #         sshobj = SshExecutor(self.uepc_ip, self.uepc_username, self.uepc_pwd, '>')
    #         sshobj.get_file(remote_log_path, log_path)
    #         sshobj.close_connection()
    #     else:
    #         sshobj = SshExecutor(self.iperfpc_ip, self.iperfpc_username, self.iperfpc_pwd)
    #         sshobj.get_file(log_path, log_path)
    #         sshobj.close_connection()
    #     return self._calculate_throughput(log_path)

    def detach_with_adb(self, device_id):
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

    def teardown(self):
        self.conn.execute_command("TASKKILL /F /PID {}".format(self.remote_pid), return_stderr=True, return_rc=True)
        self.conn.close_connection()

    def _get_lib_path_with_cmd(self):
        seper = "*SEP*"
        cmd = "import ta_kiss_qualcomm_local,os;print('%s'+os.path.dirname(ta_kiss_qualcomm_local.__file__))" % seper
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

    def _get_qualcomm_info_from_config_file(self):
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

    # def _calculate_throughput(self, log_path):
    #     f_op = open(log_path, 'r')
    #     content = f_op.read()
    #     f_op.close()
    #     pattern = '\[\s*(\d+)\]\s+([0-9.]+\s*-\s*[0-9.]+)\s+sec\s+[0-9.]+\s+\w+\s+([0-9.]+)\s+\w+/sec'
    #     throughput_list = []
    #     match_lines = re.compile(pattern, re.M).findall(content)
    #     for match in match_lines:
    #         second_space = [float(item.strip())
    #                         for item in match[1].split('-')]
    #         if second_space[1] - second_space[0] != 1.0:
    #             continue
    #         else:
    #             throughput_list.append(float(match[2]))
    #     self._log.info("throughput_list:{}".format(throughput_list))
    #     if len(throughput_list) > 0:
    #         return '%.2f' % float(sum(throughput_list) / len(throughput_list))
