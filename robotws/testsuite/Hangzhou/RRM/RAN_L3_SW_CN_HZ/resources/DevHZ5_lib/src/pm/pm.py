# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

import time
import os
import re
import random
from robot.libraries.OperatingSystem import OperatingSystem
from common_lib import common_lib
from base_lib.ta_xml.common_xml import CommonXML
from robot.libraries.BuiltIn import BuiltIn
from base_lib.ute_fsmaccess import ute_fsmaccess
from base_lib.ta_ssh_telnet import ta_ssh_telnet
from base_lib.ta_xml import ta_xml
from robot.utils import timestr_to_secs


comm_obj = common_lib()
os_obj = OperatingSystem()
builtin_obj = BuiltIn()
ssh_obj = ta_ssh_telnet()
xml_obj = ta_xml()


class pm_base(object):
    def __init__(self, alias):
        self._setup_pm_flag = False
        self.alias = alias
        self.remote_host = None
        self.rtpm_port = "49525"
        self.rtpm_counter_file = ""

    def _setup_pm(self):
        if not self._setup_pm_flag:
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#",
                                              host="192.168.255.129")
            self._setup_pm_flag = True
            # ${PM_COUNTER_INTERVAL} could be 1min, 5min and 15min
            self.pm_counter_interval = builtin_obj.get_variable_value("${PM_COUNTER_INTERVAL}").rstrip("min")
            self.pm_counter_interval = int(self.pm_counter_interval)
            self.mapping_mo_counters = {}

    def __del__(self):
        if self._setup_pm_flag:
            self.fsm_obj.teardown_all_aliases_for_enb_fsmaccess()

    def _list_counter_files(self, local_counter_path):
        # counter file name: PM.BTS-1.20180705.070000.ANY.xml.xz, PM.BTS-1.20180705.070000.ANY.raw.xz,
        # PM.BTS-1.20180705.071500.ANY.raw.xz
        out_files = []
        zip_files = os_obj.list_files_in_directory(local_counter_path)
        zip_files.sort()
        # not include duplicate counter files, for example:
        # PM.BTS-1.20180705.070000.ANY.xml.xz,
        # PM.BTS-1.20180705.070000.ANY.raw.xz
        for index in range(len(zip_files)):
            file_prefix = zip_files[index][:-7]
            flag = False
            for right in range(index + 1, len(zip_files)):
                file_right_prefix = zip_files[right][:-7]
                if file_prefix == file_right_prefix:
                    flag = True
                    break
            if flag is False:
                out_files.append(zip_files[index])
        return out_files

    def _create_counter_xpath(self, counter_mo, counter_type, counterid, counter_file):
        xpath = ""
        if counter_mo is not None:
            if counter_file.count("rtpm") == 0:
                for mo in counter_mo.split("/"):
                    xpath = xpath + "//*[matches(text(), '.*%s($|/.*)')]/../.." % mo
        if counter_type is not None:
            xpath = xpath + "//*[matches(@measurementType, '%s')]/%s" % (counter_type, counterid)
        else:
            xpath = xpath + "//%s" % counterid
        return xpath

    def _get_counter_values_from_counter_file(self, counterfile, counterid, counter_mo=None, counter_type=None):
        counter_values = []
        xpath = self._create_counter_xpath(counter_mo, counter_type, counterid, counterfile)
        if counterfile.count("rtpm"):
            xml = CommonXML(self.mapping_mo_counters[counterfile][counter_mo])
        else:
            xml = CommonXML(counterfile)

        PMSetup_elements = xml.get_elements("//PMSetup")
        for PMSetup in PMSetup_elements:
            PMSetup = """<?xml version="1.0"?>""" + xml.element_to_string(PMSetup)
            xml2 = CommonXML(PMSetup)
            elements = xml2.get_elements(xpath)
            if len(elements):
                countervalue = sum(map(lambda e: int(e.text), elements))
                counter_values.append(countervalue)
        return counter_values

    def _convert_digit(self, str_input):
        try:
            num = int(str_input)
            return num
        except ValueError:
            try:
                num = float(str_input)
                return num
            except ValueError:
                raise Exception("{} is neither int nor float".format(str_input))

    def _get_total_counter_value_from_counter_files(self, counterfiles, counterid, counter_mo=None, counter_type=None):
        counterfiles = comm_obj.remove_empty_from_list(counterfiles)
        total_value = 0
        find_num = 0
        xpath = self._create_counter_xpath(counter_mo, counter_type, counterid, counterfiles[0])
        for counterfile in counterfiles:
            builtin_obj.log("step: analyzing counter file %s" % counterfile)
            if counterfile.count("rtpm"):
                xml = CommonXML(self.mapping_mo_counters[counterfile][counter_mo])
            else:
                xml = CommonXML(counterfile)
            builtin_obj.log("trying xpath: %s" % xpath)
            elements = xml.get_elements(xpath)
            if len(elements):
                find_num = find_num + len(elements)
                countervalue = sum(map(lambda e: self._convert_digit(e.text), elements))
                builtin_obj.log("counter file '%s' : xpath '%s' value is '%s'" % (counterfile, xpath, countervalue))
                total_value += countervalue
            else:
                builtin_obj.log("counter file '%s' : xpath '%s' doesn't exist" % (counterfile, xpath))
        # counter not exiting
        if find_num == 0:
            total_value = -1
        return total_value

    def _download_counter_files(self, counter_type="PM"):
        self._setup_pm()
        # download counter files
        save_log_directory = comm_obj._get_save_log_dir(self.alias)
        local_counter_path = os.path.join(save_log_directory,
                                          "%s_counters_%s/" % (counter_type, comm_obj.get_timestamp()))
        os_obj.create_directory(local_counter_path)
        self.fsm_obj.get_enb_file(os.path.join("/tmp", "%s.BTS*" % counter_type), local_counter_path, alias=self.alias)
        # uncompress counter files
        zip_files = self._list_counter_files(local_counter_path)
        for each_file in zip_files:
            comm_obj.uncompress_file(os.path.join(local_counter_path, each_file))
        # get counter files list
        counter_files = os_obj.list_files_in_directory(local_counter_path, "%s.BTS*.xml" % counter_type)
        counter_files_raw = os_obj.list_files_in_directory(local_counter_path, "%s.BTS*.raw" % counter_type)
        counter_files.extend(counter_files_raw)
        if len(counter_files) == 0:
            raise Exception("no counter files")
        counter_files_path = []
        for counter_file in counter_files:
            counter_files_path.append(os.path.join(local_counter_path, counter_file))
        builtin_obj.log("step: counter files %s will be analyzed" % counter_files_path)
        return counter_files_path

    def _analyze_counter_files(self, counters_expression, counter_type="PM"):
        self._setup_pm()
        counters_expression = comm_obj.remove_empty_from_list(counters_expression)
        # download and unzip counter files
        counter_files_path = self._download_counter_files(counter_type)
        counter_result_list = []
        # analyze counter
        for counter_exp in counters_expression:
            scope = None
            counter_mo = None
            measurement_type = None
            builtin_obj.log("step: counter exp: %s" % counter_exp)
            # support every
            if counter_exp.lower().count("every"):
                scope = "every"
                counter_exp = counter_exp.split()[-1]

            if counter_exp.lower().count("last"):
                scope = "last"
                counter_exp = counter_exp.split()[-1]
            if counter_exp.count(":") == 0:
                counter_exp_short = counter_exp
            elif counter_exp.count(":") == 1:
                counter_mo, counter_exp_short = counter_exp.split(":")
            elif counter_exp.count(":") == 2:
                counter_mo, measurement_type, counter_exp_short = counter_exp.split(":")
            else:
                raise Exception("not support such format: %s" % counter_exp)

            match = re.search(r"([^!<>=]+)([!><=]+)(.*)", counter_exp_short, re.I)
            if match is not None:
                counter_name_or_id = match.group(1).strip()
                express = match.group(2).strip()
                value_exp = match.group(3).strip()

                if re.match(r"^(\d|[A-Za-z_])+$", value_exp) is not None:
                    pass
                elif re.match(r"^(\d+)\-(\d+)$", value_exp) is not None:
                    ret = re.match(r"^(\d+)\-(\d+)$", value_exp)
                    value_exp = list(range(int(ret.group(1)), int(ret.group(2))+1))
                    value_exp = [str(x) for x in value_exp]
                elif re.match(r"^(\d+\|+)+\d+$", value_exp) is not None:
                    # value_exp = [int(x) for x in value_exp.split("|")]
                    value_exp = [str(x) for x in value_exp.split("|")]

                if counter_exp.count(":"):
                    counter_without_value = "%s:%s" % (
                        ":".join(counter_exp.split(":")[:-1]), counter_exp_short.split(express)[0])
                else:
                    counter_without_value = counter_exp_short.split(express)[0]
                if express == "=":
                    express = "=="

                # analyze counter files
                if scope == "every":
                    for counter_file in counter_files_path:
                        counter_values = self._get_counter_values_from_counter_file(
                            counter_file, counter_name_or_id, counter_mo, measurement_type)
                        builtin_obj.log("the values of counter %s in file %s are: %s"
                                        % (counter_name_or_id, counter_file, counter_values))
                        for value_act in counter_values:
                            if type(value_exp) is list:
                                ret = eval("'%s' in %s" % (value_act, value_exp))
                                if ret:
                                    result = "passed"
                                    builtin_obj.log("%s value in %s is %s, checking it should in %s, result is %s"
                                                    % (counter_without_value, counter_file, value_act,
                                                       value_exp, result))
                                else:
                                    result = "failed"
                                    builtin_obj.log("%s value in %s is %s, checking it should in %s, result is %s"
                                                    % (counter_without_value, counter_file, value_act,
                                                       value_exp, result), level="WARN")
                                    break
                            else:
                                ret = eval("%s%s%s" % (value_act, express, value_exp))
                                if ret:
                                    result = "passed"
                                    builtin_obj.log(" %s value in %s is %s, checking it should %s %s, result is %s"
                                                    % (counter_without_value, counter_file, value_act,
                                                       express, value_exp, result))
                                else:
                                    result = "failed"
                                    builtin_obj.log("%s value in %s is %s, checking it should %s %s, result is %s"
                                                    % (counter_without_value, counter_file, value_act,
                                                       express, value_exp, result), level="WARN")
                                break
                    counter_result_list.append([counter_name_or_id, value_act, result])
                    continue

                if scope == "last":
                    counter_file = counter_files_path[-1]
                    counter_values = self._get_counter_values_from_counter_file(counter_file, counter_name_or_id,
                                                                                counter_mo, measurement_type)
                    builtin_obj.log("the values of counter %s in file %s are: %s" % (counter_name_or_id,
                                                                                     counter_file, counter_values))
                    if counter_values[-1] is not None:
                        last_value = counter_values[-1]
                    else:
                        raise Exception("not find the values of counter %s in file %s are: %s" % (
                            counter_name_or_id, counter_file, counter_values))

                    if type(value_exp) is list:
                        ret = eval("'%s' in %s" % (last_value, value_exp))
                        if ret:
                            result = "passed"
                            builtin_obj.log(" %s last value in %s is %s, checking it should in %s, result is %s"
                                            % (counter_without_value, counter_file, last_value, value_exp, result))
                        else:
                            result = "failed"
                            builtin_obj.log("%s last value in %s is %s, checking it should in %s, result is %s"
                                            % (counter_without_value, counter_file, last_value, value_exp, result),
                                            level="WARN")
                    else:
                        ret = eval("%s%s%s" % (last_value, express, value_exp))
                        if ret:
                            result = "passed"
                            builtin_obj.log("%s last value in %s is %s, checking it should %s %s, result is %s"
                                            % (counter_without_value, counter_file, last_value, express,
                                               value_exp, result))
                        else:
                            result = "failed"
                            builtin_obj.log("%s last value in %s is %s, checking it should %s %s, result is %s"
                                            % (counter_without_value, counter_file, last_value, express,
                                               value_exp, result), level="WARN")
                    counter_result_list.append([counter_name_or_id, last_value, result])
                    continue

                if value_exp == "existing":
                    total_num_act = self._get_total_counter_value_from_counter_files(
                        counter_files_path, counter_name_or_id, counter_mo, measurement_type)
                    if total_num_act != -1:
                        result = "passed"
                        builtin_obj.log("total number of %s is %s, checking it should be existing, result is %s" % (
                            counter_without_value, total_num_act, result))
                    else:
                        result = "failed"
                        total_num_act = 0
                        builtin_obj.log("%s should exist, but actual it doesn't exist" % counter_without_value,
                                        level="WARN")

                elif value_exp == "not_existing":
                    total_num_act = self._get_total_counter_value_from_counter_files(
                        counter_files_path, counter_name_or_id, counter_mo, measurement_type)
                    if total_num_act == -1:
                        result = "passed"
                        total_num_act = 0
                        builtin_obj.log("%s doesn't exist as expected" % counter_without_value)
                    else:
                        result = "failed"
                        builtin_obj.log("total number of %s is %s, checking it should be not existing, result is %s"
                                        % (counter_without_value, total_num_act, result), level="WARN")
                else:
                    total_num_act = self._get_total_counter_value_from_counter_files(counter_files_path,
                                                                                     counter_name_or_id, counter_mo,
                                                                                     measurement_type)
                    if total_num_act != -1:
                        if type(value_exp) is list:
                            ret = eval("'%s' in %s" % (total_num_act, value_exp))
                            if ret:
                                result = "passed"
                                builtin_obj.log("total number of %s is %s, checking it should in %s, result is %s"
                                                % (counter_without_value, total_num_act, value_exp, result))
                            else:
                                result = "failed"
                                builtin_obj.log("total number of %s is %s, checking it should in %s, result is %s"
                                                % (counter_without_value, total_num_act, value_exp, result),
                                                level="WARN")
                        else:
                            ret = eval("%s%s%s" % (total_num_act, express, value_exp))
                            if ret:
                                result = "passed"
                                builtin_obj.log("total number of %s is %s, checking it should %s %s, result is %s"
                                                % (counter_without_value, total_num_act, express, value_exp, result))
                            else:
                                result = "failed"
                                builtin_obj.log("total number of %s is %s, checking it should %s %s, result is %s"
                                                % (counter_without_value, total_num_act, express, value_exp, result),
                                                level="WARN")
                    else:
                        result = "failed"
                        total_num_act = 0
                        builtin_obj.log("checking counter %s should %s %s, but it doesn't exist"
                                        % (counter_without_value, express, value_exp), level="WARN")
                counter_result_list.append([counter_name_or_id, total_num_act, result])
            else:
                raise Exception("not support expression %s" % counter_exp)

        out_list = []
        for counter_result in counter_result_list:
            if counter_result not in out_list:
                out_list.append(counter_result)
        return out_list

    def _get_counter_file_remaining_time(self, counter_refresh_period):
        """calculate next counter file generated remaining time.
        :param counter_refesh_period: counter file refresh period
        :return: time string | #unit seconds
        """
        self._setup_pm()
        counter_refresh_period = timestr_to_secs(counter_refresh_period) / 60
        time_str = self.fsm_obj.execute_command_on_enb(cmd='date "+%Y-%m-%d %H:%M:%S"', alias=self.alias)
        temp_list = time_str.split(":")
        counter_refresh_period = int(counter_refresh_period)
        return (counter_refresh_period -
                int(temp_list[1]) % counter_refresh_period) * 60 - int(temp_list[2]) + 80

    # def _connect_to_netact(self):
    #     netact_info = builtin_obj.get_variable_value("${NETACT_SERVER_INFO}")
    #     netact_conn = ssh_obj.connect_to_host(
    #         netact_info.IP,
    #         "22",
    #         netact_info.USERNAME,
    #         netact_info.PASSWORD,
    #         conn_type="SSH")
    #     ssh_obj.set_shell_timeout("5min")
    #     return netact_conn
    #
    # def _netact_pm_check_counters(self, pm_counters_expression, btsid, wait):
    #     pm_counters_expression = comm_obj.remove_empty_from_list(pm_counters_expression)
    #     if wait:
    #         # wait counter file produced
    #         remain_time = self._get_counter_file_remaining_time()
    #         # if counter happened at last 1 minute, wait more 15 minutes
    #         if int(remain_time) < 140:
    #             remain_time = int(remain_time) + 900
    #         # wait 2 miutes for counter sent to netact
    #         remain_time = remain_time + 120
    #         builtin_obj.log("wait for %s secs" % remain_time)
    #         time.sleep(remain_time)
    #
    #     # download counter files for trouble shooting
    #     self._download_counter_files("PM")
    #
    #     # analyze counters in netact DB
    #     for counter_exp in pm_counters_expression:
    #         builtin_obj.log("counter exp: %s" % counter_exp)
    #         match = re.search(r"([^<>=]+)([><=]+)(.*)", counter_exp, re.I)
    #         if match is not None:
    #             counter = match.group(1).strip()
    #             express = match.group(2)
    #             value_exp = match.group(3).strip()
    #             if counter.count(":"):
    #                 counter_mo = counter.split(":")[0]
    #                 counter_name = counter.split(":")[1]
    #             else:
    #                 counter_mo = None
    #                 counter_name = counter
    #             if express == "=":
    #                 express = "=="
    #
    #             case_begin_time = builtin_obj.get_variable_value('${case_begin_time}')
    #             minute = int(case_begin_time.split(":")[1])
    #             if 0 <= minute < 15:
    #                 minute = "00"
    #             elif 15 <= minute < 30
    #                 minute = "15"
    #             elif 30 <= minute < 45:
    #                 minute = "30"
    #             else:
    #                 minute = "45"
    #             case_begin_time = case_begin_time.split(":")[0] + ":%s:00" % minute
    #             netact_conn = self._connect_to_netact()
    #             old_prompt = ssh_obj.set_shell_prompt("SQL>")
    #             old_timeout = ssh_obj.set_shell_timeout("300")
    #             ssh_obj.execute_shell_command("sqlplus omc/omc")
    #             ssh_obj.execute_shell_command("set head off")
    #             ssh_obj.execute_shell_command("set linesize 1000")
    #             ssh_obj.execute_shell_command("alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';")
    #             table_names = ssh_obj.execute_shell_command(
    #                 "SELECT table_name from dba_tab_columns where column_name='%s';" % counter_name)
    #             table_names_raw = [elem.strip() for elem in table_names.splitlines()
    #                                if elem.endswith("RAW") and elem.count("_PR_") == 0]
    #             if counter_mo is None:
    #                 lnbts_id = ssh_obj.execute_shell_command(
    #                     "select to_char(co_gid) from utp_common_objects where co_dn='PLMN-PLMN/MRBTS-%s/LNBTS-%s';"
    #                     % (btsid, btsid))
    #                 counter_result = ssh_obj.execute_shell_command(
    #                     "select %s, period_start_time from %s where LNBTS_ID=%s and period_start_time >= '%s';"
    #                     % (counter_name, table_names_raw[0], lnbts_id.strip(), case_begin_time))
    #             else:
    #                 lncel_id = ssh_obj.execute_shell_command(
    #                    "select to_char(co_gid) from utp_common_objects where co_dn='PLMN-PLMN/MRBTS-%s/LNBTS-%s/%s';"
    #                     % (btsid, btsid, counter_mo))
    #                 counter_result = ssh_obj.execute_shell_command(
    #                     "select %s, period_start_time from %s where LNCEL_ID=%s and period_start_time >= '%s';"
    #                     % (counter_name, table_names_raw[0], lncel_id.strip(), case_begin_time))
    #             ssh_obj.set_shell_prompt(old_prompt)
    #             ssh_obj.set_shell_timeout(old_timeout)
    #             ssh_obj.execute_shell_command("exit")
    #             ssh_obj.disconnect_from_host(netact_conn)
    #             total_num_act = 0
    #             for line in counter_result.strip().splitlines():
    #                 if len(line.strip()) > 0 and line.count("rows selected") == 0:
    #                     counter_value = line.split()[0]
    #                     total_num_act += int(counter_value)
    #             builtin_obj.log("total number of %s is %s, checking it should %s %s" % (
    #                 counter_name, total_num_act, express, int(value_exp)))
    #             BuiltIn().should_be_true("%s%s%s" % (total_num_act, express, int(value_exp)))
    #         else:
    #             raise Exception("not support expression %s" % counter_exp)
    #
    def _check_counters_and_return_result(self, pm_counters_expression='', rd_counters_expression='', wait=True):
        self._setup_pm()
        out1 = []
        out2 = []
        pm_counters_expression = comm_obj.remove_empty_from_list(pm_counters_expression)
        rd_counters_expression = comm_obj.remove_empty_from_list(rd_counters_expression)
        # wait counter file generated
        if len(pm_counters_expression) != 0 or len(rd_counters_expression) != 0:
            if wait:
                counters_combined = pm_counters_expression + rd_counters_expression
                self._wait_counter_file_produced(counters_combined)

        if len(pm_counters_expression) != 0:
            out1 = self._analyze_counter_files(pm_counters_expression, "PM")
        if len(rd_counters_expression) != 0:
            out2 = self._analyze_counter_files(rd_counters_expression, "RD")
        return out1 + out2

    def _clear_counter_files(self, wait):
        self._setup_pm()
        current_time = self.fsm_obj.execute_command_on_enb("date +'%Y-%m-%d %H:%M:%S'", alias=self.alias)
        builtin_obj.log("current_time is %s in gnb" % current_time)
        min = current_time.split(":")[1]
        sec = current_time.split(":")[2]
        if wait:
            if self.pm_counter_interval == 1:
                remain_time = 60 - int(sec)
                time.sleep(remain_time)  # current 1min finished
                time.sleep(30)  # for counter file generated
            else:
                remain_time = (self.pm_counter_interval - int(min) % self.pm_counter_interval) * 60 - int(sec)
                time.sleep(remain_time)
                time.sleep(60)  # for counter file generated
        self.fsm_obj.execute_command_on_enb("rm -rf /tmp/PM*.gz /tmp/RD*.gz", alias=self.alias)

    def _wait_counter_file_produced(self, count_list):
        self._setup_pm()
        current_time = self.fsm_obj.execute_command_on_enb("date +'%Y-%m-%d %H:%M:%S'", alias=self.alias)
        builtin_obj.log("current_time is %s in gnb" % current_time)
        min = current_time.split(":")[1]
        sec = current_time.split(":")[2]
        if self.pm_counter_interval == 1:
            remain_time = 60 - int(sec)
            time.sleep(remain_time)  # current 1min finished
            time.sleep(30)  # for counter file generated
            time.sleep(60)  # wait for one more interval
        else:
            # current pm interval finished
            remain_time = (self.pm_counter_interval - int(min) % self.pm_counter_interval) * 60 - int(sec)
            time.sleep(remain_time)
            # if counter happened at last 1 minute, wait one more interval
            if remain_time < 60:
                time.sleep(self.pm_counter_interval * 60)
            # for counter file generated
            time.sleep(60)
        # if last in expression, wait one more interval
        for count in count_list:
            if count.count("last"):
                time.sleep(self.pm_counter_interval * 60)
                break
        builtin_obj.log("begin to download counter files")

    def _wait_before_next_pm_interval_start(self, time_before_start=120):
        self._setup_pm()
        time_before_start = random.randint(0, int(time_before_start))
        if self.pm_counter_interval == 5:
            current_time = self.fsm_obj.execute_command_on_enb("date +'%Y-%m-%d %H:%M:%S'", alias=self.alias)
            builtin_obj.log("current_time is %s in gnb" % current_time)
            min = current_time.split(":")[1]
            sec = current_time.split(":")[2]
            remain_time = (self.pm_counter_interval - int(min) % self.pm_counter_interval) * 60 - int(sec)
            if remain_time >= time_before_start:
                time.sleep(remain_time - int(time_before_start))
            else:
                time.sleep(remain_time)
                time.sleep(self.pm_counter_interval * 60 - time_before_start)

    def _get_counters_value(self, pm_counters, wait=True):
        self._setup_pm()
        pm_counters = comm_obj.remove_empty_from_list(pm_counters)
        # wait counter file produced
        if wait:
            self._wait_counter_file_produced(pm_counters)

        # download counter files and unzip
        counter_files_path = self._download_counter_files()

        # get counter
        counters_value = []
        for counter in pm_counters:
            # scope = None
            counter_mo = None
            measurement_type = None
            counter_name_or_id = None
            builtin_obj.log("step: counter: %s" % counter)
            if counter.count(":") == 0:
                counter_name_or_id = counter
            elif counter.count(":") == 1:
                counter_mo, counter_name_or_id = counter.split(":")
            elif counter.count(":") == 2:
                counter_mo, measurement_type, counter_name_or_id = counter.split(":")
            else:
                raise Exception("not support such format: %s" % counter)

            total_num_act = self._get_total_counter_value_from_counter_files(counter_files_path,
                                                                             counter_name_or_id, counter_mo,
                                                                             measurement_type)
            builtin_obj.log("step: the total value of %s is %s" % (counter, total_num_act))
            counters_value.append(total_num_act)
        return counters_value


