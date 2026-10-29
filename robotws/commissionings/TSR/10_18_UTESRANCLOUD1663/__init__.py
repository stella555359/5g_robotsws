__maintainer__ = 'Wang Qingqing'
__team__ = '5G_PZ_HZ_8_SG'
__email__ = 'qingqing.1.wang@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 1,
    'ue_ul_layer': 2,
}

mappings = [
    {
        'scf_name': '*',
        'ue_mapping_list': [ue_mapping_1],
    }
]
