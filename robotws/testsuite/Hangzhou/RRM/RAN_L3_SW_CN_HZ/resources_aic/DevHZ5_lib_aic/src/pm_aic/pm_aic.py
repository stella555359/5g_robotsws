# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

import time
import os
import re
from robot.libraries.OperatingSystem import OperatingSystem
from common_lib_aic import common_lib_aic
from base_lib.ta_xml.common_xml import CommonXML
from ute_fsmaccess import ute_fsmaccess
from ute_fsmaccess.exception import SSHExecutionError, WrongPartition, UnknownFsmHwVersion
from robot.libraries.BuiltIn import BuiltIn
from base_lib.ta_ssh_telnet import ta_ssh_telnet
from base_lib.ta_xml import ta_xml

comm_obj = common_lib_aic()
os_obj = OperatingSystem()
builtin_obj = BuiltIn()
ssh_obj = ta_ssh_telnet()
xml_obj = ta_xml()


class aic_pm_base(object):
    def __init__(self, alias):
        self._setup_comm_ssh_pm_flag_cu = False
        self._setup_comm_ssh_pm_flag_du = False
        self.alias = alias
        self.alias_cu = self.alias
        self.alias_du = self.alias
        self.remote_host = None
        self.pm_dir = '/mnt/services/SS_OAM/PMSTAT/pm_result_files/'
        self.rd_dir = '/mnt/services/SS_OAM/PMSTAT/pm_rad_result_files/'

    def _setup_common_ssh_pm_cu(self):
        """ssh can't instantiation twice with same name otherwise prompt Alias (cu) exists"""
        self.cu_host = builtin_obj.get_variable_value("${VCU_IP}")
        self.cu_host_ssh = builtin_obj.get_variable_value("${VCU_SSH_IP}")
        self.cu_host_ssh_usr = builtin_obj.get_variable_value("${VCU_SSH_USER}")
        self.cu_host_ssh_pwd = builtin_obj.get_variable_value("${VCU_SSH_PASSWD}")
        self.cu_namespace = builtin_obj.get_variable_value("${VCU_NAMESPACE}")
        if self.alias_cu.count("gnb2"):
            self.cu_host = builtin_obj.get_variable_value("${VCU2_IP}")
            self.cu_host_ssh = builtin_obj.get_variable_value("${VCU2_SSH_IP}")
            self.cu_host_ssh_usr = builtin_obj.get_variable_value("${VCU2_SSH_USER}")
            self.cu_host_ssh_pwd = builtin_obj.get_variable_value("${VCU2_SSH_PASSWD}")
        if not self._setup_comm_ssh_pm_flag_cu:
            self._setup_comm_ssh_pm_flag_cu = True
            self.pm_counter_interval = builtin_obj.get_variable_value("${PM_COUNTER_INTERVAL}").rstrip("min")
            self.pm_counter_interval = int(self.pm_counter_interval)
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias_cu, prompt="$",
                                              user=self.cu_host_ssh_usr, password=self.cu_host_ssh_pwd,
                                              fallback_prompt="$", host=self.cu_host_ssh)
        if self._setup_comm_ssh_pm_flag_cu:
            if not self.fsm_obj:
                self.fsm_obj = ute_fsmaccess()
                self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias_cu,
                                                  fallback_prompt="$", host=self.cu_host_ssh)

    def _setup_common_ssh_pm_du(self):
        """ssh can't instantiation twice with same name otherwise prompt Alias (du) exists"""
        if not self._setup_comm_ssh_pm_flag_du:
            self._setup_comm_ssh_pm_flag_du = True
            self.pm_counter_interval = builtin_obj.get_variable_value("${PM_COUNTER_INTERVAL}").rstrip("min")
            self.pm_counter_interval = int(self.pm_counter_interval)
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias_du, prompt="$",
                                              user=self.du_host_ssh_usr, password=self.du_host_ssh_pwd,
                                              fallback_prompt="$", host=self.du_host_ssh)
        if self._setup_comm_ssh_pm_flag_du:
            if not self.fsm_obj:
                self.fsm_obj = ute_fsmaccess()
                self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias_du,
                                                  fallback_prompt="$", host=self.du_host_ssh)

    def __del__(self):
        if self._setup_comm_ssh_pm_flag_cu:
            self.fsm_obj.teardown_all_aliases_for_enb_fsmaccess()
            self._setup_comm_ssh_pm_flag_cu = False
        if self._setup_comm_ssh_pm_flag_du:
            self.fsm_obj.teardown_all_aliases_for_enb_fsmaccess()
            self._setup_comm_ssh_pm_flag_du = False

    def _list_counter_files(self, local_counter_path):
        # counter file name: PM.BTS-1.20180705.070000.ANY.xml.xz, PM.BTS-1.20180705.070000.ANY.raw.xz,
        # PM.BTS-1.20180705.071500.ANY.raw.xz
        out_files = []
        zip_files = os_obj.list_files_in_directory(local_counter_path)
        zip_files.sort()
        for index in range(len(zip_files)):
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
            countervalue = sum(map(lambda e: int(e.text), elements))
            counter_values.append(countervalue)
        return counter_values

    def _get_total_counter_value_from_counter_files(self, counterfiles, counterid,
                                                    counter_mo=None, counter_type=None):
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
                countervalue = sum(map(lambda e: int(e.text), elements))
                builtin_obj.log("counter file '%s' : xpath '%s' value is '%s'" % (counterfile, xpath, countervalue))
                total_value += countervalue
            else:
                builtin_obj.log("counter file '%s' : xpath '%s' doesn't exist" % (counterfile, xpath))
        # counter not exiting
        if find_num == 0:
            total_value = -1
        return total_value

    def _download_counter_files_cu(self, counter_type="PM"):
        self._setup_common_ssh_pm_cu()
        save_log_directory = comm_obj._get_save_log_dir(self.alias_cu)
        local_counter_path = os.path.join(save_log_directory,
                                          "%s_counters_%s/" % (counter_type, comm_obj.get_timestamp()))
        os_obj.create_directory(local_counter_path)
        if counter_type == "PM":
            self.fsm_obj.get_enb_file(os.path.join("/tmp/%s/tmp_%s" % (self.cu_namespace, counter_type), "A2*"),
                                      local_counter_path, alias=self.alias_cu)
        if counter_type == "RD":
            self.fsm_obj.get_enb_file(os.path.join("/tmp/%s/tmp_%s" % (self.cu_namespace, counter_type), "RD*"),
                                      local_counter_path, alias=self.alias_cu)
        zip_files = self._list_counter_files(local_counter_path)
        for each_file in zip_files:
            comm_obj.uncompress_file(os.path.join(local_counter_path, each_file))
        return local_counter_path

    def _download_counter_files_du(self, counter_type="PM"):
        self._setup_common_ssh_pm_du()
        save_log_directory = comm_obj._get_save_log_dir(self.alias_du)
        local_counter_path = os.path.join(save_log_directory,
                                          "%s_counters_%s/" % (counter_type, comm_obj.get_timestamp()))
        os_obj.create_directory(local_counter_path)
        if counter_type == "PM":
            self.fsm_obj.get_enb_file(os.path.join("/tmp/%s/tmp_%s" % (self.du_namespace, counter_type), "A2*"),
                                      local_counter_path, alias=self.alias_du)
        if counter_type == "RD":
            self.fsm_obj.get_enb_file(os.path.join("/tmp/%s/tmp_%s" % (self.du_namespace, counter_type), "RD*"),
                                      local_counter_path, alias=self.alias_du)
        zip_files = self._list_counter_files(local_counter_path)
        for each_file in zip_files:
            comm_obj.uncompress_file(os.path.join(local_counter_path, each_file))
        return local_counter_path

    def _download_counter_files_from_container_cu(self, counter_type="PM"):
        self.pm_pod_full_name_cu = builtin_obj.get_variable_value("${pm_pod_full_name_cu}")
        self.pm_container_full_name_cu = builtin_obj.get_variable_value("${pm_container_full_name_cu}")
        try:
            self.fsm_obj.execute_command_on_enb("rm /tmp/%s/tmp_%s/*  -rf" % (self.cu_namespace, counter_type),
                                                alias=self.alias_cu)
        except SSHExecutionError:
            pass
        try:
            self.fsm_obj.execute_command_on_enb("mkdir -p /tmp/%s/tmp_%s " % (self.cu_namespace, counter_type),
                                                alias=self.alias_cu)
        except SSHExecutionError:
            pass
        if counter_type == "PM":
            tar_cmd = (
                "kubectl exec -i " + self.pm_pod_full_name_cu + " -n " + self.cu_namespace + " -c "
                + self.pm_container_full_name_cu + " -- tar cvPf " + self.pm_dir + "pm.tar " + self.pm_dir)
            cp_cmd = (
                    "kubectl exec " + self.pm_pod_full_name_cu + " -n " + self.cu_namespace + " -c "
                    + self.pm_container_full_name_cu + " -- cat " + self.pm_dir +
                    "pm.tar > " + "/tmp/%s/tmp_%s/" % (self.cu_namespace, counter_type) + "pm.tar")
        if counter_type == "RD":
            tar_cmd = (
                    "kubectl exec -i " + self.pm_pod_full_name_cu + " -n " + self.cu_namespace + " -c "
                    + self.pm_container_full_name_cu + " -- tar cvPf " + self.rd_dir + "rd.tar " + self.rd_dir)
            cp_cmd = (
                    "kubectl exec " + self.pm_pod_full_name_cu + " -n " + self.cu_namespace + " -c "
                    + self.pm_container_full_name_cu + " -- cat " + self.rd_dir +
                    "rd.tar > " + "/tmp/%s/tmp_%s/" % (self.cu_namespace, counter_type) + "rd.tar")
        try:
            self.fsm_obj.execute_command_on_enb(tar_cmd, alias=self.alias_cu)
        except Exception as e:
            print(e)
        self.fsm_obj.execute_command_on_enb(cp_cmd, alias=self.alias_cu)

    def _download_counter_files_from_container_du(self, counter_type="PM"):
        try:
            self.fsm_obj.execute_command_on_enb("rm /tmp/%s/tmp_%s/*  -rf" % (self.du_namespace, counter_type),
                                                alias=self.alias_du)
        except SSHExecutionError:
            pass
        try:
            self.fsm_obj.execute_command_on_enb("mkdir -p /tmp/%s/tmp_%s " % (self.du_namespace, counter_type),
                                                alias=self.alias_du)
        except SSHExecutionError:
            pass
        if counter_type == "PM":
            tar_cmd = (
                "kubectl exec -i " + self.pm_pod_full_name_du + " -n " + self.du_namespace + " -c "
                + self.pm_container_full_name_du + " -- tar cvPf " + self.pm_dir + "pm.tar " + self.pm_dir)
            cp_cmd = (
                    "kubectl exec " + self.pm_pod_full_name_du + " -n " + self.du_namespace + " -c "
                    + self.pm_container_full_name_du + " -- cat " + self.pm_dir +
                    "pm.tar > " + "/tmp/%s/tmp_%s/" % (self.du_namespace, counter_type) + "pm.tar")
        if counter_type == "RD":
            tar_cmd = (
                    "kubectl exec -i " + self.pm_pod_full_name_du + " -n " + self.du_namespace + " -c "
                    + self.pm_container_full_name_du + " -- tar cvPf " + self.rd_dir + "rd.tar " + self.rd_dir)
            cp_cmd = (
                    "kubectl exec " + self.pm_pod_full_name_du + " -n " + self.du_namespace + " -c "
                    + self.pm_container_full_name_du + " -- cat " + self.rd_dir +
                    "rd.tar > " + "/tmp/%s/tmp_%s/" % (self.du_namespace, counter_type) + "rd.tar")
        try:
            self.fsm_obj.execute_command_on_enb(tar_cmd, alias=self.alias_du)
        except Exception as e:
            print(e)
            pass
        self.fsm_obj.execute_command_on_enb(cp_cmd, alias=self.alias_du)

    def _untar_pm_tar_gz_cu(self, counter_type):
        untar_cmd = "cd /tmp/%s/tmp_%s && tar -xvf %s.tar --strip-components 5" % (self.cu_namespace, counter_type,
                                                                                   counter_type.lower())
        self.fsm_obj.execute_command_on_enb(untar_cmd, alias=self.alias_cu)
        rm_cmd = "cd /tmp/%s/tmp_%s && rm %s.tar -rf" % (self.cu_namespace, counter_type, counter_type.lower())
        self.fsm_obj.execute_command_on_enb(rm_cmd, alias=self.alias_cu)

    def _untar_pm_tar_gz_du(self, counter_type):
        untar_cmd = "cd /tmp/%s/tmp_%s && tar -xvf %s.tar --strip-components 5" % (self.du_namespace, counter_type,
                                                                                   counter_type.lower())
        self.fsm_obj.execute_command_on_enb(untar_cmd, alias=self.alias_du)
        rm_cmd = "cd /tmp/%s/tmp_%s && rm %s.tar -rf" % (self.du_namespace, counter_type, counter_type.lower())
        self.fsm_obj.execute_command_on_enb(rm_cmd, alias=self.alias_du)

    def _analyze_counter_files_cu(self, counters_expression, counter_type="PM"):
        self._setup_common_ssh_pm_cu()
        counters_expression = comm_obj.remove_empty_from_list(counters_expression)

        # get counter files from container to host
        self._download_counter_files_from_container_cu(counter_type)
        self._untar_pm_tar_gz_cu(counter_type)

        # download and unzip counter files
        local_counter_path = self._download_counter_files_cu(counter_type)
        # get counter files list
        if counter_type == "PM":
            counter_files = os_obj.list_files_in_directory(local_counter_path, "A2*.xml")
        if counter_type == "RD":
            counter_files = os_obj.list_files_in_directory(local_counter_path, "RD*.xml")
        if len(counter_files) == 0:
            raise Exception("no counter files")
        counter_files_path = []
        for counter_file in counter_files:
            counter_files_path.append(os.path.join(local_counter_path, counter_file))
        builtin_obj.log("step: counter files %s will be analyzed" % counter_files_path)
        counter_result_list = []
        # analyze counter
        for counter_exp in counters_expression:
            scope = None
            counter_mo = None
            counter_type = None
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
                counter_mo, counter_type, counter_exp_short = counter_exp.split(":")
            else:
                raise Exception("not support such format: %s" % counter_exp)

            match = re.search(r"([^!<>=]+)([!><=]+)(.*)", counter_exp_short, re.I)
            if match is not None:
                counter_name_or_id = match.group(1).strip()
                express = match.group(2)
                value_exp = match.group(3).strip()
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
                            counter_file, counter_name_or_id, counter_mo, counter_type)
                        builtin_obj.log("the values of counter %s in file %s are: %s"
                                        % (counter_name_or_id, counter_file, counter_values))
                        for value_act in counter_values:
                            if eval("%s%s%s" % (value_act, express, value_exp)):
                                result = "passed"
                                builtin_obj.log(" %s value in %s is %s, checking it should %s %s, result is %s"
                                                % (counter_without_value, counter_file, value_act,
                                                   express, int(value_exp), result))
                            else:
                                result = "failed"
                                builtin_obj.log("%s value in %s is %s, checking it should %s %s, result is %s"
                                                % (counter_without_value, counter_file, value_act,
                                                   express, int(value_exp), result), level="WARN")
                                break
                    counter_result_list.append([counter_name_or_id, value_act, result])
                    continue

                if scope == "last":
                    counter_file_last_list = []
                    counter_file_last_one_timeslot = counter_files_path[-1].split("_MRBTS-")[0]
                    # serach from last counter file to first one in counter_files_path.
                    for i in range(len(counter_files_path) - 1, -1, -1):
                        comp_c_file = counter_files_path[i].split("_MRBTS-")[0]
                        if comp_c_file == counter_file_last_one_timeslot:
                            counter_file_last_list.append(counter_files_path[i])
                    # find the unique counter file, otherwise raise error.
                    counter_file_last_check_list = []
                    for j in counter_file_last_list:
                        counter_ret = comm_obj.execute_cmd_on_pc("grep -r '%s' %s" % (counter_name_or_id, j))
                        if counter_ret.count("<%s>" % counter_name_or_id) and j not in counter_file_last_check_list:
                            counter_file_last_check_list.append(j)
                    if len(counter_file_last_check_list) > 1:
                        raise Exception(
                            "Found multi counter file contain counter %s:%s" % (counter_name_or_id,
                                                                                counter_file_last_check_list))
                    if len(counter_file_last_check_list) == 0:
                        raise Exception("No counter file contain counter:%s" % counter_name_or_id)
                    # check last_counter
                    counter_values = self._get_counter_values_from_counter_file(counter_file_last_check_list[0],
                                                                                counter_name_or_id, counter_mo,
                                                                                counter_type)
                    builtin_obj.log("the values of counter %s in file %s are: %s" % (counter_name_or_id,
                                                                                     counter_file_last_check_list[0],
                                                                                     counter_values))
                    last_value = counter_values[-1]
                    if eval("%s%s%s" % (last_value, express, value_exp)):
                        result = "passed"
                        builtin_obj.log(" %s last value in %s is %s, checking it should %s %s, result is %s" % (
                            counter_without_value, counter_file_last_check_list[0], last_value, express,
                            int(value_exp), result))
                    else:
                        result = "failed"
                        builtin_obj.log("%s last value in %s is %s, checking it should %s %s, result is %s" % (
                            counter_without_value, counter_file_last_check_list[0], last_value, express,
                            int(value_exp), result), level="WARN")
                    counter_result_list.append([counter_name_or_id, last_value, result])
                    continue

                if value_exp == "existing":
                    total_num_act = self._get_total_counter_value_from_counter_files(
                        counter_files_path, counter_name_or_id, counter_mo, counter_type)
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
                        counter_files_path, counter_name_or_id, counter_mo, counter_type)
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
                                                                                     counter_type)
                    if total_num_act != -1:
                        if eval("%s%s%s" % (total_num_act, express, value_exp)):
                            result = "passed"
                            builtin_obj.log("total number of %s is %s, checking it should %s %s, result is %s" % (
                                counter_without_value, total_num_act, express, int(value_exp), result))
                        else:
                            result = "failed"
                            builtin_obj.log("total number of %s is %s, checking it should %s %s, result is %s" % (
                                counter_without_value, total_num_act, express, int(value_exp), result), level="WARN")
                    else:
                        result = "failed"
                        total_num_act = 0
                        builtin_obj.log("checking counter %s should %s %s, but it doesn't exist" % (
                            counter_without_value, express, int(value_exp)), level="WARN")
                counter_result_list.append([counter_name_or_id, total_num_act, result])
            else:
                raise Exception("not support expression %s" % counter_exp)

        out_list = []
        for counter_result in counter_result_list:
            if counter_result not in out_list:
                out_list.append(counter_result)
        return out_list

    def _analyze_counter_files_du(self, counters_expression, counter_type="PM"):
        self._setup_common_ssh_pm_du()
        counters_expression = comm_obj.remove_empty_from_list(counters_expression)

        # get counter files from container to host
        self._download_counter_files_from_container_du(counter_type)
        self._untar_pm_tar_gz_du(counter_type)

        # download and unzip counter files
        local_counter_path = self._download_counter_files_du(counter_type)
        # get counter files list
        if counter_type == "PM":
            counter_files = os_obj.list_files_in_directory(local_counter_path, "A2*.xml")
        if counter_type == "RD":
            counter_files = os_obj.list_files_in_directory(local_counter_path, "RD*.xml")
        if len(counter_files) == 0:
            raise Exception("no counter files")
        counter_files_path = []
        for counter_file in counter_files:
            counter_files_path.append(os.path.join(local_counter_path, counter_file))
        builtin_obj.log("step: counter files %s will be analyzed" % counter_files_path)
        counter_result_list = []
        # analyze counter
        for counter_exp in counters_expression:
            scope = None
            counter_mo = None
            counter_type = None
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
                counter_mo, counter_type, counter_exp_short = counter_exp.split(":")
            else:
                raise Exception("not support such format: %s" % counter_exp)

            match = re.search(r"([^!<>=]+)([!><=]+)(.*)", counter_exp_short, re.I)
            if match is not None:
                counter_name_or_id = match.group(1).strip()
                express = match.group(2)
                value_exp = match.group(3).strip()
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
                            counter_file, counter_name_or_id, counter_mo, counter_type)
                        builtin_obj.log("the values of counter %s in file %s are: %s"
                                        % (counter_name_or_id, counter_file, counter_values))
                        for value_act in counter_values:
                            if eval("%s%s%s" % (value_act, express, value_exp)):
                                result = "passed"
                                builtin_obj.log(" %s value in %s is %s, checking it should %s %s, result is %s"
                                                % (counter_without_value, counter_file, value_act,
                                                   express, int(value_exp), result))
                            else:
                                result = "failed"
                                builtin_obj.log("%s value in %s is %s, checking it should %s %s, result is %s"
                                                % (counter_without_value, counter_file, value_act,
                                                   express, int(value_exp), result), level="WARN")
                                break
                    counter_result_list.append([counter_name_or_id, value_act, result])
                    continue

                if scope == "last":
                    counter_file_last_list = []
                    counter_file_last_one_timeslot = counter_files_path[-1].split("_MRBTS-")[0]
                    # serach from last counter file to first one in counter_files_path.
                    for i in range(len(counter_files_path) - 1, -1, -1):
                        comp_c_file = counter_files_path[i].split("_MRBTS-")[0]
                        if comp_c_file == counter_file_last_one_timeslot:
                            counter_file_last_list.append(counter_files_path[i])
                    # find the unique counter file, otherwise raise error.
                    counter_file_last_check_list = []
                    for j in counter_file_last_list:
                        counter_ret = comm_obj.execute_cmd_on_pc("grep -r '%s' %s" % (counter_name_or_id, j))
                        if counter_ret.count("<%s>" % counter_name_or_id) and j not in counter_file_last_check_list:
                            counter_file_last_check_list.append(j)
                    if len(counter_file_last_check_list) > 1:
                        raise Exception(
                            "Found multi counter file contain counter %s:%s" % (counter_name_or_id,
                                                                                counter_file_last_check_list))
                    if len(counter_file_last_check_list) == 0:
                        raise Exception("No counter file contain counter:%s" % counter_name_or_id)
                    # check last_counter
                    counter_values = self._get_counter_values_from_counter_file(counter_file_last_check_list[0],
                                                                                counter_name_or_id, counter_mo,
                                                                                counter_type)
                    builtin_obj.log("the values of counter %s in file %s are: %s" % (counter_name_or_id,
                                                                                     counter_file, counter_values))
                    last_value = counter_values[-1]
                    if eval("%s%s%s" % (last_value, express, value_exp)):
                        result = "passed"
                        builtin_obj.log(" %s last value in %s is %s, checking it should %s %s, result is %s" % (
                            counter_without_value, counter_file, last_value, express, int(value_exp), result))
                    else:
                        result = "failed"
                        builtin_obj.log("%s last value in %s is %s, checking it should %s %s, result is %s" % (
                            counter_without_value, counter_file, last_value, express, int(value_exp), result),
                                        level="WARN")
                    counter_result_list.append([counter_name_or_id, last_value, result])
                    continue

                if value_exp == "existing":
                    total_num_act = self._get_total_counter_value_from_counter_files(
                        counter_files_path, counter_name_or_id, counter_mo, counter_type)
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
                        counter_files_path, counter_name_or_id, counter_mo, counter_type)
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
                                                                                     counter_type)
                    if total_num_act != -1:
                        if eval("%s%s%s" % (total_num_act, express, value_exp)):
                            result = "passed"
                            builtin_obj.log("total number of %s is %s, checking it should %s %s, result is %s" % (
                                counter_without_value, total_num_act, express, int(value_exp), result))
                        else:
                            result = "failed"
                            builtin_obj.log("total number of %s is %s, checking it should %s %s, result is %s" % (
                                counter_without_value, total_num_act, express, int(value_exp), result), level="WARN")
                    else:
                        result = "failed"
                        total_num_act = 0
                        builtin_obj.log("checking counter %s should %s %s, but it doesn't exist" % (
                            counter_without_value, express, int(value_exp)), level="WARN")
                counter_result_list.append([counter_name_or_id, total_num_act, result])
            else:
                raise Exception("not support expression %s" % counter_exp)

        out_list = []
        for counter_result in counter_result_list:
            if counter_result not in out_list:
                out_list.append(counter_result)
        return out_list

    def _check_counters_and_return_result_cu(self, pm_counters_expression='',
                                             rd_counters_expression='', wait=True):
        self.pm_pod_full_name_cu = builtin_obj.get_variable_value("${pm_pod_full_name_cu}")
        self.pm_container_full_name_cu = builtin_obj.get_variable_value("${pm_container_full_name_cu}")
        self._setup_common_ssh_pm_cu()
        out1 = []
        out2 = []
        pm_counters_expression = comm_obj.remove_empty_from_list(pm_counters_expression)
        rd_counters_expression = comm_obj.remove_empty_from_list(rd_counters_expression)
        # wait counter file produced
        if len(pm_counters_expression) != 0 or len(rd_counters_expression) != 0:
            if wait:
                counters_combined = pm_counters_expression + rd_counters_expression
                time_cmd = (
                    "kubectl exec -i " + self.pm_pod_full_name_cu + " -n " + self.cu_namespace + " -c " +
                    self.pm_container_full_name_cu + " -- date '+%Y-%m-%d %H:%M:%S'")
                current_time = self.fsm_obj.execute_command_on_enb(time_cmd, alias=self.alias_cu)
                self._wait_counter_file_produced_aic(counters_combined, current_time)

        if len(pm_counters_expression) != 0:
            out1 = self._analyze_counter_files_cu(pm_counters_expression, "PM")
        if len(rd_counters_expression) != 0:
            out2 = self._analyze_counter_files_cu(rd_counters_expression, "RD")
        return out1 + out2

    def _check_counters_and_return_result_du(self, pm_counters_expression='', rd_counters_expression='', wait=True):
        self._setup_common_ssh_pm_du()
        out1 = []
        out2 = []
        pm_counters_expression = comm_obj.remove_empty_from_list(pm_counters_expression)
        rd_counters_expression = comm_obj.remove_empty_from_list(rd_counters_expression)
        # wait counter file produced
        if len(pm_counters_expression) != 0 or len(rd_counters_expression) != 0:
            if wait:
                counters_combined = pm_counters_expression + rd_counters_expression
                time_cmd = (
                    "kubectl exec -i " + self.pm_pod_full_name_du + " -n " + self.du_namespace + " -c " +
                    self.pm_container_full_name_du + " -- date '+%Y-%m-%d %H:%M:%S'")
                current_time = self.fsm_obj.execute_command_on_enb(time_cmd, alias=self.alias_du)
                self._wait_counter_file_produced_aic(counters_combined, current_time)

        if len(pm_counters_expression) != 0:
            out1 = self._analyze_counter_files_du(pm_counters_expression, "PM")
        if len(rd_counters_expression) != 0:
            out2 = self._analyze_counter_files_du(rd_counters_expression, "RD")
        return out1 + out2

    def _clear_counter_files_cu(self, wait):
        """
        counter period is 5 minute default in Aic framework, can support set 15 min also.
        """
        self.pm_pod_full_name_cu = builtin_obj.get_variable_value("${pm_pod_full_name_cu}")
        self.pm_container_full_name_cu = builtin_obj.get_variable_value("${pm_container_full_name_cu}")
        self._setup_common_ssh_pm_cu()
        rm_file_cmd_pm = (
                "kubectl exec -i " + self.pm_pod_full_name_cu + " -n " + self.cu_namespace + " -c "
                + self.pm_container_full_name_cu + " -- bash -c 'cd %s;ls -1|xargs rm '" % self.pm_dir)
        rm_file_cmd_rd = (
                "kubectl exec -i " + self.pm_pod_full_name_cu + " -n " + self.cu_namespace + " -c "
                + self.pm_container_full_name_cu + " -- bash -c 'cd %s;ls -1|xargs rm '" % self.rd_dir)
        container_bash_cmd = ("kubectl exec -ti " + self.pm_pod_full_name_cu + " -n " + self.cu_namespace
                              + " -c " + self.pm_container_full_name_cu + " -- bash")
        builtin_obj.log(rm_file_cmd_pm)
        builtin_obj.log(rm_file_cmd_rd)
        time_cmd = (
            "kubectl exec -i " + self.pm_pod_full_name_cu + " -n " + self.cu_namespace + " -c "
            + self.pm_container_full_name_cu + " -- date '+%Y-%m-%d %H:%M:%S'")
        builtin_obj.log(time_cmd)
        current_time = self.fsm_obj.execute_command_on_enb(time_cmd, alias=self.alias_cu)
        builtin_obj.log("current_time is %s in cu" % current_time)
        min = current_time.split(":")[1]
        sec = current_time.split(":")[2]
        if wait:
            remain_time = (self.pm_counter_interval - int(min) % self.pm_counter_interval) * 60 - int(sec)
            time.sleep(remain_time)
            time.sleep(60)  # for counter file generated
        try:
            self.fsm_obj.execute_command_on_enb(rm_file_cmd_pm, alias=self.alias_cu)
        except Exception as e:
            print(e)
            comm_obj.execute_cmd_on_vcu_container(cmd="cd %s;rm -rf *" % self.pm_dir,
                                                  container_bash=container_bash_cmd)
        time.sleep(0.5)  # for wait pm remove finish
        try:
            self.fsm_obj.execute_command_on_enb(rm_file_cmd_rd, alias=self.alias_cu)
        except Exception as e:
            print(e)
            comm_obj.execute_cmd_on_vcu_container(cmd="cd %s;rm -rf *" % self.rd_dir,
                                                  container_bash=container_bash_cmd)

    def _clear_counter_files_du(self, wait):
        """
        counter period is 5 minute default in Aic framework, can support set 15 min also.
        """
        self._setup_common_ssh_pm_du()
        rm_file_cmd_pm = (
                "kubectl exec -i " + self.pm_pod_full_name_du + " -n " + self.du_namespace + " -c "
                + self.pm_container_full_name_du + " -- bash -c 'cd %s;ls -1|xargs rm '" % self.pm_dir)
        rm_file_cmd_rd = (
                "kubectl exec -i " + self.pm_pod_full_name_du + " -n " + self.du_namespace + " -c "
                + self.pm_container_full_name_du + " -- bash -c 'cd %s;ls -1|xargs rm '" % self.rd_dir)
        time_cmd = (
            "kubectl exec -i " + self.pm_pod_full_name_du + " -n " + self.du_namespace + " -c "
            + self.pm_container_full_name_du + " -- date '+%Y-%m-%d %H:%M:%S'")
        container_bash_cmd = ("kubectl exec -ti " + self.pm_pod_full_name_du + " -n " + self.du_namespace
                              + " -c " + self.pm_container_full_name_du + " -- bash")
        current_time = self.fsm_obj.execute_command_on_enb(time_cmd, alias=self.alias_du)
        builtin_obj.log("current_time is %s in du" % current_time)
        min = current_time.split(":")[1]
        sec = current_time.split(":")[2]
        if wait:
            remain_time = (self.pm_counter_interval - int(min) % self.pm_counter_interval) * 60 - int(sec)
            time.sleep(remain_time)
            time.sleep(60)  # for counter file generated
        try:
            self.fsm_obj.execute_command_on_enb(rm_file_cmd_pm, alias=self.alias_du)
        except Exception as e:
            print(e)
            comm_obj.execute_cmd_on_vdu_container(cmd="cd %s;rm -rf *" % self.pm_dir,
                                                  container_bash=container_bash_cmd)
        time.sleep(0.5)
        try:
            self.fsm_obj.execute_command_on_enb(rm_file_cmd_rd, alias=self.alias_du)
        except Exception as e:
            print(e)
            comm_obj.execute_cmd_on_vdu_container(cmd="cd %s;rm -rf *" % self.rd_dir,
                                                  container_bash=container_bash_cmd)

    def _wait_counter_file_produced_aic(self, count_list, current_time):
        # self._setup_common_ssh_pm()
        builtin_obj.log("current_time is %s in aic" % current_time)
        min = current_time.split(":")[1]
        sec = current_time.split(":")[2]
        if self.pm_counter_interval == 1:
            raise Exception("illegal ${PM_COUNTER_INTERVAL}:%s, only support 5min or 15min" % self.pm_counter_interval)
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

    def _get_counters_value_cu(self, pm_counters, wait=True, counter_type="PM"):
        self.pm_pod_full_name_cu = builtin_obj.get_variable_value("${pm_pod_full_name_cu}")
        self.pm_container_full_name_cu = builtin_obj.get_variable_value("${pm_container_full_name_cu}")
        self._setup_common_ssh_pm_cu()
        pm_counters = comm_obj.remove_empty_from_list(pm_counters)

        # wait counter file produced
        if wait:
            time_cmd = (
                    "kubectl exec -i " + self.pm_pod_full_name_cu + " -n " + self.cu_namespace + " -c " +
                    self.pm_container_full_name_cu + " -- date '+%Y-%m-%d %H:%M:%S'")
            current_time = self.fsm_obj.execute_command_on_enb(time_cmd, alias=self.alias_cu)
            self._wait_counter_file_produced_aic(pm_counters, current_time)

        # get counter files from container to host
        self._download_counter_files_from_container_cu(counter_type)
        self._untar_pm_tar_gz_cu(counter_type)

        # download and unzip counter files
        local_counter_path = self._download_counter_files_cu(counter_type=counter_type)
        # get PM counter files list
        counter_files = os_obj.list_files_in_directory(local_counter_path, "A2*.xml")

        if len(counter_files) == 0:
            raise Exception("no counter files")

        counter_files_path = []
        for counter_file in counter_files:
            counter_files_path.append(os.path.join(local_counter_path, counter_file))

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

    def _get_counters_value_du(self, pm_counters, wait=True, counter_type="PM"):
        self._setup_common_ssh_pm_du()
        pm_counters = comm_obj.remove_empty_from_list(pm_counters)

        # wait counter file produced
        if wait:
            time_cmd = (
                    "kubectl exec -i " + self.pm_pod_full_name_du + " -n " + self.du_namespace + " -c " +
                    self.pm_container_full_name_du + " -- date '+%Y-%m-%d %H:%M:%S'")
            current_time = self.fsm_obj.execute_command_on_enb(time_cmd, alias=self.alias_du)
            self._wait_counter_file_produced_aic(pm_counters, current_time)

        # get counter files from container to host
        self._download_counter_files_from_container_du(counter_type)
        self._untar_pm_tar_gz_du(counter_type)

        # download and unzip counter files
        local_counter_path = self._download_counter_files_du(counter_type=counter_type)
        # get PM counter files list
        counter_files = os_obj.list_files_in_directory(local_counter_path, "A2*.xml")

        if len(counter_files) == 0:
            raise Exception("no counter files")

        counter_files_path = []
        for counter_file in counter_files:
            counter_files_path.append(os.path.join(local_counter_path, counter_file))

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


