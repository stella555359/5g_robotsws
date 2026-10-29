__maintainer__ = 'Shi Zhihao'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'zhihao.shi@nokia-sbell.com'

__all__ = ['mappings', 'iperf_type']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'NSA',
    'ul_iperf_process': 5,
    'dl_iperf_process': 5,
    'cell_id_list': [1],
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]

iperf_type = 'via_command'
ui_version = 'S21UI3.1'
