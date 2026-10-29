# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

import os
import re
import time
import datetime
import sys
import mmap
import json
from base_lib.ute_fsmaccess import ute_fsmaccess
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.String import String
from base_lib.ta_ssh_telnet import ta_ssh_telnet
from base_lib.ta_xml import ta_xml
from base_lib.ta_xml.common_xml import CommonXML
from base_lib.ute_wtssim import ute_wtssim

import telnetlib
import random
import types
import traceback

builtin_obj = BuiltIn()
os_obj = OperatingSystem()
str_obj = String()
ssh_obj = ta_ssh_telnet()
xml_obj = ta_xml()
FCT_IP = "192.168.255.1"
BTS_USERNAME = "toor4nsn"
BTS_PASSWORD = "oZPS0POrRieRtu"


class common():
    def __init__(self):
        pass

    def _mo_xpath(self, mo):
        # consider mo ending with same string
        if mo.count("MRBTS"):
            xpath = "//managedObject[matches(@distName, '%s$')]" % mo
        else:
            xpath = "//managedObject[matches(@distName, '.*/%s$')]" % mo
        return xpath

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
                key_xpath = "%s/*[@name='%s']" % (self._mo_xpath(mo), para_name)
        else:
            mo = key.split(":")[0]
            if mo != "any":
                key_xpath = self._mo_xpath(mo)
            else:
                key_xpath = ""
            for index in range(key.count(":") - 1):
                key_xpath = key_xpath + \
                            "//*[@name='%s']" % (key.split(":")[index + 1])
            # mo:list_name:param|condtion1=value1&&condtion2=value2
            if key.count("|") == 1:
                target_key = key.split("|")[0]
                condition_part = key.split("|")[1]
                condition_key_0, condition_value_0 = condition_part.split("&&")[0].split("=")
                key_xpath = key_xpath + "//*[@name='%s'][text()='%s']" % (condition_key_0, condition_value_0)
                if condition_part.count("&&"):
                    for condition in condition_part.split("&&")[1:]:
                        condition_key_n, condition_value_n = condition.split("=")
                        key_xpath = key_xpath + "/../*[@name='%s'][text()='%s']" % (condition_key_n, condition_value_n)
                key_xpath = key_xpath + "/../*[@name='%s']" % (target_key.split(":")[-1])
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
            | 3) | mo:list:key=value|condition_key=condition_value  |
            modify parameters value of list if the list contains condition_key
            whose value is condition_value |
           (2)used in read SCF scenario:
            | 1) | mo(:list):key     |
            | 2) | mo:list:key|condition_key=condition_value  |
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
                # mo:list:key|condition_key=condition_value&&condition_key2=condition_value2
                else:
                    para_xpath = self._match_param_name_to_xpath(para)
            else:
                # mo:key=value, mo:list:key=value
                if para.count("|") == 0:
                    key = para.split("=")[0].strip()
                    value = para.split("=")[1].strip()
                    key_xpath = self._match_param_name_to_xpath(key)
                # mo:list:key=value|condition_key=condition_value&&condition_key2=condition_value2
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
        list1 = []
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
                    list1.append(value.strip())
            else:
                list1.append(value.strip())
        for value in list1:
            remove_equal_emtpy = re.sub(r"\s*=\s*", "=", value)
            remove_vertical_line_emtpy = re.sub(r"\s*\|\s*", "|", remove_equal_emtpy)
            list_out.append(remove_vertical_line_emtpy)
        return list_out

    def define_admin_port(self):
        bts_port = "443"
        use_ssl = True
        return bts_port, use_ssl

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

    def get_timestamp(self):
        time_stamp = builtin_obj.get_time().replace("-", "").replace(" ", "").replace(":", "")
        return time_stamp

    def record_current_time(self):
        self.starttime = datetime.datetime.now()

    def wait_time_since_last_record(self, wait_time):
        """
        example:
        | wait_time_since_last_record | 120s |
        """
        endtime = datetime.datetime.now()
        time_elapse = (endtime - self.starttime).seconds
        time_gap = int(wait_time[:-1]) - int(time_elapse)
        if time_gap > 0:
            time.sleep(time_gap)

    def _get_save_log_dir(self, alias):
        if alias == "enb1":
            save_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        else:
            save_log_dir = "%s/%s/" % (builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}"), alias)
        os_obj.create_directory(save_log_dir)
        return save_log_dir


