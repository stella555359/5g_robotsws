# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
import time
import re
from taf.sw.dcap.rd import rd
from robot.libraries.BuiltIn import BuiltIn
from common_lib_aic import common_lib_aic
import traceback

builtin_obj = BuiltIn()
comm_obj = common_lib_aic()


class dcap_base_aic(object):
    def __init__(self, alias):
        self.alias = alias
        self.alias_cu = self.alias + "_cu_dcap"
        self.alias_du = self.alias + "_dcap"
        # self.alias_du2 = self.alias + "_du2_dcap"
        # self.dcap_host_ip = "10.107.125.34"
        # self.host_cu = "192.168.100.129"
        # self.host_du = "192.168.255.129"
        # self.host_du2 = None

    def _connect_dcap_aic(self):
        self.dcap_obj = rd()
        if self._check_alias_exist_on_dcap(self.dcap_obj, alias_name="aic_dcap"):
            return
        self.dcap_obj.connect_to(host=self.dcap_host_ip, port='9443', username=None, password=None,
                                 secure=True, alias="aic_dcap")

    def _create_aic_cu(self):
        self._connect_dcap_aic()
        try:
            ret_create_cu = self.dcap_obj.create_bts(host=self.host_cu, port="443", username='Nemuadmin',
                                                     password='Nokia@123', bts_alias='aic', credential_region_Id="cu",
                                                     connection="aic_dcap")
            builtin_obj.log("create_cu_return_info: %s" % ret_create_cu)
        except Exception:
            detail = traceback.format_exc()
            if detail.count("BTS already exists in the database"):
                builtin_obj.log(detail)
            else:
                raise Exception(detail)

    def _create_aic_du(self):
        self._connect_dcap_aic()
        try:
            ret_create_du = self.dcap_obj.create_bts(host=self.host_du, port="443", username='Nemuadmin',
                                                     password='Nokia@123', bts_alias='aic', credential_region_Id="du",
                                                     connection="aic_dcap")
            builtin_obj.log("create_du_return_info: %s" % ret_create_du)
        except Exception:
            detail = traceback.format_exc()
            if detail.count("BTS already exists in the database"):
                builtin_obj.log(detail)
            else:
                raise Exception(detail)

    def _check_alias_exist_on_dcap(self, rd_dcap_obj, alias_name):
        if not rd_dcap_obj.store.all:
            builtin_obj.log('dcap store does not have alias now')
            return False
        if alias_name in [i[0] for i in rd_dcap_obj.store.all]:
            builtin_obj.log('dcap alias %s exists' % alias_name)
            return True
        return False

    def _get_dcap_all_bts_info_aic(self, conn):
        self._connect_dcap_aic()
        bts_info_ret = self.dcap_obj.get_all_bts_info(connection=conn)
        builtin_obj.log(bts_info_ret)
        return bts_info_ret

    def _get_dcap_all_bts_info_cu(self):
        cu_info_ret = self._get_dcap_all_bts_info_aic(conn="aic_dcap")
        builtin_obj.log(cu_info_ret)
        return cu_info_ret

    def _get_dcap_all_bts_info_du(self):
        du_info_ret = self._get_dcap_all_bts_info_aic(conn="aic_dcap")
        builtin_obj.log(du_info_ret)
        return du_info_ret

    def _get_bts_dic_cu(self):
        self.cu_account_dic = {"host": self.host_cu, "port": "443", "username": "Nemuadmin", "password": "Nokia@123"}
        return self.cu_account_dic

    def _get_bts_dic_du(self):
        self.du_account_dic = {"host": self.host_du, "port": "443", "username": "Nemuadmin", "password": "Nokia@123"}
        return self.du_account_dic

    def _check_precondition_dcap(self, bts_dic, conn, **kwargs):
        self._connect_dcap_aic()
        pre_check_ret = self.dcap_obj.check_precondition(bts=bts_dic, connection=conn, **kwargs)
        builtin_obj.log(pre_check_ret)

    def _check_precondition_dcap_cu(self):
        self._get_bts_dic_cu()
        self._check_precondition_dcap(bts_dic=self.cu_account_dic, conn="aic_dcap",
                                      vcu_custom_profile=["controlPlane5gVcu"])

    def _check_precondition_dcap_du(self):
        self._get_bts_dic_du()
        self._check_precondition_dcap(bts_dic=self.du_account_dic, conn="aic_dcap",
                                      vdu_custom_profile=["controlPlane5gVdu"])

    def _start_trace_dcap_cu(self):
        self._connect_dcap_aic()
        self._get_bts_dic_cu()
        start_trace_ret_cu = self.dcap_obj.start_trace(self.cu_account_dic, connection="aic_dcap",
                                                       vcu_custom_profile=["controlPlane5gVcu"])
        builtin_obj.log(start_trace_ret_cu)
        return start_trace_ret_cu

    def _start_trace_dcap_du(self):
        self._connect_dcap_aic()
        self._get_bts_dic_du()
        start_trace_ret_du = self.dcap_obj.start_trace(self.du_account_dic, connection="aic_dcap",
                                                       vdu_custom_profile=["controlPlane5gVdu"])
        builtin_obj.log(start_trace_ret_du)
        return start_trace_ret_du

    def _stop_trace_dcap_cu(self, trace_id):
        self._connect_dcap_aic()
        cu_trace_id_info_ret = self.dcap_obj.get_trace_info_by_id(trace_id=trace_id, connection="aic_dcap")
        if cu_trace_id_info_ret["status"].lower() in ["running", "runningwithwarning"]:
            self.dcap_obj.stop_trace(trace_id=trace_id, connection="aic_dcap")
        else:
            builtin_obj.log("cu trace_id: %s already stopped." % trace_id)

    def _stop_trace_dcap_du(self, trace_id):
        self._connect_dcap_aic()
        du_trace_id_info_ret = self.dcap_obj.get_trace_info_by_id(trace_id=trace_id, connection="aic_dcap")
        if du_trace_id_info_ret["status"].lower() in ["running", "runningwithwarning"]:
            self.dcap_obj.stop_trace(trace_id=trace_id, connection="aic_dcap")
        else:
            builtin_obj.log("du trace_id: %s already stopped." % trace_id)

    def _delete_bts_dcap_cu(self, bts_id=None):
        """bts_id need fetch from return info from start trace"""
        self._connect_dcap_aic()
        self.dcap_obj.delete_bts(bts_id=bts_id, connection="aic_dcap")

    def _delete_bts_dcap_du(self, bts_id=None):
        """bts_id need fetch from return info from start trace"""
        # dcap_object.delete_bts(bts_id=ret_create["id"], connection="cu") #single connection
        # dcap_object.delete_bts(bts_id=ret_create["id"], connection="cu") #multi connection need match with ip_address
        self._connect_dcap_aic()
        self.dcap_obj.delete_bts(bts_id=bts_id, connection="aic_dcap")