class aic_pm_gnb1_cu(object):

    def __init__(self):
        alias = "gnb1_cu_pm"
        self.pm_base_instance_1 = aic_pm_base(alias)

    def clear_counter_files_cu(self, wait=True):
        """
        clear counter files at next 1 minute(counter period is changed to every minute due to 0x340000=15).
        """
        self.pm_base_instance_1._clear_counter_files_cu(wait)

    def check_counters_and_return_result_cu(self, pm_counters_expression='', rd_counters_expression='', wait=True):
        """This keyword is to check PM counter and R&D counter
        | step1 | wait counter file produced |
        | step2 | download all counter files |
        | step3 | unzip all counter files and parse and calculate the total number, and return check list. |

        | Input Parameters | Man. | Description |
        | pm_counters_expression  | No   | pm counters expression list |
        | rd_counters_expression | No | rd counters expression list |
        | wait | No | wait for pm counter interval. for two gnbs case, only need to wait for one time |

        format of pm_counters_expression:
        | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
        | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
        | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
        | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
        | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
        | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
        | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
        | 8) | "every " before the expression listed in 1)~7) | check counter satisfying the expression
        in every pm counter interval. it is 15min for pm counter |

        format of rd_counters_expression: almost same as pm_counters_expression,like as M55131CRD50001

        Example:
        1)
        | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
        | ... | LNCEL-100:M8008C12>1 |  LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | every M8061C214<=900 |
        | ${result_list} | check_counters_and_return_result | ${pm_counters} |
        2)
        | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
        | ${result_list} | check_counters_and_return_result |  rd_counters_expression=${rd_counters} |
        3)
        | ${result_list} | check_counters_and_return_result |  ${pm_counters} | ${rd_counters} |
        """
        return self.pm_base_instance_1._check_counters_and_return_result_cu(pm_counters_expression,
                                                                            rd_counters_expression, wait)

    def get_current_bts_time(self):
        self.pm_base_instance_1._setup_common_ssh_pm_cu()
        out = self.pm_base_instance_1.fsm_obj.execute_command_on_enb("date +'%Y-%m-%d %H:%M:%S'",
                                                                     alias=self.pm_base_instance_1.alias)
        return out

    def get_counters_value_cu_aic(self, pm_counters, wait=True):
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
        return self.pm_base_instance_1._get_counters_value_cu(pm_counters, wait)


