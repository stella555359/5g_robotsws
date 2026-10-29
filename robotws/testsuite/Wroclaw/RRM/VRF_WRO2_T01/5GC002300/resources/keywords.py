import logging
from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.webem_operations import get_counter_values
from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.counter_helpers import get_last_counters_values


class EirpTestVeryfication:

    def __init__(self, bts_id, cell_id):
        self.bts_id = bts_id
        self.cell_id = cell_id
        self.LAST_COUNTER_I = 63
        self.COUNTER_BASE = "M55324C004"
        self.last_values = {}
        # preconfigured on BTS -> beam set 6 means that only counters 00-05 (6 beams id) are relevant
        self.test_beamset = 6
        self.CELL_POWER_COUNTER_NAME = "M55324C00464"
        self.last_cell_power_counter_val = 0
        self.MAX_SLIDING_EIRP_COUNTER = "M55324C00501"
        self.MIN_SLIDING_EIRP_COUNTER = "M55324C00601"
        self.NO_TPUT_MAX_SLIDING_VALUE = 49000  # system insight hint
        self.NO_TPUT_MIN_SLIDING_BALUE = 24547  # system insight hint

    def _build_counters_string(self, offset=1):
        counters_s = ""
        for i in range(0, self.LAST_COUNTER_I + 1):
            counters_s += f"{self.COUNTER_BASE}{i:02d},"
        return counters_s

    def _get_counter_val(self, webem_response):
        return webem_response['BTS'][f'MRBTS-{self.bts_id}'][f'NRBTS-{self.bts_id}'][f'NRCELL-{self.cell_id}']['NREIRP']

    def _get_last_power_counter_value(self):
        res = get_counter_values(self.CELL_POWER_COUNTER_NAME)
        counter_val = self._get_counter_val(res)
        return get_last_counters_values(counter_val)[self.CELL_POWER_COUNTER_NAME]

    def _get_last_max_sliding_counter_value(self):
        res = get_counter_values(self.MAX_SLIDING_EIRP_COUNTER)
        counter_val = self._get_counter_val(res)
        return get_last_counters_values(counter_val)[self.MAX_SLIDING_EIRP_COUNTER]

    def _get_last_min_sliding_counter_value(self):
        res = get_counter_values(self.MIN_SLIDING_EIRP_COUNTER)
        counter_val = self._get_counter_val(res)
        return get_last_counters_values(counter_val)[self.MIN_SLIDING_EIRP_COUNTER]

    def find_all_erip_counters(self):
        res = get_counter_values(self._build_counters_string())
        for i in range(0, self.LAST_COUNTER_I + 1):
            try:
                current_counter = f"{self.COUNTER_BASE}{i:02d}"
                logging.debug(
                    f"Verifying {current_counter} exist in webem response...")
                # check counter exist
                counter_val = self._get_counter_val(res)
                if i < self.test_beamset:
                    # add only relevant counter to memory values dict
                    self.last_values[current_counter] = get_last_counters_values(counter_val)[
                        current_counter]

                logging.debug(
                    f"Counter {current_counter} verification passed.")
            except KeyError:
                raise Exception(
                    f"Counter {current_counter} doesn't exist in WEBEM response.")
        logging.debug("5GC001329 counters verification passed.")

    def check_counters_incrementation_regarding_to_defined_beamset(self):
        for i in range(0, self.test_beamset):
            counter_name = f"{self.COUNTER_BASE}{i:02d}"
            assert self.last_values[counter_name] > 0, f"{counter_name} wasn't incremented after EIRP activation."

    def check_cell_power_counter(self):
        self.last_cell_power_counter_val = self._get_last_power_counter_value()
        logging.debug(
            f"Stored {self.CELL_POWER_COUNTER_NAME} value -> {self.last_cell_power_counter_val}")

    def check_and_compare_power_power_counters(self):
        current_power_counter_value = self._get_last_power_counter_value()
        logging.debug(
            f"Current {self.CELL_POWER_COUNTER_NAME} value -> {current_power_counter_value}")
        assert self.last_cell_power_counter_val > current_power_counter_value, \
            f"There is power reduction observed in cell power counter -> {self.CELL_POWER_COUNTER_NAME} \
                \nLast value: {self.last_cell_power_counter_val}\
                \nCurrent value: {current_power_counter_value}"

    def check_sliding_windows_counters_with_no_tput(self):
        current_max_sliding = self._get_last_max_sliding_counter_value()
        current_min_sliding = self._get_last_min_sliding_counter_value()

        assert self.NO_TPUT_MIN_SLIDING_BALUE <= current_max_sliding <= self.NO_TPUT_MAX_SLIDING_VALUE, \
            f"{self.MAX_SLIDING_EIRP_COUNTER} value {current_max_sliding} is not in range \
                {self.NO_TPUT_MIN_SLIDING_BALUE} - {self.NO_TPUT_MAX_SLIDING_VALUE}"

        assert self.NO_TPUT_MIN_SLIDING_BALUE <= current_min_sliding <= self.NO_TPUT_MAX_SLIDING_VALUE, \
            f"{self.MIN_SLIDING_EIRP_COUNTER} value {current_min_sliding} is not in range \
                {self.NO_TPUT_MIN_SLIDING_BALUE} - {self.NO_TPUT_MAX_SLIDING_VALUE}"

    def check_not_impacted_counters(self):
        res = get_counter_values(
            self._build_counters_string(offset=self.test_beamset))
        for i in range(self.test_beamset, self.LAST_COUNTER_I + 1):
            try:
                current_counter = f"{self.COUNTER_BASE}{i:02d}"
                logging.debug(
                    f"Verifying {current_counter} value...")
                # check counter exist
                counter_vals = self._get_counter_val(res)
                current_value = get_last_counters_values(counter_vals)[
                    current_counter]

                assert current_value == 0, \
                    f"{current_counter} shoudn't be zero but recevied {current_value}!\n\
                    HINT: Value is calculated related to beamset_6\n\
                    HINT: If the configuration is different that beamset_6 code or SCF changes are needed."

                logging.debug(
                    f"Counter {current_counter} verification passed.")
            except KeyError:
                raise Exception(
                    f"Counter {current_counter} doesn't exist in WEBEM response.")
        logging.debug("5GC001329 counters verification passed.")
