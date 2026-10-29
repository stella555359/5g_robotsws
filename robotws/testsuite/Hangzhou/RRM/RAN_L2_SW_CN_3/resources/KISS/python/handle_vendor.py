# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author:
:contact:
"""

import os
import re
from lxml import objectify
from ute_fsmaccess import ute_fsmaccess
fsmaccess = ute_fsmaccess()


vendor_target_path = {'FSIH': '/rom/', 'ASIA': '/rom/swpool/OAM/', 'ASIB': '/rom/swpool/OAM/'}


class handle_vendor():

    def __init__(self):
        pass

    def _read_xml(self, xml_path):
        return objectify.parse(xml_path)

    def get_Filedirectory_file(self):
        fsmaccess.setup_enb_fsm_access()
        fsmaccess.get_enb_file(source="/ffs/run/FileDirectory.xml", destination="/tmp/FileDirectory.xml")
        fsmaccess.teardown_enb_fsm_access()

    def get_vendorfile_path(self):
        self.get_Filedirectory_file()
        xml_read = self._read_xml("/tmp/FileDirectory.xml")
        vendor_path = xml_read.xpath('.//fileElement[@name="vendor"]/@path')
        if len(vendor_path):
            return vendor_path[0]
        else:
            enb_type = self.get_enb_type()
            return vendor_target_path[enb_type]

    def get_vendorfile_name(self):
        self.get_Filedirectory_file()
        xml_read = self._read_xml("/tmp/FileDirectory.xml")
        vendor_name = xml_read.xpath('.//fileElement[@name="vendor"]/@version')
        if len(vendor_name):
            return vendor_name[0]
        else:
            vendorfile_path = self.get_vendorfile_path()
            fsmaccess.setup_enb_fsm_access()
            lines = fsmaccess.execute_command_on_enb('cd {} ;ls -l|grep vendor'.format(vendorfile_path))
            fsmaccess.teardown_enb_fsm_access()
            vendor_name = re.findall('vendor_\\w+\\.xml', lines)
            return vendor_name[0].strip('vendor')

    def get_vendor_file(self):
        vendor_path = self.get_vendorfile_path()
        vendor_name = "vendor" + self.get_vendorfile_name()
        fsmaccess.setup_enb_fsm_access()
        fsmaccess.get_enb_file(source="{}/{}".format(vendor_path, vendor_name),
                               destination="/tmp/{}".format(vendor_name))
        fsmaccess.teardown_enb_fsm_access()
        return vendor_name

    def get_vendorfile_absolute_path(self):
        return os.path.join(self.get_vendorfile_path(), self.get_vendor_file())
