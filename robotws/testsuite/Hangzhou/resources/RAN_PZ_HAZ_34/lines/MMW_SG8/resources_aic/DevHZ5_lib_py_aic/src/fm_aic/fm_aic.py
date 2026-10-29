# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

import time
import re
from robot.libraries.OperatingSystem import OperatingSystem
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import Vdu
from ..common_lib_aic import common_lib_aic
from robot.libraries.BuiltIn import BuiltIn
from ..base_lib.ta_ssh_telnet import ta_ssh_telnet
from robot.utils.robottime import timestr_to_secs
import traceback

comm_obj = common_lib_aic()
os_obj = OperatingSystem()
builtin_obj = BuiltIn()
ssh_obj = ta_ssh_telnet()


class aic_fm_base(object):
    def __init__(self, alias):
        self._setup_fm_cu_flag = False
        self._setup_fm_du_flag = False
        # self._setup_fm_du2_flag = False
        self.alias = alias
        self.alias_cu = self.alias + "_cu"
        self.alias_du = self.alias + "_du"
        # self.alias_du2 = self.alias + "_du2"
        # self.bts_host = "192.168.255.129"
        self.du_host = None
        self.remote_host = None

    def _setup_fm_cu(self):
        """setup cu admin"""
        self.cu_host = builtin_obj.get_variable_value("${VCU_IP}")
        if not self._setup_fm_cu_flag:
            self._setup_fm_cu_flag = True
            self.cu_obj = cu()
            bts_port, use_ssl = comm_obj.define_admin_port()
            builtin_obj.log("remote_host is %s" % self.remote_host)
            cu_ping_ok = self._ping_ok(self.cu_host)
            if comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu):
                return
            if cu_ping_ok:
                self.cu_obj.connect_to(alias=self.alias_cu, port=bts_port, secure=use_ssl,
                                       host=self.cu_host, username="Nemuadmin", password="nemuuser")
            else:
                self.cu_obj.connect_to(alias=self.alias_cu, port=bts_port, secure=use_ssl,
                                       host="192.168.100.129", username="Nemuadmin", password="nemuuser")
        if self._setup_fm_cu_flag:
            if not comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu):
                self.cu_obj = cu()
                bts_port, use_ssl = comm_obj.define_admin_port()
                builtin_obj.log("remote_host is %s" % self.remote_host)
                cu_ping_ok = self._ping_ok(self.cu_host)
                if cu_ping_ok:
                    self.cu_obj.connect_to(alias=self.alias_cu, port=bts_port, secure=use_ssl,
                                           host=self.cu_host, username="Nemuadmin", password="nemuuser")
                else:
                    self.cu_obj.connect_to(alias=self.alias_cu, port=bts_port, secure=use_ssl,
                                           host="192.168.100.129", username="Nemuadmin", password="nemuuser")

    def _setup_fm_du(self):
        """setup du admin, could be du/du2"""
        if not self._setup_fm_du_flag:
            self._setup_fm_du_flag = True
            self.du_obj = Vdu()
            bts_port, use_ssl = comm_obj.define_admin_port()
            builtin_obj.log("remote_host is %s" % self.remote_host)
            du_ping_ok = self._ping_ok(self.du_host)
            if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du):
                return
            if du_ping_ok:
                self.du_obj.connect_to(host=self.du_host, port=bts_port, username="Nemuadmin", password="nemuuser",
                                       secure=use_ssl, connection_name=self.alias_du)
            else:
                raise Exception("du:%s ping is NOK" % self.du_host)
        if self._setup_fm_du_flag:
            if not comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du):
                self.du_obj = Vdu()
                bts_port, use_ssl = comm_obj.define_admin_port()
                builtin_obj.log("remote_host is %s" % self.remote_host)
                du_ping_ok = self._ping_ok(self.du_host)
                if du_ping_ok:
                    self.du_obj.connect_to(host=self.du_host, port=bts_port, username="Nemuadmin",
                                           password="nemuuser", secure=use_ssl, connection_name=self.alias_du)
                else:
                    raise Exception("du:%s ping is NOK" % self.du_host)

    def __enter__(self):
        builtin_obj.log("xk_enter")
        pass

    def __exit__(self, exc_type, exc_val, exc_tb):
        builtin_obj.log("xk_exit")
        # cu
        try:
            if comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu):
                self.cu_obj.disconnect(connection=self.alias_cu)
        except Exception:
            detail = traceback.format_exc()
            if "Session expire" in str(detail) or "Token expire" in str(detail):
                self.cu_obj.store.remove(alias=self.alias_cu)
            elif "object has no attribute 'cu_obj'" in str(detail):
                pass
            else:
                builtin_obj.log(detail)
        # du
        try:
            if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du):
                self.du_obj.disconnect(vdu_connection=self.alias_du)
        except Exception:
            detail = traceback.format_exc()
            if "Session expire" in str(detail) or "Token expire" in str(detail):
                self.du_obj.store.remove(alias=self.alias_du)
            elif "object has no attribute 'du_obj'" in str(detail):
                pass
            else:
                builtin_obj.log(detail)

    def __del__(self):
        try:
            if self._setup_fm_cu_flag:
                self.cu_obj.disconnect(self.alias_cu)
            if self._setup_fm_du_flag:
                self.du_obj.disconnect(self.alias_du)
        except Exception:
            pass

    def _ping_ok(self, ip):
        out = comm_obj.execute_cmd_on_pc("ping %s -c 2" % ip)
        if out.count("100% packet loss"):
            return False
        else:
            return True

    def _admin_active_fault_exit_or_not_cu(self, conds):
        """
        exp_fault: severity, alarm_id, alarm_name, fault_id,fault_name, alarming_object
        """
        conds = comm_obj.remove_empty_from_list(conds)
        exp_fault = {}
        for cond in conds:
            exp_fault[cond.split("=")[0].strip().lower().replace(" ", "_")] = cond.split("=")[1].strip()
        supported_keys = ["severity", "alarm_id", "alarm_name", "fault_id", "fault_name", "alarming_object"]
        for key in exp_fault.keys():
            if supported_keys.count(key) == 0:
                raise Exception("condition %s is not supported" % key)

        find_flag = False
        if "severity" in exp_fault and exp_fault['severity'].lower() == 'transient':
            builtin_obj.log("transient alarm should search history fault", console=True)
            find_flag = self._admin_history_fault_exit_or_not_cu(conds)
            return find_flag

        builtin_obj.log("expect alarm is:%s" % exp_fault)
        self._setup_fm_cu()
        all_active_alarms_dict = self.cu_obj.get_active_alarms(connection=self.alias_cu)
        builtin_obj.log("get active alarms: %s" % all_active_alarms_dict)
        all_active_alarms = all_active_alarms_dict["alarms"]
        act_alarm_list = []
        for fault_index in range(len(all_active_alarms)):
            fault = {}
            for key in all_active_alarms[fault_index].keys():
                if key.count("severity") != 0:
                    fault["severity"] = str(all_active_alarms[fault_index]["severity"]).strip()
                if key.count("alarm_id") != 0:
                    fault["alarm_id"] = str(all_active_alarms[fault_index]["alarm_id"]).strip()
                if key.count("alarm_name") != 0:
                    fault["alarm_name"] = str(all_active_alarms[fault_index]["alarm_name"]).strip()
                if key.count("fault_id") != 0:
                    fault["fault_id"] = str(all_active_alarms[fault_index]["fault_id"]).strip()
                if key.count("fault_name") != 0:
                    fault["fault_name"] = str(all_active_alarms[fault_index]["fault_name"]).strip()
                if key.count("alarming_object") != 0:
                    fault["alarming_object"] = str(all_active_alarms[fault_index]["alarming_object"]).strip()
            act_alarm_list.append(fault)

        builtin_obj.log("actual alarm list is:%s" % act_alarm_list)

        for each_act_fault in act_alarm_list:
            find_flag = True
            check_keys = list(exp_fault.keys())

            # "alarming_object" is possible empty, so need check by match condition.
            if "alarming_object" in exp_fault:
                check_keys.remove("alarming_object")
                match = re.search(r"%s" % exp_fault["alarming_object"], each_act_fault["alarming_object"], re.I)
                if match is None:
                    find_flag = False
                    continue

            for key in check_keys:
                if str(exp_fault[key]).lower().strip() != str(each_act_fault[key]).lower().strip():
                    find_flag = False
                    builtin_obj.log("expect fault is:%s:%s" % (key, exp_fault[key]))
                    builtin_obj.log("actual fault is:%s:%s" % (key, each_act_fault[key]))
                    break
            if find_flag is True:
                builtin_obj.log("expect fault is:%s" % exp_fault)
                builtin_obj.log("actual fault is:%s" % each_act_fault)
                break
        return find_flag

    def _admin_history_fault_exit_or_not_cu(self, conds):
        """
        exp_fault: severity, alarm_id, alarm_name, fault_id,fault_name, alarming_object
        """
        conds = comm_obj.remove_empty_from_list(conds)
        exp_fault = {}
        for cond in conds:
            exp_fault[cond.split("=")[0].strip().lower().replace(" ", "_")] = cond.split("=")[1].strip()
        supported_keys = ["severity", "alarm_id", "alarm_name", "fault_id", "fault_name", "alarming_object"]
        for key in exp_fault.keys():
            if supported_keys.count(key) == 0:
                raise Exception("condition %s is not supported" % key)

        find_flag = False
        builtin_obj.log("expect alarm is:%s" % exp_fault)
        self._setup_fm_cu()
        all_history_alarms_dict = self.cu_obj.get_historical_alarms(connection=self.alias_cu)
        builtin_obj.log("get history alarms: %s" % all_history_alarms_dict)
        all_history_alarms = all_history_alarms_dict["alarms"]
        his_alarm_list = []
        for fault_index in range(len(all_history_alarms)):
            fault = {}
            for key in all_history_alarms[fault_index].keys():
                if key.count("alarm_id") != 0:
                    fault["alarm_id"] = str(all_history_alarms[fault_index]["alarm_id"]).strip()
                if key.count("alarm_name") != 0:
                    fault["alarm_name"] = str(all_history_alarms[fault_index]["alarm_name"]).strip()
                if key.count("fault_id") != 0:
                    fault["fault_id"] = str(all_history_alarms[fault_index]["fault_id"]).strip()
                if key.count("fault_name") != 0:
                    fault["fault_name"] = str(all_history_alarms[fault_index]["fault_name"]).strip()
                if key.count("alarming_object") != 0:
                    fault["alarming_object"] = str(all_history_alarms[fault_index]["alarming_object"]).strip()
            his_alarm_list.append(fault)

        builtin_obj.log("history alarm list is:%s" % his_alarm_list)

        for each_his_fault in his_alarm_list:
            find_flag = True
            check_keys = list(exp_fault.keys())

            # need double confirm if need remove "severity" in alarm history.
            if "severity" in exp_fault:
                check_keys.remove("severity")

            # "alarming_object" is possible empty, so need check by match condition.
            if "alarming_object" in exp_fault:
                check_keys.remove("alarming_object")
                match = re.search(r"%s" % exp_fault["alarming_object"], each_his_fault["alarming_object"], re.I)
                if match is None:
                    find_flag = False
                    continue

            for key in check_keys:
                if str(exp_fault[key]).lower().strip() != str(each_his_fault[key]).lower().strip():
                    find_flag = False
                    builtin_obj.log("expect fault is:%s:%s" % (key, exp_fault[key]))
                    builtin_obj.log("actual fault is:%s:%s" % (key, each_his_fault[key]))
                    break
            if find_flag is True:
                builtin_obj.log("expect fault is:%s" % exp_fault)
                builtin_obj.log("actual fault is:%s" % each_his_fault)
                break
        return find_flag

    def _fm_fault_should_be_raised_cu(self, conditions, timeout):
        retry_times = int(timeout) / 10
        result = False
        while retry_times >= 0:
            result = self._admin_active_fault_exit_or_not_cu(conditions)
            if result is False:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is False:
            raise Exception("The expected fault doesn't exist")

    def _fm_fault_should_be_cleared_cu(self, conditions, timeout):
        retry_times = int(timeout) / 10
        result = False
        while retry_times >= 0:
            result = self._admin_active_fault_exit_or_not_cu(conditions)
            if result is True:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is True:
            raise Exception("The active fault should not exist")

    def _admin_active_fault_exit_or_not_du(self, conds):
        """
        exp_fault: severity, alarm_id, alarm_name, fault_id,fault_name, alarming_object
        """
        conds = comm_obj.remove_empty_from_list(conds)
        exp_fault = {}
        for cond in conds:
            exp_fault[cond.split("=")[0].strip().lower().replace(" ", "_")] = cond.split("=")[1].strip()
        supported_keys = ["severity", "alarm_id", "alarm_name", "fault_id", "fault_name", "alarming_object"]
        for key in exp_fault.keys():
            if supported_keys.count(key) == 0:
                raise Exception("condition %s is not supported" % key)

        find_flag = False
        if "severity" in exp_fault and exp_fault['severity'].lower() == 'transient':
            builtin_obj.log("transient alarm should search history fault", console=True)
            find_flag = self._admin_history_fault_exit_or_not_du(conds)
            return find_flag

        builtin_obj.log("expect alarm is:%s" % exp_fault)
        self._setup_fm_du()
        all_active_alarms_dict = self.du_obj.vdu_get_active_alarms(vdu_connection=self.alias_du)
        builtin_obj.log("get active alarms: %s" % all_active_alarms_dict)
        all_active_alarms = all_active_alarms_dict["alarms"]
        act_alarm_list = []
        for fault_index in range(len(all_active_alarms)):
            fault = {}
            for key in all_active_alarms[fault_index].keys():
                if key.count("severity") != 0:
                    fault["severity"] = str(all_active_alarms[fault_index]["severity"]).strip()
                if key.count("alarm_id") != 0:
                    fault["alarm_id"] = str(all_active_alarms[fault_index]["alarm_id"]).strip()
                if key.count("alarm_name") != 0:
                    fault["alarm_name"] = str(all_active_alarms[fault_index]["alarm_name"]).strip()
                if key.count("fault_id") != 0:
                    fault["fault_id"] = str(all_active_alarms[fault_index]["fault_id"]).strip()
                if key.count("fault_name") != 0:
                    fault["fault_name"] = str(all_active_alarms[fault_index]["fault_name"]).strip()
                if key.count("alarming_object") != 0:
                    fault["alarming_object"] = str(all_active_alarms[fault_index]["alarming_object"]).strip()
            act_alarm_list.append(fault)

        builtin_obj.log("actual alarm list is:%s" % act_alarm_list)

        for each_act_fault in act_alarm_list:
            find_flag = True
            check_keys = list(exp_fault.keys())

            if "alarming_object" in exp_fault:
                check_keys.remove("alarming_object")
                match = re.search(r"%s" % exp_fault["alarming_object"], each_act_fault["alarming_object"], re.I)
                if match is None:
                    find_flag = False
                    continue

            for key in check_keys:
                if str(exp_fault[key]).lower().strip() != str(each_act_fault[key]).lower().strip():
                    find_flag = False
                    builtin_obj.log("expect fault is:%s:%s" % (key, exp_fault[key]))
                    builtin_obj.log("actual fault is:%s:%s" % (key, each_act_fault[key]))
                    break
            if find_flag is True:
                builtin_obj.log("expect fault is:%s" % exp_fault)
                builtin_obj.log("actual fault is:%s" % each_act_fault)
                break
        return find_flag

    def _admin_history_fault_exit_or_not_du(self, conds):
        """
        exp_fault: severity, alarm_id, alarm_name, fault_id,fault_name, alarming_object
        """
        conds = comm_obj.remove_empty_from_list(conds)
        exp_fault = {}
        for cond in conds:
            exp_fault[cond.split("=")[0].strip().lower().replace(" ", "_")] = cond.split("=")[1].strip()
        supported_keys = ["severity", "alarm_id", "alarm_name", "fault_id", "fault_name", "alarming_object"]
        for key in exp_fault.keys():
            if supported_keys.count(key) == 0:
                raise Exception("condition %s is not supported" % key)

        find_flag = False

        builtin_obj.log("expect alarm is:%s" % exp_fault)
        self._setup_fm_du()
        all_history_alarms_dict = self.du_obj.vdu_get_historical_alarms(vdu_connection=self.alias_du)
        builtin_obj.log("get active alarms: %s" % all_history_alarms_dict)
        all_history_alarms = all_history_alarms_dict["alarms"]
        his_alarm_list = []
        for fault_index in range(len(all_history_alarms)):
            fault = {}
            for key in all_history_alarms[fault_index].keys():
                if key.count("alarm_id") != 0:
                    fault["alarm_id"] = str(all_history_alarms[fault_index]["alarm_id"]).strip()
                if key.count("alarm_name") != 0:
                    fault["alarm_name"] = str(all_history_alarms[fault_index]["alarm_name"]).strip()
                if key.count("fault_id") != 0:
                    fault["fault_id"] = str(all_history_alarms[fault_index]["fault_id"]).strip()
                if key.count("fault_name") != 0:
                    fault["fault_name"] = str(all_history_alarms[fault_index]["fault_name"]).strip()
                if key.count("alarming_object") != 0:
                    fault["alarming_object"] = str(all_history_alarms[fault_index]["alarming_object"]).strip()
            his_alarm_list.append(fault)

        builtin_obj.log("history alarm list is:%s" % his_alarm_list)

        for each_his_fault in his_alarm_list:
            find_flag = True
            check_keys = list(exp_fault.keys())

            if "severity" in exp_fault:
                check_keys.remove("severity")

            if "alarming_object" in exp_fault:
                check_keys.remove("alarming_object")
                match = re.search(r"%s" % exp_fault["alarming_object"], each_his_fault["alarming_object"], re.I)
                if match is None:
                    find_flag = False
                    continue

            for key in check_keys:
                if str(exp_fault[key]).lower().strip() != str(each_his_fault[key]).lower().strip():
                    find_flag = False
                    builtin_obj.log("expect fault is:%s:%s" % (key, exp_fault[key]))
                    builtin_obj.log("actual fault is:%s:%s" % (key, each_his_fault[key]))
                    break
            if find_flag is True:
                builtin_obj.log("expect fault is:%s" % exp_fault)
                builtin_obj.log("actual fault is:%s" % each_his_fault)
                break
        return find_flag

    def _fm_fault_should_be_raised_du(self, conditions, timeout):
        retry_times = int(timeout) / 10
        result = False
        while retry_times >= 0:
            result = self._admin_active_fault_exit_or_not_du(conditions)
            if result is False:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is False:
            raise Exception("The expected fault doesn't exist")

    def _fm_fault_should_be_cleared_du(self, conditions, timeout):
        retry_times = int(timeout) / 10
        result = False
        while retry_times >= 0:
            result = self._admin_active_fault_exit_or_not_du(conditions)
            if result is True:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is True:
            raise Exception("The active fault should not exist")

    def _get_current_active_faultid_cu(self):
        self._setup_fm_cu()
        all_active_alarms_dict = self.cu_obj.get_active_alarms(connection=self.alias_cu)
        builtin_obj.log("get active alarms: %s" % all_active_alarms_dict)
        all_active_alarms = all_active_alarms_dict["alarms"]
        act_alarm_list = []
        for fault_index in range(len(all_active_alarms)):
            fault = {}
            alarm_keys = ["fault_id"]
            for key in all_active_alarms[fault_index].keys():
                if alarm_keys.count("fault_id") != 0:
                    fault["fault_id"] = str(all_active_alarms[fault_index]["fault_id"]).strip()
            act_alarm_list.append(fault)

        self._stop_admin_cu()
        builtin_obj.log("actual faultId list is:%s" % act_alarm_list)
        return act_alarm_list

    def _get_current_active_faultid_du(self):
        self._setup_fm_du()
        all_active_alarms_dict = self.du_obj.vdu_get_active_alarms(vdu_connection=self.alias_du)
        builtin_obj.log("get active alarms: %s" % all_active_alarms_dict)
        all_active_alarms = all_active_alarms_dict["alarms"]
        act_alarm_list = []
        for fault_index in range(len(all_active_alarms)):
            fault = {}
            alarm_keys = ["fault_id"]
            for key in all_active_alarms[fault_index].keys():
                if alarm_keys.count("fault_id") != 0:
                    fault["fault_id"] = str(all_active_alarms[fault_index]["fault_id"]).strip()
            act_alarm_list.append(fault)

        self._stop_admin_du()
        builtin_obj.log("actual faultId list is:%s" % act_alarm_list)
        return act_alarm_list

    def _check_no_new_active_faultid_exist_cu(self, initial_act_alarm_list, faults_excluded_checking):
        """
        Arguments: Owner:TA Group
        | initial_act_alarm_list | : | [{'fault_id': '61649'}, {'fault_id': '4655'}, {'fault_id': '61524'}] |
        | faults_excluded_checking | : | [61649, 4655 ,61524] |
        Documentation:
        Example:
        """
        current_act_alarm_all, new_active_fault_id = "", ""
        current_act_alarm_list = self._get_current_active_faultid_cu()
        for current_act_alarm in current_act_alarm_list:
            fault_id = str(current_act_alarm).split("'fault_id': '")[1].replace("'}", "")
            if fault_id in faults_excluded_checking:
                builtin_obj.log("fault [%s] excluded checking in active fault_id [%s]"
                                % (faults_excluded_checking, fault_id))
                continue

            if current_act_alarm in initial_act_alarm_list:
                current_act_alarm_all = current_act_alarm_all + \
                                        str(current_act_alarm).replace("{'fault_id': '", "").replace("'}", ", ")
            else:
                new_active_fault_id = new_active_fault_id + \
                                      str(current_act_alarm).replace("{'fault_id': '", "").replace("'}", ", ")

        if current_act_alarm_all != "":
            builtin_obj.log("initial fault_id: %s, current fault_id: [%s]"
                            % (str(initial_act_alarm_list).replace("{'fault_id': '", "")
                               .replace("'},", ",").replace("'}", ""), current_act_alarm_all.rsplit(", ", 1)[0]))
        if new_active_fault_id != "":
            raise Exception("Have new fault now, initial fault_id: %s, new active fault_id: [%s]"
                            % (str(initial_act_alarm_list).replace("{'fault_id': '", "")
                               .replace("'},", ",").replace("'}", ""), new_active_fault_id.rsplit(", ", 1)[0]))

    def _check_no_new_active_faultid_exist_du(self, initial_act_alarm_list, faults_excluded_checking):
        """
        Arguments: Owner:TA Group
        | initial_act_alarm_list | : | [{'fault_id': '61649'}, {'fault_id': '4655'}, {'fault_id': '61524'}] |
        | faults_excluded_checking | : | [61649, 4655 ,61524] |
        Documentation:
        Example:
        """
        current_act_alarm_all, new_active_fault_id = "", ""
        current_act_alarm_list = self._get_current_active_faultid_du()
        for current_act_alarm in current_act_alarm_list:
            fault_id = str(current_act_alarm).split("'fault_id': '")[1].replace("'}", "")
            if fault_id in faults_excluded_checking:
                builtin_obj.log("fault [%s] excluded checking in active fault_id [%s]"
                                % (faults_excluded_checking, fault_id))
                continue

            if current_act_alarm in initial_act_alarm_list:
                current_act_alarm_all = current_act_alarm_all + \
                                        str(current_act_alarm).replace("{'fault_id': '", "").replace("'}", ", ")
            else:
                new_active_fault_id = new_active_fault_id + \
                                      str(current_act_alarm).replace("{'fault_id': '", "").replace("'}", ", ")

        if current_act_alarm_all != "":
            builtin_obj.log("initial fault_id: %s, current fault_id: [%s]"
                            % (str(initial_act_alarm_list).replace("{'fault_id': '", "")
                               .replace("'},", ",").replace("'}", ""), current_act_alarm_all.rsplit(", ", 1)[0]))
        if new_active_fault_id != "":
            raise Exception("Have new fault now, initial fault_id: %s, new active fault_id: [%s]"
                            % (str(initial_act_alarm_list).replace("{'fault_id': '", "")
                               .replace("'},", ",").replace("'}", ""), new_active_fault_id.rsplit(", ", 1)[0]))

    def _stop_admin_cu(self):
        try:
            if comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu):
                self.cu_obj.disconnect(connection=self.alias_cu)
        except Exception:
            pass

    def _stop_admin_du(self):
        try:
            if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du):
                self.du_obj.disconnect(vdu_connection=self.alias_du)
        except Exception:
            pass


