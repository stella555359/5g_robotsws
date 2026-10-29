# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

import os
import re
import time
from robot.libraries.BuiltIn import BuiltIn
from common_lib import common_lib
from base_lib.ta_ssh_telnet import ta_ssh_telnet
from ta_emss import ta_emss

comm_obj = common_lib()
builtin_obj = BuiltIn()
ssh_obj = ta_ssh_telnet()
FCT_IP = "192.168.255.1"


class trace(object):
    def __init__(self):
        self._setup_trace_flag = False

    def _setup_trace(self):
        if not self._setup_trace_flag:
            self._setup_trace_flag = True
            self.pc_conn_for_tce = ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute", conn_type="SSH",
                                                           timeout="10")
            builtin_obj.log("ssh connection is %s" % self.pc_conn_for_tce)

    def __del__(self):
        if self._setup_trace_flag:
            ssh_obj.disconnect_from_host(self.pc_conn_for_tce)

    def start_TCE(self, port, prompt="Connection from"):
        self._setup_trace()
        tce_log_dir = builtin_obj.get_variable_value('${SAVE LOG DIRECTORY}')
        assert (port.isdigit()), "port:{} can not convert to number.".format(port)
        self.stop_TCE(port)
        time.sleep(2)
        try:
            ssh_obj.switch_host_connection(self.pc_conn_for_tce)
            if prompt == "Connection from":
                old_prompt = ssh_obj.set_shell_prompt(prompt, "connect to")
            if prompt.lower() == "listening":
                old_prompt = ssh_obj.set_shell_prompt("listening", "Listening")
            old_timeout = ssh_obj.set_shell_timeout("100")
            ssh_obj.execute_shell_command("nc -lvp %s > %s&" % (port, os.path.join(tce_log_dir, "tce_%s.txt" % port)))
        except Exception as e:
            raise Exception("start TCE failed: %s" % e)
        finally:
            ssh_obj.set_shell_prompt(old_prompt)
            ssh_obj.set_shell_timeout(old_timeout)

    def stop_TCE(self, port=""):
        pids = comm_obj.get_linux_process_id("nc -lvp", port)
        comm_obj.kill_linux_process(pids)

    def start_emss(self):
        """
        This keyword to start emss, it mainly perform the following commands:\n
        cd /opt/emssim/proxy\n
        sudo perl fbox_dual.pl\n
        ssh flexi1@localhost\n
        (password flexi1)\n
        ./start\n
        """
        emss_obj = ta_emss()
        emss_obj.setup_emss(enb_id="1")


