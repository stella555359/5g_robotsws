# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author:
:contact:
"""

import logging
import os
import re
from lxml import objectify, etree
from ute_fsmaccess import ute_fsmaccess


fsmaccess = ute_fsmaccess()


vendor_target_path = {'FSIH': '/rom/', 'ASIA': '/rom/swpool/OAM/', 'ASIB': '/rom/swpool/OAM/'}


def _read_xml(xml_path):
    return objectify.parse(xml_path)


def get_Filedirectory_file():
    fsmaccess.setup_enb_fsm_access()
    fsmaccess.get_enb_file(source="/ffs/run/FileDirectory.xml", destination="/tmp/FileDirectory.xml")
    fsmaccess.teardown_enb_fsm_access()


def get_enb_type():
    fsmaccess.setup_enb_fsm_access()
    enb_type = fsmaccess.execute_command_on_enb('cat /proc/device-tree/module-identity/unit-id').strip("\x00")
    fsmaccess.teardown_enb_fsm_access()
    return enb_type


def get_eNB_vendorfile_path():
    get_Filedirectory_file()
    xml_read = _read_xml("/tmp/FileDirectory.xml")
    vendor_path = xml_read.xpath('.//fileElement[@name="vendor"]/@path')
    if len(vendor_path):
        return vendor_path[0]
    else:
        enb_type = get_enb_type()
        return vendor_target_path[enb_type]


def get_eNB_vendorfile_name():
    get_Filedirectory_file()
    xml_read = _read_xml("/tmp/FileDirectory.xml")
    vendor_name = xml_read.xpath('.//fileElement[@name="vendor"]/@version')
    if len(vendor_name):
        return vendor_name[0]
    else:
        vendorfile_path = get_eNB_vendorfile_path()
        fsmaccess.setup_enb_fsm_access()
        lines = fsmaccess.execute_command_on_enb('cd {} ;ls -l|grep vendor'.format(vendorfile_path))
        fsmaccess.teardown_enb_fsm_access()
        vendor_name = re.findall('vendor_\\w+\\.xml', lines)
        return vendor_name[0].strip('vendor')


def get_eNB_vendor_file():
    vendor_path = get_eNB_vendorfile_path()
    vendor_name = "vendor" + get_eNB_vendorfile_name()
    fsmaccess.setup_enb_fsm_access()
    fsmaccess.get_enb_file(source="{}/{}".format(vendor_path, vendor_name), destination="/tmp/{}".format(vendor_name))
    fsmaccess.teardown_enb_fsm_access()
    return vendor_name


def get_eNB_vendorfile_absolute_path():
    return os.path.join(get_eNB_vendorfile_path(), get_eNB_vendor_file())


def modify_and_upload_filedirectory():
    get_Filedirectory_file()
    xml_read = _read_xml("/tmp/FileDirectory.xml")
    checksum = xml_read.xpath('.//fileElement[@name="vendor"]/@checksum')
    if checksum[0] == '':
        logging.info(checksum[0])
        put_filedirectory_file_upload_bts(source="/tmp/FileDirectory.xml")
    else:
        lines = open("/tmp/FileDirectory.xml").readlines()
        s = ''
        for line in lines:
            if checksum[0] in line:
                s += line.replace(checksum[0], '')
            else:
                s += line
        f = open("/tmp/FileDirectory_modify.xml", 'w')
        f.write(s)
        f.close()
        put_filedirectory_file_upload_bts(source="/tmp/FileDirectory_modify.xml")


def put_filedirectory_file_upload_bts(source):
    fsmaccess.setup_enb_fsm_access()
    fsmaccess.put_enb_file(source, destination="/ffs/run/FileDirectory.xml")
    fsmaccess.teardown_enb_fsm_access()


def du1fv_modify_and_upload_vendor_file(parameter, value):
    vendor_name = get_eNB_vendor_file()
    modify_vendor_name = 'modify_' + vendor_name
    vendor_path = "/tmp/{}".format(vendor_name)
    vendorfile_path = get_eNB_vendorfile_path()
    target_vendorfile_path = os.path.join(vendorfile_path, vendor_name)
    xml_read = _read_xml(vendor_path)
    temp_value = xml_read.xpath('.//ns:p[@name="{}"]/text()'.format(parameter), namespaces={"ns": "raml21.xsd"})
    if temp_value[0] == value:
        logging.info("vendor file parameter 's value is target value ,no need modify !")
    else:
        new_file = ''
        modify_parameter = '<p name="{}">{}</p>'.format(parameter, value)
        lines = open(vendor_path).readlines()
        for line in lines:
            if parameter in line:
                # new_file+="{}\n".format(modify_parameter)
                new_file += line.replace(temp_value[0], value)
            else:
                new_file += line
        file = open("/tmp/{}".format(modify_vendor_name), 'w')
        file.write(new_file)
        file.close()
        fsmaccess.setup_enb_fsm_access()
        fsmaccess.put_enb_file(source="/tmp/{}".format(modify_vendor_name), destination=target_vendorfile_path)
        fsmaccess.execute_command_on_enb(cmd="rm -rf {}.p7".format(target_vendorfile_path))
        fsmaccess.execute_command_on_enb(cmd="crasign {}".format(target_vendorfile_path))
        fsmaccess.execute_command_on_enb(cmd="rm -f /ffs/run/HashContainer*")
        fsmaccess.teardown_enb_fsm_access()
        try:
            modify_and_upload_filedirectory()
        except Exception:
            pass
