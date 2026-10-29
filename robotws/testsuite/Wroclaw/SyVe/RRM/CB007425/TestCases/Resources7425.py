from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import COMPAL
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.TputChecker import TputChecker

LOCAL_GNB_CELL_ID = 4
NEIGHBOURING_GNB_CELL_ID = 3
CAPABILITIES = "REAL_UE"
EXPECTED_MINIMUM_TPUT_ASIK = 0
EXPECTED_MINIMUM_TPUT_ASIM = 20
DATA_TRANSMISSION_TIME = 180
TPUT_SENT = 100


class Resources7425(CommonSuite):

    def __init__(self):
        super(Resources7425, self).__init__()
        self.feature = "CB007425"
        self.neighbouring_gnb_id = "MRBTS-{}".format(Env.GNBS[1].instance_id)
        self.enb_id = "MRBTS-{}".format(Env.ENB_ID)
        self.neighbouring_gnb_connection_details = Env.TESTLINE.test_pcs[2].default_ssh_connection_details
        self.enb_connection_details = Env.LTE_VM_SSH_CONN_DETAILS
        self.startup_manager_remote_gnb = StartupManager()
        self.swconfig = Swconfig()
        self.ue = Ue(COMPAL)
        self.asim_tput = None
        self.asik_tput = None
        self.tput = TputChecker()

    def start_and_check_ul_tput_on_asik(self):
        asik_data_name = 'tput_asik'
        self.block_local_gnb_cell_and_check_if_it_is_blocked()
        self.run_ul_udp_traffic(asik_data_name)
        self.asik_tput = self.ue.get_average_megabits_data_transfer(data_name=asik_data_name, analyze_entries=100)
        Logger.info('Tput on ASIK was: {}'.format(self.asik_tput))
        self.unblock_local_gnb_cell_and_check_if_it_is_blocked()
        assert self.asik_tput >= EXPECTED_MINIMUM_TPUT_ASIK, "Throughput on ASIK was lower than expected minimum"

    def start_and_check_ul_tput_on_asim(self):
        asim_data_name = 'tput_asim'
        self.block_neighbouring_gnb_cell_and_check_if_it_is_blocked()
        self.run_ul_udp_traffic(asim_data_name)
        self.asim_tput = self.ue.get_average_megabits_data_transfer(data_name=asim_data_name, analyze_entries=100)
        Logger.info('Tput on ASIM was: {}'.format(self.asim_tput))
        self.unblock_neighbouring_gnb_cell_and_check_if_it_is_blocked()
        assert self.asim_tput >= EXPECTED_MINIMUM_TPUT_ASIM, "Throughput on ASIM was lower than expected minimum"

    def check_if_tput_was_better_on_asim(self):
        assert self.asik_tput < self.asim_tput, "Throughput was not better on asim. \n" \
                                                " ASIM tput: {}, ASIK tput: {}".format(self.asik_tput, self.asim_tput)

    def prepare_ue_for_test(self):
        self.ue.prepare_ue()

    def start_bts_log(self):
        self.syslog.start_btslog_on_local_machine()

    def attach_ue(self):
        self.detach_ue_for_test()
        self.ue.attach()

    def run_ul_udp_traffic(self, data_name):
        self.attach_ue()
        self.ue.start_udp_uplink_data_transmission(duration=DATA_TRANSMISSION_TIME, data_name=data_name,
                                                   traffic_mb=TPUT_SENT)
        self.ue.wait_for_data_transmission_end(data_name=data_name)
        self.ue.stop_downlink_transmission(data_name=data_name)
        self.detach_ue_for_test()

    def detach_ue_for_test(self):
        self.ue.detach()

    def update_sw_config(self):
        uuf_flags = ["0x3F001E=1", "0x210017=1", "0x10079=500000"]
        self.swconfig.update_swconfig_flags(uuf_flags)

    def block_all_sites(self):
        self.bts_oam.make_sure_gnb_site_is_blocked()
        self.bts_oam.make_sure_gnb_site_is_blocked(gnb_id=1)
        self.bts_oam.make_sure_enb_site_is_blocked()

    def prepare_neighbouring_gnb(self):
        Logger.info("Performing config reset, sw update and commissioning neighbouring gNB")
        self.startup_manager_remote_gnb.update_sw_and_commission_remote_bts(self.feature, self.neighbouring_gnb_id,
                                                                            self.neighbouring_gnb_connection_details)

    def collect_remote_bts_snapshots_if_execution_fails(self):
        self.collect_remote_enb_snapshot_if_execution_fails()
        self.startup_manager_remote_gnb.remote_manager.collect_bts_snapshot_on_remote_vm_in_case_failure(
            bts_name=self.neighbouring_gnb_id, ssh_connection_details=self.neighbouring_gnb_connection_details)

    def block_local_gnb_cell_and_check_if_it_is_blocked(self):
        self.bts_oam.block_gnb_cell(LOCAL_GNB_CELL_ID)

    def unblock_local_gnb_cell_and_check_if_it_is_blocked(self):
        self.bts_oam.unblock_gnb_cell(LOCAL_GNB_CELL_ID)

    def block_neighbouring_gnb_cell_and_check_if_it_is_blocked(self):
        self.bts_oam.block_gnb_cell(NEIGHBOURING_GNB_CELL_ID, 1)

    def unblock_neighbouring_gnb_cell_and_check_if_it_is_blocked(self):
        self.bts_oam.unblock_gnb_cell(NEIGHBOURING_GNB_CELL_ID, 1)
