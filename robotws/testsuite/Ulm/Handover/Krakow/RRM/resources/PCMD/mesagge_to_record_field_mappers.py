"""
:copyright: Nokia Networks
:author: Dawid Krawczuk <dawid.krawczuk@nokia.com>
:maintainer: Dawid Krawczuk <dawid.krawczuk@nokia.com>
"""
import re
from robot.api import logger as r_logger


def remove_hex_sign(value):
    print(type(value))
    return re.sub('0x', '', "{}".format(value)).lower()


def remove_dash_sign(value):
    print(type(value))
    return re.sub('-', '', "{}".format(value))


def convert_binary_to_decimal(value):
    print(type(value))
    return int(value, 2)


def premeption_capability(value):
    mapping = {'shall-not-trigger-pre-emption': 'shallNotTriggerPreemption',
               'shall-not-trigger-preemptdatDion': 'shallNotTriggerPreemption',
               'shall-not-trigger-preemption': 'shallNotTriggerPreemption',
               'may-trigger-pre-emption': 'mayTriggerPreemption'}
    if value not in mapping:
        r_logger.console(
            "\nVALUE_MAPPER: CAPABLITY value: {} could not be mapped".format(value))
        return value
    return mapping[value]


def premeption_vulnerability(value):
    mapping = {'not-pre-emptable': 'notPreemptable',
               'not-preemptable': 'notPreemptable',
               'pre-emptable': 'preemptable',
               'preemptable': 'preemptable'}
    if value not in mapping:
        r_logger.console(
            "\nVALUE_MAPPER: VULNERABILITY value: {} could not be mapped".format(value))
        return value
    return mapping[value]
