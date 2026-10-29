# -*- coding: utf-8 -*-
"""
:created on: 04-16-2022
:copyright: Nokia
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia-sbell.com
"""
import os
import re
import sys
import time
import subprocess
import glob
import logging
import requests
from tak_files import tak_files


class WgetFiles():
    ''

    def __init__(self):
        ''
        pass

    def _exe_subprocess(self, cmd):
        print('\n--> execute "{}"'.format(cmd))
        try:
            ret = subprocess.check_output(cmd, shell=True)  # os.popen(cmd)#
        except Exception as err:
            print(err)
            return
        ret = ret.decode()
        print('<-- return "{}"'.format(ret))
        return ret

    def download_wft_latest_package(self, sw_pre="SBTS00"):
        """This keyword download mcshark from https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local
        :param sw_version: such as 'SBTS00_ENB_9999_210712_000002'

        """
        wft_link = "http://files.ute.nsn-rdnet.net/builds/enb/base"
        content = requests.get(wft_link)
        with open("base.xml", 'w+') as fobj:
            fobj.write(content.text)
        from tak_xml import tak_xml
        xml = tak_xml()
        sw_version = xml.read_xml(
            "base.xml",
            "text|//a[matches(@href, '%s.*')]" %
            sw_pre)
        if not sw_version:
            raise Exception("blank webpage")
        swbuild = sw_version[-1].strip('/')
        print('latest version is %s' % swbuild)
        local_path = "/opt/wft/%s" % sw_pre
        if not os.path.exists(local_path):
            os.makedirs(local_path)
        local_pkg = "%s/%s_release_BTSSM_downloadable.zip" % (
            local_path, swbuild)

        if os.path.exists(local_pkg):
            print("this package exist in %s" % local_pkg)
        cmd = "wget -P %s -c %s/%s/%s_release_BTSSM_downloadable.zip" % (
            local_path, wft_link, swbuild, swbuild)
        st_time = time.time()
        ret = self._exe_subprocess(cmd)
        if "non-zero exit status" not in ret:
            time2 = time.time()

            print("download cost time %.2f minutes" % ((time2 - st_time) / 60))
            f = tak_files()
            tgt_path = "/BTSSW/From_jenkins/%s/" % sw_pre

            print("start to upload to server")
            f.ftp_upload('10.69.80.93', 21, 'tdlte', 'tdlte', local_pkg, tgt_path)
            time3 = time.time()
            print("upload cost time %.2f minutes" % ((time3 - time2) / 60))
            self._exe_subprocess("rm %s" % local_pkg)
        else:
            raise Exception("download failed!")


if __name__ == "__main__":
    a = WgetFiles()
    sw_pre = sys.argv[1]
    a.download_wft_latest_package(sw_pre)