class aic_fm_gnb1_cu(object):
    def __init__(self):
        alias = "fm_gnb1_vcu"
        self.fm_base_instance_1 = aic_fm_base(alias)

    def fm_fault_should_be_raised_cu(self, conditions, timeout='100'):
        """This keyword is to check fault raised in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object|
        | timeout  |  No   | default is 100s |
        1. severity, alarm_id, alarm_name, fault_id,fault_name, alarming_object  are required to specify all characters
        for example:
        | ${fault6356} | create list | Severity=minor | fault_id=6356 |
        | ... | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
        | fm_fault_should_be_raised | ${fault6356} | timeout=100 |

        2. for transient fault, severity must be specifed, otherwize no fault will be found
        for example
        | ${fault6270} | create list | fault_id=6270 | severity=transient |
        | fm_fault_should_be_raised | ${fault6270} |
        """
        builtin_obj.log("check fm fault raised on gnb1", console=True)
        timeout = timestr_to_secs(timeout)
        with self.fm_base_instance_1 as f:
            self.fm_base_instance_1._fm_fault_should_be_raised_cu(conditions, timeout)

    def fm_fault_should_be_cleared_cu(self, conditions, timeout='100'):
        """This keyword is to check fault cleared in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object|
        | timeout  |  No   | default is 100s |
         Example:
        | fm_fault_should_be_cleared | fault ID=6203 |

        """
        builtin_obj.log("check fm fault cleared on gnb1", console=True)
        timeout = timestr_to_secs(timeout)
        with self.fm_base_instance_1 as f:
            self.fm_base_instance_1._fm_fault_should_be_cleared_cu(conditions, timeout)

    def get_current_active_faultid_cu(self):
        """This keyword is to get current active faultid in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        |  ${faultid_list}  | Get Current Active Faultid |
        """
        with self.fm_base_instance_1 as f:
            act_alarm_list = self.fm_base_instance_1._get_current_active_faultid_cu()
        return act_alarm_list

    def check_no_new_active_faultid_exist_cu(self, initial_act_alarm_list, faults_excluded_checking):
        """This keyword is to check no new active faultid exist in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        | Check No New Active Faultid Exist | ${initial_act_alarm_list} |
        """
        with self.fm_base_instance_1 as f:
            self.fm_base_instance_1._check_no_new_active_faultid_exist_cu(initial_act_alarm_list,
                                                                          faults_excluded_checking)


