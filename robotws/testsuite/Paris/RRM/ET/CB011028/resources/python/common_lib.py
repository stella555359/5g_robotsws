# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
"""

import os
import re
import time
import datetime
import sys
import mmap
import copy
import configparser
from imp import reload
from ute_fsmaccess import ute_fsmaccess
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.String import String

from ute_wtssim import ute_wtssim
from testsuite.Paris.RRM.ET.CB009836.resources.python.ta_ssh_telnet_gate import install_and_import_ta_ssh_telnet
from testsuite.Paris.RRM.ET.CB011028.resources.python.ta_xml_gate import install_and_import_ta_xml

# import telnetlib
import random
import traceback

builtin_obj = BuiltIn()
os_obj = OperatingSystem()
str_obj = String()
global ta_ssh
ta_ssh = install_and_import_ta_ssh_telnet()
ssh_obj = ta_ssh.ta_ssh_telnet()
# BEWARE that this part introduced issue with iphy.xml !!! (corrupted) when robot script use XmlConfig.setListEltText
# need to configure etree default parser (etree.set_default_parser(default_parser)) in XmlConfig constructor
# use of DedicatedXmlConfig.robot instead!!!
global ta_xml
ta_xml = install_and_import_ta_xml()
CommonXML = ta_xml.common_xml.CommonXML()
xml_obj = ta_xml.ta_xml()
# end Of BEWARE !!!
FCT_IP = "192.168.255.1"
BTS_USERNAME = "toor4nsn"
BTS_PASSWORD = "oZPS0POrRieRtu"

ue_info = {}


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
        all_elements = commonxml_obj.get_elements("//*[matches(@class, '.*NRCELL$')]")
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
        if alias == "gnb1":
            save_log_dir = builtin_obj.get_variable_value("${testCaseDir}")
        else:
            save_log_dir = "%s/%s/" % (builtin_obj.get_variable_value("${testCaseDir}"), alias)
        os_obj.create_directory(save_log_dir)
        return save_log_dir

    def get_duplex(self, scfc_file, params_in_scf=None):
        """
        the keyword is to get duplex value from SCFC and ${PARAMS_IN_SCFC}
        | Input Parameters  | Man. | Description |
        | scfc_file        | Yes  |  gNB SCFC XML file |
        | params_in_scf    | No  |  the change list for scfc parameter in case definition
        | Return | return duplex value for 'tdd' 'fdd' 'fddtdd' or 'unknow' |
        Example
        | ${duplex_value} | Get Duplex| D:\\SCFC_1.xml| ${params_in_scf} |
        """
        try:
            os_obj.file_should_exist(scfc_file)
        except Exception:
            builtin_obj.log("SCFC file not exist %s in get duplex" % scfc_file, level="WARN")
            return 'unknow'
        # get duplex value from SCFC
        duplex_from_scfc = {}
        xpath = "//*[@name='cellTechnology']"
        commonxml_obj = CommonXML(scfc_file)
        all_elements = commonxml_obj.get_elements(xpath)
        for each_element in all_elements:
            mo_name = commonxml_obj.get_element_attribute((commonxml_obj.get_parent_element(each_element)), "distName")
            ret = re.search(r"nrcell-(\d+)", mo_name.lower())
            if ret:
                duplex_from_scfc[ret.group(1)] = each_element.text
        print(duplex_from_scfc)

        if bool(params_in_scf) is not True:
            return self._cal_duplex_value(duplex_from_scfc)
        params_in_scf = self.remove_empty_from_list(params_in_scf)
        # get duplex value from paramer_in_scf
        duplex_from_params_in_scf = {}
        for para in params_in_scf:
            if para.lower().count("celltechnology") == 0 or para.lower().count("delete"):
                continue
            duplex_value = ''
            if para.lower().count("fdd"):
                duplex_value = 'FDD'
            elif para.lower().count("tdd"):
                duplex_value = 'TDD'
            else:
                continue
                builtin_obj.log("celltechnology is unknow, %s" % para, level="WARN")

            ret = re.search(r"nrcell-(\d+)", para.lower())
            if ret:
                duplex_from_params_in_scf[ret.group(1)] = duplex_value

        # delete paramter from duplex_from_scfc
        for para in params_in_scf:
            if para.lower().count("delete"):
                if para.lower().count("celltechnology"):
                    ret = re.search(r"nrcell([-]]\d+)", para.lower())
                    if ret:
                        if ret.group(1).count("-") == 0:
                            duplex_from_scfc = {}
                        else:
                            duplex_from_scfc.pop(re.findall(r"\d+", ret.group(1))[0])
                else:
                    ret = re.search(r"nrcell$", para.lower())
                    if ret:
                        duplex_from_scfc = {}

        return self._cal_duplex_value(duplex_from_scfc, duplex_from_params_in_scf)

    def _cal_duplex_value(self, dict1, dict2=None):
        tdd_flag = False
        fdd_flag = False
        total_dict = copy.deepcopy(dict1)

        if dict2:
            for key_dict2, item_dict2 in dict2.items():
                find_flag = False
                for key_dict1, item_dict1 in total_dict.items():
                    if key_dict2 == key_dict1:
                        total_dict[key_dict1] = dict2[key_dict2]
                        find_flag = True
                        break
                if find_flag is False:
                    total_dict[key_dict2] = item_dict2
        for value in total_dict.values():
            if value.lower().count("fdd"):
                fdd_flag = True
                continue
            if value.lower().count("tdd"):
                tdd_flag = True
                continue
        if tdd_flag and fdd_flag:
            return 'fddtdd'
        elif tdd_flag:
            return 'tdd'
        elif fdd_flag:
            return 'fdd'
        else:
            return 'unknow'

    def get_network_mode(self, scfc_file, params_in_scf=None):
        """the keyword is to get network mode from SCFC and ${PARAMS_IN_SCFC}
        | Input Parameters | Man. | Description |
        | scfc_file        | Yes | gNB SCFC XML file |
        | params_in_scf    | No  | the change list for scfc parameter in case definition |
        | Return | return network mode for 'sa' 'nsa' 'sansa' or 'unknow' |
        Example
        | ${Network_Mode} | Get Network Mode| D:\\SCFC_1.xml | ${params_in_scf} |
        """
        try:
            os_obj.file_should_exist(scfc_file)
        except Exception:
            raise Exception("SCFC file not exist under %s.\r\n"
                            "Suggest Workaround:\r\n"
                            "1.Please check above file path right or not.\r\n"
                            "2.Please check the case running on correct testline site type.\r\n"
                            "Otherwise, please contact TA core team without hesitate."
                            % scfc_file)
        # get duplex value from SCFC
        network_mode_from_scfc = ''
        xpath = "//*[@name='gNbCuType']"
        commonxml_obj = CommonXML(scfc_file)
        elements = commonxml_obj.get_element(xpath)
        network_mode_from_scfc = elements.text

        # get network mode from paramer_in_scf
        params_in_scf = self.remove_empty_from_list(params_in_scf)
        if len(params_in_scf) == 0:
            return network_mode_from_scfc

        for para in params_in_scf:
            if para.lower().find("gnbcutype") == -1:
                continue
            network_mode_from_params_in_scf = re.search(r"gnbcutype=(\S+)", para, re.I)
            if network_mode_from_params_in_scf:
                return network_mode_from_params_in_scf.group(1)
        return network_mode_from_scfc

    def get_all_cells_id_from_scfc(self, scfc_file):
        """the keyword is to get all cells id and lcrid from SCFC
        | Input Parameters | Man. | Description |
        | scfc_file        | Yes | gNB SCFC XML file |
        | Return | return a list and include NRCELL-1:lcrid=1/NRCELL-11:lcrid=11 like this [('1', '1'), ('11', '11')] |
        | rtype | list |
        Example
        | ${cells_id} | _Get All Cells Id From Scfc | D:\\SCFC_1.xml |
        """
        if os.path.isfile(scfc_file) is not True:
            raise Exception("please provide correct SCFC file %s" % scfc_file)
        cell_ids = []
        commonxml_obj = CommonXML(scfc_file)
        all_elements = commonxml_obj.get_elements("//*[matches(@class, '.*:NRCELL$')]")
        for each_element in all_elements:
            dn = commonxml_obj.get_element_attribute(each_element, "distName")
            instance_id = dn.rpartition("-")[-1]
            lcr_id = xml_obj.read_xml(
                scfc_file, "text|//*[matches(@distName, '.*/NRCELL-%s$')]/*[matches(@name, 'lcrId')]" % instance_id)
            cell_ids.append((instance_id, lcr_id))
        return cell_ids

    def get_bbmod_rt_id_by_cell_id(self, scfc_file, cell_id):
        """
        the function is to get BBMOD_R id by specific cell id value. it help know which board connected to cell.
        | Input Parameters  | Man. |  Description   |
        | scfc_file         | Yes  |  gnb scfc file |
        | cell id           | Yes  |  the cell id which you want to find |
        | Return  | list type | the bbmod id list corresponding to cell id |
        Example
        | ${bbmod_id_list} | Get Bbmod Rt Id By Cell Id | scfc_file=D:\\SCFC_1.xml | cell_id=1 |
        """
        # find all rmod texts from LCELNR + cell_id value.
        commonxml_obj = CommonXML(scfc_file)
        rmodObjects = commonxml_obj.get_elements(
            "//managedObject[matches(@distName,'%s')]/*[@name='%s' or @name='%s']" % (
                ".*/LCELNR-{}/.*".format(str(cell_id)), "antlDN", "resourceDN")
        )
        rmodTexts = [commonxml_obj.get_element_text(rmodObject) for rmodObject in rmodObjects]
        if rmodTexts:
            builtin_obj.log("all RMOD texts are {}".format(rmodTexts))
        else:
            raise Exception("Can not find RMOD ID from cell id {}".format(cell_id))
        # extract Rmod Id from rmod texts
        rmodIds = self._find_specific_dn_id_from_texts(list_of_text=rmodTexts, distname="rmod")
        builtin_obj.log("RMOD ids are {}".format(rmodIds))
        # find bbmod id by getting rmod id
        bbmodTexts = []
        for rmodId in rmodIds:
            bbmodObjects = commonxml_obj.get_elements(
                "//managedObject[matches(@class,'.*:CABLINK$')]/p[@name='secondEndpointDN' and contains(text(),"
                "'RMOD-%s')]/../p[@name='firstEndpointDN' and contains(text(),'BBMOD')]" % rmodId)
            bbmodTexts.extend(
                [commonxml_obj.get_element_text(bbmodObject) for bbmodObject in bbmodObjects])
        builtin_obj.log("all BBMOD texts are {}".format(bbmodTexts))
        # extract bbmod Id from bbmod texts
        bbmodIds = self._find_specific_dn_id_from_texts(list_of_text=bbmodTexts, distname="bbmod")
        builtin_obj.log("BBMOD ids are {}".format(bbmodIds))
        # Find bbmod_R from BBMOD Ids
        bbmodRuntimeTexts = []
        for bbmodId in bbmodIds:
            bbmodRuntimeObjects = commonxml_obj.get_elements(
                "//managedObject[matches(@class,'.*:BBMOD_R$')]/p[@name='configDN' and contains(text(),"
                "'BBMOD-%s')]/.." % bbmodId)
            bbmodRuntimeTexts.extend(
                [commonxml_obj.get_element_attribute(bbmodRuntimeObject, "distName")
                 for bbmodRuntimeObject in bbmodRuntimeObjects])
        builtin_obj.log("all BBMOD_R texts are {}".format(bbmodRuntimeTexts))
        # extract bbmod_R Id from bbmod_r texts
        bbmodRuntimeIds = self._find_specific_dn_id_from_texts(list_of_text=bbmodRuntimeTexts, distname="bbmod_r")
        builtin_obj.log("BBMOD_R ids are {}".format(bbmodRuntimeIds))
        return bbmodRuntimeIds

    def get_bbmod_ids_from_scfc(self, scfc_file):
        """
        the function is to get all BBMOD id from scfc file. it help know which board id exists on gnb.
        | Input Parameters  | Man. |  Description   |
        | scfc_file         | Yes  |  gnb scfc file |
        | Return  | list type | the bbmod id list|
        Example
        | ${bbmod_id_list} | Get Bbmod Ids From Scfc | scfc_file=D:\\SCFC_1.xml |
        """
        # find all bbmod texts from class include bbmod value.
        commonxml_obj = CommonXML(scfc_file)
        bbmodObjects = commonxml_obj.get_elements(
            "//managedObject[matches(@class,'.*:BBMOD$')]")
        bbmodTexts = [commonxml_obj.get_element_attribute(bbmodObject, "distName") for bbmodObject in bbmodObjects]
        builtin_obj.log("all BBMOD texts are {}".format(bbmodTexts))
        # extract bbmod_R Id from bbmod_r texts
        bbmodIds = self._find_specific_dn_id_from_texts(list_of_text=bbmodTexts, distname="bbmod")
        return bbmodIds

    def _find_specific_dn_id_from_texts(self, list_of_text, distname):
        """
        the keyword is to find distname's id from text.
        """
        ids = []
        for text in list_of_text:
            ret = re.search(r"\/{}-(\d+)".format(distname), text, re.IGNORECASE)
            if ret:
                ids.append(ret.group(1))
        ids = list(set(ids))
        return ids

    def replace_string_in_file(self, file_path, old_value, new_value):
        content = os_obj.get_file(path=file_path)
        content = str_obj.replace_string_using_regexp(content, pattern=old_value, replace_with=new_value)
        os_obj.create_file(path=file_path, content=content)


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
        if alias == "gnb1":
            admin_log_dir = "{}/admin_logs/".format(builtin_obj.get_variable_value("${testCaseDir}"))
            # admin_log_dir = "/home/ute/csamson/TRACES"
        else:
            admin_log_dir = "{}/{}/admin_logs/".format(
                builtin_obj.get_variable_value("${testCaseDir}"), alias)
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
                if len(out.strip()) == 0 or out.count("=") == 0:
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
                builtin_obj.log("no %s in %s, will append it to the end" % (parameter, value))
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
        """get and return cplane nodes, but don't know how to get cplanes nodes at present, return all nodes instead"""
        nodes = []
        # execute aashell command: proc #0xFFFF
        out = self._execute_aashell_cmd("proc #0xFFFF")
        # select cplane nodes
        for line in out.strip().splitlines():
            if line.count("node"):
                node = line.split()[2]
                nodes.append(node)
        return nodes

    def _get_specific_node_id(self, node_type):
        output = self._execute_aashell_cmd("nodes -p")
        lines = output.splitlines()
        lines = [x for x in lines if x != '']
        # find all line indexs for --------------- node: 0x1511 ----------------
        heads_index_list = []
        head_match_string = r"-+\s+node:\s+"
        for index, line in enumerate(lines):
            ret = re.search(head_match_string, line, re.IGNORECASE)
            if ret:
                heads_index_list.append(index)
        # separate each node content
        split_paragraphs = []
        for index in reversed(heads_index_list):
            split_paragraphs.append(lines[index:])
            lines = lines[0:index]
        # find cp_ue in each paragraph
        nodes_list = []
        for paragraph in split_paragraphs:
            node_id = ""
            nodeTypeFlag = False
            for line in paragraph:
                find_node_id = re.search(r"-+\s+node: (\w+) -+", line, re.IGNORECASE)
                if find_node_id:
                    node_id = find_node_id.group(1)
                find_node_type = re.search(node_type, line, re.IGNORECASE)
                if find_node_type:
                    nodeTypeFlag = True
            if node_id == "":
                raise Exception("find node id failure on {}".format(paragraph))
            if nodeTypeFlag:
                nodes_list.append(node_id)
        return (nodes_list)

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

    def _get_l1_mode(self):
        out = self._execute_aashell_cmd("tag -a")
        builtin_obj.log("output of tag -a is {}".format(out))
        if "L1BypassMap".lower() in out.lower():
            l1_type = "L1B"
        else:
            l1_type = "FS"
        builtin_obj.log("L1_TYPE={}".format(l1_type), console=True)
        return l1_type

    def _check_resources_leakage(self, check_components):
        """
        refer to
        https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=956974306#Hanginguser/
        resourcechecksinPETtesting-Standalonescript(requirestaf.transport.sshforconnectivity)
        """
        self._setup_conn()
        # prepare log_dir
        log_dir = builtin_obj.get_variable_value("${testCaseDir}")
        if self.alias != "gnb1":
            log_dir = os.path.join(log_dir, self.alias)
            if not os.path.exists(log_dir):
                os.mkdir(log_dir)
        log_dir = os.path.join(log_dir, "check_resource_logs")
        if not os.path.exists(log_dir):
            os.mkdir(log_dir)

        # run hanging_check_4G_5G.py and copy log
        self._execute_cmd_on_pc("rm -rf hanging_resource_check_*")
        cwd = os.path.dirname(__file__)
        cmd = "python {}/../../../tools/hanging_check/hanging_check.py -p {}".format(cwd, check_components)
        output = self._execute_cmd_on_pc(cmd, timeout=60)
        if self.alias == "gnb1":
            self._execute_cmd_on_pc('mv hanging_resource_check_* {}'.format(log_dir))
        else:
            local_conn = ssh_obj.connect_to_host("127.0.0.1", "22", "ute", "ute", conn_type="SSH", timeout="10")
            ssh_obj.execute_shell_command(
                'scp ute@{}:~/hanging_resource_check_* {}'.format(self.pc, log_dir))
            ssh_obj.disconnect_from_host(local_conn)

        if 'No hanging resources' in output:
            builtin_obj.log("No hanging resources")
        elif 'There were hanging resources' in output:
            raise Exception("Resource Not Released")
        else:
            raise Exception("hanging_check.py issue, ask wang teana for help")

    def _get_eif_info_of_control_pc(self):
        self._setup_conn()
        output = self._execute_cmd_on_pc("ip addr")
        eth0_pattern = r"inet ([0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth0"
        eth3_pattern = r"inet ([0-9]*.[0-9]*.[0-9]*.[0-9]*).*?brd.*?eth3"
        result = re.search(eth0_pattern, str(output), re.I)
        if result:
            eth0_ip = result.group(1)
        else:
            eth0_ip = None
        result = re.search(eth3_pattern, str(output), re.I)
        if result:
            eth3_ip = result.group(1)
        else:
            eth3_ip = None
        builtin_obj.log("eth0 ip is :{}, eth3 ip is :{}".format(eth0_ip, eth3_ip))
        web_card = "eth0" if not eth3_ip else "eth3"
        dest_ip = eth0_ip if web_card == "eth0" else eth3_ip
        builtin_obj.log("web card is :{}, dest ip is :{}".format(web_card, dest_ip))
        return web_card, dest_ip