class aic_pm_gnb1_du(object):

    def __init__(self):
        alias = "gnb1_du_pm"
        self.pm_base_instance_2 = aic_pm_base(alias)

    def _setup_pm_gnb1_du(self):
        self.pm_base_instance_2.du_host = builtin_obj.get_variable_value("${VDU_IP}")
        self.pm_base_instance_2.du_host_ssh = builtin_obj.get_variable_value("${VDU_SSH_IP}")
        self.pm_base_instance_2.du_host_ssh_usr = builtin_obj.get_variable_value("${VDU_SSH_USER}")
        self.pm_base_instance_2.du_host_ssh_pwd = builtin_obj.get_variable_value("${VDU_SSH_PASSWD}")
        self.pm_base_instance_2.du_namespace = builtin_obj.get_variable_value("${VDU_NAMESPACE}")
        self.pm_base_instance_2.pm_pod_full_name_du = builtin_obj.get_variable_value("${pm_pod_full_name_du}")
        self.pm_base_instance_2.pm_container_full_name_du = builtin_obj.get_variable_value(
            "${pm_container_full_name_du}")

    def clear_counter_files_du(self, wait=True):
        """
        clear counter files at next 1 minute(counter period is changed to every minute due to 0x340000=15).
        """
        self._setup_pm_gnb1_du()
        self.pm_base_instance_2._clear_counter_files_du(wait)

    def check_counters_and_return_result_du(self, pm_counters_expression='', rd_counters_expression='', wait=True):
        """This keyword is to check PM counter and R&D counter
        | step1 | wait counter file produced |
        | step2 | download all counter files |
        | step3 | unzip all counter files and parse and calculate the total number, and return check list. |

        | Input Parameters | Man. | Description |
        | pm_counters_expression  | No   | pm counters expression list |
        | rd_counters_expression | No | rd counters expression list |
        | wait | No | wait for pm counter interval. for two gnbs case, only need to wait for one time |

        format of pm_counters_expression:
        | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
        | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
        | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
        | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
        | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
        | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
        | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
        | 8) | "every " before the expression listed in 1)~7) | check counter satisfying the expression
        in every pm counter interval. it is 15min for pm counter |

        format of rd_counters_expression: almost same as pm_counters_expression,like as M55603CRD00001

        Example:
        1)
        | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
        | ... | LNCEL-100:M8008C12>1 |  LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | every M8061C214<=900 |
        | ${result_list} | check_counters_and_return_result | ${pm_counters} |
        2)
        | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
        | ${result_list} | check_counters_and_return_result |  rd_counters_expression=${rd_counters} |
        3)
        | ${result_list} | check_counters_and_return_result |  ${pm_counters} | ${rd_counters} |
        """
        self._setup_pm_gnb1_du()
        return self.pm_base_instance_2._check_counters_and_return_result_du(pm_counters_expression,
                                                                            rd_counters_expression, wait)

    def get_current_bts_time_du(self):
        self._setup_pm_gnb1_du()
        self.pm_base_instance_2._setup_common_ssh_pm_du()
        out = self.pm_base_instance_2.fsm_obj.execute_command_on_enb("date +'%Y-%m-%d %H:%M:%S'",
                                                                     alias=self.pm_base_instance_2.alias)
        return out

    def get_counters_value_du_aic(self, pm_counters, wait=True):
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
        self._setup_pm_gnb1_du()
        return self.pm_base_instance_2._get_counters_value_du(pm_counters, wait)


