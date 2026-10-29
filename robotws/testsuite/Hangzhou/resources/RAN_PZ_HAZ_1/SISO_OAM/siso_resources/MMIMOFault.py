"""This file is used to generate Mmimo fault 1907,1911 command
These keywords can be use in Robot framework.
"""
from __future__ import absolute_import
from __future__ import print_function
import random


class MMIMOFault(object):
    def __init__(self, **kwargs):
        self._fault_1907_base_fs = 8847.36
        self._fault_1907_cmd = []
        self.fault_1907_cmd_list = []
        self._fault_1911_def_cmd = {'0': 'devmem 0xae102', '1': 'devmem 0xae202', '2': 'devmem 0xae402',
                                    '3': 'devmem 0xae802'}
        self._fault_1911_aef_cmd = \
            {'0': ['0', '1', '2', '3'], '1': ['4', '5', '6', '7'],
             '2': ['8', '9', 'A', 'B'], '3': ['C', 'D', 'E', 'F']}
        self._fault_1911_cmd = []
        self.fault_1911_cmd_list = []
        # self.cell_fre = kwargs.get('frequency',None)
        # self.dfe_chip = None
        # self.afe_chip = None

    def fault_1907_calcuate(self, frequency, dfe_chip, afe_chip):
        frequency = int(frequency)
        dfe_chip = int(dfe_chip)
        afe_chip = int(afe_chip)
        Fs = self._fault_1907_base_fs / 3.0
        value_dec = int(frequency / Fs * (2 ** 32))
        value_hex = (hex(value_dec)).upper()
        print('value_HEX=', value_hex)
        value_0 = value_hex[-2:]
        value_1 = value_hex[6:6 + len(value_hex) - 8]
        value_2 = value_hex[4:4 + len(value_hex) - 8]
        value_3 = value_hex[2:4]
        cmd1 = 'dfe_afe_spi_access %d %d -w 0x00 0x16 0xF' % (dfe_chip, afe_chip)
        cmd6 = 'dfe_afe_spi_access %d %d -w 0x00 0x16 0x0' % (dfe_chip, afe_chip)
        cmd_temp_list = ['0xE6', '0xE7', '0xF0', '0xF1']
        self._fault_1907_cmd = [cmd1, cmd6]
        for index in range(0, 4):
            value_tmp = 'value_%d' % index
            cmd_tmp = 'dfe_afe_spi_access %d %d -w 0x01 %s 0x%s' % (
                dfe_chip, afe_chip, cmd_temp_list[index], locals()[value_tmp])
            self._fault_1907_cmd.insert(-1, cmd_tmp)
        return self._fault_1907_cmd

    def fault_1907_calcuate_multi(self, frequency, dfe_afe_list):  # list should like ['dfe_afe','3_2','2_1']
        if not isinstance(dfe_afe_list, list):
            raise TypeError('type is not list')
        for dfe_afe in dfe_afe_list:
            dfe, afe = dfe_afe.split('_')
            __fault_1907_cmd_list_temp = self.fault_1907_calcuate(frequency, dfe, afe)
            self.fault_1907_cmd_list.extend(__fault_1907_cmd_list_temp)
        return self.fault_1907_cmd_list

    def fault_1911_calcuate(self, dfe_chip, afe_chip):
        _fault_1911_cmd = []
        def_cmd_part = self._fault_1911_def_cmd[str(dfe_chip)]
        afe_cmd_part = self._fault_1911_aef_cmd[str(afe_chip)]
        for item in afe_cmd_part:
            cmd_tmp = '%s%s90 32 0x0007' % (def_cmd_part, item)
            _fault_1911_cmd.append(cmd_tmp)
        return _fault_1911_cmd

    def fault_1911_calcuate_multi(self, dfe_afe_list):  # list should like ['dfe_afe','3_2','2_1']
        fault_1911_cmd_list = []
        if not isinstance(dfe_afe_list, list):
            raise TypeError('type is not list')
        for dfe_afe in dfe_afe_list:
            dfe, afe = dfe_afe.split('_')
            __fault_1911_cmd_list_temp = self.fault_1911_calcuate(dfe, afe)
            fault_1911_cmd_list.extend(__fault_1911_cmd_list_temp)
        return fault_1911_cmd_list

    def fault_6051_calcuate(self, orientation, cmd_num):
        fault_6051_cmd = ['devmem 0xae402F90 32 0x0007']
        broken_port = ['36']
        _fault_1911_port_num = \
            {'802B': '0', '802A': '1', '8029': '2', '8028': '3', '8027': '4', '8026': '5', '8025': '6', '8024': '7',
             '102B': '8', '102A': '9', '1029': '10', '1028': '11', '1027': '12', '1026': '13', '1025': '14',
             '1024': '15', '802C': '16', '802D': '17', '802E': '18', '802F': '19', '8020': '20', '8021': '21',
             '8022': '22', '8023': '23', '102C': '24', '102D': '25', '102E': '26', '102F': '27', '1020': '28',
             '1021': '29', '1022': '30', '1023': '31', '4023': '32', '4022': '33', '4021': '34', '4020': '35',
             '402F': '36', '402E': '37', '402D': '38', '402C': '39', '2023': '40', '2022': '41', '2021': '42',
             '2020': '43', '202F': '44', '202E': '45', '202D': '46', '202C': '47', '4024': '48', '4025': '49',
             '4026': '50', '4027': '51', '4028': '52', '4029': '53', '402A': '54', '402B': '55', '2024': '56',
             '2025': '57', '2026': '58', '2027': '59', '2028': '60', '2029': '61', '202A': '62', '202B': '63'}
        _fault_1911_cmd_part = {'Left': ['4', '8'], 'Right': ['1', '2'], 'Top': ['2', '4'], 'Bottom': ['1', '8']}
        while len(fault_6051_cmd) <= cmd_num:
            if orientation == 'Full':
                cmd_part1 = random.choice('1248')
            else:
                cmd_part1 = random.choice(_fault_1911_cmd_part[orientation])
            cmd_part2 = random.choice("123456789ABCDE")
            fault_6051_cmd.append('devmem 0xae%s02%s90 32 0x0007' % (cmd_part1, cmd_part2))
            broken_port.append(_fault_1911_port_num['%s02%s' % (cmd_part1, cmd_part2)])
            fault_6051_cmd = list(set(fault_6051_cmd))
        broken_port = list(set(broken_port))
        return fault_6051_cmd, broken_port


if __name__ == '__main__':
    test = MMIMOFault()
    # print test.fault_1907_calcuate_multi(2620,['1_3'])
    print(test.fault_1911_calcuate_multi(['1_3', '2_2']))
