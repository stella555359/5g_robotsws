# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import os
import re
import logging as log

from robot.libraries.OperatingSystem import OperatingSystem
from ute_fsmaccess import ute_fsmaccess
from base_lib.ta_xml import ta_xml
from base_lib.ta_xml.common_xml import CommonXML
from common_lib import common_lib
from robot.libraries.BuiltIn import BuiltIn

xml_obj = ta_xml()
os_obj = OperatingSystem()
comm_obj = common_lib()
builtin_obj = BuiltIn()


class iphy_xml_base():
    'iphy xml modify'

    def __init__(self, alias):
        ''
        self.fsm = ute_fsmaccess()
        self.xml = ta_xml()
        self.alias = alias
        self.remote_host = None
        self._setup_wts_comm_flag = False

    def _setup_wts_common(self):
        if not self._setup_wts_comm_flag:
            self._setup_wts_comm_flag = True
            self.fsm.setup_wts_fsm_access(
                prompt=' >',
                fallback_prompt='#',
                remote_host=self.remote_host, alias=self.alias)

    def _get_targetbd_rrutype(self, targetbd_path, rru_type):
        with open(targetbd_path, 'r') as f_obj:
            f_content = f_obj.read()
        ret = re.search(r'\"(\w*%s.*?)\"' % rru_type, f_content, re.M)

        if ret:
            log.info('read rru info from targetbd file %s' % targetbd_path)
            return ret.group(1)
        else:
            raise Exception(
                "Not find '%s' in '%s'" %
                (rru_type, targetbd_path))

    def _get_obsai_rru_type_from_iphy_xml(self, iphy_xml_path):
        objs = self.xml.evaluate_xml_xpath(iphy_xml_path,
                                           "//RRH")
        type_list = []
        for i in range(len(objs)):
            rru_type = self.xml.read_xml(
                iphy_xml_path, "text|//RRH[%s]//productname" %
                               (i + 1))

            type_list.append(rru_type)

        log.info(
            "Get RRU type is %s from %s" %
            (set(type_list), iphy_xml_path))
        return list(set(type_list))

    def _get_cpri_rru_type_from_iphy_xml(self, iphy_xml_path):
        objs = self.xml.evaluate_xml_xpath(iphy_xml_path,
                                           "//RE")
        type_list = []
        for i in range(len(objs)):
            # get resourceBuildKey at first, if resourceBuildKey not exist , then get cardName
            resourceBuildKey = self.xml.evaluate_xml_xpath(
                iphy_xml_path, "text|//RE[%s]//resourceBuildKey" % (i + 1))
            if resourceBuildKey:
                rru_type = self.xml.read_xml(
                    iphy_xml_path, "text|//RE[%s]//resourceBuildKey" % (i + 1))
            else:
                rru_type = self.xml.read_xml(
                    iphy_xml_path, "text|//RE[%s]//cardName" % (i + 1))

            type_list.append(rru_type)

        log.info(
            "Get RRU type is %s from %s" %
            (set(type_list), iphy_xml_path))
        return list(set(type_list))

    def _chang_iphy_obsai_rru_version(
            self, iphy_source, iphy_target, type_dict):
        modify_list = []
        for rru_type in type_dict.keys():
            rru_version = type_dict[rru_type]['rru_version']
            key_list = type_dict[rru_type]['rru_key']
            print(rru_type, rru_version, key_list)
            modify_list += ["text|%s|//*[text()='%s']/../buildname" % (rru_version, rru_type)]
            for i in range(len(key_list)):
                version = key_list[i].split(".")[0].split("_", 1)[1]
                modify_list.append(
                    "text|%s|//*[text()='%s']/../..//soap-config/software/file[%s]/version" %
                    (version, rru_type, i + 1))
                modify_list.append(
                    "text|%s|//*[text()='%s']/../..//soap-config/software/file[%s]/name" %
                    (key_list[i], rru_type, i + 1))

        self.xml.modify_xml(iphy_source, iphy_target, modify_list)
        log.info("modify %s as %s ok with parameters" %
                 (iphy_source, iphy_target))
        for mod in modify_list:
            log.info(mod)

    def _chang_iphy_cpri_rru_version(
            self, iphy_source, iphy_target, type_dict):
        modify_list = []
        for rru_type in type_dict.keys():
            rru_version = type_dict[rru_type]['rru_version']
            key_list = type_dict[rru_type]['rru_key']
            print(rru_type, rru_version, key_list)
            # update bldVersion and buildversion
            bldversion = self.xml.evaluate_xml_xpath(
                iphy_source, "//bldversion")
            if bldversion:
                modify_list += ["text|%s|//*[text()='%s']/../bldVersion" % (rru_version, rru_type)]
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
        log.info("modify %s as %s ok with parameters" %
                 (iphy_source, iphy_target))
        for mod in modify_list:
            log.info(mod)

    def _modify_iphy_xml_rru_version(
            self, iphy_source, iphy_target):
        """modify iphy xml rru version
        | Input Parameters | Man. | Description |
        | iphy_source      | Yes  | path of source iphy.xml |
        | iphy_target      | Yes  | path of target iphy.xml |

        | Return | sw_version |
        Example
        | modify_iphy_xml_rru_version | d://iphy_source.xml | d://iphy_target.xml  |
        """
        targetBD_folder = os.path.dirname(iphy_source)
        if targetBD_folder == '':
            raise Exception("Iphy Xml Path should be absolute path")
        self.fsm.setup_enb_fsm_access(
            prompt=' >',
            fallback_prompt='#',
            remote_host=self.remote_host, alias=self.alias)
        targetBD_path = self.fsm.get_enb_targetbd_file('%s/' % targetBD_folder, alias=self.alias)
        log.info('targetBd is %s' % targetBD_path)
        self.fsm.teardown_enb_fsm_access(alias=self.alias)
        self.xml.remove_xml_element(
            iphy_source,
            iphy_source,
            "//*[text()='passive']/..")
        with open(iphy_source, 'r') as f_obj:
            content = f_obj.read()
        if 'OBSAI' in content:
            raise Exception("obsai not supported yet, "
                            "pls contact I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com")
        else:
            log.info('this is cpri type')
            rru_type = self._get_cpri_rru_type_from_iphy_xml(iphy_source)
            if "ORAN" in rru_type:
                # ORAN RRU doesn't exist in TargetBD, no version in iphy.xml
                # os_obj.copy_file(iphy_source, iphy_target)
                rru_type_non_oran = []
                for rf_hw_type in rru_type:
                    if rf_hw_type != "ORAN":
                        rru_type_non_oran.append(rf_hw_type)
                if len(rru_type_non_oran) > 0:
                    rru_dict = self._get_rru_version_and_key_with_xpath(targetBD_path, rru_type_non_oran)
                    self._chang_iphy_cpri_rru_version(iphy_source, iphy_target, rru_dict)
                else:
                    os_obj.copy_file(iphy_source, iphy_target)
            else:
                rru_dict = self._get_rru_version_and_key_with_xpath(
                    targetBD_path, rru_type)
                self._chang_iphy_cpri_rru_version(
                    iphy_source, iphy_target, rru_dict)

    def _get_rru_version_and_key_with_xpath(
            self, targetbd_path, rru_type_list):
        type_dict = {}
        for rru_type in rru_type_list:
            rru_version, key_list = self._single_rru_verion(
                targetbd_path, rru_type)
            type_dict[rru_type] = {}
            type_dict[rru_type]['rru_version'] = rru_version
            type_dict[rru_type]['rru_key'] = key_list
        return type_dict

    def _single_rru_verion(self, targetbd_path, rru_type):
        key_list = []
        rru_type = self._get_targetbd_rrutype(targetbd_path, rru_type)
        objs = self.xml.evaluate_xml_xpath(
            targetbd_path,
            "//hwResource[@resourceBuildKey='%s']/swFileKey" %
            rru_type)

        for i in range(len(objs)):
            key_list.append(
                self.xml.read_xml(
                    targetbd_path, "text|//hwResource[@resourceBuildKey='%s']/swFileKey[%s]" %
                                   (rru_type, (i + 1))))

        rru_version = self.xml.read_xml(
            targetbd_path,
            "attrib=resourceSWVersion|//hwResource[@resourceBuildKey='%s']" %
            rru_type)
        log.info("Type: %s, RRU version: %s, key list is %s from %s" %
                 (rru_type, rru_version, key_list, targetbd_path))
        return rru_version, key_list

    def _change_iphy_rru_version(self, iphy_xml_path):
        """
        :param iphy_xml_path: Source iphy.xml

        | Step:
        | 1. get rru version from iphy source file
        | 2. parse rru keys by targeBD file
        | 3. modify iphy xml base on the rru keys
        """
        self._setup_wts_common()
        comm_obj.log_to_console_with_time_prefix("change version in iphy.xml")
        new_iphy_xml_path = os.path.join(
            os.path.dirname(iphy_xml_path),
            "mod_%s" % os.path.basename(iphy_xml_path))
        self._modify_iphy_xml_rru_version(
            iphy_xml_path,
            new_iphy_xml_path)
        self.fsm.put_wts_config_file(new_iphy_xml_path, alias=self.alias)
        os_obj.move_file(new_iphy_xml_path, iphy_xml_path)

    def _change_xml_setting(self, params, xml_file):
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
                    parent_node_xpath = "//" + param.rpartition(":")[0].replace(":", "//")
                    target_node, target_value = param.split("|")[0].rpartition(":")[-1].split("=")
                    cond_key, cond_value = param.split("|")[-1].split("=")
                    param_xpath = "{}/{}[text()='{}']/../{}".format(parent_node_xpath,
                                                                    cond_key,
                                                                    cond_value,
                                                                    target_node)
                    parent_node_xpath_with_condition = "{}/{}[text()='{}']/..".format(parent_node_xpath,
                                                                                      cond_key,
                                                                                      cond_value)
                    builtin_obj.log("param_xpath={}, parent_node_xpath_with_condition={}".format(
                        param_xpath, parent_node_xpath_with_condition))
                    try:
                        # modify value
                        xml_obj.read_xml(out_xml, "text|%s" % param_xpath)
                        xml_obj.modify_xml(out_xml, out_xml, "text|%s|%s" % (target_value, param_xpath))
                    except Exception:
                        # add element
                        xml_obj.add_xml_element(out_xml, out_xml, "<%s>%s</%s>|%s" % (
                            target_node, target_value, target_node, parent_node_xpath_with_condition))
        return out_xml

    def _adapt_l1_mode(self, iphy_xml):
        comm_xml_obj = CommonXML(iphy_xml)
        # adapt iphy.xml according to L1 mode of gnb if iphy.xml path not contain fs/lib
        if "/fs/" not in iphy_xml.lower() and "/l1b/" not in iphy_xml.lower():
            # 1. get l1 mode from iphy.xml
            l1_setting_elements = comm_xml_obj.get_elements("//L1Bypass")
            if len(l1_setting_elements):
                l1_type_iphy_value = comm_xml_obj.get_element_text(l1_setting_elements[0])
                l1_type_iphy = "l1b" if l1_type_iphy_value.lower() == "true" else "fs"
            else:
                l1_type_iphy = "fs"
            # 2. set l1 mode parameter
            l1_type_gnb = comm_obj.get_l1_mode()
            if l1_type_gnb.lower() == "l1b" and l1_type_iphy == "fs":
                l1_param = "GeneralSettings:L1Bypass=true"
            elif l1_type_gnb.lower() == "fs" and l1_type_iphy == "l1b":
                l1_param = "delete:GeneralSettings:L1Bypass"
            else:
                l1_param = ""
        else:
            l1_param = ""
        return l1_param

    def _adapt_param_under_cells(self, iphy_xml, gnb_id, scf_params, param_name_scf, param_name_in_iphy):
        # adapt gscn according to NRCELL:gscnOrSsPbchArfcn in SCF
        # adapt SCS_SSB according to NRCELL:ssbScs in SCF, without unit KHz
        iphy_params = []
        if len(scf_params) == 0:
            return []
        comm_xml_obj = CommonXML(iphy_xml)
        # 1. get cell id (format is gnb_id.cell_id) which belong to specified gnb_id
        gnb_cell_ids = []
        all_cell_elements = comm_xml_obj.get_elements("//vcell/cell")
        builtin_obj.log("zy_debug: all element of //vcell/cell are {}".format(all_cell_elements))
        for each_cell in all_cell_elements:
            gnb_cell_id = comm_xml_obj.get_element_text(each_cell)  # gnb_id:cell_id
            if gnb_cell_id.startswith("{}.".format(gnb_id)):
                gnb_cell_ids.append(gnb_cell_id)
        if len(gnb_cell_ids) == 0:
            raise Exception("gnb_id={} under //vcell/cell not exist in iphy.xml".format(gnb_id))
        # 2. set parameters
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
        return iphy_params

    def _modify_and_upload_iphy_xml(self, iphy_params, iphy_xml, scf_params_gnb1, scf_params_gnb2):
        self._setup_wts_common()
        iphy_params = comm_obj.remove_empty_from_list(iphy_params)
        scf_params_gnb1 = comm_obj.remove_empty_from_list(scf_params_gnb1)
        scf_params_gnb2 = comm_obj.remove_empty_from_list(scf_params_gnb2)
        l1_param = self._adapt_l1_mode(iphy_xml)
        iphy_params.append(l1_param)
        # adapt gnb1 gscn and ssbscs in iphy.xml
        params_gsnc = self._adapt_param_under_cells(iphy_xml, "2", scf_params_gnb1, "gscnOrSsPbchArfcn", "GSCN")
        iphy_params.extend(params_gsnc)
        params_scs = self._adapt_param_under_cells(iphy_xml, "2", scf_params_gnb1, "ssbScs", "SCS_SSB")
        iphy_params.extend(params_scs)
        # adapt gnb2 gscn and ssbscs in iphy.xml
        params_gsnc_gnb2 = self._adapt_param_under_cells(iphy_xml, "3", scf_params_gnb2, "gscnOrSsPbchArfcn", "GSCN")
        iphy_params.extend(params_gsnc_gnb2)
        params_scs_gnb2 = self._adapt_param_under_cells(iphy_xml, "3", scf_params_gnb2, "ssbScs", "SCS_SSB")
        iphy_params.extend(params_scs_gnb2)
        # change parameters in iphy.xml
        print("iphy_params=%s" % iphy_params)
        new_iphy_xml = self._change_xml_setting(iphy_params, iphy_xml)
        # change sw version in iphy.xml
        self._change_iphy_rru_version(new_iphy_xml)
        # for ORAN
        try:
            self.fsm.put_wts_file("{}/fjt_snapshot*.xml".format(os.path.dirname(iphy_xml)),
                                  "/ffs/run/simmode/", alias=self.alias)
        except Exception as e:
            builtin_obj.log("zy: {}".format(e))
            pass

    def _modify_apoamconfig(self, params, ApOamConfig_xml):
        new_apoamconfig_xml = self._change_xml_setting(params, ApOamConfig_xml)
        os_obj.copy_file(new_apoamconfig_xml, "/opt/iphy/latest")

    def _execute_cmd_on_wts(self, cmd):
        builtin_obj.log("Execute command on AP:{}".format(cmd))
        out = self.fsm.execute_command_on_wts(cmd, alias=self.alias)
        builtin_obj.log("Get Response:{}".format(out))
        return out

    def _get_ap_bbu_type(self):
        self._setup_wts_common()
        cmd = "cat /proc/device-tree/module-identity/unit-id"
        rrutype = self._execute_cmd_on_wts(cmd)
        return re.compile('\x00').sub("", rrutype)

    def _modify_apmirror_slot_config(self, file_path):
        ap_fsp_boards_type = builtin_obj.get_variable_value('${AP_FSP_BOARDS_TYPE}')
        builtin_obj.log("ap fsp boards type is {}".format(ap_fsp_boards_type))
        for board_number in range(1, 4):
            file_data = ""
            if ap_fsp_boards_type[board_number-1]:
                with open(file_path, 'r') as f_obj:
                    for line in f_obj:
                        if 'MIRROR_ABIL_{}'.format(board_number) in line:
                            builtin_obj.log("origin line is {}".format(line))
                            line = line.replace("'false'", "'true'")
                            builtin_obj.log("line after changed is {}".format(line))
                        file_data += line
                with open(file_path, "w") as f_obj:
                    f_obj.write(file_data)
            else:
                with open(file_path, 'r') as f_obj:
                    for line in f_obj:
                        if 'MIRROR_ABIL_{}'.format(board_number) in line:
                            builtin_obj.log("origin line is {}".format(line))
                            line = line.replace("'true'", "'false'")
                            builtin_obj.log("line after changed is {}".format(line))
                        file_data += line
                with open(file_path, "w") as f_obj:
                    f_obj.write(file_data)

    def __del__(self):
        if self._setup_wts_comm_flag:
            try:
                self.fsm.teardown_wts_fsm_access(alias=self.alias)
            except Exception as e:
                pass


