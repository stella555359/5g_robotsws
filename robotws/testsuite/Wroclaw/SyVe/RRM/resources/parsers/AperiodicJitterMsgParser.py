import re
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger


class AperiodicJitterMsgParser(object):
    def __init__(self, expect_acsi_msg):
        self.first_xsfn_on_air = None
        self.first_xsfn_line_written = False
        self.jitter_list = []
        self.last_xsfn_in_air = None
        self.aperiodic_counter = 0
        self.aperiodic_list_late_then_expected = []
        self.expect_acsi_msg = expect_acsi_msg

    def parse_file_asp_log(self, filepath):
        with open(filepath, "r") as asp_file:
            for index, line in enumerate(asp_file):
                self._parse_and_calculate_jitter(line)
        Logger.info("Total counter aperiodic that could be triggered by jitter change {}\n"
                    .format(self.aperiodic_counter))
        self._warn_possible_differences()

    def _warn_possible_differences(self):
        if len(self.aperiodic_list_late_then_expected) > 4:
            first_four_logs = slice(0, 4)
            Logger.info("Some differences are greater than 16, first 4 logs: {} all differences {}\n".
                        format(self.aperiodic_list_late_then_expected[first_four_logs],
                               len(self.aperiodic_list_late_then_expected)))

    def _parse_and_calculate_jitter(self, line):
        if re.search("xsfnOnAir", line):
            self._write_and_calculate_xsfn_on_air(line)
        elif re.search("updateCsiJitterState", line):
            self.jitter_list.append(int(re.search(r'((state to) (\d))', line).group(3)))

    def _calculate_jitter(self):
        if self._calculate_frames() > self.expect_acsi_msg:
            self.aperiodic_list_late_then_expected.append([{"frame": self._calculate_frames()},
                                                           {"first_xsfn_on_air": self.first_xsfn_on_air},
                                                           {"last_xsfn_in_air": self.last_xsfn_in_air}])
        if sum(self.jitter_list):
            self.aperiodic_counter += 1
        self._prepare_jitter_list_for_new_calculations()

    def _prepare_jitter_list_for_new_calculations(self):
        self.jitter_list = []

    def _calculate_frames(self):
        first = int(re.search(r':\[(\d+)', self.first_xsfn_on_air).group(1))
        last = int(re.search(r':\[(\d+)', self.last_xsfn_in_air).group(1))
        return last - first if (last - first) > 0 else 1024 + (last - first)

    @staticmethod
    def _get_xsfn_on_air_value(line):
        return re.search(r'(?is)(' + 'xsfnOnAir' + r':(.|\n)*?)(\n)', line).group(1)

    def _write_and_calculate_xsfn_on_air(self, line):
        if not self.first_xsfn_line_written:
            self.first_xsfn_on_air = self._get_xsfn_on_air_value(line)
            self.first_xsfn_line_written = True
        else:
            self.last_xsfn_in_air = self._get_xsfn_on_air_value(line)
            self._calculate_jitter()
            self._rewrite_xsfn_after_calculation()

    def _rewrite_xsfn_after_calculation(self):
        self.first_xsfn_on_air = self.last_xsfn_in_air
        self.last_xsfn_in_air = None