class aic_fm_gnb1_du(object):
    def __init__(self):
        alias = "fm_gnb1_vdu"
        self.fm_base_instance_2 = aic_fm_base(alias)

    def _setup_fm_gnb1_du(self):
        self.fm_base_instance_2.du_host = builtin_obj.get_variable_value("${VDU_IP}")

    def get_current_active_faultid_du(self):
        """This keyword is to get current active faultid in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        |  ${faultid_list}  | Get Current Active Faultid |
        """
        self._setup_fm_gnb1_du()
        with self.fm_base_instance_2 as f:
            act_alarm_list = self.fm_base_instance_2._get_current_active_faultid_du()
        return act_alarm_list

    def check_no_new_active_faultid_exist_du(self, initial_act_alarm_list, faults_excluded_checking):
        """This keyword is to check no new active faultid exist in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        | Check No New Active Faultid Exist | ${initial_act_alarm_list} |
        """
        self._setup_fm_gnb1_du()
        with self.fm_base_instance_2 as f:
            self.fm_base_instance_2._check_no_new_active_faultid_exist_du(initial_act_alarm_list,
                                                                          faults_excluded_checking)

    def fm_fault_should_be_raised_du(self, conditions, timeout='100'):
        """This keyword is to check fault raised in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object|
        | timeout  |  No   | default is 100s |
        1. severity, alarm_id, alarm_name, fault_id,fault_name, alarming_object  are required to specify all characters
        for example:
        | ${fault6356} | create list | Severity=minor | fault_id=6356 |
        | ... | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
        | fm_fault_should_be_raised | ${fault6356} | timeout=100 |

        2. for transient fault, severity must be specifed, otherwize no fault will be found
        for example
        | ${fault6270} | create list | fault_id=6270 | severity=transient |
        | fm_fault_should_be_raised | ${fault6270} |
        """
        builtin_obj.log("check fm fault raised on gnb1", console=True)
        timeout = timestr_to_secs(timeout)
        self._setup_fm_gnb1_du()
        with self.fm_base_instance_2 as f:
            self.fm_base_instance_2._fm_fault_should_be_raised_du(conditions, timeout)

    def fm_fault_should_be_cleared_du(self, conditions, timeout='100'):
        """This keyword is to check fault cleared in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object|
        | timeout  |  No   | default is 100s |
         Example:
        | fm_fault_should_be_cleared | fault ID=6203 |

        """
        builtin_obj.log("check fm fault cleared on gnb1", console=True)
        timeout = timestr_to_secs(timeout)
        self._setup_fm_gnb1_du()
        with self.fm_base_instance_2 as f:
            self.fm_base_instance_2._fm_fault_should_be_cleared_du(conditions, timeout)


