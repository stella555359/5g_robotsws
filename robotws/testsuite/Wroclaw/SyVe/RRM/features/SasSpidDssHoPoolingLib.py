from datetime import datetime
from time import sleep

from testsuite.Wroclaw.SyVe.RRM.resources.Attenuator import Attenuator
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsOam import BtsOam
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsPmCounters import BtsPmCounters, PM_COLLECTION_SECONDS, \
    LEGACY_CELL_COUNTER_PATH_STREAM_SW
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.BtsOs import BtsOs
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.PcapCollector import TcpdumpCollector, expected_log_is_stored_in_pcap
from testsuite.Wroclaw.SyVe.RRM.resources.NetworkInterfaceManager import NetworkInterfaceManager
from testsuite.Wroclaw.SyVe.RRM.resources.Pdu import Pdu
from testsuite.Wroclaw.SyVe.RRM.resources.Rfrl import Rfrl
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import ASKEY_AT_ADB
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from robot.libraries.BuiltIn import BuiltIn

from testsuite.Wroclaw.SyVe.RRM.resources.collectors.SyslogCollector import SyslogCollector

PRB_AVAIL_PDSCH = "M55308C10003"
PRB_AVAIL_PDSCH_SLICES = "M55308C10007"

DL_PRB_USED_DATA_PMQAP = "M55363C00001"
PRB_USED_PDSCH_NSA_PLMN = "M55338C01001"

DL_PRB_USED_DATA_NRG = "M55910C00001"
UL_PRB_USED_DATA_NRG = "M55910C00003"

PMQAP_COUNTERS = [PRB_AVAIL_PDSCH, DL_PRB_USED_DATA_PMQAP]
PLMN_COUNTERS = [PRB_AVAIL_PDSCH_SLICES, PRB_USED_PDSCH_NSA_PLMN] + PMQAP_COUNTERS
NRG_SPID_COUNTERS = [PRB_AVAIL_PDSCH_SLICES, DL_PRB_USED_DATA_NRG] + PMQAP_COUNTERS
DL_PRB_AVAIL_SAS = "M55308C10013"
UL_PRB_AVAIL_SAS = "M55308C10012"
DL_SANSA_SAS_PM_COUNTERS = [DL_PRB_AVAIL_SAS, DL_PRB_USED_DATA_NRG]
UL_SANSA_SAS_PM_COUNTERS = [UL_PRB_AVAIL_SAS, UL_PRB_USED_DATA_NRG]
NRG_SPID_COUNTERS_24R3 = DL_SANSA_SAS_PM_COUNTERS + PMQAP_COUNTERS

TCPDUMP_CMD = 'cd /tmp && (nohup  tcpdump -i any -w master.pcap 1>/dev/null 2>/dev/null &); exit'
PID_TCPDUMP_CMD = "ps -ef | grep tcpdump | egrep -v 'grep|firewall|eth' | awk '{print $2}'"

X2AP_PROTOCOL = 'x2ap'
HANDOVER_SUCCESSFUL_FILTER = 'x2ap.SgNBChangeConfirm_element'
HANDOVER_SUCCESSFUL_MESSAGE = 'SgNBChangeConfirm'
PCAP_UNSUCCESSFUL_MSG = 'Not all ues went through handover procedure'

MIN_ATTENUATION = 0
MAX_ATTENUATION = 90
SOURCE_CELL_ID = "366"
TARGET_CELL_ID = "466"
DSS_CELL_ID = "3"
SOURCE_COMMON_PATH = f"CELLS/NRCELL-{SOURCE_CELL_ID}" if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW\
    else f"MRBTS-{Env.GNB_GLOBAL_BTS_ID}/NRBTS-{Env.GNB_GLOBAL_BTS_ID}/NRCELL-{SOURCE_CELL_ID}"
TARGET_COMMON_PATH = f"CELLS/NRCELL-{TARGET_CELL_ID}" if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW\
    else f"MRBTS-{Env.GNBS[1].global_bts_id}/NRBTS-{Env.GNBS[1].global_bts_id}/NRCELL-{TARGET_CELL_ID}"
DSS_COMMON_PATH = f"CELLS/NRCELL-{DSS_CELL_ID}" if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW\
    else f"MRBTS-{Env.GNBS[1].global_bts_id}/NRBTS-{Env.GNBS[1].global_bts_id}/NRCELL-{DSS_CELL_ID}"
SHIELDBOX_PDU_ID = 2
ASKEY_PDU_PORT = 5
MCC1 = "540"
MNC1 = "01"
MCC2 = "310"
MNC2 = "260"
NUMBER_OF_UES_FOR_HO = 4
UEPC_SSH_ADDR = "10.44.72.95"
BASE_FEATURE = "CB008746"
UL_SAS_FEATURE = "CB008709"
STREAMS_BEFORE_SAS_MIGRATION = ["SBTS23R2", "SBTS23R3", "SBTS23R4", "SBTS24R1"]
SAS_MIGRATION_FIRST_STEP_STREAM = "SBTS24R2"


class Plmn(object):

    def __init__(self, cell_id, mcc, mnc, min_quota, max_quota, target_share):
        self.cell_id = cell_id
        self.mcc = mcc
        self.mnc = mnc
        self.min_quota = min_quota
        self.max_quota = max_quota
        self.quotas = [min_quota, max_quota]
        self.target_share = target_share

    def __str__(self):
        return f"MCC-{self.mcc}_MNC-{self.mnc}" if Env.STREAM_SW in LEGACY_CELL_COUNTER_PATH_STREAM_SW\
            else f"MCC-{self.mcc}/MNC-{self.mnc}"


