__maintainer__ = 'Zhong Tingting'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'ue_ul_layer': 2,
    'ul_iperf_process': 5,
    'dl_iperf_process': 5,
    'cell_id_list': [1],
    'cell_pci': 572,
    'arfcn': 633408,
    'scs': 30,  # optional, only Receiver 28A used
}

ue_mapping_2 = {
    'mobile_network_system': 'NR',
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'ue_ul_layer': 2,
    'ul_iperf_process': 5,
    'dl_iperf_process': 5,
    'cell_id_list': [2],
    'cell_pci': 573,
    'arfcn': 646656,
    'scs': 30,  # optional, only Receiver 28A used
}

ue_mapping_3 = {
    'mobile_network_system': 'NR',
    'ue_index': 2,  # ue index in TL
    'network_type': 'SA',
    'ue_ul_layer': 2,
    'ul_iperf_process': 5,
    'dl_iperf_process': 5,
    'cell_id_list': [3],
    'cell_pci': 574,
    'arfcn': 624000,
    'scs': 30,  # optional, only Receiver 28A used
}

ue_mapping_4 = {
    'mobile_network_system': 'NR',
    'ue_index': 3,  # ue index in TL
    'network_type': 'SA',
    'ue_ul_layer': 2,
    'ul_iperf_process': 5,
    'dl_iperf_process': 5,
    'cell_id_list': [4],
    'cell_pci': 575,
    'arfcn': 639936,
    'scs': 30,  # optional, only Receiver 28A used
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2, ue_mapping_3, ue_mapping_4],
    }
]
