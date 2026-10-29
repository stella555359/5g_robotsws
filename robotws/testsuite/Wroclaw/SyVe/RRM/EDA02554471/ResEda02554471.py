from testsuite.Wroclaw.SyVe.RRM.features.Res705And8806 import *

TAC_ENTRY = 'tAC: 7152 (0x001bf0)'


class ResEda02554471(object):

    def __init__(self):
        self.feature = "EDA02554471"
        self.source_gnb_id = 1
        self.bts_config = BtsConfig()
        self.env_data = TestEnvData()

    def commissioned_source_gnb_with_adj_nrplmnset_sa(self):
        self.bts_config.perform_delta_commissioning(ScfPathFinder().
                                                    get_delta_path_for_feature(self.feature, "adjnrplmnset_src"),
                                                    gnb_id=self.source_gnb_id)
        self.bts_config.perform_delta_commissioning(ScfPathFinder().
                                                    get_delta_path_for_feature(self.feature, "adjnrplmnset_tgt"))

    def tac_entry_is_stored_in_pcap_from_source(self):
        pcap_src_file = VmOs.join_path_elements(self.env_data.test_log_dir, "ho_src.pcap")
        tshark_parser = TSharkParser()
        tshark_parser.convert_pcap_file_with_filter_using_mcshark(pcap_src_file, NGAP_PROTOCOL)
        pcap_from_source = [item.strip(' ') for item in tshark_parser.tshark_output]
        assert TAC_ENTRY in pcap_from_source, PCAP_UNSUCCESSFUL_MSG
