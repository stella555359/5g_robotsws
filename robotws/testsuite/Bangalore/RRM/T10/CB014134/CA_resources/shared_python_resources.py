# -*- coding: utf-8 -*-
"""
:author: Sebastian Dziewiecki
:contact: sebastian.dziewiecki@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
import subprocess
import shlex


def split_up_value(value, base=100):
    """ Create list with int values.
    There should be as many values as times 'base' divide 'value' (one extra if 'base' divide 'value' with reminder).
    Each value should be equal to 'base' (if 'base' doesn't divide absolutely last value should be equal to reminder):
     - value = 50, base = 10 there should be 5 values equal to [10, 10, 10, 10, 10],
     - value = 51, base = 10 there should be 6 values equal to [10, 10, 10, 10, 10, 1],
     - value = 5,  base = 10 there should be 1  value equal to [5]

    :param value: Value to split
    :type value: int
    :param base: Base value used to divide the user value
    :type base: int
    :return: List with split up value
    :rtype list
    """
    quotient, remainder = divmod(int(value), base)
    summands = quotient * [base]
    if remainder:
        summands.append(remainder)
    return summands


def start_iperf_throughput(ue_ip, bitrate):
    """ Starts UDP throughput to target UE
    :param str ue_ip: IP address of UE
    :param int bitrate: bitrate in MBps
    """
    start_iperf_cmd = 'iperf -c {} --udp -P 1 -i 1 -p 44001 -l 32k -b {}M -t 10000'.format(ue_ip, bitrate)
    subprocess.Popen(shlex.split(start_iperf_cmd), stdout=subprocess.PIPE, stdin=subprocess.PIPE)


def stop_iperf_throughput(ue_ip):
    """ Stops throughput to target UE
    :param str ue_ip: IP address of UE
    """
    stop_iperf_cmd = 'pkill -f "iperf -c {}"'.format(ue_ip)
    subprocess.Popen(shlex.split(stop_iperf_cmd), stdout=subprocess.PIPE, stdin=subprocess.PIPE)
