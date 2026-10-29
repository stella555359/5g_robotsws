# -*- coding: utf-8 -*-
"""
:created on: 07-16-2021
:copyright: Nokia
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia-sbell.com
"""
import os
import re
import time
import subprocess
import glob
import logging


class WgetFiles():
    'run parallel'

    def __init__(self):
        ''
        pass

    def _exe_subprocess(self, cmd):
        logging.info('\n--> execute "{}"'.format(cmd))
        try:
            ret = subprocess.check_output(cmd, shell=True)
        except Exception as err:
            logging.error(err)
            return
        ret = ret.decode()
        logging.info('<-- return "{}"'.format(ret))
        return ret

    def download_mcshark(self, sw_version):
        """This keyword download mcshark from https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local
        :param sw_version: such as 'SBTS00_ENB_9999_210712_000002'

        """
        ret = self._exe_subprocess("lsb_release -a")
        debian_name = 'buster'
        for info in ret.splitlines():
            if info.startswith("Codename"):
                debian_name = info.split()[-1]
                logging.info(debian_name)
                break

        ret = self._exe_subprocess("wireshark --version")
        wireshark_version = None
        for info in ret.splitlines():
            if info.startswith("Wireshark"):
                tmp = info.split()[1]
                wireshark_version = '.'.join(tmp.split('.')[:2])
                logging.info(wireshark_version)
                break
        if not wireshark_version:
            logging.warn("get Wireshark version failed")

        wireshark_path = "/usr/lib/x86_64-linux-gnu/wireshark/plugins/*/epan/"
        current_path = glob.glob(wireshark_path)
        ver = float(current_path[0].split('/')[-3])
        link = "https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=779796371"
        if ver < 3.4:
            logging.warn(
                "Wireshark version is '%s', it's lower than 3.4, update in '%s'" %
                (ver, link))
        if len(current_path) < 1:
            raise Exception("not find path %s" % wireshark_path)

        mcshark_expected = ".*mcshark-%s.*%s.*%s.so" % (wireshark_version, sw_version, debian_name)
        mcshark_exist = False

        mcshark = glob.glob("%s/mcshark*.so" % wireshark_path)
        if mcshark:
            for m in mcshark:
                if re.search(mcshark_expected, m):
                    mcshark_exist = True
                else:
                    self._exe_subprocess("sudo rm %s" % m)

        if mcshark_exist:
            return
        else:
            url = 'https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local'
            cmd = "sudo wget -q -P '%s' -r -np -nH -nd -A%s.so %s/%s/" % (
                current_path[0], debian_name, url, sw_version)
            self._exe_subprocess(cmd)

        mcshark = glob.glob("%s/mcshark*.so" % wireshark_path)
        if mcshark:
            for m in mcshark:
                if not re.search(mcshark_expected, m):
                    self._exe_subprocess("sudo rm %s" % m)
