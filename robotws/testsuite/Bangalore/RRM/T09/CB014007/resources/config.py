# -*- coding: utf-8 -*-
"""
:created on: 16-03-2021

:copyright: Nokia
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com@nokia-sbell.com
"""
import os
import re
import platform
from robot.libraries.BuiltIn import BuiltIn
import sys


class configuration(object):

    def __init__(self):
        self.configuration_name = ""
        self.target_dir = "/home/ute/testline_init_results/configs"
        self.target_dir_second = "/home/ute/testline_configuration"

        if os.path.isdir("/home/ute") is False:
            return
        else:
            self._get_configuration()
            self._set_configuration()

    def _execute_cmd(self, cmd):
        out = os.popen(cmd).readlines()
        return "".join(out).strip()

    def _get_configuration(self):
        sysstr = platform.system()
        if sysstr == "Windows":  # for dryrun
            return

        host_name = self._execute_cmd("hostname")
        host_name = re.sub("-1$", "", host_name)
        host_name = re.sub("-2$", "", host_name)
        host_name = host_name.replace("-", "_")
        if os.path.isdir("%s/%s" % (self.target_dir, host_name)):
            # read init file from target_dir folder
            self.configuration_name = host_name
        elif os.path.isdir("%s/%s" % (self.target_dir_second, host_name)):
            # read init file from target_dir_second folder and copy to target_dir folder
            self._execute_cmd("mkdir -p %s" % self.target_dir)
            self._execute_cmd("rm -rf %s/%s" % (self.target_dir, host_name))
            self._execute_cmd("cp -r %s/%s %s/%s" % (self.target_dir_second, host_name, self.target_dir, host_name))
            self.configuration_name = host_name
        else:
            # read init file from variable_files and copy to target_dir folder
            BuiltIn().log_to_console("zy: hostname is %s" % host_name)
            host_ip = self._execute_cmd("sudo ifconfig eth0 | grep -w inet | awk '{print $2}'")
            BuiltIn().log_to_console("zy: hostip is %s" % host_ip)
            curdir = os.path.dirname(__file__)
            source_dir = "%s/../../configuration_file/variable_files" % curdir
            source_name = self._execute_cmd("ls %s | grep  %s$" % (source_dir, host_ip))
            BuiltIn().log_to_console("zy: source_dir=%s, source_name=%s" % (source_dir, source_name))
            if len(source_name):
                target_name = source_name.split("_")[0] + "_" + source_name.split(".")[-1]
                BuiltIn().log_to_console("zy: target_dir=%s, target_name=%s" % (self.target_dir, target_name))
                self._execute_cmd("mkdir -p %s" % self.target_dir)
                self._execute_cmd("rm -rf %s/%s" % (self.target_dir, target_name))
                self._execute_cmd("cp -r %s/%s %s/%s" % (source_dir, source_name, self.target_dir, target_name))
                self.configuration_name = target_name
            else:
                BuiltIn().log("No testline config module __init__.py under %s" % source_dir, console=True)
                BuiltIn().log("Pls fill the following info and send them to "
                              "I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com to create for you", console=True)
                BuiltIn().log("   host ip:", console=True)
                BuiltIn().log("   powerbreak vendor, IP and port for GNB:", console=True)
                BuiltIn().log("   powerbreak vendor, IP and port for AP:", console=True)
                BuiltIn().log("   vlan_id:", console=True)
                BuiltIn().log("lack of local testline config module", level='ERROR', console=True)
                sys.exit(110)

    def _set_configuration(self):
        BuiltIn().import_variables("%s/%s" % (self.target_dir, self.configuration_name))
        tl_value = BuiltIn().get_variable_value("${tl}")
        BuiltIn().set_global_variable("${tl}", tl_value)
