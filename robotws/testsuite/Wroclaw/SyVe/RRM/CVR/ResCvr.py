from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.SISO.resources.AirphoneClient import AirphoneClient
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command, upload_file
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsPmCounters import BtsPmCounters
from taf.config.testline.connection_details import SshServiceDetails
import time

IP_CONFIG_CMD = ('sudo ip addr add 10.0.1.200/24 dev eth3;'
                 'sudo ip addr add 10.0.1.131/24 dev eth3;'
                 'sudo ip addr add 10.0.1.132/24 dev eth3;'
                 'sudo ip addr add 10.0.1.133/24 dev eth3;'
                 'sudo ip addr add 10.0.1.134/24 dev eth3;'
                 'sudo ip addr add 10.0.1.135/24 dev eth3;'
                 'sudo ip addr add 10.0.1.136/24 dev eth3;'
                 'sudo ip addr add 10.0.1.121/24 dev eth3;'
                 'sudo ip addr add 10.0.1.137/24 dev eth3')
SSH_IPHY_PARAMS = SshServiceDetails(addr='192.168.200.1', username='toor4nsn', password='oZPS0POrRieRtu')
XML_ALIGN_CMD = 'r2d2 commands iphy-xml align'
VLAN_DISTNAME = 'MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1'
TPUT_VALUE = 175

RRC_RECONF_ADD1ULSCELL_ATT_SA = 'M55118C10001'
RRC_RECONF_ADD1ULSCELL_SUCC_SA = 'M55118C10002'
UE_PCELL_1_CONF_SCELL_UL_SA = 'M55118C10005'
UE_SCELL_1_CONF_SCELL_UL_SA = 'M55118C10006'
MAX_UE_PCELL_1_CONF_SCEL_UL_SA = 'M55156C10007'
PSCELL_UE_1_ACT_SCELL_UL = 'M55316C04001'
UE_PSCELL_ACT_SCELL_UL = 'M55316C02001'
SCELL_ACTIVATIONS = 'M55316C09000'
SAMPLES_UL_UE_AMOUNTS = 'M55316C01002'

COUNTERS_TO_CHECK_CELL1 = [RRC_RECONF_ADD1ULSCELL_ATT_SA, RRC_RECONF_ADD1ULSCELL_SUCC_SA,
                           UE_PCELL_1_CONF_SCELL_UL_SA, MAX_UE_PCELL_1_CONF_SCEL_UL_SA, PSCELL_UE_1_ACT_SCELL_UL,
                           UE_PSCELL_ACT_SCELL_UL, SAMPLES_UL_UE_AMOUNTS]
COUNTERS_TO_CHECK_CELL3 = [UE_SCELL_1_CONF_SCELL_UL_SA, SCELL_ACTIVATIONS]

EGATE_LOG_PATH = '/opt/wts/latest/egate_console.log'
BWP_SWITCH_ENTRIES = ['Bwp switch received from bwpId 1 to 2', 'Bwp switch received from bwpId 2 to 1']


