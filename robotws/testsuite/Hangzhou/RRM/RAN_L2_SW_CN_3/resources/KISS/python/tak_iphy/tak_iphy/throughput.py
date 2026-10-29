# -*- coding: utf-8 -*-
"""
:created on: 15-04-2017

:copyright: Nokia
:author: Leo Wang, Lily Xu
:contact: leo.y.wang@nokia.com
:maintainer: Yonna Yao
:contact: yonna.yao@nokia-sbell.com
"""

import re
from ta_kiss_core.logger import Logger


class IphyThroughput(object):

    def __init__(self):
        self._log = Logger()

    def sum_l2_cell_throughput(self, egate_info, tput_type, scell):
        """
        :param egate_info:
        :param tput_type:
        :param scell:
        :return:
        """
        self.check_throughput_egate_error(egate_info)
        throughput_table = self.remove_egate_head_info(egate_info)
        head_list = self.get_head_list(throughput_table)
        all_type_tput_dic_list = self.analyse_throughput_to_dictionary_list(head_list, throughput_table)
        one_type_tput_dic_list = self.get_all_throughput_for_one_type(all_type_tput_dic_list, tput_type,
                                                                      key=head_list[0])
        target_scell_index = self.return_all_target_scell_index(scell)
        throughput_value = self.sum_troughput(target_scell_index, one_type_tput_dic_list)
        return throughput_value

    def check_throughput_egate_error(self, egate_info):
        """

        :param egate_info:
        :return:
        """
        if 'Stats are supported only for Active UE' in egate_info:
            raise Exception('Cannot get throughput data of UEs not in active mode')
        elif 'is not configured on eNB' in egate_info:
            raise Exception('Cannot get throughput data of cell not configured on eNB')
        elif 'No ' in egate_info or ' MAC data for' in egate_info:
            raise Exception('Egate was not able to find valid throughput output.')
        elif '======' not in egate_info:
            raise Exception("There is no throughput info in egate message.")

    def remove_egate_head_info(self, egate_info):
        """will return
        =====================================================
        S-Cell   Current    Minimum    Maximum    Average
        -----------------------------------------------------
        PCell    66.1 Mbps  66.0 Mbps  68.4 Mbps  66.4 Mbps
        SCell-2  64.9 Mbps  64.5 Mbps  67.2 Mbps  65.1 Mbps
        =====================================================
        """
        throughput_pattern = "===+.*?===+"
        throughput_table = re.search(throughput_pattern, egate_info, re.DOTALL).group(0)
        return throughput_table

    def get_head_list(self, throughput_table):
        """

        :param throughput_table:
        :return:
        """
        header = re.search("((\\w+([ -.]\\w+)*)\\s\\s+)+(\\w+([ -.]\\w+)*)", throughput_table).group()
        header_list = re.split("\\s\\s+", header)
        return header_list

    def analyse_throughput_to_dictionary_list(self, header_list, throughput_info):
        """[{'Current': '66.1 Mbps', 'Average': '66.4 Mbps', 'Minimum': '66.0 Mbps', 'Maximum': '68.4 Mbps',
        'S-Cell': 'PCell'},
        {'Current': '64.9 Mbps', 'Average': '65.1 Mbps', 'Minimum': '64.5 Mbps', 'Maximum': '67.2 Mbps',
        'S-Cell': 'SCell-2'}]
        """
        row_in_table_pattern = '((\\w+([ -.]\\w+)*)\\s\\s+){' + str(len(header_list) - 1) + '}(\\w+([ -.]\\w+)*)'
        rows_with_header = [g.group(0) for g in re.finditer(row_in_table_pattern, throughput_info)]
        rows_in_table = rows_with_header[1:] if len(rows_with_header) > 1 else []

        result_list = []
        for i in rows_in_table:
            row = re.split("\\s\\s+", i)
            result_list.append(dict(zip(header_list, row)))
        return result_list

    def get_all_throughput_for_one_type(self, throughput_dic_list, tput_type, key):
        """

        :param throughput_dic_list:
        :param tput_type:
        :param key:
        :return:
        """
        tput_dic = {}
        for tput in throughput_dic_list:
            tput_dic[tput[key]] = tput[tput_type.capitalize()]
        return tput_dic

    def return_all_target_scell_index(self, scell):
        """

        :param scell:
        :return:
        """
        scell_list = [str(x).strip() for x in scell.split(',')]
        tmp1 = ['0'] if 'pcell' in scell_list else []
        tmp2 = ['1', '2', '3', '4', '5', '6'] if 'scell' in scell_list else []
        tmp3 = ['0', '1', '2', '3', '4', '5', '6'] if 'all' in scell_list else []
        tmp4 = [i for i in scell_list if i.isdigit()]
        target_scell = list(set(tmp1 + tmp2 + tmp3 + tmp4))
        self._log.info("There {} scells will sun throughput.".format(target_scell))
        return target_scell

    def sum_troughput(self, target_scell, tput_dic):
        """

        :param target_scell:
        :param tput_dic:
        :return:
        """
        throughput = '0 bps'
        key_dic = {'0': 'PCell', '1': 'SCell-1', '2': 'SCell-2', '3': 'SCell-3',
                   '4': 'SCell-4', '5': 'SCell-5', '6': 'SCell-6'}
        for scell in target_scell:
            try:
                tput_next = tput_dic[key_dic[scell]]
                throughput = self._sum_tput(throughput, tput_next)
                self._log.info(throughput)
                tput_value = re.search("([0-9.]+)\\s*([a-zA-Z]+)?", throughput).group(1)
            except Exception:
                self._log.info("no {}".format(key_dic[scell]))
        return tput_value

    def _sum_tput(self, arg1, arg2):
        """

        :param arg1:
        :param arg2:
        :return:
        """
        tput_pattern = "([0-9.]+)\\s*([a-zA-Z]+)?"
        a_string = re.search(tput_pattern, arg1)
        a = float(a_string.group(1))
        a_unit = a_string.group(2)
        a_unit = "bps" if a_unit is None else a_unit
        a_bits = self._change_to_bits(a, a_unit)
        b_string = re.search(tput_pattern, arg2)
        b = float(b_string.group(1))
        b_unit = b_string.group(2)
        b_unit = "bps" if b_unit is None else b_unit
        b_bits = self._change_to_bits(b, b_unit)
        sum = a_bits + b_bits
        if a_unit.lower() == "mbps" or b_unit.lower() == "mbps":
            return "{} {}".format(str(float(sum) / (1024 * 1024)), "mbps")
        elif a_unit.lower() == "kbps" or b_unit.lower() == "kbps":
            return "{} {}".format(str(float(sum) / 1024), "kbps")
        else:
            return "{} {}".format(str(float(sum)), "bps")

    def _change_to_bits(self, throughput, unit):
        """

        :param throughput:
        :param unit:
        :return:
        """
        if unit.lower() == "bps":
            return throughput
        if unit.lower() == "kbps":
            return throughput * 1024
        if unit.lower() == "mbps":
            return throughput * 1024 * 1024
        else:
            raise Exception("Unknown throughput unit: {}".format(unit))
