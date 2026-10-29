# -*- coding: utf-8 -*
import re
import linecache
from xml.dom.minidom import parse
from robot.libraries.BuiltIn import BuiltIn
import os


def Covert_BTS_Version(version, if_dss):
    package = version.split('_')[2]
    if package == '9999':
        if if_dss:
            scf_name = 'SCF_SBTS00_DSS.xml'
        else:
            scf_name = 'SCF_SBTS00.xml'
    else:
        package_version = version.split('_')[0]
        if if_dss:
            scf_name = 'SCF_' + package_version + '_DSS.xml'
        else:
            scf_name = 'SCF_' + package_version + '.xml'
    return scf_name
