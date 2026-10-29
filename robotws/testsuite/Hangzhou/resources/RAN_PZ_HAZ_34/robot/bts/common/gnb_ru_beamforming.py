# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:in case of changes please contact author,
:do not modify without permission
created by: LEOPARD-668
modified by: LEOPARD-1418
"""

import re
import time

from taf.transport.ssh import ssh
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation import *

csn = ssh()

__all__ = ['check_ru_beamforing']


class Beamforing(object):
    def __init__(self, ru_index=1, ru_alias='RU', connection='GNB_OAM'):
        self.ru_index = ru_index
        self.ru_alias = ru_alias
        self.connection = connection
        self.cell_list = get_all_cell_id_via_admin(ru_index=self.ru_index, connection=self.connection)


class CpriBeamforing(Beamforing):
    def get_ru_beamforing(self):
        print("no need to get CPRI RU beamforing calibration")
        return []

    def check_ru_beamforing(self, carrier_info):
        print("no need to check CPRI RU beamforing calibration")
        return None

    def get_beamforing_count(self):
        print("no need to Get CPRI RU beamforing calibration")
        return None


class EcpriBeamforing(Beamforing):

    def get_ru_beamforing(self):
        bf_output = csn.execute(command='sudo bfcali -stat', connection=self.ru_alias)
        carrier_num = re.search(pattern='Calibration statistics are stored for (\\d+) carriers',
                                string=bf_output).group(1)
        print('carrier_num: {}'.format(carrier_num))
        all_carrier = []
        if int(carrier_num) == 0:
            return all_carrier
        carrier_content_list = bf_output.split('\r\n\r\n')
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

    def check_ru_antenna(self, carrier_name):
        bf_output = csn.execute(command='sudo bfcali -stat {} | grep isCalibrated'. format(carrier_name),
                                connection=self.ru_alias)
        if 'false' in bf_output:
            return False
        else:
            return True

    def check_ru_beamforing(self, carrier_info):
        calibration_attempts = int(carrier_info['Calibration attempts'])
        successful_calibrations = int(carrier_info['Successful calibrations'])
        if calibration_attempts == successful_calibrations:
            return True
        elif calibration_attempts - successful_calibrations >= 2:
            return False
        else:
            time.sleep(60)
            return self.check_ru_antenna(carrier_name=carrier_info['Carrier name'][0])

    def get_beamforing_count(self):
        all_carrier = self.get_ru_beamforing()
        if len(all_carrier) == 0:
            return None
        count = all_carrier[0]['Calibration attempts']
        return count


def check_ru_beamforing(ru_index=1, ru_alias='RU', connection='GNB_OAM', check_count=True):
    radio_protocol = get_radio_protocal_via_admin(ru_index=ru_index, connection=connection)
    if radio_protocol == 'CPRI':
        object = CpriBeamforing(ru_index=ru_index, ru_alias=ru_alias, connection=connection)
    else:
        object = EcpriBeamforing(ru_index=ru_index, ru_alias=ru_alias, connection=connection)
    all_carrier = object.get_ru_beamforing()
    carrier_flag = True
    if len(all_carrier) == 0:
        return None
    if check_count:
        count = object.get_beamforing_count()
        if int(count) <= 0:
            print('get beamforing calibration is 0 when check count')
            return False
    for carrier_info in all_carrier:
        print(carrier_info)
        flag = object.check_ru_beamforing(carrier_info)
        if not flag:
            carrier_flag = False
    return carrier_flag
