import taf.sbts.oam.coam.admin
import csv
import re


def get_alpha_value(file_path, search_string='<alpha>0</alpha><beta>0</beta>'):
    with open(file_path,  mode='r') as f:
        line_list = f.readlines()
        alpha_value_flag = 0
        for row in line_list:
            print (row)
            if 'txArray' in row:
                if search_string in row:
                    alpha_value_flag = alpha_value_flag + 1
    return alpha_value_flag
