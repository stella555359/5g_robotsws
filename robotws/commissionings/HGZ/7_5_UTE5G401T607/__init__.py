__maintainer__ = 'Li Jie'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'jie.2.li@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'BOTH',
    'cell_id_list': [1],
    'ue_ul_layer': 2,
    'ul_iperf_process': 5
}


mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
