import re
import os


def Get_frame_from_txt(txt_file):
    frame_num_list = []
    fl = open(txt_file, 'r')
    for line in fl.readlines():
        if line.startswith('Frame '):
            for i in re.findall(r'\d+', line.split(':')[0]):
                frame_num_list.append(int(i))
    print(frame_num_list)
    return frame_num_list


def Check_frame_info(req_fl, resp_fl):
    req_list = Get_frame_from_txt(req_fl)
    resp_list = Get_frame_from_txt(resp_fl)
    if resp_list[0] < req_list[0]:
        del resp_list[0]
    if len(req_list) - len(resp_list) == 1:
        del req_list[-1]
    elif len(req_list) - len(resp_list) > 4:
        return False
    for i in range(0, len(resp_list)):
        if resp_list[i] - req_list[i] > 3:
            return False
    return True


def get_alpha_value(file_path, search_string='<alpha>0</alpha><beta>0</beta>'):
    with open(file_path,  mode='r') as f:
        line_list = f.readlines()
        alpha_value_flag = 0
        for row in line_list:
            print(row)
            if 'txArray' in row:
                if search_string in row:
                    alpha_value_flag = alpha_value_flag + 1
    return alpha_value_flag
