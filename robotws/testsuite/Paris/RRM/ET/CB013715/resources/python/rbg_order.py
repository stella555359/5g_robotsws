# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
"""
import sys
import heapq
from robot.api import logger


class rbg_order(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        pass

    def calc_rbg_order(self, bwp_width, rat, slot_num, sfn, slot, pci):
        """
        calc rbg order
        default value for tdd 100M
        :param bwp_width 273
        :param rat 'TDD'
        :param slot_num 20
        :param sfn
        :param slot
        :param pci  cell pci
        :return List
        """
        if 0 < bwp_width <= 36:
            prb_num = 2
        elif 36 < bwp_width <= 72:
            prb_num = 4
        elif 72 < bwp_width <= 144:
            prb_num = 8
        elif 144 < bwp_width <= 275:
            prb_num = 16
        else:
            sys.exit('bwp_width input error')

        primeNumber = 991 if ((bwp_width == 25) and (rat == 'FDD')) or ((bwp_width == 51) and (rat == 'TDD')) else 997

        rbg_order_list = []
        rbg_num = bwp_width // prb_num
        for rbg_id in range(0, rbg_num):
            order_id = 1 + (sfn*slot_num + slot + 1 + pci + rbg_id) * primeNumber % rbg_num
            rbg_order_list.append(order_id)
        if bwp_width % prb_num != 0:
            rbg_order_list.append(rbg_num+1)

        return rbg_order_list

    def calc_startprb(self, rbg_order_list, rbg_num_used):
        rgb_used = heapq.nsmallest(rbg_num_used, range(len(rbg_order_list)), rbg_order_list.__getitem__)

        return min(rgb_used)

    def rbg_order_check(self, rbg_order_list, rat0bitmap, ordered=True):
        bitmap_str = bin(rat0bitmap).replace("0b", "")
        rbg_len = len(rbg_order_list)
        bitmap_str = (rbg_len - len(bitmap_str)) * "0" + bitmap_str
        # len(bitmap_str)
        bitmap_list = list(bitmap_str)
        res = []
        for index in range(len(rbg_order_list)):
            if int(bitmap_list[index]) == 1:
                res.append(rbg_order_list[index] * int(bitmap_list[index]))
        if ordered:
            res.sort()
        return res

    def is_last_rbg_used(self, rat0bitmap, NbrRbg=18):
        """
        is last/partial rbg used for TDD
        :param rat0bitmap int
        :NbrRbg Number Of RBG
        :return True/False
        """
        # bitmap_str = bin(rat0bitmap).replace("0b", "")
        bitmap_str = "{:032b}".format(rat0bitmap)
        # list("{:032b}".format(267403264))[:18]
        # len(bitmap_str)
        bitmap_list = list(bitmap_str)[:NbrRbg]
        if int(bitmap_list[-1]) == 1:
            return True
        return False

    def is_contiguous_rbg_used(self, rat0bitmap):
        """
        is_contiguous_rbg_used (bin 1 is used)
        :param rat0bitmap int
        :return True/False
        example1: 2 ->  0010 True
        example2: 15 -> 1111 True
        example3: 2032 -> 111 1111 0000 True
        example4: 1728 -> 110 1100 0000 False
        """
        bitmap_str = bin(rat0bitmap).replace("0b", "")
        bitmap_list = list(bitmap_str)
        contiguous_rbg_count = 0
        used_rbg_count = bitmap_str.count("1")
        for index in range(len(bitmap_list)):
            if int(bitmap_list[index]) == 0:
                break
            contiguous_rbg_count = contiguous_rbg_count + 1
        if contiguous_rbg_count == used_rbg_count:
            return True
        else:
            return False
