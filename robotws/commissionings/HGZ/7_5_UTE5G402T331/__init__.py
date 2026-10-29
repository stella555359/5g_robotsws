__maintainer__ = 'Deng xueqin'
__team__ = '5G_PZ_MMW_HZ_2_SG'
__email__ = 'xueqin.deng@nokia-sbell.com'

__all__ = ['mappings', 'iperf_type']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'NSA',
    'cell_id_list': [1, 2, 3, 4]
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
iperf_type = 'via_command'
