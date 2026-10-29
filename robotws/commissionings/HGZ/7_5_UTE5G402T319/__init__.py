__maintainer__ = 'Shi Zhihao'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'zhihao.shi@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [143],
    'cell_pci': 490,
    'arfcn': 630624,
    'scs': 30,  # optional, only Receiver 28A used
    'dl_iperf_process': 5,
    'ul_iperf_process': 5,
    'ue_ul_layer': 2    # now all ue ue_ul_layer should be same
}

ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [144],
    'cell_pci': 491,
    'arfcn': 637248,
    'scs': 30,  # optional, only Receiver 28A used
    'dl_iperf_process': 5,
    'ul_iperf_process': 5,
    'ue_ul_layer': 2    # now all ue ue_ul_layer should be same
}

mappings = [
    {
        'scf_name': 'SCF_SBTS*_1S-1CC-8D-4U_CHT.xml',
        'ue_mapping_list': [ue_mapping_1],
    },
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    }
]
