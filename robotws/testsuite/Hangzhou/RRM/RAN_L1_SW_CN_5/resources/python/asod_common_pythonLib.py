# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tang Jiayi
:contact: jiayi.tang@nokia-sbell.com
:maintainer: jiayi.tang@nokia-sbell.com
:contact: jiayi.tang@nokia-sbell.com
"""

import re
import os
from ute_ue.exceptions import ProhibitedInstanceError, DataTransferVerificationFailure
from ute_ue.utils.param_checker import tput_user_value2normalized


def check_mac_unique(mac_str):
    """ Function for checking mac addr unique or not"""
    result = 0x2
    high_byte = mac_str.split(":")[0]
    high_byte_int = int(high_byte, 16)
    result &= high_byte_int
    if result == 0:
        return True
    else:
        return False


def Get_MRBTS_ID(scf_path):
    """ Function for getting MRBTSID from scf file"""
    with open(scf_path, 'r+') as f:
        xml = f.read()
        rule = r'.*MRBTS\" distName=\"(.*?)\" operation='
        MRBTSIDlist = re.findall(rule, xml)
        MRBTSID = ""
        MRBTSID = MRBTSID.join(MRBTSIDlist)
        return MRBTSID


def _parse_deviation(unparsed_deviation):
    """
    :param unparsed_deviation: acceptable deviation from desired data transfer throughput. e.g '5%'
    :return: deviation. e.g 0.05
    """
    number = unparsed_deviation.rstrip('%')
    deviation = float(number) / 100.0
    return deviation


def verify_average_throughput_with_deviation(average_tput, tput, deviation):
    """
    Verify if average throughput is in desired range: tput-(tput*deviation) <-> tput+(tput*deviation)
    :param average_tput: in bits/seconds unit
    :param tput: desired average data transfer throughput in string format. e.g. '6 Mbits/sec'
    :param deviation: acceptable deviation from desired data transfer throughput. e.g '5%'
    :return: None
    :raises DataTransferVerificationFailure: if verification fails
    Note: conversion rate is equal to 1000:
        1kByte = 1000 Byte; 1MByte = 1000 kByte; etc
    """
    average_throughput = float(average_tput) / 1024.0
    deviation_as_float = _parse_deviation(deviation)
    normalized_tput = tput_user_value2normalized(tput)
    min_threshold = normalized_tput - (normalized_tput * deviation_as_float)
    max_threshold = normalized_tput + (normalized_tput * deviation_as_float)
    if average_throughput < min_threshold or average_throughput > max_threshold:
        msg = ('\nBased on values provided: tput={normalized_tput} [kbits/s], deviation={dev}\n'
               'Expected tput range: min={min} [kbits/sec] <-> max={max} [kbits/sec]\n'
               'Actual average tput={actual} [kbits/sec]').format(normalized_tput=normalized_tput, dev=deviation,
                                                                  min=min_threshold, max=max_threshold,
                                                                  actual=average_throughput)
        raise DataTransferVerificationFailure(msg)


def get_valid_pm_counter_value(pm_dict):
    """
    :param: pm_dict, the result of counters get from BTS
    :return: if not zero, return pm counter value; if zero, return 0
    """
    for key, value in pm_dict.items():
        if int(value) != 0:
            return value