class ResCvr(CommonSuite):

    def __init__(self):
        super(ResCvr, self).__init__()
        self.startup_manager = StartupManager()
        self.feature = 'CVR'
        self.bts_config = BtsConfig()
        self.egate_cfg_file = 'testsuite/Wroclaw/SyVe/RRM/CVR/resources/CUS/egate_config.cfg'
        self.ue_capabilities_file = 'testsuite/Wroclaw/SyVe/RRM/CVR/resources/CUS/CB006449_Capabilities_RJIO_n78.cfg'
        self.vmos = VmOs()
        self.env = TestEnvData()
        self.bts_counters = BtsPmCounters()
        self.airphone = None

    def prepare_environment(self):
        Logger.info("Changing ute password")
        self.vmos.change_ute_password()
        Logger.info("Connecting to the AP")
        self.airphone = AirphoneClient(ip_address=self.env.VM_HOST, username=self.env.VM_USER,
                                       password=self.env.VM_PASS)
        Logger.info("Installing R2D2 package on VM")
        self.vmos.install_r2d2_package()
        Logger.info("Configuring IP adresses on VM")
        self.vmos.execute_single_command_in_shell(IP_CONFIG_CMD)
        Logger.info("Changing IPHY configuration")
        execute_ssh_command(SSH_IPHY_PARAMS, 'rm /ffs/run/simmode/iphy.xml')
        execute_ssh_command(SSH_IPHY_PARAMS, 'rm /rom/simmode/new_iphy.xml')
        upload_file(SSH_IPHY_PARAMS, 'testsuite/Wroclaw/SyVe/RRM/CVR/resources/CUS/iphy_config.xml',
                    '/ffs/run/simmode/iphy_config.xml')
        execute_ssh_command(SSH_IPHY_PARAMS,
                            'ln -s /ffs/run/simmode/iphy_config.xml /ffs/run/simmode/iphy.xml')
        Logger.info("Aligning config XML")
        Logger.info(self.vmos.execute_single_command_in_shell(XML_ALIGN_CMD))
        self.airphone.start_egate()

    def testline_is_commissioned_and_on_air(self):
        self._perform_full_commisioning()
        self.startup_manager.wait_for_all_configured_radios_appeared()
        self.bts_config.perform_parameter_recommissioning(VLAN_DISTNAME, ['vlanId'], self.env.GNB_X2C_VLAN_ID,
                                                          skip_parameter_relation_errors=True)
        self.airphone.configure_egate_config_file(self.egate_cfg_file)
        self.airphone.start_sim_egate()
        self.startup_manager.wait_for_all_cells_on_air()

    def ue_is_attached(self):
        self.airphone.load_ue_capabilities_egate(ue_id=1, ue_caps_id="UE_UL_CA_CAPA_M80",
                                                 filename=self.ue_capabilities_file)
        self.airphone.attach_ue(ue_id=1, pdu_id=1)

    def ue_traffic_is_started(self):
        assert self.airphone.start_traffic(ue_id=1, pdu_id=1, direction='dl',
                                           tput=TPUT_VALUE, trf_id=1), 'Failure while starting traffic'
        assert self.airphone.start_traffic(ue_id=1, pdu_id=1, direction='dl',
                                           tput=TPUT_VALUE, trf_id=2), 'Failure while starting traffic'
        assert self.airphone.start_traffic(ue_id=1, pdu_id=1, direction='ul',
                                           tput=TPUT_VALUE, trf_id=3), 'Failure while starting traffic'
        assert self.airphone.start_traffic(ue_id=1, pdu_id=1, direction='ul',
                                           tput=TPUT_VALUE, trf_id=4), 'Failure while starting traffic'

    def cell_aggregation_is_verified(self):
        Logger.info("Waiting 5 sec before getting traffic stats")
        time.sleep(5)
        self._verify_scells_in_traffic_stats()

    def bwp_switching_is_verified(self):
        self._verify_bwp_switch_in_egate_console_log()

    def ue_traffic_is_stopped(self):
        self.airphone.stop_traffic(ue_id=1, pdu_id=1, direction='dl')
        self.airphone.stop_traffic(ue_id=1, pdu_id=1, direction='ul')

    def counters_are_updated(self):
        self._check_if_first_counter_is_already_updated(COUNTERS_TO_CHECK_CELL1[0], 1, 1)
        self._check_if_counters_on_gnb_are_incremented(COUNTERS_TO_CHECK_CELL1, 1, 1)
        self._check_if_counters_on_gnb_are_incremented(COUNTERS_TO_CHECK_CELL3, 3, 1)

    def _perform_full_commisioning(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'initial')
        self.bts_config.perform_full_commissioning(scf_file)

    def _verify_scells_in_traffic_stats(self):
        self.airphone.clear_shell_buffer()
        output = self.airphone.get_full_traffic_stats(ue_id=1, scell='0-3', type='pusch')
        Logger.info(output)
        assert 'CellIndex-0' in output, 'Scell-0 not found in traffic stats'
        assert 'CellIndex-1' in output, 'Scell-1 not found in traffic stats'
        output = self.airphone.get_full_traffic_stats(ue_id=1, scell='0-3')
        Logger.info(output)

    def _check_if_first_counter_is_already_updated(self, counter, cell, bts_id, gnb_id=0):
        self.bts_counters.wait_and_confirm_bts_cell_pm_counter_is_greater_than_zero(counter_id=counter, cell_id=cell,
                                                                                    bts_id=bts_id, gnb_id=gnb_id)

    def _check_if_counters_on_gnb_are_incremented(self, list_of_counters, cell, bts_id, gnb_id=0):
        for counter in list_of_counters:
            self.bts_counters.get_and_confirm_bts_cell_pm_counter_is_greater_than_zero(counter_id=counter, cell_id=cell,
                                                                                       bts_id=bts_id, gnb_id=gnb_id)

    @staticmethod
    def _verify_bwp_switch_in_egate_console_log():
        results = []
        try:
            with open(EGATE_LOG_PATH, 'r', encoding='utf-8') as file:
                for line in file:
                    for entry in BWP_SWITCH_ENTRIES:
                        if entry in line:
                            Logger.info(f"{entry} found in egate log!")
                            results.append(True)
        except Exception as e:
            Logger.info(f"Error: {e}")
        assert len(results) == 2, "Not all BWP switch entries have been found!"