class aic_pm_gnb1_du2(object):

    def __init__(self):
        alias = "gnb1_du2_pm"
        self.pm_base_instance_3 = aic_pm_base(alias)

    def _setup_pm_gnb1_du2(self):
        self.pm_base_instance_3.du_host = builtin_obj.get_variable_value("${VDU2_IP}")
        self.pm_base_instance_3.du_host_ssh = builtin_obj.get_variable_value("${VDU2_SSH_IP}")
        self.pm_base_instance_3.du_host_ssh_usr = builtin_obj.get_variable_value("${VDU2_SSH_USER}")
        self.pm_base_instance_3.du_host_ssh_pwd = builtin_obj.get_variable_value("${VDU2_SSH_PASSWD}")
        self.pm_base_instance_3.du_namespace = builtin_obj.get_variable_value("${VDU2_NAMESPACE}")
        self.pm_base_instance_3.pm_pod_full_name_du = builtin_obj.get_variable_value("${pm_pod_full_name_du2}")
        self.pm_base_instance_3.pm_container_full_name_du = builtin_obj.get_variable_value(
            "${pm_container_full_name_du2}")

    def clear_counter_files_du2(self, wait=True):
        """
        clear counter files at next 1 minute(counter period is changed to every minute due to 0x340000=15).
        """
        self._setup_pm_gnb1_du2()
        self.pm_base_instance_3._clear_counter_files_du(wait)

    def check_counters_and_return_result_du2(self, pm_counters_expression='', rd_counters_expression='', wait=True):
        """This keyword is to check PM counter and R&D counter
        | step1 | wait counter file produced |
        | step2 | download all counter files |
        | step3 | unzip all counter files and parse and calculate the total number, and return check list. |

        | Input Parameters | Man. | Description |
        | pm_counters_expression  | No   | pm counters expression list |
        | rd_counters_expression | No | rd counters expression list |
        | wait | No | wait for pm counter interval. for two gnbs case, only need to wait for one time |

        format of pm_counters_expression:
        | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
        | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
        | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
        | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
        | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
        | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
        | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
        | 8) | "every " before the expression listed in 1)~7) | check counter satisfying the expression
        in every pm counter interval. it is 15min for pm counter |

        format of rd_counters_expression: almost same as pm_counters_expression, like as M55603CRD00001

        Example:
        1)
        | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
        | ... | LNCEL-100:M8008C12>1 |  LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | every M8061C214<=900 |
        | ${result_list} | check_counters_and_return_result | ${pm_counters} |
        2)
        | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
        | ${result_list} | check_counters_and_return_result |  rd_counters_expression=${rd_counters} |
        3)
        | ${result_list} | check_counters_and_return_result |  ${pm_counters} | ${rd_counters} |
        """
        self._setup_pm_gnb1_du2()
        return self.pm_base_instance_3._check_counters_and_return_result_du(pm_counters_expression,
                                                                            rd_counters_expression, wait)

    def get_current_bts_time_du2(self):
        self._setup_pm_gnb1_du2()
        self.pm_base_instance_3._setup_common_ssh_pm_du()
        out = self.pm_base_instance_3.fsm_obj.execute_command_on_enb("date +'%Y-%m-%d %H:%M:%S'",
                                                                     alias=self.pm_base_instance_3.alias)
        return out

    def get_counters_value_du2_aic(self, pm_counters, wait=True):
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
        self._setup_pm_gnb1_du2()
        return self.pm_base_instance_3._get_counters_value_du(pm_counters, wait)


