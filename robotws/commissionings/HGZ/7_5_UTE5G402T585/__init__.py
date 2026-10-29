__maintainer__ = 'Shi Zhihao'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'zhihao.shi@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_2 = {
    'ue_index': 1,  # PCI:85  NR-ARFCN:629952
    'network_type': 'SA',
    'cell_id_list': [2],
    'ue_ul_layer': 2,
    'cell_pci': 85,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

ue_mapping_1 = {
    'ue_index': 0,  # PCI:86  NR-ARFCN:636576
    'network_type': 'SA',
    'cell_id_list': [1],
    'ue_ul_layer': 2,
    'cell_pci': 86,
    'arfcn': 636000,
    'scs': 30,  # optional, only Receiver 28A used
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    }
]
