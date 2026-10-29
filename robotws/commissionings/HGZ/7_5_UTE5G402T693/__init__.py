__maintainer__ = 'Annie Hu'
__team__ = '5G_PZ_HZ_5_SG'
__email__ = 'annie.hu@nokia-sbell.com'

__all__ = ['mappings', 'ui_version', 'protocol']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1]
}

ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1]
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    },
    {
        'scf_name': 'SCF_SBTS25R1_1S-2CC-8D4U_A3_50-70M_F0-7.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R1_1S-2CC-8D4U_A6_60-80M_A2-98.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R1_2S-4CC-8D8U_50M_4Rx_CB012196_7.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R1_3S-1CC-16D8U-8D8U_60M_4Rx_CB012196_8.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R2_2S-4CC-8D8U_50M_4Rx_CB012196_7.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R2_3S-1CC-16D8U-8D8U_60M_4Rx_CB012196_8.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R3_2S-4CC-8D8U_50M_4Rx_CB012196_7.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R3_3S-1CC-16D8U-8D8U_60M_4Rx_CB012196_8.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS26R1_2S-4CC-8D8U_50M_4Rx_CB012196_7.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS26R1_3S-1CC-16D8U-8D8U_60M_4Rx_CB012196_8.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_2S-4CC-8D8U_50M_4Rx_CB012196_7.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_3S-1CC-16D8U-8D8U_60M_4Rx_CB012196_8.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_2],
    }
]

ui_version = 'S21UI4.0'
protocol = 'udp'
