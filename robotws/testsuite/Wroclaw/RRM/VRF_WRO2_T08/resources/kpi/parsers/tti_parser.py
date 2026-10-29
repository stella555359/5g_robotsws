from .pcap_parser import PCAPParser


class TTIParser(PCAPParser):
    short_to_full_lookup = {
        'ul_mcs': 'itf_L2Log_Du_Ps_Events_UlFdSchedData_UlFdSchedData_t.rrmUlProposedMcs',
        'dl_mcs': 'itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.rrmDlUsedMcs',
        'ul_bler': 'itf_L2Log_Du_Ps_Events_UlHarqRxData_UlHarqRxData_t.crcResult',
        'dl_bler': 'itf_L2Log_Du_Ps_Events_DlHarqRxDataWithoutHeader_DlHarqRxDataWithoutHeader_t.ackNack',
        'ul_pdcch_beam_id': 'itf_L2Log_Du_Ps_Events_UlFdSchedData_UlFdSchedData_t.pdcchBeamId',
        'dl_pdcch_beam_id': 'itf_L2Log_Du_Ps_Events_DlFdSchedData_DlFdSchedData_t.pdcchBeamId'
    }