class aic_pm_gnb1_du3(object):

    def __init__(self):
        alias = "gnb1_du3_pm"
        self.pm_base_instance_4 = aic_pm_base(alias)

    def _setup_pm_gnb1_du3(self):
        self.pm_base_instance_4.du_host = builtin_obj.get_variable_value("${VDU3_IP}")
        self.pm_base_instance_4.du_host_ssh = builtin_obj.get_variable_value("${VDU3_SSH_IP}")
        self.pm_base_instance_4.du_host_ssh_usr = builtin_obj.get_variable_value("${VDU3_SSH_USER}")
        self.pm_base_instance_4.du_host_ssh_pwd = builtin_obj.get_variable_value("${VDU3_SSH_PASSWD}")
        self.pm_base_instance_4.du_namespace = builtin_obj.get_variable_value("${VDU3_NAMESPACE}")
        self.pm_base_instance_4.pm_pod_full_name_du = builtin_obj.get_variable_value("${pm_pod_full_name_du3}")
        self.pm_base_instance_4.pm_container_full_name_du = builtin_obj.get_variable_value(
            "${pm_container_full_name_du3}")

    def clear_counter_files_du3(self, wait=True):
        """
        clear counter files at next 1 minute(counter period is changed to every minute due to 0x340000=15).
        """
        self._setup_pm_gnb1_du3()
        self.pm_base_instance_4._clear_counter_files_du(wait)

    def check_counters_and_return_result_du3(self, pm_counters_expression='', rd_counters_expression='', wait=True):
        """This keyword is to check PM counter and R&D counter
        | step1 | wait counter file produced |
        | step2 | download all counter files |
        | step3 | unzip all counter files and parse and calculate the total number, and return check list. |

        | Input Parameters | Man. | Description |
        | pm_counters_expression  | No   | pm counters expression list |
        | rd_counters_expression | No | rd counters expression list |
        | wait | No | wait for pm counter interval. for two gnbs case, only need to wait for one time |

        format of pm_counters_expression:
        | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
        | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
        | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
        | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
        | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
        | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
        | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
        | 8) | "every " before the expression listed in 1)~7) | check counter satisfying the expression
        in every pm counter interval. it is 15min for pm counter |

        format of rd_counters_expression: almost same as pm_counters_expression, like as M55603CRD00001

        Example:
        1)
        | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
        | ... | LNCEL-100:M8008C12>1 |  LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | every M8061C214<=900 |
        | ${result_list} | check_counters_and_return_result | ${pm_counters} |
        2)
        | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
        | ${result_list} | check_counters_and_return_result |  rd_counters_expression=${rd_counters} |
        3)
        | ${result_list} | check_counters_and_return_result |  ${pm_counters} | ${rd_counters} |
        """
        self._setup_pm_gnb1_du3()
        return self.pm_base_instance_4._check_counters_and_return_result_du(pm_counters_expression,
                                                                            rd_counters_expression, wait)

    def get_current_bts_time_du3(self):
        self._setup_pm_gnb1_du3()
        self.pm_base_instance_4._setup_common_ssh_pm_du()
        out = self.pm_base_instance_4.fsm_obj.execute_command_on_enb("date +'%Y-%m-%d %H:%M:%S'",
                                                                     alias=self.pm_base_instance_4.alias)
        return out

    def get_counters_value_du3_aic(self, pm_counters, wait=True):
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
        self._setup_pm_gnb1_du3()
        return self.pm_base_instance_4._get_counters_value_du(pm_counters, wait)


