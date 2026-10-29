# -*- coding: utf-8 -*-
import xml.etree.ElementTree as ET


class ParsingSCF(object):
    NAMESPACE = "raml21.xsd"
    MANAGED_OBJECT = "managedObject"
    CLASS = "class"
    """
        Usage example:
        For python:
        >>> from scf_xml_parsing import ParsingSCF
        >>> current_scf = ParsingSCF(path='/home/ute/vdu_scf.xml')
        >>> current_scf.start_parsing()
        >>> mo_list = current_scf.get_mo_list('SYNC')
        >>> dn_list = []
        >>> for mo in mo_list:
        >>>    dn_list.append(mo.get('distName'))

        For RobotFramework:
        >>> *** Settings ***
        >>> Library   scf_xml_parsing_new.ParsingSCF

        >>> *** Test Cases ***
        >>> Test scf xml parsing
        >>>     set_scf_path   /home/ute/scf_1cell.xml
        >>>     start_parsing
        >>>     ${MO_LIST}   get_mo_list    SYNC
    """

    def __init__(self, path=None):
        self.scf_path = path
        self.tree = None
        self.root = None

    def start_parsing(self):
        self.tree = ET.parse(self.scf_path)
        self.root = self.tree.getroot()

    def get_mo_list(self, class_name):
        mo_list = []
        for mo in self.root.iter(ParsingSCF.to_ns_path(ParsingSCF.MANAGED_OBJECT)):
            full_class_name = ParsingSCF.get_mo_class_name(mo)
            if full_class_name.endswith(class_name):
                mo_list.append(mo)
        return mo_list

    @staticmethod
    def to_ns_path(path):
        return "{" + "{}".format(ParsingSCF.NAMESPACE) + "}" + "{}".format(path)

    @staticmethod
    def get_mo_class_name(mo):
        return mo.get(ParsingSCF.CLASS)

    def set_scf_path(self, scf_file_path):
        self.scf_path = scf_file_path