class operate_on_pc_base(object):
    def __init__(self, alias):
        self.common_obj = common()
        self._setup_ssh_flag = False
        self.starttime = ""
        self._setup_iphy_aashell_flag = False
        self.pc = "127.0.0.1"
        self.alias = alias

    def _setup_conn(self):
        if not self._setup_ssh_flag:
            self._setup_ssh_flag = True
            # sometimes ssh is not working right after cloud testline is reserved.
            # Retry 20 minutes as workaround.
            conn_max_retry = 20
            while conn_max_retry > 0:
                try:
                    self.pc_conn = ssh_obj.connect_to_host(self.pc, "22", "ute", "ute", conn_type="SSH", timeout="10")
                    builtin_obj.log("ssh connection is %s" % self.pc_conn)
                    break
                except Exception as e:
                    builtin_obj.log("connect to %s failed with reason: %s" % (self.pc, e))
                    conn_max_retry = conn_max_retry - 1
                    time.sleep(60)
            # switch to test_repo virtual env
            try:
                if os.path.exists("/home/ute/test_repo/bin/activate"):
                    ssh_obj.execute_shell_command("source /home/ute/test_repo/bin/activate")
            except Exception as e:
                builtin_obj.log("enter test_repo failed: %s" % e)

    def _setup_iphy_aashell(self):
        if not self._setup_iphy_aashell_flag:
            self._setup_iphy_aashell_flag = True
            self.iphy_aashell_conn = ssh_obj.connect_to_host(self.pc, "22", "ute", "ute",
                                                             conn_type="SSH", timeout="10")
            ssh_obj.set_shell_prompt("AaShell>")
            ssh_obj.execute_shell_command("telnet 192.168.200.1 8023")

    def __del__(self):
        pass

    def _execute_cmd_on_pc(self, cmd, timeout="20", prompt=""):
        self._setup_conn()
        try:
            ssh_obj.switch_host_connection(self.pc_conn)
            ssh_obj.set_shell_timeout(int(timeout))
            if len(prompt):
                old_prompt = ssh_obj.set_shell_prompt(prompt)
            out = ssh_obj.execute_shell_command(cmd)
        except Exception:
            detail = traceback.format_exc()
            # if timeout is large, don't retry to execute the command
            if int(timeout) > 120:
                raise Exception(detail)

            try:
                ssh_obj.disconnect_from_host(self.pc_conn)
            except Exception:
                pass
            builtin_obj.log(detail)
            builtin_obj.log("reestablish ssh connection to local host")
            self.pc_conn = ssh_obj.connect_to_host(self.pc, "22", "ute", "ute", conn_type="SSH", timeout="10")
            ssh_obj.switch_host_connection(self.pc_conn)
            try:
                if os.path.exists("/home/ute/test_repo/bin/activate"):
                    ssh_obj.execute_shell_command("source /home/ute/test_repo/bin/activate")
            except Exception as e:
                builtin_obj.log("enter test_repo failed: %s" % e)
            ssh_obj.set_shell_timeout(timeout)
            if len(prompt):
                old_prompt = ssh_obj.set_shell_prompt(prompt)
            out = ssh_obj.execute_shell_command(cmd)
        finally:
            if len(prompt):
                ssh_obj.set_shell_prompt(old_prompt)
        return out

    def _set_admin_log_dir(self, alias):
        if alias == "enb1":
            admin_log_dir = "{}/admin_logs/".format(builtin_obj.get_variable_value("${SUITE_LOG_DIRECTORY}"))
        else:
            admin_log_dir = "{}/{}/admin_logs/".format(
                builtin_obj.get_variable_value("${SUITE_LOG_DIRECTORY}"), alias)
        os_obj.create_directory(admin_log_dir)
        return admin_log_dir

    def _check_alias_exist_on_admin(self, admin_obj, alias_name):
        if not admin_obj.store.all:
            builtin_obj.log('zy:store does not have alias now')
            return False
        if alias_name in [i[0] for i in admin_obj.store.all]:
            builtin_obj.log('zy:alias %s exists' % alias_name)
            return True
        else:
            builtin_obj.log('zy:alias %s does not exist' % alias_name)
            return False

    def _ping_ok(self, ip):
        out = self._execute_cmd_on_pc("ping %s -c 2" % ip)
        if out.count("100% packet loss"):
            return False
        else:
            return True

    def _setup_admin_if_alias_not_exist(self, admin_obj, alias, bts_host, remote_host):
        if not self._check_alias_exist_on_admin(admin_obj, alias):
            bts_port, use_ssl = self.common_obj.define_admin_port()
            admin_log_dir = self._set_admin_log_dir(alias)
            ping_ok = self._ping_ok(bts_host)
            if ping_ok:
                admin_obj.setup_admin(alias=alias, bts_port=bts_port, use_ssl=use_ssl,
                                      admin_api_log_dir=admin_log_dir, bts_host=bts_host)
            else:
                admin_obj.setup_admin(alias=alias, bts_port=bts_port, use_ssl=use_ssl,
                                      admin_api_log_dir=admin_log_dir,
                                      remote_host=remote_host,
                                      bts_host="192.168.255.129")

    def _kill_useless_local_hosts(self):
        """
        keep latest 127.0.0.1 connection and kill it
        kill admin cli
        remove /home/ute/.ssh/known_hosts for ssh issue
        """
        who_info = self._execute_cmd_on_pc("who | grep %s" % self.pc)
        entries = who_info.strip().splitlines()
        latest_time = ""
        latest_terminal = ""
        old_terminals = []
        for index in range(0, len(entries)):
            date_time = entries[index].split()[2] + " " + entries[index].split()[3]
            terminal = entries[index].split()[1]
            if date_time < latest_time:
                old_terminals.append(terminal)
            else:
                if latest_terminal != "":
                    old_terminals.append(latest_terminal)
                latest_time = date_time
                latest_terminal = terminal
        for term in old_terminals:
            self._execute_cmd_on_pc("pkill -9 -t " + term)
        self._execute_cmd_on_pc("who | grep %s" % self.pc)

        # kill admin cli
        pids = self._get_linux_process_id("ute_common_admin")
        self._kill_linux_process(pids)

        # ssh issue
        self._execute_cmd_on_pc("rm -rf /home/ute/.ssh/known_hosts")

    def _modify_parameter_defined_as_key_equal_value(self, file_full_path, params):
        params = self.common_obj.remove_empty_from_list(params)
        for param in params:
            builtin_obj.log("zy: handle %s" % param)
            # delete:flag_name
            if param.count("delete"):
                parameter = param.split(":")[-1]
                command1 = "grep -w %s %s" % (parameter, file_full_path)
                out_all = self._execute_cmd_on_pc(command1).strip()
                if len(out_all):
                    for out in out_all.splitlines():
                        command2 = "sed -i 's:%s::g' %s" % (out, file_full_path)
                        self._execute_cmd_on_pc(command2)
                    self._execute_cmd_on_pc(command1)
                continue
            # flag_name=flag_value
            parameter = param.split("=")[0]
            value = param.split("=")[1]
            command1 = "grep '%s *=' %s | grep -v '=='" % (parameter, file_full_path)
            out_all = self._execute_cmd_on_pc(command1)
            for out in out_all.strip().splitlines():
                if len(out.strip()) == 0 and out.count("=") == 0:
                    continue
                old_value = out.split("=")[1]
                # add out.strip().replace command to handle double colon situation
                if old_value.count("'") or old_value.count("\""):
                    command2 = '''sed -i "s:%s:%s='%s':g" %s''' \
                               % (out.strip().replace(r":", r"\:"), out.split("=")[0], value, file_full_path)
                elif out.strip().startswith("#"):
                    command2 = '''sed -i "s:%s:%s=%s:g" %s''' \
                               % (out.strip().replace(r":", r"\:"), parameter, value, file_full_path)
                else:
                    command2 = '''sed -i "s:%s:%s=%s:g" %s''' \
                               % (out.strip().replace(r":", r"\:"), out.split("=")[0], value, file_full_path)
                self._execute_cmd_on_pc(command2)
            if len(out_all.strip()) == 0:
                builtin_obj.log("no %s = %s, will append it to the end" % (parameter, value))
                self._execute_cmd_on_pc("echo >> %s" % file_full_path)
                command3 = "echo '%s=%s' >> %s" % (parameter, value, file_full_path)
                self._execute_cmd_on_pc(command3)
            builtin_obj.log("step: after modify, flag %s is changed to %s" % (parameter,
                                                                              self._execute_cmd_on_pc(command1)))

    def _check_string_in_file(self, file_with_path, string):
        if string.count("'"):
            command = '''grep -i "%s" "%s"''' % (string, file_with_path)
        else:
            command = "grep -i '''%s''' '%s'" % (string, file_with_path)
        self._execute_cmd_on_pc(command)
        out2 = self._execute_cmd_on_pc("echo $?")
        if out2 == "0":
            return True
        else:
            return False

    def _count_string_in_file(self, file_with_path, string):
        if not os.path.isfile(file_with_path):
            raise Exception("file does not exist or it is not a file: %s" % file_with_path)
        command = "grep -i '%s' '%s'" % (string, file_with_path)
        out = self._execute_cmd_on_pc(command)
        if out.count("Binary file %s matches" % file_with_path):
            count = 1
        else:
            count = 0
            for each_line in out.replace("\r", "").splitlines():
                if each_line.count("grep") == 0:
                    count = count + each_line.lower().count(string.lower())
        return int(count)

    def _file_should_contain_strings(self, file_with_path, *string):
        if not os.path.isfile(file_with_path):
            raise Exception("file does not exist or it is not a file: %s" % file_with_path)
        for each in string:
            count = self._check_string_in_file(file_with_path, each)
            if count is False:
                raise Exception("no %s in %s" % (each, file_with_path))

    def _file_should_not_contain_strings(self, file_with_path, *string):
        if not os.path.isfile(file_with_path):
            raise Exception("file does not exist or it is not a file: %s" % file_with_path)
        for each in string:
            count = self._check_string_in_file(file_with_path, each)
            if count is True:
                raise Exception("%s exits in %s" % (each, file_with_path))

    def _file_contain_string_no_less_than(self, file_with_path, string, times):
        if not os.path.isfile(file_with_path):
            raise Exception("file does not exist or it is not a file: %s" % file_with_path)
        times_a = self._count_string_in_file(file_with_path, string)
        if int(times_a) < int(times):
            raise Exception("%s only contain '%s' for %s times" % (file_with_path, string, times_a))

    def _get_linux_process_id(self, process, *other_keys):
        pids = []
        command = "ps -ef | grep -w '%s' | grep -v -w grep" % process
        self._execute_cmd_on_pc(command)
        if len(other_keys) > 0:
            for key in other_keys:
                command = command + " | grep '%s'" % key
        out = self._execute_cmd_on_pc(command)
        for line in out.splitlines():
            match = re.search(r".*:.*:.*", line, re.I)
            if match is not None:
                pids.append(line.strip().split()[1])
        return pids

    def _kill_linux_process(self, pids):
        pids = self.common_obj.remove_empty_from_list(pids)
        for pid in pids:
            self._execute_cmd_on_pc("sudo kill -9 " + pid)
            self._execute_cmd_on_pc("ps -ef | grep %s" % pid)

    def _tail_log(self, log_file, append_file):
        old_pids = self._get_linux_process_id("tail", log_file)
        self._kill_linux_process(old_pids)
        command = "nohup tail -F -n 0 %s > %s&" % (log_file, append_file)
        self._execute_cmd_on_pc(command, prompt="stderr to stdout")
        tail_pid = self._get_linux_process_id("tail", log_file)
        return tail_pid

    def _execute_aashell_cmd(self, cmd, port="15007", timeout="50"):
        self._setup_conn()
        ssh_obj.switch_host_connection(self.pc_conn)
        old_prompt = ssh_obj.set_shell_prompt("Password:", ">")
        ssh_obj.execute_shell_command("ssh toor4nsn@192.168.255.129")
        ssh_obj.execute_shell_command("oZPS0POrRieRtu")
        ssh_obj.set_shell_prompt("AaShell>")
        old_timeout = ssh_obj.set_shell_timeout(timeout)
        try:
            ssh_obj.execute_shell_command("telnet 127.0.0.1 %s" % port)
            out = ssh_obj.execute_shell_command(cmd)
        except Exception as e:
            print(e)
        finally:
            ssh_obj.set_shell_prompt(old_prompt)
            ssh_obj.set_shell_timeout(old_timeout)
            ssh_obj.execute_shell_command("quit")
            ssh_obj.execute_shell_command("exit")
        return out

    def _execute_cus_cmd(self, cmd, port="1234", timeout="120"):
        self._setup_conn()
        ssh_obj.switch_host_connection(self.pc_conn)
        old_prompt = ssh_obj.set_shell_prompt("CUS>")
        old_timeout = ssh_obj.set_shell_timeout(timeout)
        try:
            ssh_obj.execute_shell_command("telnet 0 %s" % port)
            out = ssh_obj.execute_shell_command(cmd)
        except Exception as e:
            print(e)
        finally:
            ssh_obj.set_shell_prompt(old_prompt)
            ssh_obj.set_shell_timeout(old_timeout)
            ssh_obj.execute_shell_command("\x04")  # ctrl+d, can't use exit because it impacts next time login to cus
        return out

    def _get_crnti_in_cell(self, cell_id):
        """
        execute two commands to get crnti in cell and get crnti list:\n
        1)enter into Aashell\n
        telnet 192.168.255.1 15081\n
        2)list crnti in cell\n
        listCrntiInCell <cell_id> @RROMexe\n
        example:\n
        | ${crntis} | _get_crnti_in_cell | 1 |
        | List Should Contain Value | ${crntis} | 2404 |
        """
        out = self._execute_aashell_cmd("listCrntiInCell %s @RROMexe" % cell_id, port="15081")
        return out.strip().split()

    def _execute_aashell_cmd_iphy(self, cmd, timeout="60"):
        self._setup_iphy_aashell()
        ssh_obj.switch_host_connection(self.iphy_aashell_conn)
        old_timeout = ssh_obj.set_shell_timeout(timeout)
        try:
            out = ssh_obj.execute_shell_command(cmd)
        except Exception as e:
            print(e)
        finally:
            ssh_obj.set_shell_timeout(old_timeout)
        return out

    def _execute_iphy_dump_dl(self, option=""):
        """
        refer to https://confluence.int.net.nokia.com/display/SIMMODE/
        How+to+take+DL+antenna+snapshot+%28dump%29+in+I-PHY
        option format is <trigger> [ <param> ]
        """
        self._execute_aashell_cmd_iphy("iphy_dump_dl 0x1240 %s" % option)
        self._execute_aashell_cmd_iphy("iphy_dump_dl 0x1260 %s" % option)
        self._execute_aashell_cmd_iphy("iphy_dump_dl 0x1280 %s" % option)
        self._execute_aashell_cmd_iphy("iphy_dump_dl 0x1240 %s fd" % option)
        self._execute_aashell_cmd_iphy("iphy_dump_dl 0x1260 %s fd" % option)
        self._execute_aashell_cmd_iphy("iphy_dump_dl 0x1280 %s fd" % option)
        time.sleep(10)

    def _get_uec_node(self, lcrid):
        rrom = self._get_cplane_nodes()[0]
        cell_mapping_cmd = "getCellMapping @RROMexe # %s" % rrom
        out = self._execute_aashell_cmd(cell_mapping_cmd)
        for line in out.strip().splitlines():
            if line.startswith("%s " % lcrid):
                uec_node = line.split()[11]
        return uec_node

    def _get_cplane_nodes(self):
        """get and return cplane nodes, the first one is node that RROM located in"""
        # execute aashell command: proc #0xFFFF
        out = self._execute_aashell_cmd("proc #0xFFFF")
        # select cplane nodes
        cplane_scs = ["RROM", "ENBC", "CELLC", "UEC", "TUPC"]
        cplane_nodes = []
        node_process = {}
        for line in out.strip().splitlines():
            if line.count("node"):
                node = line.split()[2]
                processes = []
            else:
                if not line.strip().startswith("Running") and not line.strip().startswith("--"):
                    processes.append(line.strip())
                    node_process[node] = processes
        for sc in cplane_scs:
            for node in node_process.keys():
                find = False
                for process in node_process[node]:
                    if process.lower().count(sc.lower()):
                        find = True
                        break
                if find is True and cplane_nodes.count(node) == 0:
                    cplane_nodes.append(node)
                    continue
        return cplane_nodes

    def _get_other_nodes(self):
        rrom = self._get_cplane_nodes()[0]
        cell_mapping_cmd = "getCellMapping @RROMexe # %s" % rrom
        out = self._execute_aashell_cmd(cell_mapping_cmd)
        mac = []
        phy = []
        for line in out.strip().splitlines()[1:]:
            if line.split()[13][0:6] == "0x0000":
                other_nodes = {}
                break
            mac.append(line.split()[-5][0:6])
            mac.append(line.split()[-4][0:6])
            phy.append(line.split()[-2])
            phy.append(line.split()[-1])
        mac = list(set(mac))
        phy = list(set(phy))
        other_nodes = {"mac": mac, "phy": phy}
        return other_nodes

    def _uncompress_file(self, compressed_file, target_dir):
        if target_dir is None:
            target_dir = os.path.dirname(compressed_file)
        file_name = os.path.basename(compressed_file)
        self._execute_cmd_on_pc("cd %s" % target_dir)
        try:
            if file_name.endswith(".zip"):
                self._execute_cmd_on_pc("unzip %s" % file_name, timeout="300")
            elif file_name.endswith(".tar.gz ") or file_name.endswith(".tgz"):
                self._execute_cmd_on_pc("tar -zxvf %s" % file_name, timeout="300")
            elif file_name.endswith(".gz"):
                self._execute_cmd_on_pc("gzip -d %s" % file_name, timeout="300")
            elif file_name.endswith(".txz"):
                self._execute_cmd_on_pc("tar xJvf %s" % file_name, timeout="300")
                # add uncompress tar file on other format
                out_status = self._execute_cmd_on_pc("echo $?")
                if int(out_status) != 0:
                    self._execute_cmd_on_pc("tar xvf %s" % file_name, timeout="300")
            else:
                raise Exception("not support to uncompress %s yet, pls raise your request" % file_name)
        except Exception:
            self._execute_cmd_on_pc("cd ~")
            self._execute_cmd_on_pc("pwd")
            raise

    def _start_to_dump_wts_messaging(self, msgs):
        self._execute_cmd_on_pc("sudo rm -rf /tmp/iphy_msgs.pcap")
        self._execute_cmd_on_pc("rm -rf /tmp/btslog2_iphy_traces/BTSLOG_TRACE*bin")
        try:
            self.pc_conn_for_iphy_msgs = ssh_obj.connect_to_host(self.pc, "22", "ute", "ute", conn_type="SSH",
                                                                 timeout="10")
            old_prompt = ssh_obj.set_shell_prompt("Tracing started")
            old_timeout = ssh_obj.set_shell_timeout("30")
            ssh_obj.execute_shell_command(
                "cd /opt/iphy/latest/iphy_msg_collector; ./iphy_msg_collector.py "
                "-m %s -t 127.0.0.1  -o iphy_msgs -p" % msgs)
        except Exception as e:
            builtin_obj.log("start to dump wts messaging failed: %s" % e)

    def _stop_dump_wts_messaging(self, log_dir):
        pids = self._get_linux_process_id("iphy_msg_collector")
        self._kill_linux_process(pids)
        self._execute_cmd_on_pc("mkdir -p %s/iphy_msgs" % log_dir)
        self._execute_cmd_on_pc("cp /tmp/iphy_msgs.pcap %s/iphy_msgs" % log_dir)
        self._execute_cmd_on_pc("cp /tmp/btslog2_iphy_traces/BTSLOG_TRACE*bin %s/iphy_msgs" % log_dir)
        ssh_obj.disconnect_from_host(self.pc_conn_for_iphy_msgs)


