"""
:copyright: Nokia Networks
:author: Maryna Lukachyk, Damian Żak, Szymon Lange
:maintainer: Maryna Lukachyk, Damian Żak
:contact: maryna.lukachyk@nokia.com, damian.zak@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import os
import sys
from types import ModuleType

from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed

from variables import *
from testsuite.Paris.RRM.ET.resources_KRK.python.swconfig import GnbSwconfigManager
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console
from testsuite.Paris.RRM.ET.resources_KRK.python.pm_counters import verify_any_counters


def validate_micro_dtx_optim_condition(cell_to_check=1, micro_dtx_optim_condition='>0'):
    logger_console(f'Micro DTX optimized counter validation on NRCELL-{cell_to_check} with condition: '
                   f'{micro_dtx_optim_condition}')
    verify_any_counters('M55308C33000', micro_dtx_optim_condition, f'NRCELL-{cell_to_check}')


def validate_micro_dtx_counters(cell_to_check=1, micro_dtx_optim_condition='>0', micro_dtx_no_bund_condition='>0'):
    logger_console(f'Micro DTX optimized counter validation on NRCELL-{cell_to_check} with condition: '
                   f'{micro_dtx_optim_condition}')
    logger_console(f'Micro DTX no bundling counter validation on NRCELL-{cell_to_check} with condition: '
                   f'{micro_dtx_no_bund_condition}')
    verify_any_counters('M55308C33000', micro_dtx_optim_condition, f'NRCELL-{cell_to_check}',
                        'M55308C33001', micro_dtx_no_bund_condition, f'NRCELL-{cell_to_check}')


def validate_sa_non_gbr_counters(number_of_bearer_requests=2, cell_to_check=1):
    logger_console('SA non-GBR counters validation')
    verify_any_counters('M55145C00220', f'== {number_of_bearer_requests}', f'NRCELL-{cell_to_check}',
                        'M55149C00020', f'== {number_of_bearer_requests}', 'NRBTS-1',
                        'M55138C00003', f'== {number_of_bearer_requests}', f'NRCELL-{cell_to_check}',
                        'M55138C00005', f'== {number_of_bearer_requests}', f'NRCELL-{cell_to_check}')


def validate_sa_non_gbr_counters_slice_scheduler(cell_to_check=3):
    logger_console('SA non-GBR counters validation')
    verify_any_counters('M55145C00220', '== 4', f'NRCELL-{cell_to_check}',
                        'M55149C00020', '== 2', 'MCC-311/MNC-489/SST-1/SD-13714341',
                        'M55149C00020', '== 2', 'MCC-311/MNC-489/SST-1/SD-2',
                        'M55138C00003', '== 4', f'NRCELL-{cell_to_check}',
                        'M55138C00005', '== 4', f'NRCELL-{cell_to_check}')


def validate_nsa_non_gbr_counters(number_of_bearer_requests=2, cell_to_check=1):
    logger_console('NSA non-GBR counters validation')
    verify_any_counters('M55114C00004', f'== {number_of_bearer_requests}', f'NRCELL-{cell_to_check}',
                        'M55145C00006', f'== {number_of_bearer_requests}', f'NRCELL-{cell_to_check}',
                        'M55114C00003', f'== {number_of_bearer_requests}', f'NRCELL-{cell_to_check}')


def validate_harq_counter(cell_to_check=1):
    logger_console('Retransmissions counter validation')
    verify_any_counters('M55302C15003', f'== 0', f'NRCELL-{cell_to_check}')


def validate_drx_sleep_active_time():
    logger_console('DRX sleep/active time counters validation')
    verify_any_counters('M55308C11001', '> 0', 'NRCELL-3',
                        'M55308C11002', '> 0', 'NRCELL-3',
                        'M55308C27001', '> 0', 'NRCELL-3')


def validate_syslog(syslog_prints):
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    logger_console('Start syslog validation')
    with open('{}/{}/{}/syslog.log'.format(OUTPUT_DIR, SUITE_NAME, test_name), 'r') as syslog_file:
        read_data = syslog_file.read()
    for syslog_print in syslog_prints:
        if syslog_print not in read_data:
            raise ExecutionFailed(f'Syslog validation failed! Syslog print: {syslog_print} not found')
        else:
            logger_console(f'Syslog print: {syslog_print} validated successfully')


def get_testline_name():
    for module in sys.modules.copy().values():
        if type(module) is ModuleType:
            if "tl" in dir(module):
                return os.path.basename(os.path.dirname(module.__file__))
    raise Exception('No Testline Module Loaded!')


def check_if_cm_execution():
    # returns False if the test was launched by the CloudManager, otherwise returns True.
    return False if os.environ.get("CM_EXECUTION_ID") is None else True
