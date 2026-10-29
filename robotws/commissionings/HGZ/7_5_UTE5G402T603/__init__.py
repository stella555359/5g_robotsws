__maintainer__ = 'Zhong Tingting'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [136],
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5,
    'cell_pci': 467,
    'arfcn': 645312,
    'scs': 30,  # optional, only Receiver 28A used
}

ue_mapping_2 = {
    'mobile_network_system': 'NR',
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [137],
    'ue_ul_layer': 2,
    'dl_iperf_process': 5,
    'ul_iperf_process': 5,
    'cell_pci': 468,
    'arfcn': 632064,
    'scs': 30,  # optional, only Receiver 28A used
}

mappings = [
    {
        'scf_name': 'SCF_SBTS*_3S-1CC-16D-8U-2CC-8D-8U.xml',
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS*_3S-1CC-NR-2CC-LTE.xml',
        'ue_mapping_list': [ue_mapping_1],
    },
    {
        'scf_name': 'SCF_SBTS*_3S-2CC-16D-8U.xml',
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    }
]