class install_dcap_aic(object):
    def __init__(self):
        pass

    def check_and_install_dcap(self):
        dcap_install_check_ret = comm_obj.execute_cmd_on_pc("which utf_lab-controller")
        if dcap_install_check_ret is (None or ""):
            comm_obj.log_to_console_with_time_prefix("DCAP not install %s, try to install..." % dcap_install_check_ret)
            self.dcap_install()
        elif dcap_install_check_ret.count("utf_lab-controller"):
            builtin_obj.log("DCAP installed already with directory:%s" % dcap_install_check_ret)
            self._check_dcap_is_running()
        else:
            builtin_obj.log(dcap_install_check_ret)
        try:
            comm_obj.execute_cmd_on_pc("utf_lab-updates")
        except Exception as e:
            builtin_obj.log(e)

    def _check_dcap_is_running(self):
        dcap_status = comm_obj.execute_cmd_on_pc("sudo utf_lab-controller status")
        if dcap_status.count("flowtracer is not in running state") or dcap_status.count(
                "emil_webserver is not in running state"):
            running_info = comm_obj.execute_cmd_on_pc("sudo utf_lab-controller restart", timeout=60)
            if running_info.count("UTF Lab containers restarted successfully"):
                builtin_obj.log("DCAP is running...")
                self._change_dcap_ip_to_hostip()

    def _change_dcap_ip_to_hostip(self):
        # default install ip is 192.168.255.126
        self.dcap_ip = builtin_obj.get_variable_value("${testline_ip}")
        comm_obj.execute_cmd_on_pc("utf_lab-IP 192.168.255.126 %s" % self.dcap_ip, timeout=60)
        builtin_obj.log("change dcap ip to hostip done.")

    def dcap_install(self):
        self.dcap_ip = builtin_obj.get_variable_value("${testline_ip}")
        ver_newest = self.fetch_newest_dcap_version()
        dcap_tool_addr = "https://artifactory-espoo2.int.net.nokia.com/artifactory/" \
                         "tts-binaries-releases-local/utf_lab/releases/%s/utf_lab_installer.%s.sh" % (ver_newest,
                                                                                                      ver_newest)
        comm_obj.execute_cmd_on_pc("cd /home/ute;rm utf_lab_installer.%s.sh" % dcap_tool_addr)
        comm_obj.execute_cmd_on_pc("cd /home/ute;wget %s" % dcap_tool_addr)
        comm_obj.execute_cmd_on_pc("sudo docker info |grep 'Docker Root Dir'")
        comm_obj.execute_cmd_on_pc("sudo rm -rf /var/lib/docker")
        comm_obj.execute_cmd_on_pc("sudo ln -s /home/docker/ /var/lib/docker")
        time.sleep(5)  # wait for download completely.
        comm_obj.log_to_console_with_time_prefix("Install DCAP will spend about 10+ min...")
        install_ret = comm_obj.execute_cmd_on_pc(
            "cd /home/ute;sudo UTE_CLOUD=1 bash utf_lab_installer.%s.sh %s" % (ver_newest, self.dcap_ip),
            timeout=900)
        if install_ret.count("SUCCESS: DCAP Basic %s installed" % ver_newest):
            comm_obj.log_to_console_with_time_prefix("DCAP install successfully")
        else:
            comm_obj.log_to_console_with_time_prefix("DCAP install fail")

    def fetch_newest_dcap_version(self, base_version="FB2309.1"):
        dcap_tool_dir = "https://artifactory-espoo2.int.net.nokia.com/artifactory/" \
                        "tts-binaries-releases-local/utf_lab/releases/"
        addr_ret = comm_obj.execute_cmd_on_pc("curl %s" % dcap_tool_dir)
        # builtin_obj.log(type(addr_ret))
        # builtin_obj.log(addr_ret.split("\r\n"))
        version_list = []
        for ver in addr_ret.split("\r\n"):
            ver_match = re.match(r'<a href="(FB(\d+).(\d+))/".*', ver)
            if ver_match:
                if ver_match.group(1) >= base_version:
                    version_list.append(ver_match.group(1))
        ver_newest = base_version
        for ver_new in version_list:
            if ver_new > ver_newest:
                ver_newest = ver_new
        builtin_obj.log(ver_newest)
        return ver_newest