class operate_on_local_pc1(object):
    def __init__(self):
        alias = "gnb1"
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

    def get_crnti_in_cell_nok(self, cell_id):
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

    def get_uec_node_nok(self, lcrid):
        """
        get cell mapping and return UEC node of specified lcrid
        """
        return self.pc_operate_instant_1._get_uec_node(lcrid)

    def get_cplane_nodes(self):
        return self.pc_operate_instant_1._get_cplane_nodes()

    def get_specific_node_id(self, node_type):
        """
        the function is to get container node id on gnb internally .
        | Input Parameters  | Man. |  Description   |
        | node_type         | Yes  |  cp_ue,cp_nb,cp_sb |
        | Return  | list type | return the nodes id for specific container. for example ['0x1011','0x1012] |
        Example
        aashell command: nodes -p
        | ${cp_ue_ids}=  |  Get Specific Node Id  |  node_type=cp_ue
        """
        return self.pc_operate_instant_1._get_specific_node_id(node_type)

    def get_other_nodes(self):
        return self.pc_operate_instant_1._get_other_nodes()

    def uncompress_file(self, compressed_file, target_dir=None):
        self.pc_operate_instant_1._uncompress_file(compressed_file, target_dir)

    def get_gnb_l1_mode(self):
        return self.pc_operate_instant_1._get_l1_mode()

    def check_resources_leakage(self, check_components="cpcl cpue cprt cpnrt"):
        return self.pc_operate_instant_1._check_resources_leakage(check_components)

    def get_eif_info_of_control_pc(self):
        return self.pc_operate_instant_1._get_eif_info_of_control_pc()


class operate_on_local_pc2(object):
    def __init__(self):
        alias = "gnb2"
        self.pc_operate_instant_2 = operate_on_pc_base(alias)

    def execute_cmd_on_pc_gnb2(self, cmd, timeout="20"):
        self.pc_operate_instant_2.pc = builtin_obj.get_variable_value('${GNB2_PC_IP}')
        return self.pc_operate_instant_2._execute_cmd_on_pc(cmd, timeout)

    def execute_aashell_cmd_gnb2(self, cmd, port="15007", timeout="50"):
        self.pc_operate_instant_2.pc = builtin_obj.get_variable_value('${GNB2_PC_IP}')
        return self.pc_operate_instant_2._execute_aashell_cmd(cmd, port, timeout)

    def check_resources_leakage_gnb2(self, check_components="cpcl cpue cprt cpnrt"):
        self.pc_operate_instant_2.pc = builtin_obj.get_variable_value('${GNB2_PC_IP}')
        return self.pc_operate_instant_2._check_resources_leakage(check_components)


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

    def _setup_fct_0b(self):
        if not self._setup_fct_0b_flag:
            self._connect_to_fct_0b()
            self._setup_fct_0b_flag = True

    def _connect_to_fct_0b(self, timeout="30"):
        self.fct_0b_conn = ssh_obj.connect_to_host(
            self.bts_host, "22", "toor4nsn", "oZPS0POrRieRtu", conn_type="SSH", timeout=timeout)
        out = ssh_obj.execute_shell_command("bsh 0:1")
        if out:
            retry_times = int(timeout) / 10
            while retry_times > 0:
                time.sleep(10)
                out = ssh_obj.execute_shell_command("bsh 0:1")
                if out is False:
                    break
                else:
                    retry_times = retry_times - 1
            if retry_times == 0:
                raise Exception("ssh fct 0b connection failure after %s seconds" % timeout)

    def execute_cmd_on_gnb(self, cmd, board):
        self._setup_bts()
        board = board.lower()
        if board.startswith("fsp") and board.count(":") == 0:
            board = board + ":0"
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        if board == "master":
            cmd = cmd
        elif board == "slave":
            cmd = "bsh 0:1 {}".format(cmd)
        elif board == "auto":
            if bbu_type == "ASIK":
                cmd = "bsh 0:1 {}".format(cmd)
            else:
                cmd = cmd
        elif board.startswith("fsp"):
            cmd = "bsh {}:{} {}".format(board.split(":")[0][-1], board.split(":")[1], cmd)
        else:
            raise Exception("not support board {}".format(board))
        builtin_obj.log("Execute command on {}:{}".format(self.alias, cmd))
        out = self.fsm_obj.execute_command_on_enb(cmd, return_rc=True, alias=self.alias)
        builtin_obj.log("Get Response:{}".format(out[0]))
        return out[0].strip()

    def execute_cmd_on_fct_0b(self, cmd, timeout="20"):
        self._setup_fct_0b()
        ssh_obj.switch_host_connection(self.fct_0b_conn)
        old_timeout = ssh_obj.set_shell_timeout(timeout)
        try:
            out = ssh_obj.execute_shell_command(cmd)
        except Exception as e:
            print(e)
            # reconnect if gnb restarted
            old_timeout = ssh_obj.set_shell_timeout(timeout)
            self._connect_to_fct_0b()
            out = ssh_obj.execute_shell_command(cmd)
        finally:
            ssh_obj.set_shell_timeout(old_timeout)
        return out

    def get_gnb_sw_version(self):
        """
        Example
        | ${gnb_version}= | get_gnb_sw_version |

        """
        self._setup_bts()
        gnb_version = self.fsm_obj.get_enb_sw_version(alias=self.alias)
        # 5G21B_GNB_0000_000800_003629  ==> 5G_0.800.3629
        if gnb_version.count("GNB"):
            if gnb_version.count("0000_000800"):  # trunk
                gnb_version = "5G_%s.%s.%s" % (
                    gnb_version.split("_")[2][:-1].lstrip("0") + gnb_version.split("_")[2][-1],
                    gnb_version.split("_")[3].lstrip("0"), gnb_version.split("_")[4].lstrip("0"))
            else:  # branches
                gnb_version = "%s_%s.%s.%s" % (gnb_version.split("_")[0],
                                               gnb_version.split("_")[2][:-1].lstrip("0") + gnb_version.split("_")[2][
                                                   -1],
                                               gnb_version.split("_")[3].lstrip("0"),
                                               gnb_version.split("_")[4].lstrip("0"))
        return gnb_version


