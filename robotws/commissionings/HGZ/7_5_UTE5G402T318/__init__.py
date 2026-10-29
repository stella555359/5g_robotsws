__maintainer__ = 'Zhong Tingting'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings']

lte_ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'cell_id_list': [1],
    'cell_pci': 318,
    'arfcn': 42090,
}

lte_ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'cell_id_list': [2],
    'cell_pci': 319,
    'arfcn': 43390,
}

mappings = [
    {
        'scf_name': 'SCF_SBTS*_1S-2CC-1D-1U_CA.xml',  # * means all scf common
        'ue_mapping_list': [lte_ue_mapping_1],
    },
    {
        'scf_name': 'SCF_SBTS*.xml',  # * means all scf common
        'ue_mapping_list': [lte_ue_mapping_1, lte_ue_mapping_2],
    }
]
