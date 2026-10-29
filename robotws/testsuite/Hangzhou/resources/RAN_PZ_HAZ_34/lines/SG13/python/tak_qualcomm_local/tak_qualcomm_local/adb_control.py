"""
:created on: 25-04-2021

:copyright: Nokia
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import datetime
import time
import os
import subprocess
import re
from tak_qualcomm_local.util import LOG_PATH, write_debug_log_to_file


CMD_AIRPLANE_SETTINGS = "settings put global airplane_mode_on"
CMD_AIRPLANE_BROADCAST = "am broadcast -a android.intent.action.AIRPLANE_MODE --ez state"
SU_CMD = 'su 0'


class AdbControl(object):

    def __init__(self):
        self.file_name = "AdbControlLogger_" + datetime.datetime.today().strftime("%Y-%m-%d-%H-%M") + ".txt"

    def attach(self, device_id):
        """ attach
        """
        airplane_setting_cmd = 'shell {} {} 0'.format(SU_CMD, CMD_AIRPLANE_SETTINGS)
        airplane_broadcast_cmd = 'shell {} {} 0'.format(SU_CMD, CMD_AIRPLANE_BROADCAST)
        self.exec_cmd(device_id, airplane_setting_cmd)
        self.exec_cmd(device_id, airplane_broadcast_cmd)
        time.sleep(20)
        get_ip_cmd = 'shell {} ifconfig'.format(SU_CMD)
        out = self.exec_cmd(device_id, get_ip_cmd)
        return False if 'rmnet_data' not in out else True

    def exec_cmd(self, device_id, cmd, instant=False):
        """ exec cmd
        """
        if not instant:
            cmd = 'adb -s {} {}'.format(device_id, cmd)
            prog = subprocess.Popen(cmd, stdout=subprocess.PIPE, stdin=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, shell=True)
            out = prog.communicate()[0].decode()
            write_debug_log_to_file(self.file_name, "exec {} out is :{}".format(cmd, out))
            if 'not found' in out:
                raise Exception('Adb cmd {} failed with {}'.format(cmd, out))
            return out
        else:
            write_debug_log_to_file(self.file_name, "exec {}".format(cmd))
            return os.popen('adb -s {} {}'.format(device_id, cmd))

    def get_ip(self, device_id):
        """ get ip
        """
        out = self.exec_cmd(device_id, 'shell ifconfig')
        ip_content = out.split('rmnet_data')[1]
        ip = re.search('inet addr:(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})', ip_content).groups()[0]
        return ip

    def start_iperf_server(self, device_id, port, iperf_path, log_path, extra_cmd):
        """ start iperf server
        """
        self._kill_iperf_process(device_id, '-s', port)
        log_path = '{}\\{}'.format(LOG_PATH, log_path.split('/')[-1])
        cmd = 'shell {} {} -s -p {} {} > {}&'.format(SU_CMD, iperf_path, port, extra_cmd, log_path)
        self.exec_cmd(device_id, cmd, True)

    def stop_iperf_server(self, device_id, port):
        """ stop iperf server
        """
        self._kill_iperf_process(device_id, '-s', port)

    def start_iperf_client(self, device_id, port, pc_ip, iperf_path, extra_cmd):
        """ start iperf client
        """
        self._kill_iperf_process(device_id, '-c', port)
        cmd = 'shell {} {} -c {} -p {} {}'.format(SU_CMD, iperf_path, pc_ip, port, extra_cmd)
        self.exec_cmd(device_id, cmd, True)

    def stop_iperf_client(self, device_id, port):
        """ stop iperf client
        """
        self._kill_iperf_process(device_id, '-c', port)

    def detach(self, device_id):
        """ detach
        """
        airplane_setting_cmd = 'shell {} {} 1'.format(SU_CMD, CMD_AIRPLANE_SETTINGS)
        airplane_broadcast_cmd = 'shell {} {} 1'.format(SU_CMD, CMD_AIRPLANE_BROADCAST)
        self.exec_cmd(device_id, airplane_setting_cmd)
        self.exec_cmd(device_id, airplane_broadcast_cmd)
        time.sleep(1)

    def get_sw_version(self, device_id):
        """ get sw version
        :param device_id:
        :return:
        """
        return self.exec_cmd(device_id, 'shell getprop ro.build.description')

    def get_physical_cell_id(self, device_id):
        """ get physical cell id

        :param device_id:
        :return:
        """
        out = self.exec_cmd(device_id, 'shell dumpsys telephony.registry')
        m_pci_con = re.search("mCellInfo=\\[.*mPci\\s=\\s(\\d+).*\\]", out)
        return m_pci_con.groups()[0] if m_pci_con else None

    def set_apn(self, device_id, name, apn, mcc='262', mnc='03'):
        """ set apn

        :param device_id:
        :param name:
        :param apn:
        :param mcc:
        :param mnc:
        :return:
        """
        query_prefer = "content query --uri content://telephony/carriers/preferapn"
        prefer_apn = self.exec_cmd(device_id, 'shell {} {}'.format(SU_CMD, query_prefer))
        if apn in prefer_apn and name in prefer_apn:
            return True
        query_all = "content query --uri content://telephony/carriers"
        all_out = self.exec_cmd(device_id, 'shell {} {}'.format(SU_CMD, query_all))
        apn_list = all_out.split('Row')
        apn_found = False
        for apn_content in apn_list:
            if apn in apn_content and name in apn_content:
                apn_found = True
                break

        if not apn_found:
            write_debug_log_to_file(self.file_name, "Add new apn")
            insert = 'content insert --uri content://telephony/carriers --bind name:s:"{}" --bind numeric:s:"{}" ' \
                     '--bind type:s:"default" --bind mcc:i:{} --bind mnc:s:{} --bind apn:s:"{}" --bind user:s:"" ' \
                     '--bind password:s:""'.format(name, mcc+mnc, mcc, mnc, apn)
            insert_cmd = 'shell {} {}'.format(SU_CMD, insert)
            self.exec_cmd(device_id, insert_cmd)

        all_out = self.exec_cmd(device_id, 'shell {} {}'.format(SU_CMD, query_all))
        apn_id = re.search('_id=(\\d+), name={}'.format(name), all_out).groups()[0]
        set_prefer = 'content insert --uri content://telephony/carriers/preferapn --bind apn_id:i:{}'.format(apn_id)
        self.exec_cmd(device_id, 'shell {} {}'.format(SU_CMD, set_prefer))
        self.exec_cmd(device_id, 'reboot')
        time.sleep(80)

    def _kill_iperf_process(self, device_id, s_or_c, port):
        """ kill iperf process
        """
        find_cmd = 'shell "ps -ef | grep iperf {}"'.format(s_or_c)
        content = self.exec_cmd(device_id, find_cmd)
        pid = self._find_to_kill_pid(content, "iperf.*%s.*-p %s" % (s_or_c, port))
        if pid:
            kill_cmd = 'shell {} kill -9 {}'.format(SU_CMD, pid)
            self.exec_cmd(device_id, kill_cmd)
            return True

    def _find_to_kill_pid(self, content, regex):
        """ find to kill pid
        """
        pid = None
        for con in content.splitlines():
            if re.search(regex, con):
                pid = con.split()[1]
                write_debug_log_to_file(self.file_name, "find client process pid is %s \nin '%s'\nExecute 'kill -9 %s'"
                                        % (pid, con, pid))
                break
        return pid


if __name__ == "__main__":
    AdbControl().set_apn('49896eae', 'test', '123.nsn1.com')
