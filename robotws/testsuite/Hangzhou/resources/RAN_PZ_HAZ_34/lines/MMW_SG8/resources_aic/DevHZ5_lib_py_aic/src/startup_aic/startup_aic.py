# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

import time
import datetime
import os
import re
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from ..common_lib_aic import common_lib_aic
from ute_fsmaccess import ute_fsmaccess
from ute_fsmaccess.exception import SSHExecutionError
from ..base_lib.ta_xml import ta_xml
from ..base_lib.ta_xml.common_xml import CommonXML
from ..base_lib.ta_ssh_telnet import ta_ssh_telnet
from taf.pdu import pdu
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import Vdu
import traceback
import json

import urllib3
# urllib3.disable_warnings()
from urllib3.exceptions import InsecureRequestWarning

urllib3.disable_warnings(InsecureRequestWarning)

comm_obj = common_lib_aic()
os_obj = OperatingSystem()
builtin_obj = BuiltIn()
xml_obj = ta_xml()
ssh_obj = ta_ssh_telnet()


class startup_base_aic(object):
    def __init__(self, alias):
        self.alias = alias
        self.alias_cu = self.alias + "_cu_startup"
        self.alias_du = self.alias
        # self.alias_du2 = self.alias + "_du2_startup"
        self._setup_comm_ssh_flag_cu = False
        self._setup_comm_ssh_flag_du = False
        self._setup_swconfig_control_flag_ap = False
        self.remote_host = None
        self._tcpdump_permission_flag = False

    def _setup_common_ssh_cu(self):
        """ssh can't instantiation twice with same name otherwise prompt Alias (cu) exists"""
        self.cu_host = builtin_obj.get_variable_value("${VCU_IP}")
        self.cu_host_ssh = builtin_obj.get_variable_value("${VCU_SSH_IP}")
        self.cu_host_ssh_usr = builtin_obj.get_variable_value(
            "${VCU_SSH_USER}")
        self.cu_host_ssh_pwd = builtin_obj.get_variable_value(
            "${VCU_SSH_PASSWD}")
        if not self._setup_comm_ssh_flag_cu:
            self._setup_comm_ssh_flag_cu = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(
                remote_host=self.remote_host,
                alias=self.alias_cu,
                prompt="$",
                user=self.cu_host_ssh_usr,
                password=self.cu_host_ssh_pwd,
                fallback_prompt="$",
                host=self.cu_host_ssh)
            self.fsm_obj.setup_wts_fsm_access(
                remote_host=self.remote_host,
                alias=self.alias,
                fallback_prompt="#")
        if self._setup_comm_ssh_flag_cu:
            if not self.fsm_obj:
                self.fsm_obj = ute_fsmaccess()
                self.fsm_obj.setup_enb_fsm_access(
                    remote_host=self.remote_host,
                    alias=self.alias_cu,
                    prompt="$",
                    fallback_prompt="$",
                    host=self.cu_host_ssh)
                self.fsm_obj.setup_wts_fsm_access(
                    remote_host=self.remote_host, alias=self.alias, fallback_prompt="#")

    def _setup_common_ssh_du(self):
        """ssh can't instantiation twice with same name otherwise prompt Alias (du) exists"""
        if not self._setup_comm_ssh_flag_du:
            self._setup_comm_ssh_flag_du = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(
                remote_host=self.remote_host,
                alias=self.alias_du,
                prompt="$",
                user=self.du_host_ssh_usr,
                password=self.du_host_ssh_pwd,
                fallback_prompt="$",
                host=self.du_host_ssh)
        if self._setup_comm_ssh_flag_du:
            if not self.fsm_obj:
                self.fsm_obj = ute_fsmaccess()
                self.fsm_obj.setup_enb_fsm_access(
                    remote_host=self.remote_host,
                    alias=self.alias_du,
                    prompt="$",
                    fallback_prompt="$",
                    host=self.du_host_ssh)

    def _setup_swconfig_control_ap(self):
        """current only ap swconfig in aic"""
        if not self._setup_swconfig_control_flag_ap:
            self._setup_swconfig_control_flag_ap = True
            self._setup_common_ssh_cu()
            self.backup_swconfig_dir = comm_obj._get_save_log_dir(self.alias)
            self.backup_swconfig_file_iphy = os.path.join(
                self.backup_swconfig_dir, "swconfig_ap.txt")
            self.modified_swconfig_file_iphy = os.path.join(
                self.backup_swconfig_dir, "swconfig_ap_modified.txt")
            self.enb_swconfig_file = "/ffs/run/swconfig.txt"

    def _start_ssh_connect_aic_for_pod_worker_node(
            self, host_ssh, host_ssh_usr, host_ssh_pwd):
        aic_conn = ssh_obj.connect_to_host(
            host_ssh,
            "22",
            host_ssh_usr,
            host_ssh_pwd,
            conn_type="SSH",
            timeout="20")
        ssh_obj.switch_host_connection(aic_conn)
        old_timeout = ssh_obj.set_shell_timeout(20)
        return aic_conn

    def _stop_ssh_connect_aic_for_pod_worker_node(self, aic_conn):
        ssh_obj.disconnect_from_host(aic_conn)

    def _start_admin_cu(self):
        self.cu_obj = cu()
        if comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu):
            return
        bts_port, use_ssl = comm_obj.define_admin_port()
        cu_ping_ok = self._ping_ok(self.cu_host)
        if cu_ping_ok:
            self.cu_obj.connect_to(
                alias=self.alias_cu,
                port=bts_port,
                secure=use_ssl,
                host=self.cu_host,
                username="Nemuadmin",
                password="Nokia@123")
        else:
            self.cu_obj.connect_to(
                alias=self.alias_cu,
                port=bts_port,
                secure=use_ssl,
                host="192.168.100.129",
                username="Nemuadmin",
                password="Nokia@123")

    def _stop_admin_cu(self):
        try:
            if comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu):
                self.cu_obj.disconnect(connection=self.alias_cu)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)

    def _start_admin_du(self):
        self.du_obj = Vdu()
        bts_port, use_ssl = comm_obj.define_admin_port()
        if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du):
            return
        du_ping_ok = self._ping_ok(self.du_host)
        if du_ping_ok:
            self.du_obj.connect_to(
                host=self.du_host,
                port=bts_port,
                username="Nemuadmin",
                password="Nokia@123",
                secure=use_ssl,
                connection_name=self.alias_du)

    def _stop_admin_du(self):
        try:
            if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du):
                self.du_obj.disconnect(vdu_connection=self.alias_du)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)

    def _get_container_namelist_aic(
            self,
            namespace,
            pod_full_name,
            container_name,
            alias):
        if alias.count("cu"):
            self._setup_common_ssh_cu()
        if alias.count("du"):
            self._setup_common_ssh_du()
        container_name_list = []
        container_check_cmd = (
            "kubectl describe pods %s -n %s |grep 'Container ID:' -B 1" %
            (pod_full_name, namespace))
        rt1 = self.fsm_obj.execute_command_on_enb(
            container_check_cmd, alias=alias)
        rt2 = rt1.split("\n")
        for ctr_name in rt2:
            if ctr_name.count("ctr-"):
                container_name_list.append(ctr_name)
        builtin_obj.log(
            "step: get %s container_name_list %s" %
            (alias, container_name))
        return container_name_list

    def _get_pods_namelist_du(self, namespace, alias):
        self._setup_common_ssh_du()
        po_du_name_list = []
        pod_check_cmd = (
            "kubectl get pods -n %s | awk '{print $1}'" %
            namespace)
        try:
            rt1 = self.fsm_obj.execute_command_on_enb(
                pod_check_cmd, alias=alias)
            for pod in rt1.split("\n")[1:]:
                if pod.strip().count("ute-") or pod.strip().count("po-") or pod.strip().count("tl-"):
                    po_du_name_list.append(pod.strip())
            builtin_obj.log("step: get du pod_name_list %s" % po_du_name_list)
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)
        finally:
            return po_du_name_list

    def _match_pod_fullname_du(self, namespace, pod_name, alias):
        po_du_name_list = self._get_pods_namelist_du(namespace, alias)
        for pod_du in po_du_name_list:
            if pod_du.count("-%s-" % pod_name):
                pod_full_name = pod_du
                break
        return pod_full_name

    def _find_pod_fullname_du(self, namespace, pod_name):
        """pod_name: brief podname like as cprt/up"""
        return self._match_pod_fullname_du(
            namespace, pod_name, alias=self.alias_du)

    def _match_container_fullname_aic(
            self,
            namespace,
            pod_full_name,
            container_name,
            alias):
        container_name_list = self._get_container_namelist_aic(
            namespace, pod_full_name, container_name, alias)
        for ctr_full_name in container_name_list:
            if ctr_full_name.count("ctr-" + container_name + ":"):
                container_fullname = ctr_full_name.split(":")[0].strip()
                break
        return container_fullname

    def _find_container_fullname_cu(self, pod_name, container_name, namespace):
        pod_full_name = self._find_pod_fullname_cu(namespace, pod_name)
        return self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias=self.alias_cu)

    def _find_container_fullname_du(self, pod_name, container_name, namespace):
        pod_full_name = self._find_pod_fullname_du(namespace, pod_name)
        return self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias=self.alias_du)

    def _get_pods_namelist_cu(self, namespace, alias):
        self._setup_common_ssh_cu()
        pod_cu_name_list = []
        pod_check_cmd = (
            "kubectl get pods -n %s | awk '{print $1}'" % namespace)
        rt1 = self.fsm_obj.execute_command_on_enb(pod_check_cmd, alias=alias)
        for pod in rt1.split("\n")[1:]:
            if pod.strip().count("ute-") or pod.strip().count("po-") or pod.strip().count("tl-"):
                pod_cu_name_list.append(pod.strip())
        return pod_cu_name_list

    def _get_container_namelist_cu(self, namespace, pod_name, alias):
        self._setup_common_ssh_cu()
        container_name_list = []
        container_check_cmd = (
            "kubectl describe pods %s -n %s |grep 'Container ID:' -B 1" %
            (pod_name, namespace))
        rt1 = self.fsm_obj.execute_command_on_enb(
            container_check_cmd, alias=alias)
        rt2 = rt1.split("\n")
        for ctr_name in rt2:
            if ctr_name.count("ctr-"):
                container_name_list.append(ctr_name)
        builtin_obj.log(
            "step: get cu container_name_list %s" %
            container_name_list)
        return container_name_list

    def _match_pod_fullname_cu(
            self,
            namespace,
            pod_name,
            alias,
            redundantRole="active"):
        redundant_flag = builtin_obj.get_variable_value(
            "${REDUNDANT_MODE_CU_FLAG}")
        pod_cu_name_list = self._get_pods_namelist_cu(namespace, alias)
        for pod_cu in pod_cu_name_list:
            if pod_cu.count("-%s-" % pod_name):
                if str(redundant_flag).capitalize() == "True":
                    pod_full_name = self._check_pod_is_active_or_standby(
                        pod_cu_name_list, namespace, pod_cu, redundantRole, alias)
                    if pod_full_name is not None:
                        return pod_full_name
                    else:
                        continue
                else:
                    pod_full_name = pod_cu
                    return pod_full_name

    def _check_pod_is_active_or_standby(
            self,
            pod_name_list,
            namespace,
            pod_full_name,
            redundantRole,
            alias):
        """return a data list include all pod info with dict"""
        # ute-7-7-ute5gcloudt7sk021-healing-controller-0
        for pod in pod_name_list:
            if pod.count("-healing-controller-"):
                set_check_cmd = (
                    "kubectl exec -i %s -n %s -- curl -fsSX"
                    " GET http://healing-controller:50056/api/vnfcmgmt/v1/vnfcs" %
                    (pod, namespace))
                break
        data_str = self.fsm_obj.execute_command_on_enb(
            set_check_cmd, alias=alias)
        data_dic = json.loads(data_str)
        for pod_data in data_dic["data"]:
            if pod_data["name"] == pod_full_name:
                if "redundantRole" in pod_data:
                    if pod_data["redundantRole"].lower(
                    ) == redundantRole.lower():
                        return pod_full_name
                    else:
                        # redundantRole is not match
                        return None
                else:
                    # no redundantRole, it means this pod is not redundant
                    # pod,will return first match
                    return pod_full_name

    def _find_pod_fullname_cu(self, namespace, pod_name):
        """pod_name: brief podname like as cpcl/cpnb/cpnrt/cpue/upue"""
        return self._match_pod_fullname_cu(
            namespace, pod_name, alias=self.alias_cu)

    def _capture_wireshark_log_aic(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            alias,
            redundantRole="active",
            protocol="sctp",
            interface="any port 36422 or port 38472 or port 38462 or port 38412 or port 38422",
            timeout="10"):
        """ default store path in cu,du: /tmp/tmp_wireshark
            pod_prefix, container_prefix may be different in real testline,check later.
            container_name:  short name(e.g. cpif, cpnrt, up, ...)
        """
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias, redundantRole)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias)
        if alias.count("du"):
            try:
                self.fsm_obj.start_command_on_enb(
                    "sudo pkill -f -9 tcpdump", alias=alias)
            except Exception as e:
                builtin_obj.log(
                    'sudo pkill tcpdump unsuccessful or killed already in previous step,%s' %
                    e)
        elif alias.count("cu"):
            set_kill_tcpdump_cmd = (
                "kubectl exec -i " +
                pod_full_name +
                " -n " +
                namespace +
                " -c " +
                container_fullname +
                " -- pkill -f -9 tcpdump")
            builtin_obj.log(set_kill_tcpdump_cmd)
            try:
                self.fsm_obj.start_command_on_enb(
                    set_kill_tcpdump_cmd, alias=alias)
            except Exception as e:
                builtin_obj.log(
                    "kill tcpdump unsuccessful or tcpdump already killed: %s" %
                    e)
            # delete cmd process in cu master
            try:
                self.fsm_obj.start_command_on_enb(
                    "ps -ef|grep -v grep|grep %s.*tcpdump|awk '{print $2}'|xargs sudo kill -9" %
                    container_fullname, alias=alias)
            except Exception as e:
                builtin_obj.log(e)
        wireshark_name_in_aic = "_" + wireshark_name + ".pcap"
        set_clear_file_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- rm -r /tmp/tmp_wireshark")
        builtin_obj.log(set_clear_file_cmd)
        try:
            self.fsm_obj.execute_command_on_enb(
                set_clear_file_cmd, alias=alias)
        except Exception as e:
            builtin_obj.log("clear unsuccessful: %s" % e)
        set_wireshark_path_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- mkdir -p /tmp/tmp_wireshark")
        builtin_obj.log(set_wireshark_path_cmd)
        self.fsm_obj.execute_command_on_enb(
            set_wireshark_path_cmd, alias=alias)
        set_wireshark_capture_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- execwithcaps -q -- tcpdump -i " +
            protocol +
            " -i " +
            interface +
            " " +
            " -s 0 -w " +
            "/tmp/tmp_wireshark" +
            "/" +
            pod_name +
            wireshark_name_in_aic +
            "&")
        builtin_obj.log(set_wireshark_capture_cmd)
        set_check_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- ps -ef | grep tcpdump")
        for check_num in range(3):
            time.sleep(1)
            self.fsm_obj.start_command_on_enb(
                set_wireshark_capture_cmd, alias=alias)
            time.sleep(1)
            tcpdump_cmd_state = self._check_tcpdump_cmd_execute_successful(
                set_check_cmd, alias=alias)
            if tcpdump_cmd_state is False:
                builtin_obj.log(
                    "Try round-%s wireshark log capture in %s" %
                    (check_num + 2, alias), level="INFO")
                if alias.count("du"):
                    try:
                        self.fsm_obj.start_command_on_enb(
                            "sudo pkill tcpdump", alias=alias)
                    except Exception as e:
                        builtin_obj.log(
                            'sudo pkill tcpdump unsuccessful or killed already in previous step,%s' %
                            e)
                elif alias.count("cu"):
                    try:
                        self.fsm_obj.start_command_on_enb(
                            set_kill_tcpdump_cmd, alias=alias)
                        self.fsm_obj.start_command_on_enb(
                            "ps -ef|grep -v grep|grep %s.*tcpdump|awk '{print $2}'|"
                            "xargs sudo kill -9" %
                            container_fullname, alias=alias)
                    except Exception as e:
                        builtin_obj.log(
                            "kill tcpdump unsuccessful or tcpdump already killed: %s" %
                            e)
                    if check_num == 2:
                        self.fsm_obj.start_command_on_enb(
                            set_wireshark_capture_cmd, alias=alias)
            else:
                break

    def _check_tcpdump_cmd_execute_successful(self, check_cmd, alias):
        check_ret = None
        try:
            check_ret, rc_code = self.fsm_obj.execute_command_on_enb(
                check_cmd, return_rc=True, alias=alias)
        except Exception as e:
            builtin_obj.log(
                "check_ret:%s,rc_code:%s, ..%s.." %
                (check_ret, rc_code, e))
        if check_ret is None:
            execute_state = False
        else:
            if check_ret.count("tcpdump -i sctp -i any"):
                execute_state = True
                builtin_obj.log("%s" % check_ret)
                builtin_obj.log(
                    "Wireshark log capture starting successful",
                    level="INFO")
            else:
                execute_state = False
                builtin_obj.log("%s" % check_ret)
                builtin_obj.log(
                    "Wireshark log capture starting fail in %s" %
                    alias, level="INFO")
        return execute_state

    def _capture_wireshark_log_aic_workaround_cu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            alias,
            redundantRole="active"):
        self._setup_common_ssh_cu()
        if alias.count("du"):
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias, redundantRole)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias)
        wireshark_name_in_aic = pod_name + "_" + wireshark_name + ".pcap"
        set_clear_file_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- rm -r /tmp/tmp_wireshark")
        builtin_obj.log(set_clear_file_cmd)
        try:
            self.fsm_obj.execute_command_on_enb(
                set_clear_file_cmd, alias=alias)
            # solve Permissions 0664 for '/var/home/core/.ssh/id_rsa' are too
            # open.
            self.fsm_obj.execute_command_on_enb(
                "chmod 600 /var/home/core/.ssh/id_rsa", alias=alias)
        except Exception as e:
            builtin_obj.log("clear unsuccessful: %s" % e)
        set_wireshark_path_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- mkdir -p /tmp/tmp_wireshark")
        builtin_obj.log(set_wireshark_path_cmd)
        self.fsm_obj.execute_command_on_enb(
            set_wireshark_path_cmd, alias=alias)
        aic_conn = self._start_ssh_connect_aic_for_pod_worker_node(
            self.cu_host_ssh, self.cu_host_ssh_usr, self.cu_host_ssh_pwd)
        ssh_obj.switch_host_connection(aic_conn)
        set_worker_node_cmd = (
            "kubectl get pod %s -o yaml -n %s|grep nodeName | awk '{print $2}'" %
            (pod_full_name, namespace))
        builtin_obj.log(set_worker_node_cmd)
        worker_node = ssh_obj.execute_shell_command(set_worker_node_cmd)
        builtin_obj.log("%s worker_node:%s" % (pod_name, worker_node))
        old_prompt = ssh_obj.set_shell_prompt("Password:", r"password:", r"$")
        old_timeout = ssh_obj.set_shell_timeout("10")
        ssh_obj.execute_shell_command(
            "ssh -o StrictHostKeyChecking=no %s" %
            worker_node)
        ssh_obj.set_shell_prompt(old_prompt)
        ssh_obj.set_shell_timeout(old_timeout)
        ssh_obj.execute_shell_command(self.cu_host_ssh_pwd)
        aic_container_id = None
        set_pid_id_cmd = (
            "echo '%s' | sudo -S crictl ps |grep '%s '|awk '{print $1}'" %
            (self.cu_host_ssh_pwd, container_fullname))
        try:
            builtin_obj.log(set_pid_id_cmd)
            pid_id_rt = ssh_obj.execute_shell_command(set_pid_id_cmd)
            aic_container_id = pid_id_rt.split(":")[0].strip()
        except Exception as e:
            builtin_obj.log("get pod pid unsuccessful, try again")
            time.sleep(1)
            builtin_obj.log("try again:%s" % set_pid_id_cmd)
            pid_id_rt = ssh_obj.execute_shell_command(set_pid_id_cmd)
            aic_container_id = pid_id_rt.split(":")[0].strip()
        builtin_obj.log("step: get aic_pod_id %s" % aic_container_id)
        set_container_pid_cmd = (
            "echo '%s' | sudo -S crictl inspect --output yaml %s |grep 'pid:'" %
            (self.cu_host_ssh_pwd, aic_container_id))
        builtin_obj.log(set_container_pid_cmd)
        container_pid_rt = ssh_obj.execute_shell_command(set_container_pid_cmd)
        containter_pid_num = container_pid_rt.split(":")[1].strip()
        set_wireshark_capture_cmd = (
            "echo '%s' | sudo -S nsenter -m -n -t %s tcpdump -i any sctp -s 0 "
            "-w /tmp/tmp_wireshark/%s&" %
            (self.cu_host_ssh_pwd, containter_pid_num, wireshark_name_in_aic))
        builtin_obj.log(set_wireshark_capture_cmd)
        old_prompt = ssh_obj.set_shell_prompt("tcpdump: listening on")
        ssh_obj.execute_shell_command(set_wireshark_capture_cmd)
        self._stop_ssh_connect_aic_for_pod_worker_node(aic_conn)

    def _capture_wireshark_log_aic_du(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            alias,
            protocol="sctp",
            interface="any",
            timeout="10"):
        """ default store path in cu,du: /tmp/tmp_wireshark
            pod_prefix, container_prefix may be different in real testline,check later.
            container_name:  short name(e.g. cprt, up, l2hi, l2rt, l1hi...)
        """
        self._setup_common_ssh_du()
        if alias.count("du"):
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias)
        wireshark_name_in_aic = "_" + wireshark_name + ".pcap"
        set_clear_file_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- rm -r /tmp/tmp_wireshark")
        builtin_obj.log(set_clear_file_cmd)
        try:
            self.fsm_obj.execute_command_on_enb(
                set_clear_file_cmd, alias=alias)
        except Exception as e:
            builtin_obj.log("clear unsuccessful: %s" % e)
        set_wireshark_path_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- mkdir -p /tmp/tmp_wireshark")
        builtin_obj.log(set_wireshark_path_cmd)
        self.fsm_obj.execute_command_on_enb(
            set_wireshark_path_cmd, alias=alias)
        self._capture_wireshark_log_aic_workaround_du(
            pod_name, container_name, namespace, wireshark_name, alias=alias)

    def _capture_wireshark_log_aic_workaround_du(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            alias):
        """ Add WA for wireshark capture due to new version in DU can't using tcpdump in future version
            'tcpdump -i f1c sctp -s 0 -w' : just capture sctp interface otherwise pcap file will be huge.
        """
        wireshark_name_in_aic = "_" + wireshark_name + ".pcap"
        self._setup_common_ssh_du()
        if alias.count("du"):
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias)
        builtin_obj.log(container_fullname)
        try:
            # solve Permissions 0664 for '/var/home/core/.ssh/id_rsa' are too
            # open.
            self.fsm_obj.execute_command_on_enb(
                "chmod 600 /var/home/core/.ssh/id_rsa", alias=alias)
        except Exception as e:
            builtin_obj.log("change id_rsa property unsuccessful: %s" % e)
        set_check_pod_pid_cmd = ("sudo crictl ps | grep %s" % pod_name)
        builtin_obj.log(set_check_pod_pid_cmd)
        pod_pid_rt = self.fsm_obj.execute_command_on_enb(
            set_check_pod_pid_cmd, alias=alias)
        builtin_obj.log(pod_pid_rt)
        pod_pid_value = None
        for pod_pid in pod_pid_rt.split("\n")[0:]:
            if re.match(
                r'(\w+) (.*) .* (%s ).*' %
                container_fullname,
                    pod_pid.strip()):
                pod_pid_value = re.match(
                    r'(\w+) (.*) .* (%s ).*' %
                    container_fullname,
                    pod_pid.strip()).group(1).strip()
        set_check_container_pid_cmd = (
            "sudo crictl inspect --output yaml %s | grep 'pid:'" %
            pod_pid_value)
        builtin_obj.log(set_check_container_pid_cmd)
        container_pid_rt = self.fsm_obj.execute_command_on_enb(
            set_check_container_pid_cmd, alias=alias)
        container_pid_value = container_pid_rt.split("pid:")[-1].strip()
        set_capture_wireshark_cmd_wa = (
            "nohup sudo nsenter -r -n -t " +
            container_pid_value +
            " tcpdump -i f1c sctp -s 0 -w " +
            "/tmp/tmp_wireshark" +
            "/" +
            pod_name +
            wireshark_name_in_aic +
            " >/tmp/nohup.out 2>&1 &")
        builtin_obj.log(set_capture_wireshark_cmd_wa)
        self.fsm_obj.execute_command_on_enb(
            set_capture_wireshark_cmd_wa, alias=alias)

    def _judge_tcpdump_permission_in_vcu(
            self,
            pod_name,
            container_name,
            namespace,
            redundantRole,
            alias):
        """judge tcpdump if permission in cu deploy version,
            using tcpdump capture wireshark,otherwise using nsenter
        """
        self._setup_common_ssh_cu()
        if alias.count("du"):
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias, redundantRole)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias)
        set_judge_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- execwithcaps -q -- tcpdump --print -c 3")
        judge_rt = self.fsm_obj.execute_command_on_enb(
            set_judge_cmd, alias=alias)
        return judge_rt

    def _capture_wireshark_log_in_vcu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            redundantRole):
        try:
            judge_rt = self._judge_tcpdump_permission_in_vcu(
                pod_name, container_name, namespace, redundantRole, alias=self.alias_cu)
            if re.findall(
                    re.compile(
                        r".*%s.*" %
                        pod_name,
                        flags=re.I | re.M),
                    judge_rt):
                builtin_obj.log("tcpdump permission allowed")
            else:
                builtin_obj.log(
                    "judge tcpdump permission unsuccessful",
                    level="WARN")
            self._tcpdump_permission_flag = True
            self._capture_wireshark_log_aic(
                pod_name,
                container_name,
                namespace,
                wireshark_name,
                alias=self.alias_cu,
                redundantRole=redundantRole)
        except Exception as e:
            builtin_obj.log(e)
            self._tcpdump_permission_flag = False
            self._capture_wireshark_log_aic_workaround_cu(
                pod_name,
                container_name,
                namespace,
                wireshark_name,
                alias=self.alias_cu,
                redundantRole=redundantRole)

    def _capture_wireshark_log_in_vdu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name):
        syscom_flag = builtin_obj.get_variable_value("${SYSCOM_FLAG}")
        if str(syscom_flag).capitalize() == "True":
            self._capture_wireshark_log_aic(
                pod_name,
                container_name,
                namespace,
                wireshark_name,
                alias=self.alias_du,
                interface="any port 36422 or port 38472 or port 38462 or port 38412 "
                "or port 38422 or port 49155 or port 49156")
        else:
            self._capture_wireshark_log_aic(
                pod_name,
                container_name,
                namespace,
                wireshark_name,
                alias=self.alias_du)
        # below WA with nsenter is not used due to new Aic deployment
        # self._capture_wireshark_log_aic_du(pod_name, container_name, namespace, wireshark_name, alias=self.alias_du)

    def _stop_wireshark_capture_aic(
            self,
            pod_name,
            container_name,
            namespace,
            alias):
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias)
        if alias.count("du"):
            try:
                self.fsm_obj.execute_command_on_enb(
                    "sudo pkill tcpdump", alias=alias)
            except Exception as e:
                builtin_obj.log(
                    'sudo pkill tcpdump unsuccessful or killed already in previous step,%s' %
                    e)
        elif alias.count("cu"):
            set_kill_tcpdump_cmd = (
                "kubectl exec -i " +
                pod_full_name +
                " -n " +
                namespace +
                " -c " +
                container_fullname +
                " -- pkill -f tcpdump")
            builtin_obj.log(set_kill_tcpdump_cmd)
            try:
                self.fsm_obj.start_command_on_enb(
                    set_kill_tcpdump_cmd, alias=alias)
                self.fsm_obj.start_command_on_enb(
                    "ps -ef|grep -v grep|grep %s.*tcpdump|awk '{print $2}'|xargs sudo kill -9" %
                    container_fullname, alias=alias)
            except Exception as e:
                builtin_obj.log(
                    "kill tcpdump unsuccessful or tcpdump already killed: %s" %
                    e)

    def _pure_download_wireshark_log_to_master(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            alias,
            timeout="10"):
        """this kw pure download wireshark log from vCU/vDU container to vCU/vDU master node"""
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias)
        # set_wireshark_download_cmd = (
        #     "kubectl cp " + "-n " + namespace + " " + pod_full_name +
        #     ":tmp/tmp_wireshark" + " " + log_dir_in_master + " -c " + container_fullname)
        set_wireshark_download_cmd = (
            "kubectl exec " +
            "-n " +
            namespace +
            " " +
            pod_full_name +
            " -c " +
            container_fullname +
            " -- cat /tmp/tmp_wireshark/" +
            wireshark_name +
            " > " +
            log_dir_in_master +
            "/" +
            wireshark_name)
        builtin_obj.log(set_wireshark_download_cmd)
        self.fsm_obj.execute_command_on_enb(
            set_wireshark_download_cmd, alias=alias)

    def _download_wireshark_log_to_master(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            alias,
            teardown=False,
            timeout="10"):
        """Example:
           log_dir_in_master:   '/tmp/tmp_wireshark'
           stop wireshark log in du is different with CU
           this kw contain _stop_wireshark_capture_aic and _pure_download_wireshark_log_to_master
        """
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias)
        if alias.count("du"):
            try:
                self.fsm_obj.execute_command_on_enb(
                    "sudo pkill tcpdump", alias=alias)
            except Exception as e:
                builtin_obj.log(
                    'sudo pkill tcpdump unsuccessful or killed already in previous step,%s' %
                    e)
        elif alias.count("cu"):
            set_kill_tcpdump_cmd = (
                "kubectl exec -i " +
                pod_full_name +
                " -n " +
                namespace +
                " -c " +
                container_fullname +
                " -- pkill -f tcpdump")
            builtin_obj.log(set_kill_tcpdump_cmd)
            try:
                self.fsm_obj.start_command_on_enb(
                    set_kill_tcpdump_cmd, alias=alias)
                self.fsm_obj.start_command_on_enb(
                    "ps -ef|grep -v grep|grep %s.*tcpdump|awk '{print $2}'|xargs sudo kill -9" %
                    container_fullname, alias=alias)
            except Exception as e:
                builtin_obj.log(
                    "kill tcpdump unsuccessful or tcpdump already killed: %s" %
                    e)
        # set_wireshark_download_cmd = (
        #     "kubectl cp " + "-n " + namespace + " " + pod_full_name +
        #     ":tmp/tmp_wireshark" + " " + log_dir_in_master + " -c " + container_fullname)
        if teardown is True:
            set_wireshark_name_check_cmd = (
                "kubectl exec " +
                "-n " +
                namespace +
                " " +
                pod_full_name +
                " -c " +
                container_fullname +
                " -- ls /tmp/tmp_wireshark/")
        else:
            set_wireshark_name_check_cmd = (
                "kubectl exec " +
                "-n " +
                namespace +
                " " +
                pod_full_name +
                " -c " +
                container_fullname +
                " -- ls -l /tmp/tmp_wireshark/" +
                wireshark_name)
        builtin_obj.log(set_wireshark_name_check_cmd)
        try:
            ret_pcap = self.fsm_obj.execute_command_on_enb(
                set_wireshark_name_check_cmd, alias=alias)
            builtin_obj.log(ret_pcap)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
            if detail.count("No such file or directory"):
                return
        if teardown is True:
            if ret_pcap != '':
                set_wireshark_download_cmd = (
                    "kubectl exec " +
                    "-n " +
                    namespace +
                    " " +
                    pod_full_name +
                    " -c " +
                    container_fullname +
                    " -- cat /tmp/tmp_wireshark/" +
                    ret_pcap +
                    " > " +
                    log_dir_in_master +
                    "/" +
                    ret_pcap)
            else:
                return
        else:
            set_wireshark_download_cmd = (
                "kubectl exec " +
                "-n " +
                namespace +
                " " +
                pod_full_name +
                " -c " +
                container_fullname +
                " -- cat /tmp/tmp_wireshark/" +
                wireshark_name +
                " > " +
                log_dir_in_master +
                "/" +
                wireshark_name)
        builtin_obj.log(set_wireshark_download_cmd)
        self.fsm_obj.execute_command_on_enb(
            set_wireshark_download_cmd, alias=alias)
        if teardown is True:
            if ret_pcap != '':
                return ret_pcap

    def _stop_wireshark_capture_aic_workaround_cu(
            self, pod_name, namespace, alias):
        """wireshark need be kill from pod worker-node due to vcu is working in cu cluster"""
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        aic_conn = self._start_ssh_connect_aic_for_pod_worker_node(
            self.cu_host_ssh, self.cu_host_ssh_usr, self.cu_host_ssh_pwd)
        ssh_obj.switch_host_connection(aic_conn)
        set_worker_node_cmd = (
            "kubectl get pod %s -o yaml -n %s|grep nodeName | awk '{print $2}'" %
            (pod_full_name, namespace))
        builtin_obj.log(set_worker_node_cmd)
        worker_node = ssh_obj.execute_shell_command(set_worker_node_cmd)
        old_prompt = ssh_obj.set_shell_prompt("Password:", r"password:", r"$")
        old_timeout = ssh_obj.set_shell_timeout("10")
        ssh_obj.execute_shell_command(
            "ssh -o StrictHostKeyChecking=no %s" %
            worker_node)
        ssh_obj.set_shell_prompt(old_prompt)
        ssh_obj.set_shell_timeout(old_timeout)
        ssh_obj.execute_shell_command(self.cu_host_ssh_pwd)
        try:
            tcpdump_rt = ssh_obj.execute_shell_command(
                "echo '%s' | ps -ef |grep %s |awk '{print $2}'" %
                (self.cu_host_ssh_pwd, "/tmp/tmp_wireshark"))
            pid_for_tcpdump_list = tcpdump_rt.splitlines()
            for pid in pid_for_tcpdump_list:
                pid_kill_rt = ssh_obj.execute_shell_command(
                    "echo '%s' | sudo -S kill %s" %
                    (self.cu_host_ssh_pwd, pid.strip()))
                builtin_obj.log("xk_pid_kill_rt: %s" % pid_kill_rt)
        except Exception as e:
            builtin_obj.log(e)
        finally:
            ssh_obj.disconnect_from_host(aic_conn)

    def _download_wireshark_log_to_master_workaround_cu(
            self,
            pod_name,
            container_name,
            namespace,
            log_dir_in_master,
            alias,
            timeout="10"):
        """Example:
           log_dir_in_master:   '/tmp/tmp_wireshark'
           stop wireshark log in vcu is different with vDU once tcpdump is forbiden due to vcu in cu cluster.
        """
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias)
        if alias.count("du"):
            try:
                self.fsm_obj.execute_command_on_enb(
                    "sudo pkill tcpdump", alias=alias)
            except Exception as e:
                builtin_obj.log(
                    'sudo pkill tcpdump unsuccessful or killed already in previous step,%s' %
                    e)
        elif alias.count("cu"):
            try:
                self._stop_wireshark_capture_aic_workaround_cu(
                    pod_name, namespace, alias)
            except Exception as e:
                builtin_obj.log(
                    "kill tcpdump unsuccessful or tcpdump already killed: %s" %
                    e)
        set_wireshark_download_cmd = (
            "kubectl cp " +
            "-n " +
            namespace +
            " " +
            pod_full_name +
            ":tmp/tmp_wireshark" +
            " " +
            log_dir_in_master +
            " -c " +
            container_fullname)
        builtin_obj.log(set_wireshark_download_cmd)
        self.fsm_obj.execute_command_on_enb(
            set_wireshark_download_cmd, alias=alias)

    def _download_wireshark_log_to_master_vcu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            teardown):
        # remove WA
        # if self._tcpdump_permission_flag is True:
        return self._download_wireshark_log_to_master(
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            alias=self.alias_cu,
            teardown=teardown)
        # else:
        #     self._download_wireshark_log_to_master_workaround_cu(pod_name, container_name, namespace,
        # log_dir_in_master, alias=self.alias_cu)

    def _download_wireshark_log_to_master_vdu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            teardown):
        return self._download_wireshark_log_to_master(
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            alias=self.alias_du,
            teardown=teardown)

    def _pure_download_wireshark_log_to_master_vcu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master):
        self._pure_download_wireshark_log_to_master(
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            alias=self.alias_cu)

    def _pure_download_wireshark_log_to_master_vdu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master):
        self._pure_download_wireshark_log_to_master(
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            alias=self.alias_du)

    def _stop_wireshark_capture_aic_vcu(
            self, pod_name, container_name, namespace):
        # remove WA
        # if self._tcpdump_permission_flag is True:
        self._stop_wireshark_capture_aic(
            pod_name, container_name, namespace, alias=self.alias_cu)
        # else:
        #     self._stop_wireshark_capture_aic_workaround_cu(pod_name, namespace, alias=self.alias_cu)

    def _stop_wireshark_capture_aic_vdu(
            self, pod_name, container_name, namespace):
        self._stop_wireshark_capture_aic(
            pod_name, container_name, namespace, alias=self.alias_du)

    def _get_wireshark_aic(self, src, dst, alias):
        if alias.count("du"):
            self._setup_common_ssh_du()
        if alias.count("cu"):
            self._setup_common_ssh_cu()
        self.fsm_obj.get_enb_file(src, dst, alias=alias)

    def _get_wireshark_aic_vcu(self, src, dst):
        self._get_wireshark_aic(src, dst, alias=self.alias_cu)

    def _get_wireshark_aic_vdu(self, src, dst):
        self._get_wireshark_aic(src, dst, alias=self.alias_du)

    def _get_bip_aic_vdu(self, src, dst):
        self._setup_common_ssh_du()
        self.fsm_obj.get_enb_file(src, dst, alias=self.alias_du)

    def _capture_aic_bip_log(
            self,
            namespace,
            pod_name,
            container_name,
            bip_port_name,
            alias):
        """bip log is captured in L1/L2 up pod, l1hi l2hi l2ps l2lo using sharing same bip channel,
           no l1hi in dRANIC, so change default to l2hi.
           bip file folder in /tmp/dpdkdump in container with size 10G.
        """
        self._setup_common_ssh_du()
        pod_full_name = self._match_pod_fullname_du(
            namespace, pod_name, alias=alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias=alias)
        set_clear_file_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- rm -r /tmp/dpdkdump/*")
        builtin_obj.log(set_clear_file_cmd)
        try:
            self.fsm_obj.execute_command_on_enb(
                set_clear_file_cmd, alias=alias)
        except Exception as e:
            builtin_obj.log("clear unsuccessful: %s" % e)
        set_check_bip_link_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -c " +
            container_fullname +
            " -n " +
            namespace +
            " bash -- hal-cli show port table")
        bip_link_status = self.fsm_obj.execute_command_on_enb(
            set_check_bip_link_cmd, alias=alias)
        builtin_obj.log(bip_link_status)
        set_check_bip_port_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -c " +
            container_fullname +
            " -n " +
            namespace +
            " bash -- hal-cli show port table | grep " +
            bip_port_name +
            " | awk '{print $1}'")
        builtin_obj.log(set_check_bip_port_cmd)
        bip_port_number = self.fsm_obj.execute_command_on_enb(
            set_check_bip_port_cmd, alias=alias)
        time.sleep(1)
        # here change bip_port_number to "all" for capture all port in l2rt and
        # l2nrt
        set_capture_bip_cmd = ("kubectl exec -i " + pod_full_name + " -c " + container_fullname + " -n " +
                               namespace + " -- hal-cli pdump port %s path /tmp/dpdkdump >"
                                           " /tmp/%s_bip_start.log 2>&1") % ("all", pod_name)
        builtin_obj.log(set_capture_bip_cmd)
        # use try to avoid sometime kw execute failure
        try:
            self.fsm_obj.start_command_on_enb(set_capture_bip_cmd, alias=alias)
        except Exception as e:
            pass
        time.sleep(1)
        set_check_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- ps -ef | grep pdump")
        # here change bip_port_number check to "all" for check port "all" in
        # l2rt and l2nrt
        set_ppid_check_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- ps -ef | grep 'hal-cli pdump port all path /tmp/dpdkdump' | awk '{print $2}'")
        set_pid_check_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- ps -ef | grep 'dpdk-pdump' | awk '{print $3}'")
        bip_cmd_state = False
        bip_cmd_state_timeout = 30
        while bip_cmd_state is False and bip_cmd_state_timeout >= 0:
            bip_cmd_state = self._check_pdump_cmd_execute_successful(
                set_check_cmd, set_ppid_check_cmd, set_pid_check_cmd, alias=alias)
            if bip_cmd_state is False:
                set_kill_pdump_cmd = (
                    "kubectl exec -i " +
                    pod_full_name +
                    " -c " +
                    container_fullname +
                    " -n " +
                    namespace +
                    " -- pkill pdump")
                builtin_obj.log(set_kill_pdump_cmd)
                self.fsm_obj.start_command_on_enb(
                    set_kill_pdump_cmd, alias=alias)
                time.sleep(2)
                self.fsm_obj.start_command_on_enb(
                    set_capture_bip_cmd, alias=alias)
                bip_cmd_state_timeout -= 5
            else:
                break

    def _check_pdump_cmd_execute_successful(
            self,
            check_cmd,
            set_ppid_check_cmd,
            set_pid_check_cmd,
            alias):
        # sleep for bip cmd execution finish
        builtin_obj.log("start to check bip process")
        time.sleep(1)
        check_ret = 'none'
        execute_state = False
        try:
            check_ret = self.fsm_obj.execute_command_on_enb(
                check_cmd, alias=alias)
        except Exception as e:
            builtin_obj.log("check pdump process failure, will try again")
        if check_ret.count(
                "dpdk-pdump") and check_ret.count("hal-cli pdump port all path /tmp/dpdkdump"):
            ppid_ret = self.fsm_obj.execute_command_on_enb(
                set_ppid_check_cmd, alias=alias)
            pid_ret = self.fsm_obj.execute_command_on_enb(
                set_pid_check_cmd, alias=alias)
            builtin_obj.log("ppid:%s, pid:%s" % (ppid_ret, pid_ret))
            if ppid_ret == pid_ret:
                execute_state = True
                builtin_obj.log("%s" % check_ret)
                builtin_obj.log(
                    "Bip log capture starting successful",
                    level="INFO")
            else:
                builtin_obj.log("%s" % check_ret)
                builtin_obj.log(
                    "Bip log capture starting successful but pid abnormal",
                    level="INFO")
        else:
            builtin_obj.log("%s" % check_ret)
            builtin_obj.log("Bip log capture starting fail", level="INFO")
        return execute_state

    def _capture_aic_bip_log_du(
            self,
            namespace,
            pod_name,
            container_name,
            bip_port_name):
        self._capture_aic_bip_log(
            namespace,
            pod_name,
            container_name,
            bip_port_name,
            alias=self.alias_du)

    def _download_bip_log_to_master(
            self,
            pod_name,
            container_name,
            namespace,
            log_dir_in_master,
            alias,
            timeout="10"):
        """Example:
           log_dir_in_master:   '/tmp/tmp_bip'
        """
        self._setup_common_ssh_du()
        pod_full_name = self._match_pod_fullname_du(
            namespace, pod_name, alias=alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias=alias)
        set_wireshark_download_cmd = (
            "kubectl cp " +
            "-n " +
            namespace +
            " " +
            pod_full_name +
            ":tmp/dpdkdump" +
            " " +
            log_dir_in_master +
            " -c " +
            container_fullname)
        builtin_obj.log(set_wireshark_download_cmd)
        self.fsm_obj.execute_command_on_enb(
            set_wireshark_download_cmd, alias=alias)

    def _download_bip_log_to_master_vdu(
            self,
            pod_name,
            container_name,
            namespace,
            log_dir_in_master):
        self._download_bip_log_to_master(
            pod_name,
            container_name,
            namespace,
            log_dir_in_master,
            alias=self.alias_du)

    def _stop_capture_bip_log_du(self, namespace, pod_name, container_name):
        self._setup_common_ssh_du()
        pod_full_name = self._match_pod_fullname_du(
            namespace, pod_name, alias=self.alias_du)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias=self.alias_du)
        set_stop_capture_bip_cmd = (
            "kubectl exec -i " + pod_full_name + " -c " + container_fullname +
            " -n " + namespace + " -- pkill pdump")
        self.fsm_obj.execute_command_on_enb(
            set_stop_capture_bip_cmd, alias=self.alias_du)

    def _collect_coredump_log_cu(self):
        self._install_coredump_tools(productVariant="cu")
        self._collect_coredump_by_coredump(productVariant="cu")
        self._download_coredump_to_ute(productVariant="cu")

    def _collect_coredump_log_du(self, du_identity="du"):
        self._install_coredump_tools(productVariant="du")
        self._collect_coredump_by_coredump(productVariant="du")
        self._download_coredump_to_ute(
            productVariant="du", du_identity=du_identity)

    def _install_coredump_tools(self, productVariant):
        if productVariant == "du":
            self._setup_common_ssh_du()
            self._install_coredump_tools_du(self.alias_du)
        if productVariant == "cu":
            self._setup_common_ssh_cu()
            self._install_coredump_tools_cu(self.alias_cu)

    def _collect_coredump_by_coredump(self, productVariant):
        if productVariant == "du":
            self._setup_common_ssh_du()
            self._collect_coredump_du(self.alias_du)
        if productVariant == "cu":
            self._setup_common_ssh_cu()
            self._collect_coredump_cu(self.alias_cu)

    def _download_coredump_to_ute(self, productVariant, du_identity="du"):
        if productVariant == "du":
            self._setup_common_ssh_du()
            self._download_coredump_to_ute_du(
                self.alias_du, du_identity=du_identity)
        if productVariant == "cu":
            self._setup_common_ssh_cu()
            self._download_coredump_to_ute_cu(self.alias_cu)

    def _install_coredump_tools_du(self, alias):
        builtin_obj.log("install coredump tool du")
        cmd = "export https_proxy=\"http://10.158.100.1:8080\""
        self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
        cmd = "export no_proxy=\"localhost,127.0.0.1,*.local,nsn-net.net,inside.nokiasiemensnetworks.com," \
              "access.nokiasiemensnetworks.com,nsn-intra.net,nsn-rdnet.net," \
              "halebopp.eecloud.dynamic.nsn-net.net,artifactory-espoo1.ext.net.nokia.com," \
              "artifactory-espoo1.int.net.nokia.com,nesc.nokia.net," \
              "microsoftonline.com,onmicrosoft.com,*.svc\""
        self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
        cmd = "helm repo add koredump https://nokia.github.io/koredump/"
        self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
        cmd = "helm repo update"
        self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
        cmd = "helm repo list"
        self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
        cmd = "helm install -n koredump koredump koredump/koredump"
        self.fsm_obj.execute_command_on_enb(cmd, alias=alias)

    def _install_coredump_tools_cu(self, alias):
        builtin_obj.log("install coredump tool cu")
        cmd = "helm repo add koredump https://nokia.github.io/koredump/"
        self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
        cmd = "helm repo update"
        self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
        cmd = "helm repo list"
        self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
        cmd = "helm install -n koredump koredump koredump/koredump"
        self.fsm_obj.execute_command_on_enb(cmd, alias=alias)

    def _collect_coredump_du(self, alias):
        builtin_obj.log("collect coredump by koredump in du")
        try:
            self.fsm_obj.execute_command_on_enb(
                "rm /tmp/%s/coredump/*  -rf" %
                self.vdu_namespace, alias=alias)
        except SSHExecutionError:
            pass
        try:
            self.fsm_obj.execute_command_on_enb(
                "mkdir /tmp/%s/coredump " %
                self.vdu_namespace, alias=alias)
        except SSHExecutionError:
            pass
        self.fsm_obj.execute_command_on_enb(
            "cd /tmp/%s/coredump " %
            self.vdu_namespace, alias=alias)
        cmd = ('koredumpctl list -n ' + self.vdu_namespace + ' | wc -l')
        result = self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
        if 'Nothing found.' not in result:
            cmd = ('nohup koredumpctl get -a -n ' + self.vdu_namespace + '&')
            self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
            self._collect_coredump_wait_finish(alias=alias)
            cmd = ('nohup tar -cvf coredumplog.gz *.lz4 &')
            self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
            self._collect_coredump_wait_finish(alias=alias)
        else:
            builtin_obj.log(
                "collect coredump by koredump , there is no core dump file")

    def _collect_coredump_cu(self, alias):
        builtin_obj.log("collect coredump by koredump in cu")
        vcu_namespace = builtin_obj.get_variable_value("${VCU_NAMESPACE}")
        try:
            self.fsm_obj.execute_command_on_enb(
                "rm /tmp/%s/coredump/*  -rf" %
                vcu_namespace, alias=alias)
        except SSHExecutionError:
            pass
        try:
            self.fsm_obj.execute_command_on_enb(
                "mkdir /tmp/%s/coredump " %
                vcu_namespace, alias=alias)
        except SSHExecutionError:
            pass
        self.fsm_obj.execute_command_on_enb(
            "cd /tmp/%s/coredump " %
            vcu_namespace, alias=alias)
        cmd = ('koredumpctl list -n ' + vcu_namespace + ' | wc -l')
        result = self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
        if 'Nothing found.' not in result:
            cmd = ('nohup koredumpctl get -a -n ' + vcu_namespace + '&')
            self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
            self._collect_coredump_wait_finish(alias=alias)
            cmd = ('nohup tar -cvf coredumplog.gz *.lz4 &')
            self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
            self._collect_coredump_wait_finish(alias=alias)
        else:
            builtin_obj.log(
                "collect coredump by koredump , there is no core dump file")

    def _collect_coredump_wait_finish(self, alias):
        builtin_obj.log("collect coredump wait for finish")
        finish_flag = False
        while finish_flag is False:
            out0 = self.fsm_obj.execute_command_on_enb(
                'cat nohup.out | wc -l', alias=alias)
            out0 = out0.strip()
            time.sleep(5)
            out1 = self.fsm_obj.execute_command_on_enb(
                'cat nohup.out | wc -l', alias=alias)
            out1 = out1.strip()
            if out0 is out1:
                finish_flag = True

    def _download_coredump_to_ute_cu(self, alias):
        builtin_obj.log("download coredump to ute for cu")
        log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        log_dir = os.path.join(log_dir, "coredump_cu")
        if not os.path.exists(log_dir):
            os.mkdir(log_dir)
        namespace = builtin_obj.get_variable_value("${VCU_NAMESPACE}")
        remote_file = '/tmp/%s/coredump/coredumplog.gz' % namespace
        self.fsm_obj.get_enb_file(remote_file, log_dir, alias=alias)

    def _download_coredump_to_ute_du(self, alias, du_identity="du"):
        builtin_obj.log("download coredump to ute for du")
        log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        log_dir = os.path.join(log_dir, "coredump_%s" % du_identity)
        if not os.path.exists(log_dir):
            os.mkdir(log_dir)
        remote_file = '/tmp/%s/coredump/coredumplog.gz' % self.vdu_namespace
        self.fsm_obj.get_enb_file(remote_file, log_dir, alias=alias)

    def _reboot_airphone_aic(self):
        self._setup_common_ssh_cu()
        # https://confluence.ext.net.nokia.com/display/AirPhoneWTS/7+-+Failure+-+switch+of+partition+on+airphone
        self.fsm_obj.start_command_on_wts(
            "ddal -s ddal_boot_set_reset_loop_count 0\n",
            alias=self.alias)
        time.sleep(3)
        self.fsm_obj.start_command_on_wts("reboot\n", alias=self.alias)

    def _get_cells_info(self):
        """not administrativeState in AiC, need check blocking state in du/du2 if need later.."""
        cells_info = []
        try:
            self._start_admin_cu()
            scf = "/home/ute/scf_cu.xml"
            self.cu_obj.get_current_plan_file(
                path="/home/ute/scf_cu.xml",
                include_runtime_data=True,
                timeout=100,
                connection=self.alias_cu)
            commonxml_obj = CommonXML(scf)
            all_elements = commonxml_obj.get_elements(
                "//*[matches(@class, '.*:NRCELL$')]")
            for each_element in all_elements:
                cell = {}
                dn = commonxml_obj.get_element_attribute(
                    each_element, "distName")
                instance_id = dn.rpartition("-")[-1]
                each_element = commonxml_obj.element_to_string(each_element)
                # administrativeState = xml_obj.read_xml(each_element, "text|//*[@name='administrativeState']")
                cellDepType = xml_obj.read_xml(
                    each_element, "text|//*[@name='cellDepType']")
                lcrid = xml_obj.read_xml(
                    each_element, "text|//*[@name='lcrId']")
                cell["instance_id"] = instance_id
                # cell["administrativeState"] = administrativeState
                cell["cellDepType"] = cellDepType
                cell["lcrid"] = lcrid
                cells_info.append(cell)
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix(
                "fail to get cells info", level="WARN")
            raise Exception("fail to get cells info: {}".format(detail))
        finally:
            self._stop_admin_cu()
        builtin_obj.log("cells_info:%s" % cells_info)
        return cells_info

    def _wait_ng_link_up_aic(self, timeout="120"):
        comm_obj.log_to_console_with_time_prefix("step: wait NG Link up..")
        start_time = datetime.datetime.now()
        interval = 10
        retry_times = int(timeout) / interval
        while retry_times > 0:
            nglink = self._get_overall_nglink_state_cu()
            print('## nglink: {}'.format(nglink))
            if nglink == "available":
                endtime = datetime.datetime.now()
                time_elapse = (endtime - start_time).seconds
                comm_obj.log_to_console_with_time_prefix(
                    "step: wait NG link up between AMF and gnb cost %s sec" % time_elapse)
                break
            else:
                retry_times = retry_times - 1
                time.sleep(interval)
        if retry_times == 0:
            comm_obj.log_to_console_with_time_prefix(
                "@@@ Fail to setup NG link.", level="WARN")
            raise Exception("@@@ Fail to setup NG link.")

    def _check_e1_link_status_cu(self):
        e1c_cucp_status = self._get_parameter_value_cu(
            "NRBTS-.*:e1CLinkStatusCuCp")
        e1c_cuup_status = self._get_parameter_value_cu(
            "NRBTS-.*:e1CLinkStatusCuUp")
        if e1c_cucp_status != "available":
            comm_obj.log_to_console_with_time_prefix(
                "e1CLinkStatusCuCp is %s" %
                e1c_cucp_status, level="WARN")
        else:
            comm_obj.log_to_console_with_time_prefix(
                "e1CLinkStatusCuCp is %s" %
                e1c_cucp_status, level="INFO")
        if e1c_cuup_status != "available":
            comm_obj.log_to_console_with_time_prefix(
                "e1CLinkStatusCuUp is %s" %
                e1c_cuup_status, level="WARN")
        else:
            comm_obj.log_to_console_with_time_prefix(
                "e1CLinkStatusCuUp is %s" %
                e1c_cuup_status, level="INFO")

    def _check_f1c_link_status_cu(self):
        du_num = builtin_obj.get_variable_value("${DU_NUMBER}")
        du1_f1clink_status = None
        du2_f1clink_status = None
        du3_f1clink_status = None
        du4_f1clink_status = None
        try:
            self._start_admin_cu()
            du1_ret = self.cu_obj.get_du(du_id=1, connection=self.alias_cu)
            du1_f1clink_status = du1_ret["f1_link_status"]
            if du_num != "du" and du_num >= "2du":
                du2_ret = self.cu_obj.get_du(du_id=2, connection=self.alias_cu)
                du2_f1clink_status = du2_ret["f1_link_status"]
            if du_num != "du" and du_num >= "3du":
                du3_ret = self.cu_obj.get_du(du_id=3, connection=self.alias_cu)
                du3_f1clink_status = du3_ret["f1_link_status"]
            if du_num != "du" and du_num >= "4du":
                du4_ret = self.cu_obj.get_du(du_id=4, connection=self.alias_cu)
                du4_f1clink_status = du4_ret["f1_link_status"]
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        finally:
            self._stop_admin_cu()
            if du1_f1clink_status != "available":
                comm_obj.log_to_console_with_time_prefix(
                    "du1_f1clink_status is %s" %
                    du1_f1clink_status, level="WARN")
            else:
                comm_obj.log_to_console_with_time_prefix(
                    "du1_f1clink_status is %s" %
                    du1_f1clink_status, level="INFO")
            if du_num != "du" and du_num >= "2du":
                if du2_f1clink_status != "available":
                    comm_obj.log_to_console_with_time_prefix(
                        "du2_f1clink_status is %s" %
                        du2_f1clink_status, level="WARN")
                else:
                    comm_obj.log_to_console_with_time_prefix(
                        "du2_f1clink_status is %s" %
                        du2_f1clink_status, level="INFO")
            if du_num != "du" and du_num >= "3du":
                if du3_f1clink_status != "available":
                    comm_obj.log_to_console_with_time_prefix(
                        "du3_f1clink_status is %s" %
                        du3_f1clink_status, level="WARN")
                else:
                    comm_obj.log_to_console_with_time_prefix(
                        "du3_f1clink_status is %s" %
                        du3_f1clink_status, level="WARN")
            if du_num != "du" and du_num >= "4du":
                if du4_f1clink_status != "available":
                    comm_obj.log_to_console_with_time_prefix(
                        "du4_f1clink_status is %s" %
                        du4_f1clink_status, level="WARN")
                else:
                    comm_obj.log_to_console_with_time_prefix(
                        "du4_f1clink_status is %s" %
                        du4_f1clink_status, level="WARN")

    def _capture_syslog_in_vcu(self, namespace, pod_name):
        self._capture_syslog_aic(namespace, pod_name, alias=self.alias_cu)

    def _capture_syslog_in_vdu(self, namespace, pod_name):
        self._capture_syslog_aic(namespace, pod_name, alias=self.alias_du)

    def _capture_syslog_aic(self, namespace, pod_name, alias, timeout="10"):
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)

        ctl_log_name = "ctr-logprocessor"
        login_po_cmd = (
            "kubectl exec -i " + "-n " + namespace + ' ' +
            pod_full_name + ' -c ' + ctl_log_name + " -- ls /var/log/syslog/")
        builtin_obj.log(login_po_cmd)
        all_syslog_list = self.fsm_obj.execute_command_on_enb(
            login_po_cmd, alias=alias)
        builtin_obj.log("get all syslog name {}".format(all_syslog_list))
        if all_syslog_list:
            for syslog_name in all_syslog_list.split():
                if 'syslog' in syslog_name:
                    remove_syslog_cmd = (
                        "kubectl exec -i " +
                        "-n " +
                        namespace +
                        ' ' +
                        pod_full_name +
                        ' -c ' +
                        ctl_log_name +
                        " -- rm /var/log/syslog/{}".format(syslog_name))
                    builtin_obj.log(
                        "remove syslog cmd: {}".format(remove_syslog_cmd))
                    self.fsm_obj.execute_command_on_enb(
                        remove_syslog_cmd, alias=alias)
                else:
                    continue

    def _capture_startup_log_in_vcu(self, namespace):
        self._setup_common_ssh_cu()
        self.fsm_obj.execute_command_on_enb(
            'rm -rf /tmp/{}/tmp_startup_log; mkdir /tmp/{}/tmp_startup_log'.format(namespace, namespace),
            alias=self.alias_cu)
        pod_types = {
            'cpue': 'cpue',
            'cpcl': 'cpcl',
            'cpif': 'cpif',
            'cpnb': 'cpnb',
            'cpnrt': 'cpnrt',
            'upue': 'l2hicu',
            'oamcm': 'oamcm'}
        for key in pod_types:
            pod_full_name = self._match_pod_fullname_cu(
                namespace, key, alias=self.alias_cu)
            container_fullname = self._match_container_fullname_aic(
                namespace, pod_full_name, pod_types[key], alias=self.alias_cu)
            self._capture_startup_log_aic(
                namespace,
                pod_full_name,
                container_fullname,
                alias=self.alias_cu)

    def _capture_startup_log_in_vdu(self, namespace):
        self._setup_common_ssh_du()
        self.fsm_obj.execute_command_on_enb(
            'rm -rf /tmp/{}/tmp_startup_log; mkdir /tmp/{}/tmp_startup_log'.format(namespace, namespace),
            alias=self.alias_du)
        pod_types = {
            'cprt': 'cprt',
            'up': 'l2hi',
            'oamcm': 'oamcm'}
        for key in pod_types:
            pod_full_name = self._match_pod_fullname_cu(
                namespace, key, alias=self.alias_du)
            container_fullname = self._match_container_fullname_aic(
                namespace, pod_full_name, pod_types[key], alias=self.alias_du)
            self._capture_startup_log_aic(
                namespace,
                pod_full_name,
                container_fullname,
                alias=self.alias_du)

    def _capture_startup_log_aic(
            self,
            namespace,
            pod_full_name,
            container_name,
            alias,
            timeout="10"):
        get_startup_cmd = (
            'kubectl exec -i ' + '-n ' + namespace + ' ' +
            pod_full_name + ' -c ' + container_name + ' -- ls /tmp/')
        builtin_obj.log(get_startup_cmd)
        startup_name = ''
        all_log_list = self.fsm_obj.execute_command_on_enb(
            get_startup_cmd, alias=alias)
        for log_name in all_log_list.split():
            if 'startup' in log_name:
                startup_name = log_name
                cmd = (
                    'kubectl cp ' +
                    '-n ' +
                    namespace +
                    ' ' +
                    pod_full_name +
                    ':tmp/' +
                    startup_name +
                    ' /tmp/' +
                    namespace +
                    '/tmp_startup_log/' +
                    pod_full_name +
                    '-' +
                    startup_name +
                    ' -c ' +
                    container_name)
                builtin_obj.log(cmd)
                self.fsm_obj.execute_command_on_enb(cmd, alias=alias)
        if not startup_name:
            raise Exception(
                "Warning: the {}:{}:{} only {} in tmp, not startup logs".format(
                    namespace, pod_full_name, container_name, all_log_list))
        startup_log_list = self.fsm_obj.execute_command_on_enb(
            'ls -l /tmp/{}/tmp_startup_log/'.format(namespace), alias=alias)
        builtin_obj.log('all startup log {}'.format(startup_log_list))

    def _get_syslog_to_ute(self, syslog_name, log_path_ute, namespace, alias):
        if alias.count("du"):
            self._setup_common_ssh_du()
        if alias.count("cu"):
            self._setup_common_ssh_cu()
        src_path = '/tmp/%s/' % namespace + syslog_name + '.txt.zip'
        builtin_obj.log('src_path {}'.format(src_path))
        # builtin_obj.log('dest_path {}'.format(log_path_ute))
        self.fsm_obj.get_enb_file(src_path, log_path_ute, alias=alias)

    def _download_syslog_from_vcu(self, namespace, syslog_name, log_path_ute):
        self._download_syslog_aic(namespace, syslog_name, alias=self.alias_cu)
        self._get_syslog_to_ute(
            syslog_name,
            log_path_ute,
            namespace,
            alias=self.alias_cu)

    def _download_syslog_from_vdu(self, namespace, syslog_name, log_path_ute):
        self._download_syslog_aic(namespace, syslog_name, alias=self.alias_du)
        self._get_syslog_to_ute(
            syslog_name,
            log_path_ute,
            namespace,
            alias=self.alias_du)

    def _download_syslog_aic(
            self,
            namespace,
            syslog_name,
            alias,
            timeout="10"):
        if alias.count("du"):
            self._setup_common_ssh_du()
            lwsd_full_name = self._match_pod_fullname_du(
                namespace, 'lwsd', alias)
            logservice_pod_fullname = self._match_pod_fullname_du(
                namespace, 'logservice', alias)
            logservice_container_fullname = self._match_container_fullname_aic(
                namespace, logservice_pod_fullname, 'logprocessor', alias=alias)
            lwsd_container_name = self._match_container_fullname_aic(
                namespace, lwsd_full_name, 'lwsd', alias=alias)
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            lwsd_full_name = self._match_pod_fullname_cu(
                namespace, 'lwsd', alias)
            logservice_pod_fullname = self._match_pod_fullname_cu(
                namespace, 'logservice', alias)
            logservice_container_fullname = self._match_container_fullname_aic(
                namespace, logservice_pod_fullname, 'logprocessor', alias=alias)
            lwsd_container_name = self._match_container_fullname_aic(
                namespace, lwsd_full_name, 'lwsd', alias=alias)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        get_url_link_cmd = (
            "kubectl exec " +
            "-n " +
            namespace +
            ' ' +
            lwsd_full_name +
            " -c " +
            lwsd_container_name +
            """ -- lwsd get-services | grep "url" | awk -F \\" '{print $4}' |grep /log_data """)
        url_link = self.fsm_obj.execute_command_on_enb(
            """ {} """.format(get_url_link_cmd), alias=alias)
        builtin_obj.log(url_link)
        syslog_new_name = namespace + syslog_name
        download_syslog_cmd = (
            "kubectl exec -n " +
            namespace +
            ' ' +
            logservice_pod_fullname +
            ' -c ' +
            logservice_container_fullname +
            """ -- curl -X GET "{}" -H "Accept-Encoding: gzip" >/tmp/{}/{}.txt.zip """.format(
                url_link,
                namespace,
                syslog_name))
        builtin_obj.log(download_syslog_cmd)
        self.fsm_obj.execute_command_on_enb(download_syslog_cmd, alias=alias)

    def _download_startup_log_from_vcu(self, namespace, log_path_ute):
        self._get_startup_log_to_ute(
            namespace, log_path_ute, alias=self.alias_cu)

    def _download_startup_log_from_vdu(self, namespace, log_path_ute):
        self._get_startup_log_to_ute(
            namespace, log_path_ute, alias=self.alias_du)

    def _get_startup_log_to_ute(self, namespace, log_path_ute, alias):
        if alias.count("du"):
            self._setup_common_ssh_du()
        if alias.count("cu"):
            self._setup_common_ssh_cu()
        startup_log_list = self.fsm_obj.execute_command_on_enb(
            'ls /tmp/{}/tmp_startup_log/'.format(namespace), alias=alias)
        builtin_obj.log('startup log {}'.format(startup_log_list))
        for log_name in startup_log_list.split():
            src_path = '/tmp/{}/tmp_startup_log/{}'.format(namespace, log_name)
            builtin_obj.log('src_path {}'.format(src_path))
            self.fsm_obj.get_enb_file(
                src_path, '{}/{}'.format(log_path_ute, log_name), alias=alias)

    def _capture_journal_log_in_vcu(self, namespace):
        self._setup_common_ssh_cu()
        self.fsm_obj.execute_command_on_enb(
            'rm -rf /tmp/{}/tmp_journal_log; mkdir /tmp/{}/tmp_journal_log'.format(namespace, namespace),
            alias=self.alias_cu)
        pod_types = {
            'oamcm': 'oamcm',
            'cpue': 'cpue',
            'cpcl': 'cpcl',
            'cpif': 'cpif',
            'cpnb': 'cpnb',
            'cpnrt': 'cpnrt',
            'upue': 'l2hicu'}
        for key in pod_types:
            pod_full_name = self._match_pod_fullname_cu(
                namespace, key, alias=self.alias_cu)
            container_fullname = self._match_container_fullname_aic(
                namespace, pod_full_name, pod_types[key], alias=self.alias_cu)
            self._capture_journal_log_aic(
                namespace,
                pod_full_name,
                container_fullname,
                alias=self.alias_cu)

    def _capture_journal_log_in_vdu(self, namespace):
        self._setup_common_ssh_du()
        self.fsm_obj.execute_command_on_enb(
            'rm -rf /tmp/{}/tmp_journal_log; mkdir /tmp/{}/tmp_journal_log'.format(namespace, namespace),
            alias=self.alias_du)
        pod_types = {
            'cprt': 'cprt',
            'l2nrt': 'l2hi',
            'oamconfig': 'oamconfig',
            'oamcm': 'oamcm'}
        for key in pod_types:
            pod_full_name = self._match_pod_fullname_du(
                namespace, key, alias=self.alias_du)
            container_fullname = self._match_container_fullname_aic(
                namespace, pod_full_name, pod_types[key], alias=self.alias_du)
            self._capture_journal_log_aic(
                namespace,
                pod_full_name,
                container_fullname,
                alias=self.alias_du)

    def _capture_journal_log_aic(
            self,
            namespace,
            pod_full_name,
            container_name,
            alias,
            timeout="10"):
        if alias.count("du"):
            self._setup_common_ssh_du()
        if alias.count("cu"):
            self._setup_common_ssh_cu()
        get_journal_cmd = (
            ' kubectl logs ' +
            '-n ' +
            namespace +
            ' ' +
            pod_full_name +
            ' -c ' +
            container_name +
            '>/tmp/{}/tmp_journal_log/'.format(namespace) +
            pod_full_name +
            '-' +
            'journal.log')
        builtin_obj.log(get_journal_cmd)
        self.fsm_obj.execute_command_on_enb(get_journal_cmd, alias=alias)
        journal_log_list = self.fsm_obj.execute_command_on_enb(
            'ls -l /tmp/{}/tmp_journal_log/'.format(namespace), alias=alias)
        builtin_obj.log('all journal log {}'.format(journal_log_list))

    def _download_journal_log_from_vcu(self, namespace, log_path_ute):
        self._get_journal_log_to_ute(
            namespace, log_path_ute, alias=self.alias_cu)

    def _download_journal_log_from_vdu(self, namespace, log_path_ute):
        self._get_journal_log_to_ute(
            namespace, log_path_ute, alias=self.alias_du)

    def _get_journal_log_to_ute(self, namespace, log_path_ute, alias):
        if alias.count("du"):
            self._setup_common_ssh_du()
        if alias.count("cu"):
            self._setup_common_ssh_cu()
        journal_log_list = self.fsm_obj.execute_command_on_enb(
            'ls /tmp/{}/tmp_journal_log/'.format(namespace), alias=alias)
        builtin_obj.log('journal log {}'.format(journal_log_list))
        for log_name in journal_log_list.split():
            src_path = '/tmp/{}/tmp_journal_log/{}'.format(namespace, log_name)
            builtin_obj.log('src_path {}'.format(src_path))
            self.fsm_obj.get_enb_file(
                src_path, '{}/{}'.format(log_path_ute, log_name), alias=alias)

    def _get_parameter_value_cu(self, param_name):
        param_value = None
        try:
            self._start_admin_cu()
            scf = "/home/ute/scf.xml"
            self.cu_obj.get_current_plan_file(
                path="/home/ute/scf.xml",
                include_runtime_data=True,
                timeout=100,
                connection=self.alias_cu)
            xpath = comm_obj.match_to_xpath(param_name)
            param_value = xml_obj.read_xml(scf, "text|%s" % xpath[0])
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
            param_value = None
        finally:
            self._stop_admin_cu()
            return param_value

    def _get_overall_x2link_state_cu(self):
        param_values = []
        try:
            self._start_admin_cu()
            scf = "/home/ute/scf.xml"
            self.cu_obj.get_current_plan_file(
                path="/home/ute/scf.xml",
                include_runtime_data=True,
                timeout=100,
                connection=self.alias_cu)
            commonxml = CommonXML(scf)
            xpath = comm_obj.match_to_xpath("LTEENB-.*:x2LinkStatus")
            all_elements = commonxml.get_elements("text|%s" % xpath[0])
            for element in all_elements:
                param_values.append(commonxml.get_element_text(element))
            if len(param_values) == 0 or (
                    "unavailable" in param_values and len(param_values) > 0):
                overall_state = "unavailable"
            else:
                overall_state = "available"
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
            overall_state = None
        finally:
            self._stop_admin_cu()
            return overall_state

    def _get_overall_nglink_state_cu(self):
        param_values = []
        try:
            self._start_admin_cu()
            scf = "/home/ute/scf.xml"
            self.cu_obj.get_current_plan_file(
                path="/home/ute/scf.xml",
                include_runtime_data=True,
                timeout=100,
                connection=self.alias_cu)
            commonxml = CommonXML(scf)
            xpath = comm_obj.match_to_xpath("SERVEDAMF-.*:ngLinkStatus")
            all_elements = commonxml.get_elements("text|%s" % xpath[0])
            print(' @@@ ALL Nglink element: {} '.format(all_elements))
            for element in all_elements:
                param_values.append(commonxml.get_element_text(element))
                print(
                    ' @@@ ALL Nglink Value: {} '.format(commonxml.get_element_text(element)))
            if len(param_values) == 0 or (
                    "Inactive" in param_values and len(param_values) > 0):
                overall_state = "unavailable"
            else:
                overall_state = "available"
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
            overall_state = None
        finally:
            self._stop_admin_cu()
            return overall_state

    def _configure_sctp_aic(self):
        """need check if different in aic***"""
        builtin_obj.log("step: configure SCTP on WTS")
        comm_obj.execute_cmd_on_pc("sudo sysctl -w net.sctp.sack_timeout=20")
        comm_obj.execute_cmd_on_pc("sudo sysctl -w net.sctp.rto_min=100")
        # https://confluence.ext.net.nokia.com/display/AirPhoneWTS/Known+issues
        # ,id=10,change to 100
        comm_obj.execute_cmd_on_pc("sudo sysctl -w net.sctp.rto_initial=200")
        comm_obj.execute_cmd_on_pc("sudo sysctl -w net.sctp.rto_max=800")
        builtin_obj.log("step: configure SCTP on AP")
        fsm_obj = ute_fsmaccess()
        fsm_obj.setup_wts_fsm_access(
            remote_host=self.remote_host,
            alias="cfg_sctp",
            fallback_prompt="#")
        fsm_obj.execute_command_on_wts(
            "sysctl -w net.sctp.sack_timeout\\=20",
            alias="cfg_sctp")
        fsm_obj.execute_command_on_wts(
            "sysctl -w net.sctp.rto_min\\=100",
            alias="cfg_sctp")
        fsm_obj.execute_command_on_wts(
            "sysctl -w net.sctp.rto_initial\\=200",
            alias="cfg_sctp")
        fsm_obj.execute_command_on_wts(
            "sysctl -w net.sctp.rto_max\\=800",
            alias="cfg_sctp")
        fsm_obj.teardown_wts_fsm_access(alias="cfg_sctp")

    def _wait_cells_onair_aic(self, alias, cell_id="all", du_identity="du"):
        self._start_admin_du()
        if builtin_obj.get_variable_value("${TEST NAME}") != "None":
            builtin_obj.log(
                "step: wait %s all cell state reach enable" %
                du_identity)
        else:
            comm_obj.log_to_console_with_time_prefix(
                "step: wait %s all cell state reach enable" %
                du_identity, "INFO")
        time_start = time.time()
        try:
            while True:
                du_cells_status_info = self.du_obj.get_vdu_cells_status(
                    vdu_connection=alias)
                du_cell_onair = {}
                du_cell_not_onair = {}
                du_cells_status_info_dic = {}
                if cell_id.lower() == "all":
                    for du_cell_status in du_cells_status_info:
                        if du_cell_status["operational_state"] == "enabled":
                            du_cell_onair[du_cell_status["name"]
                                          ] = du_cell_status["operational_state"]
                        else:
                            du_cell_not_onair[du_cell_status["name"]
                                              ] = du_cell_status["operational_state"]
                else:
                    # initial cells_to_check list
                    cells_to_check = []
                    if isinstance(cell_id, int) or isinstance(cell_id, str):
                        cells_to_check = [int(cell_id)]
                    elif isinstance(cell_id, tuple):
                        cells_to_check = list(cell_id)
                    for i in du_cells_status_info:
                        du_cells_status_info_dic[int(i['id'])] = i
                    for du_cell_id in cells_to_check:
                        if int(du_cell_id) in du_cells_status_info_dic:
                            if du_cells_status_info_dic[du_cell_id]["operational_state"] != "enabled":
                                du_cell_not_onair[du_cells_status_info_dic[int(du_cell_id)]["name"]] = \
                                    du_cells_status_info_dic[int(du_cell_id)]["operational_state"]
                            else:
                                du_cell_onair[du_cells_status_info_dic[int(du_cell_id)]["name"]] = \
                                    du_cells_status_info_dic[int(du_cell_id)]["operational_state"]
                if len(du_cell_not_onair) > 0:
                    if time.time() - time_start >= 300:
                        for onair_cell in du_cell_onair:
                            comm_obj.log_to_console_with_time_prefix("%s cell %s is %s" % (
                                du_identity, onair_cell, du_cell_onair[onair_cell]), "INFO")
                        for not_onair_cell in du_cell_not_onair:
                            comm_obj.log_to_console_with_time_prefix(
                                "%s cell %s is %s" %
                                (du_identity, not_onair_cell, du_cell_not_onair[not_onair_cell]), "WARN")
                        raise Exception(
                            "%s exist cell operational_state not reach to enabled" %
                            du_identity)
                    else:
                        time.sleep(5)
                else:
                    # comm_obj.log_to_console_with_time_prefix("%s all cell are working with onAir" % du_identity,
                    #                                          "INFO")
                    break
            time_elapse = time.time() - time_start
            if builtin_obj.get_variable_value("${TEST NAME}") != "None":
                if cell_id.lower() == "all":
                    builtin_obj.log(
                        "step: wait %s %s cell state reach enable cost %s sec" %
                        (du_identity, cell_id, int(time_elapse)))
                else:
                    builtin_obj.log(
                        "step: wait %s cell%s state reach enable cost %s sec" %
                        (du_identity, cell_id, int(time_elapse)))
            else:
                if cell_id.lower() == "all":
                    builtin_obj.log(
                        "step: wait %s %s cell state reach enable cost %s sec" %
                        (du_identity, cell_id, int(time_elapse)))
                else:
                    comm_obj.log_to_console_with_time_prefix(
                        "step: wait %s cell%s state reach enable cost %s sec" %
                        (du_identity, cell_id, int(time_elapse)))
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)
        finally:
            self._stop_admin_du()

    def _wait_sibs_aic(self, cell_id):
        cells_to_check = []
        cells_to_check = list(cell_id)
        start_time = datetime.datetime.now()
        try:
            for cell in cells_to_check:
                if isinstance(cell, tuple):
                    instance_id = cell[0]
                    lcr_id = cell[1]
                else:
                    instance_id = cell
                    lcr_id = cell
                comm_obj.log_to_console_with_time_prefix(
                    "step: wait cell%s sibs messages" % instance_id)
                comm_obj.egate_console_log_should_contain(
                    "/opt/wts/latest/egate_console.log",
                    ["cell %s: SystemInformationBlockType1-NR updated" % lcr_id,
                     "cell %s: SystemInformationBlockType2-NR updated" % lcr_id],
                    timeout=300, interval=10)
                endtime = datetime.datetime.now()
                time_elapse = (endtime - start_time).seconds
                comm_obj.log_to_console_with_time_prefix(
                    "step: wait cell%s sibs messages cost %s sec" %
                    (instance_id, time_elapse))
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix(
                "fail to wait sibs", level="WARN")
            raise Exception("fail to wait sibs: %s" % detail)

    def _wait_sibs_cmd_aic(self, cell_id='all', timeout=120, du_identity="du"):
        try:
            cells_to_check = []
            if cell_id.lower() == "all":
                builtin_obj.log(
                    "wait all cells sibs messages in %s" %
                    du_identity)
                self._start_admin_du()
                scf_du = "/home/ute/scf_%s.xml" % du_identity
                scf_name_du = "scf_%s.xml" % du_identity
                self.du_obj.get_current_plan_file(
                    local_dir_path="/home/ute/",
                    filename=scf_name_du,
                    timeout=100,
                    include_runtime_data=True,
                    vdu_connection=self.alias_du)
                commonxml_obj = CommonXML(scf_du)
                all_elements = commonxml_obj.get_elements(
                    "//*[matches(@class, '.*:NRCELL$')]")
                for each_element in all_elements:
                    dn = commonxml_obj.get_element_attribute(
                        each_element, "distName")
                    instance_id = dn.rpartition("-")[-1]
                    lcr_id = xml_obj.read_xml(
                        scf_du,
                        "text|//*[matches(@distName, '.*/NRCELL-%s$')]/*[matches(@name, 'lcrId')]" %
                        instance_id)
                    cells_to_check.append(lcr_id)
            else:
                cells_to_check = [cell_id]
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail, level="WARN")
            cells_to_check = ["1"]
        finally:
            self._stop_admin_du()

        # wait SIBs
        gnb_id = "2"
        start_time = datetime.datetime.now()
        try:
            for lcr_id in cells_to_check:
                builtin_obj.log(
                    "wait gnb-{} cell{} sibs messages".format(gnb_id, lcr_id))
                self._wait_cell_sib_aic(
                    gnb_id=gnb_id,
                    cell_id=lcr_id,
                    sib_type="sib1",
                    timeout=timeout)
                self._wait_cell_sib_aic(
                    gnb_id=gnb_id,
                    cell_id=lcr_id,
                    sib_type="sib2",
                    timeout=timeout)
            endtime = datetime.datetime.now()
            time_elapse = (endtime - start_time).seconds
            builtin_obj.log("wait sibs messages cost %s sec" % time_elapse)
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)

    def _wait_cell_sib_aic(self, gnb_id, cell_id, sib_type, timeout):
        interval = 10
        retry_times = int(timeout) / interval
        while retry_times > 0:
            lb_output = comm_obj.execute_egate_command(
                "ib_enb_cell_disp enb=%s cell=%s type=%s" %
                (gnb_id, cell_id, sib_type), "EGATE>")
            if lb_output.count("information block is unknown"):
                retry_times = retry_times - 1
                time.sleep(interval)
            else:
                break
        if retry_times == 0:
            comm_obj.execute_egate_command(
                "ib_enb_cell_disp enb=%s cell=%s" %
                (gnb_id, cell_id), "EGATE>")
            comm_obj.log_to_console_with_time_prefix(
                "no %s from gnb%s cell%s" %
                (sib_type, gnb_id, cell_id), level="WARN")
            raise Exception(
                "no %s from gnb%s cell%s" %
                (sib_type, gnb_id, cell_id))

    def _wait_x2_up_aic(self, timeout="120"):
        comm_obj.log_to_console_with_time_prefix(
            "step: wait x2 setup between LTE enb and GNB")
        start_time = datetime.datetime.now()
        interval = 10
        retry_times = int(timeout) / interval
        while retry_times > 0:
            x2link = self._get_overall_x2link_state_cu()
            if x2link == "available":
                endtime = datetime.datetime.now()
                time_elapse = (endtime - start_time).seconds
                comm_obj.log_to_console_with_time_prefix(
                    "step: wait x2 link setup cost %s sec" % time_elapse)
                break
            else:
                retry_times = retry_times - 1
                time.sleep(interval)
        if retry_times == 0:
            comm_obj.log_to_console_with_time_prefix(
                "fail to setup X2 link between LTE enb and GNB", level="WARN")
            raise Exception("fail to setup X2 link between LTE enb and GNB")

    def _cells_should_be_onair_du(
            self,
            cell_id="all",
            timeout="120",
            check_sib=True,
            du_identity="du"):
        self._wait_cells_onair_aic(
            alias=self.alias_du,
            cell_id=cell_id,
            du_identity=du_identity)
        if check_sib:
            self._wait_sibs_cmd_aic(cell_id, timeout, du_identity=du_identity)
        # sleep 12s due to PR654414:[CNI82646][NSA][TDD][ET]SGNB addition fail with non DOD cell due to
        # noRadioResourcesAvailableInTargetCell
        time.sleep(12)

    def _collect_snapshot_aic(self, snapshot_dir, productVariant):
        try:
            if productVariant == "cu":
                self._start_admin_cu()
                self.cu_obj.get_local_snapshot(
                    directory=snapshot_dir, connection=self.alias_cu)
            if productVariant == "du":
                self._start_admin_du()
                self.du_obj.get_local_snapshot(
                    directory=snapshot_dir, vdu_connection=self.alias_du)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        finally:
            if productVariant == "cu":
                self._stop_admin_cu()
            if productVariant == "du":
                self._stop_admin_du()

    def _get_vcu_version_from_helm(self, ns):
        self._setup_common_ssh_cu()
        helm_ret_cu = self.fsm_obj.execute_command_on_enb(
            "helm list -n %s| grep 'aic-vcu-0.' |awk '{print $9}'" %
            ns, alias=self.alias_cu)
        return helm_ret_cu

    def _get_vdu_version_from_helm(self, ns):
        self._setup_common_ssh_du()
        helm_ret_du = self.fsm_obj.execute_command_on_enb(
            "helm list -n %s| grep 'aic-vdu-0.' |awk '{print $9}'" %
            ns, alias=self.alias_du)
        return helm_ret_du

    def _get_aic_version(self, productVariant, ns):
        cu_version = None
        du_version = None
        try:
            if productVariant == "cu":
                self._start_admin_cu()
                cu_version = self.cu_obj.get_active_software_version(
                    connection=self.alias_cu)
            if productVariant == "du":
                self._start_admin_du()
                du_state_info = self.du_obj.get_vdu_state_data(
                    vdu_connection=self.alias_du)
                du_version = du_state_info["software_version"]
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        finally:
            if productVariant == "cu":
                self._stop_admin_cu()
                if cu_version is not None:
                    if cu_version.count('_0.250'):
                        return 'vCUCNF00' + "_" + cu_version.split("_")[-1]
                else:
                    helm_ret_cu = self._get_vcu_version_from_helm(ns)
                    if helm_ret_cu.count("0.250."):
                        cu_version = "vCUCNF00_" + \
                            str(helm_ret_cu.split("-")[-1].strip())
                return cu_version
            elif productVariant == "du":
                self._stop_admin_du()
                if du_version is not None:
                    if du_version.count('_0.300'):
                        return 'vDUCNF00' + "_" + du_version.split("_")[-1]
                else:
                    helm_ret_du = self._get_vdu_version_from_helm(ns)
                    if helm_ret_du.count("0.300."):
                        du_version = "vDUCNF00_" + \
                            str(helm_ret_du.split("-")[-1].strip())
                return du_version

    def _reset_cu(self):
        self._start_admin_cu()
        self.cu_obj.reset_cu(connection=self.alias_cu)
        self._stop_admin_cu()

    def _reset_du(self):
        self._start_admin_du()
        self.du_obj.reset_vdu(vdu_connection=self.alias_du)
        self._stop_admin_du()

    def _teardown_all_alias_for_admin_cu(self):
        cu_store_name_list = []
        cu_obj_teardown = cu()
        builtin_obj.log("cu store: %s" % cu.store.all)
        for cu_conn in cu.store.all:
            cu_store_name_list.append(cu_conn[0])
        for cu_conn_name in cu_store_name_list:
            cu_obj_teardown.disconnect(connection=cu_conn_name)

    def _teardown_all_alias_for_admin_du(self):
        du_store_name_list = []
        du_obj_teardown = Vdu()
        builtin_obj.log("Vdu store: %s" % Vdu.store.all)
        for du_conn in Vdu.store.all:
            du_store_name_list.append(du_conn[0])
        for du_conn_name in du_store_name_list:
            du_obj_teardown.disconnect(vdu_connection=du_conn_name)

    def _set_debug_log_in_cu(
            self,
            namespace,
            pod_name,
            container_name,
            pod_cfg_name):
        """this function can't set cpnrt, also can't put swconfig to cu_cpnrt due to read only system.
           pod_cfg_name: /opt/nokia/SS_CPLANE/etc/*.enb_conf.ini
        """
        self._setup_common_ssh_cu()
        pod_full_name = self._match_pod_fullname_cu(
            namespace, pod_name, alias=self.alias_cu)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias=self.alias_cu)
        if pod_name.count("cpcl"):
            controlport_name = "cpcell"
        else:
            controlport_name = pod_name
        get_cp_port_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- grep Control /opt/nokia/SS_CPLANE/etc/%s.enb_conf.ini "
            "| grep -i %s" %
            (pod_cfg_name,
             controlport_name))
        ret1 = self.fsm_obj.execute_command_on_enb(
            get_cp_port_cmd, alias=self.alias_cu)
        cp_port = ret1.split('=')[-1]
        get_cp_ip_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- netstat -l | grep %s" %
            cp_port)
        ret2 = self.fsm_obj.execute_command_on_enb(
            get_cp_ip_cmd, alias=self.alias_cu)
        cp_ip = re.match(
            r'.* ((\d+-\d+-\d+-\d+)|(\d+.\d+.\d+.\d+)).*',
            ret2).group(1).replace(
            '-',
            '.')
        set_cp_debug_log_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- /opt/nokia/SS_CPLANE/bin/set_logging_level --level trace "
            "--port %s --ip %s" %
            (cp_port,
             cp_ip))
        builtin_obj.log(set_cp_debug_log_cmd)
        ret3 = self.fsm_obj.execute_command_on_enb(
            set_cp_debug_log_cmd, alias=self.alias_cu)
        builtin_obj.log(ret3)
        return ret3

    def _change_swconfig_aic(self, flags, namespace, alias, pre_defined_flags):
        # if pre-defined flag not in input flags, append to input flags
        input_flag_names = []
        for flag in flags:
            flag_name = flag.split("=")[0]
            input_flag_names.append(flag_name)
        for pre_flag in pre_defined_flags:
            pre_flag_name = pre_flag.split("=")[0]
            if pre_flag_name not in input_flag_names:
                flags.append(pre_flag)
        builtin_obj.log("step: change swconfig flags %s" % flags)
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, "oamasm", alias=alias)
            container_fullname = self._match_container_fullname_aic(
                namespace, pod_full_name, "oamasm", alias=alias)
        if alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, "oamasm", alias=alias)
            container_fullname = self._match_container_fullname_aic(
                namespace, pod_full_name, "oamasm", alias=alias)

        # change swconfig flag
        set_check1_swconfig_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- ls -l /rpram/")
        builtin_obj.log(set_check1_swconfig_cmd)
        self.fsm_obj.execute_command_on_enb(
            set_check1_swconfig_cmd, alias=alias)
        set_clear_swconfig_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- rm -rf /rpram/swconfig.txt")
        builtin_obj.log(set_clear_swconfig_cmd)
        self.fsm_obj.execute_command_on_enb(
            set_clear_swconfig_cmd, alias=alias)
        set_add_swconfig_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- touch /rpram/swconfig.txt")
        builtin_obj.log(set_add_swconfig_cmd)
        self.fsm_obj.execute_command_on_enb(set_add_swconfig_cmd, alias=alias)

        for flag in flags:
            set_add_flag_cmd = (
                "kubectl exec -i " +
                pod_full_name +
                " -n " +
                namespace +
                " -c " +
                container_fullname +
                " -- bash -c 'echo %s >> /rpram/swconfig.txt'" %
                flag)
            self.fsm_obj.execute_command_on_enb(set_add_flag_cmd, alias=alias)
        set_check2_swconfig_cmd = (
            "kubectl exec -i " +
            pod_full_name +
            " -n " +
            namespace +
            " -c " +
            container_fullname +
            " -- cat /rpram/swconfig.txt")
        builtin_obj.log(set_check2_swconfig_cmd)
        flag_ret = self.fsm_obj.execute_command_on_enb(
            set_check2_swconfig_cmd, alias=alias)
        builtin_obj.log("setted flag:%s" % flag_ret)

    def _change_swconfig_cu(self, flags, namespace):
        """"0x10041=4",  # AaSysLogOutputMode, 0=none 1=all 2=udp 3=sic 4=standard output 5=local 6=remote 7=not valid
            only support 4 in AiC, and not set currently.
        """
        pre_defined_flags_cu = [
            "0x1003F=1",  # AaSysLogInputLevel, 0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x10040=1",  # AaSysLogOutputLevel, 0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x66001b=1",  # CP-NRT log level, default=2, 0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890001=1",  # CP-NB log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890002=1",  # CP-SB log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890003=1",  # CP-UE log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890004=1",  # CP-CL log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890005=1",  # CP-IF log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890006=1",  # CP-SCTP log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890008=1",  # CP_E2 log level
            "0x89000a=1",  # sctpDiagnosticsEnable
        ]
        # if pre-defined flag not in input flags, append to input flags
        self._change_swconfig_aic(
            flags,
            namespace,
            alias=self.alias_cu,
            pre_defined_flags=pre_defined_flags_cu)

    def _change_swconfig_du(self, flags, namespace):
        pre_defined_flags_du = [
            "0x590072=1",  # CPRT, 0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x590107=1",
            # rdResourceAuditEnabled  (This parameter is to audit resource
            # leak)
        ]
        # if pre-defined flag not in input flags, append to input flags
        self._change_swconfig_aic(
            flags,
            namespace,
            alias=self.alias_du,
            pre_defined_flags=pre_defined_flags_du)

    def _change_swconfig_airphone_aic(self, flags, swconfig_file):
        self._setup_swconfig_control_ap()
        flags = comm_obj.remove_empty_from_list(flags)
        # log level may be not as expected in swconfig.txt,
        # because there is timing issue between the value set in CCSEarlyConfig.xml and swconfig.txt.
        # in TA framework, set both swconfig.txt and execute egate command sim_debug_log after onair.
        # so log level may be not as expected during startup, but case will
        # have the right log level.
        ap_udplog_level = builtin_obj.get_variable_value("${AP_UDPLOG_LEVEL}")
        mandatory_flags = [
            "0x1003F={}".format(ap_udplog_level),  # ERadCcs_AaSysLogInputLevel
            # ERadCcs_AaSysLogOutputLevel
            "0x10040={}".format(ap_udplog_level),
            "0x10041=5",  # ERadCcs_AaSysLogOutputMode
            "0x10043=51000",  # Port used for log forwarding
            "0x20124=4",  # keep having SYSCOM running over SCTP, if not then fail to start up
        ]
        redefine_flags = []
        for i in mandatory_flags:
            if i.split("=")[0] in [j.split("=")[0] for j in flags]:
                redefine_flags.append(i)
        flags.extend(mandatory_flags)
        for k in redefine_flags:
            flags.remove(k)
        if len(flags) != 0:
            builtin_obj.log(
                "change swconfig with %s in %s airphone" %
                (flags, self.alias), console=True)
        swconfig_file_cloud = "/home/ute/testline_init_results/configs/ap_swconfig.txt"
        swconfig_new_file_cloud = "/home/ute/testline_init_results/configs/sim_swconfig.txt"
        if os.path.exists(swconfig_file):
            swconfig_file_base = swconfig_file
        elif os.path.exists(swconfig_file_cloud):
            swconfig_file_base = swconfig_file_cloud
        elif os.path.exists(swconfig_new_file_cloud):
            swconfig_file_base = swconfig_new_file_cloud
        else:
            raise Exception(
                "no base swconfig.txt, fetch one from cloud and save as %s" %
                swconfig_file)
        builtin_obj.log("zy: base swconfig.txt is %s" % swconfig_file_base)
        # modify and upload swconfig.txt
        os_obj.copy_file(swconfig_file_base, self.modified_swconfig_file_iphy)
        comm_obj.modify_parameter_defined_as_key_equal_value(
            self.modified_swconfig_file_iphy, flags)
        self.fsm_obj.put_wts_file(
            self.modified_swconfig_file_iphy,
            self.enb_swconfig_file,
            alias=self.alias)
        self.fsm_obj.execute_command_on_wts(
            "rm -rf /rom/swconfig.txt.p7", alias=self.alias)
        self.fsm_obj.execute_command_on_wts(
            "crasign /rom/swconfig.txt", alias=self.alias)
        self.fsm_obj.execute_command_on_wts(
            "craverify /rom/swconfig.txt /rom/swconfig.txt.p7",
            alias=self.alias)

    def _get_ap_bbu_type_aic(self):
        self._setup_common_ssh_cu()
        cmd = "cat /proc/device-tree/module-identity/unit-id"
        rrutype = self.fsm_obj.execute_command_on_wts(cmd, alias=self.alias)
        return re.compile('\x00').sub("", rrutype)

    def _wait_all_pods_running(self, namespace, interrupt_once_fail, alias):
        """timeout:    maximum time for waiting all pods to running state(default 5min)"""
        if alias.count("du"):
            self._setup_common_ssh_du()
        if alias.count("cu"):
            self._setup_common_ssh_cu()
        pod_running_flag = False
        not_running_pod = None
        not_ready_pod = None
        pod_running_info = None
        timeout = 300
        while pod_running_flag is False and timeout >= 0:
            pod_running_flag = True
            not_running_pod = None
            not_ready_pod = None
            pod_running_info = self.fsm_obj.execute_command_on_enb(
                "kubectl get pods -n %s" % namespace, alias=alias)
            for j in pod_running_info.split("\n")[1:]:
                if re.match(r".* (\d+)/(\d+) .* Running .*", j) is None:
                    timeout -= 5
                    time.sleep(5)
                    pod_running_flag = False
                    not_running_pod = j
                    break
                elif re.match(r".* ((\d+)/(\d+)) .* (\d+) .*", j).group(2) != re.match(r".* ((\d+)/(\d+)) .* (\d+) .*",
                                                                                       j).group(3):
                    timeout -= 5
                    time.sleep(5)
                    pod_running_flag = False
                    not_ready_pod = j
                    break
        if pod_running_flag is False:
            if not_running_pod:
                if interrupt_once_fail is True:
                    raise Exception(
                        "Exist pod not running: %s" %
                        not_running_pod)
                else:
                    builtin_obj.log(
                        "Exist pod not running: %s" %
                        not_running_pod, level="WARN")
            if not_ready_pod:
                if interrupt_once_fail is True:
                    raise Exception("Exist pod not ready: %s" % not_ready_pod)
                else:
                    builtin_obj.log(
                        "Exist pod not ready: %s" %
                        not_ready_pod, level="WARN")
        builtin_obj.log("pod_running_info:\n %s" % pod_running_info)

    def _wait_all_pods_running_vcu(self, namespace, interrupt_once_fail):
        self._wait_all_pods_running(
            namespace,
            interrupt_once_fail,
            alias=self.alias_cu)

    def _wait_all_pods_running_vdu(self, namespace, interrupt_once_fail):
        self._wait_all_pods_running(
            namespace,
            interrupt_once_fail,
            alias=self.alias_du)

    def _wait_single_pod_running(
            self,
            namespace,
            podname,
            interrupt_once_fail,
            alias):
        """timeout:    maximum time for waiting appointed pod to running state(default 5min)"""
        if alias.count("du"):
            self._setup_common_ssh_du()
        if alias.count("cu"):
            self._setup_common_ssh_cu()
        pod_running_flag = False
        pod_running_info = None
        timeout = 300
        while pod_running_flag is False and timeout >= 0:
            pod_list = []
            pod_running_info = self.fsm_obj.execute_command_on_enb(
                "kubectl get pods -n %s" % namespace, alias=alias)
            for j in pod_running_info.split("\n")[1:]:
                if j.split()[0].count("-" + podname + "-"):
                    pod_list.append(j)
            if len(pod_list) > 0:
                for k in pod_list:
                    if k.split()[2] != "Running":
                        timeout -= 5
                        pod_running_flag = False
                        time.sleep(5)
                        break
                    elif re.match(r"(\d+)/(\d+)", k.split()[1]).group(1) != re.match(r"(\d+)/(\d+)",
                                                                                     k.split()[1]).group(2):
                        timeout -= 5
                        pod_running_flag = False
                        time.sleep(5)
                        break
                    else:
                        pod_running_flag = True
            else:
                time.sleep(5)
        if pod_running_flag is False:
            if interrupt_once_fail is True:
                raise Exception("pod %s is not running" % podname)
            else:
                builtin_obj.log(
                    "pod %s is not running" %
                    podname, level="WARN")
        builtin_obj.log("pod_running_info:\n %s" % pod_running_info)

    def _wait_single_pod_running_vcu(
            self,
            namespace,
            podname,
            interrupt_once_fail):
        self._wait_single_pod_running(
            namespace,
            podname,
            interrupt_once_fail,
            alias=self.alias_cu)

    def _wait_single_pod_running_vdu(
            self,
            namespace,
            podname,
            interrupt_once_fail):
        self._wait_single_pod_running(
            namespace,
            podname,
            interrupt_once_fail,
            alias=self.alias_du)

    def _check_pod_status_aic(self, namespace, alias):
        if alias.count("du"):
            self._setup_common_ssh_du()
            # will extend to single pod status check if need later.
            # pod_full_name = self._match_pod_fullname_du(namespace, pod_name, alias)
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            # pod_full_name = self._match_pod_fullname_cu(namespace, pod_name, alias)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        set_check_pod_status_cmd = ("kubectl get pod -n " + namespace)
        builtin_obj.log(set_check_pod_status_cmd)
        status_rt = self.fsm_obj.execute_command_on_enb(
            set_check_pod_status_cmd, alias=alias)
        builtin_obj.log(status_rt)

    def _check_pod_status_cu(self, namespace):
        self._check_pod_status_aic(namespace, alias=self.alias_cu)

    def _check_pod_status_du(self, namespace):
        self._check_pod_status_aic(namespace, alias=self.alias_du)

    def _restart_pod_aic(self, pod_name, namespace, alias):
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias)
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        set_kill_pod_cmd = (
            "kubectl delete pod " +
            pod_full_name +
            " -n " +
            namespace)
        builtin_obj.log(set_kill_pod_cmd)
        self.fsm_obj.execute_command_on_enb(set_kill_pod_cmd, alias=alias)

    def _restart_pod_in_vcu(self, pod_name, namespace):
        self._restart_pod_aic(pod_name, namespace, alias=self.alias_cu)

    def _restart_pod_in_vdu(self, pod_name, namespace):
        self._restart_pod_aic(pod_name, namespace, alias=self.alias_du)

    def _scale_pod_in_aic(self, pod_name, number, namespace, alias):
        """kubectl scale --replicas=${number} statefulset/po-tl682-cpue -n tl682   --> control working CPUEs number
           ${number}=1: only one pod working
           ${number}=2: only two pod working
        """
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias)
            pod_full_name_for_scale = pod_full_name.split(pod_name)[
                0] + pod_name
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias)
            pod_full_name_for_scale = pod_full_name.split(pod_name)[
                0] + pod_name
        else:
            raise Exception(
                "%s is not support, pls contact "
                "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to check" %
                alias)
        set_scale_pod_cmd = (
            "kubectl scale --replicas=%s statefulset/%s -n %s" %
            (number, pod_full_name_for_scale, namespace))
        builtin_obj.log(set_scale_pod_cmd)
        self.fsm_obj.execute_command_on_enb(set_scale_pod_cmd, alias=alias)

    def _scale_pod_in_vcu(self, pod_name, number, namespace):
        self._scale_pod_in_aic(
            pod_name,
            number,
            namespace,
            alias=self.alias_cu)

    def _scale_pod_in_vdu(self, pod_name, number, namespace):
        self._scale_pod_in_aic(
            pod_name,
            number,
            namespace,
            alias=self.alias_du)

    def _lock_all_cells_cu(self):
        self._start_admin_cu()
        try:
            cells_status = self.cu_obj.get_cells_statuses(
                connection=self.alias_cu)
            for i in cells_status:
                lock_action = self.cu_obj.lock_cells(
                    list(i["id"]), connection=self.alias_cu)
                time.sleep(5)
                cell_lock_flag = True
                endtime = time.time() + 60
                while cell_lock_flag and time.time() < endtime:
                    lock_stat_check = self.cu_obj.get_operation_state_of_locking_cells(
                        operation_id=lock_action["id"], connection=self.alias_cu)
                    builtin_obj.log("xk:%s" % lock_stat_check)
                    if lock_stat_check["status"] != "success":
                        time.sleep(5)
                    else:
                        cell_lock_flag = False
                        builtin_obj.log("NRCELL-%s locked" % i["id"])
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)
        finally:
            self._stop_admin_cu()

    def _unlock_all_cells_cu(self):
        self._start_admin_cu()
        try:
            cells_status = self.cu_obj.get_cells_statuses(
                connection=self.alias_cu)
            for j in cells_status:
                unlock_action = self.cu_obj.unlock_cells(
                    list(j["id"]), connection=self.alias_cu)
                time.sleep(5)
                cell_unlock_flag = True
                endtime = time.time() + 60
                while cell_unlock_flag and time.time() < endtime:
                    unlock_status_check = self.cu_obj.get_operation_state_of_locking_cells(
                        operation_id=unlock_action["id"], connection=self.alias_cu)
                    builtin_obj.log("xk:%s" % unlock_status_check)
                    if unlock_status_check["status"] != "success":
                        time.sleep(5)
                    else:
                        cell_unlock_flag = False
                        builtin_obj.log("NRCELL-%s unlocked" % j["id"])
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)
        finally:
            self._stop_admin_cu()

    def _enable_m2m_interface_aic(
            self,
            namespace,
            pod_name,
            container_name,
            alias):
        m2m_ret, pod_full_name, container_fullname, check_m2m_cmd = self._check_m2m_interface_aic(
            namespace, pod_name, container_name, alias)
        if m2m_ret["enableM2MInterface"] is True:
            return
        else:
            enable_m2m_p1 = "kubectl exec -t -n %s %s -c %s -- bash -c " % (
                namespace, pod_full_name, container_fullname)
            enable_m2m_p2 = "\"curl -k -s -X PUT http://apigw:50506/config -d '{\\\"enableM2MInterface\\\": true}'\" "
            enable_m2m_cmd = enable_m2m_p1 + enable_m2m_p2
            builtin_obj.log(enable_m2m_cmd)
            self.fsm_obj.execute_command_on_enb(enable_m2m_cmd, alias=alias)
            m2m_ret_2nd = self.fsm_obj.execute_command_on_enb(
                check_m2m_cmd, alias=alias)
            builtin_obj.log(m2m_ret_2nd)

    def _check_m2m_interface_aic(
            self,
            namespace,
            pod_name,
            container_name,
            alias):
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias=alias)
        elif alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias=alias)
        check_m2m_cmd = "kubectl exec -t -n %s %s -c %s -- curl -s -X GET http://apigw:50506/config" % (
            namespace, pod_full_name, container_fullname)
        builtin_obj.log(check_m2m_cmd)
        m2m_ret = self.fsm_obj.execute_command_on_enb(
            check_m2m_cmd, alias=alias)
        m2m_ret = json.loads(m2m_ret)
        builtin_obj.log(m2m_ret)
        return m2m_ret, pod_full_name, container_fullname, check_m2m_cmd

    def _enable_m2m_interface_cu(self, namespace):
        self._enable_m2m_interface_aic(
            namespace,
            pod_name="rcpum",
            container_name="rcpum",
            alias=self.alias_cu)

    def _enable_m2m_interface_du(self, namespace):
        self._enable_m2m_interface_aic(
            namespace,
            pod_name="rcpum",
            container_name="rcpum",
            alias=self.alias_du)

    def _check_m2m_interface_cu(self, namespace):
        self._check_m2m_interface_aic(
            namespace,
            pod_name="rcpum",
            container_name="rcpum",
            alias=self.alias_cu)

    def _check_m2m_interface_du(self, namespace):
        self._check_m2m_interface_aic(
            namespace,
            pod_name="rcpum",
            container_name="rcpum",
            alias=self.alias_du)

    def _get_cu_state(self):
        self._start_admin_cu()
        cu_state_info = self.cu_obj.get_cu_state(connection=self.alias_cu)
        self._stop_admin_cu()
        return cu_state_info

    def _get_du_state(self):
        self._start_admin_du()
        du_state_info = self.du_obj.get_vdu_state_data(
            vdu_connection=self.alias_du)
        self._stop_admin_du()
        return du_state_info

    # below kw inherit from classical
    def _kill_edaemon_and_egate(self):
        comm_obj.execute_cmd_on_pc("sudo pkill edaemon")
        comm_obj.execute_cmd_on_pc("sudo pkill egate")
        comm_obj.execute_cmd_on_pc("ps -ef | grep -e edaemon -e egate")
        comm_obj.execute_cmd_on_pc("sudo rm -rf /opt/wts/latest/*.log*")

    def _ping_ok(self, ip):
        out = comm_obj.execute_cmd_on_pc("ping %s -c 2" % ip)
        if out.count("100% packet loss"):
            return False
        else:
            return True

    def _configure_and_start_wts(self, cfg_file, debug_log_level):
        comm_obj.log_to_console_with_time_prefix(
            "step: configure wts with %s and start wts" % cfg_file)
        comm_obj.execute_cmd_on_pc("cd /opt/wts/latest")
        # comment 10000 port due to APoABIO with AEHC can not receive mib/sib
        # comm_obj.execute_cmd_on_pc("sudo ./edaemon --port 10000")
        comm_obj.execute_cmd_on_pc("sudo ./edaemon --port 22222")
        comm_obj.execute_cmd_on_pc("./egate --port 20000")
        try:
            comm_obj.execute_egate_command(
                "cfg file=%s" %
                cfg_file,
                "CHANGE STATE: STARTED",
                timeout=40)
        except Exception:
            detail = traceback.format_exc()
            raise Exception(
                "fail to execute cfg file=%s: %s" %
                (cfg_file, detail))
        comm_obj.execute_egate_command("debug_log level=%s" % debug_log_level)
        comm_obj.execute_egate_command("debug_log", "Max number")
        # PR660109[Airscale][TDD][AP_LO][GNB_LO]pdu session setup failed due to
        # failure-in-radio-interface-procedure
        comm_obj.execute_egate_command(
            "uec_param id=1 srb_reordering_enabled=on")
        # current not add below kw due to some TLs are startup very slow
        # self._check_sim_state()

    def _check_sim_state(self):
        comm_obj.log_to_console_with_time_prefix(
            "step: wait egate state active")
        start_time = datetime.datetime.now()
        retry_times = 6
        while retry_times > 0:
            try:
                comm_obj.execute_egate_command(
                    "state_sim_disp", "The state is ACTIVE", timeout=10)
                break
            except Exception:
                detail = traceback.format_exc()
                retry_times = retry_times - 1
        if retry_times == 0:
            comm_obj.log_to_console_with_time_prefix(
                "fail to wait egate state active", level="WARN")
            raise Exception("fail to check state_sim_disp: %s" % detail)
        endtime = datetime.datetime.now()
        time_elapse = (endtime - start_time).seconds
        comm_obj.log_to_console_with_time_prefix(
            "step: wait egate state active cost %s sec" %
            time_elapse)

    def _auto_setup_nsa_link_by_x2_peers(self, cfg_file):
        if self._check_x2_peers_in_cfg_file(cfg_file):
            wts_enb_id, wts_gnb_id = self._get_enb_gnb_id_from_wts_file(
                cfg_file)
            comm_obj.execute_egate_command(
                "enb_x2_link_up enb=%s target=%s" %
                (wts_enb_id, wts_gnb_id))
            comm_obj.log_to_console_with_time_prefix(
                "step: setup enb x2 link up by enb_x2_link_up enb=%s target=%s" %
                (wts_enb_id, wts_gnb_id))
        else:
            comm_obj.log_to_console_with_time_prefix(
                "step: setup enb x2 link up by x2_peers=all")
            pass

    def _check_x2_peers_in_cfg_file(self, cfg_file):
        with open(cfg_file, 'r') as f_obj:
            for line in f_obj:
                if line.lower().count("set_enb"):
                    for sub_line in line.lower().split(" "):
                        if sub_line.count("x2_peers"):
                            if sub_line.count("none"):
                                return True
                            else:
                                return False

    def _get_enb_gnb_id_from_wts_file(self, file_path):
        wts_enb_id = 1
        wts_gnb_id = 2
        with open(file_path, 'r') as f_obj:
            for line in f_obj:
                match_result = re.match(r"set_enb\s*id=(\d+)", line, re.I)
                if match_result:
                    wts_enb_id = match_result.group(1)
                    break
            for line in f_obj:
                match_result = re.match(r"set_gnb\s*id=(\d+)", line, re.I)
                if match_result:
                    wts_gnb_id = match_result.group(1)
                    break
        return wts_enb_id, wts_gnb_id

    def _wait_mibs(self, instance_id, lcr_id):
        wts_gnb_id = 2
        comm_obj.log_to_console_with_time_prefix(
            "step: wait cell{} mib messages".format(instance_id))
        start_time = datetime.datetime.now()
        try:
            comm_obj.egate_console_log_should_contain(
                "/opt/wts/latest/egate_console.log", [
                    "eNB {} cell {}: MasterInformationBlock-NR Updated".format(
                        wts_gnb_id, lcr_id)], timeout=300, interval=10)
            endtime = datetime.datetime.now()
            time_elapse = (endtime - start_time).seconds
            comm_obj.log_to_console_with_time_prefix(
                "step: wait cell{} mib cost {} sec".format(
                    instance_id, time_elapse))
        except Exception:
            detail = traceback.format_exc()
            comm_obj.log_to_console_with_time_prefix(
                "fail to wait cell{} mib".format(instance_id), level="WARN")
            raise Exception(
                "fail to wait cell{} mib: {}".format(
                    instance_id, detail))

    def _ping_ok_until_timeout(self, ip, timeout=60):
        retry_times = int(timeout) / 10
        while retry_times > 0:
            result = self._ping_ok(ip)
            if result is False:
                retry_times = retry_times - 1
                continue
            else:
                return True
        if retry_times <= 0:
            return False

    def _wait_restart(self, ip, timeout=60):
        retry_times = int(timeout) / 10
        while retry_times > 0:
            time.sleep(10)
            result = self._ping_ok(ip)
            if result is False:
                break
            else:
                retry_times = retry_times - 1
        if retry_times == 0:
            raise Exception("%s is not restarted via PDU successfully" % ip)

    def _check_dcap_tls_ip(self, check_cmd, trace_gateway, conn):
        dcap_tls_add_flag = False
        tls_ret = self.fsm_obj.execute_command_on_enb(check_cmd, alias=conn)
        if tls_ret.count(trace_gateway):
            builtin_obj.log("trace_gateway ip:%s already add" % trace_gateway)
            dcap_tls_add_flag = True
        return dcap_tls_add_flag

    def _disable_tls_for_dcap_connect_cu(
            self,
            namespace,
            pod_name="oamext",
            container_name="providercontroller"):
        self._setup_common_ssh_cu()
        pod_full_name = self._match_pod_fullname_cu(
            namespace, pod_name, alias=self.alias_cu)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias=self.alias_cu)
        ping_gateway_ip_cmd = 'kubectl exec -i %s -n %s -c %s -- bash -c "ping 172.16.4.1 -c 2"' % (
            pod_full_name, namespace, container_fullname)
        try:
            ping_ret = self.fsm_obj.execute_command_on_enb(
                ping_gateway_ip_cmd, alias=self.alias_cu)
            builtin_obj.log(ping_ret)
            time.sleep(1)
        except Exception as e:
            builtin_obj.log("debug for emil gateway ip ping:{}".format(e))
        disable_tls_cmd = 'kubectl exec -i %s -n %s -c %s -- bash -c ' \
                          '"yes|/opt/nokia/bin/dataprovidercli add -u 172.16.4.1"' % (pod_full_name, namespace,
                                                                                      container_fullname)
        check_cmd = 'kubectl exec -i %s -n %s -c %s -- bash -c ' \
                    '"/opt/nokia/bin/dataprovidercli show"' % (pod_full_name, namespace, container_fullname)
        builtin_obj.log(check_cmd)
        dcap_tls_add_flag_cu = self._check_dcap_tls_ip(
            check_cmd, trace_gateway="172.16.4.1", conn=self.alias_cu)
        if dcap_tls_add_flag_cu is False:
            self.fsm_obj.execute_command_on_enb(
                disable_tls_cmd, alias=self.alias_cu)
            time.sleep(1)
        self.fsm_obj.execute_command_on_enb(check_cmd, alias=self.alias_cu)

    def _disable_tls_for_dcap_connect_du(
            self,
            namespace,
            pod_name="oamext",
            container_name="providercontroller"):
        self._setup_common_ssh_du()
        pod_full_name = self._match_pod_fullname_du(
            namespace, pod_name, alias=self.alias_du)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias=self.alias_du)
        ping_gateway_ip_cmd = 'kubectl exec -i %s -n %s -c %s -- bash -c "ping 172.16.5.1 -c 2"' % (
            pod_full_name, namespace, container_fullname)
        try:
            ping_ret = self.fsm_obj.execute_command_on_enb(
                ping_gateway_ip_cmd, alias=self.alias_cu)
            builtin_obj.log(ping_ret)
            time.sleep(1)
        except Exception as e:
            builtin_obj.log("debug for emil gateway ip ping:{}".format(e))
        disable_tls_cmd = 'kubectl exec -i %s -n %s -c %s -- bash -c ' \
                          '"yes|/opt/nokia/bin/dataprovidercli add -u 172.16.5.1"' % (pod_full_name, namespace,
                                                                                      container_fullname)
        check_cmd = 'kubectl exec -i %s -n %s -c %s -- bash -c ' \
                    '"/opt/nokia/bin/dataprovidercli show"' % (pod_full_name, namespace, container_fullname)
        dcap_tls_add_flag_du = self._check_dcap_tls_ip(
            check_cmd, trace_gateway="172.16.5.1", conn=self.alias_du)
        if dcap_tls_add_flag_du is False:
            self.fsm_obj.execute_command_on_enb(
                disable_tls_cmd, alias=self.alias_du)
            time.sleep(1)
        self.fsm_obj.execute_command_on_enb(check_cmd, alias=self.alias_du)

    def _ready_for_commission_checking_aic(
            self,
            namespace,
            pod_name,
            container_name,
            alias,
            du_identity="du"):
        if alias.count("cu"):
            self._setup_common_ssh_cu()
            pod_full_name = self._match_pod_fullname_cu(
                namespace, pod_name, alias=self.alias_cu)
        if alias.count("du"):
            self._setup_common_ssh_du()
            pod_full_name = self._match_pod_fullname_du(
                namespace, pod_name, alias=self.alias_du)
        container_fullname = self._match_container_fullname_aic(
            namespace, pod_full_name, container_name, alias)
        checking_cmd = 'kubectl exec -ti %s -n %s -c %s -- /usr/bin/curl -X GET ' \
                       'http://oam-agent:9003/api/agent/v1/readyForCommissioning -H "accept: application/json"?|' \
                       ' jq -r ".readyForCommissioning"' % (pod_full_name, namespace, container_fullname)
        builtin_obj.log(checking_cmd)
        ready_status = None
        time_start = time.time()
        try:
            while True:
                ready_status = self.fsm_obj.execute_command_on_enb(
                    checking_cmd, alias=alias)
                if ready_status != "true" and time.time() - time_start <= 60:
                    time.sleep(2)
                else:
                    break
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        finally:
            if ready_status != "true":
                if alias.count("cu"):
                    comm_obj.log_to_console_with_time_prefix(
                        "vcu is not ready for commissioning", level="WARN")
                if alias.count("du"):
                    comm_obj.log_to_console_with_time_prefix(
                        "%s is not ready for commissioning" %
                        du_identity, level="WARN")
            return ready_status

    def _ready_for_commission_checking_vcu(
            self,
            namespace,
            pod_name="oamext",
            container_name="oamagent"):
        return self._ready_for_commission_checking_aic(
            namespace, pod_name, container_name, alias=self.alias_cu)

    def _ready_for_commission_checking_vdu(
            self,
            namespace,
            pod_name="oamext",
            container_name="oamagent",
            du_identity="du"):
        return self._ready_for_commission_checking_aic(
            namespace,
            pod_name,
            container_name,
            alias=self.alias_du,
            du_identity=du_identity)

    def _collect_iq_data_vdu(self, data_direct, vdu_ns):
        self._setup_common_ssh_du()
        self.fsm_obj.execute_command_on_enb(
            "mkdir -p /tmp/%s/tmp_iq_data" %
            vdu_ns, alias=self.alias_du)
        self.fsm_obj.execute_command_on_enb(
            "rm -rf /tmp/%s/tmp_iq_data/*" %
            vdu_ns, alias=self.alias_du)
        self._start_ssh_connect_rannic()
        old_prompt = ssh_obj.set_shell_prompt("~#", r"~#")
        ssh_obj.switch_host_connection(self.rannic_conn)
        if data_direct.lower().count("ul"):
            iq_trace_file_name = "blind_iq_trace_ul.tar.gz"
        if data_direct.lower().count("dl"):
            iq_trace_file_name = "blind_iq_trace_dl.tar.gz"
        ssh_obj.execute_shell_command("rm -rf /tmp/mine/")
        ssh_obj.execute_shell_command(
            "/usr/lib64/python/antenna_snapshot_config.py --blind")
        time.sleep(1)
        ssh_obj.execute_shell_command(
            "tar -czvf /tmp/%s /tmp/mine/" %
            iq_trace_file_name)
        time.sleep(1)

        # capture another direction datalink data
        if data_direct.lower().count("ul"):
            ssh_obj.execute_shell_command(
                "/usr/lib64/python/antenna_snapshot_config.py --dlsubcellid %s" %
                self.subcellid)
        if data_direct.lower().count("dl"):
            ssh_obj.execute_shell_command(
                "/usr/lib64/python/antenna_snapshot_config.py --subcellid %s" %
                self.subcellid)
        ssh_obj.execute_shell_command("rm -rf /tmp/mine/")
        ssh_obj.execute_shell_command(
            "/usr/lib64/python/antenna_snapshot_config.py --blind")
        time.sleep(1)
        if data_direct.lower().count("ul"):
            ssh_obj.execute_shell_command(
                "tar -czvf /tmp/blind_iq_trace_dl.tar.gz /tmp/mine/")
        if data_direct.lower().count("dl"):
            ssh_obj.execute_shell_command(
                "tar -czvf /tmp/blind_iq_trace_ul.tar.gz /tmp/mine/")
        ssh_obj.set_shell_prompt("$", r"$")
        time.sleep(1)
        ssh_obj.execute_shell_command("exit")
        time.sleep(2)
        ssh_obj.set_shell_prompt("Password:", r"password:", r"$")
        old_timeout = ssh_obj.set_shell_timeout("10")

        ssh_obj.execute_shell_command(
            "scp toor4nsn@192.168.254.20:/tmp/blind_iq_trace_ul.tar.gz /tmp/%s/tmp_iq_data" %
            vdu_ns)
        ssh_obj.execute_shell_command("oZPS0POrRieRtu")
        ssh_obj.execute_shell_command(
            "scp toor4nsn@192.168.254.20:/tmp/blind_iq_trace_dl.tar.gz /tmp/%s/tmp_iq_data" %
            vdu_ns)
        ssh_obj.execute_shell_command("oZPS0POrRieRtu")
        ssh_obj.set_shell_prompt(old_prompt)
        ssh_obj.set_shell_prompt(old_timeout)
        ssh_obj.disconnect_from_host(self.rannic_conn)
        iq_ul_log_dir = builtin_obj.get_variable_value(
            "${SAVE LOG DIRECTORY}") + "/blind_iq_trace_ul.tar.gz"
        iq_dl_log_dir = builtin_obj.get_variable_value(
            "${SAVE LOG DIRECTORY}") + "/blind_iq_trace_dl.tar.gz"
        try:
            self._get_wireshark_aic_vdu(
                "/tmp/%s/tmp_iq_data/blind_iq_trace_ul.tar.gz" %
                vdu_ns, iq_ul_log_dir)
        except Exception as e:
            builtin_obj.log(e)
        try:
            self._get_wireshark_aic_vdu(
                "/tmp/%s/tmp_iq_data/blind_iq_trace_dl.tar.gz" %
                vdu_ns, iq_dl_log_dir)
        except Exception as e:
            builtin_obj.log(e)

    def _enable_iq_data_vdu(self, data_direct, physCellId):
        self._start_ssh_connect_rannic()
        old_prompt = ssh_obj.set_shell_prompt("~#", r"~#")
        ssh_obj.switch_host_connection(self.rannic_conn)
        subcellid_rt = ssh_obj.execute_shell_command(
            "/usr/lib64/python/antenna_snapshot_config.py --showcell")
        match_restult = re.search(
            re.compile(
                r'.* subcellId\s+=\s+(\d+),.* physCellId\s+=\s+(%s).*' %
                physCellId,
                flags=re.I),
            subcellid_rt)
        if match_restult:
            self.subcellid = match_restult.group(1)
        else:
            self.subcellid = 0
        builtin_obj.log("subcellid:%s" % self.subcellid)
        if data_direct.lower().count("ul"):
            ssh_obj.execute_shell_command(
                "/usr/lib64/python/antenna_snapshot_config.py --subcellid %s" %
                self.subcellid)
        if data_direct.lower().count("dl"):
            ssh_obj.execute_shell_command(
                "/usr/lib64/python/antenna_snapshot_config.py --dlsubcellid %s" %
                self.subcellid)
        ssh_obj.disconnect_from_host(self.rannic_conn)

    def _start_ssh_connect_rannic(self):
        self._setup_common_ssh_du()
        maxtime = time.time() + 120
        while time.time() < maxtime:
            try:
                message_ret = self.fsm_obj.execute_command_on_enb(
                    "sudo ifconfig ens35f0 192.168.254.16/24", alias=self.alias_du)
                if message_ret.count("No such device"):
                    time.sleep(5)
                else:
                    break
            except Exception as e:
                builtin_obj.log("debug: {}".format(e))
        ping_ret = self.fsm_obj.execute_command_on_enb(
            "sudo ping -I ens35f0 192.168.254.20 -c 2", alias=self.alias_du)
        builtin_obj.log(ping_ret)
        self.rannic_conn = ssh_obj.connect_to_host(
            self.du_host_ssh,
            "22",
            self.du_host_ssh_usr,
            self.du_host_ssh_pwd,
            conn_type="SSH",
            timeout="20")
        old_prompt = ssh_obj.set_shell_prompt("Password:", r"password:")
        old_timeout = ssh_obj.set_shell_timeout("10")
        ssh_obj.execute_shell_command(
            "ssh -o StrictHostKeyChecking=no toor4nsn@192.168.254.20")
        ssh_obj.set_shell_prompt("~#", r"~#")
        ssh_obj.execute_shell_command("oZPS0POrRieRtu")
        ssh_obj.set_shell_prompt(old_prompt)
        ssh_obj.set_shell_timeout(old_timeout)
        return self.rannic_conn

    def _stop_ssh_connect_aic_rannic(self, rannic_conn):
        ssh_obj.disconnect_from_host(rannic_conn)

    def _get_ocp_version_vcu(self):
        self._setup_common_ssh_cu()
        oc_ver_ret_cu = self.fsm_obj.execute_command_on_enb(
            "oc version", alias=self.alias_cu)
        builtin_obj.log(oc_ver_ret_cu)

    def _get_ocp_ranic_sw_control_sync_operator_version_vdu(self):
        self._setup_common_ssh_du()
        oc_ver_ret_du = self.fsm_obj.execute_command_on_enb(
            "oc version;helm list -n ran-nic-sw-controller;"
            "helm list -n nokia-sync-operator", alias=self.alias_du)
        builtin_obj.log(oc_ver_ret_du)

    def _capture_rannic_sw_controller_logs(
            self, rannic_sw_controller_log_path, du_id, namespace):
        """https://cloudinfra-ext.gitlabe2-pages.ext.net.nokia.com/ran-nic-sw-controller/docs/troubleshooting/"""
        self._setup_common_ssh_du()
        rannic_sw_controller_log_dir = "/tmp/" + namespace + \
            "/ran-nic-sw-controller-troubleshooting-logs"
        create_rannic_log_dir_cmd = (
            "rm -rf %s; rm -rf %s.tgz; mkdir -p %s" %
            (rannic_sw_controller_log_dir,
             rannic_sw_controller_log_dir,
             rannic_sw_controller_log_dir))
        self.fsm_obj.execute_command_on_enb(
            create_rannic_log_dir_cmd, alias=self.alias_du)

        # Collect RanNicConfig CR status
        collect_cmd1 = (
            "for rnc_name in `kubectl -n %s get rannicconfigs --no-headers "
            "-o custom-columns=Name:metadata.name`;do kubectl -n %s get rannicconfigs ${rnc_name} -o yaml | "
            "tee %s/rannicconfigs_${rnc_name}.log >> %s/nohup_rannic_swcontroller.txt 2>&1;"
            "done" %
            (namespace, namespace, rannic_sw_controller_log_dir, rannic_sw_controller_log_dir))
        builtin_obj.log(collect_cmd1)
        self.fsm_obj.execute_command_on_enb(collect_cmd1, alias=self.alias_du)

        # Collect RAN NIC SW controller version, pods and RanNicNodeConfig CR
        # status
        collect_cmd2 = (
            "helm list -n ran-nic-sw-controller | tee %s/RAN-NIC-SW-controller-build-version.log "
            ">> %s/nohup_rannic_swcontroller.txt 2>&1" %
            (rannic_sw_controller_log_dir, rannic_sw_controller_log_dir))
        builtin_obj.log(collect_cmd2)
        self.fsm_obj.execute_command_on_enb(collect_cmd2, alias=self.alias_du)
        collect_cmd3 = (
            "kubectl get pod -n ran-nic-sw-controller -o wide | "
            "tee %s/RAN-NIC-SW-controller-pods-status.log "
            ">> %s/nohup_rannic_swcontroller.txt 2>&1" %
            (rannic_sw_controller_log_dir, rannic_sw_controller_log_dir))
        builtin_obj.log(collect_cmd3)
        self.fsm_obj.execute_command_on_enb(collect_cmd3, alias=self.alias_du)
        collect_cmd4 = (
            "for rnnc_name in `kubectl -n ran-nic-sw-controller get rannicnodeconfigs --no-headers "
            "-o custom-columns=Name:metadata.name`;"
            "do kubectl -n ran-nic-sw-controller get rannicnodeconfigs ${rnnc_name} -o yaml | "
            "tee %s/rannicnodeconfigs_${rnnc_name}.log >> %s/nohup_rannic_swcontroller.txt 2>&1;"
            "done" %
            (rannic_sw_controller_log_dir, rannic_sw_controller_log_dir))
        builtin_obj.log(collect_cmd4)
        self.fsm_obj.execute_command_on_enb(collect_cmd4, alias=self.alias_du)

        # Collect RAN NIC SW controller pods and containers logs
        collect_cmd5 = (
            "for pod_name in `kubectl -n ran-nic-sw-controller get pod --no-headers "
            "-o custom-columns=Name:metadata.name`; "
            "do kubectl -n ran-nic-sw-controller describe pod ${pod_name} | "
            "tee %s/${pod_name}-pod.log >> %s/nohup_rannic_swcontroller.txt 2>&1;"
            "done" %
            (rannic_sw_controller_log_dir, rannic_sw_controller_log_dir))
        builtin_obj.log(collect_cmd5)
        self.fsm_obj.execute_command_on_enb(collect_cmd5, alias=self.alias_du)
        collect_cmd6 = (
            "for pod_name in `kubectl -n ran-nic-sw-controller get pod --no-headers "
            "-o custom-columns=Name:metadata.name`;"
            "do for container_name in `kubectl -n ran-nic-sw-controller get pod ${pod_name} "
            "-o jsonpath={.spec.containers[*].name}`; do echo 'container name is ${container_name}'; "
            "kubectl logs -n ran-nic-sw-controller ${pod_name} -c ${container_name} | "
            "tee %s/${pod_name}-pod_${container_name}-container.log "
            ">> %s/nohup_rannic_swcontroller.txt 2>&1;done;done" %
            (rannic_sw_controller_log_dir, rannic_sw_controller_log_dir))
        builtin_obj.log(collect_cmd6)
        self.fsm_obj.execute_command_on_enb(collect_cmd6, alias=self.alias_du)
        collect_cmd7 = (
            "for pod_name in `kubectl -n ran-nic-sw-controller get pod --no-headers "
            "-o custom-columns=Name:metadata.name`;"
            "do container_num=`kubectl -n ran-nic-sw-controller get pod ${pod_name} "
            "-o json | jq '.status.containerStatuses| length'`; for ((i=0;i<${container_num};i++));"
            "do if [[ `kubectl get pod -n ran-nic-sw-controller ${pod_name} "
            "-o jsonpath='{.status.containerStatuses[$i].restartCount}'` -ne 0 ]];"
            "then container_name=`kubectl get pod -n ran-nic-sw-controller ${pod_name} "
            "-o jsonpath='{.status.containerStatuses[$i].name}'`; "
            "kubectl logs -p -n ran-nic-sw-controller ${pod_name} -c ${container_name} | "
            "tee %s/${pod_name}-pod_${container_name}-container_previous.log "
            ">> %s/nohup_rannic_swcontroller.txt 2>&1;fi;done;done" %
            (rannic_sw_controller_log_dir, rannic_sw_controller_log_dir))
        builtin_obj.log(collect_cmd7)
        self.fsm_obj.execute_command_on_enb(collect_cmd7, alias=self.alias_du)

        # Collect host kernel dmesg logs
        collect_cmd8 = (
            "for hostname in `kubectl get nodes --no-headers -o custom-columns=Name:metadata.name`; "
            "do echo ${hostname}; ssh -q -o UserKnownHostsFile=/dev/null "
            "-o StrictHostKeyChecking=no ${hostname} dmesg -T | "
            "tee %s/${hostname}-dmesg.log;done" %
            rannic_sw_controller_log_dir)
        builtin_obj.log(collect_cmd8)
        self.fsm_obj.execute_command_on_enb(collect_cmd8, alias=self.alias_du)
        # tar all log to package
        collect_cmd9 = (
            "tar -cvzf %s.tgz %s" %
            (rannic_sw_controller_log_dir,
             rannic_sw_controller_log_dir))
        builtin_obj.log(collect_cmd9)
        self.fsm_obj.execute_command_on_enb(collect_cmd9, alias=self.alias_du)
        time.sleep(2)
        # Download to local.
        local_log_name = rannic_sw_controller_log_path + \
            "ran-nic-sw-controller-troubleshooting-logs_%s.tgz" % du_id
        self.fsm_obj.get_enb_file(
            "/tmp/" +
            namespace +
            "/ran-nic-sw-controller-troubleshooting-logs.tgz",
            local_log_name,
            alias=self.alias_du)

    def _capture_ocp_logs_vdu(self, ocp_log_path, du_id, namespace):
        """https://confluence.ext.net.nokia.com/display/CloudDeployment/How+to+collect+OCP+logs"""
        # sos log not capture due to no any required from user, and also too
        # long time for collect.
        self._setup_common_ssh_du()
        ocp_log_dir = "/tmp/" + namespace + "/ocp_logs"
        create_ocp_log_dir_cmd = (
            "rm -rf %s; mkdir -p %s" %
            (ocp_log_dir, ocp_log_dir))
        self.fsm_obj.execute_command_on_enb(
            create_ocp_log_dir_cmd, alias=self.alias_du)

        # collect journal log from du
        journal_cmd = (
            'cd {};journalctl --since "$(date +%Y-%m-%d)" > {}_journal.log'.format(ocp_log_dir, du_id))
        self.fsm_obj.execute_command_on_enb(journal_cmd, alias=self.alias_du)

        # Collect "oc must-gather" logs
        oc_must_gather_logs_cmd = ("cd %s;oc adm must-gather" % ocp_log_dir)
        self.fsm_obj.execute_command_on_enb(
            oc_must_gather_logs_cmd, alias=self.alias_du)
        time.sleep(3)
        # tar log to package
        tar_must_log_cmd = (
            "cd %s;tar -zcvf must-gather.tar.gz ./must-gather.local*" %
            ocp_log_dir)
        self.fsm_obj.execute_command_on_enb(
            tar_must_log_cmd, alias=self.alias_du)

        # Collect "oc inspect" logs
        oc_inspect_logs_cmd = (
            "cd %s;oc adm inspect ns/%s ns/ran-nic-sw-controller ns/nokia-sync-operator "
            "rannicconfigs/rannicconfig -n %s" %
            (ocp_log_dir, namespace, namespace))
        self.fsm_obj.execute_command_on_enb(
            oc_inspect_logs_cmd, alias=self.alias_du)
        time.sleep(1)
        tar_ocp_inspect_logs_cmd = (
            "cd %s;tar -zcvf inspect.tar.gz ./inspect.local*" %
            ocp_log_dir)
        self.fsm_obj.execute_command_on_enb(
            tar_ocp_inspect_logs_cmd, alias=self.alias_du)

        # delete must-gather and inspect original log file folder
        must_gather_logs_f = ("%s/must-gather.local*" % ocp_log_dir)
        cp_inspect_logs_f = ("%s/inspect.local*" % ocp_log_dir)
        self.fsm_obj.execute_command_on_enb(
            "cd %s;rm -rf %s" %
            (ocp_log_dir, must_gather_logs_f), alias=self.alias_du)
        self.fsm_obj.execute_command_on_enb(
            "cd %s;rm -rf %s" %
            (ocp_log_dir, cp_inspect_logs_f), alias=self.alias_du)
        time.sleep(1)

        # Download to local.
        local_must_log_name = ocp_log_path + "/%s_must-gather.tar.gz" % du_id
        local_inspect_log_name = ocp_log_path + "/%s_inspect.tar.gz" % du_id
        local_journal_name = ocp_log_path + "/%s_journal.log" % du_id
        self.fsm_obj.get_enb_file(
            ocp_log_dir +
            "/must-gather.tar.gz",
            local_must_log_name,
            alias=self.alias_du)
        self.fsm_obj.get_enb_file(
            ocp_log_dir + "/inspect.tar.gz",
            local_inspect_log_name,
            alias=self.alias_du)
        self.fsm_obj.get_enb_file(
            ocp_log_dir + "/%s_journal.log" %
            du_id, local_journal_name, alias=self.alias_du)
        time.sleep(1)


