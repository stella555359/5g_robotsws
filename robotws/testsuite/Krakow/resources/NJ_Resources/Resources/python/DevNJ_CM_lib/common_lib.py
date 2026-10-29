# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: yin.zhang
:contact: yin.zhang@nokia.com, cuicui.wang@nokia-sbell.com
"""

import os
import re
import time
import datetime
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from testsuite.Krakow.resources.NJ_Resources.Resources.python.ta_xml.common_xml import CommonXML
import random
import types
import testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SBTS_Configuration as sbtsConfiguration

from taf.ul.sc.unix_functionality import UnixFunctionality
from taf.ul.sc.gnb.airscale import AirScale
from taf.transport.ssh import ssh
from taf.config.testline.info import TestlineInfo
from taf.rfrl.common_resources.python.SWConfig import SWConfig


csn = ssh()
builtin_obj = BuiltIn()
os_obj = OperatingSystem()


class format_convert():

    def __init__(self):
        pass

    def _match_param_name_to_xpath(self, key):
        # param
        if key.count(":") == 0:
            key_xpath = "//*[@name='%s']" % key
        # mo:param
        elif key.count(":") == 1:
            mo = key.split(":")[0]
            para_name = key.split(":")[1]
            if mo == "any":
                key_xpath = "//*[@name='%s']" % para_name
            else:
                key_xpath = "//*[matches(@distName, '.*%s$')]/*[@name='%s']" % (mo, para_name)
        else:
            mo = key.split(":")[0]
            if mo != "any":
                key_xpath = "//*[matches(@distName, '.*%s$')]" % mo
            else:
                key_xpath = ""
            for index in range(key.count(":") - 1):
                key_xpath = key_xpath + \
                    "//*[@name='%s']" % (key.split(":")[index + 1])
            # mo:list_name:param|param2=value2
            if key.count("|") == 1:
                target_key = key.split("|")[0]
                cond_key = key.split("|")[1].split("=")[0]
                cond_value = key.split("|")[1].split("=")[1]
                key_xpath = key_xpath + "//*[@name='%s'][text()='%s']/../*[@name='%s']" % (
                    cond_key, cond_value, target_key.split(":")[-1])
            # mo:list_name:param
            else:
                key_xpath = key_xpath + "//*[@name='%s']" % key.split(":")[-1]
        return key_xpath

    def match_to_xpath(self, parameters):
        """This keyword is to convert parameters format to xpath
           parameters format:
           (1)used in modify SCF scenario:
            | 1) | mo:key=value | modify parameter value of managedObject |
            | 2) | mo:list:key=value | modify parameter value of list |
            | 3) | mo:list:key=value |condition_key=condition_value  | modify parameters value of list if the list
            contains condition_key whose value is condition_value |
           (2)used in read SCF scenario:
            | 1) | mo(:list):key     |
           (3)used in delete SCF scenario
            | 1) | mo:mo_name or pattern | match to xpath of managedObject |
            | 2) | list:blacklistHoL | match to xpath of list |

        Example1: modify SCF parameter
        ${params_xpath} | match_to_xpath | ["PSGRP-1:lbpsISONCtlEnabled=true",
        "PSGRP-1:lbpsCellList:lbpsCellSOOrder=50",
        "PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon"] |
        modify_and_upload_scf_file | C:\\SCFC_1.xml | ${params_xpath} |

        Example2: read SCFC parameter
        ${param_xpath} | match_to_xpath | PSGRP-1:lbpsISONCtlEnabled |
        ${value} | read_xml | C:\\SCFC_1.xml | text|${param_xpath[0]} |
        Should Be Equal | ${value} | true |

        Example3: delete element from SCFC
        ${param_xpath} | match_to_xpath | PSGRP-1 |
        remove_xml_element | C:\\SCFC_1.xml | C:\\SCFC_modified.xml | ${param_xpath} |
        """
        parameters_xpath = []
        if not isinstance(parameters, list):
            if len(parameters.strip()) == 0:
                return parameters
            parameters = builtin_obj.create_list(parameters)
        for para in parameters:
            if len(para.strip()) == 0:
                continue
            if para.count("=") == 0 or para.count(
                    "=") == 1 and para.count("|") == 1:
                # format like "mo:LNRELW", "mo:LNADJ-\\d{3}", "list:blacklistHoL"
                if para.count("mo:") == 1 and para.count("-") == 0:
                    para_xpath = "//*[contains(@distName, '%s')]" % (
                        para.split(":")[1])
                elif para.count("mo:") == 1 and para.count("-") == 1:
                    para_xpath = "//*[matches(@name, '%s')]" % (para.split(":")[1])
                elif para.count("list:") == 1:
                    para_xpath = "//list[@name='%s']" % (para.split(":")[1])
                else:
                    para_xpath = self._match_param_name_to_xpath(para)
            else:
                if para.count("|") == 0:
                    key = para.split("=")[0].strip()
                    value = para.split("=")[1].strip()
                    key_xpath = self._match_param_name_to_xpath(key)
                elif para.count("|") == 1:
                    target_key = para.split("|")[0].split("=")[0]
                    value = para.split("|")[0].split("=")[1]
                    condition = para.split("|")[1]
                    key_xpath = self._match_param_name_to_xpath(
                        target_key + "|" + condition)
                para_xpath = "text|%s|%s" % (value, key_xpath)
            parameters_xpath.append(para_xpath)
        return parameters_xpath

    def remove_empty_from_list(self, list_in):
        list_out = []
        # if type(list_in) is not types.ListType:
        if not isinstance(list_in, list):
            list_in = [list_in]
        for value in list_in:
            # if type(value) is types.StringType:
            if isinstance(value, str):
                if len(value.strip()) != 0:
                    list_out.append(value.strip())
            else:
                list_out.append(value)
        return list_out

    def get_all_cells_instance(self, scf):
        commonxml_obj = CommonXML(scf)
        all_dns = []
        all_elements = commonxml_obj.get_elements("//*[matches(@class, '.*LNCEL$')]")
        for each_element in all_elements:
            dn = commonxml_obj.get_element_attribute(each_element, "distName")
            all_dns.append(dn.split("/")[-1])
        all_dns.sort()
        return all_dns

    def log_to_console_with_time_prefix(self, log, level="INFO", color=""):
        current_time = builtin_obj.get_time()
        if len(color) == 0:
            if level.lower() == 'info':
                builtin_obj.log("[ INFO ] %s  %s" % (current_time, log), console="yes")
            else:
                builtin_obj.log("%s  %s" % (current_time, log), level=level)
        else:
            if color == "yellow" and level.lower() == 'info':
                builtin_obj.log("[ \033[0;33;40mINFO\033[0m ] %s %s" % (current_time, log), console="yes")

    def get_random_string(self, strings):
        strings = self.remove_empty_from_list(strings)
        return random.sample(strings, 1)[0]


class operate_on_local_pc(object):
    def __init__(self):
        self.format_convert_obj = format_convert()
        self.starttime = ""

    def __del__(self):
        pass

    def execute_cmd_on_pc(self, cmd):
        result = os_obj.run(cmd)
        builtin_obj.log("%s" % result)
        return result

    def run_tcpdump_on_pc(self, cmd):
        unix_local = UnixFunctionality(device_name="UnixLocal", autoconnect=True)
        command = unix_local.device.get_cmd(cmd_name="tcpdump", cmd_params={'options': '-i eth0'})
        result = command()
        return result

    def get_timestamp(self):
        time_stamp = builtin_obj.get_time().replace("-", "").replace(" ", "").replace(":", "")
        return time_stamp

    def modify_parameter_defined_as_key_equal_value(self, file_full_path, params):
        params = self.format_convert_obj.remove_empty_from_list(params)
        for param in params:
            parameter = param.split("=")[0]
            value = param.split("=")[1]
            command1 = "grep '%s *=' %s | grep -v '=='" % (parameter, file_full_path)
            out_all = self.execute_cmd_on_pc(command1)
            for out in out_all.strip().splitlines():
                if len(out.strip()) == 0:
                    continue
                old_value = out.split("=")[1]
                if old_value.count("'") or old_value.count("\""):
                    command2 = '''sed -i "s:%s:%s='%s':g" %s''' % (out.strip(), out.split("=")[0],
                                                                   value, file_full_path)
                elif out.strip().startswith("#"):
                    command2 = '''sed -i "s:%s:%s=%s:g" %s''' % (out.strip(), parameter, value, file_full_path)
                else:
                    command2 = '''sed -i "s:%s:%s=%s:g" %s''' % (out.strip(), out.split("=")[0], value, file_full_path)
                self.execute_cmd_on_pc(command2)
            if len(out_all.strip()) == 0:
                builtin_obj.log("no %s in %s, will append it to the end" % (parameter, value))
                self.execute_cmd_on_pc("echo >> %s" % file_full_path)
                command3 = "echo '%s=%s' >> %s" % (parameter, value, file_full_path)
                self.execute_cmd_on_pc(command3)
            builtin_obj.log("step: after modify, flag %s is changed to %s" % (parameter,
                                                                              self.execute_cmd_on_pc(command1)))

    def get_linux_process_id(self, process, *other_keys):
        pids = []
        command = "ps -ef | grep '%s' | grep -v -w grep" % process
        self.execute_cmd_on_pc(command)
        if len(other_keys) > 0:
            for key in other_keys:
                command = command + " | grep '%s'" % key
        out = self.execute_cmd_on_pc(command)
        for line in out.splitlines():
            match = re.search(r".*:.*:.*", line, re.I)
            if match is not None:
                pids.append(line.strip().split()[1])
        return pids

    def kill_linux_process(self, pids):
        pids = self.format_convert_obj.remove_empty_from_list(pids)
        for pid in pids:
            self.execute_cmd_on_pc("kill -9 " + pid)
            self.execute_cmd_on_pc("ps -ef | grep %s" % pid)

    def tail_log(self, log_file, append_file):
        old_pids = self.get_linux_process_id("tail", log_file)
        self.kill_linux_process(old_pids)
        command = "nohup tail -F -n 0 %s > %s&" % (log_file, append_file)
        self.execute_cmd_on_pc(command, prompt="stderr to stdout")
        tail_pid = self.get_linux_process_id("tail", log_file)
        return tail_pid

    def _get_files_name_according_to_pattern(self, path_to_file):
        path = path_to_file.rpartition("/")[0]
        pattern = path_to_file.rpartition("/")[2]
        out = self.execute_cmd_on_pc("cd %s; ls -ltr %s;cd ~" % (path, pattern))
        files_match = []
        for each_line in out.strip().splitlines():
            if each_line.count("->"):
                target_file = each_line.strip().split()[-3]
                source_file = each_line.strip().split()[-1]
            else:
                target_file = each_line.strip().split()[-1]
                source_file = target_file
            files_match.append([source_file, target_file])
        return files_match

    def collect_wts_logs(self, tag):
        save_log_directory = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        wts_dir = builtin_obj.get_variable_value('${WTS_DIR}')
        if len(tag) == 0:
            local_dir = os.path.join(save_log_directory, "WTS_logs")
        elif tag.count("startup"):
            local_dir = os.path.join(save_log_directory, "%s_logs" % tag, "WTS_logs")
        else:
            local_dir = os.path.join(save_log_directory, "WTS_logs_%s" % tag)
        os_obj.create_directory(local_dir)
        files = self._get_files_name_according_to_pattern(os.path.join(wts_dir, "*.log*"))
        for each_file in files:
            try:
                os_obj.copy_file(os.path.join(wts_dir, each_file[0]), os.path.join(local_dir, each_file[1]))
            except ValueError:
                builtin_obj.log("copy %s failed" % os.path.join(wts_dir, each_file[0]))

        os_obj.copy_files(os.path.join(wts_dir, "*.lua"), local_dir)
        return local_dir

    def _check_string_in_file(self, file_with_path, string):
        if string.count("'"):
            command = '''grep -i "%s" "%s"''' % (string, file_with_path)
        else:
            command = "grep -i '''%s''' '%s'" % (string, file_with_path)
        self.execute_cmd_on_pc(command)
        out2 = self.execute_cmd_on_pc("echo $?")
        if out2 == "0":
            return True
        else:
            return False

    def count_string_in_file(self, file_with_path, string):
        command = "grep -i '%s' '%s'" % (string, file_with_path)
        out = self.execute_cmd_on_pc(command)
        if out.count("Binary file %s matches" % file_with_path):
            count = 1
        else:
            count = 0
            for each_line in out.replace("\r", "").splitlines():
                if each_line.count("grep") == 0:
                    count = count + each_line.lower().count(string.lower())
        return int(count)

    def file_should_contain_strings(self, file_with_path, *string):
        for each in string:
            count = self._check_string_in_file(file_with_path, each)
            if count is False:
                raise Exception("no %s in %s" % (each, file_with_path))

    def file_should_not_contain_strings(self, file_with_path, *string):
        for each in string:
            count = self._check_string_in_file(file_with_path, each)
            if count is True:
                raise Exception("%s exits in %s" % (each, file_with_path))

    def file_contain_string_no_less_than(self, file_with_path, string, times):
        times_a = self.count_string_in_file(file_with_path, string)
        if int(times_a) < int(times):
            raise Exception("%s only contain '%s' for %s times" % (file_with_path, string, times_a))

    def record_current_time(self):
        self.starttime = datetime.datetime.now()

    def wait_time_since_last_record(self, wait_time):
        """
        example:
        | wait_time_since_last_record | 120s |
        """
        endtime = datetime.datetime.now()
        time_elapse = (endtime - self.starttime).seconds
        time_gap = int(wait_time[:-1])-int(time_elapse)
        if time_gap > 0:
            time.sleep(time_gap)

    def execute_aashell_cmd(self, cmd, port="15007", timeout="50"):
        """
        :param cmd:
        :param port:
        :param timeout:
        :return:
        """
        builtin_obj.log("execute_aashell_cmd %s:wait for implementation" % cmd, console=True)

    def _get_save_log_dir(self, alias="gNB"):
        if alias == "gNB":
            save_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")

        else:
            save_log_dir = "%s/%s/" % (builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}"), alias)
        os_obj.create_directory(save_log_dir)
        return save_log_dir


class operate_on_enb(object):
    def __init__(self):
        self.bts_alias = "gNB"
        self.swconfig_obj = SWConfig()

    def _setup_bts(self):
        if self.bts_alias in csn.store._store:
            connection = csn.get_connection_by_alias(self.bts_alias)
            if connection.is_connected:
                csn.disconnect(connection=self.bts_alias)

        csn.connect_to(hostname=sbtsConfiguration.sbts_lmp_ip, username=sbtsConfiguration.sbts_lmp_user,
                       password=sbtsConfiguration.sbts_lmp_password, alias=self.bts_alias)

    def __del__(self):
        if self.bts_alias in csn.store._store:
            csn.disconnect(connection=self.bts_alias)

    def execute_command_on_enb(self, cmd, return_rc=False, **kwargs):
        """ Execute shell command on BTS. Not Recommended.

        :param string cmd:           Shell command to be executed.
        :param bool   return_rc:     Flag for returning shell command rc. Default: False.

        :return:                     Shell command output. If return_rc is True, also returns shell command rc.
        :rtype:                      string or (string, int)
        """
        self._setup_bts()
        result = csn.execute(command=cmd, connection=self.bts_alias)
        return result

    def get_enb_file(self, source, destination):
        """Copy a file from source on eNB to destination on the local machine.

        :param string source:         Source file path.
        :param string destination:    Destination file path.
        """
        self._setup_bts()
        csn.download_file(remote_path=source, local_path=destination, connection=None, timeout=30)

    def define_admin_port(self):
        bts_port = "443"
        use_ssl = True
        return bts_port, use_ssl

    # def get_current_weekday(self):
    #     """
    #     Example
    #     | ${weekday}= | get_current_weekday |
    #
    #     """
    #     gnb = AirScale(autoconnect=True, oam_ip=sbtsConfiguration.sbts_ip, device_name=sbtsConfiguration.device_name)
    #     gnb.device.goto_state("FCT")
    #     date_cmd = gnb.device.get_cmd(cmd_name="date")
    #     result = date_cmd()
    #     return result['DAY_OF_WEEK']
    #
    # def get_current_bts_time(self):
    #     gnb = AirScale(autoconnect=True, oam_ip=sbtsConfiguration.sbts_ip, device_name=sbtsConfiguration.device_name)
    #     gnb.device.goto_state("FCT")
    #     date_cmd = gnb.device.get_cmd(cmd_name="date")
    #     result = date_cmd()
    #     return result['DATE']['FULL']+' '+result['TIME']['FULL']

    def change_swconfig_file(self, flags, swconfig_file):
        """This keyword is to change swconfig.txt in current connection
        | Input Parameters | Man. | Description |
        | swconfig_file | No | swconfig file which will be modified with parameter flags.
        if none, swconfig file in enb is used |
        | flags   |  Yes  | parameters to be modified |


        format of argument1 flags
        | 1) | key=value | modify parameter value, if param not exist, create it |
        Example
        | ${parameters_in_swconfig} | Create List |  | 0x100=5 | 0x200=4 |
        | change_swconfig_file | ${parameters_in_swconfig} |
        """
        self._setup_bts()
        backup_swconfig_file = os.path.join(operate_on_local_pc()._get_save_log_dir(), "swconfig.txt.bak")
        modified_swconfig_file = os.path.join(operate_on_local_pc()._get_save_log_dir(), "swconfig_modified.txt")
        builtin_obj.log("initial_swconfig_file %s" % swconfig_file, console=True)
        builtin_obj.log("modified_swconfig_file %s" % modified_swconfig_file, console=True)
        builtin_obj.log("backup_swconfig_file %s" % backup_swconfig_file, console=True)
        os_obj.copy_file(swconfig_file, modified_swconfig_file)
        flags = format_convert().remove_empty_from_list(flags)
        builtin_obj.log("change swconfig with %s in %s" % (flags, self.bts_alias), console=True)
        if len(flags) != 0:
            self.swconfig_obj.modify_swConfig_file(flags, modified_swconfig_file)
        self.swconfig_obj.upload_swConfig_file_to_asik_and_crasign(localFilePath=modified_swconfig_file,
                                                                   asik_alias=self.bts_alias)
        self.swconfig_obj.download_swConfig_file_from_asik_to_test_pc(localFilePath=backup_swconfig_file,
                                                                      remoteFilePath="/ffs/run/swconfig.txt.bak",
                                                                      asik_alias=self.bts_alias)

    def recover_swconfig_file(self):
        self._setup_bts()
        self.swconfig_obj.restore_swConfig_file_on_asik_and_crasign(asik_alias=self.bts_alias)


class common_lib(format_convert, operate_on_local_pc, operate_on_enb):
    def __init__(self):
        format_convert.__init__(self)
        operate_on_local_pc.__init__(self)
        operate_on_enb.__init__(self)

    def __del__(self):
        if common_lib:
            operate_on_local_pc.__del__(self)
            operate_on_enb.__del__(self)


if __name__ == "__main__":
    obj = common_lib()
    print(obj.wait_ues_attach_finish("1", "10"))
