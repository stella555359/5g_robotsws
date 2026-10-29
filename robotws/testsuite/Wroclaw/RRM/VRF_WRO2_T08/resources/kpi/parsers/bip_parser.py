from .pcap_parser import PCAPParser


class BIPParser(PCAPParser):
    short_to_full_lookup = {
        'dl_mcs': 'DlData_PdschGrant.mcs',
        'dl_prb': 'DlData_PdschGrant.numOfPrb',
        'dl_rank': 'DlData_PdschGrant.numOfLayers',
        'pusch_sinr': 'UlData_UePuschReceiveRespPs_t.sinr_item',
        'rssi': 'UlData_UePuschReceiveRespPs_t.rssi',
        'pucch_sinr': 'UlData_pucchReceiveRespPsPucchResource_t.sinr_item',
        'ul_mcs': 'UlData_puschReceiveReqGrant_t.mcs',
        'ul_prb': 'UlData_puschReceiveReqGrant_t.numOfPrb',
        'ul_rank': 'UlData_puschReceiveReqGrant_t.numOfLayers'
    }