class aic_pm_gnb1_du4(object):

    def __init__(self):
        alias = "gnb1_du4_pm"
        self.pm_base_instance_5 = aic_pm_base(alias)

    def _setup_pm_gnb1_du4(self):
        self.pm_base_instance_5.du_host = builtin_obj.get_variable_value("${VDU4_IP}")
        self.pm_base_instance_5.du_host_ssh = builtin_obj.get_variable_value("${VDU4_SSH_IP}")
        self.pm_base_instance_5.du_host_ssh_usr = builtin_obj.get_variable_value("${VDU4_SSH_USER}")
        self.pm_base_instance_5.du_host_ssh_pwd = builtin_obj.get_variable_value("${VDU4_SSH_PASSWD}")
        self.pm_base_instance_5.du_namespace = builtin_obj.get_variable_value("${VDU4_NAMESPACE}")
        self.pm_base_instance_5.pm_pod_full_name_du = builtin_obj.get_variable_value("${pm_pod_full_name_du4}")
        self.pm_base_instance_5.pm_container_full_name_du = builtin_obj.get_variable_value(
            "${pm_container_full_name_du4}")

    def clear_counter_files_du4(self, wait=True):
        """
        clear counter files at next 1 minute(counter period is changed to every minute due to 0x340000=15).
        """
        self._setup_pm_gnb1_du4()
        self.pm_base_instance_5._clear_counter_files_du(wait)

    def check_counters_and_return_result_du4(self, pm_counters_expression='', rd_counters_expression='', wait=True):
        """This keyword is to check PM counter and R&D counter
        | step1 | wait counter file produced |
        | step2 | download all counter files |
        | step3 | unzip all counter files and parse and calculate the total number, and return check list. |

        | Input Parameters | Man. | Description |
        | pm_counters_expression  | No   | pm counters expression list |
        | rd_counters_expression | No | rd counters expression list |
        | wait | No | wait for pm counter interval. for two gnbs case, only need to wait for one time |

        format of pm_counters_expression:
        | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
        | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
        | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
        | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
        | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
        | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
        | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
        | 8) | "every " before the expression listed in 1)~7) | check counter satisfying the expression
        in every pm counter interval. it is 15min for pm counter |

        format of rd_counters_expression: almost same as pm_counters_expression, like as M55603CRD00001

        Example:
        1)
        | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
        | ... | LNCEL-100:M8008C12>1 |  LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | every M8061C214<=900 |
        | ${result_list} | check_counters_and_return_result | ${pm_counters} |
        2)
        | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
        | ${result_list} | check_counters_and_return_result |  rd_counters_expression=${rd_counters} |
        3)
        | ${result_list} | check_counters_and_return_result |  ${pm_counters} | ${rd_counters} |
        """
        self._setup_pm_gnb1_du4()
        return self.pm_base_instance_5._check_counters_and_return_result_du(pm_counters_expression,
                                                                            rd_counters_expression, wait)

    def get_current_bts_time_du4(self):
        self._setup_pm_gnb1_du4()
        self.pm_base_instance_5._setup_common_ssh_pm_du()
        out = self.pm_base_instance_5.fsm_obj.execute_command_on_enb("date +'%Y-%m-%d %H:%M:%S'",
                                                                     alias=self.pm_base_instance_5.alias)
        return out

    def get_counters_value_du4_aic(self, pm_counters, wait=True):
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
        self._setup_pm_gnb1_du4()
        return self.pm_base_instance_5._get_counters_value_du(pm_counters, wait)


