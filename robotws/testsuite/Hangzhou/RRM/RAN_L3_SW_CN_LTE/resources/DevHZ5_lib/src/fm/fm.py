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
import sys
import ast
from robot.libraries.OperatingSystem import OperatingSystem
from common_lib import common_lib
from robot.libraries.BuiltIn import BuiltIn
from base_lib.ute_fsmaccess import ute_fsmaccess
from base_lib.ta_ssh_telnet import ta_ssh_telnet
from taf.sbts.oam.coam.admin import admin
from robot.utils.robottime import timestr_to_secs

comm_obj = common_lib()
os_obj = OperatingSystem()
builtin_obj = BuiltIn()
ssh_obj = ta_ssh_telnet()


class fm_base(object):
    def __init__(self, alias):
        self._setup_fm_flag = False
        self.alias = alias
        self.remote_host = None
        self.bts_host = "192.168.255.129"

    def _setup_fm(self):
        if not self._setup_fm_flag:
            self._setup_fm_flag = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#",
                                              host="192.168.255.129")
            self.admin_obj = admin()

        comm_obj.setup_admin_if_alias_not_exist(self.admin_obj, self.alias, self.bts_host, self.remote_host)

    def __del__(self):
        if self._setup_fm_flag:
            self.fsm_obj.teardown_all_aliases_for_enb_fsmaccess()

    def _remove_empty_from_list(self, list_in):
        list_out = []
        if not isinstance(list_in, list):
            list_in = [list_in]
        for value in list_in:
            is_python2 = sys.version_info.major == 2
            if is_python2:
                str_type = (unicode, bytes)
            else:
                str_type = (str, bytes)
            if isinstance(value, str_type):
                if len(value.strip()) != 0:
                    list_out.append(value.strip())
            else:
                list_out.append(value.strip())
        return list_out

    def _connect_to_netact(self):
        netact_info = builtin_obj.get_variable_value("${NETACT_SERVER_INFO}")
        netact_conn = ssh_obj.connect_to_host(
            netact_info.IP,
            "22",
            netact_info.USERNAME,
            netact_info.PASSWORD,
            conn_type="SSH")
        ssh_obj.set_shell_timeout("5min")
        return netact_conn

    def _fault_exit_or_not(self, conds, btsid):
        """
        conds: severity, fault_name, fault_id, source_dn, alarm_number, alarm_text, additional_info
        """
        case_begin_time = builtin_obj.get_variable_value('${case_begin_time_netact}')
        # convert input conds to dictionary
        conds = self._remove_empty_from_list(conds)
        builtin_obj.log("check fault with conditions:%s" % conds)
        supported_keys = ["alarm_status", "severity", "fault_name", "fault_id", "source_dn", "alarm_number",
                          "alarm_text", "additional_info"]
        exp_fault = {"alarm_status": "1"}
        for cond in conds:
            exp_fault[cond.split("=")[0].strip().lower()] = cond.split("=")[1].strip()
        for key in exp_fault.keys():
            if supported_keys.count(key) == 0:
                raise Exception("condition %s is not supported" % key)
        if "severity" in exp_fault:
            if exp_fault["severity"].lower() == "critical":
                exp_fault["severity"] = "1"
            elif exp_fault["severity"].lower() == "major":
                exp_fault["severity"] = "2"
            elif exp_fault["severity"].lower() == "minor":
                exp_fault["severity"] = "3"
            elif exp_fault["severity"].lower() == "transient":
                exp_fault["severity"] = "4"
                exp_fault["alarm_status"] = "0"
        builtin_obj.log("expected fault is %s" % exp_fault)
        # get all faults produced in case execution
        netact_conn = self._connect_to_netact()
        old_prompt = ssh_obj.set_shell_prompt("SQL>")
        old_timeout = ssh_obj.set_shell_timeout("30")
        ssh_obj.execute_shell_command("sqlplus omc/omc")
        ssh_obj.execute_shell_command("set head off")
        ssh_obj.execute_shell_command("set linesize 1000")
        ssh_obj.execute_shell_command("alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';")
        sql_cmd = "select ALARM_STATUS, SEVERITY, ALARM_TIME, SUPPLEMENTARY_INFO, DIAGNOSTIC_INFO, DN, ALARM_NUMBER, \
        TEXT from fx_alarm where DN like 'PLMN-PLMN/MRBTS-%s/LNBTS-%s" % (btsid, btsid) \
                  + "%'" + " and ALARM_TIME>'%s and DN != 'PLMN-PLMN/MRBTS-%s/LNBTS-%s/FTM-1';" \
                  % (case_begin_time, btsid, btsid)
        sql_result = ssh_obj.execute_shell_command(sql_cmd)
        ssh_obj.set_shell_timeout(old_timeout)
        ssh_obj.set_shell_prompt(old_prompt)
        ssh_obj.execute_shell_command("exit")
        ssh_obj.disconnect_from_host(netact_conn)
        # handle sqlplus result, return fault list with each item dictionary
        sql_result_list = [each_line.strip() for each_line in sql_result.strip().splitlines()
                           if len(each_line.strip()) > 0 and each_line.count("rows selected") == 0]
        act_fault_list = []
        for fault_index in range(len(sql_result_list) / 5):
            fault = {}
            fault["alarm_status"] = sql_result_list[5 * fault_index].split()[0]
            fault["severity"] = sql_result_list[5 * fault_index].split()[1]
            fault["fault_name"] = sql_result_list[5 * fault_index + 1]
            match = re.search(r"additionalFaultID\s*=\s*([0-9]+)", sql_result_list[5 * fault_index + 2], re.I)
            if match is not None:
                fault["fault_id"] = match.group(1)
            fault["additional_info"] = sql_result_list[5 * fault_index + 2]
            fault["source_dn"] = sql_result_list[5 * fault_index + 3].split()[0]
            fault["alarm_number"] = sql_result_list[5 * fault_index + 3].split()[1]
            fault["alarm_text"] = sql_result_list[5 * fault_index + 4]
            act_fault_list.append(fault)
        builtin_obj.log("all active faults are %s" % act_fault_list)
        # search expected fault in all active faults
        find_flag = False
        for each_act_fault in act_fault_list:
            find_flag = True
            check_keys = list(exp_fault.keys())
            if "source_dn" in exp_fault:
                check_keys.remove("source_dn")
                if each_act_fault["source_dn"].endswith(exp_fault["source_dn"]) is False:
                    find_flag = False
                    continue
            if "additional_info" in exp_fault:
                check_keys.remove("additional_info")
                match = re.search(r"%s" % exp_fault["additional_info"], each_act_fault["additional_info"], re.I)
                if match is None:
                    find_flag = False
                    continue
            for key in check_keys:
                if exp_fault[key] != each_act_fault[key]:
                    find_flag = False
                    break
            if find_flag is True:
                break
        return find_flag

    def _contain_sub_string(self, act_dict, exp_dict, key):
        """
        check if act_dict[key] should contain exp_dict[key]:
        1) if exp_dict[key] starts with [RE], handle it as regular expression,
        2) if no [RE], otherwise handle it as normal string
        3) if key not in exp_dict, return True
        4) if key not in act_dict, return False

        """
        if key not in exp_dict:
            return True
        if key not in act_dict:
            return False
        flag = False
        act_value = act_dict[key]
        exp_value = exp_dict[key]
        if key.lower() == "supplalarminfo":
            try:
                exp_value = ast.literal_eval(exp_value)
            except SyntaxError as e:
                pass
        if type(exp_value) is str:
            if exp_value.lower().startswith("[re]"):
                if re.search(r"%s" % exp_value[4:], act_value, re.I):
                    flag = True
            else:
                if exp_value in act_value:
                    flag = True
        elif type(exp_value) is list:
            act_value = act_value.split("\n")
            if set(exp_value) == set(act_value):
                flag = True
        return flag

    def _admin_active_fault_exit_or_not(self, conds):
        """
        exp_fault: severity, alarm_id, alarm_name, fault_id,fault_name, alarming_object, supplalarminfo
        """
        conds = self._remove_empty_from_list(conds)
        exp_fault = {}
        for cond in conds:
            exp_fault[cond.split("=")[0].strip().lower().replace(" ", "_")] = '='.join(cond.split("=")[1:]).strip()
        supported_keys = ["severity", "alarm_id", "alarm_name", "fault_id", "fault_name", "alarming_object",
                          "supplalarminfo"]
        for key in exp_fault.keys():
            if supported_keys.count(key) == 0:
                raise Exception("condition %s is not supported" % key)

        find_flag = False
        if "severity" in exp_fault and exp_fault['severity'].lower() == 'transient':
            builtin_obj.log("transient alarm should search history fault", console=True)
            exp_fault['severity'] = 'warning'  # transient belong to warning
            find_flag = self._admin_history_fault_exit_or_not(exp_fault)
            return find_flag
        builtin_obj.log("step: expect alarm is:%s" % exp_fault)
        self._setup_fm()
        all_active_alarms = self.admin_obj.get_active_alarms(alias=self.alias)
        builtin_obj.log("step: get active alarms:")
        for alarm in all_active_alarms:
            builtin_obj.log("  {}".format(alarm))
        act_alarm_list = []
        for fault_index in range(len(all_active_alarms)):
            fault = {}
            # alarm_keys = ["severity", "alarmId", "alarmName", "faultId", "faultName", "configObjectName",
            #               "supplAlarmInfo"]
            for key in all_active_alarms[fault_index].keys():
                if key.count("severity") != 0:
                    fault["severity"] = str(all_active_alarms[fault_index]["severity"]).strip()
                if key.count("alarmId") != 0:
                    fault["alarm_id"] = str(all_active_alarms[fault_index]["alarmId"]).strip()
                if key.count("alarmName") != 0:
                    fault["alarm_name"] = str(all_active_alarms[fault_index]["alarmName"]).strip()
                if key.count("faultId") != 0:
                    fault["fault_id"] = str(all_active_alarms[fault_index]["faultId"]).strip()
                if key.count("faultName") != 0:
                    fault["fault_name"] = str(all_active_alarms[fault_index]["faultName"]).strip()
                if key.count("configObjectName") != 0:
                    fault["alarming_object"] = str(all_active_alarms[fault_index]["configObjectName"]).strip()
                if key.count("supplAlarmInfo") != 0:
                    fault["supplalarminfo"] = str(all_active_alarms[fault_index]["supplAlarmInfo"]).strip()
            act_alarm_list.append(fault)
        builtin_obj.log("step: actual alarm list is:")
        for alarm in act_alarm_list:
            builtin_obj.log("  {}".format(alarm))

        for each_act_fault in act_alarm_list:
            find_flag = True
            check_keys = list(exp_fault.keys())

            if "alarming_object" in exp_fault:
                check_keys.remove("alarming_object")
                if not self._contain_sub_string(each_act_fault, exp_fault, "alarming_object"):
                    find_flag = False
                    continue

            if "supplalarminfo" in exp_fault:
                check_keys.remove("supplalarminfo")
                if not self._contain_sub_string(each_act_fault, exp_fault, "supplalarminfo"):
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

    def _admin_history_fault_exit_or_not(self, exp_fault):
        builtin_obj.log("###########################################################################################")
        case_begin_time = builtin_obj.get_variable_value('${case_begin_time}')
        builtin_obj.log("case begin time is %s" % case_begin_time)
        builtin_obj.log("expect fault list is %s" % exp_fault)
        self._setup_fm()

        # Get all history faults from the raw file
        all_alarms = [self.admin_obj.get_raw_alarm_history_file(alias=self.alias).encode("utf-8")]  # unicode to str
        builtin_obj.log(" all alarm is:%s" % ('\r\n' + str(all_alarms).replace("', '", "',\r\n '")))
        alarm_list = [each_line.strip().decode() for each_line in bytes(all_alarms[0]).strip().splitlines() if
                      len(each_line.strip()) > 0 and each_line.decode().count("\tEFaultId_")]
        builtin_obj.log(" alarm_list:%s" % ('\r\n' + str(alarm_list).replace("', '", "',\r\n '")))
        case_begin_time = datetime.datetime(*(time.strptime(case_begin_time, '%Y-%m-%d %H:%M:%S'))[:6])

        # ADMIN TimeStamp format change to string without timezone : 2019-Aug-06 10:48:39
        # 1. Filter the history fault after this case run
        history_fault = filter(lambda x: datetime.datetime(*time.strptime(
            x.strip().split('\t')[0], '%Y-%b-%d %H:%M:%S')[:6]) > case_begin_time, alarm_list)
        history_fault_tmp = list(history_fault)
        builtin_obj.log(" history_fault_tmp [list]:%s" % history_fault_tmp)

        # 2. Filter the history fault before this case run
        history_fault_other = filter(lambda x: datetime.datetime(*time.strptime(
            x.strip().split('\t')[0], '%Y-%b-%d %H:%M:%S')[:6]) <= case_begin_time, alarm_list)
        history_fault_other_tmp = list(history_fault_other)
        builtin_obj.log(" history_fault_other_tmp [list]:%s" % history_fault_other_tmp)

        # When check fault was 4592, need add 8 hours in fault4592 datetime
        if 'BTS Reset Cause' in str(exp_fault):
            if 'BtsResetCause' in str(history_fault_tmp):
                history_fault_tmp = history_fault_tmp
                builtin_obj.log(" 'BtsResetCause' after this case run [%s]" % history_fault_tmp)
            else:
                history_fault_tmp = history_fault_other_tmp
                builtin_obj.log(" 'BTS Reset Cause' 8 hours before this case run [%s]" % history_fault_tmp)

        history_fault_list = []
        for i in history_fault_tmp:
            fault = {}
            fault["fault_id"] = i.strip().split("\t")[1].strip().strip("(").strip(")")
            fault['fault_name'] = i.strip().split("\t")[2].strip()
            fault['alarming_object'] = i.strip().split("\t")[3].strip()
            fault['severity'] = i.strip().split("\t")[-1].strip()
            history_fault_list.append(fault)
        builtin_obj.log(" history alarm list is:%s" % history_fault_list)
        find_flag = False

        # If not find history fault, return false
        if len(history_fault_list) == 0:
            return find_flag

        # compare exp_fault with history_fault_list
        for each_his_fault in history_fault_list:
            find_flag = True
            check_keys = list(exp_fault.keys())

            if "source_dn" in exp_fault:
                check_keys.remove("source_dn")
                if each_his_fault["distName"].endswith(exp_fault["source_dn"]) is False:
                    find_flag = False
                    # continue
            if "severity" in exp_fault:
                check_keys.remove("severity")
                builtin_obj.log("Have 'severity' in exp_fault, check_keys=%s" % check_keys)
                # no mapping  relation
                # continue

            if "fault_name" in exp_fault:
                check_keys.remove("fault_name")
                builtin_obj.log("Have 'fault_name' in exp_fault, check_keys=%s" % check_keys)
                # fault name compare  between  active alarm and history alarm
                # continue

            if "alarm_id" in exp_fault:
                check_keys.remove("alarm_id")
                builtin_obj.log("Have 'alarm_id' in exp_fault, check_keys=%s" % check_keys)
                # no alarm_id in alarm history
                # continue

            if "alarm_name" in exp_fault:
                check_keys.remove("alarm_name")
                builtin_obj.log("Have 'alarm_name' in exp_fault, check_keys=%s" % check_keys)
                # no alarm_id in alarm history
                # continue

            """
            compare
            Maximum number of neighbor eNBs/cells exceeded
            EFaultId_MaximumNumberOfNeighbourEnbsOrCellsExceeded
            """
            builtin_obj.log(" check_keys :%s" % check_keys)
            key_num = 0
            for key in check_keys:
                key_num = key_num + 1
                builtin_obj.log("key_num[%d][%s] in check_keys" % (key_num, key))

                # Change fault name for FID-4592
                need_check_key = str(exp_fault[key]).lower()
                if need_check_key == "bts reset cause":
                    need_check_key = "efaultid_btsresetcauseal"

                if need_check_key != str(each_his_fault[key]).lower():
                    find_flag = False
                    builtin_obj.log("find_flag=%s, %s: %s != %s" %
                                    (find_flag, key, need_check_key, str(each_his_fault[key]).lower()), console=True)
                    continue
            if find_flag is True:
                builtin_obj.log("find_flag=%s, %s: %s == %s" %
                                (find_flag, key, str(exp_fault[key]).lower(), str(each_his_fault[key]).lower()),
                                console=True)
                break
        return find_flag

    def _netact_fm_fault_should_be_raised(self, conditions, btsid, timeout):
        retry_times = int(timeout) / 10
        while retry_times >= 0:
            result = self._fault_exit_or_not(conditions, btsid)
            if result is False:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is False:
            raise Exception("The expected fault doesn't exist")

    def _netact_fm_fault_should_be_cleared(self, conditions, btsid, timeout):
        retry_times = int(timeout) / 10
        while retry_times >= 0:
            result = self._fault_exit_or_not(conditions, btsid, "netact")
            if result is True:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is True:
            raise Exception("The active fault should not exist")

    def _fm_fault_should_be_raised(self, conditions, timeout):
        retry_times = int(timeout) / 10
        result = False
        while retry_times >= 0:
            builtin_obj.log("fm fault should be raised [retry_times]:%s" % retry_times)
            case_begin_time = builtin_obj.get_variable_value('${case_begin_time}')
            builtin_obj.log("retry begin time is %s" % case_begin_time)
            result = self._admin_active_fault_exit_or_not(conditions)
            if result is False:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is False:
            raise Exception("The expected fault doesn't exist")

    def _fm_fault_should_be_cleared(self, conditions, timeout):
        retry_times = int(timeout) / 10
        result = False
        while retry_times >= 0:
            result = self._admin_active_fault_exit_or_not(conditions)
            if result is True:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is True:
            raise Exception("The active fault should not exist")

    def _fm_fault_should_not_exist(self, conditions):
        result = self._admin_active_fault_exit_or_not(conditions)
        if result is True:
            raise Exception("The active fault should not exist")

    def _list_active_alarm_fm(self, all_active_alarms):
        alarms_str = ""
        if len(all_active_alarms):
            fault_name_max_len = 0
            for alarm in all_active_alarms:
                fault_name_max_len = len(alarm)
                # builtin_obj.log("[Debug] step: List active alarms: %s" % alarm)
                for i in range(fault_name_max_len):
                    # builtin_obj.log("[Debug][%d] step: List active alarms: %s" % (i, list(alarm.items())[0][0]))
                    # builtin_obj.log("[Debug][%d] step: List active alarms: %s" % (i, list(alarm.items())[0][1]))
                    if list(alarm.items())[i][0] in ["severity", "btsObservationTime", "alarmId", "faultId",
                                                     "faultName"]:
                        alarms_str = alarms_str + "%s    " % (list(alarm.items())[i][1])
                if alarms_str != "":
                    alarms_str = alarms_str + "\r\n"
            # builtin_obj.log("[Debug] step: List active alarms: %s\r\n" % alarms_str)

            title = "%-10s%-23s%-10s%s  %s" % ("severity", "btsObservationTime", "alarmId", "faultId", "faultName")
            builtin_obj.log("step: List active alarms: \n%s\n%s" % (title, alarms_str))

    def _get_current_active_faultid(self):
        self._setup_fm()
        all_active_alarms = self.admin_obj.get_active_alarms(alias=self.alias)
        self._list_active_alarm_fm(all_active_alarms)

        act_alarm_list = []
        for fault_index in range(len(all_active_alarms)):
            fault = {}
            alarm_keys = ["faultId"]
            for key in all_active_alarms[fault_index].keys():
                if alarm_keys.count("faultId") != 0:
                    fault["fault_id"] = str(all_active_alarms[fault_index]["faultId"]).strip()
            act_alarm_list.append(fault)

        builtin_obj.log("actual faultId list is:%s" % act_alarm_list)
        return act_alarm_list

    def _check_no_new_active_faultid_exist(self, initial_act_alarm_list, faults_excluded_checking):
        """
        Arguments: Owner:TA Group
        | initial_act_alarm_list | : | [{'fault_id': '61649'}, {'fault_id': '4655'}, {'fault_id': '61524'}] |
        | faults_excluded_checking | : | [61649, 4655 ,61524] |
        Documentation:
        Example:
        """
        current_act_alarm_all, new_active_fault_id = "", ""
        current_act_alarm_list = self._get_current_active_faultid()
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


