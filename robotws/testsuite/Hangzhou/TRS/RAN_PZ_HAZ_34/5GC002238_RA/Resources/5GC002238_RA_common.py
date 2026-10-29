
import re
import linecache
from xml.dom.minidom import parse
from robot.libraries.BuiltIn import BuiltIn
import os


def get_DSCP_by_txt_file(file_path, message):
    count = len(open(file_path).readlines())
    dscp_list = []
    for i in range(0, count):
        fst_line = linecache.getline(file_path, i)
        if message in fst_line:
            dscp_line = linecache.getline(file_path, i+1).split('(')[-1].split(')')[0]
            dscp_list.append(int(dscp_line))
            version_number = linecache.getline(file_path, i-2).split(' ')[-1].strip()
            du_ip = linecache.getline(file_path, i-3).split(' ')[-3].split(',')[0].strip()
            F1_U_ip = linecache.getline(file_path, i-3).split(' ')[-1].strip()
    return dscp_list, version_number, du_ip, F1_U_ip