class pm_bts1(object):

    def __init__(self):
        alias = "gnb1"
        self.pm_base_instance_1 = pm_base(alias)

    def clear_counter_files(self, wait=True):
        """This keyword is to clear counter files
        | step1 | wait for next pm counter interval start |
        | step2 | clear all counter files |

        | Input Parameters | Man. | Default | Description |
        | wait             | No   | True    | wait for pm counter interval before clear counter files or not |
        """
        self.pm_base_instance_1._clear_counter_files(wait)

    def check_counters_and_return_result(self, pm_counters_expression='', rd_counters_expression='', wait=True):
        """This keyword is to check PM counter and R&D counter
        | step1 | wait counter file produced |
        | step2 | download all counter files |
        | step3 | unzip all counter files and parse and calculate the total number, and return check list. |

        | Input Parameters | Man. | Description |
        | pm_counters_expression  | No   | pm counters expression list |
        | rd_counters_expression | No | rd counters expression list |
        | wait | No | wait current pm counter interval end. for two bts case, only need to wait for one time |

        format of pm_counters_expression:
        | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
        | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
        | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
        | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
        | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
        | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
        | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
        | 8) | "last " before the expression listed in 1)~5)  | check counter satisfying the expression in last pm
        counter interval. "last" can't be used together with expression 6) and 7) |
        | 9) | [mo:][measurement_type]:counter_id=value1|value2|value3... | eg: 1|2|3, The counter passes if the
        value is any one of 1,2,3 |
        | 10) | [mo:][measurement_type]:counter_id=[value1-value2] | eg: 1-3, Another way to write a range of
        values, The counter passes if the value is any one of 1,2,3 |

        format of rd_counters_expression: almost same as pm_counters_expression,
        the difference is that it uses counter_name not counter_id.\n

        Example:
        1)
        | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
        | ... | LNCEL-100:M8008C12>1 |  LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | last M8061C214<=900 |
        | ${result_list} | check_counters_and_return_result | ${pm_counters} |
        2)
        | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
        | ${result_list} | check_counters_and_return_result |  rd_counters_expression=${rd_counters} |
        3)
        | ${result_list} | check_counters_and_return_result |  ${pm_counters} | ${rd_counters} |
        """
        return self.pm_base_instance_1._check_counters_and_return_result(pm_counters_expression,
                                                                         rd_counters_expression, wait)

    def get_counters_value(self, pm_counters, wait=True):
        """This keyword is to get PM counters value
        | step1 | wait counter file produced at next pm counter interval |
        | step2 | download all counter files |
        | step3 | unzip all counter files and parse, calculate the total number and return counters value list. |

        | Input Parameters | Man. | Default | Description |
        | pm_counters      | Yes  | no      | pm counters list |
        | wait             | No   | True    | wait for pm counter interval before getting counters value or not |

        Format of pm_counters:
        | 1) | counter_id |
        | 2) | mo:counter_id |
        | 3) | mo:measurement_type:counter_id | this format is preferred |

        Example:
        | ${pm_counters} | Create List | M55308C11000 | NRCELL-1:M55308C11001 | NRCELL-1:NRANS:M55308C11002
        | ${M55308C11000_value} | ${M55308C11001_value} | ${M55308C11002_value} | get_counters_value | ${pm_counters} |
        | should_be_equal_as_integers | ${M55308C11000_value} | 1 |
        | should_be_equal_as_integers | ${M55308C11001_value} | 2 |
        | should_be_equal_as_integers | ${M55308C11002_value} | 2 |
        """
        return self.pm_base_instance_1._get_counters_value(pm_counters, wait)

    def get_current_bts_time(self):
        self.pm_base_instance_1._setup_pm()
        out = self.pm_base_instance_1.fsm_obj.execute_command_on_enb("date +'%Y-%m-%d %H:%M:%S'",
                                                                     alias=self.pm_base_instance_1.alias)
        return out

    def wait_before_next_pm_interval_start(self, time_before_start=120):
        """
        :param time_before_start: time before next pm interval start
        :return:
        """
        self.pm_base_instance_1._wait_before_next_pm_interval_start(time_before_start)