class operate_on_local_pc1(object):
    def __init__(self):
        alias = "enb1"
        self.pc_operate_instant_1 = operate_on_pc_base(alias)

    def execute_cmd_on_pc(self, cmd, timeout="20", prompt=""):
        return self.pc_operate_instant_1._execute_cmd_on_pc(cmd, timeout, prompt)

    def setup_admin_if_alias_not_exist(self, admin_obj, alias, bts_host, remote_host):
        self.pc_operate_instant_1._setup_admin_if_alias_not_exist(admin_obj, alias, bts_host, remote_host)

    def kill_useless_local_hosts(self):
        """
        keep latest 127.0.0.1 connection and kill it
        """
        self.pc_operate_instant_1._kill_useless_local_hosts()

    def modify_parameter_defined_as_key_equal_value(self, file_full_path, params):
        self.pc_operate_instant_1._modify_parameter_defined_as_key_equal_value(file_full_path, params)

    def count_string_in_file(self, file_with_path, string):
        return self.pc_operate_instant_1._count_string_in_file(file_with_path, string)

    def file_should_contain_strings(self, file_with_path, *string):
        self.pc_operate_instant_1._file_should_contain_strings(file_with_path, *string)

    def file_should_not_contain_strings(self, file_with_path, *string):
        self.pc_operate_instant_1._file_should_not_contain_strings(file_with_path, *string)

    def file_contain_string_no_less_than(self, file_with_path, string, times):
        self.pc_operate_instant_1._file_contain_string_no_less_than(file_with_path, string, times)

    def get_linux_process_id(self, process, *other_keys):
        return self.pc_operate_instant_1._get_linux_process_id(process, *other_keys)

    def kill_linux_process(self, pids):
        self.pc_operate_instant_1._kill_linux_process(pids)

    def tail_log(self, log_file, append_file):
        return self.pc_operate_instant_1._tail_log(log_file, append_file)

    def execute_aashell_cmd(self, cmd, port="15007", timeout="50"):
        return self.pc_operate_instant_1._execute_aashell_cmd(cmd, port, timeout)

    def execute_cus_cmd(self, cmd, port="1234", timeout="120"):
        return self.pc_operate_instant_1._execute_cus_cmd(cmd, port, timeout)

    def get_crnti_in_cell(self, cell_id):
        """
        execute two commands to get crnti in cell and get crnti list:\n
        1)enter into Aashell\n
        telnet 192.168.255.1 15081\n
        2)list crnti in cell\n
        listCrntiInCell <cell_id> @RROMexe\n
        example:\n
        | ${crntis} | _get_crnti_in_cell | 1 |
        | List Should Contain Value | ${crntis} | 2404 |
        """
        return self.pc_operate_instant_1._get_crnti_in_cell(cell_id)

    def execute_aashell_cmd_iphy(self, cmd, timeout="60"):
        return self.pc_operate_instant_1._execute_aashell_cmd_iphy(cmd, timeout)

    def execute_iphy_dump_dl(self, option=""):
        """
        refer to https://confluence.int.net.nokia.com/display/SIMMODE/
        How+to+take+DL+antenna+snapshot+%28dump%29+in+I-PHY
        option format is <trigger> [ <param> ]
        """
        self.pc_operate_instant_1._execute_iphy_dump_dl(option)

    def get_uec_node(self, lcrid):
        """
        get cell mapping and return UEC node of specified lcrid
        """
        return self.pc_operate_instant_1._get_uec_node(lcrid)

    def get_cplane_nodes(self):
        return self.pc_operate_instant_1._get_cplane_nodes()

    def get_other_nodes(self):
        return self.pc_operate_instant_1._get_other_nodes()

    def uncompress_file(self, compressed_file, target_dir=None):
        self.pc_operate_instant_1._uncompress_file(compressed_file, target_dir)

    def start_to_dump_wts_messaging(self, msgs):
        """This keyword is to start to capture IPHY internal messages referring to
        https://confluence.ext.net.nokia.com/display/SIMMODE/Dumping+WTS+messaging\n
        cmd: cd /opt/iphy/latest/iphy_msg_collector;
        ./iphy_msg_collector.py -m <msgs> -t 127.0.0.1  -o iphy_msgs -p

        | Input Parameters | Man. | Description |
        | msgs  | No   | content of -m option  |

        Example:
        | start_to_dump_wts_messaging | 0x1284:0x22EF |
        | start_to_dump_wts_messaging | 0x1272:0x2304,0x22e7-0x22e9 0x1271:0x2302 |
        """
        self.pc_operate_instant_1._start_to_dump_wts_messaging(msgs)

    def stop_dump_wts_messaging(self, log_dir):
        self.pc_operate_instant_1._stop_dump_wts_messaging(log_dir)