class operate_on_bts1(object):
    def __init__(self):
        alias = "gnb1"
        self.bts_base_instance_1 = operate_on_bts_base(alias)

    def execute_cmd_on_gnb(self, cmd, board="master"):
        """This keyword is to execute command in specified board of gnb and return the command output

        | Arguments | Man. | Default | Description |
        | cmd       | Yes  | yes     | command to be executed |
        | board     | No   | master  | the board where to execute command. |

        Supported board:
        master, slave, auto(if BBU has slave it will execute command in slave, otherwise execute command in master);
        fsp1(sams as fsp1:0), fsp1:1, fsp1:2;
        fsp2(same as fsp2:0), fsp2:1, fsp2:2;
        Example:
        | ${out} | execute_cmd_on_gnb | "ls -ltr" |
        | ${out} | execute_cmd_on_gnb | "ps -ef | grep cp-rt" | board=auto |
        | ${out} | execute_cmd_on_gnb | "ps -ef | grep cp_ue" | board=fsp1 |
        """
        return self.bts_base_instance_1.execute_cmd_on_gnb(cmd, board)

    def execute_cmd_on_fct_0b(self, cmd, timeout="20"):
        return self.bts_base_instance_1.execute_cmd_on_fct_0b(cmd, timeout)

    def get_gnb_sw_version(self):
        return self.bts_base_instance_1.get_gnb_sw_version()

    def generate_extra_swconfig_flag_based_on_condition(self, params, params_in_env):
        """This keyword is to add extra swconfig parameter into default swconfig configuration
        :param params: Source swconfig variable
        :param params_in_env: extra swconfig configuration
        :return: list after merging.

        Detail for argument params_in_env,
        for example 1:
        'classical:TDD:GNB_ASIB:NSA:>ap_4.0.19073:SBTS00:0x70676=3':
        if condition is satisfied , then 0x70676=3 will be added in swconfig.

        for example 2:
        'classical:FDD:GNB_ASIK:SANSA:>=gnb_SBTS00_ENB_9999_211202_000009:SBTS00:0x70677=3':
        if condition is satisfied , then 0x70677=3 will be added in swconfig.

        for example 3:
        '::::>=gnb_SBTS00_ENB_9999_211202_000009::0x70677=3'
        Only if version > SBTS00_ENB_9999_211202_000009, then 0x70677=3 will be added in swconfig.
        """
        params = self.remove_empty_from_list(params)
        params_in_env = self.remove_empty_from_list(params_in_env)
        if len(params_in_env) == 0:
            return params
        cur_product_type = builtin_obj.get_variable_value("${PRODUCT_TYPE}")
        cur_duplex = builtin_obj.get_variable_value("${DUPLEX}")
        cur_bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        cur_ap_bbu_type = builtin_obj.get_variable_value("${AP_BBU_TYPE}")
        cur_network_mode = builtin_obj.get_variable_value("${NETWORK_MODE}")
        cur_network_mode = "sansa" if cur_network_mode.upper() == "SA+NSA" else cur_network_mode
        cur_gnb_sw_version = builtin_obj.get_variable_value("${GNB_SW_VERSION}")
        cur_ap_sw_version = builtin_obj.get_variable_value("${AP_SW_VERSION}")
        cur_release = builtin_obj.get_variable_value("${RELEASE}")
        builtin_obj.log("\nCurrent Product Type is: {}".format(cur_product_type))
        builtin_obj.log("\nCurrent Duplex is: {}".format(cur_duplex))
        builtin_obj.log("\nCurrent Gnb BBU Type is: {}".format(cur_bbu_type))
        builtin_obj.log("\nCurrent Ap BBU Type is:{}".format(cur_ap_bbu_type))
        builtin_obj.log("\nCurrent Network mode is:{}".format(cur_network_mode))
        builtin_obj.log("\nCurrent Gnb SW version is:{}".format(cur_gnb_sw_version))
        builtin_obj.log("\nCurrent Ap SW version is:{}".format(cur_ap_sw_version))
        builtin_obj.log("\nCurrent Release is:{}".format(cur_release))
        new_flags = []
        for flag in params_in_env:
            builtin_obj.log("\nStart To Handle {}".format(flag))
            new_flag = self._filter_flag(flag)
            if new_flag:
                new_flags.append(new_flag)
            builtin_obj.log("Flag {} Handle Over".format(flag))
        if new_flags:
            builtin_obj.log("\nFinally: extra flag %s need to be changed." % new_flags)
        params.extend(new_flags)
        return params

    def _filter_flag(self, flag):
        cur_product_type = builtin_obj.get_variable_value("${PRODUCT_TYPE}")
        cur_duplex = builtin_obj.get_variable_value("${DUPLEX}")
        cur_bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        cur_ap_bbu_type = builtin_obj.get_variable_value("${AP_BBU_TYPE}")
        cur_network_mode = builtin_obj.get_variable_value("${NETWORK_MODE}")
        cur_network_mode = "sansa" if cur_network_mode.upper() == "SA+NSA" else cur_network_mode
        cur_gnb_sw_version = builtin_obj.get_variable_value("${GNB_SW_VERSION}")
        cur_ap_sw_version = builtin_obj.get_variable_value("${AP_SW_VERSION}")
        cur_release = builtin_obj.get_variable_value("${RELEASE}")
        if flag.count(":") != 6:
            builtin_obj.log("Flag: {} format doesn't correct ".format(flag))
            builtin_obj.log(
                "Recommended format: classical:TDD:GNB_ASIB:NSA:>SBTS00_ENB_9999_211202_000009:SBTS00:0x70676=3\n")
            return ''
        product_type, duplex, bbu_type, network_mode, sw_version, release, pure_flag = flag.split(':')
        try:
            if cur_product_type.lower().find(product_type.lower()) == -1:
                builtin_obj.log("Flag {} ,product type: {} mismatch with current env".format(flag, product_type))
                return ''
            if cur_duplex.lower().find(duplex.lower()) == -1:
                builtin_obj.log("Flag {} ,duplex: {} mismatch with current env".format(flag, duplex))
                return ''
            if 'gnb' in bbu_type.lower() and bbu_type.split('_', 1)[-1].lower() not in cur_bbu_type.lower():
                builtin_obj.log("Flag {} ,bbu_type: {} mismatch with current env".format(flag, bbu_type))
                return ''
            if 'ap_' in bbu_type.lower() and bbu_type.split('_', 1)[-1].lower() not in cur_ap_bbu_type.lower():
                builtin_obj.log("Flag {} ,bbu_type: {} mismatch with current env".format(flag, bbu_type))
                return ''
            if network_mode.lower() != cur_network_mode.lower() and network_mode.lower() != '':
                builtin_obj.log("Flag {} ,network_mode: {} mismatch with current env".format(flag, network_mode))
                return ''
            if cur_release.lower().find(release.lower()) == -1:
                builtin_obj.log("Flag {} ,release: {} mismatch with current env".format(flag, release))
                return ''
        except Exception:
            builtin_obj.log("Get Environment Conditions failure".format(flag, release))
            return ''
        if sw_version:
            tmp_ver_2 = sw_version
            ver_1_release = ''
            ver_2_release = ''
            cmp_string = ''
            if sw_version.lower().find('gnb') != -1:
                ver_type = 'gnb'
                tmp_ver_1 = cur_gnb_sw_version
                tmp_ver_2 = tmp_ver_2.lower().replace('gnb_0', '')
                tmp_ver_2 = tmp_ver_2.lower().replace('gnb_', '')
            elif sw_version.lower().find('ap') != -1:
                ver_type = 'ap'
                tmp_ver_1 = cur_ap_sw_version
                tmp_ver_2 = tmp_ver_2.lower().replace('ap_0', '')
                tmp_ver_2 = tmp_ver_2.lower().replace('ap_', '')
            ret = re.search("([<>=!]+)(.*)", tmp_ver_2)
            if ret:
                cmp_str = ret.group(1)
                tmp_ver_2 = tmp_ver_2.split(cmp_str)[-1]
                cmp_str = "==" if cmp_str == '=' else cmp_str
            elif ver_type == 'gnb':
                builtin_obj.log("Flag {} ,gnb_sw_version: {} doesn't compare string <>=!".format(flag, sw_version))
                return ''
            elif ver_type == 'ap':
                builtin_obj.log("Flag {} ,ap_sw_version: {} doesn't compare string <>=!".format(flag, sw_version))
                return ''
            ver_1_release = self._get_ver_release(ver_num=tmp_ver_1, ver_type=ver_type)
            ver_2_release = self._get_ver_release(ver_num=tmp_ver_2, ver_type=ver_type)
            if ver_1_release != ver_2_release or ver_1_release == 'unknow' or ver_2_release == 'unknow':
                builtin_obj.log(
                    "Flag {} ,gnb_sw_version: {} doesn't match with current version".format(flag, sw_version))
                return ''
            if self._version_compare(tmp_ver_1, tmp_ver_2, cmp_str, ver_1_release, ver_type=ver_type) is not True:
                builtin_obj.log("Flag {} doesn't add in swconfig due to condition not satified".format(flag))
                return ''
        builtin_obj.log("Flag {} Check Pass, will be added.".format(flag))
        return pure_flag

    def _version_compare(self, ver_num_1, ver_num_2, cmp_str='>', ver_release='trunk', ver_type='gnb'):
        """compare version
        SBTS22R1_ENB_0000_000954_000000 >|>=|<=|==|!= SBTS22R1_ENB_0000_000897_000000 return true or false
        SBTS00_ENB_9999_211124_000013 >|>=|<=|==|!= SBTS00_ENB_9999_211124_000013 return true or false
        4.0.18994 >|>=|<=|==|!= 4.0.18993 return true or false
        """
        ver_num_1 = ver_num_1.lower()
        ver_num_2 = ver_num_2.lower()
        ver_match_num_1 = ''
        ver_match_num_2 = ''
        try:
            if ver_type == 'gnb' and ver_release == 'trunk':
                ver_match_num_1 = "{}{}".format(ver_num_1.split('_')[-2], ver_num_1.split('_')[-1])
                ver_match_num_2 = "{}{}".format(ver_num_2.split('_')[-2], ver_num_2.split('_')[-1])
                result = eval(ver_match_num_1 + cmp_str + ver_match_num_2)
                return result
            if ver_type == 'gnb' and ver_release == 'branch':
                if ver_num_1.split("_")[0] == ver_num_2.split("_")[0]:
                    ver_match_num_1 = "{}{}".format(ver_num_1.split('_')[-2], ver_num_1.split('_')[-1])
                    ver_match_num_2 = "{}{}".format(ver_num_2.split('_')[-2], ver_num_2.split('_')[-1])
                    ver_match_num_1 = ver_match_num_1.lstrip("0")
                    ver_match_num_2 = ver_match_num_2.lstrip("0")
                    result = eval(ver_match_num_1 + cmp_str + ver_match_num_2)
                    return result
                else:
                    builtin_obj.log("{} {} can't compare under difference branch".format(ver_num_1, ver_num_2))
                    return False
            if ver_type == 'ap' and ver_release == 'trunk':
                ver_match_num_1 = ver_num_1.replace(".", '')
                ver_match_num_2 = ver_num_2.replace(".", '')
                result = eval(ver_match_num_1 + cmp_str + ver_match_num_2)
                return result
            builtin_obj.log(
                "version compare failure, ver_num_1: {} , ver_num_2: {}, cmp_str: {}, ver_release: {}, "
                "ver_type: {}".format(ver_num_1, ver_num_2, cmp_str, ver_release, ver_type))
            return False
        except Exception:
            detail = traceback.format_exc()
            traceback.print_exc()
            return False

    def _get_ver_release(self, ver_num, ver_type):
        """input version number and version type,
        for example SBTS22R1_ENB_0000_000954_000000, gnb  return branch
        for example SBTS00_ENB_9999_211206_000008, gnb  return trunk
        for example 4.0.18987, ap  return trunk
        if version number can't be identified , return unknow
        """
        ver_num = ver_num.lower()
        gnb_trunk_pattern = r"sbts[A-Za-z0-9]{2,5}_[A-Za-z]{3}_9999_\S+"
        gnb_branch_pattern = r"sbts[A-Za-z0-9]{2,5}_[A-Za-z]{3}_0000_\S+"
        ap_trunk_pattern = r"\d+[.]{1,}\d+[.]{1,}\d+"
        if ver_type == 'gnb':
            ret = re.search(gnb_trunk_pattern, ver_num)
            if ret:
                return "trunk"
            ret = re.search(gnb_branch_pattern, ver_num)
            if ret:
                return "branch"
            else:
                return "unknow"
        if ver_type == 'ap':
            ret = re.search(ap_trunk_pattern, ver_num)
            if ret:
                return "trunk"
            else:
                return "unknow"
        return "unknow"


class operate_on_bts2(object):
    def __init__(self):
        alias = "gnb2"
        self.bts_base_instance_2 = operate_on_bts_base(alias)

    def _setup_bts2(self):
        self.bts_base_instance_2.bts_host = builtin_obj.get_variable_value('${GNB2_IP}')  # NG IP
        self.bts_base_instance_2.remote_host = builtin_obj.get_variable_value('${GNB2_PC_IP}')

    def execute_cmd_on_fct_0b_gnb2(self, cmd, timeout="20"):
        self._setup_bts2()
        return self.bts_base_instance_2.execute_cmd_on_fct_0b(cmd, timeout)

    def execute_cmd_on_gnb2(self, cmd, board="master"):
        """This keyword is to execute command in specified board of gnb2 and return the command output

        | Arguments | Man. | Default | Description |
        | cmd       | Yes  | yes     | command to be executed |
        | board     | No   | master  | the board where to execute command. |

        Supported board:
        master, slave, auto(if BBU has slave it will execute command in slave, otherwise execute command in master),
        fsp1, fsp2, fsp3.

        Example:
        | ${out} | execute_cmd_on_gnb2 | "ls -ltr" |
        | ${out} | execute_cmd_on_gnb2 | "ps -ef | grep cp-rt" | board=auto |
        | ${out} | execute_cmd_on_gnb2 | "ps -ef | grep cp_ue" | board=fsp1 |
        """
        self._setup_bts2()
        return self.bts_base_instance_2.execute_cmd_on_gnb(cmd, board)