class dcap_aic_gnb1_cu(object):
    def __init__(self):
        alias = "gnb1"
        self.dcap_base_aic_instant_1 = dcap_base_aic(alias)

    def _setup_dcap_gnb1_cu(self):
        # self.dcap_base_aic_instant_1.alias_cu = "gnb1_cu_dcap"
        self.dcap_base_aic_instant_1.host_cu = builtin_obj.get_variable_value("${VCU_IP}")
        self.dcap_base_aic_instant_1.dcap_host_ip = builtin_obj.get_variable_value("${testline_ip}")

    def start_capture_emil_log_aic_cu(self):
        self._setup_dcap_gnb1_cu()
        self.dcap_base_aic_instant_1._create_aic_cu()
        self.dcap_base_aic_instant_1._get_dcap_all_bts_info_cu()
        self.dcap_base_aic_instant_1._check_precondition_dcap_cu()
        start_trace_cu_ret = self.dcap_base_aic_instant_1._start_trace_dcap_cu()
        return int(start_trace_cu_ret["tracer_id"])

    def stop_capture_emil_log_aic_cu(self, trace_id, emil_log_dir_cu):
        self._setup_dcap_gnb1_cu()
        self.dcap_base_aic_instant_1._stop_trace_dcap_cu(trace_id)
        # sleep for log file package
        time_end = time.time() + 30
        while True:
            result_ret = comm_obj.execute_cmd_on_pc("ls /home/sharedvolume/trace_results/%s" % trace_id)
            if (result_ret.count("results.zip") and result_ret.count("results") == 1) or time.time() > time_end:
                if result_ret.count("results.zip"):
                    builtin_obj.log("cu emil log file:%s packed" % result_ret)
                break
            else:
                builtin_obj.log("cu emil log file:%s not pack" % result_ret)
                time.sleep(5)
        comm_obj.execute_cmd_on_pc("mkdir %s/emil_log_cu" % emil_log_dir_cu)
        comm_obj.execute_cmd_on_pc("cp -r /home/sharedvolume/trace_results/%s/* %s/emil_log_cu" % (trace_id,
                                                                                                   emil_log_dir_cu))

    def delete_bts_from_dcap_aic_cu(self, bts_id=None):
        self._setup_dcap_gnb1_cu()
        self.dcap_base_aic_instant_1._delete_bts_dcap_cu(bts_id)


