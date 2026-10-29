# -*- coding:utf-8 -*-
# Author: Zhang Yin
import os
import sys
import re
try:
    from robot.libraries.BuiltIn import BuiltIn
    from robot.libraries.OperatingSystem import OperatingSystem
except ModuleNotFoundError as e:
    print(e)
    print("[\033[31m ERROR \033[0m ] please switch to virtual env and execute this script again: "
          "source /home/ute/test_repo/bin/activate")
    exit()

from ute_fsmaccess import ute_fsmaccess
from taf.sbts.oam.coam.admin import admin as ute_admin
from compare_scf import compare

cwd = os.path.split(os.path.abspath(__file__))[0]
sys.path.append("{}/../../resources/DevHZ5_lib/src".format(cwd))
sys.path.append("{}/../../resources/DevHZ5_lib/src/base_lib".format(cwd))
try:
    from cm import reduced_var
    from ta_xml import ta_xml
    from ta_xml.common_xml import CommonXML
except Exception:
    raise

xml_obj = ta_xml()
builtin_obj = BuiltIn()
os_obj = OperatingSystem()
xml_declare = "<?xml version='1.0' encoding='UTF-8'?>"


class generate_parameters(object):
    def __init__(self):
        self.enb_build_file = ""
        self.alias = "enb_generate"
        self.bts_host = "192.168.255.129"
        self.bts_port = "443"
        self.use_ssl = True

    def __enter__(self):
        pass

    def __exit__(self, exc_type, exc_val, exc_tb):
        try:
            self.admin_obj.teardown_admin(self.alias)
        except Exception:
            pass

    def _setup(self, log_dir):
        self.admin_obj = ute_admin()
        self.admin_obj.setup_admin(alias=self.alias, bts_port=self.bts_port, use_ssl=self.use_ssl,
                                   bts_host=self.bts_host, admin_api_log_dir="/tmp")
        self.fsm_obj = ute_fsmaccess()
        self.fsm_obj.setup_enb_fsm_access(alias=self.alias, fallback_prompt="#", host=self.bts_host)
        bts_build = self.fsm_obj.get_enb_sw_version(alias=self.alias)
        if bts_build.count("_9999_"):
            # SBTS22R1_ENB_9999_210617_000005
            release_path = "trunk"
        else:
            # SBTS21B_ENB_0000_000236_000000
            release_path = bts_build.split("_")[0]
        self.scf_template_svn = os.path.join(os.path.dirname(__file__),
                                             "../../resources/configuration_file/%s/SCFC_template.xml" % release_path)
        self.scf_supplement = os.path.join(os.path.dirname(__file__),
                                           "../../resources/configuration_file/%s/SCFC_1_supplement.xml"
                                           % release_path)
        self.delta_xml = os.path.join(log_dir, "delta.xml")
        self.parameters_file = os.path.join(log_dir, "parameters.xml")
        self.scf_t = os.path.join(log_dir, "target_scf.xml")
        self.scf_b = os.path.join(log_dir, "base_scf.xml")
        self.comm_xml_t = CommonXML(self.scf_t)
        self.comm_xml_b = CommonXML(self.scf_b)
        self.comm_xml = self.comm_xml_t

        self.scf_template_full = os.path.join(log_dir, "scf_template_full.xml")
        self.scf_template_for_mo = os.path.join(log_dir, "scf_template_for_mo.xml")
        self.scf_template_for_list = os.path.join(log_dir, "scf_template_for_list.xml")

    def __del__(self):
        try:
            self.admin_obj.teardown_admin(alias=self.alias)
            self.fsm_obj.teardown_enb_fsm_access(alias=self.alias)
        except Exception:
            pass

    def _scf_migration(self, source_scf):
        scf_name = source_scf.split("/")[-1]
        migrated_scf = "migrated_%s" % scf_name
        try:
            result = self.admin_obj.migrate_scf(source_scf, migrated_scf, alias=self.alias)
            if os_obj.get_file_size(migrated_scf) > 10000:
                # size > 10KB
                os_obj.move_file(migrated_scf, source_scf)
                flag = True
            else:
                print("fail to migrate %s" % source_scf)
        except Exception as _err:
            print("fail to migrate %s because '%s'" % (source_scf, _err))

    def _generate_three_templates(self):
        # one template becomes three template
        os_obj.copy_file(self.scf_template_svn, self.scf_template_full)
        self._delete_object_offline(self.scf_template_full, self.scf_template_for_mo,
                                    reduced_var.STRUCT_REDUCED_FOR_MO)
        self._delete_object_offline(self.scf_template_for_mo, self.scf_template_for_mo,
                                    reduced_var.STRUCT_REDUCED_FOR_LIST)
        self._delete_object_offline(self.scf_template_full, self.scf_template_for_list,
                                    reduced_var.STRUCT_REDUCED_FOR_LIST)
        self._scf_migration(self.scf_template_full)
        self._scf_migration(self.scf_template_for_mo)
        self._scf_migration(self.scf_template_for_list)
        self.comm_xml_mo = CommonXML(self.scf_template_for_mo)
        self.comm_xml_list = CommonXML(self.scf_template_for_list)
        self.comm_xml_list_s = CommonXML(self.scf_supplement)

    def _delete_object_offline(self, source_scf, target_scf, mos_param):
        for s_mo_param in mos_param:
            if len(s_mo_param.strip()) == 0:
                continue
            mo_name = s_mo_param.rsplit(":")[1].strip()
            if "=" in s_mo_param:
                list_name = s_mo_param.rsplit(":")[2].strip()
                item_key = s_mo_param.rsplit(":")[3].split("=")[0].strip()
                item_value = s_mo_param.rsplit(":")[3].split("=")[1].strip()
                tbd_pattern = "//managedObject[matches(@distName, '.*%s$')]//list[@name='%s']//*[@name='%s' \
                and text()='%s']/.." % (
                    mo_name, list_name, item_key, item_value)
            else:
                if 1 == s_mo_param.count(":"):
                    tbd_pattern = "//managedObject[matches(@distName, '.*%s($|/.*$)')]" % mo_name
                elif 2 == s_mo_param.count(":"):
                    list_or_param_name = s_mo_param.rsplit(":")[2].strip()
                    tbd_pattern = "//*[matches(@distName, '.*%s$')]//list[@name='%s']|" \
                                  "//*[matches(@distName, '.*%s$')]//p[@name='%s']"\
                                  % (mo_name, list_or_param_name, mo_name, list_or_param_name)
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

    def _get_list_info(self, list_e):
        """
        list_e: list element
        return list with dict as value, dict key is parameter name, dict value is parameter value.
        for non-item list, return list with values
        """
        values = []
        if list_e == 0:
            values.append({})
            return values

        children_in_list = self.comm_xml.get_child_elements(list_e)
        for child_list in children_in_list:
            node = self.comm_xml.get_element_tag(child_list)
            if node == "item":
                children_item = self.comm_xml.get_child_elements(child_list)
                item_dict = {}
                for child_item in children_item:
                    p_name = self.comm_xml.get_element_attribute(child_item, "name")
                    p_value = self.comm_xml.get_element_text(child_item)
                    item_dict[p_name] = p_value
                values.append(item_dict)
            else:
                p_value = self.comm_xml.get_element_text(child_list)
                values.append(p_value)
        return values

    def _make_sure_at_least_one_mandatory(self, param_list):
        mandatory_num = 0
        for each in param_list:
            if each.count("#M"):
                mandatory_num = mandatory_num + 1
        if mandatory_num == 0 and len(param_list):
            param_list[0] = param_list[0].replace("#O", "#M")
        return param_list

    def _generate_list_params(self, child_mo, dn):
        file_content = []
        dn_class = dn.split("/")[-1].split("-")[0]
        list_name = self.comm_xml.get_element_attribute(child_mo, "name")
        list_in_base = self.comm_xml_b.get_elements("//managedObject[@distName='%s']/*[@name='%s']" % (dn, list_name))
        list_in_template = self.comm_xml_list.get_elements(
            "//managedObject[matches(@class, '.*:%s$')]/*[@name='%s']" % (dn_class, list_name))
        list_in_supplement = self.comm_xml_list_s.get_elements(
            "//managedObject[matches(@distName, '.*:%s$')]/*[@name='%s']" % (dn_class, list_name))
        # print("handle list %s:%s" % (dn, list_name))
        if len(list_in_base) == 0:
            # create list
            if len(list_in_template):
                list_refer = list_in_template[0]
            elif len(list_in_supplement):
                list_refer = list_in_supplement[0]
            else:
                list_refer = 0
        else:
            list_refer = list_in_base[0]
        items = self._get_list_info(child_mo)
        # print("list items are %s" % items)
        if len(items) == 0:
            file_content.append("#M %s:%s=${EMPTY}" % (dn, list_name))
            return file_content

        items_r = self._get_list_info(list_refer)
        #         print("list items_r are %s" %items_r)
        if isinstance(items[0], dict) is False:
            # update p type list
            file_content.append("#M %s:%s=%s" % (dn, list_name, ",".join(items)))
        else:
            # update item type list, only one item
            if len(items) == 1 and len(items_r) == 1:
                one_item_param_list = []
                for param in items[0].keys():
                    if param in items_r[0]:
                        if items[0][param] == items_r[0][param]:
                            one_item_param_list.append("#O %s:%s:%s=%s" % (dn, list_name, param, items[0][param]))
                        else:
                            one_item_param_list.append("#M %s:%s:%s=%s" % (dn, list_name, param, items[0][param]))
                    else:
                        one_item_param_list.append("#M %s:%s:%s=%s" % (dn, list_name, param, items[0][param]))
                for param in items_r[0].keys():
                    if param not in items[0]:
                        one_item_param_list.append("#M %s:%s:%s=${EMPTY}" % (dn, list_name, param))
                one_item_param_list = self._make_sure_at_least_one_mandatory(one_item_param_list)
                file_content = one_item_param_list
            else:
                # update multiple items
                # select condition_key, which must exist in all items and have different value
                if len(items) == 1:
                    condition_key = list(items[0].keys())[0]
                else:
                    for param in items[0].keys():
                        condition_flag = True
                        for item in items[1:]:
                            if param not in item.keys():
                                condition_flag = False
                                break
                            else:
                                if items[0][param] == item[param]:
                                    condition_flag = False
                                    break
                        if condition_flag:
                            condition_key = param
                            break
                # construct item parameters format
                for item in items:
                    one_item_param_list = []
                    condition_value = item[condition_key]
                    for param in item.keys():
                        if param != condition_key:
                            if param in items_r[0]:
                                if item[param] == items_r[0][param]:
                                    one_item_param_list.append("#O %s:%s:%s=%s|%s=%s"
                                                               % (dn, list_name, param, item[param],
                                                                  condition_key, condition_value))
                                else:
                                    one_item_param_list.append("#M %s:%s:%s=%s|%s=%s"
                                                               % (dn, list_name, param, item[param],
                                                                  condition_key, condition_value))
                            else:
                                one_item_param_list.append("#M %s:%s:%s=%s|%s=%s"
                                                           % (dn, list_name, param, item[param],
                                                              condition_key, condition_value))
                    one_item_param_list = self._make_sure_at_least_one_mandatory(one_item_param_list)
                    file_content.extend(one_item_param_list)
        return file_content

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
            return None, None

    def generate_parameters(self, log_dir):
        print("generating parameters used by commissioning keywords")
        self._setup(log_dir)
        file_content = []
        self._generate_three_templates()
        comm_xml_delta = CommonXML(self.delta_xml)
        mo_elements = comm_xml_delta.get_elements("//managedObject")
        for mo_element in mo_elements:
            file_content.append(self.comm_xml.element_to_string(mo_element))
            dn = self.comm_xml.get_element_attribute(mo_element, "distName")
            dn_class = dn.split("/")[-1].split("-")[0]
            operation = self.comm_xml.get_element_attribute(mo_element, "operation")
            mo_template_name, mo_template_element = self._get_mo_template(dn, self.scf_template_for_mo)
            if operation == "update":
                print("update %s" % dn)
                children_mo = self.comm_xml.get_child_elements(mo_element)
                for child_mo in children_mo:
                    node = self.comm_xml.get_element_tag(child_mo)
                    if node == "p":
                        name = self.comm_xml.get_element_attribute(child_mo, "name")
                        text = self.comm_xml.get_element_text(child_mo)
                        if text is None:
                            text = "${EMPTY}"
                        file_content.append("#M %s:%s=%s" % (dn, name, text))
                    else:
                        lists_content = self._generate_list_params(child_mo, dn)
                        file_content.extend(lists_content)
            elif operation == "delete":
                print("delete %s" % dn)
                file_content.append("#M delete:%s" % dn)
            elif operation == "create":
                print("create %s" % dn)
                create_content = []
                # on the view of target mo, decide each parameter is mandatory or optional
                children_mo = self.comm_xml.get_child_elements(mo_element)
                for child_mo in children_mo:
                    node = self.comm_xml.get_element_tag(child_mo)
                    if node == "p":
                        name = self.comm_xml.get_element_attribute(child_mo, "name")
                        text = self.comm_xml.get_element_text(child_mo)
                        if mo_template_element is None:
                            create_content.append("#M %s:%s=%s" % (dn, name, text))
                        else:
                            try:
                                text_in_template = xml_obj.read_xml(mo_template_element, "text|//*[@name='%s']" % name)
                                if text_in_template != text:
                                    create_content.append("#M %s:%s=%s" % (dn, name, text))
                                else:
                                    create_content.append("#O %s:%s=%s" % (dn, name, text))
                            except Exception:
                                create_content.append("#M %s:%s=%s" % (dn, name, text))
                    else:
                        lists_content = self._generate_list_params(child_mo, dn)
                        create_content.extend(lists_content)

                # on the view of template mo, decide if need to delete parameters/list
                if mo_template_element is not None:
                    children_t = self.comm_xml.get_child_elements(self.comm_xml.string_to_element(mo_template_element))
                    for child in children_t:
                        name = self.comm_xml.get_element_attribute(child, "name")
                        element_in_delta = comm_xml_delta.get_elements("//managedObject[@distName='%s']/*[@name='%s']"
                                                                       % (dn, name))
                        if len(element_in_delta) == 0:
                            create_content.append("#M %s:%s=${EMPTY}" % (dn, name))

                # make sure at least one mandatory paramter
                create_content = self._make_sure_at_least_one_mandatory(create_content)

                # consider case that mo has on children
                if len(create_content) == 0:
                    create_content.append("#M %s" % dn)

                file_content.extend(create_content)
        # save file
        with open(self.parameters_file, "w") as f1:
            for line in file_content:
                if line.startswith("#M") or line.startswith("#O"):
                    if line.count("=") == 0:
                        line = re.sub(r"MRBTS-\d+/NRBTS-\d+", "NRBTS", line)
                        line = re.sub(r"NRBTS/NRCELL", "NRCELL", line)
                    else:
                        mo = line.partition(":")[0]
                        mo = re.sub(r"MRBTS-\d+/NRBTS-\d+", "NRBTS", mo)
                        mo = re.sub(r"NRBTS/NRCELL", "NRCELL", mo)
                        line = mo + ":" + line.partition(":")[-1]
                f1.write(line + "\r\n")
            f1.close()
        print("\nparameters are specified in %s" % self.parameters_file)
        print("More tips: 1) NRBTS and NRCELL support extension mode")
        print("           2) delete support regular expression")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usages: python %s <target_scf> <base_scf>" % sys.argv[0])
    else:
        target_scf = sys.argv[1]
        base_scf = sys.argv[2]
        log_dir = os.path.join(os.path.dirname(__file__), "logs")
        os_obj.remove_directory(log_dir, True)
        compare_obj = compare()
        with compare_obj:
            result = compare_obj.compare_scfs(target_scf, base_scf, log_dir)
        if not result:  # not same
            generate_obj = generate_parameters()
            with generate_obj:
                generate_obj.generate_parameters(log_dir)
