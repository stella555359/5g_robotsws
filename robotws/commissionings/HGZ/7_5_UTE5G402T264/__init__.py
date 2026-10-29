__maintainer__ = 'Miranda Zhong'
__team__ = '5G_PZ_HZ_5_SG'
__email__ = 'miranda.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1]
}
ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1],
    'ul_iperf_process': 5
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    },
    {
        'scf_name': 'SCF_SBTS00_1S-4CC-16D8U_16Rx_CB013394-A.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_1S-4CC-16D4U_16Rx_CB012532-A.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R3_1S-4CC-16D4U_16Rx_CB012532-A.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R2_6S-1CC-16D8U_CB012827.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R3_6S-1CC-16D8U_CB012827.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_6S-1CC-16D8U_CB012827.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS26R1_1S-4CC-16D8U_16Rx_CB013394-A.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS26R1_1S-4CC-16D4U_16Rx_CB012532-A.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS26R1_6S-1CC-16D8U_CB012827.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS26R2_1S-4CC-16D8U_16Rx_CB013394-A.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS26R2_1S-4CC-16D4U_16Rx_CB012532-A.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS26R2_6S-1CC-16D8U_CB012827.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    }
]
