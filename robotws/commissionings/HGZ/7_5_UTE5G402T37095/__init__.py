__maintainer__ = 'Shi Zhihao'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'zhihao.shi@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [5],
    'dl_iperf_process': 5,
    'ul_iperf_process': 5,
    'ue_ul_layer': 2,
    'cell_pci': 496,
    'arfcn': 630624,
    'scs': 30,  # optional, only Receiver 28A used
}

ue_mapping_2 = {
    'mobile_network_system': 'NR',
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [6],
    'dl_iperf_process': 5,
    'ul_iperf_process': 5,
    'ue_ul_layer': 2,
    'cell_pci': 497,
    'arfcn': 637248,
    'scs': 30,  # optional, only Receiver 28A used
}

ue_mapping_3 = {
    'mobile_network_system': 'LTE',
    'ue_index': 2,  # ue index in TL
    'cell_id_list': [1],
    'cell_pci': 94,
}

ue_mapping_4 = {
    'mobile_network_system': 'LTE',
    'ue_index': 2,  # ue index in TL
    'cell_id_list': [0],
    'cell_pci': 94,
}

ue_mapping_5 = {
    'mobile_network_system': 'LTE',
    'ue_index': 2,  # ue index in TL
    'cell_id_list': [3],
    'cell_pci': 94,
}

mappings = [
    {
        'scf_name': 'SCF_SBTS*_1S-1CC-8D-4U.xml',
        'ue_mapping_list': [ue_mapping_1, ue_mapping_3],
    },
    {
        'scf_name': 'SCF_SBTS*_1S-1CC-8D-4U_CHT.xml',
        'ue_mapping_list': [ue_mapping_1],
    },
    {
        'scf_name': 'SCF_SBTS*_CB009217_NR_LTE.xml',
        'ue_mapping_list': [ue_mapping_1, ue_mapping_4],
    },
    {
        'scf_name': 'SCF_SBTS*_CB009217_LTE_4CC.xml',
        'ue_mapping_list': [ue_mapping_5],
    },
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    }
]
