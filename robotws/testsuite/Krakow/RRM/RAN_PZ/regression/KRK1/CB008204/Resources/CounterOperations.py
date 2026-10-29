import logging
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter, GenericPmCounter, PmCounterOutputGetter


class CounterOperations(GenericPmCounter):

    dl_counter_ids = ["M55363C00001",
                      "M55363C00003",
                      "M55308C36001",
                      "M55308C10001"]

    ul_counter_ids = ["M55363C00002",
                      "M55363C00004",
                      "M55308C36002",
                      "M55308C10002"]

    ul_endc_counter_ids = ["M55146C00001",
                           "M55146C00002",
                           "M55146C00003",
                           "M55162C01001"]

    def get_newest_entry_for_counter(self, counters, counter_id, cell_id=None):
        if cell_id is None:
            counter = self.extract_counter_data_from_response(counters, counter_id)
            return {counter_id: counter[0]["timestamps"][0][max(counter[0]["timestamps"][0].keys())]}
        else:
            pm_output = PmCounterOutputGetter(pm_counter_output=counters)
            cell_counters = pm_output.get_cell_counters(cell_id=cell_id)
            logging.debug(f'All counters for CELL-{cell_id}: {cell_counters}')
            counter = self.extract_counter_data_from_response(cell_counters, counter_id)
            logging.debug(f'Extracted data for counter={counter_id}: {counter}')
            max_counter = {counter_id: counter[0]["timestamps"][0][max(counter[0]["timestamps"][0].keys())]}
            logging.debug(f'Max value for counter={counter_id}: {max_counter}')
            return max_counter

    def get_counters(self, counter_ids, cell_id=None):
        counters = GnbPmCounter.get_counter(self, counter_ids=",".join(counter_ids))
        counters_values = {}
        for counter in counter_ids:
            counters_values.update(self.get_newest_entry_for_counter(counters, counter, cell_id=cell_id))
        return counters_values

    def get_counters_dl(self, cell_id=None):
        return self.get_counters(self.dl_counter_ids, cell_id=cell_id)

    def get_counters_ul(self, cell_id=None):
        return self.get_counters(self.ul_counter_ids, cell_id=cell_id)

    def get_counters_endc_ul(self, cell_id=None):
        return self.get_counters(self.ul_endc_counter_ids, cell_id=cell_id)

    def calculate_counters_range(self, dl_counters, ul_counters):
        counters_range = {
            "M55363C00001_min": dl_counters["M55308C10001"] * 0.7,
            "M55363C00001_max": dl_counters["M55308C10001"] * 1.2,
            "M55363C00002_min": ul_counters["M55308C10002"] * 0.7,
            "M55363C00002_max": ul_counters["M55308C10002"] * 1.2
        }
        return counters_range
