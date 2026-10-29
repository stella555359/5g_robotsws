__maintainer__ = 'Quan qingjun'
__team__ = '5G_PZ_HZ_4_SG8'
__email__ = 'qingjun.quan@nokia-sbell.com'

__all__ = ['mappings', 'iperf_type']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'ue_ul_layer': 1,
}

ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'ue_ul_layer': 1,
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    }
]

iperf_type = 'via_app'
