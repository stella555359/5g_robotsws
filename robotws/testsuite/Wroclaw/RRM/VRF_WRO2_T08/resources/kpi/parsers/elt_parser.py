import json
from collections import defaultdict

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.averager import Averager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger


class ELTParser(object):
    def __init__(self):
        self._stats = Averager()
        self._log = None

    def reset(self):
        self._stats = Averager()
        self._log = None

    def analyze_log(self, logfile):
        self._load_log(logfile)
        parsers = self._get_msg_parsers()
        for msg in self._log:
            try:
                parsers[msg['name']](msg['data'])
            except KeyError as e:
                logger.info(f"Encountered error in decoding message {msg['name']}: {str(e)}", also_to_console=True)
        return self._stats

    def _load_log(self, logfile):
        with open(logfile, 'r') as f:
            self._log = json.load(f)

    def _get_msg_parsers(self):
        parsers = defaultdict(lambda: lambda msg: None)
        parsers['NL1_DCI_Information'] = self._parse_dci
        parsers['NL1_CSI_Report'] = self._parse_csi_report
        parsers['NL1_Serving_Cell_Measurement'] = self._parse_cell_measurements
        parsers['NL1_PUSCH_Power_Control'] = self._parse_pusch_power_control
        parsers['NL2_MAC_Throughput_UL'] = self._parse_ul_mac_tput
        parsers['NL2_MAC_Throughput_DL'] = self._parse_dl_mac_tput
        parsers['NL1_MIMO_PDSCH_Throughput'] = self._parse_pdsch_tput
        parsers['NL1_UL_Throughput'] = self._parse_ul_bler
        parsers['NL1_Sync_SSB_Measurement'] = self._parse_sync_ssb
        parsers['NL1_Serving_Cell_RSSI'] = self._parse_cell_rssi
        parsers['EL2_IP_Throughput_DL'] = self._parse_ip_tput_dl
        parsers['EL2_IP_Throughput_UL'] = self._parse_ip_tput_ul
        parsers['NL2_RLC_Throughput_DL'] = self._parse_rlc_tput_dl
        parsers['NL2_RLC_Throughput_UL'] = self._parse_rlc_tput_ul
        parsers['NL2_PDCP_Throughput_DL'] = self._parse_pdcp_tput_dl
        parsers['NL2_PDCP_Throughput_UL'] = self._parse_pdcp_tput_ul
        return parsers

    def _parse_dci(self, msg):
        dci_data = msg['DCI Info']
        for dci in dci_data:
            dl_data = dci['DL DCI Info']
            if dl_data['DL DCI valid'] == 1:
                dl_stats = {'dl_mcs_all': dl_data['MCS index 1'], 'dl_prb': dl_data['NUM RB'],
                            'dl_rank': dl_data['Num of layers']}
                if int(dl_data['MCS index 1']) > 28:
                    dl_stats['dl_mcs_29-31'] = dl_data['MCS index 1']
                else:
                    dl_stats['dl_mcs'] = dl_data['MCS index 1']
                self._stats.update(dl_stats)

            ul_data = dci['UL DCI Info']
            if ul_data['UL Grant Valid'] == 1:
                ul_stats = {'ul_mcs_all': ul_data['MCS index'], 'ul_prb': ul_data['NUM RB'],
                            'ul_rank': ul_data['Number of layers']}
                if int(ul_data['MCS index']) > 28:
                    ul_stats['ul_mcs_29-31'] = ul_data['MCS index']
                else:
                    ul_stats['ul_mcs'] = ul_data['MCS index']
                self._stats.update(ul_stats)

    def _parse_csi_report(self, msg):
        csi_data = msg['Csi Records']
        for record in csi_data:
            if record['WB CQI0 Valid'] == 1:
                self._stats.update(cqi=record['WB CQI0 Value'])

    def _parse_cell_measurements(self, msg):
        cell_data = msg['Serving Cell SSS Measurement Records']
        for record in cell_data:
            self._stats.update(rsrp=record['RSRP'], rsrq=record['RSRQ'], rssi=record['RSSI'], sinr=record['SINR'])

    def _parse_pusch_power_control(self, msg):
        power_data = msg['Pusch Power Control Records']
        for record in power_data:
            self._stats.update(pathloss=record['Path Loss'], mtpl=record['Transmitted Power'])

    def _parse_ul_mac_tput(self, msg):
        throughput = msg['NMAC Throughput UL'] / 1000000.0
        self._stats.update(ul_tput=throughput)

    def _parse_dl_mac_tput(self, msg):
        throughput = msg['NMAC Throughput DL'] / 1000000.0
        self._stats.update(dl_tput=throughput)

    def _parse_pdsch_tput(self, msg):
        self._stats.update(dl_bler=msg['DL BLER'], dl_ibler=msg['DL iBLER'])

    def _parse_ul_bler(self, msg):
        self._stats.update(ul_bler=msg['UL BLER'], ul_ibler=msg['UL iBLER'])

    def _parse_sync_ssb(self, msg):
        ssb_sync_data = msg['Sync SSB Measurement records']
        for record in ssb_sync_data:
            per_antenna = {'rx1_rsrp': record.get('Sync SSB RSRP RX0', None),
                           'rx2_rsrp': record.get('Sync SSB RSRP RX1', None),
                           'rx3_rsrp': record.get('Sync SSB RSRP RX2', None),
                           'rx4_rsrp': record.get('Sync SSB RSRP RX3', None),
                           'rx1_sinr': record.get('Sync SSB SNR RX0', None),
                           'rx2_sinr': record.get('Sync SSB SNR RX1', None),
                           'rx3_sinr': record.get('Sync SSB SNR RX2', None),
                           'rx4_sinr': record.get('Sync SSB SNR RX3', None)}
            self._stats.update(params={k: v for k, v in per_antenna.items() if v is not None})

    def _parse_cell_rssi(self, msg):
        per_antenna = {'rx1_rssi': msg.get('RSSI RX0', None), 'rx2_rssi': msg.get('RSSI RX1', None),
                       'rx3_rssi': msg.get('RSSI RX2', None), 'rx4_rssi': msg.get('RSSI RX3', None)}
        self._stats.update(params={k: v for k, v in per_antenna.items() if v is not None})

    def _parse_ip_tput_dl(self, msg):
        throughput = msg['IP Throughput DL'] / 1000000.0
        self._stats.update(dl_ip_tput=throughput)

    def _parse_ip_tput_ul(self, msg):
        throughput = msg['IP Throughput UL'] / 1000000.0
        self._stats.update(ul_ip_tput=throughput)

    def _parse_rlc_tput_dl(self, msg):
        throughput = msg['RLC Throughput DL'] / 1000000.0
        self._stats.update(dl_rlc_tput=throughput)

    def _parse_rlc_tput_ul(self, msg):
        throughput = msg['RLC Throughput UL'] / 1000000.0
        self._stats.update(ul_rlc_tput=throughput)

    def _parse_pdcp_tput_dl(self, msg):
        throughput = msg['PDCP Throughput DL'] / 1000000.0
        self._stats.update(dl_pdcp_tput=throughput)

    def _parse_pdcp_tput_ul(self, msg):
        throughput = msg['PDCP Throughput UL'] / 1000000.0
        self._stats.update(ul_pdcp_tput=throughput)
