__maintainer__ = 'Shi Zhihao'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'zhihao.shi@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,
    'network_type': 'SA',
    'cell_id_list': [1],
    'cell_pci': 320,
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

ue_mapping_2 = {
    'ue_index': 1,
    'network_type': 'SA',
    'cell_id_list': [20],
    'cell_pci': 20,
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

ue_mapping_3 = {
    'ue_index': 2,
    'network_type': 'SA',
    'cell_id_list': [40],
    'cell_pci': 40,
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2, ue_mapping_3],
    }
]
