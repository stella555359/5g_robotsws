from taf.converters.sherpa.interface import sherpa
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env


class Sherpa(object):

    def __init__(self):
        self.sherpa = sherpa()
        self.name = "sherpa"
        self._l2_csv_file_path = None

    def pcap2csv(self, files_path_pattern, output_path):
        """
        Converts pcap to csv file and saves path to l2Trace csv file
        :param files_path_pattern: pattern path for pcap files location (may be full path)
        :param output_path: output path for storing csv files
        :return: None
        """
        self.sherpa.create_sherpa_converter(name=self.name, file_path_pattern=files_path_pattern,
                                            output_path=output_path, sherpa_command_duration='3000')
        self.sherpa.setup(self.name)
        self.sherpa.convert(self.name)
        self.sherpa.teardown(self.name)
        self._l2_csv_file_path = VmOs.join_path_elements(output_path, Env.TCPDUMP_NAME, "micro__l1l2Trace.csv")

    @property
    def l2_csv_file_path(self):
        """
        Use this property for confirmed csv file location
        :return: L2 CSV file location
        """
        VmOs().confirm_file_exists(self._l2_csv_file_path)
        return self._l2_csv_file_path
