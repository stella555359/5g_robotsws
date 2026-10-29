# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Liu Tingting
:contact: tingting.1.liu@nokia-sbell.com
"""
import re


def check_4G_dl_throughput(log_file):
    with open(log_file, encoding='utf-8') as f:
        contents = f.read()
        matched_list = re.findall(r'INF/PDCP/STATS/DL: DRB S1.*inBytes:\s(\d+\s\d+\s\d+\s).*', contents)
        new_list = []
        for i in matched_list:
            if i == '0 0 0 ':
                continue
            else:
                new_elements = map(int, i.split())
                new_element_sum = sum(new_elements)
                print('new_element_sum:', new_element_sum)
                new_list.append(new_element_sum)
        num = len(new_list)
        tput_sum = sum(new_list)
        average_tput = tput_sum/1024/1000/(num*3)/2
        return average_tput


def check_4G_ul_throughput(log_file):
    with open(log_file, encoding='utf-8') as f:
        contents = f.read()
        matched_list = re.findall(r'INF/PDCP/STATS/UL: DataPDU:\s(\d+\s\d+\s\d+\s).*', contents)
        new_list = []
        for i in matched_list:
            if i == '0 0 0 ':
                continue
            else:
                new_elements = map(int, i.split())
                new_element_sum = sum(new_elements)
                avrerage_new_element = new_element_sum*1052*8/6
                new_list.append(avrerage_new_element)
        num = len(new_list)
        tput_sum = sum(new_list)
        ul_average_tput = tput_sum/num/1000000
        return ul_average_tput
