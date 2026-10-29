__maintainer__ = 'Yue Liu'
__team__ = '5G_PZ_HZ_5_SG'
__email__ = 'yue.2.liu@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'BOTH',
    'cell_id_list': [2],
}

ue_mapping_2 = {
    'mobile_network_system': 'LTE',
    'ue_index': 0,  # ue index in TL
    'cell_id_list': [21],
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    },
    {
       'scf_name': 'SCF_SBTS23R4_1S-1CC-NR100-LTE20.xml',  # * means all scf common
       'ue_mapping_list': [ue_mapping_2],
    },
    {
       'scf_name': 'SCF_SBTS24R1_1S-1CC-NR100-LTE20.xml',  # * means all scf common
       'ue_mapping_list': [ue_mapping_2],
    },
    {
       'scf_name': 'SCF_SBTS00_1S-1CC-NR100-LTE20.xml',  # * means all scf common
       'ue_mapping_list': [ue_mapping_2],
    }
]
