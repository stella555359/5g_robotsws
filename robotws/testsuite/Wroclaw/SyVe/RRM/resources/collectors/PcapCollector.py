from taf.collectors.tcpdump import tcpdump
import taf.collectors.core as collectors_core
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger


class PcapCollector(object):
    def __init__(self):
        self.name = Env.TCPDUMP_NAME
        self._pcap_dir = Env().test_log_dir
        self._pcap_file_path = VmOs.join_path_elements(self._pcap_dir, "{name}/{name}.pcap".format(name=self.name))
        self.tcpdump = tcpdump()
        self.core = collectors_core.CollectorKeywords()

    def start_collecting_pcap(self, port=Env.VM_TRACE_PORT):
        """
        Starts collecting pcap on VM.
        This keyword uses taf library and reads port for listening from Env File
        :return: None
        """
        Logger.info("Starting pcap collecting")
        self._create_collector(port)
        self._setup_and_start_collectors()

    def stop_collecting_pcap(self):
        """
        Stops and saves pcap files.
        Uses default pcap_dir for destination files location (output_dir/suite_name/test_name)
        :return: None
        """
        Logger.info("Stopping pcap collecting")
        self.core.stop_collectors(names=self.name)
        self.core.collect_collectors(names=self.name, target_dir=self._pcap_dir)
        self.core.teardown_collectors(names=self.name)

    def stop_collecting_pcap_and_collect_files_on_local_os_if_the_test_fails(self):
        """
        Stops pcap collecting and collects files in case of the test case fails or forced.
        :return: None
        """
        if BuiltIn().get_variable_value("${TEST_STATUS}") == "FAIL":
            self._try_to_stop_collecting_pcap()
        else:
            self._try_remove_pcap_dir_content_when_test_passed()

    def stop_collecting_pcap_and_collect_files_on_local_os(self):
        """
        Stops pcap collecting and collects files in case of the test case fails or forced.
        :return: None
        """
        self._try_to_stop_collecting_pcap()

    @property
    def pcap_file_path(self):
        """
        Use this property to get pcap file location (confirmed by OS)
        :return: pcap file path
        """
        VmOs().confirm_file_exists(self._pcap_file_path)
        return self._pcap_file_path

    @property
    def pcap_dir(self):
        """
        Use this property for pcap directory location (as TAF assumes this default location)
        :return: pcap dir path
        """
        return self._pcap_dir

    def _create_collector(self, port):
        self.tcpdump.create_tcpdump_collector(name=self.name, options="-i eth0 port {}".format(port))

    def _setup_and_start_collectors(self):
        self.core.setup_collectors(names=self.name)
        self.core.start_collectors(names=self.name)

    def _try_to_stop_collecting_pcap(self):
        try:
            self.stop_collecting_pcap()
        except Exception as e:
            Logger.debug("Stopping pcap collecting failed due to: {}".format(e))

    def _try_remove_pcap_dir_content_when_test_passed(self):
        try:
            VmOs.remove_dir(VmOs.join_path_elements(self._pcap_dir, self.name))
        except OSError as e:
            Logger.debug("Removing of pcap dir failed due to: {}".format(e))