class aic_fm_gnb1_du2(object):
    def __init__(self):
        alias = "fm_gnb1_vdu2"
        self.fm_base_instance_3 = aic_fm_base(alias)

    def _setup_fm_gnb1_du2(self):
        self.fm_base_instance_3.du_host = builtin_obj.get_variable_value("${VDU2_IP}")

    def get_current_active_faultid_du2(self):
        """This keyword is to get current active faultid in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        |  ${faultid_list}  | Get Current Active Faultid |
        """
        self._setup_fm_gnb1_du2()
        with self.fm_base_instance_3 as f:
            act_alarm_list = self.fm_base_instance_3._get_current_active_faultid_du()
        return act_alarm_list

    def check_no_new_active_faultid_exist_du2(self, initial_act_alarm_list, faults_excluded_checking):
        """This keyword is to check no new active faultid exist in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        | Check No New Active Faultid Exist | ${initial_act_alarm_list} |
        """
        self._setup_fm_gnb1_du2()
        with self.fm_base_instance_3 as f:
            self.fm_base_instance_3._check_no_new_active_faultid_exist_du(initial_act_alarm_list,
                                                                          faults_excluded_checking)

    def fm_fault_should_be_raised_du2(self, conditions, timeout='100'):
        """This keyword is to check fault raised in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object|
        | timeout  |  No   | default is 100s |
        1. severity, alarm_id, alarm_name, fault_id,fault_name, alarming_object are required to specify all characters
        for example:
        | ${fault6356} | create list | Severity=minor | fault_id=6356 |
        | ... | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
        | fm_fault_should_be_raised | ${fault6356} | timeout=100 |

        2. for transient fault, severity must be specifed, otherwize no fault will be found
        for example
        | ${fault6270} | create list | fault_id=6270 | severity=transient |
        | fm_fault_should_be_raised | ${fault6270} |
        """
        builtin_obj.log("check fm fault raised on gnb2 du2", console=True)
        timeout = timestr_to_secs(timeout)
        self._setup_fm_gnb1_du2()
        with self.fm_base_instance_3 as f:
            self.fm_base_instance_3._fm_fault_should_be_raised_du(conditions, timeout)

    def fm_fault_should_be_cleared_du2(self, conditions, timeout='100'):
        """This keyword is to check fault cleared in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object|
        | timeout  |  No   | default is 100s |
         Example:
        | fm_fault_should_be_cleared | fault ID=6203 |

        """
        builtin_obj.log("check fm fault cleared on gnb1 du2", console=True)
        timeout = timestr_to_secs(timeout)
        self._setup_fm_gnb1_du2()
        with self.fm_base_instance_3 as f:
            self.fm_base_instance_3._fm_fault_should_be_cleared_du(conditions, timeout)