class NRResourceGroup(object):

    def __init__(self, cell_id, resource_group_id, min_quota, max_quota, target_share):
        self.cell_id = cell_id
        self.id = resource_group_id
        self.min_quota = min_quota
        self.max_quota = max_quota
        self.quotas = [min_quota, max_quota]
        self.target_share = target_share

    def __str__(self):
        return f"nrresourcegroup-id-{self.id}"


class Environment:
    def __init__(self):
        self.attenuator = Attenuator()
        self.enb_1_name = f"MRBTS-{Env.ENBS[0].instance_id}"
        self.gnb_1_name = f"MRBTS-{Env.GNBS[0].instance_id}"
        self.enb_2_name = f"MRBTS-{Env.ENBS[1].instance_id}"
        self.gnb_2_name = f"MRBTS-{Env.GNBS[1].instance_id}"
        self.cell_id = SOURCE_CELL_ID
        self.gnb_1_id = 0
        self.enb_1_id = 0
        self.gnb_2_id = 1
        self.gnb_2_bts_id = Env.GNBS[1].global_bts_id
        self.enb_2_id = 1
        self.ssh_connection_gnb_local = Env.GNB_SSH_CONNECTION_DETAILS
        self.ssh_connection_enb_1_vm = Env.LTE_VM_SSH_CONN_DETAILS
        self.ssh_connection_gnb_2_vm = Env.TESTLINE.test_pcs[2].default_ssh_connection_details
        self.ssh_connection_enb_2_vm = Env.TESTLINE.test_pcs[3].default_ssh_connection_details
        self.bts_admin = BtsAdminApi()
        self.bts_counters = BtsPmCounters()
        self.syslog = SyslogCollector()
        self.delta = ScfPathFinder()
        self.attenuation_ports = self._set_attenuation_dict()
        self.startup_manager = StartupManager()
        self.bts_config = BtsConfig()
        self.bts_snapshot = BtsSnapshot()
        self.bts_faults = BtsFaults()

    def prepare_suite(self, feature, recommission_node=False):
        self._update_swconfig_for_syslog_flags()
        self._switch_on_ues_pdu_port()
        self._prepare_enb(self.enb_1_name, feature, self.ssh_connection_enb_1_vm)
        self._prepare_local_gnb(feature)
        self._prepare_enb(self.enb_2_name, feature, self.ssh_connection_enb_2_vm, bts_id=1,
                          recommission_node=recommission_node)
        self._prepare_gnb(self.gnb_2_name, feature, self.ssh_connection_gnb_2_vm, bts_id=1,
                          recommission_node=recommission_node)
        NetworkInterfaceManager(UEPC_SSH_ADDR).turn_off_all_interfaces()

    def suite_teardown(self):
        self._switch_off_ues_pdu_port()

    def prepare_environment_and_start_logging(self):
        for port in self.attenuation_ports.get("source_bts").get("bts"):
            self.attenuator.set_port_attenuation(port, MIN_ATTENUATION)
        for port in self.attenuation_ports.get("target_bts").get("bts"):
            self.attenuator.set_port_attenuation(port, MAX_ATTENUATION)
        self.prepare_nsa_syslogs()

    def prepare_nsa_syslogs(self):
        self.syslog.start_btslog_on_local_machine()
        lte_vm_ssh_executor = {"host": self.ssh_connection_enb_1_vm.addr,
                               "user": self.ssh_connection_enb_1_vm.username,
                               "password": self.ssh_connection_enb_1_vm.password}
        self.syslog.start_btslog_on_remote_machine(name=Env.BTSLOG_4G_ALIAS,
                                                   ssh_connection_details=self.ssh_connection_enb_1_vm,
                                                   executor=lte_vm_ssh_executor)
        self.startup_manager.wait_for_x2_connected()

    def prepare_btslog_for_remote_nsa_bts(self):
        self.startup_manager.wait_for_x2_connected(gnb_id=1, lmp_ip_if_gnb0=False)
        lte2_vm_ssh_executor = {"host": self.ssh_connection_enb_2_vm.addr,
                                "user": self.ssh_connection_enb_2_vm.username,
                                "password": self.ssh_connection_enb_2_vm.password}
        gnb2_vm_ssh_executor = {"host": self.ssh_connection_gnb_2_vm.addr,
                                "user": self.ssh_connection_gnb_2_vm.username,
                                "password": self.ssh_connection_gnb_2_vm.password}
        self.syslog.start_btslog_on_remote_machine(name=Env.BTSLOG_4G_2_ALIAS,
                                                   ssh_connection_details=self.ssh_connection_enb_2_vm,
                                                   executor=lte2_vm_ssh_executor)
        self.syslog.start_btslog_on_remote_machine(name=Env.BTSLOG_5G_2_ALIAS,
                                                   ssh_connection_details=self.ssh_connection_gnb_2_vm,
                                                   executor=gnb2_vm_ssh_executor)

    def collect_logs_if_the_test_fails(self):
        Rfrl.common_step_trigger()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails(Env.BTSLOG_4G_ALIAS)
        self.bts_snapshot.collect_snapshot_if_the_test_fails()
        self.startup_manager.remote_manager.\
            collect_bts_snapshot_on_remote_vm_in_case_failure(self.enb_1_name, self.ssh_connection_enb_1_vm,
                                                              suite_level=False,
                                                              remove_remote_dir=False)
        self.bts_faults.log_active_faults()
        self.bts_faults.log_historical_faults()

    def collect_logs_if_the_remote_nsa_bts_test_fails(self):
        Rfrl.common_step_trigger()
        self.startup_manager.remote_manager.\
            collect_bts_snapshot_on_remote_vm_in_case_failure(self.gnb_2_name, self.ssh_connection_gnb_2_vm,
                                                              suite_level=False,
                                                              remove_remote_dir=False)
        self.startup_manager.remote_manager. \
            collect_bts_snapshot_on_remote_vm_in_case_failure(self.enb_2_name, self.ssh_connection_enb_2_vm,
                                                              suite_level=False,
                                                              remove_remote_dir=False)
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails()
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails(Env.BTSLOG_4G_2_ALIAS)
        self.syslog.stop_btslog_and_collect_files_on_local_os_if_the_test_fails(Env.BTSLOG_5G_2_ALIAS)
        self.bts_faults.log_active_faults()
        self.bts_faults.log_historical_faults()
        self.bts_faults.log_active_faults(gnb_id=1)
        self.bts_faults.log_historical_faults(gnb_id=1)

    def commission_bts_if_the_test_failed(self, feature):
        if BuiltIn().get_variable_value("${TEST_STATUS}") == "FAIL":
            self.commission_gnb(feature, self.gnb_1_id, self.gnb_1_name)
            self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    def bts_configuration_update(self, feature, delta):
        Logger.info(f"Updating bts configuration with delta: {delta}")
        self.bts_config.perform_delta_commissioning(
            self.delta.get_delta_path_for_feature(feature, delta), )
        self.bts_admin.wait_for_admin_connection_possibility(interval=90)
        self.startup_manager.wait_for_all_cells_on_air()

    def _prepare_local_gnb(self, feature):
        self.startup_manager.confirm_sw_version_and_make_sure_bbu_modules_are_enabled_after_installation()
        self._commission_base_feature_test_line(feature)
        self.startup_manager.manage_commissioned_bts_to_reach_on_air_state()

    def _prepare_enb(self, bts_name, feature, enb_vm_ssh_connection_info, bts_id=0, recommission_node=False):
        Logger.info(f"Performing config reset, sw update and commissioning on eNB: {bts_name}")
        self.startup_manager.update_sw_and_commission_remote_bts(feature=feature, bts_name=bts_name,
                                                                 ssh_connection_details=enb_vm_ssh_connection_info,
                                                                 bts_id=bts_id, recommission_node=recommission_node)

    def _prepare_gnb(self, bts_name, feature, gnb_vm_ssh_connection_info, bts_id=0, recommission_node=False):
        Logger.info(f"Performing config reset, sw update and commissioning on gNB: {bts_name}")
        self.startup_manager.update_sw_and_commission_remote_bts(feature=feature, bts_name=bts_name,
                                                                 ssh_connection_details=gnb_vm_ssh_connection_info,
                                                                 bts_id=bts_id, recommission_node=recommission_node)

    @staticmethod
    def _switch_on_ues_pdu_port():
        Pdu(pdu_id=SHIELDBOX_PDU_ID).switch_on_pdu_port(ASKEY_PDU_PORT)

    @staticmethod
    def _switch_off_ues_pdu_port():
        Pdu(pdu_id=SHIELDBOX_PDU_ID).switch_off_pdu_port(ASKEY_PDU_PORT)

    @staticmethod
    def _update_swconfig_for_syslog_flags():
        syslog_flags = ["0x420000=1", "0x10041=2", "0x590072=1", "0x41001b=1"]
        Swconfig().update_swconfig_flags(syslog_flags)

    def _commission_base_feature_test_line(self, feature):
        self.bts_config.perform_full_commissioning(self.delta.get_scf_path_for_feature(feature, self.gnb_1_name))

    def commission_gnb(self, feature, bts_id, *scf_params):
        scf_file = ScfPathFinder().get_scf_path_for_feature(feature, *scf_params)
        self.bts_config.perform_full_commissioning(scf_file, bts_id)

    def commission_enb(self, feature, bts_id, *scf_params):
        scf_file = ScfPathFinder().get_scf_path_for_feature(feature, *scf_params)
        self.bts_config.perform_full_commissioning_enb(scf_file, bts_id)

    def _set_attenuation_dict(self):
        attenuator_ports = list(self.attenuator.attenuator_ports)
        attenuations = {
            "source_bts": {"bts": attenuator_ports[0:4],
                           "gnb": attenuator_ports[0:2],
                           "enb": attenuator_ports[2:4]},
            "target_bts": {"bts": attenuator_ports[4:8],
                           "gnb": attenuator_ports[4:6],
                           "enb": attenuator_ports[6:8]}
        }
        return attenuations