class iphy_xml_1(object):
    def __init__(self):
        alias = "gnb1"
        self.iphy_xml_base_instance1 = iphy_xml_base(alias)

    def modify_and_upload_iphy_xml(self, params, iphy_xml, scf_params_gnb1, scf_params_gnb2=''):
        self.iphy_xml_base_instance1._modify_and_upload_iphy_xml(params, iphy_xml, scf_params_gnb1, scf_params_gnb2)

    def modify_apoamconfig(self, params, ApOamConfig_xml):
        self.iphy_xml_base_instance1._modify_apoamconfig(params, ApOamConfig_xml)

    def get_ap_bbu_type(self):
        """
        Get Airphone Base Band Unit Type
        """
        return self.iphy_xml_base_instance1._get_ap_bbu_type()

    def modify_apmirror_slot_config(self, file_path):
        """This keyword is to modify the slot configuration in gnb mirror script by ap actual configuration
        | Input Parameters | Man. | Description |
         | file_path | Yes | gnbMirroringConfig file which is from gerrit.


        format of argument1 flags
        | 1) | key=value | modify parameter value, if param not exist, create it |
        Example
        | Modify Apmirror Slot Config | ${CURDIR}/../resources/DevHZ5_lib/src/tools/apMirroring/apMirroringConfig.sh |
        """
        return self.iphy_xml_base_instance1._modify_apmirror_slot_config(file_path)


class iphy_xml_2(object):
    def __init__(self):
        alias = "gnb2"
        self.iphy_xml_base_instance2 = iphy_xml_base(alias)

    def modify_and_upload_iphy_xml_gnb2(self, params, iphy_xml):
        raise Exception("not support yet, pls contact I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com")


class cm_iphy(iphy_xml_1):
    def __init__(self):
        iphy_xml_1.__init__(self)


if __name__ == "__main__":
    obj = cm_iphy()
    help(obj)
