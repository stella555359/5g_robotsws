__maintainer__ = 'Liu Shasha'
__team__ = 'RAN_PZ_HAZ4_SG05'
__email__ = 'shasha.liu@nokia-sbell.com'

__all__ = ['mappings', 'ui_version']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'NSA',
    'cell_id_list': [1],
}

ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'network_type': 'NSA',
    'cell_id_list': [1],
    'ue_ul_layer': 1,
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_1S-1CC-8D4U_A8_60M_B4-156_2089-41.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    }
]

ui_version = 'S21UI3.1'