class startup_aic_gnb1_cu(startup_base_aic):
    def __init__(self):
        alias = "gnb1"
        self.startup_base_aic_instant_1 = startup_base_aic(alias)

    def capture_wireshark_log_in_vcu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            redundantRole):
        """
            *Args:*
                - namespace: the tenant namespace which pod created in(e.g: cran1)
                - pod_name: collect log in which pod (e.g: cpif, cpnrt, cpnb, cpcl, cpue, upue)
                - container_name: collect log in which container (e.g: cpif, cpnrt, cpnb, cpcl, cpue, upue)
            *command:*
                'kubectl exec -i po-cran1-cpif-0 -c ctr-cran1-cpif -n cran1 -- mkdir -p /tmp/tmp_wireshark'
        """
        self.startup_base_aic_instant_1._capture_wireshark_log_in_vcu(
            pod_name, container_name, namespace, wireshark_name, redundantRole)

    def download_wireshark_log_to_master_vcu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            teardown=False):
        return self.startup_base_aic_instant_1._download_wireshark_log_to_master_vcu(
            pod_name, container_name, namespace, wireshark_name, log_dir_in_master, teardown)

    def pure_download_wireshark_log_to_master_vcu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master):
        self.startup_base_aic_instant_1._pure_download_wireshark_log_to_master_vcu(
            pod_name, container_name, namespace, wireshark_name, log_dir_in_master)

    def stop_wireshark_capture_aic_vcu(
            self, pod_name, container_name, namespace):
        self.startup_base_aic_instant_1._stop_wireshark_capture_aic_vcu(
            pod_name, container_name, namespace)

    def get_wireshark_from_vcu(self, src, dst):
        self.startup_base_aic_instant_1._get_wireshark_aic_vcu(src, dst)

    def set_debug_log_in_cpif(self, namespace):
        self.startup_base_aic_instant_1._set_debug_log_in_cu(
            namespace, pod_name='cpif', container_name='cpif', pod_cfg_name='cp_if')

    def set_debug_log_in_cpnb(self, namespace):
        self.startup_base_aic_instant_1._set_debug_log_in_cu(
            namespace, pod_name='cpnb', container_name='cpnb', pod_cfg_name='cp_nb')

    def set_debug_log_in_cpue(self, namespace):
        self.startup_base_aic_instant_1._set_debug_log_in_cu(
            namespace, pod_name='cpue', container_name='cpue', pod_cfg_name='cp_ue')

    def set_debug_log_in_cpcl(self, namespace):
        self.startup_base_aic_instant_1._set_debug_log_in_cu(
            namespace, pod_name='cpcl', container_name='cpcl', pod_cfg_name='cp_cl')

    def capture_syslog_in_vcu(self, namespace, pod_name='logservice'):
        self.startup_base_aic_instant_1._capture_syslog_in_vcu(
            namespace, pod_name)

    def download_syslog_to_master_vcu(
            self,
            namespace,
            log_path_ute,
            log_name='CU_SYSLOG'):
        self.startup_base_aic_instant_1._download_syslog_from_vcu(
            namespace, log_name, log_path_ute)

    def capture_startup_log_in_vcu(self, namespace, log_path_ute):
        self.startup_base_aic_instant_1._capture_startup_log_in_vcu(namespace)
        self.startup_base_aic_instant_1._download_startup_log_from_vcu(
            namespace, log_path_ute)

    def capture_journal_log_in_vcu(self, namespace, log_path_ute):
        self.startup_base_aic_instant_1._capture_journal_log_in_vcu(namespace)
        self.startup_base_aic_instant_1._download_journal_log_from_vcu(
            namespace, log_path_ute)

    def collect_snapshot_cu(self, snapshot_dir):
        self.startup_base_aic_instant_1._collect_snapshot_aic(
            snapshot_dir, productVariant="cu")

    def get_cu_version(self, ns):
        cu_version = self.startup_base_aic_instant_1._get_aic_version(
            productVariant="cu", ns=ns)
        return cu_version

    def change_swconfig_file_of_airphone_aic(self, flags, swconfig_file):
        """This keyword is to change swconfig.txt in current connection
        | Input Parameters | Man. | Description |
         | swconfig_file | No | swconfig file which will be modified with parameter flags. if none, swconfig file
         in enb is used |
        | flags   |  Yes  | parameters to be modified |


        format of argument1 flags
        | 1) | key=value | modify parameter value, if param not exist, create it |
        Example
        | ${parameters_in_swconfig} | Create List |  | 0x100=5 | 0x200=4 |
        | change_swconfig_file_for_iphy | ${parameters_in_swconfig} |
        """
        self.startup_base_aic_instant_1._change_swconfig_airphone_aic(
            flags, swconfig_file)

    def change_swconfig_cu(self, flags, namespace):
        self.startup_base_aic_instant_1._change_swconfig_cu(flags, namespace)

    def collect_coredump_log_cu(self):
        self.startup_base_aic_instant_1._collect_coredump_log_cu()

    def get_ap_bbu_type_aic(self):
        return self.startup_base_aic_instant_1._get_ap_bbu_type_aic()

    def wait_all_pods_running_vcu(self, namespace, interrupt_once_fail=True):
        self.startup_base_aic_instant_1._wait_all_pods_running_vcu(
            namespace, interrupt_once_fail)

    def reboot_airphone_aic(self):
        self.startup_base_aic_instant_1._reboot_airphone_aic()

    def restart_pod_in_vcu_aic(self, pod_name, namespace):
        """This keyword will automatically get the information(pod_full_name}/namespace...)
           according to the type(cpue/upue...) and execute the restart
        """
        self.startup_base_aic_instant_1._restart_pod_in_vcu(
            pod_name, namespace)

    def check_current_pod_status_in_cu(self, namespace):
        self.startup_base_aic_instant_1._check_pod_status_cu(namespace)

    def scale_pod_in_vcu(self, pod_name, number, namespace):
        self.startup_base_aic_instant_1._scale_pod_in_vcu(
            pod_name, number, namespace)

    def find_pod_fullname_cu(self, pod_name, namespace):
        return self.startup_base_aic_instant_1._find_pod_fullname_cu(
            namespace, pod_name)

    def find_container_fullname_cu(self, pod_name, container_name, namespace):
        return self.startup_base_aic_instant_1._find_container_fullname_cu(
            pod_name, container_name, namespace)

    def check_single_pod_running_vcu(
            self,
            namespace,
            podname,
            interrupt_once_fail=False):
        self.startup_base_aic_instant_1._wait_single_pod_running_vcu(
            namespace, podname, interrupt_once_fail)

    def kill_edaemon_and_egate(self):
        self.startup_base_aic_instant_1._kill_edaemon_and_egate()

    def enable_m2m_interface_cu(self, namespace):
        self.startup_base_aic_instant_1._enable_m2m_interface_cu(namespace)

    def check_m2m_interface_cu(self, namespace):
        self.startup_base_aic_instant_1._check_m2m_interface_cu(namespace)

    def disable_tls_for_dcap_connect_cu(self, namespace):
        self.startup_base_aic_instant_1._disable_tls_for_dcap_connect_cu(
            namespace)

    def ready_for_commission_checking_vcu(self, namespace):
        return self.startup_base_aic_instant_1._ready_for_commission_checking_vcu(
            namespace)

    def get_ocp_version_vcu(self):
        self.startup_base_aic_instant_1._get_ocp_version_vcu()


