__maintainer__ = 'Shi Zhihao'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'zhihao.shi@nokia-sbell.com'

__all__ = ['mappings', 'iperf_type', 'ui_version']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'cell_id_list': [3],
    'cell_pci': 82,
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]

iperf_type = 'via_app'
ui_version = 'S21UI5.1'
