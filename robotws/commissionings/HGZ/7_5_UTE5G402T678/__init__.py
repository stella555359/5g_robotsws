__maintainer__ = 'Miranda Zhong'
__team__ = '5G_PZ_HZ_5_SG'
__email__ = 'miranda.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1]
}


mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
