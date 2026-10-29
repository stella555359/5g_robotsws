__maintainer__ = 'Shi Zhihao'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'zhihao.shi@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [3],
    'dl_iperf_process': 1,
    'ul_iperf_process': 5,
    'ue_ul_layer': 2,   # now all ue ue_ul_layer should be same
    'cell_pci': 599,
    'arfcn': 644736,
    'scs': 30,
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