class aic_pm_gnb2_cu(object):

    def __init__(self):
        alias = "gnb2_cu_pm"
        self.pm_base_instance_cu2 = aic_pm_base(alias)

    def clear_counter_files_cu2(self, wait=True):
        """
        clear counter files at next 1 minute(counter period is changed to every minute due to 0x340000=15).
        """
        self.pm_base_instance_cu2._clear_counter_files_cu(wait)

    def check_counters_and_return_result_cu2(self, pm_counters_expression='', rd_counters_expression='', wait=True):
        """This keyword is to check PM counter and R&D counter
        | step1 | wait counter file produced |
        | step2 | download all counter files |
        | step3 | unzip all counter files and parse and calculate the total number, and return check list. |

        | Input Parameters | Man. | Description |
        | pm_counters_expression  | No   | pm counters expression list |
        | rd_counters_expression | No | rd counters expression list |
        | wait | No | wait for pm counter interval. for two gnbs case, only need to wait for one time |

        format of pm_counters_expression:
        | 1) | [mo:][counter_type]:counter_id=counter_value | check counter equal to some value |
        | 2) | [mo:][counter_type]:counter_id>=counter_value | check counter more than or equal to some value |
        | 3) | [mo:][counter_type]:counter_id<=counter_value | check counter less than or equal to some value |
        | 4) | [mo:][counter_type]:counter_id>counter_value | check counter more than some value |
        | 5) | [mo:][counter_type]:counter_id<counter_value | check counter less than some value |
        | 6) | [mo:][counter_type]:counter_id=existing | check counter existing |
        | 7) | [mo:][counter_type]:counter_id=not_existing | check counter not existing |
        | 8) | "every " before the expression listed in 1)~7) | check counter satisfying the expression
        in every pm counter interval. it is 15min for pm counter |

        format of rd_counters_expression: almost same as pm_counters_expression,like as M55131CRD50001

        Example:
        1)
        | ${pm_counters} | Create List | M8017C11=existing | M8017C12<=1 | M8017C13>=2 | M8008C13=1 |
        | ... | LNCEL-100:M8008C12>1 |  LNCEL-1/MCC-262/MNC-03/PMQAP-1:M8048C5=0 | every M8061C214<=900 |
        | ${result_list} | check_counters_and_return_result | ${pm_counters} |
        2)
        | ${rd_counters} | Create List | REPORT_RSCFS_ATT_UTRAN>=2 |
        | ${result_list} | check_counters_and_return_result |  rd_counters_expression=${rd_counters} |
        3)
        | ${result_list} | check_counters_and_return_result |  ${pm_counters} | ${rd_counters} |
        """
        return self.pm_base_instance_cu2._check_counters_and_return_result_cu(pm_counters_expression,
                                                                              rd_counters_expression, wait)

    def get_counters_value_cu2_aic(self, pm_counters, wait=True):
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
        return self.pm_base_instance_cu2._get_counters_value_cu(pm_counters, wait)


class pm_aic(aic_pm_gnb1_cu, aic_pm_gnb1_du, aic_pm_gnb1_du2, aic_pm_gnb1_du3, aic_pm_gnb1_du4, aic_pm_gnb2_cu):
    def __init__(self):
        aic_pm_gnb1_cu.__init__(self)
        aic_pm_gnb1_du.__init__(self)
        aic_pm_gnb1_du2.__init__(self)
        aic_pm_gnb1_du3.__init__(self)
        aic_pm_gnb1_du4.__init__(self)
        aic_pm_gnb2_cu.__init__(self)


if __name__ == "__main__":
    pm_obj = aic_pm_base("gnb1")
    help(pm_obj)
