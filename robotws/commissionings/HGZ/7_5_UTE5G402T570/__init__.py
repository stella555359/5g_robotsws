__maintainer__ = 'Shi Gaofan'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'gaofan.shi@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'ue_ul_layer': 2,
    'cell_id_list': [1],
    'peak_percent': 0.5    # optional, tput will be peak * peak_percent
}

ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'ue_ul_layer': 2,
    'cell_id_list': [2],
    'peak_percent': 0.5    # optional, tput will be peak * peak_percent
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    }
]
