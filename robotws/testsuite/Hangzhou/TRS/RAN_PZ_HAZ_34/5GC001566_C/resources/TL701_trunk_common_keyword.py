# -*- coding: utf-8 -*
import re
import os
import time


def judge_time(time_list):
    flag = True
    for i in range(0, len(time_list)-1):
        diff = float(time_list[i+1]) - float(time_list[i])
        if (diff > 0.5) or (diff < 0.375):
            flag = False
            return flag
        if i == len(time_list) - 2:
            return flag


def trnsport_bfd(filename, c, d):
    e = "'changetype' : Add"
    file = open(filename, 'r')
    lines = file.read().splitlines()
    for line in lines:
        a = str(line.split('2021')[1])
        if (c in a) and (d in a) and (e in a):
            return True
    return False


def Read_Bdf_Log(file_path):
    result = []
    file = open(file_path, 'r')
    for line in file.readlines():
        if 'My Discriminator' in line:
            for i in re.findall(r'\d+\w+', line.split(':')[-1]):
                result.append(i)
    return result
