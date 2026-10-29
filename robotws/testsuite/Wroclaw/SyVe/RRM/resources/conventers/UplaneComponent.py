from taf.converters.eventdecoder.interface import eventdecoder
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs


class UplaneComponent(object):

    def __init__(self):
        self.uplane = eventdecoder()
        self.name = "uplane"
        self._l2_csv_file_path = None

    def pcap2csv(self, files_path_pattern, output_path):
        """
        Converts pcap to csv file and saves path to l2Trace csv file
        :param files_path_pattern: pattern path for pcap files location (may be full path)
        :param output_path: output path for storing csv files
        :return: None
        """
        self.uplane.create_eventdecoder_converter(name=self.name, input_file_path=files_path_pattern,
                                                  output_file_path=output_path, output_file_format='legacyCsv')
        self.uplane.setup(self.name)
        self.uplane.convert(self.name)
        self.uplane.teardown(self.name)

    @property
    def l2_csv_file_path(self):
        """
        Use this property for confirmed csv file location
        :return: L2 CSV file location
        """
        VmOs().confirm_file_exists(self._l2_csv_file_path)
        return self._l2_csv_file_path
