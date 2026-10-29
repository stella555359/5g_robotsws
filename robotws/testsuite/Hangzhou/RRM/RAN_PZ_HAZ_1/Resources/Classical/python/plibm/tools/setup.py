#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import os
import sys
import logging
from pprint import pprint
from ute_fsmaccess import ute_fsmaccess

above_path = os.sep.join(os.path.dirname(os.path.abspath(__file__)).split(os.sep)[:-1])
sys.path.append(above_path)
sys.path.append(os.path.join(above_path, 'lib_devices'))

formatter = logging.Formatter('%(asctime)s [%(levelname)5s] %(message)s',
                              datefmt='%Y-%m-%d %H:%M:%S')
logging.basicConfig(format=formatter._fmt, datefmt=formatter.datefmt, level=logging.INFO)
logger = logging.getLogger()


class SetupTool(object):

    def __init__(self, options):
        self.options = options
        from petbase import gv
        self.gv = gv
        self.logger = logger

    def _get_bts_build(self, host):
        fsm = ute_fsmaccess()
        fsm.setup_enb_fsm_access(host=host)
        return fsm.get_enb_sw_version()

    def install_wireshark_plugin_nsetap(self):
        self.logger.info('安装 Wireshark 插件 nsetup')
        from pet_shell import c_PetShell
        c_PetShell().prepare_nsetap_plugin_for_wireshark('nsetap')

    def install_wireshark_plugin_mcshark(self):
        self.logger.info('安装 Wireshark 插件 mcshark')
        from pet_shell import c_PetShell
        self.gv.bts_version = self.options.build if self.options.build else self._get_bts_build(self.options.host)
        c_PetShell().prepare_mcshark()

    def install_gnbtool(self):
        self.logger.info('安装 gnbtool')
        fname = '~/tools/gnb_logs/gnb_logs'
        fname = os.path.expanduser(fname)
        if not os.path.exists(fname):
            from lib_devices.pet_gnb_tool import gnb_tool
            tool = gnb_tool(logger=self.logger)
            tool.setup()
        else:
            os.system(f'sudo {fname} -V')

    def run(self):
        self.logger.info('准备测试环境')
        self.install_wireshark_plugin_nsetap()
        self.install_wireshark_plugin_mcshark()
        self.install_gnbtool()


if __name__ == "__main__":

    import argparse
    parser = argparse.ArgumentParser(description='测试环境准备工具',  epilog='如果有问题，请和开发联系。')
    parser.add_argument("--btsip",
                        dest="host",
                        default='192.168.255.129',
                        help='FCT地址')

    parser.add_argument("--build",
                        dest="build",
                        help='指定包的版本；如果指定了，自己用这个值，否则到站上去获取')

    args = parser.parse_args()
    pprint(args)

    st = SetupTool(args)
    st.run()
