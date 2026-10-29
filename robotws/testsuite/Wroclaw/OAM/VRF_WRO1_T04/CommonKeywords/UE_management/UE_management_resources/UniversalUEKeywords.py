# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Krzysztof Kulibab
:contact: krzysztof.kulibab@nokia.com
"""

import re


def get_ue_ids_from_adb_output(output):
    serial_numbers = []
    # tmp = output.split("\r\r\n")
    tmp = output.split("\r\n")
    del tmp[0]
    del tmp[-1]
    for line in tmp:
        line = line.split("\t")[0]
        if line != "":
            serial_numbers.append(line)
    return serial_numbers


def get_summary(filename):
    """Parses iperf log."""
    log_file = open(filename, "r")
    lines = log_file.readlines()
    summary = ""
    for line in reversed(lines):
        if all(["datagrams received out-of-order" not in line,
                "WARNING: ack of last datagram failed" not in line,
                "Server listening on " not in line,
                "---" not in line]):
            summary = line
            break
    return summary


def askey_ip_conversion(ip):
    octets = ip.split(".")
    last_octet = int(octets[-1])-1
    ip = '{}.{}.{}.{}'.format(octets[0], octets[1], octets[2], last_octet)
    return ip


def get_line_with_askey_ip(filename):
    log_file = open(filename, "r")
    lines = log_file.readlines()
    line_to_return = ""
    for line in lines:
        if '10.42.197.170' in line:
            line_to_return = line
            break
    return line_to_return


def convert_tput(tput):
    bandwidth = re.findall(r'\d+', tput)
    if "M" in tput:
        unit = "Mbits/sec"
    elif "k" in tput:
        unit = "kbits/sec"
    elif "G" in tput:
        unit = "Gbits/sec"
    else:
        unit = "bits/sec"
    return bandwidth[0], unit