class aic_fm_gnb1_du3(object):
    def __init__(self):
        alias = "fm_gnb1_vdu3"
        self.fm_base_instance_4 = aic_fm_base(alias)

    def _setup_fm_gnb1_du3(self):
        self.fm_base_instance_4.du_host = builtin_obj.get_variable_value("${VDU3_IP}")

    def get_current_active_faultid_du3(self):
        """This keyword is to get current active faultid in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        |  ${faultid_list}  | Get Current Active Faultid |
        """
        self._setup_fm_gnb1_du3()
        with self.fm_base_instance_4 as f:
            act_alarm_list = self.fm_base_instance_4._get_current_active_faultid_du()
        return act_alarm_list

    def check_no_new_active_faultid_exist_du3(self, initial_act_alarm_list, faults_excluded_checking):
        """This keyword is to check no new active faultid exist in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        | Check No New Active Faultid Exist | ${initial_act_alarm_list} |
        """
        self._setup_fm_gnb1_du3()
        with self.fm_base_instance_4 as f:
            self.fm_base_instance_4._check_no_new_active_faultid_exist_du(initial_act_alarm_list,
                                                                          faults_excluded_checking)

    def fm_fault_should_be_raised_du3(self, conditions, timeout='100'):
        """This keyword is to check fault raised in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object|
        | timeout  |  No   | default is 100s |
        1. severity, alarm_id, alarm_name, fault_id,fault_name, alarming_object are required to specify all characters
        for example:
        | ${fault6356} | create list | Severity=minor | fault_id=6356 |
        | ... | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
        | fm_fault_should_be_raised | ${fault6356} | timeout=100 |

        2. for transient fault, severity must be specifed, otherwize no fault will be found
        for example
        | ${fault6270} | create list | fault_id=6270 | severity=transient |
        | fm_fault_should_be_raised | ${fault6270} |
        """
        builtin_obj.log("check fm fault raised on gnb2 du3", console=True)
        timeout = timestr_to_secs(timeout)
        self._setup_fm_gnb1_du3()
        with self.fm_base_instance_4 as f:
            self.fm_base_instance_4._fm_fault_should_be_raised_du(conditions, timeout)

    def fm_fault_should_be_cleared_du3(self, conditions, timeout='100'):
        """This keyword is to check fault cleared in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object|
        | timeout  |  No   | default is 100s |
         Example:
        | fm_fault_should_be_cleared | fault ID=6203 |

        """
        builtin_obj.log("check fm fault cleared on gnb1 du2", console=True)
        timeout = timestr_to_secs(timeout)
        self._setup_fm_gnb1_du3()
        with self.fm_base_instance_4 as f:
            self.fm_base_instance_4._fm_fault_should_be_cleared_du(conditions, timeout)


