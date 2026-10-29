class PdcpCounters:
    def __init__(self):
        self.DL_SDU_TX_NSA_QOS_GRP = [
            'M55319C01001',
            'M55319C01002',
            'M55319C01003',
            'M55319C01004',
            'M55319C01005',
            'M55319C01006',
            'M55319C01007',
            'M55319C01008',
            'M55319C01009',
            'M55319C01010',
            'M55319C01011',
            'M55319C01012',
            'M55319C01013',
            'M55319C01014',
            'M55319C01015',
            'M55319C01016',
            'M55319C01017',
            'M55319C01018',
            'M55319C01019',
            'M55319C01020'
        ]

        self.DL_VOL_TX_NSA_QOS_GRP = [
            'M55319C02001',
            'M55319C02002',
            'M55319C02003',
            'M55319C02004',
            'M55319C02005',
            'M55319C02006',
            'M55319C02007',
            'M55319C02008',
            'M55319C02009',
            'M55319C02010',
            'M55319C02011',
            'M55319C02012',
            'M55319C02013',
            'M55319C02014',
            'M55319C02015',
            'M55319C02016',
            'M55319C02017',
            'M55319C02018',
            'M55319C02019',
            'M55319C02020'
        ]

    def calculate_nsa_udp_dl_tput_from_pdcp_sdu(self, counter_values, tput_duration, udp_packet_size=1462):
        return round(((((sum(counter_values) * udp_packet_size) / tput_duration) * 8) / 1000) / 1000, 1)

    def calculate_nsa_tcp_dl_tput_from_pdcp_sdu(self, counter_values, tput_duration, tcp_packet_size=1367):
        return round(((((sum(counter_values) * tcp_packet_size) / tput_duration) * 8) / 1000) / 1000, 1)

    def calculate_nsa_dl_tput_from_pdcp_volume(self, counter_values, tput_duration):
        return round((((sum(counter_values) / tput_duration) * 8) / 1000), 1)

    def get_packet_size(self, pdcp_vol_counters_values, pdcp_sdu_counters_values):
        packet_size = 1000 * (float(sum(pdcp_vol_counters_values)) / float(sum(pdcp_sdu_counters_values)))
        return packet_size
