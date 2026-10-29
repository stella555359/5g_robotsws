__maintainer__ = 'Lan Shifu'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'shifu.lan@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [141],    # N78 80MHz
    'cell_pci': 418,
    'arfcn': 633408,
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

ue_mapping_2 = {
    'mobile_network_system': 'NR',
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [142],    # N38 20MHz
    'cell_pci': 419,
    'arfcn': 516970,
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

ue_mapping_3 = {
    'mobile_network_system': 'NR',
    'ue_index': 2,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [143],    # N78 80MHz
    'cell_pci': 420,
    'arfcn': 640128,
    'scs': 30,  # optional, only Receiver 28A/28B/29B used
    'ue_ul_layer': 2,
    'dl_iperf_process': 5
}

ue_mapping_4 = {
    'mobile_network_system': 'NR',
    'ue_index': 3,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [144],    # N38 20MHz
    'cell_pci': 421,
    'arfcn': 520850,
    'scs': 30,  # optional, only Receiver 28A/28B/29B used
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

ue_mapping_5 = {
    'mobile_network_system': 'NR',
    'ue_index': 3,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [144],    # N38 10MHz
    'cell_pci': 421,
    'arfcn': 521090,
    'scs': 30,  # optional, only Receiver 28A/28B/29B used
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

mappings = [
    {
        'scf_name': 'SCF_SBTS*_1S-4CC-72E-10M.xml',  # * means all scf common, 10MHz need use different arfcn
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2, ue_mapping_5],
    },
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2, ue_mapping_4],
    }
]
