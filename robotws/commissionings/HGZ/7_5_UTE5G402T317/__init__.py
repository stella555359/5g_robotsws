__maintainer__ = 'Fan Kaihui'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'kaihui.fan@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1],
    'ue_ul_layer': 2    # now all ue ue_ul_layer should be same
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