class pm_bts2(object):

    def __init__(self):
        alias = "gnb2"
        self.pm_base_instance_2 = pm_base(alias)

    def _setup_pm_bts2(self):
        self.pm_base_instance_2.bts_host = builtin_obj.get_variable_value('${GNB2_IP}')  # NG IP
        self.pm_base_instance_2.remote_host = builtin_obj.get_variable_value('${GNB2_PC_IP}')

    def clear_counter_files_gnb2(self, wait=False):
        """This keyword is to clear counter files
        | step1 | wait for next pm counter interval start |
        | step2 | clear all counter files |

        | Input Parameters | Man. | Default | Description |
        | wait             | No   | True    | wait for pm counter interval before clear counter files or not |
        """
        self._setup_pm_bts2()
        self.pm_base_instance_2._clear_counter_files(wait)

    def check_counters_and_return_result_gnb2(self, pm_counters_expression='', rd_counters_expression='', wait=False):
        """This keyword is to check PM counter and R&D counter
        | step1 | wait counter file produced at 15min |
        | step2 | download all counter files |
        | step3 | unzip all counter files and parse and calculate the total number, and return check list. |

        | Input Parameters | Man. | Description |
        | pm_counters_expression  | No   | pm counters expression list |
        | rd_counters_expression | No | rd counters expression list |
        | wait | No | wait for current pm counter interval end. for two gnbs case, only need to wait for one time |

        format of pm_counters_expression:
        | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
        | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
        | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
        | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
        | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
        | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
        | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
        | 8) | "last " before the expression listed in 1)~5)  | check counter satisfying the expression in last
        pm counter interval. "last" can't be used together with expression 6) and 7) |
        | 9) | [mo:][measurement_type]:counter_id=value1|value2|value3... | eg: 1|2|3, The counter passes if the
        value is any one of 1,2,3 |
        | 10) | [mo:][measurement_type]:counter_id=[value1-value2] | eg: 1-3, Another way to write a range of
        values, The counter passes if the value is any one of 1,2,3 |

        format of rd_counters_expression: almost same as pm_counters_expression,
        the difference is that it uses counter_name not counter_id.\n

        Example:
        1)
        | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
        | ... | LNCEL-100:M8008C12>1 |  LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | last M8061C214<=900 |
        | ${result_list} | check_counters_and_return_result_gnb2 | ${pm_counters} |
        2)
        | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
        | ${result_list} | check_counters_and_return_result_gnb2 |  rd_counters_expression=${rd_counters} |
        3)
        | ${result_list} | check_counters_and_return_result_gnb2 |  ${pm_counters} | ${rd_counters} |
        """
        self._setup_pm_bts2()
        return self.pm_base_instance_2._check_counters_and_return_result(pm_counters_expression,
                                                                         rd_counters_expression, wait)

    def get_counters_value_gnb2(self, pm_counters, wait=False):
        """This keyword is to get PM counters value
        | step1 | wait counter file produced at next pm counter interval |
        | step2 | download all counter files |
        | step3 | unzip all counter files and parse, calculate the total number and return counters value list. |

        | Input Parameters | Man. | Default | Description |
        | pm_counters      | Yes  | no      | pm counters list |
        | wait             | No   | True    | wait for pm counter interval before getting counters value or not |

        Format of pm_counters:
        | 1) | counter_id |
        | 2) | mo:counter_id |
        | 3) | mo:measurement_type:counter_id | this format is preferred |

        Example:
        | ${pm_counters} | Create List | M55308C11000 | NRCELL-1:M55308C11001 | NRCELL-1:NRANS:M55308C11002
        | ${M55308C11000_value} | ${M55308C11001_value} | ${M55308C11002_value} | get_counters_value_gnb2 |
        ${pm_counters} |
        | should_be_equal_as_integers | ${M55308C11000_value} | 1 |
        | should_be_equal_as_integers | ${M55308C11001_value} | 2 |
        | should_be_equal_as_integers | ${M55308C11002_value} | 2 |
        """
        self._setup_pm_bts2()
        return self.pm_base_instance_2._get_counters_value(pm_counters, wait)


class pm(pm_bts1, pm_bts2):
    def __init__(self):
        pm_bts1.__init__(self)
        pm_bts2.__init__(self)


if __name__ == "__main__":
    pm_obj = pm()
    help(pm_obj)
