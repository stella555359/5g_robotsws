__maintainer__ = 'Mao Cathy'
__team__ = '5G_PZ_HZ_3_SG'
__email__ = 'cathy.mao@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1],
    'ue_ul_layer': 2,
    'cell_pci': 161,
}


mappings = [
    {
        'scf_name': '*',
        'ue_mapping_list': [ue_mapping_1],
    }
]