class operate_on_local_pc2(object):
    def __init__(self):
        alias = "enb2"
        self.pc_operate_instant_2 = operate_on_pc_base(alias)

    def execute_cmd_on_pc_enb2(self, cmd, timeout="20"):
        self.pc_operate_instant_2.pc = builtin_obj.get_variable_value('${ENB2_PC_IP}')
        return self.pc_operate_instant_2._execute_cmd_on_pc(cmd, timeout)

    def execute_aashell_cmd_enb2(self, cmd, port="15007", timeout="50"):
        self.pc_operate_instant_2.pc = builtin_obj.get_variable_value('${ENB2_PC_IP}')
        return self.pc_operate_instant_2._execute_aashell_cmd(cmd, port, timeout)

    def get_crnti_in_cell_enb2(self, cell_id):
        """
        execute two commands to get crnti in cell and get crnti list:\n
        1)enter into Aashell\n
        telnet 192.168.255.1 15081\n
        2)list crnti in cell\n
        listCrntiInCell <cell_id> @RROMexe\n
        example:\n
        | ${crntis} | get_crnti_in_cell_enb2 | 1 |
        | List Should Contain Value | ${crntis} | 2404 |
        """
        self.pc_operate_instant_2.pc = builtin_obj.get_variable_value('${TGT1_BTS_PC_INFO.IP}')
        return self.pc_operate_instant_2._get_crnti_in_cell(cell_id)

    def get_cplane_nodes_enb2(self):
        self.pc_operate_instant_2.pc = builtin_obj.get_variable_value('${TGT1_BTS_PC_INFO.IP}')
        return self.pc_operate_instant_2._get_cplane_nodes()

    def get_other_nodes_enb2(self):
        self.pc_operate_instant_2.pc = builtin_obj.get_variable_value('${TGT1_BTS_PC_INFO.IP}')
        return self.pc_operate_instant_2._get_other_nodes()


class operate_on_bts_base(object):
    def __init__(self, alias):
        self.alias = alias
        self.remote_host = None
        self.bts_host = "192.168.255.129"
        self._setup_fct_0b_flag = False
        self._setup_bts_flag = False

    def _setup_bts(self):
        if not self._setup_bts_flag:
            self._setup_bts_flag = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#",
                                              host="192.168.255.129")

    def __del__(self):
        if self._setup_bts_flag:
            self.fsm_obj.teardown_all_aliases_for_enb_fsmaccess()

    def execute_cmd_on_enb(self, cmd, board):
        self._setup_bts()
        board = board.lower()
        if board == "fct":
            # execute command on fct
            cmd = cmd
            builtin_obj.log("Execute command on {}:{}".format(self.alias, cmd))
            out = self.fsm_obj.execute_command_on_enb(cmd, return_rc=True, alias=self.alias)
            builtin_obj.log("Get Response:{}".format(out[0]))
            return out[0].strip()
        else:
            # execute command on fsp
            try:
                bts_conn = ssh_obj.connect_to_host(self.bts_host, "22", BTS_USERNAME, BTS_PASSWORD, conn_type="SSH",
                                                   timeout="10")
                ssh_obj.execute_shell_command("echo '' > ~/.ssh/known_hosts")
                old_prompt = ssh_obj.set_shell_prompt("Password:", r"\?", ":~ >")
                ssh_out = ssh_obj.execute_shell_command("ssh toor4nsn@%s" % board)
                if ssh_out.count("fingerprint"):
                    ssh_obj.execute_shell_command("yes")
                if ssh_out.count("No route to host") or ssh_out.count("Name or service not known"):
                    return
                ssh_obj.set_shell_prompt(old_prompt)
                ssh_obj.execute_shell_command(BTS_PASSWORD)
                out = ssh_obj.execute_shell_command(cmd)
            except Exception:
                pass
            finally:
                ssh_obj.disconnect_from_host(bts_conn)
            return out

    # def get_gnb_sw_version(self):
    #     """
    #     Example
    #     | ${gnb_version}= | get_gnb_sw_version |
    #
    #     """
    #     self._setup_bts()
    #     gnb_version = self.fsm_obj.get_enb_sw_version(alias=self.alias)
    #     # 5G21B_GNB_0000_000800_003629  ==> 5G_0.800.3629
    #     if gnb_version.count("GNB"):
    #         if gnb_version.count("0000_000800"):  # trunk
    #             gnb_version = "5G_%s.%s.%s" % (
    #                 gnb_version.split("_")[2][:-1].lstrip("0") + gnb_version.split("_")[2][-1],
    #                 gnb_version.split("_")[3].lstrip("0"), gnb_version.split("_")[4].lstrip("0"))
    #         else:  # branches
    #             gnb_version = "%s_%s.%s.%s" % (gnb_version.split("_")[0],
    #                                            gnb_version.split("_")[2][:-1].lstrip("0") + gnb_version.split("_")[2][
    #                                                -1],
    #                                            gnb_version.split("_")[3].lstrip("0"),
    #                                            gnb_version.split("_")[4].lstrip("0"))
    #     return gnb_version


class operate_on_bts1(object):
    def __init__(self):
        alias = "enb1"
        self.bts_base_instance_1 = operate_on_bts_base(alias)

    def execute_cmd_on_enb(self, cmd, board="fct"):
        """This keyword is to execute command in specified board of enb and return the command output

        | Arguments | Man. | Default | Description |
        | cmd       | Yes  | yes     | command to be executed |
        | board     | No   | master  | the board where to execute command, which must be defined in /etc/hosts in fct.
        fct means execute command in fct, it's not defined in /etc/hosts |


        Example:
        | ${out} | execute_cmd_on_enb | "ls -ltr" |
        | ${out} | execute_cmd_on_enb | "ps -ef | grep cp-rt" | board=fct |
        | ${out} | execute_cmd_on_enb | "ps -ef | grep cp_ue" | board=fsp1 |
        | ${out} | execute_cmd_on_enb | "ps -ef | grep cp_ue" | board=fsp_5a |
        | ${out} | execute_cmd_on_enb | "ps -ef | grep cp_ue" | board=asp_5a |
        """
        return self.bts_base_instance_1.execute_cmd_on_enb(cmd, board)

    # def get_gnb_sw_version(self):
    #     return self.bts_base_instance_1.get_gnb_sw_version()

    def assert_no_hanging_resources(self, enb_alias, port=15007):
        """
        Raises error if hanging resources are found.

        Before test teardown is called all resources should be 0
        (except numCells, numS1Links and numX2Links). If kw
        finds hanging resources, it raises an assertion error.
        Additionally, snapshot is saved to test result directory.

        :param String enb_alias: eNB alias
        :param int    port     : AaShell port (default: 15007)

        :rtype: None

        Keyword example:

        ===========================    ===============
        Assert No Hanging Resources    enb_alias=enb1
        ===========================    ===============

        """
        if "enb1" in enb_alias:
            assert_ip = '192.168.255.129'
        elif "enb2" in enb_alias:
            assert_ip = '192.168.255.2'
        else:
            raise Exception("unknown enb_alias %s is found" % enb_alias)

        self.assert_no_hanging_resources_instance = operate_on_pc_base(enb_alias)
        self.assert_no_hanging_resources_instance._setup_conn()
        ssh_obj.switch_host_connection(self.assert_no_hanging_resources_instance.pc_conn)
        old_prompt = ssh_obj.set_shell_prompt("Password:", ">")
        old_timeout = ssh_obj.set_shell_timeout(50)
        try:
            ssh_obj.execute_shell_command("ssh toor4nsn@%s" % assert_ip)
            ssh_obj.execute_shell_command("oZPS0POrRieRtu")
            ssh_obj.set_shell_prompt("AaShell>")
            ssh_obj.execute_shell_command("telnet 127.0.0.1 15007")
        except Exception as e:
            raise AssertionError("Aashell connection failure,please check port %s and host %s available or not"
                                 % (port, assert_ip))
        else:
            ret = ssh_obj.execute_shell_command("nodes -p RROMexe\r")
            matched_lines = re.findall(r'node: 0x....|RROMexe', ret)
            node_string = None
            for item in matched_lines:
                if item == 'RROMexe':
                    break
                node_string = item
            if node_string is None:
                builtin_obj.log("RROMexe process not found, continue with default node 0x1011")
                virt_node = "0x1011"
            else:
                node_in_hex = node_string[6:]
                builtin_obj.log("RROMexe process found on node: {}".format(node_in_hex))
                virt_node = node_in_hex
            hang_command = "getResourcesUsage -n @RROMexe #{}\r".format(virt_node)
            ret = ssh_obj.execute_shell_command(hang_command)
            list_of_errors = ["Internal communication error", "not registered to AaShell"]
            for msg in list_of_errors:
                if msg in ret:
                    builtin_obj.log(
                        "Could not determine hanging resources, aashell command {} failed".format(hang_command))
            l_converted_result = ret.splitlines()
            l_converted_result = map(lambda x: x.strip(), l_converted_result)
            l_converted_result = list(filter(
                lambda x: ":" in x and "num" in x, l_converted_result))
            l_list_to_delete = []
            for x in l_converted_result:
                if "numCells" in x or "numS1Links" in x or "numX2Links" in x:
                    l_list_to_delete.append(x)

            for x in l_list_to_delete:
                l_converted_result.remove(x)

            l_converted_result = map(lambda x: re.split(
                r" *: *", x), l_converted_result)

            nbr_of_used_resources = 0
            nbr_of_list_elements = 0
            for x in l_converted_result:
                if x[1] == '0':
                    nbr_of_used_resources += 1
                nbr_of_list_elements += 1
            if nbr_of_list_elements == 0 or nbr_of_list_elements != nbr_of_used_resources:
                raise AssertionError(
                    "Hanging Resources detected: %s" % ret)
        finally:
            ssh_obj.set_shell_prompt(old_prompt)
            ssh_obj.set_shell_timeout(old_timeout)
            ssh_obj.execute_shell_command("quit")


