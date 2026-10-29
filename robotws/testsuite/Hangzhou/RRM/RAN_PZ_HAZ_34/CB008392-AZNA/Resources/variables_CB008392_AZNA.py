# !/usr/bin/python
# -*- coding: utf-8 -*-
import time
from datetime import datetime
from taf.transport.ssh import ssh

tput_define_AZNA = {
    1: {
        'dl_exp': 565,
        'dl_tp': '650M',
        'ul_exp': 26,
        'ul_tp': '100M',
        'ue_index': 0
    },
}


def get_current_time_from_gnb(hostname='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu'):
    cmd_weekday = 'date +"%a"'
    cmd = 'date +"%Y %m %d %X"'
    csn = ssh()
    try:
        csn.connect_to(hostname=hostname, username=username, password=password)
        weekday = csn.execute(cmd_weekday)
        weekday = weekday.replace('\r\n', '')
        gnb_time = csn.execute(cmd)
        gnb_time = gnb_time.replace('\r\n', '')
        gnb_time = datetime.strptime(gnb_time, '%Y %m %d %H:%M:%S')
        return weekday, gnb_time
    except Exception:
        csn.disconnect()


def get_lbps_current_time_AZNA():
    weekday, gnb_time = get_current_time_from_gnb()
    hour = gnb_time.hour
    minute = gnb_time.minute
    print(weekday, hour, minute)
    return weekday, hour, minute


def get_item_times_in_list(item_list, item):
    times_list = []
    for i in item_list:
        if i == item:
            times_list.append(i)
    item_times = len(times_list)
    return item_times
