#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
Python Class library to download luashark and BTS SW load.
"""
import re
import requests


def _get_remote_load_url(software_release):
    if "SBTS" in software_release:
        url = r"http://files.ute.nsn-rdnet.net/builds/enb/base"
        request_response = requests.head(r"{0}/{1}/".format(url, software_release))
        if request_response.status_code == 200:
            swrel = software_release
        else:
            id = software_release.find('_')
            swrel = 'SBTS00' + software_release[id:]
    else:
        url = r"https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release"
        swrel = software_release.split("GNB")
        swrel = re.sub(r"_0*", r".", swrel[1])
        swrel = swrel.replace("..", ".")[1:]
    return swrel, url


def get_remote_luashark_url(software_release):
    swrel, url = _get_remote_load_url(software_release)
    if "SBTS" in software_release:
        url = r'{0}/{1}/{1}_luashark.zip'.format(url, swrel)
    else:
        url = r'{0}/{1}/luashark-{1}.zip'.format(url, swrel)
    return url


def get_remote_build_url(software_release):
    swrel, url = _get_remote_load_url(software_release)
    if "SBTS" in software_release:
        url = r'{0}/{1}/{1}_release_BTSSM_downloadable.zip'.format(url, swrel)
    else:
        url = r'{0}/{1}/AirScale-{1}.zip'.format(url, swrel)
    return url
