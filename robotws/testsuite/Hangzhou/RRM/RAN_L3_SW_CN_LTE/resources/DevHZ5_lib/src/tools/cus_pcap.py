# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
import glob
import traceback
from robot.libraries.BuiltIn import BuiltIn
from base_lib.ta_ssh_telnet import ta_ssh_telnet
from common_lib import common_lib

builtin_obj = BuiltIn()
ssh_obj = ta_ssh_telnet()
comm_obj = common_lib()


class cus_pcap(object):
    def __init__(self):
        self._setup_pcap_flag = False
        self.pcap_option = ""
        self.pcap_started = False

    def _setup_pcap(self):
        if not self._setup_pcap_flag:
            self._setup_pcap_flag = True
            self.pc_conn_for_pcap = ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute", conn_type="SSH",
                                                            timeout="10")
            builtin_obj.log("ssh connection is %s" % self.pc_conn_for_pcap)
            self.old_prompt = ssh_obj.set_shell_prompt("")
            ssh_obj.set_shell_prompt(self.old_prompt)
            self.pcap_option = builtin_obj.get_variable_value("${CUS_PCAP_OPTIONS}")

    def __del__(self):
        if self._setup_pcap_flag:
            ssh_obj.disconnect_from_host(self.pc_conn_for_pcap)

    def start_to_capture_cus_pcap(self):
        if not builtin_obj.convert_to_boolean(builtin_obj.get_variable_value('${CUS_PCAP_FLAG}')):
            return
        try:
            self._setup_pcap()
            builtin_obj.log("step: clean up")
            ssh_obj.switch_host_connection(self.pc_conn_for_pcap)
            ssh_obj.set_shell_timeout(600)
            ssh_obj.set_shell_prompt(self.old_prompt)
            builtin_obj.log("debug: prompt is {}".format(self.old_prompt))
            ssh_obj.execute_shell_command(" ")
            pids = comm_obj.get_linux_process_id("cus-pcap")
            comm_obj.kill_linux_process(pids)
            comm_obj.execute_cmd_on_pc("sudo rm -rf /home/cus/logs/pcaps")

            builtin_obj.log("step: begin to capture cus-pcap")
            ssh_obj.switch_host_connection(self.pc_conn_for_pcap)
            ssh_obj.set_shell_prompt("Press ENTER to start wireshark collection")
            ssh_obj.set_shell_timeout(600)
            ssh_obj.execute_shell_command("sudo /opt/cus/bin/cus-pcap {}".format(self.pcap_option))
            ssh_obj.set_shell_timeout(10)
            ssh_obj.set_shell_prompt("Press ENTER key to stop wireshark collection")
            ssh_obj.execute_shell_command(" ")
            self.pcap_started = True
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
            builtin_obj.log("fail to start to capture cus pcap", level="WARN")

    def stop_capture_cus_pcap(self):
        if not self.pcap_started:
            return
        try:
            self._setup_pcap()
            ssh_obj.switch_host_connection(self.pc_conn_for_pcap)
            ssh_obj.set_shell_timeout(600)
            ssh_obj.set_shell_prompt(self.old_prompt)
            ssh_obj.execute_shell_command(" ")
            pcap_list = glob.glob("/home/cus/logs/pcaps/pcaps*.tar.gz")
            if len(pcap_list) == 0:
                builtin_obj.log("fail to capture cus pcap logs", level="WARN")
            else:
                save_log_dir = comm_obj._get_save_log_dir("enb1")
                ssh_obj.execute_shell_command("mkdir -p {}/cus-pcaps".format(save_log_dir))
                ssh_obj.execute_shell_command("cp -rf /home/cus/logs/pcaps/pcaps*.tar.gz {}/cus-pcaps".format(
                    save_log_dir))
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
            builtin_obj.log("fail to stop capture cus pcap", level="WARN")
