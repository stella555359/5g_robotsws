#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: None
:contact: None
"""
from __future__ import with_statement
import time
import os

import os
import sys
import time
import re
import urllib
# import urllib2(python2)
# import cookielib(python2)
from http import cookiejar
import shutil
import zipfile
from datetime import datetime
import logging


proxies = {'http': 'http://10.144.1.10:8080',
           'https': 'https://10.144.1.10:8080'}

if os.name == "nt":
    CUR_DIR = 'c:\\pstools_for_TA'
else:
    CUR_DIR = '/home/ute/pstools_for_TA'


def _get_fdd_pstools(PkName, localpath):
    if "_9999_" in PkName:
        trunk_tag = PkName.split('_')[0]
        print(trunk_tag)
        PkName = PkName.replace(trunk_tag, "SBTS00")

    pstool_address = "http://files.ute.nsn-rdnet.net//builds/enb/base/%s/pstools.zip" % PkName

    cmd = "wget -O {}/pstools.zip -e use_proxy=yes -e http_proxy={} {}".format(localpath, proxies['http'],
                                                                               pstool_address)
    logging.info("Cmd: %s" % cmd)

    p = os.system(cmd)
    if int(p) == 0:
        logging.info("4th way get %s's pstools successful!" % PkName)
    else:
        raise Exception("4th way get %s's pstool failed!" % PkName)


def _get_tdd_pstools(PkName, localpath):
    if "_9999_" in PkName:
        trunk_tag = PkName.split('_')[0]
        PkName = PkName.replace(trunk_tag, "SBTS00")
    import requests
    from xml.etree import ElementTree as ET
    url = "https://wft.int.net.nokia.com/ext/build_content/%s" % PkName
    r = requests.get(url, proxies=proxies, timeout=40)
    if r.status_code == 200:
        contents = r.content
        parsed = ET.fromstring(contents)
        build = list(parsed.iter('file'))
        for child in build:
            if re.findall('http.+pstools\\.zip', child.text):
                packages = re.findall('http.+pstools\\.zip', child.text)
                if packages:
                    for package in packages:
                        p = os.system(" wget -O {}/pstools.zip -e use_proxy=yes -e http_proxy={} {}"
                                      .format(localpath, proxies['http'], package))
                        break
        if int(p) == 0:
            logging.info("4th way get %s's pstools successful!" % PkName)
        else:
            raise Exception("4th way get %s's pstool failed!" % PkName)


def DownloadPStools(PkName):
    localpath = os.path.join(CUR_DIR, PkName)
    if not os.path.exists(localpath):
        os.makedirs(localpath)
    else:
        ret = os.popen('ls %s' % localpath).read()
        if "PsFeatureLevels.hpp" in ret:
            logging.info('already pstools files exist!')
            return
    st = time.time()
    try:
        _get_fdd_pstools(PkName, localpath)
    except Exception as err:
        shutil.rmtree(localpath)
        return

    if get_useful_files(localpath):
        logging.info(
            "download %s ps tool cost time is %d" %
            (PkName, (time.time() - st)))
        return True


def _try_unzip(zip_file_name, target_folder_name, zip_exe_path):
    cmd = "%s x \"%s\" -y -o\"%s\"" % (zip_exe_path,
                                       zip_file_name, target_folder_name)
    logging.info(cmd)
    _ret = os.popen(cmd).read()
    logging.info(_ret)

    if "everything is ok" in _ret.lower():
        logging.info("unzip '%s' to '%s' with 7z.exe successfully!" % (zip_file_name, target_folder_name))
        return True
    else:
        logging.warning("unzip '%s' to '%s' with 7z.exe failed!" % (zip_file_name, target_folder_name))
        return False


def _use_7z_unzip(zip_file_name, target_folder_name):
    zip_exe_path = "7z.exe"
    os.environ[
        'path'] += ';C:\\Program Files (x86)\\7-Zip\\;C:\\Program Files\\7-Zip\\'
    _try_unzip(zip_file_name, target_folder_name, zip_exe_path)


def get_useful_files(parent):
    import glob
    import shutil
    os.chdir(parent)
    tmp = glob.glob(os.path.join(parent, "*.zip"))
    if tmp:
        zip_path = tmp[0]
        import platform
        if platform.system() == "Windows":
            _use_7z_unzip(zip_path, os.path.dirname(zip_path))
        else:
            os.system("unzip %s" % zip_path)
        os.remove(zip_path)
    else:
        logging.warning("No zip file exist, remove it %s" % parent)
        shutil.rmtree(parent)
        return False
    files = []
    files.append(
        os.path.join(
            parent,
            'pscli',
            'ERadSwDomainLteMac.h'))
    files.append(
        os.path.join(
            parent,
            'pscli',
            'PsFeatureLevels.hpp'))
    # files.append(
    #     os.path.join(
    #         parent,
    #         'pscli',
    #         'pscli.exe'))
    # files.append(
    #     os.path.join(
    #         parent,
    #         'pscli',
    #         'pscli'))
    files.append(
        os.path.join(
            parent,
            'TtiTracer',
            'DevC_tti_trace_parser'))
    files.append(
        os.path.join(
            parent,
            'TtiTracer',
            'DevC_tti_trace_parser.exe'))
    # files.append(
    #     os.path.join(
    #         parent,
    #         'TtiTracer',
    #         'ttiStream.exe'))
    # files.append(
    #     os.path.join(
    #         parent,
    #         'pstools',
    #         'TtiTracer',
    #         'ttiStream'))
    files.append(
        os.path.join(
            parent,
            'TtiTracer',
            'onlineTtiStream',
            'onlineTtiStream.exe'))
    files.append(
        os.path.join(
            parent,
            'TtiTracer',
            'onlineTtiStream',
            'onlineTtiStream'))
    for file_name in files:
        try:
            shutil.copy(file_name, parent)
        except Exception as err:
            print(err)
    # shutil.rmtree(os.path.join(parent, 'pstools'))
    shutil.rmtree(os.path.join(parent, 'pscli'))
    shutil.rmtree(os.path.join(parent, 'TtiTracer'))
    if os.path.exists('/opt/TtiTracer/pstools/pscli/'):
        pscli_path = '/opt/TtiTracer/pstools/pscli/'
    else:
        pscli_path = '/opt/TtiTracer/'
    shutil.copy(os.path.join(parent, 'ERadSwDomainLteMac.h'), pscli_path)
    shutil.copy(os.path.join(parent, 'PsFeatureLevels.hpp'), pscli_path)

    logging.info("%s unzip ok and copy useful file ok" % parent)
    return True


if __name__ == "__main__":
    # , 'TL00_ENB_9999_160913_051003', 'TL16_ENB_0000_000983_000000']
    a = ['TL17_ENB_9999_160910_050880']
    for b in a:
        DownloadPStools(b)

    get_useful_files("D:\\jenkins\\workspace\\Everything_get_pstools\all\\TL00_ENB_9999_160912_050914")
    get_pstools_all()
    delete_null_flder()
    download_trunk_pstools('TL00_ENB_9999_160719_048388', 'c:\\tool')
    _get_fdd_pstools('TL00_ENB_9999_160910_050880', '/home/ute/temp')
    _get_branch_pstool('TL00_ENB_9999_160719_048388', 'c:\\tool')
    _latest_get_pstool('TL16A_ENB_0000_000579_000000', 'c:\\tool')
