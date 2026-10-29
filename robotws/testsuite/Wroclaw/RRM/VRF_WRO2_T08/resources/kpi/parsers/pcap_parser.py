from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_verification.pcap_reader import load_pcap
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.averager import Averager


class PCAPParser:
    short_to_full_lookup = {}

    def __init__(self):
        self._log = None
        self._tshark_output = "/tmp/tshark_output_bip.json"
        self._tshark_filter = []
        self._stats = Averager()

    def reset(self):
        self._stats = Averager()
        self._tshark_filter = []
        self._log = None

    def parse(self, logfile, stat_names):
        self._determine_tshark_filter(stat_names=stat_names)
        json_content = load_pcap(logfile, tshark_fields=self._tshark_filter, output_json_file=self._tshark_output)
        self._get_stats_from_pcap(json_content)
        return self._stats

    def _determine_tshark_filter(self, stat_names):
        self._tshark_filter = [self.short_to_full_lookup[name] for name in stat_names]

    def _get_stats_from_pcap(self, json_content):
        full_to_short_lookup = {self.short_to_full_lookup[key]: key for key in self.short_to_full_lookup}
        for msg in json_content:
            msg = msg['_source']['layers']
            params = {}
            for stat_fullname, stat_value in msg.items():
                if isinstance(stat_value, list):
                    stat_value = stat_value[0]
                try:
                    stat_value = float(stat_value)
                except ValueError:
                    stat_value = int(stat_value, 16)
                params.update({full_to_short_lookup[stat_fullname]: stat_value})
            self._stats.update(params=params)
