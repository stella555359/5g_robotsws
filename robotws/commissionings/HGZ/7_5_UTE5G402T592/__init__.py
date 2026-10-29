__maintainer__ = 'Shi Zhihao'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'zhihao.shi@nokia-sbell.com'

__all__ = ['mappings']

# ue_mapping_1 = {
#    'ue_index': 0,  # PCI:92  NR-ARFCN:629952
#    'network_type': 'SA',
#    'cell_id_list': [1],
#    'ue_ul_layer': 2,
# }
#
ue_mapping_1 = {
    'ue_index': 0,  # PCI:93  NR-ARFCN:636576
    'network_type': 'SA',
    'cell_id_list': [1],
    'ue_ul_layer': 2,
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
