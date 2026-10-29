from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData
from testsuite.Wroclaw.SyVe.RRM.resources.SwDownloader import SwDownloader
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSw import BtsSw
from testsuite.Wroclaw.SyVe.RRM.resources.Ue import Ue
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import QUALCOMM_SDX65, ASKEY_AT_ADB
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.McsharkParser import McsharkParser
from testsuite.Wroclaw.SyVe.RRM.resources.PcapCollector import BipCollector

TPUT_VALUE = 175
DURATION = 60
TRAFFIC_MB = 100
BIP_MSGS_TO_VERIFY = ['uldata_puschreceivereq', 'dldata_pdschpayloadtbsendreql1sw',
                      'UlData_srsBmStruct_t.numSrsSymbols==1']


class Res14655(CommonSuite):

    def __init__(self):
        super(Res14655, self).__init__()
        self.feature = 'CB0014655'
        self.startup_manager = StartupManager()
        self.bts_config = BtsConfig()
        self.vmos = VmOs()
        self.env = TestEnvData()
        self.sw_downloader = SwDownloader()
        self.bts_sw = BtsSw()
        self.ue1 = Ue(QUALCOMM_SDX65, ue_id=1)
        self.ue2 = Ue(ASKEY_AT_ADB, ue_id=2)
        self.tshark = McsharkParser()
        self.bip_collector = BipCollector()
        self.bip_pcap = ''

    def prepare_environment(self):
        self.make_sure_mcshark_plugin_exists()
        self.perform_ru_sw_update()

    def testline_is_commissioned_and_on_air(self):
        self._perform_full_commisioning()
        self.startup_manager.wait_for_all_configured_radios_appeared()
        self.startup_manager.wait_for_all_cells_on_air()

    def perform_ru_sw_update(self):
        self.bts_sw.software_update(self.sw_downloader.download_specific_software_version(
            self.sw_downloader.get_the_latest_trunk_build()), independent_sw_update_type='RuSwOnly')
        self.startup_manager.wait_for_all_cells_on_air()

    def ues_are_attached(self):
        self.ue1.prepare_ue()
        self.ue2.prepare_ue()
        self.ue1.attach()
        self.ue2.attach()

    def ues_traffic_is_started(self):
        self.ue1.start_tcp_downlink_data_transmission(duration=DURATION, traffic_mb=TRAFFIC_MB, data_name='DL_UE1')
        self.ue1.start_tcp_uplink_data_transmission(duration=DURATION, traffic_mb=TRAFFIC_MB, data_name='UL_UE1')
        self.ue2.start_tcp_downlink_data_transmission(duration=DURATION, traffic_mb=TRAFFIC_MB, data_name='DL_UE2')
        self.ue2.start_tcp_uplink_data_transmission(duration=DURATION, traffic_mb=TRAFFIC_MB, data_name='UL_UE2')

    def ues_traffic_is_stopped(self):
        self.ue1.stop_downlink_transmission(data_name='DL_UE1')
        self.ue1.stop_uplink_transmission(data_name='UL_UE1')
        self.ue2.stop_downlink_transmission(data_name='DL_UE2')
        self.ue2.stop_uplink_transmission(data_name='UL_UE2')

    def bip_collection_is_started(self):
        self.bip_collector.start_bip_trace_on_gnb()

    def bip_collection_is_stopped(self):
        self.bip_pcap = self.bip_collector.stop_and_download_bip_trace_on_gnb()[0]

    def required_mesgs_are_collected_in_bip_pcap(self):
        rntis = self._get_rnti_values()
        for rnti in rntis:
            self._verify_required_bip_mesgs_for_rnti(rnti)

    def _get_rnti_values(self):
        self.tshark.convert_pcap_file_with_filter_using_mcshark_and_get_field_values(self.bip_pcap, '3gpp.rnti')
        rnti_values = list(set(self.tshark.tshark_output))
        return [rnti for rnti in rnti_values if rnti != '65535' and ',' not in rnti]

    def _verify_required_bip_mesgs_for_rnti(self, rnti):
        Logger.info(f"Verifying BIP mesgs for rnti: {rnti}")
        for mesg in BIP_MSGS_TO_VERIFY:
            self.tshark.convert_pcap_file_with_filter_using_mcshark(self.bip_pcap, f'3gpp.rnti=={rnti}&&{mesg}')
            assert len(self.tshark.tshark_output) > 0, f"{mesg} not found!"

    def _perform_full_commisioning(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'initial')
        self.bts_config.perform_full_commissioning(scf_file)
