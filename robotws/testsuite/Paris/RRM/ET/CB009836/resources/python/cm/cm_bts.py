# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
"""
import os
import sys
import re
import time
import json
import random
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from ute_fsmaccess import ute_fsmaccess
from taf.sbts.oam.coam.admin import admin
from ute_admin_infomodel import ute_admin_infomodel
from ta_xml import ta_xml
from ta_xml.common_xml import CommonXML
from ta_ssh_telnet import ta_ssh_telnet
from testsuite.Paris.RRM.ET.CB009836.resources.python.common_lib import common_lib
from testsuite.Paris.RRM.ET.CB009836.resources.python.cm import reduced_var
import traceback
from testsuite.Paris.RRM.ET.CB009836.resources.python.cm.convert_delta import convert_delta_xml_to_json

xml_declare = "<?xml version='1.0' encoding='UTF-8'?>"
netact_cm_import_dir = "/var/opt/nokia/oss/global/racops/import"
netact_cm_export_dir = "/var/opt/nokia/oss/global/racops/export"

builtin_obj = BuiltIn()
os_obj = OperatingSystem()
xml_obj = ta_xml()
comm_obj = common_lib()
ssh_obj = ta_ssh_telnet()


class cm_base(object):
    def __init__(self, alias):
        self._setup_comm_flag = False
        self._setup_scf_control_flag = False
        self._setup_vendor_control_flag = False
        self._setup_swconfig_control_flag = False
        self.remote_host = None
        self.bts_host = "192.168.255.129"
        self.scf_template_full = ""
        self.scf_template_for_mo = ""
        self.scf_template_for_list = ""
        self.scf_template_svn = ""
        self.scf_for_startup = ""
        self.alias = alias
        self.modified_swconfig_file = ""
        self.modified_swconfig_file_iphy = ""
        self.params_definition = {}
        self.bts_info = {}
        self.rd_file_local_dir_old = ""
        self.rd_file_in_gnb = ""
        self.rd_file_local_target_mapping = {}

    def _setup_common(self):
        if not self._setup_comm_flag:
            self._setup_comm_flag = True
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#",
                                              host="192.168.255.129")
            self.fsm_obj.setup_wts_fsm_access(remote_host=self.remote_host, alias=self.alias, fallback_prompt="#")
            self.admin_obj = admin()

        comm_obj.setup_admin_if_alias_not_exist(self.admin_obj, self.alias, self.bts_host, self.remote_host)

    def _setup_scf_control(self):
        if not self._setup_scf_control_flag:
            self._setup_scf_control_flag = True
            self._setup_common()
            builtin_obj.log("_setup_common PASSED", level="INFO")
            if self.alias == "gnb1":
                self.full_commission_log_dir = builtin_obj.get_variable_value("${testCaseDir}")
                self.scf_template_full = os.path.join("/home/ute", "scf_template_full.xml")
                self.scf_template_for_mo = os.path.join("/home/ute", "scf_template_for_mo.xml")
                self.scf_template_for_list = os.path.join("/home/ute", "scf_template_for_list.xml")
                comm_obj.execute_cmd_on_pc("rm -rf %s" % self.scf_template_full)
                comm_obj.execute_cmd_on_pc("rm -rf %s" % self.scf_template_for_mo)
                comm_obj.execute_cmd_on_pc("rm -rf %s" % self.scf_template_for_list)
            else:
                self.full_commission_log_dir = os.path.join(builtin_obj.get_variable_value("${testCaseDir}"),
                                                            self.alias)
                self.scf_template_full = os.path.join("/home/ute", self.alias, "scf_template_full.xml")
                self.scf_template_for_mo = os.path.join("/home/ute", self.alias, "scf_template_for_mo.xml")
                self.scf_template_for_list = os.path.join("/home/ute", self.alias, "scf_template_for_list.xml")
                os_obj.create_directory(os.path.join("/home/ute", self.alias))
            self.scf_template_path = builtin_obj.get_variable_value("${testCaseDir}")
            bts_build = builtin_obj.get_variable_value("${current_gNB_sw_version}")
            if bts_build.count("_9999_"):
                # SBTS22R1_ENB_9999_210617_000005
                release_path = "trunk"
            else:
                # SBTS21B_ENB_0000_000236_000000
                release_path = bts_build.split("_")[0]
            builtin_obj.log("release_path = %s" % release_path, level="INFO")
            self.scf_template_svn = os.path.join(self.scf_template_path, release_path, "SCFC_template.xml")
            self.scf_for_startup = os.path.join(self.full_commission_log_dir + "/scfc_logs", "scf_for_startup.xml")
            self.scf_for_startup_fixing1 = os.path.join(self.full_commission_log_dir + "/scfc_logs",
                                                        "scf_for_startup_fixing_errors_1.xml")
            self.scf_for_startup_fixing2 = os.path.join(self.full_commission_log_dir + "/scfc_logs",
                                                        "scf_for_startup_fixing_errors_2.xml")
            self.scf_supplement = os.path.join(self.scf_template_path, release_path, "SCFC_1_supplement.xml")
            # download nidd json from gnb
            save_log_dir = builtin_obj.get_variable_value("${testCaseDir}")
            self.nidd_file = os.path.join(save_log_dir, "nidd.json")
            run_dir = comm_obj.get_swpool_path()
            builtin_obj.log("run_dir = %s" % run_dir, level="INFO")
            if os.path.exists(self.nidd_file) is False:
                self.fsm_obj.get_enb_file(os.path.join(run_dir, "nidd_*.json"), save_log_dir + '/', alias=self.alias)
                builtin_obj.log("get_enb_file PASSED", level="INFO")
                os_obj.move_file(os.path.join(save_log_dir, "nidd_*.json"), os.path.join(save_log_dir, "nidd.json"))

        if self._setup_scf_control_flag:
            self._setup_common()

    def _setup_swconfig_control(self):
        if not self._setup_swconfig_control_flag:
            self._setup_swconfig_control_flag = True
            self._setup_common()
            self.backup_swconfig_dir = comm_obj._get_save_log_dir(self.alias)
            self.backup_swconfig_file = os.path.join(self.backup_swconfig_dir, "swconfig.txt")
            self.backup_swconfig_file_iphy = os.path.join(self.backup_swconfig_dir, "swconfig_ap.txt")
            self.modified_swconfig_file = os.path.join(self.backup_swconfig_dir, "swconfig_modified.txt")
            self.modified_swconfig_file_iphy = os.path.join(self.backup_swconfig_dir, "swconfig_ap_modified.txt")
            self.enb_swconfig_file = "/ffs/run/swconfig.txt"

    def _setup_vendor_control(self):
        if not self._setup_vendor_control_flag:
            self._setup_vendor_control_flag = True
            self._setup_common()
            #             self.enb_vendor_dir = self._get_active_vendor_path()
            self.local_vendor_dir = comm_obj._get_save_log_dir(self.alias)

    #             self.vendor_name = self._get_active_vendor_version(self.enb_vendor_dir)
    #             self.vendor_p7_name = '%s.p7' % self.vendor_name

    def _teardown(self):
        pass

    def __del__(self):
        if self._setup_scf_control_flag or self._setup_vendor_control_flag:
            self.fsm_obj.teardown_enb_fsm_access(alias=self.alias)

    def execute_cmd_on_gnb(self, cmd):
        if self.alias == "gnb1":
            return comm_obj.execute_cmd_on_gnb(cmd)
        else:
            return comm_obj.execute_cmd_on_gnb2(cmd)

    def _mo_xpath(self, mo):
        # consider mo ending with same string
        if mo.count("MRBTS"):
            xpath = "//managedObject[matches(@distName, '%s$')]" % mo
        else:
            xpath = "//managedObject[matches(@distName, '.*/%s$')]" % mo
        return xpath

    def _get_timestamp(self):
        time_stamp = builtin_obj.get_time().replace("-", "").replace(" ", "").replace(":", "")
        return time_stamp

    def _download_scf(self, export_type="configurationAndRuntimeObjects"):
        builtin_obj.log("step: download active scf")
        time.sleep(1)  # sleep 1s to make sure parameter take effect than to download scf
        self._setup_scf_control()
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        timestamp = comm_obj.get_timestamp()
        scf_with_timestamp = "scf_%s.xml" % timestamp
        scf_with_fullpath = os.path.join((save_log_dir + "/scfc_logs"), "scf_%s.xml" % timestamp)
        self.admin_obj.get_current_scf_file(local_dir_path=(save_log_dir + "/scfc_logs"), file_name=scf_with_timestamp,
                                            connection=self.alias, export_type=export_type, timeout=20,
                                            with_auto_configured_parameters=True)
        if os.path.exists(scf_with_fullpath):
            builtin_obj.log("step: get active scf: %s" % scf_with_fullpath)
        else:
            raise Exception("fail to download active scf: %s" % scf_with_fullpath)

        return scf_with_fullpath

    def _delete_object_offline(self, source_scf, target_scf, mos_param):
        """
        Noted: match in all mo by regular expression should be '.*', but not be '*'
        | 1) | delete:mo_name or pattern | delete mo  |
        | 2) | delete:mo_name:list_name | delete list  |
        | 3) | delete:mo_name:list_name:key=value | delete the item that satisfy mo:list:key=value |
        Example
        | ${to_be_deleted_list} | Create List | delete:LNADJ.* | delete:PSGRP-1:lbpsPeriodList |
        delete:LNBTS-1824/PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ${TAR_SCF_STRING} | _delete_object_offline | D:\\scfc_1.xml | None | ${to_be_deleted_list} |
        | _delete_object_offline | D:\\scfc_1.xml | D:\\scfc_2.xml | ${to_be_deleted_list} |
        """
        mos_param = comm_obj.remove_empty_from_list(mos_param)
        for s_mo_param in mos_param:
            mo_name = s_mo_param.rsplit(":")[1].strip()
            mo_xpath = self._mo_xpath(mo_name)
            if "=" in s_mo_param:
                list_name = s_mo_param.rsplit(":")[2].strip()
                item_key = s_mo_param.rsplit(":")[3].split("=")[0].strip()
                item_value = s_mo_param.rsplit(":")[3].split("=")[1].strip()
                tbd_pattern = "%s//list[@name='%s']//*[@name='%s' and text()='%s']/.." % (
                    mo_xpath, list_name, item_key, item_value)
            else:
                if 1 == s_mo_param.count(":"):
                    tbd_pattern = mo_xpath
                elif 2 == s_mo_param.count(":"):
                    list_or_param_name = s_mo_param.rsplit(":")[2].strip()
                    tbd_pattern = "%s//list[@name='%s']|%s//p[@name='%s']" % (
                        mo_xpath, list_or_param_name, mo_xpath, list_or_param_name)
                elif 3 == s_mo_param.count(":"):
                    list_name = s_mo_param.rsplit(":")[2].strip()
                    param = s_mo_param.rsplit(":")[3].strip()
                    tbd_pattern = "%s//list[@name='%s']//p[@name='%s']" % (
                        mo_xpath, list_name, param)

            try:
                source_scf = xml_obj.remove_xml_element(
                    source_scf, None, tbd_pattern)
            except AssertionError as e:
                print(e)
                builtin_obj.log("No mo match %s\n" % tbd_pattern)

        if target_scf is None:
            return source_scf
        else:
            commonxml = CommonXML(source_scf)
            commonxml.save_xml(target_scf)
            return target_scf

    def _delete_object_online(self, active_scf, mos_param):
        """
        Noted: match in all mo by regular expression should be '.*', but not be '*'
        | 1) | delete:mo_name or pattern | delete mo  |
        | 2) | delete:mo_name:list_name | delete list  |
        | 3) | delete:mo_name:list_name:key=value | delete the item that satisfy mo:list:key=value |
        Example
        | ${to_be_deleted_list} | Create List | delete:LNADJ.* | delete:PSGRP-1:lbpsPeriodList |
        ... | delete:LNBTS-1824/PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | _delete_object_online | D:\\scfc_1.xml | ${to_be_deleted_list} |
        """
        l_mo_objects = []
        #   _verify_input_validity
        position = 1
        params_classified = self._classify_parameters_according_to_moname(mos_param, position)
        #     remove_replicate_mo
        for mo in params_classified.keys():
            mo_tbd = params_classified[mo][0]
            if 2 == len(mo_tbd.rsplit(":")):
                builtin_obj.log("Prepare to delete managedObject:\n")
                builtin_obj.log(params_classified[mo])
                l_mo_object = self._delete_mo_at_mo(active_scf, mo_tbd)
            else:
                # judge whether the mo exist or not
                mo_name = params_classified[mo][0].split(":")[1]
                mo_xpath = self._mo_xpath(mo_name)
                try:
                    pattern = "*|%s" % mo_xpath
                    s_element_mo = xml_obj.read_xml(active_scf, pattern)
                except AssertionError as e:
                    print(e)
                    builtin_obj.log(
                        "ManagedObject %s does not exist in current active_scf. Will Ignore this delete operation.\n"
                        % mo_name)
                    break
                l_mo_object = self._delete_mo_at_list_and_item(s_element_mo, params_classified[mo])

            l_mo_objects.extend(l_mo_object)

        return l_mo_objects

    def _delete_mo_at_mo(self, scf, delete_string):
        delete_list = delete_string.rsplit(":")
        mo_name = delete_list[1]
        mo_xpath = self._mo_xpath(mo_name)
        # get mo object's first line, also apply for regular expression.
        try:
            pattern = "*|%s" % mo_xpath
            s_mo_elements = self._get_multi_mo(scf, pattern)
            return s_mo_elements
        except AssertionError:
            builtin_obj.log("Can't match *|%s") % mo_xpath
            builtin_obj.log("No managed objects matching %s exists in the scf: %s" % (mo_name, scf))
            return False

    def _delete_mo_at_list_and_item(self, s_element_mo, l_under_the_same_mo):
        need_delete_flag = False
        list_position = 2
        d_under_the_same_mo = self._classify_parameters_according_to_list_dict(l_under_the_same_mo, list_position)
        mo_without_children = self._get_element_without_children(s_element_mo, "//managedObject", "operation=update")
        s_mo_object = mo_without_children
        for list_name in d_under_the_same_mo:
            l_under_the_same_list = d_under_the_same_mo[list_name]
            mo_name = l_under_the_same_list[0].split(":")[1]
            mo_xpath = self._mo_xpath(mo_name)
            # judge whether the list exist or not
            try:
                s_element_list = xml_obj.read_xml(s_element_mo,
                                                  "*|//list[@name='%s']|//p[@name='%s']" % (list_name, list_name))
                s_element_list_orignal = s_element_list
            except AssertionError as e:
                print(e)
                builtin_obj.log(" No list %s under %s exists in the scf." % (mo_name, l_under_the_same_list))
                #                 return []
                continue

            s_tbd_list = ""
            for s_delete in l_under_the_same_list:
                # judge whether the list is to be deleted or not
                if "=" not in s_delete:
                    s_tbd_list = self._get_element_without_children(s_element_list, "//list|/p")
                    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
                    print(s_tbd_list)
                    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
                    break
                else:
                    s_tbd_item = self._delete_mo_at_item(s_element_list, s_delete)
                    if s_tbd_item:
                        s_element_list = s_tbd_item

            if s_tbd_list:
                need_delete_flag = True
                builtin_obj.log("The list %s will be deleted under %s ." % (list_name, mo_name))
                s_mo_object = xml_obj.add_xml_element(s_mo_object, None,
                                                      s_tbd_list + "|%s" % mo_xpath)
                continue
            if s_element_list != s_element_list_orignal:
                need_delete_flag = True
                builtin_obj.log("The item will be deleted under %s." % list_name)
                s_mo_object = xml_obj.add_xml_element(s_mo_object, None,
                                                      s_element_list + "|%s" % mo_xpath)

        if need_delete_flag:
            return [s_mo_object]
        else:
            return []

    def _classify_parameters_according_to_list_dict(self, list_param, position=1):
        # position=1 means mo; position=2 means list, but need to make sure the
        # lists exist.
        dict_param = {}
        for line in list_param:
            key = line.split(':')[position].split("/")[-1]
            if key not in dict_param:
                dict_param[key] = []
            dict_param[key].append(line)
        return dict_param

    def _delete_mo_at_item(self, s_element_list, delete_string):
        # match the format: delete:mo_name:list_name:key=value
        split = delete_string.rsplit(":")
        mo_name = split[1]
        list_name = split[2]
        key = split[3].split("=")[0]
        value = split[3].split("=")[1]
        l_element_item = []

        # judge whether item exists or not
        item_pattern = "//list[@name='%s']//*[@name='%s' and text()='%s']/.." % (list_name, key, value)
        try:
            l_element_item = xml_obj.read_xml(s_element_list, "*|" + item_pattern)
        except AssertionError as e:
            print(e)

        if not l_element_item:
            builtin_obj.log("No key=value: %s = %s under %s:%s. This item need not to be deleted." % (
                key, value, mo_name, list_name))
            return s_element_list

        # get the list which removes the item
        try:
            s_element_list = xml_obj.remove_xml_element(s_element_list, None, item_pattern)
            return s_element_list
        except AssertionError as e:
            print(e)
            builtin_obj.log("Remove key=value: %s=%s from %s:%s failed.\n") % (key, value, mo_name, list_name)
            raise AssertionError

    def _verify_input_validity(self, mo_param):
        try:
            temp = mo_param.rsplit(":")
            if temp[0] != 'delete':
                builtin_obj.log("Input argument format should begin with \"delete:\"")
                return False
            if len(temp) == 4 and '=' in temp[3]:
                return True
            if len(temp) == 2 or len(temp) == 3:
                return True
            return False
        except Exception:
            return False

    def _get_multi_mo(self, scf, pattern):
        commonxml = CommonXML(scf)
        result_mo = []
        pattern_split = pattern.split("|", 1)
        xpath = pattern_split[1]
        elements = commonxml.get_elements(xpath)
        for element in elements:
            mo_object = commonxml.element_to_string(element)
            mo_object = self._get_element_without_children(mo_object, "//managedObject", "operation=delete")
            result_mo.append(mo_object)
        return result_mo

    def _scf_migration(self, source_scf):
        self._setup_scf_control()
        flag = False
        scf_name = source_scf.split("/")[-1]
        migrated_scf = os.path.join(self.full_commission_log_dir + "/scfc_logs", "migrated_%s" % scf_name)
        builtin_obj.log("src file is %s" % source_scf)
        builtin_obj.log("migrate file is %s" % migrated_scf)
        try:
            result = self.admin_obj.migrate_scf(source_scf, migrated_scf, alias=self.alias)
            if result['validationResult']['pdlValidationResult']['status'].lower() != 'ok' \
                    and source_scf.count("scf_for_startup.xml"):
                errors = result['validationResult']['pdlValidationResult']['logs']['relationErrors'] + \
                         result['validationResult']['pdlValidationResult']['logs']['hardwareErrors']
                self.init_relation_errors_num = len(errors)
                if len(errors):
                    comm_obj.log_to_console_with_time_prefix(
                        "There are relation errors in initial startup scf, "
                        "Please fix them, "
                        "base scf is: ***/SCFC_1.xml, "
                        "migration scf is: %s" % source_scf, level="WARN")

            if os_obj.get_file_size(migrated_scf) > 10000:
                # size > 10KB
                os_obj.copy_file(migrated_scf, source_scf)
                flag = True
            else:
                builtin_obj.log("fail to migrate %s" % source_scf, level="WARN")
                os_obj.copy_file(source_scf, migrated_scf)
        except Exception as _err:
            builtin_obj.log("fail to migrate %s because '%s'" % (source_scf, _err), level="WARN")
            os_obj.copy_file(source_scf, migrated_scf)
        return migrated_scf

    def _get_all_dns(self, scf, mo_class):
        all_dns = []
        commonxml_obj = CommonXML(scf)
        all_elements = commonxml_obj.get_elements("//*[matches(@class, '.*:%s$')]" % mo_class)
        for each_element in all_elements:
            dn = commonxml_obj.get_element_attribute(each_element, "distName")
            all_dns.append(dn)
        all_dns = list(set(all_dns))
        return all_dns

    def _extend_mo(self, parameters, scf, mo_class):
        parameters = comm_obj.remove_empty_from_list(parameters)
        need_extend = False
        for param in parameters:
            if param.split(":")[0].count(mo_class) and param.split(":")[0].count("%s-" % mo_class) == 0:
                need_extend = True
                break
        if not need_extend:
            return parameters

        out_parameters = []
        all_dns = [dn.split("/")[-1] for dn in self._get_all_dns(scf, mo_class)]
        all_dns = list(set(all_dns))
        if len(all_dns) == 0:
            return parameters
        for para in parameters:
            first = para.partition(":")[0]
            second = para.partition(":")[2]
            # mo:key=value, mo:list:key=value, mo:list:key=value|condition_key=condition_value, \
            # mo:list=value1,value2..., mo
            if first.split("/").count(mo_class):
                for dn in all_dns:
                    # first like LNCEL/LNCEL_TDD-0
                    if first.count(mo_class + "/"):
                        first_e = first.replace(mo_class + "/", dn + "/")
                    # first like LNCEL
                    else:
                        first_e = first.replace(mo_class, dn)
                    if len(second):
                        out_parameters.append(first_e + ":" + second)
                    else:
                        out_parameters.append(first_e)
            # delete:mo, delete:mo:list
            elif first == "delete" and second.split(":")[0].split("/").count(mo_class):
                for dn in all_dns:
                    if second.count(mo_class + "/"):
                        second_e = second.replace(mo_class + "/", dn + "/")
                    else:
                        second_e = second.replace(mo_class, dn)
                    out_parameters.append(first + ":" + second_e)
            else:
                out_parameters.append(para)
        return out_parameters

    def _extend_parameters(self, parameters, scf):
        parameters = comm_obj.remove_empty_from_list(parameters)
        out_parameters = self._extend_mo(parameters, scf, "NRCELL")
        out_parameters = self._extend_mo(out_parameters, scf, "NRBTS")
        out_parameters = self._extend_mo(out_parameters, scf, "MRBTS")
        return out_parameters

    def _get_element_without_children(self, xml, xpath, modified_attribs=[]):
        """
        | Input Parameters  | Man. | Description |
        | xml        | Yes  |  xml file or xml format string |
        | xpath      | Yes  |  xpath
        | modified_attribs       |  No  |  attributes to be modified. format is attrib=value list|
        | Return | xml element without child elements |
        Example
        | ${element} | _get_element_without_children| D:\\SCFC_1.xml| //managedObject | operation=update |
        """
        # handle modified_attribs, return dictionary
        modified_attribs_d = {}
        if not isinstance(modified_attribs, list):
            if len(modified_attribs.strip()) == 0:
                return modified_attribs
            modified_attribs = BuiltIn().create_list(modified_attribs)
        for item in modified_attribs:
            attrib_key = item.split("=")[0]
            attrib_value = item.split("=")[1]
            modified_attribs_d[attrib_key] = attrib_value

        old_attribs = xml_obj.read_xml(xml, "attrib|%s" % xpath)
        tag = xml_obj.read_xml(xml, "tag|%s" % xpath)
        out_element = "<%s></%s>" % (tag, tag)
        commonxml = CommonXML(out_element)
        out_element = commonxml.string_to_element(out_element)
        for attrib in old_attribs.keys():
            commonxml.set_element_attribute(out_element, attrib, old_attribs[attrib])

        for attrib_m in modified_attribs_d.keys():
            commonxml.set_element_attribute(out_element, attrib_m, modified_attribs_d[attrib_m])
        out_element = commonxml.element_to_string(out_element)
        return out_element

    def _classify_parameters_according_to_moname(self, parameters, position=0):
        """This keyword is to classify parameters according managedObject, return dictionary with key
        equals to managedObject, value is parameters belonging to the managedObject"""

        params_dict = {}
        mo_start = 0
        while (mo_start < len(parameters)):
            # judge mo already in params_dict or not
            mo = parameters[mo_start].split(":")[position]
            mo_exist = False
            for key in params_dict.keys():
                key_t = "/%s" % key
                mo_t = "/%s" % mo
                if key_t.endswith(mo_t) or mo_t.endswith(key_t):
                    mo_exist = True
            if mo_exist:
                mo_start = mo_start + 1
                continue
            # key is mo name, values are parameters belong to the mo
            paras_in_mo = []
            paras_in_mo.append(parameters[mo_start])
            for right in range(mo_start + 1, len(parameters)):
                mo_right = parameters[right].split(":")[position]
                mo_t = "/%s" % mo
                mo_right_t = "/%s" % mo_right
                if mo_t.endswith(mo_right_t) or mo_right_t.endswith(mo_t):
                    paras_in_mo.append(parameters[right])
            params_dict[mo] = paras_in_mo
            mo_start = mo_start + 1
        return params_dict

    def _classify_parameters_according_to_listname(self, parameters, position=1):
        """classify parameters which have condition(for example: mo:list:key=value|condition_key=condition_value),
           return dictionary with key equals to list_name, value is the list's parameters with condition
        """

        params_dict = {}
        # get parameters which contain condition
        params_cond = []
        for param in parameters:
            if param.count("|"):
                params_cond.append(param)

        list_start = 0
        while (list_start < len(params_cond)):
            # judge list already in params_dict or not
            list_name = params_cond[list_start].split(":")[position]
            list_exist = False
            for key in params_dict.keys():
                if key == list_name:
                    list_exist = True
            if list_exist:
                list_start = list_start + 1
                continue
            # key is list_name, values are parameters belong to the list
            paras_in_list = []
            paras_in_list.append(params_cond[list_start])
            for right in range(list_start + 1, len(params_cond)):
                list_right = params_cond[right].split(":")[1]
                if list_right == list_name:
                    paras_in_list.append(params_cond[right])
            params_dict[list_name] = paras_in_list
            list_start = list_start + 1
        return params_dict

    def _handle_items(self, mo_element, parameters):
        """
        input parameters: parameters which will be add/update and belong to one MO.

        if parameter contain condition, do the following actions
        1) get item0
        2) delete all items in the list
        3) add items according to item0 and condition specified in parameter
        """
        params_classified = self._classify_parameters_according_to_listname(parameters)
        for list_name in params_classified.keys():
            # get item0
            first_param = params_classified[list_name][0]
            mo_name = first_param.split(":")[0]
            mo_xpath = self._mo_xpath(mo_name)
            common_xml = CommonXML(mo_element)
            items = common_xml.get_elements(
                "%s/*[@name='%s']/item" % (mo_xpath, list_name))
            item0 = items[0]
            # delete old all items
            mo_element = xml_obj.remove_xml_element(mo_element, None,
                                                    "%s/*[@name='%s']/item" % (
                                                        mo_xpath, list_name))
            # add new items according to condition
            for param in params_classified[list_name]:
                condition = param.split("|")[1]
                condition_key = condition.split("=")[0]
                condition_value = condition.split("=")[1]
                try:
                    xml_obj.read_xml(mo_element,
                                     "*|%s/*[@name='%s']/item/*[@name='%s' and text()='%s']" % (
                                         mo_xpath, list_name, condition_key, condition_value))
                except AssertionError:
                    new_item = xml_declare + common_xml.element_to_string(item0)
                    new_item = xml_obj.modify_xml(new_item, "",
                                                  "text|%s|//*[@name='%s']" % (condition_value, condition_key))
                    mo_element = xml_obj.add_xml_element(mo_element, "",
                                                         new_item + "|%s/*[@name='%s']" % (
                                                             mo_xpath, list_name))
        return mo_element

    def _handle_mo_list_value_parameter(self, mo_element_or_scf, param):
        """
        param: mo:list=value1,value2 or mo:list=${EMPTY}
        <list name="taList">
        <p>125</p>
        <p>100</p>
       </list>
        """
        builtin_obj.log("zy: handling mo:list=value parameter: %s" % param)
        mo, list_name = param.split("=")[0].split(":")
        values = param.split("=")[1]
        mo_xpath = self._mo_xpath(mo)
        # flag true means existing in mo_element_or_scf
        try:
            xml_obj.read_xml(mo_element_or_scf, "*|%s/*[@name='%s']" % (mo_xpath, list_name))
            flag = True
        except AssertionError:
            flag = False
        if flag:
            # delete list if existing
            mo_element_or_scf = xml_obj.remove_xml_element(mo_element_or_scf, None,
                                                           "%s/*[@name='%s']" % (
                                                               mo_xpath, list_name))
        # add list
        mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "",
                                                    "<list name='%s'></list>|%s" % (
                                                        list_name, mo_xpath))
        # add p tag one by one
        if len(values):
            for p_value in values.split(","):
                new_p_element = "<p>%s</p>" % p_value
                mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "",
                                                            new_p_element + "|%s/*[@name='%s']" % (
                                                                mo_xpath, list_name))
        return mo_element_or_scf

    def _try_mo_key_parameter(self, mo_element_or_scf, param):
        # para format:  mo:key=value
        builtin_obj.log("zy: handling mo:key parameter: %s" % param)
        mo, key = param.split("=")[0].split(":")
        mo_xpath = self._mo_xpath(mo)
        try:
            xml_obj.read_xml(mo_element_or_scf, "*|%s/*[@name='%s']" % (mo_xpath, key))
        except AssertionError:
            mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "",
                                                        "<p name='%s'></p>|%s" % (key, mo_xpath))
        # builtin_obj.log("zy_debug: mo_element_or_scf is %s" % mo_element_or_scf)
        return mo_element_or_scf

    def _try_mo_list_key_parameter(self, mo_element_or_scf, param):
        # para format:  mo:list:key=value
        builtin_obj.log("zy: trying mo:list:key parameter: %s" % param)
        mo, list_name, key = param.split(":")
        mo_xpath = self._mo_xpath(mo)
        try:
            xml_obj.read_xml(mo_element_or_scf, "*|%s/*[@name='%s']//*[@name='%s']" % (mo_xpath, list_name, key))
        except AssertionError:
            mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "",
                                                        "<p name='%s'></p>|%s/*[@name='%s']/item"
                                                        % (key, mo_xpath, list_name))
        return mo_element_or_scf

    def _try_mo_list_with_item(self, mo_element_or_scf, param, active_scf=''):
        # para format is mo:list, the list has item
        builtin_obj.log("zy: trying mo:list parameter: %s" % param)
        if param.count(":") == 1:
            mo, list_name = param.split(":")
            mo_xpath = self._mo_xpath(mo)
            xpath_in_normal_scf = "*|%s/*[@name='%s']" % (mo_xpath, list_name)
            xpath_without_mo = "*|/managedObject/*[@name='%s']" % list_name
            xpath_in_scf_supplement = "*|%s/*[@name='%s']" % (
                self._mo_xpath("".join(re.split("-[0-9]+", mo))), list_name)
            xpath_parent = mo_xpath
            scf_template = self.scf_template_full
        else:
            raise Exception("this function doesn't support %s" % param)

        # flag true means existing in mo_element_or_scf
        try:
            param_element = xml_obj.read_xml(mo_element_or_scf, xpath_in_normal_scf)
            flag = True
        except AssertionError:
            flag = False
            try:
                param_element = xml_obj.read_xml(active_scf, xpath_in_normal_scf)
            except Exception as err_info:
                if len(active_scf):
                    builtin_obj.log(err_info)
                    builtin_obj.log("no %s in active SCFC, will try scfc template" % param)

                mo_template_name, mo_template_element = self._get_mo_template(mo, scf_template)
                try:
                    # get list from mo template
                    param_element = xml_obj.read_xml(mo_template_element, xpath_without_mo)
                    builtin_obj.log("get %s under %s in SCFC template(%s) " % (
                        param.partition(":")[-1], mo_template_name, scf_template))
                except AssertionError as err_info:
                    builtin_obj.log(err_info)
                    builtin_obj.log("no %s under %s in SCFC template(%s), will try scfc supplement" % (
                        param.partition(":")[-1], mo_template_name, scf_template))
                    try:
                        # get key or list from scfc supplement.xml
                        param_element = xml_obj.read_xml(
                            self.scf_supplement, xpath_in_scf_supplement)
                        builtin_obj.log("get %s under %s in SCFC supplement(%s) " % (
                            param.partition(":")[-1], "".join(re.split("-[0-9]+", mo)), self.scf_supplement))
                    except AssertionError as err_info:
                        builtin_obj.log(err_info)
                        raise Exception("no %s under %s in SCFC supplement(%s) " % (
                            param.partition(":")[-1], "".join(re.split("-[0-9]+", mo)), self.scf_supplement))

        # only get the first item to avoid some parameter in first item and some in other items.
        # here make first item contain as much parameter as possible
        commonxml = CommonXML(param_element)
        get_all_items = commonxml.get_elements("//item")
        if len(get_all_items):
            item0 = xml_declare + commonxml.element_to_string(get_all_items[0])
            param_element = self._get_element_without_children(param_element, "/*")
            param_element = xml_obj.add_xml_element(param_element, "", item0 + "|/*")

        # add the list into mo_element_or_scf
        if flag is True:
            mo_element_or_scf = xml_obj.remove_xml_element(mo_element_or_scf, None,
                                                           "%s/*[@name='%s']" % (
                                                               mo_xpath, list_name))
        mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "", param_element + "|" + xpath_parent)
        return mo_element_or_scf

    def _classify_parameters(self, parameters):
        """
        classify parameters to
        class1: mo
        class2: mo:key=value
        class3: mo:list=value1,value2, mo:list=${EMPTY}
        class4: mo:list:key=value(|cond_key=cond_value)
        """
        class1 = []
        class2 = []
        class3 = []
        class4 = []
        with open(self.nidd_file, 'r') as load_f:
            load_dict = json.load(load_f)
            for param in parameters:
                if param.split("=")[0].count(":") == 0:
                    class1.append(param)
                elif param.split("=")[0].count(":") == 1:
                    mo, key_or_list = param.split("=")[0].split(":")
                    mo_class = mo.split("/")[-1].split("-")[0]
                    if load_dict[mo_class]["params"][key_or_list]["type"] == "simple" and \
                            "maxOccurs" not in load_dict[mo_class]["params"][key_or_list].keys():
                        if "instanceId" not in load_dict[mo_class]["params"][key_or_list].keys():
                            class2.append(param)
                    else:
                        class3.append(param)
                elif param.split("=")[0].count(":") == 2:
                    class4.append(param)
                else:
                    raise Exception("wrong format: %s" % param)
        return class2, class3, class4

    def _add_or_update_parameters_element(self, mo_element_or_scf, parameters, active_scf=''):
        """add/update parameters value in managedObject element
        | Input Parameters | Man. | Description |
        | mo_element_or_scf  |  Yes  | managedObject or SCF where parameters will be add/update |
        | parameters  |  Yes  | parameters to be added/updated, which belong to one mo |
        | active_scf  | No | it is used for delta commissioning |
        """
        class2, class3, class4 = self._classify_parameters(parameters)
        # try structure for class2: mo:key
        for param in class2:
            mo_element_or_scf = self._try_mo_key_parameter(mo_element_or_scf, param)

        # add or modify for class3: mo:list=value1,value2, mo:list=${EMPTY}
        for param in class3:
            mo_element_or_scf = self._handle_mo_list_value_parameter(mo_element_or_scf, param)

        # try structure for class4: mo:list:key=value(|cond_key=cond_value)
        for param in class4:
            builtin_obj.log("zy: handling mo:list:key parameter: %s" % param)
            mo = param.split(":")[0]
            list_name = param.split(":")[1]
            mo_element_or_scf = self._try_mo_list_with_item(mo_element_or_scf, "%s:%s" % (mo, list_name), active_scf)
            key_name = param.split("=")[0].split(":")[-1]
            mo_element_or_scf = self._try_mo_list_key_parameter(mo_element_or_scf,
                                                                "%s:%s:%s" % (mo, list_name, key_name))
            if param.count("|") == 1:
                condition_key_name = param.split("|")[-1].split("=")[0]
                mo_element_or_scf = self._try_mo_list_key_parameter(mo_element_or_scf,
                                                                    "%s:%s:%s" % (mo, list_name, condition_key_name))

        # handle mutiple items
        mo_element_or_scf = self._handle_items(mo_element_or_scf, parameters)

        # modify parameters
        parameters_xpath = comm_obj.match_to_xpath(class2 + class4)
        mo_element_or_scf_content = xml_obj.modify_xml(mo_element_or_scf, "", parameters_xpath)
        return mo_element_or_scf_content

    def _update_mo(self, mo_in_scf, parameters, active_scf):
        "create managedObject element with update operation according to the managedObject element \
        in SCF or SCF template"
        mo_update = self._get_element_without_children(mo_in_scf, "//managedObject", "operation=update")
        mo_update = self._add_or_update_parameters_element(mo_update, parameters, active_scf)
        return mo_update

    def _update_trace(self, trace_element, parameters):
        # delete old ltrace
        delete_trace = self._get_element_without_children(trace_element, "//managedObject", "operation=delete")
        # create new ltrace
        create_trace = self._add_or_update_parameters_element(trace_element, parameters)
        create_trace = xml_obj.modify_xml(create_trace, "", "attrib=operation|create|//managedObject")
        # remove mo:key=${EMPTY}
        create_trace = xml_obj.remove_xml_element(create_trace, None, "//managedObject/p[not(text())]")
        return delete_trace, create_trace

    def _get_mo_template(self, mo, scf_template):
        dn_dict = {}
        # find all distnames which has same class as input mo
        mo_class = mo.split("/")[-1].split("-")[0]
        commonxml = CommonXML(scf_template)
        elements = commonxml.get_elements("//managedObject[matches(@class, '.*:%s$')]" % mo_class)
        for element in elements:
            distName = commonxml.get_element_attribute(element, "distName")
            # convert mo_template has same levels as mo
            mo_items = mo.split("/")
            mo_template_items = distName.split("/")
            mo_template_items = mo_template_items[-len(mo_items):]
            distName = "/".join(mo_template_items)
            element = xml_declare + commonxml.element_to_string(element)
            dn_dict[distName] = element

        if len(dn_dict):
            dn_all = sorted(list(dn_dict.keys()))
            for dn in dn_all:
                if dn.endswith("-1"):
                    return dn, dn_dict[dn]
            return dn_all[0], dn_dict[dn_all[0]]
        else:
            raise Exception("no template for %s in file %s" % (mo, scf_template))

    def _get_parameter_definition_from_meta(self, param):
        attributes = {}
        set_by_system_params = []
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        meta_file = os.path.join(save_log_dir, "meta", "lte", "meta.xml")
        if os.path.exists(meta_file) is False:
            run_dir = comm_obj.get_swpool_path()
            self.fsm_obj.get_enb_file(os.path.join(run_dir, "meta*.zip"), save_log_dir, alias=self.alias)
            os_obj.move_file(os.path.join(save_log_dir, "meta*.zip"), os.path.join(save_log_dir, "meta.zip"))
            comm_obj.uncompress_file(os.path.join(save_log_dir, "meta.zip"))
        mo_class = param.split(":")[0].split("/")[-1].split("-")[0]
        parameter = param.split(":")[-1]
        commonxml = CommonXML(meta_file)
        parameter_element_in_meta = commonxml.get_element(
            "//managedObject[matches(@class, '%s_A')]//p[matches(@name, '^%s$')]"
            % (mo_class, parameter))
        type1 = commonxml.get_element_attribute(parameter_element_in_meta, "type")
        attributes = commonxml.get_element_all_attributes(parameter_element_in_meta)
        attributes["type1"] = attributes["type"]
        attributes.pop("type")
        child_elements = commonxml.get_child_elements(parameter_element_in_meta)
        for element in child_elements:
            attributes = dict(attributes.items() + commonxml.get_element_all_attributes(element).items())
        attributes["type2"] = attributes["type"]
        if attributes["type1"] == "integer":
            attributes["type"] = "integer"
        if attributes["type2"] == "enum":
            values = []
            enum_element = commonxml.get_element(
                "//managedObject[matches(@class, '%s_A')]//enumeration[matches(@name, '^%s$')]"
                % (mo_class, type1))
            for enum_e in commonxml.get_child_elements(enum_element):
                values.append(commonxml.get_element_attribute(enum_e, "value"))
            values.sort()
            attributes["values"] = values
        return attributes

    def _get_parameter_definition(self, param):
        self._setup_scf_control()
        out_attrs = {"type": "", "min": "", "max": "", "values": ""}
        mo_class = param.split(":")[0].split("/")[-1].split("-")[0]
        parameter = param.split(":")[-1]
        if "%s/%s" % (mo_class, parameter) in self.params_definition.keys():
            out_attrs = self.params_definition["%s/%s" % (mo_class, parameter)]
            builtin_obj.log("zy: param=%s, new attrs=%s" % (param, out_attrs))
            return out_attrs

        with open(self.nidd_file, 'r') as load_f:
            load_dict = json.load(load_f)
            if param.count(":") == 1:
                attributes = load_dict["%s" % mo_class]["params"]["%s" % parameter]
            elif param.count(":") == 2:
                list = param.split(":")[1]
                attributes = load_dict["%s" % mo_class]["params"]["%s" % list]["params"]["%s" % parameter]
            else:
                builtin_obj.log("zy: not suppport %s" % param)
            builtin_obj.log("zy: param=%s, old attrs=%s" % (param, attributes))
            if "step" in attributes:
                if attributes["step"] == 1:
                    out_attrs["type"] = "integer"
                    out_attrs["min"] = attributes["minIncl"]
                    out_attrs["max"] = attributes["maxIncl"]
                else:
                    values = []
                    out_attrs["type"] = "enum"
                    value = attributes["minIncl"]
                    while value <= attributes["maxIncl"]:
                        values.append(str(value))
                        value = value + attributes["step"]
                    out_attrs["values"] = values

            if "enumeration" in attributes:
                out_attrs["type"] = "enum"
                out_attrs["values"] = [each["text"] for each in attributes["enumeration"]]

            if "base" in attributes:
                if attributes["base"] == "boolean":
                    out_attrs["type"] = "enum"
                    out_attrs["values"] = ["true", "false"]

        builtin_obj.log("zy: param=%s, new attrs=%s" % (param, out_attrs))
        self.params_definition["%s/%s" % (mo_class, parameter)] = out_attrs
        return out_attrs

    def _remove_parameters_set_by_system(self, mo_create):
        set_by_system_params = []
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        meta_file = os.path.join(save_log_dir, "meta", "lte", "meta.xml")
        if os.path.exists(meta_file) is False:
            run_dir = comm_obj.get_swpool_path()
            self.fsm_obj.get_enb_file(os.path.join(run_dir, "meta*.zip"), save_log_dir, alias=self.alias)
            os_obj.move_file(os.path.join(save_log_dir, "meta*.zip"), os.path.join(save_log_dir, "meta.zip"))
            comm_obj.uncompress_file(os.path.join(save_log_dir, "meta.zip"))

        commonxml_1 = CommonXML(mo_create)
        commonxml_2 = CommonXML(meta_file)
        mo_create_e = commonxml_1.get_element("/managedObject")
        mo_class_full = commonxml_1.get_element_attribute(mo_create_e, "class")
        mo_class = mo_class_full.split(":")[-1]
        all_P_elements = commonxml_1.get_elements("/managedObject/p")
        for P_element in all_P_elements:
            parameter = commonxml_1.get_element_attribute(P_element, "name")
            parameter_element_in_meta = commonxml_2.get_element(
                "//managedObject[matches(@class, '%s_A')]//p[matches(@name, '^%s$')]"
                % (mo_class, parameter))
            recurrence = commonxml_2.get_element_attribute(parameter_element_in_meta, "recurrence")
            modification_element = commonxml_2.get_element(
                "//managedObject[matches(@class, '%s_A')]//p[matches(@name, '^%s$')]/modification"
                % (mo_class, parameter))
            modification_type = commonxml_2.get_element_attribute(modification_element, "type")
            if recurrence == "optional" and modification_type == "unmodifiable":
                builtin_obj.log("zy: parameter %s may be type of value-set-by-sytem, removed" % parameter)
                set_by_system_params.append("/managedObject/p[matches(@name, '%s')]" % parameter)
        mo_create = xml_obj.remove_xml_element(mo_create, None, set_by_system_params)

        # list LNADJL:ecgiPlmnId can't exist when create LNADJL
        mo_create = xml_obj.remove_xml_element(mo_create, None,
                                               "/managedObject[matches(@class, '.*LNADJL')]/list[matches(@name, "
                                               "'ecgiPlmnId')]")
        return mo_create

    def _create_mo(self, mo_params, commission_type="delta"):
        "create new managedObject element according to template."
        mo = mo_params[0].split(":")[0]
        # use reduced scf template because sometimes case don't want too many MO parameters
        mo_template_name, mo_template_element = self._get_mo_template(mo, self.scf_template_for_mo)
        builtin_obj.log("get %s as %s template in SCFC template(%s)" %
                        (mo_template_name, mo, self.scf_template_for_mo))
        # replace mo template distName with mo and modify parameters of mo
        mo_create = xml_obj.modify_xml(mo_template_element, "",
                                       "attrib=distName|replace('%s', '%s')|//managedObject" % (mo_template_name, mo))
        if commission_type == "delta":
            mo_create = xml_obj.modify_xml(mo_create, "", "attrib=operation|create|//managedObject")
            # mo_create = self._remove_parameters_set_by_system(mo_create)
        # for create mo, all structures come from template
        mo_create = self._add_or_update_parameters_element(mo_create, mo_params)
        # remove mo:key=${EMPTY}
        mo_create = xml_obj.remove_xml_element(mo_create, None, "//managedObject/p[not(text())]")
        # remove mo:list=${EMPTY}
        mo_create = xml_obj.remove_xml_element(mo_create, None, "//managedObject/list[not(node())]")
        # remove mo:list:key=${EMPTY}
        mo_create = xml_obj.remove_xml_element(mo_create, None, "//managedObject/list//p[not(text())]")
        return mo_create

    def _search_in_NIDD(self, parameters):
        """
        parameters like:
        MRBTS/MNL/TCEADM
        MRBTS/MNL/TCEADM/TCE:tceIdentifier
        NRBTS/NRCTRLTS/NRMTRACECU:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced
        """
        params_pass = []
        params_fail = []
        self._setup_scf_control()
        # check parameters in NIDD
        with open(self.nidd_file, 'r') as load_f:
            load_dict = json.load(load_f)
            for param in parameters:
                # builtin_obj.log("debug: search {} in NIDD".format(param))
                # mo
                if param.count(":") == 0:
                    if param.count("."):
                        builtin_obj.log("wrong format %s, should not contain '.'" % param, level="WARN")
                        params_fail.append(param)
                    else:
                        for each in param.split("/"):
                            if each not in load_dict.keys():
                                builtin_obj.log("no %s in NIDD, please double confirm" % param, level="WARN")
                                params_fail.append(param)
                                break
                    if param not in params_fail:
                        params_pass.append(param)
                # mo:key
                elif param.count(":") == 1:
                    mo_class = param.split(":")[0].split("/")[-1]
                    key = param.split(":")[1]
                    if mo_class in load_dict.keys() and key in load_dict[mo_class]["params"].keys():
                        params_pass.append(param)
                    else:
                        builtin_obj.log("no %s in NIDD, please double confirm" % param, level="WARN")
                        params_fail.append(param)
                # mo:list:key
                elif param.count(":") == 2:
                    mo_class = param.split(":")[0].split("/")[-1]
                    list_name = param.split(":")[1]
                    key = param.split(":")[2]
                    try:
                        if mo_class in load_dict.keys() and \
                                list_name in load_dict[mo_class]["params"].keys() and \
                                key in load_dict[mo_class]["params"][list_name]["params"]:
                            params_pass.append(param)
                        else:
                            builtin_obj.log("no %s in NIDD, please double confirm" % param, level="WARN")
                            params_fail.append(param)
                    except Exception:  # consider list in mo:list:key is not list
                        detail = traceback.format_exc()
                        builtin_obj.log(detail)
                        builtin_obj.log("no %s in NIDD, please double confirm" % param, level="WARN")
                        params_fail.append(param)
                else:
                    builtin_obj.log("%s: wrong format" % param, level="WARN")
        return params_pass, params_fail

    def _search_mo_in_template(self, parameters):
        """
        parameters like:
        MRBTS/MNL/TCEADM
        MRBTS/MNL/TCEADM/TCE:tceIdentifier
        NRBTS/NRCTRLTS/NRMTRACECU:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced
        """
        mos_pass = []
        mos_fail = []
        mo_class_list = []
        # get mo_class list, remove duplicate and remove LTEENB because it's not in scf template
        for param in parameters:
            mo_class = param.split(":")[0].split("/")[-1]
            mo_class_list.append(mo_class)
        mo_class_list = list(set(mo_class_list))
        if "LTEENB" in mo_class_list:
            mo_class_list.remove("LTEENB")

        # check mo should exist in scf template
        commonxml1 = CommonXML(self.scf_template_full)
        for mo_class in mo_class_list:
            xpath_mo = "//*[matches(@class, '.*:%s$')]" % mo_class
            for param in parameters:
                if param.split(":")[0].split("/")[-1] == mo_class:
                    mo = param.split(":")[0]
                    break
            if len(commonxml1.get_elements(xpath_mo)):
                mos_pass.append(mo)
            else:
                builtin_obj.log("no %s in %s after migrated" % (mo, self.scf_template_svn), level="WARN")
                mos_fail.append(mo)
        return mos_pass, mos_fail

    def _search_mo_list_in_template(self, parameters):
        """
        parameters like:
        MRBTS/MNL/TCEADM
        MRBTS/MNL/TCEADM/TCE:tceIdentifier
        NRBTS/NRCTRLTS/NRMTRACECU:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced
        """
        self._setup_scf_control()
        lists_pass = []
        lists_fail = []
        commonxml1 = CommonXML(self.scf_template_full)
        commonxml2 = CommonXML(self.scf_supplement)
        for param in parameters:
            # for mo:list:key, search mo:list
            if param.count(":") == 2:
                mo, list_name, key = param.split(":")
                # list xpath in scf template
                mo_in_template = mo.replace("/", r"-\d+/") + r"-\d+"
                list_xpath_in_template = self._mo_xpath(mo_in_template) + "/*[@name='%s']" % list_name
                # list xpath in scf supplement
                list_xpath_in_supplement = self._mo_xpath(mo) + "/*[@name='%s']" % list_name
                # search in scf template and scf supplement
                if len(commonxml1.get_elements(list_xpath_in_template)) or len(
                        commonxml2.get_elements(list_xpath_in_supplement)):
                    lists_pass.append("%s:%s" % (mo, list_name))
                else:
                    lists_fail.append("%s:%s" % (mo, list_name))
        lists_pass = list(set(lists_pass))
        lists_fail = list(set(lists_fail))
        for each in lists_fail:
            builtin_obj.log("no %s in %s after migrated" % (each, self.scf_template_svn), level="WARN")
        return lists_pass, lists_fail

    def _search_params_in_template(self, parameters):
        self._setup_scf_control()

        # find mo:key, mo:list, mo:list:key, mo
        params_to_check = []
        parameters = comm_obj.remove_empty_from_list(parameters)
        for param in parameters:
            if param.count("delete"):
                continue
            if param.count("="):
                params_to_check.append(param.split("=")[0])
                if param.count("|"):
                    # LNBTS/PSGRP-1:lbpsCelPeriodList:lbpsCellDuration=1400|lbpsCellDayOfWeek=Sun
                    mo, list_name = param.split(":")[0:2]
                    condition_key = param.split("|")[-1].split("=")[0]
                    params_to_check.append("%s:%s:%s" % (mo, list_name, condition_key))
            else:
                params_to_check.append(param)

        # remove instance id and the duplicate, and sort list
        params_to_check2 = []
        for param in params_to_check:
            mo = param.split(":")[0]
            new_param = param.replace(mo, "".join(re.split("-[0-9]+", mo)))
            if new_param not in params_to_check2:
                params_to_check2.append(new_param)
        params_to_check2.sort()
        builtin_obj.log("params to be checked: %s" % params_to_check2)

        # all parameters should be in NIDD
        params_pass_nidd, params_fail_nidd = self._search_in_NIDD(params_to_check2)
        if len(params_fail_nidd):
            raise Exception("please make sure all parameters format right and can be found in WebGUI or NIDD")

        # MO need in SCF template, So all mandatory parameters will be in it.
        # for MO:list:key, MO:list need be defined in SCF template or supplement(if conflict in scf template)
        # MO:key, MO:list:key not in it, they are optional for MO or list creation
        mos_pass, mos_fail = self._search_mo_in_template(params_to_check2)
        lists_pass, lists_fail = self._search_mo_list_in_template(params_to_check2)
        if len(mos_fail) or len(lists_fail):
            raise Exception(
                "missing parameters in scf template, "
                "contact I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com")

    def _convert_delete(self, parameters):
        # convert delete:mo:list/key, delete:mo:list:key to mo:list/key=${EMPTY}, mo:list:key=${EMPTY}
        out = []
        parameters = comm_obj.remove_empty_from_list(parameters)
        for param in parameters:
            if param.count("delete:NRCELL_TDD-0") or param.count("delete:NRCELL_FDD-0"):
                param = "delete:NRCELL/%s" % param.partition(":")[-1]

            if param.count("delete") and param.count(":") > 1 and param.count("=") == 0 and param.count("*") == 0:
                out.append("%s=" % param.partition(":")[-1])
            else:
                out.append(param)
        return out

    def _generate_three_templates(self, mrbts_id, nrbts_id):
        builtin_obj.log("scf template is %s and SCFC_1_supplement.xml" % self.scf_template_svn, console=False)
        # one template becomes three template
        os_obj.copy_file(self.scf_template_svn, self.scf_template_full)
        if mrbts_id != "1":
            comm_obj.execute_cmd_on_pc("sed -i 's:MRBTS-1:MRBTS-%s:g' %s" % (mrbts_id, self.scf_template_full))
        if nrbts_id != "1":
            comm_obj.execute_cmd_on_pc("sed -i 's:NRBTS-1:NRBTS-%s:g' %s" % (nrbts_id, self.scf_template_full))
        self._delete_object_offline(self.scf_template_full, self.scf_template_for_mo,
                                    reduced_var.STRUCT_REDUCED_FOR_MO)
        self._delete_object_offline(self.scf_template_for_mo, self.scf_template_for_mo,
                                    reduced_var.STRUCT_REDUCED_FOR_LIST)
        self._delete_object_offline(self.scf_template_full, self.scf_template_for_list,
                                    reduced_var.STRUCT_REDUCED_FOR_LIST)
        self._scf_migration(self.scf_template_full)
        self._scf_migration(self.scf_template_for_mo)
        self._scf_migration(self.scf_template_for_list)

    def _fix_mo_create_error(self, mo, scf, mo_create):
        # if cell is FDD, beamformingInScellAllowed should not be configured into CAREL, \
        # but NRCELL-1/CAREL-1 as mo template has it because it is TDD cell
        if mo.rpartition("-")[0].endswith("CAREL"):
            cellTechnology = xml_obj.read_xml(scf, "text|%s/p[matches(@name, 'cellTechnology')]"
                                              % self._mo_xpath(mo.split("/")[-2]))
            if cellTechnology == "FDD":
                mo_create = xml_obj.remove_xml_element(mo_create, None,
                                                       "//p[matches(@name, 'beamformingInScellAllowed')]")
        return mo_create

    def _find_mo(self, scf, mo):
        comm_xml = CommonXML(scf)
        mo_xpath = self._mo_xpath(mo)
        elements = comm_xml.get_elements(mo_xpath)
        if len(elements):
            return True
        else:
            return False

    def _update_scf(self, scf, parameters):
        # convert delete:mo:list/key, delete:mo:list:key to mo:list/key=${EMPTY}, mo:list:key=${EMPTY}
        parameters = self._convert_delete(parameters)
        # check if parameters are in NIDD, scf template/scf supplement
        self._search_params_in_template(parameters)
        # extend NRCELL and LCELL and NRBTS according scf template
        parameters = self._extend_parameters(parameters, scf)
        builtin_obj.log("parameters to be changed: %s" % parameters)

        # modify scf according to parameters
        if len(parameters):
            params_classified = self._classify_parameters_according_to_moname(parameters)
            for mo in params_classified.keys():
                if mo == "delete":
                    self._delete_object_offline(
                        scf, scf, params_classified["delete"])

            for mo in params_classified.keys():
                if mo != "delete":
                    existing = self._find_mo(scf, mo)
                    if existing:
                        # update parameters of mo
                        builtin_obj.log("zy_mo: there is %s in %s, update it" % (mo, scf))
                        target_scf_content = self._add_or_update_parameters_element(
                            scf, params_classified[mo])
                        commonxml = CommonXML(target_scf_content)
                        commonxml.save_xml(scf, target_scf_content)
                    else:
                        builtin_obj.log("zy_mo: no %s in %s, create it" % (mo, scf))
                        mo_create = self._create_mo(params_classified[mo], "full")
                        mo_create = self._fix_mo_create_error(mo, scf, mo_create)
                        xml_obj.add_xml_element(scf, scf, mo_create + "|//cmData")
            # remove mo:key=${EMPTY}
            xml_obj.remove_xml_element(scf, scf, "//managedObject/p[not(text())]")
            # remove mo:list=${EMPTY}
            xml_obj.remove_xml_element(scf, scf, "//managedObject/list[not(node())]")
            # remove mo:list:key=${EMPTY}
            xml_obj.remove_xml_element(scf, scf,
                                       "//managedObject/list//p[not(text())]")
        else:
            builtin_obj.log("no parameters to be changed")

    def _find_param(self, param, user_params):
        find = False
        find_param = ''
        for user_param in user_params:
            if user_param.split("=")[0].endswith(param) or param.endswith(user_param.split("=")[0]):
                find = True
                find_param = user_param

            if user_param.count("|"):
                user_param2 = user_param.rpartition(":")[0] + ":" + user_param.rpartition(":")[-1].split("|")[-1]
                if user_param2.split("=")[0].endswith(param) or param.endswith(user_param2.split("=")[0]):
                    find = True
                    find_param = user_param2
            if find is True:
                break
        return find, find_param

    def _decide_expected_value(self, param, compare, target_value, user_params):
        exp_value = ""
        if len(compare) and len(target_value):
            attrs = self._get_parameter_definition(param)
            if attrs["type"] == "enum":
                match = re.search(r"^\d+([a-z]+)$", attrs["values"][-1], re.I)
                if match is not None:
                    unit = match.group(1)
                    target_value = target_value + unit

            if compare.count("="):
                if attrs["type"] == "integer" and attrs["min"] <= int(target_value) <= attrs["max"]:
                    exp_value = target_value
                elif attrs["type"] == "enum":
                    if attrs["values"].count(target_value):
                        exp_value = target_value

            if len(exp_value) == 0:
                if compare.count(">"):
                    if attrs["type"] == "integer" and int(target_value) + 1 <= attrs["max"]:
                        exp_value = str(int(target_value) + 1)
                    elif attrs["type"] == "enum":
                        for value in attrs["values"]:
                            if value > target_value:
                                exp_value = value
                                break
                elif compare.count("<"):
                    if attrs["type"] == "integer" and int(target_value) - 1 >= attrs["min"]:
                        exp_value = str(int(target_value) - 1)
                    elif attrs["type"] == "enum":
                        for value in attrs["values"]:
                            match = re.search(r"(\d+)\D*", value, re.I)
                            if match is not None:
                                if int(match.group(1)) < int(target_value):
                                    exp_value = value
                                    continue

            if exp_value.startswith("-"):
                exp_value = int(exp_value) + 140

        return exp_value

    def _adapt_param_value(self, exp, user_params, entry):
        params_to_modify = []
        params = []
        error = entry['feedback']
        related_objects = entry['relatedObjects']
        match = re.search(r"([^<>=]+)([<>=]*)([^<>=]*)", exp, re.I)
        if match is not None:
            param = match.group(1).strip().replace(".", ":").lstrip("(").rstrip(")")
            compare = match.group(2)
            target_value = match.group(3).rstrip("%")
            match2 = re.search(r"(^-?\d+)\s*\D*", target_value, re.I)
            if match2 is not None:
                target_value = match2.group(1)

            builtin_obj.log("zy: exp=%s%s%s" % (param, compare, target_value))
            if param.count(")") or param.count("(") or param.count(","):
                return []
            # supplement param according to relatedObjects
            if param.startswith("${"):
                param = param.lstrip("${").rstrip("}")
                param_to_compare = "".join(re.split(r"-\d+", param))
                if param_to_compare.count(":") == 2:
                    param_to_compare = param_to_compare.rpartition(":")[0]
                for obj_param in related_objects:
                    obj_param = obj_param.replace(".", ":")
                    obj_to_compare = "".join(re.split(r"-\d+", obj_param))
                    if obj_to_compare.count(param_to_compare):
                        if param.count(":") == 0:
                            params.append(obj_param.split(":")[0])
                        else:
                            # mo:list-1/2:key, remove -xx from list
                            params.append("%s:%s" % (obj_param.split(":")[0],
                                                     "".join(re.split(r"-\d+", param.partition(":")[-1]))))
            else:
                if param.count("NRBTS") == 0 and param.count("NRCELL:") == 0 and param.count("NRCELL/") == 0 \
                        and param.count("NRCELL-") == 0 and param.count("delete") == 0:
                    dn = self._get_all_dns(self.scf_template_full, param.split(":")[0].split("/")[-1].split("-")[0])[0]
                    if dn.count("NRCELL"):
                        param = "NRCELL/" + param
                # extend mo
                mo_split = param.split(":")[0].split("/")
                if param.count(":") > 0:
                    # mo:list-1/2:key, remove -xx from list
                    param = "%s:%s" % (param.split(":")[0], "".join(re.split(r"-\d+", param.partition(":")[-1])))
                params = param
                for mo in mo_split:
                    params = self._extend_mo(params, self.scf_to_fix, mo.split("-")[0])
                    params = self._extend_mo(params, self.scf_template_full, mo.split("-")[0])
            params = list(set(params))

            exp_value = self._decide_expected_value(params[0], compare, target_value, user_params)
            for param in params:
                builtin_obj.log("zy: exp=%s%s%s" % (param, compare, target_value))
                find, find_param = self._find_param(param, user_params)
                if not find:
                    if len(compare) == 0:
                        builtin_obj.log("zy: define %s" % param)
                        params_to_modify.append(param)
                    elif len(target_value) == 0:
                        if param.count(":"):
                            modify = "%s=" % param
                            builtin_obj.log("zy: remove %s" % param)
                            params_to_modify.append(modify)
                        else:
                            builtin_obj.log("zy: remove %s and its children" % param)
                            params_to_modify.extend(["delete:%s" % param, "delete:%s/.*" % param])
                    elif exp_value != '':
                        modify = "%s=%s" % (param, exp_value)
                        builtin_obj.log("zy: define %s" % modify)
                        params_to_modify.append(modify)
                    else:
                        builtin_obj.log("zy: can't define %s" % exp)
                        if param.endswith("moPrMappingList:spidLast"):
                            modify = self._adapt_param_value("%s=" % param, user_params, entry)
                            params_to_modify.extend(modify)
                        # it is required that ${CATMPR-1.catMVoLTETab-1.qci1ProtectionTimerCatM} (value: 40s) \
                        # greater than ${CATMPR-1.inactivityTimerCatM} (value: 1000s)
                        if param.endswith("catMVoLTETab:qci1ProtectionTimerCatM") and compare == ">" \
                                and error.count("inactivityTimerCatM"):
                            modify = self._adapt_param_value("%s=%s" % (
                                param, self.params_definition["CATMPR/qci1ProtectionTimerCatM"]["max"]),
                                                             user_params, entry)
                            params_to_modify.extend(modify)
                            modify = "%s:inactivityTimerCatM=%s" \
                                     % (param.split(":")[0],
                                        int(self.params_definition["CATMPR/qci1ProtectionTimerCatM"]["max"]) - 1)
                            builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                            params_to_modify.append(modify)
                else:
                    builtin_obj.log("zy: %s specified in case, can't be modified" % find_param)
                    # modify pre-conditions
                    if param.endswith("actIfHo") and target_value == "enabled" and error.count("threshold2aHpue"):
                        modify = self._adapt_param_value("NRCELL:threshold2aHpue=", user_params, entry)
                        params_to_modify.extend(modify)
                    elif param.endswith("actConvVoice") and target_value == "true":
                        if error.count("n310Qci1"):
                            modify = self._adapt_param_value("NRCELL:n310Qci1=", user_params, entry)
                            params_to_modify.extend(modify)
                        elif error.count("t310Qci1"):
                            modify = self._adapt_param_value("NRCELL:t310Qci1=", user_params, entry)
                            params_to_modify.extend(modify)
                    elif param.endswith("a2TimeToTriggerActInterFreqMeas") and len(compare) == 0:
                        modify = self._adapt_param_value("NRBTS.actIfHo=disabled", user_params, entry)
                        params_to_modify.extend(modify)
                    elif param.endswith("actHOtoWcdma") and target_value == "true" \
                            and error.count("actCsfbPsHoToUtra"):
                        modify = self._adapt_param_value("NRBTS.actCsfbPsHoToUtra=false", user_params, entry)
                        params_to_modify.extend(modify)
                    elif param.endswith("NRBTS_FDD-0:actSrvccToWcdma") \
                            and target_value == "false" and error.count("actHOtoWcdma"):
                        modify = self._adapt_param_value("NRBTS:actHOtoWcdma=true", user_params, entry)
                        params_to_modify.extend(modify)
                    elif param.endswith("actEnhAcAndGbrServices") \
                            and target_value == "true" and error.count("actMultGbrBearers"):
                        modify = self._adapt_param_value("NRBTS:actMultGbrBearers=false", user_params, entry)
                        params_to_modify.extend(modify)

                    # mandatory change the required
                    # Whenever NRCELL-1 having ${NRCELL-1.cellTechnology} (value: TDD) equal to TDD, \
                    # it is required that ${LNRELW-1.utranLbAllowed} (value: true) equal to false
                    elif param.endswith("utranLbAllowed") and target_value == "false":
                        modify = "%s=%s" % (param, target_value)
                        builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                        params_to_modify.append(modify)
                    # It is required that ${NRBTS_TDD-0.actHOtoTdscdma} (value: true) equal to false
                    elif param.endswith("NRBTS_TDD-0:actHOtoTdscdma") and target_value == "false":
                        modify = "%s=%s" % (param, target_value)
                        builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                        params_to_modify.append(modify)
                    # It is required that ${NRBTS_FDD-0.actFlexBbUsage} (value: true) is equal to false \
                    # if only SMOD is of type ASI or ASO
                    elif param.endswith(":actFlexBbUsage") and target_value == "false" \
                            and error.count("if only SMOD is of type ASI or ASO"):
                        modify = "%s=%s" % (param, target_value)
                        builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                        params_to_modify.append(modify)
                    # it is required that ${NRCELL_FDD-0.earfcnDL} (value: 4070) equal to \
                    # (${NRCELL_FDD-0.earfcnUL} (value: 21900) minus 18000)
                    elif param.endswith(":earfcnUL") and error.count("earfcnDL") and error.count("minus"):
                        modify = "%s=%s" % (param, target_value)
                        builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                        params_to_modify.append(modify)
                    # Whenever NRBTS-1 having ${NRBTS-1.actEmerCallRedir} (value: Enabled) equal to Enabled \
                    # and ${NRBTS-1.actCoC2kWcdmaGsmMob} (value: false) equal to false, \
                    # NRCELL-1 having ${NRCELL-1.cellTechnology} (value: FDD) is within range FDD|TDD, \
                    # REDRT-5 having ${REDRT-5.redirRat} (value: cdma2000HRPD) is \
                    # within range eutra|cdma20001xRTT|cdma2000HRPD, it is required that ${REDRT-5.emerCallPrio} \
                    # (value: 5) is not configured
                    elif param.endswith("csFallBPrio") and len(target_value) == 0 or param.endswith("emerCallPrio") \
                            and len(target_value) == 0:
                        builtin_obj.log("zy: remove %s, not care if it is defined by user or not" % param)
                        params_to_modify.append("%s=" % param)
                    # Whenever NRCELL-1 having embedded assertion valid (Namely: It is required that there exist MOs \
                    # NRCELL/NRCELL_FDD), CATMCEL-0 having ${CATMCEL-0.actConvVoiceCatM} (value: true) equal to true,\
                    # it is required that ${NRCELL_FDD-0.actCatM} (value: false) equal to true
                    elif param.endswith("actCatM") and target_value == "true" \
                            and error.count("actConvVoiceCatM} (value: true) equal to true"):
                        modify = "%s=%s" % (param, target_value)
                        builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                        params_to_modify.append(modify)

            return params_to_modify

    def _handle_one_require(self, each_require, user_params, entry):
        params_to_modify = []
        requires = each_require.split(" and ")
        for require in requires:
            builtin_obj.log("zy: handle %s" % require)
            # the set of MOs LNADJ-* ${LNADJ-1.cPlaneIpAddr} (value: 1.1.1.1) must be unique
            # the set of MOs LNADJW-* combination of parameters ${LNADJW-1.uTargetCid} \
            # (value: 1)+${LNADJW-1.uTargetRncId} (value: 1)+${LNADJW-1.primaryPlmnId-1.mcc} \
            # (value: 262)+${LNADJW-1.primaryPlmnId-1.mnc} (value: 3)+${LNADJW-1.primaryPlmnId-1.mncLength} \
            # (value: 2) must be unique
            # the set of MOs LNRELW-* combination of parameters ${LNRELW-1.plmnId-1.mcc} \
            # (value: 262)+${LNRELW-1.plmnId-1.mnc} (value: 3)+${LNRELW-1.plmnId-1.mncLength} \
            # (value: 2)+${LNRELW-1.uTargetRncId} (value: 1)+${LNRELW-1.uTargetCid} (value: 1) must be unique
            # the set of MOs LNHENB-* ${LNHENB-1.freqEutra} (value: 1700) must be unique
            match = re.search(r"the set of MOs.*\${([a-z]+-1)\S+}.*must be unique", require, re.I)
            if match is not None:
                param = "${%s}" % match.group(1)
                modify = self._adapt_param_value("%s=" % (param), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # the set of MOs REDRT-* ${REDRT-4.csFallBPrio} (value: 4) must be unique
            match = re.search(r"the set of MOs REDRT-\* (\${REDRT-\d+.*Prio}) \(value: \d+\) must be unique",
                              require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value("%s=" % (param), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # the set of MOs CAPR-* ${CAPR-3.earfcnDL} (value: 3000) must be unique
            match = re.search(r"the set of MOs CAPR-\* (\${CAPR-\d+.earfcnDL}) \(value: (\d+)\) must be unique",
                              require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(2)
                modify = self._adapt_param_value("%s=%s" % (param, int(value) + 1), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that ${NRCELL-2.loadSettings} (list of 0 items) is configured
            match = re.search(r"^(\S+)\s*\(list of 0 items\) is configured", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value(param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # NRCELL-3.furtherPlmnIdL(list of 0 items).acbFurtherPlmnProfileIdCatM is configured
            match = re.search(r"^(\S+)\s*\(list of 0 items\)(\.\S+) is configured", require, re.I)
            if match is not None:
                param = match.group(1) + ":" + match.group(2)[1:]
                modify = self._adapt_param_value(param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # ${NRCELL-1.threshold2a} (value: -51dBm) is configured
            match = re.search(r".*\s*\(value:.*\) is configured$", require, re.I)
            if match is not None:
                continue

            # it is required that ${NRCELL-4.dlCaMinPcellCqiQci1} (undefined) is configured
            # it is required that ${NRCELL-1.furtherPlmnIdL-1.acbFurtherPlmnProfileIdCatM}(undefined) is configured
            match = re.search(r"^(\S+)\(undefined\) is configured", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value(param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # It is required that PMCADM.rTPmCollEntity is configured
            match = re.search(r"^(\S+\.\S+)\s* is configured", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value(param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that ${CAREL-1.beamformingInScellAllowed} (value: allowed) is not configured
            match = re.search(r"^(\S+)\s*\(value:\s*\S+\) is not configured", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value("%s=" % param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that ${NRCELL_FDD-0.csiRsConfigInfo} (list of 1 items) is not configured
            match = re.search(r"^(\S+)\s*\(list of \d+ items\) is not configured", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value("%s=" % param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that there not exist MOs MRBTS-1/NRBTS-1/CATMPR-1.catMCELevel1-1
            match = re.search(r"there not exist MOs (\S+\.\S+)", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value("%s=" % param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that there exist MOs MRBTS-1/NRBTS-1/NRCELL-3/BBPOOLALLOC
            match = re.search(r"^there exist MOs (\S+)", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value(param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that NRCELL-1.drxProfile104-1.drxOnDuratT (value: 6) greater/equal to 10
            match = re.search(r"^(\S+)\s*\(value: (\d+)\D*\) greater/equal to (\d+)\D*\)*$", require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(3).strip()
                modify = self._adapt_param_value("%s>=%s" % (param, value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # ${NRCELL_TDD-0.maxNumActUE} (value: 535) is less or equal to 400
            match = re.search(r"^(\S+)\s*\(value: (\d+)\D*\) (is less or |less/)equal to (\d+)\D*\)*$", require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(4).strip()
                modify = self._adapt_param_value("%s<=%s" % (param, value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that ${MPUCCH_TDD-0.nPucchF3Prbs} (value: 0) greater than 0
            match = re.search(r"^(\S+)\s*\(value: (\d+)\D*\) greater than (\d+)", require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(3).strip()
                modify = self._adapt_param_value("%s>%s" % (param, value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # MTRACE.immedMDTControl.iFMDTPercentage greater than 0
            match = re.search(r"^(\S+)\s* greater than (\d+)", require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(2).strip()
                modify = self._adapt_param_value("%s>%s" % (param, value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            match = re.search(r"^(\S+)\s*\(value: (\d+)\D*\) less than (\d+)", require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(3).strip()
                modify = self._adapt_param_value("%s<%s" % (param, value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that ${MPUCCH_TDD-0.maxNumRrc} (value: 55) greater/equal to ${NRCELL_TDD-0.maxNumActUE} \
            # (value: 535)
            match = re.search(r"^(\S+)\s*\(value: (\S+)\) greater/equal to (\S+)\s*\(value: (\S+)\)\)*$",
                              require, re.I)
            if match is not None:
                param1 = match.group(1)
                param1_value = match.group(2).strip()
                param2 = match.group(3)
                param2_value = match.group(4).strip()
                modify = self._adapt_param_value("%s>=%s" % (param1, param2_value), user_params, entry)
                if len(modify) == 0:
                    modify = self._adapt_param_value("%s<=%s" % (param2, param1_value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # ${MPUCCH_TDD-0.minNumRrc} (value: 10) less/equal to ${NRCELL_TDD-0.maxNumActUE} (value: 2)
            match = re.search(r"^(\S+)\s*\(value: (\S+)\) less/equal to (\S+)\s*\(value: (\S+)\)\)*$", require, re.I)
            if match is not None:
                param1 = match.group(1)
                param1_value = match.group(2).strip()
                param2 = match.group(3)
                param2_value = match.group(4).strip()
                modify = self._adapt_param_value("%s<=%s" % (param1, param2_value), user_params, entry)
                if len(modify) == 0:
                    modify = self._adapt_param_value("%s>=%s" % (param2, param1_value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # ${MPUCCH_TDD-0.minNumRrc} (value: 10) is equal to ${NRCELL_TDD-0.maxNumActUE} (value: 2)
            match = re.search(r"^(\S+)\s*\(value: (\S+)\)( is|) equal to (\S+)\s*\(value: (\S+)\)\)*$", require, re.I)
            if match is not None:
                param1 = match.group(1)
                param1_value = match.group(2).strip()
                param2 = match.group(4)
                param2_value = match.group(5).strip()
                modify = self._adapt_param_value("%s=%s" % (param1, param2_value), user_params, entry)
                if len(modify) == 0:
                    modify = self._adapt_param_value("%s=%s" % (param2, param1_value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that ${CATMPR-1.catMVoLTETab-1.qci1ProtectionTimerCatM} (value: 40s) greater than \
            # ${CATMPR-1.inactivityTimerCatM} (value: 170s)
            match = re.search(r"^(\S+)\s*\(value: (\S+)\) greater than (\S+)\s*\(value: (\S+)\)\)*$", require, re.I)
            if match is not None:
                param1 = match.group(1)
                param1_value = match.group(2).strip()
                param2 = match.group(3)
                param2_value = match.group(4).strip()
                modify = self._adapt_param_value("%s>%s" % (param1, param2_value), user_params, entry)
                if len(modify) == 0:
                    modify = self._adapt_param_value("%s<%s" % (param2, param1_value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that ${NRCELL-1.t301Guard} (value: 1990ms) less than ${SIB-0.t301} (value: 400ms)
            match = re.search(r"^(\S+)\s*\(value: (\S+)\) less than (\S+)\s*\(value: (\S+)\)\)*$", require, re.I)
            if match is not None:
                param1 = match.group(1)
                param1_value = match.group(2).strip()
                param2 = match.group(3)
                param2_value = match.group(4).strip()
                modify = self._adapt_param_value("%s<%s" % (param1, param2_value), user_params, entry)
                if len(modify) == 0:
                    modify = self._adapt_param_value("%s>%s" % (param2, param1_value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # ${NRCELL_FDD-0.earfcnDL} (value: 1500) greater/equal to \
            # (${NRCELL_FDD-0.earfcnUL} (value: 19400) minus 18000)
            match = re.search(r"^(\S+)\s*\(value: (\d+)\D*\) greater/equal to "
                              r"(\S+)\s*\(value: (\d+)\D*\) minus (\d+)\)*$", require, re.I)
            if match is not None:
                param1 = match.group(1)
                param1_value = match.group(2).strip()
                param2 = match.group(3)
                param2_value = match.group(4).strip()
                minus_value = match.group(5).strip()
                modify = self._adapt_param_value("%s>=%s" % (param1, int(param2_value) - int(minus_value)),
                                                 user_params, entry)
                if len(modify) == 0:
                    modify = self._adapt_param_value("%s<=%s" % (param2, int(param1_value) + int(minus_value)),
                                                     user_params, entry)
                params_to_modify.extend(modify)
                continue

            match = re.search(r"^(\S+)\s*\(value: (\d+)\D*\) less/equal to "
                              r"(\S+)\s*\(value: (\d+)\D*\) minus (\d+)\)*$", require, re.I)
            if match is not None:
                param1 = match.group(1)
                param1_value = match.group(2).strip()
                param2 = match.group(3)
                param2_value = match.group(4).strip()
                minus_value = match.group(5).strip()
                modify = self._adapt_param_value("%s<=%s" % (param1, int(param2_value) - int(minus_value)),
                                                 user_params, entry)
                if len(modify) == 0:
                    modify = self._adapt_param_value("%s>=%s" % (param2, int(param1_value) + int(minus_value)),
                                                     user_params, entry)
                params_to_modify.extend(modify)
                continue

            match = re.search(r"^(\S+)\s*\(value: (\d+)\D*\) equal to (\S+)\s*\(value: (\d+)\D*\) minus (\d+)\)*$",
                              require, re.I)
            if match is not None:
                param1 = match.group(1)
                param1_value = match.group(2).strip()
                param2 = match.group(3)
                param2_value = match.group(4).strip()
                minus_value = match.group(5).strip()
                modify = self._adapt_param_value("%s=%s" % (param1, int(param2_value) - int(minus_value)),
                                                 user_params, entry)
                if len(modify) == 0:
                    modify = self._adapt_param_value("%s=%s" % (param2, int(param1_value) + int(minus_value)),
                                                     user_params, entry)
                params_to_modify.extend(modify)
                continue

            # ${CATMCEL-0.actConvVoiceCatM} (value: true) equal to true
            # it is required that ${NRCELL_FDD-0.actCatM} (value: false) equal to true
            # it is required that ${NRBTS-1.qciTab5-1.schedulType} (value: SIGNALLING) equal to NON-GBR
            # ${NRCELL_TDD-0.maxNumActUE} (value: 535) is equal to 400
            # ${NRBTS_FDD-0.actFlexBbUsage} (value: true) is equal to false if only SMOD is of type ASI
            match = re.search(r"^(\S+)\s*\(value: (\S+)\)( is|) equal to (\S+)", require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(4).strip()
                if match.group(2) != match.group(4):
                    modify = self._adapt_param_value("%s=%s" % (param, value), user_params, entry)
                    params_to_modify.extend(modify)
                continue

            # SIB.siWindowLen equal to ${SIB-0.siWindowLen} (value: 20ms))
            match = re.search(r"SIB.siWindowLen equal to \${SIB-0.siWindowLen} \(value: (\S+)\)", require, re.I)
            if match is not None:
                value = match.group(1)
                modify = self._adapt_param_value("SIB-0:siWindowLen=%s" % (value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # It is required that NRCELL_FDD.actAutoPucchAlloc equal to true
            match = re.search(r"^(\S+)( is|) equal to (true|false|enabled|disabled)", require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(3).strip()
                modify = self._adapt_param_value("%s=%s" % (param, value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # ${NRCELL_FDD-0.maxNumUeUl} (value: 14) is within range between 1 and 7
            match = re.search(r"^(\S+)\s*\(value: .*\) is within range between (\d+)", require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(2).strip()
                modify = self._adapt_param_value("%s=%s" % (param, value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # not equal to floor(${NRCELL-1.idleLBCellReSelPrio3CC}
            match = re.search(r"not equal to floor\s*(\S+)", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value("%s=" % (param), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # floor(IRFIM.idleLBEutCelResPrio2CC) not equal to
            match = re.search(r"floor(\S+) not equal to", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value("%s=" % (param), user_params, entry)
                params_to_modify.extend(modify)
                continue
            # NRCELL_TDD.actAutoPucchAlloc equal to NRCELL_TDD.actAutoPucchAlloc
            match = re.search(r"(NRCELL_[FT]DD.actAutoPucchAlloc) equal to NRCELL_[FT]DD.actAutoPucchAlloc",
                              require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value("%s=true" % param, user_params, entry)
                if len(modify) == 0:
                    modify = self._adapt_param_value("%s=false" % param, user_params, entry)
                params_to_modify.extend(modify)
                continue

        return params_to_modify

    def _try_to_fix_relation_error(self, scf, errors, user_params):
        params_try_to_fix = []
        self.scf_to_fix = scf
        user_params = self._extend_parameters(user_params, scf)
        user_params = self._convert_delete(user_params)
        for entry in errors:
            builtin_obj.log("zy: %s" % entry['feedback'])
            # Whenever NRCELL_TDD-0 having NRCELL_TDD-0.actAutoPucchAlloc (value: false) equal to false, \
            # it is required that parameter maxNumRrc is equal to maxNumActUE + minNumRrcNoDrb
            # Whenever NRCELL_FDD-0 having ${NRCELL_FDD-0.actAutoPucchAlloc} (value: false) equal to false, \
            # MPUCCH_FDD-0 having ${MPUCCH_FDD-0.riEnable} (value: true) equal to true and ${MPUCCH_FDD-0.riPerM} \
            # (value: 2) not equal to 1, it is required that ${NRCELL-1.actDrx} (value: true) equal to false
            match = re.search(r"having (\S*actAutoPucchAlloc}?)\s+\(value: false\) equal to false", entry['feedback'],
                              re.I)
            if match is not None:
                param = match.group(1)
                params_to_modify = self._adapt_param_value("%s=true" % param, user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                if len(params_to_modify):
                    continue

            # Whenever NRCELL_TDD-0 having ${NRCELL_TDD-0.twoLayerMimoAvSpectralEff} \
            # (value: 0.5(bit/s)/Hz) is configured, \
            # it is required that ${NRCELL_TDD-0.dlMimoMode} (value: Single Stream Beamforming) is \
            # within range Dynamic Open Loop MIMO|Closed Loop Mimo|Closed Loop MIMO (4x2)|\
            # Closed Loop MIMO (8x2)|Closed Loop MIMO (4x4)|Closed Loop MIMO (8x4)|Dual Stream Beamforming
            match = re.search(r"having (\S+) \(value: \S+\) is configured, it is required that .*\.dlMimoMode",
                              entry['feedback'], re.I)
            if match is not None:
                param = match.group(1)
                params_to_modify = self._adapt_param_value("%s=" % param, user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever for each NRCELL.furtherPlmnIdL, NRCELL.furtherPlmnIdL.acbFurtherPlmnProfileId is configured, \
            # it is required that there exist MOs NRCELL.furtherPlmnIdL
            match = re.search(r"Whenever for each NRCELL\S+, (\S+) is configured, it is required that there exist",
                              entry['feedback'], re.I)
            if match is not None:
                param = match.group(1)
                params_to_modify = self._adapt_param_value(param, user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever CRGPR-1 having ${CRGPR-1.plmnGroupList} (list of 2 items) is configured, it is required that \
            # embedded assertion valid (Namely: Whenever for each CRGPR.plmnGroupList,\
            # CRGPR.plmnGroupList.mcc equal to\
            # ${NRBTS-1.mcc} (value: 244) and CRGPR.plmnGroupList.mnc equal to ${NRBTS-1.mnc} (value: 9) and \
            # CRGPR.plmnGroupList.mncLength equal to ${NRBTS-1.mncLength} (value: 2), it is required that \
            # there exist MOs CRGPR.plmnGroupList)
            match = re.search(r"Whenever CRGPR-(\d+) having.* Whenever for each CRGPR.plmnGroupList, "
                              r"CRGPR.plmnGroupList.mcc equal to \${NRBTS-1.mcc} \(value: (\d+)\) "
                              r"and CRGPR.plmnGroupList.mnc equal to \${NRBTS-1.mnc} \(value: (\d+)\) "
                              r"and CRGPR.plmnGroupList.mncLength equal to \${NRBTS-1.mncLength} \(value: (\d+)\), "
                              r"it is required that there exist MOs CRGPR.plmnGroupList",
                              entry['feedback'], re.I)
            if match is not None:
                CRGPR_id = match.group(1)
                mcc = match.group(2)
                mnc = match.group(3)
                mncLength = match.group(4)
                if not self._find_param("plmnGroupList:mcc", user_params)[0] \
                        and not self._find_param("plmnGroupList:mnc", user_params)[0] \
                        and not self._find_param("plmnGroupList:mncLength", user_params)[0]:
                    builtin_obj.log("zy: define CRGPR-%s:plmnGroupList:mnc=%s|mcc=%s" % (CRGPR_id, mnc, mcc))
                    builtin_obj.log("zy: define CRGPR-%s:plmnGroupList:mncLength=%s|mcc=%s"
                                    % (CRGPR_id, mncLength, mcc))
                    builtin_obj.log("zy: define CRGPR-%s:plmnGroupList:groupId=0|mcc=%s" % (CRGPR_id, mcc))
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:mnc=%s|mcc=%s" % (CRGPR_id, mnc, mcc))
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:mncLength=%s|mcc=%s" % (CRGPR_id, mncLength, mcc))
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:groupId=0|mcc=%s" % (CRGPR_id, mcc))
                    builtin_obj.log("zy: define CRGPR-%s:plmnGroupList:mnc=3|mcc=262" % CRGPR_id)
                    builtin_obj.log("zy: define CRGPR-%s:plmnGroupList:mncLength=2|mcc=262" % CRGPR_id)
                    builtin_obj.log("zy: define CRGPR-%s:plmnGroupList:groupId=1|mcc=262" % CRGPR_id)
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:mnc=3|mcc=262" % CRGPR_id)
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:mncLength=2|mcc=262" % CRGPR_id)
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:groupId=1|mcc=262" % CRGPR_id)
                continue

            # It is required that there exist MOs NRCELL/IAFIM) or ${NRBTS-1.actCsgS1Mobility} (value: true)
            match = re.search(r"It is required that there exist MOs NRCELL/IAFIM", entry['feedback'], re.I)
            if match is not None:
                params_to_modify = self._adapt_param_value("NRCELL/IAFIM-1", user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            match = re.search(r"MBSFN_FDD-\* having MBSFN_FDD.mbsfnAreaId equal to "
                              r"\${MBSFNCEL-0.mbsfnAreaInUseList-1} "
                              r"\(value: (\d+)\), it is required that there exist MOs MBSFNSYNCAREA_FDD/MBSFN_FDD",
                              entry['feedback'], re.I)
            if match is not None:
                param = "MBSFNSYNCAREA_FDD/MBSFN_FDD-%s" % match.group(1)
                params_to_modify = self._adapt_param_value("%s:mbsfnAreaId=%s" % (param, match.group(1)),
                                                           user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever for each NRDCDPR.nrDcMeasConfig, it is required that there exist MOs NRDCDPR.nrDcMeasConfig
            # Whenever for each NRDCDPR.nrDcQuantityConfig, it is required that \
            # there exist MOs NRDCDPR.nrDcQuantityConfig
            match = re.search(r"Whenever for each (\S+), it is required that there exist MOs (\S+)",
                              entry['feedback'], re.I)
            if match is not None:
                if match.group(1) == match.group(2).rstrip(")"):
                    param = match.group(1)
                    params_to_modify = self._adapt_param_value(param, user_params, entry)
                    params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever NRCELL-* having NRCELL.lcrId equal to ${CAREL-1.lcrId} (value: 2), it is required that
            # NRCELL.caPoolId equal to ${NRCELL-1.caPoolId} (value: 1))
            match = re.search(r"Whenever NRCELL-\* having NRCELL.lcrId equal to \${CAREL-\d+.lcrId} \(value: (\d)+\), "
                              r"it is required that NRCELL.caPoolId equal to \${NRCELL-1.caPoolId} \(value: 1\)",
                              entry['feedback'], re.I)
            if match is not None:
                params_to_modify = self._adapt_param_value("NRCELL-%s:caPoolId=1" % match.group(1), user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # it is required that quantity of NRCELL_TDD.srsDlMimoModeDepConf equal to 2
            match = re.search(r"quantity of NRCELL_TDD.srsDlMimoModeDepConf equal to 2", entry['feedback'], re.I)
            if match is not None:
                builtin_obj.log("zy: define two items in NRCELL/NRCELL_TDD:srsDlMimoModeDepConf, \
                not care if it is defined by user or not")
                params_try_to_fix.append(
                    "NRCELL/NRCELL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=nonBeamforming")
                params_try_to_fix.append(
                    "NRCELL/NRCELL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=beamforming")
                continue

            # it is required that quantity of NRCELL_TDD.srsDlMimoModeDepConf equal to 1 and \
            # ${NRCELL_TDD-0.srsDlMimoModeDepConf-1.beamformingType} (value: beamforming) equal to nonBeamforming
            match = re.search(r"quantity of NRCELL_TDD.srsDlMimoModeDepConf equal to 1 and "
                              r"(\S+.srsDlMimoModeDepConf-\d+.beamformingType}) \(value: \S+\) equal to (\S+)",
                              entry['feedback'], re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(2)
                param_to_modify = "NRCELL/NRCELL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=%s" \
                                  % value
                builtin_obj.log("zy: define %s, not care if it is defined by user or not" % param_to_modify)
                params_try_to_fix.append(param_to_modify)
                continue

            # It is required that FEATLADM.actTacPreemption is configured and FEATLADM.actTacPreemption equal to false)
            match = re.search(r"is required that (\S+) is configured and (\S+)( is|) equal to (\S+)",
                              entry['feedback'], re.I)
            if match is not None:
                if match.group(1) == match.group(2):
                    param = match.group(1)
                    value = match.group(4).rstrip(")")
                    params_to_modify = self._adapt_param_value("%s=%s" % (param, value), user_params, entry)
                    params_try_to_fix.extend(params_to_modify)
                    continue

            # it is required that maxNumScells in at least one PCell, where cellTechnology is FDD, \
            # must be grater or equal to 3
            match = re.search(r"it is required that maxNumScells in at least one PCell, "
                              r"where cellTechnology is FDD, must be (grater|greater) or equal to (\d+)",
                              entry['feedback'], re.I)
            if match is not None:
                params_to_modify = self._adapt_param_value("NRCELL:maxNumScells=%s"
                                                           % match.group(2), user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever CATMPR-* having CATMPR.catMPrId equal to ${NRCELL_FDD-0.catMProfId}(undefined), \
            # it is required that there exist MOs NRBTS/CATMPR
            match = re.search(r"Whenever CATMPR-\* having CATMPR.catMPrId equal to "
                              r"(\${NRCELL_FDD-0.catMProfId})\(undefined\), "
                              r"it is required that there exist MOs NRBTS/CATMPR",
                              entry['feedback'], re.I)
            if match is not None:
                param = match.group(1)
                params_to_modify = self._adapt_param_value(param, user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever ACBPR-* having ACBPR.acbPrId equal to ${NRCELL-1.acbPrimaryPlmnProfileId} (value: 0) \
            # and ACBPR.acBarMMTelVoiceOcStatic is configured, it is required that
            # ACBPR.acBarMMTelVoiceOcAutoMin is configured
            # Whenever ACBPR-* having ACBPR.acbPrId equal to ${NRCELL-1.acbPrimaryPlmnProfileId} (value: 0) and \
            # ACBPR.acBarMMTelVoiceOcStatic is configured, it is required that
            # ACBPR.acBarMMTelVoiceOcAutoMax is configured
            match = re.search(r"Whenever ACBPR-\* having ACBPR.acbPrId equal to \S+ \(value: (\d+)\) and "
                              r"ACBPR.acBarMMTelVoiceOcStatic is configured, it is required that "
                              r"ACBPR.(acBarMMTelVoiceOcAutoMin|acBarMMTelVoiceOcAutoMax) is configured",
                              entry['feedback'], re.I)
            if match is not None:
                param_to_modify = "ACBPR-%s:%s" % (match.group(1), match.group(2))
                builtin_obj.log("zy: define %s, not care if it is defined by user or not" % param_to_modify)
                params_try_to_fix.append(param_to_modify)
                continue

            # check last require
            # Whenever MTRACE-1 having ${MTRACE-1.iFMDTList} (list of 1 items) is configured, \
            # for each MTRACE.immedMDTControl, MTRACE.immedMDTControl.iFMDTPercentage greater than 0 or \
            # MTRACE.immedMDTControl.maxMDTFreqLayers greater than 1, it is required that \
            # there exist MOs MRBTS-1/NRBTS-1/CTRLTS-1/MTRACE-1.immedMDTControl
            match = re.search(r"for each \S+\.\S+, (.*), it is required that there exist MOs \S+\.\S+",
                              entry['feedback'], re.I)
            if match is not None:
                last_require = match.group(1)
            else:
                last_require = re.split('[Ii]t is required that', entry['feedback'].split(
                    "if having embedded assertion valid")[0])[-1].strip()

            require_ors = last_require.replace("is less or equal", "less/equal").split(" or ")
            for each_require in require_ors:
                params_to_modify = self._handle_one_require(each_require, user_params, entry)
                if len(params_to_modify):
                    params_try_to_fix.extend(params_to_modify)
                    break

        params_try_to_fix = list(set(params_try_to_fix))
        params_try_to_fix = comm_obj.remove_empty_from_list(params_try_to_fix)
        random.shuffle(params_try_to_fix)
        self.params_fixed_all.extend(params_try_to_fix)
        if len(params_try_to_fix):
            builtin_obj.log("zy: params to fix=%s, length=%s" % (params_try_to_fix, len(params_try_to_fix)))
            self._update_scf(scf, params_try_to_fix)
        return len(params_try_to_fix)

    def _fix_relation_error(self, user_params):
        # 1. fail new cases if there are any new validation errors
        new_case_path = ["rework", "new_feature"]
        suite_path = builtin_obj.get_variable_value("${SUITE_SOURCE}")
        for path in new_case_path:
            if suite_path.count(path):
                result = self.admin_obj.validate_scf(self.scf_for_startup,
                                                     skip_parameter_relation_errors=True, alias=self.alias)
                errors = result['pdlValidationResult']['logs']['relationErrors']
                errors = errors + result['pdlValidationResult']['logs']['hardwareErrors']
                for entry in errors:
                    builtin_obj.log("zy: %s" % entry['feedback'])
                if len(errors) > self.init_relation_errors_num:
                    raise Exception("new cases are not allowed to involve more validation errors,"
                                    "initial scf has %s errors, but scf_for_startup.xml has %s errors, pls fix them"
                                    % (self.init_relation_errors_num, len(errors)))
                break
        # 2. auto fix works if AUTO_FIX_VALIDATION_ERRORS=True and suite is in auto_fix_path
        auto_fix_flag = builtin_obj.get_variable_value("${AUTO_FIX_VALIDATION_ERRORS}")
        #         auto_fix_path_flag = False
        #         auto_fix_path = ["/CIT/", "/CRT/Regression_iPHY_AS/", "/Regression_iPHY_AS_FDD_9CELL/"]
        #
        #         for path in auto_fix_path:
        #             if suite_path.count(path):
        #                 auto_fix_path_flag = True
        #                 break
        #         if auto_fix_flag is not True or auto_fix_path_flag is not True:
        #             return
        if auto_fix_flag is not True:
            return

        # 3. if suite in auto_fix_path_fail, it will fail if auto-fix function can't fix all errors
        auto_fix_path_fail = []
        auto_fix_fail = False
        for path in auto_fix_path_fail:
            if suite_path.count(path):
                auto_fix_fail = True
                break

                # start to auto-fix validaiton errors
        builtin_obj.log("step: trying to fix validation errors")
        self.params_fixed_all = []
        max_retry_times = 5
        fixed = False
        os_obj.copy_file(self.scf_for_startup, "%s/scf_for_startup_fixing_errors_0.xml"
                         % (self.full_commission_log_dir + "/scfc_logs"))
        for time in range(0, max_retry_times):
            old_file = "%s/scf_for_startup_fixing_errors_%s.xml" \
                       % ((self.full_commission_log_dir + "/scfc_logs"), time)
            new_file = "%s/scf_for_startup_fixing_errors_%s.xml" \
                       % ((self.full_commission_log_dir + "/scfc_logs"), time + 1)
            try:
                result = self.admin_obj.validate_scf(old_file, skip_parameter_relation_errors=True, alias=self.alias)
            except Exception:
                detail = traceback.format_exc()
                comm_obj.log_to_console_with_time_prefix("fail to fix relation error, "
                                                         "contact I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com: %s"
                                                         % detail, "WARN")
                break
            if result['pdlValidationResult']['status'] == "FAIL":
                errors = result['pdlValidationResult']['logs']['relationErrors'] + \
                         result['pdlValidationResult']['logs']['hardwareErrors']
                if time == 0:
                    comm_obj.log_to_console_with_time_prefix("there are %s validation errors in scf_for_startup.xml, \
                    try to auto-fix them" % len(errors), "WARN")
                else:
                    comm_obj.log_to_console_with_time_prefix("there are still %s validation errors after auto-fixing,\
                    try again" % len(errors), "WARN")
                os_obj.copy_file(old_file, new_file)
                try:
                    fix_number = self._try_to_fix_relation_error(new_file, errors, user_params)
                    if fix_number == 0:
                        comm_obj.log_to_console_with_time_prefix("no validation errors could be auto-fixed any longer,\
                        stop auto-fixing", "WARN")
                        break
                except Exception:
                    detail = traceback.format_exc()
                    comm_obj.log_to_console_with_time_prefix("fail to fix relation error, "
                                                             "contact I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com: %s"
                                                             % detail, "WARN")
                    break
            else:
                fixed = True
                if time == 0:
                    builtin_obj.log("zy: no PDL relation errors")
                else:
                    comm_obj.log_to_console_with_time_prefix("validation errors are auto-fixed", level="WARN")
                    os_obj.copy_file(old_file, self.scf_for_startup)
                break
        if fixed is False:
            if auto_fix_fail:
                raise Exception("there are still some validation errors, pls fix them, last scf is %s" % new_file)
            else:
                comm_obj.log_to_console_with_time_prefix("revert scf_for_startup.xml", level="WARN")

    def _ping_ok(self, ip):
        out = comm_obj.execute_cmd_on_pc("ping %s -c 2" % ip)
        if out.count("100% packet loss"):
            return False
        else:
            return True

    def _get_bts_info(self):
        self._setup_common()
        bts_port, use_ssl = comm_obj.define_admin_port()
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        try:
            info_obj = ute_admin_infomodel()
            ping_ok = self._ping_ok(self.bts_host)
            if ping_ok:
                info_obj.setup_infomodel(alias=self.alias, port=bts_port, use_ssl=use_ssl,
                                         admin_api_log_dir=save_log_dir + "/admin_logs", address=self.bts_host)
            else:
                info_obj.setup_infomodel(alias=self.alias, port=bts_port, use_ssl=use_ssl,
                                         admin_api_log_dir=save_log_dir + "/admin_logs", remote_host=self.remote_host,
                                         address="192.168.255.129")
            info_obj.connect_infomodel(alias=self.alias)
            # get positionInRack
            # for 1GNB, there is one //SMOD_L-1/CONCENTRATOR_L-1
            # for 2GNB, there are two //SMOD_L-1/CONCENTRATOR_L-1 in not-commissioned state, one in other state
            objs = info_obj.query_infomodel("get list //SMOD_L-1/CONCENTRATOR_L-1", alias=self.alias)
            if len(objs) == 1:
                if objs[0].positionInRack.lower().count("right"):
                    self.bts_info["position"] = "right"
                elif objs[0].positionInRack.lower().count("left"):
                    self.bts_info["position"] = "left"
                else:
                    self.bts_info["position"] = "wholeShelf"
            else:
                if self.alias == "gnb1":
                    self.bts_info["position"] = "left"
                else:
                    self.bts_info["position"] = "right"
            # get HW type
            objs = info_obj.query_infomodel("get list //INVUNIT_R-*", alias=self.alias)
            self.bts_info["bbmod_type"] = None
            for obj in objs:
                if obj.inventoryUnitType is not None:
                    unit_type = obj.inventoryUnitType.split()[0]
                    builtin_obj.log("unit_type is %s" % unit_type)
                    if unit_type.startswith("AS"):
                        self.bts_info["bbu_type"] = unit_type
                    if unit_type.startswith("Flexi"):
                        self.bts_info["bbu_type"] = "FSMF"
                    if unit_type.startswith("AB"):
                        self.bts_info["bbmod_type"] = unit_type
            # Get Product type
            self.bts_info["product_type"] = None
            tl = builtin_obj.get_variable_value("${tl}")
            self.bts_info["product_type"] = 'classical' if \
                tl.gnbs[0].cu.oam_ssh_connection_details.username == 'toor4nsn' else 'cloud'
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
            traceback.print_exc()
        finally:
            info_obj.disconnect_infomodel(alias=self.alias)
            info_obj.teardown_infomodel(alias=self.alias)

    def _get_rack_position(self):
        if self.bts_info == {}:
            self._get_bts_info()
        return self.bts_info["position"]

    def _get_bbmod_type(self):
        if self.bts_info == {}:
            self._get_bts_info()
        return self.bts_info["bbmod_type"]

    def _get_product_type(self):
        if self.bts_info == {}:
            self._get_bts_info()
        return self.bts_info["product_type"]

    def _get_bbu_type(self):
        self._setup_common()
        cmd = "cat /proc/device-tree/module-identity/unit-id"
        rrutype = self.execute_cmd_on_gnb(cmd)
        return re.compile('\x00').sub("", rrutype)

    def _get_gnb_fsp_types(self):
        # return gnb fsp boards type such as [u'ABIO', u'ABIL', None]
        self._setup_common()
        gnb_fsp_types = []
        for board_number in range(1, 4):
            cmd = "bsh {}:0 cat /proc/device-tree/module-identity/unit-id".format(board_number)
            try:
                ret = self.execute_cmd_on_gnb(cmd)
                board_type = re.compile('\x00').sub("", ret)
                gnb_fsp_types.append(board_type)
            except Exception:
                gnb_fsp_types.append("None")
        return gnb_fsp_types

    def _get_unique_mo_instance_id(self, parameters, mo_class):
        mo_ids = []
        for param in parameters:
            match = re.search(r"%s-(\d+)" % mo_class, param, re.I)
            if match is not None:
                mo_ids.append(match.group(1))
        mo_ids = list(set(mo_ids))  # remove duplicate value
        if len(mo_ids) > 1:
            # more than one instance id
            raise Exception("%s can't have more than one instance, but case gives %s" % (mo_class, mo_ids))
        elif len(mo_ids) == 1:
            # one instance id
            return mo_ids[0]
        else:
            # no such mo or use mo extension mode
            return "default"

    def _adapt_mrbts_nrbts_instance_id(self, scf_base, parameters, scf_target_dir):
        # get MRBTS,NRBTS instance id from scf_base
        mrbts_dn = xml_obj.read_xml(scf_base,
                                    "attrib=distName|//managedObject[matches(@class, '.*MRBTS$')]")
        mrbts_id_b = mrbts_dn.split("-")[-1]
        nrbts_dn = xml_obj.read_xml(scf_base,
                                    "attrib=distName|//managedObject[matches(@class, '.*NRBTS$')]")
        nrbts_id_b = nrbts_dn.split("-")[-1]

        # get MRBTS,NRBTS instance id from parameters
        mrbts_id_t = self._get_unique_mo_instance_id(parameters, "MRBTS")
        nrbts_id_t = self._get_unique_mo_instance_id(parameters, "NRBTS")

        # adapt MRBTS,NRBTS instance id
        new_scf_base = os.path.join(scf_target_dir, "SCFC_%s_%s.xml" % (mrbts_id_t, nrbts_id_t))
        os_obj.copy_file(scf_base, new_scf_base)
        change_flag = False
        if mrbts_id_t != "default" and mrbts_id_b != mrbts_id_t:
            comm_obj.execute_cmd_on_pc("sed -i 's:MRBTS-%s:MRBTS-%s:g' %s" % (mrbts_id_b, mrbts_id_t, new_scf_base))
            mrbts_id = mrbts_id_t
            change_flag = True
        else:
            mrbts_id = mrbts_id_b
        if nrbts_id_t != "default" and nrbts_id_b != nrbts_id_t:
            comm_obj.execute_cmd_on_pc("sed -i 's:NRBTS-%s:NRBTS-%s:g' %s" % (nrbts_id_b, nrbts_id_t, new_scf_base))
            # fix relation error for NRREL
            comm_xml_b = CommonXML(scf_base)
            NRREL_list = comm_xml_b.get_elements("//managedObject[matches(@class, '.*NRREL$')]/p[@name='gNbId']")
            if len(NRREL_list):
                xml_obj.modify_xml(new_scf_base,
                                   new_scf_base,
                                   "text|sub('^%s$', '%s')|"
                                   "//managedObject[matches(@class, '.*NRREL$')]/p[@name='gNbId']"
                                   % (nrbts_id_b, nrbts_id_t))

            nrbts_id = nrbts_id_t
            change_flag = True
        else:
            nrbts_id = nrbts_id_b
        if change_flag:
            builtin_obj.log("new base scf is %s" % new_scf_base, console=True)

        return new_scf_base, mrbts_id, nrbts_id

    def _set_pm_counters_interval(self, scf):
        exclude_intervals = ["ulUeThptMethod"]  # can't set to xxmin
        self._setup_scf_control()
        # this keyword works together with _change_swconfig
        # counter interval=interval in scf/value of 0x340000
        interval = builtin_obj.get_variable_value("${PM_COUNTER_INTERVAL}")
        if interval == "15min":
            scf_target_interval = "15min"
        else:  # 1min, 15min
            scf_target_interval = "5min"
        params_modified = []
        comm_xml_obj = CommonXML(scf)
        for element in comm_xml_obj.get_elements("//managedObject[matches(@class, '.*:NRPMRNL$')]/*"):
            # element like: <p name="miNrBeamforming">15min</p>
            name = comm_xml_obj.get_element_attribute(element, "name")
            text = comm_xml_obj.get_element_text(element)
            if name in exclude_intervals:
                continue
            if text != scf_target_interval:
                param_modified = "text|%s|//managedObject[matches(@class, '.*:NRPMRNL$')]/*[@name='%s']" % \
                                 (scf_target_interval, name)
                builtin_obj.log("zy:modify %s" % param_modified)
                params_modified.append(param_modified)
        if len(params_modified):
            xml_obj.modify_xml(scf, scf, params_modified)
            # fix relation errors related to pm counter interval
            params_modified_2 = []
            result = self.admin_obj.validate_scf(scf,
                                                 skip_parameter_relation_errors=True, alias=self.alias)
            errors = result['pdlValidationResult']['logs']['relationErrors']
            for entry in errors:
                builtin_obj.log("zy: %s" % entry['feedback'])
                # it is required that ${NRPMRNL-1.miNrInterGnbMobilityNsaPmqap} (value: 5min) equal to disabled
                match = re.search(r"it is required that \${NRPMRNL-1.(\S+)} \(value: \d+min\) equal to disabled",
                                  entry['feedback'], re.I)
                if match is not None:
                    param = match.group(1)
                    param_modified = "text|disabled|" \
                                     "//managedObject[matches(@class, '.*:NRPMRNL$')]/*[@name='%s']" % param
                    builtin_obj.log("zy:modify %s" % param_modified)
                    params_modified_2.append(param_modified)
                    continue
            xml_obj.modify_xml(scf, scf, params_modified_2)

    def _modify_scf(self, scf_base, parameters_in, scf_target):
        builtin_obj.log("base scf is %s" % scf_base, console=True)
        parameters_m = parameters_in.copy()
        self._setup_scf_control()
        scf_target_dir = os.path.dirname(scf_target)
        # modify scf_base
        new_scf_base, mrbts_id, nrbts_id = self._adapt_mrbts_nrbts_instance_id(scf_base, parameters_in, scf_target_dir)

        # migrate scf_base
        os_obj.copy_file(new_scf_base, scf_target)
        migrated_scf = self._scf_migration(scf_target)
        os_obj.move_file(migrated_scf, os.path.join(os.path.dirname(migrated_scf), "migrated_SCFC_1.xml"))

        # create 3 scf template
        # csamson : I dont want to have a scf template !!!
        os_obj.copy_file(scf_base, self.scf_template_svn)
        os_obj.copy_file(scf_base, self.scf_supplement)
        comm_obj.log_to_console_with_time_prefix("mrbts_id=%s and nrbts_id=%s" % (mrbts_id, nrbts_id),
                                                 level="INFO")
        self._generate_three_templates(mrbts_id, nrbts_id)

        # update vlanid
        vlan_id = builtin_obj.get_variable_value("${tl.gnbs[0].cu.x2c.vlan_id}", None)
        if vlan_id:
            comm_obj.log_to_console_with_time_prefix("vlan_id is %s " % vlan_id, level="INFO")
        if vlan_id is None:
            comm_obj.log_to_console_with_time_prefix("no vlan_id found", level="WARN")
            pass
        elif int(vlan_id) == 0:
            parameters_m.append("MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1:interfaceDN="
                                "MRBTS-%s/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1" % mrbts_id)
            parameters_m.append("delete:MRBTS/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1")
        else:
            parameters_m.append("MRBTS/TNLSVC-1/TNL-1/IPNO-1/IPIF-1:interfaceDN="
                                "MRBTS-%s/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1" % mrbts_id)
            parameters_m.append("MRBTS/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1:vlanId=%s" % vlan_id)

        # update scf according to required parameters
        self._update_scf(scf_target, parameters_m)

    def _modify_scf_and_perform_full_commission(self, scf_base, parameters):
        self.init_relation_errors_num = 0
        self._setup_scf_control()

        # update scf according to parameters.
        self._modify_scf(scf_base, parameters, self.scf_for_startup)
        self._fix_relation_error(parameters)
        self._set_pm_counters_interval(self.scf_for_startup)

        # update cmData attributes in scf startup
        plan_id = "3221225472"
        mrbts_dn = xml_obj.read_xml(self.scf_for_startup,
                                    "attrib=distName|//managedObject[matches(@class, '.*MRBTS$')]")
        bts_id = mrbts_dn.split("-")[-1]
        # update cmData
        xml_obj.modify_xml(self.scf_for_startup, self.scf_for_startup, "attrib=type|plan|//cmData")
        xml_obj.modify_xml(self.scf_for_startup, self.scf_for_startup, "attrib=id|%s|//cmData" % plan_id)
        xml_obj.modify_xml(self.scf_for_startup, self.scf_for_startup, "attrib=scope|all|//cmData")

        # call taf admin to perform full commissioning
        try:
            current_time = builtin_obj.get_time()
            comm_obj.log_to_console_with_time_prefix("step: perform full commissioning in %s with %s"
                                                     % (self.alias, self.scf_for_startup))
            result = self.admin_obj.perform_commissioning(bts_id, self.scf_for_startup,
                                                          skip_parameter_relation_errors=True,
                                                          alias=self.alias, timeout=600)
            if result['validationResult']['pdlValidationResult']['status'].lower() != 'ok':
                errors = result['validationResult']['pdlValidationResult']['logs']['relationErrors'] + \
                         result['validationResult']['pdlValidationResult']['logs']['hardwareErrors']
                for entry in errors:
                    builtin_obj.log("zy: %s" % entry['feedback'])
                comm_obj.log_to_console_with_time_prefix(
                    "there are %s validation errors during full commission, "
                    "pls fix them when develop new cases or before report PR" % len(errors),
                    level="WARN")
        except Exception as e:
            raise Exception(str(e))
        return self.scf_for_startup

    def _online_change_parameter(self, dist_name, parameter, value, operation):
        # call taf admin to perform parameter recommissioning
        try:
            current_time = builtin_obj.get_time()
            comm_obj.log_to_console_with_time_prefix("step: perform %s online recommission to %s under MO %s"
                                                     % (parameter, value, dist_name))
            self.admin_obj.perform_parameter_recommissioning(dist_name, parameter, operation, value,
                                                             skip_parameter_relation_errors=True, timeout=300,
                                                             alias=self.alias)
        except Exception as e:
            raise Exception(str(e))
        print('perform {} online recommission to {} successfully.'.format(parameter, value))

    def _combine_mos_element(self, mos_delta_1, mos_delta_2):
        # combine mo elment with same dn and operation
        mos_delta_combine = []
        for mo_1 in mos_delta_1:
            flag = False
            commonxml = CommonXML(mo_1)
            mo_1_dn = xml_obj.read_xml(mo_1, "attrib=distName|//managedObject")
            mo_1_operation = xml_obj.read_xml(mo_1, "attrib=operation|//managedObject")
            for mo_2 in mos_delta_2:
                mo_2_dn = xml_obj.read_xml(mo_2, "attrib=distName|//managedObject")
                mo_2_operation = xml_obj.read_xml(mo_2, "attrib=operation|//managedObject")
                if mo_1_dn == mo_2_dn and mo_1_operation == mo_2_operation:
                    flag = True
                    mo_1 = commonxml.parse_xml(mo_1)
                    childs = commonxml.get_child_elements(mo_1)
                    mo_2_add = mo_2
                    for child in childs:
                        child = commonxml.element_to_string(child)
                        mo_2_add = xml_obj.add_xml_element(mo_2_add, "", child + "|//managedObject")
                    mos_delta_combine.append(mo_2_add)
                    mos_delta_2.remove(mo_2)
                    break
            if flag is False:
                mos_delta_combine.append(mo_1)

        if len(mos_delta_2):
            mos_delta_combine.extend(mos_delta_2)

        return mos_delta_combine

    def _create_delta_file_based_on_mo_elements(self, active_scf, mos, commission_type):
        if len(mos) != 0:
            # get btsid
            commonxml = CommonXML(active_scf)
            mo_0 = commonxml.string_to_element(mos[0])
            dn = commonxml.get_element_attribute(mo_0, "distName")
            if "/" not in dn:
                btsid = dn.split("-")[-1]
            else:
                btsid = dn.split("/")[1].split("-")[-1]
            # create delta file with cmData
            save_log_directory = comm_obj._get_save_log_dir(self.alias)
            delta_file_with_path = os.path.join(save_log_directory,
                                                "delta_file_%s_%s.xml" % (btsid, comm_obj.get_timestamp()))
            raml = self._get_element_without_children(active_scf, "/raml")
            cmData = self._get_element_without_children(active_scf, "//cmData")
            delta_file_content = xml_obj.add_xml_element(raml, "", cmData + "|/raml")
            # add mo elements into delta file
            for mo in mos:
                delta_file_content = xml_obj.add_xml_element(delta_file_content, "", mo + "|//cmData")

            if commission_type == "admin":
                delta_file_content = xml_obj.modify_xml(delta_file_content, "", "attrib=id|3221225472|//cmData")
                commonxml.save_xml(delta_file_with_path, delta_file_content)
                convert_delta_xml_to_json(delta_file_with_path)
                delta_file_with_path = delta_file_with_path.replace(".xml", ".json")

            elif commission_type == "netact":
                delta_file_content = xml_obj.modify_xml(delta_file_content, "", "attrib=type|plan|//cmData")
                commonxml.save_xml(delta_file_with_path, delta_file_content)
            else:
                raise Exception("no support for commission type %s" % commission_type)

            if len(mos) < 100:
                builtin_obj.log("step: delta file is %s" % delta_file_with_path)
                file_object = open(delta_file_with_path)
                try:
                    delta_content = file_object.read()
                    builtin_obj.log("step: delta file content:%s" % delta_content)
                finally:
                    file_object.close()

            return delta_file_with_path

    def _create_delta_file(self, parameters, active_scf, commission_type="admin"):
        # delete related elements are in mos_delta_1, others mos in mos_delta_2
        delta_files = []
        mos_delta_2 = []
        mos_delta_1 = []
        one_file_flag = True

        parameters = self._extend_parameters(parameters, active_scf)
        params_classified = self._classify_parameters_according_to_moname(parameters)
        mo_list = list(params_classified.keys())
        mo_list.sort()
        for mo in mo_list:
            if mo == "delete":
                mo_deletes = self._delete_object_online(active_scf, params_classified["delete"])
                mos_delta_1.extend(mo_deletes)
            else:
                try:
                    mo_in_scf = xml_obj.read_xml(active_scf, "*|%s" % self._mo_xpath(mo))
                    # update parameters of mo
                    if mo.count("LTRACE") or mo.count("MTRACE"):
                        mo_delete_trace, mo_create_trace = self._update_trace(mo_in_scf, params_classified[mo])
                        mos_delta_1.append(mo_delete_trace)
                        mos_delta_2.append(mo_create_trace)
                        one_file_flag = False
                    else:
                        builtin_obj.log("zy_mo:update %s with %s" % (mo, params_classified[mo]))
                        params_to_update = self._remove_same_params_in_scf(active_scf, params_classified[mo])
                        builtin_obj.log(
                            "zy_mo:after remove same value as active scf, parameters need to update: %s"
                            % params_to_update)
                        if len(params_to_update) != 0:
                            mo_update = self._update_mo(mo_in_scf, params_to_update, active_scf)
                            mos_delta_2.append(mo_update)
                except AssertionError as err_info:
                    builtin_obj.log(err_info)
                    builtin_obj.log("zy_mo:no %s in %s, create it" % (mo, active_scf))
                    mo_create = self._create_mo(params_classified[mo])
                    mo_create = self._fix_mo_create_error(mo, active_scf, mo_create)
                    mos_delta_2.append(mo_create)

        # create delta file and do delta commission
        if one_file_flag:
            mos_delta_combine = self._combine_mos_element(mos_delta_1, mos_delta_2)
            delta_file = self._create_delta_file_based_on_mo_elements(active_scf, mos_delta_combine, commission_type)
            if delta_file is not None:
                delta_files.append(delta_file)
        else:
            delta_file_1 = self._create_delta_file_based_on_mo_elements(active_scf, mos_delta_1, commission_type)
            BuiltIn().sleep("1s")
            delta_file_2 = self._create_delta_file_based_on_mo_elements(active_scf, mos_delta_2, commission_type)
            delta_files.append(delta_file_1)
            delta_files.append(delta_file_2)
        return delta_files

    def _remove_same_params_in_scf(self, scf, parameters):
        out_parameters = []
        for param in parameters:
            # NRCELL:administrativeState sometimes not updated to SCFC, delta file will include it whenever \
            # it is same or not as active scfc
            if param.count("administrativeState"):
                out_parameters.append(param)
                continue

            if param.count("=") and param.count("|") == 0:
                param_name, param_value = param.split("=")
                param_name_xpath = comm_obj.match_to_xpath(param_name)[0]
                try:
                    param_value_in_scf = xml_obj.read_xml(scf, "text|%s" % param_name_xpath)
                    if param_value_in_scf != param_value:
                        out_parameters.append(param)
                except Exception:
                    out_parameters.append(param)
                finally:
                    pass
            else:
                out_parameters.append(param)
        return out_parameters

    def _remove_same_params_in_scf_bakup(self, scf, parameters):
        out_parameters = parameters
        # 1. format mo:key=value
        params_with_p = [param for param in parameters if
                         param.count(":") == 1 and param.count("=") and param.count(",") == 0]
        for param1 in params_with_p:
            param1_name, param1_value = param1.split("=")
            param1_name_xpath = comm_obj.match_to_xpath(param1_name)[0]
            try:
                param1_value_in_scf = xml_obj.read_xml(scf, "text|%s" % param1_name_xpath)
                if param1_value_in_scf == param1_value:
                    out_parameters.remove(param1)
            except Exception:
                pass
                # 2. format mo:list:key=value
        # list could be removed only when all parameters in the list have same value as in active scf
        params_with_normal_list = [param for param in parameters if
                                   param.count(":") == 2 and param.count("=") == 1 and param.count(",") == 0]
        params_classified = self._classify_parameters_according_to_list_dict(params_with_normal_list, 1)
        for list_name in params_classified.keys():
            same_flag = True
            for param2 in params_classified[list_name]:
                param2_name, param2_value = param2.split("=")
                param2_name_xpath = comm_obj.match_to_xpath(param2_name)[0]
                try:
                    param2_value_in_scf = xml_obj.read_xml(scf, "text|%s" % param2_name_xpath)
                    if param2_value_in_scf != param2_value:
                        same_flag = False
                        break
                except Exception:
                    pass
            if same_flag is True:
                for param3 in params_classified[list_name]:
                    out_parameters.remove(param3)
        return out_parameters

    def _judge_if_delta_commission_lteenb(self, parameters):
        flag = False
        parameters = comm_obj.remove_empty_from_list(parameters)
        for param in parameters:
            if re.search(r"LTEENB-\d+:", param):
                flag = True
                break
        return flag

    def _delta_commission_parameters(self, parameters, background=False):
        self._setup_scf_control()
        # get active scf
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        scf_with_timestamp = "scf_%s.xml" % comm_obj.get_timestamp()
        scf = os.path.join((save_log_dir + "/scfc_logs"), scf_with_timestamp)
        if self._judge_if_delta_commission_lteenb(parameters):
            export_type = "configurationAndRuntimeObjects"
        else:
            export_type = "configuration"
        self.admin_obj.get_current_scf_file(local_dir_path=(save_log_dir + "/scfc_logs"), file_name=scf_with_timestamp,
                                            connection=self.alias, export_type=export_type,
                                            timeout=20, with_auto_configured_parameters=True)
        builtin_obj.log("step: active scf is %s" % scf)
        # validate active scf
        builtin_obj.log("step: validate active scf %s" % scf)
        result1 = self.admin_obj.validate_scf(scf,
                                              skip_parameter_relation_errors=True, alias=self.alias)
        errors1 = result1['pdlValidationResult']['logs']['relationErrors']
        errors1 = errors1 + result1['pdlValidationResult']['logs']['hardwareErrors']
        for entry in errors1:
            builtin_obj.log("zy: %s" % entry['feedback'])

        # generate scf template
        if not os.path.exists(self.scf_template_full):
            # get bts id
            mrbts_dn = xml_obj.read_xml(scf,
                                        "attrib=distName|//managedObject[matches(@class, '.*MRBTS$')]")
            mrbts_id = mrbts_dn.split("-")[-1]
            nrbts_dn = xml_obj.read_xml(scf,
                                        "attrib=distName|//managedObject[matches(@class, '.*NRBTS$')]")
            nrbts_id = nrbts_dn.split("-")[-1]
            # csamson : I dont want to have a scf template !!!
            os_obj.copy_file(scf, self.scf_template_svn)
            os_obj.copy_file(scf, self.scf_supplement)
            self._generate_three_templates(mrbts_id, nrbts_id)

        # convert delete:mo:list/key, delete:mo:list:key to mo:list/key=${EMPTY}, mo:list:key=${EMPTY}
        parameters = self._convert_delete(parameters)
        # check if parameters are in scf template or scf supplement
        self._search_params_in_template(parameters)

        # create delta file and commission with it
        try:
            delta_files = self._create_delta_file(parameters, scf)
            result_all = ''
            if len(delta_files) != 0:
                for delta_file in delta_files:
                    builtin_obj.log("step: perform delta commission with %s" % delta_file)
                    if background is False:
                        result2 = self.admin_obj.perform_delta_recommissioning(delta_file,
                                                                               skip_parameter_relation_errors=True,
                                                                               timeout=300,
                                                                               alias=self.alias)
                        if result2['validationResult']['pdlValidationResult']['status'].lower() != 'ok':
                            # get the relation errors of delta commission
                            builtin_obj.log("step: get the relation errors of delta commission")
                            errors2 = \
                                result2['validationResult']['pdlValidationResult']['logs']['relationErrors'] + \
                                result2['validationResult']['pdlValidationResult']['logs']['hardwareErrors']
                            for entry in errors2:
                                builtin_obj.log("zy: %s" % entry['feedback'])
                            builtin_obj.log_to_console("\n")
                            # check if there are new involved relation errors
                            builtin_obj.log("step: check if there are new involved relation errors")
                            error_entry_new = []
                            for entry in errors2:
                                if entry not in errors1:
                                    builtin_obj.log("zy: %s" % entry['feedback'])
                                    error_entry_new.append(entry)
                            if len(error_entry_new):
                                comm_obj.log_to_console_with_time_prefix(
                                    "there are %s new validation errors involved by delta commission,"
                                    "pls fix them when develop new cases or before report PR" % len(error_entry_new),
                                    level="WARN")
                                for entry in error_entry_new:
                                    comm_obj.log_to_console_with_time_prefix(
                                        entry['feedback'], level="WARN"
                                    )
                                new_case_path = ["rework", "new_feature"]
                                suite_path = builtin_obj.get_variable_value("${SUITE_SOURCE}")
                                for path in new_case_path:
                                    if suite_path.count(path):
                                        raise Exception(
                                            "new cases are not allowed to involve validation errors, pls fix them")

                        scf_after = self._download_scf()
                        builtin_obj.log("step: scf is %s after delta commission" % scf_after)
                        result_all = result_all + str(result2)
                        time.sleep(2)  # sleep 2s to make sure parameter take effect
                    else:
                        builtin_obj.log("step: perform delta commission with %s" % delta_file)
                        task = self.admin_obj.run_keyword_in_background("perform_delta_recommissioning",
                                                                        delta_file,
                                                                        skip_parameter_relation_errors=True,
                                                                        timeout=300,
                                                                        alias=self.alias)
                        return task
                return result_all
        except Exception as e:
            traceback.print_exc()
            raise Exception(str(e))

    def _create_delta_plan_and_validate(self, parameters):
        relation_errors = []
        self._setup_scf_control()
        # get active scf
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        scf_with_timestamp = "scf_%s.xml" % comm_obj.get_timestamp()
        scf = os.path.join((save_log_dir + "/scfc_logs"), scf_with_timestamp)
        self.admin_obj.get_current_scf_file(local_dir_path=(save_log_dir + "/scfc_logs"), file_name=scf_with_timestamp,
                                            connection=self.alias, export_type="configurationAndRuntimeObjects",
                                            timeout=20, with_auto_configured_parameters=True)
        builtin_obj.log("step: active scf is %s" % scf)
        # generate scf template
        if not os.path.exists(self.scf_template_full):
            mrbts_id = self._get_bts_instance_id(scf, "MRBTS")
            nrbts_id = self._get_bts_instance_id(scf, "NRBTS")
            lnbts_id = self._get_bts_instance_id(scf, "LNBTS")
            self._generate_three_templates(mrbts_id, nrbts_id, lnbts_id)
        # convert delete:mo:list/key, delete:mo:list:key to mo:list/key=${EMPTY}, mo:list:key=${EMPTY}
        parameters = self._convert_delete(parameters)
        # check if parameters are in NIDD, scf template or scf supplement
        self._search_params_in_template(parameters)
        # create delta file and commission it without activate
        try:
            delta_file = self._create_delta_file(parameters, scf)[0]
            result = self.admin_obj.perform_delta_recommissioning(delta_file, skip_parameter_relation_errors=True,
                                                                  should_activate=False,
                                                                  timeout=300,
                                                                  alias=self.alias)
            if result['validationResult']['pdlValidationResult']['status'].lower() != 'ok':
                errors = result['validationResult']['pdlValidationResult']['logs']['relationErrors'] + \
                         result['validationResult']['pdlValidationResult']['logs']['hardwareErrors']
                for entry in errors:
                    builtin_obj.log("zy: %s" % entry['feedback'])
                    relation_errors.append(entry['feedback'])
        except Exception as e:
            traceback.print_exc()
            raise Exception(str(e))
        finally:
            return relation_errors

    def _object_with_instance_exist_or_not(self, scf, params):
        """
        the mo in params must be full name or short name, for example LNADJ-255
        """
        exist_flag = True
        comm_xml = CommonXML(scf)
        for param in params:
            if param.count("|"):
                # mo:list:key=value|condition_key=condition_value
                param_name = param.split("=")[0].split("=")[0] + "|" + param.split("|")[-1]
                expected_value = param.split("|")[0].split("=")[-1]
            else:
                # mo:key, mo:list:key, mo:list=value1,value2
                param_name = param.split("=")[0]
                expected_value = param.split("=")[1]
            print("zy_debug: param_name=%s" % param_name)
            print("zy_debug: expected_value=%s" % expected_value)
            param_name_xpath = comm_obj.match_to_xpath(param_name)
            try:
                actual_value = xml_obj.read_xml(scf, "text|%s" % param_name_xpath[0])
                if param.count(":") == 1 and actual_value is None:
                    # mo:list=value1,value2...
                    try:
                        actual_value = []
                        p_elements = comm_xml.get_elements(param_name_xpath[0] + "/p")
                        for each in p_elements:
                            actual_value.append(comm_xml.get_element_text(each))
                        actual_value.sort()
                        expected_value = expected_value.split(",")
                        expected_value.sort()
                    except Exception:
                        raise AssertionError("maybe wrong format")
                if actual_value != expected_value:
                    builtin_obj.log("%s: actual value is %s in scf, but expected value is %s" % (
                        param_name, actual_value, expected_value))
                    exist_flag = False
            except AssertionError as err_info:
                builtin_obj.log(err_info)
                exist_flag = False
        return exist_flag

    def _object_exist_or_not(self, params, scf, commission_type="admin", btsid=""):
        """
        the mo in param can be two formats:
        1. full name/short name, for example LNADJ-255
        2. mo class with full path, for example LNADJ, or LNADJ-255/LNADJL
        """

        params = comm_obj.remove_empty_from_list(params)
        builtin_obj.log("conditions are: %s" % params)
        if scf is None:
            if commission_type == "admin":
                scf = self._download_scf()
                builtin_obj.log("step: check scf: %s" % scf)
            elif commission_type == "netact":
                scf = self._netact_cm_actual_export(btsid)
            else:
                raise Exception("no suppport commission commission_type for %s" % commission_type)

        mo = params[0].split(":")[0]
        if mo.split("/")[-1].count("-"):
            result = self._object_with_instance_exist_or_not(scf, params)
        else:
            # find all mos with the same as input mo
            result = False
            dn_list = []
            commonxml = CommonXML(scf)
            mo_class = mo.split("/")[-1]
            if mo.count("/"):
                parent_mo = mo.rpartition("/")[0]
                elements = commonxml.get_elements("//*[matches(@distName, '.*%s/%s-[0-9]+$')]" % (parent_mo, mo_class))
            else:
                elements = commonxml.get_elements("//*[matches(@class, '.*:%s$')]" % mo_class)

            for element in elements:
                distName = commonxml.get_element_attribute(element, "distName")
                dn_list.append(distName)
            # find the mo satisfying the condition
            for dn in dn_list:
                builtin_obj.log("checking %s" % dn)
                params_new = []
                for param in params:
                    params_new.append(dn + ":" + param.partition(":")[-1])
                if self._object_with_instance_exist_or_not(scf, params_new) is True:
                    result = True
                    mo = dn
                    break
        builtin_obj.log("result is %s, mo is %s" % (result, mo))
        return result, mo

    def _object_should_exist(self, params, scf=None, timeout="120"):
        """This keyword is to check one managedObject should exist according to the conditions specified in params.
        1. If exist it will return the mo
        2. if not it will raise exception

        | Input Parameters | Man. | Description |
        | params   |  Yes  | parameters to be check |
        | scf  |  No   | scf file, if it is None, this keyword will download scf from BTS |
        | timeout  |  No   | default is 2 minutes |
        format of params:
        | 1) | mo:key=value | check parameter value |
        | 2) | mo:list:key=value | check parameter value in list |
        Note: the last level instance of mo may be unknown. this keyword will support format like LNADJ or LNADJ-255

        Example
        | ${params} | create list | LNADJ:cPlaneIpAddrCtrl=oamControlled |  LNADJ:adjEnbId=11
        | ${mo_dn} | object_should_exist | ${params}
        """
        if scf is None:
            retry_times = int(timeout) / 10
        else:
            retry_times = 0
        while retry_times >= 0:
            result, mo = self._object_exist_or_not(params, scf)
            if result is False:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is False:
            raise Exception("mo with %s doesn't exist" % params)
        else:
            return mo

    def _get_scf_parameter_value(self, param_name, scf=None):
        if scf is None:
            scf = self._download_scf()
        xpath = comm_obj.match_to_xpath(param_name)
        builtin_obj.log("xpath is %s" % xpath)
        param_value = xml_obj.read_xml(scf, "text|%s" % xpath[0])
        return param_value

    def _object_should_not_exist(self, params, scf=None, timeout="120"):
        """This keyword is to check if one managedObject should not exist according to the conditions
        specified in params.
        1. If exist it will raise exception
        2. if not it succeeds

        format of params:
        | 1) | mo:key=value | check parameter value |
        | 2) | mo:list:key=value | check parameter value in list |
        | timeout  |  No   | default is 2 minutes |
        Note: the last level instance of mo may be unknown. this keyword will support format like LNADJ or LNADJ-255

        Example
        | ${params} | create list | LNADJ:cPlaneIpAddrCtrl=oamControlled |  LNADJ:adjEnbId=11
        | object_should_not_exist | ${params}
        """
        if scf is None:
            retry_times = int(timeout) / 10
        else:
            retry_times = 0
        while retry_times >= 0:
            result, mo = self._object_exist_or_not(params, scf)
            if result is True:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is True:
            raise Exception("mo with %s exist and it is %s" % (params, mo))

    def _get_all_cells_id(self):
        self._setup_scf_control()
        builtin_obj.log("_get_all_cells_id PASSED", level="INFO")
        cell_ids = []
        self.admin_obj.get_current_scf_file(local_dir_path=".", file_name="scf.xml",
                                            connection=self.alias, export_type="configurationAndRuntimeObjects",
                                            with_auto_configured_parameters=True)
        builtin_obj.log("get_current_scf_file PASSED", level="INFO")
        commonxml_obj = CommonXML("scf.xml")
        all_elements = commonxml_obj.get_elements("//*[matches(@class, '.*:NRCELL$')]")
        for each_element in all_elements:
            dn = commonxml_obj.get_element_attribute(each_element, "distName")
            instance_id = dn.rpartition("-")[-1]
            lcr_id = xml_obj.read_xml(
                "scf.xml", "text|//*[matches(@distName, '.*/NRCELL-%s$')]/*[matches(@name, 'lcrId')]" % instance_id)
            cell_ids.append((instance_id, lcr_id))
        builtin_obj.log("get_current_scf_file cell_ids = %s" % cell_ids, level="INFO")
        return cell_ids

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
    # def _netact_cm_upload(self, btsid):
    #     save_log_dir = comm_obj._get_save_log_dir(self.alias)
    #     netact_info = builtin_obj.get_variable_value("${NETACT_SERVER_INFO}")
    #     self._setup_scf_control()
    #     # delete old upload log file from netact
    #     netact_conn = self._connect_to_netact()
    #     ssh_obj.execute_shell_command(
    #         "rm -f %s/%s" % ("/home/%s" % netact_info.USERNAME, "uploadResult_" + btsid + "_*.xml"))
    #     # netact upload
    #     upload_log_name = "uploadResult_%s_%s.log" % (btsid, comm_obj.get_timestamp())
    #     cmd_upload = "racclimx.sh -DN PLMN-PLMN/MRBTS-%s -op Upload -v > %s" % (btsid, upload_log_name)
    #     ssh_obj.execute_shell_command(cmd_upload)
    #     ssh_obj.disconnect_from_host(netact_conn)
    #     # sftp download upload log file to save_log_directory
    #     local_upload_log = os.path.join(save_log_dir, upload_log_name)
    #     self.files_obj.sftp_download(netact_info.IP,
    #                                  "22",
    #                                  netact_info.USERNAME,
    #                                  netact_info.PASSWORD,
    #                                  upload_log_name,
    #                                  local_upload_log)
    #     comm_obj.file_should_contain_strings(local_upload_log, "Status received: Finished")
    #     comm_obj.file_should_not_contain_strings(local_upload_log, "Error in system")
    #     comm_obj.file_should_not_contain_strings(local_upload_log, "Status received: Failed")
    #
    # def _netact_cm_actual_export(self, btsid):
    #     save_log_dir = comm_obj._get_save_log_dir(self.alias)
    #     netact_info = builtin_obj.get_variable_value("${NETACT_SERVER_INFO}")
    #     self._setup_scf_control()
    #     # delete old export files btsid_*.xml
    #     netact_conn = self._connect_to_netact()
    #     ssh_obj.execute_shell_command("rm -f %s/%s" % (netact_cm_export_dir, btsid + "_*.xml"))
    #     # export actual configuration as btsid_timestamp.xml
    #     export_file_name = "%s_%s.xml" % (btsid, comm_obj.get_timestamp())
    #     cmd_export = "racclimx.sh -op Import_Export -importExportOperation actualExport -DN PLMN-PLMN/MRBTS-%s \
    #     -UIValues true -fileName %s -v" % (
    #     btsid, export_file_name)
    #     out = ssh_obj.execute_shell_command(cmd_export)
    #     ssh_obj.disconnect_from_host(netact_conn)
    #     builtin_obj.should_not_contain(out.lower(), "failureexception")
    #     builtin_obj.should_not_contain(out.lower(), "caused by")
    #     builtin_obj.should_not_contain(out.lower(), "root exception")
    #     builtin_obj.should_not_contain(out.lower(), "failed")
    #     builtin_obj.should_not_contain(out.lower(), "error")
    #     builtin_obj.should_not_contain(out.lower(), "error in system")
    #     # sftp download export file to save_log_directory
    #     local_export_file = os.path.join(save_log_dir, export_file_name)
    #     self.files_obj.sftp_download(netact_info.IP,
    #                                  "22",
    #                                  netact_info.USERNAME,
    #                                  netact_info.PASSWORD,
    #                                  os.path.join(netact_cm_export_dir, export_file_name),
    #                                  local_export_file)
    #     builtin_obj.log("actual configuration is %s" % local_export_file)
    #     return local_export_file
    #
    # def _netact_cm_import(self, local_plan_file, plan_name):
    #     netact_info = builtin_obj.get_variable_value("${NETACT_SERVER_INFO}")
    #     self._setup_scf_control()
    #     self.files_obj.sftp_upload(netact_info.IP,
    #                                "22",
    #                                netact_info.USERNAME,
    #                                netact_info.PASSWORD,
    #                                local_plan_file,
    #                                os.path.join(netact_cm_import_dir, "%s.xml" % plan_name)
    #                                )
    #     netact_conn = self._connect_to_netact()
    #     cmd_import = "racclimx.sh -op Import_Export -importExportOperation planImport  -fileName %s.xml \
    #     -planName %s -v -UIValues true" % (
    #     plan_name, plan_name)
    #     out = ssh_obj.execute_shell_command(cmd_import)
    #     ssh_obj.disconnect_from_host(netact_conn)
    #     builtin_obj.should_not_contain(out.lower(), "error in system")
    #     builtin_obj.should_not_contain(out.lower(), "error")
    #     builtin_obj.should_not_contain(out.lower(), "operation planimport failed")
    #     return out
    #
    # def _netact_cm_provision(self, plan_name):
    #     self._setup_scf_control()
    #     netact_conn = self._connect_to_netact()
    #     cmd_provision = " racclimx.sh  -op Provision -planName %s -v" % plan_name
    #     out = ssh_obj.execute_shell_command(cmd_provision)
    #     ssh_obj.disconnect_from_host(netact_conn)
    #     builtin_obj.should_not_contain(out.lower(), "error")
    #     builtin_obj.should_contain(out.lower(), "status received: finished")
    #     return out
    #
    # def _netact_cm_delete_plan(self, plan_name):
    #     self._setup_scf_control()
    #     netact_conn = self._connect_to_netact()
    #     cmd_delete = " racclimx.sh  -op planDeletion -planName %s -v" % plan_name
    #     out = ssh_obj.execute_shell_command(cmd_delete)
    #     ssh_obj.disconnect_from_host(netact_conn)
    #     builtin_obj.should_not_contain(out.lower(), "error")
    #     return out
    #
    # def _netact_delta_commission(self, parameters, btsid):
    #     self._setup_scf_control()
    #     scf = self._netact_cm_actual_export(btsid)
    #     builtin_obj.log("step: active scf is %s" % scf)
    #     delta_files = self._create_delta_file(parameters, scf, commission_type="netact")
    #     if len(delta_files) != 0:
    #         for delta_file in delta_files:
    #             plan_name = "delta_plan_%s" % btsid
    #             try:
    #                 builtin_obj.log("step: delet plan %s" % plan_name)
    #                 self._netact_cm_delete_plan(plan_name)
    #             except AssertionError:
    #                 builtin_obj.log("ignore the error", level="DEBUG")
    #             builtin_obj.log("step: import %s as plan %s" % (delta_file, plan_name))
    #             self._netact_cm_import(delta_file, plan_name)
    #             builtin_obj.log("step: provision plan %s" % (plan_name))
    #             self._netact_cm_provision(plan_name)
    #             scf_after = self._netact_cm_actual_export(btsid)
    #             builtin_obj.log("step: scf is %s after netact delta commission" % scf_after)
    #
    # def _netact_cm_get_parameter_value(self, param_name, btsid):
    #     if param_name.count("="):
    #         raise Exception("param_name:%s is wrong format" % param_name)
    #     xpath = comm_obj.match_to_xpath(param_name)
    #     local_export_file = self._netact_cm_actual_export(btsid)
    #     param_value = xml_obj.read_xml(local_export_file, "text|%s" % xpath[0])
    #     return param_value
    #
    # def _netact_cm_object_should_exist(self, params, btsid, scf=None, timeout="300"):
    #     if scf is None:
    #         retry_times = int(timeout) / 10
    #     else:
    #         retry_times = 0
    #     while retry_times >= 0:
    #         result, mo = self._object_exist_or_not(params, scf, commission_type="netact", btsid=btsid)
    #         if result is False:
    #             retry_times = retry_times - 1
    #             time.sleep(10)
    #         else:
    #             break
    #     if result is False:
    #         raise Exception("mo with %s doesn't exist" % params)
    #     else:
    #         return mo
    #
    # def _netact_cm_object_should_not_exist(self, params, btsid, scf=None, timeout="300"):
    #     if scf is None:
    #         retry_times = int(timeout) / 10
    #     else:
    #         retry_times = 0
    #     while retry_times >= 0:
    #         result, mo = self._object_exist_or_not(params, scf, commission_type="netact", btsid=btsid)
    #         builtin_obj.log("find mo %s satisfiying the conditions" % mo)
    #         if result is True:
    #             retry_times = retry_times - 1
    #             time.sleep(10)
    #         else:
    #             break
    #     if result is True:
    #         raise Exception("mo with %s exist" % params)

    def _get_active_vendor_path(self):
        """ This keyword is used to return actual run directory from bts.
            In some bts, the value of BTS_VENDOR_DIR (/ffs/run) is not the real run directory, it need to read it
            from the link.

             | Input Paramaters      | Man. | Description |
             | host                  | No  | None by default |

             Example:
             1) connect the remote PC to run the readlink command
             | get active vendor path | 10.69.64.134 |
             2) run readlink command directory on the current connection
             | get active vendor path |
        """
        run_dir = comm_obj.get_swpool_path()
        if run_dir != "/ffs/run":
            return run_dir

        ret = self.execute_cmd_on_gnb("readlink %s" % run_dir)
        return ret

    def _get_active_vendor_version(self, vendor_dir):
        ret = self.execute_cmd_on_gnb("ls %s | grep vendor" % vendor_dir)
        tmp = re.search('(vendor.*.xml)', ret, re.M | re.I)

        vendor_name = None
        if tmp:
            vendor_name = tmp.group(1)
        if not vendor_name:
            raise Exception("Not find vendor file in '%s'" % vendor_dir)
        return vendor_name

    def _modify_and_upload_vendor_file(self, parameters_xpath):
        """modify source vendor according parameter list and then upload to enb.
        | Input Parameters | Man. | Description |
        | parameters_xpath  | Yes | modify parameters list, refer keyword "modify xml" |
        | return           | tuple for src_vendor_name, src_vendor_path
        Step:
            | 1 | login FCTB, execute "ls /flash" get vendor name such as "vendor_JE720300.xml" |
            | 2 | download vendor file |
            | 3 | change vendor file by your argus |
            | 4 | upload vendor file |
        Example
        # change vendor.xml ${NRCELLL1} inactivityTimer to 30.
        | ${var} | set variable | text|30|//*[contains(@distName, '${NRCELL1}')]/*[@name='inactivityTimer'] |
        | ${vendor_name} | ${vendor_save_path} | _modify_and_upload_vendor_file |  ${var} |
        """
        self._setup_vendor_control()
        src_vendor = os.path.join(self.local_vendor_dir, "vendor_lte.xml")
        mod_vendor = os.path.join(self.local_vendor_dir, "vendor_modified.xml")

        builtin_obj.log("step: download current used vendor file to %s" % self.local_vendor_dir, console=True)
        self.admin_obj.download_vendor_file(src_vendor, alias=self.alias)
        builtin_obj.log("step: modify vendor file, modify parameter is %s" % parameters_xpath, console=True)
        xml_obj.modify_xml(source_xml=src_vendor, target_xml=mod_vendor, modify_parameters=parameters_xpath)
        builtin_obj.log("step: set vendor file with %s" % mod_vendor, console=True)
        self.admin_obj.set_vendor_file(mod_vendor, alias=self.alias)
        return mod_vendor

    def _change_vendor(self, params):
        params = comm_obj.remove_empty_from_list(params)
        if len(params) == 0:
            return
        self._setup_vendor_control()
        builtin_obj.log("change vendor with %s in %s" % (params, self.alias), console=True)
        params_with_mo = []
        for param in params:
            if len(param.strip()):
                params_with_mo.append("any:" + param)
        xpath = comm_obj.match_to_xpath(params_with_mo)
        _mod_vendor = self._modify_and_upload_vendor_file(xpath)
        return _mod_vendor

    def _change_swconfig(self, flags, swconfig_file):
        """
        refer to https://confluence.ext.net.nokia.com/pages/viewpage.action?
        pageId=477569351#Prontologsfor5Greleases-5G-L3C-Plane
        """
        self._setup_swconfig_control()
        # flags to be changed
        flags = comm_obj.remove_empty_from_list(flags)
        if len(flags) != 0:
            builtin_obj.log("change swconfig with %s in %s" % (flags, self.alias), console=True)

        gnb_bip_size = builtin_obj.get_variable_value("${GNB_BIP_SIZE}", 300)
        if not gnb_bip_size.isdigit():
            raise Exception("GNB_BIP_SIZE={} is not supported, the value must be digit".format(gnb_bip_size))

        pre_defined_flags = [
            "0x1003F=1",  # AaSysLogInputLevel, 0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x10040=1",  # AaSysLogOutputLevel, 0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x10041=5",  # AaSysLogOutputMode, 0=none 1=all 2=udp 3=sic 4=standard output 5=local 6=remote 7=not valid
            "0x10043=51000",  # Port used for log forwarding
            "0x590072=1",  # CP-RT log level, 0=disable debug 1=enable debug
            "0x66001b=1",  # CP-NRT log level, default=2, 0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890001=1",  # CP-NB log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890002=1",  # CP-SB log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890003=1",  # CP-UE log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890004=1",  # CP-CL log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890005=1",  # CP-IF log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890006=1",  # CP-SCTP log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890008=1",  # CP_E2 log level
            "0x450027=1",  # enable R&D mode of WebEM
            "0x4F0214=0",  # ignore HWF info, due to problems in case TL prepared for TDD is used for FDD or vice versa
            "0x1002A=1",  # EMIL, AaTrace used flag:0=not used, 1=used, 2=used only (ignore configuration messages)
            "delete:0x420048",  # EMIL, use Trace management to collect tracing data instead of legacy provider/givaxi
            "0x890008=1",  # CP-E2 log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x890009=1",  # CP-VEMC log level, default=2, 0=trace 1=debug 2=info 3=warning 4=error 5=vip 6=disable
            "0x3F007C={}".format(gnb_bip_size),  # GNB BIP size, unit is M
            "0x5900B9=1",  # rdPdcchDmrsScramblingId
            "delete:0x480005",  # Workaround for Adet check failure introduced by CB006294-SR-A-B2
        ]

        # if pre-defined flag not in input flags, append to input flags
        input_flag_names = []
        for flag in flags:
            flag_name = flag.split(":")[-1] if flag.count("delete") else flag.split("=")[0]
            input_flag_names.append(flag_name)
        for pre_flag in pre_defined_flags:
            pre_flag_name = pre_flag.split(":")[-1] if pre_flag.count("delete") else pre_flag.split("=")[0]
            if pre_flag_name not in input_flag_names:
                flags.append(pre_flag)

        # for PM counter, counter interval=interval in scf/value of 0x340000
        interval = builtin_obj.get_variable_value("${PM_COUNTER_INTERVAL}")
        if interval == "1min":
            flags.append("0x340000=15")
        elif interval == "5min" or interval == "15min":
            # not set swconfig.txt, but set in scf
            flags.append("delete:0x340000")
        else:
            raise Exception("illegal ${PM_COUNTER_INTERVAL}:%s, only support 1min, 5min and 15min" % interval)

        builtin_obj.log("zy: to change flags %s" % flags)
        # base swconfig.txt
        swconfig_file_base = self._find_swconfig_file_path(file_path=swconfig_file, device_type='gnb')
        # modify swconfig.txt
        os_obj.copy_file(swconfig_file_base, self.modified_swconfig_file)
        comm_obj.modify_parameter_defined_as_key_equal_value(self.modified_swconfig_file, flags)
        self.fsm_obj.put_enb_file(self.modified_swconfig_file, self.enb_swconfig_file, alias=self.alias)
        # re-sign swconfig.txt
        self.execute_cmd_on_gnb("rm -rf /rom/swconfig.txt.p7")
        self.execute_cmd_on_gnb("crasign /rom/swconfig.txt")
        self.execute_cmd_on_gnb("craverify /rom/swconfig.txt /rom/swconfig.txt.p7")

    def _change_swconfig_airphone(self, flags, swconfig_file):
        self._setup_swconfig_control()
        # flags to be changed
        flags = comm_obj.remove_empty_from_list(flags)
        if len(flags) != 0:
            builtin_obj.log("change swconfig with %s in %s" % (flags, self.alias), console=True)
        # log level may be not as expected in swconfig.txt,
        # because there is timing issue between the value set in CCSEarlyConfig.xml and swconfig.txt.
        # in TA framework, set both swconfig.txt and execute egate command sim_debug_log after onair.
        # so log level may be not as expected during startup, but case will have the right log level.
        ap_udplog_level = builtin_obj.get_variable_value("${AP_UDPLOG_LEVEL}")
        pre_defined_flags = [
            "0x1003F={}".format(ap_udplog_level),  # ERadCcs_AaSysLogInputLevel
            "0x10040={}".format(ap_udplog_level),  # ERadCcs_AaSysLogOutputLevel
            "0x10041=5",  # ERadCcs_AaSysLogOutputMode
            "0x10042=0xC0A8C87E",  # 192.168.200.126
            "0x10043=51000",  # Port used for log forwarding
            "0x20124=4",  # keep having SYSCOM running over SCTP
            "0x5C0007=1"  # SCTP OAM Delay RAD Param in AirPhone swconfig flag file
        ]
        # if pre-defined flag not in input flags, append to input flags
        input_flag_names = []
        for flag in flags:
            flag_name = flag.split(":")[-1] if flag.count("delete") else flag.split("=")[0]
            input_flag_names.append(flag_name)
        for pre_flag in pre_defined_flags:
            pre_flag_name = pre_flag.split(":")[-1] if pre_flag.count("delete") else pre_flag.split("=")[0]
            if pre_flag_name not in input_flag_names:
                flags.append(pre_flag)
        swconfig_file_base = self._find_swconfig_file_path(file_path=swconfig_file, device_type='ap')
        # modify and upload swconfig.txt
        os_obj.copy_file(swconfig_file_base, self.modified_swconfig_file_iphy)
        comm_obj.modify_parameter_defined_as_key_equal_value(self.modified_swconfig_file_iphy, flags)
        self.fsm_obj.put_wts_file(self.modified_swconfig_file_iphy, self.enb_swconfig_file, alias=self.alias)
        self.fsm_obj.execute_command_on_wts("rm -rf /rom/swconfig.txt.p7", alias=self.alias)
        self.fsm_obj.execute_command_on_wts("crasign /rom/swconfig.txt", alias=self.alias)
        self.fsm_obj.execute_command_on_wts("craverify /rom/swconfig.txt /rom/swconfig.txt.p7", alias=self.alias)

    def _change_rd_b(self, node_type, params):
        # define rd_file_prefix to cp-xx or cp_xx
        rd_file_prefix = node_type.lower().replace(r'cp', r'cp[_-]')
        rd_file_prefix = rd_file_prefix.lower().replace(r'up', r'up[_-]')

        params = comm_obj.remove_empty_from_list(params)
        if len(params) == 0:
            return
        self._setup_common()
        # download rd file
        #  get rd file, for example cp_ue_S3129018.txz
        rd_file_in_gnb = self.execute_cmd_on_gnb("find /ffs/run/swpool/ -name %s_*.txz |grep -v ABINO"
                                                 % rd_file_prefix)
        rd_file_in_gnb = rd_file_in_gnb.splitlines()
        # find the path for /ffs/run/swpool/5G/CPUENODE/addons/cp-ue_S6045250.txz
        # find the path for /ffs/run/swpool/CPLANE-5G/airscale5g-xeon/cp-ue_S2617623.txz
        find_flag = False
        for sub_rd_file_in_gnb in rd_file_in_gnb:
            ret = re.search("%s" % rd_file_prefix, sub_rd_file_in_gnb)
            if ret and (sub_rd_file_in_gnb.lower().count("node")
                        or sub_rd_file_in_gnb.lower().count("airscale5g-xeon")):
                rd_file_prefix = ret.group(0)
                rd_file_in_gnb = sub_rd_file_in_gnb
                find_flag = True
                break
        if not find_flag:
            raise Exception("change_rd cannot find correct prefix in rd file, please contact TA group ")
        builtin_obj.log("change RD parameters %s in %s of %s" % (params, rd_file_in_gnb, self.alias), console=True)
        self.rd_file_in_gnb = rd_file_in_gnb
        rd_file_name = rd_file_in_gnb.split("/")[-1]

        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        self.rd_file_local_dir_old = "%s/rd_%s/old" % (save_log_dir, rd_file_prefix)
        os_obj.create_directory(self.rd_file_local_dir_old)
        self.fsm_obj.get_enb_file(rd_file_in_gnb, "%s/%s" % (self.rd_file_local_dir_old, rd_file_name),
                                  alias=self.alias)
        self.fsm_obj.get_enb_file(rd_file_in_gnb + ".p7", "%s/%s.p7" % (self.rd_file_local_dir_old, rd_file_name),
                                  alias=self.alias)
        self.rd_file_local_target_mapping[self.rd_file_local_dir_old] = self.rd_file_in_gnb

        # modify rd parameters
        local_dir = "%s/rd_%s/new" % (save_log_dir, rd_file_prefix)
        os_obj.create_directory(local_dir)
        os_obj.copy_file("%s/%s" % (self.rd_file_local_dir_old, rd_file_name), "%s/%s" % (local_dir, rd_file_name))
        comm_obj.uncompress_file("%s/%s" % (local_dir, rd_file_name))
        comm_obj.execute_cmd_on_pc("rm -rf %s/%s" % (local_dir, rd_file_name))
        comm_obj.modify_parameter_defined_as_key_equal_value("%s/opt/nokia/SS_CPLANE/etc/%s.enb_conf.ini"
                                                             % (local_dir, rd_file_prefix.replace("-", "_")),
                                                             params)
        comm_obj.execute_cmd_on_pc("cd %s" % local_dir)
        comm_obj.execute_cmd_on_pc("tar cJf %s *" % rd_file_name, timeout="600")
        # upload to gnb
        self.fsm_obj.put_enb_file("%s/%s" % (local_dir, rd_file_name), rd_file_in_gnb, alias=self.alias)
        self.execute_cmd_on_gnb("crasign %s" % rd_file_in_gnb)
        self.execute_cmd_on_gnb("craverify %s %s.p7" % (rd_file_in_gnb, rd_file_in_gnb))
        self.execute_cmd_on_gnb("rm -rf /ffs/run/HashContainer*")

        # # update fileLength and md5sum in targetbd
        # self._update_fields_in_targetbd(rd_file_in_gnb)

    def _update_fields_in_targetbd(self, file_in_gnb):
        self._setup_common()
        # get md5sum and file length
        md5sum = self.execute_cmd_on_gnb("md5sum %s" % file_in_gnb).split()[0]
        file_len = self.execute_cmd_on_gnb("ls -ltr %s | awk '{print $5}'" % file_in_gnb)
        # download targetbd
        targetbd = self.execute_cmd_on_gnb("ls  /ffs/run/TargetBD_* | grep -v p7")
        targetbd_local = os.path.join("/home/ute", os.path.basename(targetbd))
        self.fsm_obj.get_enb_targetbd_file(targetbd_local, alias=self.alias)
        # modify targetbd
        targetPath_in_targetbd = os.path.dirname(file_in_gnb).replace("/ffs/run", "/rom")
        name_in_targetbd = os.path.basename(file_in_gnb).split("_")[0]
        xpath = "//*[@targetPath='%s/' and @name='%s']" % (targetPath_in_targetbd, name_in_targetbd)
        modify_list = ["attrib=md5sum|%s|%s" % (md5sum, xpath),
                       "attrib=fileLength|%s|%s" % (file_len, xpath),
                       ]
        xml_obj.modify_xml(targetbd_local, targetbd_local, modify_list)
        # upload targetbd and crasign
        self.fsm_obj.put_enb_targetbd_file(targetbd_local, alias=self.alias)
        self.execute_cmd_on_gnb("crasign %s" % targetbd)
        self.execute_cmd_on_gnb("craverify %s %s.p7" % (targetbd, targetbd))

    def _change_rd_on_asib_abio(self, node_type, params):
        # define rd_file_prefix to cp-xx or cp_xx
        rd_file_prefix = node_type.lower().replace(r'cp', r'cp[_-]')
        rd_file_prefix = rd_file_prefix.lower().replace(r'up', r'up[_-]')
        params = comm_obj.remove_empty_from_list(params)
        if len(params) == 0:
            return
        self._setup_common()
        # download rd file
        #  get rd file, for example cp_ue_S3129018.txz
        rd_file_in_gnb = self.execute_cmd_on_gnb("find /ffs/run/swpool/ -name %s_*.txz"
                                                 % rd_file_prefix)
        rd_file_in_gnb = rd_file_in_gnb.splitlines()
        # find the path for /ffs/run/swpool/5G/CPUENODE_ABINO/addons/cp-ue_S6045250.txz
        # find the path for /ffs/run/swpool/CPLANE-5G/sm6-snowfish/cp-ue_S2617623.txz
        # find the path for /ffs/run/swpool/CPLANE-5G/fsmr4-axm64/cp-cl_S2617623.txz
        find_flag = False
        for sub_rd_file_in_gnb in rd_file_in_gnb:
            ret = re.search("%s" % rd_file_prefix, sub_rd_file_in_gnb)
            if ret and (sub_rd_file_in_gnb.lower().count("abino")
                        or sub_rd_file_in_gnb.lower().count("sm6-snowfish")
                        or node_type.lower() != "cpue"):
                rd_file_prefix = ret.group(0)
                rd_file_in_gnb = sub_rd_file_in_gnb
                find_flag = True
                break

        if not find_flag:
            raise Exception("change_rd cannot find correct prefix in rd file, please contact TA group ")
        builtin_obj.log("change RD parameters %s in %s of %s" % (params, rd_file_in_gnb, self.alias), console=True)
        self.rd_file_in_gnb = rd_file_in_gnb
        rd_file_name = rd_file_in_gnb.split("/")[-1]

        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        self.rd_file_local_dir_old = "%s/rd_%s/old" % (save_log_dir, rd_file_prefix)
        os_obj.create_directory(self.rd_file_local_dir_old)
        self.fsm_obj.get_enb_file(rd_file_in_gnb, "%s/%s" % (self.rd_file_local_dir_old, rd_file_name),
                                  alias=self.alias)
        self.fsm_obj.get_enb_file(rd_file_in_gnb + ".p7", "%s/%s.p7" % (self.rd_file_local_dir_old, rd_file_name),
                                  alias=self.alias)
        self.rd_file_local_target_mapping[self.rd_file_local_dir_old] = self.rd_file_in_gnb

        # modify rd parameters
        local_dir = "%s/rd_%s/new" % (save_log_dir, rd_file_prefix)
        os_obj.create_directory(local_dir)
        os_obj.copy_file("%s/%s" % (self.rd_file_local_dir_old, rd_file_name), "%s/%s" % (local_dir, rd_file_name))
        comm_obj.uncompress_file("%s/%s" % (local_dir, rd_file_name))
        comm_obj.execute_cmd_on_pc("rm -rf %s/%s" % (local_dir, rd_file_name))
        comm_obj.modify_parameter_defined_as_key_equal_value("%s/opt/nokia/SS_CPLANE/etc/%s.enb_conf.ini"
                                                             % (local_dir, rd_file_prefix.replace("-", "_")),
                                                             params)
        comm_obj.execute_cmd_on_pc("cd %s" % local_dir)
        comm_obj.execute_cmd_on_pc("tar cJf %s *" % rd_file_name, timeout="600")
        # upload to gnb
        self.fsm_obj.put_enb_file("%s/%s" % (local_dir, rd_file_name), rd_file_in_gnb, alias=self.alias)
        self.execute_cmd_on_gnb("crasign %s" % rd_file_in_gnb)
        self.execute_cmd_on_gnb("craverify %s %s.p7" % (rd_file_in_gnb, rd_file_in_gnb))
        self.execute_cmd_on_gnb("rm -rf /ffs/run/HashContainer*")

    def _change_rd_on_asil_abio(self, node_type, params):
        # define rd_file_prefix to cp-xx or cp_xx
        rd_file_prefix = node_type.lower().replace(r'cp', r'cp[_-]')
        rd_file_prefix = rd_file_prefix.lower().replace(r'up', r'up[_-]')
        params = comm_obj.remove_empty_from_list(params)
        if len(params) == 0:
            return
        self._setup_common()
        # download rd file
        #  get rd file, for example cp_ue_S3129018.txz
        rd_file_in_gnb = self.execute_cmd_on_gnb("find /ffs/run/swpool/ -name %s_*.txz"
                                                 % rd_file_prefix)
        rd_file_in_gnb = rd_file_in_gnb.splitlines()
        # find the path for /ffs/run/swpool/5G/CPUENODE_ABINO/addons/cp-ue_S6045250.txz
        # find the path for /ffs/run/swpool/CPLANE-5G/sm6-snowfish/cp-ue_S2617623.txz
        # find the path for /ffs/run/swpool/CPLANE-5G/sm6-snowfish/cp-cl_S2617623.txz
        find_flag = False
        for sub_rd_file_in_gnb in rd_file_in_gnb:
            ret = re.search("%s" % rd_file_prefix, sub_rd_file_in_gnb)
            if ret and (sub_rd_file_in_gnb.lower().count("abino")
                        or sub_rd_file_in_gnb.lower().count("sm6-snowfish")):
                rd_file_prefix = ret.group(0)
                rd_file_in_gnb = sub_rd_file_in_gnb
                find_flag = True
                break

        if not find_flag:
            raise Exception("change_rd cannot find correct prefix in rd file, please contact TA group ")
        builtin_obj.log("change RD parameters %s in %s of %s" % (params, rd_file_in_gnb, self.alias), console=True)
        self.rd_file_in_gnb = rd_file_in_gnb
        rd_file_name = rd_file_in_gnb.split("/")[-1]

        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        self.rd_file_local_dir_old = "%s/rd_%s/old" % (save_log_dir, rd_file_prefix)
        os_obj.create_directory(self.rd_file_local_dir_old)
        self.fsm_obj.get_enb_file(rd_file_in_gnb, "%s/%s" % (self.rd_file_local_dir_old, rd_file_name),
                                  alias=self.alias)
        self.fsm_obj.get_enb_file(rd_file_in_gnb + ".p7", "%s/%s.p7" % (self.rd_file_local_dir_old, rd_file_name),
                                  alias=self.alias)
        self.rd_file_local_target_mapping[self.rd_file_local_dir_old] = self.rd_file_in_gnb

        # modify rd parameters
        local_dir = "%s/rd_%s/new" % (save_log_dir, rd_file_prefix)
        os_obj.create_directory(local_dir)
        os_obj.copy_file("%s/%s" % (self.rd_file_local_dir_old, rd_file_name), "%s/%s" % (local_dir, rd_file_name))
        comm_obj.uncompress_file("%s/%s" % (local_dir, rd_file_name))
        comm_obj.execute_cmd_on_pc("rm -rf %s/%s" % (local_dir, rd_file_name))
        comm_obj.modify_parameter_defined_as_key_equal_value("%s/opt/nokia/SS_CPLANE/etc/%s.enb_conf.ini"
                                                             % (local_dir, rd_file_prefix.replace("-", "_")),
                                                             params)
        comm_obj.execute_cmd_on_pc("cd %s" % local_dir)
        comm_obj.execute_cmd_on_pc("tar cJf %s *" % rd_file_name, timeout="600")
        # upload to gnb
        self.fsm_obj.put_enb_file("%s/%s" % (local_dir, rd_file_name), rd_file_in_gnb, alias=self.alias)
        self.execute_cmd_on_gnb("crasign %s" % rd_file_in_gnb)
        self.execute_cmd_on_gnb("craverify %s %s.p7" % (rd_file_in_gnb, rd_file_in_gnb))
        self.execute_cmd_on_gnb("rm -rf /ffs/run/HashContainer*")

    def _change_rd_parameters_on_asim(self, node_type, params):
        # define rd_file_prefix to cp-xx or cp_xx
        rd_file_prefix = node_type.lower().replace(r'cp', r'cp[_-]')
        rd_file_prefix = rd_file_prefix.lower().replace(r'up', r'up[_-]')
        params = comm_obj.remove_empty_from_list(params)
        if len(params) == 0:
            return
        self._setup_common()
        # download rd file
        #  get rd file, for example cp_ue_S3129018.txz
        rd_file_in_gnb = self._execute_cmd_on_bts("find /ffs/run/swpool/ -name %s_*.txz"
                                                  % rd_file_prefix)
        rd_file_in_gnb = rd_file_in_gnb.splitlines()
        # find the path for /ffs/run/swpool/CPLANE-5G/sm7-marlin/cp-ue_85307c66.txz
        find_flag = False
        for sub_rd_file_in_gnb in rd_file_in_gnb:
            ret = re.search("%s" % rd_file_prefix, sub_rd_file_in_gnb)
            if ret and sub_rd_file_in_gnb.lower().count("sm7-marlin"):
                rd_file_prefix = ret.group(0)
                rd_file_in_gnb = sub_rd_file_in_gnb
                find_flag = True
                break

        if not find_flag:
            raise Exception("change_rd cannot find correct prefix in rd file, please contact TA group ")
        builtin_obj.log("change RD parameters %s in %s of %s" % (params, rd_file_in_gnb, self.alias), console=True)
        self.rd_file_in_gnb = rd_file_in_gnb
        rd_file_name = rd_file_in_gnb.split("/")[-1]

        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        self.rd_file_local_dir_old = "%s/rd_%s/old" % (save_log_dir, rd_file_prefix)
        os_obj.create_directory(self.rd_file_local_dir_old)
        self.fsm_obj.get_enb_file(rd_file_in_gnb, "%s/%s" % (self.rd_file_local_dir_old, rd_file_name),
                                  alias=self.alias)
        self.fsm_obj.get_enb_file(rd_file_in_gnb + ".p7", "%s/%s.p7" % (self.rd_file_local_dir_old, rd_file_name),
                                  alias=self.alias)
        self.rd_file_local_target_mapping[self.rd_file_local_dir_old] = self.rd_file_in_gnb

        # modify rd parameters
        local_dir = "%s/rd_%s/new" % (save_log_dir, rd_file_prefix)
        os_obj.create_directory(local_dir)
        os_obj.copy_file("%s/%s" % (self.rd_file_local_dir_old, rd_file_name), "%s/%s" % (local_dir, rd_file_name))
        comm_obj.uncompress_file("%s/%s" % (local_dir, rd_file_name))
        comm_obj.execute_cmd_on_pc("rm -rf %s/%s" % (local_dir, rd_file_name))
        comm_obj.modify_parameter_defined_as_key_equal_value("%s/opt/nokia/SS_CPLANE/etc/%s.enb_conf.ini"
                                                             % (local_dir, rd_file_prefix.replace("-", "_")),
                                                             params)
        comm_obj.execute_cmd_on_pc("cd %s" % local_dir)
        comm_obj.execute_cmd_on_pc("tar cJf %s *" % rd_file_name, timeout="600")
        # upload to gnb
        self.fsm_obj.put_enb_file("%s/%s" % (local_dir, rd_file_name), rd_file_in_gnb, alias=self.alias)
        self._execute_cmd_on_bts("crasign %s" % rd_file_in_gnb)
        self._execute_cmd_on_bts("craverify %s %s.p7" % (rd_file_in_gnb, rd_file_in_gnb))
        self._execute_cmd_on_bts("rm -rf /ffs/run/HashContainer*")

    def _change_rd_parameters_by_default(self, node_type, params):
        self._change_rd_b(node_type, params)

    def _change_rd_parameters_on_asil_abio(self, node_type, params):
        self._change_rd_on_asil_abio(node_type, params)

    def _change_rd_parameters_on_asib_abio(self, node_type, params):
        self._change_rd_on_asib_abio(node_type, params)

    def _change_enb_conf_ini(self, node_type, params):
        """
        refer to https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1272498314
        ASIK-3ABIL (airscale)
        ASIL-3ABIO (snowfish)
        ASIL-3ABIN (snowfish)
        ASIB-3ABIO (fsmr4-axm64, snowfish)
        ASIB-3ABIN (fsmr4-axm64, snowfish)
        ASIM-3ABIP (sm7-marlin)
        ASOD (airscale)
        ASOE (snowfish)
        """
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        bbmod_type = builtin_obj.get_variable_value("${BBMOD_TYPE}")[0]
        if bbu_type == 'ASIB' and bbmod_type == 'ABIO':
            self._change_rd_parameters_on_asib_abio(node_type, params)
        elif bbu_type == 'ASIL' and bbmod_type == 'ABIO':
            self._change_rd_parameters_on_asil_abio(node_type, params)
        elif bbu_type == 'ASOE':
            self._change_rd_parameters_on_asib_abio(node_type, params)
        elif bbu_type == 'ASIM':
            self._change_rd_parameters_on_asim(node_type, params)
        else:
            # change rd parameter in gnb ASIK+ABIL or ASOD
            self._change_rd_parameters_by_default(node_type, params)

    def _recover_enb_config_ini(self):
        self._setup_common()
        if len(self.rd_file_local_target_mapping):
            for local_dir, target_rd_file in self.rd_file_local_target_mapping.items():
                # upload to gnb
                builtin_obj.log("step: upload {}/* to {}".format(local_dir, target_rd_file.rpartition("/")[0]))
                self.fsm_obj.put_enb_file("%s/*" % local_dir,
                                          target_rd_file.rpartition("/")[0],
                                          alias=self.alias)
            self.execute_cmd_on_gnb("rm -rf /ffs/run/HashContainer*")

    def _create_cp_runtime_ini(self, params):
        self.execute_cmd_on_gnb("rm -rf /ffs/run/cp_runtime.ini")
        params = comm_obj.remove_empty_from_list(params)
        if len(params):
            self.execute_cmd_on_gnb("echo -e '[rnd]' > /ffs/run/cp_runtime.ini")
            for param in params:
                self.execute_cmd_on_gnb("echo -e '{}' >> /ffs/run/cp_runtime.ini".format(param))
            # Check Cp_runtime produce correct or not
            out = self.execute_cmd_on_gnb("ls -lrt /ffs/run/cp_runtime.ini;cat /ffs/run/cp_runtime.ini")
            if out.count("[rnd]") == 0:
                builtin_obj.log("/ffs/run/cp_runtime.ini create failure", level="WARN")

    def _delete_cp_runtime_ini(self):
        out = self.execute_cmd_on_gnb("ls /ffs/run/cp_runtime.ini")
        if out.count("No such file or directory") == 0:
            self.execute_cmd_on_gnb("rm -rf /ffs/run/cp_runtime.ini")
            self.execute_cmd_on_gnb("ls /ffs/run/cp_runtime.ini")

    def _modify_gnbmirror_slot_config(self, file_path):
        self._setup_common()
        self.bts_info["bbmod_info"] = []
        bbmod_all_distname_list = self.admin_obj.get_ids_for_all(class_name="BBMOD", connection=self.alias)
        for bbmod_distname in bbmod_all_distname_list:
            sub_bbmod_info = self.admin_obj.get_parameters(dist_name=bbmod_distname, connection=self.alias)
            self.bts_info["bbmod_info"].append(sub_bbmod_info)
        file_data = ""
        with open(file_path, 'r') as f_obj:
            for line in f_obj:
                if "BB_SLOT_1" in line:
                    line = line.replace("'true'", "'false'")
                file_data += line
        with open(file_path, "w") as f_obj:
            f_obj.write(file_data)
        for sub_bbmod_info in self.bts_info["bbmod_info"]:
            slot_key = "BB_SLOT_"
            if sub_bbmod_info["horizontalPosition"] == 1 and sub_bbmod_info["verticalPosition"] == 2:
                slot_key = slot_key + "1"
            elif sub_bbmod_info["horizontalPosition"] == 1 and sub_bbmod_info["verticalPosition"] == 3:
                slot_key = slot_key + "2"
            elif sub_bbmod_info["horizontalPosition"] == 1 and sub_bbmod_info["verticalPosition"] == 4:
                slot_key = slot_key + "3"
            elif sub_bbmod_info["horizontalPosition"] == 2 and sub_bbmod_info["verticalPosition"] == 2:
                slot_key = slot_key + "5"
            elif sub_bbmod_info["horizontalPosition"] == 2 and sub_bbmod_info["verticalPosition"] == 3:
                slot_key = slot_key + "6"
            elif sub_bbmod_info["horizontalPosition"] == 2 and sub_bbmod_info["verticalPosition"] == 4:
                slot_key = slot_key + "7"
            else:
                return
            file_data = ""
            with open(file_path, 'r') as f_obj:
                for line in f_obj:
                    if slot_key in line:
                        line = line.replace("'false'", "'true'")
                    file_data += line
            with open(file_path, "w") as f_obj:
                f_obj.write(file_data)

    def _modify_mirror_script_parameters(self, flags, mirror_config_file):
        flags = comm_obj.remove_empty_from_list(flags)
        if len(flags) == 0:
            return
        else:
            builtin_obj.log("change mirror script with %s " % flags, console=True)
        if os.path.exists(mirror_config_file):
            mirror_file_base = mirror_config_file
        else:
            raise Exception("no base MirroringConfig.sh,please check %s" % mirror_config_file)
        mirror_config_file_dir, mirror_config_file_name = os.path.split(mirror_file_base)
        backup_mirror_file = os.path.join(mirror_config_file_dir,
                                          mirror_config_file_name.split(".")[0] +
                                          "_backup." + mirror_config_file_name.split(".")[-1]
                                          )
        os_obj.copy_file(mirror_config_file, backup_mirror_file)
        comm_obj.modify_parameter_defined_as_key_equal_value(mirror_config_file, flags)

    def _find_swconfig_file_path(self, file_path, device_type):
        self._setup_swconfig_control()
        swconfig_file = file_path
        gnb_swconfig_new_file_cloud = "/home/ute/testline_init_results/configs/sm_swconfig.txt"
        gnb_swconfig_old_file_cloud = "/home/ute/testline_init_results/configs/gnb_swconfig.txt"
        ap_swconfig_new_file_cloud = "/home/ute/testline_init_results/configs/sim_swconfig.txt"
        ap_swconfig_old_file_cloud = "/home/ute/testline_init_results/configs/ap_swconfig.txt"
        if device_type.lower().count("gnb"):
            if os.path.exists(swconfig_file):
                swconfig_file_base = swconfig_file
            elif os.path.exists(gnb_swconfig_new_file_cloud):
                swconfig_file_base = gnb_swconfig_new_file_cloud
            elif os.path.exists(gnb_swconfig_old_file_cloud):
                swconfig_file_base = gnb_swconfig_old_file_cloud
            else:
                try:
                    self.fsm_obj.get_enb_file(self.enb_swconfig_file, self.backup_swconfig_file, alias=self.alias)
                    swconfig_file_base = self.backup_swconfig_file
                except Exception:
                    raise Exception("no base swconfig.txt, fetch one from cloud and save as %s" % swconfig_file)

        if device_type.lower().count("ap"):
            if os.path.exists(swconfig_file):
                swconfig_file_base = swconfig_file
            elif os.path.exists(ap_swconfig_new_file_cloud):
                swconfig_file_base = ap_swconfig_new_file_cloud
            elif os.path.exists(ap_swconfig_old_file_cloud):
                swconfig_file_base = ap_swconfig_old_file_cloud
            else:
                try:
                    self.fsm_obj.get_wts_file("/ffs/run/swconfig.txt",
                                              self.backup_swconfig_file_iphy, alias=self.alias)
                    swconfig_file_base = self.backup_swconfig_file_iphy
                except Exception:
                    raise Exception("no base swconfig.txt, fetch one from cloud and save as %s" % swconfig_file)

        if device_type.lower().count("ap") == 0 and device_type.lower().count("gnb") == 0:
            raise Exception("device type %s is unknown" % device_type)
        builtin_obj.log("zy: base swconfig.txt is %s" % swconfig_file_base)
        return swconfig_file_base

    def _get_log_from_snapshot_with_name(self, file_name, snapshot_path='', snapshot_name='', timeout='20min'):
        snapshot_file_path = os.path.join(snapshot_path, snapshot_name)
        if not snapshot_file_path:
            # get snapshot due to no specific snapshot file.
            try:
                self._setup_common()
                save_log_dir = comm_obj._get_save_log_dir(self.alias)
                self.admin_obj.collect_snapshot(target_file_name="%s/snapshot.zip" % save_log_dir,
                                                timeout=timeout, alias=self.alias)
            except Exception as err:
                raise Exception(
                    "collect snapshot failure on function "
                    "cm_bts.get_log_from_snapshot_with_name, error info:{}".format(err))
            else:
                snapshot_file_path = "%s/snapshot.zip" % save_log_dir
                snapshot_path = save_log_dir
                snapshot_name = 'snapshot.zip'
        saved_snapshot_path = os.path.join(snapshot_path, 'snapshot')
        comm_obj.execute_cmd_on_pc("rm -rf %s;mkdir -p %s" % (saved_snapshot_path, saved_snapshot_path))
        if not os.path.isfile(snapshot_file_path):
            raise Exception("snapshot file doesn't find. {}".format(snapshot_file_path))
        comm_obj.execute_cmd_on_pc("unzip -o -d %s %s" % (saved_snapshot_path, snapshot_file_path))
        snapshot_file_list_path = os.path.join(saved_snapshot_path, "snapshot_file_list.txt")
        cmd = r"tac %s | awk 'BEGIN{flag=0}{a[++l]=$0}(/^[A-Za-z]/){for(i=l;i>=1;i--){if(a[i] ~ /%s/) " \
              r"{print a[l]; break;}};l=0}'" % (snapshot_file_list_path, file_name)
        cmd_output = comm_obj.execute_cmd_on_pc(cmd)
        if not cmd_output:
            raise Exception("Find file name %s failure on snapshot %s" % (file_name, snapshot_file_path))
        cmd_output = cmd_output.replace("zip:", "zip")
        comm_obj.execute_cmd_on_pc("unzip -o -d %s %s/%s" % (saved_snapshot_path, saved_snapshot_path, cmd_output))
        comm_obj.execute_cmd_on_pc("for i in `ls %s | grep %s` ;do unzip -o -d %s %s/$i ;done"
                                   % (saved_snapshot_path, file_name, saved_snapshot_path, saved_snapshot_path))
        comm_obj.execute_cmd_on_pc("xz -d %s/*.xz" % saved_snapshot_path)
        comm_obj.execute_cmd_on_pc("rm %s/*.zip" % saved_snapshot_path)
        comm_obj.execute_cmd_on_pc("rm %s/*.xz" % saved_snapshot_path)

    def _get_all_physical_cell_ids(self):
        pciValue = []
        cellIdsAndInstanceIds = self._get_all_cells_id()
        for cellIdAndInstanceId in cellIdsAndInstanceIds:
            cellId = cellIdAndInstanceId[0]
            pci = self._get_scf_parameter_value("NRCELL-{}:physCellId".format(cellId))
            pciValue.append(pci)
        return pciValue

    def _get_physical_cell_id_for_specific_cell(self, cellIds='1,2'):
        cellIds = cellIds.split(',')
        pciValue = []
        for cellId in cellIds:
            pci = self._get_scf_parameter_value("NRCELL-{}:physCellId".format(cellId))
            pciValue.append(pci)
        return pciValue

    def _compare_two_scf(self, target_scf, source_scf):
        builtin_obj.log("step: compare target scf: {} with source scf: {}".format(target_scf, source_scf))
        log_dir = os.path.dirname(source_scf)
        cwd = os.path.dirname(__file__)
        cmd = "python {}/../../../../tools/generate_parameters/compare_scf.py {} {} {}".format(
            cwd, target_scf, source_scf, log_dir)
        comm_obj.execute_cmd_on_pc(cmd, timeout=120)
        delta_file = os.path.join(log_dir, "delta_{}.xml".format(comm_obj.get_timestamp()))
        os_obj.move_file(os.path.join(log_dir, "delta.xml"), delta_file)
        builtin_obj.log("step: get delta file: {}".format(delta_file))
        if os.path.getsize(delta_file) == 0:
            result = True
            builtin_obj.log("step: two scf are same")
        else:
            result = False
            builtin_obj.log("step: two scf are different")
        return delta_file, result

    def _recover_scf_configuration(self, target_scf):
        self._setup_scf_control()
        # get active scf
        current_scf = self._download_scf(export_type="configuration")

        # compare current active scf with given scf, get delta file
        delta_file, result = self._compare_two_scf(target_scf, current_scf)
        if result is True:
            return

        # delta commission
        convert_delta_xml_to_json(delta_file)
        delta_file = delta_file.replace(".xml", ".json")
        builtin_obj.log("step: convert to json: {}".format(delta_file))
        builtin_obj.log("step: delta comission with {}".format(delta_file))
        self.admin_obj.perform_delta_recommissioning(delta_file,
                                                     skip_parameter_relation_errors=True,
                                                     timeout=300,
                                                     alias=self.alias)

        # get active scf
        current_scf2 = self._download_scf(export_type="configuration")

        # compare current active scf with given scf, they should be same
        delta_file, result = self._compare_two_scf(target_scf, current_scf2)
        if result is False:
            raise Exception("recover to {} failed".format(target_scf))


class cm_gnb1(object):
    def __init__(self):
        alias = "gnb1"
        self.cm_base_instant_1 = cm_base(alias)

    #     def __del__(self):
    #         self.cm_base_instant_1.__del__()

    def get_rack_position(self):
        """
        taf admin.get_smod_position doesn't support not_commissioned state, this keyword uses infomodel to check
        rack position, not care enb state
        """
        return self.cm_base_instant_1._get_rack_position()

    def get_bbmod_type(self):
        return self.cm_base_instant_1._get_bbmod_type()

    def get_bbu_type(self):
        return self.cm_base_instant_1._get_bbu_type()

    def get_gnb_fsp_types(self):
        """
        Get Gnb FSP board type
        """
        return self.cm_base_instant_1._get_gnb_fsp_types()

    def get_product_type(self):
        return self.cm_base_instant_1._get_product_type()

    def modify_scf(self, scf_base, parameters, scf_target):
        self.cm_base_instant_1._modify_scf(scf_base, parameters, scf_target)

    def modify_scf_and_perform_full_commission(self, scf_base, parameters):
        """This keyword is to modify golden scf with the specified parameters and full commission GNB with it.
        | Arguments  | Man. | Description |
        | scf_base   | Yes  | initial startup scf |
        | parameters | Yes |  parameters to be modified |

        format of parameters and action
        | 1) | mo:key=value            | modify the parameter directly under managedObject |
        | 2) | mo:list:key=value       | modify list parameters of managedObject, modify all if multiple items exist |
        | 3) | mo:list:key=value|condition_key=condition_value  | the list only contains item with \
        condition_key=condition_value. update key=value and Other parameters are same as item 0 \
        in active SCF or SCF template  |
        | 4) | mo:list=value1,value2...| modify list which only has values |
        | 5) | delete:mo(or mo RE)     | delete one managedObeject or manageObjects satisfying the regular expression |
        | 6) | delete:mo:list(or key)  | delete list or parameter directly under managedObject |
        | 7) | delete:mo:list:key      | delete parameter under list |
        | 8) | mo                      | create MO, this is suggested to be used for empty MO |

        Note:
        1.for format 4)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        2. value could be ${EMPTY}, the parameter will have no value. But condition_value can't be ${EMPTY}

        3. support extension mode for MRBTS, NRBTS and NRCELL.
        MRBTS and NRBTS will be explained with actual instance id.
        NRCELL will be extended with all NRCELL instances.

        4. handle some abnormal scenarios:
        | 1) | MO doesn't exist | create the new MO based on scf template, and modify it with parameters
        specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |


        Example:
        | ${parameters} | Create List | NRCELL-1:a1MeashoEnabled=rsrp |
        | ...           | NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=50 |
        | ...           | NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4|cellBwpId=0 |
        | ...           | NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-33|cellBwpId=1 |
        | ...           | NRCELL-1:cellBwpList:bwpDN=${EMPTY}|cellBwpId=2 |
        | ...           | NRBTS/NRCELLGRP-0:nrCellList=1,2 |
        | ...           | delete:NRADJGNB-[^2-3] |
        | ...           | delete:NRCELL-2:cellBwpList |
        | ...           | delete:NRCELL-2:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp |
        | ...           | NRCELL/NRHOIF-1:a1BasedPCellSwitchEnabled=false |
        | modify_scf_and_perform_full_commission | /home/ute/SCFC_1.xml | ${parameters} |
        """
        return self.cm_base_instant_1._modify_scf_and_perform_full_commission(scf_base, parameters)

    def download_scf(self):
        """This keyword is to download active SCF from bts
        Example
        | scf_with_full_path | download_scf |
        """
        return self.cm_base_instant_1._download_scf()

    def delta_commission_parameters(self, parameters, background=False):
        """This keyword is to perform delta commissioning to GNB
        | step1 | download active scf from GNB |
        | step2 | create delta file based on active scf and input parameters |
        | step3 | delta commission GNB via ADMIN API |

        | Arguments    | Man. | Default | Description |
        | parameters   | Yes  | NA      | parameters to be modified |
        | background   | No   | False   | if true, it will not wait delta commission finished. It is used for rare case
         that need executes other action in parallel with delta commission |

        Format of parameters and action
        | 1) | mo:key=value            | modify the parameter directly under managedObject |
        | 2) | mo:list:key=value       | modify list parameters of managedObject, modify all if multiple items exist |
        | 3) | mo:list:key=value|condition_key=condition_value  | the list only contains item with \
        condition_key=condition_value. update key=value and Other parameters are same as item 0 \
        in active SCF or SCF template  |
        | 4) | mo:list=value1,value2...| modify list which only has values |
        | 5) | delete:mo(or mo RE)     | delete one managedObeject or manageObjects satisfying the regular expression |
        | 6) | delete:mo:list(or key)  | delete list or parameter directly under managedObject |
        | 7) | delete:mo:list:key      | delete parameter under list |
        | 8) | mo                      | create MO, this is suggested to be used for empty MO |

        Note:
        1.for format 4)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        2. value could be ${EMPTY}, the parameter will have no value. But condition_value can't be ${EMPTY}

        3. support extension mode for MRBTS, NRBTS and NRCELL.
        MRBTS and NRBTS will be explained with actual instance id.
        NRCELL will be extended with all NRCELL instances.

        4. handle some abnormal scenarios:
        | 1) | MO doesn't exist | create the new MO based on scf template, and modify it with parameters
        specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |


        Examples:
        1) execute delta commission and wait the procedure finished
        | ${delta_parameters} | Create List | NRCELL-1:a1MeashoEnabled=rsrp |
        | ...           | NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=50 |
        | ...           | NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-4|cellBwpId=0 |
        | ...           | NRCELL-1:cellBwpList:bwpDN=MRBTS-1/NRBTS-1/BWP_PROFILE-33|cellBwpId=1 |
        | ...           | NRCELL-1:cellBwpList:bwpDN=${EMPTY}|cellBwpId=2 |
        | ...           | NRBTS/NRCELLGRP-0:nrCellList=1,2 |
        | ...           | delete:NRADJGNB-[^2-3] |
        | ...           | delete:NRCELL-2:cellBwpList |
        | ...           | delete:NRCELL-2:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp |
        | ...           | NRCELL/NRHOIF-1:a1BasedPCellSwitchEnabled=false |
        | delta_commission_parameters | ${delta_parameters} |

        2) execute delta commission in background, not wait the procedure finished
        | delta_commission_parameters | ${delta_parameters} | background=${True} |
        """
        vendor_params = builtin_obj.get_variable_value("@{PARAMS_IN_VENDOR}")
        self.cm_base_instant_1._change_vendor(vendor_params)
        return self.cm_base_instant_1._delta_commission_parameters(parameters, background=background)

    def online_change_parameter(self, dist_name, parameter, value, operation):
        return self.cm_base_instant_1._online_change_parameter(dist_name, parameter, value, operation)

    def create_delta_plan_and_validate(self, parameters):
        """This keyword is to create delta plan and validate it

        | Input Parameters | Man. | Description |
        | parameters   |  Yes  | parameters to be modified |

        format of parameters and action
        | 1) | mo:key=value | modify parameter of managedObject |
        | 2) | mo:list:key=value | modify list parameters of managedObject, modify all if mutiple items exist |
        | 3) | mo:list=value1,value2... | modify list which only has one parameter in p tag |
        | 4) | mo:list:key=value|condition_key=condition_value  | the list only contains item with condition_key=
                  condition_value, key=vaule. Other parameters are same as item 0 in active SCF or template SCF |
        | 5) | delete:mo_name or pattern | delete mo  |
        | 6) | delete:mo_name:list_name or parameter | delete list or parameter |
        | 7) | delete:mo:list:key=value | delete the item that satisfy mo:list:key=value |
        | 8) | mo | create/update MO, this is suggest to be used for empty MO |

        Note:
        1.for format 3)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        2. value could be ${EMPTY}, the parameter will have no value. But condition_value can't be ${EMPTY}

        3. support extension mode for LNBTS and LNCEL. LNBTS will be explained with actual LNBTS instance.
           LNCEL will be extend with all LNCEL instances as all LNCELs instance.

        4. handle some abnormal scenarios:
        | 1) | MO doesn't exist | create the new MO based on scf template, and modify
               it with parameters specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |

        Example
        | ${delta_parameters} | Create List | PSGRP-1:lbpsISONCtlEnabled=true |
        | ... |PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ... | PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon | delete:PSGPR-[^2-3] |
        | ... | delete:PSGPR-1:lbpsPeriodList |
        | ... | delete:PSGRP-1:lbpsPeriodList:lbpsDayOfWeek=Mon | delete:LNADJ.* | LNCEL/LNREL-1:amleAllowed=false |
        | ${relation_errors} | create_delta_plan_and_validate | ${delta_parameters} |
        """
        return self.cm_base_instant_1._create_delta_plan_and_validate(parameters)

    def object_should_exist(self, params, scf=None, timeout="120"):
        """This keyword is to check one managedObject should exist according to the conditions specified in params.
        | step1 | download active scf from GNB if scf None |
        | step2 | check if the managedObject exist according to the conditions |
        | step3 | return mo if exist, raise exception if not exist |

        | Arguments | Man. | Default | Description |
        | params    |  Yes | NA      | parameters to be check, they must belong to one manageObject |
        | scf       |  No  | None    | scf file, if None, it will download scf from GNB |
        | timeout   |  No  | 120(s)  | the time retry to check scf |

        Format of params:
        | 1) | mo:key=value             | check parameter value |
        | 2) | mo:list:key=value        | check parameter value in list |
        | 3) | mo:list=value1,value2... | check list which only has values  |
        | 4) | mo:list:key=value|condition_key=condition_value  | check list which item structure |

        Note: because the instance of mo may be unknown, this keyword supports format like NRADJ or NRADJ-255.
        for format 3)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        Examples
        1) specify instance id
        | ${params}           | create list | NRADJ-1:cPlaneIpAddrCtrl=oamControlled |  NRADJ-1:adjEnbId=11 |
        | object_should_exist | ${params}

        2) not specify instance id
        | ${params} | create list         | NRADJ:cPlaneIpAddrCtrl=oamControlled |  NRADJ:adjEnbId=11 |
        | ${mo_dn}  | object_should_exist | ${params} |
        """
        return self.cm_base_instant_1._object_should_exist(params, scf, timeout)

    def object_should_not_exist(self, params, scf=None, timeout="120"):
        """This keyword is to check one managedObject should not exist according to the conditions specified in params.
        | step1 | download active scf from GNB if scf None |
        | step2 | check if the managedObject exist according to the conditions |
        | step3 | raise exception if exist |

        | Arguments | Man. | Default | Description |
        | params    |  Yes | NA      | parameters to be check, they must belong to one manageObject |
        | scf       |  No  | None    | scf file, if None, it will download scf from GNB |
        | timeout   |  No  | 120(s)  | the time retry to check scf |

        Format of params:
        | 1) | mo:key=value             | check parameter value |
        | 2) | mo:list:key=value        | check parameter value in list |
        | 3) | mo:list=value1,value2... | check list which only has values  |
        | 4) | mo:list:key=value|condition_key=condition_value  | check list which item structure |

        Note: because the instance of mo may be unknown, this keyword supports format like NRADJ or NRADJ-255.
        for format 3)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        Examples
        1) specify instance id
        | ${params}           | create list | NRADJ-1:cPlaneIpAddrCtrl=oamControlled |  NRADJ-1:adjEnbId=11 |
        | object_should_not_exist | ${params} |

        2) not specify instance id
        | ${params} | create list   | NRADJ:cPlaneIpAddrCtrl=oamControlled |  NRADJ:adjEnbId=11 |
        | object_should_not_exist   | ${params} |
        """
        self.cm_base_instant_1._object_should_not_exist(params, scf, timeout)

    def get_all_cells_id(self):
        """
        get instanceid and lcrid of all cells
        """
        return self.cm_base_instant_1._get_all_cells_id()

    def change_vendor_parameters(self, params):
        """This keyword is to change vendor parameters in local BTS
        | Input Parameters | Man. | Description |
        | params   |  Yes  | parameters to be modified |

        format of argument1 params
        | 1) | list:key=value | modify parameter in list |
        | 2) | key=value | modify normal parameter |
        Example
        | ${parameters_in_vendor} | Create List |  | anrUtraInactivityTimer=5 | lBFastProfile:kLoad=4 |
        | change_vendor_parameters | ${parameters_in_vendor} |
        """
        _mod_vendor = self.cm_base_instant_1._change_vendor(params)
        return _mod_vendor

    def recover_vendor_parameters(self):
        """
        No need to recover vendor because setup_admin in next suite will load default vendor file
        """
        return

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
        self.cm_base_instant_1._change_swconfig(flags, swconfig_file)

    def change_swconfig_file_of_airphone(self, flags, swconfig_file):
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
        self.cm_base_instant_1._change_swconfig_airphone(flags, swconfig_file)

    def change_enb_conf_ini(self, node_type, params):
        """This keyword is to change RD parameters in enb_conf.ini
        | Input Parameters | Man. | Description |
        | node_type        | Man. | node type such as CPCL,CPIF,CPNB,CPUE |
        | params           | Yes |  RD parameters |

        format of params
        | 1) | key=value | modify parameter value, if param not exist, create it |
        Example
        | ${parameters_in_cp_ue_rad} | Create List |  | rdUeContextRequest=True |
        | change_enb_conf_ini | node_type=CPUE | params=${parameters_in_cp_ue_rad} |
        """
        self.cm_base_instant_1._change_enb_conf_ini(node_type, params)

    def recover_enb_config_ini(self):
        self.cm_base_instant_1._recover_enb_config_ini()

    def create_cp_runtime_ini(self, params):
        """This keyword is to change RD parameters in cp_runtime.ini
        | Input Parameters | Man. | Description |
        | params           | Yes |  RD parameters |

        format of params
        | 1) | key=value |

        Example
        | ${parameters} | Create List | rdEnableTrafficManager=True | rdEnableUeIdRangeAllocationViaSdl=True |
        | create_cp_runtime_ini | ${parameters} |
        """
        self.cm_base_instant_1._create_cp_runtime_ini(params)

    def delete_cp_runtime_ini(self):
        self.cm_base_instant_1._delete_cp_runtime_ini()

    def search_params_in_template(self, parameters):
        self.cm_base_instant_1._search_params_in_template(parameters)

    def get_scf_parameter_value(self, param_name, scf=None):
        """This keyword is to get parameter value from active scf of specified scf
        | Arguments  | Man. | Default | Description |
        | param_name | Yes  | NA      | parameter name |
        | scf        | No   | None    | if None, it will download scf from GNB. |

        format of param_name:
        | 1) | mo:key      | get parameter value in managedObject |
        | 2) | mo:list:key | get parameter value in list |

        Example
        | ${value} | get_scf_parameter_value | LNADJ-1:cPlaneIpAddrCtrl |
        | should be equal | ${value} | oamControlled |
        """
        return self.cm_base_instant_1._get_scf_parameter_value(param_name, scf)

    def modify_gnbmirror_slot_config(self, file_path):
        """This keyword is to modify the slot configuration in gnb mirror script by gnb actual configuration
        | Input Parameters | Man. | Description |
         | file_path | Yes | gnbMirroringConfig file which is from gerrit.
         https://gitlabe2.ext.net.nokia.com/juhakang/tools.git

        format of argument1 flags
        | 1) | key=value | modify parameter value, if param not exist, create it |
        Example
        | Modify Gnbmirror Slot Config | ${CURDIR}/../tools/gnbMirroring/gnbMirroringConfig.sh |
        """
        self.cm_base_instant_1._modify_gnbmirror_slot_config(file_path)

    def modify_mirror_script_parameters(self, flags, config_file):
        """This keyword is to modify the specific value in mirror script
        | Input Parameters | Man. | Description |
        | flags | Yes | the parameters what you want to modify.
        | config_file | Yes | MirroringConfig file path which is from gerrit.

        format of argument1 flags
        | 1) | key=value | modify parameter value, if param not exist, create it |
        Example
        | ${params_in_gnbmirror} | Create List | SYSCOM_MIRRORING=true | BACKHAUL_MIRRORING=true |
        | Modify Mirror Script Parameters| ${params_in_gnbmirror}| /home/ute/gnbMirroringConfig.sh |
        """
        self.cm_base_instant_1._modify_mirror_script_parameters(flags, config_file)

    def get_log_from_snapshot_with_name(self, file_name, snapshot_path='', snapshot_name='', timeout='20min'):
        """This keyword is to get log from snapshot for specific file name
        | Input Parameters | Man. | Description |
        | file_name | Yes | the file name what you want to get.
        | snapshot_path | No | the target snapshot file path.
        | snapshot_name | No | the target snapshot file name.
        | timeout | No | the time out on getting target snapshot file.
        Example
        | Get Log From Snapshot With Name | file_name=BTS1_2512_runtime.zip | | |
        """
        return self.cm_base_instant_1._get_log_from_snapshot_with_name(file_name, snapshot_path,
                                                                       snapshot_name, timeout)

    def get_all_physical_cell_ids(self):
        """
        Get Gnb All Cells Physical Cell Ids From Scfc And Return
        """
        return self.cm_base_instant_1._get_all_physical_cell_ids()

    def get_physical_cell_id_for_specific_cell(self, cellIds="1,2"):
        """
        Get Gnb Physical Cell Ids From Specific Cell Id
        """
        return self.cm_base_instant_1._get_physical_cell_id_for_specific_cell(cellIds=cellIds)

    def recover_scf_configuration(self, target_scf):
        """
        This keyword is to recover configuration to specified scf.
        | step1 | download active scf from GNB |
        | step2 | compare current active scf and given scf, get delta file |
        | step3 | perform delta commission with the delta file |
        | step4 | download active scf and compare it with given scf. The keyword will pass if they are same,
        otherwise it will fail |

        | Arguments    | Man. | Default | Description |
        | target_scf   | Yes  | NA      | target scf file |

        Examples:
        | ${scf_full}  | Download SCF |
        | Delta Commission Parameters | xxx |
        | Recover SCF Configuration | ${scf_full} |
        """
        self.cm_base_instant_1._recover_scf_configuration(target_scf)


class cm_gnb2(object):
    def __init__(self):
        alias = "gnb2"
        self.cm_base_instant_2 = cm_base(alias)

    #     def __del__(self):
    #          self.cm_base_instant_2.__del__()

    def _setup_cm_gnb2(self):
        self.cm_base_instant_2.bts_host = builtin_obj.get_variable_value('${GNB2_IP}')  # NG IP
        self.cm_base_instant_2.remote_host = builtin_obj.get_variable_value('${GNB2_PC_IP}')

    def get_rack_position_gnb2(self):
        """
        ute_admin.get_smod_position doesn't support not_commissioned state,
        this keyword uses infomodel to check rack position, not care enb state
        """
        self._setup_cm_gnb2()
        return self.cm_base_instant_2._get_rack_position()

    def get_gnb_fsp_types_gnb2(self):
        """
        Get Gnb FSP board type
        """
        self._setup_cm_gnb2()
        return self.cm_base_instant_2._get_gnb_fsp_types()

    def modify_scf_and_perform_full_commission_gnb2(self, scf_base, parameters):
        """This keyword is to perform full commissioning with the specified parameters.
        | Arguments  | Man. | Description |
        | scf_base   | Yes  | initial startup scf |
        | parameters | Yes  |  parameters to be modified |

        format of parameters and action
        | 1) | mo:key=value | modify parameter of managedObject |
        | 2) | mo:list:key=value | modify list parameters of managedObject, modify all if mutiple items exist |
        | 3) | mo:list=value1,value2... | modify list which only has one parameter in p tag |
        | 4) | mo:list:key=value|condition_key=condition_value  | the list only contains item with
        condition_key=condition_value, key=vaule. Other parameters are same as item 0 in active SCF or template SCF |
        | 5) | delete:mo_name or pattern | delete mo  |
        | 6) | delete:mo_name:list_name or parameter | delete list or parameter |
        | 7) | delete:mo:list:key=value | delete the item that satisfy mo:list:key=value |
        | 8) | mo | create/update MO, this is suggest to be used for empty MO |

        Note:
        1.for format 3)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        2. value could be ${EMPTY}, the parameter will have no value. But condition_value can't be ${EMPTY}

        3. support extension mode for NRBTS and NRCELL. NRBTS will be explained with actual NRBTS instance.
        NRCELL will be extend with all NRCELL instances as all NRCELLs instance.

        4. handle some abnormal scenarios:
        | 1) | MO doesn't exist | create the new MO based on scf template, \
        and modify it with parameters specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |


        Example:
        | ${parameters} | Create List | PSGRP-1:lbpsISONCtlEnabled=true | PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ... | PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon | delete:PSGPR-[^2-3] |
        | ... | delete:PSGPR-1:lbpsPeriodList |
        | ... | delete:PSGRP-1:lbpsPeriodList:lbpsDayOfWeek=Mon | NRCELL/LNREL-1:amleAllowed=false |
        | modify_scf_and_perform_full_commission_gnb2 | C:\\SCFC_1.xml | ${parameters} |
        """
        self._setup_cm_gnb2()
        return self.cm_base_instant_2._modify_scf_and_perform_full_commission(scf_base, parameters)

    def download_scf_gnb2(self):
        """This keyword is to download active SCF from bts
        Example
        | scf_with_full_path | download_scf_gnb2 |
        """
        self._setup_cm_gnb2()
        return self.cm_base_instant_2._download_scf()

    def delta_commission_parameters_gnb2(self, parameters):
        """This keyword is to perform delta commissioning to enb1

        | Input Parameters | Man. | Description |
        | parameters   |  Yes  | parameters to be modified |

        format of parameters and action
        | 1) | mo:key=value | modify parameter of managedObject |
        | 2) | mo:list:key=value | modify list parameters of managedObject, modify all if mutiple items exist |
        | 3) | mo:list=value1,value2... | modify list which only has one parameter in p tag |
        | 4) | mo:list:key=value|condition_key=condition_value  | the list only contains item with
        condition_key=condition_value, key=vaule. Other parameters are same as item 0 in active SCF or template SCF |
        | 5) | delete:mo_name or pattern | delete mo  |
        | 6) | delete:mo_name:list_name or parameter | delete list or parameter |
        | 7) | delete:mo:list:key=value | delete the item that satisfy mo:list:key=value |
        | 8) | mo | create/update MO, this is suggest to be used for empty MO |

        Note:
        1.for format 3)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        2. value could be ${EMPTY}, the parameter will have no value. But condition_value can't be ${EMPTY}

        3. support extension mode for NRBTS and NRCELL. NRBTS will be explained with actual NRBTS instance.
        NRCELL will be extend with all NRCELL instances as all NRCELLs instance.

        4. handle some abnormal scenarios:
        | 1) | MO doesn't exist | create the new MO based on scf template,
        and modify it with parameters specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |

        Example
        | ${delta_parameters} | Create List | PSGRP-1:lbpsISONCtlEnabled=true |
        PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ... | PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon | delete:PSGPR-[^2-3] |
        delete:PSGPR-1:lbpsPeriodList |
        | ... | delete:PSGRP-1:lbpsPeriodList:lbpsDayOfWeek=Mon | delete:LNADJ.* | NRCELL/LNREL-1:amleAllowed=false |
        | delta_commission_parameters_gnb2 | ${delta_parameters} |
        """
        self._setup_cm_gnb2()
        self.cm_base_instant_2._delta_commission_parameters(parameters)

    def object_should_exist_gnb2(self, params, scf=None, timeout="120"):
        """This keyword is to check  managedObject should exist according to the conditions specified in params.
        1. If exist it will return the mo
        2. if not it will raise exception
        | Input Parameters | Man. | Description |
        | params   |  Yes  | parameters to be check |
        | scf  |  No   | scf file, if it is None, this keyword will download scf from BTS |
        | timeout  |  No   | default is 2 minutes |
        format of params:
        | 1) | mo:key=value | check parameter value |
        | 2) | mo:list:key=value | check parameter value in list |
        | 3) | mo:list=value1,value2... | check list which only has one parameter in p tag  |
        Note: because the instance of mo may be unknown, this keyword supports format like LNADJ or LNADJ-255.\n
        for format 3)\n
        mo:list=value1,value2..., here list format is like:\n
        <list name="taList">\n
        <p>100</p>\n
        <p>150</p>\n
        </list>\n
        Example
        | ${params} | create list | LNADJ:cPlaneIpAddrCtrl=oamControlled |  LNADJ:adjEnbId=11
        | ${mo_dn} | object_should_exist_gnb2 | ${params}
        """
        self._setup_cm_gnb2()
        self.cm_base_instant_2._object_should_exist(params, scf, timeout)

    def object_should_not_exist_gnb2(self, params, scf=None, timeout="120"):
        """This keyword is to check if managedObject should not exist according to the conditions specified in params.
        1. If exist it will raise exception
        2. if not it succeeds
        | Input Parameters | Man. | Description |
        | params   |  Yes  | parameters to be check |
        | scf  |  No   | scf file, if it is None, this keyword will download scf from BTS |
        | timeout  |  No   | default is 2 minutes |
        format of params:
        | 1) | mo:key=value | check parameter value |
        | 2) | mo:list:key=value | check parameter value in list |
        | 3) | mo:list=value1,value2... | check list which only has one parameter in p tag  |
        Note: because the instance of mo may be unknown, this keyword supports format like LNADJ or LNADJ-255.\n
        for format 3)\n
        mo:list=value1,value2..., here list format is like:\n
        <list name="taList">\n
        <p>100</p>\n
        <p>150</p>\n
        </list>\n
        Example
        | ${params} | create list | LNADJ:cPlaneIpAddrCtrl=oamControlled |  LNADJ:adjEnbId=11
        | object_should_not_exist_gnb2 | ${params}
        """
        self._setup_cm_gnb2()
        self.cm_base_instant_2._object_should_not_exist(params, scf, timeout)

    def get_all_cells_id_gnb2(self):
        """
        get instanceid and lcrid of all cells
        """
        self._setup_cm_gnb2()
        return self.cm_base_instant_2._get_all_cells_id()

    def change_vendor_parameters_gnb2(self, params):
        """This keyword is to change vendor parameters in TGT1 BTS
        | Input Parameters | Man. | Description |
        | params   |  Yes  | parameters to be modified |

        format of argument1 params
        | 1) | list:key=value | modify parameter in list |
        | 2) | key=value | modify normal parameter |
        Example
        | ${parameters_in_vendor} | Create List |  | anrUtraInactivityTimer=5 | lBFastProfile:kLoad=4 |
        | change_vendor_parameters_gnb2 | ${parameters_in_vendor} |
        """
        self._setup_cm_gnb2()
        self.cm_base_instant_2._change_vendor(params)

    def recover_vendor_parameters_gnb2(self):
        """
        No need to recover vendor because setup_admin in next suite will load default vendor file
        """
        return

    def change_swconfig_file_gnb2(self, flags, swconfig_file=None):
        """This keyword is to change swconfig.txt in current connection
        | Input Parameters | Man. | Description |
        | flags   |  Yes  | parameters to be modified |

        format of argument1 flags
        | 1) | key=value | modify parameter value, if param not exist, create it |
        Example
        | ${parameters_in_swconfig} | Create List |  | 0x100=5 | 0x200=4 |
        | change_swconfig_file_gnb2 | ${parameters_in_swconfig} |
        """
        self._setup_cm_gnb2()
        self.cm_base_instant_2._change_swconfig(flags, swconfig_file)

    def change_enb_conf_ini_gnb2(self, node_type, params):
        """This keyword is to change RD parameters in enb_conf.ini
        | Input Parameters | Man. | Description |
        | node_type        | Man. | node type such as CPCL,CPIF,CPNB,CPUE |
        | params           | Yes |  RD parameters |

        format of params
        | 1) | key=value | modify parameter value, if param not exist, create it |
        Example
        | ${parameters_in_cp_ue_rad} | Create List |  | rdUeContextRequest=True |
        | change_enb_conf_ini_gnb2 | node_type=CPUE | params=${parameters_in_cp_ue_rad} |
        """
        self._setup_cm_gnb2()
        self.cm_base_instant_2._change_enb_conf_ini(node_type, params)

    def recover_enb_config_ini_gnb2(self):
        self._setup_cm_gnb2()
        self.cm_base_instant_2._recover_enb_config_ini()

    def create_cp_runtime_ini_gnb2(self, params):
        """This keyword is to change RD parameters in cp_runtime.ini
        | Input Parameters | Man. | Description |
        | params           | Yes |  RD parameters |

        format of params
        | 1) | key=value |

        Example
        | ${parameters} | Create List | rdEnableTrafficManager=True | rdEnableUeIdRangeAllocationViaSdl=True |
        | create_cp_runtime_ini_gnb2 | ${parameters} |
        """
        self._setup_cm_gnb2()
        self.cm_base_instant_2._create_cp_runtime_ini(params)

    def delete_cp_runtime_ini_gnb2(self):
        self._setup_cm_gnb2()
        self.cm_base_instant_2._delete_cp_runtime_ini()

    def get_scf_parameter_value_gnb2(self, param_name, scf=None):
        """This keyword is to get parameter value from active scf of specified scf
        | Arguments  | Man. | Default | Description |
        | param_name | Yes  | NA      | parameter name |
        | scf        | No   | None    | if None, it will download scf from GNB. |

        format of param_name:
        | 1) | mo:key      | get parameter value in managedObject |
        | 2) | mo:list:key | get parameter value in list |

        Example
        | ${value} | get_scf_parameter_value_gnb2 | LNADJ-1:cPlaneIpAddrCtrl |
        | should be equal | ${value} | oamControlled |
        """
        self._setup_cm_gnb2()
        return self.cm_base_instant_2._get_scf_parameter_value(param_name, scf)

    def modify_gnbmirror_slot_config_gnb2(self, file_path):
        """This keyword is to modify the slot configuration in gnb mirror script by gnb actual configuration
        | Input Parameters | Man. | Description |
         | file_path | Yes | gnbMirroringConfig file which is from gerrit.
         https://gitlabe2.ext.net.nokia.com/juhakang/tools.git

        format of argument1 flags
        | 1) | key=value | modify parameter value, if param not exist, create it |
        Example
        | modify_gnbmirror_slot_config_gnb2 | ${CURDIR}/../tools/gnbMirroring/gnbMirroringConfig.sh |
        """
        self._setup_cm_gnb2()
        self.cm_base_instant_2._modify_gnbmirror_slot_config(file_path)

    def get_all_physical_cell_ids_gnb2(self):
        """
        Get Gnb All Cells Physical Cell Ids From Scfc And Return
        """
        self._setup_cm_gnb2()
        return self.cm_base_instant_2._get_all_physical_cell_ids()

    def get_physical_cell_id_for_specific_cell_gnb2(self, cellIds="1,2"):
        """
        Get Gnb Physical Cell Ids From Specific Cell Id
        """
        self._setup_cm_gnb2()
        return self.cm_base_instant_2._get_physical_cell_id_for_specific_cell(cellIds=cellIds)


class cm_bts(cm_gnb1, cm_gnb2):
    def __init__(self):
        cm_gnb1.__init__(self)
        cm_gnb2.__init__(self)


if __name__ == "__main__":
    obj = cm_bts()
    help(obj)
