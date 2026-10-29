# -*- coding: utf-8 -*
import re


def check_parameter_value_in_btslog_file(input_content, keyword, except_value):
    for i in input_content.split(','):
        if keyword in i:
            value = re.findall(r'\d+\.?\d+', i)
            if abs(float(value[0])) < float(except_value):
                return True
            else:
                return False


def check_syncSourceInfo_if_right(input_list):
    key_list = ['isActive', 'status', 'syncInputPrio']
    topp_list = []
    other_list = []
    total_list = []
    for syncSourceInfo_dic in input_list:
        if syncSourceInfo_dic['syncInputType'] == 'TOPP':
            for key in key_list:
                topp_list.append(syncSourceInfo_dic[key])
        else:
            for key in key_list:
                other_list.append(syncSourceInfo_dic[key])
    total_list.append(topp_list)
    total_list.append(other_list)
    return total_list


def check_active_alarms_faultId(faultId_list, faultId):
    if int(faultId) in faultId_list:
        return True
    else:
        return False


def get_active_alarms_faultId(alarms_list, keyword):
    fault_id_list = []
    for alarms in alarms_list:
        fault_id_list.append(alarms[keyword])
    return fault_id_list


def check_relation_error(input_list, excpect_list):
    for i in excpect_list:
        if i not in input_list:
            return True
        else:
            return False


def Covert_BTS_Version(version):
    package = version.split('_')[-2]
    package_21B = version.split('_')[-3]
    if package == '000400':
        scf_name = 'SCF_14.400_DU.xml'
    elif package == '001100':
        scf_name = 'SCF_10.1100_DU.xml'
    if package_21B == '0012':
        scf_name = 'SCF_12.400_DU.xml'
    return scf_name
