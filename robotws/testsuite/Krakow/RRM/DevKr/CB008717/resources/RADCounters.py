# Documentation
# ...      == COPYRIGHT ==
# ...      Nokia Networks
# ...      == AUTHORS C-PLANE ==
# ...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
# ...      == MAINTAINER ==
# ...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
import re

from robot.api.deco import keyword
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from ta5g_pm_counters import ta5g_pm_counters


class RADCounters(object):
    def __init__(self):
        super(RADCounters, self).__init__()
        self.current_rd_pm_file = ''

    @keyword("Wait for new PM Counter collecting period")
    def collect_rd_pm_counters(self):
        robot_logs_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
        try:
            pm_file_name = ta5g_pm_counters.get_next_unpacked_raw_rd_counters_file(robot_logs_dir)
        except RuntimeError:
            logger.info('SSHClientException occurred, retry!')
            pm_file_name = ta5g_pm_counters.get_next_unpacked_raw_rd_counters_file(robot_logs_dir)

        logger.info('New PM Counter file collected and stored in: {}'.format(pm_file_name))
        self.current_rd_pm_file = pm_file_name

    def get_cell_rd_counter_value_from_file(self, rd_counter_name, cell_id):
        list_rd_counters_value = self.get_rd_counter_value_list_for_all_cells(rd_counter_name)
        cell_index = int(cell_id) - 1
        cell_counter_value = list_rd_counters_value[cell_index]
        logger.info('gNB PM counter {} for NRCELL-{} value: {}'.format(rd_counter_name, cell_id, cell_counter_value))

        return int(cell_counter_value)

    def get_rd_counter_value_list_for_all_cells(self, rd_counter_name):
        with open(self.current_rd_pm_file, 'r') as pm_counters_file:
            pm_counters = pm_counters_file.read()

        regexp_for_counter = '<{}>(.*?)</{}>'.format(rd_counter_name, rd_counter_name)
        list_rd_counters_value = re.findall(regexp_for_counter, pm_counters)
        logger.info('List of counter values from file: {}'.format(list_rd_counters_value))

        assert len(list_rd_counters_value) > 0, 'PM Counter {} is not present in file!'.format(rd_counter_name)

        return list_rd_counters_value

    @keyword("Verify that ${rd_counter_name} is equal to ${expected_value} for NRCELL-${cell_id}")
    def check_rd_counters_from_pm_file(self, rd_counter_name, expected_value, cell_id):
        pm_counter_value = self.get_cell_rd_counter_value_from_file(rd_counter_name, cell_id)
        logger.info('gNB: PM counter name: {} value: {} for NRCELL-{}'.format(rd_counter_name,
                                                                              pm_counter_value,
                                                                              cell_id))

        assert pm_counter_value == int(expected_value), \
            '{} counter value {} from gNBb does not match provided value {}'.format(rd_counter_name,
                                                                                    pm_counter_value,
                                                                                    expected_value)

    @keyword("Verify that ${rd_counter_name} is in range (${min_value}, ${max_value}) for NRCELL-${cell_id}")
    def check_if_rd_counters_from_pm_file_is_in_range(self, rd_counter_name, min_value, max_value, cell_id):
        pm_counter_value = self.get_cell_rd_counter_value_from_file(rd_counter_name, cell_id)
        logger.info('gNB: PM counter name: {} value: {} for NRCELL-{}'.format(rd_counter_name,
                                                                              pm_counter_value,
                                                                              cell_id))

        assert int(min_value) <= pm_counter_value <= int(max_value), \
            '{} counter value {} from gNBb does not match provided range ({}, {})'.format(rd_counter_name,
                                                                                          pm_counter_value,
                                                                                          min_value,
                                                                                          max_value)

    @keyword("Verify that ${rd_counter_name} is equal to ${expected_value} for PMQAP-${pmqap_id} in NRCELL-${cell_id}")
    def check_if_counter_for_pmqap_is_eq_to_expected_value(self, rd_counter_name, expected_value, pmqap_id, cell_id):
        list_rd_counters_value = self.get_rd_counter_value_list_for_all_cells(rd_counter_name)

        cell_counter_value = self.get_counter_value_for_pmqap_and_nrcell(rd_counter_name, pmqap_id, cell_id,
                                                                         list_rd_counters_value)

        assert int(cell_counter_value) == int(expected_value), \
            '{} counter value {} from gNBb does not match provided value {} for PMQAP-{}'.format(rd_counter_name,
                                                                                                 cell_counter_value,
                                                                                                 expected_value,
                                                                                                 pmqap_id)

    def get_counter_value_for_pmqap_and_nrcell(self, rd_counter_name, pmqap_id, cell_id, list_rd_counters_value):
        logger.info('Verify PMQAP counters with assumption that 4 PMQAP profiles configured on gNB!')
        cell_index = int(cell_id) - 1
        pmqap_counter_index = cell_index * 4 + int(pmqap_id) - 1
        logger.info('List index for counter: {}'.format(pmqap_counter_index))
        cell_counter_value = list_rd_counters_value[pmqap_counter_index]
        logger.info('gNB PM counter {} for NRCELL-{} and PMQAP-{} value: {}'.format(rd_counter_name, cell_id, pmqap_id,
                                                                                    cell_counter_value))

        return int(cell_counter_value)

    @keyword("Verify that ${rd_counter_name} is in range (${min_value}, ${max_value}) for PMQAP-${pmqap_id} in "
             "NRCELL-${cell_id}")
    def check_if_counter_for_pmqap_is_in_expected_range(self, rd_counter_name, min_value, max_value, pmqap_id, cell_id):
        list_rd_counters_value = self.get_rd_counter_value_list_for_all_cells(rd_counter_name)

        cell_counter_value = self.get_counter_value_for_pmqap_and_nrcell(rd_counter_name, pmqap_id, cell_id,
                                                                         list_rd_counters_value)

        assert int(min_value) <= cell_counter_value <= int(max_value), \
            '{} counter value {} from gNBb does not match provided range ({}, {}) ' \
            'for PMQAP-{}'.format(rd_counter_name, cell_counter_value, min_value, max_value, pmqap_id)
