from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
import re


class TputChecker(object):

    def check_downlink_tcp_throughput(self, ue_id, required_tput, deviation, analyze_entries,
                                      data_name, reverse_mode=False):
        log_file = self._get_ue_client_log_file(ue_id, data_name) if reverse_mode else \
            self._get_ue_server_log_file(ue_id, data_name)
        self._check_tput(required_tput, deviation, analyze_entries, log_file)

    def get_average_throughput(self, log_file, analyze_entries):
        Logger.info("Getting average throughput value for {} last entries".format(analyze_entries))
        min_, avg, max_ = self._get_tput_statistics(analyze_entries, log_file)
        return avg

    def get_maximum_throughput(self, log_file, analyze_entries):
        Logger.info("Getting maximum throughput value for {} last entries".format(analyze_entries))
        min_, avg, max_ = self._get_tput_statistics(analyze_entries, log_file)
        return max_

    def get_minimum_throughput(self, log_file, analyze_entries):
        Logger.info("Getting minimum throughput value for {} last entries".format(analyze_entries))
        min_, avg, max_ = self._get_tput_statistics(analyze_entries, log_file)
        return min_

    def get_all_throughputs(self, log_file, analyze_entries):
        Logger.info("Getting all throughput values for {} last entries".format(analyze_entries))
        with open(log_file, "r") as ue_log:
            tput_values = self._get_all_throughput_values(ue_log.readlines(), analyze_entries)
        Logger.debug(f"Last {analyze_entries} Tput values {tput_values[-analyze_entries:]}")
        return tput_values[-analyze_entries:]

    def check_uplink_tcp_throughput(self, ue_id, required_tput, deviation, analyze_entries,
                                    data_name):
        log_file = self._get_appserver_server_log_file(ue_id, data_name)
        self._check_tput(required_tput, deviation, analyze_entries, log_file)

    def check_downlink_udp_throughput(self, ue_id, deviation, data_name):
        log_file = self._get_ue_server_log_file(ue_id, data_name)
        Logger.debug("Checking UDP throughput values in {} file".format(log_file))
        with open(log_file, "r") as ue_log:
            deviation_values = self._get_all_percent_values(ue_log.readlines())
            assert deviation_values, "UE log from iperf binary does not contain any value"
            for value in deviation_values:
                assert value < deviation, \
                    "Downlink throughput exceeds allowed {:.2f}% deviation with {:.2f}%".format(deviation, value)

    def _get_tput_statistics(self, analyze_entries, log_file, ignored_boundaries_nr=1):
        Logger.debug("Checking throughput statistics in {} file".format(log_file))
        with open(log_file, "r") as ue_log:
            tput_values = self._get_all_throughput_values(ue_log.readlines(), analyze_entries)
        Logger.debug(f"Last {analyze_entries} Tput values {tput_values[-analyze_entries:]}")
        tput_entries = tput_values[-analyze_entries:]
        tput_entries.sort()
        nr_of_entries = len(tput_entries) - 2 * ignored_boundaries_nr
        Logger.debug(f"Sorted {nr_of_entries} Tput values {tput_entries} with skipped {ignored_boundaries_nr}"
                     f" boundaries values")
        assert nr_of_entries > 0, f"Throughput statistics table is empty, there is nothing to analyze.\n" \
                                  f"Requested entries: {analyze_entries}, " \
                                  f"skipped boundary values number:{ignored_boundaries_nr}, " \
                                  f"nr of entries to be analyzed: {nr_of_entries}, " \
                                  f"tput values without ignoring boundaries: {tput_values}"
        avg_ = sum(tput_entries[ignored_boundaries_nr:-ignored_boundaries_nr])/nr_of_entries
        max_ = tput_entries[-(ignored_boundaries_nr + 1)]
        min_ = tput_entries[ignored_boundaries_nr]
        Logger.info(f"Throughput statistics - Min:{min_}Mbps, Avg:{avg_:.1f}Mbps, Max:{max_}Mbps")
        return min_, avg_, max_

    def _check_tput(self, required_tput, deviation, analyze_entries, log_file):
        Logger.debug("Checking throughput values in {} file".format(log_file))
        _min, average_tput, _max = self._get_tput_statistics(analyze_entries, log_file)
        tput_deviation = 100 * (abs(average_tput - required_tput)/required_tput)
        Logger.info("Required throughput={:.2f}Mbits/s, average throughput={:.2f}Mbits/s,"
                    " deviation={:.2f}%".format(required_tput, average_tput, tput_deviation))
        assert tput_deviation < deviation, "Downlink throughput exceeds allowed {:.2f}% deviation" \
                                           " with avg {:.2f}%".format(deviation, tput_deviation)

    @staticmethod
    def _get_appserver_server_log_file(ue_id, data_name):
        appserver_iperf_log_file = "LOG_{}_SERVER_APPSERV_{}".format(Env.UES[ue_id - 1].serial_number, data_name)
        all_logs = [Os.join_path_elements(Env().test_log_dir, log_file) for
                    log_file in Os.get_files_with_names_starting_with(directory=Env().test_log_dir,
                                                                      startswith=appserver_iperf_log_file)]
        return Os.get_the_newest_file(all_logs)

    @staticmethod
    def _get_ue_client_log_file(ue_id, data_name):
        ue_iperf_log_file = "LOG_{}_CLIENT_UE_{}".format(Env.UES[ue_id - 1].serial_number, data_name)
        all_logs = [Os.join_path_elements(Env().test_log_dir, log_file) for
                    log_file in Os.get_files_with_names_starting_with(directory=Env().test_log_dir,
                                                                      startswith=ue_iperf_log_file)]
        return Os.get_the_newest_file(all_logs)

    @staticmethod
    def _get_ue_server_log_file(ue_id, data_name):
        ue_iperf_log_file = "LOG_{}_SERVER_UE_{}".format(Env.UES[ue_id - 1].serial_number, data_name)
        all_logs = [Os.join_path_elements(Env().test_log_dir, log_file) for
                    log_file in Os.get_files_with_names_starting_with(directory=Env().test_log_dir,
                                                                      startswith=ue_iperf_log_file)]
        return Os.get_the_newest_file(all_logs)

    @staticmethod
    def _get_all_percent_values(log_lines):
        percents_pattern = re.compile(r'(\((\S+)%\))')
        pattern_index = 0
        pattern_group = 1
        return [float(percents_pattern.findall(line)[pattern_index][pattern_group])
                for line in log_lines if line.strip().endswith("%)") and not line.strip().endswith("(1e+02%)")]

    @staticmethod
    def _get_all_throughput_values(log_lines, analyze_entries):
        skip_last_entries = -4
        tput_size_pattern = re.compile(r'(\S+) Mbits/sec(.*)')
        tput_size_group = 1
        try:
            return [float(re.search(tput_size_pattern, line).group(tput_size_group)) for line in log_lines
                    if re.search(tput_size_pattern, line)][:skip_last_entries]
        except IndexError:
            assert False, \
                "Throughput log file contains only {} lines, {} needed".format(len(log_lines)-4, analyze_entries)