class SasSpidDssHoPoolingLib:

    def __init__(self, feature=BASE_FEATURE):
        self.bts_configuration = Environment()
        self.ue_nrg1 = Ue(type_=ASKEY_AT_ADB, ue_id=1)
        self.ue_nrg2 = Ue(type_=ASKEY_AT_ADB, ue_id=2)
        self.ue_nrg3 = Ue(type_=ASKEY_AT_ADB, ue_id=3)
        self.ue_nrg4 = Ue(type_=ASKEY_AT_ADB, ue_id=4)
        self.feature = feature
        self.pcap_tgt_file = None
        self.pcap_src_file = None
        self.counter_timestamp = None
        self.active_raw_counters = None
        self.cell_id = SOURCE_CELL_ID
        self.bts_admin = BtsAdminApi()
        self.bts_counters = BtsPmCounters()
        self.plmns = None
        self.nr_resource_groups = None
        self._configure_plmn_list()
        self._configure_nr_resource_group_list()
        self._source_tcpdump_collector = TcpdumpCollector(self.bts_configuration.ssh_connection_gnb_local)

    def prepare_suite(self):
        self.bts_configuration.prepare_suite(self.feature)

    def prepare_ul_sas_suite(self):
        self.feature = UL_SAS_FEATURE
        self.bts_configuration.prepare_suite(self.feature)

    def prepare_ul_dss_test(self):
        self.feature = UL_SAS_FEATURE
        self.environment_for_dss_test_is_prepared()

    def prepare_test(self):
        self.bts_configuration.prepare_environment_and_start_logging()
        self._prepare_ues()

    def teardown_suite(self):
        self.bts_configuration.suite_teardown()

    def teardown_test(self):
        self._detach_ue_remove_traffic_files_and_cleanup_logs()

    def teardown_2_nsa_btss_test(self):
        self._detach_ue_remove_traffic_files_and_cleanup_logs()
        self.bts_configuration.collect_logs_if_the_remote_nsa_bts_test_fails()

    def stop_tcp_dump_if_test_failed(self):
        if BuiltIn().get_variable_value("${TEST_STATUS}") == "FAIL":
            self._source_tcpdump_collector.stop_tcpdump_collection()

    def environment_for_successful_handover_is_prepared(self):
        self._set_atten_to_force_attach_in_source_bts()
        self.bts_configuration.prepare_btslog_for_remote_nsa_bts()
        self._prepare_ues()

    def environment_for_dss_test_is_prepared(self):
        self._set_atten_to_force_attach_in_target_bts()
        self.bts_configuration.prepare_btslog_for_remote_nsa_bts()
        self._recommission_remote_bts_to_dss()
        self._prepare_ues()

    def _recommission_remote_bts_to_dss(self):
        self.bts_configuration. \
            commission_gnb(self.feature, self.bts_configuration.gnb_2_id,
                           f"{self.bts_configuration.gnb_2_name.split('-')[1]}_dss")
        self.bts_configuration.startup_manager. \
            manage_commissioned_remote_bts_to_reach_on_air_state(self.bts_configuration.gnb_2_name,
                                                                 self.bts_configuration.ssh_connection_gnb_2_vm)
        self.bts_configuration. \
            commission_enb(self.feature, self.bts_configuration.enb_2_id,
                           f"{self.bts_configuration.enb_2_name.split('-')[1]}_dss")
        self.bts_configuration.startup_manager. \
            manage_commissioned_remote_bts_to_reach_on_air_state(self.bts_configuration.enb_2_name,
                                                                 self.bts_configuration.ssh_connection_enb_2_vm)

    def _set_atten_to_force_attach_in_source_bts(self):
        for port in self.bts_configuration.attenuation_ports.get('source_bts').get('gnb'):
            self.bts_configuration.attenuator.set_port_attenuation(port, MIN_ATTENUATION)
        for port in self.bts_configuration.attenuation_ports.get('target_bts').get('gnb'):
            self.bts_configuration.attenuator.set_port_attenuation(port, MAX_ATTENUATION)

    def _set_atten_to_force_attach_in_target_bts(self):
        for port in self.bts_configuration.attenuation_ports.get('source_bts').get('bts'):
            self.bts_configuration.attenuator.set_port_attenuation(port, MAX_ATTENUATION)
        for port in self.bts_configuration.attenuation_ports.get('target_bts').get('bts'):
            self.bts_configuration.attenuator.set_port_attenuation(port, MIN_ATTENUATION)

    def restore_default_config_after_dss_test(self):
        self.bts_configuration.commission_enb(self.feature, self.bts_configuration.enb_2_id,
                                              self.bts_configuration.enb_2_name)
        self.bts_configuration.startup_manager. \
            manage_commissioned_remote_bts_to_reach_on_air_state(self.bts_configuration.enb_2_name,
                                                                 self.bts_configuration.ssh_connection_enb_2_vm)
        self.bts_configuration.commission_gnb(self.feature, self.bts_configuration.gnb_2_id,
                                              self.bts_configuration.gnb_2_name)
        self.bts_configuration.startup_manager. \
            manage_commissioned_remote_bts_to_reach_on_air_state(self.bts_configuration.gnb_2_name,
                                                                 self.bts_configuration.ssh_connection_gnb_2_vm)

    def pcap_capturing_is_started_on_source_gnb(self):
        self._source_tcpdump_collector.start_tcpdump_collection()

    def pcap_capturing_is_stopped_and_downloaded_from_source_gnb(self):
        self.pcap_src_file = self._source_tcpdump_collector.stop_and_download_tcpdump_from_gnb("ho_src.pcap")

    def successful_handover_attempt_log_is_stored_in_pcap(self):
        filtered_logs = expected_log_is_stored_in_pcap(self.pcap_src_file, HANDOVER_SUCCESSFUL_FILTER)
        assert filtered_logs.count(HANDOVER_SUCCESSFUL_MESSAGE) == NUMBER_OF_UES_FOR_HO, PCAP_UNSUCCESSFUL_MSG

    def handover_is_performed(self):
        self.bts_configuration.attenuator.\
            perform_handover(self.bts_configuration.attenuation_ports.get("source_bts").get("gnb"),
                             self.bts_configuration.attenuation_ports.get("target_bts").get("gnb"),
                             target_bts_db_decrase_factor=2)

    def multiple_ues_are_detached_from_cell(self):
        self._detach_all_ues()

    def multiple_ues_are_attached_to_the_cell(self):
        self._attach_all_ues()

    def multiple_ues_are_attached_to_the_dss_cell(self):
        BtsOam().make_sure_dss_cell_is_running(enb_dss_cell_id="199", enb_id=1)
        self._attach_all_ues()

    def data_tx_started_for_the_all_ues(self):
        transmission_time = self._prepare_counter_measurement()
        self._start_tput_for_all_ues(transmission_time)

    def data_rx_started_for_the_all_ues(self):
        transmission_time = self._prepare_counter_measurement(data_name="SAS_UL_UE")
        self._start_ul_tput_for_all_ues(transmission_time)

    def configuration_is_changed_with_feature_activated(self):
        if Env().STREAM_SW in STREAMS_BEFORE_SAS_MIGRATION:
            self.bts_configuration.bts_configuration_update(self.feature, "activate_feature_8746_old")
        else:
            self.bts_configuration.bts_configuration_update(self.feature, "activate_feature_8746_new")

    def change_configuration_to_deactivate_feature(self):
        if Env().STREAM_SW in STREAMS_BEFORE_SAS_MIGRATION:
            self.bts_configuration.bts_configuration_update(self.feature, "disable_feature_8746_old")
        else:
            self.bts_configuration.bts_configuration_update(self.feature, "disable_feature_8746_new")

    def plmn_pm_counters_are_collected_before_feature_activation(self):
        self._wait_and_collect_counters(PLMN_COUNTERS, "TEST STARTED")

    def spid_pm_counters_are_collected_for_source_gnb(self):
        spid_counters = NRG_SPID_COUNTERS_24R3 if self.sas_migration_2nd_step else NRG_SPID_COUNTERS
        self._wait_and_collect_counters(spid_counters, "BEFORE HANDOVER", gnb_id=self.bts_configuration.gnb_1_id)

    def spid_pm_counters_are_collected_for_target_gnb(self):
        spid_counters = NRG_SPID_COUNTERS_24R3 if self.sas_migration_2nd_step else NRG_SPID_COUNTERS
        self._wait_and_collect_counters(spid_counters, "AFTER HANDOVER", gnb_id=self.bts_configuration.gnb_2_id)

    def spid_pm_counters_are_collected_after_activation(self):
        spid_counters = NRG_SPID_COUNTERS_24R3 if self.sas_migration_2nd_step else NRG_SPID_COUNTERS
        self._wait_and_collect_counters(spid_counters, "FEATURE ACTIVATION")

    def plmn_pm_counters_are_collected_after_feature_deactivation(self):
        self._wait_and_collect_counters(PLMN_COUNTERS, "FEATURE DEACTIVATION")

    def spid_pm_counters_are_collected_for_dss_case(self):
        spid_counters = NRG_SPID_COUNTERS_24R3 if self.sas_migration_2nd_step else NRG_SPID_COUNTERS
        self._wait_and_collect_counters(spid_counters, "DL DSS CASE", gnb_id=self.bts_configuration.gnb_2_id)

    def pm_counters_are_collected_for_ul_dss_case(self):
        self._wait_and_collect_counters(UL_SANSA_SAS_PM_COUNTERS, "UL DSS CASE",
                                        gnb_id=self.bts_configuration.gnb_2_id)

    def source_gnb_pm_counters_are_collected_for_ul_handover_case(self):
        self._wait_and_collect_counters(UL_SANSA_SAS_PM_COUNTERS, "UL SAS BEFORE HANDOVER",
                                        gnb_id=self.bts_configuration.gnb_1_id)

    def target_gnb_pm_counters_are_collected_for_ul_handover_case(self):
        self._wait_and_collect_counters(UL_SANSA_SAS_PM_COUNTERS, "UL SAS AFTER HANDOVER",
                                        gnb_id=self.bts_configuration.gnb_2_id)

    def plmn_pm_counters_meets_quota_before_feature_activation(self):
        self._verify_plmn_counters()

    def spid_pm_counters_meets_quota_for_online_activation(self):
        self._verify_spid_counters_for_online_activation()

    def plmn_pm_counters_meets_quota_after_feature_deactivation(self):
        self._verify_plmn_counters()

    def spid_pm_counters_meets_quota_for_handover_on_source_gnb(self):
        self._verify_spid_counters(SOURCE_COMMON_PATH)

    def spid_pm_counters_meets_quota_for_handover_on_source_gnb_in_uplink(self):
        self._verify_uplink_spid_counters(SOURCE_COMMON_PATH)

    def spid_pm_counters_meets_quota_for_handover_on_target_gnb(self):
        self._verify_spid_counters(TARGET_COMMON_PATH)

    def spid_pm_counters_meets_quota_for_handover_on_target_gnb_in_uplink(self):
        self._verify_uplink_spid_counters(TARGET_COMMON_PATH)

    def spid_pm_counters_meets_quota(self):
        self._verify_spid_counters(DSS_COMMON_PATH)

    def uplink_spid_pm_counters_meets_quota(self):
        self._verify_uplink_spid_counters(DSS_COMMON_PATH)

    def _prepare_ues(self):
        try:
            self._check_all_ues_are_prepared()
        except AssertionError as not_prepared_ue_error:
            Logger.warning(f"{not_prepared_ue_error} - UEs will be restarted with adb and checked again")
            self._restart_all_ues()
            self._check_all_ues_are_prepared()

    def _restart_all_ues(self):
        Logger.info("Restarting all UEs with adb reboot")
        self._reboot_all_ues()

    def _reboot_all_ues(self):
        self.ue_nrg1.restart_ue()
        self.ue_nrg2.restart_ue()
        self.ue_nrg3.restart_ue()
        self.ue_nrg4.restart_ue()

    def _check_all_ues_are_prepared(self):
        self.ue_nrg1.prepare_ue()
        self.ue_nrg2.prepare_ue()
        self.ue_nrg3.prepare_ue()
        self.ue_nrg4.prepare_ue()

    def _attach_all_ues(self):
        self.ue_nrg1.attempt_to_attach_several_times()
        self.ue_nrg2.attempt_to_attach_several_times()
        self.ue_nrg3.attempt_to_attach_several_times()
        self.ue_nrg4.attempt_to_attach_several_times()

    def _start_tput_for_all_ues(self, transmission_time):
        self.ue_nrg1.start_tcp_downlink_data_transmission(duration=transmission_time, traffic_mb=100,
                                                          data_name=self.data_name.format(1))
        self.ue_nrg2.start_tcp_downlink_data_transmission(duration=transmission_time, traffic_mb=100,
                                                          data_name=self.data_name.format(2))
        self.ue_nrg3.start_tcp_downlink_data_transmission(duration=transmission_time, traffic_mb=100,
                                                          data_name=self.data_name.format(3))
        self.ue_nrg4.start_tcp_downlink_data_transmission(duration=transmission_time, traffic_mb=100,
                                                          data_name=self.data_name.format(4))

    def _start_ul_tput_for_all_ues(self, transmission_time):
        self.ue_nrg1.start_udp_uplink_data_transmission(duration=transmission_time, traffic_mb=100,
                                                        data_name=self.data_name.format(1))
        self.ue_nrg2.start_udp_uplink_data_transmission(duration=transmission_time, traffic_mb=100,
                                                        data_name=self.data_name.format(2))
        self.ue_nrg3.start_udp_uplink_data_transmission(duration=transmission_time, traffic_mb=100,
                                                        data_name=self.data_name.format(3))
        self.ue_nrg4.start_udp_uplink_data_transmission(duration=transmission_time, traffic_mb=100,
                                                        data_name=self.data_name.format(4))

    def _stop_traffic_on_all_ues(self):
        self.ue_nrg1.stop_downlink_transmission(data_name=self.data_name.format(1))
        self.ue_nrg2.stop_downlink_transmission(data_name=self.data_name.format(2))
        self.ue_nrg3.stop_downlink_transmission(data_name=self.data_name.format(3))
        self.ue_nrg4.stop_downlink_transmission(data_name=self.data_name.format(4))

    def _detach_ue_remove_traffic_files_and_cleanup_logs(self):
        self._detach_all_ues()
        self._try_to_get_and_remove_traffic_files()
        self.bts_configuration.collect_logs_if_the_test_fails()

    def _detach_all_ues(self):
        self.ue_nrg1.detach()
        self.ue_nrg2.detach()
        self.ue_nrg3.detach()
        self.ue_nrg4.detach()

    def _try_to_get_and_remove_traffic_files(self):
        self.ue_nrg1.try_to_get_and_remove_traffic_log_files()
        self.ue_nrg2.try_to_get_and_remove_traffic_log_files()
        self.ue_nrg3.try_to_get_and_remove_traffic_log_files()
        self.ue_nrg4.try_to_get_and_remove_traffic_log_files()

    def _prepare_counter_measurement(self, data_name='SPID_BASED_UL_UE'):
        self.bts_counters.wait_for_mimutes_before_next_pm_counter_period(minutes_before_pm_period=2)
        two_minutes_before_test_pm_period = 120
        one_minute_after_test_pm_period = 60
        transmission_time = two_minutes_before_test_pm_period + 3600 + one_minute_after_test_pm_period
        self.data_name = f"{data_name}_{{}}"
        return transmission_time

    def _wait_for_next_pm_counters_measurements(self, action):
        Logger.info(f"Waiting {PM_COLLECTION_SECONDS}sec for PM Counters to be generated by UEs throughput "
                    f"after *{action.upper()}* online reconfiguration")
        sleep(PM_COLLECTION_SECONDS)
        self.bts_counters.wait_for_new_pm_counters_measurement_interval_data()

    @staticmethod
    def _get_latest_pm_counters_period_epoch():
        latest_pm_counters_epoch = (BtsOs().get_epoch() - PM_COLLECTION_SECONDS) \
                                   // PM_COLLECTION_SECONDS * PM_COLLECTION_SECONDS
        Logger.info(f"Timestamp for PM Counters collecting: {datetime.fromtimestamp(latest_pm_counters_epoch)}"
                    f" Epoch: {latest_pm_counters_epoch}")
        return latest_pm_counters_epoch

    def _wait_and_collect_counters(self, counters, msg, gnb_id=0):
        self._wait_for_next_pm_counters_measurements(msg)
        self.active_raw_counters = self.bts_counters.get_raw_pm_counters(counters, gnb_id=gnb_id)
        self.counter_timestamp = self._get_latest_pm_counters_period_epoch()

    def _verify_plmn_counters(self):
        if self.sas_migration_first_step or self.sas_migration_2nd_step:
            self._check_plmn_after_migration_not_updated()
        else:
            plmn_counters = self._extract_plmn_counters()
            self._check_target_share_plmn(*plmn_counters)

    def _check_plmn_after_migration_not_updated(self):
        plmn_counters = self._extract_plmn_counters()
        Logger.info("Due to CB008828, NSA (per PLNM) counters should not be updated anymore")
        available_prbs, used_prbs_plmn_1, used_prbs_plmn_2 = plmn_counters
        if self.sas_migration_first_step:
            assert available_prbs > 0, "PRB_AVAIL_PDSCH_SLICES should be incremented in SBTS24R2"
        else:
            assert available_prbs == 0, "PRB_AVAIL_PDSCH_SLICES should not be incremented after SBTS24R3"
        assert not used_prbs_plmn_1 and not used_prbs_plmn_2, \
            "PRB_USED_PDSCH_NSA_PLMN should not be updated any longer"
        Logger.info(f"NSA (per PLNM) counters not be updated as expected for {Env.STREAM_SW} stream after migration")

    def _verify_spid_counters_for_online_activation(self):
        spid_counters = self._extract_spid_counters(SOURCE_COMMON_PATH)
        self._check_target_share_spid_for_online_activation(*spid_counters)

    def _verify_spid_counters(self, common_path):
        spid_counters = self._extract_spid_counters(common_path)
        self._check_target_share_spid_for_handover(*spid_counters)

    def _verify_uplink_spid_counters(self, common_path):
        spid_counters = self._extract_spid_counters(common_path, traffic_direction="UL")
        self._check_target_share_spid_for_handover(*spid_counters, traffic_direction="UL")

    def _extract_plmn_counters(self):
        available_prbs_path = f"{SOURCE_COMMON_PATH}/NCELA/{PRB_AVAIL_PDSCH_SLICES}"
        used_prbs_plmn1_path = f"{SOURCE_COMMON_PATH}/{self.plmns[0]}/NCUPL/{PRB_USED_PDSCH_NSA_PLMN}"
        used_prbs_plmn2_path = f"{SOURCE_COMMON_PATH}/{self.plmns[1]}/NCUPL/{PRB_USED_PDSCH_NSA_PLMN}"
        counters_path_to_check = [available_prbs_path, used_prbs_plmn1_path, used_prbs_plmn2_path]
        read_counters = []
        empty_pm = 0
        for pm_path in counters_path_to_check:
            try:
                read_counters.append(self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
                    raw_pm_data=self.active_raw_counters, path=pm_path, t_stamp=self.counter_timestamp))
            except AssertionError as assert_error:
                if self.sas_migration_2nd_step:
                    Logger.info(f"Counter: {pm_path} not exist as expected for full SAS migration done in SBTS24R3")
                    read_counters.append(empty_pm)
                else:
                    raise assert_error
        available_prbs, used_prbs_plmn_1, used_prbs_plmn_2 = read_counters
        return [available_prbs, used_prbs_plmn_1, used_prbs_plmn_2]

    def _extract_spid_counters(self, common_path, traffic_direction="DL"):
        if traffic_direction == "DL":
            avail_sas_counter = DL_PRB_AVAIL_SAS if self.sas_migration_2nd_step else PRB_AVAIL_PDSCH_SLICES
            used_data_counter = DL_PRB_USED_DATA_NRG
        else:
            avail_sas_counter = UL_PRB_AVAIL_SAS
            used_data_counter = UL_PRB_USED_DATA_NRG
        available_prbs_path = f"{common_path}/NCELA/{avail_sas_counter}"
        used_prbs_nrg1_path = f"{common_path}/NRRESOURCEGROUP-1/NCUPNRG/{used_data_counter}"
        used_prbs_nrg2_path = f"{common_path}/NRRESOURCEGROUP-2/NCUPNRG/{used_data_counter}"
        used_prbs_nrg3_path = f"{common_path}/NRRESOURCEGROUP-3/NCUPNRG/{used_data_counter}"
        used_prbs_nrg4_path = f"{common_path}/NRRESOURCEGROUP-4/NCUPNRG/{used_data_counter}"
        available_prbs = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.active_raw_counters, path=available_prbs_path, t_stamp=self.counter_timestamp)
        used_prbs_nrg_1 = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.active_raw_counters, path=used_prbs_nrg1_path, t_stamp=self.counter_timestamp)
        used_prbs_nrg_2 = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.active_raw_counters, path=used_prbs_nrg2_path, t_stamp=self.counter_timestamp)
        used_prbs_nrg_3 = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.active_raw_counters, path=used_prbs_nrg3_path, t_stamp=self.counter_timestamp)
        used_prbs_nrg_4 = self.bts_counters.extract_pm_counter_by_path_after_given_timestamp(
            raw_pm_data=self.active_raw_counters, path=used_prbs_nrg4_path, t_stamp=self.counter_timestamp)
        return [available_prbs, used_prbs_nrg_1, used_prbs_nrg_2, used_prbs_nrg_3, used_prbs_nrg_4]

    def _check_target_share_plmn(self, available_prbs, used_prbs_plmn_1, used_prbs_plmn_2):
        assert (1 - ((used_prbs_plmn_2+used_prbs_plmn_1)/available_prbs))*100 < 5.0, \
            f"Expected not used prbs less than 5%.\n" \
            f"Not used prbs are {(1 - ((used_prbs_plmn_1 + used_prbs_plmn_2) / available_prbs)) * 100:.2f}% " \
            f"of all throughput."
        self._check_target_share_for_single_plmn(used_prbs_plmn_1, available_prbs, plmn_id=1)
        self._check_target_share_for_single_plmn(used_prbs_plmn_2, available_prbs, plmn_id=2)

    def _check_target_share_spid_for_online_activation(self, available_prbs, used_prbs_nrg_1, used_prbs_nrg_2,
                                                       used_prbs_nrg_3, used_prbs_nrg_4):
        assert used_prbs_nrg_2 + used_prbs_nrg_4 < 10000, "traffic found on NRG which should not have any traffic."
        assert (1 - ((used_prbs_nrg_1 + used_prbs_nrg_3) / available_prbs)) * 100 < 5.0, \
            f"Expected not used prbs less than 5%.\n" \
            f"Not used prbs are {(1.0 - (used_prbs_nrg_1 + used_prbs_nrg_3) / available_prbs) * 100:.2f}% " \
            f"of all throughput."

        self._check_target_share_for_single_plmn(used_prbs_nrg_1, available_prbs, plmn_id=1)
        self._check_target_share_for_single_plmn(used_prbs_nrg_3, available_prbs, plmn_id=2)

    def _check_target_share_spid_for_handover(self, available_prbs, used_prbs_nrg_1, used_prbs_nrg_2,
                                              used_prbs_nrg_3, used_prbs_nrg_4, traffic_direction="DL"):
        used_prbs = (used_prbs_nrg_1 + used_prbs_nrg_2 + used_prbs_nrg_3 + used_prbs_nrg_4)
        accepted_deviation = 5.0 if traffic_direction == "DL" else 10.0
        assert (1 - (used_prbs / available_prbs)) * 100 < accepted_deviation, \
            f"Expected not used prbs more than {accepted_deviation}%.\n" \
            f"Not used prbs are {(1.0 - used_prbs / available_prbs) * 100:.2f}% " \
            f"of all throughput."
        Logger.info(f"Total share: {(used_prbs/available_prbs)*100:.2f}%")
        self._check_target_share_for_single_nrg(used_prbs_nrg_1, available_prbs, nrg_id=1)
        self._check_target_share_for_single_nrg(used_prbs_nrg_2, available_prbs, nrg_id=2)
        self._check_target_share_for_single_nrg(used_prbs_nrg_3, available_prbs, nrg_id=3)
        self._check_target_share_for_single_nrg(used_prbs_nrg_4, available_prbs, nrg_id=4)

    def _check_target_share_for_single_nrg(self, nrg_prbs, available_prbs, nrg_id):
        assert abs(nrg_prbs / available_prbs * 100 - self.nr_resource_groups[nrg_id-1].target_share) < 5.0, \
            f"Target shares not meet. Should be less than 5% off.\n" \
            f"Expected target share for nrg-{nrg_id}: {self.nr_resource_groups[nrg_id-1].target_share}%.\n" \
            f"Achieved target share for nrg-{nrg_id}: {nrg_prbs / available_prbs * 100:.2f}%."
        Logger.info(f"Achieved target share for NRG-{nrg_id}: {nrg_prbs / available_prbs * 100:.2f}% "
                    f"vs expected {self.nr_resource_groups[nrg_id-1].target_share}%")

    def _check_target_share_for_single_plmn(self, plmn_prbs, available_prbs, plmn_id):
        assert abs(plmn_prbs / available_prbs * 100 - self.plmns[plmn_id-1].target_share) < 5.0, \
            f"Target shares not meet. Should be less than 5% off.\n" \
            f"Expected target share for plmn-{plmn_id}: {self.plmns[plmn_id-1].target_share}%.\n" \
            f"Achieved target share for plmn-{plmn_id}: {plmn_prbs / available_prbs * 100:.2f}%."
        Logger.info(f"Achieved target share for PLMN-{plmn_id}: {plmn_prbs / available_prbs * 100:.2f}%")

    def _configure_plmn_list(self):
        plmn1 = Plmn(cell_id=self.cell_id, mcc=MCC1, mnc=MNC1, min_quota=10, max_quota=20, target_share=17.89)
        plmn2 = Plmn(cell_id=self.cell_id, mcc=MCC2, mnc=MNC2, min_quota=15, max_quota=100, target_share=82.11)
        self.plmns = [plmn1, plmn2]

    def _configure_nr_resource_group_list(self):
        nrresource_group1 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=1, min_quota=10, max_quota=20,
                                            target_share=12.11)
        nrresource_group2 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=2, min_quota=30, max_quota=50,
                                            target_share=34.21)
        nrresource_group3 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=3, min_quota=15, max_quota=100,
                                            target_share=32.89)
        nrresource_group4 = NRResourceGroup(cell_id=self.cell_id, resource_group_id=4, min_quota=5, max_quota=80,
                                            target_share=20.79)
        self.nr_resource_groups = [nrresource_group1, nrresource_group2, nrresource_group3, nrresource_group4]

    @property
    def sas_migration_first_step(self):
        return True if Env.ADMIN_CONNECT_STREAM == SAS_MIGRATION_FIRST_STEP_STREAM else False

    @property
    def sas_migration_2nd_step(self):
        return True if Env.STREAM_SW not in STREAMS_BEFORE_SAS_MIGRATION + [SAS_MIGRATION_FIRST_STEP_STREAM] else False
