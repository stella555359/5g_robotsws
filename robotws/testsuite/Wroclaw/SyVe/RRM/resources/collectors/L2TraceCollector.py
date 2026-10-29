from testsuite.Wroclaw.SyVe.RRM.resources.collectors.PcapCollector import PcapCollector
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from taf.collectors.l2stream3 import l2stream3

ALLOWED_CONFIGURATION_KEYS = ["nr_phy_cell_ids", "nr_cell_dns", "up_sw", "trace_type"]
ASSERT_MSG_NO_KEY = "Unknown key:'{}' allowed keys are: {}"
ASSERT_MSG_PREPARE = "Empty configuration, execute 'update_l2_stream_configuration' first " \
                     "with some of these parameters: {}".format(" || ".join(ALLOWED_CONFIGURATION_KEYS))


class L2TraceCollector(PcapCollector):

    def __init__(self):
        super(L2TraceCollector, self).__init__()
        self.l2_stream_configuration = []
        self._pcap_file_path = VmOs.join_path_elements(self._pcap_dir,
                                                       "{name}/{name}/{name}.pcap".format(name=self.name))

    def update_l2_trace_configuration(self, **kwargs):
        """
        Updates L2 trace configuration
        :param kwargs: parameters listed in ALLOWED_CONFIGURATION_KEYS
        :return: None
        """
        self._confirm_keys(**kwargs)
        self.l2_stream_configuration.append(kwargs)
        Logger.debug("L2Stream configuration for trace collecting start is: {}".format(self.l2_stream_configuration))

    def prepare_and_start_collecting_pcap_trace_logs(self, port=Env.VM_TRACE_PORT):
        """
        Prepares and starts collecting pcap trace logs
        :return: None
        """
        self._confirm_start()
        Logger.info("Starting pcap and L2Stream collecting")
        self._create_collector(port)
        l2stream3().create_sbts_l2stream_collector(name=self.name, webservice=Env.TPCDUMP_EXECUTOR_DICT,
                                                   destination_ip_addr=Env.VM_HOST, collector=self.name,
                                                   l2_stream_configuration=self.l2_stream_configuration, dscp=5,
                                                   destination_port_number=Env.VM_TRACE_PORT)
        self._setup_and_start_collectors()

    def stop_collecting_pcap_trace_logs(self):
        """
        Stops collecting trace logs and pcap (via core.collector)
        :return: None
        """
        Logger.info("Stopping L2 Trace collecting")
        self.stop_collecting_pcap()

    def stop_collecting_trace_pcap_and_collect_files_on_local_os_if_the_test_fails(self):
        """
        Stops trace pcap collecting and collects files in case of the test case fails.
        :return: None
        """
        self.stop_collecting_pcap_and_collect_files_on_local_os_if_the_test_fails()

    def stop_collecting_trace_pcap_and_collect_files_on_local_os(self):
        """
        Stops trace pcap collecting and collects files.
        :return: None
        """
        self.stop_collecting_pcap_and_collect_files_on_local_os()

    @property
    def trace_pcap_file_path(self):
        return self.pcap_file_path

    @property
    def trace_pcap_dir(self):
        """
        Use this property for pcap directory location (as TAF assumes this default location).
        Parent's property not used due to L2Stream library duplicates the name in the path
        :return: pcap dir path
        """
        return VmOs.join_path_elements(self._pcap_dir, self.name)

    def _confirm_start(self):
        if not len(self.l2_stream_configuration):
            assert False, ASSERT_MSG_PREPARE

    @staticmethod
    def _confirm_keys(**kwargs):
        for key in kwargs:
            assert key in ALLOWED_CONFIGURATION_KEYS, ASSERT_MSG_NO_KEY.format(key, ALLOWED_CONFIGURATION_KEYS)
