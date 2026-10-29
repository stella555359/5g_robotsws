__maintainer__ = 'Wu Jerry'
__team__ = 'mmw2'
__email__ = 'jerry.wu@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'mobile_network_system': 'NR',
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1],
    'ue_ul_layer': 2
}


ue_mapping_2 = {
    'mobile_network_system': 'LTE',
    'ue_index': 1,  # ue index in TL
    'cell_id_list': [0],
    'cell_pci': 388,
}


ue_mapping_3 = {
    'mobile_network_system': 'LTE',
    'ue_index': 2,  # ue index in TL
    'cell_id_list': [1],
    'cell_pci': 1,
}


ue_mapping_4 = {
    'mobile_network_system': 'LTE',
    'ue_index': 1,  # ue index in TL
    'cell_id_list': [1],
    'cell_pci': 388,
}

mappings = [
    {
        'scf_name': 'SCF_SBTS00.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R2.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS23R3.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS24R1.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_CNI123552.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R1_CNI123552.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R2_CNI123552.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_2x10NR_2x10LTE.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R1_2x10NR_2x10LTE.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R2_2x10NR_2x10LTE.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_20_20_20.xml',
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_12838_A.xml',
        'ue_mapping_list': [ue_mapping_1],
    },
    {
        'scf_name': 'SCF_SBTS25R1_12838_A.xml',
        'ue_mapping_list': [ue_mapping_1],
    },
    {
        'scf_name': 'SCF_SBTS25R2_12838_A.xml',
        'ue_mapping_list': [ue_mapping_1],
    },
    {
        'scf_name': 'SCF_SBTS00_20_20_15.xml',
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS00_1S_4cc.xml',
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS23R3_20_20_20.xml',
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS24R3_20_20_20.xml',
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS24R3_20_20_15.xml',
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS24R1_20_20_15.xml',
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS24R3_1S_4cc.xml',
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS24R1_1S_4cc.xml',
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS23R3_7499.xml',
        'ue_mapping_list': [ue_mapping_4],
    },
    {
        'scf_name': 'SCF_SBTS00_7499.xml',
        'ue_mapping_list': [ue_mapping_4],
    },
    {
        'scf_name': 'SCF_SBTS25R1_7499.xml',
        'ue_mapping_list': [ue_mapping_4],
    },
    {
        'scf_name': 'SCF_SBTS25R2_7499.xml',
        'ue_mapping_list': [ue_mapping_4],
    },
    {
        'scf_name': 'SCF_SBTS25R1.xml',
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R1_20_20_15.xml',
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R1_1S_4cc.xml',
        'ue_mapping_list': [ue_mapping_2],
    },
    {
        'scf_name': 'SCF_SBTS25R2_1S_4cc.xml',
        'ue_mapping_list': [ue_mapping_2],
    }
]
