# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
import sys

if sys.version_info.major == 2:
    import ConfigParser as configparser
else:
    import configparser


class modify_ini(object):

    def __init__(self):
        self.conf = configparser.ConfigParser()
        self.ini_file = ''

    def setup_ini(self, ini_file):
        self.conf.read(ini_file)
        self.ini_file = ini_file

    def add_ini_section(self, section, *key_value_pairs):
        section = section.replace("[", "").replace("]", "")
        # remove section if exist
        if self.conf.has_section(section):
            self.conf.remove_section(section)
        # add new section and its key value pairs
        self.conf.add_section(section)
        for key_value_pair in key_value_pairs:
            if len(key_value_pair.strip()) == 0:
                continue
            if key_value_pair.count("=") == 0:
                raise Exception("wrong format:{}, should like key=value".format(key_value_pair))
            key, value = key_value_pair.split("=")
            self.conf.set(section, key.strip(), value.strip())

    def modify_ini_section(self, section, *key_value_pairs):
        section = section.replace("[", "").replace("]", "")
        if not self.conf.has_section(section):
            raise Exception("section:{} not exist, should call add_section instead".format(section))
        for key_value_pair in key_value_pairs:
            if len(key_value_pair.strip()) == 0:
                continue
            if key_value_pair.count("=") == 0:
                raise Exception("wrong format:{}, should like key=value".format(key_value_pair))
            key, value = key_value_pair.split("=")
            self.conf.set(section, key.strip(), value.strip())

    def delete_ini_section(self, section, *keys):
        section = section.replace("[", "").replace("]", "")
        if not self.conf.has_section(section) and len(keys):
            raise Exception("section:{} not exist".format(section))
        if len(keys) == 0:
            self.conf.remove_section(section)
        else:
            for key in keys:
                if len(key.strip()) == 0:
                    continue
                self.conf.remove_option(section, key)

    def teardown_ini(self):
        self.conf.write(open(self.ini_file, 'w'))


if __name__ == "__main__":
    ini_obj = modify_ini()
    ini_obj.setup_ini(r"C:\TA\robotlte\testsuite\hangzhou\RAN_3_SW_CN_HZ\resources\DevHZ5_lib\src\cus.ini")
    ini_obj.add_ini_section("enb2", "enb_type = FLEXI")
    ini_obj.add_ini_section("ctrl_2", "trsw_ip = 10.0.2.3")
    ini_obj.modify_ini_section("executor", "log_level = INFO")
    ini_obj.delete_ini_section("ip_configuration")
    ini_obj.delete_ini_section("ctrl_1", "sectors", "ip_addr")
    ini_obj.teardown_ini()
