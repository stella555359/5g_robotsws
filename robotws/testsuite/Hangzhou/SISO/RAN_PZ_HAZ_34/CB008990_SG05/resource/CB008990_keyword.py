# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Liu Yue
:contact: yue.2.liu@nokia-sbell.com
:in case of changes please contact author,
:do not modify without permission
created by: CB008990
"""
import re
import time

# from taf.transport.ssh import ssh
# from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation import *


def get_ru_carrier_name(input):
    carrier_num = re.search(pattern='Calibration statistics are stored for (\\d+) carriers',
                            string=input).group(1)
    print('carrier_num: {}'.format(carrier_num))
    all_carrier = []
    if int(carrier_num) == 0:
        return all_carrier
    carrier_content_list = input.split('\r\n\r\n')
    carrier_content_list.pop(0)
    for carrier_content in carrier_content_list:
        content = carrier_content.strip().split('\r\n')
        carrier_info = {}
        one_carrier_name = ''
        for line in content:
            item = line.strip().split(':')
            if len(item) == 1:
                one_carrier_name = item[0]
            elif len(item) == 2:
                name, value = line.strip().split(':')
                carrier_info[name.strip()] = value.strip()
        if carrier_info != {} and 'Carrier name' in carrier_info:
            name_list = [carrier_info['Carrier name']]
            if one_carrier_name:
                name_list.append(one_carrier_name)
            carrier_info['Carrier name'] = name_list
            all_carrier.append(carrier_info)
    return all_carrier