class dcap_aic_gnb1_du(object):
    def __init__(self):
        alias = "gnb1_du"
        self.dcap_base_aic_instant_2 = dcap_base_aic(alias)

    def _setup_dcap_gnb1_du(self):
        # self.dcap_base_aic_instant_2.alias_du = "gnb1_du_dcap"
        self.dcap_base_aic_instant_2.host_du = builtin_obj.get_variable_value("${VDU_IP}")
        self.dcap_base_aic_instant_2.dcap_host_ip = builtin_obj.get_variable_value("${testline_ip}")

    def start_capture_emil_log_aic_du(self):
        self._setup_dcap_gnb1_du()
        self.dcap_base_aic_instant_2._create_aic_du()
        self.dcap_base_aic_instant_2._get_dcap_all_bts_info_du()
        self.dcap_base_aic_instant_2._check_precondition_dcap_du()
        start_trace_du_ret = self.dcap_base_aic_instant_2._start_trace_dcap_du()
        return int(start_trace_du_ret["tracer_id"])

    def stop_capture_emil_log_aic_du(self, trace_id, emil_log_dir_du):
        self._setup_dcap_gnb1_du()
        self.dcap_base_aic_instant_2._stop_trace_dcap_du(trace_id)
        # sleep for log file package
        time_end = time.time() + 30
        while True:
            result_ret = comm_obj.execute_cmd_on_pc("ls /home/sharedvolume/trace_results/%s" % trace_id)
            if (result_ret.count("results.zip") and result_ret.count("results") == 1) or time.time() > time_end:
                if result_ret.count("results.zip"):
                    builtin_obj.log("du emil log file:%s packed" % result_ret)
                break
            else:
                builtin_obj.log("du emil log file:%s not pack" % result_ret)
                time.sleep(5)
        comm_obj.execute_cmd_on_pc("mkdir %s/emil_log_du" % emil_log_dir_du)
        comm_obj.execute_cmd_on_pc("cp -r /home/sharedvolume/trace_results/%s/* %s/emil_log_du" % (trace_id,
                                                                                                   emil_log_dir_du))

    def delete_bts_from_dcap_aic_du(self, bts_id=None):
        self._setup_dcap_gnb1_du()
        self.dcap_base_aic_instant_2._delete_bts_dcap_du(bts_id)


class dcap_aic_gnb1_du2(object):
    def __init__(self):
        alias = "gnb1_du2"
        self.dcap_base_aic_instant_3 = dcap_base_aic(alias)

    def _setup_dcap_gnb1_du2(self):
        # self.dcap_base_aic_instant_3.alias_du = "gnb1_du2_dcap"
        self.dcap_base_aic_instant_3.host_du = builtin_obj.get_variable_value("${VDU2_IP}")
        self.dcap_base_aic_instant_3.dcap_host_ip = builtin_obj.get_variable_value("${testline_ip}")

    def start_capture_emil_log_aic_du2(self):
        self._setup_dcap_gnb1_du2()
        self.dcap_base_aic_instant_3._create_aic_du()
        self.dcap_base_aic_instant_3._get_dcap_all_bts_info_du()
        self.dcap_base_aic_instant_3._check_precondition_dcap_du()
        start_trace_du2_ret = self.dcap_base_aic_instant_3._start_trace_dcap_du()
        return int(start_trace_du2_ret["tracer_id"])

    def stop_capture_emil_log_aic_du2(self, trace_id, emil_log_dir_du2):
        self._setup_dcap_gnb1_du2()
        self.dcap_base_aic_instant_3._stop_trace_dcap_du(trace_id)
        # sleep for log file package
        time_end = time.time() + 30
        while True:
            result_ret = comm_obj.execute_cmd_on_pc("ls /home/sharedvolume/trace_results/%s" % trace_id)
            if (result_ret.count("results.zip") and result_ret.count("results") == 1) or time.time() > time_end:
                if result_ret.count("results.zip"):
                    builtin_obj.log("du2 emil log file:%s packed" % result_ret)
                break
            else:
                builtin_obj.log("du2 emil log file:%s not pack" % result_ret)
                time.sleep(5)
        comm_obj.execute_cmd_on_pc("mkdir %s/emil_log_du2" % emil_log_dir_du2)
        comm_obj.execute_cmd_on_pc("cp -r /home/sharedvolume/trace_results/%s/* %s/emil_log_du2" % (trace_id,
                                                                                                    emil_log_dir_du2))

    def delete_bts_from_dcap_aic_du2(self, bts_id=None):
        self._setup_dcap_gnb1_du2()
        self.dcap_base_aic_instant_3._delete_bts_dcap_du(bts_id)