class operate_on_wts(object):
    def __init__(self):
        self.wts_alias = "wts"
        self._setup_wts_flag = False
        self.common_obj = common()
        self.pc_obj = operate_on_local_pc1()
        self.get_meas_id_fun_supported_keys = ["ue_id", "carrierfreq", "event_type",
                                               "carrierfreq_rat", "measho_type", "threshold",
                                               "timetotrigger", "timeout"
                                               ]
        self.ue_info = {}

    def _setup_wts(self):
        if not self._setup_wts_flag:
            self.iphy_obj = ute_wtssim()
            self.iphy_obj.setup_egate(egate_port='9880')
            # self.iphy_obj.setup_egate(egate_port='33333')
            self._setup_wts_flag = True
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
        if command.count("ue_pdu_session_setup"):
            options_d = self._convert_to_dict(command)
            ue_info[options_d["ue"]] = options_d
            match = re.search(r"UE IP address:(\d+\.\d+\.\d+\.\d+)", out, re.I)
            if match is not None:
                ue_info[options_d["ue"]]["ip"] = match.group(1)
            save_log_dir = builtin_obj.get_variable_value("${testCaseDir}")
            self.pc_obj.execute_cmd_on_pc('''echo ue_info="%s" >> %s/ue_info.py''' % (ue_info, save_log_dir))
        time.sleep(float(sleep_time))
        if out.count("\x1b[K") > 0:
            out = str_obj.remove_string(out, "\x1b[K")
        return out

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
        save_log_directory = builtin_obj.get_variable_value("${testCaseDir}")
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

    def ue_register(self, ue_id=1, gnb_id=1, cell_id=1, pdu_id=1, gw_id=1):
        """
        Example:
        | Ue Register | ue_id=1 | gnb_id=1 | cell_id=1 | pdu_id=1 | gw_id=1 |
        # common register Ue with "pdu_session"|
        """
        try:
            self.execute_egate_command("ue_change_location id=%s enb=%s cell=%s" %
                                       (ue_id, gnb_id, cell_id), timeout=3)
        except Exception as e:
            builtin_obj.log("def ue_register: ue_change_location ERR: %s." %
                            str(e).splitlines()[0], level="WARN")
        try:
            self.execute_egate_command("ue_register id=%s" %
                                       ue_id, pass_regexp='UE now in NG RM Registered', timeout=3)
        except Exception as e:
            builtin_obj.log("def ue_register: ue_register ERR: %s." %
                            str(e).splitlines()[0], level="WARN")
        try:
            self.execute_egate_command("ue_pdu_session_setup ue=%s pdu=%s gw=%s" %
                                       (ue_id, pdu_id, gw_id), pass_regexp='QoS Routing Table', timeout=3)
        except Exception as e:
            builtin_obj.log("def ue_register: ue_pdu_session_setup ERR: %s." %
                            str(e).splitlines()[0], level="WARN")

    def ue_handover(self, ue_id=1, carrierfreq="518910", event_type="A1", phycell_id="12345"):
        """
        Example:
        | Ue Handover | ue_id=1 | carrierfreq="518910" | event_type="A1" | phycell_id="12345" |
        # common Ue Handover |
        """
        meas_id = self.get_nr_meas_id_for_specific_type_and_frequency(ue_id, carrierfreq, event_type)
        try:
            self.execute_egate_command("ue_measurement_send_nr id=%s meas_id=%s event=%s srsrp_nr=11 srsrq_nr=11 "
                                       "phycell_id=%s nrsrp_nr=30 nrsrq_nr=30" %
                                       (ue_id, meas_id, event_type, phycell_id),
                                       pass_regexp='Sending SgNB Change Confirm', timeout=5)
        except Exception as e:
            builtin_obj.log("def ue_handover: ERR: %s." % str(e).splitlines()[0], level="WARN")

    def traffic_data_stop(self, ue_id):
        """
        # == == == == == == == == == == == == == == == == == == == ==
        # Parameter   Simulated  External  Total
        # ----------------------------------------
        # Configured  60         0         60
        # Active       0         0          0
        # Idle         0         0          0
        # == == == == == == == == == == == == == == == == == == == ==
        Example: Traffic Data Stop  ue_id=all
                 Traffic Data Stop  ue_id=1
                 Traffic Data Stop  ue_id=1-10
        """
        sa_ue_num, nsa_ue_num, other_ues = "", "", ""
        if ue_id == "all":
            sa_ue_num, inactive_sa_ue_num, nsa_ue_num, other_ues = self.get_all_ues()
        else:
            sa_ue_num = ue_id

        # traffic_data_stop SA and NSA UEs
        if sa_ue_num != "":
            try:
                self.execute_egate_command("trf_data_stop ue=%s" % sa_ue_num, timeout=3)
            except Exception as e:
                builtin_obj.log("def traffic_data_stop:trf_data_stop SA UE ERR: %s." %
                                str(e).splitlines()[0], level="WARN")
        if nsa_ue_num != "":
            try:
                self.execute_egate_command("trf_data_stop ue=%s" % nsa_ue_num, timeout=3)
            except Exception as e:
                builtin_obj.log("def traffic_data_stop:trf_data_stop NSA UE ERR: %s." %
                                str(e).splitlines()[0], level="WARN")

    def ue_pdu_session_release(self, ue_id):
        """
        Example:
        | Ue Pdu Session Release | ue_id=all |
        | Ue Pdu Session Release | ue_id=1 |
        | Ue Pdu Session Release | ue_id=1-10 |
        """
        sa_ue_num, nsa_ue_num, other_ues = "", "", ""
        if ue_id == "all":
            sa_ue_num, inactive_sa_ue_num, nsa_ue_num, other_ues = self.get_all_ues()
        else:
            sa_ue_num = ue_id

        # ue_pdu_session_release SA and NSA UEs
        if sa_ue_num != "":
            try:
                self.execute_egate_command("ue_pdu_session_release ue=%s pdu=1" % sa_ue_num, timeout=3)
            except Exception as e:
                builtin_obj.log("def ue_pdu_session_release:ue_pdu_session_release SA UE ERR: %s." %
                                str(e).splitlines()[0], level="WARN")
        if nsa_ue_num != "":
            builtin_obj.log("def ue_pdu_session_release:ue_pdu_session_release NSA UE [%s] not need release" %
                            nsa_ue_num, level="INFO")
            # try:
            #     self.execute_egate_command("ue_pdu_session_release ue=%s pdu=1" % nsa_ue_num, timeout=3)
            # except Exception as e:
            #     builtin_obj.log("def ue_pdu_session_release:ue_pdu_session_release NSA UE ERR: %s." %
            #                     str(e).splitlines()[0], level="WARN")

    def get_all_ues(self):
        """
        # [1/2] get UE number from cfg
        time.sleep(1)
        ue_number_in_wts = builtin_obj.get_variable_value("${MAX_UE_NUMBER_IN_WTS}", "500")
        builtin_obj.log("def ap_release_all_ues(1):ue_number_in_wts=[%s]" % ue_number_in_wts, level="INFO")

        # [2/2] get UE number from "egate" use cmd "ue_disp"
        # == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        # --------------------------------------------------------------------------------------------------------
        # UE Id  Type  State  IP addresses  NAT IP addresses  Location  MME  UEC  Group-ID  Group-name
        # ----------------------------------------------------------------------------------------------
        # 1      INT   ACTIVE <inactive>    <inactive>        2.1       1    1    -         -             # NSA UE
        # 2      INT   UE_INACTIVE  <inactive>    <inactive>  2.1       1    1    -         -             # NSA UE
        # 31     INT   ACTIVE  4.7.254.208* (PDN1)  72.22.0.2 (PDN1)   1.1       1    1    -         -    # SA UE
        # == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == == ==
        """
        ue_disp = ""
        total_sleep_time = 1
        # [1]. wait all UE change to "ACTIVE"
        while total_sleep_time <= 10:
            time.sleep(1)
            if (ue_disp == "") or ("ACTIVATING" in ue_disp) or ("addresses" not in ue_disp):
                self.execute_egate_command("set_log flush")
                ue_disp = self.execute_egate_command("ue_disp", pass_regexp='EGATE>')
                if "ACTIVATING" in ue_disp:
                    if total_sleep_time < 10:
                        builtin_obj.log("get_all_ues: some UEs was 'ACTIVATING'."
                                        "wait %s second to [ue_disp]" % total_sleep_time, level="INFO")
                    else:
                        builtin_obj.log("get_all_ues:some UEs was 'ACTIVATING'."
                                        "wait %s second to [ue_disp]" % total_sleep_time, level="WARN")
                total_sleep_time = total_sleep_time + 1
            else:
                break

        # [2]. get all active/idle/inactive UEs
        active_sa_ue_num = inactive_sa_ue_num = idle_sa_ue_num = nsa_ue_num = other_ues = ""
        check_ue_state = ["ACTIVE", "IDLE", "UE_INACTIVE"]
        if any(name in ue_disp for name in check_ue_state):  # if find "ACTIVE" or "IDLE" in ue_disp
            # split every lines
            # builtin_obj.log("def ap_release_all_ues(1.2):ue_disp=%s." % ue_disp, level="INFO")
            for line in ue_disp.splitlines():
                if line.strip() == "":  # if was blank line
                    continue
                if ("Configured UEs" in line) or ("======" in line) or ("addresses" in line) \
                        or ("-----" in line) or ("EGATE" in line):
                    continue
                if ("inactive" not in line) and ("PDN" not in line):
                    continue

                # get UE data form return of cmd "ue_disp"
                # builtin_obj.log("def get_all_ues:line=%s." % line, level="INFO")
                ue_id, ue_state = line.split()[0], line.split()[2]
                # sa_ue_num=[K2,[K3,[K4
                if "[K" in ue_id:
                    ue_id = ue_id.replace("[K", "")

                if line.split()[4] == "(PDN1)":
                    ue_ip_addresses = line.split()[3] + " " + line.split()[4]
                else:
                    ue_ip_addresses = line.split()[3]
                # builtin_obj.log("def ap_release_all_ues(3.4):ue_id=%d,ue_state=%s,ue_ip_addresses=%s."
                #                 % (ue_id, ue_state, ue_ip_addresses), level="INFO")

                # [3.1] get all ACTIV SA UEs
                if ue_state == "ACTIVE" and ue_ip_addresses == "<inactive>":
                    if active_sa_ue_num == "":
                        active_sa_ue_num = ue_id
                    else:
                        active_sa_ue_num = active_sa_ue_num + "," + ue_id
                # [3.2] get all INACTIV SA UEs
                if ue_state == "UE_INACTIVE" and ue_ip_addresses == "<inactive>":
                    if inactive_sa_ue_num == "":
                        inactive_sa_ue_num = ue_id
                    else:
                        inactive_sa_ue_num = inactive_sa_ue_num + "," + ue_id
                # [3.3] get all IDLE SA UEs
                elif ue_state == "IDLE" and ue_ip_addresses == "<inactive>":
                    if idle_sa_ue_num == "":
                        idle_sa_ue_num = ue_id
                    else:
                        idle_sa_ue_num = idle_sa_ue_num + "," + ue_id
                # [3.4] get all NSA UEs
                elif ue_state in check_ue_state and "(PDN1)" in ue_ip_addresses:
                    if nsa_ue_num == "":
                        nsa_ue_num = ue_id
                    else:
                        nsa_ue_num = nsa_ue_num + "," + ue_id
                # [3.5] get other UEs
                else:
                    other_ues = other_ues + "," + ue_id
                    # builtin_obj.log("def ap_release_all_ues(3.3):find no SA or NSA UEs. "
                    #                 "ue_id=%d,ue_state=%s,ue_ip_addresses=%s."
                    #                 % (ue_id, ue_state, ue_ip_addresses), level="INFO")
        builtin_obj.log("get_all_ues(3.4):"
                        "active_sa_ue_num=%s,inactive_sa_ue_num=%s,idle_sa_ue_num=%s,nsa_ue_num=%s."
                        % (active_sa_ue_num, inactive_sa_ue_num, idle_sa_ue_num, nsa_ue_num), level="INFO")
        return active_sa_ue_num, inactive_sa_ue_num, idle_sa_ue_num, nsa_ue_num, other_ues

    def _ue_deregister(self, sa_ue_num=""):
        # deregister SA UEs for two times if fail
        release_sa_ue_times = 1
        while release_sa_ue_times <= 2:
            builtin_obj.log("Step1: Begin ue_deregister, sa_ue_num=%s." % sa_ue_num, level="INFO")
            if "," in sa_ue_num:
                last_sa_ue_num = sa_ue_num.rsplit(",")[1]
            elif "-" in sa_ue_num:
                last_sa_ue_num = sa_ue_num.rsplit("-")[1]
            else:
                last_sa_ue_num = sa_ue_num
            try:
                release_sa_ue_times = release_sa_ue_times + 1
                self.execute_egate_command("ue_deregister id=%s  ue_deregister_type=switch_off" % sa_ue_num,
                                           pass_regexp="UE%s: detached" % last_sa_ue_num, timeout=60)
                builtin_obj.log("Step2: Execute ue_deregister successful, sa_ue_num=%s." %
                                sa_ue_num, level="INFO")
                return
            except Exception as e:
                builtin_obj.log("Step2: Execute ue_deregister fail, Exception ERR=%s." %
                                str(e).splitlines()[0], level="WARN")
        # decide whether SA Ues was deregister successful
        if release_sa_ue_times == 2:
            self._judge_ue_release_resut(sa_ue_num)

    def _ue_detach(self, nsa_ue_num=""):
        # detach NSA UEs for two times if fail
        release_nsa_ue_times = 1
        while release_nsa_ue_times <= 2:
            builtin_obj.log("Step1: Begin ue_detach, nsa_ue_num=%s." % nsa_ue_num, level="INFO")
            if "," in nsa_ue_num:
                last_nsa_ue_num = nsa_ue_num.rsplit(",")[1]
            elif "-" in nsa_ue_num:
                last_nsa_ue_num = nsa_ue_num.rsplit("-")[1]
            else:
                last_nsa_ue_num = nsa_ue_num
            try:
                release_nsa_ue_times = release_nsa_ue_times + 1
                self.execute_egate_command("ue_detach id=%s" % nsa_ue_num,
                                           pass_regexp="UE%s: detached" % last_nsa_ue_num, timeout=60)
                builtin_obj.log("Step2: Execute ue_detach successful, sa_ue_num=%s." %
                                nsa_ue_num, level="INFO")
                return
            except Exception as e:
                builtin_obj.log("Step2: Execute ue_detach fail, Exception ERR=%s." %
                                str(e).splitlines()[0], level="WARN")
        # decide whether NSA Ues was detach successful
        if release_nsa_ue_times == 2:
            self._judge_ue_release_resut(nsa_ue_num)

    def _judge_ue_release_resut(self, ue_id=""):
        active_sa_ue_num, inactive_sa_ue_num, idle_sa_ue_num, nsa_ue_num, other_ues = self.get_all_ues()
        active_sa_ue_num_list = active_sa_ue_num.split(",")
        inactive_sa_ue_num_list = inactive_sa_ue_num.split(",")
        idle_sa_ue_num_list = idle_sa_ue_num.split(",")
        nsa_ue_num_list = nsa_ue_num.split(",")

        release_result = ''
        if "," in ue_id:
            for ue_id_tmp in ue_id.split(","):
                if ue_id_tmp in active_sa_ue_num_list:
                    release_result = "Fail"
                if ue_id_tmp in inactive_sa_ue_num_list:
                    release_result = "Fail"
                if ue_id_tmp in idle_sa_ue_num_list:
                    release_result = "Fail"
                if ue_id_tmp in nsa_ue_num_list:
                    release_result = "Fail"
        elif "-" in ue_id:
            release_result = "Fail"
        else:
            if ue_id in active_sa_ue_num_list:
                release_result = "Fail"
            if ue_id in inactive_sa_ue_num_list:
                release_result = "Fail"
            if ue_id in idle_sa_ue_num_list:
                release_result = "Fail"
            if ue_id in nsa_ue_num_list:
                release_result = "Fail"

        if release_result == "Fail":
            raise Exception(
                "Step3: ue release fail, "
                "active_sa_ue_num=[%s], inactive_sa_ue_num=[%s], idle_sa_ue_num=[%s], nsa_ue_num=[%s]" %
                (active_sa_ue_num, inactive_sa_ue_num, idle_sa_ue_num, nsa_ue_num))

    def release_ues(self, ue_type="sa", ue_id=""):
        """
        Arguments: Owner:TA Group
        | ue_type | : | "sa" | "nsa" | "all" |
        | ue_id | : | 1 | 1-10 | 1,3,5 |
        Documentation:
        Example:
        | Release Ues | ue_type=all |           | # release all SA and NSA UEs, used in teardown |
        | Release Ues | ue_type=sa  | ue_id=1-2 | # release all SA UEs, used in case |
        | Release Ues | ue_type=nsa | ue_id=1-2 | # release all NSA UEs, used in case |
        """
        builtin_obj.log("Begin release_ues().", level="INFO")
        # 1.check ue_type
        if ue_type == "all":
            active_sa_ue_num, inactive_sa_ue_num, idle_sa_ue_num, nsa_ue_num, other_ues = self.get_all_ues()
            if active_sa_ue_num == "" and inactive_sa_ue_num == "" and idle_sa_ue_num == "" and nsa_ue_num == "":
                return "pass"
            else:
                # 1. release active SA ues
                if active_sa_ue_num != "":
                    self._ue_deregister(active_sa_ue_num)
                # 2. release inactive SA ues
                if inactive_sa_ue_num != "":
                    self.execute_egate_command("ue_nr_rrc_resume_request_param id=%s cause=mo_Signalling"
                                               % inactive_sa_ue_num, timeout=60)
                    self._ue_deregister(inactive_sa_ue_num)
                # 3. release idle SA ues
                if idle_sa_ue_num != "":
                    if "," in idle_sa_ue_num:
                        for idle_sa_ue in idle_sa_ue_num.split(","):
                            self._ue_deregister(idle_sa_ue)
                    else:
                        self._ue_deregister(idle_sa_ue_num)
                # 4. release NSA ues
                if nsa_ue_num != "":
                    self._ue_detach(nsa_ue_num)
        elif ue_type == "sa":
            if ue_id != "":
                self._ue_deregister(ue_id)
            else:
                builtin_obj.log("Release SA Ue fail, have wrong ue id [%s]." % ue_id, level="ERROR")
        elif ue_type == "nsa":
            if ue_id != "":
                self._ue_detach(ue_id)
            else:
                builtin_obj.log("Release NSA Ue fail, have wrong ue id [%s]." % ue_id, level="ERROR")

        builtin_obj.log("End release_ues()", level="INFO")
        self.execute_egate_command("set_log flush")
        self.execute_egate_command("ue_disp", pass_regexp='EGATE>')

    def wait_ues_attach_finish(self, ue_id_start, ue_id_stop):
        retry_times = 6
        while retry_times > 0:
            time.sleep(10)
            not_finish = []
            ue_disp = self.execute_egate_command("ue_disp id=%s-%s" % (ue_id_start, ue_id_stop), "={70,}.*={70,}",
                                                 padding_buffer='80000')
            for line in ue_disp.strip().splitlines():
                match = re.search(r"^\d+\s+.*", line, re.I)
                if match is not None:
                    ue, type, state = line.split()[0:3]
                    print("ue=%s, state=%s" % (ue, state))
                    if state != "ACTIVE":
                        not_finish.append(ue)
            if len(not_finish):
                retry_times = retry_times - 1
            else:
                break
        return not_finish

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

    def rrc_should_contain(self, *expected_strings):
        check_strs = [str for str in expected_strings]
        all_rrc = self.pc_obj.execute_cmd_on_pc("ls -ltr /opt/iphy/latest/rrc*.log | awk '{print $9}'")
        latest_rrc = all_rrc.splitlines()[-1]
        try:
            self.egate_console_log_should_contain(latest_rrc, check_strs, timeout=60, interval=2)
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)
        finally:
            self.get_rrc_log()

    def rrc_should_not_contain(self, *expected_strings):
        check_strs = [str for str in expected_strings]
        all_rrc = self.pc_obj.execute_cmd_on_pc("ls -ltr /opt/iphy/latest/rrc*.log | awk '{print $9}'")
        latest_rrc = all_rrc.splitlines()[-1]
        try:
            self.get_rrc_log()
            self.pc_obj.file_should_not_contain_strings(latest_rrc, *expected_strings)
        except Exception:
            detail = traceback.format_exc()
            raise Exception(detail)

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

    def get_rrc_log(self):
        """
        to get complete rrc log, it is tailed from egate_console.log.
        precondition: start_rrc_log is executed before
        """
        wts_exe_dir = "/opt/iphy/latest"
        out = self.pc_obj.execute_cmd_on_pc("ps -ef | grep tail | grep egate_console.log | grep -v grep ")
        if len(out) != 0:
            all_rrc = self.pc_obj.execute_cmd_on_pc("ls -ltr %s/rrc*.log | awk '{print $9}'" % wts_exe_dir)
            latest_rrc = all_rrc.splitlines()[-1]
            date = self.common_obj.get_timestamp()
            self.execute_egate_command(date, "is unknown")
            self.egate_console_log_should_contain(latest_rrc, "Command %s is unknown" % date,
                                                  timeout=60, interval=2)
            save_log_directory = builtin_obj.get_variable_value('${testCaseDir}')
            os_obj.copy_file(latest_rrc, save_log_directory)
            self._split_iphy_log_by_ueid(os.path.join(save_log_directory, latest_rrc.split("/")[-1]))

    def _disp_ue(self, ueid):
        ue_disp = self.execute_egate_command("ue_disp id=%s;help ue_disp" % ueid, "ue_disp")
        return ue_disp

    def get_active_ue(self, env_type="NSA"):
        active_ue = []
        start_search = False
        ue_disp_mode = ""

        output = self.execute_egate_command(
            'ue_disp', pass_regexp='EGATE>')
        lines = output.splitlines()

        for line in lines:
            line = line.strip('\n')
            if re.match(r'^Parameter\s+Value.*', line) is not None:
                ue_disp_mode = "seperated"
            elif re.match(r'^UE Id\s+Type\s+State.*', line) is not None:
                ue_disp_mode = "summary"
            else:
                continue

        print("------ue_disp mode-------")
        print(ue_disp_mode)
        print("-------------------------")
        if ue_disp_mode == "seperated":
            for num, line in enumerate(lines):
                matched_ue = re.findall(r'UE-\d+', line)
                if matched_ue:
                    start_search = True
                    matched_ue = re.findall(r'UE-(\d+)', line)
                    print(line)
                    ue_id = matched_ue[0]
                    print("--------")
                    print(ue_id)
                    continue
                if start_search and 'state' in line:
                    start_search = False
                    if env_type == "NSA":
                        if 'ACTIVE' in line:
                            active_ue.append(ue_id)
                    elif env_type == "SA":
                        if 'ACTIVE' in line or 'IDLE' in line:
                            active_ue.append(ue_id)
                    else:
                        raise Exception("Input Wrong env_type.")
        elif ue_disp_mode == "summary":
            for num, line in enumerate(lines):
                if "Configured UEs" in line:
                    start_search = True
                if start_search:
                    if 'ACTIVE' in line or 'IDLE' in line:
                        ue_id = line.split(' ')[0]
                        active_ue.append(ue_id)
        else:
            raise Exception("Cannot match a ue_disp mode.")

        print(active_ue)
        return active_ue

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

    def get_ue_ip(self, ue_id):
        save_log_dir = builtin_obj.get_variable_value("${testCaseDir}")
        sys.path.insert(0, save_log_dir)
        import ue_info
        reload(ue_info)
        builtin_obj.log("ue_info is %s" % ue_info.ue_info)
        return ue_info.ue_info["%s" % ue_id]["ip"]

    def get_ue_gw_ip(self, ue_id):
        save_log_dir = builtin_obj.get_variable_value("${testCaseDir}")
        sys.path.insert(0, save_log_dir)
        import ue_info
        reload(ue_info)
        gw_id = ue_info.ue_info["%s" % ue_id]["gw"]
        gw_set_in_cfg = self.pc_obj.execute_cmd_on_pc(
            "grep set_pdu_gateway /opt/iphy/latest/wts.cfg | grep id=%s" % gw_id)
        pdu_gw_ip = gw_set_in_cfg.partition("ue_nat_ip=")[-1].split()[0]
        return pdu_gw_ip

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

    def configure_to_improve_wts_performance(self, suite_source="", keyword_modify_lua="Modify Lua"):
        print("suite_source='%s' ; keyword_modify_lua='%s' " % (suite_source, keyword_modify_lua))
        f = open(suite_source, "r")
        robot_content = f.read()
        f.close()
        # ret = re.search("%s\n(.+\n)+\n+"%keyword_modify_lua,robot_content,re.I|re.M)    # windows
        ret = re.search("%s\r\n(.+\r\n)+\r\n*" % keyword_modify_lua, robot_content, re.I | re.M)  # linux
        if ret is None:
            print("RE may error,didn't found '%s' code block" % keyword_modify_lua)
        else:
            ml = ret.group()
            print("'%s' code block is :\n%s" % (keyword_modify_lua, ml))
            modify_lua_enb = []
            modify_lua_gnb = []
            modify_lua_pgw = []
            modify_lua_sgw = []
            # "set_enb_in_lua,set_cell_in_lua"
            [modify_lua_enb.append(int(tuple[-1])) for tuple in re.findall(
                r"Set(_|\s{1})\S+(_|\s{1})In(_|\s{1})Lua(.+)enb_id=(\d+)", ml, re.I)]
            # "set_gnb_in_lua,set_cell_in_lua"
            [modify_lua_gnb.append(int(tuple[-1])) for tuple in re.findall(
                r"Set(_|\s{1})\S+(_|\s{1})In(_|\s{1})Lua(.+)gnb_id=(\d+)", ml, re.I)]
            [modify_lua_pgw.append(int(tuple[-1])) for tuple in re.findall(
                r"Set(_|\s{1})Pgw(_|\s{1})In(_|\s{1})Lua(.+)pgw_id=(\d+)", ml, re.I)]
            [modify_lua_sgw.append(int(tuple[-1])) for tuple in re.findall(
                r"Set(_|\s{1})Sgw(_|\s{1})In(_|\s{1})Lua(.+)sgw_id=(\d+)", ml, re.I)]
            add_cmds = []
            # [add_cmds.append("enb_param id=%d auto_send_end_markers=on"%enb) for enb in list(set(modify_lua_enb)) \
            # if modify_lua_enb != []]
            [add_cmds.append(
                "gnb_param id=%d end_markers=5 s1u_rcv_buff_size=50000000 x2u_snd_buff_size=50000000" % gnb)
                for gnb in list(set(modify_lua_gnb)) if modify_lua_gnb != []]
            [add_cmds.append("pgw_param id=%d sgi_rcv_buff_size=50000000 sgi_snd_buff_size=50000000 \
            s5u_rcv_buff_size=50000000 s5u_snd_buff_size=50000000 sgi_read_packet_threshold=0 mtu=2000" % pgw)
             for pgw in list(set(modify_lua_pgw)) if modify_lua_pgw != []]
            [add_cmds.append("sgw_param id=%d s1u_rcv_buff_size=50000000 s1u_snd_buff_size=50000000 \
            s5u_rcv_buff_size=50000000 s5u_snd_buff_size=50000000" % sgw) for sgw in list(set(modify_lua_sgw))
             if modify_lua_sgw != []]
            [self.execute_egate_command(command=cmd) for cmd in add_cmds]
            print("So add below configurations to lua:")
            for i in add_cmds:
                print(i)

    def ap_get_nsa_throughput(self, ue_id, bearer_id, direction, rate_type='ave', **kwargs):
        """
        execute bearer_stats ue=<ue_id> id=<bearer_id> dir=<direction> and return throuput.\n
        :param string  ue_id: ue id. Mandatory
        :param string  bearer_id: nsa bearer id. Mandatory
        :param string  direction: dl or ul. Mandatory
        :param string  rate_type: ave, max or min. get the throughput for Average data rate,
         Maximum data rate or Minimum data rate.optional
        :param dict    kwargs: other parameters for bearer_stats command ,fox example :dc_cell_group=scg  scell=1

        :return: according to rate_type, get throughput value, unit is kbps
        :rtype: string
        Example:
        | ${dl_throuput} | Ap Get Nsa Throughput | ue_id=1 | bearer_id=1 | direction=dl | rate_type=max|
        | Should Be True | ${dl_throughput}/1000 < 5|
        """
        s_extra_parameters = ""
        if kwargs:
            s_extra_parameters = self._convert_kwargs_to_para_str(kwargs)
        cmd = "bearer_stats ue=%s id=%s dir=%s %s" % (ue_id, bearer_id, direction, s_extra_parameters)
        builtin_obj.log("egate cmd=%s" % cmd)
        stats_info = self.execute_egate_command(cmd, pass_regexp="Average packet interval")
        builtin_obj.log(stats_info)
        tput = self._convert_bps_to_kbps(self._analyse_traffic_result(stats_info, rate_type))
        self.execute_egate_command("set_log flush")
        return tput

    def ap_get_sa_throughput(self, ue_id, pdu, qfi, direction, rate_type='ave', **kwargs):
        """
        execute bearer_stats ue=<ue_id> pdu=<pdu> qfi=<qfi> dir=<direction> and return throuput.\n
        :param string  ue_id: ue id. Mandatory
        :param string  pdu: sa ue pdu. Mandatory
        :param string  qfi: qfi. Mandatory
        :param string  dir: dir. Mandatory
        :param string  rate_type: ave, max or min. get the throughput for Average data rate,
         Maximum data rate or Minimum data rate.optional
        :param dict    kwargs: other parameters for bearer_stats command ,fox example :dc_cell_group=scg  scell=1

        :return: according to rate_type, get throughput value, unit is kbps
        :rtype: string
        Example:
        | ${dl_throuput} | Ap Get Sa Throughput | ue_id=1 | pdu=1 | qfi=1 | dir=dl | rate_type=max |
        | Should Be True | ${dl_throughput}/1000 < 5|
        """
        s_extra_parameters = ""
        if kwargs:
            s_extra_parameters = self._convert_kwargs_to_para_str(kwargs)
        cmd = "bearer_stats ue=%s pdu=%s qfi=%s dir=%s %s" % (ue_id, pdu, qfi, direction, s_extra_parameters)
        builtin_obj.log("egate cmd=%s" % cmd)
        stats_info = self.execute_egate_command(cmd, pass_regexp="Average packet interval")
        builtin_obj.log(stats_info)
        tput = self._convert_bps_to_kbps(self._analyse_traffic_result(stats_info, rate_type))
        self.execute_egate_command("set_log flush")
        return tput

    def ap_get_bearer_stats_info(self, **kwargs):
        """
        execute bearer_stats command and return all data.\n
        :kwargs    : add all parameters used in bearer_stats command.

        :rtype: dict
        Example:
        | &{nsaBearerStatsDict}= | Ap Get Bearer Stats Info | ue=31 | id=2 | dir=dl |
        | Log |  &{nsaBearerStatsDict} |
        | Log |  &{nsaBearerStatsDict}[Bytes sent] |
        | &{saBearerStatsDict}= | Ap Get Bearer Stats Info | ue=1 | pdu=1 | qfi=1 | dir=dl |
        | Log |  &{saBearerStatsDict}[Total packets received] |

        """
        if kwargs:
            bearer_stats_parameters = self._convert_kwargs_to_para_str(kwargs)
        else:
            raise Exception("please input bearer_stats command's parameters.")
        cmd = "bearer_stats %s" % (bearer_stats_parameters)
        builtin_obj.log("egate cmd=%s" % cmd)
        statsInfo = self.execute_egate_command(cmd, pass_regexp="Average packet interval")
        builtin_obj.log(statsInfo)
        listOfStatsInfo = statsInfo.splitlines()
        listOfStatsInfo = [x for x in listOfStatsInfo if x != '']
        messageHeadIndex, messageEndIndex, messageHeadCount = 0, 0, 0
        bearerStatsDict = {}
        # filter message content
        for index, line in enumerate(listOfStatsInfo):
            if line.count("===") and messageHeadCount == 0:
                messageHeadIndex = index
                messageHeadCount += 1
                continue
            if (line.count("Parameter") and line.count("Value")) or line.count("----"):
                continue
            if line.count("===") and messageHeadCount == 1:
                messageEndIndex = index
                messageHeadCount += 1
                break
            if messageHeadCount == 1 and messageHeadIndex != 0 and messageEndIndex == 0:
                lineContent = [x.strip() for x in line.split("  ") if x != '']
                bearerStatsDict[lineContent[0]] = lineContent[1]
                continue
        return bearerStatsDict

    @staticmethod
    def _convert_kwargs_to_para_str(kwargs):
        parameters_str = ""
        for para, value in kwargs.items():
            parameters_str = parameters_str + "%s=%s " % (para, value)
        return parameters_str

    @staticmethod
    def _analyse_traffic_result(stats_info, rate_type):
        """Get throughput by analyze info from egate command.

        :param string  stats_info: info from egate.
        :param string  rate_type: include ave, max min

        :return: according to rate_type, get throughput value, unit is kbps
        :rtype: string
        """
        rate_type = rate_type.lower()
        rate_dict = {'ave': "Average data rate",
                     'max': "Maximum data rate",
                     'min': "Minimum data rate"}

        for line in stats_info.split("\n"):
            if rate_dict[rate_type] in line:
                tput = line.split()[3]
        return tput

    @staticmethod
    def _convert_bps_to_kbps(tput):
        """Convert bps to kbps

        :param tput: throughput value, unit is bps
        :return: throughput value, unit is kbps
        """
        ret = float(tput) / 1000
        return float('%.2f' % ret)

    def ap_get_throuput_on_specific_scell(self, ue_id, scell_id, type, rate_type='ave', **kwargs):
        """
        execute ue_stats_nr id=<ue_id> scell=<scell_id> type=<type> and return scell throuput.\n
        :param string  ue_id: Specified UE ID(s). Mandatory
        :param string  scell_id: Carrier Aggregation serving cell. Mandatory
        :param string  type: Statistics type. pdsch or all.Mandatory
        :param string  rate_type: ave, current, max or min. get the throughput for Average data rate,Current data rate
         Maximum data rate or Minimum data rate.optional
        :param dict    kwargs: other parameters for ue_stats_nr command ,fox example :format=long

        :return: according to rate_type, get throughput value, unit is kbps
        :rtype: string
        Example:
        | ${scell_tput} | Ap Get Throuput On Specific Scell | ue_id=1 | scell_id=1 | type=pdsch | rate_type=ave |
        | Should Be True | ${scell_tput}/1000 > 0|
        """
        self._check_params_on_scell_thoughput(ue_id, scell_id, type, rate_type)
        s_extra_parameters = ""
        if kwargs:
            s_extra_parameters = self._convert_kwargs_to_para_str(kwargs)
        cmd = "ue_stats_nr id=%s scell=%s type=%s %s" % (ue_id, scell_id, type, s_extra_parameters)
        builtin_obj.log("egate cmd=%s" % cmd)
        pass_regex = "CellIndex-{}".format(scell_id)
        stats_info = self.execute_egate_command(cmd, pass_regexp=pass_regex)
        builtin_obj.log(stats_info)
        lines = stats_info.split('\n')
        hit_line = ''
        for each_line in lines:
            if pass_regex in each_line:
                hit_line = each_line
                break
        throughput = float(self._analyse_throughput_on_scell_thoughput(hit_line, rate_type))
        return throughput

    def _analyse_throughput_on_scell_thoughput(self, hit_line, rate_type):
        """analyze value for ap_get_throuput_on_specific_scell"""
        hit_list = hit_line.split()[1:]
        if hit_list[-1] != "0":
            unit_type = hit_list[-1]
        else:
            unit_type = "bps"
        res_hit_list = []
        for i in hit_list:
            if re.match(r"(\d+|\d+\.\d+)", i) is not None:
                res_hit_list.append("%s%s" % (i, unit_type))
        tput_dict = {'current': 0, 'min': 1, 'max': 2, 'ave': 3}
        throughput = res_hit_list[tput_dict[rate_type.lower()]]
        throughput_unit = re.search(r"[A-Za-z]+", throughput).group()
        throughput_value = float(throughput.replace(throughput_unit, ""))
        if throughput_unit.lower() == "mbps":
            throughput_value = float(throughput_value) * 1000
        return throughput_value

    def _check_params_on_scell_thoughput(self, ue_id, scell_id, direction, rate_type):
        """check if give parameters for ap_get_throuput_on_specific_scell is valid"""
        if ue_id.isdigit() is not True:
            raise Exception("UE id %s is an unsupported format" % ue_id)
        if scell_id.isdigit() is not True:
            raise Exception("scell id %s is an unsupported format" % scell_id)
        if str(direction).upper() not in ["ALL", "PDSCH", "PUSCH"]:
            raise Exception("direction %s is an unsupported format, only all or pdsch in ap now" % direction)
        if str(rate_type).upper() not in ['AVE', 'MAX', 'MIN', 'CURRENT']:
            raise Exception("ave: Average, max: Maximum, min: Minimum, cur: Current, please check para %s") % rate_type

    def traffic_should_be_ok(
            self, ue_id='1', bearer_id='2', dl_mbps='5', ul_mbps='1', timeout=5, pdu='1', qfi='1', type='NSA',
            dl_trf_id='1', ul_trf_id='2', thresh='0.9'):
        """
        the keyword is to test traffic ok or not.\n
        the keyword will start to send traffic and wait timeout time , then stop traffic and check.
        :param ue_id  string: Specified UE ID(s). for SA type or NSA type.optional
        :param bearer_id  string:Specified Bearer ID(s) for NSA type. optional
        :param dl_mbps  string: DL Traffic rate in megabytes per second. optional
        :param ul_mbps  string: UL Traffic rate in megabytes per second. optional
        :param timeout    string: wait time between traffic sending and stop.
        :param qfi    string: QFI associated with traffic (id dynamically allocated during PDU Session establishment)
        :param type    string: check NSA traffic or SA traffic.
        :param dl_trf_id    string: DL Traffic id (several traffics can be started for a bearer)
        :param ul_trf_id    string: UL Traffic id (several traffics can be started for a bearer)
        :param thresh    string: coefficient in comparing the actual value with target dl_mbps or ul_mpbs value
        Example:
        | Traffic Should Be Ok | ue_id=91  |  pdu=1 | | qfi=1 | Type=SA |
        | Traffic Should Be Ok | ue_id=91  | bearer_id=2 | Type=NSA |
        """
        if type.lower() == 'nsa':
            start_dl_cmd = 'trf_data_start ue={} id={} dir=dl mbps={} trf_id={}'.format(
                ue_id, bearer_id, dl_mbps, dl_trf_id)
            start_ul_cmd = 'trf_data_start ue={} id={} dir=ul mbps={} trf_id={}'.format(
                ue_id, bearer_id, ul_mbps, ul_trf_id)
            stop_dl_cmd = 'trf_data_stop ue={} id={} dir=dl trf_id={}'.format(
                ue_id, bearer_id, dl_trf_id)
            stop_ul_cmd = 'trf_data_stop ue={} id={} dir=ul trf_id={}'.format(
                ue_id, bearer_id, ul_trf_id)
            self.execute_egate_command(
                start_dl_cmd, pass_regexp='UDP DL TRF')
            self.execute_egate_command(
                start_ul_cmd, pass_regexp='UDP UL TRF')
            time.sleep(int(timeout))
            dl_stats = self.ap_get_nsa_throughput(ue_id=ue_id, bearer_id=bearer_id, direction='dl', rate_type='max')
            ul_stats = self.ap_get_nsa_throughput(ue_id=ue_id, bearer_id=bearer_id, direction='ul', rate_type='max')
            self.execute_egate_command(
                stop_dl_cmd, pass_regexp='stopped')
            self.execute_egate_command(
                stop_ul_cmd, pass_regexp='stopped')

        elif type.lower() == 'sa':
            start_dl_cmd = 'trf_data_start ue={} pdu={} qfi={} dir=dl mbps={}'.format(
                ue_id, pdu, qfi, dl_mbps)
            start_ul_cmd = 'trf_data_start ue={} pdu={} qfi={} dir=ul mbps={}'.format(
                ue_id, pdu, qfi, dl_mbps)
            stop_dl_cmd = 'trf_data_stop ue={} pdu={} dir=dl'.format(
                ue_id, pdu, )
            stop_ul_cmd = 'trf_data_stop ue={} pdu={} dir=ul'.format(
                ue_id, pdu, )
            self.execute_egate_command(
                start_dl_cmd, pass_regexp='UDP DL TRF')
            self.execute_egate_command(
                start_ul_cmd, pass_regexp='UDP UL TRF')
            time.sleep(int(timeout))
            dl_stats = self.ap_get_sa_throughput(ue_id=ue_id, pdu=pdu, qfi=qfi, direction='dl', rate_type='max')
            ul_stats = self.ap_get_sa_throughput(ue_id=ue_id, pdu=pdu, qfi=qfi, direction='ul', rate_type='max')
            self.execute_egate_command(
                stop_dl_cmd, pass_regexp='Stopped')
            self.execute_egate_command(
                stop_ul_cmd, pass_regexp='Stopping')
        dl_max = dl_stats
        ul_max = ul_stats
        if dl_max < float(thresh) * float(dl_mbps) * 1000:
            raise AssertionError(
                'dl max data rate is {} which is below {}*{}'.format(dl_max, thresh, dl_mbps))
        if ul_max < float(thresh) * float(ul_mbps) * 1000:
            raise AssertionError(
                'ul max data rate is {} which is below {}*{}'.format(ul_max, thresh, ul_mbps))

    def get_nr_meas_id_for_specific_type_and_frequency(self,
                                                       ue_id,
                                                       carrierfreq,
                                                       event_type,
                                                       carrierfreq_rat="NR",
                                                       measho_type='',
                                                       threshold='',
                                                       timetotrigger='',
                                                       timeout='2',
                                                       ):
        """
        the keyword is to get meas id from ue_meas_cfg_disp according to carrierfrequency, carrierfrequency rat
        and event_type.\n
        :param ue_id  string: Specified UE ID(s). for SA type or NSA type.mandatory
        :param carrierfreq  string:condition to look up meas id, absoluteFrequencySSB calculated by
        nr arfcn and gscn. mandatory
        :param carrierfreq_rat  string: condition to look up meas id , such as NR,EUTRAN , default is NR. optional
        :param event_type  string: condition to look up meas id , such as A1,A2,A3,A4,A5,A6,B1,B2,periodical.
        :param mesho_type  string: condition to look up RSRP or RSRQ.
        :param threshold   string: condition to look up specific threhold value. such as threshold=RSRP 60
        :param timetotrigger    string:condition to look up TimeToTrigger value. such as timetotrigger=480 ms
        :param timeout     string: the wait time after inputting ue_meas_cfg_disp command.
        Example:
        | Get Nr Meas Id For Specific Type And Frequency | ue_id=91  |  carrierfreq=633216 | carrierfreq_rat=NR |
        | event_type=A3 |
        """
        query_para, filter_conditions = [], {}
        # convert the parameter as dict format
        for items in self.get_meas_id_fun_supported_keys:
            filter_conditions[items] = str(eval(items))
        query_para.append(filter_conditions)
        return self.get_nr_meas_ids_for_specific_type_and_frequency(query_para)

    def get_nr_meas_ids_for_specific_type_and_frequency(self, list_of_query_conditions):
        """
        the keyword is to get meas ids from ue_meas_cfg_disp according to carrierfrequency, carrierfrequency rat
        , event_type, measho_type, threshold, timetotrigger.
        when set multiple timeout, the minimum timeout value will be used.\n
        :param list_of_query_conditions  list:
        [{"ue_id":"81","carrierfreq":12345, "event_type"="A2"},
         {"ue_id":"81","carrierfreq":12346, "carrierfreq_rat"="EUTRA", "event_type"="B2"},}
        Example:
        | ${total_query} |  Create List  |
        | ${query1}  |  Create Dictionary |  ue_id=81   | carrierfreq=514080 | event_type=A2 |
        | ${query2}  |  Create Dictionary |  ue_id=81   | carrierfreq=1 | event_type=B2 | carrierfreq_rat=EUTRAN |
        | Append To List |  ${total_query} | ${query1}
        | Append To List |  ${total_query} | ${query2}
        | {measid}=  | Get Nr Meas Ids For Specific Type And Frequency | list_of_query_conditions=${total_query} |
        """
        meas_ids = []
        # parse ue_meas_cfg_disp output and return dict.
        try:
            # get ue id
            ue_id = list_of_query_conditions[0]["ue_id"]
            # get minimum timeout value on parameters of multiple group
            timeout = min([time_value
                           for time_value in [per_para.get("timeout", "2") for per_para in list_of_query_conditions]])
        except Exception:
            detail = traceback.format_exc()
            raise Exception("the error is from ue id or timeout not specify, "
                            "parameter is {},err:{}.".format(list_of_query_conditions, detail))
        builtin_obj.log("ue_id:{},timeout:{}".format(ue_id, timeout), level="INFO")
        # execute egate cmd and parse data
        cmd = 'ue_meas_cfg_disp id={} meas_obj_type=nr'.format(ue_id)
        try:
            meas_cfg_info = self.execute_egate_command(cmd,
                                                       fail_regexp='no NR MEASUREMENT IDENTITIES', timeout=timeout)
            ue_meas_dict = self.parse_nr_ue_meas_cfg(meas_cfg_info)
        except Exception:
            # re-execute egate cmd if fail
            detail = traceback.format_exc()
            builtin_obj.log("Parse UE Meas Cfg Data Error, Retry...", level="WARN")
            builtin_obj.log("Egate Returned Error Data is {}.".format(meas_cfg_info))
            self.execute_egate_command("set_log flush")
            meas_cfg_info = self.execute_egate_command(cmd,
                                                       fail_regexp='no NR MEASUREMENT IDENTITIES', timeout=timeout)
            ue_meas_dict = self.parse_nr_ue_meas_cfg(meas_cfg_info)
        # parse each block content from ue_meas_cfg_disp
        meas_objectid_data = ue_meas_dict['measurment_objects']
        nr_rept_cfg_data = ue_meas_dict['nr_report_configurations']
        detailed_nr_rept_cfg_data = ue_meas_dict['detailed_info_about_nr_report_configurations']
        meas_id_data = ue_meas_dict['nr_measurement_identities']
        # find the meas id from filter conditions
        for fun_para in list_of_query_conditions:
            # check conditions parameter is correct
            for key in fun_para.keys():
                if self.get_meas_id_fun_supported_keys.count(key) == 0:
                    traceback.print_exc()
                    raise Exception("condition %s is not supported" % key)
            builtin_obj.log("Start to find measurement identity by {}.".format(fun_para), level="INFO")
            # get meas object id from measurment_objects table
            meas_object_ids = self._get_meas_objectid_from_data(carrierfreq=fun_para.get("carrierfreq"),
                                                                carrierfreq_rat=fun_para.get("carrierfreq_rat", "NR"),
                                                                data=meas_objectid_data,
                                                                )
            # get report config id from nr_report_configurations and detail_info_about_nr_report_configurations table
            report_cfg_ids = self._get_report_cfg_id_from_data(event_type=fun_para.get("event_type"),
                                                               measho_type=fun_para.get("measho_type", ""),
                                                               threshold=fun_para.get("threshold", ''),
                                                               timetotrigger=fun_para.get("timetotrigger", ''),
                                                               nr_report_config_data=nr_rept_cfg_data,
                                                               detailed_nr_report_config_data=detailed_nr_rept_cfg_data
                                                               )
            # get meas id from nr_measurement_identities table
            meas_id = self._get_meas_id_from_data(meas_object_ids=meas_object_ids,
                                                  report_cfg_ids=report_cfg_ids,
                                                  data=meas_id_data
                                                  )
            if meas_id:
                builtin_obj.log("Lookup MeasurementIdentity"
                                " {} success by {}.".format(meas_id, fun_para), level="INFO")
                meas_ids.append(meas_id)
        if len(meas_ids) == 1:
            return meas_ids[0]
        else:
            return meas_ids

    def parse_nr_ue_meas_cfg(self, meas_cfg_info):
        """
        from ue_meas_cfg_disp id=xxx meas_obj_type=nr command's result,
        generate json data for NR MEASUREMENT OBJECTS,NR REPORT CONFIGURATIONS, NR MEASUREMENT IDENTITIES
        and DETAILED INFO ABOUT NR REPORT CONFIGURATIONS.
        """
        pattern_info = {
            'nr_measurment_objects': r"=== UE\d+ NR MEASUREMENT OBJECTS",
            'nr_report_configurations': r'=== UE\d+ NR REPORT CONFIGURATIONS',
            'nr_measurement_identities': r'=== UE\d+ NR MEASUREMENT IDENTITIES',
            'measurment_objects': r'=== UE\d+ MEASUREMENT OBJECTS',
            'detailed_info_about_nr_report_configurations': r'=== DETAILED INFO ABOUT NR REPORT CONFIGURATIONS',
        }

        if self._nr_ue_meas_cfg_check(meas_cfg_info, pattern_info) is not True:
            traceback.print_exc()
            raise Exception("Parse NR UE MEAS CFG Failure {}".format(meas_cfg_info))

        meas_cfg_block = map(lambda x: "=== " + x, meas_cfg_info.split("=== "))

        all_meas_cfg_data = {}
        for sub_meas_cfg_block in meas_cfg_block:
            data = {}
            # get nr_measure_objects data
            ret = re.search(pattern_info['nr_measurment_objects'], sub_meas_cfg_block)
            if ret:
                data = self._parse_meas_cfg_block(parse_type='nr_measurment_objects', info=sub_meas_cfg_block)
                all_meas_cfg_data['nr_measurment_objects'] = data
            # get nr_report_configurations data
            ret = re.search(pattern_info['nr_report_configurations'], sub_meas_cfg_block)
            if ret:
                data = self._parse_meas_cfg_block(parse_type='nr_report_configurations', info=sub_meas_cfg_block)
                all_meas_cfg_data['nr_report_configurations'] = data
            # get nr_measurement_identities data
            ret = re.search(pattern_info['nr_measurement_identities'], sub_meas_cfg_block)
            if ret:
                data = self._parse_meas_cfg_block(parse_type='nr_measurement_identities', info=sub_meas_cfg_block)
                all_meas_cfg_data['nr_measurement_identities'] = data
            # get measurment_objects data
            ret = re.search(pattern_info['measurment_objects'], sub_meas_cfg_block)
            if ret:
                data = self._parse_meas_cfg_block(parse_type='measurment_objects', info=sub_meas_cfg_block)
                all_meas_cfg_data['measurment_objects'] = data
            # get detailed_info_about_nr_report_configurations data
            ret = re.search(pattern_info['detailed_info_about_nr_report_configurations'], sub_meas_cfg_block)
            if ret:
                data = self._parse_detailed_nr_report_config(info=sub_meas_cfg_block)
                all_meas_cfg_data['detailed_info_about_nr_report_configurations'] = data
        return (all_meas_cfg_data)

    def _get_meas_objectid_from_data(self, carrierfreq, carrierfreq_rat, data):
        _meas_objectid = []
        for items in data.values():
            if carrierfreq in items['CarrierFreq'] and carrierfreq_rat in items['RAT']:
                _meas_objectid.append(items['Id'])
        if len(_meas_objectid) == 0:
            raise Exception("Look up carrierfreq:{} failure from {}".format(carrierfreq, data))
        return (_meas_objectid)

    def _get_report_cfg_id_from_data(self, event_type,
                                     measho_type, threshold, timetotrigger,
                                     nr_report_config_data, detailed_nr_report_config_data):
        rept_cfg_id_on_nr_rept_cfg = []
        for items in nr_report_config_data.values():
            if event_type.lower() in items['eventType'].lower():
                rept_cfg_id_on_nr_rept_cfg.append(items['Id'])
        if len(rept_cfg_id_on_nr_rept_cfg) == 0:
            raise Exception("Lookup event type:{} fail on nr report config"
                            " from {}".format(event_type, nr_report_config_data))

        rept_cfg_id_on_detailed_nr_rept_cfg = []
        for rpt_cfg_id, rpt_cfg_id_value in detailed_nr_report_config_data.items():
            for name, value in rpt_cfg_id_value.items():
                if timetotrigger in rpt_cfg_id_value.get('TimeToTrigger', '') \
                        and measho_type.lower() in value.lower() \
                        and threshold.lower() in value.lower():
                    rept_cfg_id_on_detailed_nr_rept_cfg.append(rpt_cfg_id)
                    break
        if len(rept_cfg_id_on_detailed_nr_rept_cfg) == 0:
            traceback.print_exc()
            raise Exception("Lookup event type:{}, measho_type:{}, threshold:{}, timetotrigger:{}"
                            " fail on detailed nr report config from {}".format(event_type,
                                                                                measho_type,
                                                                                threshold,
                                                                                timetotrigger,
                                                                                detailed_nr_report_config_data))

        report_cfg_id = []
        report_cfg_id = list(set(rept_cfg_id_on_nr_rept_cfg) & set(rept_cfg_id_on_detailed_nr_rept_cfg))
        if len(report_cfg_id) == 0:
            traceback.print_exc()
            raise Exception("Lookup report cfg id fail on nr report config and detailed nr report config table.")
        return report_cfg_id

    def _get_meas_id_from_data(self, meas_object_ids, report_cfg_ids, data):
        meas_id = ''
        for items in data.values():
            for sub_report_cfg_id in report_cfg_ids:
                for sub_meas_objectid in meas_object_ids:
                    if items['ReportCfgId'] == sub_report_cfg_id and items['ObjectId'] == sub_meas_objectid:
                        meas_id = items['MeasId']
                        return meas_id

        raise Exception("Lookup measId failure ,ReportCfgId is {},ObjectId is {}, but the database is :{}"
                        "".format(report_cfg_ids, meas_object_ids, data))

    def _parse_meas_cfg_block(self, parse_type, info):
        parse_data = {}
        lines = info.splitlines()
        lines = [x for x in lines if x != '']
        head_index = head_content = body_start = body_end = ''
        # get all column names for per measurement cfg block
        for index, line in enumerate(lines):
            if line.count("Id") and line.count("CarrierFreq") and parse_type == 'nr_measurment_objects' or \
                    line.count("Id") and line.count("eventType") and parse_type == 'nr_report_configurations' or \
                    line.count("MeasId") and parse_type == 'nr_measurement_identities' or \
                    line.count("CarrierFreq") and parse_type == 'measurment_objects':
                head_index = index
                head_content = line
        if head_index == '':
            raise Exception("Parse %s Head Data Failure {} in {}".format(parse_type, info))

        head_items = self._parse_meas_cfg_line(head_content)

        # get row data for per measure cfg block row
        for index, line in enumerate(lines[head_index + 1:]):
            if line.count("----"):
                body_start = head_index + index + 2
            if line.count("===="):
                body_end = head_index + index + 1
        if body_start == '' or body_end == '':
            raise Exception("Parse %s Body Data Failure {} in {}".format(parse_type, info))

        for index, sub_body_data in enumerate(lines[body_start:body_end]):
            sub_body_items = self._parse_meas_cfg_line(sub_body_data)
            result = dict(list(zip(head_items, sub_body_items)))
            if parse_type == 'nr_measurment_objects':
                parse_data[str(index)] = result
            if parse_type == 'nr_report_configurations':
                parse_data[result['Id']] = result
            if parse_type == 'nr_measurement_identities':
                parse_data[result['MeasId']] = result
            if parse_type == 'measurment_objects':
                parse_data[result['Id']] = result
        return parse_data

    def _parse_meas_cfg_line(self, meas_cfg_line):
        objects = meas_cfg_line.split("  ")
        objects = [x.strip() for x in objects if x.strip()]
        return objects

    def _nr_ue_meas_cfg_check(self, meas_cfg_info, pattern_info):
        """check ue_meas_cfg_disp command output and confirm if the output is satified."""
        for sub_pattern_info in pattern_info.values():
            sub_pattern_result = re.search(sub_pattern_info, meas_cfg_info)
            if sub_pattern_result:
                continue
            else:
                return False
        return True

    def _parse_detailed_nr_report_config(self, info):
        parse_data = {}
        nr_report_config_lines = [x.replace("\t", "    ") for x in info.splitlines() if x]
        search_pattern = r"ue\d+\s+trigger\s+event\s+for\s+report\s+configuration\s+(\d+):"
        # sperate nr report configuration and extract the main content
        check_valid_line_flag = False
        for index, line in enumerate(nr_report_config_lines):
            if re.search(search_pattern, line, re.I):
                nr_report_config_lines[index], check_valid_line_flag = "@@@@" + line, True
        if not check_valid_line_flag:
            builtin_obj.log("Warning: No NR Report Configuration Data Found On {}".format(info), level="WARN")
            return {}
        nr_report_config_lines = "".join(nr_report_config_lines).split("@@@@")
        # handle each line nr report configuration data
        for line in nr_report_config_lines:
            data_line_flag = re.search(search_pattern, line, re.I)
            if data_line_flag:
                nr_report_config_id = data_line_flag.group(1)
                trigger_event_data = [x.strip() for x in line.split("  ") if x]
                if len(trigger_event_data) == 2:
                    trigger_event_value = trigger_event_data[1]
                    parse_data[nr_report_config_id] = self._parse_trigger_event_on_nr_report_config(
                        trigger_event_value)
                else:
                    builtin_obj.log("Warning: found unofficial format on detailed"
                                    " nr report config :{}".format(line), level="WARN")
        return parse_data

    def _parse_trigger_event_on_nr_report_config(self, info):
        parse_data = {}
        lines = [line.strip() for line in info.split(",")]
        for line in lines:
            line = [x.strip() for x in line.split(":", 1)]
            parse_data[line[0]] = line[1]
        return parse_data

    def check_specific_ue_state(self, ue_id, state):
        """
        the keyword is to check ue state correct or not from ue_disp info\n
        :param ue_id  string: Specified UE ID(s). for example: 1,2,3,4-5,6-20,mandatory
        :param state  string: need confirmed state for ue. for example: active, off, activing
        Example:
        | Check Specific Ue State | ue_id=1,2,3-50  |  state=active |
        | Check Specific Ue State | ue_id=1-50  |  state=off |
        | Check Specific Ue State | ue_id=5,6,7,8,9  |  state=activing |
        """
        ue_id_list = self._gen_ue_id_from_para(id_data=ue_id)
        state = state.upper()
        cmd_rlt = self.execute_egate_command('ue_disp', fail_regexp="keyword end", timeout=5)
        ue_disp_info = self._parse_ue_disp(ue_info=cmd_rlt)
        for per_id in ue_id_list:
            try:
                ue_state = ue_disp_info[per_id]['State']
                if ue_state != state:
                    raise Exception(
                        "ue_id: {}, actual state is {}, expected value is {}, result FAIL.".format(
                            per_id, ue_state, state)
                    )
                else:
                    builtin_obj.log("ue_id: {}, actual state is {}, expected value is {}, result PASS.".format(
                        per_id, ue_state, state))
            except KeyError:
                raise Exception("ue_id :{}, data doesn't exist in ue_disp info".format(
                    per_id)
                )
            except Exception:
                detail = traceback.format_exc()
                raise Exception(detail)

    def _gen_ue_id_from_para(self, id_data):
        """
        return the id list that need be checked
        ue_id format:  1,2,10-12
        rtype: list
        return result example: ["1","2","10","11","12"]
        """
        result = []
        ids = [x.strip() for x in id_data.split(",") if len(x) != 0]
        for per_id in ids:
            if per_id.isdigit():
                result.append(per_id)
                continue
            match_result = re.search(r'(\d+)-(\d+)', per_id)
            if match_result:
                start_id = match_result.group(1)
                end_id = match_result.group(2)
                if start_id <= end_id:
                    for index in range(int(start_id), int(end_id) + 1):
                        result.append(str(index))
            else:
                raise Exception("ue_id: {} input incorrect,supported format is such as 1,2,3-50".format(per_id))

        result = list(set(result))
        result.sort()
        return result

    def _parse_ue_disp(self, ue_info):
        """
        parse ue_disp command's result
        used in Keyword Check Specific Ue State
        """
        parse_data = {}
        equal_sign_char_num = 0  # type: int
        minor_sign_char_num = 0  # type: int
        lines = ue_info.splitlines()
        lines = [x for x in lines if x != '']
        # find the head data
        for line in lines:
            if line.count("==="):
                equal_sign_char_num += 1
                continue
            if line.count("---"):
                minor_sign_char_num += 1
                continue
            if line.count("UE Id") and equal_sign_char_num == 1:
                head_items = self._parse_meas_cfg_line(line)
                continue
            if equal_sign_char_num == 1 and minor_sign_char_num == 1:
                data_items = self._parse_meas_cfg_line(line)
                combine_items = dict(list(zip(head_items, data_items)))
                parse_data[combine_items['UE Id']] = combine_items
        return parse_data

    def change_ap_bip_size_before_sos_capture(self, defined_size):
        """AP bip size is 1000 by default in sos report capturing, and defined 10 pcap files by cycle."""
        default_sos_bip_size = 1000
        ap_tmp_folder_size_check = self.execute_cmd_on_wts("df -h /tmp")
        storage_size_ret = self.execute_cmd_on_wts("df -h /tmp | grep '/tmp' | awk '{print $4}'")
        storage_check_G = re.match(r"(.*)G", storage_size_ret)
        storage_check_M = re.match(r"(.*)M", storage_size_ret)
        if storage_check_G:
            bip_storage_size = int(float(storage_check_G.group(1)) * 1000)
        elif storage_check_M:
            bip_storage_size = int(float(storage_check_M.group(1)))
        else:
            builtin_obj.log("Warning: Airphone storage size is not enough for"
                            " capture bip:\n%s" % ap_tmp_folder_size_check, level="WARN")
            bip_storage_size = default_sos_bip_size
        if int(defined_size) > bip_storage_size - 500:
            builtin_obj.log("Warning: Airphone storage size: %s is not enough for defined size:%s, "
                            "will use default size:%sM" % (storage_size_ret, defined_size,
                                                           default_sos_bip_size), level="WARN")
            defined_size = default_sos_bip_size
        self._change_sos_bip_size(defined_size)

    def _change_sos_bip_size(self, defined_size):
        each_bip_file_size = int(int(defined_size)/10)
        builtin_obj.log("step: BIP_FILE_SIZE_MBYTES and BIP_NUMBER_OF_FILES before change")
        self.pc_obj.execute_cmd_on_pc("cd /opt/iphy/latest; grep 'BIP_FILE_SIZE_MBYTES=' sosReport.cfg")
        self.pc_obj.execute_cmd_on_pc("cd /opt/iphy/latest; grep 'BIP_NUMBER_OF_FILES=' sosReport.cfg")
        self.pc_obj.execute_cmd_on_pc(
            "cd /opt/iphy/latest; "
            "sed -i -E 's/BIP_FILE_SIZE_MBYTES=[0-9]+/BIP_FILE_SIZE_MBYTES=%s/g' sosReport.cfg" % each_bip_file_size)
        builtin_obj.log("step: BIP_FILE_SIZE_MBYTES and BIP_NUMBER_OF_FILES after change")
        self.pc_obj.execute_cmd_on_pc("cd /opt/iphy/latest; grep 'BIP_FILE_SIZE_MBYTES=' sosReport.cfg")
        self.pc_obj.execute_cmd_on_pc("cd /opt/iphy/latest; grep 'BIP_NUMBER_OF_FILES=' sosReport.cfg")


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

    def set_ovlthreshold_on_cpues(self, threshold_value, target, cpue_ids):
        """This keyword is to change overload threshold on FSP specific cpue id container.
        keyword steps:
        | 1 | auto-adapt target DSP or K2 according to rack position.
        for example asp-1a is modified as asp-5a for right rack |
        | 2 | ssh to FCT |
        | 3 | ssh to target DSP(K2) |
        | 4 | ssh to target cp ue id |
        | 5 | execute set_overload_high_threshold script |
        | 6 | disconnect from FCT |
        arguments:
        | Input Parameters | Man. | Description |
        | threshold_value   |  Yes  | the threhold value  |
        | target | Yes |  DSP or K2 on which to execute the command. keyword will auto-adapt it for left/right rack. |
        | cpue_ids | Yes |  the list you need change cp ue container id from aashell nodes -p command |
        for example:
        | Set Ovlthreshold On CPUEs |  threshold_value=0 |  target=asp-1a  |  cpue_ids=['0x1011','0x1780']
        """
        rack_position = builtin_obj.get_variable_value("${RACK_POSITION}")
        if rack_position.lower().count("left"):
            target = target.replace("5", "1").replace("6", "2").replace("7", "3")
        elif rack_position.lower().count("right"):
            target = target.replace("1", "5").replace("2", "6").replace("3", "7")
        else:
            target = target
        build_release = builtin_obj.get_variable_value("${RELEASE}")
        if build_release == 'SBTS21B':
            cpln_ovl_cmd = "LD_LIBRARY_PATH=/opt/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold " \
                           "--overload_high_threshold {} --port 30671".format(threshold_value)
        else:
            cpln_ovl_cmd = "LD_LIBRARY_PATH=/opt/nokia/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold " \
                           "--overload_high_threshold {} --port 30671".format(threshold_value)
        try:
            cpue_conn = ssh_obj.connect_to_host(
                FCT_IP, "22", BTS_USERNAME, BTS_PASSWORD, conn_type="SSH", timeout="10")
            old_prompt = ssh_obj.set_shell_prompt("Password:", r"\?", ":~ >")
            ssh_out = ssh_obj.execute_shell_command("ssh toor4nsn@%s" % target)
            if ssh_out.count("fingerprint"):
                ssh_obj.execute_shell_command("yes")
            ssh_obj.set_shell_prompt(old_prompt)
            ssh_obj.execute_shell_command(BTS_PASSWORD)
            for cpue_id in cpue_ids:
                ssh_obj.execute_shell_command("lxc-attach -n {}".format(cpue_id))
                cpln_ovl_cmd_output = ssh_obj.execute_shell_command(cpln_ovl_cmd)
                if "Sent request to change overload high threshold" not in str(cpln_ovl_cmd_output):
                    builtin_obj.log("Set Overload Threshold Failure !", level="ERROR")
                ssh_obj.execute_shell_command("exit")
        except Exception:
            pass
        finally:
            ssh_obj.disconnect_from_host(cpue_conn)

    def get_all_cpue_ids(self, bbmod_ids):
        """This keyword is to get all cpue id list from all bbmod board.
        keyword steps:
        | 1 | login bbmod board according to bbmod ids
        | 2 | cd tmp folder |
        | 3 | check all cpue nodeid and corresponding cpue id. |
        | 4 | return the all result as dict format |
        arguments:
        | Input Parameters | Man. | Description |
        | bbmod_ids   |  Yes  | the bbmod id list from gnb |
        for example:
        | Get All Cpue Ids |  bbmod_ids=1,2,3 |
        """
        cpue_ids_dict = {}
        cpue_ids_temp_dict = {}
        try:
            cpue_conn = ssh_obj.connect_to_host(
                FCT_IP, "22", BTS_USERNAME, BTS_PASSWORD, conn_type="SSH", timeout="10")
            old_prompt = ssh_obj.set_shell_prompt("Password:", r"\?", ":~ >")
            for bbmod_id in bbmod_ids:
                ssh_out = ssh_obj.execute_shell_command("bsh %s:0" % bbmod_id)
                if ssh_out.count("fingerprint"):
                    ssh_obj.execute_shell_command("yes")
                ssh_obj.set_shell_prompt(old_prompt)
                ssh_obj.execute_shell_command(BTS_PASSWORD)
                ssh_obj.execute_shell_command("cd /ram")
                out = ssh_obj.execute_shell_command("ls -lrt |grep -i cpue |grep -v -w grep")
                cpue_ids_temp_dict[bbmod_id] = out
                ssh_obj.execute_shell_command("exit")
        except Exception:
            pass
        finally:
            ssh_obj.disconnect_from_host(cpue_conn)
        for bbmod_id, cpue_ids_output in cpue_ids_temp_dict.items():
            lines = cpue_ids_output.splitlines()
            for line in lines:
                temp_dict = {}
                result = re.search(r"node_(.*) [->]+.*CPUE(\d+)", line)
                if result:
                    temp_dict["bbmod_id"] = bbmod_id
                    temp_dict["cpue_node_id"] = result.group(1)
                    cpue_ids_dict[result.group(2)] = temp_dict
        return (cpue_ids_dict)

    def set_ovlthreshold_on_specific_cpue_id(self, cpue_ids, threshold_value):
        """This keyword is to change overload threshold on specific cpue id.
        arguments:
        | Input Parameters | Man. | Description |
        | threshold_value   |  Yes  | the threhold value  |
        | cpue_ids | Yes |  the list you need change cp ue id from aashell nodes -p command |
        for example:
        | Get OvlThreshold Prerequisite |
        | Set Ovlthreshold On Specific Cpue Id | cpue_ids=20,21,30,31 | threshold_value=20 |
        """
        cpue_ids = [x for x in cpue_ids.split(",") if x != '']
        cpue_ids_data = builtin_obj.get_variable_value("&{CPUE_IDS_DATA}")
        build_release = builtin_obj.get_variable_value("${RELEASE}")
        if build_release == 'SBTS21B':
            cpln_ovl_cmd = "LD_LIBRARY_PATH=/opt/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold " \
                           "--overload_high_threshold {} --port 30671".format(threshold_value)
        else:
            cpln_ovl_cmd = "LD_LIBRARY_PATH=/opt/nokia/lib64/ /opt/nokia/SS_CPLANE/bin/set_overload_high_threshold " \
                           "--overload_high_threshold {} --port 30671".format(threshold_value)
        try:
            cpue_conn = ssh_obj.connect_to_host(
                FCT_IP, "22", BTS_USERNAME, BTS_PASSWORD, conn_type="SSH", timeout="10")
            old_prompt = ssh_obj.set_shell_prompt("Password:", r"\?", ":~ >")
            for cpue_id in cpue_ids:
                if cpue_id not in cpue_ids_data.keys():
                    builtin_obj.log("cpud id %s can't be find in gnb." % cpue_id)
                    continue
                ssh_out = ssh_obj.execute_shell_command("bsh %s:0" % cpue_ids_data[cpue_id]["bbmod_id"])
                if ssh_out.count("fingerprint"):
                    ssh_obj.execute_shell_command("yes")
                ssh_obj.set_shell_prompt(old_prompt)
                ssh_obj.execute_shell_command(BTS_PASSWORD)
                ssh_obj.execute_shell_command("lxc-attach -n {}".format(cpue_ids_data[cpue_id]["cpue_node_id"]))
                cpln_ovl_cmd_output = ssh_obj.execute_shell_command(cpln_ovl_cmd)
                if "Sent request to change overload high threshold" not in str(cpln_ovl_cmd_output):
                    builtin_obj.log("Set Overload Threshold Failure !", level="ERROR")
                ssh_obj.execute_shell_command("exit")
                ssh_obj.execute_shell_command("exit")
        except Exception:
            pass
        finally:
            ssh_obj.disconnect_from_host(cpue_conn)

    def verify_gnb_AP_and_wts_version(self):
        """
        This keyword is to verify GNB version, AP version, and WTS version whether match
        """
        ap_build_link = "https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/"
        manifesh_link = "http://files.ute.nsn-rdnet.net/builds/enb/base/"
        save_path = "/home/ute/Downloads/"
        ap_vers = builtin_obj.get_variable_value('${AP_SW_VERSION}')
        gnb_vers = builtin_obj.get_variable_value('${GNB_SW_VERSION}')
        gnb_banch_name = gnb_vers.split('_')[0]
        trunk_gnb_vers = gnb_vers.replace(gnb_banch_name, 'SBTS00')
        ssh_obj.execute_shell_command("rm -rf %s%s" % (save_path, ap_vers))
        ssh_obj.execute_shell_command("rm -rf %s%s" % (save_path, trunk_gnb_vers))
        res1 = ssh_obj.execute_shell_command("wget %s%s/Manifest.ini -P /home/ute/Downloads/%s/"
                                             % (manifesh_link, trunk_gnb_vers, trunk_gnb_vers))
        if '404 Not Found' not in res1:
            config = configparser.ConfigParser()
            config.read("%s%s/Manifest.ini" % (save_path, trunk_gnb_vers))
            ap_pattern = re.compile(r"5G_\d.\d.\d+")
            ute_ap_version = ap_pattern.findall(config['GENERAL']['related_artifacts'])
            match_ap_version = ute_ap_version[0].replace('5G_', '')
            if ap_vers in match_ap_version:
                builtin_obj.log("ap version and GNB version match")
            else:
                builtin_obj.log("The GNB(%s) and ap(%s) version mismatch. Please doulbe confirm before raising \
                pronto, the official release link: %s%s/Manifest.ini.txt"
                                % (trunk_gnb_vers, ap_vers, manifesh_link, trunk_gnb_vers), level="WARN")
        pattern = re.compile(r"WTS_\d+.\d_\d.\d.\d+")
        cmd = "wget --http-user=ncommon --http-password=Cplansg4@123 -A sandybridge.tar.bz2 %s%s \
        -P /home/ute/Downloads/%s" % (ap_build_link, ap_vers, ap_vers)
        res = ssh_obj.execute_shell_command(cmd)
        if '%s.tmp' % (ap_vers) in res:
            all_vers = ssh_obj.execute_shell_command("cat /home/ute/Downloads/%s/%s.tmp |grep sandybridge.tar.bz2"
                                                     % (ap_vers, ap_vers))
            wts_vers = pattern.findall(all_vers)
            office_wts_vers = wts_vers[0]
            builtin_obj.log("The office release wts version=%s" % office_wts_vers)
        else:
            builtin_obj.log("The AP version is not office release, so get wts version failed", level="WARN")
        wts_version_all = ssh_obj.execute_shell_command("/opt/iphy/latest/egate --version")
        if wts_version_all:
            active_wts = pattern.findall(wts_version_all)
            act_wts_vers = active_wts[0]
            builtin_obj.log("activeWtsVersion=%s" % act_wts_vers, level="WARN")
        else:
            builtin_obj.log("Failed to get the current wts version, PLZ owner check", level="WARN")
        if act_wts_vers and office_wts_vers and "%s" % (act_wts_vers) != "%s" % (office_wts_vers):
            builtin_obj.log("The AP official release WTS:%s, but active WTS version:%s. \
            Please double check before raising pronto"
                            % (office_wts_vers, act_wts_vers), level="WARN")


class common_lib(common, operate_on_local_pc1, operate_on_local_pc2, operate_on_bts1, operate_on_bts2,
                 operate_on_wts, operate_on_fsp):
    def __init__(self):
        common.__init__(self)
        operate_on_local_pc1.__init__(self)
        operate_on_local_pc2.__init__(self)
        operate_on_bts1.__init__(self)
        operate_on_bts2.__init__(self)
        operate_on_wts.__init__(self)
        operate_on_fsp.__init__(self)


if __name__ == "__main__":
    obj = common_lib()
    help(obj)
    help(xml_obj)
