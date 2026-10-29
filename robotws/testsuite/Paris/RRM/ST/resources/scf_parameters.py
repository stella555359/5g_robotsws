# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author:  Annie Wong (I&V)
:contact:  annie.wong@nokia.com
"""

import re
import os
from taf.config.scf import scf

scf = scf()


def delete_scf_file(scf_file):
    os.remove(scf_file)


def get_value_from_scf_with_taf(scf_file, **kwargs):
    scf.load_scf(scf_file)
    return scf.get_value_from_scf(**kwargs)


def get_values_from_scf_with_taf(scf_file, **kwargs):
    scf.load_scf(scf_file)
    return scf.get_all_values_from_scf(**kwargs)


def get_mrbts_id_from_scf(scf_file):
    scf.load_scf(scf_file)
    return scf.scf_operations._internal_scf.raml.cmData._path_root.split("-")[-1]


def Get_MRBTS_ID_withRegex(scf_file):
    with open(scf_file, 'r+') as f:
        xml = f.read()
        rule = r'..*class=\"com.nokia.srbts:MRBTS\" distName=\"MRBTS-(.*?)\" .*=\".*\" .*=\".*">'
        MRBTSIDlist = re.findall(rule, xml)
        MRBTSID = ""
        MRBTSID = MRBTSID.join(MRBTSIDlist)
        return MRBTSID


def Get_MRBTS_Version_withRegex(scf_file):
    with open(scf_file, 'r+') as f:
        xml = f.read()
        rule = r'.*class=\"com.nokia.srbts:MRBTS\" distName=\"MRBTS-.*\" version=\"(.*?)\".*'
        versionlist = re.findall(rule, xml)
        version = ""
        version = version.join(versionlist)
        return version


def Get_NRBTS_ID_withRegex(scf_file):
    with open(scf_file, 'r+') as f:
        xml = f.read()
        rule = r'.*class=\"com.nokia.srbts.nrbts:NRBTS\" distName=\"MRBTS-.*\/NRBTS-(.*?)\" .*=\".*\" .*=\".*\">'
        NRBTSIDlist = re.findall(rule, xml)
        NRBTSID = ""
        NRBTSID = NRBTSID.join(NRBTSIDlist)
        return NRBTSID


def Get_NRBTS_Version_withRegex(scf_file):
    with open(scf_file, 'r+') as f:
        xml = f.read()
        rule = r'.*class=\"com.nokia.srbts.nrbts:NRBTS\" distName=\"MRBTS-.*\/NRBTS-.*\" version=\"(.*?)\".*'
        versionlist = re.findall(rule, xml)
        version = ""
        version = version.join(versionlist)
        return version


def get_reportingIntervalPm_from_scf_with_taf_mzoam(scf_file):
    scf.load_scf(scf_file)
    mrbtsid = scf.scf_operations._internal_scf.raml.cmData._path_root.split("-")[-1]
    distname = "MRBTS-" + mrbtsid + "/MNL-1/PMCADM-1"
    return scf.get_value_from_scf(dist_name=distname, p_name="reportingIntervalPm")


def get_reportingIntervalPm_from_scf_with_taf_coam(scf_file):
    scf.load_scf(scf_file)
    mrbtsid = scf.scf_operations._internal_scf.raml.cmData._path_root.split("-")[-1]
    distname = "MRBTS-" + mrbtsid + "/MNL-1/MNLENT-1/PMCADM-1"
    return scf.get_value_from_scf(dist_name=distname, p_name="reportingIntervalPm")


def Get_ReportingIntervalPm_withRegex(scf_file):
    with open(scf_file, 'r+') as f:
        xml = f.read()
        rule = r'.*<p name=\"reportingIntervalPm\">(.*?)<.*'
        periodlist = re.findall(rule, xml)
        period = ""
        period = period.join(periodlist)
        return period


def Get_Value_reportingIntervalPm(scf_file):
    return Get_ReportingIntervalPm_withRegex(scf_file)


def Get_DllaIniMcs_withRegex(scf_file):
    with open(scf_file, 'r+') as f:
        xml = f.read()
        rule = r'.*<p name=\"dllaIniMcs\">(.*?)<.*'
        periodlist = re.findall(rule, xml)
        iniMcs = ""
        iniMcs = iniMcs.join(periodlist)
        return iniMcs


def Get_Value_dllaIniMcs(scf_file):
    return Get_DllaIniMcs_withRegex(scf_file)


def Get_ActEnhancedLinkAdaptation_withRegex(scf_file):
    with open(scf_file, 'r+') as f:
        xml = f.read()
        rule = r'.*<p name=\"actEnhancedLinkAdaptation\">(.*?)<.*'
        periodlist = re.findall(rule, xml)
        actEnhanLA = ""
        actEnhanLA = actEnhanLA.join(periodlist)
        return actEnhanLA


def Get_Value_actEnhancedLinkAdaptation(scf_file):
    return Get_ActEnhancedLinkAdaptation_withRegex(scf_file)


def Get_MO_withRegex(scf_file):
    """
    The keyword used for get MO list from SCF file
    :param scf_file: String, the scf file path want to check
    :return: List, MO list
    """
    with open(scf_file, 'r+') as f:
        xml = f.read()
        rule = r'.*distName=\"(.*?)\" operation='
        MOList = re.findall(rule, xml)
        return MOList