class operate_on_bts2(object):
    def __init__(self):
        alias = "enb2"
        self.bts_base_instance_2 = operate_on_bts_base(alias)

    def _setup_bts2(self):
        self.bts_base_instance_2.bts_host = builtin_obj.get_variable_value('${ENB2_IP}')  # S1 IP
        self.bts_base_instance_2.remote_host = builtin_obj.get_variable_value('${ENB2_PC_IP}')

    def execute_cmd_on_enb2(self, cmd, board="fct"):
        """This keyword is to execute command in specified board of enb2 and return the command output

        | Arguments | Man. | Default | Description |
        | cmd       | Yes  | yes     | command to be executed |
        | board     | No   | master  | the board where to execute command, which must be defined in /etc/hosts in fct.
        fct means execute command in fct, it's not defined in /etc/hosts |


        Example:
        | ${out} | execute_cmd_on_enb2 | "ls -ltr" |
        | ${out} | execute_cmd_on_enb2 | "ps -ef | grep cp-rt" | board=fct |
        | ${out} | execute_cmd_on_enb2 | "ps -ef | grep cp_ue" | board=fsp1 |
        | ${out} | execute_cmd_on_enb2 | "ps -ef | grep cp_ue" | board=fsp_5a |
        | ${out} | execute_cmd_on_enb2 | "ps -ef | grep cp_ue" | board=asp_5a |
        """
        self._setup_bts2()
        return self.bts_base_instance_2.execute_cmd_on_enb(cmd, board)


