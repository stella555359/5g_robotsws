from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_verification.pcap_reader import \
    load_pcap
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.averager import Averager

short_to_full_lookup = {
    "dl_mcs": "DlData_PdschGrant.mcs",
    "dl_prb": "DlData_PdschGrant.numOfPrb",
    "dl_rank": "DlData_PdschGrant.numOfLayers",
    "pusch_sinr": "UlData_UePuschReceiveRespPs_t.sinr_item",
    "rssi": "UlData_UePuschReceiveRespPs_t.rssi",
    "pucch_sinr": "UlData_pucchReceiveRespPsPucchResource_t.sinr_item",
    "ul_mcs": "UlData_puschReceiveReqGrant_t.mcs",
    "ul_prb": "UlData_puschReceiveReqGrant_t.numOfPrb",
    "ul_rank": "UlData_puschReceiveReqGrant_t.numOfLayers",
}

update_25r3 = {
    "dl_mcs": "DlData_PdschGrantL1sw.mcs",
    "dl_prb": "DlData_PdschGrantL1sw.numOfPrb",
    "dl_rank": "DlData_PdschGrantL1sw.numOfLayers",
    "pucch_sinr": "UlData_pucchReceiveRespPsPucchResourceL1sw_t.sinr_item",
}


class BipParser:
    def __init__(self):
        self._log = None
        self._tshark_output = "/tmp/tshark_output_bip.json"
        self._tshark_filter = []
        self._stats = Averager()
        self.sw_branch = "25r2"
        self.full_to_short_lookup = {full: short for short, full in short_to_full_lookup.items()}

    def reset(self):
        self._stats = Averager()
        self._tshark_filter = []
        self._log = None

    def analyze_log(self, logfile, stat_names):
        self._determine_tshark_filter(stat_names=stat_names)
        json_content = load_pcap(logfile, tshark_fields=self._tshark_filter, output_json_file=self._tshark_output)
        self._get_stats_from_bip(json_content)
        return self._stats

    def _determine_tshark_filter(self, stat_names):
        lookup_table = short_to_full_lookup.copy()
        if self.sw_branch.lower() == "sbts00" or self.sw_branch.lower() >= "sbts25r3":
            lookup_table.update(update_25r3)
            self.full_to_short_lookup = {full: short for short, full in short_to_full_lookup.items()}
        self._tshark_filter = [lookup_table[name] for name in stat_names]

    def _get_stats_from_bip(self, json_content):
        for msg in json_content:
            msg = msg["_source"]["layers"]
            params = {}
            for stat_fullname, stat_value in msg.items():
                if isinstance(stat_value, list):
                    stat_value = stat_value[0]
                params.update({self.full_to_short_lookup[stat_fullname]: float(stat_value)})
            self._stats.update(params=params)
