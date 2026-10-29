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
import time
import logging as log
from ute_fsmaccess import ute_fsmaccess
from tak_xml import tak_xml
from .robot_func import get_robot_runtime_variable


class IphyXmlFileModify():
    'iphy xml modify'

    def __init__(self):
        ''
        self.fsm = ute_fsmaccess()
        self.xml = tak_xml()

    def _get_targetbd_rrutype(self, targetbd_path, rru_type):
        with open(targetbd_path, 'r') as f_obj:
            f_content = f_obj.read()
        ret = re.search(r'\"(\w+_%s.*?)\"' % rru_type, f_content, re.M)

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
            rru_type = self.xml.read_xml(
                iphy_xml_path, "text|//RE[%s]//cardName" %
                (i + 1))

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
            modify_list += ["text|%s|//*[text()='%s']/../buildname" %
                            (rru_version, rru_type), "text|%s|//*[text()='%s']/../buildversion" %
                            (rru_version, rru_type)]
        self.xml.modify_xml(iphy_source, iphy_target, modify_list)
        log.info("modify %s as %s ok with parameters" %
                 (iphy_source, iphy_target))
        for mod in modify_list:
            log.info(mod)

        for rru_type in type_dict.keys():
            key_list = type_dict[rru_type]['rru_key']
            for i in range(len(key_list)):
                self.xml.remove_xml_element(iphy_target, iphy_target,
                                            "//*[text()='%s']/../..//soap-config/software/file/." % rru_type)

                for i in range(len(key_list)):

                    file_node = """
                <file>
                  <name>%s</name>
                  <usageStatus>active</usageStatus>
                  <version>%s</version>
                </file>
                """ % (key_list[i], rru_version)
                    modify_list.append(
                        "%s|//*[text()='%s']/../..//soap-config/software/." %
                        (file_node, rru_type))
                self.xml.add_xml_element(iphy_target, iphy_target, modify_list)

    def _chang_iphy_cpri_rru_version(
            self, iphy_source, iphy_target, type_dict):
        modify_list = []
        for rru_type in type_dict.keys():
            rru_version = type_dict[rru_type]['rru_version']
            key_list = type_dict[rru_type]['rru_key']
            print(rru_type, rru_version, key_list)
            bldversion = self.xml.evaluate_xml_xpath(
                iphy_source, "//buildversion")
            build_version = rru_version
            if bldversion:
                modify_list += ["text|%s|//*[text()='%s']/../bldVersion" %
                                (rru_version, rru_type), "text|%s|//*[text()='%s']/../buildversion" %
                                (build_version, rru_type)]
            else:
                modify_list += ["text|%s|//*[text()='%s']/../bldVersion" %
                                (rru_version, rru_type)]
        log.info(modify_list)
        self.xml.modify_xml(iphy_source, iphy_target, modify_list)
        log.info("modify %s as %s ok with parameters" %
                 (iphy_source, iphy_target))

        modify_list = []
        for rru_type in type_dict.keys():
            self.xml.remove_xml_element(iphy_target, iphy_target,
                                        "//*[text()='%s']/../..//soap-config/software/file/." % rru_type)
            key_list = type_dict[rru_type]['rru_key']
            for i in range(len(key_list)):
                name = key_list[i]
                if 'rfsw' in key_list[i]:
                    rru_version = name.split('_')[-1].strip('.tar')

                file_node = """
            <file>
              <name>%s</name>
              <usageStatus>active</usageStatus>
              <version>%s</version>
            </file>
            """ % (name, rru_version)
                modify_list.append(
                    "%s|//*[text()='%s']/../..//soap-config/software/." %
                    (file_node, rru_type))
        log.info('add files: %s' % modify_list)
        self.xml.add_xml_element(iphy_target, iphy_target, modify_list)

    def _get_targetbd_from_core(self, targetBD_folder):
        import taf.transport.ssh as csn
        ssh = csn.ssh()
        ssh.connect_to(
            hostname=self.remote_host,
            username='ute',
            password='ute',
            alias='remote')
        ssh.connect_to(
            hostname=self.enb_ip,
            username=self.enb_user,
            password=self.enb_pwd,
            alias='core',
            proxy='remote')
        vdu_version = get_robot_runtime_variable('${NAMESPACE_VDU}')
        pre_cmd = 'oc exec -it ute-cran45-oamfh-0 -n cran45 -c ctr-cran45-oamfh'.replace('cran45', vdu_version)
        cmd = ' -- find /ffs/run/RFSW -type f -name "TargetBD*.xml"'
        exe_cmd = pre_cmd + cmd
        log.info(exe_cmd)
        tmp = ssh.execute(exe_cmd, connection='core').splitlines()[0]
        log.info('targetBd is "%s"' % tmp)
        exe_cmd = pre_cmd + ' -- cat %s ' % tmp
        log.info(exe_cmd)
        content = ssh.execute(exe_cmd, connection='core')
        targetBD_path = os.path.join(targetBD_folder, os.path.basename(tmp))

        with open(targetBD_path, 'w') as fobj:
            fobj.write(content)
        return targetBD_path

    def _get_targetbd_from_fsm(self, targetBD_folder):
        self.fsm.setup_enb_fsm_access(
            prompt=' >',
            fallback_prompt='#',
            host=self.enb_ip,
            remote_host=self.remote_host)

        targetBD_path = self.fsm.get_enb_targetbd_file('%s/' % targetBD_folder)
        self.fsm.teardown_enb_fsm_access()
        return targetBD_path

    def _modify_iphy_xml_rru_version(self, iphy_source, iphy_target):
        """modify iphy xml rru version
        | Input Parameters | Man. | Description |
        | iphy_source      | Yes  | path of source iphy.xml |
        | iphy_target      | Yes  | path of target iphy.xml |
        | kwargs           | No   | optional parameters |

        kwargs aviliable inputs:
             host default is fcmd ip.
        | Return | sw_version |
        Example
        | modify_iphy_xml_rru_version | d://iphy_source.xml | d://iphy_target.xml  |
        """
        targetBD_folder = os.path.dirname(iphy_source)
        if targetBD_folder == '':
            raise Exception("Iphy Xml Path should be absolute path")

        if self.enb_ip == '192.168.255.1':
            targetBD_path = self._get_targetbd_from_fsm(targetBD_folder)
        else:
            targetBD_path = self._get_targetbd_from_core(targetBD_folder)

        self.xml.remove_xml_element(
            iphy_source,
            iphy_source,
            "//*[text()='passive']/..")
        with open(iphy_source, 'r') as f_obj:
            content = f_obj.read()
        if 'OBSAI' in content:
            log.info('this is obsai type')
            rru_type = self._get_obsai_rru_type_from_iphy_xml(iphy_source)
            rru_dict = self._get_rru_version_and_key_with_xpath(
                targetBD_path, rru_type, iphy_source)
            self._chang_iphy_obsai_rru_version(
                iphy_source, iphy_target, rru_dict)
        else:
            log.info('this is cpri type')
            rru_type = self._get_cpri_rru_type_from_iphy_xml(iphy_source)
            rru_dict = self._get_rru_version_and_key_with_xpath(
                targetBD_path, rru_type, iphy_source)
            self._chang_iphy_cpri_rru_version(
                iphy_source, iphy_target, rru_dict)

    def _get_rru_version_and_key_with_xpath(
            self, targetbd_path, rru_type_list, iphy_source):
        type_dict = {}
        for rru_type in rru_type_list:
            search_rru = rru_type
            if rru_type == 'AEQN':
                try:
                    tmp = self.xml.read_xml(
                        iphy_source, "text|//cardName[text()='AEQN']/../resourceBuildKey")
                    search_rru = tmp.strip('LTX_')
                except Exception as err:
                    pass

            rru_version, key_list, buildTimestamp = self._single_rru_verion(
                targetbd_path, search_rru)
            type_dict[rru_type] = {}
            type_dict[rru_type]['rru_version'] = rru_version
            type_dict[rru_type]['rru_key'] = key_list
            type_dict[rru_type]['buildTimestamp'] = buildTimestamp
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
        buildTimestamp = self.xml.read_xml(
            targetbd_path,
            "attrib=buildTimestamp|//hwResource[@resourceBuildKey='%s']" %
            rru_type)
        log.info("Type: %s, RRU version: %s, key list is %s from %s" %
                 (rru_type, rru_version, key_list, targetbd_path))
        return rru_version, key_list, buildTimestamp

    def change_iphy_rru_version(self, iphy_xml_path, **kwargs):
        """
        :param iphy_xml_path: Source iphy.xml
        :Supported SSH parameters are available via kwargs:
            * **enb_ip**         (string)     - ENB ip. Default is '192.168.255.1'.
            * **wts_ip**         (string)     - Iphy wts ip, default is 192.168.200.1
            * **remote_host**    (string)     - remote host ip default is 127.0.0.1.

        | Step:
        | 1. get rru version from iphy source file
        | 2. parse rru keys by targeBD file
        | 3. modify iphy xml base on the rru keys

        | change_iphy_rru_version    ${CURDIR}${/}iphy_local.xml
        | change_iphy_rru_version    ${CURDIR}${/}iphy_local.xml enb_ip=192.168.2.124 enb_user=core enb_pwd=system123
        """
        self.enb_ip = kwargs.get('enb_ip', '192.168.255.1')
        self.enb_user = kwargs.get('enb_user', None)
        self.enb_pwd = kwargs.get('enb_pwd', None)
        self.iphy_ip = kwargs.get('wts_ip', '192.168.200.1')
        self.remote_host = kwargs.get('remote_host', '127.0.0.1')
        log.info("enb ip is %s, iphy ip is %s, remote host is %s" %
                 (self.enb_ip, self.iphy_ip, self.remote_host))
        xml_name = os.path.basename(iphy_xml_path)
        new_iphy_xml_folder = os.path.join(
            os.path.dirname(iphy_xml_path),
            'mod_iphy')
        if not os.path.exists(new_iphy_xml_folder):
            os.mkdir(new_iphy_xml_folder)
        new_iphy_xml_path = os.path.join(
            new_iphy_xml_folder,
            os.path.basename(iphy_xml_path))
        self._modify_iphy_xml_rru_version(
            iphy_xml_path,
            new_iphy_xml_path)
        self.fsm.setup_wts_fsm_access(
            prompt=' >',
            fallback_prompt='#',
            host=self.iphy_ip,
            remote_host=self.remote_host,
            retry_timeout=120)

        try:
            self.fsm.put_wts_config_file(new_iphy_xml_path)
        except Exception as err:
            log.warn("put_wts_config_file failed for %s, and will try again" %
                     (err))
            self.fsm.wait_for_host_ssh(
                host=self.iphy_ip, remote_host=self.remote_host)
            self.fsm.put_wts_config_file(new_iphy_xml_path)
        self.fsm.teardown_wts_fsm_access()
