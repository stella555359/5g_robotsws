__maintainer__ = 'Zhong Tingting'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'ul_iperf_process': 5,
    'dl_iperf_process': 5,
    'cell_id_list': [1]
}

ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'ul_iperf_process': 5,
    'dl_iperf_process': 5,
    'cell_id_list': [2]
}

mappings = [
    {
        'scf_name': 'SCF_SBTS*_1S-2CC-4D-2U.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS*_1S-2CC-4D-4U_Split_Mode.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    }
]
