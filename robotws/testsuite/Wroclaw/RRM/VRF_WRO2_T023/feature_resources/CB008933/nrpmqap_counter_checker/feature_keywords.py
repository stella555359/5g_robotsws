"""
:copyright: Nokia Networks
:author: 'Mikolaj Kasian'
:maintainer: 'Mikolaj Kasian'
:contact: 'mikolaj.kasian@nokia.com'
:version: 0.1

This file contains function verify_counters_list_increased
that is external interface for all counters checking logic.
"""

from reporting import Reporter
from counters_checker import CountersChecker
from data_keeper import DataKeeper
from pm_xml_parser import NRPMQAPCountersXMLParser

MAX_NRPMQAP_NUMBER = 64


def verify_counters_list_increased(*args, pm_counter_file=None, cell_id=3):
    """
    This function compares counters values in NRPMQAP profiles with expectations, and returns bool result.
    :param args:              List of NRPMQAP counters with they expectations
    :param pm_counter_file:   path to file with collected counters
    :param cell_id:           Cell id to check counters
    :return:                  bool value of evaluation

    Example:
    ${result}=    verify counters list increased

        ...    M55352C00001        3-22,42-60,64       >0            DL_PDCP_TIME_UE_TPUT_PMQAP
        ...    M55352C01001        3-22,42-60,64       >0            DL_PDCP_VOL_UE_TPUT_PMQAP
        ...    M55353C00001        3-22,42-60,64       >0            UL_RLC_VOL_UE_TPUT_PMQAP
        ...    M55353C01001        3-22,42-60,64       >0            UL_RLC_TIME_UE_TPUT_PMQAP
        ...    M55193C00001        1-64                >0            NG_FLOW_REL_NORMAL_PMQAP
        ...    pm_counter_file=${pm_counter_file}
        ...    cell_id=${cell_id}
    """
    m = NRPMQAPVerifier(
        DataKeeper(args, values_number=4),
        NRPMQAPCountersXMLParser(nrpmqap_number=MAX_NRPMQAP_NUMBER,
                                 xml_path=pm_counter_file),
        CountersChecker(nrpmqap_number=MAX_NRPMQAP_NUMBER),
        Reporter(nrpmqap_number=MAX_NRPMQAP_NUMBER)
    )
    m.get_actual_values(cell_id)
    result = m.verify_counters_expectations()
    m.show_report()
    return result


class NRPMQAPVerifier:

    def __init__(self, data_keeper, counters_parser, counters_checker, reporter):
        self._data_keeper = data_keeper
        self._counters_parser = counters_parser
        self._counters_checker = counters_checker
        self._reporter = reporter

    @property
    def counters(self):
        return self._data_keeper.counters

    def get_actual_values(self, cell_id):
        self._counters_parser.get_counters_values(cell_id, self._data_keeper)

    def verify_counters_expectations(self):
        return self._counters_checker.check_values(self._data_keeper.counters)

    def show_report(self):
        self._reporter.table_counter_logger(self._data_keeper.counters)