class dcap_aic_gnb1_du3(object):
    def __init__(self):
        alias = "gnb1_du3"
        self.dcap_base_aic_instant_4 = dcap_base_aic(alias)

    def _setup_dcap_gnb1_du3(self):
        # self.dcap_base_aic_instant_4.alias_du = "gnb1_du3_dcap"
        self.dcap_base_aic_instant_4.host_du = builtin_obj.get_variable_value("${VDU3_IP}")
        self.dcap_base_aic_instant_4.dcap_host_ip = builtin_obj.get_variable_value("${testline_ip}")

    def start_capture_emil_log_aic_du3(self):
        self._setup_dcap_gnb1_du3()
        self.dcap_base_aic_instant_4._create_aic_du()
        self.dcap_base_aic_instant_4._get_dcap_all_bts_info_du()
        self.dcap_base_aic_instant_4._check_precondition_dcap_du()
        start_trace_du3_ret = self.dcap_base_aic_instant_4._start_trace_dcap_du()
        return int(start_trace_du3_ret["tracer_id"])

    def stop_capture_emil_log_aic_du3(self, trace_id, emil_log_dir_du3):
        self._setup_dcap_gnb1_du3()
        self.dcap_base_aic_instant_4._stop_trace_dcap_du(trace_id)
        # sleep for log file package
        time_end = time.time() + 30
        while True:
            result_ret = comm_obj.execute_cmd_on_pc("ls /home/sharedvolume/trace_results/%s" % trace_id)
            if (result_ret.count("results.zip") and result_ret.count("results") == 1) or time.time() > time_end:
                if result_ret.count("results.zip"):
                    builtin_obj.log("du3 emil log file:%s packed" % result_ret)
                break
            else:
                builtin_obj.log("du3 emil log file:%s not pack" % result_ret)
                time.sleep(5)
        comm_obj.execute_cmd_on_pc("mkdir %s/emil_log_du3" % emil_log_dir_du3)
        comm_obj.execute_cmd_on_pc("cp -r /home/sharedvolume/trace_results/%s/* %s/emil_log_du3" % (trace_id,
                                                                                                    emil_log_dir_du3))

    def delete_bts_from_dcap_aic_du3(self, bts_id=None):
        self._setup_dcap_gnb1_du3()
        self.dcap_base_aic_instant_4._delete_bts_dcap_du(bts_id)


class dcap_aic_gnb1_du4(object):
    def __init__(self):
        alias = "gnb1_du4"
        self.dcap_base_aic_instant_5 = dcap_base_aic(alias)

    def _setup_dcap_gnb1_du4(self):
        # self.dcap_base_aic_instant_5.alias_du = "gnb1_du4_dcap"
        self.dcap_base_aic_instant_5.host_du = builtin_obj.get_variable_value("${VDU4_IP}")
        self.dcap_base_aic_instant_5.dcap_host_ip = builtin_obj.get_variable_value("${testline_ip}")

    def start_capture_emil_log_aic_du4(self):
        self._setup_dcap_gnb1_du4()
        self.dcap_base_aic_instant_5._create_aic_du()
        self.dcap_base_aic_instant_5._get_dcap_all_bts_info_du()
        self.dcap_base_aic_instant_5._check_precondition_dcap_du()
        start_trace_du4_ret = self.dcap_base_aic_instant_5._start_trace_dcap_du()
        return int(start_trace_du4_ret["tracer_id"])

    def stop_capture_emil_log_aic_du4(self, trace_id, emil_log_dir_du4):
        self._setup_dcap_gnb1_du4()
        self.dcap_base_aic_instant_5._stop_trace_dcap_du(trace_id)
        # sleep for log file package
        time_end = time.time() + 30
        while True:
            result_ret = comm_obj.execute_cmd_on_pc("ls /home/sharedvolume/trace_results/%s" % trace_id)
            if (result_ret.count("results.zip") and result_ret.count("results") == 1) or time.time() > time_end:
                if result_ret.count("results.zip"):
                    builtin_obj.log("du4 emil log file:%s packed" % result_ret)
                break
            else:
                builtin_obj.log("du4 emil log file:%s not pack" % result_ret)
                time.sleep(5)
        comm_obj.execute_cmd_on_pc("mkdir %s/emil_log_du4" % emil_log_dir_du4)
        comm_obj.execute_cmd_on_pc("cp -r /home/sharedvolume/trace_results/%s/* %s/emil_log_du4" % (trace_id,
                                                                                                    emil_log_dir_du4))

    def delete_bts_from_dcap_aic_du4(self, bts_id=None):
        self._setup_dcap_gnb1_du4()
        self.dcap_base_aic_instant_5._delete_bts_dcap_du(bts_id)


