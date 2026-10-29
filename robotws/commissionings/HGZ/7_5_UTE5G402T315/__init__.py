__maintainer__ = 'Lan Shifu'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'shifu.lan@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'NSA',
    'cell_id_list': [1],
    'ue_ul_layer': 1,
    'cell_pci': 103,
    'ul_iperf_process': 5,
    'dl_iperf_process': 5
}

ue_mapping_2 = {
    'peak_percent': 0.20,  # optional, tput will be peak * peak_percent
    'mobile_network_system': 'NR',
    'ue_index': 1,  # ue index in TL
    'network_type': 'NSA',
    'cell_id_list': [2],
    'cell_pci': 52
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    }
]