class operate_on_wts(object):
    def __init__(self):
        self.wts_alias = "wts"
        self._setup_wts_flag = False
        self.common_obj = common()
        self.ue_info = {}

    def _setup_wts(self):
        if not self._setup_wts_flag:
            self.iphy_obj = ute_wtssim()
            self.iphy_obj.setup_egate(egate_port='20000')
            self._setup_wts_flag = True
            self.pc_obj = operate_on_local_pc1()
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_wts_fsm_access(alias=self.wts_alias, fallback_prompt="#")

    def _teardown(self):
        pass

    def __del__(self):
        if self._setup_wts_flag:
            self.fsm_obj.teardown_all_aliases_for_wts_fsmaccess()

    def _convert_to_dict(self, strs):
        out_d = {}
        for i in strs.split():
            if i.count("="):
                out_d[i.split("=")[0]] = i.split("=")[1]
        return out_d

    def execute_cmd_on_wts(self, cmd):
        self._setup_wts()
        builtin_obj.log("Execute command on WTS:{}".format(cmd))
        out = self.fsm_obj.execute_command_on_wts(cmd, return_rc=True, alias=self.wts_alias)
        builtin_obj.log("Get Response:{}".format(out[0]))
        return out[0]

    def execute_egate_command(self, command, pass_regexp=None, fail_regexp=None, timeout=20, pf_mode=2, sleep_time=0.2,
                              padding_buffer='50000'):
        """
        This keyword is to wrapper execute_egate_command from ute-wtssim and no need to add "\" before "=".
        And return the command output.
        | Arguments      | Man. | Default | Description |
        | command        | Yes  | NA      | egate command to be executed |
        | pass_regexp    | No   | None    | regular expression for command pass condition |
        | fail_regexp    | No   | None    | regular expression for command fail condition |
        | timeout        | No   | 20      | timeout for waiting pass_regexp or fail_regexp |
        | pf_mode        | No   | 2       | The processing mode while give parameter pass_regexp and fail_regexp at
                                            the same time|
        | sleep_time     | No   | 0.2     | sleep time after execute egate command |
        | padding_buffer | No   | 50000   | set egate command output buffer size |

        Examples:
        1) execute egate command and wait pass_regexp
        | ${out} | Execute Egate Command | ue_attach id=1 | UE.* is Active |
        | Should Contain | ${out} |
        ue_stats_nr id=91 scell=9 type=pdsch    fail_regexp=CellIndex-9
        """
        self._setup_wts()
        out = self.iphy_obj.execute_egate_command(cmd=command,
                                                  pass_regexp=pass_regexp,
                                                  fail_regexp=fail_regexp,
                                                  timeout=timeout,
                                                  pf_mode=pf_mode,
                                                  padding_buffer=padding_buffer,
                                                  ignore_prompt_prefix=True)
        time.sleep(float(sleep_time))
        if out.count("\x1b[K") > 0:
            out = str_obj.remove_string(out, "\x1b[K")
        return out

    def execute_uex_command(self, command):
        builtin_obj.log("Execute UEx command:{}".format(command))
        uexgate_obj = builtin_obj.get_library_instance("ta_uexgate")
        # args = []
        # kwargs = {}
        # func = command.split()[0]
        # if len(command.split()) > 1:
        #     for item in command.split()[1:]:
        #         if item.count("="):
        #             kwargs[item.split("=")[0]] = item.split("=")[1]
        #         else:
        #             args.append(item)
        # out = uexgate_obj.run_uex_command(func, *args, **kwargs)
        out = uexgate_obj.run_uex_command(command)
        if command.startswith("get"):
            pretty_json = json.dumps(out, indent=4)
            builtin_obj.log("Uex command output:")
            builtin_obj.log(pretty_json)
        else:
            builtin_obj.log("Uex command output:{}".format(out))
        return out

    def execute_uex_command_and_expect_error(self, command, error):
        try:
            self.execute_uex_command(command)
        except Exception:
            detail = traceback.format_exc()
            if error not in detail:
                raise Exception("{} \nnot contain {}".format(detail, error))

    def release_all_ues(self):
        out = self.execute_uex_command("get_ue_summary")
        active_idle = out["active"] + out["idle"]
        # detach UE one by one. retry one more time if failed
        for ue_id in active_idle:
            try:
                self.execute_uex_command("ue_detach id={}".format(ue_id))
            except Exception:
                detail = traceback.format_exc()
                builtin_obj.log("debug: ue_detach id={} failed with reason:{}".format(ue_id, detail))
                time.sleep(10)
                builtin_obj.log("debug: retry to detach {}".format(ue_id))
                try:
                    self.execute_uex_command("ue_detach id={}".format(ue_id))
                except Exception:
                    detail = traceback.format_exc()
                    builtin_obj.log("debug: ue_detach id={} failed with reason:{}".format(ue_id, detail))
                    builtin_obj.log("fail to detach {}".format(ue_id), level="WARN")

    def get_throughput(self, ue_id, type="dl_mac", wait_time=30):
        """This keyword is to print throughput with command get_ue_stats
         command: get_ue_stats id=xxx type=xxx scell=0..7 unit=Mbps

        | Arguements | Man. | Default | Description  |
        | ue_id      | Yes  | NA      |              |
        | type       | No   | dl_mac  | dl_mac/dl_rlc/dl_pdcp |
        | wait_time  | No   | 30      | wait throughput stabler before get throughput |

        Example:
        | ${throughput}  | Get Throughput | ue_id=1 |
        | Should Be True | ${throughput["UE"]["Overall"]["cur"]} > 100 |
        """
        time.sleep(wait_time)
        out = self.execute_uex_command("get_ue_stats id={} type={} scell=0..7 unit=Mbps".format(ue_id, type))
        return out

    def _check_throughput(self, ue_id, target, source, type, timeout):
        # validate source
        source_1 = source.lower()
        source_supported = ["overall", "pcell", "scell-1", "scell-2", "scell-3",
                            "scell-4", "scell-5", "scell-6", "scell-7"]
        if source_1 not in source_supported:
            raise Exception("{} not supported, available object is one of {}".format(source, source_supported))
        # convert type
        if type == "current":
            type_1 = "cur"
        elif type == "average":
            type_1 = "avg"
        else:
            raise Exception("not support type={}, ask TA core team for help".format(type))
        # wait throughput larger than or equal to target
        interval = 10
        start_time = time.time()
        while True:
            out = self.execute_uex_command("get_ue_stats id={} type=dl_mac scell=0..7 unit=Mbps".format(ue_id))
            source_2 = source[0].upper() + source[1:].lower()
            if out["UE"][source_2][type_1] < float(target):
                time.sleep(interval)
                if time.time() - start_time > timeout:
                    raise Exception("UE{} {} throughput can't reach {} in timeout {}s".format(
                        ue_id, type, target, timeout))
            else:
                break

    def check_current_throughput(self, ue_id, target, source="overall", timeout=60):
        """This keyword is to validate current throughput reach target value in timeout
         command: get_ue_stats id=xxx type=dl_mac scell=0..7 unit=Mbps

        | Arguements | Man. | Default | Description  |
        | ue_id      | Yes  | NA      |              |
        | target     | Yes  | NA      | target value |
        | source     | No   | overall | overall/pcell/scell-1/scell-2.../scell-7 |
        | timeout    | No   | 30(s)|  | timeout to check throughput |

        Example:
        | Check Current Throughput | ue_id=1 | target=100 |
        | Check Current Throughput | ue_id=1 | target=100 | source=pcell |
        | Check Current Throughput | ue_id=1 | target=100 | source=scell-1 |
        """
        self._check_throughput(ue_id, target, source, "current", timeout)

    def check_average_throughput(self, ue_id, target, source="overall", timeout=60):
        """This keyword is to validate average throughput reach target value in timeout
         command: get_ue_stats id=xxx type=dl_mac scell=0..7 unit=Mbps

        | Arguements | Man. | Default | Description  |
        | ue_id      | Yes  | NA      |              |
        | target     | Yes  | NA      | target value |
        | source     | No   | overall | overall/pcell/scell-1/scell-2.../scell-7 |
        | timeout    | No   | 30(s)   | timeout to check throughput |

        Example:
        | Check Average Throughput | ue_id=1 | target=100 |
        """
        self._check_throughput(ue_id, target, source, "average", timeout)

    # def run_wts_command(self, command):
    #     uexgate_obj = builtin_obj.get_library_instance("ta_uexgate")
    #     return self.uexgate_obj.run_wts_command(command)
    #
    # def run_wts_command_and_expect_error(self, command, error):
    #     try:
    #         self.run_wts_command(command)
    #     except Exception:
    #         detail = traceback.format_exc()
    #         if error not in detail:
    #             raise Exception("{} \nnot contain {}".format(detail, error))

    def _get_files_name_according_to_pattern(self, path_to_file):
        path = path_to_file.rpartition("/")[0]
        pattern = path_to_file.rpartition("/")[2]
        out = self.pc_obj.execute_cmd_on_pc("cd %s; ls -ltr %s;cd ~" % (path, pattern))
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
        self._setup_wts()
        # create local log directory
        save_log_directory = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        wts_dir = "/opt/iphy/latest"
        if len(tag) == 0:
            local_dir = os.path.join(save_log_directory, "WTS_logs")
        elif tag.count("startup"):
            local_dir = os.path.join(save_log_directory, "%s_logs" % tag, "WTS_logs")
        else:
            local_dir = os.path.join(save_log_directory, "WTS_logs_%s" % tag)
        os_obj.create_directory(local_dir)
        # make rrc log complete
        all_rrc = self.pc_obj.execute_cmd_on_pc("ls -ltr %s/rrc*.log | awk '{print $9}'" % wts_dir)
        if "No such file or directory" not in all_rrc:
            latest_rrc = all_rrc.splitlines()[-1]
            try:
                date = self.common_obj.get_timestamp()
                self.execute_egate_command(date, "is unknown")
                builtin_obj.wait_until_keyword_succeeds("1 min", "2 sec", "egate_console_log_should_contain",
                                                        latest_rrc,
                                                        "Command %s is unknown" % date)
            except Exception as e:
                builtin_obj.log("get latest rrc failed with info: %s" % e)
            # get case only egate console log
            for rrc in all_rrc.splitlines():
                self.pc_obj.execute_cmd_on_pc("cat %s >> %s/case_egate_console.log" % (rrc, local_dir))

        # copy logs
        files = self._get_files_name_according_to_pattern(os.path.join(wts_dir, "*.log*"))
        for each_file in files:
            try:
                os_obj.copy_file(os.path.join(wts_dir, each_file[0]), os.path.join(local_dir, each_file[1]))
            except Exception:
                builtin_obj.log("copy %s failed" % os.path.join(wts_dir, each_file[0]))
        return local_dir

    def collect_uex_logs(self, tag):
        # define uex logs src dst directory
        self._setup_wts()
        output_dir = builtin_obj.get_variable_value("${OUTPUT_DIR}")
        uex_log_src_dir = os.path.join(output_dir, "uex_logs")
        save_log_directory = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        if tag.count("startup"):
            uex_log_dst_dir = os.path.join(save_log_directory, "%s_logs" % tag, "uex_logs")
        else:
            uex_log_dst_dir = os.path.join(save_log_directory, "uex_logs")
        os_obj.create_directory(uex_log_dst_dir)

        # copy latest uex_logs_x/*.log
        self.pc_obj.execute_cmd_on_pc("ls -ltr {}".format(uex_log_src_dir))
        self.pc_obj.execute_cmd_on_pc("cp -rf {}/*.log {}".format(uex_log_src_dir, uex_log_dst_dir))
        uex_logs_dir_list = self.pc_obj.execute_cmd_on_pc(
            "ls -ltr %s | grep uex_logs_ | awk '{print $9}'" % uex_log_src_dir).splitlines()
        if len(uex_logs_dir_list):
            self.pc_obj.execute_cmd_on_pc("cp -rf {}/{}/* {}".format(uex_log_src_dir,
                                                                     uex_logs_dir_list[-1],
                                                                     uex_log_dst_dir))
        # copy /home/cus/logs/l3proxy_*.log
        self.pc_obj.execute_cmd_on_pc("cp -f /home/cus/logs/l3proxy_*.log {}".format(uex_log_dst_dir))

        # copy tgr logs
        self.pc_obj.execute_cmd_on_pc("cp -f /opt/tgr_ss/var/log/etgr-ss.log {}".format(uex_log_dst_dir))
        self.pc_obj.execute_cmd_on_pc("cp -f /opt/tgr_ms/var/log/etgr-ms.log {}".format(uex_log_dst_dir))

        # decode cell-*.log
        self.pc_obj.execute_cmd_on_pc("cd {}".format(uex_log_dst_dir))
        cells_log = self.pc_obj.execute_cmd_on_pc("ls -ltr cell-*.log | awk '{print $9}'")
        if cells_log.count("No such file or directory"):
            self.pc_obj.execute_cmd_on_pc("cd ~")
            return
        for cell_log in cells_log.splitlines():
            self.pc_obj.execute_cmd_on_pc("uesim-dump {} > {}_decode.log".format(cell_log, cell_log.split(".")[0]))
        self.pc_obj.execute_cmd_on_pc("cd ~")

    def egate_console_log_should_contain(self, egate_console_log, check_strs, timeout=60, interval=10):
        self._setup_wts()
        check_strs = self.common_obj.remove_empty_from_list(check_strs)
        retry_times = int(timeout) / int(interval)
        while retry_times > 0:
            try:
                self.execute_egate_command("set_log flush")
                self.pc_obj.file_should_contain_strings(egate_console_log, *check_strs)
                return
            except Exception:
                detail = traceback.format_exc()
                retry_times = retry_times - 1
                time.sleep(int(interval))
        if retry_times == 0:
            raise Exception(detail)

    # def rrc_should_contain(self, *expected_strings):
    #     check_strs = [str for str in expected_strings]
    #     all_rrc = self.pc_obj.execute_cmd_on_pc("ls -ltr /opt/iphy/latest/rrc*.log | awk '{print $9}'")
    #     latest_rrc = all_rrc.splitlines()[-1]
    #     try:
    #         self.egate_console_log_should_contain(latest_rrc, check_strs, timeout=60, interval=2)
    #     except Exception:
    #         detail = traceback.format_exc()
    #         raise Exception(detail)
    #     finally:
    #         self.get_rrc_log()
    #
    # def rrc_should_not_contain(self, *expected_strings):
    #     check_strs = [str for str in expected_strings]
    #     all_rrc = self.pc_obj.execute_cmd_on_pc("ls -ltr /opt/iphy/latest/rrc*.log | awk '{print $9}'")
    #     latest_rrc = all_rrc.splitlines()[-1]
    #     try:
    #         self.get_rrc_log()
    #         self.pc_obj.file_should_not_contain_strings(latest_rrc, *expected_strings)
    #     except Exception:
    #         detail = traceback.format_exc()
    #         raise Exception(detail)

    def _file_match_all(self, source_file_path, regexp):
        """This keyword return all matched regexp list
        :param source_file_path: Source file path
        :param regexp: match regexp
        :return: matched list, [] if match nothing.
        """
        if type(regexp) is str:
            regexp = regexp.encode('utf-8')

        with open(source_file_path, 'r+') as self._file_obj:
            data = mmap.mmap(self._file_obj.fileno(), 0)
            result = re.findall(regexp, data)
            return result

    def _split_iphy_log_by_ueid(self, src_file):
        """split iphy log by ueid
        :param src_file: Source file path
        """
        self._src_path = src_file
        with open(src_file, 'r+') as self._file_obj:
            self.file_content = self._file_obj.readlines()

        ue_id_list = self._file_match_all(
            self._src_path, r'\d{2}:\d{2}:\d{2}.\d{3}.*\s(UE\d+).*\[')
        ue_id_list = set(ue_id_list)

        start_index = []
        for line in range(len(self.file_content)):
            if re.match(r'^\d{2}:\d{2}:\d{2}.\d{3}', self.file_content[line]):
                start_index.append(line)

        start_index.append(len(self.file_content))
        for ue_id in ue_id_list:
            if type(ue_id) is bytes:
                ue_id = ue_id.decode('utf-8')
            frame_content = []
            new_file_path = self._src_path.replace('.log', '_%s.log' % ue_id)

            for num in range(len(start_index) - 1):
                if ue_id in self.file_content[start_index[num]]:
                    frame_content.extend(self.file_content[
                                         start_index[num]:start_index[num + 1]])
            with open(new_file_path, 'a') as fw:
                fw.writelines(frame_content)

    # def get_rrc_log(self):
    #     """
    #     to get complete rrc log, it is tailed from egate_console.log.
    #     precondition: start_rrc_log is executed before
    #     """
    #     wts_exe_dir = "/opt/iphy/latest"
    #     out = self.pc_obj.execute_cmd_on_pc("ps -ef | grep tail | grep egate_console.log | grep -v grep ")
    #     if len(out) != 0:
    #         all_rrc = self.pc_obj.execute_cmd_on_pc("ls -ltr %s/rrc*.log | awk '{print $9}'" % wts_exe_dir)
    #         latest_rrc = all_rrc.splitlines()[-1]
    #         date = self.common_obj.get_timestamp()
    #         self.execute_egate_command(date, "is unknown")
    #         self.egate_console_log_should_contain(latest_rrc, "Command %s is unknown" % date,
    #                                               timeout=60, interval=2)
    #         save_log_directory = builtin_obj.get_variable_value('${SAVE LOG DIRECTORY}')
    #         os_obj.copy_file(latest_rrc, save_log_directory)
    #         self._split_iphy_log_by_ueid(os.path.join(save_log_directory, latest_rrc.split("/")[-1]))

    def get_ue_crnti(self, ueid):
        """
        get ue crnti with command ue_disp
        """
        ue_disp = self._disp_ue(ueid)
        match = re.search(r"C-RNTI +(\d+)", ue_disp, re.I)
        if match is not None:
            crnti = match.group(1)
            return crnti
        else:
            raise Exception("no crnti found for ue%s, pls make sure the ue is active" % ueid)

    def get_ue_location(self, ueid):
        """
        get enb, cellid where UE located.
        for example:
        | ${enb_id} | ${cell_id} | Get UE Location | 1 |
        | should be equal | ${enb_id} | 1 |
        | should be equal | ${cell_id} | 11 |
        """
        ue_disp = self._disp_ue(ueid)

        match = re.search(r"enb +(\d+)", ue_disp, re.I)
        if match is not None:
            enb = match.group(1)
        else:
            raise Exception("no enb found for %s" % ueid)

        match = re.search(r"cell +(\d+)", ue_disp, re.I)
        if match is not None:
            cellid = match.group(1)
        else:
            raise Exception("no cellid found for %s" % ueid)

        return enb, cellid

    def get_ue_mme(self, ueid):
        """
        get ue mme location with command ue_disp
        """
        ue_disp = self._disp_ue(ueid)
        match = re.search(r"serving MME id\s+(\d+)", ue_disp, re.I)
        if match is not None:
            mme = match.group(1)
            return mme
        else:
            raise Exception("no mme found for ue%s, pls make sure the ue is active" % ueid)

    def get_ue_scell_info(self, ueid):
        """
        execute ue_disp id=<ue_id> and return 2-keys dictionary.\n
        The first key is scell index.\n
        The second key is sector and status.\n
        Example:
        | ${scell_info} | Get UE Scell Info | 1 |
        | Should Be Equal | ${scell_info["1"]["sector"]} | 1 |
        | Should Be Equal | ${scell_info["1"]["status"]} | activated |
        """
        ue_info = self.execute_uex_command("get_ue_info id=%s" % ueid)
        ue_info_key_str = {str(key): value for key, value in ue_info["ca_cells"].items()}
        return ue_info_key_str

    def get_bearer_info(self, ue_id):
        """
        execute bearer_disp ue=<ue_id> at=ue and return 2-keys dictionary.\n
        The first key is QCI id.\n
        The second key is Id, EBI, RBI, SCG, RLC, LCG, LCP, RoHC, maxCid, RoHC, PDN, MBR and GBR.\n
        Example:
        | ${bearer_info} | Get Bearer Info | 1 |
        | Should Be Equal | ${bearer_info["6"]["SCG"]} | 4 |
        | Should Be Equal | ${bearer_info["6"]["EBI"]} | 5 |
        """
        out = self.execute_egate_command("bearer_disp ue=%s at=ue" % ue_id, fail_regexp="keyword end", timeout=5)
        valid_lines = []
        bearer_info = {}
        out = out.replace("SCG LCID", "SCG").replace("RoHC Ctx", "RoHC").replace(
            "MBR, kbps", "MBR").replace("GBR, kbps", "GBR").replace(" DL=", "zyDL=")
        for line in out.strip().splitlines():
            if line.count("===") == 0 and line.count("---") == 0 and line.count("EGATE>") == 0 and len(line.strip()):
                valid_lines.append(line)
        titles = valid_lines[0].split()
        for line in valid_lines[1:]:
            one_bearer_info = {}
            values = line.split()
            for index in range(len(titles)):
                one_bearer_info[titles[index]] = values[index].replace("zy", " ")
            bearer_info[line.split()[12]] = one_bearer_info
        return bearer_info

    def get_field_value(self, logs, field_name, sep=":"):
        """
        get entry from logs and return field value.
        """
        match = re.search(r"\b%s\s*%s\s*(.*)" % (field_name, sep), logs, re.I)
        if match is not None:
            field_value = match.group(1)
            return field_value.strip()
        else:
            raise Exception("no %s in logs" % field_name)

    def get_ue_x2ap_ids(self, ue_id, logs):
        """
        get UE_X2AP_ID and SgNB_UE_X2AP_ID, and deposit them for
        keyword iphy_gnb_send_error_indication .\n
        logs: logs including SgNBAdditionRequestAcknowledge,
        x2 protocol must be opened via sim_trace command.\n
        for example:
        | Iphy Execute Ue Command Without Kargs | trace enb=7 protocol=x2 on |
        | ${out} | Iphy Execute Ue Command Without Kargs |
                   ue_measurement_send id=1 meas_id=17 event=B1_NR phycell_id=31 nrsrp=60 |
                   pass_regexp=Bearer-type change from MCG to SCG-split is successful |
        | Get UE X2ap Ids | 1 | ${out} |
        """
        ue_x2ap_id = self.get_field_value(logs, "UE-X2AP-ID")
        sgnb_ue_x2ap_id = self.get_field_value(logs, "SgNB-UE-X2AP-ID")
        enb, cell = self.get_ue_location(ue_id)
        ue_crnti = self.get_ue_crnti(ue_id)
        self.ue_info["%s_%s_%s" % (enb, cell, ue_crnti)] = (ue_x2ap_id, sgnb_ue_x2ap_id)
        return ue_x2ap_id, sgnb_ue_x2ap_id

    def iphy_gnb_send_error_indication(self,
                                       ue_id,
                                       cause="unknown-pair-of-UE-X2AP-ID",
                                       expect_string="SgNBReleaseRequestAcknowledge",
                                       gnb="7",
                                       enb="1",
                                       ue_x2ap_id=None,
                                       sgnb_ue_x2ap_id=None):
        """
        send error indication message from gnb to enb by command send_hex.\n
        cause: support unknown-old-eNB-UE-X2AP-ID,
               unknown-old-en-gNB-UE-X2AP-ID,
               unknown-pair-of-UE-X2AP-ID and unknown-new-eNB-UE-X2AP-ID.\n
        if ue_x2ap_id or sgnb_ue_x2ap_id is None,
        it will use the right UE-X2AP-ID and SgNB-UE-X2AP-ID for sending error indication.
        You can give specifed value for them in abnormal cases. \n
        this keyword depends on keyword get_ue_x2ap_ids to get UE_X2AP_ID and SgNB_UE_X2AP_ID.
        don't forget to call it when setup ENDC.\n
        for example:
        | Iphy Gnb Send Error Indication | ue_id=1 |
        | Iphy Gnb Send Error Indication | ue_id=1 | cause="unknown-old-en-gNB-UE-X2AP-ID" |
        | Iphy Gnb Send Error Indication | ue_id=1 | cause="unknown-old-eNB-UE-X2AP-ID" |
        expect_string="IS IDLE" |
        | Iphy Gnb Send Error Indication | ue_id=1 | expect_string=${EMPTY} | ue_x2ap_id=1000 |
        sgnb_ue_x2ap_id=2000 |
        """
        cause_mapping = {
            "": "",
            "unknown-old-eNB-UE-X2AP-ID": "0300",
            "unknown-old-en-gNB-UE-X2AP-ID": "1360",
            "unknown-pair-of-UE-X2AP-ID": "0380",
            "unknown-new-eNB-UE-X2AP-ID": "0280",
        }
        cause_code = cause_mapping[cause]

        if ue_x2ap_id is None or sgnb_ue_x2ap_id is None:
            try:
                enb, cell = self.get_ue_location(ue_id)
                ue_crnti = self.get_ue_crnti(ue_id)
                ue_x2ap_id_r, sgnb_ue_x2ap_id_r = self.ue_info["%s_%s_%s" % (enb, cell, ue_crnti)]
            except Exception:
                raise Exception("no ue_x2ap_id and sgnb_ue_x2ap_id info, "
                                "pls call get_ue_x2ap_ids when setup ENDC")

        if ue_x2ap_id is None:
            ue_x2ap_id = ue_x2ap_id_r

        if sgnb_ue_x2ap_id is None:
            sgnb_ue_x2ap_id = sgnb_ue_x2ap_id_r

        payload_len = 28
        item_len = 4
        for ele_len in [len(ue_x2ap_id), len(sgnb_ue_x2ap_id), len(cause_code)]:
            if ele_len == 0:
                payload_len = payload_len - 6
                item_len = item_len - 1

        payload = "000340%s00000%s" % (hex(payload_len)[2:].zfill(2), item_len)
        if len(ue_x2ap_id):
            payload = payload + "00094002%s" % (hex(int(ue_x2ap_id))[2:].zfill(4))
        if len(cause_code):
            payload = payload + "00054002%s" % (cause_code)
        payload = payload + "00114003701B40"
        if len(sgnb_ue_x2ap_id):
            payload = payload + "01084002%s" % (hex(int(sgnb_ue_x2ap_id))[2:].zfill(4))

        command = "send_hex source=gnb:%s target=enb:%s hex=%s" % (gnb, enb, payload)
        if len(expect_string) == 0:
            expect_string = None
        out = self.execute_egate_command(command, expect_string)
        return out

    def parse_modifylua_to_get_wts_performance_paras(self, suite_source="", keyword_modify_lua="Modify Lua"):
        f = open(suite_source, "r")
        robot_content = f.read()
        f.close()
        gnb_id = []
        pgw_id = []
        sgw_id = []
        # ret = re.search("%s\n(.+\n)+\n*"%keyword_modify_lua,robot_content,re.I|re.M)    # windows
        ret = re.search("%s\r\n(.+\r\n)+(\r\n)*" % keyword_modify_lua, robot_content, re.I | re.M)  # linux
        if ret is None:
            print(
                "Don't found '%s' code block in robot script '%s'. End directly." % (keyword_modify_lua,
                                                                                     suite_source))
        else:
            ml = ret.group()
            print("'%s' code block is :\n%s" % (keyword_modify_lua, ml))
            [gnb_id.append(int(id)) for id in
             re.findall(r"set[_|\s{1}]gnb[_|\s{1}]In[_|\s{1}]Lua.+gnb_id=(\d+)", ml, re.I)]
            [pgw_id.append(int(id)) for id in
             re.findall(r"set[_|\s{1}]pgw[_|\s{1}]In[_|\s{1}]Lua.+pgw_id=(\d+)", ml, re.I)]
            [sgw_id.append(int(id)) for id in
             re.findall(r"set[_|\s{1}]sgw[_|\s{1}]In[_|\s{1}]Lua.+sgw_id=(\d+)", ml, re.I)]
        return [gnb_id, pgw_id, sgw_id]


