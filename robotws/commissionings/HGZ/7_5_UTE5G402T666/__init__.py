__maintainer__ = 'Annie Hu'
__team__ = '5G_PZ_HZ_5_SG'
__email__ = 'annie.hu@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1],
    'ue_ul_layer': 1    # now all ue ue_ul_layer should be same
}

ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [1],
    'ue_ul_layer': 1    # now all ue ue_ul_layer should be same
}

ue_mapping_3 = {
    'ue_index': 2,  # ue index in TL
    'network_type': 'SA',
    'cell_id_list': [2],
    'ue_ul_layer': 1    # now all ue ue_ul_layer should be same
}

mappings = [
    {
        'scf_name': 'SCF_SBTS00.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    },
    {
        'scf_name': 'SCF_SBTS00_1S-2CC-4D-4U_SA.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2, ue_mapping_3],
    },
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1],
    },
]
