# -*- coding: utf-8 -*
import re


def Covert_BTS_Version(version, gnbnumber):
    scf_name = ''
    package = version.split('_')[2]
    if package == '9999':
        if str(gnbnumber) == '1':
            scf_name = 'SCF_Trunk_gNB1.xml'
        else:
            scf_name = 'SCF_Trunk_gNB2.xml'
    elif package == '0000':  # uncertain
        if str(gnbnumber) == '2':
            scf_name = 'SCF_SBTS22R1_gNB2.xml'
        else:
            scf_name = 'SCF_SBTS22R1_gNB1.xml'
    return scf_name


def Get_Viavi_CSV_Log_Path(log_str):
    log_list = []
    replace_list = [[r'\\', r'/'], ["'", ""], ['C:', '/cygdrive/c'], [r'\r', '']]
    log = re.search('Current logging folder is .*', log_str).group()
    log = re.search('C:.*', log).group()
    for sub_list in replace_list:
        log = re.sub(sub_list[0], sub_list[1], log)
    dir_name = log.split(r'/')[-1]
    log_list = [log, dir_name]
    return log_list


def Get_csv_is_exsit(input_list):
    return_list = []
    for i in input_list:
        if len(i) != 0:
            if 'L1DLSTATS' in i and i.split('.')[-1] == 'csv':
                return_list.append(i)
            if 'L1ULSTATS' in i and i.split('.')[-1] == 'csv':
                return_list.append(i)
    return return_list
