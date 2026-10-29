from taf.rfrl.bts.devices.du.cell_operations import GenericCellOperations
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations
from taf.rfrl.bts.devices.du.logs_collecting.btslog_collector import GnbBtslogCollector
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.transfer_files import download_files
from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_test_variable
from testsuite.Krakow.RRM.RAN_PZ.features.FR5GC002198.resources.Positioner import Positioner
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
import datetime
import os


class MasterGnb(object):
    def __init__(self):
        self.timeout_cmd = 900
        self.device_gnb = None
        self.device_xeon_slave = None
        self.device_xeon_master = None
        self.device_moler_syslog = None
        self.xeon_slave_tcpdump = None
        self.xeon_slave_pcap_name = None
        self.syslog_id = None
        self.positioner = Positioner()
        self.log_collector = GnbBtslogCollector()
        self.cell = GenericCellOperations()
        self.gnb_du = GenericDuOperations(bts_type="GNB")
        self.tl = get_builtin_value(param_name="tl")

    def _initialize_device(self):
        self.device_gnb = DeviceFactory.get_device(name='GNB0_DU0', initial_state='FCT')
        self.device_xeon_slave = DeviceFactory.get_cloned_device("GNB0_DU0", "GNB0_DU0_XEON_SLAVE",
                                                                 initial_state="FCT")
        self.device_xeon_master = DeviceFactory.get_cloned_device("GNB0_DU0", "GNB0_DU0_XEON_MASTER",
                                                                  initial_state="FCT")

    def _initialize_syslog_device(self, syslog_id):
        self.device_moler_syslog = DeviceFactory.get_cloned_device("GNB0_DU0_SYSLOG",
                                                                   "SYSLOG_START_TIME_{}".format(syslog_id))
        self.device_moler_syslog.goto_state("SYSLOG", keep_state=False)
        MolerTest.sleep(seconds=2)

    def _switch_to_xeon_slave(self):
        switch = self.device_xeon_slave.get_cmd(
            cmd_name="ssh",
            cmd_params={"login": self.tl.gnbs[0].cu.oam_ssh_connection_details.username,
                        "password": self.tl.gnbs[0].cu.oam_ssh_connection_details.password,
                        "host": "fct-1-0b"})
        switch(timeout=60)

    def _create_sniffer(self, interface="any", msg_filter="sctp"):
        self.xeon_slave_tcpdump = self.device_xeon_slave.get_cmd(cmd_name="tcpdump", cmd_params={
            "options": "-i {} -s0 -w /tmp/{} {} -v".format(interface, self.xeon_slave_pcap_name, msg_filter)})

    def _stop_tcpdump_on_xeon_slave(self):
        self.xeon_slave_tcpdump.break_cmd()

    def _download_pcap_from_xeon_slave_to_xeon_master(self):
        user = self.tl.gnbs[0].cu.oam_ssh_connection_details.username
        password = self.tl.gnbs[0].cu.oam_ssh_connection_details.password
        scp = self.device_xeon_master.get_cmd(cmd_name="scp", cmd_params={
            "source": "{}@{}:/tmp/{}".format(user, "fct0s1icom", self.xeon_slave_pcap_name),
            "dest": "/tmp/",
            "password": password})
        scp(timeout=self.timeout_cmd)

    def _remove_pcap_from_xeon_slave(self):
        rm = self.device_xeon_slave.get_cmd(cmd_name="rm",
                                            cmd_params={"file": "/tmp/{}".format(self.xeon_slave_pcap_name)})
        rm(timeout=60)

    def _download_pcap_from_xeon_master_to_output_dir(self):
        output_dir = get_builtin_value('LOG_PATH')
        MolerTest.info('Output dir: {}'.format(output_dir))
        download_files(local_dir=output_dir, remote_file=self.xeon_slave_pcap_name, device_name="GNB0_DU0_XEON_MASTER",
                       remote_dir="/tmp/", from_state="FCT", timeout=self.timeout_cmd, remove_source_file=True)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def enable_syslog_cp_debugs(self):
        sw_release = self.gnb_du.get_bts_sw_release_name()
        if sw_release in ["SBTS22R2", "SBTS22R3"]:
            self.enable_traces_in_cp_runtime()
        else:
            self.set_swconfig_cp_debug_flags()

    def enable_traces_in_cp_runtime(self):
        cmd = 'echo -e "[control]\\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini;chmod a+r /ffs/run/cp_runtime.ini'
        self._initialize_device()
        enable_debug = self.device_gnb.get_cmd(cmd_name="run_script",
                                               cmd_params={'script_command': cmd})
        enable_debug(timeout=60)

    def set_swconfig_cp_debug_flags(self):
        flags = {'0x890005': 1,  # CP-IF log
                 '0x890001': 1,  # CP-NB log
                 '0x890003': 1,  # CP-UE log
                 '0x890004': 1}  # CP-CL log

        for cp_flag, debug_lvl in flags.items():
            self.gnb_du.set_swconfig_flag(flag=cp_flag, value=debug_lvl)
            MolerTest.info('Value "{}" was assigned to Flag "{}" in /rom/swconfig.txt'.format(debug_lvl, cp_flag))

    def start_tcpdump_on_xeon_slave(self):
        timestamp = datetime.datetime.now().strftime("%H_%M_%S")
        self.xeon_slave_pcap_name = "MASTER_GNB_XEON_SLAVE_SCTP_{}.pcap".format(timestamp)
        self._initialize_device()
        self.device_xeon_slave.goto_state(state='FCT', rerun=3)
        self._create_sniffer()
        self._switch_to_xeon_slave()
        self.xeon_slave_tcpdump.start(timeout=self.timeout_cmd)
        return self.xeon_slave_pcap_name

    def stop_tcpdump_on_xeon_slave_and_download_pcap(self):
        self._stop_tcpdump_on_xeon_slave()
        self.device_xeon_master.goto_state(state='FCT', rerun=3)
        self._download_pcap_from_xeon_slave_to_xeon_master()
        self._remove_pcap_from_xeon_slave()
        self._download_pcap_from_xeon_master_to_output_dir()
        set_robot_test_variable('pcap_path', os.path.join(get_builtin_value('LOG_PATH'), self.xeon_slave_pcap_name))

    def stop_tcpdump_on_xeon_slave(self):
        self._stop_tcpdump_on_xeon_slave()
        self._remove_pcap_from_xeon_slave()

    def get_global_cell_id(self, cell_index=0):
        global_cell_id = self.cell.get_all_cells_id()[cell_index]
        return global_cell_id

    def _get_moler_syslog_path(self):
        raw_log_path = os.path.join(get_builtin_value('OUTPUT_DIR'), 'moler',
                                    get_builtin_value(param_name="TEST NAME").replace(" ", "_"),
                                    'moler.SYSLOG_START_TIME_{}.raw.log'.format(self.syslog_id))
        set_robot_test_variable("current_syslog_path", raw_log_path)
        return raw_log_path

    @load_moler_configuration_from_tl()
    def start_syslog(self):
        self.syslog_id = datetime.datetime.now().strftime("%H_%M_%S")
        self.log_collector.start_collecting_btslog()
        self._initialize_syslog_device(self.syslog_id)
        set_robot_test_variable("current_syslog_path", self._get_moler_syslog_path())

    @load_moler_configuration_from_tl()
    def stop_syslog(self):
        self.device_moler_syslog = DeviceFactory.get_cloned_device("GNB0_DU0_SYSLOG",
                                                                   "SYSLOG_START_TIME_{}".format(self.syslog_id))
        self.device_moler_syslog.goto_state("UNIX_REMOTE")

    @MolerTest.raise_background_exceptions()
    def teardown_log_collector(self):
        self.log_collector.teardown_btslog_collector()

    @load_moler_configuration_from_tl()
    def trigger_handover_with_log_collection(self):
        try:
            self.start_syslog()
            self.start_tcpdump_on_xeon_slave()
            self.positioner.perform_inter_gnb_handover()
        except Exception as e:
            raise Exception('Handover procedure with log collection FAILED! '
                            'During execution exception occurred: "{}"'.format(e))
        finally:
            self.stop_syslog()
            self.stop_tcpdump_on_xeon_slave_and_download_pcap()