class operate_on_rru(object):
    def __init__(self):
        self.rru_ip = None
        self.rru_conns = {}

    def __del__(self):
        for conn in self.rru_conns.values():
            ssh_obj.disconnect_from_host(conn)

    def execute_cmd_on_rru(self, cmd, rru_ip="172.16.9.129", user_name="root", password="root", cmd_timeout="10"):
        """This keyword is to perform delta cmd to rru
        | Input Parameters | Man. | Description |
        | cmd   |  Yes  | "/run/rfsh.sh sendFault 1136 3 0 0 0 0" |
        """
        self.rru_ip = rru_ip

        bts_conn = ssh_obj.connect_to_host(FCT_IP, "22", BTS_USERNAME, BTS_PASSWORD, conn_type="SSH", timeout="10")
        out = ssh_obj.execute_shell_command("lxc-ls --active")
        node = [i for i in out.strip().split() if i.endswith("018")][0]
        if node not in ["0x1018", '0x2018']:
            raise Exception("Not find node like 0x1018/0x2018")
        ssh_obj.execute_shell_command("lxc-attach -n %s" % node)
        builtin_obj.log("node connection is %s" % node)
        old = ssh_obj.set_shell_prompt("$", "#", ":")
        ret = ssh_obj.execute_shell_command('arp -a| grep -v incomplete')
        builtin_obj.log("arp ips is %s" % ret)

        if node.lower() == "0x1018":
            rru_port = "23"
            if not cmd.strip().startswith("/run/rfsh.sh"):
                cmd = " ".join(("/run/rfsh.sh", cmd.strip()))
        else:
            rru_port = "2323"
            if cmd.strip().startswith("/run/rfsh.sh"):
                cmd = cmd.strip().lstrip("/run/rfsh.sh").strip()
        builtin_obj.log("telnet to rru %s:%s" % (self.rru_ip, rru_port))
        ssh_obj.execute_shell_command("telnet %s %s" % (self.rru_ip, rru_port))
        ssh_obj.execute_shell_command(user_name)
        ssh_obj.execute_shell_command(password)
        self.rru_conns[self.rru_ip] = bts_conn

        builtin_obj.log("Execute Command: %s" % cmd)
        return ssh_obj.execute_shell_command(cmd, timeout_add=cmd_timeout)


