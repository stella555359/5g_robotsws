__maintainer__ = 'Zhong Tingting'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [142],
    'cell_pci': 484,
    'arfcn': 631680,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

ue_mapping_2 = {
    'mobile_network_system': 'NR',
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [143],
    'cell_pci': 485,
    'arfcn': 639648,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5
}

mappings = [
    {
        'scf_name': 'SCF_SBTS*_1S-1CC-8D-4U.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    },
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    }
]
