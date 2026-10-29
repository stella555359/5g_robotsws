# -*- coding: utf-8 -*-
"""
2022/05/19 first version by @author: xiang.5.li@nokia-sbell.com
"""

from xml.etree import ElementTree as et
# from xml.etree.ElementTree import Element
try:
    from .logger_et import LoggingEt
except Exception as e:
    from logger_et import LoggingEt
import os
import re


class ReadGnbScf(object):
    def __init__(
            self,
            log_path,
            scfFile,
            managedObject_distName,
            paras,
            *args,
            **kwargs):
        self.log_path = log_path
        self.scf_file = scfFile
        __logger_name = os.path.basename(__file__)
        self.log = LoggingEt(self.log_path, __logger_name).log()
        # self.log = LoggingEt(self.log_path, __name__).log()
        self.managedObject_distName = managedObject_distName
        self.paras = [paras] if type(paras) is str else paras
        self.ns = ''
        self.managedObject = None
        self.paras_result = {}

    def get_xmlns(self, root_tag):
        """
        Get the namespace of xlm file.
        :param root_tag:
        :return:
        """
        # print(root_tag.index("{"))
        # print(root_tag.index("}"))
        if "{" in root_tag:
            # print(root_tag.index("{"))
            self.ns = root_tag[root_tag.index("{"): root_tag.index("}") + 1]
        self.log.info("the file:%s xmlns:%s" %
                      (os.path.basename(self.scf_file), self.ns))

    def get_managed_object_with_ns_py(self):
        """
        Parser the Gnb scf xml file with namespace
        :param managed_object_dist_name:
        :return:
        """
        xml_root = et.parse(self.scf_file).getroot()
        self.get_xmlns(xml_root.tag)
        # print(xml_root.find("./*/" + self.ns + "managedObject"))
        managed_obj = xml_root.findall('.//{0}managedObject'.format(self.ns))
        for item in managed_obj:
            if item.attrib['distName'] == self.managedObject_distName:
                self.managedObject = item
                break
            else:
                continue

    def get_one_para(self, para):
        # print("type:", type(para.attrib['name']))
        if para.attrib['name'] in self.paras:
            self.paras_result[para.attrib['name']] = para.text

    def get_para_nrdrb_5qi(self, para):
        """
        get parameter form managedObject, such as:distName="MRBTS-1/NRBTS-1/NRDRB_5QI-1"
        :return:
        """
        if para.attrib['name'] in self.paras:
            self.paras_result[para.attrib['name']] = para.findall("./")[0].text

    def get_para_list(self, para):
        para_list = para.findall("./%sitem/" % self.ns)
        # print("para_list:%s" % para_list)
        for para in para_list:
            self.get_one_para(para)

    def parser_scf_by_managed(self):
        self.get_managed_object_with_ns_py()
        if self.managedObject:
            self.log.info("self.managedObject, distName:%s" %
                          self.managedObject.attrib['distName'])
            for para in self.managedObject.findall("./"):
                # print(self.managedObject.attrib['distName'])
                if re.search(
                    "MRBTS-\\d+\\/NRBTS-\\d+\\/NRDRB_5QI-\\d+",
                        self.managedObject.attrib['distName']):
                    self.get_para_nrdrb_5qi(para)
                elif para.tag == "%slist" % self.ns:
                    self.get_para_list(para)
                else:
                    self.get_one_para(para)
        if len(self.paras_result) == len(self.paras):
            self.log.info("scf parameters: %s" % self.paras_result)
            return self.paras_result
        else:
            self.log.warning(
                "The paras maybe not find or not enough!\n "
                "required:%s, result:%s" %
                (self.paras, self.paras_result))
            return self.paras_result


if __name__ == "__main__":
    log_path = r"C:\work\data\017-Feature\5G\8534\TDRA_log\CB007601_Auto_semiStatic_DL14"
    xmlFile = r"C:\work\data\017-Feature\5G\8534\TDRA_log\CB007601_Auto_semiStatic_DL14\scf.xml"
    # file = r"C:\work\data\017-Feature\5G\8534\TDRA_log\CB007601_Auto_semiStatic_DL14\iphy.xml"
    # managedObject_distName = "MRBTS-1/NRBTS-1/NRCELL-1"
    # paras = ["actCellCsirsTddOnSsbBf", "actCsiMeasEthFlowControl"]
    # managedObject_distName = "tddFrameStructure"
    # paras = ["frameStructureType", "guardPeriodLength", "ulDlDataSlotRatio"]
    managedObject_distName = "MRBTS-1/NRBTS-1/NRCELLGRP-0"
    paras = ["maxUlHarqTx", "dataFlowResumeThrFR1"]
    managedObject_distName = "MRBTS-1/NRBTS-1/NRDRB_5QI-3"
    paras = ["fiveqiValueList"]
    readxml = ReadGnbScf(log_path, xmlFile, managedObject_distName, paras)
    readxml.parser_scf_by_managed()
