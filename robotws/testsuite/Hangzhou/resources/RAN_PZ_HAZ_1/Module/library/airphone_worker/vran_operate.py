import copy
import re
import os
import shutil
import csv


def replace_line(file_path, line_number, new_content):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    if line_number < 1 or line_number > len(lines):
        print("Invalid line number")
        return

    lines[line_number] = new_content  # + '\n'

    with open(file_path, 'w') as file:
        file.writelines(lines)


def change_VDU_TLconfig_in_scf(
        new_serialnumber, new_RANNIC1_PRODUCT_CODE, DU_scf):
    DU_abspath = os.path.abspath(DU_scf)
    index_point = DU_abspath.index('.')
    DU_cp_abspath = DU_abspath[:index_point] + '_cp' + DU_abspath[index_point:]
    shutil.copyfile(DU_abspath, DU_cp_abspath)  # 备份
    '''
    with open(ini_file, 'r', encoding='utf-8') as infile:
        list_reader = infile.readlines()
        for i_line in list_reader:
            if 'serial_number' in i_line:
                new_serialnumber = re.findall('".*?"', i_line)[0]
                new_serialnumber = new_serialnumber[1:-1]
                print('new_Serailnum:', new_serialnumber)
                break
    '''
    with open(DU_cp_abspath, 'r') as file:
        list_reader = file.readlines()
        for i_line in list_reader:
            if 'com.nokia.srbts.eqm:RNICMOD' in i_line:
                index = list_reader.index(i_line)
                break
        find_RNICMOD_prodCode = False
        for i_line in list_reader[index:]:
            if 'prodCodePlanned' in i_line and not find_RNICMOD_prodCode:
                index_RNICMOD_prodCode = list_reader.index(i_line)
                old_prodCode = re.findall('>(.*?)<', i_line)[0]
                print('old_prodCode:', old_prodCode)
                index_1 = i_line.index('>')
                pre = i_line[:index_1 + 1]
                index_2 = i_line.find('<')  # '<'第一次位置
                index_3 = i_line.find('<', index_2 + 1)  # '<'第二次位置
                suff = i_line[index_3:]
                new_line_prodCode = pre + new_RANNIC1_PRODUCT_CODE + suff
                print('new_line:', new_line_prodCode)
                print('old_line:', i_line)
                find_RNICMOD_prodCode = True

            if 'serialNumberPlanned' in i_line:
                index_serianumber = list_reader.index(i_line)
                old_serialnumber = re.findall('>(.*?)<', i_line)[0]
                print('old_Serialnum:', old_serialnumber)

                index_1 = i_line.index('>')
                pre = i_line[:index_1 + 1]
                index_2 = i_line.find('<')  # '<'第一次位置
                index_3 = i_line.find('<', index_2 + 1)  # '<'第二次位置
                suff = i_line[index_3:]
                new_line_SerialNumber = pre + new_serialnumber + suff
                print('new_line:', new_line_SerialNumber)
                print('old_line:', i_line)
                break

    replace_line(DU_cp_abspath, index_serianumber, new_line_SerialNumber)
    replace_line(DU_cp_abspath, index_RNICMOD_prodCode, new_line_prodCode)
    return DU_cp_abspath
