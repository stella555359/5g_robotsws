"""
Common resources for MaxTput PM counters gathering and verification

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

import json
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.pm_counters import wait_for_next_pm_interval_and_get_counters
from robot.api import logger


class MaxTputCounters:
    def __init__(self):
        # WRO4
        self.dl_pdcp_sdu_counters = [f'M55319C110{i:02}' for i in range(1, 21)]
        self.dl_pdcp_sdu_vol_counters = [f'M55319C120{i:02}' for i in range(1, 21)]
        self.ul_pdcp_sdu_counters = [f'M55319C150{i:02}' for i in range(1, 21)]
        self.ul_pdcp_sdu_vol_counters = [f'M55319C160{i:02}' for i in range(1, 21)]

        # WRO5
        self.ethernet_link_counters = ['M51301C0', 'M51301C1', 'M51301C5']

        # WRO6
        self.dl_sdu_tx_nsa_qos_grp = [f'M55319C010{i:02}' for i in range(1, 21)]
        self.dl_vol_tx_nsa_qos_grp = [f'M55319C020{i:02}' for i in range(1, 21)]

        # WRO7
        self.second_level_scheduler_counters = ['M51352C1', 'M51352C9']

        # WRO8
        self.discarded_tx_frames_counters = ['M51363C7']

        self.default_counters = self.dl_pdcp_sdu_counters + self.dl_pdcp_sdu_vol_counters + self.ul_pdcp_sdu_counters \
            + self.ul_pdcp_sdu_vol_counters + self.ethernet_link_counters + self.dl_sdu_tx_nsa_qos_grp \
            + self.dl_vol_tx_nsa_qos_grp + self.second_level_scheduler_counters + self.discarded_tx_frames_counters
        self.reference_point = {}
        self.collected_counters = {}
        self.verbose = False

    def wait_for_next_pm_interval_before_test(self, counters_list=None, admin_connection=None):
        if counters_list is None:
            counters_list = self.default_counters
        self.reference_point = wait_for_next_pm_interval_and_get_counters(counter_ids=counters_list,
                                                                          admin_connection=admin_connection)
        logger.info("Counters gathered before test as reference point:", also_console=self.verbose)
        logger.info(json.dumps(self.reference_point, indent=4), also_console=self.verbose)

    def collect_counters_after_test(self, counters_list=None, admin_connection=None):
        if counters_list is None:
            counters_list = self.default_counters
        self.collected_counters = wait_for_next_pm_interval_and_get_counters(counter_ids=counters_list,
                                                                             admin_connection=admin_connection,
                                                                             reference_point=self.reference_point)
        logger.info("Counters collected after the test:", also_console=self.verbose)
        logger.info(json.dumps(self.collected_counters, indent=4), also_console=self.verbose)

    def verify_pdcp_tput_counter(self, sdu_counter_id, vol_counter_id, tput_duration, expected_min_tput):
        sdu_counter = self._filter_counters(patterns=[sdu_counter_id])
        vol_counter = self._filter_counters(patterns=[vol_counter_id])
        assert sdu_counter, f"No counters containing patterns {sdu_counter_id} were collected"
        assert vol_counter, f"No counters containing patterns {vol_counter_id} were collected"
        assert len(sdu_counter) == 1, f"More than one counter containing patterns {sdu_counter_id} were collected: " \
                                      f"{sdu_counter}"
        assert len(vol_counter) == 1, f"More than one counter containing patterns {vol_counter_id} were collected: " \
                                      f"{vol_counter}"
        sdu_counter_value = sum([x[1] for x in next(iter(sdu_counter.values()))])
        vol_counter_value = sum([x[1] for x in next(iter(vol_counter.values()))])
        try:
            packet_size = self._get_packet_size(sdu_counter_value, vol_counter_value)
            pdcp_sdu_tput = self._get_pdcp_tput_from_sdu_counters(sdu_counter_value, tput_duration=tput_duration,
                                                                  packet_size=packet_size)
        except ZeroDivisionError:
            logger.error(f"ZeroDivisionError: Sum of relevant PDCP Volume counters ({vol_counter_id}) = 0")
            pdcp_sdu_tput = 0
        pdcp_vol_tput = self._get_pdcp_tput_from_vol_counters(vol_counter_value, tput_duration=tput_duration)
        logger.info(f"PDCP Tput calculated from counters {sdu_counter_id} and {vol_counter_id}:",
                    also_console=self.verbose)
        logger.info(f"SDU: {pdcp_sdu_tput}, VOL: {pdcp_vol_tput}", also_console=self.verbose)
        assert pdcp_sdu_tput > float(expected_min_tput), f"Tput calculated from counters {sdu_counter_id} and " \
                                                         f"{vol_counter_id} is too low. Got {pdcp_sdu_tput}, " \
                                                         f"expected minimum {expected_min_tput}"
        assert pdcp_vol_tput > float(expected_min_tput), f"Tput calculated from counters {sdu_counter_id} and " \
                                                         f"{vol_counter_id} is too low. Got {pdcp_vol_tput}, " \
                                                         f"expected minimum {expected_min_tput}"
        return pdcp_sdu_tput, pdcp_vol_tput

    def verify_M51301C1_counter(self, tnl=1, ethlk=1, tput_duration=300, expected_tput=1100000000, max_error=0.05):
        patterns = (f'TNL-{tnl}', f'ETHLK-{ethlk}', 'M51301C1')
        counters = self._filter_counters(patterns=patterns)
        assert counters, f"No counters containing patterns {patterns} were collected"
        dn, values = next(iter(counters.items()))
        counters_sum_in_bits = sum([x[1] for x in values]) * 8
        expected_counter_value_in_bits = expected_tput * 1000 * 1000 * tput_duration
        try:
            ratio = abs(counters_sum_in_bits - expected_counter_value_in_bits) / counters_sum_in_bits
        except ZeroDivisionError:
            logger.error("ZeroDivisionError: Sum of relevant M51301C1 counters = 0")
            raise AssertionError("Sum of relevant M51301C1 counters = 0, possibly no tput received.")
        assert ratio <= float(max_error), f"Difference between relevant counter {dn} values ({counters_sum_in_bits})" \
                                          f" and expected tput ({expected_counter_value_in_bits}) exceeds maximum" \
                                          f" error of {max_error * 100}%"

    def verify_M51301C5_counter(self, tnl=1, ethlk=1, max_threshold=0):
        patterns = (f'TNL-{tnl}', f'ETHLK-{ethlk}', 'M51301C5')
        counters = self._filter_counters(patterns=patterns)
        assert counters, f"No counters containing patterns {patterns} were collected"
        for k, v in counters.items():
            counters_sum = sum([x[1] for x in v])
            assert counters_sum <= float(max_threshold), f"Sum of all relevant counter {k} values ({counters_sum})" \
                                                         f" is higher than {max_threshold}"

    def verify_M51363C7_counter(self, max_threshold=0):
        counters = self._filter_counters(patterns='M51363C7')
        assert counters, "No counters containing pattern M51363C7 were collected"
        for k, v in counters.items():
            counters_sum = sum([x[1] for x in v])
            assert counters_sum <= float(max_threshold), f"Sum of all relevant counter {k} values ({counters_sum})" \
                                                         f" is higher than {max_threshold}"

    def verify_M51352C1_counter(self, tnl=1, ethif=1, max_threshold=500):
        patterns = (f'TNL-{tnl}', f'ETHIF-{ethif}', 'M51352C1')
        counters = self._filter_counters(patterns=patterns)
        assert counters, f"No counters containing patterns {patterns} were collected"
        for k, v in counters.items():
            counters_sum = sum([x[1] for x in v])
            assert counters_sum <= float(max_threshold), f"Sum of all relevant counter {k} values ({counters_sum})" \
                                                         f" is higher than {max_threshold}"

    def verify_M51352C9_counter(self, tnl=1, ethif=1, max_threshold=0):
        patterns = (f'TNL-{tnl}', f'ETHIF-{ethif}', 'M51352C9')
        counters = self._filter_counters(patterns=patterns)
        assert counters, f"No counters containing patterns {patterns} were collected"
        for k, v in counters.items():
            assert sum([x[1] for x in v]) <= float(max_threshold), f"Sum of all relevant counter {k} values is " \
                                                                   f"higher than {max_threshold}"

    def assert_counters_have_been_collected(self):
        assert self.collected_counters, "No counters collected. Did you run 'collect_counters_after_test' keyword?"

    def _filter_counters(self, patterns):
        if isinstance(patterns, str):
            patterns = [patterns]
        return {k: v for k, v in self.collected_counters.items() if all([pattern in k for pattern in patterns])}

    @staticmethod
    def _get_pdcp_tput_from_sdu_counters(pdcp_sdu_counter_value, tput_duration, packet_size):
        return round((pdcp_sdu_counter_value * packet_size / int(tput_duration)) * 8 / 1000 / 1000, 1)

    @staticmethod
    def _get_pdcp_tput_from_vol_counters(pdcp_vol_counter_value, tput_duration):
        return round((pdcp_vol_counter_value / int(tput_duration)) * 8 / 1000, 1)

    @staticmethod
    def _get_packet_size(pdcp_sdu_counter_value, pdcp_vol_counter_value):
        return 1000 * (float(pdcp_vol_counter_value) / float(pdcp_sdu_counter_value))

    def set_verbose(self):
        self.verbose = True
