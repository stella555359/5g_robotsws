# import os
import time
import re
from taf.transport.ssh import ssh
from robot.api import logger

# from robot.libraries.BuiltIn import BuiltIn
# tl = BuiltIn().get_variable_value('${tl}')

# MR_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id)
# MR_NR_NAME = MR_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
# MR_NR_CELL_NAME = MR_NR_NAME + '/NRCELL-1'
# MR_NR_CELLGRP_NAME = MR_NR_NAME + '/NRCELLGRP-0'


powerSavingBwpSwitching = [
    {
        "parameterName": "powerSavingBwpSwitching",
        "operation": "update",
        "value": [
            {
                "dlBufferEmptyRatioFromPsBwp": 40,
                "dlBufferEmptyRatioToPsBwp": 90,
                "dlRateThresholdFromPsBwp": 1000,
                "dlRateThresholdToPsBwp": 500,
                "measurementDurationFromPsBwp": 40,
                "measurementDurationToPsBwp": 160,
                "ulBufferEmptyRatioFromPsBwp": 40,
                "ulBufferEmptyRatioToPsBwp": 90,
                "ulRateThresholdNoVoNRFromPsBwp": 100,
                "ulRateThresholdNoVoNRToPsBwp": 95,
                "ulRateThresholdVoNRFromPsBwp": 100,
                "ulRateThresholdVoNRToPsBwp": 60
            }
        ]
    }
]


powerSavingBwpSwitching_for_buffer = [
    {
        "parameterName": "powerSavingBwpSwitching",
        "operation": "update",
        "value": [
            {
                "dlBufferEmptyRatioFromPsBwp": 96,
                "dlBufferEmptyRatioToPsBwp": 98,
                "dlRateThresholdFromPsBwp": 1000,
                "dlRateThresholdToPsBwp": 500,
                "measurementDurationFromPsBwp": 40,
                "measurementDurationToPsBwp": 160,
                "ulBufferEmptyRatioFromPsBwp": 96,
                "ulBufferEmptyRatioToPsBwp": 98,
                "ulRateThresholdNoVoNRFromPsBwp": 100,
                "ulRateThresholdNoVoNRToPsBwp": 95,
                "ulRateThresholdVoNRFromPsBwp": 100,
                "ulRateThresholdVoNRToPsBwp": 60
            }
        ]
    }
]

powerSavingBwpSwitching_for_case7_1 = [
    {
        "parameterName": "powerSavingBwpSwitching",
        "operation": "update",
        "value": [
            {
                "dlBufferEmptyRatioFromPsBwp": 40,
                "dlBufferEmptyRatioToPsBwp": 90,
                "dlRateThresholdFromPsBwp": 1000,
                "dlRateThresholdToPsBwp": 500,
                "measurementDurationFromPsBwp": 80,
                "measurementDurationToPsBwp": 320,
                "ulBufferEmptyRatioFromPsBwp": 40,
                "ulBufferEmptyRatioToPsBwp": 90,
                "ulRateThresholdNoVoNRFromPsBwp": 100,
                "ulRateThresholdNoVoNRToPsBwp": 95,
                "ulRateThresholdVoNRFromPsBwp": 100,
                "ulRateThresholdVoNRToPsBwp": 60
            }
        ]
    }
]

powerSavingBwpSwitching_for_case7_2 = [
    {
        "parameterName": "powerSavingBwpSwitching",
        "operation": "update",
        "value": [
            {
                "dlBufferEmptyRatioFromPsBwp": 40,
                "dlBufferEmptyRatioToPsBwp": 90,
                "dlRateThresholdFromPsBwp": 1000,
                "dlRateThresholdToPsBwp": 500,
                "measurementDurationFromPsBwp": 160,
                "measurementDurationToPsBwp": 640,
                "ulBufferEmptyRatioFromPsBwp": 40,
                "ulBufferEmptyRatioToPsBwp": 90,
                "ulRateThresholdNoVoNRFromPsBwp": 100,
                "ulRateThresholdNoVoNRToPsBwp": 95,
                "ulRateThresholdVoNRFromPsBwp": 100,
                "ulRateThresholdVoNRToPsBwp": 60
            }
        ]
    }
]


ssh = ssh()


def check_from_btslog(alias, sample=1, start_offset=0, log_path='/tmp/bwp_type.txt'):
    connection = ssh.get_connection_by_alias(alias)
    filter = 'switched to bwpType'
    parser = _bwp_message_parser
    output = _get_syslog_output(
        ssh=connection, filter=filter, log_path=log_path)
    logger.info("the bwp message print is {}".format(output))
    bwp_type = _find_specific_type_num(output, parser, sample, start_offset, 0)
    logger.info("Bwp Type is {}".format(bwp_type))
    return bwp_type


def _get_syslog_output(ssh, filter, log_path):
    time.sleep(10)
    output = ssh.execute(
        command=r'cat {}| grep -a "{}"'.format(log_path, filter), timeout=10).split('\r\n')
    return output


def _find_specific_type_num(type_list, bwp_element_parser, sample, start_offset, location):
    logger.debug("index {} received".format(len(type_list)))
    for index in range(len(type_list)-1):
        element = type_list[index]
        logger.debug("type_list {} received".format(element))
        bwp_type = bwp_element_parser(element, location)
        logger.info("Bwp type {} received".format(bwp_type))
    return bwp_type


def _bwp_message_parser(element, location):
    data = re.findall(r"switched to bwpType(.+)", element)
    return data[location].split('=')[1].split(';')[0]
