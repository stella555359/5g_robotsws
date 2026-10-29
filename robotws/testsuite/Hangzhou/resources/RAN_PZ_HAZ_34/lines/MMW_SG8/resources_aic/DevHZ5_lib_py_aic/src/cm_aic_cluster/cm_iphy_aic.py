# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Eric Jiang
:contact: eric.jiang@nokia-sbell.com
:maintainer: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

import os
import re
import logging
import shutil
import lxml.objectify
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from ..common_lib_aic import common_lib_aic
from ..base_lib.ta_xml import ta_xml
from ..base_lib.ta_xml.common_xml import CommonXML
from ute_fsmaccess import ute_fsmaccess

builtin_obj = BuiltIn()
os_obj = OperatingSystem()
comm_obj = common_lib_aic()
xml_obj = ta_xml()


# class iphy_xml_base_aic(iphy_xml_base):
#     def __init__(self, alias):
#         iphy_xml_base.__init__(self, alias)
#         super(iphy_xml_base_aic, self).__init__(alias)
class iphy_xml_base_aic(object):
    def __init__(self, alias):
        self.fsm = ute_fsmaccess()
        self.xml = ta_xml()
        self.alias = alias
        self.remote_host = None

    def _get_targetbd_rrutype_aic(self, targetbd_path, rru_type):
        with open(targetbd_path, 'r') as f_obj:
            f_content = f_obj.read()
        ret = re.search(r'\"(\w*%s.*?)\"' % rru_type, f_content, re.M)

        if ret:
            logging.info('read rru info from targetbd file %s' % targetbd_path)
            return ret.group(1)
        else:
            raise Exception(
                "Not find '%s' in '%s'" %
                (rru_type, targetbd_path))

    def _get_obsai_rru_type_from_iphy_xml_aic(self, iphy_xml_path):
        pass

    def _get_cpri_rru_type_from_iphy_xml_aic(self, iphy_xml_path):
        objs = self.xml.evaluate_xml_xpath(iphy_xml_path, "//RE")
        type_list = []
        for i in range(len(objs)):
            resourceBuildKey = self.xml.evaluate_xml_xpath(iphy_xml_path, "text|//RE[%s]//resourceBuildKey" % (i + 1))
            if resourceBuildKey:
                rru_type = self.xml.read_xml(iphy_xml_path, "text|//RE[%s]//resourceBuildKey" % (i + 1))
            else:
                rru_type = self.xml.read_xml(iphy_xml_path, "text|//RE[%s]//cardName" % (i + 1))  # AEQP

            type_list.append(rru_type)

        return list(set(type_list))

    def _chang_iphy_obsai_rru_version_aic(self, iphy_source, iphy_target, type_dict):
        pass

    def _chang_iphy_cpri_rru_version_aic(self, iphy_source, iphy_target, type_dict):
        modify_list = []
        for rru_type in type_dict.keys():
            rru_version = type_dict[rru_type]['rru_version']
            key_list = type_dict[rru_type]['rru_key']
            # update bldVersion and buildversion
            bldversion = self.xml.evaluate_xml_xpath(
                iphy_source, "//buildversion")
            if bldversion:
                modify_list += ["text|%s|//*[text()='%s']/../bldVersion" %
                                (rru_version, rru_type), "text|%s|//*[text()='%s']/../buildversion" %
                                (rru_version, rru_type)]
            else:
                modify_list += ["text|%s|//*[text()='%s']/../bldVersion" %
                                (rru_version, rru_type)]
            # update name and version under software/file
            for i in range(len(key_list)):
                modify_list.append(
                    "text|%s|//*[text()='%s']/../..//soap-config/software/file[%s]/version" %
                    (rru_version, rru_type, i + 1))
                modify_list.append(
                    "text|%s|//*[text()='%s']/../..//soap-config/software/file[%s]/name" %
                    (key_list[i], rru_type, i + 1))
        self.xml.modify_xml(iphy_source, iphy_target, modify_list)
        logging.info("modify %s as %s ok with parameters" %
                     (iphy_source, iphy_target))
        for mod in modify_list:
            logging.info(mod)

    def _modify_iphy_xml_rru_version_aic(self, iphy_source, iphy_target):
        targetbd_path = self._get_du_targetbd_aic()

        self.xml.remove_xml_element(iphy_source, iphy_source, "//*[text()='passive']/..")
        with open(iphy_source, 'r') as f_obj:
            content = f_obj.read()
        if 'OBSAI' in content:
            raise Exception("OBSAI not supported yet, "
                            "pls contact I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com")
        else:
            logging.info('This is cpri type')
            rru_type_list = self._get_cpri_rru_type_from_iphy_xml_aic(iphy_source)  # ["AEQP"]
            rru_dict = self._get_rru_version_and_key_with_xpath_aic(targetbd_path, rru_type_list)
            self._chang_iphy_cpri_rru_version_aic(iphy_source, iphy_target, rru_dict)

    def _get_rru_version_and_key_with_xpath_aic(self, targetbd_path, rru_type_list):
        type_dict = {}
        for rru_type in rru_type_list:
            rru_version, key_list = self._single_rru_verion_aic(targetbd_path, rru_type)
            type_dict[rru_type] = {}
            type_dict[rru_type]['rru_version'] = rru_version
            type_dict[rru_type]['rru_key'] = key_list
        return type_dict

    def _single_rru_verion_aic(self, targetbd_path, rru_type):
        key_list = []
        rru_type = self._get_targetbd_rrutype_aic(targetbd_path, rru_type)  # AEQP --> LTX_AEQP_E1

        # '''
        # //hwResource[@resourceBuildKey="LTX_AEQP_E1"]/swFileKey
        objs = self.xml.evaluate_xml_xpath(targetbd_path, '//hwResource[@resourceBuildKey="%s"]/swFileKey' % rru_type)
        for i in range(len(objs)):
            res = self.xml.read_xml(targetbd_path,
                                    "text|//hwResource[@resourceBuildKey='%s']/swFileKey[%s]" % (rru_type, (i + 1)))
            key_list.append(res)
        # '''
        # xml_obj = lxml.objectify.parse(targetbd_path)
        # key_list = xml_obj.xpath('//hwResource[@resourceBuildKey="%s"]/swFileKey' % rru_type)

        rru_version = self.xml.read_xml(targetbd_path,
                                        "attrib=resourceSWVersion|//hwResource[@resourceBuildKey='%s']" % rru_type)
        builtin_obj.log("Type: %s, RRU version: %s, key list is %s from %s" %
                        (rru_type, rru_version, key_list, targetbd_path))
        return rru_version, key_list

    def _change_iphy_rru_version_aic(self, iphy_source_path):
        comm_obj.log_to_console_with_time_prefix("change version in iphy.xml")
        iphy_target_path = os.path.join(os.path.dirname(iphy_source_path),
                                        "mod_%s" % os.path.basename(iphy_source_path))

        self._modify_iphy_xml_rru_version_aic(iphy_source=iphy_source_path, iphy_target=iphy_target_path)

        self.fsm.setup_wts_fsm_access(prompt=' >', fallback_prompt='#', remote_host=self.remote_host, alias=self.alias)
        self.fsm.put_wts_config_file(iphy_target_path, alias=self.alias)
        os_obj.move_file(iphy_target_path, iphy_source_path)
        self.fsm.teardown_wts_fsm_access(alias=self.alias)

    def _change_xml_setting_aic(self, params, xml_file):
        ''' 20220317
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        out_xml = os.path.join(save_log_dir, xml_file.split("/")[-1])
        params = comm_obj.remove_empty_from_list(params)
        os_obj.copy_file(xml_file, out_xml)
        if len(params):
            comm_obj.log_to_console_with_time_prefix("modify %s in %s" % (params, xml_file.split("/")[-1]))
            for param in params:
                param_name = param.split("=")[0]
                param_value = param.split("=")[1]
                param_xpath = "//" + param_name.replace(":", "//")
                try:
                    # modify value
                    xml_obj.read_xml(out_xml, "text|%s" % param_xpath)
                    xml_obj.modify_xml(out_xml, out_xml, "text|%s|%s" % (param_value, param_xpath))
                except Exception:
                    # add element
                    if param.count(":") == 0:
                        raise Exception(
                            "don't know where to add %s, the format must be like aa:bb=value for new parameter" %
                            param.split("=")[0])
                    parent_xpath = param_xpath.rpartition("//")[0]
                    xml_obj.add_xml_element(out_xml, out_xml, "<%s>%s</%s>|%s" % (
                        param_name.split(":")[-1], param_value, param_name.split(":")[-1], parent_xpath))
        return out_xml
        '''
        # '''
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        out_xml = os.path.join(save_log_dir, xml_file.split("/")[-1])
        params = comm_obj.remove_empty_from_list(params)
        os_obj.copy_file(xml_file, out_xml)
        if len(params) == 0:
            return out_xml

        comm_obj.log_to_console_with_time_prefix("modify %s in %s" % (params, xml_file.split("/")[-1]))
        for param in params:
            if "delete" in param:
                param_name = param.partition(":")[-1]
                param_xpath = "//" + param_name.replace(":", "//")
                try:
                    # delete element
                    xml_obj.read_xml(out_xml, "text|%s" % param_xpath)
                    xml_obj.remove_xml_element(out_xml, out_xml, param_xpath)
                except Exception as e:
                    print(e)
                    builtin_obj.log("no %s in %s, no need action for delete" % (param_name, out_xml))
            else:
                if param.count("|") == 0:
                    # aa[:bb:cc]=value
                    param_name = param.split("=")[0]
                    param_value = param.split("=")[1]
                    param_xpath = "//" + param_name.replace(":", "//")
                    try:
                        # modify value
                        xml_obj.read_xml(out_xml, "text|%s" % param_xpath)
                        xml_obj.modify_xml(out_xml, out_xml, "text|%s|%s" % (param_value, param_xpath))
                    except Exception:
                        # add element
                        if param.count(":") == 0:
                            raise Exception(
                                "don't know where to add %s, the format must be like aa:bb=value for new parameter" %
                                param.split("=")[0])
                        parent_xpath = param_xpath.rpartition("//")[0]
                        xml_obj.add_xml_element(out_xml, out_xml, "<%s>%s</%s>|%s" % (
                            param_name.split(":")[-1], param_value, param_name.split(":")[-1], parent_xpath))
                elif param.count("|") == 1:
                    # aa:bb=xxx|cc=xxx, bb and cc under aa, aa may be contain multiple nodes
                    # only support modify, not support add yet
                    parent_node_xpath = "//" + param.rpartition(":")[0].replace(":", "//")
                    target_node, target_value = param.split("|")[0].rpartition(":")[-1].split("=")
                    cond_key, cond_value = param.split("|")[-1].split("=")
                    param_xpath = "{}/{}[text()='{}']/../{}".format(parent_node_xpath,
                                                                    cond_key,
                                                                    cond_value,
                                                                    target_node)
                    print(param_xpath)
                    xml_obj.modify_xml(out_xml, out_xml, "text|%s|%s" % (target_value, param_xpath))
        return out_xml
        # '''

    def _get_du_targetbd_aic(self):
        self.du_ssh_ip = builtin_obj.get_variable_value("${VDU_SSH_IP}")
        self.du_ssh_user = builtin_obj.get_variable_value("${VDU_SSH_USER}")
        self.du_ssh_pwd = builtin_obj.get_variable_value("${VDU_SSH_PASSWD}")
        self.du_namespace = builtin_obj.get_variable_value("${VDU_NAMESPACE}")
        self.fsm.setup_enb_fsm_access(host=self.du_ssh_ip,
                                      user=self.du_ssh_user,
                                      password=self.du_ssh_pwd,
                                      port=22,
                                      timeout=20.0,
                                      prompt='$ ')
        ret = self.fsm.execute_command_on_enb("kubectl get pod -n %s" % self.du_namespace)
        pod_name = re.search(r".*((po|ute|tl)-oamfh-\d).*", ret, flags=re.I).group(1)

        kubectl_cmd_prefix = "kubectl exec -ti %s -n %s -c ctr-oamfh -- " % (pod_name, self.du_namespace)

        ret = self.fsm.execute_command_on_enb("%s ls -l /ffs/run/RFSW" % kubectl_cmd_prefix)
        targetbd_name = re.search(r".*(TargetBD_.+\.xml).*", ret).group(1)

        # kubectl exec -ti po-cran1-oamfh-0 -n cran1 -c ctr-cran1-oamfh -- cd /ffs/run/RFSW
        # kubectl cp -c ctr-cran1-oamfh cran1/po-cran1-oamfh-0:TargetBD_vDUCNF22R3_GNB_0000_000300_004360.xml
        #               /home/ute/Downloads/TargetBD_vDUCNF22R3_GNB_0000_000300_004360.xml

        targetbd_content = self.fsm.execute_command_on_enb("%s cat -A /ffs/run/RFSW/%s" % (kubectl_cmd_prefix,
                                                                                           targetbd_name))
        targetbd_content = targetbd_content.replace("$", "")  # remove $ at end of every line
        targetbd_path = os.path.join(comm_obj._get_save_log_dir(self.alias), targetbd_name)

        with open(targetbd_path, "w") as f:
            f.write(targetbd_content)
            f.close()
        builtin_obj.log("[Modify And Upload Iphy Xml]: Get TargetBD file %s" % targetbd_path)

        # self.fsm.teardown_enb_fsm_access(alias=self.alias)
        return targetbd_path

    def _adapt_param_under_cells(self, iphy_xml, scf_params, param_name_scf, param_name_in_iphy):
        iphy_params = []
        gnb_cell_ids = []
        f = lxml.objectify.parse(iphy_xml)
        cellsL = f.xpath(".//CPRI-Config/CPRI-RP1-RE_List/RE/hardware/vcellList/vcell")
        if cellsL != []:
            for i in cellsL:
                # print i.cell, i.phy_cell_id, i.GSCN, i.SCS_SSB
                gnb_cell_ids.append(str(i.phy_cell_id))
            gnb_id = str(i.cell).partition(".")[0]

            for param in scf_params:
                if param.count(param_name_scf):
                    value = param.split("=")[-1]
                    if param.lower().count("ssbscs"):
                        value = value.lower().replace("khz", "").strip()  # no unit KHz in iphy.xml
                    if param.count("NRCELL-"):
                        # single cell
                        cell_id = param.split(":")[0].rpartition("-")[-1]
                        gnb_cell_id = "{}.{}".format(gnb_id, cell_id)
                        iphy_params.append("vcell:{}={}|cell={}".format(param_name_in_iphy, value, gnb_cell_id))
                    elif param.count("NRCELL:"):
                        # all cell
                        for gnb_cell_id in gnb_cell_ids:
                            iphy_params.append("vcell:{}={}|cell={}".format(param_name_in_iphy, value, gnb_cell_id))
                    else:
                        raise Exception("wrong format：{}".format(param))
        return iphy_params

    def _modify_and_upload_iphy_xml_aic(self,
                                        iphy_params,
                                        iphy_xml,
                                        params_in_scf_du1,
                                        params_in_scf_du2,
                                        params_in_scf_du3,
                                        params_in_scf_du4,
                                        vdu_fhm_vlan,
                                        vdu2_fhm_vlan,
                                        vdu3_fhm_vlan,
                                        vdu4_fhm_vlan):
        txt = """
        [Modify And Upload Iphy Xml Aic]:
        ${PARAMS_IN_IPHY_XML}:  %s
        ${TEMPLATE_IPHY_XML}:   %s
        ${PARAMS_IN_SCF_DU1}:   %s
        ${PARAMS_IN_SCF_DU2}:   %s
        ${PARAMS_IN_SCF_DU3}:   %s
        ${PARAMS_IN_SCF_DU4}:   %s
        ${VDU_FHM_VLAN}:        %s
        ${VDU2_FHM_VLAN}:       %s
        ${VDU3_FHM_VLAN}:       %s
        ${VDU4_FHM_VLAN}:       %s
        """ % (iphy_params, iphy_xml,
               params_in_scf_du1, params_in_scf_du2, params_in_scf_du3, params_in_scf_du4,
               vdu_fhm_vlan, vdu2_fhm_vlan, vdu3_fhm_vlan, vdu4_fhm_vlan)
        builtin_obj.log(txt, console=False)

        builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[1.1]Start to update @{PARAMS_IN_IPHY_XML} and sync given "
                        "DUs GSCN & SCS_SSB to iphy.xml", console=False)
        # Handle GSCN & SCS_SSB in iphy.xml
        du_scf_params = []
        for du_params_list in [params_in_scf_du1, params_in_scf_du2, params_in_scf_du3, params_in_scf_du4]:
            if len(du_params_list) > 0:
                for i in du_params_list:
                    if re.match(r".*\:(gscnOrSsPbchArfcn|ssbScs)\s*=.*", i.strip()):
                        du_scf_params.append(i)

        if len(du_scf_params) > 0:
            builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[1.2]DUs.xml gscn&scsSSB params: %s" % du_scf_params)
            for tupleT in [("gscnOrSsPbchArfcn", "GSCN"), ("ssbScs", "SCS_SSB")]:
                params_gsnc = self._adapt_param_under_cells(iphy_xml, du_scf_params, tupleT[0], tupleT[1])
                iphy_params.extend(params_gsnc)

        builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[1.3]Need update iphy.xml gscn&scsSSB params:%s" %
                        iphy_params, console=False)
        new_iphy_xml = self._change_xml_setting_aic(params=iphy_params, xml_file=iphy_xml)
        builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[1.4]Download previous %s and update iphy params %s,"
                        "Generate new iphy_xml %s" % (iphy_xml, iphy_params, new_iphy_xml), console=False)

        builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[2.1]Start to modify rru version of iphy.xml",
                        console=False)
        self._modify_iphy_xml_rru_version_aic(iphy_source=new_iphy_xml, iphy_target=new_iphy_xml)
        builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[2.2]Complete to modify change iphy.xml rru version, "
                        "the latest iphy.xml is %s" % new_iphy_xml, console=False)

        builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[2.3]Start to modify preferredVlanId(FHM_VLAN)in iphy.xml",
                        console=False)

        temp_dir = os.path.dirname(iphy_xml)
        du_scf = ""
        du2_scf = ""
        du3_scf = ""
        du4_scf = ""
        fhm_vlan_modify = []
        for i in os.listdir(temp_dir):
            if i == "SCFC_1_du.xml":
                du_scf = os.path.join(temp_dir, i)
            elif i == "SCFC_1_du2.xml":
                du2_scf = os.path.join(temp_dir, i)
            elif i == "SCFC_1_du3.xml":
                du3_scf = os.path.join(temp_dir, i)
            elif i == "SCFC_1_du4.xml":
                du4_scf = os.path.join(temp_dir, i)
        new_iphy_xml_obj = lxml.objectify.parse(new_iphy_xml)
        for tupleT in [(du_scf, vdu_fhm_vlan), (du2_scf, vdu2_fhm_vlan), (du3_scf, vdu3_fhm_vlan),
                       (du4_scf, vdu4_fhm_vlan)]:
            if tupleT[0] != "" and len(str(tupleT[1])) > 0:
                vdu_scfc_info = {}
                du_scf_obj = lxml.objectify.parse(tupleT[0])
                cells_dist_names = du_scf_obj.xpath('.//ns:managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]'
                                                    '/@distName', namespaces={"ns": "raml21.xsd"})
                for cell in cells_dist_names:
                    cell_pci = du_scf_obj.xpath('.//ns:managedObject[@distName="%s"]/ns:p[@name="physCellId"]/text()'
                                                % cell, namespaces={"ns": "raml21.xsd"})[0]
                    cell_technology = du_scf_obj.xpath('.//ns:managedObject[@distName="%s"]/'
                                                       'ns:p[@name="cellTechnology"]/text()' % cell,
                                                       namespaces={"ns": "raml21.xsd"})[0].upper()
                    vdu_scfc_info[cell] = {"pci": cell_pci,
                                           "technology": cell_technology}

                cell_belong_rrus = []
                for cell, infoD in vdu_scfc_info.items():
                    cell_belong_rru = new_iphy_xml_obj.xpath(".//CPRI-Config/CPRI-RP1-RE_List/RE/hardware/"
                                                             "vcellList/vcell/phy_cell_id[text()='%s']/"
                                                             "..//..//../optlink_List/optlink/preferredVlanId"
                                                             % infoD["pci"])
                    if cell_belong_rru != []:
                        xpath_para = "text|%s|//hardware/vcellList/vcell/phy_cell_id[text()='%s']/..//..//../" \
                                     "optlink_List/optlink/preferredVlanId" % (str(tupleT[1]), infoD["pci"])
                        fhm_vlan_modify.append(xpath_para)
                    else:
                        builtin_obj.log("[Modify And Upload Iphy Xml Aic] --Error! this cell belong RRU didn't have "
                                        "preferredVlanId param, please check! DU scfc: %s;  cell info: %s-%s" %
                                        (tupleT[0], cell, infoD), console=False)

                builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[2.3.1]DU: cells_if is %s, "
                                "fhm_vlan_modify is %s." % (vdu_scfc_info, fhm_vlan_modify), console=False)

        builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[2.3.2]Start to modify preferredVlanId in iphy.xml:"
                        "${VDU_FHM_VLAN}=%s, ${VDU2_FHM_VLAN}=%s, ${VDU3_FHM_VLAN}=%s, ${VDU3_FHM_VLAN}=%s"
                        "; Need modify fhm_vlan params=%s"
                        % (vdu_fhm_vlan, vdu2_fhm_vlan, vdu3_fhm_vlan, vdu4_fhm_vlan, fhm_vlan_modify), console=False)

        if fhm_vlan_modify != []:
            iphy_target_xml = os.path.join(os.path.dirname(new_iphy_xml), "mod_%s" % os.path.basename(new_iphy_xml))
            self.xml.modify_xml(source_xml=new_iphy_xml,
                                target_xml=iphy_target_xml,
                                modify_parameters=fhm_vlan_modify)
            builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[2.3.3]Complete modify fhm_vlan: source is %s, "
                            "target is %s" % (new_iphy_xml, iphy_target_xml))
        else:
            iphy_target_xml = shutil.copy2(src=new_iphy_xml,
                                           dst=os.path.join(os.path.dirname(new_iphy_xml),
                                                            "mod_%s" % os.path.basename(new_iphy_xml)))
            builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[2.3.3] The 'fhm_vlan_modify' is NULL, "
                            "directly copy: source is %s, target is %s" % (new_iphy_xml, iphy_target_xml))

        self.fsm.setup_wts_fsm_access(prompt=' >',
                                      fallback_prompt='#',
                                      remote_host=self.remote_host,
                                      alias=self.alias)
        self.fsm.put_wts_config_file(iphy_target_xml, alias=self.alias)
        # os_obj.move_file(iphy_target_xml, new_iphy_xml)
        self.fsm.teardown_wts_fsm_access(alias=self.alias)
        builtin_obj.log("[Modify And Upload Iphy Xml Aic] --[2.3.4]Complete upload target iphy.xml %s to Airphone."
                        % iphy_target_xml)

    def _modify_apoamconfig_aic(self, params, ApOamConfig_xml):
        pass


class iphy_xml_1_aic(object):
    def __init__(self):
        alias = "gnb1"
        self.iphy_xml_base_aic_instance1 = iphy_xml_base_aic(alias)

    def modify_and_upload_iphy_xml_aic(self, iphy_params, iphy_xml, params_in_scf_du1, params_in_scf_du2,
                                       params_in_scf_du3, params_in_scf_du4, vdu_fhm_vlan, vdu2_fhm_vlan,
                                       vdu3_fhm_vlan, vdu4_fhm_vlan):
        self.iphy_xml_base_aic_instance1._modify_and_upload_iphy_xml_aic(iphy_params,
                                                                         iphy_xml,
                                                                         params_in_scf_du1,
                                                                         params_in_scf_du2,
                                                                         params_in_scf_du3,
                                                                         params_in_scf_du4,
                                                                         vdu_fhm_vlan,
                                                                         vdu2_fhm_vlan,
                                                                         vdu3_fhm_vlan,
                                                                         vdu4_fhm_vlan)


class iphy_xml_2_aic(object):
    pass


class cm_iphy_aic(iphy_xml_1_aic):
    def __init__(self):
        iphy_xml_1_aic.__init__(self)


if __name__ == "__main__":
    obj = cm_iphy_aic()
    help(obj)
