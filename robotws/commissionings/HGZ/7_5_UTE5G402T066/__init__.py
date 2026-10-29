__maintainer__ = 'Miranda Zhong'
__team__ = '5G_PZ_HZ_5_SG'
__email__ = 'miranda.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'LTE',
    'ue_index': 0,  # ue index in TL
    'cell_id_list': [1],
    'ul_iperf_process': 5
}

ue_mapping_2 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'BOTH',
    'cell_id_list': [1],
    'ul_iperf_process': 5
}


mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    },
    {
        'scf_name': 'SCF_SBTS00_1S-2CC-NR70-LTE20.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_1S-2CC-NR70-NR70.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS23R3_1S-2CC-NR70-LTE20.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS23R3_1S-2CC-NR70-NR70.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS23R4_1S-2CC-NR70-LTE20.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS23R4_1S-2CC-NR70-NR70.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS24R1_1S-2CC-NR70-LTE20.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS24R1_1S-2CC-NR70-NR70.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS24R3_1S-1CC-2D2U_SuperCell.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS24R3_1S-2CC-2DL2UL_70MHz_40MHz.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R1_1S-1CC-2D2U_SuperCell.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R1_1S-2CC-2DL2UL_70MHz_40MHz.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_1S-1CC-2D2U_SuperCell.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_1S-2CC-2DL2UL_70MHz_40MHz.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    }
]