class fm_enb1(object):

    def __init__(self):
        alias = "enb1"
        self.fm_base_instance_1 = fm_base(alias)

    def fm_fault_should_be_raised(self, conditions, timeout='100'):
        """This keyword is to check fault raised in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
                                 alarming_object, supplalarminfo|
        | timeout  |  No   | default is 100s |

        (1) severity, alarm_id, alarm_name, fault_id, fault_name are required to specify all characters
        for example:
        | ${fault6356} | create list | Severity=minor | fault_id=6356 |
                                       fault_name=Automatic access class barring is active |
                                       alarm_id=7655| alarm_name=CELL NOTIFICATION |
        | fm_fault_should_be_raised | ${fault6356} | timeout=100 |

        (2) for alarming_object and supplalarminfo, if there is [RE] before string, it means to be parsed as
        regular expression, otherwise it is normal string.
        Example 1: normal string
        | ${fault6356} | create list | fault_id=6356 |
                                       supplalarminfo=LNRELGNBCELL cannot be created due to max object number reached
                                       for the UE reported NR-CGI [PLMN Id {MCC = 262, MNC = 3, MNCLength = 2}]|
        | fm_fault_should_be_raised | ${fault6356} |

        Example 2: regular expression
        | ${fault7516} | create list | fault_id=7516 |
                                       supplalarminfo=[RE]Mismatch of System Information SIB Type \\(.*SIB3.*\\)|
        | fm_fault_should_be_raised | ${fault7516} |

        (3) for transient fault, severity must be specifed, otherwize no fault will be found
        for example
        | ${fault6270} | create list | fault_id=6270 | severity=transient |
        | fm_fault_should_be_raised | ${fault6270} |
        """
        timeout = timestr_to_secs(timeout)
        self.fm_base_instance_1._fm_fault_should_be_raised(conditions, timeout)

    def fm_fault_should_be_cleared(self, conditions, timeout='100'):
        """This keyword is to check fault cleared in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object, supplalarminfo|
        | timeout  |  No   | default is 100s |
         Example:
        | fm_fault_should_be_cleared | fault_id=6203 |

        """
        timeout = timestr_to_secs(timeout)
        self.fm_base_instance_1._fm_fault_should_be_cleared(conditions, timeout)

    def fm_fault_should_not_exist(self, conditions):
        """This keyword is to check fault not exist in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
                                 alarming_object, supplalarminfo|
         Example:
        | fm_fault_should_be_cleared | fault_id=6203 |

        """
        self.fm_base_instance_1._fm_fault_should_not_exist(conditions)

    def get_current_active_faultid(self):
        """This keyword is to get current active faultid in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        |  ${faultid_list}  | Get Current Active Faultid |
        """
        act_alarm_list = self.fm_base_instance_1._get_current_active_faultid()
        return act_alarm_list

    def check_no_new_active_faultid_exist(self, initial_act_alarm_list, faults_excluded_checking):
        """This keyword is to check no new active faultid exist in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        | Check No New Active Faultid Exist | ${initial_act_alarm_list} |
        """
        self.fm_base_instance_1._check_no_new_active_faultid_exist(initial_act_alarm_list, faults_excluded_checking)


