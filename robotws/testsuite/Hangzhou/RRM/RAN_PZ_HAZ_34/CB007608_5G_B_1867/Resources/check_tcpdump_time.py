# -*- coding: utf-8 -*
import re
import linecache
from xml.dom.minidom import parse
import os
from robot.libraries.BuiltIn import BuiltIn


def return_time_diff(list1, list2):
    output_dict_list = []
    diff_H = []
    list3 = []
    list_starttime = []
    list4 = []
    list_stoptime = []
    a = ':'
    for i in range(0, len(list1)):
        list1_C = int((list1[i].split(':')[0]))+8
        if list1_C > 24:
            list1_C = list1_C-24
        elif list1_C == 24:
            list1_C = 0
        list3 = [str(list1_C), str(int(list1[i].split(':')[1])), str(int(list1[i].split(':')[2]))]
        for k in range(0, len(list3)):
            if int(list3[k]) < 10:
                list3[k] = str('0') + str(list3[k])
        b = a.join(list3)
        list_starttime.append(b)
        list2_C = int((list2[i].split(':')[0])) + 8
        if list2_C > 24:
            list2_C = list2_C - 24
        list4 = [str(list2_C), str(int(list2[i].split(':')[1])), str(int(list2[i].split(':')[2]))]
        for k in range(0, len(list4)):
            if int(list4[k]) < 10:
                list4[k] = str('0') + str(list4[k])
        d = a.join(list4)
        list_stoptime.append(str(d))
        list1sum = int(list1[i].split(':')[0])*60*60 + int(list1[i].split(':')[1])*60 + int(list1[i].split(':')[2])
        list2sum = int(list2[i].split(':')[0])*60*60 + int(list2[i].split(':')[1])*60 + int(list2[i].split(':')[2])
        diff_H = list2sum - list1sum
        output_dict_list.append(str(diff_H))
    return output_dict_list, list_starttime, list_stoptime,
