# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: yin.zhang
:contact: yin.zhang@nokia.com
"""
import os
import re
import time
import json
import random
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.Collections import Collections
from taf.gnb.oam.coam.admin import admin
from testsuite.Krakow.resources.NJ_Resources.Resources.python.ta_xml import ta_xml
from testsuite.Krakow.resources.NJ_Resources.Resources.python.ta_xml.common_xml import CommonXML
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_CM_lib.common_lib import common_lib
from .reduced_var import STRUCT_REDUCED_FOR_MO, STRUCT_REDUCED_FOR_LIST
import traceback
import testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_SBTS_Configuration as sbtsConfiguration

# from __builtin__ import False
# from __builtin__ import True

xml_declare = "<?xml version='1.0' encoding='UTF-8'?>"

builtin_obj = BuiltIn()
os_obj = OperatingSystem()
xml_obj = ta_xml()
comm_obj = common_lib()
admin_obj = admin()


class cm_base(object):
    def __init__(self):
        self.scf_template_svn = ""
        self.params_definition = {}

    def __del__(self):
        pass

    def download_scf(self, bts_alias="gNB"):
        """This keyword is to download active SCF from bts
        Example
        | scf_with_full_path | downlad_scf |
        """
        save_log_dir = comm_obj._get_save_log_dir(alias)
        timestamp = comm_obj.get_timestamp()
        scf_with_fullpath = os.path.join(save_log_dir, "scf_%s.xml" % timestamp)
        admin_obj.connect_to(bts_host=sbtsConfiguration.sbts_ip, name=bts_alias)
        admin_obj.get_current_scf_file(save_log_dir, "scf_%s.xml" % timestamp, connection=bts_alias)
        admin_obj.teardown(connection=bts_alias)
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
            if "=" in s_mo_param:
                list_name = s_mo_param.rsplit(":")[2].strip()
                item_key = s_mo_param.rsplit(":")[3].split("=")[0].strip()
                item_value = s_mo_param.rsplit(":")[3].split("=")[1].strip()
                tbd_pattern = "//managedObject[matches(@distName, '.*%s$')]" \
                              "//list[@name='%s']//*[@name='%s' and text(" \
                              ")='%s']/.." % (
                                  mo_name, list_name, item_key, item_value)
            else:
                if 1 == s_mo_param.count(":"):
                    tbd_pattern = "//managedObject[matches(@distName, '.*%s($|/.*$)')]" % mo_name
                elif 2 == s_mo_param.count(":"):
                    list_or_param_name = s_mo_param.rsplit(":")[2].strip()
                    tbd_pattern = "//*[matches(@distName, '.*%s$')]//list[@name='%s']|//*[matches(@distName, " \
                                  "'.*%s$')]//p[@name='%s']" % (
                                      mo_name, list_or_param_name, mo_name, list_or_param_name)
                elif 3 == s_mo_param.count(":"):
                    list_name = s_mo_param.rsplit(":")[2].strip()
                    param = s_mo_param.rsplit(":")[3].strip()
                    tbd_pattern = "//*[matches(@distName, '.*%s$')]//list[@name='%s']//p[@name='%s']" % (
                        mo_name, list_name, param)

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
                try:
                    pattern = "*|//managedObject[matches(@distName, '.*%s$')]" % mo_name
                    s_element_mo = xml_obj.read_xml(active_scf, pattern)
                except AssertionError as e:
                    print(e)
                    builtin_obj.log(
                        "ManagedObject %s does not exist in current active_scf. Will Ignore this delete operation.\n" %
                        mo_name)
                    break
                l_mo_object = self._delete_mo_at_list_and_item(s_element_mo, params_classified[mo])

            l_mo_objects.extend(l_mo_object)

        return l_mo_objects

    def _delete_mo_at_mo(self, scf, delete_string):
        delete_list = delete_string.rsplit(":")
        mo_name = delete_list[1]
        # get mo object's first line, also apply for regular expression.
        try:
            pattern = "*|//managedObject[matches(@distName, '.*%s($|/.*$)')]" % mo_name
            s_mo_elements = self._get_multi_mo(scf, pattern)
            return s_mo_elements
        except AssertionError:
            builtin_obj.log("Can't match *|//managedObject[matches(@distName, '.*%s$')]") % mo_name
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
                                                      s_tbd_list + "|//managedObject[matches(@distName, '.*%s$')]" %
                                                      mo_name)
                continue
            if s_element_list != s_element_list_orignal:
                need_delete_flag = True
                builtin_obj.log("The item will be deleted under %s." % list_name)
                s_mo_object = xml_obj.add_xml_element(s_mo_object, None,
                                                      s_element_list +
                                                      "|//managedObject[matches(@distName, '.*%s$')]" %
                                                      mo_name)

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
            return False

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

    def _scf_migration(self, source_scf, bts_alias="gNB"):
        flag = False
        scf_name = source_scf.split("/")[-1]
        full_commission_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        migrated_scf = os.path.join(full_commission_log_dir, "migrated_%s" % scf_name)
        builtin_obj.log("src file is %s" % source_scf)
        builtin_obj.log("migrate file is %s" % migrated_scf)
        try:
            admin_obj.connect_to(bts_host=sbtsConfiguration.sbts_ip, name=bts_alias)
            result = admin_obj.migrate_scf(source_scf, migrated_scf, alias=bts_alias)
            admin_obj.teardown(connection=bts_alias)
            if result['validationResult']['pdlValidationResult']['status'].lower() != 'ok' and source_scf.count(
                    "scf_for_startup.xml"):
                comm_obj.log_to_console_with_time_prefix(
                    "there are relation errors in initial startup scf, "
                    "pls upload right commission file to gitlab 5g-commission to fix them",
                    level="WARN")

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
        #         finally:
        #             if flag is False:
        #                 builtin_obj.log("scf migration does not work,
        #                 pls contact yin.zhang@nokia-sbell.com", level="WARN")
        return migrated_scf

    def _get_all_dns(self, scf, mo_class):
        all_dns = []
        commonxml_obj = CommonXML(scf)
        all_elements = commonxml_obj.get_elements("//*[matches(@class, '.*%s$')]" % mo_class)
        for each_element in all_elements:
            dn = commonxml_obj.get_element_attribute(each_element, "distName")
            all_dns.append(dn)
        all_dns = list(set(all_dns))
        return all_dns

    def _extend_mo(self, parameters, scf, mo_class):
        parameters = comm_obj.remove_empty_from_list(parameters)
        need_extend = False
        for param in parameters:
            if param.count(mo_class) and param.count("%s-" % mo_class) == 0:
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
            # mo:key=value, mo:list:key=value, mo:list:key=value|condition_key=condition_value, mo:list=value1,
            # value2..., mo
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
        out_parameters = self._extend_mo(parameters, scf, "LNCEL")
        out_parameters = self._extend_mo(out_parameters, scf, "LCELL")
        out_parameters = self._extend_mo(out_parameters, scf, "LNBTS")
        # cuicui add to support 5G start
        out_parameters = self._extend_mo(out_parameters, scf, "MRBTS")
        out_parameters = self._extend_mo(out_parameters, scf, "NRBTS")
        # cuicui add to support 5G end
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
        while mo_start < len(parameters):
            # judge list already in params_dict or not
            mo = parameters[mo_start].split(":")[position]
            mo_exist = False
            for key in params_dict.keys():
                if key.endswith(mo) or mo.endswith(key):
                    mo_exist = True
            if mo_exist:
                mo_start = mo_start + 1
                continue
            # key is mo name, values are parameters belong to the mo
            paras_in_mo = []
            paras_in_mo.append(parameters[mo_start])
            for right in range(mo_start + 1, len(parameters)):
                mo_right = parameters[right].split(":")[position]
                if mo.endswith(mo_right) or mo_right.endswith(mo):
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
        while list_start < len(params_cond):
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
            common_xml = CommonXML(mo_element)
            items = common_xml.get_elements(
                "//managedObject[matches(@distName, '.*%s$')]/*[@name='%s']/item" % (mo_name, list_name))
            item0 = items[0]
            # delete old all items
            mo_element = xml_obj.remove_xml_element(mo_element, None,
                                                    "//managedObject[matches(@distName, '.*%s$')]/*[@name='%s']/item" %
                                                    (mo_name, list_name))
            # add new items according to condition
            for param in params_classified[list_name]:
                condition = param.split("|")[1]
                condition_key = condition.split("=")[0]
                condition_value = condition.split("=")[1]
                try:
                    xml_obj.read_xml(mo_element,
                                     "*|//managedObject[matches(@distName, '.*%s$')]/*[@name='%s']/item/*[@name='%s' "
                                     "and text()='%s']" % (
                                         mo_name, list_name, condition_key, condition_value))
                except AssertionError:
                    new_item = xml_declare + common_xml.element_to_string(item0)
                    new_item = xml_obj.modify_xml(new_item, "",
                                                  "text|%s|//*[@name='%s']" % (condition_value, condition_key))
                    mo_element = xml_obj.add_xml_element(mo_element, "",
                                                         new_item + "*|//managedObject[matches(@distName, "
                                                                    "'.*%s$')]/*[@name='%s']" % (mo_name, list_name))
        return mo_element

    def _handle_list_with_only_p_tag(self, mo_element, parameters):
        """
        input parameters: parameters which will be add/update and belong to one MO.

        This keyword is to handle list like:
        <list name="taList">
        <p>125</p>
        <p>100</p>
       </list>

        if parameter contains list like above(format is mo:list=value1,value2), do the following actions
        2) delete all parameter in the list
        3) add parameters value in the list
        """
        parameters_left = Collections().copy_list(parameters)
        for para in parameters:
            if para.count(":") == 1 and para.count("="):
                mo = para.split(":")[0]
                key = para.split(":")[1].split("=")[0]
                value = para.split("=")[1].strip()
                try:
                    tag = xml_obj.read_xml(mo_element,
                                           "tag|//managedObject[matches(@distName, '.*%s$')]/*[@name='%s']" %
                                           (mo, key))
                except Exception:
                    continue
                if tag == "list" and len(value):
                    # delete all p tag
                    mo_element = xml_obj.remove_xml_element(mo_element, None,
                                                            "//managedObject[matches(@distName, '.*%s$')]/*["
                                                            "@name='%s']/p" % (mo, key))
                    # add p tag one by one
                    for p_value in value.split(","):
                        new_p_element = "<p>%s</p>" % p_value
                        mo_element = xml_obj.add_xml_element(mo_element, "",
                                                             new_p_element + "*|//managedObject[matches(@distName, "
                                                                             "'.*%s$')]/*[@name='%s']" % (mo, key))
                    Collections().remove_values_from_list(parameters_left, para)
                elif tag == "list" and len(value) == 0:
                    # delete all items and p elements
                    mo_element = xml_obj.remove_xml_element(mo_element, None,
                                                            "//managedObject[matches(@distName, '.*%s$')]/*["
                                                            "@name='%s']/item" % (mo, key))
                    mo_element = xml_obj.remove_xml_element(mo_element, None,
                                                            "//managedObject[matches(@distName, '.*%s$')]/*["
                                                            "@name='%s']/p" % (mo, key))
                    Collections().remove_values_from_list(parameters_left, para)
        return mo_element, parameters_left

    def _try_parameter(self, mo_element_or_scf, para, active_scf=''):
        """para format is mo:key, mo:list, mo:list:key"""
        builtin_obj.log("zy: trying parameter: %s" % para)
        scf_template_full = os.path.join("/home/ute", "scf_template_full.xml")
        scf_template_for_list = os.path.join("/home/ute", "scf_template_for_list.xml")
        if para.count(":") == 1:
            # mo:key or mo:list
            mo = para.split(":")[0]
            key_or_list = para.split(":")[1]
            xpath_in_normal_scf = "*|//managedObject[matches(@distName, '.*%s$')]/*[@name='%s']" % (
                mo, key_or_list)
            xpath_without_mo = "*|/managedObject/*[@name='%s']" % key_or_list
            xpath_in_scf_supplement = "*|//managedObject[matches(@distName, '.*%s$')]/*[@name='%s']" % (
                "".join(re.split("-[0-9]+", mo)), key_or_list)
            xpath_parent = "//managedObject[matches(@distName, '.*%s$')]" % mo
            scf_template = scf_template_for_list
        elif para.count(":") == 2:
            # mo:list:key
            mo = para.split(":")[0]
            list_name = para.split(":")[1]
            key_name = para.split(":")[2]
            xpath_in_normal_scf = "*|//managedObject[matches(@distName, '.*%s$')]/*[@name='%s']//*[@name='%s']" % (
                mo, list_name, key_name)
            xpath_without_mo = "*|/managedObject/*[@name='%s']//*[@name='%s']" % (
                list_name, key_name)
            xpath_in_scf_supplement = "*|//managedObject[matches(@distName, '.*%s$')]/*[@name='%s']//*[@name='%s']" % (
                "".join(re.split("-[0-9]+", mo)), list_name, key_name)
            xpath_parent = "//managedObject[matches(@distName, '.*%s$')]/*[@name='%s']/item" % (
                mo, list_name)
            scf_template = scf_template_full
        else:
            raise Exception("not support %s" % para)

        # flag true means existing in mo_element_or_scf
        flag = False
        try:
            param_element = xml_obj.read_xml(mo_element_or_scf, xpath_in_normal_scf)
            flag = True
        except AssertionError:
            try:
                # get key or list from active scf
                param_element = xml_obj.read_xml(active_scf, xpath_in_normal_scf)
            except Exception as err_info:
                if len(active_scf):
                    builtin_obj.log(err_info)
                    builtin_obj.log("no %s in active SCFC, will try scfc template" % para)

                mo_template_name, mo_template_element = self._get_mo_template(mo, scf_template)
                try:
                    # get key or list from mo template
                    param_element = xml_obj.read_xml(mo_template_element, xpath_without_mo)
                    builtin_obj.log("get %s under %s in SCFC template(%s) " % (
                        para.partition(":")[-1], mo_template_name, scf_template))
                except AssertionError as err_info:
                    builtin_obj.log(err_info)
                    builtin_obj.log("no %s under %s in SCFC template(%s), will try scfc supplement" % (
                        para.partition(":")[-1], mo_template_name, scf_template))
                    scf_template_path = builtin_obj.get_variable_value("${SCF_TEMPLATE_PATH}")
                    scf_supplement = os.path.join(scf_template_path, "SCFC_1_supplement.xml")
                    try:
                        # get key or list from scfc supplement.xml
                        param_element = xml_obj.read_xml(
                            scf_supplement, xpath_in_scf_supplement)
                        builtin_obj.log("get %s under %s in SCFC supplement(%s) " % (
                            para.partition(":")[-1], "".join(re.split("-[0-9]+", mo)), scf_supplement))
                    except AssertionError as err_info:
                        builtin_obj.log(err_info)
                        raise Exception("no %s under %s in SCFC supplement(%s) " % (
                            para.partition(":")[-1], "".join(re.split("-[0-9]+", mo)), scf_supplement))

        tag = xml_obj.read_xml(param_element, "tag|/*")
        # only get the first item to avoid some parameter in first item and some in other items.
        # here make first item contain as much parameter as possible
        if tag == "list":
            commonxml = CommonXML(param_element)
            get_all_items = commonxml.get_elements("//item")
            if len(get_all_items):
                item0 = xml_declare + commonxml.element_to_string(get_all_items[0])
                param_element = self._get_element_without_children(param_element, "/*")
                param_element = xml_obj.add_xml_element(param_element, "", item0 + "*|/*")

        # add the list into mo_element_or_scf
        if flag is True and tag == "list":
            mo_element_or_scf = xml_obj.remove_xml_element(mo_element_or_scf, None,
                                                           "//managedObject[matches(@distName, '.*%s$')]/*[@name='%s']"
                                                           % (mo, key_or_list))
            mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "", param_element + "|" + xpath_parent)

        if flag is False:
            mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "", param_element + "|" + xpath_parent)
        return mo_element_or_scf

    def _add_or_update_parameters_element(self, mo_element_or_scf, parameters, active_scf=''):
        """add/update parameters value in managedObject element
        | Input Parameters | Man. | Description |
        | mo_element_or_scf  |  Yes  | managedObject or SCF where parameters will be add/update
        | parameters  |  Yes  | parameters to be added/updated, which belong to one mo
        """
        # create parameters elements according to template
        for para in parameters:
            builtin_obj.log("zy: handling parameter: %s" % para)
            if para.split("=")[0].count(":") == 0:
                # mo
                break
            elif para.split("=")[0].count(":") == 1:
                # mo:key=value, mo:list=value1,value2
                mo_element_or_scf = self._try_parameter(mo_element_or_scf, para.split("=")[0], active_scf)
            elif para.split("=")[0].count(":") == 2:
                # mo:list:key=value or mo:list:key=value|condition_key=condition_value
                mo = para.split(":")[0]
                list_name = para.split(":")[1]
                mo_element_or_scf = self._try_parameter(mo_element_or_scf, "%s:%s" % (mo, list_name), active_scf)
                key_name = para.split("=")[0].split(":")[-1]
                mo_element_or_scf = self._try_parameter(mo_element_or_scf, "%s:%s:%s" % (mo, list_name, key_name),
                                                        active_scf)
                if para.count("|") == 1:
                    condition_key_name = para.split("|")[-1].split("=")[0]
                    mo_element_or_scf = self._try_parameter(mo_element_or_scf,
                                                            "%s:%s:%s" % (mo, list_name, condition_key_name),
                                                            active_scf)
            else:
                raise Exception("not support format %s" % para)

        # handle mutiple items
        mo_element_or_scf = self._handle_items(mo_element_or_scf, parameters)

        # handle list with only one parameter
        mo_element_or_scf, parameters_without_special_list = self._handle_list_with_only_p_tag(mo_element_or_scf,
                                                                                               parameters)

        # remove parameters without =
        parametes_to_modify = []
        for param in parameters_without_special_list:
            if param.count("="):
                parametes_to_modify.append(param)

        # modify parameters
        parameters_xpath = comm_obj.match_to_xpath(parametes_to_modify)
        mo_element_or_scf_content = xml_obj.modify_xml(mo_element_or_scf, "", parameters_xpath)
        return mo_element_or_scf_content

    def _update_mo(self, mo_in_scf, parameters, active_scf):
        """create managedObject element with update operation according to the managedObject element in SCF or SCF
        template """
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
            dn_all = sorted(dn_dict.keys())
            for dn in dn_all:
                if dn.endswith("-1"):
                    return dn, dn_dict[dn]
            return dn_all[0], dn_dict[dn_all[0]]
        else:
            raise Exception("no template for %s in file %s" % (mo, scf_template))

    def _get_parameter_definition(self, param, bts_alias="gNB"):
        builtin_obj.log("_get_parameter_definition", console=True)
        out_attrs = {"type": "", "min": "", "max": "", "values": ""}
        mo_class = param.split(":")[0].split("/")[-1].split("-")[0]
        parameter = param.split(":")[-1]
        if "%s/%s" % (mo_class, parameter) in self.params_definition.keys():
            out_attrs = self.params_definition["%s/%s" % (mo_class, parameter)]
            builtin_obj.log("zy: param=%s, new attrs=%s" % (param, out_attrs))
            return out_attrs
        save_log_dir = comm_obj._get_save_log_dir(bts_alias)
        nidd_file = os.path.join(save_log_dir, "nidd.json")
        bbu_type = builtin_obj.get_variable_value("${BBU_TYPE}")
        if bbu_type == 'FSMF':
            run_dir = "/ffs/run"
        else:
            run_dir = "/ffs/run/swpool/OAM"
        if os.path.exists(nidd_file) is False:
            comm_obj.get_enb_file(os.path.join(run_dir, "nidd_*.json"), save_log_dir)
            os_obj.move_file(os.path.join(save_log_dir, "nidd_*.json"), os.path.join(save_log_dir, "nidd.json"))

        with open(nidd_file, 'r') as load_f:
            load_dict = json.load(load_f)
            if param.count(":") == 1:
                attributes = load_dict["%s" % mo_class]["params"]["%s" % parameter]
            elif param.count(":") == 2:
                list = param.split(":")[1]
                attributes = load_dict["%s" % mo_class]["params"]["%s" % list]["params"]["%s" % parameter]
            else:
                builtin_obj.log("zy: not suppport %s" % param)
            builtin_obj.log("zy: param=%s, old attrs=%s" % (param, attributes))
            # if attributes.has_key("step"):
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

            # if attributes.has_key("enumeration"):
            if "enumeration" in attributes:
                out_attrs["type"] = "enum"
                out_attrs["values"] = [each["text"] for each in attributes["enumeration"]]

            # if attributes.has_key("base"):
            if "base" in attributes:
                if attributes["base"] == "boolean":
                    out_attrs["type"] = "enum"
                    out_attrs["values"] = ["true", "false"]

        builtin_obj.log("zy: param=%s, new attrs=%s" % (param, out_attrs))
        self.params_definition["%s/%s" % (mo_class, parameter)] = out_attrs
        return out_attrs

    def _create_mo(self, mo_params, commission_type="delta"):
        """create new managedObject element according to template."""
        mo = mo_params[0].split(":")[0]
        scf_template_for_mo = os.path.join("/home/ute", "scf_template_for_mo.xml")
        # use reduced scf template because sometimes case don't want too many MO parameters
        mo_template_name, mo_template_element = self._get_mo_template(mo, scf_template_for_mo)
        builtin_obj.log("get %s as %s template in SCFC template(%s)" % (mo_template_name, mo, scf_template_for_mo))
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

    def search_params_in_template(self, parameters):
        """
        search parameters in scf template and SCFC_1_supplement.xml
        """
        self.scf_template_svn = "/home/ute/robotlte/testsuite/hangzhou/trunk_sbts/4G_RAN_ASL3_HZH/resources" \
                                "/configuration_file/SCFC_template.xml "
        params_pass = []
        params_fail = []
        scf_template_path = builtin_obj.get_variable_value("${SCF_TEMPLATE_PATH}")
        scf_supplement = os.path.join(scf_template_path, "SCFC_1_supplement.xml")
        scf_template_full = os.path.join("/home/ute", "scf_template_full.xml")
        commonxml1 = CommonXML(scf_template_full)
        commonxml2 = CommonXML(scf_supplement)

        # find mo:key, mo:list, mo:list:key, mo
        params_to_check = []
        parameters = comm_obj.remove_empty_from_list(parameters)
        for param in parameters:
            if param.count("delete"):
                continue
            if param.count("="):
                params_to_check.append(param.split("=")[0])
                if param.count("|"):
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

        # find parameters in scf template and supplement
        for param in params_to_check2:
            param_items = param.split(":")
            if len(param_items) > 3:
                builtin_obj.log("%s: wrong format" % param, level="WARN")
                params_fail.append(param)

            mo = param_items[0]
            mo_in_template = mo.replace("/", r"-\d+/") + r"-\d+"
            xpath_in_template = "//managedObject[matches(@distName, '.*%s$')]" % mo_in_template
            xpath_in_supplement = "//managedObject[matches(@distName, '.*%s$')]" % mo
            if len(param_items) > 1:
                list_or_key = param_items[1]
                xpath_in_template = xpath_in_template + "/*[@name='%s']" % list_or_key
                xpath_in_supplement = xpath_in_supplement + "/*[@name='%s']" % list_or_key

            if len(param_items) > 2:
                list_key = param_items[2]
                xpath_in_template = xpath_in_template + "//*[@name='%s']" % list_key
                xpath_in_supplement = xpath_in_supplement + "//*[@name='%s']" % list_key

            if len(commonxml1.get_elements(xpath_in_template)) or len(commonxml2.get_elements(xpath_in_supplement)):
                params_pass.append(param)
            else:
                builtin_obj.log(
                    "no %s in %s after migrated" % (mo + ":" + ":".join(param_items[1:]), self.scf_template_svn),
                    level="WARN")
                params_fail.append(param)
        if len(params_pass):
            builtin_obj.log("parameters pass checking:")
            for param_pass in params_pass:
                builtin_obj.log("    %s" % param_pass)
        if len(params_fail):
            builtin_obj.log("step: parameters fail checking:")
            for param_fail in params_fail:
                builtin_obj.log("    %s" % param_fail)
            raise Exception(
                "missing parameters in scf template, contact yin.zhang@nokia-sbell.com if no spelling erors confirmed")

    def _convert_delete(self, parameters):
        # convert delete:mo:list/key, delete:mo:list:key to mo:list/key=${EMPTY}, mo:list:key=${EMPTY}
        out = []
        parameters = comm_obj.remove_empty_from_list(parameters)
        for param in parameters:
            if param.count("delete:LNCEL_TDD-0") or param.count("delete:LNCEL_FDD-0"):
                param = "delete:LNCEL/%s" % param.partition(":")[-1]

            if param.count("delete") and param.count(":") > 1 and param.count("=") == 0 and param.count("*") == 0:
                out.append("%s=" % param.partition(":")[-1])
            else:
                out.append(param)
        return out

    def _generate_three_templates(self, bts_alias="gNB"):
        scf_template_path = builtin_obj.get_variable_value("${SCF_TEMPLATE_PATH}")
        self.scf_template_svn = os.path.join(scf_template_path, "SCFC_template.xml")
        builtin_obj.log("scf template is %s and SCFC_1_supplement.xml" % self.scf_template_svn, console=True)

        # one template becomes three template
        scf_template_full = os.path.join("/home/ute", "scf_template_full.xml")
        scf_template_for_mo = os.path.join("/home/ute", "scf_template_for_mo.xml")
        scf_template_for_list = os.path.join("/home/ute", "scf_template_for_list.xml")
        os_obj.copy_file(self.scf_template_svn, scf_template_full)
        if bts_alias == "enb2":
            comm_obj.execute_cmd_on_pc("sed -i 's:MRBTS-1:MRBTS-2:g' %s" % scf_template_full)
            comm_obj.execute_cmd_on_pc("sed -i 's:LNBTS-1:LNBTS-2:g' %s" % scf_template_full)
        self._delete_object_offline(scf_template_full, scf_template_for_mo, STRUCT_REDUCED_FOR_MO)
        self._delete_object_offline(scf_template_full, scf_template_for_list, STRUCT_REDUCED_FOR_LIST)
        self._scf_migration(scf_template_full)
        self._scf_migration(scf_template_for_mo)
        self._scf_migration(scf_template_for_list)

    def _fix_mo_create_error(self, mo, scf, mo_create):
        # if cell is FDD, beamformingInScellAllowed should not be configured into CAREL, but LNCEL-1/CAREL-1 as mo
        # template has it because it is TDD cell
        if mo.rpartition("-")[0].endswith("CAREL"):
            cellTechnology = xml_obj.read_xml(scf,
                                              "text|//managedObject[matches(@distName, '.*%s$')]/p[matches(@name, "
                                              "'cellTechnology')]" % mo.split("/")[-2])
            if cellTechnology == "FDD":
                mo_create = xml_obj.remove_xml_element(mo_create, None,
                                                       "//p[matches(@name, 'beamformingInScellAllowed')]")
        return mo_create

    def _find_mo(self, scf, mo):
        comm_xml = CommonXML(scf)
        elements = comm_xml.get_elements("//managedObject[matches(@distName, '.*%s$')]" % mo)
        if len(elements):
            return True
        else:
            return False

    def _update_scf(self, scf, parameters):
        # convert delete:mo:list/key, delete:mo:list:key to mo:list/key=${EMPTY}, mo:list:key=${EMPTY}
        parameters = self._convert_delete(parameters)
        # check if parameters are in scf template or scf supplement
        self.search_params_in_template(parameters)
        # extend LNCEL and LCELL and LNBTS according scf template
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
                        target_scf_content = self._add_or_update_parameters_element(
                            scf, params_classified[mo])
                        commonxml = CommonXML(target_scf_content)
                        commonxml.save_xml(scf, target_scf_content)
                    else:
                        builtin_obj.log("no %s in %s, create it" % (mo, scf))
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
                if attrs["type"] == "integer" and \
                        int(target_value) >= attrs["min"] and \
                        int(target_value) <= attrs["max"]:
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
        builtin_obj.log("_adapt_param_value", console=True)
        params_to_modify = []
        params = []
        error = entry['feedback']
        related_objects = entry['relatedObjects']
        match = re.search(r"([^<>=]+)([<>=]*)([^<>=]*)", exp, re.I)
        scf_template_full = os.path.join("/home/ute", "scf_template_full.xml")
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
                            params.append("%s:%s" % (
                                obj_param.split(":")[0], "".join(re.split(r"-\d+", param.partition(":")[-1]))))
            else:
                if param.count("LNBTS") == 0 and param.count("LNCEL:") == 0 and param.count(
                        "LNCEL/") == 0 and param.count("LNCEL-") == 0 and param.count("delete") == 0:
                    dn = self._get_all_dns(scf_template_full, param.split(":")[0].split("/")[-1].split("-")[0])[0]
                    if dn.count("LNCEL"):
                        param = "LNCEL/" + param
                # extend mo
                mo_split = param.split(":")[0].split("/")
                if param.count(":") > 0:
                    # mo:list-1/2:key, remove -xx from list
                    param = "%s:%s" % (param.split(":")[0], "".join(re.split(r"-\d+", param.partition(":")[-1])))
                params = param
                for mo in mo_split:
                    params = self._extend_mo(params, self.scf_to_fix, mo.split("-")[0])
                    params = self._extend_mo(params, scf_template_full, mo.split("-")[0])
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
                        modify = "%s=" % param
                        builtin_obj.log("zy: remove %s" % param)
                        params_to_modify.append(modify)
                    elif exp_value != '':
                        modify = "%s=%s" % (param, exp_value)
                        #                         find_conflict = False
                        #                         for param_in in self.params_fixed_all:
                        #                             if param_in.split("=")[0] == param and
                        #                             param_in.split("=")[1] != exp_value:
                        #                                 builtin_obj.log("zy: can't define %s,
                        #                                 because %s is already decided" %(modify, param_in))
                        #                                 find_conflict = True
                        #                         if not find_conflict:
                        #                             builtin_obj.log("zy: define %s" %modify)
                        #                             params_to_modify.append(modify)
                        builtin_obj.log("zy: define %s" % modify)
                        params_to_modify.append(modify)
                    else:
                        builtin_obj.log("zy: can't define %s" % exp)
                        if param.endswith("moPrMappingList:spidLast"):
                            modify = self._adapt_param_value("%s=" % param, user_params, entry)
                            params_to_modify.extend(modify)
                        # it is required that ${CATMPR-1.catMVoLTETab-1.qci1ProtectionTimerCatM} (value: 40s) greater
                        # than ${CATMPR-1.inactivityTimerCatM} (value: 1000s)
                        if param.endswith("catMVoLTETab:qci1ProtectionTimerCatM") and compare == ">" and error.count(
                                "inactivityTimerCatM"):
                            modify = self._adapt_param_value(
                                "%s=%s" % (param, self.params_definition["CATMPR/qci1ProtectionTimerCatM"]["max"]),
                                user_params, entry)
                            params_to_modify.extend(modify)
                            modify = "%s:inactivityTimerCatM=%s" % (param.split(":")[0], int(
                                self.params_definition["CATMPR/qci1ProtectionTimerCatM"]["max"]) - 1)
                            builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                            params_to_modify.append(modify)
                else:
                    builtin_obj.log("zy: %s specified in case, can't be modified" % find_param)
                    # modify pre-conditions
                    if param.endswith("actIfHo") and target_value == "enabled" and error.count("threshold2aHpue"):
                        modify = self._adapt_param_value("LNCEL:threshold2aHpue=", user_params, entry)
                        params_to_modify.extend(modify)
                    elif param.endswith("actConvVoice") and target_value == "true":
                        if error.count("n310Qci1"):
                            modify = self._adapt_param_value("LNCEL:n310Qci1=", user_params, entry)
                            params_to_modify.extend(modify)
                        elif error.count("t310Qci1"):
                            modify = self._adapt_param_value("LNCEL:t310Qci1=", user_params, entry)
                            params_to_modify.extend(modify)
                    elif param.endswith("a2TimeToTriggerActInterFreqMeas") and len(compare) == 0:
                        modify = self._adapt_param_value("LNBTS.actIfHo=disabled", user_params, entry)
                        params_to_modify.extend(modify)
                    elif param.endswith("actHOtoWcdma") and \
                            target_value == "true" and \
                            error.count("actCsfbPsHoToUtra"):
                        modify = self._adapt_param_value("LNBTS.actCsfbPsHoToUtra=false", user_params, entry)
                        params_to_modify.extend(modify)
                    elif param.endswith("LNBTS_FDD-0:actSrvccToWcdma") and target_value == "false" and error.count(
                            "actHOtoWcdma"):
                        modify = self._adapt_param_value("LNBTS:actHOtoWcdma=true", user_params, entry)
                        params_to_modify.extend(modify)
                    elif param.endswith("actEnhAcAndGbrServices") and target_value == "true" and error.count(
                            "actMultGbrBearers"):
                        modify = self._adapt_param_value("LNBTS:actMultGbrBearers=false", user_params, entry)
                        params_to_modify.extend(modify)

                    # mandatory change the required Whenever LNCEL-1 having ${LNCEL-1.cellTechnology} (value: TDD)
                    # equal to TDD, it is required that ${LNRELW-1.utranLbAllowed} (value: true) equal to false
                    elif param.endswith("utranLbAllowed") and target_value == "false":
                        modify = "%s=%s" % (param, target_value)
                        builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                        params_to_modify.append(modify)
                    # It is required that ${LNBTS_TDD-0.actHOtoTdscdma} (value: true) equal to false
                    elif param.endswith("LNBTS_TDD-0:actHOtoTdscdma") and target_value == "false":
                        modify = "%s=%s" % (param, target_value)
                        builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                        params_to_modify.append(modify)
                    # It is required that ${LNBTS_FDD-0.actFlexBbUsage} (value: true) is equal to false if only SMOD
                    # is of type ASI or ASO
                    elif param.endswith(":actFlexBbUsage") and target_value == "false" and error.count(
                            "if only SMOD is of type ASI or ASO"):
                        modify = "%s=%s" % (param, target_value)
                        builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                        params_to_modify.append(modify)
                    # it is required that ${LNCEL_FDD-0.earfcnDL} (value: 4070) equal to (${LNCEL_FDD-0.earfcnUL} (
                    # value: 21900) minus 18000)
                    elif param.endswith(":earfcnUL") and error.count("earfcnDL") and error.count("minus"):
                        modify = "%s=%s" % (param, target_value)
                        builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                        params_to_modify.append(modify)
                    # Whenever LNBTS-1 having ${LNBTS-1.actEmerCallRedir} (value: Enabled) equal to Enabled and ${
                    # LNBTS-1.actCoC2kWcdmaGsmMob} (value: false) equal to false, LNCEL-1 having ${
                    # LNCEL-1.cellTechnology} (value: FDD) is within range FDD|TDD, REDRT-5 having ${
                    # REDRT-5.redirRat} (value: cdma2000HRPD) is within range eutra|cdma20001xRTT|cdma2000HRPD,
                    # it is required that ${REDRT-5.emerCallPrio} (value: 5) is not configured
                    elif param.endswith("csFallBPrio") and len(target_value) == 0 or param.endswith(
                            "emerCallPrio") and len(target_value) == 0:
                        builtin_obj.log("zy: remove %s, not care if it is defined by user or not" % param)
                        params_to_modify.append("%s=" % param)
                    # Whenever LNCEL-1 having embedded assertion valid (Namely: It is required that there exist MOs
                    # LNCEL/LNCEL_FDD), CATMCEL-0 having ${CATMCEL-0.actConvVoiceCatM} (value: true) equal to true,
                    # it is required that ${LNCEL_FDD-0.actCatM} (value: false) equal to true
                    elif param.endswith("actCatM") and target_value == "true" and error.count(
                            "actConvVoiceCatM} (value: true) equal to true"):
                        modify = "%s=%s" % (param, target_value)
                        builtin_obj.log("zy: define %s, not care if it is defined by user or not" % modify)
                        params_to_modify.append(modify)

            return params_to_modify

    def _handle_one_require(self, each_require, user_params, entry):
        params_to_modify = []
        requires = each_require.split(" and ")
        for require in requires:
            builtin_obj.log("zy: handle %s" % require)
            # the set of MOs LNADJ-* ${LNADJ-1.cPlaneIpAddr} (value: 1.1.1.1) must be unique the set of MOs LNADJW-*
            # combination of parameters ${LNADJW-1.uTargetCid} (value: 1)+${LNADJW-1.uTargetRncId} (value: 1)+${
            # LNADJW-1.primaryPlmnId-1.mcc} (value: 262)+${LNADJW-1.primaryPlmnId-1.mnc} (value: 3)+${
            # LNADJW-1.primaryPlmnId-1.mncLength} (value: 2) must be unique the set of MOs LNRELW-* combination of
            # parameters ${LNRELW-1.plmnId-1.mcc} (value: 262)+${LNRELW-1.plmnId-1.mnc} (value: 3)+${
            # LNRELW-1.plmnId-1.mncLength} (value: 2)+${LNRELW-1.uTargetRncId} (value: 1)+${LNRELW-1.uTargetCid} (
            # value: 1) must be unique the set of MOs LNHENB-* ${LNHENB-1.freqEutra} (value: 1700) must be unique
            match = re.search(r"the set of MOs.*\${([a-z]+-1)\S+}.*must be unique", require, re.I)
            if match is not None:
                param = match.group(1)
                builtin_obj.log("zy: remove %s and its children" % param)
                params_to_modify.append("delete:%s" % param)
                params_to_modify.append("delete:%s/.*" % param)
                continue

            # the set of MOs REDRT-* ${REDRT-4.csFallBPrio} (value: 4) must be unique
            match = re.search(r"the set of MOs REDRT-\* (\${REDRT-\d+.*Prio}) \(value: \d+\) must be unique", require,
                              re.I)
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

            # it is required that ${LNCEL-2.loadSettings} (list of 0 items) is configured
            match = re.search(r"^(\S+)\s*\(list of 0 items\) is configured", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value(param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # LNCEL-3.furtherPlmnIdL(list of 0 items).acbFurtherPlmnProfileIdCatM is configured
            match = re.search(r"^(\S+)\s*\(list of 0 items\)(\.\S+) is configured", require, re.I)
            if match is not None:
                param = match.group(1) + ":" + match.group(2)[1:]
                modify = self._adapt_param_value(param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # ${LNCEL-1.threshold2a} (value: -51dBm) is configured
            match = re.search(r".*\s*\(value:.*\) is configured$", require, re.I)
            if match is not None:
                continue

            # it is required that ${LNCEL-4.dlCaMinPcellCqiQci1} (undefined) is configured
            # it is required that ${LNCEL-1.furtherPlmnIdL-1.acbFurtherPlmnProfileIdCatM}(undefined) is configured
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

            # it is required that ${LNCEL_FDD-0.csiRsConfigInfo} (list of 1 items) is not configured
            match = re.search(r"^(\S+)\s*\(list of \d+ items\) is not configured", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value("%s=" % param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that there not exist MOs MRBTS-1/LNBTS-1/CATMPR-1.catMCELevel1-1
            match = re.search(r"there not exist MOs (\S+\.\S+)", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value("%s=" % param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that there exist MOs MRBTS-1/LNBTS-1/LNCEL-3/BBPOOLALLOC
            match = re.search(r"^there exist MOs (\S+)", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value(param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # it is required that LNCEL-1.drxProfile104-1.drxOnDuratT (value: 6) greater/equal to 10
            match = re.search(r"^(\S+)\s*\(value: (\d+)\D*\) greater/equal to (\d+)\D*\)*$", require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(3).strip()
                modify = self._adapt_param_value("%s>=%s" % (param, value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # ${LNCEL_TDD-0.maxNumActUE} (value: 535) is less or equal to 400
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

            # it is required that ${MPUCCH_TDD-0.maxNumRrc} (value: 55) greater/equal to ${LNCEL_TDD-0.maxNumActUE} (
            # value: 535)
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

            # ${MPUCCH_TDD-0.minNumRrc} (value: 10) less/equal to ${LNCEL_TDD-0.maxNumActUE} (value: 2)
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

            # ${MPUCCH_TDD-0.minNumRrc} (value: 10) is equal to ${LNCEL_TDD-0.maxNumActUE} (value: 2)
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

            # it is required that ${CATMPR-1.catMVoLTETab-1.qci1ProtectionTimerCatM} (value: 40s) greater than ${
            # CATMPR-1.inactivityTimerCatM} (value: 170s)
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

            # it is required that ${LNCEL-1.t301Guard} (value: 1990ms) less than ${SIB-0.t301} (value: 400ms)
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

            # ${LNCEL_FDD-0.earfcnDL} (value: 1500) greater/equal to (${LNCEL_FDD-0.earfcnUL} (value: 19400) minus
            # 18000)
            match = re.search(
                r"^(\S+)\s*\(value: (\d+)\D*\) greater/equal to (\S+)\s*\(value: (\d+)\D*\) minus (\d+)\)*$", require,
                re.I)
            if match is not None:
                param1 = match.group(1)
                param1_value = match.group(2).strip()
                param2 = match.group(3)
                param2_value = match.group(4).strip()
                minus_value = match.group(5).strip()
                modify = self._adapt_param_value("%s>=%s" % (param1, int(param2_value) - int(minus_value)),
                                                 user_params,
                                                 entry)
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
                                                 user_params,
                                                 entry)
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
                modify = self._adapt_param_value("%s=%s" % (param1, int(param2_value) - int(minus_value)), user_params,
                                                 entry)
                if len(modify) == 0:
                    modify = self._adapt_param_value("%s=%s" % (param2, int(param1_value) + int(minus_value)),
                                                     user_params, entry)
                params_to_modify.extend(modify)
                continue

            # ${CATMCEL-0.actConvVoiceCatM} (value: true) equal to true
            # it is required that ${LNCEL_FDD-0.actCatM} (value: false) equal to true
            # it is required that ${LNBTS-1.qciTab5-1.schedulType} (value: SIGNALLING) equal to NON-GBR
            # ${LNCEL_TDD-0.maxNumActUE} (value: 535) is equal to 400
            # ${LNBTS_FDD-0.actFlexBbUsage} (value: true) is equal to false if only SMOD is of type ASI
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
                modify = self._adapt_param_value("SIB-0:siWindowLen=%s" % value, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # It is required that LNCEL_FDD.actAutoPucchAlloc equal to true
            match = re.search(r"^(\S+)( is|) equal to (true|false|enabled|disabled)", require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(3).strip()
                modify = self._adapt_param_value("%s=%s" % (param, value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # ${LNCEL_FDD-0.maxNumUeUl} (value: 14) is within range between 1 and 7
            match = re.search(r"^(\S+)\s*\(value: .*\) is within range between (\d+)", require, re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(2).strip()
                modify = self._adapt_param_value("%s=%s" % (param, value), user_params, entry)
                params_to_modify.extend(modify)
                continue

            # not equal to floor(${LNCEL-1.idleLBCellReSelPrio3CC}
            match = re.search(r"not equal to floor\s*(\S+)", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value("%s=" % param, user_params, entry)
                params_to_modify.extend(modify)
                continue

            # floor(IRFIM.idleLBEutCelResPrio2CC) not equal to
            match = re.search(r"floor(\S+) not equal to", require, re.I)
            if match is not None:
                param = match.group(1)
                modify = self._adapt_param_value("%s=" % param, user_params, entry)
                params_to_modify.extend(modify)
                continue
            # LNCEL_TDD.actAutoPucchAlloc equal to LNCEL_TDD.actAutoPucchAlloc
            match = re.search(r"(LNCEL_[FT]DD.actAutoPucchAlloc) equal to LNCEL_[FT]DD.actAutoPucchAlloc", require,
                              re.I)
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
            # Whenever LNCEL_TDD-0 having LNCEL_TDD-0.actAutoPucchAlloc (value: false) equal to false, it is required
            # that parameter maxNumRrc is equal to maxNumActUE + minNumRrcNoDrb Whenever LNCEL_FDD-0 having ${
            # LNCEL_FDD-0.actAutoPucchAlloc} (value: false) equal to false, MPUCCH_FDD-0 having ${
            # MPUCCH_FDD-0.riEnable} (value: true) equal to true and ${MPUCCH_FDD-0.riPerM} (value: 2) not equal to
            # 1, it is required that ${LNCEL-1.actDrx} (value: true) equal to false
            match = re.search(r"having (\S*actAutoPucchAlloc}?)\s+\(value: false\) equal to false", entry['feedback'],
                              re.I)
            if match is not None:
                param = match.group(1)
                params_to_modify = self._adapt_param_value("%s=true" % param, user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                if len(params_to_modify):
                    continue

            # Whenever LNCEL_TDD-0 having ${LNCEL_TDD-0.twoLayerMimoAvSpectralEff} (value: 0.5(bit/s)/Hz) is
            # configured, it is required that ${LNCEL_TDD-0.dlMimoMode} (value: Single Stream Beamforming) is within
            # range Dynamic Open Loop MIMO|Closed Loop Mimo|Closed Loop MIMO (4x2)|Closed Loop MIMO (8x2)|Closed Loop
            # MIMO (4x4)|Closed Loop MIMO (8x4)|Dual Stream Beamforming
            match = re.search(r"having (\S+) \(value: \S+\) is configured, it is required that .*\.dlMimoMode",
                              entry['feedback'], re.I)
            if match is not None:
                param = match.group(1)
                params_to_modify = self._adapt_param_value("%s=" % param, user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever for each LNCEL.furtherPlmnIdL, LNCEL.furtherPlmnIdL.acbFurtherPlmnProfileId is configured,
            # it is required that there exist MOs LNCEL.furtherPlmnIdL
            match = re.search(r"Whenever for each LNCEL\S+, (\S+) is configured, it is required that there exist",
                              entry['feedback'], re.I)
            if match is not None:
                param = match.group(1)
                params_to_modify = self._adapt_param_value(param, user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever CRGPR-1 having ${CRGPR-1.plmnGroupList} (list of 2 items) is configured, it is required that
            # embedded assertion valid (Namely: Whenever for each CRGPR.plmnGroupList, CRGPR.plmnGroupList.mcc equal
            # to ${LNBTS-1.mcc} (value: 244) and CRGPR.plmnGroupList.mnc equal to ${LNBTS-1.mnc} (value: 9) and
            # CRGPR.plmnGroupList.mncLength equal to ${LNBTS-1.mncLength} (value: 2), it is required that there exist
            # MOs CRGPR.plmnGroupList)
            match = re.search(
                r"Whenever CRGPR-(\d+) having.* Whenever for each CRGPR.plmnGroupList, CRGPR.plmnGroupList.mcc equal "
                r"to \${LNBTS-1.mcc} \(value: (\d+)\) and CRGPR.plmnGroupList.mnc equal to \${LNBTS-1.mnc} \(value: ("
                r"\d+)\) and CRGPR.plmnGroupList.mncLength equal to \${LNBTS-1.mncLength} \(value: (\d+)\), "
                r"it is required that there exist MOs CRGPR.plmnGroupList",
                entry['feedback'], re.I)
            if match is not None:
                CRGPR_id = match.group(1)
                mcc = match.group(2)
                mnc = match.group(3)
                mncLength = match.group(4)
                if not self._find_param("plmnGroupList:mcc", user_params)[0] and not \
                        self._find_param("plmnGroupList:mnc", user_params)[0] and not \
                        self._find_param("plmnGroupList:mncLength", user_params)[0]:
                    builtin_obj.log("zy: define CRGPR-%s:plmnGroupList:mnc=%s|mcc=%s" % (CRGPR_id, mnc, mcc))
                    builtin_obj.log(
                        "zy: define CRGPR-%s:plmnGroupList:mncLength=%s|mcc=%s" % (CRGPR_id, mncLength, mcc))
                    builtin_obj.log("zy: define CRGPR-%s:plmnGroupList:groupId=0|mcc=%s" % (CRGPR_id, mcc))
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:mnc=%s|mcc=%s" % (CRGPR_id, mnc, mcc))
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:mncLength=%s|mcc=%s" % (CRGPR_id, mncLength, mcc))
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:groupId=0|mcc=%s" % (CRGPR_id, mcc))
                    builtin_obj.log("zy: define CRGPR-%s:plmnGroupList:mnc=3|mcc=262" % (CRGPR_id))
                    builtin_obj.log("zy: define CRGPR-%s:plmnGroupList:mncLength=2|mcc=262" % (CRGPR_id))
                    builtin_obj.log("zy: define CRGPR-%s:plmnGroupList:groupId=1|mcc=262" % (CRGPR_id))
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:mnc=3|mcc=262" % (CRGPR_id))
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:mncLength=2|mcc=262" % (CRGPR_id))
                    params_try_to_fix.append("CRGPR-%s:plmnGroupList:groupId=1|mcc=262" % (CRGPR_id))
                continue

            # It is required that there exist MOs LNCEL/IAFIM) or ${LNBTS-1.actCsgS1Mobility} (value: true)
            match = re.search(r"It is required that there exist MOs LNCEL/IAFIM", entry['feedback'], re.I)
            if match is not None:
                params_to_modify = self._adapt_param_value("LNCEL/IAFIM-1", user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            match = re.search(
                r"MBSFN_FDD-\* having MBSFN_FDD.mbsfnAreaId equal to \${MBSFNCEL-0.mbsfnAreaInUseList-1} \(value: ("
                r"\d+)\), it is required that there exist MOs MBSFNSYNCAREA_FDD/MBSFN_FDD",
                entry['feedback'], re.I)
            if match is not None:
                param = "MBSFNSYNCAREA_FDD/MBSFN_FDD-%s" % match.group(1)
                params_to_modify = self._adapt_param_value("%s:mbsfnAreaId=%s" % (param, match.group(1)), user_params,
                                                           entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever for each NRDCDPR.nrDcMeasConfig, it is required that there exist MOs NRDCDPR.nrDcMeasConfig
            # Whenever for each NRDCDPR.nrDcQuantityConfig, it is required that there exist MOs
            # NRDCDPR.nrDcQuantityConfig
            match = re.search(r"Whenever for each (\S+), it is required that there exist MOs (\S+)", entry['feedback'],
                              re.I)
            if match is not None:
                if match.group(1) == match.group(2).rstrip(")"):
                    param = match.group(1)
                    params_to_modify = self._adapt_param_value(param, user_params, entry)
                    params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever LNCEL-* having LNCEL.lcrId equal to ${CAREL-1.lcrId} (value: 2), it is required that
            # LNCEL.caPoolId equal to ${LNCEL-1.caPoolId} (value: 1))
            match = re.search(
                r"Whenever LNCEL-\* having LNCEL.lcrId equal to \${CAREL-\d+.lcrId} \(value: (\d)+\), it is required "
                r"that LNCEL.caPoolId equal to \${LNCEL-1.caPoolId} \(value: 1\)",
                entry['feedback'], re.I)
            if match is not None:
                params_to_modify = self._adapt_param_value("LNCEL-%s:caPoolId=1" % match.group(1), user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # it is required that quantity of LNCEL_TDD.srsDlMimoModeDepConf equal to 2
            match = re.search(r"quantity of LNCEL_TDD.srsDlMimoModeDepConf equal to 2", entry['feedback'], re.I)
            if match is not None:
                builtin_obj.log(
                    "zy: define two items in LNCEL/LNCEL_TDD:srsDlMimoModeDepConf, not care if it is defined by user "
                    "or not")
                params_try_to_fix.append(
                    "LNCEL/LNCEL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=nonBeamforming")
                params_try_to_fix.append(
                    "LNCEL/LNCEL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=beamforming")
                continue

            # it is required that quantity of LNCEL_TDD.srsDlMimoModeDepConf equal to 1 and ${
            # LNCEL_TDD-0.srsDlMimoModeDepConf-1.beamformingType} (value: beamforming) equal to nonBeamforming
            match = re.search(
                r"quantity of LNCEL_TDD.srsDlMimoModeDepConf equal to 1 and ("
                r"\S+.srsDlMimoModeDepConf-\d+.beamformingType}) \(value: \S+\) equal to (\S+)",
                entry['feedback'], re.I)
            if match is not None:
                param = match.group(1)
                value = match.group(2)
                param_to_modify = "LNCEL/LNCEL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=%s" % value
                builtin_obj.log("zy: define %s, not care if it is defined by user or not" % param_to_modify)
                params_try_to_fix.append(param_to_modify)
                continue

            # It is required that FEATLADM.actTacPreemption is configured and FEATLADM.actTacPreemption equal to false)
            match = re.search(r"is required that (\S+) is configured and (\S+)( is|) equal to (\S+)",
                              entry['feedback'],
                              re.I)
            if match is not None:
                if match.group(1) == match.group(2):
                    param = match.group(1)
                    value = match.group(4).rstrip(")")
                    params_to_modify = self._adapt_param_value("%s=%s" % (param, value), user_params, entry)
                    params_try_to_fix.extend(params_to_modify)
                    continue

            # it is required that maxNumScells in at least one PCell, where cellTechnology is FDD, must be grater or
            # equal to 3
            match = re.search(
                r"it is required that maxNumScells in at least one PCell, where cellTechnology is FDD, must be ("
                r"grater|greater) or equal to (\d+)",
                entry['feedback'], re.I)
            if match is not None:
                params_to_modify = self._adapt_param_value("LNCEL:maxNumScells=%s" % match.group(2),
                                                           user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever CATMPR-* having CATMPR.catMPrId equal to ${LNCEL_FDD-0.catMProfId}(undefined), it is required
            # that there exist MOs LNBTS/CATMPR
            match = re.search(
                r"Whenever CATMPR-\* having CATMPR.catMPrId equal to (\${LNCEL_FDD-0.catMProfId})\(undefined\), "
                r"it is required that there exist MOs LNBTS/CATMPR",
                entry['feedback'], re.I)
            if match is not None:
                param = match.group(1)
                params_to_modify = self._adapt_param_value(param, user_params, entry)
                params_try_to_fix.extend(params_to_modify)
                continue

            # Whenever ACBPR-* having ACBPR.acbPrId equal to ${LNCEL-1.acbPrimaryPlmnProfileId} (value: 0) and
            # ACBPR.acBarMMTelVoiceOcStatic is configured, it is required that ACBPR.acBarMMTelVoiceOcAutoMin is
            # configured Whenever ACBPR-* having ACBPR.acbPrId equal to ${LNCEL-1.acbPrimaryPlmnProfileId} (value: 0)
            # and ACBPR.acBarMMTelVoiceOcStatic is configured, it is required that ACBPR.acBarMMTelVoiceOcAutoMax is
            # configured
            match = re.search(
                r"Whenever ACBPR-\* having ACBPR.acbPrId equal to \S+ \(value: (\d+)\) and "
                r"ACBPR.acBarMMTelVoiceOcStatic is configured, it is required that ACBPR.("
                r"acBarMMTelVoiceOcAutoMin|acBarMMTelVoiceOcAutoMax) is configured",
                entry['feedback'], re.I)
            if match is not None:
                param_to_modify = "ACBPR-%s:%s" % (match.group(1), match.group(2))
                builtin_obj.log("zy: define %s, not care if it is defined by user or not" % param_to_modify)
                params_try_to_fix.append(param_to_modify)
                continue

            # ###### check last require ######### Whenever MTRACE-1 having ${MTRACE-1.iFMDTList} (list of 1 items) is
            # configured, for each MTRACE.immedMDTControl, MTRACE.immedMDTControl.iFMDTPercentage greater than 0 or
            # MTRACE.immedMDTControl.maxMDTFreqLayers greater than 1, it is required that there exist MOs
            # MRBTS-1/LNBTS-1/CTRLTS-1/MTRACE-1.immedMDTControl
            match = re.search(r"for each \S+\.\S+, (.*), it is required that there exist MOs \S+\.\S+",
                              entry['feedback'], re.I)
            if match is not None:
                last_require = match.group(1)
            else:
                last_require = \
                    re.split('[Ii]t is required that',
                             entry['feedback'].split("if having embedded assertion valid")[0])[
                        -1].strip()

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

    def _fix_relation_error(self, user_params, bts_alias="gNB"):
        # 1. fail new cases if there are any validation errors
        new_case_path = ["rework", "new_feature"]
        suite_path = builtin_obj.get_variable_value("${SUITE_SOURCE}")
        builtin_obj.log("_fix_relation_error: suite_path=%s" % suite_path, console=True)
        for path in new_case_path:
            if suite_path.count(path):
                full_commission_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
                scf_for_startup = os.path.join(full_commission_log_dir, "scf_for_startup.xml")
                admin_obj.connect_to(bts_host=sbtsConfiguration.sbts_ip, name=bts_alias)
                result = admin_obj.validate_scf(scf_for_startup, connection=bts_alias)
                admin_obj.teardown(connection=bts_alias)
                errors = \
                    result['pdlValidationResult']['logs']['relationErrors'] + \
                    result['pdlValidationResult']['logs']['hardwareErrors']
                if len(errors):
                    comm_obj.log_to_console_with_time_prefix(
                        "there are %s validation errors in scf_for_startup.xml" % len(errors), "WARN")
                    raise Exception("new cases are not allowed to involve valdation errors, pls fix them" %
                                    len(errors))
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
        full_commission_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        scf_for_startup = os.path.join(full_commission_log_dir, "scf_for_startup.xml")
        os_obj.copy_file(scf_for_startup, "%s/scf_for_startup_fixing_errors_0.xml" % full_commission_log_dir)
        for time in range(0, max_retry_times):
            old_file = "%s/scf_for_startup_fixing_errors_%s.xml" % (full_commission_log_dir, time)
            new_file = "%s/scf_for_startup_fixing_errors_%s.xml" % (full_commission_log_dir, time + 1)
            try:
                admin_obj.connect_to(bts_host=sbtsConfiguration.sbts_ip, name=bts_alias)
                result = admin_obj.validate_scf(old_file, connection=bts_alias)
                admin_obj.teardown(connection=bts_alias)
            except Exception:
                detail = traceback.format_exc()
                comm_obj.log_to_console_with_time_prefix("fail to fix relation error, contact yin.zhang: %s" % detail,
                                                         "WARN")
                break
            if result['pdlValidationResult']['status'] == "FAIL":
                errors = result['pdlValidationResult']['logs']['relationErrors'] + \
                         result['pdlValidationResult']['logs']['hardwareErrors']
                if time == 0:
                    comm_obj.log_to_console_with_time_prefix(
                        "there are %s validation errors in scf_for_startup.xml, try to auto-fix them" % len(errors),
                        "WARN")
                else:
                    comm_obj.log_to_console_with_time_prefix(
                        "there are still %s validation errors after auto-fixing, try again" % len(errors), "WARN")
                os_obj.copy_file(old_file, new_file)
                try:
                    fix_number = self._try_to_fix_relation_error(new_file, errors, user_params)
                    if fix_number == 0:
                        comm_obj.log_to_console_with_time_prefix(
                            "no validation errors could be auto-fixed any longer, stop auto-fixing", "WARN")
                        break
                except Exception:
                    detail = traceback.format_exc()
                    comm_obj.log_to_console_with_time_prefix(
                        "fail to fix relation error, contact yin.zhang: %s" % detail, "WARN")
                    break
            else:
                fixed = True
                if time == 0:
                    builtin_obj.log("zy: no PDL relation errors")
                else:
                    comm_obj.log_to_console_with_time_prefix("validation errors are auto-fixed", level="WARN")
                    os_obj.copy_file(old_file, scf_for_startup)
                break
        if fixed is False:
            if auto_fix_fail:
                raise Exception("there are still some validation errors, pls fix them, last scf is %s" % new_file)
            else:
                comm_obj.log_to_console_with_time_prefix("revert scf_for_startup.xml", level="WARN")

    def modify_scf_and_perform_full_commission(self, scf_base, parameters, bts_alias="gNB"):

        """This keyword is to perform full commissioning with the specified parameters.
        | Input Parameters | Man. | Description |
        | scf_base  | Yes   | initial startup scf |
        | parameters | Yes |  parameters to be modified. format is same as delta_commission_parameters |

        format of parameters and action
        | 1) | mo:key=value | modify parameter of managedObject |
        | 2) | mo:list:key=value | modify list parameters of managedObject, modify all if mutiple items exist |
        | 3) | mo:list=value1,value2... | modify list which only has one parameter in p tag |
        | 4) | mo:list:key=value|condition_key=condition_value  |
        the list only contains item with condition_key=condition_value, key=vaule.
        Other parameters are same as item 0 in active SCF or template SCF |
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
        | 1) | MO doesn't exist | create the new MO based on scf template,
        and modify it with parameters specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |


        Example:
        | ${parameters} | Create List | PSGRP-1:lbpsISONCtlEnabled=true | PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ... | PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon | delete:PSGPR-[^2-3] |
        delete:PSGPR-1:lbpsPeriodList |
        | ... | delete:PSGRP-1:lbpsPeriodList:lbpsDayOfWeek=Mon | LNCEL/LNREL-1:amleAllowed=false |
        | modify_scf_and_perform_full_commission | C:\\SCFC_1.xml | ${parameters} |

        """
        builtin_obj.log("initial startup scf is %s" % scf_base, console=True)

        # migrate scf_base
        full_commission_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
        scf_for_startup = os.path.join(full_commission_log_dir, "scf_for_startup.xml")
        os_obj.copy_file(scf_base, scf_for_startup)
        migrated_scf = self._scf_migration(scf_for_startup)
        os_obj.move_file(migrated_scf, migrated_scf.replace("startup", "startup_base"))

        # create 3 scf template mme_ip = xml_obj.read_xml(scf_base, "text|//managedObject[matches(@distName,
        # '.*SERVEDAMF-1$')]/*[@name='amfIPAddress']")
        scf_template_full = os.path.join("/home/ute", "scf_template_full.xml")
        scf_template_for_mo = os.path.join("/home/ute", "scf_template_for_mo.xml")
        scf_template_for_list = os.path.join("/home/ute", "scf_template_for_list.xml")
        # if mme_ip != "10.0.1.1":
        # for non-iphy cases, scf template is same as scf_base
        os_obj.copy_file(scf_for_startup, scf_template_full)
        os_obj.copy_file(scf_for_startup, scf_template_for_mo)
        os_obj.copy_file(scf_for_startup, scf_template_for_list)
        self.scf_template_svn = scf_base
        builtin_obj.log("scf template is %s" % self.scf_template_svn, console=True)
        # else:
        #     self._generate_three_templates()

        # update cmData attributes in scf startup
        plan_id = "3221225472"
        mrbts_dn = xml_obj.read_xml(scf_for_startup,
                                    "attrib=distName|//managedObject[matches(@class, '.*MRBTS$')]")
        bts_id = mrbts_dn.split("-")[-1]
        # update cmData
        xml_obj.modify_xml(scf_for_startup, scf_for_startup, "attrib=type|plan|//cmData")
        xml_obj.modify_xml(scf_for_startup, scf_for_startup, "attrib=id|%s|//cmData" % plan_id)
        xml_obj.modify_xml(scf_for_startup, scf_for_startup, "attrib=scope|all|//cmData")

        # update scf startup according to required parameters and try to fix simple relation errors
        if len(parameters) != 0:
            builtin_obj.log("step: update scf_for_startup.xml according to ${PARAMS_IN_SCF}")
            self._update_scf(scf_for_startup, parameters)
        # self._fix_relation_error(parameters)

        # perform full commissioning
        try:
            current_time = builtin_obj.get_time()
            comm_obj.log_to_console_with_time_prefix(
                "step: perform full commissioning in %s with %s" % (bts_alias, scf_for_startup))
            admin_obj.connect_to(bts_host=sbtsConfiguration.sbts_ip, name=bts_alias)
            result = admin_obj.perform_commissioning(scf_for_startup, skip_parameter_relation_errors=True,
                                                     connection=bts_alias)
            admin_obj.teardown(connection=bts_alias)
            #            builtin_obj.log("perform_commissioning: %s" % result, console=True)
            if result['validationResult']['pdlValidationResult']['status'].lower() != 'ok':
                errors = result['validationResult']['pdlValidationResult']['logs']['relationErrors'] + \
                         result['validationResult']['pdlValidationResult']['logs']['hardwareErrors']
                for entry in errors:
                    builtin_obj.log("zy: %s" % entry['feedback'])
                comm_obj.log_to_console_with_time_prefix(
                    "there are %s validation errors during full commission, pls fix them when develop new cases or "
                    "before report PR" % len(
                        errors), level="WARN")
        except Exception as e:
            raise Exception(str(e))
        return scf_for_startup

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

    def _create_delta_file_based_on_mo_elements(self, active_scf, mos, commission_type, bts_alias="gNB"):
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
            save_log_directory = comm_obj._get_save_log_dir(bts_alias)
            delta_file_with_path = os.path.join(save_log_directory,
                                                "delta_file_%s_%s.xml" % (btsid, comm_obj.get_timestamp()))
            raml = self._get_element_without_children(active_scf, "/raml")
            cmData = self._get_element_without_children(active_scf, "//cmData")
            delta_file_content = xml_obj.add_xml_element(raml, "", cmData + "|/raml")
            # add mo elements into delta file
            for mo in mos:
                delta_file_content = xml_obj.add_xml_element(delta_file_content, "", mo + "|//cmData")

            if commission_type == "admin":
                from convert_delta import convert_delta_xml_to_json
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
        mo_list = params_classified.keys()
        mo_list.sort()
        for mo in mo_list:
            if mo == "delete":
                mo_deletes = self._delete_object_online(active_scf, params_classified["delete"])
                mos_delta_1.extend(mo_deletes)
            else:
                try:
                    mo_in_scf = xml_obj.read_xml(active_scf, "*|//managedObject[matches(@distName, '.*%s$')]" % mo)
                    # update parameters of mo
                    if mo.count("LTRACE") or mo.count("MTRACE"):
                        mo_delete_trace, mo_create_trace = self._update_trace(mo_in_scf, params_classified[mo])
                        mos_delta_1.append(mo_delete_trace)
                        mos_delta_2.append(mo_create_trace)
                        one_file_flag = False
                    else:
                        builtin_obj.log("update %s with %s" % (mo, params_classified[mo]))
                        params_to_update = self._remove_same_params_in_scf(active_scf, params_classified[mo])
                        builtin_obj.log(
                            "after remove same value as active scf, parameters need to update: %s" % params_to_update)
                        if len(params_to_update) != 0:
                            mo_update = self._update_mo(mo_in_scf, params_to_update, active_scf)
                            mos_delta_2.append(mo_update)
                except AssertionError as err_info:
                    builtin_obj.log(err_info)
                    builtin_obj.log("no %s in %s, create it" % (mo, active_scf))
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
            # LNCEL:administrativeState sometimes not updated to SCFC, delta file will include it whenever it is same
            # or not as active scfc
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

    def delta_commission_parameters(self, parameters, background=False, bts_alias="gNB"):
        """This keyword is to perform delta commissioning to enb1

        | Input Parameters | Man. | Description |
        | parameters   |  Yes  | parameters to be modified |
        | background   | No | if true, it will not wait delta commission finished,
        it is used for rare case that need executes other action in parallel with delta commission |

        format of parameters and action
        | 1) | mo:key=value | modify parameter of managedObject |
        | 2) | mo:list:key=value | modify list parameters of managedObject, modify all if mutiple items exist |
        | 3) | mo:list=value1,value2... | modify list which only has one parameter in p tag |
        | 4) | mo:list:key=value|condition_key=condition_value  |
        the list only contains item with condition_key=condition_value, key=vaule.
        Other parameters are same as item 0 in active SCF or template SCF |
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
        | 1) | MO doesn't exist | create the new MO based on scf template,
        and modify it with parameters specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |

        Example
        | ${delta_parameters} | Create List | PSGRP-1:lbpsISONCtlEnabled=true |
        PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ... | PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon | delete:PSGPR-[^2-3] |
        delete:PSGPR-1:lbpsPeriodList |
        | ... | delete:PSGRP-1:lbpsPeriodList:lbpsDayOfWeek=Mon | delete:LNADJ.* | LNCEL/LNREL-1:amleAllowed=false |
        | delta_commission_parameters | ${delta_parameters} |
        """
        scf_template_full = os.path.join("/home/ute", "scf_template_full.xml")
        if not os.path.exists(scf_template_full):
            self._generate_three_templates()

        # convert delete:mo:list/key, delete:mo:list:key to mo:list/key=${EMPTY}, mo:list:key=${EMPTY}
        parameters = self._convert_delete(parameters)
        # check if parameters are in scf template or scf supplement
        self.search_params_in_template(parameters)
        save_log_dir = comm_obj._get_save_log_dir(bts_alias)
        try:
            scf = os.path.join(save_log_dir, "scf_%s.xml" % comm_obj.get_timestamp())
            admin_obj.connect_to(bts_host=sbtsConfiguration.sbts_ip, name=bts_alias)
            admin_obj.get_current_scf_file(save_log_dir, "scf_%s.xml" % comm_obj.get_timestamp(), connection=bts_alias)
            admin_obj.teardown(connection=bts_alias)
            builtin_obj.log("step: active scf is %s" % scf)
            delta_files = self._create_delta_file(parameters, scf)
            if len(delta_files) != 0:
                for delta_file in delta_files:
                    builtin_obj.log("step: perform delta commission with %s" % delta_file)
                    if background is False:
                        admin_obj.connect_to(bts_host=sbtsConfiguration.sbts_ip, name=bts_alias)
                        result = admin_obj.perform_delta_recommissioning(delta_file,
                                                                         skip_parameter_relation_errors=True,
                                                                         alias=bts_alias)
                        admin_obj.teardown(connection=bts_alias)
                        if result['validationResult']['pdlValidationResult']['status'].lower() != 'ok':
                            errors = result['validationResult']['pdlValidationResult']['logs']['relationErrors'] + \
                                     result['validationResult']['pdlValidationResult']['logs']['hardwareErrors']
                            for entry in errors:
                                builtin_obj.log("zy: %s" % entry['feedback'])
                            comm_obj.log_to_console_with_time_prefix(
                                "there are %s validation errors during delta commission, pls fix them when develop "
                                "new cases or before report PR" % len(
                                    errors), level="WARN")
                            new_case_path = ["rework", "new_feature"]
                            suite_path = builtin_obj.get_variable_value("${SUITE_SOURCE}")
                            for path in new_case_path:
                                if suite_path.count(path):
                                    raise Exception(
                                        "new cases are not allowed to involve validation errors, pls fix them")

                        scf_after = self.download_scf(bts_alias)
                        builtin_obj.log("step: scf is %s after delta commission" % scf_after)
                        return result
                    else:
                        builtin_obj.log("step: perform delta commission with %s" % delta_file)
                        admin_obj.connect_to(bts_host=sbtsConfiguration.sbts_ip, name=bts_alias)
                        task = admin_obj.run_keyword_in_background("perform_delta_recommissioning", delta_file,
                                                                   skip_parameter_relation_errors=True,
                                                                   alias=bts_alias)
                        admin_obj.teardown(connection=bts_alias)
                        return task
        except Exception as e:
            traceback.print_exc()
            raise Exception(str(e))

    def _object_with_instance_exist_or_not(self, scf, params):
        """
        the mo in params must be full name or short name, for example LNADJ-255
        """
        exist_flag = True
        comm_xml = CommonXML(scf)
        for param in params:
            param_name = param.split("=")[0]
            expected_value = param.split("=")[1]
            param_name_xpath = comm_obj.match_to_xpath(param_name)
            try:
                actual_value = xml_obj.read_xml(scf, "text|%s" % param_name_xpath[0])
                # mo:list=value1,value2...
                if param.count(":") == 1 and actual_value is None:
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

    def object_should_exist(self, params, scf=None, timeout="120"):
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

    def object_should_not_exist(self, params, scf=None, timeout="120"):
        """This keyword is to check if managedObject should not exist
        according to the conditions specified in params.\n
        1. If exist it will raise exception\n
        2. if not it succeeds\n
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

    def get_all_cells_id(self, bts_alias="gNB"):
        """
            get instanceid and lcrid of all cells
        """
        cell_ids = []
        admin_obj.connect_to(bts_host=sbtsConfiguration.sbts_ip, name=bts_alias)
        admin_obj.get_current_scf_file("./", "scf.xml", connection=bts_alias)
        admin_obj.teardown(connection=bts_alias)
        commonxml_obj = CommonXML("scf.xml")
        # all_elements = commonxml_obj.get_elements("//*[matches(@class, '.*LNCEL')]/*[matches(@name, 'lcrId')]")
        all_elements = commonxml_obj.get_elements("//*[matches(@class, '.*LNCEL$')]")
        for each_element in all_elements:
            dn = commonxml_obj.get_element_attribute(each_element, "distName")
            instance_id = dn.rpartition("-")[-1]
            lcr_id = xml_obj.read_xml("scf.xml",
                                      "text|//*[matches(@distName, '.*LNCEL-%s$')]/*[matches(@name, 'lcrId')]" %
                                      instance_id)
            cell_ids.append((instance_id, lcr_id))
        return cell_ids


class cm(cm_base):
    def __init__(self):
        cm_base.__init__(self)
        # cm_base.cm_connect_to(self)

    def __del__(self):
        # cm_base.cm_teardown(self)
        cm_base.__del__(self)


if __name__ == "__main__":
    entry = {}
    entry['feedback'] = ""
    require = "${CATMBPR-1.catMCELevel2-1.pdschRepLevPagCatM} (value: n3) equal to ${" \
              "CATMBPR-1.catMCELevel3-1.pdschRepLevPagCatM} (value: n1) "
    match = re.search(r"(\S+)\s*\(value: (\S+)\)( is|) equal to (\S+)\s*\(value: (\S+)\)", require, re.I)
    if match is not None:
        param1 = match.group(1)
        param1_value = match.group(2).strip()
        param2 = match.group(4)
        param2_value = match.group(5).strip()
        print(param1, param1_value, param2, param2_value)