class fm_enb2(object):

    def __init__(self):
        alias = "enb2"
        self.fm_base_instance_2 = fm_base(alias)

    def _setup_fm_bts2(self):
        self.fm_base_instance_2.bts_host = builtin_obj.get_variable_value('${ENB2_IP}')  # S1 IP
        self.fm_base_instance_2.remote_host = builtin_obj.get_variable_value('${ENB2_PC_IP}')

    def fm_fault_should_be_raised_enb2(self, conditions, timeout='100'):
        """This keyword is to check fault raised in local BTS
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
                                 alarming_object, supplalarminfo|
        | timeout  |  No   | default is 100s |

        (1) severity, alarm_id, alarm_name, fault_id, fault_name are required to specify all characters
        for example:
        | ${fault6356} | create list | Severity=minor | fault_id=6356 |
                                       fault_name=Automatic access class barring is active |
                                       alarm_id=7655| alarm_name=CELL NOTIFICATION |
        | fm_fault_should_be_raised_gnb2 | ${fault6356} | timeout=100 |

        (2) for alarming_object and supplalarminfo, if there is [RE] before string, it means to be parsed as
        regular expression, otherwise it is normal string.
        Example 1: normal string
        | ${fault6356} | create list | fault_id=6356 |
                                       supplalarminfo=LNRELGNBCELL cannot be created due to max object number reached
                                       for the UE reported NR-CGI [PLMN Id {MCC = 262, MNC = 3, MNCLength = 2}]|
        | fm_fault_should_be_raised_enb2 | ${fault6356} |

        Example 2: regular expression
        | ${fault7516} | create list | fault_id=7516 |
                                       supplalarminfo=[RE]Mismatch of System Information SIB Type \\(.*SIB3.*\\)|
        | fm_fault_should_be_raised_enb2 | ${fault7516} |

        (3) for transient fault, severity must be specifed, otherwize no fault will be found
        for example
        | ${fault6270} | create list | fault_id=6270 | severity=transient |
        | fm_fault_should_be_raised_enb2 | ${fault6270} |
        """
        self._setup_fm_bts2()
        timeout = timestr_to_secs(timeout)
        self.fm_base_instance_2._fm_fault_should_be_raised(conditions, timeout)

    def fm_fault_should_be_cleared_enb2(self, conditions, timeout='100'):
        """This keyword is to check fault cleared
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
        alarming_object, supplalarminfo|
        | timeout  |  No   | default is 100s |
         Example:
        | fm_fault_should_be_cleared_enb2 | fault_id=6203 |

        """
        self._setup_fm_enb2()
        timeout = timestr_to_secs(timeout)
        self.fm_base_instance_2._fm_fault_should_be_cleared(conditions, timeout)

    def fm_fault_should_not_exist_enb2(self, conditions):
        """This keyword is to check fault not exist
        | Input Parameters | Man. | Description |
        | conditions   |  Yes  | fault's condtions, such as severity, alarm_id, alarm_name, fault_id, fault_name,
                                 alarming_object, supplalarminfo|
         Example:
        | fm_fault_should_not_exist_enb2 | fault_id=6203 |

        """
        self._setup_fm_enb2()
        self.fm_base_instance_2._fm_fault_should_not_exist(conditions)

    def get_current_active_faultid_enb2(self):
        """This keyword is to get current active faultid in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        |  ${faultid_list}  | check_no_new_active_faultid_exist_enb2 |
        """
        self._setup_fm_bts2()
        act_alarm_list = self.fm_base_instance_2._get_current_active_faultid()
        return act_alarm_list

    def check_no_new_active_faultid_exist_enb2(self, initial_act_alarm_list_enb2, faults_excluded_checking):
        """This keyword is to check no new active faultid exist in local BTS
        | Input Parameters |  No   |
        | timeout  |  No   |
         Example:
        | check_no_new_active_faultid_exist_enb2 | ${initial_act_alarm_list_enb2} |
        """
        self._setup_fm_bts2()
        self.fm_base_instance_2._check_no_new_active_faultid_exist(initial_act_alarm_list_enb2,
                                                                   faults_excluded_checking)


class fm(fm_enb1, fm_enb2):
    def __init__(self):
        fm_enb1.__init__(self)
        fm_enb2.__init__(self)


if __name__ == "__main__":
    fm_obj = fm()
    help(fm_obj)
