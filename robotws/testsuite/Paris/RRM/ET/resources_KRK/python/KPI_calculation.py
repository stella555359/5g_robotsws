"""
:copyright: Nokia Networks
:author: Anna Bien
:maintainer: Anna Bien
:contact: anna.bien@nokia.com
"""

from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import (
    logger_info, logger_debug
)
from testsuite.Paris.RRM.ET.resources_KRK.python.KPI_validation import (
    get_latest_pm_file, get_sum_of_counter_list
)


class KpiCalculationFailure(Exception):
    pass


class KpiCalculation:

    def __init__(self, counter_file_path=None):
        self.counter_file_path = counter_file_path

    def set_counter_file_path(self, log_dir, wait_for_pm_interval_end=True):
        self.counter_file_path = get_latest_pm_file(
            log_dir=log_dir,
            wait_for_pm_interval_end=wait_for_pm_interval_end
        )

    def calculate_nr_70b_value(self):
        """
        The function for calculating KPI NR_70B value
        NR_70B: 5G Average PDCP SDU delay in DL: M55319C09001..20 / (M55319C01001..20 + M55319C11001..20)
        """

        logger_debug(f'Calculating NR_70B value according to {self.counter_file_path}')
        pdcp_sdu_delay_qos = get_sum_of_counter_list(
            first_counter='M55319C09001', last_counter='M55319C09020',
            counters_path='PLMN-PLMN/MRBTS-1/NRBTS-1', counter_file_path=self.counter_file_path
        )
        dl_sdu_tx_nsa_qos = get_sum_of_counter_list(
            first_counter='M55319C01001', last_counter='M55319C01020',
            counters_path='PLMN-PLMN/MRBTS-1/NRBTS-1', counter_file_path=self.counter_file_path
        )
        dl_sdu_tx_sa_qos = get_sum_of_counter_list(
            first_counter='M55319C11001', last_counter='M55319C11020',
            counters_path='PLMN-PLMN/MRBTS-1/NRBTS-1', counter_file_path=self.counter_file_path
        )
        try:
            nr_70b = pdcp_sdu_delay_qos / (dl_sdu_tx_nsa_qos + dl_sdu_tx_sa_qos)
        except ZeroDivisionError:
            raise KpiCalculationFailure('KPI NR_70B: DL SDU TX PM Counters values not found')
        logger_info(f'Calculated KPI NR_70B value: {nr_70b}')
        return nr_70b