class operate_on_fsp(object):
    def __init__(self):
        pass

    def __del__(self):
        pass

    def execute_cmd_on_fsp(self, cmd, target):
        """This keyword is to perform command on FSP.
        keyword steps:
        | 1 | auto-adapt target DSP or K2 according to rack position.
        for example asp-1a is modified as asp-5a for right rack |
        | 2 | ssh to FCT |
        | 3 | ssh to taget DSP(K2) and execute command |
        | 4 | disconnect from FCT |
        arguments:
        | Input Parameters | Man. | Description |
        | cmd   |  Yes  |  |
        | target | Yes |  DSP or K2 on which to execute the command. keyword will auto-adapt it for left/right rack. |
        for example:
        | ${out}  | execute_cmd_on_fsp | ncpRead 0x44.0x10.0x100 2 | asp-1a |
        """
        rack_position = builtin_obj.get_variable_value("${RACK_POSITION}")
        if rack_position.lower().count("left"):
            target = target.replace("5", "1").replace("6", "2").replace("7", "3")
        elif rack_position.lower().count("right"):
            target = target.replace("1", "5").replace("2", "6").replace("3", "7")
        else:
            target = target

        try:
            bts_conn = ssh_obj.connect_to_host(FCT_IP, "22", BTS_USERNAME, BTS_PASSWORD, conn_type="SSH", timeout="10")
            old_prompt = ssh_obj.set_shell_prompt("Password:", r"\?", ":~ >")
            ssh_out = ssh_obj.execute_shell_command("ssh toor4nsn@%s" % target)
            if ssh_out.count("fingerprint"):
                ssh_obj.execute_shell_command("yes")
            ssh_obj.set_shell_prompt(old_prompt)
            ssh_obj.execute_shell_command(BTS_PASSWORD)
            out = ssh_obj.execute_shell_command(cmd)
        except Exception:
            pass
        finally:
            ssh_obj.disconnect_from_host(bts_conn)
        return out


class adapt_hw(object):
    def __init__(self):
        pass

    def __del__(self):
        pass

    def _get_enb_interface(self):
        "get the interfaces of enb s1 10.0.1.2 and LMP 192.168.255.1"
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        if bbu_type == "FSMF":
            interfaces = ("eth3", "eth5:2")
        elif bbu_type == "ASIA" or bbu_type == "ASIB":
            interfaces = ("br1", "ethlmp0:2")
        elif bbu_type == "ASIL" or bbu_type == "ASIM":
            interfaces = ("br0", "ethlmp0:2")
        else:
            raise Exception("new hw:%s, pls adapt keyword" % bbu_type)
        return interfaces

    def get_s1_interface(self):
        return self._get_enb_interface()[0]

    def get_lmp_interface(self):
        return self._get_enb_interface()[1]

    def get_swpool_path(self):
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        if bbu_type == "FSMF":
            path = "/ffs/run"
        else:  # ASIA, ASIB, ASIL
            path = "/ffs/run/swpool/OAM"
        return path

    def decide_configurate_files_path(self):
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        bbmod_type = builtin_obj.get_variable_value("${BBMOD_TYPE}")
        bts_build = builtin_obj.get_variable_value("${ENB_SW_VERSION}")
        scf_template_path = builtin_obj.get_variable_value("${SCF_TEMPLATE_PATH}")
        if bts_build.count("_9999_") or bts_build.count("_9990_"):
            # SBTS22R1_ENB_9999_210617_000005
            release_path = "trunk"
        else:
            # SBTS21B_ENB_0000_000236_000000
            release_path = bts_build.split("_")[0]
        if os.path.exists(os.path.join(scf_template_path, release_path)):
            release_path = release_path
        else:
            release_path = "trunk"
        if bbu_type == "ASIA":
            sub_path = "CLOUD_R4A_CUS"
        elif bbu_type == "FSMF":
            sub_path = "CLOUD_R3_CUS"
        elif bbu_type == "ASIB" and bbmod_type == ['ABIO', None, None]:
            sub_path = "CLOUD_R4BO9_CUS"
        elif bbmod_type == ["ABIA", "ABIP", "ABIO"]:
            sub_path = "CLOUD_R4xAPO_CUS"
        elif bbmod_type == ["ABIA", "ABIN", "ABIO"] or bbmod_type == [None, "ABIN", "ABIO"]:
            sub_path = "CLOUD_R4xANO_CUS"
        elif bbmod_type == ["ABIA", "ABIP", "ABIN"]:
            sub_path = "CLOUD_R4xAPN_CUS"
        elif bbmod_type == ["ABIP", None, None]:
            sub_path = "CLOUD_R4xP12_CUS"
        elif bbmod_type == ["ABIA", "ABIQ", "ABIN"]:
            sub_path = "CLOUD_R4MAQN_CUS"
        else:
            raise Exception("can't decide configuration file path, "
                            "according to bbu_type={}, bbmod_type={}".format(bbu_type, bbmod_type))

        configuration_file_path = "%s/%s/%s" % (scf_template_path, release_path, sub_path)
        return configuration_file_path

    def judge_hw_type(self):
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        if bbu_type == "FSMF":
            hw_type = "R3"
        else:  # ASIA, ASIB, ASIL
            hw_type = "R4"
        return hw_type

    def _restart_bts_with_ddal(self, remote_host=None):
        hw_type = self.judge_hw_type()
        if hw_type == "R3":
            # ddal -s ddal_reboot_graceful or ddal -s ddal_watchdog_reboot_site
            command = "ddal -s ddal_reboot_graceful"
        else:
            command = "ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN"

        fsm_obj = ute_fsmaccess()
        fsm_obj.setup_enb_fsm_access(alias=remote_host, fallback_prompt="#", host="192.168.255.129",
                                     remote_host=remote_host)
        try:
            builtin_obj.log("execute command: %s" % command)
            fsm_obj.execute_command_on_enb(command, alias=remote_host)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        finally:
            fsm_obj.teardown_enb_fsm_access(alias=remote_host)

    def reboot_bts(self):
        log_obj = common()
        log_obj.log_to_console_with_time_prefix("restart eNB with ddal reboot")
        self._restart_bts_with_ddal()

    def reboot_bts_enb2(self):
        remote_host = builtin_obj.get_variable_value('${TGT1_BTS_PC_INFO.IP}')
        log_obj = common()
        log_obj.log_to_console_with_time_prefix("restart eNB2 with ddal reboot")
        self._restart_bts_with_ddal(remote_host)


class common_lib(common, operate_on_local_pc1, operate_on_local_pc2, operate_on_bts1, operate_on_bts2,
                 operate_on_wts, operate_on_rru, operate_on_fsp, adapt_hw):
    def __init__(self):
        common.__init__(self)
        operate_on_local_pc1.__init__(self)
        operate_on_local_pc2.__init__(self)
        operate_on_bts1.__init__(self)
        operate_on_bts2.__init__(self)
        operate_on_wts.__init__(self)
        operate_on_rru.__init__(self)
        operate_on_fsp.__init__(self)
        adapt_hw.__init__(self)


if __name__ == "__main__":
    obj = common_lib()
    help(obj)