class aic_fm_gnb1_du4(object):
    def __init__(self):
        alias = "fm_gnb1_vdu4"
        self.fm_base_instance_5 = aic_fm_base(alias)

    def _setup_fm_gnb1_du4(self):
        self.fm_base_instance_5.du_host = builtin_obj.get_variable_value("${VDU4_IP}")

    def get_current_active_faultid_du4(self):
        """This keyword is to get current active faultid in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        |  ${faultid_list}  | Get Current Active Faultid |
        """
        self._setup_fm_gnb1_du4()
        with self.fm_base_instance_5 as f:
            act_alarm_list = self.fm_base_instance_5._get_current_active_faultid_du()
        return act_alarm_list

    def check_no_new_active_faultid_exist_du4(self, initial_act_alarm_list, faults_excluded_checking):
        """This keyword is to check no new active faultid exist in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        | Check No New Active Faultid Exist | ${initial_act_alarm_list} |
        """
        self._setup_fm_gnb1_du4()
        with self.fm_base_instance_5 as f:
            self.fm_base_instance_5._check_no_new_active_faultid_exist_du(initial_act_alarm_list,
                                                                          faults_excluded_checking)

    def fm_fault_should_be_raised_du4(self, conditions, timeout='100'):
        """This keyword is to check fault raised in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object|
        | timeout  |  No   | default is 100s |
        1. severity, alarm_id, alarm_name, fault_id,fault_name, alarming_object are required to specify all characters
        for example:
        | ${fault6356} | create list | Severity=minor | fault_id=6356 |
        | ... | fault_name=Automatic access class barring is active |  alarm_id=7655| alarm_name=CELL NOTIFICATION|
        | fm_fault_should_be_raised | ${fault6356} | timeout=100 |

        2. for transient fault, severity must be specifed, otherwize no fault will be found
        for example
        | ${fault6270} | create list | fault_id=6270 | severity=transient |
        | fm_fault_should_be_raised | ${fault6270} |
        """
        builtin_obj.log("check fm fault raised on gnb2 du2", console=True)
        timeout = timestr_to_secs(timeout)
        self._setup_fm_gnb1_du4()
        with self.fm_base_instance_5 as f:
            self.fm_base_instance_5._fm_fault_should_be_raised_du(conditions, timeout)

    def fm_fault_should_be_cleared_du4(self, conditions, timeout='100'):
        """This keyword is to check fault cleared in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object|
        | timeout  |  No   | default is 100s |
         Example:
        | fm_fault_should_be_cleared | fault ID=6203 |

        """
        builtin_obj.log("check fm fault cleared on gnb1 du2", console=True)
        timeout = timestr_to_secs(timeout)
        self._setup_fm_gnb1_du4()
        with self.fm_base_instance_5 as f:
            self.fm_base_instance_5._fm_fault_should_be_cleared_du(conditions, timeout)


class aic_fm_gnb2(object):

    def __init__(self):
        alias = "gnb2"
        self.fm_base_instance_2 = aic_fm_base(alias)


class fm_aic(aic_fm_gnb1_cu, aic_fm_gnb1_du, aic_fm_gnb1_du2, aic_fm_gnb1_du3, aic_fm_gnb1_du4):
    def __init__(self):
        aic_fm_gnb1_cu.__init__(self)
        aic_fm_gnb1_du.__init__(self)
        aic_fm_gnb1_du2.__init__(self)
        aic_fm_gnb1_du3.__init__(self)
        aic_fm_gnb1_du4.__init__(self)


if __name__ == "__main__":
    fm_obj = fm_aic()
    help(fm_obj)
