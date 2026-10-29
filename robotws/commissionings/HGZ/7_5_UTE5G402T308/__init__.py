__maintainer__ = 'Zhong Tingting'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings']

lte_ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'cell_id_list': [1],
    'cell_pci': 308,
    'arfcn': 42590,
}

lte_ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'cell_id_list': [2],
    'cell_pci': 309,
    'arfcn': 42390,
}

lte_ue_mapping_3 = {
    'ue_index': 0,  # ue index in TL
    'cell_id_list': [0],
    'cell_pci': 308,
    'arfcn': 42590,
}

lte_ue_mapping_4 = {
    'ue_index': 1,  # ue index in TL
    'cell_id_list': [0],
    'cell_pci': 308,
    'arfcn': 42590,
}

mappings = [
    {
        'scf_name': 'SCF_SBTS*_1S-1CC-1D-1U.xml',  # * means all scf common
        'ue_mapping_list': [lte_ue_mapping_3, lte_ue_mapping_4],
    },
    {
        'scf_name': 'SCF_SBTS*_1S-2CC-1D-1U_CA.xml',  # * means all scf common
        'ue_mapping_list': [lte_ue_mapping_1],
    },
    {
        'scf_name': 'SCF_SBTS*.xml',  # * means all scf common
        'ue_mapping_list': [lte_ue_mapping_1, lte_ue_mapping_2],
    },
]
