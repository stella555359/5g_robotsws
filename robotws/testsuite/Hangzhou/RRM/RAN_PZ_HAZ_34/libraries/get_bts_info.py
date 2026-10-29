# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Yali Guo
:contact: yali.guo@nokia-sbell.com
:maintainer: Yali Guo
:contact: yali.guo@nokia-sbell.com
"""
import re
import os


def Get_MO(scf_path):
    """
    The keyword used for get MO list from SCF file

    :param scf_path: String, the scf file path want to check
    :return: List, MO list
    """
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*distName=\"(.*?)\" operation='
        MOList = re.findall(rule, xml)
        return MOList


def Get_MRBTS_Version(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*class=\"com.nokia.srbts:MRBTS\" version=\"(.*?)\" operation='
        versionlist = re.findall(rule, xml)
        version = ""
        version = version.join(versionlist)
        return version


def Get_NRBTS_Version(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*class=\"com.nokia.srbts.nrbts:NRBTS\" version=\"(.*?)\" operation='
        versionlist = re.findall(rule, xml)
        version = ""
        version = version.join(versionlist)
        return version


def Get_EQM_Version(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*class=\"com.nokia.srbts.eqm:EQM\" version=\"(.*?)\" operation='
        versionlist = re.findall(rule, xml)
        version = ""
        version = version.join(versionlist)
        return version


def Get_MNL_Version(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*class=\"com.nokia.srbts.mnl:MNL\" version=\"(.*?)\" operation='
        versionlist = re.findall(rule, xml)
        version = ""
        version = version.join(versionlist)
        return version


def Get_TNL_Version(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*class=\"com.nokia.srbts.tnl:TNLSVC\" version=\"(.*?)\" operation='
        versionlist = re.findall(rule, xml)
        version = ""
        version = version.join(versionlist)
        return version


def Get_MRBTS_ID(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*MRBTS\" distName=\"(.*?)\" operation='
        MRBTSIDlist = re.findall(rule, xml)
        MRBTSID = ""
        MRBTSID = MRBTSID.join(MRBTSIDlist)
        return MRBTSID


def Get_MRBTSID_cOAM(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*MRBTS\" distName=\"MRBTS-(.*?)\" version=\"'
        MRBTSIDlist = re.findall(rule, xml)
        MRBTSID = ""
        MRBTSID = MRBTSID.join(MRBTSIDlist)
        return MRBTSID


def Get_NRBTS_ID(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*NRBTS\" distName=\".*\/(.*?)\" operation='
        NRBTSIDlist = re.findall(rule, xml)
        NRBTSID = ""
        NRBTSID = NRBTSID.join(NRBTSIDlist)
        return NRBTSID


def Get_NRBTSID_cOAM(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*NRBTS\" distName=\".*\/NRBTS-(.*?)\" version=\"NRBTS'
        NRBTSIDlist = re.findall(rule, xml)
        NRBTSID = ""
        NRBTSID = NRBTSID.join(NRBTSIDlist)
        return NRBTSID


def Get_BTS_name(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*name=\"btsName\">(.*?)</p>'
        BTS_namelist = re.findall(rule, xml)
        BTS_name = ""
        BTS_name = BTS_name.join(BTS_namelist)
        return BTS_name


def Get_VTK_Operation_feedback(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*<message_result>(.*?)</message_result>'
        Operation_feedback_list = re.findall(rule, xml)
        Operation_feedback = ""
        Operation_feedback = Operation_feedback.join(Operation_feedback_list)
        return Operation_feedback


def Get_fault_name(scf_path):
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*<additionalText1>(.*?)</additionalText1>'
        fault_name_list = re.findall(rule, xml)
        fault_name = ""
        fault_name = fault_name.join(fault_name_list)
        return fault_name


def Refine_fie_name(list):
    file_name = list.strip('\r\n')
    return file_name


def get_disk_mapping(disk_map_info):
    stb_rule = r".*\sstb.*(/ffs/fs\d)"
    run_rule = r".*\srun.*(/ffs/fs\d)"
    run_disk = ""
    stb_disk = ""
    for line in disk_map_info.splitlines():
        if re.findall(run_rule, line):
            print(re.findall(run_rule, line))
            run_disk = re.findall(run_rule, line)[0]
        elif re.findall(stb_rule, line):
            print(re.findall(stb_rule, line))
            stb_disk = re.findall(stb_rule, line)[0]
    return run_disk, stb_disk


def get_disk_space(space_info, active_disk, passive_disk):
    active_spare = "0"
    passive_spare = "0"
    for line in space_info.splitlines():
        items = line.split()
        if items[-1] == active_disk:
            active_spare = items[3]
        elif items[-1] == passive_disk:
            passive_spare = items[3]
    return active_spare, passive_spare


def get_cell_group_mapping(bts_info):
    group_list = bts_info['cellsGroup']
    group_mapping = range(len(group_list))
    for group in group_list:
        group_index = int(group['name'].split("-")[1])
        cell_list = [int(cell.split("-")[1]) for cell in group['nrCellList']]
        group_mapping[group_index] = cell_list
    return group_mapping