class dcap_aic_gnb2_cu(object):
    def __init__(self):
        alias = "gnb2"
        self.dcap_base_aic_instant_cu2 = dcap_base_aic(alias)

    def _setup_dcap_gnb2_cu(self):
        # self.dcap_base_aic_instant_cu2.alias_cu = "gnb2_cu_dcap"
        self.dcap_base_aic_instant_cu2.host_cu = builtin_obj.get_variable_value("${VCU2_IP}")
        self.dcap_base_aic_instant_cu2.dcap_host_ip = builtin_obj.get_variable_value("${testline_ip}")

    def start_capture_emil_log_aic_cu2(self):
        self._setup_dcap_gnb2_cu()
        self.dcap_base_aic_instant_cu2._create_aic_cu()
        self.dcap_base_aic_instant_cu2._get_dcap_all_bts_info_cu()
        self.dcap_base_aic_instant_cu2._check_precondition_dcap_cu()
        start_trace_cu_ret = self.dcap_base_aic_instant_cu2._start_trace_dcap_cu()
        return int(start_trace_cu_ret["tracer_id"])

    def stop_capture_emil_log_aic_cu2(self, trace_id, emil_log_dir_cu2):
        self._setup_dcap_gnb2_cu()
        self.dcap_base_aic_instant_cu2._stop_trace_dcap_cu(trace_id)
        # sleep for log file package
        time_end = time.time() + 30
        while True:
            result_ret = comm_obj.execute_cmd_on_pc("ls /home/sharedvolume/trace_results/%s" % trace_id)
            if (result_ret.count("results.zip") and result_ret.count("results") == 1) or time.time() > time_end:
                if result_ret.count("results.zip"):
                    builtin_obj.log("cu2 emil log file:%s packed" % result_ret)
                break
            else:
                builtin_obj.log("cu2 emil log file:%s not pack" % result_ret)
                time.sleep(5)
        comm_obj.execute_cmd_on_pc("mkdir %s/emil_log_cu2" % emil_log_dir_cu2)
        comm_obj.execute_cmd_on_pc("cp -r /home/sharedvolume/trace_results/%s/* %s/emil_log_cu2" % (trace_id,
                                                                                                    emil_log_dir_cu2))

    def delete_bts_from_dcap_aic_cu2(self, bts_id=None):
        self._setup_dcap_gnb2_cu()
        self.dcap_base_aic_instant_cu2._delete_bts_dcap_cu(bts_id)


class dcap_aic(dcap_aic_gnb1_cu, dcap_aic_gnb1_du, dcap_aic_gnb1_du2, dcap_aic_gnb1_du3, dcap_aic_gnb1_du4,
               dcap_aic_gnb2_cu, install_dcap_aic):
    def __init__(self):
        dcap_aic_gnb1_cu.__init__(self)
        dcap_aic_gnb1_du.__init__(self)
        dcap_aic_gnb1_du2.__init__(self)
        dcap_aic_gnb1_du3.__init__(self)
        dcap_aic_gnb1_du4.__init__(self)
        dcap_aic_gnb2_cu.__init__(self)
        install_dcap_aic.__init__(self)


if __name__ == "__main__":
    obj = dcap_aic()
    help(obj)
