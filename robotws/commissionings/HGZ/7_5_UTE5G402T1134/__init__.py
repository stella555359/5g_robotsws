__maintainer__ = 'Lin jiangjing'
__team__ = '5G_PZ_HZ_8_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'ue_ul_layer': 2,
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
