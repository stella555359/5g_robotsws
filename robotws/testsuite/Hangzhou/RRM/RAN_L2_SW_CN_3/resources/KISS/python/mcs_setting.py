# -*- coding: UTF-8 -*-
# !/usr/bin/python

from hbte import PA
from base_logic import HbteException
import time
import csv
import numpy as np

factor = 2.8125


def _read_csv(filename):
    datas = []
    channelList = []
    phaseList = []
    with open(filename) as file:
        lines = csv.reader(file)
        for i, line in enumerate(lines):
            if i > 1:
                datas.append(line[:16])
    # print datas
    temp_datas = np.transpose(datas).reshape(64*16)
    for i, element in enumerate(temp_datas, start=1):
        channelList.append(i)
        if '.' in element:
            phaseList.append(float(element))
        else:
            phaseList.append(int(element))
    return channelList, phaseList


def set_mcs_phase_from_csv(filename, ip):
    channelList, phaseList = _read_csv(filename)
    pa = PA(ip)
    try:
        if pa.operateChannelPhase(channelList, phaseList):
            print("operate channel phase ok ")
        else:
            print("operate channel phase failed ")
    except HbteException as e:
        print(e.error)
    import random
    number = random.sample(channelList, 1)
    value = float(phaseList[number[0]]/factor)
    value_int = int(value)
    D_value = value-value_int
    if D_value > 0.5:
        real_value = (value_int+1)*factor
    else:
        real_value = value_int*factor
    check_value = pa.queryChannelPhase(channelList=number)
    if real_value == check_value[0]:
        return True
    else:
        return False


def set_mcs_att_from_csv(filename, ip):
    channelList, valueList = _read_csv(filename)
    pa = PA(ip)
    try:
        if pa.operateChannel(channelList, valueList):
            print("operate channel ok ")
        else:
            print("operate channel failed ")
    except HbteException as e:
        print(e.error)


def phase_calc(angle_h, angle_v):
    basic_data = np.tile(np.arange(1, 9), (4, 1))
    basic_data_row = np.zeros((4, 8))
    for i in range(4):
        basic_data_row[i] = i + 1
    value = ((basic_data-1)*180*np.sin(angle_h*np.pi/180.0)+(basic_data_row-1)*2.8*180*np.sin(angle_v*np.pi/180.0)) \
        % 360
    return value.repeat(2).round(2).tolist()


def generate_channel_and_phase_list(output_id_list, angle_h, angle_v):
    angle_h = float(angle_h)
    angle_v = float(angle_v)
    channelList = []
    for i in output_id_list:
        temp_listed = range(64*(i-1)+1, 64*(i-1)+65)
        channelList.extend(temp_listed)
    value = phase_calc(angle_h, angle_v)
    phaseList = np.tile(value, (1, len(output_id_list)))[0].tolist()
    return channelList, phaseList


def att_calc(att_odd, att_even):
    data = np.array([att_odd, att_even])
    return np.tile(data, 32).tolist()


def generate_channel_and_att_list_2port(output_id_list, att_odd, att_even):
    att_even = float(att_even)
    att_odd = float(att_odd)
    channelList = []
    valueList = []
    for i in output_id_list:
        temp_listed = range(64 * (i - 1) + 1, 64 * (i - 1) + 65)
        channelList.extend(temp_listed)
    port_1_list = att_calc(att_odd, att_even)
    port_2_list = port_1_list[::-1]
    valueList.extend(port_1_list)
    valueList.extend(port_2_list)
    return channelList, valueList


def set_mcs_phase_via_input(ip, output_id_list, angle_h, angle_v):
    channelList, phaseList = generate_channel_and_phase_list(output_id_list, angle_h, angle_v)
    pa = PA(ip)
    try:
        if pa.operateChannelPhase(channelList, phaseList):
            print("operate channel phase ok ")
        else:
            print("operate channel phase failed ")
    except HbteException as e:
        print(e.error)


def set_mcs_att_2port_via_input(ip, output_id_list, att_odd, att_even):
    channelList, valueList = generate_channel_and_att_list_2port(output_id_list, att_odd, att_even)
    pa = PA(ip)
    try:
        if pa.operateChannel(channelList, valueList):
            print("operate channel ok ")
        else:
            print("operate channel failed ")
    except HbteException as e:
        print(e.error)


if __name__ == '__main__':
    # _read_csv('Att_zwc.csv')
    # set_mcs_phase_via_input(ip='10.69.66.228', output_id_list=[1,2], angle_h=10, angle_v=0)
    # set_mcs_att_2port_via_input(ip='10.69.66.228', output_id_list=[1,2], att_odd=10, att_even=60)
    channelList, phaseList = generate_channel_and_phase_list(output_id_list=[1, 2], angle_h=-48.6, angle_v=16)
    print(channelList)
    print(phaseList)
    pass
