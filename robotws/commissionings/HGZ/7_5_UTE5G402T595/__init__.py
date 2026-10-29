__maintainer__ = 'Lan Shifu'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'shifu.lan@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [141],
    'cell_pci': 454,
    'arfcn': 641376,
    'scs': 30,  # optional, only Receiver 28A used
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

ue_mapping_2 = {
    'mobile_network_system': 'NR',
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [142],
    'cell_pci': 455,
    'arfcn': 509070,
    'scs': 30,  # optional, only Receiver 28A used
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

ue_mapping_3 = {
    'mobile_network_system': 'NR',
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [142],    # N41 10MHz
    'cell_pci': 455,
    'arfcn': 509310,
    'scs': 30,  # optional, only Receiver 28A used
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

mappings = [
    {
        'scf_name': 'SCF_SBTS*_1S-4CC-72E-10M.xml',  # * means all scf common, 10MHz need use different arfcn
        'ue_mapping_list': [ue_mapping_1, ue_mapping_3],
    },
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    }
]
