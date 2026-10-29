__maintainer__ = 'Zhong Tingting'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings', 'iperf_type']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [301]
}

ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [301]
}

ue_mapping_3 = {
    'ue_index': 2,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [21]
}

ue_mapping_4 = {
    'ue_index': 3,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [11]
}

ue_mapping_5 = {
    'ue_index': 4,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [501]
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2, ue_mapping_3, ue_mapping_4, ue_mapping_5],
    },
]

iperf_type = 'via_command'
