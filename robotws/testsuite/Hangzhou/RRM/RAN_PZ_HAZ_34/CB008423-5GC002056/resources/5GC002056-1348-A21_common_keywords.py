# -*- coding: utf-8 -*
import re
import os
import linecache
from robot.libraries.BuiltIn import BuiltIn
import xml.dom.minidom
import logging
import csv


def check_prach_result(Prach_result_list):
    print('check_prach_result')
    Prach_multiplexing_sfn = []
    Prach_pucch_result_dict = Prach_result_list[0]
    Prach_pusch_result_dict = Prach_result_list[1]
    pucch_sfn_list = Prach_pucch_result_dict['sfn']
    pucchFormat_list = Prach_pucch_result_dict['pucchFormat']
    numOfPrb_list = Prach_pusch_result_dict['numOfPrb']
    pusch_sfn_list = Prach_pusch_result_dict['sfn']
    for i in range(len(pucch_sfn_list)):
        j = pucch_sfn_list[i]
        for m in range(len(pusch_sfn_list)):
            if pusch_sfn_list[m] == j:
                break
        if (int(pucchFormat_list[i]) == 0) and int(numOfPrb_list[m]):
            print('i:', i)
            print('pucchFormat:', pucchFormat_list[i])
            print('numOfPrb:', numOfPrb_list[m])
            Prach_multiplexing_sfn.append(pucchFormat_list[i])
            print('Prach_multiplexing_sfn:', Prach_multiplexing_sfn)
    return Prach_multiplexing_sfn


def check_noPrach_result(NoPrach_result_list):
    print('check_noPrach_result')
    NoPrach_multiplexing_sfn = []
    Prach_pucch_result_dict = NoPrach_result_list[0]
    Prach_pusch_result_dict = NoPrach_result_list[1]
    pucch_sfn_list = Prach_pucch_result_dict['sfn']
    pucchFormat_list = Prach_pucch_result_dict['pucchFormat']
    numOfPrb_list = Prach_pusch_result_dict['numOfPrb']
    pusch_sfn_list = Prach_pusch_result_dict['sfn']
    for i in range(len(pucch_sfn_list)):
        j = pucch_sfn_list[i]
        for m in range(len(pusch_sfn_list)):
            if pusch_sfn_list[m] == j:
                break
        if (int(pucchFormat_list[i]) == 0) and int(numOfPrb_list[m]):
            print('i:', i)
            print('pucchFormat:', pucchFormat_list[i])
            print('numOfPrb:', numOfPrb_list[m])
            NoPrach_multiplexing_sfn.append(pucchFormat_list[i])
            print('NoPrach_multiplexing_sfn:', NoPrach_multiplexing_sfn)
    return NoPrach_multiplexing_sfn


def Check_multiplexing_result(Prach_result_list, NoPrach_result_list):
    print('Check_multiplexing_result')
    Prach_multiplexing_sfn = check_prach_result(Prach_result_list)
    NoPrach_multiplexing_sfn = check_noPrach_result(NoPrach_result_list)
    if Prach_multiplexing_sfn:
        is_Prach_multiplexing = 1
    else:
        is_Prach_multiplexing = 0
    if NoPrach_multiplexing_sfn:
        is_NoPrach_multiplexing = 1
    else:
        is_NoPrach_multiplexing = 0
    return is_Prach_multiplexing, is_NoPrach_multiplexing
