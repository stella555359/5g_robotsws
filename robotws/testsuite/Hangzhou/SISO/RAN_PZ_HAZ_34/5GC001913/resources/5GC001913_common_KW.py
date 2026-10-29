# -*- coding: utf-8 -*
"""
:author: Hongyu Jiang
:contact: hongyu.jiang@nokia-sbell.com
:squad group: mmw_SG_04
"""
import os


def split_traffic_data_string(data):
    list1 = data.split('\r\n')
    new_list = [i + '\r\n' for i in list1 if i.isdigit()]
    new_str = ''.join(new_list)
    return new_str


def Covert_BTS_Version(version):
    package = version.split('_')[-2]
    scf_name = ''
    package_21B = version.split('_')[-3]
    if package == '9999':
        scf_name = 'SCF_SBTS00.xml'
    elif package == '001100':
        scf_name = 'SCF_10.1100_DU.xml'
    if package_21B == '0012':
        scf_name = 'SCF_12.400_DU.xml'
    return scf_name
