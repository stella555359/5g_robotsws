from testsuite.Ulm.resources.Common.python.pmcounters import get_pi_dict, get_counter_value
import logging


class PMCounterThroughputCalculator:
    def __init__(self, pm_counter_dir):
        self.prefix_dl = 'M55310C010'
        self.prefix_ul = 'M55310C030'
        self.pm_counters_qdu_volume_dl_all_qos = self.generate_pm_counter_id_list_for_all_qos(self.prefix_dl)
        self.pm_counters_qdu_volume_ul_all_qos = self.generate_pm_counter_id_list_for_all_qos(self.prefix_ul)
        self.pm_counters_to_be_extracted = self.pm_counters_qdu_volume_dl_all_qos +\
            self.pm_counters_qdu_volume_ul_all_qos
        pi_file_pattern = "PM.BTS-*"
        self.retrieved_pm_counters = get_pi_dict(pm_counter_dir,
                                                 pi_list=self.pm_counters_to_be_extracted,
                                                 pi_file_pattern=pi_file_pattern)

    def generate_pm_counter_id_list_for_all_qos(self, prefix, num_of_qos=20):
        list_of_pm_counter_ids = []
        for qos in range(1, num_of_qos + 1):
            list_of_pm_counter_ids.append("{}{:02d}".format(prefix, qos))
        return list_of_pm_counter_ids

    def get_pdu_volume_low_rlc_by_cell_and_qos(self, cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
                                               interval=1, timestamps=None):
        total_pdu_volume = {'dl': 0,
                            'ul': 0}
        for timestamp in timestamps:
            total_pdu_volume["dl"] = total_pdu_volume['dl'] +\
                self.get_sum_of_all_values_in_pm_ids(self.pm_counters_qdu_volume_dl_all_qos,
                                                     cell_dist_name=cell_dist_name,
                                                     interval=interval, timestamp=timestamp)
            total_pdu_volume["ul"] = total_pdu_volume['ul'] +\
                self.get_sum_of_all_values_in_pm_ids(self.pm_counters_qdu_volume_ul_all_qos,
                                                     cell_dist_name=cell_dist_name,
                                                     interval=interval, timestamp=timestamp)
        return total_pdu_volume

    def get_sum_of_all_values_in_pm_ids(self, pm_ids, cell_dist_name, interval, timestamp=None):
        all_values = []
        for pm_counter in pm_ids:
            try:
                all_values.append(get_counter_value(pi_dict=self.retrieved_pm_counters,
                                                    pi=pm_counter,
                                                    dist_name=cell_dist_name,
                                                    index=interval,
                                                    pi_timestamp=timestamp) or 0)
            except KeyError:
                print("PM Counter ID not found in retrieved PM Dictionary")
        return sum(all_values)

    def get_divisor(self, unit):
        divisor = {'kbps': 1e3,
                   'mbps': 1e6,
                   'gbps': 1e9}
        return divisor[unit.lower()]

    def compute_cell_throughput(self, pm_value, traffic_duration_sec, unit='mbps'):
        if pm_value:
            """Convert Bytes to bits"""
            pm_value_in_bits = pm_value * 8
            pm_value_in_desired_units = pm_value_in_bits / self.get_divisor(unit)
            average_throughput_for_pm_interval = pm_value_in_desired_units / traffic_duration_sec
            return average_throughput_for_pm_interval
        else:
            logging.info("Throughput in given PM interval is 0")
            return 0

    def get_average_throughput(self, interval, traffic_duration_sec,
                               unit='Mbps', cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
                               timestamps=None):
        throughput = {}
        throughput_volume = self.get_pdu_volume_low_rlc_by_cell_and_qos(cell_dist_name, interval,
                                                                        timestamps=timestamps)
        dl_throughput = self.compute_cell_throughput(pm_value=throughput_volume['dl'],
                                                     traffic_duration_sec=traffic_duration_sec,
                                                     unit=unit)
        ul_throughput = self.compute_cell_throughput(pm_value=throughput_volume['ul'],
                                                     traffic_duration_sec=traffic_duration_sec,
                                                     unit=unit)
        print("Observed Average Cell Throughput : \nDL: {} {}\nUL: {} {}".format(dl_throughput, unit,
                                                                                 ul_throughput, unit))
        throughput['throughput_ul'] = ul_throughput
        throughput['throughput_dl'] = dl_throughput
        throughput['unit_dl'] = unit
        throughput['unit_ul'] = unit
        return throughput


def initialize_pmc_throughput_calculator(path_to_pmc_dir):
    throughput_calc_obj = PMCounterThroughputCalculator(path_to_pmc_dir)
    return throughput_calc_obj


def get_average_cell_throughput_for_interval(object,
                                             interval,
                                             traffic_duration_sec,
                                             cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
                                             unit='Mbps',
                                             timestamps=None):
    return (object.get_average_throughput(interval=interval,
                                          traffic_duration_sec=traffic_duration_sec,
                                          cell_dist_name=cell_dist_name,
                                          unit=unit, timestamps=timestamps))


if __name__ == '__main__':
    pm_counter_dir = '/mnt/etfiles/users/srjanard/AiCPMCounters/gnb_pm_counters'
    throughput_calc_obj = initialize_pmc_throughput_calculator(pm_counter_dir, False)
    for interval in range(0, 5):
        print("Interval: {}".format(interval))
        get_average_cell_throughput_for_interval(object=throughput_calc_obj, interval=interval,
                                                 traffic_duration_sec=5, unit='Mbps',
                                                 cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
                                                 timestamps=None)
        print('---------------')
