from robot.libraries.BuiltIn import BuiltIn
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


class ClassicalX2Sniffer:
    def __init__(self):
        self.x2_tracker = None
        self.x2_tcpdump_cmd = None
        self.enb_ip = None
        self.enb_prompt = r"(root|toor4nsn).*"
        self.enb_interface = "br1"
        self.path_to_x2_pcap_file = "/tmp/x2.pcap"
        self.fct_username = None
        self.fct_password = None
        self.default_cmd_timeout = 600

    def start_x2_collection(self):
        self._prepare_sniffer_utilities()
        self.x2_tcpdump_cmd.start(timeout=self.default_cmd_timeout)

    def stop_x2_collection_and_download_pcap(self):
        self.x2_tcpdump_cmd.break_cmd()
        self.x2_tracker.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": ".*"})()
        scp_x2_pcap = self.x2_tracker.get_cmd(cmd_name="scp", cmd_params={
            "source": "{}@{}:{}".format(self.fct_username, self.enb_ip, self.path_to_x2_pcap_file), "dest": "/tmp",
            "password": self.fct_password, "prompt": ".*"})
        scp_x2_pcap(timeout=self.default_cmd_timeout)

    @load_moler_configuration_from_tl()
    def _prepare_sniffer_utilities(self):
        tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.enb_ip = tl.enbs[0].oam_ip.v4
        self.fct_username = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username
        self.fct_password = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password
        self.x2_tracker = DeviceFactory.get_cloned_device("GNB0", "GNB0_x2", initial_state="PROXY_PC")
        self._ssh_to_enb()
        self.x2_tcpdump_cmd = self.x2_tracker.get_cmd(cmd_name="tcpdump", cmd_params={
            "options": "-ni {} -w {} sctp -v".format(self.enb_interface, self.path_to_x2_pcap_file),
            "prompt": "{}.*".format(self.enb_prompt)})

    def _ssh_to_enb(self):
        ssh_to_enb_cmd = self.x2_tracker.get_cmd(cmd_name="ssh", cmd_params={"login": self.fct_username,
                                                                             "password": self.fct_password,
                                                                             "host": self.enb_ip,
                                                                             "expected_prompt": self.enb_prompt})
        ssh_to_enb_cmd()

    def _remove_remote_x2_file(self):
        self._ssh_to_enb()
        self.x2_tracker.get_cmd(cmd_name="rm", cmd_params={"file": "/tmp/x2.pcap"})(timeout=self.default_cmd_timeout)
        self.x2_tracker.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute.*"})()