class startup_aic_gnb1_du(startup_base_aic):
    def __init__(self):
        alias = "gnb1_du_startup"
        self.startup_base_aic_instant_2 = startup_base_aic(alias)

    def _setup_startup_gnb1_du(self):
        self.startup_base_aic_instant_2.du_host = builtin_obj.get_variable_value(
            "${VDU_IP}")
        self.startup_base_aic_instant_2.du_host_ssh = builtin_obj.get_variable_value(
            "${VDU_SSH_IP}")
        self.startup_base_aic_instant_2.du_host_ssh_usr = builtin_obj.get_variable_value(
            "${VDU_SSH_USER}")
        self.startup_base_aic_instant_2.du_host_ssh_pwd = builtin_obj.get_variable_value(
            "${VDU_SSH_PASSWD}")
        self.startup_base_aic_instant_2.vdu_namespace = builtin_obj.get_variable_value(
            "${VDU_NAMESPACE}")

    def capture_wireshark_log_in_vdu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name):
        """
             *Args:*
                 - namespace: the tenant namespace which pod created in(e.g: cran1)
                 - pod_name: collect log in which pod (e.g: cp, up, oam)
                 - container_name: collect log in which container (e.g: cprt, l1hi, l2ps, l2hi, l2lo, oam)
             *command:*
                 'kubectl exec -i po-cran1-up-0 -c ctr-cran1-l1hi -n cran1 -- mkdir -p /tmp/tmp_wireshark'
        """
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._capture_wireshark_log_in_vdu(
            pod_name, container_name, namespace, wireshark_name)

    def download_wireshark_log_to_master_vdu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            teardown=False):
        self._setup_startup_gnb1_du()
        return self.startup_base_aic_instant_2._download_wireshark_log_to_master_vdu(
            pod_name, container_name, namespace, wireshark_name, log_dir_in_master, teardown)

    def pure_download_wireshark_log_to_master_vdu(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._pure_download_wireshark_log_to_master_vdu(
            pod_name, container_name, namespace, wireshark_name, log_dir_in_master)

    def stop_wireshark_capture_aic_vdu(
            self, pod_name, container_name, namespace):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._stop_wireshark_capture_aic_vdu(
            pod_name, container_name, namespace)

    def get_wireshark_from_vdu(self, src, dst):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._get_wireshark_aic_vdu(src, dst)

    def capture_aic_bip_log_du_l2rt(
            self,
            namespace,
            pod_name="l2rt",
            container_name="l2rt",
            bip_port_name="l1up"):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._capture_aic_bip_log_du(
            namespace, pod_name, container_name, bip_port_name)

    def capture_aic_bip_log_du_l2nrt(
            self,
            namespace,
            pod_name="l2nrt",
            container_name="l2hi",
            bip_port_name="l2biphi"):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._capture_aic_bip_log_du(
            namespace, pod_name, container_name, bip_port_name)

    def capture_aic_bip_log_du(self, namespace):
        self.capture_aic_bip_log_du_l2rt(namespace)
        self.capture_aic_bip_log_du_l2nrt(namespace)

    def stop_to_collect_bip_log_on_du_l2rt(
            self,
            namespace,
            pod_name="l2rt",
            container_name="l2rt"):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._stop_capture_bip_log_du(
            namespace, pod_name, container_name)

    def stop_to_collect_bip_log_on_du_l2nrt(
            self,
            namespace,
            pod_name="l2nrt",
            container_name="l2hi"):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._stop_capture_bip_log_du(
            namespace, pod_name, container_name)

    def stop_to_collect_bip_log_on_du(self, namespace):
        self.stop_to_collect_bip_log_on_du_l2rt(namespace)
        self.stop_to_collect_bip_log_on_du_l2nrt(namespace)

    def download_bip_log_to_master_vdu(
            self,
            pod_name,
            container_name,
            namespace,
            log_dir_in_master):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._download_bip_log_to_master_vdu(
            pod_name, container_name, namespace, log_dir_in_master)

    def get_bip_log_vdu(self, src, dst):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._get_bip_aic_vdu(src, dst)

    def capture_syslog_in_vdu(self, namespace, pod_name='logservice'):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._capture_syslog_in_vdu(
            namespace, pod_name)

    def download_syslog_to_master_vdu(
            self,
            namespace,
            log_path_ute,
            log_name='DU_SYSLOG'):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._download_syslog_from_vdu(
            namespace, log_name, log_path_ute)

    def capture_startup_log_in_vdu(self, namespace, log_path_ute):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._capture_startup_log_in_vdu(namespace)
        self.startup_base_aic_instant_2._download_startup_log_from_vdu(
            namespace, log_path_ute)

    def capture_journal_log_in_vdu(self, namespace, log_path_ute):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._capture_journal_log_in_vdu(namespace)
        self.startup_base_aic_instant_2._download_journal_log_from_vdu(
            namespace, log_path_ute)

    def collect_snapshot_du(self, snapshot_dir):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._collect_snapshot_aic(
            snapshot_dir, productVariant="du")

    def get_du_version(self, ns):
        self._setup_startup_gnb1_du()
        du_version = self.startup_base_aic_instant_2._get_aic_version(
            productVariant="du", ns=ns)
        return du_version

    def collect_coredump_log_du(self):
        self.startup_base_aic_instant_2._collect_coredump_log_du()

    def wait_all_pods_running_vdu(self, namespace, interrupt_once_fail=True):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._wait_all_pods_running_vdu(
            namespace, interrupt_once_fail)

    def cells_should_be_onair_du(
            self,
            cell_id="all",
            timeout="120",
            check_sib=True):
        """This keyword is to check cell should be onair.
            | step1 | find which cells to be checked |
            | step2 | wait cells state onairdone |
            | step3 | wait sib1 and sib2 if check_sib is True |
            | step4 | sleep 12s for waiting 'CuConfigurationUpdate' with timeToWait=10s due to PR654414:
            [CNI82646][NSA][TDD][ET]SGNB addition fail with non DOD cell due to noRadioResourcesAvailableInTargetCell |

            | Arguments  | Man.    | Default | Description |
            | cell_id    | No      | all     | which cells need to be checked |
            | timeout    | No      | 120     | timeout for wait sib1 and sib2 |
            | check_sib  | No      | True    | check sib1 and sib2 if True, don't check if False |

            Example:
            | cells_should_be_onair_du |
            | cells_should_be_onair_du | 1 |
            | cells_should_be_onair_du | check_sib=${False} |
        """
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._cells_should_be_onair_du(
            cell_id, timeout, check_sib=check_sib)

    def restart_pod_in_vdu_aic(self, pod_name, namespace):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._restart_pod_in_vdu(
            pod_name, namespace)

    def check_current_pod_status_in_du(self, namespace):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._check_pod_status_du(namespace)

    def scale_pod_in_vdu(self, pod_name, number, namespace):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._scale_pod_in_vdu(
            pod_name, number, namespace)

    def find_pod_fullname_du(self, pod_name, namespace):
        self._setup_startup_gnb1_du()
        return self.startup_base_aic_instant_2._find_pod_fullname_du(
            namespace, pod_name)

    def find_container_fullname_du(self, pod_name, container_name, namespace):
        self._setup_startup_gnb1_du()
        return self.startup_base_aic_instant_2._find_container_fullname_du(
            pod_name, container_name, namespace)

    def check_single_pod_running_vdu(
            self,
            namespace,
            podname,
            interrupt_once_fail=False):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._wait_single_pod_running_vdu(
            namespace, podname, interrupt_once_fail)

    def enable_m2m_interface_du(self, namespace):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._enable_m2m_interface_du(namespace)

    def check_m2m_interface_du(self, namespace):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._check_m2m_interface_du(namespace)

    def disable_tls_for_dcap_connect_du(self, namespace):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._disable_tls_for_dcap_connect_du(
            namespace)

    def change_swconfig_du(self, flags, namespace):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._change_swconfig_du(flags, namespace)

    def ready_for_commission_checking_vdu(self, namespace):
        self._setup_startup_gnb1_du()
        return self.startup_base_aic_instant_2._ready_for_commission_checking_vdu(
            namespace)

    def enable_iq_data_vdu1(self, data_direct, physCellId):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._enable_iq_data_vdu(
            data_direct, physCellId)

    def collect_iq_data_vdu1(self, data_direct, vdu_ns):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._collect_iq_data_vdu(
            data_direct, vdu_ns)

    def get_ocp_ranic_sw_control_sync_operator_version_vdu(self):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._get_ocp_ranic_sw_control_sync_operator_version_vdu()

    def capture_rannic_sw_controller_logs_du(
            self, rannic_sw_controller_log_path):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._capture_rannic_sw_controller_logs(
            rannic_sw_controller_log_path, "du", self.startup_base_aic_instant_2.vdu_namespace)

    def capture_ocp_logs_du(self, ocp_log_path):
        self._setup_startup_gnb1_du()
        self.startup_base_aic_instant_2._capture_ocp_logs_vdu(
            ocp_log_path, "du", self.startup_base_aic_instant_2.vdu_namespace)


class startup_aic_gnb1_du2(startup_base_aic):
    def __init__(self):
        alias = "gnb1_du2_startup"
        self.startup_base_aic_instant_3 = startup_base_aic(alias)

    def _setup_startup_gnb1_du2(self):
        self.startup_base_aic_instant_3.du_host = builtin_obj.get_variable_value(
            "${VDU2_IP}")
        self.startup_base_aic_instant_3.du_host_ssh = builtin_obj.get_variable_value(
            "${VDU2_SSH_IP}")
        self.startup_base_aic_instant_3.du_host_ssh_usr = builtin_obj.get_variable_value(
            "${VDU2_SSH_USER}")
        self.startup_base_aic_instant_3.du_host_ssh_pwd = builtin_obj.get_variable_value(
            "${VDU2_SSH_PASSWD}")
        self.startup_base_aic_instant_3.vdu_namespace = builtin_obj.get_variable_value(
            "${VDU2_NAMESPACE}")

    def capture_wireshark_log_in_vdu_du2(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._capture_wireshark_log_in_vdu(
            pod_name, container_name, namespace, wireshark_name)

    def download_wireshark_log_to_master_vdu2(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            teardown=False):
        self._setup_startup_gnb1_du2()
        return self.startup_base_aic_instant_3._download_wireshark_log_to_master_vdu(
            pod_name, container_name, namespace, wireshark_name, log_dir_in_master, teardown)

    def pure_download_wireshark_log_to_master_vdu2(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._pure_download_wireshark_log_to_master_vdu(
            pod_name, container_name, namespace, wireshark_name, log_dir_in_master)

    def stop_wireshark_capture_aic_vdu2(
            self, pod_name, container_name, namespace):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._stop_wireshark_capture_aic_vdu(
            pod_name, container_name, namespace)

    def get_wireshark_from_vdu2(self, src, dst):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._get_wireshark_aic_vdu(src, dst)

    def capture_aic_bip_log_du2_l2rt(
            self,
            namespace,
            pod_name="l2rt",
            container_name="l2rt",
            bip_port_name="l1up"):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._capture_aic_bip_log_du(
            namespace, pod_name, container_name, bip_port_name)

    def capture_aic_bip_log_du2_l2nrt(
            self,
            namespace,
            pod_name="l2nrt",
            container_name="l2hi",
            bip_port_name="l2biphi"):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._capture_aic_bip_log_du(
            namespace, pod_name, container_name, bip_port_name)

    def capture_aic_bip_log_du2(self, namespace):
        self.capture_aic_bip_log_du2_l2rt(namespace)
        self.capture_aic_bip_log_du2_l2nrt(namespace)

    def stop_to_collect_bip_log_on_du2_l2rt(
            self, namespace, pod_name="l2rt", container_name="l2rt"):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._stop_capture_bip_log_du(
            namespace, pod_name, container_name)

    def stop_to_collect_bip_log_on_du2_l2nrt(
            self, namespace, pod_name="l2nrt", container_name="l2hi"):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._stop_capture_bip_log_du(
            namespace, pod_name, container_name)

    def stop_to_collect_bip_log_on_du2(self, namespace):
        self.stop_to_collect_bip_log_on_du2_l2rt(namespace)
        self.stop_to_collect_bip_log_on_du2_l2nrt(namespace)

    def download_bip_log_to_master_vdu2(
            self,
            pod_name,
            container_name,
            namespace,
            log_dir_in_master):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._download_bip_log_to_master_vdu(
            pod_name, container_name, namespace, log_dir_in_master)

    def get_bip_log_vdu2(self, src, dst):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._get_bip_aic_vdu(src, dst)

    def capture_syslog_in_vdu2(self, namespace, pod_name='logservice'):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._capture_syslog_in_vdu(
            namespace, pod_name)

    def download_syslog_to_master_vdu2(
            self,
            namespace,
            log_path_ute,
            log_name='DU2_SYSLOG'):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._download_syslog_from_vdu(
            namespace, log_name, log_path_ute)

    def capture_startup_log_in_vdu2(self, namespace, log_path_ute):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._capture_startup_log_in_vdu(namespace)
        self.startup_base_aic_instant_3._download_startup_log_from_vdu(
            namespace, log_path_ute)

    def capture_journal_log_in_vdu2(self, namespace, log_path_ute):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._capture_journal_log_in_vdu(namespace)
        self.startup_base_aic_instant_3._download_journal_log_from_vdu(
            namespace, log_path_ute)

    def collect_snapshot_du2(self, snapshot_dir):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._collect_snapshot_aic(
            snapshot_dir, productVariant="du")

    def get_du2_version(self, ns):
        self._setup_startup_gnb1_du2()
        du2_version = self.startup_base_aic_instant_3._get_aic_version(
            productVariant="du", ns=ns)
        return du2_version

    def collect_coredump_log_du2(self):
        self.startup_base_aic_instant_3._collect_coredump_log_du(
            du_identity="du2")

    def wait_all_pods_running_vdu2(self, namespace, interrupt_once_fail=True):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._wait_all_pods_running_vdu(
            namespace, interrupt_once_fail)

    def cells_should_be_onair_du2(
            self,
            cell_id="all",
            timeout="120",
            check_sib=True):
        """This keyword is to check cell should be onair.
            | step1 | find which cells to be checked |
            | step2 | wait cells state onairdone |
            | step3 | wait sib1 and sib2 if check_sib is True |
            | step4 | sleep 12s for waiting 'CuConfigurationUpdate' with timeToWait=10s due to PR654414:
            [CNI82646][NSA][TDD][ET]SGNB addition fail with non DOD cell due to noRadioResourcesAvailableInTargetCell |

            | Arguments  | Man.    | Default | Description |
            | cell_id    | No      | all     | which cells need to be checked |
            | timeout    | No      | 120     | timeout for wait sib1 and sib2 |
            | check_sib  | No      | True    | check sib1 and sib2 if True, don't check if False |

            Example:
            | cells_should_be_onair_du2 |
            | cells_should_be_onair_du2 | 2 |
            | cells_should_be_onair_du2 | check_sib=${False} |
        """
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._cells_should_be_onair_du(
            cell_id, timeout, check_sib=check_sib, du_identity="du2")

    def restart_pod_in_vdu2_aic(self, pod_name, namespace):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._restart_pod_in_vdu(
            pod_name, namespace)

    def check_current_pod_status_in_du2(self, namespace):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._check_pod_status_du(namespace)

    def scale_pod_in_vdu2(self, pod_name, number, namespace):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._scale_pod_in_vdu(
            pod_name, number, namespace)

    def find_pod_fullname_du2(self, pod_name, namespace):
        self._setup_startup_gnb1_du2()
        return self.startup_base_aic_instant_3._find_pod_fullname_du(
            namespace, pod_name)

    def find_container_fullname_du2(self, pod_name, container_name, namespace):
        self._setup_startup_gnb1_du2()
        return self.startup_base_aic_instant_3._find_container_fullname_du(
            pod_name, container_name, namespace)

    def check_single_pod_running_vdu2(
            self,
            namespace,
            podname,
            interrupt_once_fail=False):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._wait_single_pod_running_vdu(
            namespace, podname, interrupt_once_fail)

    def enable_m2m_interface_du2(self, namespace):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._enable_m2m_interface_du(namespace)

    def check_m2m_interface_du2(self, namespace):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._check_m2m_interface_du(namespace)

    def disable_tls_for_dcap_connect_du2(self, namespace):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._disable_tls_for_dcap_connect_du(
            namespace)

    def change_swconfig_du2(self, flags, namespace):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._change_swconfig_du(flags, namespace)

    def ready_for_commission_checking_vdu2(self, namespace):
        self._setup_startup_gnb1_du2()
        return self.startup_base_aic_instant_3._ready_for_commission_checking_vdu(
            namespace, du_identity="du2")

    def enable_iq_data_vdu2(self, data_direct, physCellId):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._enable_iq_data_vdu(
            data_direct, physCellId)

    def collect_iq_data_vdu2(self, data_direct, vdu_ns):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._collect_iq_data_vdu(
            data_direct, vdu_ns)

    def get_ocp_ranic_sw_control_sync_operator_version_vdu2(self):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._get_ocp_ranic_sw_control_sync_operator_version_vdu()

    def capture_rannic_sw_controller_logs_du2(
            self, rannic_sw_controller_log_path):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._capture_rannic_sw_controller_logs(
            rannic_sw_controller_log_path, "du2", self.startup_base_aic_instant_3.vdu_namespace)

    def capture_ocp_logs_du2(self, ocp_log_path):
        self._setup_startup_gnb1_du2()
        self.startup_base_aic_instant_3._capture_ocp_logs_vdu(
            ocp_log_path, "du2", self.startup_base_aic_instant_3.vdu_namespace)


class startup_aic_gnb1_du3(startup_base_aic):
    def __init__(self):
        alias = "gnb1_du3_startup"
        self.startup_base_aic_instant_4 = startup_base_aic(alias)

    def _setup_startup_gnb1_du3(self):
        self.startup_base_aic_instant_4.du_host = builtin_obj.get_variable_value(
            "${VDU3_IP}")
        self.startup_base_aic_instant_4.du_host_ssh = builtin_obj.get_variable_value(
            "${VDU3_SSH_IP}")
        self.startup_base_aic_instant_4.du_host_ssh_usr = builtin_obj.get_variable_value(
            "${VDU3_SSH_USER}")
        self.startup_base_aic_instant_4.du_host_ssh_pwd = builtin_obj.get_variable_value(
            "${VDU3_SSH_PASSWD}")
        self.startup_base_aic_instant_4.vdu_namespace = builtin_obj.get_variable_value(
            "${VDU3_NAMESPACE}")

    def capture_wireshark_log_in_vdu_du3(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._capture_wireshark_log_in_vdu(
            pod_name, container_name, namespace, wireshark_name)

    def download_wireshark_log_to_master_vdu3(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            teardown=False):
        self._setup_startup_gnb1_du3()
        return self.startup_base_aic_instant_4._download_wireshark_log_to_master_vdu(
            pod_name, container_name, namespace, wireshark_name, log_dir_in_master, teardown)

    def pure_download_wireshark_log_to_master_vdu3(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._pure_download_wireshark_log_to_master_vdu(
            pod_name, container_name, namespace, wireshark_name, log_dir_in_master)

    def stop_wireshark_capture_aic_vdu3(
            self, pod_name, container_name, namespace):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._stop_wireshark_capture_aic_vdu(
            pod_name, container_name, namespace)

    def get_wireshark_from_vdu3(self, src, dst):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._get_wireshark_aic_vdu(src, dst)

    def capture_aic_bip_log_du3_l2rt(
            self,
            namespace,
            pod_name="l2rt",
            container_name="l2rt",
            bip_port_name="l1up"):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._capture_aic_bip_log_du(
            namespace, pod_name, container_name, bip_port_name)

    def capture_aic_bip_log_du3_l2nrt(
            self,
            namespace,
            pod_name="l2nrt",
            container_name="l2hi",
            bip_port_name="l2biphi"):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._capture_aic_bip_log_du(
            namespace, pod_name, container_name, bip_port_name)

    def capture_aic_bip_log_du3(self, namespace):
        self.capture_aic_bip_log_du3_l2rt(namespace)
        self.capture_aic_bip_log_du3_l2nrt(namespace)

    def stop_to_collect_bip_log_on_du3_l2rt(
            self, namespace, pod_name="l2rt", container_name="l2rt"):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._stop_capture_bip_log_du(
            namespace, pod_name, container_name)

    def stop_to_collect_bip_log_on_du3_l2nrt(
            self, namespace, pod_name="l2nrt", container_name="l2hi"):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._stop_capture_bip_log_du(
            namespace, pod_name, container_name)

    def stop_to_collect_bip_log_on_du3(self, namespace):
        self.stop_to_collect_bip_log_on_du3_l2rt(namespace)
        self.stop_to_collect_bip_log_on_du3_l2nrt(namespace)

    def download_bip_log_to_master_vdu3(
            self,
            pod_name,
            container_name,
            namespace,
            log_dir_in_master):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._download_bip_log_to_master_vdu(
            pod_name, container_name, namespace, log_dir_in_master)

    def get_bip_log_vdu3(self, src, dst):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._get_bip_aic_vdu(src, dst)

    def capture_syslog_in_vdu3(self, namespace, pod_name='logservice'):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._capture_syslog_in_vdu(
            namespace, pod_name)

    def download_syslog_to_master_vdu3(
            self,
            namespace,
            log_path_ute,
            log_name='DU3_SYSLOG'):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._download_syslog_from_vdu(
            namespace, log_name, log_path_ute)

    def capture_startup_log_in_vdu3(self, namespace, log_path_ute):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._capture_startup_log_in_vdu(namespace)
        self.startup_base_aic_instant_4._download_startup_log_from_vdu(
            namespace, log_path_ute)

    def capture_journal_log_in_vdu3(self, namespace, log_path_ute):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._capture_journal_log_in_vdu(namespace)
        self.startup_base_aic_instant_4._download_journal_log_from_vdu(
            namespace, log_path_ute)

    def collect_snapshot_du3(self, snapshot_dir):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._collect_snapshot_aic(
            snapshot_dir, productVariant="du")

    def get_du3_version(self, ns):
        self._setup_startup_gnb1_du3()
        du3_version = self.startup_base_aic_instant_4._get_aic_version(
            productVariant="du", ns=ns)
        return du3_version

    def collect_coredump_log_du3(self):
        self.startup_base_aic_instant_4._collect_coredump_log_du(
            du_identity="du3")

    def wait_all_pods_running_vdu3(self, namespace, interrupt_once_fail=True):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._wait_all_pods_running_vdu(
            namespace, interrupt_once_fail)

    def cells_should_be_onair_du3(
            self,
            cell_id="all",
            timeout="120",
            check_sib=True):
        """This keyword is to check cell should be onair.
            | step1 | find which cells to be checked |
            | step2 | wait cells state onairdone |
            | step3 | wait sib1 and sib2 if check_sib is True |
            | step4 | sleep 12s for waiting 'CuConfigurationUpdate' with timeToWait=10s due to PR654414:
            [CNI82646][NSA][TDD][ET]SGNB addition fail with non DOD cell due to noRadioResourcesAvailableInTargetCell |

            | Arguments  | Man.    | Default | Description |
            | cell_id    | No      | all     | which cells need to be checked |
            | timeout    | No      | 120     | timeout for wait sib1 and sib2 |
            | check_sib  | No      | True    | check sib1 and sib2 if True, don't check if False |

            Example:
            | cells_should_be_onair_du3 |
            | cells_should_be_onair_du3 | 2 |
            | cells_should_be_onair_du3 | check_sib=${False} |
        """
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._cells_should_be_onair_du(
            cell_id, timeout, check_sib=check_sib, du_identity="du3")

    def restart_pod_in_vdu3_aic(self, pod_name, namespace):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._restart_pod_in_vdu(
            pod_name, namespace)

    def check_current_pod_status_in_du3(self, namespace):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._check_pod_status_du(namespace)

    def scale_pod_in_vdu3(self, pod_name, number, namespace):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._scale_pod_in_vdu(
            pod_name, number, namespace)

    def find_pod_fullname_du3(self, pod_name, namespace):
        self._setup_startup_gnb1_du3()
        return self.startup_base_aic_instant_4._find_pod_fullname_du(
            namespace, pod_name)

    def find_container_fullname_du3(self, pod_name, container_name, namespace):
        self._setup_startup_gnb1_du3()
        return self.startup_base_aic_instant_4._find_container_fullname_du(
            pod_name, container_name, namespace)

    def check_single_pod_running_vdu3(
            self,
            namespace,
            podname,
            interrupt_once_fail=False):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._wait_single_pod_running_vdu(
            namespace, podname, interrupt_once_fail)

    def enable_m2m_interface_du3(self, namespace):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._enable_m2m_interface_du(namespace)

    def check_m2m_interface_du3(self, namespace):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._check_m2m_interface_du(namespace)

    def disable_tls_for_dcap_connect_du3(self, namespace):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._disable_tls_for_dcap_connect_du(
            namespace)

    def change_swconfig_du3(self, flags, namespace):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._change_swconfig_du(flags, namespace)

    def ready_for_commission_checking_vdu3(self, namespace):
        self._setup_startup_gnb1_du3()
        return self.startup_base_aic_instant_4._ready_for_commission_checking_vdu(
            namespace, du_identity="du3")

    def enable_iq_data_vdu3(self, data_direct, physCellId):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._enable_iq_data_vdu(
            data_direct, physCellId)

    def collect_iq_data_vdu3(self, data_direct, vdu_ns):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._collect_iq_data_vdu(
            data_direct, vdu_ns)

    def get_ocp_ranic_sw_control_sync_operator_version_vdu3(self):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._get_ocp_ranic_sw_control_sync_operator_version_vdu()

    def capture_rannic_sw_controller_logs_du3(
            self, rannic_sw_controller_log_path):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._capture_rannic_sw_controller_logs(
            rannic_sw_controller_log_path, "du3", self.startup_base_aic_instant_4.vdu_namespace)

    def capture_ocp_logs_du3(self, ocp_log_path):
        self._setup_startup_gnb1_du3()
        self.startup_base_aic_instant_4._capture_ocp_logs_vdu(
            ocp_log_path, "du3", self.startup_base_aic_instant_4.vdu_namespace)


class startup_aic_gnb1_du4(startup_base_aic):
    def __init__(self):
        alias = "gnb1_du4_startup"
        self.startup_base_aic_instant_5 = startup_base_aic(alias)

    def _setup_startup_gnb1_du4(self):
        self.startup_base_aic_instant_5.du_host = builtin_obj.get_variable_value(
            "${VDU4_IP}")
        self.startup_base_aic_instant_5.du_host_ssh = builtin_obj.get_variable_value(
            "${VDU4_SSH_IP}")
        self.startup_base_aic_instant_5.du_host_ssh_usr = builtin_obj.get_variable_value(
            "${VDU4_SSH_USER}")
        self.startup_base_aic_instant_5.du_host_ssh_pwd = builtin_obj.get_variable_value(
            "${VDU4_SSH_PASSWD}")
        self.startup_base_aic_instant_5.vdu_namespace = builtin_obj.get_variable_value(
            "${VDU4_NAMESPACE}")

    def capture_wireshark_log_in_vdu_du4(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._capture_wireshark_log_in_vdu(
            pod_name, container_name, namespace, wireshark_name)

    def download_wireshark_log_to_master_vdu4(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master,
            teardown=False):
        self._setup_startup_gnb1_du4()
        return self.startup_base_aic_instant_5._download_wireshark_log_to_master_vdu(
            pod_name, container_name, namespace, wireshark_name, log_dir_in_master, teardown)

    def pure_download_wireshark_log_to_master_vdu4(
            self,
            pod_name,
            container_name,
            namespace,
            wireshark_name,
            log_dir_in_master):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._pure_download_wireshark_log_to_master_vdu(
            pod_name, container_name, namespace, wireshark_name, log_dir_in_master)

    def stop_wireshark_capture_aic_vdu4(
            self, pod_name, container_name, namespace):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._stop_wireshark_capture_aic_vdu(
            pod_name, container_name, namespace)

    def get_wireshark_from_vdu4(self, src, dst):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._get_wireshark_aic_vdu(src, dst)

    def capture_aic_bip_log_du4_l2rt(
            self,
            namespace,
            pod_name="l2rt",
            container_name="l2rt",
            bip_port_name="l1up"):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._capture_aic_bip_log_du(
            namespace, pod_name, container_name, bip_port_name)

    def capture_aic_bip_log_du4_l2nrt(
            self,
            namespace,
            pod_name="l2nrt",
            container_name="l2hi",
            bip_port_name="l2biphi"):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._capture_aic_bip_log_du(
            namespace, pod_name, container_name, bip_port_name)

    def capture_aic_bip_log_du4(self, namespace):
        self.capture_aic_bip_log_du4_l2rt(namespace)
        self.capture_aic_bip_log_du4_l2nrt(namespace)

    def stop_to_collect_bip_log_on_du4_l2rt(
            self, namespace, pod_name="l2rt", container_name="l2rt"):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._stop_capture_bip_log_du(
            namespace, pod_name, container_name)

    def stop_to_collect_bip_log_on_du4_l2nrt(
            self, namespace, pod_name="l2nrt", container_name="l2hi"):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._stop_capture_bip_log_du(
            namespace, pod_name, container_name)

    def stop_to_collect_bip_log_on_du4(self, namespace):
        self.stop_to_collect_bip_log_on_du4_l2rt(namespace)
        self.stop_to_collect_bip_log_on_du4_l2nrt(namespace)

    def download_bip_log_to_master_vdu4(
            self,
            pod_name,
            container_name,
            namespace,
            log_dir_in_master):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._download_bip_log_to_master_vdu(
            pod_name, container_name, namespace, log_dir_in_master)

    def get_bip_log_vdu4(self, src, dst):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._get_bip_aic_vdu(src, dst)

    def capture_syslog_in_vdu4(self, namespace, pod_name='logservice'):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._capture_syslog_in_vdu(
            namespace, pod_name)

    def download_syslog_to_master_vdu4(
            self,
            namespace,
            log_path_ute,
            log_name='DU4_SYSLOG'):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._download_syslog_from_vdu(
            namespace, log_name, log_path_ute)

    def capture_startup_log_in_vdu4(self, namespace, log_path_ute):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._capture_startup_log_in_vdu(namespace)
        self.startup_base_aic_instant_5._download_startup_log_from_vdu(
            namespace, log_path_ute)

    def capture_journal_log_in_vdu4(self, namespace, log_path_ute):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._capture_journal_log_in_vdu(namespace)
        self.startup_base_aic_instant_5._download_journal_log_from_vdu(
            namespace, log_path_ute)

    def collect_snapshot_du4(self, snapshot_dir):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._collect_snapshot_aic(
            snapshot_dir, productVariant="du")

    def get_du4_version(self, ns):
        self._setup_startup_gnb1_du4()
        du4_version = self.startup_base_aic_instant_5._get_aic_version(
            productVariant="du", ns=ns)
        return du4_version

    def collect_coredump_log_du4(self):
        self.startup_base_aic_instant_5._collect_coredump_log_du(
            du_identity="du4")

    def wait_all_pods_running_vdu4(self, namespace, interrupt_once_fail=True):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._wait_all_pods_running_vdu(
            namespace, interrupt_once_fail)

    def cells_should_be_onair_du4(
            self,
            cell_id="all",
            timeout="120",
            check_sib=True):
        """This keyword is to check cell should be onair.
            | step1 | find which cells to be checked |
            | step2 | wait cells state onairdone |
            | step3 | wait sib1 and sib2 if check_sib is True |
            | step4 | sleep 12s for waiting 'CuConfigurationUpdate' with timeToWait=10s due to PR654414:
            [CNI82646][NSA][TDD][ET]SGNB addition fail with non DOD cell due to noRadioResourcesAvailableInTargetCell |

            | Arguments  | Man.    | Default | Description |
            | cell_id    | No      | all     | which cells need to be checked |
            | timeout    | No      | 120     | timeout for wait sib1 and sib2 |
            | check_sib  | No      | True    | check sib1 and sib2 if True, don't check if False |

            Example:
            | cells_should_be_onair_du3 |
            | cells_should_be_onair_du3 | 2 |
            | cells_should_be_onair_du3 | check_sib=${False} |
        """
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._cells_should_be_onair_du(
            cell_id, timeout, check_sib=check_sib, du_identity="du4")

    def restart_pod_in_vdu4_aic(self, pod_name, namespace):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._restart_pod_in_vdu(
            pod_name, namespace)

    def check_current_pod_status_in_du4(self, namespace):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._check_pod_status_du(namespace)

    def scale_pod_in_vdu4(self, pod_name, number, namespace):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._scale_pod_in_vdu(
            pod_name, number, namespace)

    def find_pod_fullname_du4(self, pod_name, namespace):
        self._setup_startup_gnb1_du4()
        return self.startup_base_aic_instant_5._find_pod_fullname_du(
            namespace, pod_name)

    def find_container_fullname_du4(self, pod_name, container_name, namespace):
        self._setup_startup_gnb1_du4()
        return self.startup_base_aic_instant_5._find_container_fullname_du(
            pod_name, container_name, namespace)

    def check_single_pod_running_vdu4(
            self,
            namespace,
            podname,
            interrupt_once_fail=False):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._wait_single_pod_running_vdu(
            namespace, podname, interrupt_once_fail)

    def enable_m2m_interface_du4(self, namespace):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._enable_m2m_interface_du(namespace)

    def check_m2m_interface_du4(self, namespace):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._check_m2m_interface_du(namespace)

    def disable_tls_for_dcap_connect_du4(self, namespace):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._disable_tls_for_dcap_connect_du(
            namespace)

    def change_swconfig_du4(self, flags, namespace):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._change_swconfig_du(flags, namespace)

    def ready_for_commission_checking_vdu4(self, namespace):
        self._setup_startup_gnb1_du4()
        return self.startup_base_aic_instant_5._ready_for_commission_checking_vdu(
            namespace, du_identity="du4")

    def enable_iq_data_vdu4(self, data_direct, physCellId):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._enable_iq_data_vdu(
            data_direct, physCellId)

    def collect_iq_data_vdu4(self, data_direct, vdu_ns):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._collect_iq_data_vdu(
            data_direct, vdu_ns)

    def get_ocp_ranic_sw_control_sync_operator_version_vdu4(self):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._get_ocp_ranic_sw_control_sync_operator_version_vdu()

    def capture_rannic_sw_controller_logs_du4(
            self, rannic_sw_controller_log_path):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._capture_rannic_sw_controller_logs(
            rannic_sw_controller_log_path, "du4", self.startup_base_aic_instant_5.vdu_namespace)

    def capture_ocp_logs_du4(self, ocp_log_path):
        self._setup_startup_gnb1_du4()
        self.startup_base_aic_instant_5._capture_ocp_logs_vdu(
            ocp_log_path, "du4", self.startup_base_aic_instant_5.vdu_namespace)


class startup_aic(
        startup_aic_gnb1_cu,
        startup_aic_gnb1_du,
        startup_aic_gnb1_du2,
        startup_aic_gnb1_du3,
        startup_aic_gnb1_du4):
    def __init__(self):
        startup_aic_gnb1_cu.__init__(self)
        startup_aic_gnb1_du.__init__(self)
        startup_aic_gnb1_du2.__init__(self)
        startup_aic_gnb1_du3.__init__(self)
        startup_aic_gnb1_du4.__init__(self)

    def _evaluate_network_type_aic(self, scf_cu):
        """
        if gNbCuType=SA, return SA;
        if gNbCuType=NSA, return NSA;
        if gNbCuType=SA+NSA and cellDepType under all unlocked cells are SA, then return SA;
        if gNbCuType=SA+NSA and cellDepType under all unlocked cells are NSA, then return NSA;
        if gNbCuType=SA+NSA and cellDepType under all unlocked cells are SA+NSA, then return SA+NSA;
        if gNbCuType=SA+NSA and cellDepType are different among unlocked cells, then retrun SA+NSA
        """
        commonxml_obj = CommonXML(scf_cu)
        cu_type_xpath = comm_obj.match_to_xpath("gNbCuType")
        cu_type_value = xml_obj.read_xml(scf_cu, "text|%s" % cu_type_xpath[0])
        if cu_type_value == "SA+NSA":
            cells_deptype = []
            all_elements = commonxml_obj.get_elements(
                "//*[@name='administrativeState'][text()='Unlocked']/../*[@name='cellDepType']")
            for element in all_elements:
                cells_deptype.append(commonxml_obj.get_element_text(element))
            cells_deptype = list(set(cells_deptype))  # remove duplicate

            if len(cells_deptype) == 1:
                actual_network_type = cells_deptype[0]
            else:
                actual_network_type = "SA+NSA"
        else:
            actual_network_type = cu_type_value
        return actual_network_type

    def wait_bts_onair_aic(self):
        cu_type = self.startup_base_aic_instant_1._get_parameter_value_cu(
            "gNbCuType")
        du_num = builtin_obj.get_variable_value("${DU_NUMBER}")
        result = False
        try:
            actual_network_type = self._evaluate_network_type_aic(
                "/home/ute/scf.xml")
            if actual_network_type == "SA":
                self.startup_base_aic_instant_1._wait_ng_link_up_aic()
            elif actual_network_type == "NSA":
                self.startup_base_aic_instant_1._wait_x2_up_aic()
            elif actual_network_type == "SA+NSA":
                self.startup_base_aic_instant_1._wait_ng_link_up_aic()
                self.startup_base_aic_instant_1._wait_x2_up_aic()
            else:
                raise Exception(
                    "not support %s yet, pls contact "
                    "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com to support it" %
                    cu_type)

            # wait cu du onair
            self._wait_cu_du_onair_aic()
            self.startup_base_aic_instant_2._wait_cells_onair_aic(
                alias=self.startup_base_aic_instant_2.alias_du)
            if du_num != "du" and du_num >= "2du":
                self.startup_base_aic_instant_3._wait_cells_onair_aic(
                    alias=self.startup_base_aic_instant_3.alias_du, du_identity="du2")
            if du_num != "du" and du_num >= "3du":
                self.startup_base_aic_instant_4._wait_cells_onair_aic(
                    alias=self.startup_base_aic_instant_4.alias_du, du_identity="du3")
            if du_num != "du" and du_num >= "4du":
                self.startup_base_aic_instant_5._wait_cells_onair_aic(
                    alias=self.startup_base_aic_instant_5.alias_du, du_identity="du4")

            builtin_obj.log("@@@ GNB Is Already OnAir. ")
            result = True
        except Exception:
            detail = traceback.format_exc()
            # builtin_obj.log(detail)
            raise Exception(detail)
        return result

    def _wait_cu_du_onair_aic(self):
        du_num = builtin_obj.get_variable_value("${DU_NUMBER}")
        time_start = time.time()
        try:
            if du_num == "2du":
                while True:
                    time.sleep(10)
                    cu_state_info = self.startup_base_aic_instant_1._get_cu_state()
                    du_state_info = self.startup_base_aic_instant_2._get_du_state()
                    du2_state_info = self.startup_base_aic_instant_3._get_du_state()
                    cu_state = cu_state_info["operational_state"]
                    du_state = du_state_info["operational_state"]
                    du2_state = du2_state_info["operational_state"]
                    if cu_state == "enabled" and du_state == "onAir" and du2_state == "onAir":
                        comm_obj.log_to_console_with_time_prefix(
                            "DU1 state is %s" % du_state, "INFO")
                        comm_obj.log_to_console_with_time_prefix(
                            "DU2 state is %s" % du2_state, "INFO")
                        break
                    else:
                        if time.time() - time_start >= 300:
                            if du_state != "onAir":
                                comm_obj.log_to_console_with_time_prefix(
                                    "Du1 state is %s" % du_state, "WARN")
                            if du2_state != "onAir":
                                comm_obj.log_to_console_with_time_prefix(
                                    "Du2 state is %s" % du2_state, "WARN")
                            raise Exception("Du state is not onAir")
            elif du_num == "3du":
                while True:
                    time.sleep(10)
                    cu_state_info = self.startup_base_aic_instant_1._get_cu_state()
                    du_state_info = self.startup_base_aic_instant_2._get_du_state()
                    du2_state_info = self.startup_base_aic_instant_3._get_du_state()
                    du3_state_info = self.startup_base_aic_instant_4._get_du_state()
                    cu_state = cu_state_info["operational_state"]
                    du_state = du_state_info["operational_state"]
                    du2_state = du2_state_info["operational_state"]
                    du3_state = du3_state_info["operational_state"]
                    if cu_state == "enabled" and du_state == "onAir" and du2_state == "onAir" and du3_state == "onAir":
                        comm_obj.log_to_console_with_time_prefix(
                            "DU1 state is %s" % du_state, "INFO")
                        comm_obj.log_to_console_with_time_prefix(
                            "DU2 state is %s" % du2_state, "INFO")
                        comm_obj.log_to_console_with_time_prefix(
                            "DU3 state is %s" % du3_state, "INFO")
                        break
                    else:
                        if time.time() - time_start >= 300:
                            if du_state != "onAir":
                                comm_obj.log_to_console_with_time_prefix(
                                    "Du1 state is %s" % du_state, "WARN")
                            if du2_state != "onAir":
                                comm_obj.log_to_console_with_time_prefix(
                                    "Du2 state is %s" % du2_state, "WARN")
                            if du3_state != "onAir":
                                comm_obj.log_to_console_with_time_prefix(
                                    "Du3 state is %s" % du3_state, "WARN")
                            raise Exception("Du state is not onAir")
            elif du_num == "4du":
                while True:
                    time.sleep(10)
                    cu_state_info = self.startup_base_aic_instant_1._get_cu_state()
                    du_state_info = self.startup_base_aic_instant_2._get_du_state()
                    du2_state_info = self.startup_base_aic_instant_3._get_du_state()
                    du3_state_info = self.startup_base_aic_instant_4._get_du_state()
                    du4_state_info = self.startup_base_aic_instant_5._get_du_state()
                    cu_state = cu_state_info["operational_state"]
                    du_state = du_state_info["operational_state"]
                    du2_state = du2_state_info["operational_state"]
                    du3_state = du3_state_info["operational_state"]
                    du4_state = du4_state_info["operational_state"]
                    if cu_state == "enabled" and du_state == "onAir" and du2_state == "onAir" and du3_state == "onAir"\
                            and du4_state == "onAir":
                        comm_obj.log_to_console_with_time_prefix(
                            "DU1 state is %s" % du_state, "INFO")
                        comm_obj.log_to_console_with_time_prefix(
                            "DU2 state is %s" % du2_state, "INFO")
                        comm_obj.log_to_console_with_time_prefix(
                            "DU3 state is %s" % du3_state, "INFO")
                        comm_obj.log_to_console_with_time_prefix(
                            "DU4 state is %s" % du4_state, "INFO")
                        break
                    else:
                        if time.time() - time_start >= 300:
                            if du_state != "onAir":
                                comm_obj.log_to_console_with_time_prefix(
                                    "Du1 state is %s" % du_state, "WARN")
                            if du2_state != "onAir":
                                comm_obj.log_to_console_with_time_prefix(
                                    "Du2 state is %s" % du2_state, "WARN")
                            if du3_state != "onAir":
                                comm_obj.log_to_console_with_time_prefix(
                                    "Du3 state is %s" % du3_state, "WARN")
                            if du4_state != "onAir":
                                comm_obj.log_to_console_with_time_prefix(
                                    "Du4 state is %s" % du4_state, "WARN")
                            raise Exception("Du state is not onAir")
            else:
                while True:
                    time.sleep(10)
                    cu_state_info = self.startup_base_aic_instant_1._get_cu_state()
                    du_state_info = self.startup_base_aic_instant_2._get_du_state()
                    cu_state = cu_state_info["operational_state"]
                    du_state = du_state_info["operational_state"]
                    if cu_state == "enabled" and du_state == "onAir":
                        comm_obj.log_to_console_with_time_prefix(
                            "DU state is %s" % du_state, "INFO")
                        break
                    else:
                        if time.time() - time_start >= 360:
                            if du_state != "onAir":
                                comm_obj.log_to_console_with_time_prefix(
                                    "Du state is %s" % du_state, "WARN")
                            raise Exception("Du state is not onAir")
            time_elapse = time.time() - time_start
            comm_obj.log_to_console_with_time_prefix(
                "step: wait all Du state reach OnAirDone cost %s sec" %
                int(time_elapse))
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)

    def restart_aic(self):
        self.startup_base_aic_instant_1._reset_cu()
        self.startup_base_aic_instant_2._reset_du()
        du_num = builtin_obj.get_variable_value("${DU_NUMBER}")
        if du_num != "du" and du_num >= "2du":
            self.startup_base_aic_instant_3._reset_du()
        if du_num != "du" and du_num >= "3du":
            self.startup_base_aic_instant_4._reset_du()
        if du_num != "du" and du_num >= "4du":
            self.startup_base_aic_instant_5._reset_du()

    def reset_du(self):
        self.startup_base_aic_instant_2._reset_du()
        du_num = builtin_obj.get_variable_value("${DU_NUMBER}")
        if du_num != "du" and du_num >= "2du":
            self.startup_base_aic_instant_3._reset_du()
        if du_num != "du" and du_num >= "3du":
            self.startup_base_aic_instant_4._reset_du()
        if du_num != "du" and du_num >= "4du":
            self.startup_base_aic_instant_5._reset_du()

    def reset_cu(self):
        self.startup_base_aic_instant_1._reset_cu()

    def teardown_all_alias_for_admin_aic(self):
        self.startup_base_aic_instant_1._teardown_all_alias_for_admin_cu()
        self.startup_base_aic_instant_2._teardown_all_alias_for_admin_du()
        self.startup_base_aic_instant_3._teardown_all_alias_for_admin_du()
        self.startup_base_aic_instant_4._teardown_all_alias_for_admin_du()
        self.startup_base_aic_instant_5._teardown_all_alias_for_admin_du()


if __name__ == "__main__":
    obj = startup_aic()
    help(obj)