class etws_cmas(object):
    def __init__(self):
        pass

    def send_cmas_request(self, msg_id="4372", update_number="1", repeat_period="5s",
                          broadcast_number="6", enb="1", warn_length="84", warn_msg_contents_in_hex="",
                          eaids="", tacs="", lcrs="", wait_string="MME-1: S1:WriteReplaceWarningResponse", timeout=10):

        if len(warn_msg_contents_in_hex) == 0:
            cmd = "mme_warn_request enb=%s msg_id=%s update_number=%s rep_period=%s number=%s data_coding_scheme=15 \
            warn_msg_contents_length=%s concurrent=on" % (
                enb, msg_id, update_number, repeat_period, broadcast_number, warn_length)
        else:
            cmd = "mme_warn_request enb=%s msg_id=%s update_number=%s rep_period=%s number=%s data_coding_scheme=15 \
            warn_msg_contents_in_hex=%s concurrent=on" % (
                enb, msg_id, update_number, repeat_period, broadcast_number, warn_msg_contents_in_hex)

        if len(eaids) != 0:
            for eaid in eaids.split(","):
                cmd = cmd + " eaid=%s" % hex(int(eaid.strip()))[2:].zfill(6)
        if len(tacs) != 0:
            for tac in tacs.split(","):
                cmd = cmd + " tai=%s" % tac.strip()
        if len(lcrs) != 0:
            cmd = cmd + " cell=%s" % lcrs.strip()
        out = comm_obj.execute_egate_command(cmd, wait_string, timeout=timeout)
        return out

    def kill_cmas_request(self, msg_id="4372", update_number="1", enb="1", eaids="", tacs="", lcrs="",
                          wait_string="MME-1: S1:KillResponse", timeout=10):
        cmd = "mme_warn_kill enb=%s msg_id=%s update_number=%s" % (enb, msg_id, update_number)
        if len(eaids) != 0:
            for eaid in eaids.split(","):
                cmd = cmd + " eaid=%s" % hex(int(eaid.strip()))[2:].zfill(6)
        if len(tacs) != 0:
            for tac in tacs.split(","):
                cmd = cmd + " tai=%s" % tac.strip()
        if len(lcrs) != 0:
            cmd = cmd + " cell=%s" % lcrs.strip()
        out = comm_obj.execute_egate_command(cmd, wait_string, timeout=timeout)
        return out

    def send_etws_primary_request(self, msg_id="4352", update_number="1", repeat_period="5s",
                                  broadcast_number="6", enb="1", warning_type="earthquake", alert="true",
                                  popup="true", eaids="", tacs="", lcrs="",
                                  wait_string="MME-1: S1:WriteReplaceWarningResponse", timeout=10):
        cmd = "mme_warn_request enb=%s msg_id=%s update_number=%s rep_period=%s number=%s \
        concurrent=off type=%s alert=%s popup=%s" % (
            enb, msg_id, update_number, repeat_period, broadcast_number, warning_type, alert, popup)
        if len(eaids) != 0:
            for eaid in eaids.split(","):
                cmd = cmd + " eaid=%s" % hex(int(eaid.strip()))[2:].zfill(6)
        if len(tacs) != 0:
            for tac in tacs.split(","):
                cmd = cmd + " tai=%s" % tac.strip()
        if len(lcrs) != 0:
            cmd = cmd + " cell=%s" % lcrs.strip()
        out = comm_obj.execute_egate_command(cmd, wait_string, timeout=timeout)
        return out

    def send_etws_secondary_request(self, msg_id="4352", update_number="1", repeat_period="5s",
                                    broadcast_number="6", enb="1", warn_length="84", warn_msg_contents_in_hex="",
                                    eaids="", tacs="", lcrs="", wait_string="MME-1: S1:WriteReplaceWarningResponse",
                                    timeout=10):
        if len(warn_msg_contents_in_hex) == 0:
            cmd = "mme_warn_request enb=%s msg_id=%s update_number=%s rep_period=%s number=%s concurrent=off \
            data_coding_scheme=15 warn_msg_contents_length=%s" % (
                enb, msg_id, update_number, repeat_period, broadcast_number, warn_length)
        else:
            cmd = "mme_warn_request enb=%s msg_id=%s update_number=%s rep_period=%s number=%s concurrent=off \
            data_coding_scheme=15 warn_msg_contents_in_hex=%s" % (
                enb, msg_id, update_number, repeat_period, broadcast_number, warn_msg_contents_in_hex)

        if len(eaids) != 0:
            for eaid in eaids.split(","):
                cmd = cmd + " eaid=%s" % hex(int(eaid.strip()))[2:].zfill(6)
        if len(tacs) != 0:
            for tac in tacs.split(","):
                cmd = cmd + " tai=%s" % tac.strip()
        if len(lcrs) != 0:
            cmd = cmd + " cell=%s" % lcrs.strip()
        out = comm_obj.execute_egate_command(cmd, wait_string, timeout=timeout)
        return out

    def send_etws_primary_and_secondary_request(self, msg_id="4352", update_number="1", repeat_period="5s",
                                                broadcast_number="6", enb="1", warning_type="earthquake", alert="true",
                                                popup="true", warn_length="84", eaids="", tacs="", lcrs="",
                                                wait_string="MME-1: S1:WriteReplaceWarningResponse", timeout=10):
        cmd = "mme_warn_request enb=%s msg_id=%s update_number=%s rep_period=%s number=%s concurrent=off \
        type=%s alert=%s popup=%s data_coding_scheme=15 warn_msg_contents_length=%s" % (
            enb, msg_id, update_number, repeat_period, broadcast_number, warning_type, alert, popup, warn_length)
        if len(eaids) != 0:
            for eaid in eaids.split(","):
                cmd = cmd + " eaid=%s" % hex(int(eaid.strip()))[2:].zfill(6)
        if len(tacs) != 0:
            for tac in tacs.split(","):
                cmd = cmd + " tai=%s" % tac.strip()
        if len(lcrs) != 0:
            cmd = cmd + " cell=%s" % lcrs.strip()
        out = comm_obj.execute_egate_command(cmd, wait_string, timeout=timeout)
        return out


class features(trace, etws_cmas):
    def __init__(self):
        trace.__init__(self)
        etws_cmas.__init__(self)


if __name__ == "__main__":
    obj = features()
    help(obj)
