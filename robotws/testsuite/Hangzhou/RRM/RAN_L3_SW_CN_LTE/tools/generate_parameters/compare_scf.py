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

from taf.sbts.oam.coam.admin import admin as ute_admin

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

MOS_INGORE = ["SMOD-1"]


class compare(object):
    def __init__(self):
        self.enb_build_file = ""
        self.alias = "enb_compare"
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

    def _sort_scf(self, scf):
        dns = []
        new_mos = []
        comm_xml_obj = CommonXML(scf)
        mo_elements = comm_xml_obj.get_elements("//managedObject")
        for mo in mo_elements:
            dns.append(comm_xml_obj.get_element_attribute(mo, "distName"))
        dns.sort()
        for dn in dns:
            mo_element = comm_xml_obj.get_element("//managedObject[@distName='%s']" % dn)
            new_mos.append(mo_element)
        self._create_scf_file(scf, new_mos, "scf_temp.xml")
        os_obj.move_file("scf_temp.xml", scf)

    def _setup(self, target_scf, base_scf, log_dir):
        os_obj.create_directory(log_dir)
        self.admin_obj = ute_admin()
        self.admin_obj.setup_admin(alias=self.alias, bts_port=self.bts_port, use_ssl=self.use_ssl,
                                   bts_host=self.bts_host, admin_api_log_dir="/tmp")
        self.delta_xml = os.path.join(log_dir, "delta.xml")
        self.scf_t = os.path.join(log_dir, "target_scf.xml")
        self.scf_b = os.path.join(log_dir, "base_scf.xml")
        base_scf = self._find_base_scf_path(base_scf, target_scf)
        print("comparing %s with %s" % (target_scf, base_scf))
        self.admin_obj.migrate_scf(target_scf, self.scf_t, alias=self.alias)
        self.admin_obj.migrate_scf(base_scf, self.scf_b, alias=self.alias)
        self._sort_scf(self.scf_t)
        self._sort_scf(self.scf_b)
        self.comm_xml_t = CommonXML(self.scf_t)
        self.comm_xml_b = CommonXML(self.scf_b)
        self.comm_xml = self.comm_xml_t

    def __del__(self):
        try:
            self.admin_obj.teardown_admin(alias=self.alias)
        except Exception:
            pass

    def _get_bts_info(self, target_scf):
        self.bts_info = {}
        comm_xml = CommonXML(target_scf)
        smod_element = comm_xml.get_element(
            "//managedObject[matches(@distName, '.*/SMOD-1$')]/p[@name='prodCodePlanned']")
        smod_prodcode = comm_xml.get_element_text(smod_element)
        if smod_prodcode == '472181A':
            self.bts_info["bbu_type"] = "FSMF"
        elif smod_prodcode == '473095A':
            self.bts_info["bbu_type"] = "ASIA"
        elif smod_prodcode == '474767A':
            self.bts_info["bbu_type"] = "ASIL"
        elif smod_prodcode == '474021A':
            self.bts_info["bbu_type"] = "ASIK"
        else:
            self.bts_info["bbu_type"] = None
        self.bts_info["bbmod_type"] = None

    def _decide_configurate_files_path(self):
        bbu_type = self.bts_info["bbu_type"]
        bbmod_type = self.bts_info["bbmod_type"]
        scf_template_path = os.path.join(os.path.dirname(__file__), "../../resources/configuration_file")
        if bbu_type == "FSMF":
            sub_path = "IPHY_R3_CONF"
        elif bbu_type == "ASIA":
            sub_path = "IPHY_R4_CONF"
        elif bbu_type == "ASIB" and bbmod_type == "ABIC":
            sub_path = "IPHY_R4B_CONF"
        elif bbu_type == "ASIB" and bbmod_type == "ABIO":
            sub_path = "IPHY_ABIO_CONF"
        elif bbu_type == "ASIL":
            sub_path = "IPHY_ASIL_CONF"
        elif bbu_type == "ASIK":
            sub_path = "AP_KL_CONF"
        elif bbu_type == "ASOE":
            sub_path = "AP_ASOE_CONF"
        else:
            builtin_obj.log("new hw, use IPHY_R4_CONF as CONFIG_PATH", "WARN")
            sub_path = "IPHY_R4_CONF"

        bts_build = self.admin_obj.get_software_info(alias=self.alias)['Active SW version']
        if bts_build.count("_9999_"):
            # SBTS22R1_ENB_9999_210617_000005
            release_path = "trunk"
        else:
            # SBTS21B_ENB_0000_000236_000000
            release_path = bts_build.split("_")[0]
        return "%s/%s/%s" % (scf_template_path, release_path, sub_path)

    def _find_base_scf_path(self, base_scf, target_scf):
        if base_scf.endswith(".xml") is False:
            self._get_bts_info(target_scf)
            path = self._decide_configurate_files_path()
            base_scf = os.path.join(path, base_scf, "SCFC_1.xml")
        return base_scf

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

    def _create_scf_file(self, refer_scf, mos, target_scf):
        if len(mos) == 0:
            with open(target_scf, "w") as f:
                f.close()
            return
        commonxml = CommonXML(refer_scf)
        # create delta file with cmData
        raml = self._get_element_without_children(refer_scf, "/raml")
        cmData = self._get_element_without_children(refer_scf, "//cmData")
        xml_obj.add_xml_element(raml, target_scf, cmData + "|/raml")
        header = commonxml.get_element("//header")
        header = commonxml.element_to_string(header)
        header = re.sub(r" xmlns=\"raml\d*.xsd\"", "", header)
        xml_obj.add_xml_element(target_scf, target_scf, header + "|//cmData")
        # add mo elements into delta file
        for mo in mos:
            # print(mo)
            mo = commonxml.element_to_string(mo)
            mo = re.sub(r" xmlns=\"raml\d*.xsd\"", "", mo)
            xml_obj.add_xml_element(target_scf, target_scf, mo + "|//cmData")

    def _update_mo(self, element_t, element_b):
        dn = self.comm_xml.get_element_attribute(element_t, "distName")
        mo_update = self._get_element_without_children(self.scf_t, "//managedObject[@distName='%s']"
                                                       % dn, "operation=update")
        mo_children_t = self.comm_xml.get_child_elements(element_t)
        mo_children_b = self.comm_xml.get_child_elements(element_b)
        for child_t in mo_children_t:
            name = self.comm_xml.get_element_attribute(child_t, "name")
            child_t = self.comm_xml.element_to_string(child_t)
            child_b = self.comm_xml_b.get_elements("//managedObject[@distName='%s']/*[@name='%s']" % (dn, name))
            if len(child_b) != 0:
                child_b = child_b[0]
                child_b = self.comm_xml.element_to_string(child_b)
                if child_t == child_b:
                    # same child, discarded
                    pass
                else:
                    # update child
                    mo_update = xml_obj.add_xml_element(mo_update, "", child_t + "|//managedObject")
            else:
                # create child
                mo_update = xml_obj.add_xml_element(mo_update, "", child_t + "|//managedObject")

        for child_b in mo_children_b:
            name = self.comm_xml.get_element_attribute(child_b, "name")
            child_t = self.comm_xml_t.get_elements("//managedObject[@distName='%s']/*[@name='%s']" % (dn, name))
            if len(child_t) == 0:
                # delete child
                tag = self.comm_xml.get_element_tag(child_b)
                mo_update = xml_obj.add_xml_element(mo_update, "", "<%s name='%s'></%s>|//managedObject"
                                                    % (tag, name, tag))
        return self.comm_xml.string_to_element(mo_update)

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

    def compare_scfs(self, target_scf, base_scf, log_dir):

        self._setup(target_scf, base_scf, log_dir)
        delta_elements = []
        mo_elements_t = self.comm_xml_t.get_elements("//managedObject")
        mo_elements_b = self.comm_xml_b.get_elements("//managedObject")
        for element_t in mo_elements_t:
            dn = self.comm_xml.get_element_attribute(element_t, "distName")
            if dn.split("/")[-1] in MOS_INGORE:
                continue
            element_b = self.comm_xml_b.get_elements("//managedObject[@distName='%s']" % dn)
            if len(element_b) != 0:
                element_b = element_b[0]
                if self.comm_xml.element_to_string(element_t) == self.comm_xml.element_to_string(element_b):
                    # same mo, discarded
                    pass
                else:
                    # update mo
                    mo_update = self._update_mo(element_t, element_b)
                    delta_elements.append(mo_update)
            else:
                # create mo
                delta_elements.append(element_t)
        for element_b in mo_elements_b:
            dn = self.comm_xml.get_element_attribute(element_b, "distName")
            element_t = self.comm_xml_t.get_elements("//managedObject[@distName='%s']" % dn)
            if len(element_t) == 0:
                # mo delete
                mo_delete = self._get_element_without_children(self.scf_b, "//managedObject[@distName='%s']"
                                                               % dn, "operation=delete")
                mo_delete = self.comm_xml.string_to_element(mo_delete)
                delta_elements.append(mo_delete)
        # save xml
        self._create_scf_file(self.scf_t, delta_elements, self.delta_xml)
        if os.path.getsize(self.delta_xml) == 0:
            print("the two files are same")
            return True
        else:
            return False


if __name__ == "__main__":
    if len(sys.argv) < 3 or len(sys.argv) > 4:
        print("Usages: python %s <target_scf> <base_scf>" % sys.argv[0])
        exit
    else:
        if len(sys.argv) == 3:
            log_dir = "logs"
        else:
            log_dir = sys.argv[3]
        target_scf = sys.argv[1]
        base_scf = sys.argv[2]
        compare_obj = compare()
        with compare_obj:
            compare_obj.compare_scfs(target_scf, base_scf, log_dir)
